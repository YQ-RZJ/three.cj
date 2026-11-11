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
 * @file[zh-cn] UiInputCallback.cj — ImGui 输入文本回调数据
 * @brief[zh-cn] 封装 ImGuiInputTextCallbackData，支持输入框回调内的文本操作
 * @explain[zh-cn] 用法示例：
 *   // 在自定义 UiInputText 的回调中：
 *   let cb = UiInputTextCallback(callbackDataPtr)
 *   cb.selectAll()
 *   cb.insertChars(0, "prefix_")
 *
 * @file[en] UiInputCallback.cj — ImGui Input Text Callback Data
 * @brief[en] Wraps ImGuiInputTextCallbackData for text operations inside input callbacks
 * @explain[en] Usage example:
 *   // In a custom UiInputText callback:
 *   let cb = UiInputTextCallback(callbackDataPtr)
 *   cb.selectAll()
 *   cb.insertChars(0, "prefix_")
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.VoidPtr

// =============================================================================
// UiInputTextCallback — 输入文本回调数据
// Input Text Callback Data
// =============================================================================

/**
 * @brief[zh-cn] 输入文本回调数据包装器
 * @explain[zh-cn] 封装 ImGuiInputTextCallbackData 的文本操作方法。
 *         在 igInputText 的回调函数内通过回调参数获取。
 *
 * @brief[en] Input text callback data wrapper
 * @explain[en] Wraps ImGuiInputTextCallbackData text operation methods.
 *         Obtained via callback parameter inside igInputText callback.
 */
public class UiInputTextCallback {
    private var _data: CPointer<Unit>

    /**
     * @brief[zh-cn] 使用底层回调数据指针构造包装器
     * @param[zh-cn] dataPtr 底层 ImGuiInputTextCallbackData 指针
     *
     * @brief[en] Constructs a wrapper with the underlying callback data pointer
     * @param[en] dataPtr Underlying ImGuiInputTextCallbackData pointer
     */
    public init(dataPtr: VoidPtr) { this._data = dataPtr.value }

    /**
     * @brief[zh-cn] 底层指针是否有效
     *
     * @brief[en] Whether the underlying pointer is valid
     */
    public func isValid(): Bool { return !this._data.isNull() }

    /**
     * @brief[zh-cn] 全选文本
     *
     * @brief[en] Selects all text
     */
    public func selectAll(): Unit {
        if (!this._data.isNull()) { ImGuiInputTextCallbackData_SelectAll_cj(this._data) }
    }

    /**
     * @brief[zh-cn] 清除选区
     *
     * @brief[en] Clears the selection
     */
    public func clearSelection(): Unit {
        if (!this._data.isNull()) { ImGuiInputTextCallbackData_ClearSelection_cj(this._data) }
    }

    /**
     * @brief[zh-cn] 是否有选中文本
     *
     * @brief[en] Whether there is selected text
     */
    public func hasSelection(): Bool {
        if (this._data.isNull()) { return false }
        return ImGuiInputTextCallbackData_HasSelection_cj(this._data) != 0
    }

    /**
     * @brief[zh-cn] 设置选区范围
     * @param[zh-cn] start 起始位置
     * @param[zh-cn] end_ 结束位置
     *
     * @brief[en] Sets the selection range
     * @param[en] start Start position
     * @param[en] end_ End position
     */
    public func setSelection(start: Int32, end_ : Int32): Unit {
        if (!this._data.isNull()) { ImGuiInputTextCallbackData_SetSelection_cj(this._data, start, end_) }
    }

    /**
     * @brief[zh-cn] 删除指定范围的字符
     * @param[zh-cn] pos 起始位置
     * @param[zh-cn] bytesCount 删除的字节数
     *
     * @brief[en] Deletes characters in the specified range
     * @param[en] pos Start position
     * @param[en] bytesCount Number of bytes to delete
     */
    public func deleteChars(pos: Int32, bytesCount: Int32): Unit {
        if (!this._data.isNull()) { ImGuiInputTextCallbackData_DeleteChars_cj(this._data, pos, bytesCount) }
    }

    /**
     * @brief[zh-cn] 在指定位置插入文本
     * @param[zh-cn] pos 插入位置
     * @param[zh-cn] text 要插入的文本
     *
     * @brief[en] Inserts text at the specified position
     * @param[en] pos Insertion position
     * @param[en] text Text to insert
     */
    public func insertChars(pos: Int32, text: String): Unit {
        if (this._data.isNull() || text.isEmpty()) { return }
        let cs = unsafe { LibC.mallocCString(text) }
        let csEnd = CString(CPointer<UInt8>())
        ImGuiInputTextCallbackData_InsertChars_cj(this._data, pos, cs, csEnd)
        unsafe { LibC.free(cs) }
    }

    // ===== 字段访问（@C struct 指针重解释，见 imgui4cj types.cj） =====

    /**
     * @brief[zh-cn] 回调事件类型（ImGuiInputTextFlags_Callback*，只读）
     *
     * @brief[en] Callback event type (ImGuiInputTextFlags_Callback*, read-only)
     */
    public func getEventFlag(): Int32 { return ImGui_InputTextData_GetEventFlag_cj(this._data) }

    /**
     * @brief[zh-cn] 事件键（ImGuiKey，只读）
     *
     * @brief[en] Event key (ImGuiKey, read-only)
     */
    public func getEventKey(): Int32 { return ImGui_InputTextData_GetEventKey_cj(this._data) }

    /**
     * @brief[zh-cn] 输入字符（[CharFilter] 可读写：替换字符或置 0 丢弃）
     *
     * @brief[en] Event character ([CharFilter] read-write: replace, or 0 to drop)
     */
    public func getEventChar(): UInt16 { return ImGui_InputTextData_GetEventChar_cj(this._data) }

    /**
     * @brief[zh-cn] 设置输入字符（置 0 表示丢弃该字符）
     * @param[zh-cn] c 新字符
     *
     * @brief[en] Sets the event character (0 to drop it)
     * @param[en] c New character
     */
    public func setEventChar(c: UInt16): Unit { ImGui_InputTextData_SetEventChar_cj(this._data, c) }

    /**
     * @brief[zh-cn] 文本缓冲指针（internal：仅供包内 FFI 桥接使用）
     * @explain[zh-cn] 公开面请使用 getBufText() 读取缓冲内容——本方法暴露裸指针，
     *             直接写入可能破坏 ImGui 缓冲区不变量（长度/容量/终止符）。
     *
     * @brief[en] Text buffer pointer (internal: for package-internal FFI bridging only)
     * @explain[en] Use getBufText() in public code to read buffer contents — this method
     *             exposes a raw pointer; writing it directly may break ImGui buffer
     *             invariants (length/capacity/terminator).
     */
    internal func getBuf(): CPointer<UInt8> { return ImGui_InputTextData_GetBuf_cj(this._data) }

    /**
     * @brief[zh-cn] 文本长度（不含 '\0'）
     *
     * @brief[en] Text length (excluding the terminating '\0')
     */
    public func getBufTextLen(): Int32 { return ImGui_InputTextData_GetBufTextLen_cj(this._data) }

    /**
     * @brief[zh-cn] 缓冲容量（含 '\0' 存储位，只读）
     *
     * @brief[en] Buffer capacity (including '\0' storage, read-only)
     */
    public func getBufSize(): Int32 { return ImGui_InputTextData_GetBufSize_cj(this._data) }

    /**
     * @brief[zh-cn] 读取缓冲区当前内容为仓颉字符串
     * @return[zh-cn] 缓冲区文本（缓冲为空时为空字符串）
     *
     * @brief[en] Reads the current buffer contents as a Cangjie string
     * @return[en] Buffer text (empty string when the buffer is null)
     */
    public func getBufText(): String {
        let p = this.getBuf()
        if (p.isNull()) { return "" }
        return unsafe { CString(CPointer<UInt8>(CPointer<Unit>(p))).toString() }
    }

    /**
     * @brief[zh-cn] 光标位置
     *
     * @brief[en] Cursor position
     */
    public func getCursorPos(): Int32 { return ImGui_InputTextData_GetCursorPos_cj(this._data) }

    /**
     * @brief[zh-cn] 设置光标位置
     * @param[zh-cn] pos 光标位置
     *
     * @brief[en] Sets the cursor position
     * @param[en] pos Cursor position
     */
    public func setCursorPos(pos: Int32): Unit { ImGui_InputTextData_SetCursorPos_cj(this._data, pos) }

    /**
     * @brief[zh-cn] 选区起点（== selectionEnd 时无选区）
     *
     * @brief[en] Selection start (== selection end when no selection)
     */
    public func getSelectionStart(): Int32 { return ImGui_InputTextData_GetSelectionStart_cj(this._data) }

    /**
     * @brief[zh-cn] 选区终点
     *
     * @brief[en] Selection end
     */
    public func getSelectionEnd(): Int32 { return ImGui_InputTextData_GetSelectionEnd_cj(this._data) }

    /**
     * @brief[zh-cn] 设置选区（同时移动光标到终点）
     * @param[zh-cn] start 起点
     * @param[zh-cn] end_ 终点
     *
     * @brief[en] Sets the selection (moves cursor to end)
     * @param[en] start Start
     * @param[en] end_ End
     */
    public func setSelectionRange(start: Int32, end_: Int32): Unit {
        ImGui_InputTextData_SetSelection_cj(this._data, start, end_)
    }
}
