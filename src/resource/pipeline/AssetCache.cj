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
 * @file[zh-cn] AssetCache 引用计数资源缓存
 * @brief[zh-cn] 线程安全、带引用计数的资源缓存，支持按引用计数自动卸载
 * @explain[zh-cn] 对照 Unity Resources.UnloadUnusedAssets / Unreal 资源引用计数工作流：
 * - 生命周期：add(key, resource) 入缓存（初始引用计数 0）→ 使用方 retain(key) 持有 →
 *   使用完毕 release(key) 释放 → collect()/collectIfNeeded() 把引用计数归零的资源移出缓存。
 * - 线程安全：内部用 std.sync.Mutex 保护；后台加载线程（AssetManager）
 *   与主循环线程可并发访问。
 * - 与 three.resource.cache.Cache 的关系：Cache 是引擎通用的"永不过期"URL 缓存
 *   （FileLoader 等加载器内部使用）；本类面向游戏运行时资源生命周期管理（场景切换时
 *   release 场景资源 → collect 卸载），两者互不依赖。
 * 用法示例：
 * let cache = AssetCache.shared
 * cache.add("tex/hero.png", texture)
 * cache.retain("tex/hero.png")            // 场景 A 持有
 * cache.release("tex/hero.png")           // 场景 A 卸载
 * cache.collect()                         // 引用归零 → 立即移出
 *
 * @file[en] AssetCache  Ref-counted asset cache
 * @brief[en] Thread-safe ref-counted asset cache with ref-count-based unloading
 * @explain[en] Mirrors Unity Resources.UnloadUnusedAssets / Unreal ref-counted asset workflows:
 * - Lifecycle: add(key, resource) caches (initial ref count 0) → retain(key) by consumers →
 *   release(key) when done → collect()/collectIfNeeded() evicts entries whose count is zero.
 * - Thread safety: guarded internally by std.sync.Mutex; the background loading
 *   thread (AssetManager) and the main loop thread may access it concurrently.
 * - Relation to three.resource.cache.Cache: Cache is the engine-wide "never expiring"
 *   URL cache used internally by loaders (FileLoader etc.); this class targets game-runtime
 *   asset lifecycle management (release scene assets on scene switch → collect unload).
 * Usage:
 * let cache = AssetCache.shared
 * cache.add("tex/hero.png", texture)
 * cache.retain("tex/hero.png")            // scene A holds it
 * cache.release("tex/hero.png")           // scene A unloads
 * cache.collect()                         // ref count zero → evicted immediately
 */
package three.resource.pipeline

import std.collection.*
import std.sync.*
import three.core.interfaces.ILoadResult
import three.utils.safe.IReleasable

/**
 * @brief[zh-cn] 缓存条目：资源 + 引用计数
 *
 * @brief[en] Cache entry: resource + reference count
 */
internal class CacheEntry {
    /** 缓存的资源 */
    public var resource: ILoadResult
    /** 引用计数（0 = 无人持有，可被 collect 回收） */
    public var refCount: Int64
    /** 最近一次 retain/release 的逻辑帧号（collectIfNeeded 的惰性回收依据） */
    public var lastTouchFrame: Int64

    public init(resource: ILoadResult) {
        this.resource = resource
        this.refCount = 0
        this.lastTouchFrame = 0
    }
}

/**
 * @brief[zh-cn] 引用计数资源缓存
 * @explain[zh-cn] 线程安全的键值缓存，为每个条目维护引用计数；retain/release 增减计数，
 * collect 回收归零条目。提供全局共享实例 shared，也可按业务域自建实例（如按场景隔离）。
 *
 * @brief[en] Ref-counted asset cache
 * @explain[en] Thread-safe key-value cache maintaining a reference count per entry;
 * retain/release adjust the count and collect evicts zero-count entries. A global
 * shared instance is provided; per-domain instances (e.g. scene-isolated) are also fine.
 */
public class AssetCache <: IReleasable {
    /** 全局共享实例（多数游戏直接使用） */
    public static let shared: AssetCache = AssetCache()

    private var _entries: HashMap<String, CacheEntry>
    private var _mutex: Mutex
    /** 当前逻辑帧号（retain/release 时更新条目的 lastTouchFrame） */
    private var _frame: Int64
    /** 上次 collect 的帧号（collectIfNeeded 间隔控制） */
    private var _lastCollectFrame: Int64

    public init() {
        this._entries = HashMap<String, CacheEntry>()
        this._mutex = Mutex()
        this._frame = 0
        this._lastCollectFrame = -1
    }

    /**
     * @brief[zh-cn] 缓存条目数量
     *
     * @brief[en] Number of cached entries
     */
    public prop count: Int64 {
        get() {
            synchronized(_mutex) {
                return _entries.size
            }
        }
    }

    /**
     * @brief[zh-cn] 每帧推进逻辑帧号（由 AssetManager.update 调用，也可手动调用）
     *
     * @brief[en] Advances the logical frame per frame (called by AssetManager.update, or manually)
     */
    public func advanceFrame(): Unit {
        synchronized(_mutex) {
            _frame += 1
        }
    }

    /**
     * @brief[zh-cn] 向缓存添加资源（初始引用计数 0）
     * @explain[zh-cn] 重复添加同一 key 会覆盖旧资源（引用计数重置为 0）。
     * @param[zh-cn] key 资源键（通常为 URL 或包内资源名）
     * resource 加载结果
     *
     * @brief[en] Adds a resource to the cache (initial ref count 0)
     * @explain[en] Adding the same key again overwrites the old resource (count reset to 0).
     * @param[en] key Resource key (usually a URL or bundle entry name)
     * resource Load result
     */
    public func add(key: String, resource: ILoadResult): Unit {
        synchronized(_mutex) {
            let entry = CacheEntry(resource)
            entry.lastTouchFrame = _frame
            _entries.add(key, entry)
        }
    }

    /**
     * @brief[zh-cn] 从缓存获取资源（不改变引用计数）
     * @param[zh-cn] key 资源键
     * @return[zh-cn] 缓存的资源，不存在时返回 None
     *
     * @brief[en] Gets a cached resource without changing the ref count
     * @param[en] key Resource key
     * @return[en] Cached resource, or None when absent
     */
    public func get(key: String): Option<ILoadResult> {
        return synchronized(_mutex) {
            if (let Some(e) <- _entries.get(key)) {
                    e.lastTouchFrame = _frame
                    Some(e.resource)
                } else {
                    None
                }
        }
    }

    /**
     * @brief[zh-cn] 获取资源并持有一次引用（不存在时返回 None）
     * @param[zh-cn] key 资源键
     * @return[zh-cn] 缓存的资源；同时引用计数 +1
     *
     * @brief[en] Gets a resource and acquires one reference (None when absent)
     * @param[en] key Resource key
     * @return[en] Cached resource; ref count incremented by 1
     */
    public func acquire(key: String): Option<ILoadResult> {
        return synchronized(_mutex) {
            if (let Some(e) <- _entries.get(key)) {
                    e.refCount += 1
                    e.lastTouchFrame = _frame
                    Some(e.resource)
                } else {
                    None
                }
        }
    }

    /**
     * @brief[zh-cn] 手动持有一次引用
     * @param[zh-cn] key 资源键
     * @return[zh-cn] 资源存在并成功 +1 返回 true
     *
     * @brief[en] Manually acquires one reference
     * @param[en] key Resource key
     * @return[en] True when the entry exists and the count was incremented
     */
    public func retain(key: String): Bool {
        return synchronized(_mutex) {
            if (let Some(e) <- _entries.get(key)) {
                    e.refCount += 1
                    e.lastTouchFrame = _frame
                    true
                } else {
                    false
                }
        }
    }

    /**
     * @brief[zh-cn] 释放一次引用（计数归零的条目等待 collect 回收）
     * @param[zh-cn] key 资源键
     * @return[zh-cn] 资源存在并成功 -1 返回 true
     *
     * @brief[en] Releases one reference (zero-count entries wait for collect)
     * @param[en] key Resource key
     * @return[en] True when the entry exists and the count was decremented
     */
    public func release(key: String): Bool {
        return synchronized(_mutex) {
            if (let Some(e) <- _entries.get(key)) {
                    if (e.refCount > 0) {
                        e.refCount -= 1
                    }
                    e.lastTouchFrame = _frame
                    true
                } else {
                    false
                }
        }
    }

    /**
     * @brief[zh-cn] 查询引用计数
     * @param[zh-cn] key 资源键
     * @return[zh-cn] 引用计数；资源不存在返回 -1
     *
     * @brief[en] Queries the ref count
     * @param[en] key Resource key
     * @return[en] Ref count; -1 when absent
     */
    public func refCount(key: String): Int64 {
        return synchronized(_mutex) {
            if (let Some(e) <- _entries.get(key)) {
                    e.refCount
                } else {
                    -1
                }
        }
    }

    /**
     * @brief[zh-cn] 移除指定条目（无论引用计数）
     * @param[zh-cn] key 资源键
     *
     * @brief[en] Removes the entry regardless of ref count
     * @param[en] key Resource key
     */
    public func remove(key: String): Unit {
        synchronized(_mutex) {
            _entries.remove(key)
        }
    }

    /**
     * @brief[zh-cn] 回收所有引用计数为 0 的条目
     * @return[zh-cn] 本次回收的条目数量
     *
     * @brief[en] Evicts all entries with ref count 0
     * @return[en] Number of evicted entries
     */
    public func collect(): Int64 {
        return synchronized(_mutex) {
            var removed: Int64 = 0
            let dead = ArrayList<String>()
            for ((key, e) in _entries) {
                if (e.refCount <= 0) {
                    dead.add(key)
                }
            }
            for (key in dead) {
                _entries.remove(key)
                removed += 1
            }
            _lastCollectFrame = _frame
            return removed
        }
    }

    /**
     * @brief[zh-cn] 惰性回收：距上次 collect 超过 interval 帧才执行一次
     * @explain[zh-cn] 供每帧调用的分帧回收：避免每帧全表扫描，同时保证归零资源最终被卸载。
     * @param[zh-cn] interval 回收间隔（帧数，默认 60）
     * @return[zh-cn] 本次执行的回收数量（未触发返回 0）
     *
     * @brief[en] Lazy collect: runs once every interval frames
     * @explain[en] Frame-spread collection: avoids full scans every frame while guaranteeing
     * zero-count resources are eventually unloaded.
     * @param[en] interval Collect interval in frames (default 60)
     * @return[en] Evicted count this run (0 when not triggered)
     */
    public func collectIfNeeded(interval!: Int64 = 60): Int64 {
        return synchronized(_mutex) {
            if (_lastCollectFrame >= 0 && _frame - _lastCollectFrame < interval) {
                return 0
            }
            // 在锁内直接回收（避免二次加锁死锁）
            var removed: Int64 = 0
            let dead = ArrayList<String>()
            for ((key, e) in _entries) {
                if (e.refCount <= 0) {
                    dead.add(key)
                }
            }
            for (key in dead) {
                _entries.remove(key)
                removed += 1
            }
            _lastCollectFrame = _frame
            return removed
        }
    }

    /**
     * @brief[zh-cn] 清空全部缓存（无视引用计数）
     * @explain[zh-cn] 与带参 release(key) 重载区分。
     *
     * @brief[en] clears the whole cache (ignores ref counts)
     * @explain[en] distinct from the keyed
     *              release(key) overload
     */
    public func release(): Bool {
        synchronized(_mutex) {
            _entries.clear()
        }
        return true
    }
}
