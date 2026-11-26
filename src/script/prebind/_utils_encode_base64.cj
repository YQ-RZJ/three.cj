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
 * @file[zh-cn] utils_encode_base64 Base64 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.Base64 绑定为 Lua 命名空间 three.utils.encode.Base64
 * @explain[zh-cn] 纯静态工具类：encode(字节数组) → Base64 字符串；decode(字符串) → 字节数组。
 * 字节数组按 Lua 数值数组（0~255）往返，供脚本侧与引擎编解码能力复用。
 *
 * @file[en] utils_encode_base64  Lua binding of Base64 (three.script.prebind)
 * @brief[en] Binds three.utils.encode.Base64 as the Lua namespace three.utils.encode.Base64
 * @explain[en] Pure static utility: encode(byte array) -> Base64 string; decode(string) -> byte
 * array. Byte arrays round-trip as Lua number arrays (0..255) so scripts reuse the engine's
 * codec capabilities.
 */
package three.script.prebind

import three.utils.encode.Base64
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Base64 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.Base64）
 *
 * @brief[en] Installs the Lua binding of Base64 (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.Base64)
 */
public func installBase64(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.Base64")
    b.staticMethod("encode") { args =>
        [LuaValue.of(Base64.encode(prebindBytes(vm, args, 0)))]
    }
    b.staticMethod("decode") { args =>
        [prebindBytesToLua(Base64.decode(prebindStr(args, 0)))]
    }
    b.install(vm)
}
