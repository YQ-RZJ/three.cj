/**
 * @file[zh-cn] SSAARenderPass 超采样抗锯齿渲染 pass
 * @brief[zh-cn] 超采样抗锯齿渲染 pass —— 单帧多 jitter 样本累加
 * @explain[zh-cn] 算法（SSAA）：
 *         对 jitterOffsets 数组（= _JitterVectors[sampleLevel]，样本数 2^sampleLevel）每个 jitter：
 *           1. camera.setViewOffset 抖动投影
 *           2. 把 renderer.viewId（主 view）frame buffer 指向 sampleRT，clear
 *           3. renderer.render(scene, camera) → 场景写入 sampleRT
 *           4. fsQuad（copy shader + 加性混合）→ writeBuffer 或屏幕（i==0 时清屏幕）
 *         循环结束 camera.clearViewOffset()
 *         unbiased 模式：sampleWeight 按 uniformCenteredDistribution 微调，
 *         避免累加舍入误差（RGBA8 下最明显）。
 *         渲染差异：
 *         - 用 bgfx FrameBufferHandle(RGBA16F color + D24 depth) +
 *           ShaderLibs.get("copy") + bgfx BLEND_ADD 状态。
 *         - jitter 经 camera.setViewOffset（PerspectiveCamera 已实现）。
 *         - 加性混合 = src*1 + dst*1（BLEND_ADD）。
 *         序列化约束（★关键）：
 *         renderer.render(scene, camera) 内部走 _execBgfx（同步等待渲染线程）。
 *         _execBgfx 不可重入：若在 execBgfx 闭包内调 renderer.render 会自我等待死锁。
 *         故本 pass 的"每 jitter 样本"流程拆为三步顺序执行：
 *           a. renderer.execBgfx({ 设 view 0 frame buffer = sampleRT + clear })   ← 排队 + 等待
 *           b. renderer.render(scene, camera)                                     ← 排队 + 等待
 *           c. renderer.execBgfx({ 设 view 0 frame buffer = writeBuffer/swap + clear + copy 加性累加 submit })
 *         三步各自独立 _execBgfx，不嵌套，不死锁。
 *         用法：
 *         let ssaaPass = SSAARenderPass(scene, camera, quad)
 *         ssaaPass.sampleLevel = 3   // 8 样本
 *         composer.addPass(ssaaPass)
 *
 * @file[en] SSAARenderPass supersampling antialiasing render pass
 * @brief[en] Supersampling antialiasing render pass - accumulates multiple jittered samples in a single frame
 * @explain[en] Algorithm (SSAA):
 *         For each jitter in the jitterOffsets array (= _JitterVectors[sampleLevel], sample count 2^sampleLevel):
 *           1. camera.setViewOffset jitters the projection
 *           2. Point renderer.viewId (main view) frame buffer at sampleRT, clear
 *           3. renderer.render(scene, camera) → scene written to sampleRT
 *           4. fsQuad (copy shader + additive blending) → writeBuffer or screen (cleared when i==0)
 *         After the loop, camera.clearViewOffset()
 *         unbiased mode: sampleWeight is fine-tuned by uniformCenteredDistribution
 *         to avoid accumulation rounding error (most visible under RGBA8).
 *         Rendering differences:
 *         - Uses bgfx FrameBufferHandle (RGBA16F color + D24 depth) +
 *           ShaderLibs.get("copy") + bgfx BLEND_ADD state.
 *         - Jitter via camera.setViewOffset (implemented in PerspectiveCamera).
 *         - Additive blending = src*1 + dst*1 (BLEND_ADD).
 *         Serialization constraint (★critical):
 *         renderer.render(scene, camera) internally goes through _execBgfx (synchronously waits on the render thread).
 *         _execBgfx is not reentrant: calling renderer.render inside an execBgfx closure self-waits and deadlocks.
 *         So this pass's "per-jitter sample" flow is split into three sequential steps:
 *           a. renderer.execBgfx({ set view 0 frame buffer = sampleRT + clear })   ← queued + waits
 *           b. renderer.render(scene, camera)                                     ← queued + waits
 *           c. renderer.execBgfx({ set view 0 frame buffer = writeBuffer/swap + clear + copy additive accumulate submit })
 *         Each of the three steps uses its own independent _execBgfx, no nesting, no deadlock.
 *         Usage:
 *         let ssaaPass = SSAARenderPass(scene, camera, quad)
 *         ssaaPass.sampleLevel = 3   // 8 samples
 *         composer.addPass(ssaaPass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.bgfx.BgfxBackend
import three.rendering.types.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.cameras.*
import three.scene.scenegraph.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import std.collection.*
import std.math.*

/**
 * Jitter 向量表。
 * 索引 = sampleLevel，值为该 sampleLevel 下所有 jitter 偏移量（整数，需 ×0.0625=1/16 映射到 [-0.5,0.5)）。
 */
public let JITTER_VECTORS: Array<Array<Array<Int64>>> = [
    // sampleLevel = 0：1 样本
    [[0, 0]],
    // sampleLevel = 1：2 样本
    [[4, 4], [-4, -4]],
    // sampleLevel = 2：4 样本
    [[-2, -6], [6, -2], [-6, 2], [2, 6]],
    // sampleLevel = 3：8 样本
    [[1, -3], [-1, 3], [5, 1], [-3, -5], [-5, 5], [-7, -1], [3, 7], [7, -7]],
    // sampleLevel = 4：16 样本
    [
        [1, 1], [-1, -3], [-3, 2], [4, -1],
        [-5, -2], [2, 5], [5, 3], [3, -5],
        [-2, 6], [0, -7], [-4, -6], [-6, 4],
        [-8, 0], [7, -4], [6, 7], [-7, -8]
    ],
    // sampleLevel = 5：32 样本
    [
        [-4, -7], [-7, -5], [-3, -5], [-5, -4],
        [-1, -4], [-2, -2], [-6, -1], [-4, 0],
        [-7, 1], [-1, 2], [-6, 3], [-3, 3],
        [-7, 6], [-3, 6], [-5, 7], [-1, 7],
        [5, -7], [1, -6], [6, -5], [4, -4],
        [2, -3], [7, -2], [1, -1], [4, -1],
        [2, 1], [6, 2], [0, 4], [4, 4],
        [2, 5], [7, 5], [5, 6], [3, 7]
    ]
]

/**
 * @brief[zh-cn] 超采样抗锯齿渲染 pass
 * @brief[en] Supersampling antialiasing render pass
 * @explain[zh-cn] 多 jitter 样本累加，sampleRT + copy shader（加性混合）。
 * @explain[en] Accumulates multiple jittered samples; sampleRT + copy shader (additive blending).
 */
public open class SSAARenderPass <: Pass {
    /**
     * 累加 pass 用的 view ID（避开 SSAO 160/Bloom/shadow 50~127/ShaderPass 200~209/
     * SavePass 210/TexturePass 211/OutputPass 212/FXAAPass 213/SMAA 214~216）。
     */
    public static let SSAA_VIEW_ACCUM: UInt16 = 217u16

    /**
     * 待渲染场景。
     */
    public let scene: Scene

    /**
     * 待渲染相机。
     */
    public let camera: Camera

    /**
     * 采样级别。指定为 n，其中样本数为 2^n，故 sampleLevel=4 为 2^4=16 样本。
     * 默认 4。
     */
    public var sampleLevel: Int64 = 4

    /**
     * 是否 unbiased。true 时 sampleWeight 按 uniformCenteredDistribution 微调，
     * 避免累加舍入误差（RGBA8 下最明显）。
     * 默认 true。
     */
    public var unbiased: Bool = true

    /**
     * clear 颜色（UInt32，0xRRGGBB）。
     * 默认透明黑。
     */
    public var clearColor: UInt32 = 0x00000000u32

    /**
     * clear alpha [0,1]。
     * 默认 0。
     */
    public var clearAlpha: Float64 = 0.0

    /**
     * RT 尺寸（TAARenderPass 子类 setSize 守卫用）。
     */
    protected var _width: Int64 = 0
    protected var _height: Int64 = 0

    /**
     * RT 是否已创建（TAARenderPass 子类 setSize 守卫用）。
     */
    protected var _rtsCreated: Bool = false

    // ===== 内部 sampleRT =====
    /** sample RT 的 color 纹理（RGBA16F，HalfFloatType） */
    protected var _sampleTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** sample RT 的 depth attachment（D24，场景深度测试用） */
    protected var _sampleDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    /** sample RT 的 frame buffer（TAARenderPass 复用作跨帧累加池） */
    protected var _sampleFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /**
     * 已编译 copy program handle 缓存。
     */
    protected var _copyProg: Option<ProgramHandle> = None

    /**
     * 渲染器引用（render() 时缓存，setSize/dispose 经其高阶 API 序列化；TAARenderPass 子类复用）。
     */
    protected var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造 SSAARenderPass。
     *
     * @param scene 待渲染场景
     * @param camera 待渲染相机
     * @param clearColor clear 颜色（默认透明黑）
     * @param clearAlpha clear alpha（默认 0）
     *
     * 差异：全屏 quad 由 EffectComposer 持单例并经 setQuad 注入（基类 quad 字段）。
     */
    public init(
        scene: Scene,
        camera: Camera,
        clearColor!: UInt32 = 0x00000000u32,
        clearAlpha!: Float64 = 0.0
    ) {
        super()
        this.scene = scene
        this.camera = camera
        this.clearColor = clearColor
        this.clearAlpha = clearAlpha
        // SSAARenderPass 默认 clear=true（每帧清 writeBuffer 或屏幕）
        this.clear = true
        // SSAARenderPass 默认 needsSwap=true（pass 后 composer 交换 buffer）
        this.needsSwap = true
    }

    /**
     * 设置 pass 尺寸（重建内部 sampleRT）。
     *
     * 调用约定：caller（EffectComposer.setSize/addPass）已把本方法包进 renderer.execBgfx，
     * 故本方法直接调 bgfx API，不再嵌套 renderer.execBgfx（避免死锁）。
     */
    public open override func setSize(width: Int64, height: Int64): Unit {
        if (width == this._width && height == this._height && this._rtsCreated) {
            return
        }
        this._width = width
        this._height = height
        if (width <= 0 || height <= 0) {
            return
        }
        this._destroyRTs()
        this._createRTs()
    }

    /**
     * 创建内部 sampleRT（RGBA16F color + D24 depth）。
     *
     * 调用约定：caller 已在渲染线程，本方法直接调 bgfx API。
     */
    private func _createRTs(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                let w = UInt16(this._width)
                let h = UInt16(this._height)
                let rtFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)

                this._sampleTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.RGBA16F.value(), rtFlags, None)
                this._sampleDepthTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.D24.value(), rtFlags, None)

                let handles = Array<TextureHandle>(2, { i => if (i == 0) { this._sampleTex } else { this._sampleDepthTex } })
                this._sampleFB = renderer.createFrameBuffer(2u8, handles, true)

                this._rtsCreated = true
            case None => ()
        }
        Logger.trace(["SSAARenderPass", "_createRTs done ${this._width}x${this._height} sampleFB.idx=${handleIdx(this._sampleFB)}"])
    }

    /**
     * 销毁内部 sampleRT。
     */
    private func _destroyRTs(): Unit {
        if (!this._rtsCreated) {
            return
        }
        match (this._renderer) {
            case Some(renderer) =>
                if (isValidHandle(this._sampleFB)) {
                    renderer.destroyFrameBuffer(this._sampleFB)
                    this._sampleFB = INVALID_FRAME_BUFFER_HANDLE
                }
                if (isValidHandle(this._sampleTex)) {
                    renderer.destroyTexture(this._sampleTex)
                    this._sampleTex = INVALID_TEXTURE_HANDLE
                }
                if (isValidHandle(this._sampleDepthTex)) {
                    renderer.destroyTexture(this._sampleDepthTex)
                    this._sampleDepthTex = INVALID_TEXTURE_HANDLE
                }
            case None => ()
        }
        this._rtsCreated = false
    }

    /**
     * 执行 SSAA 渲染 pass（单帧多 jitter 样本累加）。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（累加结果输出；renderToScreen=true 时写屏幕）
     * @param readBuffer 读 buffer（SSAA 不用 readBuffer，而是渲染场景到 sampleRT）
     * @param deltaTime 帧间隔
     */
    public open override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 确保内部 sampleRT 已创建（若 setSize 未调，首帧 lazy 创建）
        if (!this._rtsCreated) {
            this.setSize(Int64(renderer.width), Int64(renderer.height))
        }
        if (!this._rtsCreated) { return }

        // 编译 copy shader（仅首次）
        this._ensureCompiled()
        match (this._copyProg) {
            case Some(copyProg) =>
                if (!isValidHandle(copyProg)) { return }
                this._renderSSAA(renderer, writeBuffer, copyProg)
            case None => ()
        }
    }

    /**
     * 实际执行单帧多 jitter 样本累加。
     *
     * 序列化约束（★关键）：renderer.render 内部走 _execBgfx（同步等待）。
     * _execBgfx 不可重入：若在 execBgfx 闭包内调 renderer.render 会自我等待死锁。
     * 故本 pass 的"每 jitter 样本"流程拆为三步顺序执行，三步各自独立 _execBgfx，不嵌套：
     *   a. renderer.execBgfx({ 设 view 0 frame buffer = sampleRT + clear })
     *   b. renderer.render(scene, camera)        ← 走 _execBgfx，排队 + 等待
     *   c. renderer.execBgfx({ 设 view 0 frame buffer = writeBuffer/swap + clear + copy 加性累加 submit })
     */
    private func _renderSSAA(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        copyProg: ProgramHandle
    ): Unit {
        let rw = renderer.width
        let rh = renderer.height
        let rt = this.renderToScreen
        let viewId = renderer.viewId
        // clearColor 是 0xRRGGBB（6 位 hex），alpha [0,1] → 最低字节
        let alphaByte = UInt32(Int32(this.clearAlpha * 255.0)) & 0xFFu32
        let colWithAlpha = ((this.clearColor & 0x00FFFFFFu32) << 8) | alphaByte
        let clearFlags: UInt16 = BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH  // CLEAR_COLOR | CLEAR_DEPTH

        // 取 jitterOffsets（按 sampleLevel，clamp 到 [0, 5]）
        let clampedSampleLevel = max(0, min(this.sampleLevel, 5))
        let jitterOffsets = JITTER_VECTORS[clampedSampleLevel]
        let jitterCount = jitterOffsets.size

        // 累加 pass 用的 view rect（与主 view 同尺寸）
        let accumView = SSAARenderPass.SSAA_VIEW_ACCUM
        // copy shader 的 u_opacity.x = sampleWeight（加性混合权重）
        // 基础权重 = 1 / jitterCount
        let baseSampleWeight = 1.0 / Float64(jitterCount)
        // roundingRange = 1/32
        let roundingRange = 1.0 / 32.0

        // 循环累加（每 jitter 样本）
        var i: Int64 = 0
        while (i < jitterCount) {
            let jitterOffset = jitterOffsets[i]

            // ===== a. 设 view 0 frame buffer = sampleRT + clear =====
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setRenderTarget(renderer, viewId, this._sampleFB)
            this.clearRenderTarget(renderer, viewId, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)

            // ===== b. camera.setViewOffset 抖动 + renderer.render(scene, camera) =====
            match (this.camera) {
                case p: PerspectiveCamera =>
                    p.setViewOffset(
                        Float64(rw), Float64(rh),
                        Float64(jitterOffset[0]) * 0.0625,
                        Float64(jitterOffset[1]) * 0.0625,
                        Float64(rw), Float64(rh)
                    )
                case _ => ()
            }
            renderer.render(this.scene, this.camera)

            // ===== c. copy shader 加性累加 → writeBuffer（离屏，不写屏幕）=====
            // sampleWeight（unbiased 微调）
            var sampleWeight = baseSampleWeight
            if (this.unbiased) {
                let uniformCenteredDistribution = -0.5 + (Float64(i) + 0.5) / Float64(jitterCount)
                sampleWeight = sampleWeight + roundingRange * uniformCenteredDistribution
            }
            // i==0 时清 writeBuffer；i>0 时不清（保留累加结果）
            // 关键：累加目标始终是离屏 writeBuffer（而非屏幕 swap chain）。
            //   renderer.render 内部 finishRender 每次都会 bgfx_frame（双缓冲交换）；
            //   若逐样本写屏幕，back buffer 在样本间被交换，i>0 不清除导致
            //   跨帧累加到残留 buffer → 画面越亮直到纯色。
            let firstSample = (i == 0)
            let sw = Float32(sampleWeight)

            // 设累加 view 的 rect + frame buffer（离屏 writeBuffer）
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setViewport(renderer, accumView, 0u16, 0u16, UInt16(rw), UInt16(rh))
            this.setRenderTarget(renderer, accumView, writeBuffer)
            // i==0 时清，i>0 时不清（累加保留）
            if (firstSample) {
                this.clearRenderTarget(renderer, accumView, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)
            } else {
                this.clearRenderTarget(renderer, accumView, 0x0000u16, 0x00000000u32, depth: 1.0f32, stencil: 0u8)
            }

            // 绑 sampleRT color 0 到 tDiffuse sampler
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let sampleTex = this.getTexture(renderer, this._sampleFB, 0u8)
            this.bindTexture(renderer, 0u8, uTex, sampleTex, 0u32)

            // u_opacity.x = sampleWeight
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([Float64(sw), 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            // 加性混合：BGFX_STATE_BLEND_FUNC(ONE, ONE) = src*1 + dst*1
            let blendState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                BgfxBackend.makeBlendFunc(BgfxConstants.BLEND_ONE, BgfxConstants.BLEND_ONE)

            // submit 全屏 quad（★必须用 submitWithState：submit() 内部会覆盖 state 为覆盖写）
            this.submitQuadWithState(accumView, copyProg, blendState)
            // 注意：此处不调 bgfx_frame —— 上屏由循环结束后的步骤 e 统一处理

            i++
        }

        // ===== d. camera.clearViewOffset（恢复） =====
        match (this.camera) {
            case p: PerspectiveCamera => p.clearViewOffset()
            case _ => ()
        }

        // ===== e. renderToScreen=true 时：把累加结果一次性拷到屏幕 + 触发一次 bgfx_frame =====
        // 关键：所有样本累加完成后才上屏，且只调一次 bgfx_frame，
        //   避免逐样本写屏幕 + bgfx_frame 双缓冲交换导致画面越亮。
        if (rt) {
            let outputView = SSAARenderPass.SSAA_VIEW_ACCUM  // 复用累加 view
            // 高阶方法各自走 execBgfx，不能嵌套；顺序调用即可。
            this.setViewport(renderer, outputView, 0u16, 0u16, UInt16(rw), UInt16(rh))
            // 写屏幕（swap chain = 无效 FB handle）
            this.setRenderTarget(renderer, outputView, INVALID_FRAME_BUFFER_HANDLE)
            this.clearRenderTarget(renderer, outputView, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)

            // 绑 writeBuffer color 0 到 tDiffuse sampler
            let uniforms = BgfxUniforms()
            let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
            let writeTex = this.getTexture(renderer, writeBuffer, 0u8)
            this.bindTexture(renderer, 0u8, uTex, writeTex, 0u32)

            // u_opacity.x = 1.0（覆盖写，非加性）
            let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
            let opacityMem = BgfxMemory(16u32)
            opacityMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
            this.setUniform(renderer, uOpacity, opacityMem, num: 1u16)

            // 普通覆盖写状态
            let state = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW
            this.submitQuadWithState(outputView, copyProg, state)
            // 不在此调 bgfx_frame：frame 统一由 EffectComposer.render 末尾触发
            // （bgfx_frame 是双缓冲交换，每帧仅一次；pass 只负责 submit）
        }
    }

    /**
     * 释放 SSAARenderPass 占用的所有 GPU 资源（sampleRT + copy shader）。
     */
    public open override func dispose(): Unit {
        this._destroyRTs()
        this._copyProg = None
    }

    // ===== 内部辅助 =====

    /**
     * 编译 copy shader（仅首次）。
     */
    private func _ensureCompiled(): Unit {
        if (this._copyProg.isSome()) {
            return
        }
        // 后处理 shader 已迁移到 postprocessing 内部注册表 PostProcessingShaders
        match (PostProcessingShaders.get("copy")) {
            case Some(sp) =>
                sp.compileBgfx()
                this._copyProg = Some(Box(sp.programHandle))
            case None => Logger.warn(["SSAARenderPass", "shader copy not found"])
        }
    }
}
