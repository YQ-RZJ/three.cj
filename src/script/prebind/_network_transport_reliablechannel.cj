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
 * @file[zh-cn] network_transport_reliablechannel ReliableChannel 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.network.transport.ReliableChannel 绑定为 Lua 类型
 * three.network.transport.ReliableChannel
 * @explain[zh-cn] 覆盖构造（remoteHost / remotePort / bindPort）、remoteHost / remotePort /
 * rttMs / pendingCount / releasable 只读属性、resendDelayMs / maxResendDelayMs 可读写配置、
 * bind / send / update / release，以及 onMessage 回调与包头常量
 * （RELIABLE_HEADER_SIZE / RELIABLE_ACK_SEQ / RELIABLE_MAX_PAYLOAD）。
 * onMessage 由引擎在主循环 update() 内按序下发给「按序投递队列」，因此回调仍在 Lua 线程；
 * 绑定层只做异常隔离（回调出错静默跳过），并额外抽干共享传输任务队列以保持与
 * Connection 的统一调度。update() 返回本次抽干的任务条数。
 *
 * @file[en] network_transport_reliablechannel  Lua binding of ReliableChannel
 * (three.script.prebind)
 * @brief[en] Binds three.network.transport.ReliableChannel as the Lua type
 * three.network.transport.ReliableChannel
 * @explain[en] Covers construction (remoteHost / remotePort / bindPort), the read-only
 * remoteHost / remotePort / rttMs / pendingCount / releasable properties, the mutable
 * resendDelayMs / maxResendDelayMs settings, bind / send / update / release, the onMessage
 * callback and the header constants (RELIABLE_HEADER_SIZE / RELIABLE_ACK_SEQ /
 * RELIABLE_MAX_PAYLOAD).
 * The engine dispatches onMessage in order from the main-loop update(), so the callback already
 * runs on the Lua thread; the binding only isolates exceptions (a failing callback is silently
 * skipped) and additionally drains the shared transport task queue for uniform scheduling with
 * Connection. update() returns the number of drained tasks.
 */
package three.script.prebind

import three.network.transport.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ReliableChannel 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.transport.ReliableChannel）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ReliableChannel
 * @param[en] vm The target virtual machine (class table installed at
 * three.network.transport.ReliableChannel)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installReliableChannel(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.transport.ReliableChannel")
    // ===== 包头常量 =====
    b.staticMethod("RELIABLE_HEADER_SIZE") {_ => [LuaValue.of(RELIABLE_HEADER_SIZE)]}
    b.staticMethod("RELIABLE_ACK_SEQ") {_ => [LuaValue.of(Float64(RELIABLE_ACK_SEQ))]}
    b.staticMethod("RELIABLE_MAX_PAYLOAD") {_ => [LuaValue.of(RELIABLE_MAX_PAYLOAD)]}
    // ===== 构造：new(remoteHost, remotePort, bindPort?) =====
    b.constructor {
        args => ReliableChannel(prebindStr(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
            bindPort: UInt16(prebindInt(args, 2, default: 0) & 0xFFFF))
    }
    // ===== 只读属性 =====
    b.property("remoteHost", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().remoteHost)}))
    b.property("remotePort", getter: Some({ref => LuaValue.of(Int64(ref.cast<ReliableChannel>().remotePort))}))
    b.property("rttMs", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().rttMs)}))
    b.property("pendingCount", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().pendingCount)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().releasable)}))
    // ===== 重发配置 =====
    b.property("resendDelayMs", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().resendDelayMs)}),
        setter: Some({ref, v => ref.cast<ReliableChannel>().resendDelayMs = v.numberValue()}))
    b.property("maxResendDelayMs", getter: Some({ref => LuaValue.of(ref.cast<ReliableChannel>().maxResendDelayMs)}),
        setter: Some({ref, v => ref.cast<ReliableChannel>().maxResendDelayMs = v.numberValue()}))
    // ===== 数据到达回调（只写） =====
    b.property(
        "onMessage",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let chan = ref.cast<ReliableChannel>()
                    if (let Some(cb) <- prebindOptCallbackOf(vm, v)) {
                        chan.onMessage = Some({
                            data: Array<UInt8> => _callTransportCallback(cb, [prebindBytesToLua(data)])
                        })
                    } else {
                        chan.onMessage = None
                    }
            }
        )
    )
    // ===== 绑定 / 发送 =====
    b.method("bind") {
        ref, _ => [LuaValue.of(ref.cast<ReliableChannel>().bind())]
    }
    b.method("send") {
        ref, args => [LuaValue.of(ref.cast<ReliableChannel>().send(prebindBytes(vm, args, 0)))]
    }
    // ===== 主循环驱动（重发 + 派发，并抽干共享队列） =====
    b.method("update") {
        ref, _ =>
            ref.cast<ReliableChannel>().update()
            [LuaValue.of(_netTransportTasks.drain())]
    }
    // ===== 关闭 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<ReliableChannel>().release())]
    }
    b.install(vm)
}
