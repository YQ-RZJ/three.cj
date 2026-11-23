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
 * @file[zh-cn] window_ui_uitable UiTable.cj 表格组件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiTable.cj 中 7 个 public 表格控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiTable、UiTableRow、
 * UiTableHeader、UiTableCell、UiTableSetupColumn、UiTableSetupScrollFreeze、UiTableHeadersRow，
 * 共 7 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数经 prebindInt/prebindNum 的 default 形参越界安全读取，取源码中的
 *   默认值（UiTable.columns 默认 1、flags 默认 0、innerWidth 默认 0.0；UiTableRow.minRowHeight
 *   默认 0.0；UiTableSetupColumn.flags 默认 0、initWidthOrWeight 默认 0.0、userId 默认 0；
 *   UiTableSetupScrollFreeze.cols/rows 默认 0）；
 * - () -> Unit 参数（UiTable/UiTableRow/UiTableCell 的 content）经 prebindOptCallback 包装为
 *   仓颉闭包，缺少时传空闭包，回调异常在闭包内捕获并吞掉；
 * - Vector2 参数（UiTable.outerSize）用对象探测，缺失、nil 或非对象时回落到 (0, 0)；
 * - UInt32 参数（UiTableSetupColumn.userId）以 Int64 读取后按 UInt32(... & 0xFFFFFFFF) 回写；
 * - 浮点参数以 Float32(...) 回写；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false（UiTable 的 draw() 在 Lua 侧表示表格是否
 *   可见）；
 * - 绑定层无 __index 继承链，因此不重复登记基类 UiWidget 的 getId()（与 window_ui_uiwidget.cj
 *   的写法一致）。
 * 跳过成员及原因：
 * - 所有类的字段（_id/_columns/_flags/_outerSize/_innerWidth/_content/_minRowHeight/_label/
 *   _initWidthOrWeight/_userId/_cols/_rows）均为 private，只能经构造与 draw() 访问，无独立
 *   public 成员可绑定；
 * - 本文件不含 CPointer/VoidPtr/ImVec4/接口实例类型的 public 成员；ImVec2 只在 UiTable.draw()
 *   内部由 outerSize 构造并传给 ImGui，未出现在公开签名中，故无因类型不可映射而跳过的成员。
 *
 * @file[en] window_ui_uitable  Lua binding of the UiTable.cj table widgets (three.script.prebind)
 * @brief[en] Binds the 7 public table widgets of three.window.ui.UiTable.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiTable, UiTableRow,
 * UiTableHeader, UiTableCell, UiTableSetupColumn, UiTableSetupScrollFreeze and UiTableHeadersRow —
 * 7 install functions (one installXxx(vm) per class).
 * Conventions:
 * - Constructors take positional arguments; optional arguments are read through prebindInt/
 *   prebindNum with the source defaults and are out-of-range safe (UiTable.columns defaults to 1,
 *   flags to 0 and innerWidth to 0.0; UiTableRow.minRowHeight defaults to 0.0;
 *   UiTableSetupColumn.flags to 0, initWidthOrWeight to 0.0 and userId to 0;
 *   UiTableSetupScrollFreeze.cols/rows to 0);
 * - () -> Unit parameters (content of UiTable/UiTableRow/UiTableCell) are wrapped with
 *   prebindOptCallback into Cangjie closures; a no-op closure is used when absent and callback
 *   exceptions are caught inside the closure;
 * - The Vector2 parameter (UiTable.outerSize) is probed as an object and falls back to (0, 0) when
 *   missing, nil or not an object;
 * - The UInt32 parameter (UiTableSetupColumn.userId) is read as Int64 and written back as
 *   UInt32(... & 0xFFFFFFFF);
 * - Floating-point parameters are written back with Float32(...);
 * - Every Bool-returning draw() is bound and returns false if an exception occurs (UiTable's draw()
 *   reports whether the table is visible);
 * - The binding layer has no __index inheritance chain, so the inherited UiWidget.getId() is not
 *   re-registered (same as window_ui_uiwidget.cj).
 * Skipped members and reasons:
 * - All fields (_id/_columns/_flags/_outerSize/_innerWidth/_content/_minRowHeight/_label/
 *   _initWidthOrWeight/_userId/_cols/_rows) are private and are reachable only through constructors
 *   and draw(), so there is no separate public member to bind;
 * - No public member here uses CPointer/VoidPtr/ImVec4/interface instances; ImVec2 is built inside
 *   UiTable.draw() from outerSize and passed to ImGui, never appearing in a public signature, so
 *   nothing is skipped for unmappable types.
 */
package three.script.prebind

import three.core.math.*
import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选 Vector2 参数（缺失 / nil / 非对象时返回默认值）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] 解析到的 Vector2
 *
 * @brief[en] Reads an optional Vector2 argument (default when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default value
 * @return[en] The resolved Vector2
 */
private func _prebindUitbVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<Vector2>(args, idx)
    }
    return default
}

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
private func _prebindUitbCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
private func _prebindUitbDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiTable 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTable）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTable
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTable)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTable(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTable")
    b.constructor {
        args => UiTable(id: prebindStr(args, 0), columns: Int32(prebindInt(args, 1, default: 1)),
            flags: Int32(prebindInt(args, 2, default: 0)), outerSize: _prebindUitbVec2(args, 3,
                default: Vector2(0.0, 0.0)), innerWidth: Float32(prebindNum(args, 4, default: 0.0)),
            content: _prebindUitbCallback(vm, args, 5))
    }
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTable>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableRow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableRow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableRow
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTableRow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableRow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableRow")
    b.constructor {
        args => UiTableRow(content: _prebindUitbCallback(vm, args, 0),
            minRowHeight: Float32(prebindNum(args, 1, default: 0.0)))
    }
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTableRow>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableHeader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableHeader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableHeader
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTableHeader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableHeader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableHeader")
    b.constructor {
        args => UiTableHeader(label: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTableHeader>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableCell 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableCell）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableCell
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTableCell)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableCell(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableCell")
    b.constructor {
        args => UiTableCell(content: _prebindUitbCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTableCell>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableSetupColumn 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableSetupColumn）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableSetupColumn
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiTableSetupColumn)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableSetupColumn(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableSetupColumn")
    b.constructor {
        args => UiTableSetupColumn(label: prebindStr(args, 0), flags: Int32(prebindInt(args, 1, default: 0)),
            initWidthOrWeight: Float32(prebindNum(args, 2, default: 0.0)),
            userId: UInt32(prebindInt(args, 3) & 0xFFFFFFFF))
    }
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTableSetupColumn>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableSetupScrollFreeze 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableSetupScrollFreeze）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableSetupScrollFreeze
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiTableSetupScrollFreeze)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableSetupScrollFreeze(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableSetupScrollFreeze")
    b.constructor {
        args => UiTableSetupScrollFreeze(cols: Int32(prebindInt(args, 0, default: 0)),
            rows: Int32(prebindInt(args, 1, default: 0)))
    }
    b.method("draw") {
        ref, _ => _prebindUitbDraw({=> ref.cast<UiTableSetupScrollFreeze>().draw()})
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTableHeadersRow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTableHeadersRow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTableHeadersRow
 * @param[en] vm The target virtual machine (class table installed at
 * three.window.ui.UiTableHeadersRow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTableHeadersRow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTableHeadersRow")
    b.constructor {_ => UiTableHeadersRow()}
    b.method("draw") {ref, _ => _prebindUitbDraw({=> ref.cast<UiTableHeadersRow>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}
