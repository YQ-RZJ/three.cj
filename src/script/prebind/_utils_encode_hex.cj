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
 * @file[zh-cn] utils_encode_hex Hex 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.Hex 绑定为 Lua 命名空间 three.utils.encode.Hex
 * @explain[zh-cn] 纯静态工具类：encode(字节数组) → 十六进制字符串；decode(字符串) → 字节数组。
 *
 * @file[en] utils_encode_hex  Lua binding of Hex (three.script.prebind)
 * @brief[en] Binds three.utils.encode.Hex as the Lua namespace three.utils.encode.Hex
 * @explain[en] Pure static utility: encode(byte array) -> hex string; decode(string) -> byte array.
 */
package three.script.prebind

import three.utils.encode.Hex
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Hex 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.Hex）
 *
 * @brief[en] Installs the Lua binding of Hex (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.Hex)
 */
public func installHex(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.Hex")
    b.staticMethod("encode") { args =>
        [LuaValue.of(Hex.encode(prebindBytes(vm, args, 0)))]
    }
    b.staticMethod("decode") { args =>
        [prebindBytesToLua(Hex.decode(prebindStr(args, 0)))]
    }
    b.install(vm)
}
