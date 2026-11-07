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

import three.utils.safe.IReleasable
import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.types.*
import three.utils.memory.BgfxMemory
import std.collection.*

/**
 * @brief[zh-cn] 后处理 pass 抽象基类
 * @explain[zh-cn] render() 为抽象方法，子类必须实现。
 *         bgfx 差异：共享 quad 由 EffectComposer 持单例，经 setQuad 注入，避免每 pass 一份 quad；
 *         bgfx view id 是全局稀缺资源，由 EffectComposer.allocViewId() 统一分配，pass 经 onAttach 钩子申请。
 *
 * @brief[en] Post-processing pass abstract base class
 * @explain[en] render() is abstract and must be implemented by subclasses.
 *         bgfx differences: the shared quad is held as a singleton by EffectComposer and injected via setQuad,
 *         avoiding one quad per pass; bgfx view ids are a scarce global resource, allocated uniformly by
 *         EffectComposer.allocViewId(), with passes requesting one via the onAttach hook.
 */
public open class Pass <: IReleasable {
    /**
     * @brief[zh-cn] 类型标志，用于运行期判断是否为 Pass
     *
     * @brief[en] Type flag used to identify a Pass at runtime
     */
    public let isPass: Bool = true

    /**
     * @brief[zh-cn] 若为 false，composer 跳过本 pass，默认 true
     *
     * @brief[en] If false, the composer skips this pass; default true
     */
    public var enabled: Bool = true

    /**
     * @brief[zh-cn] 若为 true，pass 渲染后 composer 交换 read/write buffer，默认 true
     *
     * @brief[en] If true, the composer swaps the read/write buffers after rendering; default true
     */
    public var needsSwap: Bool = true

    /**
     * @brief[zh-cn] 若为 true，pass 渲染前清 buffer，默认 false
     *
     * @brief[en] If true, clears the buffer before rendering; default false
     */
    public var clear: Bool = false

    /**
     * @brief[zh-cn] 若为 true，pass 结果直接渲染到屏幕，默认 false
     * @explain[zh-cn] 由 composer 自动赋值给最后一个 enabled pass，用户通常无需设置。
     *
     * @brief[en] If true, the pass result renders directly to the screen; default false
     * @explain[en] Assigned automatically by the composer to the last enabled pass; users usually do not set it.
     */
    public var renderToScreen: Bool = false

    /**
     * @brief[zh-cn] 共享全屏 quad（由 EffectComposer 持单例，addPass 时经 setQuad 注入）
     * @explain[zh-cn] Option：pass 未挂到 composer 前为 None，submitQuad 时须 match。
     *
     * @brief[en] Shared full-screen quad (held as a singleton by EffectComposer, injected via setQuad on addPass)
     * @explain[en] Option: None before the pass is attached to a composer; must be matched in submitQuad.
     */
    public var quad: Option<FullScreenQuad> = None

    // ===== pass 内上传缓冲（按槽位复用）=====
    // 后处理 pass 的 render() 每帧都要上传少量 uniform / 矩阵，原实现逐帧新建
    // BgfxMemory（走 bgfx_alloc；该内存只作 set_uniform 的数据源，调用时即 memcpy
    // 进引擎内部 uniform buffer，且不会归还 → 逐帧新建等于持续泄漏原生内存）。
    //
    // 按槽位（而非共用一块）的原因：同一个 render() 内常有多个 uniform 是
    // "先写好、再依次 set_uniform 提交"，共用一块会让后写的覆盖先写而尚未提交
    // 的数据 → uniform 串值。故每个 uniform 独占一个槽位，槽内缓冲跨帧复用。
    // 复用安全性：bgfx_set_uniform / bgfx_set_view_transform / bgfx_set_transform
    // 均在调用时立即 memcpy 取走数据。
    private var _uploadMems: ArrayList<Option<BgfxMemory>> = ArrayList<Option<BgfxMemory>>()
    private var _uploadMemSizes: ArrayList<UInt32> = ArrayList<UInt32>()
    /** 标量 vec4 暂存（4 元素），避免每帧为单个 uniform 新建数组字面量。 */
    private let _uploadScratch4: Array<Float64> = Array<Float64>(4, { _ => 0.0 })

    /**
     * @brief[zh-cn] 取槽位 slot 对应的复用上传缓冲（容量不足时才重新分配）
     * @param[zh-cn] slot 槽位编号（每个 uniform 一个固定槽位）
     * @param[zh-cn] need 所需容量（字节）
     * @return[zh-cn] 复用缓冲
     *
     * @brief[en] Returns the reusable upload buffer bound to `slot` (reallocates only when it must grow)
     * @param[en] slot Slot index (one fixed slot per uniform)
     * @param[en] need Required capacity in bytes
     * @return[en] The reusable buffer
     */
    protected func _uploadMem(slot: Int64, need: UInt32): BgfxMemory {
        while (this._uploadMems.size <= slot) {
            this._uploadMems.add(None)
            this._uploadMemSizes.add(0u32)
        }
        if (let Some(m) <- this._uploadMems[Int64(slot)]) {
            if (this._uploadMemSizes[Int64(slot)] >= need) { return m }
        }
        let m = BgfxMemory(need)
        this._uploadMems[Int64(slot)] = Some(m)
        this._uploadMemSizes[Int64(slot)] = need
        return m
    }

    /**
     * @brief[zh-cn] 把单个标量写入槽位 slot 的 vec4 缓冲并提交（x=value, y/z/w=0）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] slot 槽位编号
     * @param[zh-cn] value 标量值（写入 x 分量）
     *
     * @brief[en] Writes a single scalar into the vec4 buffer of slot `slot` and submits it
     * @param[en] renderer Renderer
     * @param[en] handle Uniform handle
     * @param[en] slot Slot index
     * @param[en] value Scalar value (written to the x component)
     */
    protected func _setScalarUniform(renderer: ThreeRenderer, handle: UniformHandle, slot: Int64, value: Float64): Unit {
        let scratch = this._uploadScratch4
        scratch[0] = value
        scratch[1] = 0.0
        scratch[2] = 0.0
        scratch[3] = 0.0
        let mem = this._uploadMem(slot, 16u32)
        mem.writeFloats(scratch, 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * @brief[zh-cn] 把两个标量写入槽位 slot 的 vec4 缓冲并提交（x=x, y=y, z/w=0）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] slot 槽位编号
     * @param[zh-cn] x 写入 x 分量的值
     * @param[zh-cn] y 写入 y 分量的值
     *
     * @brief[en] Writes two scalars into the vec4 buffer of slot `slot` and submits it
     * @param[en] renderer Renderer
     * @param[en] handle Uniform handle
     * @param[en] slot Slot index
     * @param[en] x Value written to the x component
     * @param[en] y Value written to the y component
     */
    protected func _setVec2Uniform(renderer: ThreeRenderer, handle: UniformHandle, slot: Int64, x: Float64, y: Float64): Unit {
        let scratch = this._uploadScratch4
        scratch[0] = x
        scratch[1] = y
        scratch[2] = 0.0
        scratch[3] = 0.0
        let mem = this._uploadMem(slot, 16u32)
        mem.writeFloats(scratch, 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * @brief[zh-cn] 把四个标量写入槽位 slot 的 vec4 缓冲并提交（x/y/z/w 全写）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] slot 槽位编号
     * @param[zh-cn] x 写入 x 分量的值
     * @param[zh-cn] y 写入 y 分量的值
     * @param[zh-cn] z 写入 z 分量的值
     * @param[zh-cn] w 写入 w 分量的值
     *
     * @brief[en] Writes four scalars into the vec4 buffer of slot `slot` and submits it
     * @param[en] renderer Renderer
     * @param[en] handle Uniform handle
     * @param[en] slot Slot index
     * @param[en] x Value written to the x component
     * @param[en] y Value written to the y component
     * @param[en] z Value written to the z component
     * @param[en] w Value written to the w component
     */
    protected func _setVec4Uniform(renderer: ThreeRenderer, handle: UniformHandle, slot: Int64,
                                   x: Float64, y: Float64, z: Float64, w: Float64): Unit {
        let scratch = this._uploadScratch4
        scratch[0] = x
        scratch[1] = y
        scratch[2] = z
        scratch[3] = w
        let mem = this._uploadMem(slot, 16u32)
        mem.writeFloats(scratch, 4)
        this.setUniform(renderer, handle, mem, num: 1u16)
    }

    /**
     * @brief[zh-cn] GC 回收兜底释放回调（终结器专用）
     * @explain[zh-cn] 仓颉终结器内不能调用实例方法，故把释放动作包成函数值字段，
     *                 由子类终结器读取并执行（终结器调用函数值是允许的，见 utils.memory 先例）。
     *                 dispose() 已幂等，用户主动调用后终结器再执行也安全。
     *                 终结器只允许定义在非 open 类上，本基类为 open 不可直接定义终结器。
     *
     * @brief[en] GC-collection fallback release callback (for finalizers only)
     * @explain[en] Instance methods cannot be called inside a Cangjie finalizer, so the release
     *               action is wrapped as a function-valued field executed by the subclass finalizer
     *               (calling a function value from a finalizer is allowed, cf. utils.memory).
     *               dispose() is idempotent, so re-execution after an explicit call is safe.
     *               Finalizers are only allowed on non-open classes; this open base class cannot
     *               define one directly.
     */
    protected var _finalizerFallback: Option<() -> Unit> = None

    public init() {}

    /**
     * @brief[zh-cn] 注入共享全屏 quad
     * @param[zh-cn] quad composer 持有的共享全屏 quad
     * @explain[zh-cn] EffectComposer.addPass 自动调用。
     *
     * @brief[en] Injects the shared full-screen quad
     * @param[en] quad The shared full-screen quad held by the composer
     * @explain[en] Called automatically by EffectComposer.addPass.
     */
    public func setQuad(quad: FullScreenQuad): Unit {
        this.quad = Some(quad)
    }

    /**
     * @brief[zh-cn] 挂载到 composer 时的钩子
     * @param[zh-cn] composer 挂载的 EffectComposer
     * @explain[zh-cn] 需要 bgfx view id 的 pass 在此向 composer.allocViewId() 申请。基类默认 no-op，子类按需 override。
     *
     * @brief[en] Hook called when attached to a composer
     * @param[en] composer The EffectComposer being attached to
     * @explain[en] Passes needing a bgfx view id request one from composer.allocViewId() here. Base class defaults to no-op; subclasses override as needed.
     */
    public open func onAttach(composer: EffectComposer): Unit {}

    /**
     * @brief[zh-cn] 用共享 quad 提交全屏四边形（默认覆盖写 state）
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译 program handle
     * @explain[zh-cn] 统一入口：quad 未注入（None）时静默跳过，避免各 pass 重复 match。
     *
     * @brief[en] Submits the full-screen quad with the shared quad (default overwrite state)
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @explain[en] Unified entry: silently skips when the quad is not injected (None), avoiding repeated match in each pass.
     */
    protected func submitQuad(viewId: UInt16, prog: ProgramHandle): Unit {
        if (let Some(q) <- this.quad) { q.submit(viewId, prog) }
    }

    /**
     * @brief[zh-cn] 用共享 quad 提交全屏四边形，使用自定义 render state（如加性混合）
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] prog 已编译 program handle
     * @param[zh-cn] state 完整 render state（bgfx_set_state_cj 第 1 参）
     * @explain[zh-cn] 统一入口：quad 未注入（None）时静默跳过。
     *
     * @brief[en] Submits the full-screen quad with a custom render state (e.g. additive blending)
     * @param[en] viewId The bgfx view id
     * @param[en] prog The compiled program handle
     * @param[en] state The full render state (first argument of bgfx_set_state_cj)
     * @explain[en] Unified entry: silently skips when the quad is not injected (None).
     */
    protected func submitQuadWithState(viewId: UInt16, prog: ProgramHandle, state: UInt64): Unit {
        if (let Some(q) <- this.quad) { q.submitWithState(viewId, prog, state) }
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
    //   - 整条 pass 链由 EffectComposer.render 一次性提交到渲染线程执行，因此链内的
    //     execBgfx 会命中"渲染线程快路径"（SDL 系统线程 ID 相同 → 直接执行），
    //     不再产生线程往返。
    //   - 快路径同时解除了"execBgfx 不可重入"的限制：链内调用 renderer.render
    //     （其内部也走 execBgfx）不会自我等待死锁（RenderPass 即为此种嵌套）。
    //   - 若 pass 被单独调用（不在 EffectComposer 链内、调用线程非渲染线程），
    //     这些 API 仍会各自产生一次线程往返，此时应尽量减少调用次数。
    // ========================================================================

    /**
     * @brief[zh-cn] 设置某 view 的渲染目标 frame buffer
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id（pass 持有，由 EffectComposer.allocViewId 分配）
     * @param[zh-cn] fb 目标 frame buffer；传无效 handle（idx=65535）表示写 swap chain（屏幕）
     *
     * @brief[en] Sets the render target frame buffer for a view
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id (held by the pass, allocated via EffectComposer.allocViewId)
     * @param[en] fb Target frame buffer; pass an invalid handle (idx=65535) to write to the swap chain (screen)
     */
    protected func setRenderTarget(renderer: ThreeRenderer, viewId: UInt16, fb: FrameBufferHandle): Unit {
        renderer.setViewFrameBuffer(viewId, fb)
    }

    /**
     * @brief[zh-cn] 设置某 view 的视口矩形（像素）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] x 视口左上角 x（像素）
     * @param[zh-cn] y 视口左上角 y（像素）
     * @param[zh-cn] w 视口宽（像素）
     * @param[zh-cn] h 视口高（像素）
     *
     * @brief[en] Sets the viewport rectangle (pixels) for a view
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     * @param[en] x Viewport top-left x (pixels)
     * @param[en] y Viewport top-left y (pixels)
     * @param[en] w Viewport width (pixels)
     * @param[en] h Viewport height (pixels)
     */
    protected func setViewport(
        renderer: ThreeRenderer,
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
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     * @param[zh-cn] flags clear 标志位（CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004）
     * @param[zh-cn] color clear 颜色（UInt32）
     * @param[zh-cn] depth clear 深度（0.0~1.0，默认 1.0）
     * @param[zh-cn] stencil clear 模板值（默认 0）
     * @explain[zh-cn] 本方法命名为 clearRenderTarget 而非 clear，避免与 Pass.clear 字段（bool）冲突。
     *
     * @brief[en] Sets the clear for a view (color + depth + stencil)
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     * @param[en] flags Clear flags (CLEAR_COLOR=0x0001 | CLEAR_DEPTH=0x0002 | CLEAR_STENCIL=0x0004)
     * @param[en] color Clear color (UInt32)
     * @param[en] depth Clear depth (0.0~1.0, default 1.0)
     * @param[en] stencil Clear stencil value (default 0)
     * @explain[en] Named clearRenderTarget instead of clear to avoid conflicting with the Pass.clear field (bool).
     */
    protected func clearRenderTarget(
        renderer: ThreeRenderer,
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
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] stage 纹理 stage（0..MAX_TEXTURE_SAMPLERS-1）
     * @param[zh-cn] sampler sampler uniform 句柄
     * @param[zh-cn] tex 待绑纹理句柄
     * @param[zh-cn] flags 采样器 flags（如 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP，0 表示用纹理默认）
     *
     * @brief[en] Binds a texture to the sampler of the given stage
     * @param[en] renderer Renderer
     * @param[en] stage Texture stage (0..MAX_TEXTURE_SAMPLERS-1)
     * @param[en] sampler The sampler uniform handle
     * @param[en] tex The texture handle to bind
     * @param[en] flags Sampler flags (e.g. SAMPLER_U_CLAMP|SAMPLER_V_CLAMP; 0 uses the texture default)
     */
    protected func bindTexture(
        renderer: ThreeRenderer,
        stage: UInt8,
        sampler: UniformHandle,
        tex: TextureHandle,
        flags: UInt32
    ): Unit {
        renderer.bindTexture(stage, sampler, tex, flags)
    }

    /**
     * @brief[zh-cn] 取 frame buffer 指定 attachment 的纹理句柄
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] fb 源 frame buffer
     * @param[zh-cn] attachment attachment 索引（0=主 color，1=depth 等）
     * @return[zh-cn] attachment 对应的 TextureHandle
     *
     * @brief[en] Fetches the texture handle of a frame buffer attachment
     * @param[en] renderer Renderer
     * @param[en] fb Source frame buffer
     * @param[en] attachment Attachment index (0=main color, 1=depth, etc.)
     * @return[en] The TextureHandle for the attachment
     */
    protected func getTexture(
        renderer: ThreeRenderer,
        fb: FrameBufferHandle,
        attachment: UInt8
    ): TextureHandle {
        return renderer.getTexture(fb, attachment)
    }

    /**
     * @brief[zh-cn] 设置 uniform 数据
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] data uniform 数据指针（float32 数组）
     * @param[zh-cn] num 数组长度（默认 1）
     * @explain[zh-cn] bgfx uniform 最小单位是 vec4，数组 uniform 用 num 指定数组长度。
     *
     * @brief[en] Sets uniform data
     * @param[en] renderer Renderer
     * @param[en] handle The uniform handle
     * @param[en] data Uniform data pointer (float32 array)
     * @param[en] num Array length (default 1)
     * @explain[en] bgfx uniforms have a minimum unit of vec4; array uniforms use num for the array length.
     */
    protected func setUniform(
        renderer: ThreeRenderer,
        handle: UniformHandle,
        data: BgfxMemory,
        num!: UInt16 = 1u16
    ): Unit {
        renderer.setUniform(handle, data, num: num)
    }

    /**
     * @brief[zh-cn] 设置 uniform 数据（安全重载，无需外部管理指针）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] handle uniform 句柄
     * @param[zh-cn] values uniform 数据（Float64 数组，bgfx 按 float32 写入）
     * @param[zh-cn] num 数组长度（默认 1）
     * @explain[zh-cn] 内部用 BgfxMemory 包装 Float64 数组并转为 bgfx uniform 指针，
     *         外部只传数值数组，无须 `unsafe { CPointer<Unit>(...) }`。
     *
     * @brief[en] Sets uniform data (safe overload, no external pointer management)
     * @param[en] renderer Renderer
     * @param[en] handle The uniform handle
     * @param[en] values Uniform data (Float64 array, written as float32 by bgfx)
     * @param[en] num Array length (default 1)
     * @explain[en] Internally wraps the Float64 array in BgfxMemory and converts it to a bgfx uniform pointer;
     *         callers only pass the numeric array, no `unsafe { CPointer<Unit>(...) }` needed.
     */
    protected func setUniformFloats(
        renderer: ThreeRenderer,
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
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] fstencil 前面 stencil 位域（FUNC_REF/OP_FAIL/OP_ZFAIL/OP_PASS/RWMASK 编码）
     * @param[zh-cn] bstencil 后面 stencil 位域（同上）
     * @explain[zh-cn] bgfx 的 stencil 是 per-draw 瞬态状态，每次 submit 前需重设。
     *
     * @brief[en] Sets stencil state (per-draw transient)
     * @param[en] renderer Renderer
     * @param[en] fstencil Front stencil bitfield (FUNC_REF/OP_FAIL/OP_ZFAIL/OP_PASS/RWMASK encoding)
     * @param[en] bstencil Back stencil bitfield (same encoding)
     * @explain[en] bgfx stencil is per-draw transient state and must be reset before each submit.
     */
    protected func setStencil(renderer: ThreeRenderer, fstencil: UInt32, bstencil: UInt32): Unit {
        renderer.setStencil(fstencil, bstencil)
    }

    /**
     * @brief[zh-cn] 触发某 view 的 empty submit（仅推进 clear / view 序号，不绘制）
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] viewId bgfx view id
     *
     * @brief[en] Triggers an empty submit for a view (only advances clear / view sequence, draws nothing)
     * @param[en] renderer Renderer
     * @param[en] viewId The bgfx view id
     */
    protected func touchView(renderer: ThreeRenderer, viewId: UInt16): Unit {
        renderer.touchView(viewId)
    }

    /**
     * @brief[zh-cn] 设置 pass 内部 RT 尺寸
     * @explain[zh-cn] 基类默认 no-op，子类按需 override。
     *
     * @brief[en] Sets the pass's internal RT size
     * @explain[en] Base class defaults to no-op; subclasses override as needed.
     */
    public open func setSize(width: Int64, height: Int64): Unit {}

    /**
     * @brief[zh-cn] 执行 pass 渲染逻辑
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写入 buffer（FrameBufferHandle）
     * @param[zh-cn] readBuffer 读取 buffer（上一 pass 结果）
     * @param[zh-cn] deltaTime 帧间隔（秒）
     * @explain[zh-cn] 基类默认 no-op，子类必须 override。
     *
     * @brief[en] Executes the pass render logic
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (FrameBufferHandle)
     * @param[en] readBuffer Read buffer (previous pass result)
     * @param[en] deltaTime Frame delta time (seconds)
     * @explain[en] Base class defaults to no-op; subclasses must override.
     */
    public open func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {}

    /**
     * @brief[zh-cn] 基类默认 no-op，子类覆写释放自身 GPU 资源
     *
     * @brief[en] base default no-op; subclasses override to release their own GPU resources
     */
    public open func release(): Bool {
        return true
    }

    /**
     * @brief[zh-cn] 本 pass 私有的 uniform 缓存（按 pass 实例隔离）
     * @explain[zh-cn] uniform 缓存以"名字"为键，同名不同类型/数组长度会互相污染，
     *               故不能全局共享；但每个 pass 每帧新建 BgfxUniforms 会让缓存恒空，
     *               导致每帧重建 bgfx uniform（创建开销 + uniform 列表无限增长）。
     *               此处按 pass 实例懒创建一个并长期复用：同名不同 pass 互不影响，
     *               同一 pass 内则命中缓存。
     *
     * @brief[en] The uniform cache private to this pass instance
     * @explain[en] The uniform cache is keyed by name, so entries with the same name but
     *               different types/array lengths would collide — it must not be shared
     *               globally. Creating a fresh BgfxUniforms every frame, however, keeps
     *               the cache permanently empty, so every frame rebuilds bgfx uniforms
     *               (creation cost + an unbounded uniform list). One instance per pass is
     *               created lazily and reused: no cross-pass collision, cache hits within
     *               the pass.
     */
    private var _uniformsCache: Option<BgfxUniforms> = None

    /**
     * @brief[zh-cn] uniform 句柄按名缓存（本 pass 私有）
     * @explain[zh-cn] 后处理 pass 的 render() 每帧都要取若干 uniform 句柄，
     *               原实现每次调 _passUniforms().createUniform(name, ...) ——
     *               内部要对全局 bgfxCallMtx 加解锁 + 对 name 字符串求哈希。
     *               句柄在进程生命周期内不变，按 "name@type@num" 缓存一次即可，
     *               避免每帧重复的锁与字符串哈希。
     *
     * @brief[en] Per-pass uniform handle cache keyed by name
     * @explain[en] A post-processing pass fetches several uniform handles every frame;
     *               the previous implementation called _passUniforms().createUniform(name, ...)
     *               each time, which locks the global bgfxCallMtx and hashes the name string.
     *               Handles are stable for the process lifetime, so caching them once by
     *               "name@type@num" removes the per-frame locking and string hashing.
     */
    private var _uniformHandleCache: HashMap<String, UniformHandle> = HashMap<String, UniformHandle>()

    /**
     * @brief[zh-cn] 按名取 uniform 句柄（首次创建后缓存，本 pass 私有）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] uniformType uniform 类型
     * @param[zh-cn] num 数组长度（非数组传 1）
     * @return[zh-cn] 缓存的 uniform 句柄
     *
     * @brief[en] Gets a uniform handle by name (cached after first creation; per-pass)
     * @param[en] name Uniform name
     * @param[en] uniformType Uniform type
     * @param[en] num Array length (1 for non-array)
     * @return[en] Cached uniform handle
     */
    protected func _cachedUniform(name: String, uniformType: UInt32, num!: UInt16 = 1u16): UniformHandle {
        let key = if (num == 1u16) {
            name + "@" + uniformType.toString()
        } else {
            name + "@" + uniformType.toString() + "@" + num.toString()
        }
        if (let Some(h) <- this._uniformHandleCache.get(key)) {
            return h
        } else {
            let h = this._passUniforms().createUniform(name, uniformType, num)
            this._uniformHandleCache.add(key, h)
            return h
        }
    }

    /**
     * @brief[zh-cn] 释放本 pass 私有的 uniform 缓存与句柄缓存
     * @explain[zh-cn] uniform 句柄由 _passUniforms() 创建的 BgfxUniforms 持有；
     *               释放 BgfxUniforms 会销毁底层 bgfx uniform，此时句柄缓存中的
     *               句柄已失效，必须一并清空，否则重启渲染时会拿到已销毁的句柄。
     *
     * @brief[en] Releases this pass's private uniform cache and handle cache
     * @explain[en] The uniform handles are owned by the BgfxUniforms created in _passUniforms();
     *               disposing it destroys the underlying bgfx uniforms, after which the handles
     *               in the handle cache are dangling and must be cleared too — otherwise a
     *               restarted render would fetch destroyed handles.
     */
    protected func _disposePassUniforms(): Unit {
        if (let Some(u) <- this._uniformsCache) { u.release() }
        this._uniformsCache = None
        this._uniformHandleCache.clear()
    }

    /**
     * @brief[zh-cn] 取本 pass 私有的 uniform 缓存（首次调用时创建）
     * @return[zh-cn] 本 pass 私有的 BgfxUniforms 实例
     *
     * @brief[en] Returns this pass's private uniform cache (created on first use)
     * @return[en] This pass's private BgfxUniforms instance
     */
    protected func _passUniforms(): BgfxUniforms {
        if (let Some(u) <- this._uniformsCache) {
            return u
        } else {
            let u = BgfxUniforms()
            this._uniformsCache = Some(u)
            return u
        }
    }
}
