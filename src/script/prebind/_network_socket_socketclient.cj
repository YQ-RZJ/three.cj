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
 * @file[zh-cn] network_socket_socketclient SocketClient 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.socket.SocketClient 绑定为 Lua 类型
 * three.network.socket.SocketClient
 * @explain[zh-cn] ISocketListener 为接口（按约定不绑定），改由内部适配器
 * _LuaSocketListener 承接：Lua 侧把一个含 onOpen / onMessage / onError / onClose
 * 四个函数字段的表赋给 client.listener，适配器在引擎回调时转调对应 Lua 函数。
 * 回调均在调用 connect / read / release 的线程（即 Lua 线程）触发，可直接执行；
 * 若回调自身出错则静默跳过（不向引擎抛出，避免绑定层 longjmp）。
 * 绑定内容：构造（host / port）、host / port / isConnected / releasable 只读属性、
 * connect / write / writeString / read / readBytes / readString / release，listener 属性
 * （只写；读取恒为 nil，因为接口实例无法映射为 Lua 值）。
 * read(buf) 的 buf 在 Lua 侧为数值数组，绑定层复制一份传给引擎，因此脚本无法看到
 * 引擎回填的内容；需要数据请使用 listener.onMessage 或 readBytes / readString。
 * readBytes(maxBytes?) 为绑定层便利方法：内部分配缓冲、调用 read 并返回读到的字节数组。
 *
 * @file[en] network_socket_socketclient  Lua binding of SocketClient (three.script.prebind)
 * @brief[en] Binds three.network.socket.SocketClient as the Lua type
 * three.network.socket.SocketClient
 * @explain[en] ISocketListener is an interface (not bound by convention), replaced by the
 * internal adapter _LuaSocketListener: Lua assigns a table with the four function fields
 * onOpen / onMessage / onError / onClose to client.listener, and the adapter forwards engine
 * callbacks to the matching Lua functions. Callbacks fire on the thread calling
 * connect / read / release (the Lua thread), so they run directly; a failing callback is
 * silently skipped (never thrown into the engine, avoiding a binding-layer longjmp).
 * Bound: construction (host / port), the read-only host / port / isConnected / releasable
 * properties, connect / write / writeString / read / readBytes / readString / release, and the
 * listener property (write-only; reads always return nil since interface instances have no Lua
 * mapping). For read(buf), buf is a Lua number array copied by the binding, so scripts cannot
 * observe the data written by the engine; use listener.onMessage or readBytes / readString
 * instead. readBytes(maxBytes?) is a binding-level convenience that allocates a buffer, calls
 * read and returns the bytes actually received.
 */
package three.script.prebind

import three.network.socket.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 在 Lua 线程安全执行一条 socket 回调
 * @param[zh-cn] cb 目标回调
 * @param[zh-cn] args 回调参数
 *
 * @brief[en] Runs one socket callback safely on the Lua thread
 * @param[en] cb The target callback
 * @param[en] args The callback arguments
 */
private func _callSocketCallback(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_) {
        // 回调自身出错：跳过，不向引擎抛出
    }
}

/**
 * @brief[zh-cn] ISocketListener 的 Lua 函数适配器
 * @explain[zh-cn] 把四个事件转发到 Lua 函数；四个字段均可缺省（缺省即忽略该事件）。
 * 与引擎的连接期一致，回调参数中的 client 会重新登记为 Lua 对象后传入。
 *
 * @brief[en] Lua-function adapter for ISocketListener
 * @explain[en] Forwards the four events to Lua functions; every field is optional (a missing
 * field ignores that event). As with the engine lifecycle, the client argument is re-registered
 * as a Lua object before being passed in.
 */
class _LuaSocketListener <: ISocketListener {
    private let _onOpen: Option<LuaCallback>
    private let _onMessage: Option<LuaCallback>
    private let _onError: Option<LuaCallback>
    private let _onClose: Option<LuaCallback>

    init(onOpen: Option<LuaCallback>, onMessage: Option<LuaCallback>, onError: Option<LuaCallback>,
        onClose: Option<LuaCallback>) {
        this._onOpen = onOpen
        this._onMessage = onMessage
        this._onError = onError
        this._onClose = onClose
    }

    /// 释放四个回调的注册表引用（幂等）
    func releaseCallbacks(): Unit {
        if (let Some(cb) <- this._onOpen) {
            cb.release()
        }
        if (let Some(cb) <- this._onMessage) {
            cb.release()
        }
        if (let Some(cb) <- this._onError) {
            cb.release()
        }
        if (let Some(cb) <- this._onClose) {
            cb.release()
        }
    }

    public func onOpen(client: ISocketClient): Unit {
        if (let Some(cb) <- this._onOpen) {
            _callSocketCallback(cb,
                [LuaValue.Object(LuaObjectRegistry.register(client, "three.network.socket.SocketClient"))])
        }
    }

    public func onMessage(client: ISocketClient, data: Array<UInt8>): Unit {
        if (let Some(cb) <- this._onMessage) {
            _callSocketCallback(
                cb,
                [
                    LuaValue.Object(LuaObjectRegistry.register(client, "three.network.socket.SocketClient")),
                    prebindBytesToLua(data)
                ]
            )
        }
    }

    public func onError(client: ISocketClient, message: String): Unit {
        if (let Some(cb) <- this._onError) {
            _callSocketCallback(
                cb,
                [
                    LuaValue.Object(LuaObjectRegistry.register(client, "three.network.socket.SocketClient")),
                    LuaValue.of(message)
                ]
            )
        }
    }

    public func onClose(client: ISocketClient): Unit {
        if (let Some(cb) <- this._onClose) {
            _callSocketCallback(cb,
                [LuaValue.Object(LuaObjectRegistry.register(client, "three.network.socket.SocketClient"))])
        }
    }
}

/**
 * @brief[zh-cn] 安装 SocketClient 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.socket.SocketClient）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SocketClient
 * @param[en] vm The target virtual machine (class table installed at three.network.socket.SocketClient)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSocketClient(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.socket.SocketClient")
    // ===== 构造：new(host, port) =====
    b.constructor {
        args => SocketClient(prebindStr(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF))
    }
    // ===== 只读属性 =====
    b.property("host", getter: Some({ref => LuaValue.of(ref.cast<SocketClient>().host)}))
    b.property("port", getter: Some({ref => LuaValue.of(Int64(ref.cast<SocketClient>().port))}))
    b.property("isConnected", getter: Some({ref => LuaValue.of(ref.cast<SocketClient>().isConnected)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SocketClient>().releasable)}))
    // ===== 事件监听（只写：接口实例无 Lua 映射） =====
    b.property(
        "listener",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let client = ref.cast<SocketClient>()
                    // 先释放旧适配器持有的 Lua 函数引用
                    if (let Some(old) <- client.listener) {
                        if (let Some(prev) <- (old as _LuaSocketListener)) {
                            prev.releaseCallbacks()
                        }
                    }
                    if (v.isTable) {
                        let t = LuaTable(vm: vm, ref: Int32(v.refId()))
                        client.listener = Some(
                            _LuaSocketListener(prebindOptCallbackOf(vm, t.get("onOpen")),
                                prebindOptCallbackOf(vm, t.get("onMessage")), prebindOptCallbackOf(vm, t.get("onError")),
                                prebindOptCallbackOf(vm, t.get("onClose"))))
                    } else {
                        client.listener = None
                    }
            }
        )
    )
    // ===== 连接 =====
    b.method("connect") {
        ref, _ => [LuaValue.of(ref.cast<SocketClient>().connect())]
    }
    // ===== 发送 =====
    b.method("write") {
        ref, args => [LuaValue.of(ref.cast<SocketClient>().write(prebindBytes(vm, args, 0)))]
    }
    b.method("writeString") {
        ref, args => [LuaValue.of(ref.cast<SocketClient>().writeString(prebindStr(args, 0)))]
    }
    // ===== 接收（阻塞） =====
    b.method("read") {
        ref, args =>
            let buf = prebindBytes(vm, args, 0)
            var n: Int64 = -1
            try {
                n = ref.cast<SocketClient>().read(buf)
            } catch (_) {
                n = -1
            }
            [LuaValue.of(n)]
    }
    b.method("readBytes") {
        ref, args =>
            let maxBytes = prebindInt(args, 0, default: 4096)
            if (maxBytes <= 0) {
                [prebindBytesToLua(Array<UInt8>())]
            } else {
                let buf = Array<UInt8>(maxBytes, {_ => 0u8})
                var n: Int64 = -1
                try {
                    n = ref.cast<SocketClient>().read(buf)
                } catch (_) {
                    n = -1
                }
                if (n <= 0) {
                    [prebindBytesToLua(Array<UInt8>())]
                } else {
                    var out = Array<UInt8>(n, {_ => 0u8})
                    for (i in 0..n) {
                        out[i] = buf[i]
                    }
                    [prebindBytesToLua(out)]
                }
            }
    }
    b.method("readString") {
        ref, _ =>
            var out = ""
            try {
                out = ref.cast<SocketClient>().readString()
            } catch (_) {
                out = ""
            }
            [LuaValue.of(out)]
    }
    // ===== 关闭 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<SocketClient>().release())]
    }
    b.install(vm)
}
