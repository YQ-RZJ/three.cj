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
 * @file[zh-cn] network_http_networkhttp NetworkHttp / HttpClient 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.network.http.NetworkHttp / HttpClient 绑定为 Lua 类型
 * @explain[zh-cn] NetworkHttp 为静态工具：execute / get / post 均为阻塞调用，
 * 绑定层捕获底层异常并返回 nil（**不向 Lua 抛错**，避免 lua_error 的 longjmp）。
 * HttpClient 为可复用客户端：构造（connect/read/write 超时）、三个超时只读属性、
 * releasable / release、execute（阻塞，失败返回 nil）与 enqueue（异步）。
 * 线程模型：enqueue 的成功/失败回调在 httpclient4cj 的工作线程上触发，而 LuaJIT 的
 * lua_State 非线程安全，因此包装回调只把「构造返回值 + 调用 Lua 函数」整体作为任务
 * 投递到 LuaDeferredTaskQueue；由 Lua 线程调用 pumpCallbacks() 抽干执行。
 * enqueue 的两个回调必须都是函数，否则返回 false（不入队、不抛错）。
 *
 * @file[en] network_http_networkhttp  Lua bindings of NetworkHttp / HttpClient
 * (three.script.prebind)
 * @brief[en] Binds three.network.http.NetworkHttp / HttpClient as Lua types
 * @explain[en] NetworkHttp is a static utility: execute / get / post are blocking calls;
 * the binding catches underlying exceptions and returns nil (**never throws to Lua**, to avoid
 * lua_error's longjmp). HttpClient is a reusable client: construction (connect/read/write
 * timeouts), three read-only timeout properties, releasable / release, execute (blocking,
 * nil on failure) and enqueue (asynchronous).
 * Threading: enqueue's success/failure callbacks fire on httpclient4cj worker threads while
 * the LuaJIT lua_State is not thread-safe, so the wrapper only posts a task bundling
 * "build return values + invoke the Lua function" into LuaDeferredTaskQueue; the Lua thread
 * drains it via pumpCallbacks(). Both enqueue callbacks must be functions, otherwise false is
 * returned (nothing enqueued, no exception).
 */
package three.script.prebind

import three.network.http.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] HTTP 异步回调队列（进程内单例）
 * @explain[zh-cn] httpclient4cj 工作线程只投递任务，Lua 线程经 pumpCallbacks 抽干；
 * 所有 HttpClient 实例共享同一队列。
 *
 * @brief[en] The HTTP asynchronous callback queue (process-wide)
 * @explain[en] httpclient4cj worker threads only post tasks; the Lua thread drains them via
 * pumpCallbacks. Every HttpClient instance shares this queue.
 */
private let _netHttpTasks: LuaDeferredTaskQueue = LuaDeferredTaskQueue()

/**
 * @brief[zh-cn] 在 Lua 线程安全执行一条回调并释放引用
 * @param[zh-cn] cb 目标回调
 * @param[zh-cn] args 回调参数
 *
 * @brief[en] Runs one callback safely on the Lua thread and releases its reference
 * @param[en] cb The target callback
 * @param[en] args The callback arguments
 */
private func _dispatchHttpCallback(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_) {
    // 回调自身出错：跳过，不向调用方抛出
    } finally {
        cb.release()
    }
}

/**
 * @brief[zh-cn] 安装 NetworkHttp 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.http.NetworkHttp）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of NetworkHttp
 * @param[en] vm The target virtual machine (class table installed at three.network.http.NetworkHttp)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installNetworkHttp(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.http.NetworkHttp")
    // ===== 同步执行（失败返回 nil，不抛错） =====
    b.staticMethod("execute") {
        args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(NetworkHttp.execute(prebindAs<HttpRequest>(args, 0)),
                    "three.network.http.HttpResponse")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.staticMethod("get") {
        args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(NetworkHttp.get(prebindStr(args, 0), headers: httpHeadersFromLua(vm, args, 1)),
                    "three.network.http.HttpResponse")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.staticMethod("post") {
        args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(
                    NetworkHttp.post(prebindStr(args, 0), json: prebindStr(args, 1),
                        headers: httpHeadersFromLua(vm, args, 2)), "three.network.http.HttpResponse")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 HttpClient 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.http.HttpClient）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of HttpClient
 * @param[en] vm The target virtual machine (class table installed at three.network.http.HttpClient)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installHttpClient(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.http.HttpClient")
    // ===== 构造：new(connectTimeoutMs?, readTimeoutMs?, writeTimeoutMs?) =====
    b.constructor {
        args => HttpClient(connectTimeoutMs: prebindInt(args, 0, default: 10000),
            readTimeoutMs: prebindInt(args, 1, default: 10000), writeTimeoutMs: prebindInt(args, 2, default: 10000))
    }
    // ===== 只读属性 =====
    b.property("connectTimeoutMs", getter: Some({ref => LuaValue.of(ref.cast<HttpClient>().connectTimeoutMs)}))
    b.property("readTimeoutMs", getter: Some({ref => LuaValue.of(ref.cast<HttpClient>().readTimeoutMs)}))
    b.property("writeTimeoutMs", getter: Some({ref => LuaValue.of(ref.cast<HttpClient>().writeTimeoutMs)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<HttpClient>().releasable)}))
    // ===== 同步执行（失败返回 nil，不抛错） =====
    b.method("execute") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<HttpClient>().execute(prebindAs<HttpRequest>(args, 0)),
                    "three.network.http.HttpResponse")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    // ===== 异步执行（回调经任务队列回到 Lua 线程） =====
    b.method("enqueue") {
        ref, args =>
            let okCb = prebindOptCallback(vm, args, 1)
            let failCb = prebindOptCallback(vm, args, 2)
            match ((okCb, failCb)) {
                case (Some(onOk), Some(onFail)) => try {
                    ref.cast<HttpClient>().enqueue(prebindAs<HttpRequest>(args, 0), {
                        resp: HttpResponse => _netHttpTasks.post({
                            => _dispatchHttpCallback(onOk, [prebindRegister(resp, "three.network.http.HttpResponse")])
                        })
                    }, {
                        msg: String => _netHttpTasks.post({=> _dispatchHttpCallback(onFail, [LuaValue.of(msg)])})
                    })
                    [LuaValue.Boolean(true)]
                } catch (_) {
                    onOk.release()
                    onFail.release()
                    [LuaValue.Boolean(false)]
                }
                case _ => [LuaValue.Boolean(false)]
            }
    }
    // ===== 回调抽干 =====
    b.method("pumpCallbacks") {
        _, _ => [LuaValue.of(_netHttpTasks.drain())]
    }
    b.property("pendingCallbacks", getter: Some({_ => LuaValue.of(_netHttpTasks.size)}))
    // ===== 释放 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<HttpClient>().release())]
    }
    b.install(vm)
}
