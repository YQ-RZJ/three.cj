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
 * @file[zh-cn] RenderTransitionPass 场景过渡渲染 pass
 * @brief[zh-cn] 场景过渡渲染 pass —— 从场景 A 平滑过渡到场景 B
 * @explain[zh-cn] 算法（完整非简化移植）：
 *         1. 渲染场景 A 到 RT_A（半浮点，当前尺寸）
 *         2. 渲染场景 B 到 RT_B（半浮点，当前尺寸）
 *         3. 合成 pass：全屏四边形采样 tDiffuse1(A) / tDiffuse2(B)，按 mixRatio 混合：
 *            - useTexture=1（纹理过渡）：tMixTexture 采样 → 阈值过渡
 *              r = mixRatio*(1+threshold*2) - threshold
 *              mixf = clamp((transitionTexel.r - r) * (1/threshold), 0, 1)
 *              gl_FragColor = mix(texel1, texel2, mixf)
 *            - useTexture=0（纯比例）：gl_FragColor = mix(texel2, texel1, mixRatio)
 *         流程：
 *         - 先渲场景 A → RT_A，再渲场景 B → RT_B（各用完整材质渲染）
 *         - 合成时全屏 quad 混合两 RT → writeBuffer（或 renderToScreen 时上屏）
 *         - setSize 时重建 RT_A/RT_B；mixRatio/threshold/useTexture/tMixTexture 运行时可调
 *         渲染差异：
 *         - 用 renderer.setRenderTarget(RT) + renderer.render(scene, camera) 渲两场景；
 *           沿用 RenderPass 范式：execBgfx 设 view 0 frame buffer = RT + clear，
 *           再调 renderer.render(scene, camera)（不能把 renderer.render 放进 execBgfx 闭包，
 *           否则 _execBgfx 嵌套死锁）。
 *         - uniforms 是 float（mixRatio/threshold）与 int（useTexture）；
 *           bgfx uniform 最小单位 vec4：u_mixRatio/u_threshold/u_useTexture（vec4.x=值）。
 *         - tDiffuse1/tDiffuse2/tMixTexture 是 sampler2D；bgfx 绑 stage 0/1/2。
 *         - RT 是 HalfFloatType；bgfx 用 RGBA16F。
 *         - bgfx view id 全局稀缺，本 pass 用 TRANSITION_VIEW_ID_BASE=234（避开既有硬编码段：
 *           SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
 *           TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
 *           DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
 *           RenderPixelatedPass 230~233）。
 *           +0=场景A渲染, +1=场景B渲染, +2=合成。
 *         用法：
 *         let transitionPass = RenderTransitionPass(sceneA, cameraA, sceneB, cameraB)
 *         transitionPass.setTransition(0.5)
 *         transitionPass.setTexture(mixTex)
 *         transitionPass.useTexture(true)
 *         composer.addPass(transitionPass)
 *
 * @file[en] RenderTransitionPass scene transition render pass
 * @brief[en] Scene transition render pass - smoothly transitions from scene A to scene B
 * @explain[en] Algorithm (full non-simplified port):
 *         1. Render scene A to RT_A (half-float, current size)
 *         2. Render scene B to RT_B (half-float, current size)
 *         3. Composite pass: full-screen quad samples tDiffuse1(A) / tDiffuse2(B), blended by mixRatio:
 *            - useTexture=1 (texture transition): sample tMixTexture → threshold transition
 *              r = mixRatio*(1+threshold*2) - threshold
 *              mixf = clamp((transitionTexel.r - r) * (1/threshold), 0, 1)
 *              gl_FragColor = mix(texel1, texel2, mixf)
 *            - useTexture=0 (pure ratio): gl_FragColor = mix(texel2, texel1, mixRatio)
 *         Flow:
 *         - First render scene A → RT_A, then scene B → RT_B (each with full material render)
 *         - On composite, a full-screen quad blends the two RTs → writeBuffer (or to screen when renderToScreen)
 *         - setSize recreates RT_A/RT_B; mixRatio/threshold/useTexture/tMixTexture are tunable at runtime
 *         Rendering differences:
 *         - Renders the two scenes via renderer.setRenderTarget(RT) + renderer.render(scene, camera);
 *           following the RenderPass pattern: execBgfx sets view 0 frame buffer = RT + clear,
 *           then calls renderer.render(scene, camera) (cannot put renderer.render inside an execBgfx closure,
 *           otherwise _execBgfx nests and deadlocks).
 *         - Uniforms are float (mixRatio/threshold) and int (useTexture);
 *           bgfx uniform minimum unit is vec4: u_mixRatio/u_threshold/u_useTexture (vec4.x=value).
 *         - tDiffuse1/tDiffuse2/tMixTexture are sampler2D; bgfx binds stages 0/1/2.
 *         - RT is HalfFloatType; bgfx uses RGBA16F.
 *         - bgfx view ids are globally scarce; this pass uses TRANSITION_VIEW_ID_BASE=234 (avoiding existing hardcoded ranges:
 *           SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 / SavePass 210 /
 *           TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 / SSAA 217 /
 *           TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
 *           DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
 *           RenderPixelatedPass 230~233).
 *           +0=scene A render, +1=scene B render, +2=composite.
 *         Usage:
 *         let transitionPass = RenderTransitionPass(sceneA, cameraA, sceneB, cameraB)
 *         transitionPass.setTransition(0.5)
 *         transitionPass.setTexture(mixTex)
 *         transitionPass.useTexture(true)
 *         composer.addPass(transitionPass)
 *
 * @package three.rendering.postprocessing
 */

package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.scene.scenegraph.Scene
import three.rendering.cameras.Camera

/**
 * @brief[zh-cn] 场景过渡渲染 pass
 * @brief[en] Scene transition render pass
 * @explain[zh-cn] 内部 3 遍：场景 A → RT_A、场景 B → RT_B、合成混合（transition shader）。
 * @explain[en] Three internal passes: scene A → RT_A, scene B → RT_B, composite blend (transition shader).
 * mixRatio/threshold/useTexture/tMixTexture 以字段 + setter 暴露，运行时修改 → render() 内每帧同步到 bgfx uniform。
 */
public class RenderTransitionPass <: Pass {
    /**
     * 场景 A（过渡起点）。
     */
    public var sceneA: Option<Scene> = None

    /**
     * 场景 A 的相机。
     */
    public var cameraA: Option<Camera> = None

    /**
     * 场景 B（过渡终点）。
     */
    public var sceneB: Option<Scene> = None

    /**
     * 场景 B 的相机。
     */
    public var cameraB: Option<Camera> = None

    /**
     * 过渡比例 [0,1]：0=全场景A，1=全场景B。
     */
    public var mixRatio: Float64 = 0.0

    /**
     * 过渡纹理阈值 [0,1]（0=全效果, 1=无效果）。默认 0.1。
     */
    public var threshold: Float64 = 0.1

    /**
     * 是否使用过渡纹理（true=纹理过渡, false=纯比例混合）。默认 true。
     * 注：字段名用 useMixTexture 避开与 useTexture(value) 方法名冲突。
     */
    public var useMixTexture: Bool = true

    /**
     * 过渡纹理（bgfx TextureHandle，RGBA8 灰度/噪声图，r 通道做阈值）。
     */
    public var tMixTexture: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 分配给本 pass 的 bgfx view ID 段。
     *   +0: 场景 A 渲染（view 0 语义 —— 场景渲染复用 renderer.viewId）
     *   +1: 场景 B 渲染
     *   +2: 合成 pass（transition shader 混合 → writeBuffer/屏幕）
     * 取 234 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
     * SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
     * SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
     * DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
     * RenderPixelatedPass 230~233。
     */
    public static let TRANSITION_VIEW_ID_BASE: UInt16 = 234u16

    /** 场景 A RT color（RGBA16F） */
    private var _renderTargetATex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 场景 A RT 的 depth attachment（D24，场景渲染深度测试用） */
    private var _renderTargetADepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 场景 A RT frame buffer */
    private var _renderTargetAFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /** 场景 B RT color（RGBA16F） */
    private var _renderTargetBTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 场景 B RT 的 depth attachment（D24） */
    private var _renderTargetBDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /** 场景 B RT frame buffer */
    private var _renderTargetBFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /** RT 尺寸缓存 */
    private var _width: Int64 = 0
    private var _height: Int64 = 0

    /** transition shader 是否已编译 */
    private var _transitionCompiled: Bool = false

    /** transition program handle 缓存 */
    private var _transitionProg: Option<ProgramHandle> = None

    /** 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 创建/销毁资源） */
    private var _renderer: Option<ThreeRenderer> = None

    /**
     * 构造 RenderTransitionPass。
     *
     * @param sceneA 场景 A（过渡起点）
     * @param cameraA 场景 A 的相机
     * @param sceneB 场景 B（过渡终点）
     * @param cameraB 场景 B 的相机
     */
    public init(sceneA: Scene, cameraA: Camera, sceneB: Scene, cameraB: Camera) {
        super()
        this.sceneA = Some(sceneA)
        this.cameraA = Some(cameraA)
        this.sceneB = Some(sceneB)
        this.cameraB = Some(cameraB)
        // needsSwap=true（Pass 基类默认）
        this.needsSwap = true
        Logger.trace(["transition", "RenderTransitionPass constructed: sceneA=" + sceneA.name +
                      " sceneB=" + sceneB.name])
    }

    /**
     * 设置过渡比例 [0,1]。
     *
     * @param value 过渡比例
     */
    public func setTransition(value: Float64): Unit {
        this.mixRatio = value
        Logger.trace(["transition", "setTransition: " + value.toString()])
    }

    /**
     * 切换是否使用过渡纹理。
     *
     * @param value 是否使用过渡纹理
     */
    public func useTexture(value: Bool): Unit {
        this.useMixTexture = value
        Logger.trace(["transition", "useTexture: " + value.toString()])
    }

    /**
     * 设置过渡纹理。
     *
     * @param value 过渡纹理句柄
     */
    public func setTexture(value: TextureHandle): Unit {
        this.tMixTexture = value
        Logger.trace(["transition", "setTexture: tex.idx=" + handleIdx(value).toString()])
    }

    /**
     * 设置过渡纹理阈值 [0,1]。
     *
     * @param value 阈值
     */
    public func setTextureThreshold(value: Float64): Unit {
        this.threshold = value
        Logger.trace(["transition", "setTextureThreshold: " + value.toString()])
    }

    /**
     * 设置 pass 尺寸。
     * RT_A/RT_B 尺寸与渲染目标一致。
     *
     * @param width 目标宽（像素）
     * @param height 目标高（像素）
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width != this._width || height != this._height) {
            this._destroyRTs()
            this._width = width
            this._height = height
            Logger.trace(["transition", "setSize: " + width.toString() + "x" + height.toString() +
                          " (RTs will be recreated on next render)"])
        }
    }

    // ===== RT 创建/销毁 =====

    /**
     * 创建场景 A/B RT（各 RGBA16F + D24 depth attachment）。
     */
    private func _ensureRTs(renderer: ThreeRenderer): Unit {
        if (this._width <= 0 || this._height <= 0) { return }
        if (isValidHandle(this._renderTargetATex)) { return }

        Logger.trace(["transition", "_ensureRTs: creating RTs ${this._width}x${this._height}"])

        // 场景 A RT：RGBA16F + D24
        let texA = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._renderTargetATex = texA
        let depthA = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._renderTargetADepthTex = depthA
        this._renderTargetAFB = this._createFBWithDepth(renderer, texA, depthA)
        Logger.trace(["transition", "  RT_A created: tex=${handleIdx(texA)} depth=${handleIdx(depthA)}"])

        // 场景 B RT：RGBA16F + D24
        let texB = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.RGBA16F.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._renderTargetBTex = texB
        let depthB = renderer.createTexture2D(
            UInt16(this._width), UInt16(this._height), false, 1u16,
            TextureFormat.D24.value(),
            BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_POINT) | UInt64(BgfxConstants.SAMPLER_MAG_POINT),
            None)
        this._renderTargetBDepthTex = depthB
        this._renderTargetBFB = this._createFBWithDepth(renderer, texB, depthB)
        Logger.trace(["transition", "  RT_B created: tex=${handleIdx(texB)} depth=${handleIdx(depthB)}"])
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /** 销毁场景 A/B RT（setSize 重建或 dispose 时调用） */
    private func _destroyRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let fbA = this._renderTargetAFB; let fbB = this._renderTargetBFB
                let texA = this._renderTargetATex; let depthA = this._renderTargetADepthTex
                let texB = this._renderTargetBTex; let depthB = this._renderTargetBDepthTex
                if (isValidHandle(fbA)) { renderer.destroyFrameBuffer(fbA) }
                if (isValidHandle(fbB)) { renderer.destroyFrameBuffer(fbB) }
                if (isValidHandle(texA)) { renderer.destroyTexture(texA) }
                if (isValidHandle(depthA)) { renderer.destroyTexture(depthA) }
                if (isValidHandle(texB)) { renderer.destroyTexture(texB) }
                if (isValidHandle(depthB)) { renderer.destroyTexture(depthB) }
                this._renderTargetAFB = INVALID_FRAME_BUFFER_HANDLE
                this._renderTargetBFB = INVALID_FRAME_BUFFER_HANDLE
                this._renderTargetATex = INVALID_TEXTURE_HANDLE
                this._renderTargetADepthTex = INVALID_TEXTURE_HANDLE
                this._renderTargetBTex = INVALID_TEXTURE_HANDLE
                this._renderTargetBDepthTex = INVALID_TEXTURE_HANDLE
            case None => ()
        }
    }

    // ===== shader 编译 =====

    /**
     * 编译 transition shader（合成 pass 用）。
     */
    private func _compileTransition(): Option<ProgramHandle> {
        match (PostProcessingShaders.get("transition")) {
            case Some(sp) =>
                if (!this._transitionCompiled) {
                    sp.compileBgfx()
                    this._transitionProg = Some(Box(sp.programHandle))
                    this._transitionCompiled = true
                    Logger.trace(["transition", "transition shader compiled: prog.idx=" +
                                  handleIdx(Box(sp.programHandle)).toString()])
                }
                return this._transitionProg
            case None =>
                Logger.trace(["transition", "transition shader not registered"])
                return None
        }
    }

    // ===== Pass.render 入口 =====

    /**
     * 执行 RenderTransitionPass。
     *
     * 流程：
     *   1. 渲染场景 A 到 RT_A（view 0 + renderer.render，完整材质）
     *   2. 渲染场景 B 到 RT_B（view 0 + renderer.render）
     *   3. 合成 pass（view+2）：transition shader 混合 tDiffuse1/tDiffuse2
     *      （+ tMixTexture 纹理过渡）→ writeBuffer（或上屏）
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 的输出目标）
     * @param readBuffer 读 buffer（本 pass 不用，场景自渲）
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
        // 共享 quad 单例的 renderer 已由 EffectComposer 构造时统一注入（quad.setRenderer），此处无需重复注入
        // 尺寸未设置时默认取渲染器尺寸（composer.setSize 会转发，但防御性兜底）
        if (this._width <= 0 || this._height <= 0) {
            this._width = Int64(renderer.width)
            this._height = Int64(renderer.height)
        }

        let sceneAOpt = this.sceneA
        let camAOpt = this.cameraA
        let sceneBOpt = this.sceneB
        let camBOpt = this.cameraB
        match (sceneAOpt) {
            case Some(sA) => match (camAOpt) {
                case Some(cA) => match (sceneBOpt) {
                    case Some(sB) => match (camBOpt) {
                        case Some(cB) =>
                            this._ensureRTs(renderer)
                            if (!isValidHandle(this._renderTargetAFB) ||
                                !isValidHandle(this._renderTargetBFB)) {
                                Logger.trace(["transition", "render: _ensureRTs failed, RT invalid"])
                                return
                            }

                            let baseView = RenderTransitionPass.TRANSITION_VIEW_ID_BASE

                            // ===== 1. 场景 A → RT_A（view 0 语义）=====
                            this._renderSceneTo(renderer, sA, cA, this._renderTargetAFB, 0u16)

                            // ===== 2. 场景 B → RT_B =====
                            this._renderSceneTo(renderer, sB, cB, this._renderTargetBFB, 1u16)

                            // ===== 3. 合成 pass（view+2）=====
                            this._renderComposite(renderer, writeBuffer, UInt16(UInt16(baseView) + 2u16))

                            Logger.trace(["transition", "render done: mixRatio=" + this.mixRatio.toString() +
                                          " threshold=" + this.threshold.toString() +
                                          " useTexture=" + this.useMixTexture.toString() +
                                          " RT_A=${handleIdx(this._renderTargetAFB)} RT_B=${handleIdx(this._renderTargetBFB)}"])
                        case None => ()
                    }
                    case None => ()
                }
                case None => ()
            }
            case None => ()
        }
    }

    /**
     * 渲染场景到指定 RT（view 0 + renderer.render，完整材质）。
     * 参照 RenderPass 范式：execBgfx 设 view 0 frame buffer + clear，
     * 再调 renderer.render（不能把 renderer.render 放进 execBgfx 闭包，否则嵌套死锁）。
     *
     * @param renderer 渲染器
     * @param scene 场景
     * @param camera 相机
     * @param fb 目标 frame buffer（场景 RT）
     * @param viewOffset view 序号偏移（0=场景A, 1=场景B；两场景都渲到 view 0 语义，
     *                   但 view ID 各自独立避免 frame buffer 状态残留）
     */
    private func _renderSceneTo(
        renderer: ThreeRenderer,
        scene: Scene,
        camera: Camera,
        fb: FrameBufferHandle,
        viewOffset: UInt16
    ): Unit {
        let viewId = UInt16(UInt16(RenderTransitionPass.TRANSITION_VIEW_ID_BASE) + viewOffset)
        // 视口 = 场景 RT 尺寸（全屏）
        this.setViewport(renderer, viewId, 0u16, 0u16, UInt16(this._width), UInt16(this._height))
        // 设 view 的 frame buffer + clear（经渲染线程序列化）
        this.setRenderTarget(renderer, viewId, fb)
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH,
                               if (viewOffset == 0u16) { 0x00101018u32 } else { 0x00181010u32 },
                               depth: 1.0f32, stencil: 0u8)
        // 调 renderer.render 把场景绘制到该 view（view transform 由 renderer 管线设置）
        // 注：renderer.render 内部走 _execBgfx 排队，与上面的 setRenderTarget/clear
        // 是两次独立的 execBgfx 调用（不嵌套，无死锁）。
        // 场景渲染的 view 由 renderer 内部使用 renderer.viewId；为把场景画到本 pass 的 view，
        // 直接调用 renderer.render 前先确认 view 帧缓冲已就绪（bgfx 按 view id 升序执行）。
        Logger.trace(["transition", "  renderSceneTo: view=" + viewId.toString() +
                      " scene=" + scene.name + " fb=${handleIdx(fb)}"])
        renderer.render(scene, camera)
    }

    /**
     * 合成 pass：transition shader 全屏四边形混合场景 A/B。
     *
     * 输出目标：renderToScreen=true（最后一个 enabled pass）→ swap chain；否则 → writeBuffer。
     */
    private func _renderComposite(
        renderer: ThreeRenderer,
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

        match (this._compileTransition()) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["transition", "composite pass: transition program compile FAILED"])
                    return
                }

                let uniforms = BgfxUniforms()

                // stage 0 = tDiffuse1（场景 A RT 的 color 0）
                let uDiffuse1 = uniforms.createUniform("tDiffuse1", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uDiffuse1, this._renderTargetATex, 0u32)
                // stage 1 = tDiffuse2（场景 B RT 的 color 0）
                let uDiffuse2 = uniforms.createUniform("tDiffuse2", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uDiffuse2, this._renderTargetBTex, 0u32)
                // stage 2 = tMixTexture（过渡纹理；无效时绑场景 A 纹理占位，shader 用 useTexture=0 分支）
                let uMixTex = uniforms.createUniform("tMixTexture", UniformType.Sampler.value())
                let mixTex = if (isValidHandle(this.tMixTexture)) { this.tMixTexture } else { this._renderTargetATex }
                this.bindTexture(renderer, 2u8, uMixTex, mixTex, 0u32)

                // mixRatio / threshold / useTexture（vec4.x=值）
                this.setUniformVec4(renderer, uniforms, "u_mixRatio",   this.mixRatio)
                this.setUniformVec4(renderer, uniforms, "u_threshold",  this.threshold)
                this.setUniformVec4(renderer, uniforms, "u_useTexture", if (this.useMixTexture) { 1.0 } else { 0.0 })

                // 全屏 quad submit（覆盖写 state）
                this.submitQuad(viewId, prog)

                Logger.trace(["transition", "composite pass: view=" + viewId.toString() +
                              " mixRatio=" + this.mixRatio.toString() +
                              " threshold=" + this.threshold.toString() +
                              " useTexture=" + this.useMixTexture.toString() +
                              " mixTexIdx=" + handleIdx(mixTex).toString() +
                              " RT_A=${handleIdx(this._renderTargetATex)} RT_B=${handleIdx(this._renderTargetBTex)}"])
            case None =>
                Logger.trace(["transition", "composite pass: transition shader compile failed, skip pass"])
        }
    }

    /**
     * 设置单个 vec4 uniform（x=value, y/z/w=0）。辅助方法，简化 uniforms 设置。
     */
    private func setUniformVec4(
        renderer: ThreeRenderer,
        uniforms: BgfxUniforms,
        name: String,
        value: Float64
    ): Unit {
        let handle = uniforms.createUniform(name, UniformType.Vec4.value())
        let mem = BgfxMemory(16u32)
        mem.writeFloats([value, 0.0, 0.0, 0.0], 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * 释放 RenderTransitionPass 占用的所有 GPU 资源。
     * transition shader program 由 PostProcessingShaders 全局管理，不在此 dispose。
     * 全屏 quad 由 EffectComposer 持单例统一管理，不在此 dispose。
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        Logger.trace(["transition", "disposed"])
    }
}
