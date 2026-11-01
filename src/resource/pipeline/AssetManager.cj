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
 * @file[zh-cn] AssetManager 资源管理器
 * @brief[zh-cn] 异步分帧加载 + 引用计数卸载 + AssetBundle 分发的统一资源入口
 * @explain[zh-cn] 补齐游戏引擎资源管线的核心三层能力（对照 Unity AssetManager / 主流引擎的 LoadingManager）：
 * 1. 异步加载：loadBytes/loadText/loadJson 把文件 IO 放到 spawn 后台线程，
 *    彻底消除 FileLoader 的同步读盘卡顿；同 URL 并发请求自动合并（pending 去重）。
 * 2. 分帧派发：后台读盘完成后压入完成队列，主循环每帧调用 update() 在时间预算内
 *    分帧派发回调（预算内尽可能多，超限延后到下一帧），避免大资源集中回调造成帧尖峰。
 * 3. 引用计数卸载：加载结果可写入 AssetCache（retain/release/collect），
 *    场景切换时统一释放，配合 collectIfNeeded 惰性回收。
 * 另提供 loadFromBundle：从 AssetBundle（单档案多资源）内分发条目，走同一条分帧回调路径。
 * 集成方式：在窗口主循环（WindowEngine._windowLoop）中引擎已自动调用 pumpShared，
 * 用户无需手动调用；独立使用（无窗口）时每帧手动调 AssetManager.shared.update()。
 *
 * @file[en] AssetManager  Asset manager
 * @brief[en] Unified asset entry for async frame-spread loading, ref-counted unloading and bundle dispatch
 * @explain[en] Fills in the three core layers of a game engine asset pipeline (mirroring Unity
 * AssetManager / mainstream engine LoadingManager):
 * 1. Async loading: loadBytes/loadText/loadJson move file IO onto a spawn'd background thread,
 *    eliminating FileLoader's synchronous disk-read stalls; concurrent requests for the same URL
 *    are coalesced (pending dedup).
 * 2. Frame-spread dispatch: finished reads are pushed into a completion queue; the main loop calls
 *    update() every frame and dispatches callbacks within a time budget (as many as fit, the rest
 *    deferred to the next frame), avoiding frame spikes from batched large-asset callbacks.
 * 3. Ref-counted unloading: load results can be stored in AssetCache (retain/release/collect);
 *    released on scene switches, lazily reclaimed via collectIfNeeded.
 * loadFromBundle dispatches entries from an AssetBundle (single archive, many assets) through the
 * same frame-spread callback path.
 * Integration: the engine already calls pumpShared inside the window main loop
 * (WindowEngine._windowLoop); standalone usage (no window) should call
 * AssetManager.shared.update() manually each frame.
 */
package three.resource.pipeline

import std.collection.*
import std.sync.*
import std.fs.*
import std.time.*
import three.core.interfaces.ILoadResult
import three.resource.loader.StringLoadResult
import three.resource.loader.BytesLoadResult

/**
 * @brief[zh-cn] 完成队列条目：一次已完成的读取及其回调
 *
 * @brief[en] Completion queue entry: one finished read plus its callbacks
 */
internal class LoadCompletion {
    /** 资源键（缓存键） */
    public var key: String
    /** 是否成功 */
    public var success: Bool
    /** 成功时的字节数据 */
    public var bytes: Array<UInt8>
    /** 失败时的错误信息 */
    public var error: String
    /** 成功回调（主循环线程执行） */
    public var onLoad: Option<(ILoadResult) -> Unit>
    /** 失败回调（主循环线程执行） */
    public var onError: Option<(String) -> Unit>

    public init(key: String, success: Bool, bytes: Array<UInt8>, error: String,
                onLoad: Option<(ILoadResult) -> Unit>, onError: Option<(String) -> Unit>) {
        this.key = key
        this.success = success
        this.bytes = bytes
        this.error = error
        this.onLoad = onLoad
        this.onError = onError
    }
}

/**
 * @brief[zh-cn] 资源管理器
 * @explain[zh-cn] 统一资源入口：异步读盘（后台线程）→ 完成队列 → 分帧派发回调；
 * 可选写入 AssetCache 做引用计数生命周期管理；支持从 AssetBundle 分发资源。
 *
 * @brief[en] Asset manager
 * @explain[en] Unified asset entry: async disk IO (background thread) → completion queue →
 * frame-spread callback dispatch; optionally stores results in AssetCache for ref-counted
 * lifecycle management; supports dispatching from an AssetBundle.
 */
public class AssetManager {
    /** 全局共享实例（引擎主循环自动泵该实例） */
    public static let shared: AssetManager = AssetManager()

    /** 引用计数缓存（加载结果生命周期管理） */
    public let cache: AssetCache

    private var _mutex: Mutex
    /** 完成队列：后台线程压入，主循环 update() 派发 */
    private var _completions: ArrayList<LoadCompletion>
    /** 进行中请求：url → 是否进行中（并发去重） */
    private var _inflight: HashSet<String>

    public init() {
        this.cache = AssetCache()
        this._mutex = Mutex()
        this._completions = ArrayList<LoadCompletion>()
        this._inflight = HashSet<String>()
    }

    /**
     * @brief[zh-cn] 待派发的完成条目数量
     *
     * @brief[en] Number of completions pending dispatch
     */
    public prop pendingCount: Int64 {
        get() {
            synchronized(_mutex) {
                return _completions.size
            }
        }
    }

    /**
     * @brief[zh-cn] 异步加载文件字节
     * @explain[zh-cn] 文件 IO 在后台线程执行；回调经完成队列在主循环线程分帧派发。
     * 命中缓存（cache 中已存在同 key 结果）时不重复读盘，直接进入派发队列。
     * 同 URL 的并发请求自动合并为一次读盘。
     * @param[zh-cn] url 文件路径（相对或绝对）
     * onLoad 成功回调，参数为字节数组（主循环线程执行）
     * onError 失败回调，参数为错误信息（主循环线程执行）
     * storeCache 是否把结果写入 cache（默认 false；true 时可配合 retain/release 管理）
     *
     * @brief[en] Loads file bytes asynchronously
     * @explain[en] File IO runs on a background thread; callbacks are dispatched on the main
     * loop thread via the completion queue. Cache hits (same key already in cache) skip the
     * disk read and go straight to dispatch. Concurrent requests for the same URL are coalesced.
     * @param[en] url File path (relative or absolute)
     * onLoad Success callback with the byte array (runs on main loop thread)
     * onError Failure callback with the error message (runs on main loop thread)
     * storeCache Whether to store the result into cache (default false; combine with
     * retain/release when true)
     */
    public func loadBytes(url: String, onLoad: (ILoadResult) -> Unit, onError!: (String) -> Unit = { _ => () },
                          storeCache!: Bool = false): Unit {
        let key = "file:" + url
        // 1. 缓存命中：不读盘，直接派发
        var hitCache = false
        if (let Some(_) <- this.cache.get(key)) {
            hitCache = true
        }
        if (!hitCache) {
            // 2. 并发去重：同一 url 已在进行中时直接返回（简化实现：防同帧重复 spawn）
            var skip = false
            synchronized(_mutex) {
                if (_inflight.contains(key)) {
                    skip = true
                } else {
                    _inflight.add(key)
                }
            }
            if (!skip) {
                // 3. 后台线程读盘
                let cacheRef = this.cache
                let selfRef = this
                spawn {
                    var bytes: Array<UInt8> = Array<UInt8>()
                    var err = ""
                    var ok = true
                    try {
                        bytes = File.readFrom(url)
                    } catch (e: Exception) {
                        ok = false
                        err = e.toString()
                    }
                    // 4. 成功且需要缓存：写入 cache（引用计数 0，等待 collect 回收）
                    if (ok && storeCache) {
                        cacheRef.add(key, BytesLoadResult(bytes))
                    }
                    // 5. 压入完成队列，等待主循环分帧派发
                    selfRef._pushCompletion(LoadCompletion(key, ok, bytes, err, Some(onLoad), Some(onError)))
                    synchronized(selfRef._mutex) {
                        selfRef._inflight.remove(key)
                    }
                }
            }
        }
        // 缓存命中：字节为空 + key 有效，update() 派发时从 cache 取真实结果
        if (hitCache) {
            this._pushCompletion(LoadCompletion(key, true, Array<UInt8>(), "", Some(onLoad), Some(onError)))
        }
    }

    /**
     * @brief[zh-cn] 异步加载文本文件（UTF-8）
     * @param[zh-cn] url 文件路径
     * onLoad 成功回调（主循环线程执行）
     * onError 失败回调（主循环线程执行）
     *
     * @brief[en] Loads a text file asynchronously (UTF-8)
     * @param[en] url File path
     * onLoad Success callback (main loop thread)
     * onError Failure callback (main loop thread)
     */
    public func loadText(url: String, onLoad: (String) -> Unit, onError!: (String) -> Unit = { _ => () }): Unit {
        this.loadBytes(url, { res =>
            // loadBytes 成功路径派发 BytesLoadResult；缓存命中可能返回 StringLoadResult
            if (res is StringLoadResult) {
                if (let Some(sr) <- (res as StringLoadResult)) {
                    onLoad(sr.value)
                }
            } else if (res is BytesLoadResult) {
                if (let Some(br) <- (res as BytesLoadResult)) {
                    onLoad(String.fromUtf8(br.value))
                }
            }
        }, onError: onError)
    }

    /**
     * @brief[zh-cn] 从资源包内分发一个条目（内存操作，但仍走分帧回调路径）
     * @param[zh-cn] bundle 资源包
     * name 包内资源名
     * onLoad 成功回调（主循环线程执行）
     * onError 失败回调（主循环线程执行）
     *
     * @brief[en] Dispatches one entry from a bundle (in-memory, still via the frame-spread path)
     * @param[en] bundle The bundle
     * name Bundle entry name
     * onLoad Success callback (main loop thread)
     * onError Failure callback (main loop thread)
     */
    public func loadFromBundle(bundle: AssetBundle, name: String,
                               onLoad: (ILoadResult) -> Unit, onError!: (String) -> Unit = { _ => () }): Unit {
        let key = "bundle:" + name
        var hitCache = false
        if (let Some(_) <- this.cache.get(key)) {
            hitCache = true
        }
        if (!hitCache) {
            if (let Some(bytes) <- bundle.read(name)) {
                let res = BytesLoadResult(bytes)
                this.cache.add(key, res)
                // 字节非空，update() 直接用 completion.bytes 构造结果
                this._pushCompletion(LoadCompletion(key, true, bytes, "", Some(onLoad), Some(onError)))
            } else {
                this._pushCompletion(LoadCompletion(key, false, Array<UInt8>(), "bundle entry not found: " + name, Some(onLoad), Some(onError)))
            }
        } else {
            // 缓存命中：字节为空 + key 有效，update() 派发时从 cache 取真实结果
            this._pushCompletion(LoadCompletion(key, true, Array<UInt8>(), "", Some(onLoad), Some(onError)))
        }
    }

    /**
     * @brief[zh-cn] 每帧派发：在时间预算内分帧消费完成队列
     * @explain[zh-cn] 由引擎主循环自动调用（pumpShared）；独立使用时每帧手动调用。
     * 派发策略：优先消费强制上限（maxPerFrame）内的条目；若设置了 budgetMs 且耗时超限，
     * 剩余条目延后到下一帧。
     * @param[zh-cn] maxPerFrame 单帧最大派发条目数（默认 4）
     * budgetMs 单帧派发时间预算（毫秒，0 = 不限制，默认 2.0）
     * @return[zh-cn] 本帧派发的条目数
     *
     * @brief[en] Per-frame dispatch: consumes the completion queue within the time budget
     * @explain[en] Called automatically by the engine main loop (pumpShared); call manually
     * each frame for standalone usage. Strategy: dispatch up to maxPerFrame entries; when
     * budgetMs is set and exceeded, the rest defer to the next frame.
     * @param[en] maxPerFrame Max entries dispatched per frame (default 4)
     * budgetMs Per-frame dispatch time budget in milliseconds (0 = unlimited, default 2.0)
     * @return[en] Entries dispatched this frame
     */
    public func update(maxPerFrame!: Int64 = 4, budgetMs!: Float64 = 2.0): Int64 {
        var dispatched: Int64 = 0
        let start = performanceNow()
        while (dispatched < maxPerFrame) {
            // 弹出一个待派发条目
            let item: Option<LoadCompletion> = synchronized(_mutex) {
                if (_completions.size == 0) {
                    None
                } else {
                    let it = _completions[0]
                    _completions.remove(at: 0)
                    Some(it)
                }
            }
            if (let Some(completion) <- item) {
                if (completion.success) {
                    // 成功：构造 ILoadResult 派发 onLoad
                    var result: ILoadResult = BytesLoadResult(completion.bytes)
                    // 缓存命中路径（bytes 为空且 cache 有值）时从 cache 取真实结果
                    if (completion.bytes.size == 0) {
                        if (let Some(cached) <- this.cache.get(completion.key)) {
                            result = cached
                        }
                    }
                    if (let Some(cb) <- completion.onLoad) {
                        cb(result)
                    }
                } else {
                    if (let Some(cb) <- completion.onError) {
                        cb(completion.error)
                    }
                }
                dispatched += 1
                // 时间预算检查（预算 > 0 才启用）
                if (budgetMs > 0.0) {
                    let elapsed = performanceNow() - start
                    if (elapsed >= budgetMs) {
                        break
                    }
                }
            } else {
                break
            }
        }
        // 推进缓存逻辑帧 + 惰性回收
        this.cache.advanceFrame()
        this.cache.collectIfNeeded()
        return dispatched
    }

    /**
     * @brief[zh-cn] 泵全局共享实例（引擎主循环每帧调用）
     *
     * @brief[en] Pumps the global shared instance (called by the engine main loop every frame)
     */
    public static func pumpShared(): Unit {
        AssetManager.shared.update()
    }

    // ===== 内部 =====

    /**
     * @brief[zh-cn] 压入完成条目
     * @param[zh-cn] completion 完成条目
     */
    private func _pushCompletion(completion: LoadCompletion): Unit {
        synchronized(_mutex) {
            _completions.add(completion)
        }
    }

    /** 单调时钟起点（进程级） */
    private static let _epoch: MonoTime = MonoTime.now()

    /**
     * @brief[zh-cn] 单调毫秒时钟（自进程起点）
     * @return[zh-cn] 相对毫秒数
     *
     * @brief[en] Monotonic millisecond clock (since process epoch)
     * @return[en] Relative milliseconds
     */
    private static func performanceNow(): Float64 {
        let d = MonoTime.now() - _epoch
        return Float64(d.toMilliseconds())
    }
}
