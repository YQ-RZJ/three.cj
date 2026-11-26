/**
 * @file httpclient4cj.net CookieJar 类型
 * @brief 提供与 stdx.net.http.CookieJar 兼容的 CookieJar 接口和实现
 */
protected package three._vendor.httpclient4cj.net

internal import std.collection.ArrayList
internal import std.collection.HashMap

/**
 * @brief HTTP Cookie 存储接口
 * @explain 与 stdx.net.http.CookieJar 兼容的接口
 */
public interface CookieJar {
    /**
     * @brief 保存从响应中接收的 Cookie
     * @param url 请求 URL
     * @param cookies 要保存的 Cookie 数组
     */
    func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit

    /**
     * @brief 为请求加载 Cookie
     * @param url 请求 URL
     * @return 匹配的 Cookie 数组
     */
    func loadForRequest(url: URL): Array<Cookie>
}

/**
 * @brief HTTP Cookie 存储实现
 * @explain 提供与 stdx.net.http.CookieJar 类兼容的实现。
 *         在 stdx 中，CookieJar 既是接口也是类（有静态方法），
 *         这里提供 HttpCookieJar 作为实现类。
 */
public class HttpCookieJar <: CookieJar {
    private let cookies: HashMap<String, ArrayList<Cookie>> = HashMap<String, ArrayList<Cookie>>()

    private init() {}

    /**
     * @brief 创建默认的 CookieJar 实例
     * @param initialCookies 初始 Cookie 列表
     * @param useInMemory 是否使用内存存储
     * @return HttpCookieJar 实例
     */
    public static func createDefaultCookieJar(initialCookies: ArrayList<Cookie>, useInMemory: Bool): HttpCookieJar {
        let jar = HttpCookieJar()
        for (c in initialCookies) {
            jar.storeCookie(c)
        }
        return jar
    }

    /**
     * @brief 存储 Cookie
     * @param url 关联的 URL
     * @param cookies 要存储的 Cookie 列表
     */
    public func storeCookies(url: URL, cookies: ArrayList<Cookie>): Unit {
        for (c in cookies) {
            storeCookie(c)
        }
    }

    /**
     * @brief 获取与 URL 匹配的 Cookie
     * @param url 请求 URL
     * @return 匹配的 Cookie 列表
     */
    public func getCookies(url: URL): ArrayList<Cookie> {
        let result = ArrayList<Cookie>()
        for ((domain, jarCookies) in cookies) {
            if (domainMatches(url.hostName, domain)) {
                for (c in jarCookies) {
                    result.add(c)
                }
            }
        }
        return result
    }

    /**
     * @brief 保存从响应中接收的 Cookie
     * @param url 请求 URL
     * @param cookies 要保存的 Cookie 数组
     */
    public func saveFromResponse(url: URL, cookies: Array<Cookie>): Unit {
        for (c in cookies) {
            storeCookie(c)
        }
    }

    /**
     * @brief 为请求加载 Cookie
     * @param url 请求 URL
     * @return 匹配的 Cookie 数组
     */
    public func loadForRequest(url: URL): Array<Cookie> {
        return getCookies(url).toArray()
    }

    private func storeCookie(cookie: Cookie): Unit {
        let domain = if (!cookie.domain.isEmpty()) {
            cookie.domain
        } else {
            ""
        }
        let key = domain
        let list = cookies.get(key) ?? ArrayList<Cookie>()
        // 替换同名的 Cookie
        var found = false
        for (i in 0..list.size) {
            if (list[i].cookieName == cookie.cookieName) {
                list[i] = cookie
                found = true
                break
            }
        }
        if (!found) {
            list.add(cookie)
        }
        cookies.add(key, list)
    }

    private func domainMatches(host: String, domain: String): Bool {
        if (domain.isEmpty()) {
            return true
        }
        if (host == domain) {
            return true
        }
        if (host.endsWith(domain) && host[host.size - domain.size - 1] == b'.') {
            return true
        }
        return false
    }
}