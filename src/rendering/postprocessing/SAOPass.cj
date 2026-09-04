package three.rendering.postprocessing

/**
 * @file[zh-cn] BgfxSAOPass 尺度敏感环境光遮蔽（SAO）后处理 pass
 * @brief[zh-cn] 尺度敏感环境光遮蔽（SAO）后处理 pass
 * @explain[zh-cn] 以 EffectComposer Pass 链方式注入（对齐 bloom/ssao/gtao 的 Bgfx*Pass）：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(BgfxSAOPass(scene, camera))
 *         composer.render()
 *         render() 内部（每帧经 renderer.execBgfx 序列化到渲染线程）：
 *         1. 法线 pass（view SAO_VIEW_ID_BASE+0）：normal shader 渲场景法线到法线 RT（RGBA16F+D24）
 *         2. 深度 pass（view +1）：aodepth shader 渲场景 NDC 深度到深度 RT（RGBA32F+D24）
 *         3. SAO 计算 pass（view +2）：全屏四边形采样法线/深度，输出 1-occlusion 到 sao RT（RGBA16F）
 *         4. vBlur pass（view +3）：深度受限高斯模糊（方向 0,1）→ blur RT（RGBA16F）
 *         5. hBlur pass（view +4）：深度受限高斯模糊（方向 1,0）→ 写回 sao RT
 *         6. 输出 pass（view +5）：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）
 *            Default：sceneColor × ao（saoapply）；SAO/Normal：copy 透传对应纹理
 *         自包含：uniforms（BgfxUniforms 实例）、全屏四边形（composer 共享 quad）、
 *         场景几何体 VB/IB/layout 均在 pass 内懒创建并缓存，不依赖 BgfxBackend 内部资源
 *         （避免 bgfx_backend ↔ postprocessing 包循环依赖，对齐 BgfxSSAOPass/BgfxGTAOPass 自包含模式）。
 *         移植要点：
 *         - 噪声：原 SAO 用 rand() 内联，bgfx 无 rand → SAO_FS 内联实现
 *         - blur：DepthLimitedBlurShader 的 sampleUvOffsets/sampleWeights 数组 → uniform vec4 数组
 *           u_sampleOffsets[9]/u_sampleWeights[9]，CPU 端按 configure 生成
 *           （gaussian 权重 + 方向偏移），KERNEL_RADIUS 固定 8（默认 saoBlurRadius=8）
 *         - 输出：materialCopy + CustomBlending(乘法) 两步 → saoapply shader 一步 sceneColor × ao
 *
 * @file[en] BgfxSAOPass scale-aware ambient occlusion (SAO) post-processing pass
 * @brief[en] Scale-aware ambient occlusion (SAO) post-processing pass
 * @explain[en] Injected via the EffectComposer Pass chain (aligned with the Bgfx*Pass bloom/ssao/gtao style):
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(BgfxSAOPass(scene, camera))
 *         composer.render()
 *         Inside render() (each frame serialized to the render thread via renderer.execBgfx):
 *         1. Normal pass (view SAO_VIEW_ID_BASE+0): normal shader renders scene normals to a normal RT (RGBA16F+D24)
 *         2. Depth pass (view +1): aodepth shader renders scene NDC depth to a depth RT (RGBA32F+D24)
 *         3. SAO compute pass (view +2): full-screen quad samples normals/depth, outputs 1-occlusion to the sao RT (RGBA16F)
 *         4. vBlur pass (view +3): depth-limited gaussian blur (direction 0,1) → blur RT (RGBA16F)
 *         5. hBlur pass (view +4): depth-limited gaussian blur (direction 1,0) → writes back to the sao RT
 *         6. Output pass (view +5): outputs to writeBuffer per output mode (writes to screen when renderToScreen=true)
 *            Default: sceneColor × ao (saoapply); SAO/Normal: copy pass-through of the corresponding texture
 *         Self-contained: uniforms (BgfxUniforms instance), full-screen quad (composer shared quad),
 *         and scene geometry VB/IB/layout are lazily created and cached inside the pass, not depending on BgfxBackend internals
 *         (avoiding a bgfx_backend ↔ postprocessing package cycle, aligned with the BgfxSSAOPass/BgfxGTAOPass self-contained pattern).
 *         Porting notes:
 *         - Noise: the original SAO inlines rand(), bgfx has no rand → inlined in SAO_FS
 *         - blur: DepthLimitedBlurShader sampleUvOffsets/sampleWeights arrays → uniform vec4 arrays
 *           u_sampleOffsets[9]/u_sampleWeights[9], generated on CPU per configure
 *           (gaussian weights + direction offsets), KERNEL_RADIUS fixed at 8 (default saoBlurRadius=8)
 *         - Output: materialCopy + CustomBlending(multiply) two steps → saoapply shader one step sceneColor × ao
 *
 * @package three.rendering.postprocessing
 */

import three.rendering.common.*
import three.rendering.bgfx.*
import three.rendering.shaders.ShaderLibs
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.Mesh
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import std.collection.*
import std.math.*

public class BgfxSAOPass <: Pass {
    /** SAO pass 用的 view ID 段约定：SSAO 160~164，GTAO 165~169，SAO 170~175，composer 分配 230+ */
    public static let SAO_VIEW_ID_BASE: UInt16 = 170u16

    /** 输出模式 */
    public static let OUTPUT_DEFAULT: Int64 = 0
    public static let OUTPUT_SAO: Int64 = 1
    public static let OUTPUT_NORMAL: Int64 = 2

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _normalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 法线 RT 的 depth attachment（D24，法线 pass 深度测试用） */
    private var _normalDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT（RGBA32F，存 NDC 深度 gl_FragCoord.z，SAO shader 用 perspectiveDepthToViewZ 反算 viewZ） */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT 的 depth attachment（D24，深度 pass 深度测试用） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** SAO 遮蔽 RT（RGBA16F，存 1-occlusion） */
    private var _saoFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _saoTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** blur 中间 RT（RGBA16F，vBlur 中间结果） */
    private var _blurFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blurTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** RT 尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    // ===== SAO 参数 =====
    /** 输出模式（默认 Default=0，AO 乘到场景色） */
    public var output: Int64 = 0
    /** 遮蔽偏置（默认 0.5） */
    public var saoBias: Float64 = 0.5
    /** 遮蔽强度（默认 0.18） */
    public var saoIntensity: Float64 = 0.18
    /** 遮蔽尺度（默认 1） */
    public var saoScale: Float64 = 1.0
    /** 采样核半径（视图空间距离，默认 100） */
    public var saoKernelRadius: Float64 = 100.0
    /** 最小分辨率（默认 0） */
    public var saoMinResolution: Float64 = 0.0
    /** 是否启用深度受限模糊（默认 true） */
    public var saoBlur: Bool = true
    /** 模糊半径（默认 8） */
    public var saoBlurRadius: Int64 = 8
    /** 模糊标准差（默认 4） */
    public var saoBlurStdDev: Float64 = 4.0
    /** 模糊深度截止（视图空间深度差阈值，默认 0.01） */
    public var saoBlurDepthCutoff: Float64 = 0.01

    /** 本 pass 自有的 uniform 注册表（对齐 BgfxSSAOPass/BgfxGTAOPass 自包含模式） */
    private var _uniforms: BgfxUniforms = BgfxUniforms()

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，dispose/_destroyRTs 经其高阶 API 销毁资源） */
    private var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造：`new SAOPass(scene, camera, resolution)`。
     * 默认输出 Default（0）；needsSwap=true（composer 链约定，写 writeBuffer 后交换）。
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this._scene = Some(scene)
        this._camera = Some(camera)
        this.needsSwap = true
    }

    /** 设置 RT 尺寸（与渲染目标一致；composer.setSize 转发调用） */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            Logger.trace(["sao", "setSize=${width}x${height}"])
        }
    }

    // ===== RT 创建/销毁 =====

    private func _ensureRTs(renderer: BgfxRenderer): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (isValidHandle(this._normalTex)) { return }

        // 法线 RT：RGBA16F + D24 depth attachment
        let normalTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalTex = normalTex
        let normalDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._normalDepthTex = normalDepthTex
        this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)

        // 深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z）
        let depthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA32F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)

        // SAO 遮蔽 RT：RGBA16F
        let saoTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._saoTex = saoTex
        this._saoFB = this._createFB(renderer, saoTex)

        // blur 中间 RT：RGBA16F
        let blurTex = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP),
            None)
        this._blurTex = blurTex
        this._blurFB = this._createFB(renderer, blurTex)

        Logger.trace(["sao", "_ensureRTs done ${this._width}x${this._height}"])
    }

    private func _createFB(renderer: BgfxRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: BgfxRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let normalFB = this._normalFB; let depthFB = this._depthFB
                let saoFB = this._saoFB; let blurFB = this._blurFB
                let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
                let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
                let saoTex = this._saoTex; let blurTex = this._blurTex
                if (isValidHandle(normalFB)) { renderer.destroyFrameBuffer(normalFB) }
                if (isValidHandle(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (isValidHandle(saoFB)) { renderer.destroyFrameBuffer(saoFB) }
                if (isValidHandle(blurFB)) { renderer.destroyFrameBuffer(blurFB) }
                if (isValidHandle(normalTex)) { renderer.destroyTexture(normalTex) }
                if (isValidHandle(normalDepthTex)) { renderer.destroyTexture(normalDepthTex) }
                if (isValidHandle(depthTex)) { renderer.destroyTexture(depthTex) }
                if (isValidHandle(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
                if (isValidHandle(saoTex)) { renderer.destroyTexture(saoTex) }
                if (isValidHandle(blurTex)) { renderer.destroyTexture(blurTex) }
                this._normalFB = INVALID_FRAME_BUFFER_HANDLE
                this._normalTex = INVALID_TEXTURE_HANDLE
                this._normalDepthTex = INVALID_TEXTURE_HANDLE
                this._depthFB = INVALID_FRAME_BUFFER_HANDLE
                this._depthTex = INVALID_TEXTURE_HANDLE
                this._depthDepthTex = INVALID_TEXTURE_HANDLE
                this._saoFB = INVALID_FRAME_BUFFER_HANDLE
                this._saoTex = INVALID_TEXTURE_HANDLE
                this._blurFB = INVALID_FRAME_BUFFER_HANDLE
                this._blurTex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    // ===== 自建场景几何体 VB/IB/layout（对齐 BgfxBackend._createVB/_createIB 模式） =====

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

    // ===== Blur 权重/偏移生成 =====

    /**
     * 高斯权重：
     * exp(-x²/(2·stdDev²)) / (sqrt(2π)·stdDev)
     */
    private func _gaussian(x: Float64, stdDev: Float64): Float64 {
        return exp(-(x * x) / (2.0 * stdDev * stdDev)) / (sqrt(2.0 * PI) * stdDev)
    }

    /**
     * 生成 blur 偏移与权重。
     * @param dirX dirY 方向（vBlur=(0,1)，hBlur=(1,0)）
     * @return 两个 9 元素数组：offsets(像素单位，shader 内除以 size 转 uv)、weights(高斯权重)
     */
    private func _generateBlurData(dirX: Float64, dirY: Float64): (Array<Float64>, Array<Float64>) {
        let radius = this.saoBlurRadius
        let stdDev = this.saoBlurStdDev
        let offsets = Array<Float64>(9 * 2, { _ => 0.0 })
        let weights = Array<Float64>(9 * 4, { _ => 0.0 })
        for (i in 0..9) {
            if (i <= radius) {
                offsets[i * 2 + 0] = dirX * Float64(i)
                offsets[i * 2 + 1] = dirY * Float64(i)
                weights[i * 4 + 0] = this._gaussian(Float64(i), stdDev)
            } else {
                // 超出半径的项权重为 0（KERNEL_RADIUS 固定 8，shader 数组 9 项）
                offsets[i * 2 + 0] = 0.0
                offsets[i * 2 + 1] = 0.0
                weights[i * 4 + 0] = 0.0
            }
        }
        return (offsets, weights)
    }

    // ===== Pass.render 入口 =====

    /**
     * Pass.render 入口：执行 SAO 链并输出遮蔽应用到场景。
     *
     * 流程：
     *   1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SAO 计算（view+2）→
     *   4. vBlur（view+3）→ 5. hBlur（view+4）→ 6. 输出（view+5）
     *
     * 子渲染方法各自走 Pass 基类高阶 API（内部经 renderer.execBgfx 序列化到渲染线程），
     * 不再外层包 execBgfx 闭包（避免嵌套死锁）。对齐 BgfxSSAOPass.render。
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
                    if (!isValidHandle(this._normalFB)) { Logger.trace(["sao", "render: _ensureRTs failed, normalFB invalid"]); return }

                    let baseView = BgfxSAOPass.SAO_VIEW_ID_BASE
                    let uniforms = this._uniforms

                    // ===== 1. 法线 pass（view+0）：normal shader 渲场景到法线 RT =====
                    this._renderNormals(renderer, scene, camera, baseView)
                    // ===== 2. 深度 pass（view+1）：aodepth shader 渲 NDC 深度到深度 RT =====
                    this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
                    // ===== 3. SAO 计算 pass（view+2）：全屏四边形采样法线/深度 =====
                    this._renderSAOCalc(renderer, camera, UInt16(UInt16(baseView) + 2u16), uniforms)
                    // ===== 4. vBlur pass（view+3）=====
                    this._renderBlur(renderer, camera, UInt16(UInt16(baseView) + 3u16), uniforms, 0.0, 1.0, this._saoTex, this._blurFB)
                    // ===== 5. hBlur pass（view+4）：写回 sao RT =====
                    this._renderBlur(renderer, camera, UInt16(UInt16(baseView) + 4u16), uniforms, 1.0, 0.0, this._blurTex, this._saoFB)
                    // ===== 6. 输出 pass（view+5）：按 output 模式写 writeBuffer/屏幕 =====
                    this._renderOutput(renderer, readBuffer, writeBuffer, UInt16(UInt16(baseView) + 5u16))
                    Logger.trace(["sao", "render: 6-pass chain done"])
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * 法线 pass：normal shader 渲场景到法线 RT。
     */
    private func _renderNormals(renderer: BgfxRenderer, scene: Scene, camera: Camera, baseView: UInt16): Unit {
        let viewId = baseView
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._normalFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为中性法线编码（view space +Z = 0.5,0.5,1.0 → 0x8080FF），背景法线朝相机
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x8080FFu32, depth: 1.0f32, stencil: 0u8)

        let normalProgOpt = ShaderLibs.get("normal")
        match (normalProgOpt) {
            case Some(normalSp) =>
                if (!isValidHandle(Box(normalSp.programHandle))) {
                    normalSp.compileBgfx()
                }
                let normalProg = Box(normalSp.programHandle)
                if (!isValidHandle(normalProg)) { Logger.trace(["sao", "normal prog compile failed"]); return }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                let viewMtx = camera.matrixWorldInverse.elements
                let uniforms = this._uniforms
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序 → 紧凑 9 floats）
                            // SSR 实验验证：PostProcessingShaders 自定义 shader 的 mat3 uniform
                            //   必须用紧凑 c*3+r 布局（主渲染器 vec4 pad 格式会 col1row0 等错位）
                            // 仓颉 0..3 = 0,1,2（不含 3），不会迭代第 4 列/行，无越界
                            let nmData = Array<Float64>(12, { i => 0.0 })
                            for (c in 0..3) {
                                for (r in 0..3) {
                                    var acc = 0.0
                                    for (k in 0..3) {
                                        acc += viewMtx[k * 4 + r] * mtxArr[c * 4 + k]
                                    }
                                    nmData[c * 3 + r] = acc
                                }
                            }
                            let uNormalMat = uniforms.createUniform("u_normalMatrix", UniformType.Mat3.value())
                            let nmMem = BgfxMemory(48u32)
                            nmMem.writeFloats(nmData, 12)
                            this.setUniform(renderer, uNormalMat, nmMem, num: 1u16)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(renderer, ro.geometry)
                            if (isValidHandle(ib)) {
                                renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                            }
                            let normalState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                              BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                              BgfxConstants.FRONT_CCW
                            renderer.setState(normalState, rgba: 0x00000000u32)
                            renderer.submit(viewId, normalProg, depth: 0u32, blend: 0xFFu8)
                            submitCnt += 1
                        case None => ()
                    }
                }
                Logger.trace(["sao", "normal pass submitCnt=${submitCnt}"])
            case None => Logger.trace(["sao", "normal shader not registered"])
        }
    }

    /**
     * 深度 pass：aodepth shader 渲场景到深度 RT（写 gl_FragCoord.z = NDC 深度）。
     */
    private func _renderDepth(renderer: BgfxRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（NDC 深度=1.0）：背景无片元时颜色保持 1.0，SAO shader 用 depth>=1.0-EPSILON 跳过
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let depthProgOpt = PostProcessingShaders.get("aodepth")
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (!isValidHandle(Box(depthSp.programHandle))) {
                    depthSp.compileBgfx()
                }
                let depthProg = Box(depthSp.programHandle)
                if (!isValidHandle(depthProg)) { Logger.trace(["sao", "depth: aodepth program compile FAILED"]); return }
                Logger.trace(["sao", "depth: aodepth prog idx=${handleIdx(depthProg)}"])

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
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
                }
                Logger.trace(["sao", "depth: submitted renderObjects=${renderObjects.size}"])
            case None => Logger.trace(["sao", "depth: aodepth shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * SAO 计算 pass：全屏四边形采样法线/深度纹理，输出 1-occlusion。
     * sao shader（NUM_SAMPLES=7, NUM_RINGS=4）。
     */
    private func _renderSAOCalc(renderer: BgfxRenderer, camera: Camera, viewId: UInt16, uniforms: BgfxUniforms): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._saoFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let saoProgOpt = PostProcessingShaders.get("sao")
        match (saoProgOpt) {
            case Some(saoSp) =>
                if (!isValidHandle(Box(saoSp.programHandle))) {
                    saoSp.compileBgfx()
                }
                let saoProg = Box(saoSp.programHandle)
                if (!isValidHandle(saoProg)) { Logger.trace(["sao", "sao prog compile failed"]); return }
                Logger.trace(["sao", "saoCalc: prog idx=${handleIdx(saoProg)} normalTex=${handleIdx(this._normalTex)} depthTex=${handleIdx(this._depthTex)}"])

                // 采样器：stage 0=深度, 1=法线
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDepth, this._depthTex, 0u32)
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uNormal, this._normalTex, 0u32)

                // size
                let uSize = uniforms.createUniform("u_size", UniformType.Vec4.value())
                let sizeMem = BgfxMemory(16u32)
                sizeMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uSize, sizeMem, num: 1u16)

                // cameraNear/Far
                let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                let nfMem = BgfxMemory(16u32)
                nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                this.setUniform(renderer, uNearFar, nfMem, num: 1u16)

                // projection / inverse projection
                let uProj = uniforms.createUniform("u_projMatrix", UniformType.Mat4.value())
                let projMem = BgfxMemory(64u32)
                projMem.writeFloats(camera.projectionMatrix.elements, 16)
                this.setUniform(renderer, uProj, projMem, num: 1u16)

                let invProj = camera.projectionMatrix.clone().invert()
                let uInvProj = uniforms.createUniform("u_invProjMatrix", UniformType.Mat4.value())
                let invMem = BgfxMemory(64u32)
                invMem.writeFloats(invProj.elements, 16)
                this.setUniform(renderer, uInvProj, invMem, num: 1u16)

                // saoParams: x=scale, y=intensity, z=bias, w=kernelRadius
                let uParams = uniforms.createUniform("u_saoParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([this.saoScale, this.saoIntensity, this.saoBias, this.saoKernelRadius], 4)
                this.setUniform(renderer, uParams, pMem, num: 1u16)

                // minResSeed: x=minResolution, y=randomSeed（randomSeed 恒为 0）
                let uMinRes = uniforms.createUniform("u_minResSeed", UniformType.Vec4.value())
                let mMem = BgfxMemory(16u32)
                mMem.writeFloats([this.saoMinResolution, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uMinRes, mMem, num: 1u16)

                // 全屏四边形 submit
                this.submitQuad(viewId, saoProg)
            case None => Logger.trace(["sao", "sao shader not registered"])
        }
    }

    /**
     * 深度受限高斯模糊 pass（DepthLimitedBlurShader + configure 数据）。
     * @param dirX dirY 方向（vBlur=(0,1)，hBlur=(1,0)）
     * @param srcTex 输入纹理（vBlur=saoTex，hBlur=blurTex）
     * @param dstFB 输出 frame buffer（vBlur=blurFB，hBlur=saoFB）
     */
    private func _renderBlur(renderer: BgfxRenderer, camera: Camera, viewId: UInt16, uniforms: BgfxUniforms, dirX: Float64, dirY: Float64, srcTex: TextureHandle, dstFB: FrameBufferHandle): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, dstFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let blurProgOpt = PostProcessingShaders.get("saoblur")
        match (blurProgOpt) {
            case Some(blurSp) =>
                if (!isValidHandle(Box(blurSp.programHandle))) {
                    blurSp.compileBgfx()
                }
                let blurProg = Box(blurSp.programHandle)
                if (!isValidHandle(blurProg)) { Logger.trace(["sao", "blur: saoblur program compile FAILED"]); return }
                Logger.trace(["sao", "blur: prog idx=${handleIdx(blurProg)}srcTex=${handleIdx(srcTex)}}ir=(${dirX},${dirY})"])

                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)

                let uSize = uniforms.createUniform("u_size", UniformType.Vec4.value())
                let sizeMem = BgfxMemory(16u32)
                sizeMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uSize, sizeMem, num: 1u16)

                let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                let nfMem = BgfxMemory(16u32)
                nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                this.setUniform(renderer, uNearFar, nfMem, num: 1u16)

                // depthCutoff = saoBlurDepthCutoff * (far - near)
                let depthCutoff = this.saoBlurDepthCutoff * (camera.far - camera.near)
                let uCutoff = uniforms.createUniform("u_depthCutoff", UniformType.Vec4.value())
                let cMem = BgfxMemory(16u32)
                cMem.writeFloats([depthCutoff, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uCutoff, cMem, num: 1u16)

                // 偏移/权重数组（9 项）
                // ★修复：shader 声明 uniform vec4 u_sampleOffsets[9]（9×16=144 字节），
                //   原实现只上传 18 个 float（9 个 xy 对，72 字节）→ bgfx_set_uniform 按
                //   count=9 读取 144 字节 → 72 字节堆越界读 → 偏移为垃圾值 → 模糊采样随机
                //   → SAO 原始噪点无法平滑（稀疏小黑点）。现按 vec4(x,y,0,0) 补齐 36 个 float。
                let (offsets, weights) = this._generateBlurData(dirX, dirY)
                let uOffsets = uniforms.createUniform("u_sampleOffsets", UniformType.Vec4.value(), 9u16)
                let offData = Array<Float64>(36, { i => 0.0 })
                for (i in 0..9) {
                    offData[i * 4 + 0] = offsets[i * 2 + 0]
                    offData[i * 4 + 1] = offsets[i * 2 + 1]
                }
                let offMem = BgfxMemory(UInt32(9 * 4 * 4))
                offMem.writeFloats(offData, 36)
                this.setUniform(renderer, uOffsets, offMem, num: 9u16)

                let uWeights = uniforms.createUniform("u_sampleWeights", UniformType.Vec4.value(), 9u16)
                let wMem = BgfxMemory(UInt32(9 * 4 * 4))
                wMem.writeFloats(weights, 36)
                this.setUniform(renderer, uWeights, wMem, num: 9u16)

                this.submitQuad(viewId, blurProg)
            case None => Logger.trace(["sao", "blur: saoblur shader NOT REGISTERED in PostProcessingShaders"])
        }
    }

    /**
     * 输出 pass：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）。
     * 输出阶段的 switch 分支：
     *   - Default：saoapply（sceneColor × ao，合并 materialCopy + CustomBlending 乘法）
     *   - SAO：copy saoRT；Normal：copy normalRT
     */
    private func _renderOutput(renderer: BgfxRenderer, readBuffer: FrameBufferHandle, writeBuffer: FrameBufferHandle, viewId: UInt16): Unit {
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let uniforms = this._uniforms

        // Default 模式：saoapply（sceneColor × ao）
        if (this.output == BgfxSAOPass.OUTPUT_DEFAULT) {
            let applyProgOpt = PostProcessingShaders.get("saoapply")
            match (applyProgOpt) {
                case Some(applySp) =>
                    if (!isValidHandle(Box(applySp.programHandle))) {
                        applySp.compileBgfx()
                    }
                    let applyProg = Box(applySp.programHandle)
                    if (!isValidHandle(applyProg)) { Logger.trace(["sao", "output default: saoapply compile FAILED"]); return }
                    let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                    let uScene = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                    this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                    let uAO = uniforms.createUniform("tAO", UniformType.Sampler.value())
                    this.bindTexture(renderer, 1u8, uAO, this._saoTex, 0u32)
                    Logger.trace(["sao", "output default: sceneTex=${handleIdx(sceneTex)} saoTex=${handleIdx(this._saoTex)}"])
                    this.submitQuad(viewId, applyProg)
                case None => Logger.trace(["sao", "output default: saoapply shader NOT REGISTERED"])
            }
            return
        }

        // SAO/Normal：copy shader 透传对应纹理
        var srcTex: TextureHandle = this._saoTex
        if (this.output == BgfxSAOPass.OUTPUT_NORMAL) {
            srcTex = this._normalTex
        }
        let copyProgOpt = PostProcessingShaders.get("copy")
        match (copyProgOpt) {
            case Some(copySp) =>
                if (!isValidHandle(Box(copySp.programHandle))) {
                    copySp.compileBgfx()
                }
                let copyProg = Box(copySp.programHandle)
                if (!isValidHandle(copyProg)) { Logger.trace(["sao", "output copy: copy compile FAILED"]); return }
                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let oMem = BgfxMemory(16u32)
                oMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, oMem, num: 1u16)
                Logger.trace(["sao", "output copy: output=${this.output} srcTex=${handleIdx(srcTex)}"])
                this.submitQuad(viewId, copyProg)
            case None => Logger.trace(["sao", "output copy: copy shader NOT REGISTERED"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（用 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: BgfxRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.toArray(Array<Float64>(16, { _ => 0.0 }))
        let projArr = camera.projectionMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
    }

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

    /** 销毁全部 GPU 资源（composer.dispose 或 renderer.shutdown 调用） */
    public override func dispose(): Unit {
        this._destroyRTs()
        // 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose
        // 释放场景几何体缓存
        match (this._renderer) {
            case Some(renderer) =>
                for ((_, vb) in this._vbCache) {
                    renderer.destroyVertexBuffer(vb)
                }
                this._vbCache.clear()
                for ((_, ib) in this._ibCache) {
                    renderer.destroyIndexBuffer(ib)
                }
                this._ibCache.clear()
                match (this._layoutHandleCache) {
                    case Some(lh) =>
                        renderer.destroyVertexLayout(lh)
                        this._layoutHandleCache = None
                    case None => ()
                }
            case None => ()
        }
    }
}
