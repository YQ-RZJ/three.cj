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
 * @file[zh-cn] safe.cj 可释放资源接口与 Safe 安全托管包装
 * @brief[zh-cn] 定义 IReleasable 可释放资源接口与 Safe<T> GC 兜底自动释放包装类
 * @explain[zh-cn] 本文件为 three.utils 包的包级锚文件（cjpm 目录扫描规则要求父目录
 *         至少存在一个 .cj 文件），同时定义了通用资源释放抽象：
 *         - IReleasable：需要手动释放资源的类实现的接口（releasable 可释放判据 + release 释放）；
 *         - Safe<T>：以组合方式接管 IReleasable 对象，保留主动 release() 的同时，
 *           经终结器（~init）实现 GC 回收兜底释放——开发者忘记手动释放时由 GC 代为释放。
 *         适用场景：仓颉语言约束"带终结器的类不可用 open 修饰"，因此需要保持 open
 *         可继承的资源类（如后处理 Pass 体系）无法自带终结器，可改为实现 IReleasable
 *         并交给 Safe<T> 托管，从而同时获得 open 继承能力与自动兜底释放。
 * @note[zh-cn] release() 要求实现为幂等操作（重复调用安全）；Safe<T> 内部以
 *         _released 标记防止手动释放后终结器二次释放。
 *
 * @file[en] safe.cj IReleasable resource interface and the Safe wrapper
 * @brief[en] Defines the IReleasable resource interface and the Safe<T> GC-fallback auto-release wrapper
 * @explain[en] This file is the package-level anchor file of three.utils (cjpm requires at
 *         least one .cj file in the parent directory for subpackage scanning), and also
 *         defines the generic resource-release abstraction:
 *         - IReleasable: the interface implemented by classes holding manually-released
 *           resources (releasable check + release);
 *         - Safe<T>: takes ownership of a IReleasable object by composition. Manual release()
 *           is preserved while a finalizer (~init) provides GC-collection fallback release —
 *           when the developer forgets to release manually, the GC does it.
 *         Applicability: the Cangjie language forbids open classes from having finalizers,
 *         so resource classes that must stay open for inheritance (e.g. the post-processing
 *         Pass family) cannot carry a finalizer themselves; they can implement IReleasable
 *         and be wrapped in Safe<T> to gain both open inheritance and automatic fallback release.
 * @note[en] release() implementations must be idempotent (safe to call repeatedly);
 *         Safe<T> keeps a _released flag to prevent a second release from the finalizer
 *         after a manual release.
 *
 * @package three.utils
 */
package three.utils.safe

/**
 * @brief[zh-cn] 可释放资源接口
 * @explain[zh-cn] 持有 GPU/系统句柄等需显式释放资源的类实现本接口，约定两个能力：
 *         - releasable：资源当前是否可释放（未释放且句柄可用），供守卫 release() 调用；
 *         - release()：主动释放资源，返回是否本次真正执行了释放。
 * @note[zh-cn] 实现要求：
 *         1. release() 必须幂等——重复调用应直接返回 false，不得二次释放句柄；
 *         2. release() 后 releasable 应返回 false；
 *         3. 释放动作应能在终结器上下文中安全执行（不依赖调用线程）。
 *         配合 Safe<T> 使用可实现"主动释放 + GC 兜底"双保险。
 *
 * @brief[en] IReleasable resource interface
 * @explain[en] Classes holding resources that require explicit release (GPU/system handles
 *         etc.) implement this interface with two capabilities:
 *         - releasable: whether the resource is currently releasable (not released and
 *           handles held), guarding release() calls;
 *         - release(): releases the resource, returning whether this call actually released.
 * @note[en] Implementation requirements:
 *         1. release() must be idempotent — repeat calls return false and never free a
 *            handle twice;
 *         2. after release(), releasable must return false;
 *         3. the release action must be safe to execute in a finalizer context
 *            (no dependence on the calling thread).
 *         Combined with Safe<T>, this yields "manual release + GC fallback" double safety.
 */
public interface IReleasable {
    /**
     * @brief[zh-cn] 资源当前是否可释放（未被释放且仍持有底层资源）
     * @explain[zh-cn] 命名为 releasable 而非 releasable：本接口管理的是"释放生命周期"，
     *         该属性回答"现在调用 release() 是否仍有意义"，与 release() 的幂等返回
     *         呼应；"有效性"是更宽的概念（如 GPU 设备丢失导致的失效并未释放），
     *         不属于本接口职责。release() 后应返回 false。
     * @return[zh-cn] true 表示仍持有资源、release() 有意义；false 表示已释放或句柄已失效
     *
     * @brief[en] Whether the resource is currently releasable (not released and still
     *            holding underlying resources)
     * @explain[en] Named releasable rather than releasable: this interface manages the
     *         release lifecycle — the property answers "is calling release() still
     *         meaningful now", echoing the idempotent return of release(). "Validity"
     *         is a broader concept (e.g. invalidation from GPU device loss without a
     *         release) and is not this interface's responsibility. Must return false
     *         after release().
     * @return[en] true if resources are still held and release() is meaningful;
     *             false if released or the handle is gone
     */
    prop releasable: Bool {
        /* 默认实现：资源在 release() 前视为可释放。
         * Default: the resource is considered releasable until release() is called.
         */
        get() { return true }
    }

    /**
     * @brief[zh-cn] 主动释放资源
     * @return[zh-cn] 本次调用真正执行了释放时返回 true；资源此前已释放（幂等命中）返回 false
     * @note[zh-cn] 实现必须幂等：重复调用安全，不得二次释放底层句柄
     *
     * @brief[en] Releases the resource explicitly
     * @return[en] true if this call actually released; false if already released (idempotent hit)
     * @note[en] Implementations must be idempotent: repeated calls are safe and never
     *           free the underlying handles twice
     */
    func release(): Bool
}

/**
 * @brief[zh-cn] IReleasable 对象的安全托管包装
 * @explain[zh-cn] 以组合方式接管一个 IReleasable 对象的生命周期：
 *         - 主动路径：开发者可随时调用 release() 显式释放（幂等，重复调用返回 false）；
 *         - 兜底路径：开发者忘记释放时，Safe<T> 被GC 回收，其终结器（~init）代为调用
 *           value.release()——资源不因遗忘而泄漏；
 *         - 防重路径：内部 _released 标记保证"手动释放 + 终结器兜底"全程至多释放一次。
 * @note[zh-cn] 本类刻意保持非 open（仓颉语言约束：带终结器的类不可 open），
 *         需要继承扩展时请继承被托管的资源类而非本包装。
 * @note[zh-cn] 终结器触发时机不确定（可能在任意线程延迟触发），故 release() 实现必须
 *         幂等且线程安全；被托管对象在终结器触发前仍可正常使用。
 * @example[zh-cn] Safe 托管一个 IReleasable 资源
 *         let safe = Safe(myRenderTarget)   // myRenderTarget 实现 IReleasable
 *         safe.value.resize(1920, 1080)     // 经 value 正常使用
 *         if (safe.releasable) { ... }      // 可释放才释放
 *         safe.release()                    // 主动释放（可选；忘写则 GC 兜底）
 *
 * @brief[en] Safe ownership wrapper for a IReleasable object
 * @explain[en] Takes over a IReleasable object's lifecycle by composition:
 *         - manual path: the developer may call release() at any time (idempotent,
 *           repeat calls return false);
 *         - fallback path: if the developer forgets, Safe<T>'s finalizer (~init) calls
 *           value.release() when the wrapper itself is GC-collected — no leak by omission;
 *         - once-only path: the internal _released flag guarantees at most one release
 *           across "manual release + finalizer fallback".
 * @note[en] This class is deliberately non-open (Cangjie constraint: classes with
 *         finalizers cannot be open); to extend via inheritance, subclass the wrapped
 *         resource class, not this wrapper.
 * @note[en] Finalizer timing is indeterminate (may fire late on any thread), so release()
 *         implementations must be idempotent and thread-safe; the wrapped object remains
 *         fully usable until the finalizer fires.
 * @example[en] Safe wrapping a IReleasable resource
 *         let safe = Safe(myRenderTarget)   // myRenderTarget implements IReleasable
 *         safe.value.resize(1920, 1080)     // use normally via value
 *         if (safe.releasable) { ... }      // guard before release
 *         safe.release()                    // explicit release (optional; GC fallback otherwise)
 */
public class Safe<T> <: IReleasable where T <: IReleasable {
    /**
     * @brief[zh-cn] 被安全接管的资源对象实例
     * @explain[zh-cn] 经此字段以原类型正常使用对象；释放请走 Safe.release() 或依赖兜底。
     *
     * @brief[en] The wrapped resource object instance
     * @explain[en] Use the object via this field with its original type; release through
     *              Safe.release() or rely on the fallback.
     */
    public let value: T

    /**
     * @brief[zh-cn] 是否已释放（手动或终结器任一路径触发后置 true）
     * @explain[zh-cn] 保证"主动释放 + GC 兜底"全程至多执行一次底层释放。
     *
     * @brief[en] Whether the resource has been released (set by either the manual or
     *            the finalizer path)
     * @explain[en] Guarantees the underlying release runs at most once across
     *              "manual release + GC fallback".
     */
    private var _released: Bool = false

    /**
     * @brief[zh-cn] 创建托管包装，接管 obj 的释放职责
     * @param[zh-cn] obj 待托管的 IReleasable 资源对象（此后其释放由本包装负责）
     *
     * @brief[en] Creates the wrapper and takes over obj's release responsibility
     * @param[en] obj The IReleasable resource object to wrap (its release is now owned by this wrapper)
     */
    public init(obj: T) {
        this.value = obj
    }

    /**
     * @brief[zh-cn] 被托管资源当前是否可释放
     * @explain[zh-cn] 包装已释放或资源自身已不可释放（value.releasable 为 false）时返回
     *         false，否则返回 true。
     *
     * @brief[en] Whether the wrapped resource is currently releasable
     * @explain[en] false if the wrapper has released or the resource itself is no longer
     *              releasable (value.releasable is false); true otherwise
     */
    public prop releasable: Bool {
        get() { !this._released && this.value.releasable }
    }

    /**
     * @brief[zh-cn] 主动释放被托管资源（幂等）
     * @return[zh-cn] 本次调用真正执行了释放返回 true；此前已释放（手动或兜底）返回 false
     * @note[zh-cn] 主动释放后终结器兜底不再重复执行；释放后请勿再经 value 使用资源
     *         （可用 releasable 判断）。
     *
     * @brief[en] Releases the wrapped resource explicitly (idempotent)
     * @return[en] true if this call actually released; false if already released
     *             (manually or by the fallback)
     * @note[en] After an explicit release the finalizer fallback will not run again;
     *           do not use the resource via value afterwards (check releasable).
     */
    public func release(): Bool {
        if (this._released) {
            return false
        }
        this._released = true
        return this.value.release()
    }

    /**
     * @brief[zh-cn] 终结器：GC 回收兜底释放（开发者忘记调用 release() 时由 GC 代为释放）
     * @explain[zh-cn] 经 _released 标记防止与手动释放路径重复执行；Safe<T> 保持非 open
     *         （仓颉语言约束：带终结器的类不可 open）。
     *
     * @brief[en] Finalizer: GC-collection fallback release (GC releases on the developer's behalf
     *            when release() was never called)
     * @explain[en] The _released flag prevents double execution against the manual path;
     *              Safe<T> stays non-open (Cangjie constraint: classes with finalizers cannot be open).
     */
    ~init() {
        if (!this._released) {
            this._released = true
            this.value.release()
        }
    }
}
