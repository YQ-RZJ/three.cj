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
 * @file[zh-cn] utils_encode_md5 MD5 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.MD5 绑定为 Lua 命名空间 three.utils.encode.MD5
 * @explain[zh-cn] 纯静态工具类：compute(字符串或字节数组) → 32 位十六进制摘要；computeRaw(字节数组)
 * → 16 字节原始摘要。首参为字符串时按 UTF-8 文本摘要，为数组/表时按字节摘要。
 *
 * @file[en] utils_encode_md5  Lua binding of MD5 (three.script.prebind)
 * @brief[en] Binds three.utils.encode.MD5 as the Lua namespace three.utils.encode.MD5
 * @explain[en] Pure static utility: compute(string or byte array) -> 32-char hex digest;
 * computeRaw(byte array) -> 16-byte raw digest. A string first argument digests UTF-8 text,
 * an array/table digests bytes.
 */
package three.script.prebind

import three.utils.encode.MD5
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MD5 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.MD5）
 *
 * @brief[en] Installs the Lua binding of MD5 (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.MD5)
 */
public func installMD5(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.MD5")
    b.staticMethod("compute") { args =>
        let digest = if (args.size > 0 && args[0].isString) {
            MD5.compute(prebindStr(args, 0))
        } else {
            MD5.compute(prebindBytes(vm, args, 0))
        }
        [LuaValue.of(digest)]
    }
    b.staticMethod("computeRaw") { args =>
        [prebindBytesToLua(MD5.computeRaw(prebindBytes(vm, args, 0)))]
    }
    b.install(vm)
}
