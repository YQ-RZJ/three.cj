/**
 * @file[zh-cn] TouchProvider 触摸输入提供者
 * @brief[zh-cn] 触摸输入状态管理，处理触摸按下/移动/释放事件，提供触摸点查询
 * @explain[zh-cn] 职责：
 * - 维护当前活跃的触摸点列表
 * - 记录每个触摸点的归一化坐标、位移、压力
 * - 提供 getTouchCount/getTouch 查询接口
 *
 * @file[en] TouchProvider Touch input provider
 * @brief[en] Touch input state management, handles touch down/motion/up events, provides touch point queries
 * @explain[en] Responsibilities:
 * - Maintains list of currently active touch points
 * - Records normalized position, delta, pressure for each touch point
 * - Provides getTouchCount/getTouch query APIs
 */
package three.window

import std.core.*
import std.collection.*
import sdl4cj.sdl.*

/**
 * @brief[zh-cn] 触摸点数据
 * @explain[zh-cn] 单个触摸点的状态快照
 *
 * @brief[en] Touch point data
 * @explain[en] State snapshot of a single touch point
 */
public class TouchPoint {
    /// 触摸手指实例 ID
    public var fingerID: Int64 = 0
    /// 归一化 X 坐标（0~1，相对窗口）
    public var x: Float32 = 0.0
    /// 归一化 Y 坐标（0~1，相对窗口）
    public var y: Float32 = 0.0
    /// 归一化 X 位移（本帧）
    public var dx: Float32 = 0.0
    /// 归一化 Y 位移（本帧）
    public var dy: Float32 = 0.0
    /// 压力（0~1）
    public var pressure: Float32 = 0.0

    /**
     * @brief[zh-cn] 构造触摸点
     *
     * @brief[en] Constructs a touch point
     */
    public init() {}

    /**
     * @brief[zh-cn] 构造触摸点
     * @param[zh-cn] fingerID 手指实例 ID
     * x 归一化 X 坐标
     * y 归一化 Y 坐标
     * dx X 位移
     * dy Y 位移
     * pressure 压力
     *
     * @brief[en] Constructs a touch point
     * @param[en] fingerID Finger instance ID
     * x Normalized X position
     * y Normalized Y position
     * dx X delta
     * dy Y delta
     * pressure Pressure
     */
    public init(fingerID!: Int64, x!: Float32, y!: Float32, dx!: Float32, dy!: Float32, pressure!: Float32) {
        this.fingerID = fingerID
        this.x = x
        this.y = y
        this.dx = dx
        this.dy = dy
        this.pressure = pressure
    }
}

/**
 * @brief[zh-cn] 触摸输入提供者
 * @explain[zh-cn] 处理触摸事件，维护触摸点状态，提供查询接口。
 *
 * @brief[en] Touch input provider
 * @explain[en] Handles touch events, maintains touch point state, provides query APIs.
 */
public class TouchProvider <: InputProvider {
    /// 当前活跃的触摸点（fingerID → TouchPoint）
    private var _touches: HashMap<Int64, TouchPoint> = HashMap<Int64, TouchPoint>()
    /// 本帧新增的触摸点（边沿）
    private var _touchesBegan: ArrayList<TouchPoint> = ArrayList<TouchPoint>()
    /// 本帧移除的触摸点（边沿）
    private var _touchesEnded: ArrayList<Int64> = ArrayList<Int64>()

    /**
     * @brief[zh-cn] 构造触摸提供者
     *
     * @brief[en] Constructs a touch provider
     */
    public init() {}

    /**
     * @brief[zh-cn] 处理触摸事件
     * @param[zh-cn] evt 分发事件
     *
     * @brief[en] Handles touch events
     * @param[en] evt The dispatch event
     */
    public override func onEvent(evt: DispatchEvent): Unit {
        let t = evt.`type`
        if (t >= SDL_EVENT_FINGER_DOWN && t <= SDL_EVENT_FINGER_MOTION) {
            let fingerID = Int64(evt.f1)
            let x = evt.f2
            let y = evt.f3
            let dx = evt.f4
            let dy = evt.f5
            let pressure = evt.f5

            if (t == SDL_EVENT_FINGER_DOWN) {
                let point = TouchPoint(fingerID: fingerID, x: x, y: y, dx: 0.0, dy: 0.0, pressure: pressure)
                this._touches.add(fingerID, point)
                this._touchesBegan.add(point)
            } else if (t == SDL_EVENT_FINGER_UP) {
                this._touches.remove(fingerID)
                this._touchesEnded.add(fingerID)
            } else if (t == SDL_EVENT_FINGER_MOTION) {
                if (let Some(point) <- this._touches.get(fingerID)) {
                    point.x = x
                    point.y = y
                    point.dx += dx
                    point.dy += dy
                    point.pressure = pressure
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
        this._touchesBegan.clear()
        this._touchesEnded.clear()
        // 重置所有触摸点的位移
        for ((_, point) in this._touches) {
            point.dx = 0.0
            point.dy = 0.0
        }
    }

    /**
     * @brief[zh-cn] 获取当前活跃触摸点数量
     * @return[zh-cn] 触摸点数量
     *
     * @brief[en] Gets the number of active touch points
     * @return[en] The number of touch points
     */
    public func getTouchCount(): Int64 {
        return this._touches.size
    }

    /**
     * @brief[zh-cn] 获取指定索引的触摸点
     * @param[zh-cn] index 触摸点索引（0-based）
     * @return[zh-cn] 触摸点数据；索引越界返回 None
     *
     * @brief[en] Gets the touch point at the specified index
     * @param[en] index Touch point index (0-based)
     * @return[en] The touch point data, or None if index is out of bounds
     */
    public func getTouch(index: Int64): Option<TouchPoint> {
        var i = 0i64
        for ((_, point) in this._touches) {
            if (i == index) {
                return Some(point)
            }
            i += 1
        }
        return None
    }

    /**
     * @brief[zh-cn] 获取指定 fingerID 的触摸点
     * @param[zh-cn] fingerID 手指实例 ID
     * @return[zh-cn] 触摸点数据；未找到返回 None
     *
     * @brief[en] Gets the touch point with the specified finger ID
     * @param[en] fingerID Finger instance ID
     * @return[en] The touch point data, or None if not found
     */
    public func getTouchByID(fingerID: Int64): Option<TouchPoint> {
        return this._touches.get(fingerID)
    }

    /**
     * @brief[zh-cn] 获取本帧新增的触摸点列表
     * @return[zh-cn] 新增触摸点列表
     *
     * @brief[en] Gets the list of touch points added this frame
     * @return[en] The list of added touch points
     */
    public func getTouchesBegan(): ArrayList<TouchPoint> {
        return this._touchesBegan
    }

    /**
     * @brief[zh-cn] 获取本帧移除的触摸点 fingerID 列表
     * @return[zh-cn] 移除的 fingerID 列表
     *
     * @brief[en] Gets the list of finger IDs removed this frame
     * @return[en] The list of removed finger IDs
     */
    public func getTouchesEnded(): ArrayList<Int64> {
        return this._touchesEnded
    }
}
