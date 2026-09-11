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
 * @file[zh-cn] SSRPass 屏幕空间反射（SSR）后处理 pass
 * @brief[zh-cn] 屏幕空间反射（SSR）后处理 pass
 * @explain[zh-cn] 以 EffectComposer Pass 链方式注入（对齐 bloom/ssao/gtao 的 Bgfx*Pass）：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SSRPass(scene, camera))
 *         composer.render()
 *         render() 内部（各子方法经 Pass 基类高阶 API 调用 bgfx，高阶 API 自身走 renderer.execBgfx 序列化到渲染线程）：
 *         1. 法线 pass（view SSR_VIEW_ID_BASE+0）：normal shader 渲场景法线到法线 RT（RGBA16F+D24）
 *         2. 深度 pass（view +1）：aodepth shader 渲场景 NDC 深度到深度 RT（RGBA32F+D24）
 *         3. SSR 计算 pass（view +2）：全屏四边形采样法线/深度/场景色，射线步进输出反射到 ssr RT（RGBA16F）
 *         4. 模糊 pass 1（view +3）：全屏四边形 5 抽头 alpha 加权模糊 → blur RT（RGBA16F）
 *         5. 模糊 pass 2（view +4）：再次模糊 → blur2 RT（RGBA16F）
 *         6. 输出 pass（view +5）：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）
 *         bgfx 差异关键点：
 *         - 左手系：viewZ 为正，深度比较符号与右手系相反（>= 替代 <=）
 *         - UV 原点左上、v 向下；NDC y = 1 - 2*uv.y
 *         - NDC z ∈ [0,1]（near→0, far→1）
 *         - 场景色从 composer readBuffer 取（对齐 GTAO 使用 readBuffer 做 scene color 的范式）
 *         - 法线/深度 pass 自建场景几何体 VB/IB/layout（对齐 GTAOPass 自包含模式）
 *         日志：每个 pass 入口/出口均输出 Logger.debug，辅助渲染流程跟踪与纠错验证。
 *
 * @file[en] SSRPass screen-space reflection (SSR) post-processing pass
 * @brief[en] Screen-space reflection (SSR) post-processing pass
 * @explain[en] Injected via the EffectComposer Pass chain (aligned with the Bgfx*Pass bloom/ssao/gtao style):
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(SSRPass(scene, camera))
 *         composer.render()
 *         Inside render() (each sub-method calls bgfx via the Pass base-class high-level APIs, which serialize to the render thread via renderer.execBgfx):
 *         1. Normal pass (view SSR_VIEW_ID_BASE+0): normal shader renders scene normals to a normal RT (RGBA16F+D24)
 *         2. Depth pass (view +1): aodepth shader renders scene NDC depth to a depth RT (RGBA32F+D24)
 *         3. SSR compute pass (view +2): full-screen quad samples normal/depth/scene color, ray-marching outputs reflections to the ssr RT (RGBA16F)
 *         4. Blur pass 1 (view +3): full-screen quad 5-tap alpha-weighted blur → blur RT (RGBA16F)
 *         5. Blur pass 2 (view +4): blur again → blur2 RT (RGBA16F)
 *         6. Output pass (view +5): outputs to writeBuffer per output mode (writes to screen when renderToScreen=true)
 *         Key bgfx differences:
 *         - Left-handed: viewZ is positive, depth comparison signs are inverted (>= instead of <=)
 *         - UV origin top-left, v downward; NDC y = 1 - 2*uv.y
 *         - NDC z ∈ [0,1] (near→0, far→1)
 *         - Scene color taken from the composer readBuffer (aligned with the GTAO readBuffer scene-color pattern)
 *         - Normal/depth passes build their own scene geometry VB/IB/layout (aligned with the GTAOPass self-contained pattern)
 *         Logging: Logger.debug at each pass entry/exit to assist render-flow tracing and debugging.
 */
package three.rendering.postprocessing

import three.rendering.common.*
import three.rendering.bgfx.*
import three.rendering.shaders.ShaderLibs
import three.rendering.shaders.ShaderProgram
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
import three.scene.entity.GroundReflector
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import std.collection.*
import std.math.*
import std.fs.*
import std.env.*

public class SSRPass <: Pass {
    /**
     * SSR pass 用的 view ID 段约定：
     * SSAO 160~164，GTAO 165~169，SAO 170~175，SSR 176~181，composer 分配 230+
     * SSR 需要 6 个 view：normal(0) depth(1) ssr(2) blur1(3) blur2(4) output(5)
     */
    public static let SSR_VIEW_ID_BASE: UInt16 = 176u16

    /**
     * 输出模式。
     * 注：数值跳过 2/6（保留位），Metalness=7 暂未实现。
     */
    public static let OUTPUT_DEFAULT: Int64 = 0   // 场景色 + SSR 混合
    public static let OUTPUT_SSR: Int64 = 1       // 仅 SSR 结果
    public static let OUTPUT_BEAUTY: Int64 = 3    // 仅场景色
    public static let OUTPUT_DEPTH: Int64 = 4     // 深度可视化
    public static let OUTPUT_NORMAL: Int64 = 5    // 法线可视化
    public static let OUTPUT_HITNORMALS: Int64 = 6 // 命中点法线可视化（调试用）

    /** 场景/相机（法线/深度 pass 渲场景用） */
    private var _scene: Option<Scene> = None
    private var _camera: Option<Camera> = None

    // ===== RT 句柄（懒创建，setSize 或首帧时初始化） =====
    /** 法线 RT（RGBA16F，法线编码 0.5+0.5 视图空间） */
    private var _normalFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _normalTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 法线 RT 的 depth attachment（D24，法线 pass 深度测试用） */
    private var _normalDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT（RGBA32F，存 NDC 深度 gl_FragCoord.z） */
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 深度 RT 的 depth attachment（D24，深度 pass 深度测试用） */
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** SSR 反射结果 RT（RGBA16F，rgb=反射色, a=不透明度） */
    private var _ssrFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _ssrTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 模糊 RT 1（RGBA16F） */
    private var _blurFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blurTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** 模糊 RT 2（RGBA16F） */
    private var _blur2FB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blur2Tex: TextureHandle = INVALID_TEXTURE_HANDLE
    /**
     * 金属度 RT（RGBA16F，r=metalness）。
     * selective 模式下 SSR_FS 顶层采样本 RT，metalness==0 的非金属表面直接 return 跳过。
     * 仅当 _selects 非空（selective=true）时创建并参与渲染链。
     */
    private var _metalnessFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _metalnessTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** RT 尺寸 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    // ===== RT 访问器（暴露 RT 给 capture/debug 工具）=====
    /** 当前 RT 宽（capture.cj 调试回读用） */
    public func rtWidth(): Int64 { return this._width }

    /** 当前 RT 高（capture.cj 调试回读用） */
    public func rtHeight(): Int64 { return this._height }

    /** 法线 RT color 纹理（capture.cj 调试回读用） */
    public func normalTexture(): TextureHandle { return this._normalTex }

    /** 深度 RT color 纹理（capture.cj 调试回读用） */
    public func depthTexture(): TextureHandle { return this._depthTex }

    /** SSR 反射结果 RT color 纹理（capture.cj 调试回读用） */
    public func ssrTexture(): TextureHandle { return this._ssrTex }

    /** 模糊 2 RT color 纹理（capture.cj 调试回读用） */
    public func blur2Texture(): TextureHandle { return this._blur2Tex }

    // ===== 输出/参数（字段与 SSRShader uniforms 对应） =====
    /** 输出模式（默认 Default=0，场景+SSR 混合） */
    public var output: Int64 = 0
    /** 反射不透明度（默认 0.5） */
    public var opacity: Float64 = 0.5
    /** 最大反射距离（默认 180） */
    public var maxDistance: Float64 = 180.0
    /** 厚度阈值（默认 0.018） */
    public var thickness: Float64 = 0.018
    /** 是否启用模糊（默认 true） */
    public var blur: Bool = true
    /** 是否启用距离衰减（DISTANCE_ATTENUATION define） */
    public var distanceAttenuation: Bool = true
    /** 是否启用菲涅耳效应（FRESNEL define） */
    public var fresnel: Bool = true
    /** 是否使用无限厚度（INFINITE_THICK define） */
    public var infiniteThick: Bool = false
    /** 诊断可视化开关：true 时 SSR_FS 按射线拒绝原因着色（定位伪影用，默认 false） */
    public var debug: Bool = false

    /**
     * selective 模式开关。
     * 为 true 时启用 metalness pass + SSR_FS SELECTIVE define：
     *   - _selects 中的 mesh 渲染为 metalness=1（白色）写入 metalness RT
     *   - 其他 mesh 渲染为 metalness=0（黑色）
     *   - SSR_FS 顶层采样 metalness RT，metalness==0 的像素直接 return 跳过 SSR
     * 范式：selects=[球/立方体/...]+groundReflector → SSR 只处理金属物体表面。
     */
    public var selective: Bool = false
    /**
     * selective 模式下视为金属的 mesh 列表。
     * 列表中的 mesh 在 metalness pass 中渲为白（metalness=1），其他 mesh 渲为黑。
     * selective=false 时本字段被忽略。
     */
    public var selects: Option<ArrayList<Object3D>> = None

    /**
     * 地面反射器（平面反射组件，可选）。
     * 范式：selects=[球/立方体/...]+groundReflector → SSR 只处理金属物体表面，
     *   地面用 GroundReflector 平面反射（镜像相机渲场景到反射 RT，
     *   ReflectorShader 经 textureMatrix 投影到地面）。
     * 协作方式（包依赖约束：objects 不能依赖 renderers）：
     *   - GroundReflector.computeVirtualCamera(camera) 做镜像相机数学（纯计算）
     *   - 本 pass 在 render 链开头调用该数学 + 渲场景到反射 RT（view 0 语义 +
     *     renderer.render(scene, virtualCamera)，参照 RenderPass 范式）
     *   - 防自反射：渲反射场景前临时隐藏反射面（visible=false），渲完恢复；
     *     且 _collectMeshes 跳过反射面自身（不参与 normal/depth/metalness/SSR）。
     */
    public var groundReflector: Option<GroundReflector> = None

    /** MAX_STEP（= sqrt(width² + height²)，编译时传入 shader define） */
    private var _maxStep: Int64 = 0

    private var _renderer: Option<ThreeRenderer> = None

    /** 本 pass 自有的 uniform 注册表（对齐 GTAOPass/SSAOPass 自包含模式） */
    private var _uniforms: BgfxUniforms = BgfxUniforms()

    // ===== 场景几何体缓存（对齐 BgfxBackend._createVB/_createIB 模式） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /**
     * 构造：`new SSRPass({ scene, camera, width, height })`。
     * 默认 output=Default（0）；needsSwap=true（Pass 基类默认）。
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
            // MAX_STEP = sqrt(width² + height²)
            // 安全上限 1024：循环采用开放式 [loop] for
            // + `if (i >= MAX_STEP+1) break;` 静态整型比较，D3DCompiler 能识别常量上界。
            // 同时 `if (float(i)*stepSize >= totalStep) break;` 动态限制多数射线在短距离早退。
            // shader 内 stepSize = max(1.0, totalStep/MAX_STEP) 放缩：
            //   totalStep ≤ MAX_STEP 时 stepSize=1（细密1像素步），
            //   totalStep 极大时 stepSize>1（稀疏采样、不截断），
            // 因此 MAX_STEP=1024 不会让实际循环次数激增（大多数像素 totalStep<100）。
            let rawMaxStep = Int64(sqrt(Float64(width * width + height * height)))
            this._maxStep = min(rawMaxStep, 1024i64)
            Logger.trace(["ssr", "setSize=${width}x${height} rawMaxStep=${rawMaxStep} maxStep(capped)=${this._maxStep}"])
        }
    }

    // ===== RT 创建/销毁 =====

    private func _ensureRTs(): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (isValidHandle(this._normalTex)) { return }
        match (this._renderer) {
            case Some(renderer) =>
                Logger.trace(["ssr", "_ensureRTs: creating RTs ${this._width}x${this._height}"])

                // 法线 RT：RGBA16F + D24 depth attachment
                let normalTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                    None)
                this._normalTex = normalTex
                let normalDepthTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.D24.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                    None)
                this._normalDepthTex = normalDepthTex
                this._normalFB = this._createFBWithDepth(renderer, normalTex, normalDepthTex)
                Logger.trace(["ssr", "  normalFB created: normalTex=${handleIdx(normalTex)} normalDepthTex=${handleIdx(normalDepthTex)}"])

                // 深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z）+ D24 depth attachment
                let depthTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA32F.value(),
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
                Logger.trace(["ssr", "  depthFB created: depthTex=${handleIdx(depthTex)} depthDepthTex=${handleIdx(depthDepthTex)}"])

                // SSR 反射结果 RT：RGBA16F
                let ssrTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                    None)
                this._ssrTex = ssrTex
                this._ssrFB = this._createFB(renderer, ssrTex)
                Logger.trace(["ssr", "  ssrFB created: ssrTex=${handleIdx(ssrTex)}"])

                // 模糊 RT 1：RGBA16F
                let blurTex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                    None)
                this._blurTex = blurTex
                this._blurFB = this._createFB(renderer, blurTex)
                Logger.trace(["ssr", "  blurFB created: blurTex=${handleIdx(blurTex)}"])

                // 模糊 RT 2：RGBA16F
                let blur2Tex = renderer.createTexture2D(
                    UInt16(this._width), UInt16(this._height), false, 1u16,
                    TextureFormat.RGBA16F.value(),
                    BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                    None)
                this._blur2Tex = blur2Tex
                this._blur2FB = this._createFB(renderer, blur2Tex)
                Logger.trace(["ssr", "  blur2FB created: blur2Tex=${handleIdx(blur2Tex)}"])

                // 金属度 RT：RGBA16F（r=metalness），仅 selective 模式下创建参与渲染链
                // 对应 metalnessRenderTarget（NearestFilter + HalfFloatType）
                if (this.selective) {
                    let metalnessTex = renderer.createTexture2D(
                        UInt16(this._width), UInt16(this._height), false, 1u16,
                        TextureFormat.RGBA16F.value(),
                        BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
                        None)
                    this._metalnessTex = metalnessTex
                    this._metalnessFB = this._createFB(renderer, metalnessTex)
                    Logger.trace(["ssr", "  metalnessFB created (selective): metalnessTex=${handleIdx(metalnessTex)}"])
                }

                Logger.trace(["ssr", "_ensureRTs done"])
            case None => ()
        }
    }

    private func _createFB(renderer: ThreeRenderer, tex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => tex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let normalFB = this._normalFB; let depthFB = this._depthFB
                let ssrFB = this._ssrFB; let blurFB = this._blurFB; let blur2FB = this._blur2FB
                let metalnessFB = this._metalnessFB
                let normalTex = this._normalTex; let normalDepthTex = this._normalDepthTex
                let depthTex = this._depthTex; let depthDepthTex = this._depthDepthTex
                let ssrTex = this._ssrTex; let blurTex = this._blurTex; let blur2Tex = this._blur2Tex
                let metalnessTex = this._metalnessTex
                if (isValidHandle(normalFB)) { renderer.destroyFrameBuffer(normalFB) }
                if (isValidHandle(depthFB)) { renderer.destroyFrameBuffer(depthFB) }
                if (isValidHandle(ssrFB)) { renderer.destroyFrameBuffer(ssrFB) }
                if (isValidHandle(blurFB)) { renderer.destroyFrameBuffer(blurFB) }
                if (isValidHandle(blur2FB)) { renderer.destroyFrameBuffer(blur2FB) }
                if (isValidHandle(metalnessFB)) { renderer.destroyFrameBuffer(metalnessFB) }
                if (isValidHandle(normalTex)) { renderer.destroyTexture(normalTex) }
                if (isValidHandle(normalDepthTex)) { renderer.destroyTexture(normalDepthTex) }
                if (isValidHandle(depthTex)) { renderer.destroyTexture(depthTex) }
                if (isValidHandle(depthDepthTex)) { renderer.destroyTexture(depthDepthTex) }
                if (isValidHandle(ssrTex)) { renderer.destroyTexture(ssrTex) }
                if (isValidHandle(blurTex)) { renderer.destroyTexture(blurTex) }
                if (isValidHandle(blur2Tex)) { renderer.destroyTexture(blur2Tex) }
                if (isValidHandle(metalnessTex)) { renderer.destroyTexture(metalnessTex) }
                this._normalFB = INVALID_FRAME_BUFFER_HANDLE
                this._normalTex = INVALID_TEXTURE_HANDLE
                this._normalDepthTex = INVALID_TEXTURE_HANDLE
                this._depthFB = INVALID_FRAME_BUFFER_HANDLE
                this._depthTex = INVALID_TEXTURE_HANDLE
                this._depthDepthTex = INVALID_TEXTURE_HANDLE
                this._ssrFB = INVALID_FRAME_BUFFER_HANDLE
                this._ssrTex = INVALID_TEXTURE_HANDLE
                this._blurFB = INVALID_FRAME_BUFFER_HANDLE
                this._blurTex = INVALID_TEXTURE_HANDLE
                this._blur2FB = INVALID_FRAME_BUFFER_HANDLE
                this._blur2Tex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    // ===== 自建场景几何体 VB/IB/layout（对齐 GTAOPass 模式） =====

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

    private func _createVB(geom: BufferGeometry): VertexBufferHandle {
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
                match (this._renderer) {
                    case Some(renderer) =>
                        // 经 renderer 高阶 API 创建顶点缓冲：createVertexLayout(attrs) 建布局句柄，
                        // createVertexBufferFromLayout 内部从 handle 查回 layout 内存指针创建 VB。
                        let layout = this._getOrCreateLayout(renderer)
                        let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
                        this._vbCache.add(geomId, handle)
                        return handle
                    case None => return INVALID_VERTEX_BUFFER_HANDLE
                }
            case None => return INVALID_VERTEX_BUFFER_HANDLE
        }
    }

    private func _createIB(geom: BufferGeometry): IndexBufferHandle {
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
                match (this._renderer) {
                    case Some(renderer) =>
                        let handle = renderer.createIndexBuffer(mem, flags: 0u16)
                        this._ibCache.add(geomId, handle)
                        return handle
                    case None => return INVALID_INDEX_BUFFER_HANDLE
                }
            case None => return INVALID_INDEX_BUFFER_HANDLE
        }
    }

    // ===== Pass.render 入口 =====

    /**
     * Pass.render 入口：执行 SSR 链并输出反射应用到场景。
     *
     * 流程：
     *   1. 法线 pass（view+0）→ 2. 深度 pass（view+1）→ 3. SSR 计算（view+2）→
     *   4. 模糊 1（view+3）→ 5. 模糊 2（view+4）→ 6. 输出（view+5）
     *
     * 各渲染子方法通过 Pass 基类高阶 API（setViewport / setRenderTarget /
     * clearRenderTarget / bindTexture / getTexture / setUniform / submitQuad）
     * 调用 bgfx，这些高阶 API 自身走 renderer.execBgfx 序列化到渲染线程，
     * 故不再外层包裹 renderer.execBgfx（避免嵌套死锁）。
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        if (!this.enabled) { return }
        this._renderer = Some(renderer)
        // 尺寸未设置时默认取渲染器尺寸
        if (this._width <= 0 || this._height <= 0) {
            this._width = Int64(renderer.width)
            this._height = Int64(renderer.height)
            let rawMaxStep = Int64(sqrt(Float64(this._width * this._width + this._height * this._height)))
            this._maxStep = min(rawMaxStep, 1024i64)
        }

        let sceneOpt = this._scene
        let camOpt = this._camera
        match (sceneOpt) {
            case Some(scene) => match (camOpt) {
                case Some(camera) =>
                    this._ensureRTs()
                    if (!isValidHandle(this._normalFB)) {
                        Logger.trace(["ssr", "render: _ensureRTs failed, normalFB invalid"])
                        return
                    }

                    let baseView = SSRPass.SSR_VIEW_ID_BASE
                    let uniforms = this._uniforms

                    // ===== 注意：不再在渲染开始前"预编译所有 shader" =====
                    //   各 _renderXXX 子方法内部已自带懒编译（!isValidHandle(programHandle) 时才编译）。
                    //   预编译会导致第一帧同时分配 5 个 shader 的 String→Array<UInt8> 临时内存
                    //   （+ Logger.debug 字符串拼接），瞬间 GC 压力过大触发仓颉 STW GC；
                    //   主线程此时在 wndProc / DispatchMessageW 与渲染循环之间切换，
                    //   GC 的 TransitionAllMutatorsToGCPhase 可能因主线程卡在 FFI/C 栈帧
                    //   或 IME 内部消息上无法进入 safe-point → 崩溃（CJ_MRT_FlushGCInfo）。
                    //   改为懒编译：每个 shader 在首次真正需要时才编译，分散 GC 压力。

                    Logger.trace(["ssr", "render: starting 6-pass chain, output=${this.output}"])

                    // ===== 0. 地面反射器协作（可选，render 开头 doRender）=====
                    //   渲反射贴图：computeVirtualCamera（镜像数学）→ 渲场景到反射 RT（view 0 语义
                    //   + renderer.render，参照 RenderPass 范式）→ useDepthTexture 时渲深度 RT。
                    //   防自反射 + SSR 各 pass 不含地面：渲反射期间及 SSR 各 pass 期间反射面
                    //   visible=false（beauty 渲完 groundReflector.visible=false），
                    //   链末恢复 visible=true（下一帧 RenderPass 渲 readBuffer 时地面可见，
                    //   反射贴图滞后一帧可接受——同帧语义是 SSRPass 自己渲 beauty 才有的）。
                    match (this.groundReflector) {
                        case Some(reflector) =>
                            reflector.visible = false
                            this._renderGroundReflector(renderer, scene, camera, reflector)
                        case None => ()
                    }

                    // ===== view ID 分配（关键：bgfx 按 view ID 升序执行 GPU draw，不按提交顺序）=====
                    //   数据依赖：normal/depth/metalness 必须在 ssrCalc 之前完成（SSR 采样这三张 RT），
                    //   ssrCalc 必须在 blur 之前，blur 在 output 之前。
                    //   故 ID 必须严格按依赖递增：normal(+0) < depth(+1) < metalness(+2) <
                    //   ssrCalc(+3) < blur1(+4) < blur2(+5) < output(+6)。
                    //   此前 metalness 用 +6、ssrCalc 用 +2，导致 ssrCalc 先于 metalness 执行，
                    //   SSR_FS 采样到上一帧（首帧为清屏黑=metalness 0）的 metalness RT，
                    //   与按 render() 调用顺序同步执行的语义不符。
                    // ===== 1. 法线 pass（view+0）=====
                    this._renderNormals(renderer, scene, camera, baseView)
                    // ===== 2. 深度 pass（view+1）=====
                    this._renderDepth(renderer, scene, camera, UInt16(UInt16(baseView) + 1u16))
                    // ===== 3. 金属度 pass（view+2，仅 selective 时）=====
                    if (this.selective) {
                        this._renderMetalness(renderer, scene, camera, UInt16(UInt16(baseView) + 2u16))
                    }
                    // ===== 4. SSR 计算 pass（view+3）=====
                    this._renderSSRCalc(renderer, camera, readBuffer, UInt16(UInt16(baseView) + 3u16), uniforms)
                    // ===== 5. 模糊 pass 1（view+4）=====
                    if (this.blur) {
                        this._renderBlur(renderer, UInt16(UInt16(baseView) + 4u16), this._ssrTex, this._blurFB, uniforms)
                        // ===== 6. 模糊 pass 2（view+5） =====
                        this._renderBlur(renderer, UInt16(UInt16(baseView) + 5u16), this._blurTex, this._blur2FB, uniforms)
                    }
                    // ===== 7. 输出 pass（view+6）=====
                    this._renderOutput(renderer, readBuffer, writeBuffer, UInt16(UInt16(baseView) + 6u16), uniforms)
                    Logger.trace(["ssr", "render: 6-pass chain done"])
                    // 链末恢复反射面可见（下一帧 RenderPass 渲 readBuffer 时地面显示反射贴图）
                    match (this.groundReflector) {
                        case Some(reflector) => reflector.visible = true
                        case None => ()
                    }
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * 法线 pass：normal shader 渲场景到法线 RT。
     */
    private func _renderNormals(renderer: ThreeRenderer, scene: Scene, camera: Camera, baseView: UInt16): Unit {
        let viewId = baseView
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._normalFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为中性法线编码：view space +Z = (0,0,1) 编码为 (0.5,0.5,1.0)
        // bgfx clear color 为 ABGR 格式（见 BgfxBackground.uint32FromRGBA）：
        //   uint32 = (A<<24)|(B<<16)|(G<<8)|R
        //   要得到 RGBA=(0.5,0.5,1.0,0.0) 即 R=0x80,G=0x80,B=0xFF,A=0x00
        //   ABGR = 0x00FF8080（而非 0x008080FF，后者实际产生 RGBA=(1.0,0.5,0.5)=法线+X）
        // 背景法线朝远处（+Z 在左手系 bgfx 中是远处，即背向相机），
        // SSR shader 中 dot(viewReflectDir, vN)>=0 会 break，背景不产生反射。
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00FF8080u32, depth: 1.0f32, stencil: 0u8)

        let normalProgOpt = ShaderLibs.get("normal")
        match (normalProgOpt) {
            case Some(normalSp) =>
                if (!isValidHandle(Box(normalSp.programHandle))) {
                    normalSp.compileBgfx()
                }
                let normalProg = Box(normalSp.programHandle)
                if (!isValidHandle(normalProg)) {
                    Logger.trace(["ssr", "normal pass: prog compile FAILED"])
                    return
                }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                // view 矩阵 3x3（法线 RT 需要 view space 法线，u_normalMatrix = mat3(view) × mat3(model)）
                let viewMtx = camera.matrixWorldInverse.elements
                let uniforms = this._uniforms
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // u_normalMatrix = mat3(view) × mat3(model)（3x3 列主序 → 紧凑 9 floats bgfx UniformType.Mat3）
                            // 用户实验 + 仓颉 range 语法确认（0..3 = 不含 3 的 0/1/2 三值）：
                            //   - PostProcessingShaders 自定义 shader 中，bgfx mat3 uniform 实际按
                            //     紧凑 9 floats 读取（3 列×3 rows 连续，每列不 pad 到 vec4）
                            //   - 如果写入 c*4+r（主渲染器的 vec4 padding 格式），紧凑读取时
                            //     Float32[3]=0 会被当成 col1 row0、Float32[6]=[c1r2] 错位，
                            //     Y 方向列（地板/天花板法线）的分量完全错乱 → 倒影消失；
                            //     水平侧墙 col0 (X) 的 3 个元素位置恰好正确 → 只剩一点水平反射。
                            //   - c*3+r（紧凑 9 floats）：写入布局匹配 shader 读取方式，
                            //     所有方向的法线（含地板/天花板的 Y 分量）都正确 → 倒影完整。
                            // 注：仓颉 for (c/r/k in 0..3) 中 = 0/1/2（不包含 3），不会迭代第 4 列/行，
                            //   因此不会越界写 Array。BgfxMemory(48u32) = 48 bytes > 9 Float32 = 36 bytes，
                            //   writeFloats(nmData, 12) 多写的 3 zeros 是安全富余（bgfx 不读超过 9 的部分），
                            //   不会导致崩溃。之前的"一帧崩"是 GC/驱动/shader编译叠加的其他问题，
                            //   已由 precompileShaders + MAX_STEP 编译期 define 方案解决。
                            let nmData = Array<Float64>(12, { i => 0.0 })
                            for (c in 0..3) {   // 仓颉 0..3 = 3 列（0,1,2），不包含 3
                                for (r in 0..3) { // 仓颉 0..3 = 3 行（0,1,2），不包含 3
                                    var acc = 0.0
                                    for (k in 0..3) { // 仓颉 0..3 = 3 内积项（0,1,2）
                                        acc += viewMtx[k * 4 + r] * mtxArr[c * 4 + k]
                                    }
                                    nmData[c * 3 + r] = acc
                                }
                            }
                            let uNormalMat = uniforms.createUniform("u_normalMatrix", UniformType.Mat3.value())
                            let nmMem = BgfxMemory(48u32)
                            nmMem.writeFloats(nmData, 12)
                            this.setUniform(renderer, uNormalMat, nmMem)

                            // u_opacity（normalFS 用 alpha，补齐保持材质语义）
                            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                            let oMem = BgfxMemory(16u32)
                            oMem.writeFloats([1.0, 1.0, 1.0, 1.0], 4)
                            this.setUniform(renderer, uOpacity, oMem)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(ro.geometry)
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
                Logger.trace(["ssr", "normal pass done: prog= submitCnt="])
            case None => Logger.trace(["ssr", "normal pass: normal shader NOT registered in ShaderLibs"])
        }
    }

    /**
     * 深度 pass：aodepth shader 渲场景到深度 RT（写 gl_FragCoord.z = NDC 深度）。
     * 用独立深度 RT（对齐 GTAO）。
     */
    private func _renderDepth(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._depthFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为白色（NDC 深度=1.0=far）：背景无片元时保持 1.0，SSR shader 用 depth>=0.999 跳过背景
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        let depthProgOpt = PostProcessingShaders.get("aodepth")
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (!isValidHandle(Box(depthSp.programHandle))) {
                    depthSp.compileBgfx()
                }
                let depthProg = Box(depthSp.programHandle)
                if (!isValidHandle(depthProg)) {
                    Logger.trace(["ssr", "depth pass: aodepth program compile FAILED"])
                    return
                }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(ro.geometry)
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
                Logger.trace(["ssr", "depth pass done: prog= submitCnt="])
            case None => Logger.trace(["ssr", "depth pass: aodepth shader NOT registered"])
        }
    }

    /**
     * 金属度 pass：ssr_metalness shader 渲场景到 metalness RT。
     *
     * 实现范式（与 _renderNormals/_renderDepth 一致，走"自建几何 + shader override"路径，
     * 而非 per-mesh 材质替换——避免渲染线程并发改写 mesh.material 风险）：
     *   - selects 列表中的 mesh → u_metalness = (1.0, 1.0, 1.0, 1.0)（白色=金属）
     *   - 其他 mesh               → u_metalness = (0.0, 0.0, 0.0, 1.0)（黑色=非金属）
     * RT clear 为黑色 = metalness=0 背景。
     *
     * 注：本 pass 仅在 selective=true 时调用（render 链在此条件下插入）。
     */
    private func _renderMetalness(renderer: ThreeRenderer, scene: Scene, camera: Camera, viewId: UInt16): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._metalnessFB)
        this._setViewTransformFor(renderer, viewId, camera)
        // clear 为黑色（metalness=0 背景）：ABGR=0x00000000（RGBA=(0,0,0,0)），但 RT 不透明故 a=1
        // bgfx clear color 0x00000000 → RGBA=(0,0,0,0)，depth clear 1.0；FS 写 a=1.0 覆盖背景 alpha
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let metalProgOpt = PostProcessingShaders.get("ssr_metalness")
        match (metalProgOpt) {
            case Some(metalSp) =>
                if (!isValidHandle(Box(metalSp.programHandle))) {
                    metalSp.compileBgfx()
                }
                let metalProg = Box(metalSp.programHandle)
                if (!isValidHandle(metalProg)) {
                    Logger.trace(["ssr", "metalness pass: ssr_metalness program compile FAILED"])
                    return
                }

                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                // selects 列表只读引用：每 mesh 比对是否在其中，决定 u_metalness=1.0/0.0
                // 仓颉 ArrayList<Object3D>.contains 范式：遍历比 refEq（Object3D == 重载亦走 refEq）
                let selectsListOpt = this.selects
                var onCnt: Int64 = 0
                var submitCnt: Int64 = 0
                let uniforms = this._uniforms
                let uMetalness = uniforms.createUniform("u_metalness", UniformType.Vec4.value())
                for (ro in renderObjects) {
                    let vb = this._createVB(ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(_) =>
                            let mtxArr = ro.worldMatrix.elements
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            renderer.setTransform(mtxMem, num: 1u16)

                            // 判定本 mesh 是否在 selects 列表内 → u_metalness=1.0 或 0.0
                            var isOn: Bool = false
                            match (selectsListOpt) {
                                case Some(selectsList) =>
                                    for (sel in selectsList) {
                                        if (refEq(ro.mesh, sel)) { isOn = true; break }
                                    }
                                case None => ()
                            }
                            let mVal: Float64 = if (isOn) { 1.0 } else { 0.0 }
                            if (isOn) { onCnt += 1 }
                            let mMem = BgfxMemory(16u32)
                            mMem.writeFloats([mVal, mVal, mVal, 1.0], 4)
                            this.setUniform(renderer, uMetalness, mMem)

                            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                            let ib = this._createIB(ro.geometry)
                            if (isValidHandle(ib)) {
                                renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                            }
                            let metalState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                             BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                             BgfxConstants.FRONT_CCW
                            renderer.setState(metalState, rgba: 0x00000000u32)
                            renderer.submit(viewId, metalProg, depth: 0u32, blend: 0xFFu8)
                            submitCnt += 1
                        case None => ()
                    }
                }
                Logger.trace(["ssr", "metalness pass done: prog= submitCnt= onCnt=${onCnt}"])
            case None => Logger.trace(["ssr", "metalness pass: ssr_metalness shader NOT registered"])
        }
    }

    /**
     * SSR 计算 pass：全屏四边形采样法线/深度/场景色，射线步进输出反射色+不透明度。
     * ssr shader（MAX_STEP, DISTANCE_ATTENUATION, FRESNEL defines）。
     */
    private func _renderSSRCalc(
        renderer: ThreeRenderer,
        camera: Camera,
        readBuffer: FrameBufferHandle,
        viewId: UInt16,
        uniforms: BgfxUniforms
    ): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._ssrFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let ssrProgOpt = PostProcessingShaders.get("ssr")
        match (ssrProgOpt) {
            case Some(ssrSp) =>
                // 带 MAX_STEP + DISTANCE_ATTENUATION + FRESNEL defines 编译
                if (!isValidHandle(Box(ssrSp.programHandle))) {
                    this._compileSSRShader(ssrSp)
                }
                let ssrProg = Box(ssrSp.programHandle)
                if (!isValidHandle(ssrProg)) {
                    Logger.trace(["ssr", "ssrCalc: prog compile FAILED"])
                    return
                }

                Logger.trace(["ssr", "ssrCalc STEP-1: create samplers (tDiffuse/tNormal/tDepth)"])
                // 采样器：stage 0=场景色(readBuffer), 1=法线, 2=深度
                let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                let uDiffuse = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiffuse, sceneTex, 0u32)
                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uNormal, this._normalTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uDepth, this._depthTex, 0u32)
                // selective 模式：绑 metalness RT 到 stage 3（SSR_FS #ifdef SELECTIVE 采样本 RT 跳过非金属）
                if (this.selective) {
                    let uMetalness = uniforms.createUniform("tMetalness", UniformType.Sampler.value())
                    this.bindTexture(renderer, 3u8, uMetalness, this._metalnessTex, 0u32)
                }

                Logger.trace(["ssr", "ssrCalc STEP-2: create uniform u_resolution/u_cameraNearFar"])
                // resolution
                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                // cameraNear/Far
                let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                let nfMem = BgfxMemory(16u32)
                nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                this.setUniform(renderer, uNearFar, nfMem)

                Logger.trace(["ssr", "ssrCalc STEP-3: create uniform u_projMatrix/u_invProjMatrix"])
                // projection / inverse projection
                let uProj = uniforms.createUniform("u_projMatrix", UniformType.Mat4.value())
                let projMem = BgfxMemory(64u32)
                projMem.writeFloats(camera.projectionMatrix.elements, 16)
                this.setUniform(renderer, uProj, projMem)

                let invProj = camera.projectionMatrix.clone().invert()
                let uInvProj = uniforms.createUniform("u_invProjMatrix", UniformType.Mat4.value())
                let invMem = BgfxMemory(64u32)
                invMem.writeFloats(invProj.elements, 16)
                this.setUniform(renderer, uInvProj, invMem)

                Logger.trace(["ssr", "ssrCalc STEP-4: create uniform u_ssrParams/u_debug"])
                // ssrParams: x=opacity, y=maxDistance, z=thickness, w=cameraRange
                let cameraRange = camera.far - camera.near
                let uParams = uniforms.createUniform("u_ssrParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([this.opacity, this.maxDistance, this.thickness, cameraRange], 4)
                this.setUniform(renderer, uParams, pMem)

                // 诊断可视化开关（u_debug.x>0.5 时按拒绝原因着色，默认 0=正常）
                let uDebug = uniforms.createUniform("u_debug", UniformType.Vec4.value())
                let dbgVal: Float64 = if (this.debug) { 1.0 } else { 0.0 }
                let dbgMem = BgfxMemory(16u32)
                dbgMem.writeFloats([dbgVal, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uDebug, dbgMem)

                // ---- 移除 u_ssrStep uniform（完全回到编译期 MAX_STEP define 控制）
                // 之前的动态 uniform 方案会导致 D3DCompiler 无法静态推断循环上界，
                // 即便 define 不参与控制也会触发 CFG 分析膨胀/驱动崩溃。
                // 改为纯编译期方案：_compileSSRShader 将 MAX_STEP=this._maxStep 传入
                // (= min(sqrt(w²+h²), 1024))，shader 内条件3 `if (i>=MAX_STEP+1) break`
                // 是静态整型比较，D3DCompiler 能静态识别循环上界，CFG 可控。

                // ===== 详细日志：记录 SSR 计算关键参数（用户要求辅助诊断伪影问题） =====
                // 涵盖相机、投影、SSR 参数、深度/法线/反射 RT 句柄、shader defines 全量信息，
                // 便于在出现伪影时回溯排查：左手系矩阵、深度范围、UV 翻转、Fresnel/Break 行为等。
                let projElems = camera.projectionMatrix.elements
                let invProjElems = invProj.elements
                Logger.trace([
                    "ssr",
                    "ssrCalc params START --- view=${viewId} rt=${this._width}x${this._height} maxStep(define)=${this._maxStep}",
                    "  camera: near=${camera.near} far=${camera.far} range=${cameraRange} pos=(${camera.position.x}, ${camera.position.y}, ${camera.position.z})",
                    "  ssrParams: opacity=${this.opacity} maxDistance=${this.maxDistance} thickness=${this.thickness} fresnel=${this.fresnel} distAtten=${this.distanceAttenuation} infiniteThick=${this.infiniteThick}",
                    "  projMatrix(row-major-ish, 16 elems): " +
                    "m[0]=${projElems[0]} m[5]=${projElems[5]} m[10]=${projElems[10]} m[11]=${projElems[11]} m[14]=${projElems[14]} m[15]=${projElems[15]}",
                    "  invProjMatrix(key elems): " +
                    "m[0]=${invProjElems[0]} m[5]=${invProjElems[5]} m[10]=${invProjElems[10]} m[11]=${invProjElems[11]} m[14]=${invProjElems[14]} m[15]=${invProjElems[15]}",
                    "  textures: sceneTex=${handleIdx(sceneTex)} normalTex=${handleIdx(this._normalTex)} depthTex=${handleIdx(this._depthTex)} ssrTex=${handleIdx(this._ssrTex)}",
                    "  shaderFix: fresnel-original (dot(incident,reflect)+1)/2; backface/distance check use break (not continue)",
                    "  texFix: all SSR RT textures use SAMPLER_MIN_POINT|SAMPLER_MAG_POINT (NearestFilter)",
                    "ssrCalc params END ---"
                ])

                // 全屏四边形 submit
                this.submitQuad(viewId, ssrProg)
            case None => Logger.trace(["ssr", "ssrCalc: ssr shader NOT registered"])
        }
    }

    /**
     * 编译 SSR shader，带动态 MAX_STEP + DISTANCE_ATTENUATION + FRESNEL defines。
     * 对照 UnrealBloomPass 的 KERNEL_RADIUS define 编译模式。
     *
     * 循环编译说明（用户最终决策——纯编译期 MAX_STEP，移除动态 uniform）：
     *   MAX_STEP 按 this._maxStep = min(sqrt(w²+h²), 1024) 动态传入 define。
     *   这样：
     *     - 分辨率适中（1920×1080 → rawMaxStep≈2202，截 1024），MAX_STEP=1024 →
     *       stepSize = max(1.0, totalStep / 1024)。大部分像素 totalStep<1024 →
     *       stepSize=1.0 细密 1 像素步采样；对角线像素 totalStep≈2202 →
     *       stepSize≈2.15，1024 步覆盖完整射线不截断（略有稀疏）。
     *     - 分辨率较低（1280×720 → rawMaxStep≈1465，截 1024）→ 同上。
     *     - 分辨率很低（800x600 → rawMaxStep=1000，不超 1024 取实际值 1000）→
     *       MAX_STEP=1000 → stepSize ≤1 → 细密采样无精度损失。
     *   配合循环内静态 break `if (i >= MAX_STEP+1) break;`：D3DCompiler 能静态识别
     *   循环上界（整型常量比较），CFG/寄存器分配可控 → 不膨胀、不崩溃。
     *   历史：动态 uniform 方案（u_ssrStep.x）曾导致第一帧驱动崩溃，已舍弃。
     *
     * （setSize 通常发生在首帧之前，此时 _compiledMaxStep=-1，首次编译直接使用当前 _maxStep）
     */
    private var _compiledMaxStep: Int64 = -1

    private func _compileSSRShader(sp: ShaderProgram): Unit {
        // 构建 defines 列表
        let definesList = ArrayList<String>()
        // MAX_STEP：动态取 _maxStep（= min(sqrt(w²+h²), 1024)）
        let ms = this._maxStep
        definesList.add("MAX_STEP=${ms.toString()}")
        // 若 MAX_STEP 变了且已编译过，重置 programHandle 让 compileBgfxWithDefines 重编译
        // 注：ShaderProgram 暂未暴露 dispose 接口，这里直接把三个 handle 置为未初始化状态（65535u16），
        // 等价于强制重编译（compileBgfxWithDefines 内部每次都会完整重编译）。
        if (this._compiledMaxStep > 0 && this._compiledMaxStep != ms && isValidHandle(Box(sp.programHandle))) {
            sp.resetHandles()
        }
        this._compiledMaxStep = ms
        if (this.distanceAttenuation) {
            definesList.add("DISTANCE_ATTENUATION")
        }
        if (this.fresnel) {
            definesList.add("FRESNEL")
        }
        if (this.infiniteThick) {
            definesList.add("INFINITE_THICK")
        }
        // SELECTIVE：selective 模式启用，SSR_FS #ifdef SELECTIVE 采 metalness RT 跳过非金属表面
        if (this.selective) {
            definesList.add("SELECTIVE")
        }

        sp.compileBgfx(extraDefines: definesList.toArray())

        // ===== 临时调试：转储 SSR shader 源码到文件（已注释——仅排查阶段使用，正常运行时不需要）=====
        // 以下 dump 逻辑在每次 SSR shader 编译时把编译后 glsl 写入 ssr_shader_dump 目录，
        // 排查完成后按用户要求注释掉，避免运行时无谓的文件 IO。
        // try {
        //     let dumpDir = getWorkingDirectory().join("ssr_shader_dump")
        //     if (!exists(dumpDir)) {
        //         Directory.create(dumpDir, recursive: true)
        //     }
        //     File.writeTo(dumpDir.join("ssr_fs.glsl"), sp.fragmentShaderBgfx.toArray())
        //     File.writeTo(dumpDir.join("ssr_vs.glsl"), sp.vertexShaderBgfx.toArray())
        //     File.writeTo(dumpDir.join("ssr_defines.txt"), ("defines: " + definesList.toString() + "\n").toArray())
        //     match (PostProcessingShaders.get("ssrblur")) {
        //         case Some(blurSp) => File.writeTo(dumpDir.join("ssrblur_fs.glsl"), blurSp.fragmentShaderBgfx.toArray())
        //         case None => ()
        //     }
        //     match (PostProcessingShaders.get("ssrapply")) {
        //         case Some(applySp) => File.writeTo(dumpDir.join("ssrapply_fs.glsl"), applySp.fragmentShaderBgfx.toArray())
        //         case None => ()
        //     }
        //     match (PostProcessingShaders.get("aodepth")) {
        //         case Some(depthSp) => File.writeTo(dumpDir.join("aodepth_fs.glsl"), depthSp.fragmentShaderBgfx.toArray())
        //         case None => ()
        //     }
        //     match (ShaderLibs.get("normal")) {
        //         case Some(normalSp) => File.writeTo(dumpDir.join("normal_fs.glsl"), normalSp.fragmentShaderBgfx.toArray())
        //         case None => ()
        //     }
        //     match (PostProcessingShaders.get("ssr_metalness")) {
        //         case Some(metalSp) => File.writeTo(dumpDir.join("ssr_metalness_fs.glsl"), metalSp.fragmentShaderBgfx.toArray())
        //         case None => ()
        //     }
        //     Logger.trace(["ssr", "_compileSSRShader: shader source dumped to ${dumpDir.toString()}"])
        // } catch (e: Exception) {
        //     Logger.trace(["ssr", "_compileSSRShader: dump failed: ${e.message}"])
        // }

        Logger.trace(["ssr", "_compileSSRShader: defines=${definesList.size} maxStep(define)=${this._maxStep}"])
    }

    /**
     * 预编译所有 SSR shader，避免渲染帧内逐 pass 懒编译。
     *
     * 历史迁移中多次出现在渲染帧内懒编译最后一个 shader 时 sc_compile 硬崩（无错误码，
     * 进程直接终止）。预编译确保所有 shader 在任何 bgfx view 操作前完成编译，
     * 避免潜在的内存碎片/资源竞争/sc 内部状态问题。
     *
     * 已修复的多根因：
     *   1. SSR_FS 超大 for(;;MAX_STEP) 循环 → 开放式 for + [loop] + 动态距离break + 静态MAX_STEP+1 break + stepSize自适应放缩 + MAX_STEP cap 1024
     *   2. AO_DEPTH/SSAO_DEPTH FS 零输入 varying → 加 v_ndcDummy 占位，避免 D3DCompiler 边缘路径崩
     *
     * 编译顺序：aodepth → ssr → ssrblur → ssrdepth → ssrapply
     * 其中 ssr 带 MAX_STEP + define 编译，其余无 define。
     */
    private func _preCompileShaders(): Unit {
        // aodepth（GTAO/SAO 共用深度 shader，SSR 深度 pass 借用；零 varying 历史上多次崩溃）
        match (PostProcessingShaders.get("aodepth")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling aodepth shader"])
                    sp.compileBgfx()
                }
            case None => ()
        }
        // ssr（带 defines）
        match (PostProcessingShaders.get("ssr")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling ssr shader"])
                    this._compileSSRShader(sp)
                }
            case None => ()
        }
        // ssrblur（无 defines）
        match (PostProcessingShaders.get("ssrblur")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling ssrblur shader"])
                    sp.compileBgfx()
                }
            case None => ()
        }
        // ssrdepth（无 defines）
        match (PostProcessingShaders.get("ssrdepth")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling ssrdepth shader"])
                    sp.compileBgfx()
                }
            case None => ()
        }
        // ssrapply（无 defines）
        match (PostProcessingShaders.get("ssrapply")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling ssrapply shader"])
                    sp.compileBgfx()
                }
            case None => ()
        }
        // normal shader（法线 pass 用，来自 ShaderLibs）
        match (ShaderLibs.get("normal")) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    Logger.trace(["ssr", "preCompile: compiling normal shader"])
                    sp.compileBgfx()
                }
            case None => ()
        }
        Logger.trace(["ssr", "preCompile: all shaders compiled"])
    }

    /**
     * 模糊 pass：全屏四边形 5 抽头 alpha 加权模糊。
     * ssrblur shader。
     *
     * @param viewId bgfx view id
     * @param inputTex 输入纹理（ssrTex 或 blurTex）
     * @param outputFB 输出 frame buffer
     * @param uniforms uniform 注册表
     */
    private func _renderBlur(
        renderer: ThreeRenderer,
        viewId: UInt16,
        inputTex: TextureHandle,
        outputFB: FrameBufferHandle,
        uniforms: BgfxUniforms
    ): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, outputFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let blurProgOpt = PostProcessingShaders.get("ssrblur")
        match (blurProgOpt) {
            case Some(blurSp) =>
                if (!isValidHandle(Box(blurSp.programHandle))) {
                    blurSp.compileBgfx()
                }
                let blurProg = Box(blurSp.programHandle)
                if (!isValidHandle(blurProg)) {
                    Logger.trace(["ssr", "blur: prog compile FAILED"])
                    return
                }

                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, inputTex, 0u32)

                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                Logger.trace(["ssr", "blur: prog=${handleIdx(blurProg)} inputTex=${handleIdx(inputTex)}"])
                this.submitQuad(viewId, blurProg)
            case None => Logger.trace(["ssr", "blur: ssrblur shader NOT registered"])
        }
    }

    /**
     * 输出 pass：按 output 模式输出到 writeBuffer（renderToScreen=true 时写屏幕）。
     * 对应 output 的 switch 分支：
     *   - Default：ssrapply（sceneColor × (1-ssrAlpha) + ssrColor × ssrAlpha，合并 copy+blend 两步）
     *   - SSR：copy shader 透传 blur2/ssr 纹理
     *   - Beauty：copy shader 透传 readBuffer 场景色
     *   - Depth：ssrdepth shader（1.0 - 线性深度可视化）
     *   - Normal：copy shader 透传法线纹理
     */
    private func _renderOutput(
        renderer: ThreeRenderer,
        readBuffer: FrameBufferHandle,
        writeBuffer: FrameBufferHandle,
        viewId: UInt16,
        uniforms: BgfxUniforms
    ): Unit {
        // 目标：renderToScreen（最后一个 enabled pass）→ swap chain（无效 FB handle）；否则 writeBuffer
        if (this.renderToScreen) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
        } else {
            this.setRenderTarget(renderer, viewId, writeBuffer)
        }
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        // Depth 模式：ssrdepth shader（tDepth + cameraNearFar）
        if (this.output == SSRPass.OUTPUT_DEPTH) {
            let depthProgOpt = PostProcessingShaders.get("ssrdepth")
            match (depthProgOpt) {
                case Some(depthSp) =>
                    if (!isValidHandle(Box(depthSp.programHandle))) {
                        depthSp.compileBgfx()
                    }
                    let depthProg = Box(depthSp.programHandle)
                    if (!isValidHandle(depthProg)) {
                        Logger.trace(["ssr", "output depth: ssrdepth compile FAILED"])
                        return
                    }
                    let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                    this.bindTexture(renderer, 0u8, uDepth, this._depthTex, 0u32)
                    match (this._camera) {
                        case Some(camera) =>
                            let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                            let nfMem = BgfxMemory(16u32)
                            nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                            this.setUniform(renderer, uNearFar, nfMem)
                        case None => ()
                    }
                    Logger.trace(["ssr", "output depth: prog=${handleIdx(depthProg)}"])
                    this.submitQuad(viewId, depthProg)
                case None => Logger.trace(["ssr", "output depth: ssrdepth shader NOT registered"])
            }
            return
        }

        // Default 模式：ssrapply（sceneColor × (1-ssrAlpha) + ssrColor × ssrAlpha）
        if (this.output == SSRPass.OUTPUT_DEFAULT) {
            let applyProgOpt = PostProcessingShaders.get("ssrapply")
            match (applyProgOpt) {
                case Some(applySp) =>
                    if (!isValidHandle(Box(applySp.programHandle))) {
                        applySp.compileBgfx()
                    }
                    let applyProg = Box(applySp.programHandle)
                    if (!isValidHandle(applyProg)) {
                        Logger.trace(["ssr", "output default: ssrapply compile FAILED"])
                        return
                    }
                    // tDiffuse = 场景色（readBuffer）
                    let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                    let uScene = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                    this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                    // tSSR = blur2（如果模糊开启）或 ssr 结果
                    var ssrSrcTex = this._ssrTex
                    if (this.blur) {
                        ssrSrcTex = this._blur2Tex
                    }
                    let uSSR = uniforms.createUniform("tSSR", UniformType.Sampler.value())
                    this.bindTexture(renderer, 1u8, uSSR, ssrSrcTex, 0u32)
                    Logger.trace(["ssr", "output default: sceneTex=${handleIdx(sceneTex)}ssrSrcTex=${handleIdx(ssrSrcTex)}}lur=${this.blur}"])
                    this.submitQuad(viewId, applyProg)
                case None => Logger.trace(["ssr", "output default: ssrapply shader NOT registered"])
            }
            return
        }

        // SSR 模式：copy shader 透传 blur2/ssr 纹理
        if (this.output == SSRPass.OUTPUT_SSR) {
            var srcTex = this._ssrTex
            if (this.blur) {
                srcTex = this._blur2Tex
            }
            this._renderCopyOutput(renderer, viewId, srcTex, uniforms)
            return
        }

        // Beauty 模式：copy shader 透传 readBuffer 场景色
        if (this.output == SSRPass.OUTPUT_BEAUTY) {
            let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
            this._renderCopyOutput(renderer, viewId, sceneTex, uniforms)
            return
        }

        // Normal 模式：copy shader 透传法线纹理
        if (this.output == SSRPass.OUTPUT_NORMAL) {
            this._renderCopyOutput(renderer, viewId, this._normalTex, uniforms)
            return
        }

        // HitNormals 模式（调试用）：显示命中点法线
        if (this.output == SSRPass.OUTPUT_HITNORMALS) {
            this._renderHitNormals(renderer, viewId, uniforms)
            return
        }
    }

    /**
     * 渲染命中点法线调试视图：ssr 计算时不仅输出反射颜色，还输出命中点法线
     */
    private func _renderHitNormals(
        renderer: ThreeRenderer,
        viewId: UInt16,
        uniforms: BgfxUniforms
    ): Unit {
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        this.setRenderTarget(renderer, viewId, this._ssrFB)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        let hitNormalsProgOpt = PostProcessingShaders.get("ssr_hitnormals")
        match (hitNormalsProgOpt) {
            case Some(sp) =>
                if (!isValidHandle(Box(sp.programHandle))) {
                    sp.compileBgfx()
                }
                let prog = Box(sp.programHandle)
                if (!isValidHandle(prog)) {
                    Logger.trace(["ssr", "hitnormals: prog compile FAILED"])
                    return
                }

                let uNormal = uniforms.createUniform("tNormal", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uNormal, this._normalTex, 0u32)
                let uDepth = uniforms.createUniform("tDepth", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDepth, this._depthTex, 0u32)

                let uRes = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(this._width), Float64(this._height), 0.0, 0.0], 4)
                this.setUniform(renderer, uRes, resMem)

                match (this._camera) {
                    case Some(camera) =>
                        let uNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
                        let nfMem = BgfxMemory(16u32)
                        nfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
                        this.setUniform(renderer, uNearFar, nfMem)

                        let uProj = uniforms.createUniform("u_projMatrix", UniformType.Mat4.value())
                        let projMem = BgfxMemory(64u32)
                        projMem.writeFloats(camera.projectionMatrix.elements, 16)
                        this.setUniform(renderer, uProj, projMem)

                        let invProj = camera.projectionMatrix.clone().invert()
                        let uInvProj = uniforms.createUniform("u_invProjMatrix", UniformType.Mat4.value())
                        let invMem = BgfxMemory(64u32)
                        invMem.writeFloats(invProj.elements, 16)
                        this.setUniform(renderer, uInvProj, invMem)
                    case None => ()
                }

                Logger.trace(["ssr", "hitnormals: prog=${handleIdx(prog)}"])
                this.submitQuad(viewId, prog)
            case None => Logger.trace(["ssr", "hitnormals: ssr_hitnormals shader NOT registered"])
        }
    }

    /** copy shader 透传辅助：用 PostProcessingShaders "copy" 透传指定纹理到输出。 */
    private func _renderCopyOutput(
        renderer: ThreeRenderer,
        viewId: UInt16,
        srcTex: TextureHandle,
        uniforms: BgfxUniforms
    ): Unit {
        let copyProgOpt = PostProcessingShaders.get("copy")
        match (copyProgOpt) {
            case Some(copySp) =>
                if (!isValidHandle(Box(copySp.programHandle))) {
                    copySp.compileBgfx()
                }
                let copyProg = Box(copySp.programHandle)
                if (!isValidHandle(copyProg)) {
                    Logger.trace(["ssr", "output copy: copy compile FAILED"])
                    return
                }
                let uDiff = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiff, srcTex, 0u32)
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let oMem = BgfxMemory(16u32)
                oMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, oMem)
                Logger.trace(["ssr", "output copy: srcTex=${handleIdx(srcTex)}"])
                this.submitQuad(viewId, copyProg)
            case None => Logger.trace(["ssr", "output copy: copy shader NOT registered"])
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（改用 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
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
            // 跳过不可见对象（防自反射：渲反射场景前反射面 visible=false，
            // 深度/法线/金属度 pass 不收集反射面自身）
            if (!child.visible) { continue }
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

    /**
     * 地面反射器协作：渲反射贴图到反射 RT。
     * 对应 render 开头的协作序列：
     *   groundReflector.visible = false;
     *   groundReflector.doRender(renderer, scene, camera);
     *   groundReflector.visible = true;
     *
     * 实现（包依赖约束：objects 不能依赖 renderers，故协作编排在本 pass）：
     *   1. reflector.computeVirtualCamera(camera)：镜像相机数学（fresnelCoe/镜像相机/textureMatrix）
     *   2. 反射面朝向检测失败（computeVirtualCamera 返回 false）→ 跳过
     *   3. 临时隐藏反射面（visible=false，防自反射：反射场景不含地面自身）
     *   4. 渲场景到反射 RT（view 0 语义 + renderer.render(scene, virtualCamera)，参照 RenderPass 范式）
     *   5. useDepthTexture=true 时：额外渲 NDC 深度到 RGBA32F 深度 RT（aodepth）
     *   6. 恢复反射面可见（visible=true，后续 beauty 渲染含反射面）
     *
     * @param renderer 渲染器
     * @param scene 场景
     * @param camera 主相机
     * @param reflector 地面反射器
     */
    private func _renderGroundReflector(
        renderer: ThreeRenderer,
        scene: Scene,
        camera: Camera,
        reflector: GroundReflector
    ): Unit {
        // 1+2. 镜像相机数学 + 朝向检测（false=反射面背向相机，跳过）
        if (!reflector.computeVirtualCamera(camera)) {
            Logger.trace(["ssr", "groundReflector: facing away, skip reflection render"])
            return
        }
        // 3. 防自反射：临时隐藏反射面
        let wasVisible = reflector.visible
        reflector.visible = false

        // 4. 渲场景到反射 RT（独立 view + renderer.render，参照 RenderPass 范式）
        //    ★关键 bgfx 差异：不能与 RenderPass 共用 view 0！
        //      bgfx 中同一 view 的所有 draw 都输出到该 view 最后一次设置的 FB——
        //      若反射渲 view 0，会把 RenderPass 渲 readBuffer 的场景也重定向到反射 RT
        //      （readBuffer 收不到场景，SSR 采样读空/错帧，画面错乱）。
        //      故渲反射场景时临时把 renderer.viewId 切到 REFLECTOR_VIEW_ID_BASE（独立 view），
        //      渲完恢复 renderer.viewId=0（主渲染 view 语义）。
        //    注：不能把 renderer.render 放进 execBgfx 闭包（_execBgfx 嵌套死锁）；
        //    先 execBgfx 设独立 view FB + clear，再单独调 renderer.render。
        //    renderer.render 内部用 reflector.virtualCamera 的 matrixWorldInverse/projectionMatrix
        //    设 view transform（BgfxBackend 从 camera 读取）。
        let savedViewId = renderer.viewId
        renderer.viewId = GroundReflector.REFLECTOR_VIEW_ID_BASE
        let (texW, texH) = reflector.getTextureSize()
        // 独立 view 的 FB/rect/clear 经 Pass 高阶 API 设置（各自走 execBgfx 序列化，不嵌套）。
        this.setRenderTarget(renderer, renderer.viewId, reflector.getReflectFB())
        this.setViewport(renderer, renderer.viewId, 0u16, 0u16, UInt16(texW), UInt16(texH))
        this.clearRenderTarget(renderer, renderer.viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
        Logger.trace(["ssr", "groundReflector: rendering scene to reflect RT (${texW}x${texH}) view=${renderer.viewId}"])
        renderer.render(scene, reflector.virtualCamera)
        renderer.viewId = savedViewId

        // 5. useDepthTexture=true：渲 NDC 深度到反射深度 RT（aodepth shader）
        if (reflector.useDepthTexture) {
            this._renderReflectorDepth(renderer, scene, reflector)
        }

        // 6. 恢复反射面可见
        reflector.visible = wasVisible
        Logger.trace(["ssr", "groundReflector: done, reflectTex=${handleIdx(reflector.getRenderTarget())}"])
    }

    /**
     * 渲反射场景 NDC 深度到反射深度 RT（useDepthTexture=true 时调用）。
     * 反射 RT 的 depthTexture 由场景渲染自动写入；
     * bgfx D24 attachment 不可采样，故用 aodepth shader 渲 gl_FragCoord.z 到 RGBA32F。
     * 对齐 SSR/GTAO 独立深度 RT 范式。
     *
     * @param renderer 渲染器
     * @param scene 场景
     * @param reflector 地面反射器（虚拟相机已由 computeVirtualCamera 计算）
     */
    private func _renderReflectorDepth(
        renderer: ThreeRenderer,
        scene: Scene,
        reflector: GroundReflector
    ): Unit {
        let viewId = UInt16(UInt16(GroundReflector.REFLECTOR_VIEW_ID_BASE) + 1u16)
        let (texW, texH) = reflector.getTextureSize()
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(texW), UInt16(texH))
        this.setRenderTarget(renderer, viewId, reflector.getReflectDepthFB())
        this._setViewTransformFor(renderer, viewId, reflector.virtualCamera)
        // clear 为白色（NDC 深度=1.0=far）
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0xFFFFFFFFu32, depth: 1.0f32, stencil: 0u8)

        match (PostProcessingShaders.get("aodepth")) {
            case Some(depthSp) =>
                if (!isValidHandle(Box(depthSp.programHandle))) {
                    depthSp.compileBgfx()
                }
                let depthProg = Box(depthSp.programHandle)
                if (!isValidHandle(depthProg)) {
                    Logger.trace(["ssr", "reflectorDepth: aodepth compile FAILED"])
                    return
                }
                let layout = this._getOrCreateLayout(renderer)
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(scene, renderObjects)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = this._createVB(ro.geometry)
                    if (!isValidHandle(vb)) { continue }
                    let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(ro.geometry)
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
                Logger.trace(["ssr", "reflectorDepth done: prog= submitCnt="])
            case None => Logger.trace(["ssr", "reflectorDepth: aodepth NOT registered"])
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
