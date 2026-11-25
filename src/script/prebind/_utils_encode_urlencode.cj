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
 * @file[zh-cn] utils_encode_urlencode UrlEncode 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.utils.encode.UrlEncode 绑定为 Lua 命名空间 three.utils.encode.UrlEncode
 * @explain[zh-cn] 纯静态工具类：encodeQuery(二维键值表) → 查询串；decodeQuery(查询串) → 二维键值表
 * （每项为 { key, value } 的 Lua 数组）；percentEncode / percentDecode 处理单值百分号编码。
 *
 * @file[en] utils_encode_urlencode  Lua binding of UrlEncode (three.script.prebind)
 * @brief[en] Binds three.utils.encode.UrlEncode as the Lua namespace three.utils.encode.UrlEncode
 * @explain[en] Pure static utility: encodeQuery(2-D key/value table) -> query string;
 * decodeQuery(query string) -> 2-D table (each item is a Lua array { key, value });
 * percentEncode / percentDecode handle single-value percent encoding.
 */
package three.script.prebind

import three.utils.encode.UrlEncode
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 键值对数组转 Lua 二维表
 * @param[zh-cn] pairs 键值对数组
 * @return[zh-cn] Lua 数组（元素为 { key, value }）
 *
 * @brief[en] Converts a pair array into a 2-D Lua table
 * @param[en] pairs The pair array
 * @return[en] Lua array whose items are { key, value }
 */
internal func _utilsEncodePairsToLua(pairs: Array<(String, String)>): LuaValue {
    let n = pairs.size
    var out = Array<LuaValue>(n, { _ => LuaValue.Nil })
    for (i in 0..n) {
        let (k, v) = pairs[i]
        out[i] = LuaValue.Array([LuaValue.of(k), LuaValue.of(v)])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] Lua 二维表转键值对数组
 * @param[zh-cn] vm 目标虚拟机（读取 Lua 表需要）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 键值对数组（缺省项按空串处理）
 *
 * @brief[en] Converts a 2-D Lua table into a pair array
 * @param[en] vm The target virtual machine (needed to read Lua tables)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The pair array (missing entries become empty strings)
 */
internal func _utilsEncodePairsArg(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<(String, String)> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<(String, String)>(n, { _ => ("", "") })
    for (i in 0..n) {
        let pair = prebindArray(vm, [elems[i]], 0)
        let k = if (pair.size > 0) { pair[0].stringValue() } else { "" }
        let v = if (pair.size > 1) { pair[1].stringValue() } else { "" }
        out[i] = (k, v)
    }
    return out
}

/**
 * @brief[zh-cn] 安装 UrlEncode 的 Lua 绑定（纯静态类，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.utils.encode.UrlEncode）
 *
 * @brief[en] Installs the Lua binding of UrlEncode (a pure static class; no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.utils.encode.UrlEncode)
 */
public func installUrlEncode(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.utils.encode.UrlEncode")
    b.staticMethod("encodeQuery") { args =>
        [LuaValue.of(UrlEncode.encodeQuery(_utilsEncodePairsArg(vm, args, 0)))]
    }
    b.staticMethod("decodeQuery") { args =>
        [_utilsEncodePairsToLua(UrlEncode.decodeQuery(prebindStr(args, 0)))]
    }
    b.staticMethod("percentEncode") { args =>
        [LuaValue.of(UrlEncode.percentEncode(prebindStr(args, 0)))]
    }
    b.staticMethod("percentDecode") { args =>
        [LuaValue.of(UrlEncode.percentDecode(prebindStr(args, 0)))]
    }
    b.install(vm)
}
