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
 * @file[zh-cn] UiTab.cj — ImGui 标签页组件
 * @brief[zh-cn] 封装 ImGui 标签页 API：BeginTabBar/EndTabBar、BeginTabItem/EndTabItem
 * @explain[zh-cn] 提供 UiTabBar、UiTabItem、UiTabItemButton、UiSetTabItemClosed 四个标签页控件。用法示例：
 *   UiTabBar("MyTabBar").draw({ =>
 *       UiTabItem("General", { => UiText("General settings here") })
 *       UiTabItem("Advanced", { => UiText("Advanced settings here") })
 *       UiTabItemButton("Add Tab")
 *   })
 *
 * @file[en] UiTab.cj — ImGui Tab Components
 * @brief[en] Wrappers for ImGui tab API: BeginTabBar/EndTabBar, BeginTabItem/EndTabItem
 * @explain[en] Provides UiTabBar, UiTabItem, UiTabItemButton, UiSetTabItemClosed — four tab-related widgets.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.PtrArray

// =============================================================================
// UiTabBar — 标签栏容器
// =============================================================================

/**
 * @brief[zh-cn] 标签栏容器控件
 *
 * @brief[en] Tab bar container widget
 */
public class UiTabBar <: UiWidget {
    private var _id: String
    private var _flags: Int32
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造标签栏容器
     * @param[zh-cn] id 标签栏 ID
     * @param[zh-cn] flags 标签栏标志（默认 0）
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a tab bar container
     * @param[en] id Tab bar ID
     * @param[en] flags Tab bar flags (default 0)
     * @param[en] content Child content drawing closure
     */
    public init(id!: String, flags!: Int32 = 0, content!: () -> Unit) {
        super()
        this._id = id
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制标签栏
     * @explain[zh-cn] 调用 ImGui BeginTabBar/EndTabBar 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the tab bar
     * @explain[en] Wraps child content with ImGui BeginTabBar/EndTabBar.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._id) }
        let r = igBeginTabBar_cj(cs, this._flags) != 0
        unsafe { LibC.free(cs) }
        if (r) {
            this._content()
            igEndTabBar_cj()
        }
        return false
    }
}

// =============================================================================
// UiTabItem — 标签页
// =============================================================================

/**
 * @brief[zh-cn] 标签页控件
 *
 * @brief[en] Tab item widget
 */
public class UiTabItem <: UiWidget {
    private var _label: String
    private var _open: Option<PtrArray<Int32>>
    private var _flags: Int32
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造标签页（不绑定外部打开状态）
     * @param[zh-cn] label 标签页标题
     * @param[zh-cn] content 子内容绘制闭包
     * @param[zh-cn] flags 标签页标志（默认 0）
     *
     * @brief[en] Constructs a tab item (without an external open state)
     * @param[en] label Tab title
     * @param[en] content Child content drawing closure
     * @param[en] flags Tab flags (default 0)
     */
    public init(label!: String, content!: () -> Unit, flags!: Int32 = 0) {
        super()
        this._label = label
        this._open = None
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 构造绑定外部打开状态的标签页
     * @param[zh-cn] label 标签页标题
     * @param[zh-cn] open 外部打开状态指针（关闭时写入 0）
     * @param[zh-cn] content 子内容绘制闭包
     * @param[zh-cn] flags 标签页标志（默认 0）
     *
     * @brief[en] Constructs a tab item bound to an external open state
     * @param[en] label Tab title
     * @param[en] open External open state pointer (writes 0 when closed)
     * @param[en] content Child content drawing closure
     * @param[en] flags Tab flags (default 0)
     */
    public init(label!: String, open!: PtrArray<Int32>,
                content!: () -> Unit, flags!: Int32 = 0) {
        super()
        this._label = label
        this._open = Some(open)
        this._flags = flags
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制标签页
     * @explain[zh-cn] 调用 ImGui BeginTabItem/EndTabItem 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the tab item
     * @explain[en] Wraps child content with ImGui BeginTabItem/EndTabItem.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let openPtr: CPointer<Int32> = match (this._open) {
            case Some(p) => p.data()
            case None => CPointer<Int32>()
        }
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igBeginTabItem_cj(cs, openPtr, this._flags) != 0
        unsafe { LibC.free(cs) }
        if (r) {
            this._content()
            igEndTabItem_cj()
        }
        return false
    }
}

// =============================================================================
// UiTabItemButton — 标签栏按钮
// =============================================================================

/**
 * @brief[zh-cn] 标签栏按钮控件（如 "+" 按钮）
 *
 * @brief[en] Tab bar button widget (e.g. "+" button)
 */
public class UiTabItemButton <: UiWidget {
    private var _label: String
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造标签栏按钮
     * @param[zh-cn] label 按钮标签
     * @param[zh-cn] flags 按钮标志（默认 0）
     *
     * @brief[en] Constructs a tab bar button
     * @param[en] label Button label
     * @param[en] flags Button flags (default 0)
     */
    public init(label!: String, flags!: Int32 = 0) {
        super()
        this._label = label
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 绘制标签栏按钮
     * @explain[zh-cn] 调用 ImGui TabItemButton。
     * @return[zh-cn] 按钮是否被点击
     *
     * @brief[en] Draws the tab bar button
     * @explain[en] Calls ImGui TabItemButton.
     * @return[en] Whether the button was clicked
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igTabItemButton_cj(cs, this._flags) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

// =============================================================================
// UiSetTabItemClosed — 关闭标签页
// =============================================================================

/**
 * @brief[zh-cn] 关闭指定标签页控件
 *
 * @brief[en] Close specified tab widget
 */
public class UiSetTabItemClosed <: UiWidget {
    private var _tabOrWindow: String

    /**
     * @brief[zh-cn] 构造关闭标签页控件
     * @param[zh-cn] tabOrWindowLabel 标签页或窗口标识
     *
     * @brief[en] Constructs a close-tab widget
     * @param[en] tabOrWindowLabel Tab or window identifier
     */
    public init(tabOrWindowLabel: String) {
        super()
        this._tabOrWindow = tabOrWindowLabel
    }

    /**
     * @brief[zh-cn] 关闭指定标签页
     * @explain[zh-cn] 调用 ImGui SetTabItemClosed。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Closes the specified tab
     * @explain[en] Calls ImGui SetTabItemClosed.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._tabOrWindow) }
        igSetTabItemClosed_cj(cs)
        unsafe { LibC.free(cs) }
        return false
    }
}
