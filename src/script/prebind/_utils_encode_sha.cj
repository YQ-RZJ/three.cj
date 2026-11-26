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
 * @file[zh-cn] utils_encode_sha SHA 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.SHA 绑定为 Lua 命名空间 three.utils.encode.SHA
 * @explain[zh-cn] 纯静态工具类：sha1 / sha224 / sha256 / sha384 / sha512 接收字符串（按 UTF-8 文本）
 * 或字节数组，返回十六进制摘要；对应 *Raw 方法接收字节数组，返回原始摘要字节。首参为字符串时走
 * 文本重载，为数组/表时走字节重载。
 *
 * @file[en] utils_encode_sha  Lua binding of SHA (three.script.prebind)
 * @brief[en] Binds three.utils.encode.SHA as the Lua namespace three.utils.encode.SHA
 * @explain[en] Pure static utility: sha1 / sha224 / sha256 / sha384 / sha512 accept a string
 * (UTF-8 text) or a byte array and return a hex digest; the matching *Raw methods accept a byte
 * array and return the raw digest bytes. A string first argument takes the text overload, an
 * array/table takes the byte overload.
 */
package three.script.prebind

import three.utils.encode.SHA
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SHA 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.SHA）
 *
 * @brief[en] Installs the Lua binding of SHA (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.SHA)
 */
public func installSHA(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.SHA")
    // ===== SHA-1 =====
    b.staticMethod("sha1") { args =>
        [LuaValue.of(if (args.size > 0 && args[0].isString) {
            SHA.sha1(prebindStr(args, 0))
        } else {
            SHA.sha1(prebindBytes(vm, args, 0))
        })]
    }
    b.staticMethod("sha1Raw") { args =>
        [prebindBytesToLua(SHA.sha1Raw(prebindBytes(vm, args, 0)))]
    }
    // ===== SHA-224 =====
    b.staticMethod("sha224") { args =>
        [LuaValue.of(if (args.size > 0 && args[0].isString) {
            SHA.sha224(prebindStr(args, 0))
        } else {
            SHA.sha224(prebindBytes(vm, args, 0))
        })]
    }
    // ===== SHA-256 =====
    b.staticMethod("sha256") { args =>
        [LuaValue.of(if (args.size > 0 && args[0].isString) {
            SHA.sha256(prebindStr(args, 0))
        } else {
            SHA.sha256(prebindBytes(vm, args, 0))
        })]
    }
    b.staticMethod("sha256Raw") { args =>
        [prebindBytesToLua(SHA.sha256Raw(prebindBytes(vm, args, 0)))]
    }
    // ===== SHA-384 =====
    b.staticMethod("sha384") { args =>
        [LuaValue.of(if (args.size > 0 && args[0].isString) {
            SHA.sha384(prebindStr(args, 0))
        } else {
            SHA.sha384(prebindBytes(vm, args, 0))
        })]
    }
    // ===== SHA-512 =====
    b.staticMethod("sha512") { args =>
        [LuaValue.of(if (args.size > 0 && args[0].isString) {
            SHA.sha512(prebindStr(args, 0))
        } else {
            SHA.sha512(prebindBytes(vm, args, 0))
        })]
    }
    b.staticMethod("sha512Raw") { args =>
        [prebindBytesToLua(SHA.sha512Raw(prebindBytes(vm, args, 0)))]
    }
    b.install(vm)
}
