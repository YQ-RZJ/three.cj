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
 * @file[zh-cn] UiPopup.cj — ImGui 弹出窗口组件
 * @brief[zh-cn] 封装 ImGui 弹出窗口 API：BeginPopup、BeginPopupModal、OpenPopup 等
 * @explain[zh-cn] 提供 UiPopup、UiPopupModal、UiOpenPopup、UiCloseCurrentPopup、UiEndPopup 五个弹出窗口控件。用法示例：
 *   UiWindow("Popup Demo").draw({ =>
 *       if (UiButton("Open Popup").draw()) { UiOpenPopup("MyPopup") }
 *       UiPopup("MyPopup").draw({ =>
 *           UiText("Popup content!")
 *           UiButton("Close").draw()
 *       })
 *       UiPopupModal("Modal Dialog", { =>
 *           UiText("This is a modal dialog")
 *           UiButton("OK").draw()
 *       })
 *   })
 *
 * @file[en] UiPopup.cj — ImGui Popup Components
 * @brief[en] Wrappers for ImGui popup API: BeginPopup, BeginPopupModal, OpenPopup etc.
 * @explain[en] Provides UiPopup, UiPopupModal, UiOpenPopup, UiCloseCurrentPopup, UiEndPopup — five popup-related widgets.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.PtrArray

// =============================================================================
// UiPopup — 普通弹出窗口
// =============================================================================

/**
 * @brief[zh-cn] 普通弹出窗口控件
 *
 * @brief[en] Regular popup window widget
 */
public class UiPopup <: UiWidget {
    private var _id: String
    private var _flags: Int32
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造普通弹出窗口
     * @param[zh-cn] id 弹出窗口 ID
     * @param[zh-cn] flags 弹出窗口标志（默认 0）
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a regular popup window
     * @param[en] id Popup ID
     * @param[en] flags Popup flags (default 0)
     * @param[en] content Child content drawing closure
     */
    public init(id!: String, flags!: Int32 = 0, content!: () -> Unit) {
        super()
        this._id = id
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制弹出窗口
     * @explain[zh-cn] 调用 ImGui BeginPopup/EndPopup 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the popup window
     * @explain[en] Wraps child content with ImGui BeginPopup/EndPopup.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._id) }
        if (igBeginPopup_cj(cs, this._flags) != 0) {
            this._content()
            igEndPopup_cj()
        }
        unsafe { LibC.free(cs) }
        return false
    }
}

// =============================================================================
// UiPopupModal — 模态弹出窗口
// =============================================================================

/**
 * @brief[zh-cn] 模态弹出窗口控件（阻塞交互）
 *
 * @brief[en] Modal popup window widget (blocks interaction)
 */
public class UiPopupModal <: UiWidget {
    private var _name: String
    private var _open: Option<PtrArray<Int32>>
    private var _flags: Int32
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造模态弹出窗口（不绑定外部打开状态）
     * @param[zh-cn] name 窗口名称
     * @param[zh-cn] content 子内容绘制闭包
     * @param[zh-cn] flags 模态窗口标志（默认 0）
     *
     * @brief[en] Constructs a modal popup window (without an external open state)
     * @param[en] name Window name
     * @param[en] content Child content drawing closure
     * @param[en] flags Modal window flags (default 0)
     */
    public init(name!: String, content!: () -> Unit,
                flags!: Int32 = 0) {
        super()
        this._name = name
        this._open = None
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 构造绑定外部打开状态的模态弹出窗口
     * @param[zh-cn] name 窗口名称
     * @param[zh-cn] open 外部打开状态指针（点击关闭按钮时写入 0）
     * @param[zh-cn] content 子内容绘制闭包
     * @param[zh-cn] flags 模态窗口标志（默认 0）
     *
     * @brief[en] Constructs a modal popup window bound to an external open state
     * @param[en] name Window name
     * @param[en] open External open state pointer (writes 0 when the close button is clicked)
     * @param[en] content Child content drawing closure
     * @param[en] flags Modal window flags (default 0)
     */
    public init(name!: String, open!: PtrArray<Int32>,
                content!: () -> Unit, flags!: Int32 = 0) {
        super()
        this._name = name
        this._open = Some(open)
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制模态弹出窗口
     * @explain[zh-cn] 调用 ImGui BeginPopupModal/EndPopup 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the modal popup window
     * @explain[en] Wraps child content with ImGui BeginPopupModal/EndPopup.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let openPtr = match (this._open) {
            case Some(p) => p.data()
            case None => CPointer<Int32>()
        }
        let cs = unsafe { LibC.mallocCString(this._name) }
        let r = igBeginPopupModal_cj(cs, openPtr, this._flags) != 0
        unsafe { LibC.free(cs) }
        if (r) {
            this._content()
            igEndPopup_cj()
        }
        return false
    }
}

// =============================================================================
// UiOpenPopup — 打开弹出窗口
// =============================================================================

/**
 * @brief[zh-cn] 打开弹出窗口控件
 *
 * @brief[en] Open popup widget
 */
public class UiOpenPopup <: UiWidget {
    private var _id: String
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造打开弹出窗口控件
     * @param[zh-cn] id 弹出窗口 ID
     * @param[zh-cn] flags 弹出窗口标志（默认 0）
     *
     * @brief[en] Constructs an open-popup widget
     * @param[en] id Popup ID
     * @param[en] flags Popup flags (default 0)
     */
    public init(id!: String, flags!: Int32 = 0) { super(); this._id = id; this._flags = flags }

    /**
     * @brief[zh-cn] 打开指定弹出窗口
     * @explain[zh-cn] 调用 ImGui OpenPopup。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Opens the specified popup
     * @explain[en] Calls ImGui OpenPopup.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._id) }
        igOpenPopup_Str_cj(cs, this._flags)
        unsafe { LibC.free(cs) }
        return false
    }
}

// =============================================================================
// UiCloseCurrentPopup — 关闭当前弹出窗口
// =============================================================================

/**
 * @brief[zh-cn] 关闭当前弹出窗口控件
 *
 * @brief[en] Close current popup widget
 */
public class UiCloseCurrentPopup <: UiWidget {
    /**
     * @brief[zh-cn] 构造关闭当前弹出窗口控件
     *
     * @brief[en] Constructs a close-current-popup widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 关闭当前打开的弹出窗口
     * @explain[zh-cn] 调用 ImGui CloseCurrentPopup。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Closes the currently open popup
     * @explain[en] Calls ImGui CloseCurrentPopup.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        igCloseCurrentPopup_cj()
        return false
    }
}

// =============================================================================
// UiEndPopup — 结束弹出窗口（手动调用）
// =============================================================================

/**
 * @brief[zh-cn] 结束弹出窗口控件
 *
 * @brief[en] End popup widget
 */
public class UiEndPopup <: UiWidget {
    /**
     * @brief[zh-cn] 构造结束弹出窗口控件
     *
     * @brief[en] Constructs an end-popup widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 结束当前弹出窗口
     * @explain[zh-cn] 调用 ImGui EndPopup（适用于手动调用场景）。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Ends the current popup
     * @explain[en] Calls ImGui EndPopup (for manual usage scenarios).
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        igEndPopup_cj()
        return false
    }
}
