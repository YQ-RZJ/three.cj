/**
 * @file[zh-cn] Cache 资源缓存
 * @brief[zh-cn] 资源缓存类，为加载器提供已加载资源的全局缓存
 * @explain[zh-cn] Cache 以键值对形式缓存已加载的资源（ILoadResult），加载器首次加载后存入缓存，后续相同 URL 的请求直接返回缓存结果。对应 Three.js 的 Cache 对象，通过 enabled 开关控制是否启用缓存。
 *
 * @file[en] Cache  Resource caching
 * @brief[en] Resource cache class providing global caching for loaders
 * @explain[en] Cache stores loaded resources (ILoadResult) as key-value pairs. After the first load, subsequent requests for the same URL return the cached result. Mirrors the Three.js Cache object with an enabled toggle.
 */
package three.resource.cache

import std.collection.*
import three.core.interfaces.ILoadResult

/**
 * @brief[zh-cn] 资源缓存类，为加载器提供已加载资源的全局缓存
 * @explain[zh-cn] 以静态方式管理缓存，通过 enabled 开关控制是否启用。启用后，FileLoader/ImageLoader 等加载器会在加载成功后将结果写入缓存，并在后续加载时优先查询缓存。
 *
 * @brief[en] Resource cache class providing global caching for loaders
 * @explain[en] Manages cache statically with an enabled toggle. When enabled, loaders such as FileLoader/ImageLoader write results to cache on successful load and check cache first on subsequent loads.
 */
public class Cache {
    /**
     * @brief[zh-cn] 是否启用缓存
     *
     * @brief[en] Whether caching is enabled
     */
    public static var enabled: Bool = false
    /**
     * @brief[zh-cn] 缓存文件字典
     *
     * @brief[en] Cached files dictionary
     */
    public static var files: HashMap<String, ILoadResult> = HashMap<String, ILoadResult>()

    /**
     * @brief[zh-cn] 向缓存中添加资源
     * @param[zh-cn] key 缓存键（通常为 URL）
     * file 加载结果
     *
     * @brief[en] Add a resource to the cache
     * @param[en] key Cache key (typically a URL)
     * file Load result
     */
    public static func add(key: String, file: ILoadResult): Unit {
        if (Cache.enabled) { Cache.files.add(key, file) }
    }

    /**
     * @brief[zh-cn] 从缓存中获取资源
     * @param[zh-cn] key 缓存键
     * @return[zh-cn] 缓存的加载结果，不存在时返回 None
     *
     * @brief[en] Get a resource from the cache
     * @param[en] key Cache key
     * @return[en] Cached load result, or None if not found
     */
    public static func get(key: String): Option<ILoadResult> {
        return Cache.files.get(key)
    }

    /**
     * @brief[zh-cn] 从缓存中移除资源
     * @param[zh-cn] key 缓存键
     *
     * @brief[en] Remove a resource from the cache
     * @param[en] key Cache key
     */
    public static func remove(key: String): Unit {
        Cache.files.remove(key)
    }

    /**
     * @brief[zh-cn] 清空所有缓存
     *
     * @brief[en] Clear all cached resources
     */
    public static func clear(): Unit {
        Cache.files.clear()
    }
}
