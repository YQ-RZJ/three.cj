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
 * @file[zh-cn] HttpResponse HTTP 响应封装（three.network.http 子包）
 * @brief[zh-cn] 包装 httpclient4cj.Response 的核心信息：状态码 / 消息 / 头部 / 正文
 * @explain[zh-cn] 提供 String 与字节两种正文访问方式。
 *
 * @file[en] HttpResponse  HTTP response wrapper (three.network.http sub-package)
 * @brief[en] Wraps the core information of an httpclient4cj.Response: status code /
 * message / headers / body
 * @explain[en] Provides both String and byte access to the response body.
 */
package three.network.http

/**
 * @brief[zh-cn] HTTP 响应
 * @explain[zh-cn] 携带状态码、状态消息、响应头部与可选正文，并提供便捷的访问属性与方法。
 *
 * @brief[en] HTTP response
 * @explain[en] Carries the status code, status message, response headers and optional body,
 * with convenient accessors.
 */
public class HttpResponse {
    /**
     * @brief[zh-cn] 状态码（200/404/500 等）
     *
     * @brief[en] Status code (e.g. 200/404/500)
     */
    public let code: Int64

    /**
     * @brief[zh-cn] 状态消息（如 "OK"）
     *
     * @brief[en] Status message (e.g. "OK")
     */
    public let message: String

    /**
     * @brief[zh-cn] 响应头部（name, value 键值对）
     *
     * @brief[en] Response headers as (name, value) pairs
     */
    public let headers: Array<(String, String)>

    /**
     * @brief[zh-cn] 正文（文本形式；二进制时为空）
     *
     * @brief[en] Body as text (empty when the body is binary)
     */
    public let body: Option<String>

    /**
     * @brief[zh-cn] 构造响应
     * @param[zh-cn] code 状态码
     * message 状态消息
     * headers 响应头部（可选）
     * body 正文（可选）
     *
     * @brief[en] Constructs a response
     * @param[en] code Status code
     * message Status message
     * headers Response headers (optional)
     * body Response body (optional)
     */
    public init(code: Int64,
                message: String,
                headers!: Array<(String, String)> = [],
                body!: Option<String> = None) {
        this.code = code
        this.message = message
        this.headers = headers
        this.body = body
    }

    /**
     * @brief[zh-cn] 是否成功（2xx）
     * @return[zh-cn] 状态码位于 [200, 300) 区间时返回 true
     *
     * @brief[en] Whether the response is successful (2xx)
     * @return[en] Returns true when the status code is in [200, 300)
     */
    public prop isSuccess: Bool {
        get() { this.code >= 200 && this.code < 300 }
    }

    /**
     * @brief[zh-cn] 是否重定向（3xx）
     * @return[zh-cn] 状态码位于 [300, 400) 区间时返回 true
     *
     * @brief[en] Whether the response is a redirect (3xx)
     * @return[en] Returns true when the status code is in [300, 400)
     */
    public prop isRedirect: Bool {
        get() { this.code >= 300 && this.code < 400 }
    }

    /**
     * @brief[zh-cn] 获取正文文本
     * @return[zh-cn] 返回正文文本；空正文返回空串
     *
     * @brief[en] Returns the body as text
     * @return[en] Returns the body text, or an empty string when the body is empty
     */
    public func bodyString(): String {
        match (this.body) {
            case Some(s) => s
            case None => ""
        }
    }

    /**
     * @brief[zh-cn] 按名称获取响应头
     * @param[zh-cn] name 头部名称
     * @return[zh-cn] 返回匹配的头部值；不存在返回 None
     *
     * @brief[en] Looks up a response header by name
     * @param[en] name Header name
     * @return[en] Returns the matching header value, or None when absent
     */
    public func header(name: String): Option<String> {
        for ((n, v) in this.headers) {
            if (n == name) {
                return Some(v)
            }
        }
        return None
    }

    /**
     * @brief[zh-cn] 响应内容类型（Content-Type 头的值）
     * @return[zh-cn] 返回 Content-Type 头的值；缺失时返回空串
     *
     * @brief[en] Response content type (value of the Content-Type header)
     * @return[en] Returns the Content-Type header value, or an empty string when absent
     */
    public prop contentType: String {
        get() {
            match (this.header("Content-Type")) {
                case Some(v) => v
                case None => ""
            }
        }
    }
}
