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
 * @file[zh-cn] HttpRequest HTTP 请求描述（three.network.http 子包）
 * @brief[zh-cn] 描述一次 HTTP 请求的纯数据封装：URL / 方法 / 头部 / 正文
 * @explain[zh-cn] 纯数据封装，供 NetworkHttp 执行。内部经 httpclient4cj.Request 转换，
 * 上层无需接触底层 API。
 *
 * @file[en] HttpRequest  HTTP request description (three.network.http sub-package)
 * @brief[en] Pure-data encapsulation describing an HTTP request: URL / method / headers / body
 * @explain[en] A pure-data encapsulation executed by NetworkHttp. Internally converted to an
 * httpclient4cj.Request, so callers never touch the underlying API.
 *
 * @note[zh-cn] 可通过静态工厂 get/post/put/delete 快速构造常见请求。
 * @note[en] Use the static factories get/post/put/delete to build common requests quickly.
 */
package three.network.http

/**
 * @brief[zh-cn] HTTP 请求描述
 * @explain[zh-cn] 携带 URL、方法、头部与可选正文，供 NetworkHttp 执行。
 *
 * @brief[en] HTTP request description
 * @explain[en] Carries the URL, method, headers and optional body for NetworkHttp to execute.
 */
public class HttpRequest {
    /**
     * @brief[zh-cn] 请求 URL
     *
     * @brief[en] Request URL
     */
    public let url: String

    /**
     * @brief[zh-cn] HTTP 方法（GET/POST/PUT/DELETE/HEAD/PATCH）
     *
     * @brief[en] HTTP method (GET/POST/PUT/DELETE/HEAD/PATCH)
     */
    public let method: String

    /**
     * @brief[zh-cn] 请求头部（name, value 键值对）
     *
     * @brief[en] Request headers as (name, value) pairs
     */
    public let headers: Array<(String, String)>

    /**
     * @brief[zh-cn] 请求正文（可选，GET 通常为空）
     *
     * @brief[en] Optional request body (usually empty for GET)
     */
    public let body: Option<String>

    /**
     * @brief[zh-cn] 构造请求
     * @param[zh-cn] url 请求 URL
     * method HTTP 方法（默认 GET）
     * headers 请求头部（可选）
     * body 请求正文（可选）
     *
     * @brief[en] Constructs a request
     * @param[en] url Request URL
     * method HTTP method (defaults to GET)
     * headers Request headers (optional)
     * body Request body (optional)
     */
    public init(url: String,
                method!: String = "GET",
                headers!: Array<(String, String)> = [],
                body!: Option<String> = None) {
        this.url = url
        this.method = method
        this.headers = headers
        this.body = body
    }

    /**
     * @brief[zh-cn] 便捷构造：GET 请求
     * @param[zh-cn] url 请求 URL
     * headers 请求头部（可选）
     * @return[zh-cn] 返回构造好的 GET 请求
     *
     * @brief[en] Convenience factory for a GET request
     * @param[en] url Request URL
     * headers Request headers (optional)
     * @return[en] Returns the constructed GET request
     */
    public static func get(url: String,
                           headers!: Array<(String, String)> = []): HttpRequest {
        return HttpRequest(url, method: "GET", headers: headers, body: None)
    }

    /**
     * @brief[zh-cn] 便捷构造：POST 请求（JSON 正文）
     * @param[zh-cn] url 请求 URL
     * json JSON 正文（默认空；为空时不再附加正文）
     * headers 请求头部（可选，未指定时自动添加 JSON Content-Type）
     * @return[zh-cn] 返回构造好的 POST 请求
     *
     * @brief[en] Convenience factory for a POST request with a JSON body
     * @param[en] url Request URL
     * json JSON body (empty by default; empty means no body attached)
     * headers Request headers (optional; a JSON Content-Type is added when omitted)
     * @return[en] Returns the constructed POST request
     */
    public static func post(url: String,
                            json!: String = "",
                            headers!: Array<(String, String)> = []): HttpRequest {
        let hs = if (json != "" && headers.size == 0) {
            [("Content-Type", "application/json; charset=utf-8")]
        } else {
            headers
        }
        return HttpRequest(url, method: "POST", headers: hs,
            body: if (json == "") { None } else { Some(json) })
    }

    /**
     * @brief[zh-cn] 便捷构造：PUT 请求
     * @param[zh-cn] url 请求 URL
     * body 请求正文（可选）
     * headers 请求头部（可选）
     * @return[zh-cn] 返回构造好的 PUT 请求
     *
     * @brief[en] Convenience factory for a PUT request
     * @param[en] url Request URL
     * body Request body (optional)
     * headers Request headers (optional)
     * @return[en] Returns the constructed PUT request
     */
    public static func put(url: String,
                           body!: Option<String> = None,
                           headers!: Array<(String, String)> = []): HttpRequest {
        return HttpRequest(url, method: "PUT", headers: headers, body: body)
    }

    /**
     * @brief[zh-cn] 便捷构造：DELETE 请求
     * @param[zh-cn] url 请求 URL
     * headers 请求头部（可选）
     * @return[zh-cn] 返回构造好的 DELETE 请求
     *
     * @brief[en] Convenience factory for a DELETE request
     * @param[en] url Request URL
     * headers Request headers (optional)
     * @return[en] Returns the constructed DELETE request
     */
    public static func delete(url: String,
                              headers!: Array<(String, String)> = []): HttpRequest {
        return HttpRequest(url, method: "DELETE", headers: headers, body: None)
    }
}
