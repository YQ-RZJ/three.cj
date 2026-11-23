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
 * @file[zh-cn] window_ui_uimenu UiMenu.cj 菜单组件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiMenu.cj 中 5 个 public 菜单控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiMenuBar、UiMainMenuBar、
 * UiMenu、UiMenuItem、UiMenuSeparator，共 5 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数经 prebindStr/prebindBool 的 default 形参越界安全读取，取源码
 *   中的默认值（UiMenu.enabled 默认 true；UiMenuItem.shortcut 默认 ""、selected 默认 false、
 *   enabled 默认 true）；
 * - () -> Unit 参数（UiMenuBar/UiMainMenuBar/UiMenu 的 content）经 prebindOptCallback 包装为
 *   仓颉闭包，缺少时传空闭包，回调异常在闭包内捕获并吞掉；UiMenuItem.onClick(callback) 同样处理；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false（UiMenuItem 的 draw() 在 Lua 侧表示是否被
 *   点击）；
 * - 返回自身的链式方法（UiMenuItem.onClick）返回 [LuaValue.Object(ref.id)]；
 * - 绑定层无 __index 继承链，因此不重复登记基类 UiWidget 的 getId()（与 window_ui_uiwidget.cj
 *   的写法一致）。
 * 跳过成员及原因：
 * - 所有类的字段（_content/_label/_enabled/_shortcut/_selected/_onClick）均为 private，只能经
 *   构造与成员方法访问，无独立 public 成员可绑定；
 * - UiMenuItem 的点击回调保存在 private 字段 _onClick 中，仅通过 onClick(callback) 写入，不存在
 *   可绑定的属性；
 * - 本文件不含 CPointer/VoidPtr/ImVec4/接口实例类型的 public 成员，故无因类型不可映射而跳过的
 *   成员。
 *
 * @file[en] window_ui_uimenu  Lua binding of the UiMenu.cj menu widgets (three.script.prebind)
 * @brief[en] Binds the 5 public menu widgets of three.window.ui.UiMenu.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiMenuBar,
 * UiMainMenuBar, UiMenu, UiMenuItem and UiMenuSeparator — 5 install functions (one
 * installXxx(vm) per class).
 * Conventions:
 * - Constructors take positional arguments; optional arguments are read through prebindStr/
 *   prebindBool with the source defaults and are out-of-range safe (UiMenu.enabled defaults to
 *   true; UiMenuItem.shortcut defaults to "", selected to false and enabled to true);
 * - () -> Unit parameters (content of UiMenuBar/UiMainMenuBar/UiMenu) are wrapped with
 *   prebindOptCallback into Cangjie closures; a no-op closure is used when absent and callback
 *   exceptions are caught inside the closure. UiMenuItem.onClick(callback) is handled the same way;
 * - Every Bool-returning draw() is bound and returns false if an exception occurs (UiMenuItem's
 *   draw() reports whether the item was clicked);
 * - Self-returning chain methods (UiMenuItem.onClick) return [LuaValue.Object(ref.id)];
 * - The binding layer has no __index inheritance chain, so the inherited UiWidget.getId() is not
 *   re-registered (same as window_ui_uiwidget.cj).
 * Skipped members and reasons:
 * - All fields (_content/_label/_enabled/_shortcut/_selected/_onClick) are private and are reachable
 *   only through constructors and methods, so there is no separate public member to bind;
 * - The click callback of UiMenuItem is stored in the private _onClick field and can only be set
 *   through onClick(callback), so there is no bindable property;
 * - No public member here uses CPointer/VoidPtr/ImVec4/interface instances, so nothing is skipped
 *   for unmappable types.
 */
package three.script.prebind

import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将可选 Lua 回调包装为无参仓颉闭包（缺省为空闭包，回调异常在闭包内捕获）
 * @param[zh-cn] vm 目标虚拟机
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 回调参数下标
 * @return[zh-cn] 无参闭包
 *
 * @brief[en] Wraps an optional Lua callback into a Cangjie no-arg closure (no-op when absent;
 * callback exceptions are caught inside the closure)
 * @param[en] vm The target virtual machine
 * @param[en] args The Lua argument array
 * @param[en] idx The callback argument index
 * @return[en] The no-arg closure
 */
private func _prebindUimCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
    let cb = prebindOptCallback(vm, args, idx)
    return {
        => if (let Some(c) <- cb) {
            try {
                let _ = c.call()
            } catch (_: Exception) {
                ()
            }
        }
    }
}

/**
 * @brief[zh-cn] 执行控件 draw() 并包装为 Lua 返回值（异常返回 false）
 * @param[zh-cn] fn 控件的 draw() 调用
 * @return[zh-cn] 单元素 Lua 返回值（Bool）
 *
 * @brief[en] Executes a widget draw() and wraps it as a Lua return value (false on exception)
 * @param[en] fn The widget draw() call
 * @return[en] A single-element Lua return value (Bool)
 */
private func _prebindUimDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiMenuBar 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMenuBar）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMenuBar
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMenuBar)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMenuBar(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMenuBar")
    b.constructor {
        args => UiMenuBar(content: _prebindUimCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUimDraw({=> ref.cast<UiMenuBar>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiMainMenuBar 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMainMenuBar）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMainMenuBar
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMainMenuBar)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMainMenuBar(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMainMenuBar")
    b.constructor {
        args => UiMainMenuBar(content: _prebindUimCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUimDraw({=> ref.cast<UiMainMenuBar>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiMenu 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMenu）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMenu
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMenu)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMenu(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMenu")
    b.constructor {
        args => UiMenu(label: prebindStr(args, 0), enabled: prebindBool(args, 1, default: true),
            content: _prebindUimCallback(vm, args, 2))
    }
    b.method("draw") {ref, _ => _prebindUimDraw({=> ref.cast<UiMenu>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiMenuItem 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMenuItem）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMenuItem
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMenuItem)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMenuItem(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMenuItem")
    b.constructor {
        args => UiMenuItem(label: prebindStr(args, 0), shortcut: prebindStr(args, 1, default: ""),
            selected: prebindBool(args, 2, default: false), enabled: prebindBool(args, 3, default: true))
    }
    b.method("onClick") {
        ref, args =>
            ref.cast<UiMenuItem>().onClick(_prebindUimCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUimDraw({=> ref.cast<UiMenuItem>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiMenuSeparator 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMenuSeparator）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMenuSeparator
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMenuSeparator)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMenuSeparator(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMenuSeparator")
    b.constructor {_ => UiMenuSeparator()}
    b.method("draw") {ref, _ => _prebindUimDraw({=> ref.cast<UiMenuSeparator>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}
