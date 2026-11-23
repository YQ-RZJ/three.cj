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
 * @file[zh-cn] network_socket_socketudp SocketUdp 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.socket.SocketUdp 绑定为 Lua 类型 three.network.socket.SocketUdp
 * @explain[zh-cn] 覆盖构造（bindPort）、isBound / releasable 只读属性、bind 两种重载
 * （bind() 使用构造端口，bind(port) 指定端口）、sendTo / sendString 发送、
 * receive 阻塞接收（返回「远端地址, 字节数组」两个值）、release 关闭。
 * 收发数据在 Lua 侧均为数值数组（元素 0~255）。
 *
 * @file[en] network_socket_socketudp  Lua binding of SocketUdp (three.script.prebind)
 * @brief[en] Binds three.network.socket.SocketUdp as the Lua type
 * three.network.socket.SocketUdp
 * @explain[en] Covers construction (bindPort), the read-only isBound / releasable
 * properties, the two bind overloads (bind() uses the constructor port, bind(port) binds an
 * explicit port), sendTo / sendString sending, the blocking receive (returning
 * "remote address, byte array" as two values) and release.
 * Both sent and received data are Lua number arrays (0~255) on the Lua side.
 */
package three.script.prebind

import three.network.socket.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SocketUdp 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.socket.SocketUdp）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SocketUdp
 * @param[en] vm The target virtual machine (class table installed at three.network.socket.SocketUdp)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSocketUdp(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.socket.SocketUdp")
    // ===== 构造：new(bindPort?) =====
    b.constructor {
        args => SocketUdp(bindPort: UInt16(prebindInt(args, 0, default: 0) & 0xFFFF))
    }
    // ===== 只读属性 =====
    b.property("isBound", getter: Some({ref => LuaValue.of(ref.cast<SocketUdp>().isBound)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SocketUdp>().releasable)}))
    // ===== 绑定端口（0/1 参数两种重载） =====
    b.method("bind") {
        ref, args => if (args.size >= 1) {
            [LuaValue.of(ref.cast<SocketUdp>().bind(UInt16(prebindInt(args, 0) & 0xFFFF)))]
        } else {
            [LuaValue.of(ref.cast<SocketUdp>().bind())]
        }
    }
    // ===== 发送 =====
    b.method("sendTo") {
        ref, args => [LuaValue.of(
            ref.cast<SocketUdp>().sendTo(prebindStr(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
                prebindBytes(vm, args, 2)))]
    }
    b.method("sendString") {
        ref, args => [LuaValue.of(
            ref.cast<SocketUdp>().sendString(prebindStr(args, 0), UInt16(prebindInt(args, 1) & 0xFFFF),
                prebindStr(args, 2)))]
    }
    // ===== 接收（阻塞，返回 远端地址 + 字节数组） =====
    b.method("receive") {
        ref, _ =>
            let (from, data) = ref.cast<SocketUdp>().receive()
            [LuaValue.of(from), prebindBytesToLua(data)]
    }
    // ===== 关闭 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<SocketUdp>().release())]
    }
    b.install(vm)
}
