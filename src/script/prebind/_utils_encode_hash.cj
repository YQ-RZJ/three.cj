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
 * @file[zh-cn] utils_encode_hash Hash 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.Hash 绑定为 Lua 命名空间 three.utils.encode.Hash
 * @explain[zh-cn] 纯静态工具类：fnv1a32(字节数组) → Int64 哈希；murmurHash32(字节数组[, seed]) →
 * Int64 哈希。返回值按 Lua 数值呈现（Lua 双精度可精确表示 53 位以内的整数）。
 *
 * @file[en] utils_encode_hash  Lua binding of Hash (three.script.prebind)
 * @brief[en] Binds three.utils.encode.Hash as the Lua namespace three.utils.encode.Hash
 * @explain[en] Pure static utility: fnv1a32(byte array) -> Int64 hash; murmurHash32(byte
 * array[, seed]) -> Int64 hash. Results surface as Lua numbers (doubles exactly represent
 * integers up to 53 bits).
 */
package three.script.prebind

import three.utils.encode.Hash
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Hash 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.Hash）
 *
 * @brief[en] Installs the Lua binding of Hash (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.utils.encode.Hash)
 */
public func installHash(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.Hash")
    b.staticMethod("fnv1a32") { args =>
        [LuaValue.of(Hash.fnv1a32(prebindBytes(vm, args, 0)))]
    }
    b.staticMethod("murmurHash32") { args =>
        [LuaValue.of(Hash.murmurHash32(prebindBytes(vm, args, 0),
            seed: UInt32(prebindInt(args, 1, default: 1102) & 0xFFFFFFFF)))]
    }
    b.install(vm)
}
