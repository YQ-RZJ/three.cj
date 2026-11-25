/**
 * @file httpclient4cj.net URL 类型
 * @brief 提供与 stdx.encoding.url.URL 兼容的 URL 类型
 */
protected package three._vendor.httpclient4cj.net

/**
 * @brief 统一资源定位符（URL）
 * @explain 提供 URL 解析和访问功能，与 stdx.encoding.url.URL 兼容。
 */
public class URL {
    public var scheme: String = ""
    public var userInfo: String = ""
    public var hostName: String = ""
    public var port: String = ""
    public var rawPath: String = ""
    public var query: ?String = None
    public var fragment: ?String = None

    public init() {}

    /**
     * @brief 从字符串解析 URL
     * @param url 要解析的 URL 字符串
     * @return 解析后的 URL 对象
     */
    public static func parse(url: String): URL {
        let result = URL()
        if (url.isEmpty()) {
            return result
        }

        var s = url
        // 解析 scheme
        let schemeEnd = url.indexOf("://")
        if (schemeEnd.isSome()) {
            let idx = schemeEnd.getOrThrow({=> Exception("")})
            result.scheme = s[0..idx]
            s = s[idx + 3..]
        }

        // 解析 fragment
        let fragIdx = s.indexOf("#")
        if (fragIdx.isSome()) {
            let fi = fragIdx.getOrThrow({=> Exception("")})
            result.fragment = Some(s[fi + 1..])
            s = s[0..fi]
        }

        // 解析 query
        let queryIdx = s.indexOf("?")
        if (queryIdx.isSome()) {
            let qi = queryIdx.getOrThrow({=> Exception("")})
            result.query = Some(s[qi + 1..])
            s = s[0..qi]
        }

        // 解析 authority 和 path
        let pathIdx = s.indexOf("/")
        var authority = s
        if (pathIdx.isSome()) {
            let pi = pathIdx.getOrThrow({=> Exception("")})
            authority = s[0..pi]
            result.rawPath = s[pi..]
        } else {
            result.rawPath = "/"
        }

        // 解析 userInfo@host:port
        let atIdx = authority.indexOf("@")
        if (atIdx.isSome()) {
            let ai = atIdx.getOrThrow({=> Exception("")})
            result.userInfo = authority[0..ai]
            authority = authority[ai + 1..]
        }

        // 解析 IPv6 地址 [::1]
        if (authority.startsWith("[")) {
            let closeBracket = authority.indexOf("]")
            if (closeBracket.isSome()) {
                let ci = closeBracket.getOrThrow({=> Exception("")})
                result.hostName = authority[0..ci + 1]
                let portStr = authority[ci + 1..]
                if (portStr.startsWith(":")) {
                    result.port = portStr[1..]
                }
            }
        } else {
            // 解析 host:port
            let colonIdx = authority.lastIndexOf(":")
            if (colonIdx.isSome()) {
                let ci = colonIdx.getOrThrow({=> Exception("")})
                if (ci > 0) {
                    result.hostName = authority[0..ci]
                    result.port = authority[ci + 1..]
                } else {
                    result.hostName = authority
                }
            } else {
                result.hostName = authority
            }
        }

        return result
    }

    /**
     * @brief 返回 URL 的字符串表示
     * @return URL 字符串
     */
    public func toString(): String {
        var result = ""
        if (!scheme.isEmpty()) {
            result += scheme + "://"
        }
        if (!userInfo.isEmpty()) {
            result += userInfo + "@"
        }
        if (!hostName.isEmpty()) {
            result += hostName
        }
        if (!port.isEmpty()) {
            result += ":" + port
        }
        if (!rawPath.isEmpty()) {
            result += rawPath
        } else {
            result += "/"
        }
        if (query.isSome()) {
            result += "?" + query.getOrThrow({=> Exception("")})
        }
        if (fragment.isSome()) {
            result += "#" + fragment.getOrThrow({=> Exception("")})
        }
        return result
    }

    public func hashCode(): Int64 {
        return toString().hashCode()
    }
}