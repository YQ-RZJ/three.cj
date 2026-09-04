/**
 * @file[zh-cn] BgfxPass 后处理 pass 抽象基类
 * @brief[zh-cn] 后处理 pass 抽象基类
 * @explain[zh-cn] 所有后处理 pass（RenderPass/BloomPass/...）的基类。
 *         - enabled: 是否参与 composer 渲染链
 *         - needsSwap: pass 渲染后是否交换 read/write buffer
 *         - clear: pass 渲染前是否清 buffer
 *         - renderToScreen: 是否把结果渲染到屏幕（由 composer 自动给最后一个 enabled pass 设 true）
 *         子类必须 override render(renderer, writeBuffer, readBuffer, deltaTime)。
 *
 * @file[en] BgfxPass post-processing pass abstract base class
 * @brief[en] Post-processing pass abstract base class
 * @explain[en] Base class for all post-processing passes (RenderPass/BloomPass/...).
 *         - enabled: whether the pass participates in the composer render chain
 *         - needsSwap: whether to swap the read/write buffers after rendering
 *         - clear: whether to clear the buffer before rendering
 *         - renderToScreen: whether to render the result to the screen (set to true by the composer
 *           automatically for the last enabled pass)
 *         Subclasses must override render(renderer, writeBuffer, readBuffer, deltaTime).
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.types.*
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 后处理 pass 抽象基类
 * @brief[en] Post-processing pass abstract base class
 * @explain[zh-cn] render() 为抽象方法，子类必须实现。
 *         bgfx 差异：共享 quad 由 EffectComposer 持单例，经 setQuad 注入，避免每 pass 一份 quad；
 *         bgfx view id 是全局稀缺资源，由 EffectComposer.allocViewId() 统一分配，pass 经 onAttach 钩子申请。
 * @explain[en] render() is abstract and must be implemented by subclasses.
 *         bgfx differences: the shared quad is held as a singleton by EffectComposer and injected via setQuad,
 *         avoiding one quad per pass; bgfx view ids are a scarce global resource, allocated uniformly by
 *         EffectComposer.allocViewId(), with passes requesting one via the onAttach hook.
 */
public open class Pass {
    /**
     * @brief[zh-cn] 类型标志，用于运行期判断是否为 Pass
     * @brief[en] Type flag used to identify a Pass at runtime
     */
    public let isPass: Bool = true

    /**
     * @brief[zh-cn] 若为 false，composer 跳过本 pass，默认 true
     * @brief[en] If false, the composer skips this pass; default true
     */
    public var enabled: Bool = true

    /**
     * @brief[zh-cn] 若为 true，pass 渲染后 composer 交换 read/write buffer，默认 true
     * @brief[en] If true, the composer swaps the read/write buffers after rendering; default true
     */
    public var needsSwap: Bool = true

    /**
     * @brief[zh-cn] 若为 true，pass 渲染前清 buffer，默认 false
     * @brief[en] If true, clears the buffer before rendering; default false
     */
    public var clear: Bool = false

    /**
     * @brief[zh-cn] 若为 true，pass 结果直接渲染到屏幕，默认 false
     * @brief[en] If true, the pass result renders directly to the screen; default false
     * @explain[zh-cn] 由 composer 自动赋值给最后一个 enabled pass，用户通常无需设置。
     * @explain[en] Assigned automatically by the composer to the last enabled pass; users usually do not set it.
     */
    public var renderToScreen: Bool = false

    /**
     * @brief[zh-cn] 共享全屏 quad（由 EffectComposer 持单例，addPass 时经 setQuad 注入）
     * @brief[en] Shared full-screen quad (held as a singleton by EffectComposer, injected via setQuad on addPass)
     * @explain[zh-cn] Option：pass 未挂到 composer 前为 None，submitQuad 时须 match。
     * @explain[en] Option: None before the pass is attached to a composer; must be matched in submitQuad.
     */
    public var quad: Option<FullScreenQuad> = None

    public init() {}

    /**
     * @brief[zh-cn] 注入共享全屏 quad
     * @brief[en] Injects the shared full-screen quad
     * @param[zh-cn] quad composer 持有的共享全屏 quad
     * @param[en] quad The shared full-screen quad held by the composer
     * @explain[zh-cn] EffectComposer.addPass 自动调用。
     * @explain[en] Called automatically by EffectComposer.addPass.
     */
    public func setQuad(quad: FullScreenQuad): Unit {
        this.quad = Some(quad)
    }

    /**
     * @brief[zh-cn] 挂载到 composer 时的钩子
     * @brief[en] Hook called when attached to a composer
     * @param[zh-cn] composer 挂载的 EffectComposer
     * @param[en] composer The EffectComposer being attached to
     * @explain[zh-cn] 需要 bgfx view id 的 pass 在此向 composer.allocViewId() 申请。基类默认 no-op，子类按需 override。
     * @explain[en] Passes needing a bgfx view id request one from composer.allocViewId() here. Base class defaults to no-op; subclasses override as needed.
     */
    public open func onAttach(composer: EffectComposer): Unit {}

    /**
     * @brief[zh-cn] 用共享 quad 提交全屏四边形（默认覆盖写 state）
     * @brief[en] Submits the full-screen quad with the shared quad (default overwrite state)
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译 program handle
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @explain[zh-cn] 统一入口：quad 未注入（None）时静默跳过，避免各 pass 重复 match。
     * @explain[en] Unified entry: silently skips when the quad is not injected (None), avoiding repeated match in each pass.
     */
    protected func submitQuad(viewId: UInt16, prog: ProgramHandle): Unit {
        match (this.quad) {
            case Some(q) => q.submit(viewId, prog)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 用共享 quad 提交全屏四边形，使用自定义 render state（如加性混合）
     * @brief[en] Submits the full-screen quad with a custom render state (e.g. additive blending)
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译 program handle
     * @param[zh-cn] state 完整 render state（bgfx_set_state_cj 第 1 参）
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @param[en] state The full render state (first argument of bgfx_set_state_cj)
     * @explain[zh-cn] 统一入口：quad 未注入（None）时静默跳过。
     * @explain[en] Unified entry: silently skips when the quad is not injected (None).
     */
    protected func submitQuadWithState(viewId: UInt16, prog: ProgramHandle, state: UInt64): Unit {
        match (this.quad) {
            case Some(q) => q.submitWithState(viewId, prog, state)
            case None => ()
        }
    }

    // ========================================================================
    // ===== Pass 高阶渲染 API =====
    // ========================================================================
    //
    // 设计动机：子类（ClearPass/ShaderPass/BloomPass/...）原本直接调底层 bgfx API
    // （bgfx_set_view_frame_buffer_cj / bgfx_set_texture_cj / bgfx_set_uniform_cj /
    //   bgfx_set_view_clear_cj / bgfx_set_view_rect_cj / bgfx_touch_cj ...），
    // 违反分层设计——pass 应只使用高阶 API（setRenderTarget / clear / quad submit），
    // 不接触底层渲染 API。
    //
    // 本组方法把 bgfx 底层调用封装到 Pass 基类，子类调用本组方法即可，
    // 无须 import bgfx4cj.bgfx.* 也无须直接调 bgfx_*_cj 函数。
    //
    // 命名对齐既有后处理分层设计：
    //   - setRenderTarget                        ← 设置某 view 的渲染目标
    //   - clearRenderTarget                      ← 清 view（颜色 + 深度 + 模板）
    //   - setViewport                            ← 设置视口
    //   - bindTexture / getTexture               ← 绑纹理 / 取 attachment 纹理句柄
    //   - setUniform / setUniformFloats          ← 设置 uniform
    //   - submitQuad / submitQuadWithState       ← 全屏 quad 提交
    //   - touchView                              ← empty submit（推进 clear / view 序号）
    //
    // 线程模型约束（★关键，供 pass 实现者遵守）：
    //   - 这些高阶 API 自身走 renderer.execBgfx（同步等待渲染线程）。
    //   - renderer.execBgfx 不可重入：调用本组方法期间不能再调 renderer.render（其内部
    //     也走 execBgfx），否则自我等待死锁。
    //   - 若 pass 流程需要"set view → renderer.render → copy 加性"这种交错，
    //     应拆为多次顺序独立调用，每次调用各走 execBgfx 但不嵌套。
    // ========================================================================

    /**
     * @brief[zh-cn] 设置某 view 的渲染目标 frame buffer
     * @brief[en] Sets the render target frame buffer for a view
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id（pass 持有，由 EffectComposer.allocViewId 分配）
     * @param[zh-cn] fb 目标 frame buffer；传无效 handle（idx=65535）表示写 swap chain（屏幕）
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id (held by the pass, allocated via EffectComposer.allocViewId)
     * @param[en] fb Target frame buffer; pass an invalid handle (idx=65535) to write to the swap chain (screen)
     */
    protected func setRenderTarget(renderer: BgfxRenderer, viewId: UInt16, fb: FrameBufferHandle): Unit {
        renderer.setViewFrameBuffer(viewId, fb)
    }

    /**
     * @brief[zh-cn] 设置某 view 的视口矩形（像素）
     * @brief[en] Sets the viewport rectangle (pixels) for a view
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] x 视口左上角 x（像素）
     * @param[zh-cn] y 视口左上角 y（像素）
     * @param[zh-cn] w 视口宽（像素）
     * @param[zh-cn] h 视口高（像素）
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     * @param[en] x Viewport top-left x (pixels)
     * @param[en] y Viewport top-left y (pixels)
     * @param[en] w Viewport width (pixels)
     * @param[en] h Viewport height (pixels)
     */
    protected func setViewport(
        renderer: BgfxRenderer,
        viewId: UInt16,
        x: UInt16,
        y: UInt16,
        w: UInt16,
        h: UInt16
    ): Unit {
        renderer.setViewRect(viewId, x, y, w, h)
    }

    /**
     * @brief[zh-cn] 设置某 view 的 clear（颜色 + 深度 + 模板）
     * @brief[en] Sets the clear for a view (color + depth + stencil)
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] flags clear 标志位（CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004）
     * @param[zh-cn] color clear 颜色（UInt32）
     * @param[zh-cn] depth clear 深度（0.0~1.0，默认 1.0）
     * @param[zh-cn] stencil clear 模板值（默认 0）
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     * @param[en] flags Clear flags (CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004)
     * @param[en] color Clear color (UInt32)
     * @param[en] depth Clear depth (0.0~1.0, default 1.0)
     * @param[en] stencil Clear stencil value (default 0)
     * @explain[zh-cn] 本方法命名为 clearRenderTarget 而非 clear，避免与 Pass.clear 字段（bool）冲突。
     * @explain[en] Named clearRenderTarget instead of clear to avoid conflicting with the Pass.clear field (bool).
     */
    protected func clearRenderTarget(
        renderer: BgfxRenderer,
        viewId: UInt16,
        flags: UInt16,
        color: UInt32,
        depth!: Float32 = 1.0f32,
        stencil!: UInt8 = 0u8
    ): Unit {
        renderer.setViewClear(viewId, flags, color, depth: depth, stencil: stencil)
    }

    /**
     * @brief[zh-cn] 绑定纹理到指定 stage 的 sampler
     * @brief[en] Binds a texture to the sampler of the given stage
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] stage 纹理 stage（0..MAX_TEXTURE_SAMPLERS-1）
     * @param[zh-cn] sampler sampler uniform 句柄
     * @param[zh-cn] tex 待绑纹理句柄
     * @param[zh-cn] flags 采样器 flags（如 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP，0 表示用纹理默认）
     * @param[en] renderer Renderer
     * @param[en] stage Texture stage (0..MAX_TEXTURE_SAMPLERS-1)
     * @param[en] sampler The sampler uniform handle
     * @param[en] tex The texture handle to bind
     * @param[en] flags Sampler flags (e.g. SAMPLER_U_CLAMP|SAMPLER_V_CLAMP; 0 uses the texture default)
     */
    protected func bindTexture(
        renderer: BgfxRenderer,
        stage: UInt8,
        sampler: UniformHandle,
        tex: TextureHandle,
        flags: UInt32
    ): Unit {
        renderer.bindTexture(stage, sampler, tex, flags)
    }

    /**
     * @brief[zh-cn] 取 frame buffer 指定 attachment 的纹理句柄
     * @brief[en] Fetches the texture handle of a frame buffer attachment
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] fb 源 frame buffer
     * @param[zh-cn] attachment attachment 索引（0=主 color，1=depth 等）
     * @param[en] renderer Renderer
     * @param[en] fb Source frame buffer
     * @param[en] attachment Attachment index (0=main color, 1=depth, etc.)
     * @return[zh-cn] attachment 对应的 TextureHandle
     * @return[en] The TextureHandle for the attachment
     */
    protected func getTexture(
        renderer: BgfxRenderer,
        fb: FrameBufferHandle,
        attachment: UInt8
    ): TextureHandle {
        return renderer.getTexture(fb, attachment)
    }

    /**
     * @brief[zh-cn] 设置 uniform 数据
     * @brief[en] Sets uniform data
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] data uniform 数据指针（float32 数组）
     * @param[zh-cn] num 数组长度（默认 1）
     * @param[en] renderer Renderer
     * @param[en] handle The uniform handle
     * @param[en] data Uniform data pointer (float32 array)
     * @param[en] num Array length (default 1)
     * @explain[zh-cn] bgfx uniform 最小单位是 vec4，数组 uniform 用 num 指定数组长度。
     * @explain[en] bgfx uniforms have a minimum unit of vec4; array uniforms use num for the array length.
     */
    protected func setUniform(
        renderer: BgfxRenderer,
        handle: UniformHandle,
        data: BgfxMemory,
        num!: UInt16 = 1u16
    ): Unit {
        renderer.setUniform(handle, data, num: num)
    }

    /**
     * @brief[zh-cn] 设置 uniform 数据（安全重载，无需外部管理指针）
     * @brief[en] Sets uniform data (safe overload, no external pointer management)
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] values uniform 数据（Float64 数组，bgfx 按 float32 写入）
     * @param[zh-cn] num 数组长度（默认 1）
     * @param[en] renderer Renderer
     * @param[en] handle The uniform handle
     * @param[en] values Uniform data (Float64 array, written as float32 by bgfx)
     * @param[en] num Array length (default 1)
     * @explain[zh-cn] 内部用 BgfxMemory 包装 Float64 数组并转为 bgfx uniform 指针，
     *         外部只传数值数组，无须 `unsafe { CPointer<Unit>(...) }`。
     * @explain[en] Internally wraps the Float64 array in BgfxMemory and converts it to a bgfx uniform pointer;
     *         callers only pass the numeric array, no `unsafe { CPointer<Unit>(...) }` needed.
     */
    protected func setUniformFloats(
        renderer: BgfxRenderer,
        handle: UniformHandle,
        values: Array<Float64>,
        num!: UInt16 = 1u16
    ): Unit {
        let mem = BgfxMemory(UInt32(values.size * 4))
        mem.writeFloats(values, Int64(values.size))
        renderer.setUniform(handle, mem, num: num)
    }

    /**
     * @brief[zh-cn] 设置模板状态（per-draw 瞬态）
     * @brief[en] Sets stencil state (per-draw transient)
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] fstencil 前面 stencil 位域（FUNC_REF/OP_FAIL/OP_ZFAIL/OP_PASS/RWMASK 编码）
     * @param[zh-cn] bstencil 后面 stencil 位域（同上）
     * @param[en] renderer Renderer
     * @param[en] fstencil Front stencil bitfield (FUNC_REF/OP_FAIL/OP_ZFAIL/OP_PASS/RWMASK encoding)
     * @param[en] bstencil Back stencil bitfield (same encoding)
     * @explain[zh-cn] bgfx 的 stencil 是 per-draw 瞬态状态，每次 submit 前需重设。
     * @explain[en] bgfx stencil is per-draw transient state and must be reset before each submit.
     */
    protected func setStencil(renderer: BgfxRenderer, fstencil: UInt32, bstencil: UInt32): Unit {
        renderer.setStencil(fstencil, bstencil)
    }

    /**
     * @brief[zh-cn] 触发某 view 的 empty submit（仅推进 clear / view 序号，不绘制）
     * @brief[en] Triggers an empty submit for a view (only advances clear / view sequence, draws nothing)
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     */
    protected func touchView(renderer: BgfxRenderer, viewId: UInt16): Unit {
        renderer.touchView(viewId)
    }

    /**
     * @brief[zh-cn] 设置 pass 内部 RT 尺寸
     * @brief[en] Sets the pass's internal RT size
     * @explain[zh-cn] 基类默认 no-op，子类按需 override。
     * @explain[en] Base class defaults to no-op; subclasses override as needed.
     */
    public open func setSize(width: Int64, height: Int64): Unit {}

    /**
     * @brief[zh-cn] 执行 pass 渲染逻辑
     * @brief[en] Executes the pass render logic
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写入 buffer（FrameBufferHandle）
     * @param[zh-cn] readBuffer 读取 buffer（上一 pass 结果）
     * @param[zh-cn] deltaTime 帧间隔（秒）
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (FrameBufferHandle)
     * @param[en] readBuffer Read buffer (previous pass result)
     * @param[en] deltaTime Frame delta time (seconds)
     * @explain[zh-cn] 基类默认 no-op，子类必须 override。
     * @explain[en] Base class defaults to no-op; subclasses must override.
     */
    public open func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {}

    /**
     * @brief[zh-cn] 释放 pass 占用的 GPU 资源
     * @brief[en] Releases the GPU resources held by the pass
     * @explain[zh-cn] 基类默认 no-op。
     * @explain[en] Base class defaults to no-op.
     */
    public open func dispose(): Unit {}
}
