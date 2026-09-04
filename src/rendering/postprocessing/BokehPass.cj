/**
 * @file[zh-cn] BokehPass 景深（Depth of Field）后处理 pass
 * @brief[zh-cn] 景深（DOF）后处理 pass —— 带散景（bokeh）的镜头模糊
 * @explain[zh-cn] 算法（完整非简化移植）：
 *         1. 深度 pass：用 bokeh_depth shader（对照 MeshDepthMaterial + RGBADepthPacking）
 *           把场景 NDC 深度 packDepthToRGBA 打包写入深度 RT（RGBA16F，等价 HalfFloatType）
 *         2. bokeh 合成 pass：全屏四边形 41 抽头 lens blur —— 每个抽头按
 *           dofblur = clamp(factor * aperture, -maxblur, maxblur) 偏移采样 tColor，
 *           factor = focus - viewZ（bgfx 左手系 viewZ 为正；右手系 viewZ<=0 用 focus+viewZ）
 *         3. 输出到 writeBuffer（或 renderToScreen 时直接上屏）
 *         流程：
 *         - 先渲深度（scene 几何 → bokeh_depth → 深度 RT，clear 白=far）
 *         - 再 bokeh 合成（tColor=readBuffer.color0, tDepth=深度 RT, 41 抽头）
 *         - setSize 时销毁重建深度 RT 并更新 aspect（uniforms.aspect = w/h + RT.setSize）
 *         渲染差异：
 *         - 用 MeshDepthMaterial(scene.overrideMaterial) + renderer.render；bgfx 复用
 *           PostProcessingShaders.get("bokeh_depth") 几何 shader，自建几何 + shader 直接 submit
 *           （走"自建几何 + shader override"路径，避免渲染线程并发改写 mesh.material 风险，
 *           参照 SSRPass._renderDepth 范式）。
 *         - uniforms 是 float；bgfx uniform 最小单位 vec4，故用 u_focus/u_aspect/u_aperture/
 *           u_maxblur/u_nearClip/u_farClip（vec4.x=值）。
 *         - tColor/tDepth 是 sampler2D；bgfx 用 SAMPLER2D 宏声明，tColor 绑 stage 0
 *           （readBuffer.color0），tDepth 绑 stage 1（深度 RT color attachment）。
 *         - bgfx view id 全局稀缺，本 pass 用 BOKEH_VIEW_ID_BASE=228（避开既有硬编码段：
 *           SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
 *           TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
 *           DotScreenPass 226 / HalftonePass 227）。+0=深度 pass, +1=bokeh 合成。
 *         - 深度 RT 是 HalfFloatType + NearestFilter；bgfx 用 RGBA16F + MIN_POINT|MAG_POINT。
 *         用法：
 *         let bokehPass = BokehPass(scene, camera, focus: 500.0, aperture: 5.0, maxblur: 0.01)
 *         composer.addPass(bokehPass)
 *         运行时调参：bokehPass.focus / bokehPass.aperture / bokehPass.maxblur（render 内每帧同步）
 *
 * @file[en] BokehPass Depth of Field post-processing pass
 * @brief[en] Depth of Field (DOF) post-processing pass - lens blur with bokeh
 * @explain[en] Algorithm (full non-simplified port):
 *         1. Depth pass: uses the bokeh_depth shader (mapped from MeshDepthMaterial +
 *            RGBADepthPacking) to pack the scene NDC depth via packDepthToRGBA into the depth RT
 *            (RGBA16F, equivalent to HalfFloatType)
 *         2. Bokeh composite pass: full-screen quad 41-tap lens blur - each tap offsets the tColor
 *            sample by dofblur = clamp(factor * aperture, -maxblur, maxblur),
 *            factor = focus - viewZ (bgfx left-handed: viewZ is positive; right-handed: viewZ<=0
 *            uses focus+viewZ)
 *         3. Output to writeBuffer (or straight to screen when renderToScreen)
 *         Flow:
 *         - First render depth (scene geometry → bokeh_depth → depth RT, clear white = far)
 *         - Then bokeh composite (tColor=readBuffer.color0, tDepth=depth RT, 41 taps)
 *         - On setSize, destroy and rebuild the depth RT and update aspect
 *           (uniforms.aspect = w/h + RT.setSize)
 *         Rendering differences:
 *         - MeshDepthMaterial(scene.overrideMaterial) + renderer.render; bgfx reuses the
 *           PostProcessingShaders.get("bokeh_depth") geometry shader and submits it directly with
 *           self-built geometry + shader (the "self-built geometry + shader override" path, avoiding
 *           concurrent render-thread mutation of mesh.material, following the SSRPass._renderDepth pattern).
 *         - uniforms are float; bgfx uniforms have a minimum vec4 unit, so u_focus/u_aspect/u_aperture/
 *           u_maxblur/u_nearClip/u_farClip are used (vec4.x = value).
 *         - tColor/tDepth are sampler2D; bgfx declares them with the SAMPLER2D macro, tColor bound to
 *           stage 0 (readBuffer.color0), tDepth bound to stage 1 (depth RT color attachment).
 *         - bgfx view ids are globally scarce; this pass uses BOKEH_VIEW_ID_BASE=228 (avoiding existing
 *           hardcoded ranges: SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 / TAA 219~220 /
 *           Afterimage 221~223 / FilmPass 224 / GlitchPass 225 / DotScreenPass 226 / HalftonePass 227).
 *           +0 = depth pass, +1 = bokeh composite.
 *         - The depth RT is HalfFloatType + NearestFilter; bgfx uses RGBA16F + MIN_POINT|MAG_POINT.
 *         Usage:
 *         let bokehPass = BokehPass(scene, camera, focus: 500.0, aperture: 5.0, maxblur: 0.01)
 *         composer.addPass(bokehPass)
 *         Runtime tuning: bokehPass.focus / bokehPass.aperture / bokehPass.maxblur
 *         (synced to bgfx uniforms inside render every frame)
 *
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.common.RenderObject
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.scene.scenegraph.Scene
import three.rendering.cameras.Camera
import three.scene.entity.Mesh
import three.scene.objects.Object3D
import three.rendering.geometry.BufferGeometry
import three.core.math.Matrix4
import three.rendering.types.*
import three.rendering.bgfx.BgfxAttributeDesc
import std.collection.*

/**
 * @brief[zh-cn] 景深（DOF）后处理 pass
 * @brief[en] Depth of Field (DOF) post-processing pass
 * @explain[zh-cn] 内部 2 遍：深度 pass（bokeh_depth）+ bokeh 合成 pass（bokeh，41 抽头 lens blur）。
 *         focus/aperture/maxblur 以 public 字段暴露，运行时修改字段 → render() 内每帧同步到 bgfx uniform。
 * @explain[en] Internally 2 passes: a depth pass (bokeh_depth) + a bokeh composite pass
 *         (bokeh, 41-tap lens blur). focus/aperture/maxblur are exposed as public fields; modifying
 *         them at runtime syncs to bgfx uniforms inside render() every frame.
 */
public class BokehPass <: Pass {
    /**
     * @brief[zh-cn] 焦点距离（世界单位，沿相机朝向）
     * @brief[en] Focal distance (world units, along the camera direction)
     * @explain[zh-cn] 默认 1.0。
     * @explain[en] Default 1.0.
     */
    public var focus: Float64

    /**
     * @brief[zh-cn] 光圈（越大景深越浅）
     * @brief[en] Aperture (larger = shallower depth of field)
     * @explain[zh-cn] 默认 0.025。
     * @explain[en] Default 0.025.
     */
    public var aperture: Float64

    /**
     * @brief[zh-cn] 最大模糊量（控制散景半径上限）
     * @brief[en] Maximum blur (caps the bokeh radius)
     * @explain[zh-cn] 默认 1.0。
     * @explain[en] Default 1.0.
     */
    public var maxblur: Float64

    /**
     * 调试输出模式（测试项目按键切换，中间步骤独立呈现）：
     *   0 = 完整 bokeh 流程（41 抽头 lens blur，默认）
     *   1 = 深度图可视化（tDepth 解包 → 灰度伪彩显示）
     *   2 = 原图直出（tColor 透传，跳过模糊）
     * 非 0 时 bokeh shader 跳过 41 抽头，直接输出对应中间结果。
     * 注：此为测试辅助扩展，不改变默认 0 的语义。
     */
    public var debugMode: Int64 = 0

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: 深度 pass（场景几何 → bokeh_depth → 深度 RT）
     *   +1: bokeh 合成 pass（41 抽头 lens blur → writeBuffer/屏幕）
     * 取 228 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
     * SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
     * SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
     * DotScreenPass 226 / HalftonePass 227。
     */
    public static let BOKEH_VIEW_ID_BASE: UInt16 = 228u16

    /** 待渲场景。 */
    private var _scene: Option<Scene> = None

    /** 相机。 */
    private var _camera: Option<Camera> = None

    /** 深度 RT color texture（RGBA16F，packDepthToRGBA 打包深度）。 */
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 深度 RT 的 depth attachment（D24，深度 pass 深度测试用） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 深度 RT frame buffer。 */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /** 深度 RT 尺寸缓存 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    /** bokeh_depth shader 是否已编译 */
    private var _depthCompiled: Bool = false

    /** bokeh_depth program handle 缓存 */
    private var _depthProg: Option<ProgramHandle> = None

    /** bokeh shader 是否已编译 */
    private var _bokehCompiled: Bool = false

    /** bokeh program handle 缓存 */
    private var _bokehProg: Option<ProgramHandle> = None

    // ===== 场景几何体缓存（对齐 SSRPass._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，setSize/dispose 销毁 GPU 资源时经其高阶 API 序列化） */
    private var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造 BokehPass。
     *
     * @param scene 待渲场景（深度 pass 用）
     * @param camera 相机（view transform / near / far / aspect）
     * @param focus 焦点距离（默认 1.0）
     * @param aperture 光圈（默认 0.025）
     * @param maxblur 最大模糊量（默认 1.0）
     */
    public init(
        scene: Scene,
        camera: Camera,
        focus!: Float64 = 1.0,
        aperture!: Float64 = 0.025,
        maxblur!: Float64 = 1.0
    ) {
        super()
        this._scene = Some(scene)
        this._camera = Some(camera)
        this.focus = focus
        this.aperture = aperture
        this.maxblur = maxblur
        // needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
        Logger.trace(["bokeh", "BokehPass constructed: focus=" + focus.toString() +
                      " aperture=" + aperture.toString() +
                      " maxblur=" + maxblur.toString() +
                      " cameraNear=" + camera.near.toString() +
                      " cameraFar=" + camera.far.toString() +
                      " (aspect synced from width/height in render)"])
    }

    /**
     * 设置 pass 尺寸。
     * 深度 RT 尺寸与渲染目标一致（setSize 时同步），
     * 且 aspect 同步更新（aspect = width / height）。
     *
     * @param width 目标宽（像素）
     * @param height 目标高（像素）
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            Logger.trace(["bokeh", "setSize: " + width.toString() + "x" + height.toString() +
                          " (depth RT will be recreated on next render)"])
        }
    }

    // ===== RT 创建/销毁 =====

    /**
     * 创建深度 RT（RGBA16F + D24 depth attachment）。
     * 配置：RGBA16F + MIN_POINT|MAG_POINT（最近邻采样，避免深度插值）。
     */
    private func _ensureRTs(renderer: BgfxRenderer): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (isValidHandle(this._depthTex)) { return }

        Logger.trace(["bokeh", "_ensureRTs: creating depth RT ${this._width}x${this._height}"])

        let depthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)
        Logger.trace(["bokeh", "  depthFB created: depthTex=${handleIdx(depthTex)} depthDepthTex=${handleIdx(depthDepthTex)}"])
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: BgfxRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /** 销毁深度 RT（setSize 重建或 dispose 时调用） */
    private func _destroyRTs(): Unit {
        let depthFB = this._depthFB
        let depthTex = this._depthTex
        let depthDepthTex = this._depthDepthTex
        match (this._renderer) {
            case Some(renderer) =>
                if (isValidHandle(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (isValidHandle(depthTex)) { renderer.destroyTexture(depthTex) }
                if (isValidHandle(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
            case None => ()
        }
        this._depthFB = INVALID_FRAME_BUFFER_HANDLE
        this._depthTex = INVALID_TEXTURE_HANDLE
        this._depthDepthTex = INVALID_TEXTURE_HANDLE
    }

    // ===== 场景几何体缓存（对齐 SSRPass/_renderDepth 范式） =====

    private func _getOrCreateLayout(renderer: BgfxRenderer): VertexLayoutHandle {
        match (this._layoutHandleCache) {
            case Some(lh) => return lh
            case None => ()
        }
        // 经 renderer.createVertexLayout(attrs) 高阶 API 创建布局句柄（封装 begin/add/end/create 序列）。
        // _createVB 经 renderer.createVertexBufferFromLayout(handle) 创建顶点缓冲
        // （renderer 内部从 handle 查回 layout 内存指针，无须接触 CPointer<VertexLayout>）。
        let handle = renderer.createVertexLayout(this._getLayoutAttrs())
        this._layoutHandleCache = Some(handle)
        return handle
    }

    /** 构建顶点布局属性描述（对齐旧 begin/add/end 序列：position(3) + normal(3) + color(4) + uv(2)） */
    private func _getLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        let normal = BgfxAttributeDesc()
        normal.attrib = Attrib.Normal.value()
        normal.num = 3u8
        normal.attribType = AttribType.Float.value()
        normal.normalized = true
        normal.asInt = false
        list.add(normal)
        let color = BgfxAttributeDesc()
        color.attrib = Attrib.Color0.value()
        color.num = 4u8
        color.attribType = AttribType.Float.value()
        color.normalized = false
        color.asInt = false
        list.add(color)
        let uv = BgfxAttributeDesc()
        uv.attrib = Attrib.TexCoord0.value()
        uv.num = 2u8
        uv.attribType = AttribType.Float.value()
        uv.normalized = false
        uv.asInt = false
        list.add(uv)
        return list.toArray()
    }

    private func _createVB(renderer: BgfxRenderer, geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._vbCache.get(geomId)) {
            case Some(vb) => return vb
            case None => ()
        }
        let posAttrOpt = geom.getAttribute("position")
        match (posAttrOpt) {
            case Some(pos) =>
                let vc = pos.count
                if (vc == 0) { return INVALID_VERTEX_BUFFER_HANDLE }
                // position(3) + normal(3) + color(4) + uv(2) = 12 floats
                let vertStride: Int64 = 12
                let totalFloats = vc * vertStride
                let data = Array<Float64>(totalFloats, { i => 0.0 })
                let normAttrOpt = geom.getAttribute("normal")
                let colAttrOpt = geom.getAttribute("color")
                let uvAttrOpt = geom.getAttribute("uv")
                for (vi in 0..vc) {
                    let base = vi * vertStride
                    data[base] = pos.getX(vi)
                    data[base + 1] = pos.getY(vi)
                    data[base + 2] = pos.getZ(vi)
                    match (normAttrOpt) {
                        case Some(na) =>
                            data[base + 3] = na.getX(vi)
                            data[base + 4] = na.getY(vi)
                            data[base + 5] = na.getZ(vi)
                        case None => data[base + 5] = 1.0
                    }
                    match (colAttrOpt) {
                        case Some(ca) =>
                            data[base + 6] = ca.getX(vi)
                            data[base + 7] = ca.getY(vi)
                            data[base + 8] = ca.getZ(vi)
                            data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                        case None =>
                            for (j in 0..4) { data[base + 6 + j] = 1.0 }
                    }
                    match (uvAttrOpt) {
                        case Some(ua) =>
                            data[base + 10] = ua.getX(vi)
                            data[base + 11] = ua.getY(vi)
                        case None => ()
                    }
                }
                let mem = BgfxMemory(UInt32(totalFloats * 4))
                mem.writeFloats(data, totalFloats)
                let layout = this._getOrCreateLayout(renderer)
                let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
                this._vbCache.add(geomId, handle)
                return handle
            case None => return INVALID_VERTEX_BUFFER_HANDLE
        }
    }

    private func _createIB(renderer: BgfxRenderer, geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._ibCache.get(geomId)) {
            case Some(ib) => return ib
            case None => ()
        }
        match (geom.index) {
            case Some(idxAttr) =>
                let count = idxAttr.count
                if (count == 0) { return INVALID_INDEX_BUFFER_HANDLE }
                let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
                let mem = BgfxMemory(UInt32(count * 2))
                mem.writeUInt16(idxData, count)
                let handle = renderer.createIndexBuffer(mem, flags: 0u16)
                this._ibCache.add(geomId, handle)
                return handle
            case None => return INVALID_INDEX_BUFFER_HANDLE
        }
    }

    /** 收集场景中所有 Mesh（递归遍历 children，对齐 SSRPass._collectMeshes） */
    private func _collectMeshes(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectMeshes(child, renderObjects)
            }
            if (child.kind == "Mesh") {
                match (child as Mesh) {
                    case Some(mesh) =>
                        let ro = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        renderObjects.add(ro)
                    case None => ()
                }
            }
        }
    }

    /** 设置 view transform（view=matrixWorldInverse, proj=projectionMatrix，对齐 SSRPass） */
    private func _setViewTransformFor(renderer: BgfxRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.toArray(Array<Float64>(16, { _ => 0.0 }))
        let projArr = camera.projectionMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
    }

    // ===== shader 编译 =====

    /**
     * 编译 bokeh_depth shader（深度 pass 用）。
     * 功能等价 MeshDepthMaterial（RGBADepthPacking + NoBlending）。
     */
    private func _compileDepth(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("bokeh_depth")) {
            case Some(sp) =>
                if (!this._depthCompiled) {
                    sp.compileBgfx()
                    this._depthProg = Some(Box(sp.programHandle))
                    this._depthCompiled = true
                    Logger.trace(["bokeh", "bokeh_depth shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._depthProg
            case None =>
                Logger.trace(["bokeh", "bokeh_depth shader not registered"])
                return None
        }
    }

    /**
     * 编译 bokeh shader（合成 pass 用）。
     * 功能等价 ShaderMaterial（BokehShader）。
     */
    private func _compileBokeh(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("bokeh")) {
            case Some(sp) =>
                if (!this._bokehCompiled) {
                    sp.compileBgfx()
                    this._bokehProg = Some(Box(sp.programHandle))
                    this._bokehCompiled = true
                    Logger.trace(["bokeh", "bokeh shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._bokehProg
            case None =>
                Logger.trace(["bokeh", "bokeh shader not registered"])
                return None
        }
    }

    /**
     * 设置单个 vec4 uniform（x=value, y/z/w=0）。辅助方法，简化 6 个 uniforms 的设置。
     */
    private func setUniformVec4(
        renderer: BgfxRenderer,
        uniforms: BgfxUniforms,
        name: String,
        value: Float64
    ): Unit {
        let handle = uniforms.createUniform(name, UniformType.Vec4.value())
        let mem = BgfxMemory(16u32)
        mem.writeFloats([value, 0.0, 0.0, 0.0], 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    // ===== Pass.render 入口 =====

    /**
     * 执行 BokehPass。
     *
     * 流程：
     *   1. 深度 pass（view+0）：场景几何 → bokeh_depth → 深度 RT（clear 白=far，packDepthToRGBA）
     *   2. bokeh 合成 pass（view+1）：全屏四边形 41 抽头 lens blur，tColor=readBuffer.color0,
     *      tDepth=深度 RT → writeBuffer（或 renderToScreen 时上屏）
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 的输出目标）
     * @param readBuffer 读 buffer（上一 pass 结果，绑到 tColor）
     * @param deltaTime 帧间隔（秒）
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        if (!this.enabled) { return }
        this._renderer = Some(renderer)
        // 尺寸未设置时默认取渲染器尺寸（composer.setSize 会转发，但防御性兜底）
        if (this._width <= 0 || this._height <= 0) {
            this._width = Int64(renderer.width)
            this._height = Int64(renderer.height)
        }

        let sceneOpt = this._scene
        let camOpt = this._camera
        match (sceneOpt) {
            case Some(scene) => match (camOpt) {
                case Some(camera) =>
                    this._ensureRTs(renderer)
                    if (!isValidHandle(this._depthFB)) {
                        Logger.trace(["bokeh", "render: _ensureRTs failed, depthFB invalid"])
                        return
                    }

                    let baseView = BokehPass.BOKEH_VIEW_ID_BASE

                    // ===== 1. 深度 pass（view+0）=====
                    // overrideMaterial=深度材质，clear(白=far)，再渲场景
                    this._renderDepth(renderer, scene, camera, baseView)

                    // ===== 2. bokeh 合成 pass（view+1）=====
                    this._renderBokeh(renderer, camera, readBuffer, writeBuffer,
                                      UInt16(UInt16(baseView) + 1u16))

                    Logger.trace(["bokeh", "render done: focus=" + this.focus.toString() +
                                  " aperture=" + this.aperture.toString() +
                                  " maxblur=" + this.maxblur.toString() +
                                  " depthFB=${handleIdx(this._depthFB)} readBuffer=${handleIdx(readBuffer)}"])
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * 深度 pass：bokeh_depth shader 渲场景到深度 RT（写 packDepthToRGBA(gl_FragCoord.z)）。
     * overrideMaterial=深度材质，clear 为白色（ABGR=0xFFFFFFFF → RGBA=(1,1,1,1) → unpack 深度=1.0=far）：
     * 背景无片元时保持 far，bokeh shader 用深度 1.0 → viewZ=far → factor=focus-far → 背景全糊。
     */
    private func _renderDepth(renderer: BgfxRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        match (this._compileDepth()) {
            case Some(depthProg) =>
                if (!isValidHandle(depthProg)) {
                    Logger.trace(["bokeh", "depth pass: bokeh_depth program compile FAILED"])
                    return
                }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (isValidHandle(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let depthRenderState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                           BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                           BgfxConstants.FRONT_CCW
                    renderer.setState(depthRenderState, rgba: 0x00000000u32)
                    renderer.submit(viewId, depthProg, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
                Logger.trace(["bokeh", "depth pass done: prog=${handleIdx(depthProg)} submitCnt=${submitCnt}"])
            case None => Logger.trace(["bokeh", "depth pass: bokeh_depth shader NOT registered"])
        }
    }

    /**
     * bokeh 合成 pass：全屏四边形 41 抽头 lens blur。
     *
     * 输出目标：renderToScreen=true（最后一个 enabled pass）→ swap chain；否则 → writeBuffer。
     * nearClip/farClip 每帧从相机同步。
     */
    private func _renderBokeh(
        renderer: BgfxRenderer,
        camera: Camera,
        readBuffer: FrameBufferHandle,
        writeBuffer: FrameBufferHandle,
        viewId: UInt16
    ): Unit {
        let w = UInt16(this._width)
        let h = UInt16(this._height)
        this.setViewport(renderer, viewId, 0u16, 0u16, w, h)

        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        match (this._compileBokeh()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["bokeh", "bokeh pass: bokeh program compile FAILED"])
                    return
                }

                let uniforms = BgfxUniforms()

                // stage 0 = tColor（readBuffer 的 color 0）
                let uColor = uniforms.createUniform("tColor", UniformType.Sampler.value())
                let colorTex = this.getTexture(renderer, readBuffer, 0u8)
                this.bindTexture(renderer, 0u8, uColor, colorTex, 0u32)

                // stage 1 = tDepth（深度 RT 的 color 0）
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                let depthTex = this.getTexture(renderer, this._depthFB, 0u8)
                this.bindTexture(renderer, 1u8, uDepth, depthTex, 0u32)

                // 6 个 uniforms（bgfx 最小单位 vec4，x=value）
                this.setUniformVec4(renderer, uniforms, "u_focus",    this.focus)
                // aspect = width/height（setSize 时随尺寸更新）
                let aspect = Float64(this._width) / Float64(if (this._height > 0) { this._height } else { 1 })
                this.setUniformVec4(renderer, uniforms, "u_aspect",   aspect)
                this.setUniformVec4(renderer, uniforms, "u_aperture", this.aperture)
                this.setUniformVec4(renderer, uniforms, "u_maxblur",  this.maxblur)
                this.setUniformVec4(renderer, uniforms, "u_nearClip", camera.near)
                this.setUniformVec4(renderer, uniforms, "u_farClip",  camera.far)
                this.setUniformVec4(renderer, uniforms, "u_debugMode", Float64(this.debugMode))

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                Logger.trace(["bokeh", "bokeh pass: view=" + viewId.toString() +
                              " focus=" + this.focus.toString() +
                              " aspect=" + aspect.toString() +
                              " aperture=" + this.aperture.toString() +
                              " maxblur=" + this.maxblur.toString() +
                              " nearClip=" + camera.near.toString() +
                              " farClip=" + camera.far.toString() +
                              " tSize=" + this._width.toString() + "x" + this._height.toString()])
            case None =>
                Logger.trace(["bokeh", "bokeh pass: bokeh shader compile failed, skip pass"])
        }
    }

    /**
     * 释放 BokehPass 占用的所有 GPU 资源。
     * bokeh/bokeh_depth shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
     * 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        // 释放场景几何体共享 layout handle
        match (this._renderer) {
            case Some(renderer) =>
                match (this._layoutHandleCache) {
                    case Some(lh) =>
                        renderer.destroyVertexLayout(lh)
                        this._layoutHandleCache = None
                    case None => ()
                }
            case None => ()
        }
        Logger.trace(["bokeh", "disposed"])
    }
}
