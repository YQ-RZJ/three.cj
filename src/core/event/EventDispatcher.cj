/**
 * @file[zh-cn] EventDispatcher
 * @brief[zh-cn] 提供自定义对象的事件监听和分发机制
 * @explain[zh-cn] 参考 Three.js EventDispatcher 实现，支持 addEventListener/removeEventListener/hasEventListener/dispatchEvent 标准事件 API，同时保留 on/off/emit 兼容方法。由于仓颉语言中函数类型无法直接进行引用相等比较，使用 ListenerHandle 包装类来实现监听器的添加、移除和查重。调用方需保存 addEventListener 返回的 ListenerHandle，以便后续调用 removeEventListener/hasEventListener 时使用。
 *
 * @file[en] EventDispatcher
 * @brief[en] Provides event listening and dispatching mechanism for custom objects
 * @explain[en] Modeled after the Three.js EventDispatcher implementation, supporting addEventListener/removeEventListener/hasEventListener/dispatchEvent standard event API, with on/off/emit compatibility methods. Since the Cangjie language does not support reference equality comparison for function types directly, the ListenerHandle wrapper class is used to enable adding, removing, and deduplicating listeners. Callers must save the ListenerHandle returned by addEventListener for subsequent removeEventListener/hasEventListener calls.
 */
package three.core.event

import std.collection.*

/**
 * @brief[zh-cn] 监听器句柄，包装回调函数以支持引用比较
 * @explain[zh-cn] 每次调用 addEventListener 都会创建一个新的 ListenerHandle 实例，通过引用比较（refEq）可以精确识别和移除特定监听器。
 *
 * @brief[en] Listener handle, wrapping callback functions to support reference comparison
 * @explain[en] Each call to addEventListener creates a new ListenerHandle instance; reference equality (refEq) can be used to precisely identify and remove specific listeners.
 */
public class ListenerHandle {
    /**
     * @brief[zh-cn] 回调函数
     */
    public let callback: (Event) -> Unit

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] callback 回调函数
     *
     * @brief[en] Constructor
     * @param[en] callback Callback function
     */
    public init(callback: (Event) -> Unit) {
        this.callback = callback
    }
}

/**
 * @brief[zh-cn] 事件对象，在分发事件时传递给监听器
 * @explain[zh-cn] 事件对象包含 type（事件类型）和 target（事件目标）属性。在 dispatchEvent 调用期间，target 会被设置为事件分发器自身，调用完成后 target 会被重置为 null。
 *
 * @brief[en] Event object passed to listeners when dispatching events
 * @explain[en] The event object contains type (event type) and target (event target) properties. During dispatchEvent, target is set to the event dispatcher itself; after the call completes, target is reset to null.
 */
public class Event {
    /**
     * @brief[zh-cn] 事件类型
     */
    public var `type`: String
    /**
     * @brief[zh-cn] 事件目标（分发事件的对象），由 dispatchEvent 自动设置
     */
    public var target: ?EventDispatcher

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] type 事件类型
     *
     * @brief[en] Constructor
     * @param[en] type Event type
     */
    public init(`type`: String) {
        this.`type` = `type`
        this.target = None
    }
}

/**
 * @brief[zh-cn] 事件分发器，提供 addEventListener/removeEventListener/hasEventListener/dispatchEvent 事件 API
 * @explain[zh-cn] 用法示例：
 * ```
 * class Car <: EventDispatcher {
 * public func start(): Unit {
 * this.dispatchEvent(Event("start"))
 * }
 * }
 * let car = Car()
 * let handle = car.addEventListener("start", { event =>
 * println("Car started!")
 * })
 * car.start()
 * car.removeEventListener("start", handle)
 * ```
 *
 * @brief[en] Event dispatcher providing addEventListener/removeEventListener/hasEventListener/dispatchEvent event API
 * @explain[en] Usage example:
 * ```
 * class Car <: EventDispatcher {
 * public func start(): Unit {
 * this.dispatchEvent(Event("start"))
 * }
 * }
 * let car = Car()
 * let handle = car.addEventListener("start", { event =>
 * println("Car started!")
 * })
 * car.start()
 * car.removeEventListener("start", handle)
 * ```
 */
public open class EventDispatcher {
    /**
     * @brief[zh-cn] 事件监听器存储，键为事件类型，值为监听器句柄列表
     */
    private var _listeners: HashMap<String, ArrayList<ListenerHandle>>

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() {
        this._listeners = HashMap<String, ArrayList<ListenerHandle>>()
    }

    // ===== 标准 JS 事件 API =====

    /**
     * @brief[zh-cn] 添加事件监听器
     * @explain[zh-cn] 将给定的监听器函数添加到指定事件类型的监听器列表中。如果同一句柄已经添加过，则不会重复添加。返回监听器句柄，用于后续移除或查询。
     * @param[zh-cn] type 事件类型
     * listener 监听器函数，接收 Event 对象作为参数
     * @return[zh-cn] 监听器句柄，用于 removeEventListener/hasEventListener
     *
     * @brief[en] Add an event listener
     * @explain[en] Adds the given listener function to the listener list for the specified event type. If the same handle has already been added, it will not be added again. Returns the listener handle for subsequent removal or querying.
     * @param[en] type Event type
     * listener Listener function, receives an Event object as parameter
     * @return[en] Listener handle, for use with removeEventListener/hasEventListener
     */
    public func addEventListener(`type`: String, listener: (Event) -> Unit): ListenerHandle {
        let listeners = this._listeners
        if (!listeners.contains(`type`)) {
            listeners.add(`type`, ArrayList<ListenerHandle>())
        }
        let handle = ListenerHandle(listener)
        let array = listeners.get(`type`).getOrThrow()
        array.add(handle)
        return handle
    }

    /**
     * @brief[zh-cn] 检查是否已注册指定类型和监听器句柄
     * @param[zh-cn] type 事件类型
     * handle 监听器句柄
     * @return[zh-cn] 如果已注册则返回 true
     *
     * @brief[en] Check if a specific type and listener handle are registered
     * @param[en] type Event type
     * handle Listener handle
     * @return[en] Returns true if registered
     */
    public func hasEventListener(`type`: String, handle: ListenerHandle): Bool {
        let listeners = this._listeners
        if (!listeners.contains(`type`)) {
            return false
        }
        let array = listeners.get(`type`).getOrThrow()
        for (i in 0..array.size) {
            if (refEq(array[i], handle)) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 检查是否已注册指定类型的事件监听器（仅检查类型）
     * @param[zh-cn] type 事件类型
     * @return[zh-cn] 如果该类型有监听器则返回 true
     *
     * @brief[en] Check if event listeners are registered for the specified type (type-only check)
     * @param[en] type Event type
     * @return[en] Returns true if there are listeners for this type
     */
    public func hasEventListener(`type`: String): Bool {
        // 修复：键存在但监听器列表已空（全部移除后）时返回 false
        if (!this._listeners.contains(`type`)) {
            return false
        }
        let array = this._listeners.get(`type`).getOrThrow()
        return array.size > 0
    }

    /**
     * @brief[zh-cn] 移除事件监听器
     * @explain[zh-cn] 从指定事件类型的监听器列表中移除给定的监听器句柄。
     * @param[zh-cn] type 事件类型
     * handle 要移除的监听器句柄
     *
     * @brief[en] Remove an event listener
     * @explain[en] Removes the given listener handle from the listener list for the specified event type.
     * @param[en] type Event type
     * handle Listener handle to remove
     */
    public func removeEventListener(`type`: String, handle: ListenerHandle): Unit {
        let listeners = this._listeners
        if (!listeners.contains(`type`)) {
            return
        }
        let array = listeners.get(`type`).getOrThrow()
        var i = 0
        while (i < array.size) {
            if (refEq(array[i], handle)) {
                array.remove(i..i + 1)
                // 不递增 i，因为移除后后面的元素前移
            } else {
                i += 1
            }
        }
    }

    /**
     * @brief[zh-cn] 移除指定类型的所有事件监听器
     * @param[zh-cn] type 事件类型
     *
     * @brief[en] Remove all event listeners for the specified type
     * @param[en] type Event type
     */
    public func removeEventListener(`type`: String): Unit {
        this._listeners.remove(`type`)
    }

    /**
     * @brief[zh-cn] 分发事件
     * @explain[zh-cn] 将事件对象分发给所有注册了该事件类型的监听器。在分发期间，event.target 会被设置为 this。为防止迭代期间监听器被移除导致的问题，会先复制监听器数组再遍历。
     * @param[zh-cn] event 要分发的事件对象
     *
     * @brief[en] Dispatch an event
     * @explain[en] Dispatches the event object to all listeners registered for this event type. During dispatch, event.target is set to this. To prevent issues from listeners being removed during iteration, the listener array is copied before traversal.
     * @param[en] event Event object to dispatch
     */
    public func dispatchEvent(event: Event): Unit {
        let listeners = this._listeners
        if (!listeners.contains(event.`type`)) {
            return
        }
        let array = listeners.get(event.`type`).getOrThrow()
        // 复制数组，防止迭代期间监听器被移除
        let copied = ArrayList<ListenerHandle>()
        for (handle in array) {
            copied.add(handle)
        }
        event.target = this
        for (handle in copied) {
            handle.callback(event)
        }
        event.target = None
    }

    // ===== 兼容方法（保留 on/off/emit 接口） =====

    /**
     * @brief[zh-cn] 添加事件监听器（兼容方法，等同于 addEventListener）
     * @param[zh-cn] kind 事件类型
     * listener 监听器函数
     * @return[zh-cn] 监听器句柄
     *
     * @brief[en] Add an event listener (compatibility method, equivalent to addEventListener)
     * @param[en] kind Event type
     * listener Listener function
     * @return[en] Listener handle
     */
    public func on(kind: String, listener: (Event) -> Unit): ListenerHandle {
        return this.addEventListener(kind, listener)
    }

    /**
     * @brief[zh-cn] 移除事件监听器（兼容方法，等同于 removeEventListener）
     * @param[zh-cn] kind 事件类型
     * handle 要移除的监听器句柄
     *
     * @brief[en] Remove an event listener (compatibility method, equivalent to removeEventListener)
     * @param[en] kind Event type
     * handle Listener handle to remove
     */
    public func off(kind: String, handle: ListenerHandle): Unit {
        this.removeEventListener(kind, handle)
    }

    /**
     * @brief[zh-cn] 分发事件（兼容方法，创建 Event 对象并调用 dispatchEvent）
     * @param[zh-cn] kind 事件类型
     * event 事件对象
     *
     * @brief[en] Dispatch an event (compatibility method, creates an Event object and calls dispatchEvent)
     * @param[en] kind Event type
     * event Event object
     */
    public func emit(kind: String, event: Event): Unit {
        event.`type` = kind
        this.dispatchEvent(event)
    }
}
