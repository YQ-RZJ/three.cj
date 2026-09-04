/**
 * @file[zh-cn] MouseProvider 鼠标输入提供者
 * @brief[zh-cn] 鼠标输入状态管理，处理鼠标移动/按键/滚轮事件，提供鼠标状态查询
 * @explain[zh-cn] 职责：
 * - 维护鼠标当前位置（持续状态）
 * - 累积本帧鼠标位移（帧末重置）
 * - 维护鼠标按键状态（位掩码）
 * - 累积本帧滚轮滚动量（帧末重置）
 * - 提供 getMouseX/Y/getMouseDX/Y/isMouseButtonDown/getWheelX/Y 查询接口
 *
 * @file[en] MouseProvider Mouse input provider
 * @brief[en] Mouse input state management, handles mouse motion/button/wheel events, provides mouse state queries
 * @explain[en] Responsibilities:
 * - Maintains current mouse position (persistent state)
 * - Accumulates mouse delta this frame (reset at frame end)
 * - Maintains mouse button state (bitmask)
 * - Accumulates wheel scroll this frame (reset at frame end)
 * - Provides getMouseX/Y/getMouseDX/Y/isMouseButtonDown/getWheelX/Y query APIs
 */
package three.window

import std.core.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 鼠标输入提供者
 * @explain[zh-cn] 处理鼠标事件，维护鼠标状态，提供查询接口。
 *
 * @brief[en] Mouse input provider
 * @explain[en] Handles mouse events, maintains mouse state, provides query APIs.
 */
public class MouseProvider <: InputProvider {
    /// 鼠标 X 坐标（相对窗口，持续状态）
    private var _mouseX: Float32 = 0.0
    /// 鼠标 Y 坐标（相对窗口，持续状态）
    private var _mouseY: Float32 = 0.0
    /// 本帧鼠标 X 累积位移（帧末清空）
    private var _mouseDX: Float32 = 0.0
    /// 本帧鼠标 Y 累积位移（帧末清空）
    private var _mouseDY: Float32 = 0.0
    /// 鼠标按键位掩码（button-1 位，持续状态）
    private var _mouseButtons: UInt32 = 0
    /// 本帧滚轮 X 累积滚动（帧末清空）
    private var _wheelX: Float32 = 0.0
    /// 本帧滚轮 Y 累积滚动（帧末清空）
    private var _wheelY: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造鼠标提供者
     *
     * @brief[en] Constructs a mouse provider
     */
    public init() {}

    /**
     * @brief[zh-cn] 处理鼠标事件
     * @param[zh-cn] evt 分发事件
     *
     * @brief[en] Handles mouse events
     * @param[en] evt The dispatch event
     */
    public override func onEvent(evt: DispatchEvent): Unit {
        let t = evt.`type`
        if (t == SDL_EVENT_MOUSE_MOTION) {
            this._mouseX = evt.f1
            this._mouseY = evt.f2
            this._mouseDX += evt.f3
            this._mouseDY += evt.f4
        } else if (t == SDL_EVENT_MOUSE_BUTTON_DOWN || t == SDL_EVENT_MOUSE_BUTTON_UP) {
            let button = UInt8(evt.f1)
            let mask: UInt32 = 1u32 << UInt32(button - 1u8)
            if (evt.b1) {
                this._mouseButtons = this._mouseButtons | mask
            } else {
                this._mouseButtons = this._mouseButtons & (0xFFFFFFFFu32 ^ mask)
            }
        } else if (t == SDL_EVENT_MOUSE_WHEEL) {
            this._wheelX += evt.f1
            this._wheelY += evt.f2
        }
    }

    /**
     * @brief[zh-cn] 帧末重置边沿状态和累积量
     *
     * @brief[en] Resets edge states and accumulated values at frame end
     */
    public override func endFrame(): Unit {
        this._mouseDX = 0.0
        this._mouseDY = 0.0
        this._wheelX = 0.0
        this._wheelY = 0.0
    }

    /**
     * @brief[zh-cn] 获取鼠标 X 坐标（相对窗口）
     * @return[zh-cn] 鼠标 X 坐标
     *
     * @brief[en] Gets the mouse X position (relative to the window)
     * @return[en] The mouse X position
     */
    public func getMouseX(): Float32 { return this._mouseX }

    /**
     * @brief[zh-cn] 获取鼠标 Y 坐标（相对窗口）
     * @return[zh-cn] 鼠标 Y 坐标
     *
     * @brief[en] Gets the mouse Y position (relative to the window)
     * @return[en] The mouse Y position
     */
    public func getMouseY(): Float32 { return this._mouseY }

    /**
     * @brief[zh-cn] 获取鼠标本帧 X 位移（累积）
     * @return[zh-cn] 鼠标 X 位移
     *
     * @brief[en] Gets the mouse X delta accumulated this frame
     * @return[en] The mouse X delta
     */
    public func getMouseDX(): Float32 { return this._mouseDX }

    /**
     * @brief[zh-cn] 获取鼠标本帧 Y 位移（累积）
     * @return[zh-cn] 鼠标 Y 位移
     *
     * @brief[en] Gets the mouse Y delta accumulated this frame
     * @return[en] The mouse Y delta
     */
    public func getMouseDY(): Float32 { return this._mouseDY }

    /**
     * @brief[zh-cn] 查询鼠标按键是否按下
     * @param[zh-cn] button 鼠标按键（SDL_BUTTON_*，如 SDL_BUTTON_LEFT=1）
     * @return[zh-cn] 按下返回 true，否则 false
     *
     * @brief[en] Queries whether a mouse button is pressed
     * @param[en] button Mouse button (SDL_BUTTON_*, e.g. SDL_BUTTON_LEFT=1)
     * @return[en] true if pressed, false otherwise
     */
    public func isMouseButtonDown(button: UInt8): Bool {
        let mask: UInt32 = 1u32 << UInt32(button - 1u8)
        return (this._mouseButtons & mask) != 0u32
    }

    /**
     * @brief[zh-cn] 获取滚轮水平滚动量（本帧累积）
     * @return[zh-cn] 水平滚动量
     *
     * @brief[en] Gets the horizontal wheel scroll amount (accumulated this frame)
     * @return[en] The horizontal scroll amount
     */
    public func getWheelX(): Float32 { return this._wheelX }

    /**
     * @brief[zh-cn] 获取滚轮垂直滚动量（本帧累积）
     * @return[zh-cn] 垂直滚动量
     *
     * @brief[en] Gets the vertical wheel scroll amount (accumulated this frame)
     * @return[en] The vertical scroll amount
     */
    public func getWheelY(): Float32 { return this._wheelY }
}
