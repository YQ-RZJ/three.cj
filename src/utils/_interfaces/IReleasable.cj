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
 * @file[zh-cn] IReleasable 可释放资源接口（自 three.utils.safe 迁入本接口包）
 * @brief[zh-cn] 需手动释放资源的类的公共契约，经实现包重导出为 three.utils.safe.IReleasable
 * @explain[zh-cn] 按 C9 约定收纳于 utils/interfaces（protected 包），实现方（Safe、AudioContext 等）经 safe 包重导出路径访问。
 *
 * @file[en] IReleasable  Releasable-resource interface (moved from three.utils.safe into this interface package)
 * @brief[en] The common contract of classes holding manually-released resources, re-exported by the implementation package as three.utils.safe.IReleasable
 * @explain[en] Collected into utils/interfaces per C9 (protected package); implementers (Safe, AudioContext etc.) access it via the safe package re-export path.
 */
protected package three.utils._interfaces

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
