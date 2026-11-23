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
 * @file[zh-cn] network_http_httprequest HttpRequest 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.http.HttpRequest 绑定为 Lua 类型 three.network.http.HttpRequest
 * @explain[zh-cn] 覆盖构造（url / method / headers / body）与静态工厂 get / post / put / delete，
 * 以及 url / method / headers / body 四个只读属性。
 * headers 在 Lua 侧表示为「数组的表」：`{{name, value}, {name, value}, ...}`；
 * body 为 Option<String>，Lua 侧传字符串表示有正文，传 nil / 省略表示无正文。
 * 本文件同时提供 http 子包共用的头部双向转换工具（internal）。
 *
 * @file[en] network_http_httprequest  Lua binding of HttpRequest (three.script.prebind)
 * @brief[en] Binds three.network.http.HttpRequest as the Lua type
 * three.network.http.HttpRequest
 * @explain[en] Covers construction (url / method / headers / body), the static factories
 * get / post / put / delete and the four read-only properties url / method / headers / body.
 * Headers appear on the Lua side as a table of pairs: `{{name, value}, {name, value}, ...}`;
 * body is Option<String>, where a string means a body exists and nil / omitted means none.
 * This file also provides the internal header conversion helpers shared by the http bindings.
 */
package three.script.prebind

import three.network.http.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将头部键值对数组转为 Lua 数组（元素为 {name, value} 二元数组）
 * @param[zh-cn] hs 头部键值对数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts header pairs into a Lua array (each element is a {name, value} pair)
 * @param[en] hs The header pairs
 * @return[en] The Lua array value
 */
internal func httpHeadersToLua(hs: Array<(String, String)>): LuaValue {
    var out = Array<LuaValue>(hs.size, {_ => LuaValue.Nil})
    var i: Int64 = 0
    for ((name, value) in hs) {
        out[i] = LuaValue.Array([LuaValue.of(name), LuaValue.of(value)])
        i += 1
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 从 Lua 参数读取头部键值对数组（元素须为 {name, value} 数组或表）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 头部键值对数组（参数缺失 / 非数组时返回空）
 *
 * @brief[en] Reads header pairs from a Lua argument (each element must be a {name, value}
 * array or table)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The header pairs (empty when the argument is absent or not an array)
 */
internal func httpHeadersFromLua(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<(String, String)> {
    let elems = prebindArray(vm, args, idx)
    var out = Array<(String, String)>(elems.size, {_ => ("", "")})
    var i: Int64 = 0
    for (elem in elems) {
        let pair = prebindArray(vm, [elem], 0)
        let name = if (pair.size > 0) {
            pair[0].stringValue()
        } else {
            ""
        }
        let value = if (pair.size > 1) {
            pair[1].stringValue()
        } else {
            ""
        }
        out[i] = (name, value)
        i += 1
    }
    return out
}

/**
 * @brief[zh-cn] 从 Lua 参数读取可选字符串（省略或 nil → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(字符串) 或 None
 *
 * @brief[en] Reads an optional string argument (absent or nil → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(string) or None
 */
internal func httpOptStringFromLua(args: Array<LuaValue>, idx: Int64): Option<String> {
    if (args.size <= idx || args[idx].isNil) {
        return None
    }
    return Some(args[idx].stringValue())
}

/**
 * @brief[zh-cn] 安装 HttpRequest 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.http.HttpRequest）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of HttpRequest
 * @param[en] vm The target virtual machine (class table installed at three.network.http.HttpRequest)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installHttpRequest(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.http.HttpRequest")
    // ===== 构造：new(url, method?, headers?, body?) =====
    b.constructor {
        args => HttpRequest(prebindStr(args, 0), method: prebindStr(args, 1, default: "GET"),
            headers: httpHeadersFromLua(vm, args, 2), body: httpOptStringFromLua(args, 3))
    }
    // ===== 只读属性 =====
    b.property("url", getter: Some({ref => LuaValue.of(ref.cast<HttpRequest>().url)}))
    b.property("method", getter: Some({ref => LuaValue.of(ref.cast<HttpRequest>().method)}))
    b.property("headers", getter: Some({ref => httpHeadersToLua(ref.cast<HttpRequest>().headers)}))
    b.property("body", getter: Some({
        ref => match (ref.cast<HttpRequest>().body) {
            case Some(s) => LuaValue.of(s)
            case None => LuaValue.Nil
        }
    }))
    // ===== 静态工厂 =====
    b.staticMethod("get") {
        args => [prebindRegister(HttpRequest.get(prebindStr(args, 0), headers: httpHeadersFromLua(vm, args, 1)),
            "three.network.http.HttpRequest")]
    }
    b.staticMethod("post") {
        args => [prebindRegister(
            HttpRequest.post(prebindStr(args, 0), json: prebindStr(args, 1), headers: httpHeadersFromLua(vm, args, 2)),
            "three.network.http.HttpRequest")]
    }
    b.staticMethod("put") {
        args => [prebindRegister(
            HttpRequest.put(prebindStr(args, 0), body: httpOptStringFromLua(args, 1),
                headers: httpHeadersFromLua(vm, args, 2)), "three.network.http.HttpRequest")]
    }
    b.staticMethod("delete") {
        args => [prebindRegister(HttpRequest.delete(prebindStr(args, 0), headers: httpHeadersFromLua(vm, args, 1)),
            "three.network.http.HttpRequest")]
    }
    b.install(vm)
}
