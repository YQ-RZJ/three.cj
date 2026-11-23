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
 * @file[zh-cn] network_transport_connection Connection 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.transport.Connection 绑定为 Lua 类型
 * three.network.transport.Connection
 * @explain[zh-cn] 覆盖构造（host / port）、host / port / isConnected / releasable 只读属性、
 * 心跳与重连四个可读写配置（heartbeatIntervalMs / heartbeatTimeoutMs / autoReconnect /
 * maxReconnectDelayMs）、connect / send / sendString / update / release，以及
 * onMessage / onConnected / onDisconnected 三个回调和帧常量（FRAME_PING / FRAME_PONG /
 * FRAME_DATA / MAX_FRAME_SIZE）。
 * 线程模型适配：引擎的 onMessage 在收包线程触发，而 LuaJIT 的 lua_State 非线程安全，
 * 因此绑定层把「构造字节数组 + 调用 Lua 函数」封装为任务投递到共享的
 * LuaDeferredTaskQueue（process-wide），由 Lua 线程在 update() 中抽干执行——即 onMessage
 * 实际在调用 update 的 Lua 线程上回调，且顺序与到达顺序一致。onConnected /
 * onDisconnected 本就在主循环 update 内触发，但同样走队列以保持统一顺序。
 * 回调属性只写（读取恒为 nil）；替换回调不会主动释放旧 Lua 函数引用，引用随 VM 关闭回收。
 *
 * @file[en] network_transport_connection  Lua binding of Connection (three.script.prebind)
 * @brief[en] Binds three.network.transport.Connection as the Lua type
 * three.network.transport.Connection
 * @explain[en] Covers construction (host / port), the read-only host / port / isConnected /
 * releasable properties, the four mutable heartbeat/reconnect settings
 * (heartbeatIntervalMs / heartbeatTimeoutMs / autoReconnect / maxReconnectDelayMs),
 * connect / send / sendString / update / release, the onMessage / onConnected /
 * onDisconnected callbacks and the frame constants (FRAME_PING / FRAME_PONG / FRAME_DATA /
 * MAX_FRAME_SIZE).
 * Threading adaptation: the engine fires onMessage on the receive thread while the LuaJIT
 * lua_State is not thread-safe, so the binding posts a task bundling "build the byte array +
 * invoke the Lua function" into a shared LuaDeferredTaskQueue (process-wide); the Lua thread
 * drains it inside update(), meaning onMessage actually fires on the Lua thread calling
 * update(), in arrival order. onConnected / onDisconnected already fire inside the main-loop
 * update but also go through the queue for a consistent ordering.
 * Callback properties are write-only (reads always return nil); replacing a callback does not
 * release the old Lua function reference, which is reclaimed when the VM shuts down.
 */
package three.script.prebind

import three.network.transport.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 网络传输层的共享回调任务队列（进程内单例）
 * @explain[zh-cn] Connection / ReliableChannel 的收包线程都向此队列投递，
 * 由任一 update()（或 Connection.pumpCallbacks）在 Lua 线程抽干。
 *
 * @brief[en] The shared transport callback task queue (process-wide)
 * @explain[en] Receive threads of Connection / ReliableChannel post here; any update()
 * (or Connection.pumpCallbacks) drains it on the Lua thread.
 */
internal let _netTransportTasks: LuaDeferredTaskQueue = LuaDeferredTaskQueue()

/**
 * @brief[zh-cn] 在 Lua 线程安全执行一条传输层回调
 * @param[zh-cn] cb 目标回调
 * @param[zh-cn] args 回调参数
 *
 * @brief[en] Runs one transport callback safely on the Lua thread
 * @param[en] cb The target callback
 * @param[en] args The callback arguments
 */
internal func _callTransportCallback(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_) {
        // 回调自身出错：跳过，不向调用方抛出
    }
}

/**
 * @brief[zh-cn] 安装 Connection 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.transport.Connection）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Connection
 * @param[en] vm The target virtual machine (class table installed at three.network.transport.Connection)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installConnection(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.transport.Connection")
    // ===== 帧常量 =====
    b.staticMethod("FRAME_PING") {_ => [LuaValue.of(Int64(FRAME_PING))]}
    b.staticMethod("FRAME_PONG") {_ => [LuaValue.of(Int64(FRAME_PONG))]}
    b.staticMethod("FRAME_DATA") {_ => [LuaValue.of(Int64(FRAME_DATA))]}
    b.staticMethod("MAX_FRAME_SIZE") {_ => [LuaValue.of(MAX_FRAME_SIZE)]}
    // ===== 构造：new(host, port) =====
    b.constructor {
        args => Connection(prebindStr(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF))
    }
    // ===== 只读属性 =====
    b.property("host", getter: Some({ref => LuaValue.of(ref.cast<Connection>().host)}))
    b.property("port", getter: Some({ref => LuaValue.of(Int64(ref.cast<Connection>().port))}))
    b.property("isConnected", getter: Some({ref => LuaValue.of(ref.cast<Connection>().isConnected)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<Connection>().releasable)}))
    // ===== 心跳 / 重连配置 =====
    b.property("heartbeatIntervalMs", getter: Some({ref => LuaValue.of(ref.cast<Connection>().heartbeatIntervalMs)}),
        setter: Some({ref, v => ref.cast<Connection>().heartbeatIntervalMs = v.numberValue()}))
    b.property("heartbeatTimeoutMs", getter: Some({ref => LuaValue.of(ref.cast<Connection>().heartbeatTimeoutMs)}),
        setter: Some({ref, v => ref.cast<Connection>().heartbeatTimeoutMs = v.numberValue()}))
    b.property("autoReconnect", getter: Some({ref => LuaValue.of(ref.cast<Connection>().autoReconnect)}),
        setter: Some({ref, v => ref.cast<Connection>().autoReconnect = v.boolValue()}))
    b.property("maxReconnectDelayMs", getter: Some({ref => LuaValue.of(ref.cast<Connection>().maxReconnectDelayMs)}),
        setter: Some({ref, v => ref.cast<Connection>().maxReconnectDelayMs = v.numberValue()}))
    // ===== 事件回调（只写；收包线程经任务队列转投 Lua 线程） =====
    b.property(
        "onMessage",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let conn = ref.cast<Connection>()
                    if (let Some(cb) <- prebindOptCallbackOf(vm, v)) {
                        conn.onMessage = Some({
                            data: Array<UInt8> => _netTransportTasks.post(
                                {=> _callTransportCallback(cb, [prebindBytesToLua(data)])})
                        })
                    } else {
                        conn.onMessage = None
                    }
            }
        )
    )
    b.property(
        "onConnected",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let conn = ref.cast<Connection>()
                    if (let Some(cb) <- prebindOptCallbackOf(vm, v)) {
                        conn.onConnected = Some({
                            => _netTransportTasks.post({=> _callTransportCallback(cb, Array<LuaValue>())})
                        })
                    } else {
                        conn.onConnected = None
                    }
            }
        )
    )
    b.property(
        "onDisconnected",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let conn = ref.cast<Connection>()
                    if (let Some(cb) <- prebindOptCallbackOf(vm, v)) {
                        conn.onDisconnected = Some({
                            reason: String => _netTransportTasks.post(
                                {=> _callTransportCallback(cb, [LuaValue.of(reason)])})
                        })
                    } else {
                        conn.onDisconnected = None
                    }
            }
        )
    )
    // ===== 连接 / 发送 =====
    b.method("connect") {
        ref, _ => [LuaValue.of(ref.cast<Connection>().connect())]
    }
    b.method("send") {
        ref, args => [LuaValue.of(ref.cast<Connection>().send(prebindBytes(vm, args, 0)))]
    }
    b.method("sendString") {
        ref, args => [LuaValue.of(ref.cast<Connection>().sendString(prebindStr(args, 0)))]
    }
    // ===== 主循环驱动（同时抽干回调队列，返回执行条数） =====
    b.method("update") {
        ref, _ =>
            ref.cast<Connection>().update()
            [LuaValue.of(_netTransportTasks.drain())]
    }
    b.method("pumpCallbacks") {
        _, _ => [LuaValue.of(_netTransportTasks.drain())]
    }
    b.property("pendingCallbacks", getter: Some({_ => LuaValue.of(_netTransportTasks.size)}))
    // ===== 关闭 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Connection>().release())]
    }
    b.install(vm)
}
