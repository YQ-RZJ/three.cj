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
 * @file[zh-cn] UiPayload.cj — ImGui 拖放载荷
 * @brief[zh-cn] 封装 ImGuiPayload，提供拖放数据查询接口
 * @explain[zh-cn] 用法示例：
 *   // 在 UiDragDropTarget 内：
 *   let payload = UiPayload.getCurrentPayload()
 *   if (payload.isValid() && payload.isDataType("MY_TYPE")) { ... }
 *
 * @file[en] UiPayload.cj — ImGui Drag & Drop Payload
 * @brief[en] Wraps ImGuiPayload for drag-drop data queries
 * @explain[en] Usage example:
 *   // Inside UiDragDropTarget:
 *   let payload = UiPayload.getCurrentPayload()
 *   if (payload.isValid() && payload.isDataType("MY_TYPE")) { ... }
 * @explain[en] Usage example:
 *   // Inside UiDragDropTarget:
 *   let payload = UiPayload.getCurrentPayload()
 *   if (payload.isValid() && payload.isDataType("MY_TYPE")) { ... }
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// =============================================================================
// UiPayload — 拖放载荷查询
// Drag & Drop Payload Query
// =============================================================================

/**
 * @brief[zh-cn] 拖放载荷包装器
 * @explain[zh-cn] 封装 ImGuiPayload 的只读查询方法。
 *         通过 igAcceptDragDropPayload 获取后使用。
 *
 * @brief[en] Drag & drop payload wrapper
 * @explain[en] Wraps ImGuiPayload read-only query methods.
 *         Use after obtaining via igAcceptDragDropPayload.
 */
public class UiPayload {
    private var _payload: CPointer<Unit>

    public init(payloadPtr: CPointer<Unit>) { this._payload = payloadPtr }

    /**
     * @brief[zh-cn] 获取当前活跃的拖放载荷（在 BeginDragDropTarget/EndDragDropTarget 内调用）
     *
     * @brief[en] Gets the current active drag-drop payload (call inside BeginDragDropTarget/EndDragDropTarget)
     */
    public static func getCurrentPayload(): UiPayload {
        return UiPayload(igGetDragDropPayload_cj())
    }

    /**
     * @brief[zh-cn] 载荷是否有效
     *
     * @brief[en] Whether the payload is valid
     */
    public func isValid(): Bool {
        return !this._payload.isNull()
    }

    /**
     * @brief[zh-cn] 载荷数据类型是否匹配
     * @param[zh-cn] dataType 数据类型字符串（如 "MY_TYPE"）
     * @return[zh-cn] 是否匹配
     *
     * @brief[en] Whether the payload data type matches
     * @param[en] dataType Data type string (e.g. "MY_TYPE")
     * @return[en] Whether it matches
     */
    public func isDataType(dataType: String): Bool {
        if (this._payload.isNull()) { return false }
        let cs = unsafe { LibC.mallocCString(dataType) }
        let r = ImGuiPayload_IsDataType_cj(this._payload, cs)
        unsafe { LibC.free(cs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 是否为预览状态（拖拽过程中悬停在目标上）
     *
     * @brief[en] Whether in preview state (hovering over target during drag)
     */
    public func isPreview(): Bool {
        if (this._payload.isNull()) { return false }
        return ImGuiPayload_IsPreview_cj(this._payload) != 0
    }

    /**
     * @brief[zh-cn] 是否为交付状态（释放完成）
     *
     * @brief[en] Whether in delivery state (drop completed)
     */
    public func isDelivery(): Bool {
        if (this._payload.isNull()) { return false }
        return ImGuiPayload_IsDelivery_cj(this._payload) != 0
    }

    /**
     * @brief[zh-cn] 清空载荷数据
     *
     * @brief[en] Clears the payload data
     */
    public func clear(): Unit {
        if (!this._payload.isNull()) { ImGuiPayload_Clear_cj(this._payload) }
    }
}
