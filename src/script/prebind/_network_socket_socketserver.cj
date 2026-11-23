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
 * @file[zh-cn] network_socket_socketserver SocketServer 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.socket.SocketServer 绑定为 Lua 类型
 * three.network.socket.SocketServer
 * @explain[zh-cn] 覆盖构造（port）、port / isBound / releasable 只读属性、
 * bind（同步绑定端口）、accept（阻塞接受一个客户端，返回 SocketClient 对象或 nil）、
 * release（关闭服务端）。
 *
 * @file[en] network_socket_socketserver  Lua binding of SocketServer (three.script.prebind)
 * @brief[en] Binds three.network.socket.SocketServer as the Lua type
 * three.network.socket.SocketServer
 * @explain[en] Covers construction (port), the read-only port / isBound / releasable
 * properties, bind (synchronous port binding), accept (blocking acceptance returning a
 * SocketClient object or nil) and release (shuts the server down).
 */
package three.script.prebind

import three.network.socket.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SocketServer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.socket.SocketServer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SocketServer
 * @param[en] vm The target virtual machine (class table installed at three.network.socket.SocketServer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSocketServer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.socket.SocketServer")
    // ===== 构造：new(port) =====
    b.constructor {
        args => SocketServer(UInt16(prebindInt(args, 0) & 0xFFFF))
    }
    // ===== 只读属性 =====
    b.property("port", getter: Some({ref => LuaValue.of(Int64(ref.cast<SocketServer>().port))}))
    b.property("isBound", getter: Some({ref => LuaValue.of(ref.cast<SocketServer>().isBound)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SocketServer>().releasable)}))
    // ===== 绑定端口 =====
    b.method("bind") {
        ref, _ => [LuaValue.of(ref.cast<SocketServer>().bind())]
    }
    // ===== 接受连接（阻塞） =====
    b.method("accept") {
        ref, _ => match (ref.cast<SocketServer>().accept()) {
            case Some(client) => [prebindRegister(client, "three.network.socket.SocketClient")]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 关闭 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<SocketServer>().release())]
    }
    b.install(vm)
}
