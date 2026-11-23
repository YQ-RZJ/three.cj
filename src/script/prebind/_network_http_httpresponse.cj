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
 * @file[zh-cn] network_http_httpresponse HttpResponse 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.http.HttpResponse 绑定为 Lua 类型 three.network.http.HttpResponse
 * @explain[zh-cn] 覆盖构造（code / message / headers / body）、只读属性
 * code / message / headers / body / isSuccess / isRedirect / contentType，以及
 * bodyString / header 方法。headers 的 Lua 表示与 HttpRequest 一致（{name, value} 二元数组
 * 的数组）；body 缺失时属性为 nil，bodyString() 返回空串。
 *
 * @file[en] network_http_httpresponse  Lua binding of HttpResponse (three.script.prebind)
 * @brief[en] Binds three.network.http.HttpResponse as the Lua type
 * three.network.http.HttpResponse
 * @explain[en] Covers construction (code / message / headers / body), the read-only
 * properties code / message / headers / body / isSuccess / isRedirect / contentType, and
 * the bodyString / header methods. Headers use the same Lua representation as HttpRequest
 * (an array of {name, value} pairs); a missing body is nil and bodyString() returns "".
 */
package three.script.prebind

import three.network.http.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 HttpResponse 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.http.HttpResponse）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of HttpResponse
 * @param[en] vm The target virtual machine (class table installed at three.network.http.HttpResponse)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installHttpResponse(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.http.HttpResponse")
    // ===== 构造：new(code, message, headers?, body?) =====
    b.constructor {
        args => HttpResponse(prebindInt(args, 0), prebindStr(args, 1), headers: httpHeadersFromLua(vm, args, 2),
            body: httpOptStringFromLua(args, 3))
    }
    // ===== 只读属性 =====
    b.property("code", getter: Some({ref => LuaValue.of(ref.cast<HttpResponse>().code)}))
    b.property("message", getter: Some({ref => LuaValue.of(ref.cast<HttpResponse>().message)}))
    b.property("headers", getter: Some({ref => httpHeadersToLua(ref.cast<HttpResponse>().headers)}))
    b.property("body", getter: Some({
        ref => match (ref.cast<HttpResponse>().body) {
            case Some(s) => LuaValue.of(s)
            case None => LuaValue.Nil
        }
    }))
    b.property("isSuccess", getter: Some({ref => LuaValue.of(ref.cast<HttpResponse>().isSuccess)}))
    b.property("isRedirect", getter: Some({ref => LuaValue.of(ref.cast<HttpResponse>().isRedirect)}))
    b.property("contentType", getter: Some({ref => LuaValue.of(ref.cast<HttpResponse>().contentType)}))
    // ===== 方法 =====
    b.method("bodyString") {
        ref, _ => [LuaValue.of(ref.cast<HttpResponse>().bodyString())]
    }
    b.method("header") {
        ref, args => match (ref.cast<HttpResponse>().header(prebindStr(args, 0))) {
            case Some(v) => [LuaValue.of(v)]
            case None => [LuaValue.Nil]
        }
    }
    b.install(vm)
}
