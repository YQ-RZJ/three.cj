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

    public init(id!: String, flags!: Int32 = 0, content!: () -> Unit) {
        super()
        this._id = id
        this._flags = flags
        this._content = content
    }

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
    private var _open: Option<CPointer<Int32>>
    private var _flags: Int32
    private var _content: () -> Unit

    public init(label!: String, content!: () -> Unit, flags!: Int32 = 0) {
        super()
        this._label = label
        this._open = None
        this._flags = flags
        this._content = content
    }

    public init(label!: String, open!: CPointer<Int32>,
                content!: () -> Unit, flags!: Int32 = 0) {
        super()
        this._label = label
        this._open = Some(open)
        this._flags = flags
        this._content = content
    }

    public override func draw(): Bool {
        let openPtr: CPointer<Int32> = match (this._open) {
            case Some(p) => p
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

    public init(label!: String, flags!: Int32 = 0) {
        super()
        this._label = label
        this._flags = flags
    }

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

    public init(tabOrWindowLabel: String) {
        super()
        this._tabOrWindow = tabOrWindowLabel
    }

    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._tabOrWindow) }
        igSetTabItemClosed_cj(cs)
        unsafe { LibC.free(cs) }
        return false
    }
}
