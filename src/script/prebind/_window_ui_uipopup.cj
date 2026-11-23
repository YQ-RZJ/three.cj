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
 * @file[zh-cn] window_ui_uipopup UiPopup.cj 弹出窗口组件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiPopup.cj 中 5 个 public 弹出窗口控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiPopup、UiPopupModal、
 * UiOpenPopup、UiCloseCurrentPopup、UiEndPopup，共 5 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数 flags 经 prebindInt 的 default 形参越界安全读取（默认 0）；
 * - () -> Unit 参数（UiPopup/UiPopupModal 的 content）经 prebindOptCallback 包装为仓颉闭包，
 *   缺少时传空闭包，回调异常在闭包内捕获并吞掉；
 * - UiPopupModal 有两个构造重载：Lua 侧以第二个参数是否为对象（PtrArrayInt32）区分——
 *   传指针时读取 UiPopupModal(name, open, content, flags)，否则读取
 *   UiPopupModal(name, content, flags)；
 * - PtrArray<Int32> 参数（UiPopupModal.open）经 prebindAs<PtrArray<Int32>>(args, i) 接收 Lua 侧
 *   已绑定的 three.utils.memory.PtrArrayInt32 实例；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false；
 * - 绑定层无 __index 继承链，因此不重复登记基类 UiWidget 的 getId()（与 window_ui_uiwidget.cj
 *   的写法一致）。
 * 跳过成员及原因：
 * - 所有类的字段（_id/_name/_open/_flags/_content）均为 private，只能经构造与 draw() 访问，
 *   无独立 public 成员可绑定；
 * - UiPopupModal._open 为 Option<PtrArray<Int32>>，其底层 CPointer<Int32> 只在 draw() 内部取出
 *   传给 ImGui，不会出现在公开签名中，故无需跳过任何公开成员；
 * - 本文件不含 VoidPtr/ImVec4/接口实例类型的 public 成员，故无因类型不可映射而跳过的成员。
 *
 * @file[en] window_ui_uipopup  Lua binding of the UiPopup.cj popup widgets (three.script.prebind)
 * @brief[en] Binds the 5 public popup widgets of three.window.ui.UiPopup.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiPopup, UiPopupModal,
 * UiOpenPopup, UiCloseCurrentPopup and UiEndPopup — 5 install functions (one installXxx(vm) per
 * class).
 * Conventions:
 * - Constructors take positional arguments; the optional flags argument is read through
 *   prebindInt with the source default (0) and is out-of-range safe;
 * - () -> Unit parameters (content of UiPopup/UiPopupModal) are wrapped with prebindOptCallback
 *   into Cangjie closures; a no-op closure is used when absent and callback exceptions are caught
 *   inside the closure;
 * - UiPopupModal has two constructor overloads; on the Lua side they are distinguished by whether
 *   the second argument is an object (PtrArrayInt32): when a pointer is given the
 *   UiPopupModal(name, open, content, flags) form is used, otherwise UiPopupModal(name, content,
 *   flags);
 * - The PtrArray<Int32> parameter (UiPopupModal.open) is accepted through
 *   prebindAs<PtrArray<Int32>>(args, i) from the already bound three.utils.memory.PtrArrayInt32
 *   Lua instance;
 * - Every Bool-returning draw() is bound and returns false if an exception occurs;
 * - The binding layer has no __index inheritance chain, so the inherited UiWidget.getId() is not
 *   re-registered (same as window_ui_uiwidget.cj).
 * Skipped members and reasons:
 * - All fields (_id/_name/_open/_flags/_content) are private and are reachable only through
 *   constructors and draw(), so there is no separate public member to bind;
 * - UiPopupModal._open is Option<PtrArray<Int32>>; its underlying CPointer<Int32> is extracted only
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
private func _prebindUipCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
private func _prebindUipDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiPopup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiPopup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiPopup
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiPopup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiPopup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiPopup")
    b.constructor {
        args => UiPopup(id: prebindStr(args, 0), flags: Int32(prebindInt(args, 1, default: 0)),
            content: _prebindUipCallback(vm, args, 2))
    }
    b.method("draw") {ref, _ => _prebindUipDraw({=> ref.cast<UiPopup>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiPopupModal 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiPopupModal）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiPopupModal
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiPopupModal)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiPopupModal(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiPopupModal")
    b.constructor {
        args => if (args.size > 1 && args[1].isObject) {
            UiPopupModal(name: prebindStr(args, 0), open: prebindAs<PtrArray<Int32>>(args, 1),
                content: _prebindUipCallback(vm, args, 2), flags: Int32(prebindInt(args, 3, default: 0)))
        } else {
            UiPopupModal(name: prebindStr(args, 0), content: _prebindUipCallback(vm, args, 1),
                flags: Int32(prebindInt(args, 2, default: 0)))
        }
    }
    b.method("draw") {ref, _ => _prebindUipDraw({=> ref.cast<UiPopupModal>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiOpenPopup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiOpenPopup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiOpenPopup
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiOpenPopup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiOpenPopup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiOpenPopup")
    b.constructor {
        args => UiOpenPopup(id: prebindStr(args, 0), flags: Int32(prebindInt(args, 1, default: 0)))
    }
    b.method("draw") {ref, _ => _prebindUipDraw({=> ref.cast<UiOpenPopup>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiCloseCurrentPopup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCloseCurrentPopup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCloseCurrentPopup
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiCloseCurrentPopup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCloseCurrentPopup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCloseCurrentPopup")
    b.constructor {_ => UiCloseCurrentPopup()}
    b.method("draw") {ref, _ => _prebindUipDraw({=> ref.cast<UiCloseCurrentPopup>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiEndPopup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiEndPopup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiEndPopup
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiEndPopup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiEndPopup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiEndPopup")
    b.constructor {_ => UiEndPopup()}
    b.method("draw") {ref, _ => _prebindUipDraw({=> ref.cast<UiEndPopup>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}
