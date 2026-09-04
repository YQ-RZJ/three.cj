/**
 * @file[zh-cn] KeyboardProvider 键盘输入提供者
 * @brief[zh-cn] 键盘输入状态管理，处理键盘按下/释放事件，提供按键状态查询
 * @explain[zh-cn] 职责：
 * - 维护键盘当前状态（哪些键按下）
 * - 记录本帧刚按下的键（边沿触发）
 * - 记录本帧刚释放的键（边沿触发）
 * - 提供 isKeyDown/isKeyPressed/isKeyReleased 查询接口
 *
 * @file[en] KeyboardProvider Keyboard input provider
 * @brief[en] Keyboard input state management, handles key press/release events, provides key state queries
 * @explain[en] Responsibilities:
 * - Maintains current keyboard state (which keys are down)
 * - Records keys just pressed this frame (edge-triggered)
 * - Records keys just released this frame (edge-triggered)
 * - Provides isKeyDown/isKeyPressed/isKeyReleased query APIs
 */
package three.window

import std.core.*
import std.collection.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 键盘输入提供者
 * @explain[zh-cn] 处理键盘事件，维护按键状态，提供查询接口。
 *
 * @brief[en] Keyboard input provider
 * @explain[en] Handles keyboard events, maintains key state, provides query APIs.
 */
public class KeyboardProvider <: InputProvider {
    /// 键盘当前状态（scancode → 是否按下，持续状态，不清零）
    private var _keys: Array<Bool> = Array<Bool>(512, { _ => false })
    /// 本帧刚按下的键集合（边沿，帧末清空）
    private var _pressedKeys: HashSet<UInt32> = HashSet<UInt32>()
    /// 本帧刚释放的键集合（边沿，帧末清空）
    private var _releasedKeys: HashSet<UInt32> = HashSet<UInt32>()

    /**
     * @brief[zh-cn] 构造键盘提供者
     *
     * @brief[en] Constructs a keyboard provider
     */
    public init() {}

    /**
     * @brief[zh-cn] 处理键盘事件
     * @param[zh-cn] evt 分发事件
     *
     * @brief[en] Handles keyboard events
     * @param[en] evt The dispatch event
     */
    public override func onEvent(evt: DispatchEvent): Unit {
        let t = evt.`type`
        if (t == SDL_EVENT_KEY_DOWN || t == SDL_EVENT_KEY_UP) {
            let sc = UInt32(evt.f1)
            if (sc < 512u32) {
                this._keys[Int64(sc)] = evt.b1
                if (evt.b1 && !evt.b2) {
                    this._pressedKeys.add(sc)
                }
                if (!evt.b1) {
                    this._releasedKeys.add(sc)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 帧末重置边沿状态
     *
     * @brief[en] Resets edge states at frame end
     */
    public override func endFrame(): Unit {
        this._pressedKeys.clear()
        this._releasedKeys.clear()
    }

    /**
     * @brief[zh-cn] 查询键盘某键当前是否按下
     * @param[zh-cn] scancode 键盘扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 按下返回 true，否则 false
     *
     * @brief[en] Queries whether a key is currently held down
     * @param[en] scancode Key scancode (SDL_SCANCODE_*)
     * @return[en] true if held down, false otherwise
     */
    public func isKeyDown(scancode: UInt32): Bool {
        if (scancode >= 512u32) { return false }
        return this._keys[Int64(scancode)]
    }

    /**
     * @brief[zh-cn] 查询键盘某键本帧是否刚按下（边沿触发）
     * @param[zh-cn] scancode 键盘扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 刚按下返回 true，否则 false
     *
     * @brief[en] Queries whether a key was just pressed this frame (edge-triggered)
     * @param[en] scancode Key scancode (SDL_SCANCODE_*)
     * @return[en] true if just pressed, false otherwise
     */
    public func isKeyPressed(scancode: UInt32): Bool {
        return this._pressedKeys.contains(scancode)
    }

    /**
     * @brief[zh-cn] 查询键盘某键本帧是否刚释放（边沿触发）
     * @param[zh-cn] scancode 键盘扫描码（SDL_SCANCODE_*）
     * @return[zh-cn] 刚释放返回 true，否则 false
     *
     * @brief[en] Queries whether a key was just released this frame (edge-triggered)
     * @param[en] scancode Key scancode (SDL_SCANCODE_*)
     * @return[en] true if just released, false otherwise
     */
    public func isKeyReleased(scancode: UInt32): Bool {
        return this._releasedKeys.contains(scancode)
    }
}
