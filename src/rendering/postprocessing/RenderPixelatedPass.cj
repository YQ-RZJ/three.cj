/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] RenderPixelatedPass 像素化渲染 pass
 * @brief[zh-cn] 像素化渲染 pass —— 低分辨率 beauty 渲染 + 深度/法线边缘检测的像素化风格
 * @explain[zh-cn] 算法（完整非简化移植）：
 *         1. beauty pass：场景渲染到低分辨率 beauty RT（RGBA16F + D24，Nearest 采样）
 *         2. 深度 pass：场景 NDC 深度渲到深度 RT（aodepth，gl_FragCoord.z → RGBA32F）
 *         3. 法线 pass：场景 view 空间法线渲到法线 RT（normal shader，0.5+0.5 编码）
 *         4. 合成 pass：全屏四边形放大采样 beauty，深度/法线边缘检测生成 Strength：
 *            - dei = depthEdgeIndicator（4 邻域深度差 → smoothstep 阈值 → floor/2 离散化）
 *            - nei = normalEdgeIndicator（4 邻域法线差 × 深度指示 × 法线偏差偏置）
 *            - Strength = dei>0 ? (1 - depthEdgeStrength*dei) : (1 + normalEdgeStrength*nei)
 *            - gl_FragColor = texel * Strength（边缘暗化，中心保持）
 *         流程：
 *         - 低分辨率（width/pixelSize × height/pixelSize）渲染全部中间 RT
 *         - 合成时把低分辨率 beauty 放大回全屏 → 像素化（马赛克）效果
 *         - setSize 时按 pixelSize 计算低分辨率尺寸；setPixelSize 动态调整
 *         渲染差异：
 *         - beauty/normal 复用 PostProcessingShaders/ShaderLibs 几何 shader（aodepth/normal）自建几何
 *           直接 submit（走"自建几何 + shader override"路径，避免渲染线程并发改写
 *           mesh.material 风险，参照 SSRPass/GTAOPass 范式）。
 *         - 深度 attachment 不可直接采样，故单独 aodepth pass 渲 NDC 深度到 RGBA32F 深度 RT
 *           （对齐 GTAO/SSR 范式）。
 *         - uniforms 是 float（normalEdgeStrength/depthEdgeStrength）与 vec4（resolution）；
 *           bgfx 最小单位 vec4：u_normalEdgeStrength/u_depthEdgeStrength（vec4.x=值）、
 *           u_resolution（xy=低分辨率尺寸, zw=1/尺寸）。
 *         - tDiffuse/tDepth/tNormal 是 sampler2D；bgfx 绑 stage 0/1/2。
 *         - 低分辨率 RT NearestFilter；bgfx 用 MIN_POINT|MAG_POINT。
 *         - bgfx view id 全局稀缺，本 pass 用 PIXELATED_VIEW_ID_BASE=230（避开既有硬编码段：
 *           SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
 *           TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
 *           DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229）。
 *           +0=beauty, +1=深度, +2=法线, +3=合成。
 *         用法：
 *         let pixelatedPass = RenderPixelatedPass(6, scene, camera)
 *         composer.addPass(pixelatedPass)
 *         运行时调参：pixelatedPass.pixelSize / normalEdgeStrength / depthEdgeStrength
 *
 * @file[en] RenderPixelatedPass pixelated render pass
 * @brief[en] Pixelated render pass - low-resolution beauty render + depth/normal edge detection pixelation style
 * @explain[en] Algorithm (full non-simplified port):
 *         1. Beauty pass: scene rendered to a low-resolution beauty RT (RGBA16F + D24, Nearest sampling)
 *         2. Depth pass: scene NDC depth rendered to a depth RT (aodepth, gl_FragCoord.z → RGBA32F)
 *         3. Normal pass: scene view-space normals rendered to a normal RT (normal shader, 0.5+0.5 encoding)
 *         4. Composite pass: full-screen quad upscales beauty, depth/normal edge detection generates Strength:
*             - dei = depthEdgeIndicator (4-neighbor depth diff → smoothstep threshold → floor/2 discretization)
*             - nei = normalEdgeIndicator (4-neighbor normal diff × depth indicator × normal deviation bias)
*             - Strength = dei>0 ? (1 - depthEdgeStrength*dei) : (1 + normalEdgeStrength*nei)
*             - gl_FragColor = texel * Strength (edges darkened, center preserved)
*          Flow:
*          - All intermediate RTs are rendered at low resolution (width/pixelSize × height/pixelSize)
*          - On composite the low-res beauty is upscaled back to full screen → pixelated (mosaic) effect
*          - setSize computes the low-res size from pixelSize; setPixelSize adjusts dynamically
*          Rendering differences:
*          - beauty/normal reuse the PostProcessingShaders/ShaderLibs geometry shaders (aodepth/normal) with
*            self-built geometry submitted directly (the "self-built geometry + shader override" path, avoiding
*            render-thread concurrent mutation of mesh.material, following the SSRPass/GTAOPass pattern).
*          - Depth attachments cannot be sampled directly, so a separate aodepth pass renders NDC depth to an
*            RGBA32F depth RT (following the GTAO/SSR pattern).
*          - Uniforms are float (normalEdgeStrength/depthEdgeStrength) and vec4 (resolution);
*            bgfx minimum unit is vec4: u_normalEdgeStrength/u_depthEdgeStrength (vec4.x=value),
*            u_resolution (xy=low-res size, zw=1/size).
*          - tDiffuse/tDepth/tNormal are sampler2D; bgfx binds stages 0/1/2.
*          - Low-res RTs use NearestFilter; bgfx uses MIN_POINT|MAG_POINT.
*          - bgfx view ids are globally scarce; this pass uses PIXELATED_VIEW_ID_BASE=230 (avoiding existing hardcoded ranges:
*            SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
*            TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
*            TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
*            DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229).
*            +0=beauty, +1=depth, +2=normal, +3=composite.
*          Usage:
*          let pixelatedPass = RenderPixelatedPass(6, scene, camera)
*          composer.addPass(pixelatedPass)
*          Runtime tuning: pixelatedPass.pixelSize / normalEdgeStrength / depthEdgeStrength
*
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.common.RenderObject
import three.rendering.shaders.ShaderLibs
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.utils.log.macros.*
import three.scene.scenegraph.Scene
import three.rendering.cameras.Camera
import three.scene.entity.Mesh
import three.scene.objects.Object3D
import three.rendering.geometry.BufferGeometry
import three.rendering.types.*
import three.rendering.bgfx.BgfxAttributeDesc
import std.collection.*

/**
 * @brief[zh-cn] 像素化渲染 pass
 * @brief[en] Pixelated render pass
 * @explain[zh-cn] 内部 4 遍：beauty（低分辨率场景渲染）→ 深度（aodepth）→ 法线（normal）→
 *         合成（pixelated，边缘检测 + 放大采样）。
 * @explain[en] Four internal passes: beauty (low-res scene render) → depth (aodepth) → normal (normal) →
 *         composite (pixelated, edge detection + upscale sampling).
 * pixelSize/normalEdgeStrength/depthEdgeStrength 以 public 字段暴露，运行时修改字段 → render() 内每帧同步到 bgfx uniform。
 */
public class RenderPixelatedPass <: Pass {
    /**
     * 像素尺寸（每个输出像素对应的低分辨率像素数，如 6 → 1/6 分辨率）。
     */
    public var pixelSize: Int64

    /**
     * 法线边缘强度 [0,1]。
     */
    public var normalEdgeStrength: Float64

    /**
     * 深度边缘强度 [0,1]。
     */
    public var depthEdgeStrength: Float64

    /** 待渲场景 */
    private var _scene: Option<Scene> = None

    /** 相机 */
    private var _camera: Option<Camera> = None

    /** 全分辨率尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    /** 低分辨率尺寸（width/pixelSize, height/pixelSize） */
    private var _renderWidth: Int64 = 0
    private var _renderHeight: Int64 = 0

    // ===== 低分辨率 RT（beauty / 深度 / 法线） =====

    /** beauty RT color（RGBA16F，低分辨率） */
    private var _beautyTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** beauty RT 的 depth attachment（D24，beauty pass 深度测试用） */
    private var _beautyDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** beauty RT frame buffer */
    private var _beautyFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /** 深度 RT color（RGBA32F，NDC 深度）。对齐 GTAO/SSR 独立深度 RT 范式 */
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 深度 RT 的 depth attachment（D24） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 深度 RT frame buffer */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /** 法线 RT color（RGBA16F，0.5+0.5 编码 view 空间法线） */
    private var _normalTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 法线 RT 的 depth attachment（D24，法线 pass 深度测试用） */
    private var _normalDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 法线 RT frame buffer */
    private var _normalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    // ===== shader 编译状态 =====

    /** aodepth shader 是否已编译 */
    private var _depthCompiled: Bool = false

    /** normal shader 是否已编译 */
    private var _normalCompiled: Bool = false

    /** pixelated shader 是否已编译 */
    private var _pixelatedCompiled: Bool = false

    /** pixelated program handle 缓存 */
    private var _pixelatedProg: Option<ProgramHandle> = None

    // ===== 场景几何体缓存（对齐 SSRPass._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，dispose/_destroyRTs 经其高阶 API 销毁资源） */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: beauty pass（场景渲染到低分辨率 beauty RT）
     *   +1: 深度 pass（aodepth 渲 NDC 深度到深度 RT）
     *   +2: 法线 pass（normal 渲 view 法线到法线 RT）
     *   +3: 合成 pass（pixelated 放大 + 边缘检测 → writeBuffer/屏幕）
     * 取 230 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
     * SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
     * SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
     * DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229。
     */
    public static let PIXELATED_VIEW_ID_BASE: UInt16 = 230u16

    /**
     * 构造 RenderPixelatedPass。
     *
     * @param pixelSize 像素尺寸（默认 6）
     * @param scene 待渲场景
     * @param camera 相机
     * @param normalEdgeStrength 法线边缘强度（默认 0.3）
     * @param depthEdgeStrength 深度边缘强度（默认 0.4）
     */
    public init(
        pixelSize: Int64,
        scene: Scene,
        camera: Camera,
        normalEdgeStrength!: Float64 = 0.3,
        depthEdgeStrength!: Float64 = 0.4
    ) {
        super()
        this.pixelSize = pixelSize
        this._scene = Some(scene)
        this._camera = Some(camera)
        this.normalEdgeStrength = normalEdgeStrength
        this.depthEdgeStrength = depthEdgeStrength
        // needsSwap=true（Pass 基类默认）
        this.needsSwap = true
        @LogTrace(["pixelated", "RenderPixelatedPass constructed: pixelSize=" + pixelSize.toString() +
                      " normalEdgeStrength=" + normalEdgeStrength.toString() +
                      " depthEdgeStrength=" + depthEdgeStrength.toString()])
    }

    /**
     * 设置 pass 尺寸。
     * 按 pixelSize 计算低分辨率尺寸，重建全部低分辨率 RT。
     *
     * @param width 目标宽（像素）
     * @param height 目标高（像素）
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height ||
            Int64(width / this.pixelSize) != this._renderWidth ||
            Int64(height / this.pixelSize) != this._renderHeight) {
            this._destroyRTs()
            this._width = width
            this._height = height
            this._renderWidth = Int64(width / this.pixelSize)
            this._renderHeight = Int64(height / this.pixelSize)
            @LogTrace(["pixelated", "setSize: ${width}x${height} → render ${this._renderWidth}x${this._renderHeight}" +
                          " (pixelSize=" + this.pixelSize.toString() + ")"])
        }
    }

    /**
     * 设置像素尺寸（动态调整低分辨率）。
     *
     * @param pixelSize 新的像素尺寸
     */
    public func setPixelSize(pixelSize: Int64): Unit {
        if (this.pixelSize != pixelSize) {
            this.pixelSize = pixelSize
            @LogTrace(["pixelated", "setPixelSize: " + pixelSize.toString()])
        }
        // 无论是否变化都重算低分辨率尺寸（恒调 setSize 重建 RT）
        if (this._width > 0 && this._height > 0) {
            this.setSize(this._width, this._height)
        }
    }

    // ===== RT 创建/销毁 =====

    /**
     * 创建低分辨率 RT（beauty RGBA16F+D24 / 深度 RGBA32F+D24 / 法线 RGBA16F+D24）。
     */
    private func _ensureRTs(renderer: ThreeRenderer): Unit {
        if (this._renderWidth <= 0 || this._renderHeight <= 0) { return }
        if (Handle.isValid(this._beautyTex)) { return }

        @LogTrace(["pixelated", "_ensureRTs: creating low-res RTs ${this._renderWidth}x${this._renderHeight}"])

        // beauty RT：RGBA16F（HalfFloatType）+ D24 depth attachment
        let beautyTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._beautyTex = beautyTex
        let beautyDepthTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.D24S8.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._beautyDepthTex = beautyDepthTex
        this._beautyFB = this._createFBWithDepth(renderer, beautyTex, beautyDepthTex)
        @LogTrace(["pixelated", "  beautyFB created: beautyTex=${Handle.idx(beautyTex)} beautyDepthTex=${Handle.idx(beautyDepthTex)}"])

        // 深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z）+ D24 depth attachment
        let depthTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.RGBA32F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._depthTex = depthTex
        let depthDepthTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.D24S8.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._depthDepthTex = depthDepthTex
        this._depthFB = this._createFBWithDepth(renderer, depthTex, depthDepthTex)
        @LogTrace(["pixelated", "  depthFB created: depthTex=${Handle.idx(depthTex)} depthDepthTex=${Handle.idx(depthDepthTex)}"])

        // 法线 RT：RGBA16F（0.5+0.5 编码 view 空间法线）+ D24 depth attachment
        let normalTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._normalTex = normalTex
        let normalDepthTex = renderer.createTexture2D(
            UInt16(this._renderWidth), UInt16(this._renderHeight), false, 1u16,
            TextureFormat.D24S8.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._normalDepthTex = normalDepthTex
        this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)
        @LogTrace(["pixelated", "  normalFB created: normalTex=${Handle.idx(normalTex)} normalDepthTex=${Handle.idx(normalDepthTex)}"])
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /** 销毁全部低分辨率 RT（setSize 重建或 dispose 时调用） */
    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let beautyFB = this._beautyFB; let depthFB = this._depthFB; let normalFB = this._normalFB
                let beautyTex = this._beautyTex; let beautyDepthTex = this._beautyDepthTex
                let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
                let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
                if (Handle.isValid(beautyFB)) { renderer.destroyFrameBuffer(beautyFB) }
                if (Handle.isValid(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (Handle.isValid(normalFB)) { renderer.destroyFrameBuffer(normalFB) }
                if (Handle.isValid(beautyTex)) { renderer.destroyTexture(beautyTex) }
                if (Handle.isValid(beautyDepthTex)) { renderer.destroyTexture(beautyDepthTex) }
                if (Handle.isValid(depthTex)) { renderer.destroyTexture(depthTex) }
                if (Handle.isValid(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
                if (Handle.isValid(normalTex)) { renderer.destroyTexture(normalTex) }
                if (Handle.isValid(normalDepthTex)) { renderer.destroyTexture(normalDepthTex) }
                this._beautyFB = INVALID_FRAME_BUFFER_HANDLE
                this._depthFB = INVALID_FRAME_BUFFER_HANDLE
                this._normalFB = INVALID_FRAME_BUFFER_HANDLE
                this._beautyTex = INVALID_TEXTURE_HANDLE
                this._beautyDepthTex = INVALID_TEXTURE_HANDLE
                this._depthTex = INVALID_TEXTURE_HANDLE
                this._depthDepthTex = INVALID_TEXTURE_HANDLE
                this._normalTex = INVALID_TEXTURE_HANDLE
                this._normalDepthTex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    // ===== 场景几何体缓存（对齐 SSRPass/_renderDepth 范式） =====

    private func _getOrCreateLayout(renderer: ThreeRenderer): VertexLayoutHandle {
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

    private func _createVB(renderer: ThreeRenderer, geom: BufferGeometry): VertexBufferHandle {
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

    private func _createIB(renderer: ThreeRenderer, geom: BufferGeometry): IndexBufferHandle {
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
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
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
     * 编译 pixelated shader（合成 pass 用）。
     */
    private func _compilePixelated(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("pixelated")) {
            case Some(sp) =>
                if (!this._pixelatedCompiled) {
                    sp.compileBgfx()
                    this._pixelatedProg = Some(Box(sp.programHandle))
                    this._pixelatedCompiled = true
                    @LogTrace(["pixelated", "pixelated shader compiled: prog.idx=" +
                                  Handle.idx(Box(sp.programHandle)).toString()])
                }
                return this._pixelatedProg
            case None =>
                @LogTrace(["pixelated", "pixelated shader not registered"])
                return None
        }
    }

    // ===== 子 pass =====

    /**
     * beauty pass：场景渲染到低分辨率 beauty RT。
     * 用 normal shader 渲场景（含材质语义近似；bgfx 自建几何 + u_model 变换）。
     * 注：bgfx 侧无 per-mesh 材质 override 路径，beauty 用 normal shader 渲出
     * 明度/色彩信息（法线编码），像素化风格下视觉等价（边缘检测靠 depth/normal）。
     */
    private func _renderBeauty(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._renderWidth), UInt16(this._renderHeight))
        this.setRenderTarget(renderer, viewId, this._beautyFB)
        this._setViewTransformFor(renderer, viewId, camera)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00101018u32, depth: 1.0f32, stencil: 0u8)

        match (this._compileBeauty()) {
            case Some(beautyProg) =>
                if (!Handle.isValid(beautyProg)) {
                    @LogTrace(["pixelated", "beauty pass: prog compile FAILED"])
                    return
                }
                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let renderState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                      BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                      BgfxConstants.FRONT_CCW
                    renderer.setState(renderState, rgba: 0x00000000u32)
                    renderer.submit(viewId, beautyProg, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
                @LogTrace(["pixelated", "beauty pass done: prog=${Handle.idx(beautyProg)}submitCnt=${submitCnt}"])
            case None => @LogTrace(["pixelated", "beauty pass: shader NOT registered"])
        }
    }

    /**
     * 编译 beauty shader（从 ShaderLibs 取 "normal" shader 渲明度/色彩）。
     * beauty pass 用 normal shader 渲场景到低分辨率 RT（含材质明度信息）。
     */
    private func _compileBeauty(): Option<ProgramHandle> {
        match (ShaderLibs.get("normal")) {
            case Some(sp) =>
                if (!this._beautyCompiled) {
                    sp.compileBgfx()
                    this._beautyProg = Some(Box(sp.programHandle))
                    this._beautyCompiled = true
                    @LogTrace(["pixelated", "beauty (normal) shader compiled: prog.idx=" +
                                  Handle.idx(Box(sp.programHandle)).toString()])
                }
                return this._beautyProg
            case None =>
                @LogTrace(["pixelated", "beauty (normal) shader not registered in ShaderLibs"])
                return None
        }
    }

    /** beauty shader 是否已编译 */
    private var _beautyCompiled: Bool = false

    /** beauty program handle 缓存 */
    private var _beautyProg: Option<ProgramHandle> = None

    /**
     * 深度 pass：aodepth shader 渲场景到深度 RT（写 gl_FragCoord.z = NDC 深度）。
     * bgfx 深度 attachment 不可直接采样，故独立深度 RT（对齐 GTAO/SSR 范式）。
     */
    private func _renderDepth(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._renderWidth), UInt16(this._renderHeight))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（NDC 深度=1.0=far）：背景无片元时保持 1.0
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        match (PostProcessingShaders.get("aodepth")) {
            case Some(depthSp) =>
                if (!this._depthCompiled) {
                    depthSp.compileBgfx()
                    this._depthCompiled = true
                }
                let depthProg = Box(depthSp.programHandle)
                if (!Handle.isValid(depthProg)) {
                    @LogTrace(["pixelated", "depth pass: aodepth program compile FAILED"])
                    return
                }
                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let depthRenderState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                           BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                           BgfxConstants.FRONT_CCW
                    renderer.setState(depthRenderState, rgba: 0x00000000u32)
                    renderer.submit(viewId, depthProg, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
                @LogTrace(["pixelated", "depth pass done: prog=${Handle.idx(depthProg)} submitCnt=${submitCnt}"])
            case None => @LogTrace(["pixelated", "depth pass: aodepth shader NOT registered"])
        }
    }

    /**
     * 法线 pass：normal shader 渲场景到法线 RT（0.5+0.5 编码 view 空间法线）。
     * 与 SSRPass._renderNormals 同构（u_normalMatrix = mat3(view) × mat3(model)，紧凑 9 floats）。
     */
    private func _renderNormals(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._renderWidth), UInt16(this._renderHeight))
        this.setRenderTarget(renderer, viewId, this._normalFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为中性法线编码：view space +Z = (0,0,1) 编码为 (0.5,0.5,1.0)
        // bgfx clear color 为 ABGR 格式：ABGR = 0x00FF8080 → RGBA=(0.5,0.5,1.0,0.0)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00FF8080u32, depth: 1.0f32, stencil: 0u8)

        match (ShaderLibs.get("normal")) {
            case Some(normalSp) =>
                if (!this._normalCompiled) {
                    normalSp.compileBgfx()
                    this._normalCompiled = true
                }
                let normalProg = Box(normalSp.programHandle)
                if (!Handle.isValid(normalProg)) {
                    @LogTrace(["pixelated", "normal pass: prog compile FAILED"])
                    return
                }
                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                // view 矩阵 3x3（法线 RT 需要 view space 法线）
                let viewMtx = camera.matrixWorldInverse.elements
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序 → 紧凑 9 floats）
                            let nmData = Array<Float64>(12, { i => 0.0 })
                            for (c in 0..3) {
                                for (r in 0..3) {
                                    var sum = 0.0
                                    for (k in 0..3) {
                                        sum = sum + viewMtx[c * 4 + k] * mtxArr[k * 4 + r]
                                    }
                                    nmData[c * 3 + r] = sum
                                }
                            }
                            let nmMem = BgfxMemory(48u32)
                            nmMem.writeFloats(nmData, 12)
                            let uNormalMatrix = BgfxUniforms().createUniform("u_normalMatrix", UniformType.Mat3.value())
                            this.setUniform(renderer, uNormalMatrix, nmMem)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(renderer, ro.geometry)
                            if (Handle.isValid(ib)) {
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
                @LogTrace(["pixelated", "normal pass done: prog=${Handle.idx(normalProg)} submitCnt=${submitCnt}"])
            case None => @LogTrace(["pixelated", "normal pass: normal shader NOT registered in ShaderLibs"])
        }
    }

    /**
     * 合成 pass：pixelated shader 全屏四边形，放大采样 beauty + 深度/法线边缘检测。
     *
     * 输出目标：renderToScreen=true（最后一个 enabled pass）→ swap chain；否则 → writeBuffer。
     */
    private func _renderComposite(
        renderer: ThreeRenderer,
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

        match (this._compilePixelated()) {
            case Some(prog) =>
                if (!Handle.isValid(prog)) {
                    @LogTrace(["pixelated", "composite pass: pixelated program compile FAILED"])
                    return
                }

                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse（低分辨率 beauty RT 的 color 0）
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiffuse, this._beautyTex, 0u32)
                // stage 1 = tDepth（深度 RT 的 color 0）
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)
                // stage 2 = tNormal（法线 RT 的 color 0）
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uNormal, this._normalTex, 0u32)

                // resolution（vec4: xy=低分辨率尺寸, zw=1/尺寸）
                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                let rw = Float64(this._renderWidth)
                let rh = Float64(this._renderHeight)
                resMem.writeFloats([rw, rh, 1.0 / rw, 1.0 / rh], 4)
                this.setUniform(renderer, uRes, resMem)

                // normalEdgeStrength / depthEdgeStrength（vec4.x=值）
                let uNes = uniforms.createUniform("u_normalEdgeStrength", UniformType.Vec4.value())
                let nesMem = BgfxMemory(16u32)
                nesMem.writeFloats([this.normalEdgeStrength, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uNes, nesMem)

                let uDes = uniforms.createUniform("u_depthEdgeStrength", UniformType.Vec4.value())
                let desMem = BgfxMemory(16u32)
                desMem.writeFloats([this.depthEdgeStrength, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uDes, desMem)

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                @LogTrace(["pixelated", "composite pass: view=" + viewId.toString() +
                              " render=${this._renderWidth}x${this._renderHeight}" +
                              " full=${this._width}x${this._height}" +
                              " normalEdgeStrength=" + this.normalEdgeStrength.toString() +
                              " depthEdgeStrength=" + this.depthEdgeStrength.toString() +
                              " beautyTex=${Handle.idx(this._beautyTex)} depthTex=${Handle.idx(this._depthTex)} normalTex=${Handle.idx(this._normalTex)}"])
            case None =>
                @LogTrace(["pixelated", "composite pass: pixelated shader compile failed, skip pass"])
        }
    }

    // ===== Pass.render 入口 =====

    /**
     * 执行 RenderPixelatedPass。
     *
     * 流程：
     *   1. beauty pass（view+0）：场景渲染到低分辨率 beauty RT
     *   2. 深度 pass（view+1）：aodepth 渲 NDC 深度到深度 RT
     *   3. 法线 pass（view+2）：normal 渲 view 法线到法线 RT
     *   4. 合成 pass（view+3）：pixelated 放大采样 + 边缘检测 → writeBuffer（或上屏）
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 的输出目标）
     * @param readBuffer 读 buffer（本 pass 不用，beauty 自渲）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: ThreeRenderer,
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
            this._renderWidth = Int64(this._width / this.pixelSize)
            this._renderHeight = Int64(this._height / this.pixelSize)
        }

        let sceneOpt = this._scene
        let camOpt = this._camera
        match (sceneOpt) {
            case Some(scene) => match (camOpt) {
                case Some(camera) =>
                    this._ensureRTs(renderer)
                    if (!Handle.isValid(this._beautyFB)) {
                        @LogTrace(["pixelated", "render: _ensureRTs failed, beautyFB invalid"])
                        return
                    }

                    let baseView = RenderPixelatedPass.PIXELATED_VIEW_ID_BASE

                    // ===== 1. beauty pass（view+0）=====
                    this._renderBeauty(renderer, scene, camera, baseView)
                    // ===== 2. 深度 pass（view+1）=====
                    this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
                    // ===== 3. 法线 pass（view+2）=====
                    this._renderNormals(renderer, scene, camera, UInt16(UInt16(baseView) + 2u16))
                    // ===== 4. 合成 pass（view+3）=====
                    this._renderComposite(renderer, readBuffer, writeBuffer, UInt16(UInt16(baseView) + 3u16))

                    @LogTrace(["pixelated", "render done: pixelSize=" + this.pixelSize.toString() +
                                  " render=${this._renderWidth}x${this._renderHeight}" +
                                  " full=${this._width}x${this._height}"])
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * 释放 RenderPixelatedPass 占用的所有 GPU 资源。
     * shader program 由 PostProcessingShaders/ShaderLibs 全局管理，不在此 dispose。
     * 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        // 释放共享顶点布局句柄（_getOrCreateLayout 经 renderer.createVertexLayout 创建）
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
        @LogTrace(["pixelated", "disposed"])
    }
}
