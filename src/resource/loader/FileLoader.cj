/**
 * @file[zh-cn] FileLoader 文件加载器
 * @brief[zh-cn] 使用本地文件系统加载文件
 * @explain[zh-cn] 仓颉侧无浏览器 fetch/XMLHttpRequest，使用 std.fs 实现本地文件读取。支持 Cache、manager.resolveURL、path 拼接、responseType、mimeType。
 *
 * @file[en] FileLoader  File loader
 * @brief[en] Loads files using the local file system
 * @explain[en] Cangjie side has no browser fetch/XMLHttpRequest; uses std.fs for local file reading. Supports Cache, manager.resolveURL, path concatenation, responseType, mimeType.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.resource.cache.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 文件加载器，用于通过本地文件系统加载文件
 * @explain[zh-cn] 支持 responseType/mimeType/requestHeader/withCredentials/path。仓颉侧：使用 std.fs.File.readFrom 读取本地文件，不支持 fetch/AbortController/ProgressEvent。
 *
 * @brief[en] File loader for loading files via the local file system
 * @explain[en] Supports responseType/mimeType/requestHeader/withCredentials/path. Cangjie side: uses std.fs.File.readFrom for local file reading; does not support fetch/AbortController/ProgressEvent.
 *
 * @extends Loader
 */
public class FileLoader <: Loader {
    /** 响应类型（如 "arraybuffer"、"text"、"json"、"blob"、"document"） */
    public var responseType: String
    /** MIME 类型（用于 document 响应类型） */
    public var mimeType: String

    public init(manager: LoadingManager) {
        super(manager: manager)
        this.responseType = ""
        this.mimeType = ""
    }

    public init() {
        super()
        this.responseType = ""
        this.mimeType = ""
    }

    /**
     * @param[zh-cn] responseType 响应类型字符串
     * @return[zh-cn] 自身引用
     *
     * @param[en] responseType Response type string
     * @return[en] Self reference
     *
     * 设置响应类型
     */
    public func setResponseType(responseType: String): FileLoader {
        this.responseType = responseType
        return this
    }

    /**
     * @param[zh-cn] mimeType MIME 类型字符串
     * @return[zh-cn] 自身引用
     *
     * @param[en] mimeType MIME type string
     * @return[en] Self reference
     *
     * 设置 MIME 类型
     */
    public func setMimeType(mimeType: String): FileLoader {
        this.mimeType = mimeType
        return this
    }

    /**
     * @param[zh-cn] url 文件路径（相对或绝对路径）
     * @param[zh-cn] onLoad 加载完成回调，参数类型根据 responseType 决定
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url File path (relative or absolute)
     * @param[en] onLoad Load complete callback, parameter type determined by responseType
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载文件
     * 使用 std.fs.File.readFrom 读取本地文件内容
     * 支持特性：Cache 缓存、manager.resolveURL、path 拼接、responseType 转换
     * 不支持的特性：fetch/AbortController/ReadableStream/ProgressEvent（浏览器专用）
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        
        var resolvedUrl = url
        if (resolvedUrl == "") { resolvedUrl = "" }

        
        if (this.path != "") { resolvedUrl = this.path + resolvedUrl }

        
        resolvedUrl = this.manager.resolveURL(resolvedUrl)

        
        let cacheKey = "file:" + resolvedUrl
        let cached = Cache.get(cacheKey)

        
        if (cached.isSome()) {
            this.manager.itemStart(resolvedUrl)
            onLoad(cached.getOrThrow())
            this.manager.itemEnd(resolvedUrl)
            return
        }

        
        try {
            this.manager.itemStart(resolvedUrl)

            // 读取文件内容
            let bytes = File.readFrom(resolvedUrl)

            // 根据 responseType 转换数据
            
            // 仓颉：onLoad 回调参数为 ILoadResult，值类型结果用包装类（StringLoadResult/BytesLoadResult）
            var result: ILoadResult = StringLoadResult("")
            if (this.responseType == "arraybuffer" || this.responseType == "blob") {
                result = BytesLoadResult(bytes)
            } else if (this.responseType == "json") {
                let jsonStr = String.fromUtf8(bytes)
                result = StringLoadResult(jsonStr)
            } else {
                // 默认 "text" 或空
                result = StringLoadResult(String.fromUtf8(bytes))
            }

            
            Cache.add(cacheKey, result)

            this.manager.itemEnd(resolvedUrl)
            onLoad(result)
        } catch (e: Exception) {
            this.manager.itemError(resolvedUrl)
            this.manager.itemEnd(resolvedUrl)
            onError(e.toString())
        }
    }
}