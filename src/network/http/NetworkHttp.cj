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
 * @file[zh-cn] NetworkHttp HTTP 客户端高级封装（three.network.http 子包）
 * @brief[zh-cn] 基于 httpclient4cj（OkHttp 风格完整 HTTP 客户端）提供 three 风格的 HTTP 封装
 * @explain[zh-cn] 能力覆盖：
 * - GET / POST / PUT / DELETE / HEAD / PATCH
 * - 自定义头部、JSON/文本正文
 * - 连接/读取/写入超时配置
 * - 同步 execute() 与异步 enqueue()（回调）
 * - 响应状态码/头部/正文访问
 * 用法示例：
 * // 一次性请求（内部创建默认客户端）
 * let resp = NetworkHttp.execute(HttpRequest.get("https://api.example.com/x"))
 * // 带超时/复用客户端
 * let client = HttpClient(connectTimeoutMs: 3000, readTimeoutMs: 5000)
 * let resp = client.execute(HttpRequest.post(url: "https://...", json: "{\"a\":1}"))
 * // 异步回调
 * client.enqueue(req) { r -> Logger.info(["NetworkHttp", r.bodyString()]) }  // 成功
 * { e -> Logger.error(["NetworkHttp", "失败: " + e]) }    // 失败
 *
 * @file[en] NetworkHttp  High-level HTTP client wrapper (three.network.http sub-package)
 * @brief[en] Provides three-style HTTP wrappers built on httpclient4cj
 * (an OkHttp-style full HTTP client)
 * @explain[en] Feature coverage:
 * - GET / POST / PUT / DELETE / HEAD / PATCH
 * - Custom headers, JSON/text bodies
 * - Connect/read/write timeout configuration
 * - Synchronous execute() and asynchronous enqueue() (callbacks)
 * - Access to response status code/headers/body
 * Usage:
 * // one-shot request (creates a default client internally)
 * let resp = NetworkHttp.execute(HttpRequest.get("https://api.example.com/x"))
 * // client with timeouts and reuse
 * let client = HttpClient(connectTimeoutMs: 3000, readTimeoutMs: 5000)
 * let resp = client.execute(HttpRequest.post(url: "https://...", json: "{\"a\":1}"))
 * // asynchronous callback
 * client.enqueue(req) { r -> Logger.info(["NetworkHttp", r.bodyString()]) }  // success
 * { e -> Logger.error(["NetworkHttp", "failure: " + e]) }   // failure
 *
 * @see[zh-cn] https://gitcode.com/raozj/httpclient4cj
 *
 * @see[en] https://gitcode.com/raozj/httpclient4cj
 */
package three.network.http

import httpclient4cj.Request
import httpclient4cj.Response
import httpclient4cj.Call
import httpclient4cj.Callback
import httpclient4cj.RequestBody
import httpclient4cj.RealRequestBody
import httpclient4cj.MediaType
import httpclient4cj.HttpClient as TpcHttpClient
import std.collection.*
import std.time.*

// =============================================================================
// NetworkHttp：HTTP 客户端静态工具
// =============================================================================

/**
 * @brief[zh-cn] HTTP 客户端静态工具
 * @explain[zh-cn] 提供一次性便捷请求，内部创建默认客户端并执行。
 *
 * @brief[en] Static HTTP client utilities
 * @explain[en] Provides one-shot convenience requests by creating a default client internally.
 */
public class NetworkHttp {

    /**
     * @brief[zh-cn] 执行一次 HTTP 请求（同步，默认 10s 超时）
     * @param[zh-cn] req 请求描述
     * @return[zh-cn] 返回 HTTP 响应
     *
     * @brief[en] Executes an HTTP request synchronously (10s default timeout)
     * @param[en] req The request description
     * @return[en] Returns the HTTP response
     */
    public static func execute(req: HttpRequest): HttpResponse {
        let client = HttpClient()
        return client.execute(req)
    }

    /**
     * @brief[zh-cn] 便捷 GET（同步）
     * @param[zh-cn] url 请求 URL
     * headers 请求头部（可选）
     * @return[zh-cn] 返回 HTTP 响应
     *
     * @brief[en] Convenience GET (synchronous)
     * @param[en] url Request URL
     * headers Request headers (optional)
     * @return[en] Returns the HTTP response
     */
    public static func get(url: String,
                           headers!: Array<(String, String)> = []): HttpResponse {
        return NetworkHttp.execute(HttpRequest.get(url, headers: headers))
    }

    /**
     * @brief[zh-cn] 便捷 POST JSON（同步）
     * @param[zh-cn] url 请求 URL
     * json JSON 正文（默认空）
     * headers 请求头部（可选）
     * @return[zh-cn] 返回 HTTP 响应
     *
     * @brief[en] Convenience POST with JSON body (synchronous)
     * @param[en] url Request URL
     * json JSON body (empty by default)
     * headers Request headers (optional)
     * @return[en] Returns the HTTP response
     */
    public static func post(url: String,
                            json!: String = "",
                            headers!: Array<(String, String)> = []): HttpResponse {
        return NetworkHttp.execute(HttpRequest.post(url, json: json, headers: headers))
    }

    // =========================================================================
    // 内部转换工具（供 HttpClient 使用）
    // =========================================================================

    /**
     * @brief[zh-cn] 将 HttpRequest 转换为 httpclient4cj.Request
     * @param[zh-cn] req 请求描述
     * @return[zh-cn] 转换后的底层请求对象
     *
     * @brief[en] Convert HttpRequest to httpclient4cj.Request
     * @param[en] req The request description
     * @return[en] The converted underlying request object
     */
    internal static func toUnderlying(req: HttpRequest): Request {
        var builder = Request.builder().url(req.url)
        for ((name, value) in req.headers) {
            builder = builder.header(name, [value])
        }
        match (req.body) {
            case Some(b) =>
                match (req.method) {
                    case "POST" =>
                        let body = RealRequestBody.create(
                            Option<MediaType>.Some(MediaType.get("application/json; charset=utf-8")), b)
                        builder = builder.post(body)
                    case "PUT" =>
                        let body = RealRequestBody.create(
                            Option<MediaType>.Some(MediaType.get("application/json; charset=utf-8")), b)
                        builder = builder.put(body)
                    case "PATCH" =>
                        let body = RealRequestBody.create(
                            Option<MediaType>.Some(MediaType.get("application/json; charset=utf-8")), b)
                        builder = builder.patch(body)
                    case "DELETE" =>
                        let body = RealRequestBody.create(
                            Option<MediaType>.Some(MediaType.get("application/json; charset=utf-8")), b)
                        builder = builder.delete(Option<RequestBody>.Some(body))
                    case _ => ()
                }
            case None => ()
        }
        return builder.build()
    }

    /**
     * @brief[zh-cn] 将 httpclient4cj.Response 转换为 HttpResponse
     * @param[zh-cn] resp 底层响应对象
     * @return[zh-cn] 转换后的 HttpResponse
     *
     * @brief[en] Convert httpclient4cj.Response to HttpResponse
     * @param[en] resp The underlying response object
     * @return[en] The converted HttpResponse
     */
    internal static func fromUnderlying(resp: Response): HttpResponse {
        let code = resp.getCode()
        let message = resp.getMessage()
        // 头部（Header 实现 Iterable<(String, ArrayList<String>)>）
        let hdrs = resp.getHeaders()
        let hs = ArrayList<(String, String)>()
        for ((name, values) in hdrs) {
            for (v in values) {
                hs.add((name, v))
            }
        }
        // 正文
        var body: Option<String> = None
        let b = resp.getBody()
        match (b) {
            case Some(rb) => body = Some(rb.getString())
            case None => ()
        }
        var arr = Array<(String, String)>(hs.size, { _ => ("", "") })
        for (i in 0..hs.size) {
            arr[Int64(i)] = hs[i]
        }
        return HttpResponse(code, message, headers: arr, body: body)
    }

    /**
     * @brief[zh-cn] 构造 httpclient4cj.Callback（异步回调适配）
     * @param[zh-cn] onSuccess 成功回调：(HttpResponse) -> Unit
     * @param[zh-cn] onFailure 失败回调：(String) -> Unit
     * @return[zh-cn] 返回底层回调适配对象
     *
     * @brief[en] Construct httpclient4cj.Callback (async callback adapter)
     * @param[en] onSuccess Success callback: (HttpResponse) -> Unit
     * @param[en] onFailure Failure callback: (String) -> Unit
     * @return[en] Returns the underlying callback adapter object
     */
    internal static func makeCallback(onSuccess: (HttpResponse) -> Unit,
                                      onFailure: (String) -> Unit): Callback {
        return HttpClientCallback(onSuccess, onFailure)
    }
}

// =============================================================================
// HttpClient：可配置 HTTP 客户端
// =============================================================================

/**
 * @brief[zh-cn] 可配置 HTTP 客户端
 * @explain[zh-cn] 可复用客户端，支持连接/读取/写入超时配置，提供同步 execute 与异步 enqueue 执行。
 *
 * @brief[en] Configurable HTTP client
 * @explain[en] A reusable client with configurable connect/read/write timeouts,
 * offering synchronous execute and asynchronous enqueue.
 */
public class HttpClient {
    /**
     * @brief[zh-cn] 底层 httpclient4cj 客户端
     *
     * @brief[en] Underlying httpclient4cj client
     */
    private var _inner: TpcHttpClient

    /**
     * @brief[zh-cn] 连接超时（毫秒）
     *
     * @brief[en] Connect timeout in milliseconds
     */
    public let connectTimeoutMs: Int64

    /**
     * @brief[zh-cn] 读取超时（毫秒）
     *
     * @brief[en] Read timeout in milliseconds
     */
    public let readTimeoutMs: Int64

    /**
     * @brief[zh-cn] 写入超时（毫秒）
     *
     * @brief[en] Write timeout in milliseconds
     */
    public let writeTimeoutMs: Int64

    /**
     * @brief[zh-cn] 构造客户端
     * @param[zh-cn] connectTimeoutMs 连接超时（毫秒，默认 10000）
     * readTimeoutMs 读取超时（毫秒，默认 10000）
     * writeTimeoutMs 写入超时（毫秒，默认 10000）
     *
     * @brief[en] Constructs a client
     * @param[en] connectTimeoutMs Connect timeout in milliseconds (default 10000)
     * readTimeoutMs Read timeout in milliseconds (default 10000)
     * writeTimeoutMs Write timeout in milliseconds (default 10000)
     */
    public init(connectTimeoutMs!: Int64 = 10000,
                readTimeoutMs!: Int64 = 10000,
                writeTimeoutMs!: Int64 = 10000) {
        this.connectTimeoutMs = connectTimeoutMs
        this.readTimeoutMs = readTimeoutMs
        this.writeTimeoutMs = writeTimeoutMs
        let builder = TpcHttpClient.builder()
            .connectTimeout(Duration.millisecond * connectTimeoutMs)
            .readTimeout(Duration.millisecond * readTimeoutMs)
            .writeTimeout(Duration.millisecond * writeTimeoutMs)
        this._inner = builder.build()
    }

    /**
     * @brief[zh-cn] 执行请求（同步）
     * @param[zh-cn] req 请求描述
     * @return[zh-cn] 返回 HTTP 响应
     *
     * @brief[en] Executes a request synchronously
     * @param[en] req The request description
     * @return[en] Returns the HTTP response
     */
    public func execute(req: HttpRequest): HttpResponse {
        let call = this._inner.newCall(NetworkHttp.toUnderlying(req))
        let resp = call.execute()
        return NetworkHttp.fromUnderlying(resp)
    }

    /**
     * @brief[zh-cn] 执行请求（异步回调）
     * @param[zh-cn] req 请求描述
     * onSuccess 成功回调：(HttpResponse) -> Unit
     * onFailure 失败回调：(String) -> Unit
     *
     * @brief[en] Executes a request asynchronously via callbacks
     * @param[en] req The request description
     * onSuccess Success callback: (HttpResponse) -> Unit
     * onFailure Failure callback: (String) -> Unit
     */
    public func enqueue(req: HttpRequest,
                        onSuccess: (HttpResponse) -> Unit,
                        onFailure: (String) -> Unit): Unit {
        let call = this._inner.newCall(NetworkHttp.toUnderlying(req))
        call.enqueue(NetworkHttp.makeCallback(onSuccess, onFailure))
    }

    /**
     * @brief[zh-cn] 关闭客户端（释放连接池等资源）
     *
     * @brief[en] Closes the client (releases resources such as the connection pool)
     *
     * @note[zh-cn] httpclient4cj 未暴露显式 close，连接池随 GC 回收。
     * @note[en] httpclient4cj does not expose an explicit close; the connection pool
     * is reclaimed by GC.
     */
    public func close(): Unit {
        // httpclient4cj 未暴露显式 close，连接池随 GC 回收
    }
}

// =============================================================================
// HttpClientCallback：httpclient4cj.Callback 适配实现
// =============================================================================

/**
 * @brief[zh-cn] 内部回调适配：把 httpclient4cj 回调转成仓颉闭包
 *
 * @brief[en] Internal callback adapter: converts httpclient4cj callbacks to Cangjie closures
 */
class HttpClientCallback <: Callback {
    /**
     * @brief[zh-cn] 成功回调
     *
     * @brief[en] Success callback
     */
    private let _onSuccess: (HttpResponse) -> Unit

    /**
     * @brief[zh-cn] 失败回调
     *
     * @brief[en] Failure callback
     */
    private let _onFailure: (String) -> Unit

    /**
     * @brief[zh-cn] 构造回调适配
     * @param[zh-cn] onSuccess 成功回调
     * @param[zh-cn] onFailure 失败回调
     *
     * @brief[en] Constructs callback adapter
     * @param[en] onSuccess Success callback
     * @param[en] onFailure Failure callback
     */
    init(onSuccess: (HttpResponse) -> Unit, onFailure: (String) -> Unit) {
        this._onSuccess = onSuccess
        this._onFailure = onFailure
    }

    /**
     * @brief[zh-cn] 请求失败回调
     * @param[zh-cn] call 底层调用对象
     * @param[zh-cn] e 异常
     *
     * @brief[en] Request failure callback
     * @param[en] call Underlying call object
     * @param[en] e Exception
     */
    public func onFailure(call: Call, e: Exception): Unit {
        this._onFailure(e.toString())
    }

    /**
     * @brief[zh-cn] 请求成功回调
     * @param[zh-cn] call 底层调用对象
     * @param[zh-cn] response 底层响应对象
     *
     * @brief[en] Request success callback
     * @param[en] call Underlying call object
     * @param[en] response Underlying response object
     */
    public func onResponse(call: Call, response: Response): Unit {
        let r = NetworkHttp.fromUnderlying(response)
        this._onSuccess(r)
    }
}
