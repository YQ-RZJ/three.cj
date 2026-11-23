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
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] ViewRegistry 视图 id 登记表
 * @brief[zh-cn] 渲染视图 id 的集中治理（保留位 + 动态分配池）
 * @explain[zh-cn] 把原先散落各处的隐式 view id 约定收敛为单一登记处：
 * - VIEW_MAIN = 0：主渲染视图（ThreeRenderer）；
 * - VIEW_UI = 1：UI 叠加视图（UiContext）；
 * - [VIEW_POST_BASE, VIEW_XR_BASE) = [2, 64)：后处理视图池（EffectComposer/pass）；
 * - [VIEW_XR_BASE, VIEW_MAX) = [64, 256)：XR 扩展区间。
 * acquire 以 owner 名称登记（"main"/"ui" 命中保留位，其余从池中首次适配），
 * 池耗尽返回 INVALID_VIEW 并记错误日志。初始分配表与既有隐式约定完全一致。
 *
 * @file[en] ViewRegistry view id registry
 * @brief[en] Centralized governance of render view ids (reserved slots + dynamic pool)
 * @explain[en] Consolidates the previously scattered implicit view id conventions
 * into a single registry:
 * - VIEW_MAIN = 0: main render view (ThreeRenderer);
 * - VIEW_UI = 1: UI overlay view (UiContext);
 * - [VIEW_POST_BASE, VIEW_XR_BASE) = [2, 64): post-processing view pool
 *   (EffectComposer/passes);
 * - [VIEW_XR_BASE, VIEW_MAX) = [64, 256): XR extension range.
 * acquire registers by owner name ("main"/"ui" hit reserved slots; others are
 * first-fit from the pool); pool exhaustion returns INVALID_VIEW with an error
 * log. The initial allocation table matches the existing implicit conventions
 * exactly.
 *
 * @package three
 */
package three.renderers.common

import std.sync.Mutex
import three.utils.log.*
import three.utils.log.macros.*

protected class ViewRegistry {
    /** 主渲染视图（保留位） */
    protected static let VIEW_MAIN: UInt16 = 0u16
    /** UI 叠加视图（保留位） */
    protected static let VIEW_UI: UInt16 = 1u16
    /** 后处理视图池起始（含） */
    protected static let VIEW_POST_BASE: UInt16 = 2u16
    /** XR 区间起始（含）；同时也是后处理池结束（不含） */
    protected static let VIEW_XR_BASE: UInt16 = 64u16
    /** 视图 id 上限（不含） */
    protected static let VIEW_MAX: UInt16 = 256u16
    /** 无效视图 id */
    protected static let INVALID_VIEW: UInt16 = 0xFFFFu16

    private static let lock = Mutex()

    /** 各视图槽位的登记名（None = 空闲） */
    private static var owners: Array<Option<String>> = Array<Option<String>>(256, repeat: None)

    /**
     * 登记并获取一个视图 id。
     * owner 为 "main"/"ui" 时返回对应保留位；否则在 [VIEW_POST_BASE, VIEW_MAX)
     * 区间首次适配空闲槽位。池耗尽返回 INVALID_VIEW 并记错误日志。
     */
    protected static func acquire(owner: String): UInt16 {
        synchronized(lock) {
            match (owner) {
                case "main" =>
                    owners[Int64(VIEW_MAIN)] = Some(owner)
                    return VIEW_MAIN
                case "ui" =>
                    owners[Int64(VIEW_UI)] = Some(owner)
                    return VIEW_UI
                case _ =>
                    var slot = Int64(VIEW_POST_BASE)
                    while (slot < Int64(VIEW_MAX)) {
                        if (owners[slot] == None) {
                            owners[slot] = Some(owner)
                            return UInt16(slot)
                        }
                        slot += 1
                    }
            }
        }
        @LogError(["ViewRegistry", "view id pool exhausted (max=${VIEW_MAX}), acquire('${owner}') failed"])
        return INVALID_VIEW
    }

    /** 释放视图 id（保留位仅清除登记，不参与复用语义变化）。 */
    protected static func release(viewId: UInt16): Unit {
        if (viewId == INVALID_VIEW) {
            return
        }
        synchronized(lock) {
            owners[Int64(viewId)] = None
        }
    }

    /** 查询视图 id 的登记名（调试输出；未登记返回 "<free>"）。 */
    protected static func name(viewId: UInt16): String {
        if (viewId == INVALID_VIEW || Int64(viewId) >= Int64(VIEW_MAX)) {
            return "<invalid>"
        }
        synchronized(lock) {
            match (owners[Int64(viewId)]) {
                case Some(owner) => owner
                case None => "<free>"
            }
        }
    }
}
