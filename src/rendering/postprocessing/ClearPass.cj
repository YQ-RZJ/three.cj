/**
 * @file[zh-cn] BgfxClearPass 清屏 pass
 * @brief[zh-cn] 清屏 pass —— 对当前读 buffer（或屏幕）执行 clear 操作
 * @explain[zh-cn] 设计：
 *         - needsSwap=false（清屏后不交换 buffer，下一 pass 仍从 readBuffer 取）
 *         - clearColor/clearAlpha：清屏颜色与透明度
 *         - render(renderer, writeBuffer, readBuffer, deltaTime)：
 *             bgfx_set_view_frame_buffer(view, renderToScreen? null : readBuffer)
 *             bgfx_set_view_clear(view, COLOR|DEPTH, clearColor, clearAlpha, 0)
 *             bgfx_touch(view)（无 submit，仅触发 clear）
 *         用 view 级 clear：bgfx_set_view_frame_buffer + bgfx_set_view_clear + bgfx_touch，
 *         在该 view 的所有 submit 前清帧 buffer。clearColor 是 UInt32（0xAABBGGRR，
 *         与 BgfxRenderer.clearColor 一致）；clearAlpha 由 bgfx_set_view_clear 合并到颜色 uint32 高字节。
 *
 * @file[en] BgfxClearPass clear pass
 * @brief[en] Clear pass - performs a clear operation on the current read buffer (or screen)
 * @explain[en] Design:
 *         - needsSwap=false (does not swap buffers after clearing; next pass still reads from readBuffer)
 *         - clearColor/clearAlpha: clear color and alpha
 *         - render(renderer, writeBuffer, readBuffer, deltaTime):
 *             bgfx_set_view_frame_buffer(view, renderToScreen? null : readBuffer)
 *             bgfx_set_view_clear(view, COLOR|DEPTH, clearColor, clearAlpha, 0)
 *             bgfx_touch(view) (no submit; only triggers the clear)
 *         Uses view-level clear: bgfx_set_view_frame_buffer + bgfx_set_view_clear + bgfx_touch,
 *         clearing the frame buffer before all submits on that view. clearColor is a UInt32
 *         (0xAABBGGRR, consistent with BgfxRenderer.clearColor); clearAlpha is merged into the
 *         color uint32 high byte by bgfx_set_view_clear.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.utils.log.Logger
import three.rendering.types.*
import std.collection.*

/**
 * @brief[zh-cn] 清屏 pass
 * @brief[en] Clear pass
 * @explain[zh-cn] 对当前 read buffer（renderToScreen=true 时对屏幕）执行 clear。
 * @explain[en] Performs clear on the current read buffer (or the screen when renderToScreen=true).
 */
public class ClearPass <: Pass {
    /**
     * @brief[zh-cn] Clear 颜色（UInt32，0xAABBGGRR，对齐 BgfxRenderer.clearColor），默认透明黑
     * @brief[en] Clear color (UInt32, 0xAABBGGRR, aligned with BgfxRenderer.clearColor), default transparent black
     */
    public var clearColor: UInt32 = 0x00000000u32

    /**
     * @brief[zh-cn] Clear alpha [0,1]，默认 0
     * @brief[en] Clear alpha [0,1], default 0
     */
    public var clearAlpha: Float64 = 0.0

    /**
     * 本 pass 用的 view id（ClearPass 不在主 view 0 上清，避免与 RenderPass 冲突；
     * 用一个空闲 view，composer 分配或固定常量）。
     * 当前固定 60（EffectComposer 的 pass 通常用 0..49，shadow 用 50..127，60 在空闲区）。
     */
    private static let CLEAR_VIEW_ID: UInt16 = 60u16

    /**
     * @brief[zh-cn] 构造 ClearPass
     * @brief[en] Constructs ClearPass
     * @param[zh-cn] clearColor clear 颜色（默认透明黑 0x00000000）
     * @param[zh-cn] clearAlpha clear alpha（默认 0）
     * @param[en] clearColor Clear color (default transparent black 0x00000000)
     * @param[en] clearAlpha Clear alpha (default 0)
     */
    public init(clearColor!: UInt32 = 0x00000000u32, clearAlpha!: Float64 = 0.0) {
        super()
        this.clearColor = clearColor
        this.clearAlpha = clearAlpha
        // 清屏后不交换 buffer
        this.needsSwap = false
    }

    /**
     * @brief[zh-cn] 执行清屏
     * @brief[en] Performs the clear operation
     * @param[zh-cn] renderer 渲染器
     * @param[zh-cn] writeBuffer 写 buffer（本 pass 不用）
     * @param[zh-cn] readBuffer 读 buffer（renderToScreen=false 时清这个）
     * @param[zh-cn] deltaTime 帧间隔
     * @param[en] renderer Renderer
     * @param[en] writeBuffer Write buffer (unused by this pass)
     * @param[en] readBuffer Read buffer (cleared when renderToScreen=false)
     * @param[en] deltaTime Frame delta time
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        let viewId = ClearPass.CLEAR_VIEW_ID
        let col = this.clearColor
        // clearColor 是 0xRRGGBB（6 位 hex），alpha [0,1] → 最低字节：布局 0xRRGGBBAA
        // （对齐 BgfxRenderer.setClearColor 的 (r<<24)|(g<<16)|(b<<8)|a 约定）。
        // 错误拼接（alpha<<24）会让 alpha=0 → 全黑。
        let alphaByte = UInt32(Int32(this.clearAlpha * 255.0)) & 0xFFu32
        let colWithAlpha = ((col & 0x00FFFFFFu32) << 8) | alphaByte
        let rt = this.renderToScreen
        Logger.trace(["ClearPass", "render() ENTER viewId=" + viewId.toString() + " clearColor=" + col.toString() + " clearAlpha=" + this.clearAlpha.toString() + " colWithAlpha=" + colWithAlpha.toString() + " renderToScreen=" + rt.toString() + " readBuffer.idx=" + handleIdx(readBuffer).toString() + " writeBuffer.idx=" + handleIdx(writeBuffer).toString()])
        // 关键：必须设置 view rect，否则 view 的 rect 是未定义值（bgfx View.Rect 默认构造未初始化），
        // clear 不会渲染到有效区域 → 全黑。对齐其他 pass 的范式。
        let vw = UInt16(renderer.width)
        let vh = UInt16(renderer.height)
        this.setViewport(renderer, viewId, 0u16, 0u16, vw, vh)
        // renderToScreen=true 时清屏幕（无效 FB handle = swap chain）
        if (rt) {
            this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
            Logger.trace(["ClearPass", "set view frame buffer → swap chain (null FB)"])
        } else {
            this.setRenderTarget(renderer, viewId, readBuffer)
            Logger.trace(["ClearPass", "set view frame buffer → readBuffer idx=" + handleIdx(readBuffer).toString()])
        }
        // CLEAR_COLOR | CLEAR_DEPTH，alpha 写颜色高字节
        let clearFlags: UInt16 = BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH  // CLEAR_COLOR | CLEAR_DEPTH
        this.clearRenderTarget(renderer, viewId, clearFlags, colWithAlpha, depth: 1.0f32, stencil: 0u8)
        // touch 触发本 view 的 clear（touch = empty primitive submit，进 frame 队列）
        this.touchView(renderer, viewId)
        Logger.trace(["ClearPass", "touch done (view=" + viewId.toString() + ")"])
        // 不在此调 present：frame 统一由 EffectComposer.render 末尾触发
        Logger.trace(["ClearPass", "bgfx_frame 由 EffectComposer.render 末尾统一触发"])
    }
}
