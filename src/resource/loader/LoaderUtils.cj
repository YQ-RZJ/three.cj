/**
 * @file[zh-cn] LoaderUtils 加载器工具类
 * @brief[zh-cn] 加载器辅助工具类，提供 URL 解析等静态方法
 * @explain[zh-cn] 提供 extractUrlBase 和 resolveURL 两个静态方法，用于从 URL 提取基础路径和解析相对 URL。
 *
 * @file[en] LoaderUtils  Loader utility class
 * @brief[en] Loader utility class providing static methods for URL resolution etc.
 * @explain[en] Provides extractUrlBase and resolveURL static methods for extracting base paths from URLs and resolving relative URLs.
 */
package three.resource.loader

/**
 * @brief[zh-cn] 加载器工具类
 * @explain[zh-cn] 提供 URL 解析等静态工具方法。
 *
 * @brief[en] Loader utility class
 * @explain[en] Provides static utility methods for URL resolution etc.
 */
public class LoaderUtils {
    /**
     * @brief[zh-cn] 从 URL 提取基础路径
     * @param[zh-cn] url 输入 URL
     * @return[zh-cn] 基础路径
     *
     * @brief[en] Extract base path from URL
     * @param[en] url Input URL
     * @return[en] Base path
     */
    public static func extractUrlBase(url: String): String {
        let index = url.lastIndexOf("/")
        match (index) {
            case Some(idx) => return url[0..(idx + 1)]
            case None => return "./"
        }
    }

    /**
     * @brief[zh-cn] 解析相对 URL 到给定路径
     * @explain[zh-cn] 无效/空 URL 返回空串；host-relative URL：path 为 http(s):// 开头且 url 以 / 开头时，path 截断为协议+主机；绝对 URL（http(s)://、//）、data:、blob: 原样返回；其余情况返回 path + url。
     * @param[zh-cn] url 要解析的 URL
     * path 相对 URL 的基础路径
     * @return[zh-cn] 解析后的 URL
     *
     * @brief[en] Resolve relative URL to a given path
     * @explain[en] Invalid/empty URL returns empty string; host-relative URL: when path starts with http(s):// and url starts with /, path is truncated to protocol+host; absolute URLs (http(s)://, //), data:, blob: returned as-is; otherwise returns path + url.
     * @param[en] url URL to resolve
     * path Base path for relative URLs
     * @return[en] Resolved URL
     */
    public static func resolveURL(url: String, path: String): String {
        
        if (url == "") { return "" }

        
        //         path = path.replace(/(^https?:\/\/[^\/]+).*/i, '$1')
        var basePath = path
        if ((basePath.startsWith("http://") || basePath.startsWith("https://")) && url.startsWith("/")) {
            let schemeLen = if (basePath.startsWith("https://")) { 8 } else { 7 }
            // 找到协议+主机部分（首个 / 在 scheme 之后）
            let hostEnd = basePath.indexOf("/", schemeLen)
            match (hostEnd) {
                case Some(h) => if (h != -1) { basePath = basePath[0..h] }
                case None => ()
            }
        }

        
        if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("//")) { return url }
        
        if (url.startsWith("data:")) { return url }
        
        if (url.startsWith("blob:")) { return url }
        
        return basePath + url
    }
}
