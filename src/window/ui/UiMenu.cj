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
 * @file[zh-cn] UiMenu.cj — ImGui 菜单组件
 * @brief[zh-cn] 封装 ImGui 菜单 API：MenuBar、Menu、MenuItem
 * @explain[zh-cn] 提供 UiMenuBar、UiMainMenuBar、UiMenu、UiMenuItem、UiMenuSeparator 五个菜单相关控件，支持链式回调注册。用法示例：
 *   UiMenuBar({ =>
 *       UiMenu("File", { =>
 *           UiMenuItem("New", "Ctrl+N", { => @LogInfo(["UiMenu", "New"]) })
 *           UiMenuItem("Open", "Ctrl+O", { => @LogInfo(["UiMenu", "Open"]) })
 *           UiMenuSeparator()
 *           UiMenuItem("Exit", "Alt+F4", { => exit() })
 *       })
 *       UiMenu("Edit", { =>
 *           UiMenuItem("Undo", "Ctrl+Z")
 *           UiMenuItem("Redo", "Ctrl+Y")
 *       })
 *   })
 *
 * @file[en] UiMenu.cj — ImGui Menu Components
 * @brief[en] Wrappers for ImGui menu API: MenuBar, Menu, MenuItem
 * @explain[en] Provides UiMenuBar, UiMainMenuBar, UiMenu, UiMenuItem, UiMenuSeparator — five menu-related widgets with chainable callback registration.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// =============================================================================
// UiMenuBar — 菜单栏容器
// =============================================================================

/**
 * @brief[zh-cn] 菜单栏容器控件
 *
 * @brief[en] Menu bar container widget
 */
public class UiMenuBar <: UiWidget {
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造菜单栏容器
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a menu bar container
     * @param[en] content Child content drawing closure
     */
    public init(content!: () -> Unit) { super(); this._content = content }

    /**
     * @brief[zh-cn] 绘制菜单栏
     * @explain[zh-cn] 调用 ImGui BeginMenuBar/EndMenuBar 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the menu bar
     * @explain[en] Wraps child content with ImGui BeginMenuBar/EndMenuBar.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        if (igBeginMenuBar_cj() != 0) {
            this._content()
            igEndMenuBar_cj()
        }
        return false
    }
}

// =============================================================================
// UiMainMenuBar — 主菜单栏容器（窗口顶部固定）
// =============================================================================

/**
 * @brief[zh-cn] 主菜单栏容器控件（全屏固定）
 *
 * @brief[en] Main menu bar container widget (fullscreen fixed)
 */
public class UiMainMenuBar <: UiWidget {
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造主菜单栏容器
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a main menu bar container
     * @param[en] content Child content drawing closure
     */
    public init(content!: () -> Unit) { super(); this._content = content }

    /**
     * @brief[zh-cn] 绘制主菜单栏
     * @explain[zh-cn] 调用 ImGui BeginMainMenuBar/EndMainMenuBar 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the main menu bar
     * @explain[en] Wraps child content with ImGui BeginMainMenuBar/EndMainMenuBar.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        if (igBeginMainMenuBar_cj() != 0) {
            this._content()
            igEndMainMenuBar_cj()
        }
        return false
    }
}

// =============================================================================
// UiMenu — 下拉菜单
// =============================================================================

/**
 * @brief[zh-cn] 下拉菜单控件
 *
 * @brief[en] Drop-down menu widget
 */
public class UiMenu <: UiWidget {
    private var _label: String
    private var _enabled: Bool
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造下拉菜单
     * @param[zh-cn] label 菜单标签
     * @param[zh-cn] enabled 是否可用（默认 true）
     * @param[zh-cn] content 子内容绘制闭包
     *
     * @brief[en] Constructs a drop-down menu
     * @param[en] label Menu label
     * @param[en] enabled Whether enabled (default true)
     * @param[en] content Child content drawing closure
     */
    public init(label!: String, enabled!: Bool = true, content!: () -> Unit) {
        super()
        this._label = label
        this._enabled = enabled
        this._content = content
    }

    /**
     * @brief[zh-cn] 绘制下拉菜单
     * @explain[zh-cn] 调用 ImGui BeginMenu/EndMenu 包裹子内容。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the drop-down menu
     * @explain[en] Wraps child content with ImGui BeginMenu/EndMenu.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igBeginMenu_cj(cs, if (this._enabled) { 1 } else { 0 }) != 0
        unsafe { LibC.free(cs) }
        if (r) {
            this._content()
            igEndMenu_cj()
        }
        return false
    }
}

// =============================================================================
// UiMenuItem — 菜单项
// =============================================================================

/**
 * @brief[zh-cn] 菜单项控件
 *
 * @brief[en] Menu item widget
 */
public class UiMenuItem <: UiWidget {
    private var _label: String
    private var _shortcut: String
    private var _selected: Bool
    private var _enabled: Bool
    private var _onClick: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造菜单项
     * @param[zh-cn] label 菜单项标签
     * @param[zh-cn] shortcut 快捷键提示文本（默认空字符串）
     * @param[zh-cn] selected 是否选中（默认 false）
     * @param[zh-cn] enabled 是否可用（默认 true）
     *
     * @brief[en] Constructs a menu item
     * @param[en] label Menu item label
     * @param[en] shortcut Shortcut hint text (default empty string)
     * @param[en] selected Whether selected (default false)
     * @param[en] enabled Whether enabled (default true)
     */
    public init(label!: String, shortcut!: String = "",
                selected!: Bool = false, enabled!: Bool = true) {
        super()
        this._label = label
        this._shortcut = shortcut
        this._selected = selected
        this._enabled = enabled
    }

    /**
     * @brief[zh-cn] 设置点击回调
     * @param[zh-cn] callback 点击时调用的回调函数
     * @return[zh-cn] 当前实例，支持链式调用
     *
     * @brief[en] Sets the click callback
     * @param[en] callback Callback invoked on click
     * @return[en] The current instance for chaining
     */
    public func onClick(callback: () -> Unit): UiMenuItem {
        this._onClick = Some(callback)
        return this
    }

    /**
     * @brief[zh-cn] 绘制菜单项
     * @explain[zh-cn] 调用 ImGui MenuItem，被点击时触发已注册的回调。
     * @return[zh-cn] 菜单项是否被点击
     *
     * @brief[en] Draws the menu item
     * @explain[en] Calls ImGui MenuItem; fires the registered callback when clicked.
     * @return[en] Whether the menu item was clicked
     */
    public override func draw(): Bool {
        let labelCs = unsafe { LibC.mallocCString(this._label) }
        let shortcutCs = unsafe { LibC.mallocCString(this._shortcut) }
        let r = igMenuItem_Bool_cj(labelCs, shortcutCs,
                                    if (this._selected) { 1 } else { 0 },
                                    if (this._enabled) { 1 } else { 0 })
        unsafe { LibC.free(labelCs); LibC.free(shortcutCs) }
        let clicked = r != 0
        if (clicked) {
            match (this._onClick) {
                case Some(f) => f()
                case None => ()
            }
        }
        return clicked
    }
}

// =============================================================================
// UiMenuSeparator — 菜单分隔线
// =============================================================================

/**
 * @brief[zh-cn] 菜单分隔线控件
 *
 * @brief[en] Menu separator widget
 */
public class UiMenuSeparator <: UiWidget {
    /**
     * @brief[zh-cn] 构造菜单分隔线
     *
     * @brief[en] Constructs a menu separator
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 绘制菜单分隔线
     * @explain[zh-cn] 调用 ImGui Separator 绘制一条水平分隔线。
     * @return[zh-cn] 是否发生交互（当前实现恒返回 false）
     *
     * @brief[en] Draws the menu separator
     * @explain[en] Calls ImGui Separator to draw a horizontal divider line.
     * @return[en] Whether interaction occurred (always false in this implementation)
     */
    public override func draw(): Bool {
        igSeparator_cj()
        return false
    }
}
