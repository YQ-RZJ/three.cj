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
 *           UiMenuItem("New", "Ctrl+N", { => Logger.info(["UiMenu", "New"]) })
 *           UiMenuItem("Open", "Ctrl+O", { => Logger.info(["UiMenu", "Open"]) })
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

    public init(content!: () -> Unit) { super(); this._content = content }

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

    public init(content!: () -> Unit) { super(); this._content = content }

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

    public init(label!: String, enabled!: Bool = true, content!: () -> Unit) {
        super()
        this._label = label
        this._enabled = enabled
        this._content = content
    }

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

    public init(label!: String, shortcut!: String = "",
                selected!: Bool = false, enabled!: Bool = true) {
        super()
        this._label = label
        this._shortcut = shortcut
        this._selected = selected
        this._enabled = enabled
    }

    public func onClick(callback: () -> Unit): UiMenuItem {
        this._onClick = Some(callback)
        return this
    }

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
    public init() { super() }
    public override func draw(): Bool {
        igSeparator_cj()
        return false
    }
}
