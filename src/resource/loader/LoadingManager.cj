/**
 * @file[zh-cn] LoadingManager 加载管理器
 * @brief[zh-cn] 加载管理器，跟踪已加载项目并提供回调
 * @explain[zh-cn] 管理多个加载器的全局加载状态，提供 onStart/onLoad/onProgress/onError 回调，支持 URL 修改器和正则匹配的处理器注册。
 *
 * @file[en] LoadingManager  Loading manager
 * @brief[en] Loading manager that tracks loaded items and provides callbacks
 * @explain[en] Manages global loading state across multiple loaders, provides onStart/onLoad/onProgress/onError callbacks, supports URL modifier and regex-matched handler registration.
 */
package three.resource.loader

import std.collection.*
import std.regex.*

/**
 * @brief[zh-cn] 加载管理器，跟踪已加载项目并提供回调
 * @explain[zh-cn] 管理多个加载器的全局加载状态，提供 onStart/onLoad/onProgress/onError 回调，支持 URL 修改器和正则匹配的处理器注册。
 *
 * @brief[en] Loading manager that tracks loaded items and provides callbacks
 * @explain[en] Manages global loading state across multiple loaders, provides onStart/onLoad/onProgress/onError callbacks, supports URL modifier and regex-matched handler registration.
 */
public class LoadingManager {
    /**
     * @brief[zh-cn] 加载开始回调
     *
     * @brief[en] Load start callback
     */
    public var onStart: Option<(String, Int64, Int64) -> Unit>
    /**
     * @brief[zh-cn] 全部加载完成回调
     *
     * @brief[en] All loads complete callback
     */
    public var onLoad: Option<() -> Unit>
    /**
     * @brief[zh-cn] 加载进度回调
     *
     * @brief[en] Load progress callback
     */
    public var onProgress: Option<(String, Int64, Int64) -> Unit>
    /**
     * @brief[zh-cn] 加载错误回调
     *
     * @brief[en] Load error callback
     */
    public var onError: Option<(String) -> Unit>
    /**
     * @brief[zh-cn] 是否正在加载
     *
     * @brief[en] Whether currently loading
     */
    private var isLoading: Bool
    /**
     * @brief[zh-cn] 已加载项目数
     *
     * @brief[en] Number of items loaded
     */
    private var itemsLoaded: Int64
    /**
     * @brief[zh-cn] 项目总数
     *
     * @brief[en] Total number of items
     */
    private var itemsTotal: Int64
    /**
     * @brief[zh-cn] URL 修改器
     *
     * @brief[en] URL modifier
     */
    private var urlModifier: Option<(String) -> String>
    // 处理器表：regex 模式与对应 Loader 分离存储（替代原 ArrayList<Any> 交替存储）。
    private var handlerRegexes: ArrayList<String>
    private var handlerLoaders: ArrayList<Loader>

    public init(onLoad!: Option<() -> Unit> = None, onProgress!: Option<(String, Int64, Int64) -> Unit> = None, onError!: Option<(String) -> Unit> = None) {
        this.isLoading = false
        this.itemsLoaded = 0
        this.itemsTotal = 0
        this.onStart = None
        this.onLoad = onLoad
        this.onProgress = onProgress
        this.onError = onError
        this.urlModifier = None
        this.handlerRegexes = ArrayList<String>()
        this.handlerLoaders = ArrayList<Loader>()
    }

    /**
     * @brief[zh-cn] 标记一个项目开始加载
     * @param[zh-cn] url 项目 URL
     *
     * @brief[en] Mark an item as started loading
     * @param[en] url Item URL
     */
    public func itemStart(url: String): Unit {
        this.itemsTotal += 1
        if (!this.isLoading) {
            match (this.onStart) {
                case Some(f) => f(url, this.itemsLoaded, this.itemsTotal)
                case None => ()
            }
        }
        this.isLoading = true
    }

    /**
     * @brief[zh-cn] 标记一个项目加载完成
     * @param[zh-cn] url 项目 URL
     *
     * @brief[en] Mark an item as finished loading
     * @param[en] url Item URL
     */
    public func itemEnd(url: String): Unit {
        this.itemsLoaded += 1
        match (this.onProgress) {
            case Some(f) => f(url, this.itemsLoaded, this.itemsTotal)
            case None => ()
        }
        if (this.itemsLoaded == this.itemsTotal) {
            this.isLoading = false
            match (this.onLoad) {
                case Some(f) => f()
                case None => ()
            }
        }
    }

    /**
     * @brief[zh-cn] 标记一个项目加载出错
     * @param[zh-cn] url 项目 URL
     *
     * @brief[en] Mark an item as having a load error
     * @param[en] url Item URL
     */
    public func itemError(url: String): Unit {
        match (this.onError) {
            case Some(f) => f(url)
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 通过 URL 修改器解析 URL
     * @param[zh-cn] url 原始 URL
     * @return[zh-cn] 修改后的 URL
     *
     * @brief[en] Resolve URL through the URL modifier
     * @param[en] url Original URL
     * @return[en] Modified URL
     */
    public func resolveURL(url: String): String {
        match (this.urlModifier) {
            case Some(f) => return f(url)
            case None => return url
        }
    }

    /**
     * @brief[zh-cn] 设置 URL 修改器
     * @param[zh-cn] transform URL 修改函数
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set the URL modifier
     * @param[en] transform URL modifier function
     * @return[en] Self reference
     */
    public func setURLModifier(transform: (String) -> String): LoadingManager {
        this.urlModifier = Some(transform)
        return this
    }

    /**
     * @brief[zh-cn] 添加正则匹配的处理器
     * @param[zh-cn] regex 正则表达式模式
     * loader 对应的加载器
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Add a regex-matched handler
     * @param[en] regex Regex pattern
     * loader Corresponding loader
     * @return[en] Self reference
     */
    public func addHandler(regex: String, loader: Loader): LoadingManager {
        this.handlerRegexes.add(regex)
        this.handlerLoaders.add(loader)
        return this
    }

    /**
     * @brief[zh-cn] 根据文件名查找匹配的处理加载器
     * @explain[zh-cn] handler.regex.test(file)，使用正则匹配而非子串包含。
     * @param[zh-cn] file 文件名
     * @return[zh-cn] 匹配的加载器（无匹配时返回 None）
     *
     * @brief[en] Find matching handler loader by file name
     * @explain[en] handler.regex.test(file), uses regex matching rather than substring inclusion.
     * @param[en] file File name
     * @return[en] Matched loader (returns None if no match)
     */
    public func getHandler(file: String): Option<Loader> {
        for (i in 0..this.handlerRegexes.size) {
            let re = Regex(this.handlerRegexes[i])
            if (re.find(file).isSome()) { return Some(this.handlerLoaders[i]) }
        }
        return None
    }
}
