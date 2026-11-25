/**
 * @file httpclient4cj.net Cookie 类型
 * @brief 提供与 stdx.net.http.Cookie 兼容的 Cookie 类型
 */
protected package three._vendor.httpclient4cj.net

internal import std.time.DateTime

/**
 * @brief 表示一个 HTTP Cookie
 */
public class Cookie {
    public var cookieName: String = ""
    public var cookieValue: String = ""
    public var expires: ?DateTime = None
    public var maxAge: ?Int64 = None
    public var domain: String = ""
    public var path: String = ""
    public var secure: Bool = false
    public var httpOnly: Bool = false
    public var others: HashMap<String, String> = HashMap<String, String>()

    public init() {}

    public init(
        name: String,
        value: String,
        expires!: ?DateTime = None,
        maxAge!: ?Int64 = None,
        domain!: String = "",
        path!: String = "",
        secure!: Bool = false,
        httpOnly!: Bool = false
    ) {
        this.cookieName = name
        this.cookieValue = value
        this.expires = expires
        this.maxAge = maxAge
        this.domain = domain
        this.path = path
        this.secure = secure
        this.httpOnly = httpOnly
    }
}