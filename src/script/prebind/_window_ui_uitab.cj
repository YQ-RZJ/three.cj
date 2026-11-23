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
 * @file[zh-cn] window_ui_uitab UiTab.cj 标签页组件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiTab.cj 中 4 个 public 标签页控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiTabBar、UiTabItem、
 * UiTabItemButton、UiSetTabItemClosed，共 4 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数 flags 经 prebindInt 的 default 形参越界安全读取（默认 0）；
 * - () -> Unit 参数（UiTabBar/UiTabItem 的 content）经 prebindOptCallback 包装为仓颉闭包，
 *   缺少时传空闭包，回调异常在闭包内捕获并吞掉；
 * - UiTabItem 有两个构造重载：Lua 侧以第二个参数是否为对象（PtrArrayInt32）区分——传指针时读取
 *   UiTabItem(label, open, content, flags)，否则读取 UiTabItem(label, content, flags)；
 * - PtrArray<Int32> 参数（UiTabItem.open）经 prebindAs<PtrArray<Int32>>(args, i) 接收 Lua 侧
 *   已绑定的 three.utils.memory.PtrArrayInt32 实例；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false（UiTabItemButton 的 draw() 在 Lua 侧表示
 *   按钮是否被点击）；
 * - 绑定层无 __index 继承链，因此不重复登记基类 UiWidget 的 getId()（与 window_ui_uiwidget.cj
 *   的写法一致）。
 * 跳过成员及原因：
 * - 所有类的字段（_id/_label/_open/_flags/_content/_tabOrWindow）均为 private，只能经构造与
 *   draw() 访问，无独立 public 成员可绑定；
 * - UiTabItem._open 为 Option<PtrArray<Int32>>，其底层 CPointer<Int32> 只在 draw() 内部取出
 *   传给 ImGui，不会出现在公开签名中，故无需跳过任何公开成员；
 * - 本文件不含 VoidPtr/ImVec4/接口实例类型的 public 成员，故无因类型不可映射而跳过的成员。
 *
 * @file[en] window_ui_uitab  Lua binding of the UiTab.cj tab widgets (three.script.prebind)
 * @brief[en] Binds the 4 public tab widgets of three.window.ui.UiTab.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiTabBar, UiTabItem,
 * UiTabItemButton and UiSetTabItemClosed — 4 install functions (one installXxx(vm) per class).
 * Conventions:
 * - Constructors take positional arguments; the optional flags argument is read through
 *   prebindInt with the source default (0) and is out-of-range safe;
 * - () -> Unit parameters (content of UiTabBar/UiTabItem) are wrapped with prebindOptCallback
 *   into Cangjie closures; a no-op closure is used when absent and callback exceptions are caught
 *   inside the closure;
 * - UiTabItem has two constructor overloads; on the Lua side they are distinguished by whether the
 *   second argument is an object (PtrArrayInt32): when a pointer is given the
 *   UiTabItem(label, open, content, flags) form is used, otherwise UiTabItem(label, content,
 *   flags);
 * - The PtrArray<Int32> parameter (UiTabItem.open) is accepted through
 *   prebindAs<PtrArray<Int32>>(args, i) from the already bound three.utils.memory.PtrArrayInt32
 *   Lua instance;
 * - Every Bool-returning draw() is bound and returns false if an exception occurs
 *   (UiTabItemButton's draw() reports whether the button was clicked);
 * - The binding layer has no __index inheritance chain, so the inherited UiWidget.getId() is not
 *   re-registered (same as window_ui_uiwidget.cj).
 * Skipped members and reasons:
 * - All fields (_id/_label/_open/_flags/_content/_tabOrWindow) are private and are reachable only
 *   through constructors and draw(), so there is no separate public member to bind;
 * - UiTabItem._open is Option<PtrArray<Int32>>; its underlying CPointer<Int32> is extracted only
 *   inside draw() for ImGui and never appears in a public signature, so no public member needs to
 *   be skipped;
 * - No public member here uses VoidPtr/ImVec4/interface instances, so nothing is skipped for
 *   unmappable types.
 */
package three.script.prebind

import three.window.ui.*
import three.utils.memory.PtrArray
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
private func _prebindUitCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
private func _prebindUitDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiTabBar 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTabBar）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTabBar
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTabBar)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTabBar(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTabBar")
    b.constructor {
        args => UiTabBar(id: prebindStr(args, 0), flags: Int32(prebindInt(args, 1, default: 0)),
            content: _prebindUitCallback(vm, args, 2))
    }
    b.method("draw") {ref, _ => _prebindUitDraw({=> ref.cast<UiTabBar>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTabItem 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTabItem）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTabItem
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTabItem)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTabItem(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTabItem")
    b.constructor {
        args => if (args.size > 1 && args[1].isObject) {
            UiTabItem(label: prebindStr(args, 0), open: prebindAs<PtrArray<Int32>>(args, 1),
                content: _prebindUitCallback(vm, args, 2), flags: Int32(prebindInt(args, 3, default: 0)))
        } else {
            UiTabItem(label: prebindStr(args, 0), content: _prebindUitCallback(vm, args, 1),
                flags: Int32(prebindInt(args, 2, default: 0)))
        }
    }
    b.method("draw") {ref, _ => _prebindUitDraw({=> ref.cast<UiTabItem>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTabItemButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTabItemButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTabItemButton
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiTabItemButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTabItemButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTabItemButton")
    b.constructor {
        args => UiTabItemButton(label: prebindStr(args, 0), flags: Int32(prebindInt(args, 1, default: 0)))
    }
    b.method("draw") {ref, _ => _prebindUitDraw({=> ref.cast<UiTabItemButton>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSetTabItemClosed 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSetTabItemClosed）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSetTabItemClosed
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiSetTabItemClosed)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSetTabItemClosed(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSetTabItemClosed")
    b.constructor {
        args => UiSetTabItemClosed(prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUitDraw({=> ref.cast<UiSetTabItemClosed>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}
