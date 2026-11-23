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
 * @file[zh-cn] window_ui_uiwidget_more UiWidget.cj 后半部分控件的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiWidget.cj 中后半部分 public 控件、裁剪器、过滤器与
 * 键鼠查询工具类绑定为 Lua 类型
 * @explain[zh-cn] UiWidget.cj 与 window_ui_uiwidget.cj 同属 three.window.ui.UiWidget 导入路径，
 * 因单文件体量过大（近 3900 行、七十余个类）拆为两个绑定文件；本文件覆盖后半部分：
 * UiArrowButton、UiBeginCombo/UiEndCombo、UiBeginListBox/UiEndListBox、UiColorButton、
 * UiColorEdit3、UiDragFloat2~4、UiDragInt2~4、UiSliderFloat2~4、UiSliderAngle、
 * UiSliderInt2~4、UiInputFloat2~4、UiInputInt2~4、UiColorPicker3、UiTextLink、UiTextBullet、
 * UiLabelText、UiValueBool/UiValueInt/UiValueUint、UiListClipper、UiTextFilter、
 * UiKeyboard、UiMouse。
 *
 * 绑定约定：
 * - 构造一律按位置读取参数，可选参数经 prebindNum/prebindInt/prebindBool/prebindStr 提供默认值；
 * - PtrArray<Int32|Float32|Float64> 参数经 prebindAs<PtrArray<...>>(args, i) 传入（Lua 侧用
 *   three.utils.memory.PtrArrayInt32 / PtrArrayFloat32 等已绑定实例）；
 * - Vector2 返回值经 prebindRegister 注册为 three.core.math.Vector2；
 * - 本半部分没有 Color 参数或返回值；Vector2 仅作为 UiMouse 两个查询的返回值出现；
 * - 控件 draw() 返回 Bool，直接以 LuaValue.of(...) 返回；
 * - 绑定层无 __index 继承链，故每个控件重复登记基类 UiWidget 的 getId()；
 * - 所有 lambda 均在 LuaClassBinder 分派内执行，异常由分派层捕获并转为 Lua 错误，不会穿透
 *   到 Lua C 调用栈之外。
 *
 * 跳过项（逐条注明原因）：
 * - 私有字段 _id/_dir/_label/_col/_v/_fmt/_flags 等：均无 public getter/setter，不属于 public
 *   成员，保持私有；
 * - UiListClipper._clipper（CPointer<Unit>）与 UiTextFilter._filter（CPointer<Unit>）：底层
 *   ImGui 指针为私有实现细节，CPointer 无法映射到 Lua，已跳过；对外仅暴露构造/begin/step/
 *   end/getDisplayStart/getDisplayEnd/draw/passFilter/isActive/clear/release/releasable；
 * - IReleasable 接口本身不绑定（接口不绑），仅绑定具体类上的 release() 与 releasable；
 * - 本文件范围内无 public 成员使用 VoidPtr 或 ImVec4（ImVec4 仅作为 UiColorButton 私有字段，
 *   构造参数已拆成 r/g/b/a 四个 Float32），故无需额外跳过；
 * - UiKeyboard/UiMouse 为纯静态工具类，仅注册 staticMethod，无 constructor。
 *
 * @file[en] window_ui_uiwidget_more  Lua bindings for the second half of UiWidget.cj
 * (three.script.prebind)
 * @brief[en] Binds the public widgets, clipper, text filter and keyboard/mouse query utilities
 * from the second half of three.window.ui.UiWidget.cj as Lua types
 * @explain[en] UiWidget.cj and window_ui_uiwidget.cj share the three.window.ui.UiWidget import
 * path; because the single file is very large (nearly 3900 lines, 70+ classes) the bindings are
 * split into two files. This file covers the second half: UiArrowButton, UiBeginCombo/UiEndCombo,
 * UiBeginListBox/UiEndListBox, UiColorButton, UiColorEdit3, UiDragFloat2~4, UiDragInt2~4,
 * UiSliderFloat2~4, UiSliderAngle, UiSliderInt2~4, UiInputFloat2~4, UiInputInt2~4,
 * UiColorPicker3, UiTextLink, UiTextBullet, UiLabelText, UiValueBool/UiValueInt/UiValueUint,
 * UiListClipper, UiTextFilter, UiKeyboard and UiMouse.
 *
 * Binding conventions:
 * - Constructors read arguments positionally; optional parameters use prebindNum/prebindInt/
 *   prebindBool/prebindStr defaults;
 * - PtrArray<Int32|Float32|Float64> parameters go through prebindAs<PtrArray<...>>(args, i)
 *   (Lua uses the already-bound PtrArrayInt32 / PtrArrayFloat32 instances);
 * - Vector2 return values are registered as three.core.math.Vector2 via prebindRegister;
 * - This half has no Color parameters or return values; Vector2 appears only as the return
 *   value of the two UiMouse queries;
 * - Widget draw() returns Bool and is returned directly through LuaValue.of(...);
 * - The binding layer has no __index inheritance chain, so every widget re-registers the
 *   UiWidget base method getId();
 * - Every lambda runs inside LuaClassBinder dispatch, which catches exceptions and converts
 *   them into Lua errors, so nothing escapes the Lua C call stack.
 *
 * Skipped items (with reasons):
 * - Private fields _id/_dir/_label/_col/_v/_fmt/_flags etc.: no public getters/setters, not
 *   public members, kept private;
 * - UiListClipper._clipper (CPointer<Unit>) and UiTextFilter._filter (CPointer<Unit>): private
 *   ImGui pointers, CPointer cannot map to Lua and is skipped; only constructor/begin/step/end/
 *   getDisplayStart/getDisplayEnd/draw/passFilter/isActive/clear/release/releasable are exposed;
 * - The IReleasable interface itself is not bound (interfaces are not bound); only the concrete
 *   classes' release() and releasable are bound;
 * - No public member in this file uses VoidPtr or ImVec4 (ImVec4 only appears as UiColorButton's
 *   private field, whose constructor arguments are split into four Float32 values);
 * - UiKeyboard/UiMouse are pure static utility classes: staticMethod only, no constructor.
 */
package three.script.prebind

import three.window.ui.*
import three.utils.memory.PtrArray
import three.script.vm.*
import three.script.binding.*

// =============================================================================
// UiArrowButton
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiArrowButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiArrowButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiArrowButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiArrowButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiArrowButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiArrowButton")
    b.constructor {
        args => UiArrowButton(prebindStr(args, 0), Int32(prebindInt(args, 1)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiArrowButton>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiArrowButton>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiBeginCombo / UiEndCombo
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiBeginCombo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiBeginCombo）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiBeginCombo
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiBeginCombo)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiBeginCombo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiBeginCombo")
    b.constructor {
        args => UiBeginCombo(prebindStr(args, 0), prebindStr(args, 1), flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiBeginCombo>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiBeginCombo>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiEndCombo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiEndCombo）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiEndCombo
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiEndCombo)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiEndCombo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiEndCombo")
    b.constructor {_ => UiEndCombo()}
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiEndCombo>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiEndCombo>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiBeginListBox / UiEndListBox
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiBeginListBox 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiBeginListBox）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiBeginListBox
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiBeginListBox)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiBeginListBox(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiBeginListBox")
    b.constructor {
        args => UiBeginListBox(prebindStr(args, 0), w: Float32(prebindNum(args, 1, default: 0.0)),
            h: Float32(prebindNum(args, 2, default: 0.0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiBeginListBox>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiBeginListBox>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiEndListBox 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiEndListBox）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiEndListBox
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiEndListBox)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiEndListBox(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiEndListBox")
    b.constructor {_ => UiEndListBox()}
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiEndListBox>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiEndListBox>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiColorButton
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiColorButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColorButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColorButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColorButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColorButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColorButton")
    b.constructor {
        args => UiColorButton(prebindStr(args, 0), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)), a: Float32(prebindNum(args, 4, default: 1.0)),
            flags: Int32(prebindInt(args, 5, default: 0)), w: Float32(prebindNum(args, 6, default: 0.0)),
            h: Float32(prebindNum(args, 7, default: 0.0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiColorButton>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiColorButton>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiColorEdit3
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiColorEdit3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColorEdit3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColorEdit3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColorEdit3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColorEdit3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColorEdit3")
    b.constructor {
        args => UiColorEdit3(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiColorEdit3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiColorEdit3>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiDragFloat2 / UiDragFloat3 / UiDragFloat4
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiDragFloat2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragFloat2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragFloat2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragFloat2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragFloat2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragFloat2")
    b.constructor {
        args => UiDragFloat2(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Float32(prebindNum(args, 3, default: 0.0)),
            max: Float32(prebindNum(args, 4, default: 0.0)), format: prebindStr(args, 5, default: "%.3f"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragFloat3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragFloat3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragFloat3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragFloat3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragFloat3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragFloat3")
    b.constructor {
        args => UiDragFloat3(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Float32(prebindNum(args, 3, default: 0.0)),
            max: Float32(prebindNum(args, 4, default: 0.0)), format: prebindStr(args, 5, default: "%.3f"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragFloat4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragFloat4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragFloat4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragFloat4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragFloat4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragFloat4")
    b.constructor {
        args => UiDragFloat4(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Float32(prebindNum(args, 3, default: 0.0)),
            max: Float32(prebindNum(args, 4, default: 0.0)), format: prebindStr(args, 5, default: "%.3f"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragFloat4>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiDragInt2 / UiDragInt3 / UiDragInt4
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiDragInt2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragInt2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragInt2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragInt2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragInt2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragInt2")
    b.constructor {
        args => UiDragInt2(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Int32(prebindInt(args, 3, default: 0)),
            max: Int32(prebindInt(args, 4, default: 0)), format: prebindStr(args, 5, default: "%d"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragInt2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragInt2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragInt3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragInt3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragInt3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragInt3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragInt3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragInt3")
    b.constructor {
        args => UiDragInt3(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Int32(prebindInt(args, 3, default: 0)),
            max: Int32(prebindInt(args, 4, default: 0)), format: prebindStr(args, 5, default: "%d"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragInt3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragInt3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragInt4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragInt4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragInt4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragInt4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragInt4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragInt4")
    b.constructor {
        args => UiDragInt4(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Int32(prebindInt(args, 3, default: 0)),
            max: Int32(prebindInt(args, 4, default: 0)), format: prebindStr(args, 5, default: "%d"),
            flags: Int32(prebindInt(args, 6, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiDragInt4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragInt4>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiSliderFloat2 / UiSliderFloat3 / UiSliderFloat4 / UiSliderAngle
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiSliderFloat2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderFloat2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderFloat2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderFloat2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderFloat2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderFloat2")
    b.constructor {
        args => UiSliderFloat2(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1), Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)), format: prebindStr(args, 4, default: "%.3f"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderFloat3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderFloat3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderFloat3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderFloat3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderFloat3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderFloat3")
    b.constructor {
        args => UiSliderFloat3(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1), Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)), format: prebindStr(args, 4, default: "%.3f"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderFloat4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderFloat4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderFloat4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderFloat4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderFloat4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderFloat4")
    b.constructor {
        args => UiSliderFloat4(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1), Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)), format: prebindStr(args, 4, default: "%.3f"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderFloat4>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderAngle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderAngle）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderAngle
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderAngle)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderAngle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderAngle")
    b.constructor {
        args => UiSliderAngle(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            minDeg: Float32(prebindNum(args, 2, default: -360.0)), maxDeg: Float32(prebindNum(args, 3, default: 360.0)),
            format: prebindStr(args, 4, default: "%.0f deg"), flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderAngle>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderAngle>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiSliderInt2 / UiSliderInt3 / UiSliderInt4
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiSliderInt2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderInt2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderInt2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderInt2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderInt2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderInt2")
    b.constructor {
        args => UiSliderInt2(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1), Int32(prebindInt(args, 2)),
            Int32(prebindInt(args, 3)), format: prebindStr(args, 4, default: "%d"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderInt3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderInt3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderInt3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderInt3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderInt3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderInt3")
    b.constructor {
        args => UiSliderInt3(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1), Int32(prebindInt(args, 2)),
            Int32(prebindInt(args, 3)), format: prebindStr(args, 4, default: "%d"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderInt4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderInt4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderInt4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderInt4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderInt4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderInt4")
    b.constructor {
        args => UiSliderInt4(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1), Int32(prebindInt(args, 2)),
            Int32(prebindInt(args, 3)), format: prebindStr(args, 4, default: "%d"),
            flags: Int32(prebindInt(args, 5, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSliderInt4>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiInputFloat2 / UiInputFloat3 / UiInputFloat4
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiInputFloat2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputFloat2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputFloat2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputFloat2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputFloat2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputFloat2")
    b.constructor {
        args => UiInputFloat2(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            format: prebindStr(args, 2, default: "%.3f"), flags: Int32(prebindInt(args, 3, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputFloat3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputFloat3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputFloat3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputFloat3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputFloat3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputFloat3")
    b.constructor {
        args => UiInputFloat3(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            format: prebindStr(args, 2, default: "%.3f"), flags: Int32(prebindInt(args, 3, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputFloat4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputFloat4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputFloat4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputFloat4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputFloat4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputFloat4")
    b.constructor {
        args => UiInputFloat4(prebindStr(args, 0), prebindAs<PtrArray<Float32>>(args, 1),
            format: prebindStr(args, 2, default: "%.3f"), flags: Int32(prebindInt(args, 3, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputFloat4>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiInputInt2 / UiInputInt3 / UiInputInt4
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiInputInt2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputInt2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputInt2
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputInt2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputInt2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputInt2")
    b.constructor {
        args => UiInputInt2(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputInt2>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputInt2>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputInt3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputInt3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputInt3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputInt3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputInt3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputInt3")
    b.constructor {
        args => UiInputInt3(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputInt3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputInt3>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputInt4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputInt4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputInt4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputInt4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputInt4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputInt4")
    b.constructor {
        args => UiInputInt4(prebindStr(args, 0), prebindAs<PtrArray<Int32>>(args, 1),
            flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiInputInt4>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInputInt4>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiColorPicker3
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiColorPicker3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColorPicker3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColorPicker3
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColorPicker3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColorPicker3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColorPicker3")
    b.constructor {
        args => UiColorPicker3(label: prebindStr(args, 0), col: prebindAs<PtrArray<Float32>>(args, 1),
            flags: Int32(prebindInt(args, 2, default: 0)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiColorPicker3>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiColorPicker3>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiTextLink / UiTextBullet / UiLabelText
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiTextLink 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextLink）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextLink
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextLink)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextLink(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextLink")
    b.constructor {args => UiTextLink(label: prebindStr(args, 0))}
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiTextLink>().draw())]}
    b.method("openURL") {
        ref, _ =>
            ref.cast<UiTextLink>().openURL()
            Array<LuaValue>()
    }
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiTextLink>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTextBullet 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextBullet）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextBullet
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextBullet)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextBullet(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextBullet")
    b.constructor {args => UiTextBullet(text: prebindStr(args, 0))}
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiTextBullet>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiTextBullet>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiLabelText 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiLabelText）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiLabelText
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiLabelText)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiLabelText(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiLabelText")
    b.constructor {
        args => UiLabelText(label: prebindStr(args, 0), text: prebindStr(args, 1))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiLabelText>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiLabelText>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiValueBool / UiValueInt / UiValueUint
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiValueBool 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiValueBool）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiValueBool
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiValueBool)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiValueBool(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiValueBool")
    b.constructor {
        args => UiValueBool(prefix: prebindStr(args, 0), v: prebindBool(args, 1))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiValueBool>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiValueBool>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiValueInt 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiValueInt）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiValueInt
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiValueInt)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiValueInt(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiValueInt")
    b.constructor {
        args => UiValueInt(prefix: prebindStr(args, 0), v: Int32(prebindInt(args, 1)))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiValueInt>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiValueInt>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiValueUint 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiValueUint）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiValueUint
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiValueUint)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiValueUint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiValueUint")
    b.constructor {
        args => UiValueUint(prefix: prebindStr(args, 0), v: UInt32(prebindInt(args, 1) & 0xFFFFFFFF))
    }
    b.method("draw") {ref, _ => [LuaValue.of(ref.cast<UiValueUint>().draw())]}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiValueUint>().getId())]}
    b.install(vm)
}

// =============================================================================
// UiListClipper
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiListClipper 的 Lua 绑定
 * @explain[zh-cn] 底层 CPointer 私有字段不绑定；暴露构造、begin/step/end、
 * getDisplayStart/getDisplayEnd、release 与 releasable。
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiListClipper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiListClipper
 * @explain[en] The private CPointer field is not bound; exposes the constructor, begin/step/end,
 * getDisplayStart/getDisplayEnd, release and releasable.
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiListClipper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiListClipper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiListClipper")
    b.constructor {_ => UiListClipper()}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<UiListClipper>().releasable)}))
    b.method("begin") {
        ref, args =>
            ref
                .cast<UiListClipper>()
                .begin(Int32(prebindInt(args, 0)), itemsHeight: Float32(prebindNum(args, 1, default: -1.0)))
            Array<LuaValue>()
    }
    b.method("step") {ref, _ => [LuaValue.of(ref.cast<UiListClipper>().step())]}
    b.method("end") {
        ref, _ =>
            ref.cast<UiListClipper>().end()
            Array<LuaValue>()
    }
    b.method("getDisplayStart") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiListClipper>().getDisplayStart()))]
    }
    b.method("getDisplayEnd") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiListClipper>().getDisplayEnd()))]
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<UiListClipper>().release())]}
    b.install(vm)
}

// =============================================================================
// UiTextFilter
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiTextFilter 的 Lua 绑定
 * @explain[zh-cn] 底层 CPointer 私有字段不绑定；暴露构造、draw/passFilter/isActive/clear、
 * release 与 releasable。
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextFilter）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextFilter
 * @explain[en] The private CPointer field is not bound; exposes the constructor,
 * draw/passFilter/isActive/clear, release and releasable.
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextFilter)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextFilter(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextFilter")
    b.constructor {args => UiTextFilter(defaultFilter: prebindStr(args, 0))}
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<UiTextFilter>().releasable)}))
    b.method("draw") {
        ref, args => [LuaValue.of(ref.cast<UiTextFilter>().draw(label: prebindStr(args, 0, default: "Filter")))]
    }
    b.method("passFilter") {
        ref, args => [LuaValue.of(ref.cast<UiTextFilter>().passFilter(prebindStr(args, 0)))]
    }
    b.method("isActive") {ref, _ => [LuaValue.of(ref.cast<UiTextFilter>().isActive())]}
    b.method("clear") {
        ref, _ =>
            ref.cast<UiTextFilter>().clear()
            Array<LuaValue>()
    }
    b.method("release") {ref, _ => [LuaValue.of(ref.cast<UiTextFilter>().release())]}
    b.install(vm)
}

// =============================================================================
// UiKeyboard（纯静态工具类）
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiKeyboard 的 Lua 绑定
 * @explain[zh-cn] 纯静态工具类，仅注册 staticMethod，无 constructor。
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiKeyboard）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiKeyboard
 * @explain[en] Pure static utility class: staticMethod only, no constructor.
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiKeyboard)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiKeyboard(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiKeyboard")
    b.staticMethod("isKeyDown") {
        args => [LuaValue.of(UiKeyboard.isKeyDown(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isKeyPressed") {
        args => [LuaValue.of(
            UiKeyboard.isKeyPressed(Int32(prebindInt(args, 0)), repeat_: prebindBool(args, 1, default: true)))]
    }
    b.staticMethod("isKeyReleased") {
        args => [LuaValue.of(UiKeyboard.isKeyReleased(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("getKeyName") {
        args => [LuaValue.of(UiKeyboard.getKeyName(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("getKeyPressedAmount") {
        args => [LuaValue.of(
            Int64(UiKeyboard.getKeyPressedAmount(Int32(prebindInt(args, 0)), Float32(prebindNum(args, 1)),
                Float32(prebindNum(args, 2)))))]
    }
    b.install(vm)
}

// =============================================================================
// UiMouse（纯静态工具类）
// =============================================================================

/**
 * @brief[zh-cn] 安装 UiMouse 的 Lua 绑定
 * @explain[zh-cn] 纯静态工具类，仅注册 staticMethod，无 constructor；getMousePos 与
 * getMouseDragDelta 返回的 Vector2 注册为 three.core.math.Vector2。
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiMouse）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiMouse
 * @explain[en] Pure static utility class: staticMethod only, no constructor; the Vector2 values
 * returned by getMousePos and getMouseDragDelta are registered as three.core.math.Vector2.
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiMouse)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiMouse(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiMouse")
    b.staticMethod("isMouseDown") {
        args => [LuaValue.of(UiMouse.isMouseDown(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isMouseClicked") {
        args => [LuaValue.of(
            UiMouse.isMouseClicked(Int32(prebindInt(args, 0)), repeat_: prebindBool(args, 1, default: false)))]
    }
    b.staticMethod("isMouseReleased") {
        args => [LuaValue.of(UiMouse.isMouseReleased(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isMouseDoubleClicked") {
        args => [LuaValue.of(UiMouse.isMouseDoubleClicked(Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isMouseHoveringRect") {
        args => [LuaValue.of(
            UiMouse.isMouseHoveringRect(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                Float32(prebindNum(args, 2)), Float32(prebindNum(args, 3)), clip: prebindBool(args, 4, default: true)))]
    }
    b.staticMethod("isAnyMouseDown") {_ => [LuaValue.of(UiMouse.isAnyMouseDown())]}
    b.staticMethod("getMousePos") {
        _ => [prebindRegister(UiMouse.getMousePos(), "three.core.math.Vector2")]
    }
    b.staticMethod("getMouseDragDelta") {
        args => [prebindRegister(
            UiMouse.getMouseDragDelta(button: Int32(prebindInt(args, 0, default: 0)),
                lockThreshold: Float32(prebindNum(args, 1, default: -1.0))), "three.core.math.Vector2")]
    }
    b.staticMethod("resetMouseDragDelta") {
        args =>
            UiMouse.resetMouseDragDelta(button: Int32(prebindInt(args, 0, default: 0)))
            Array<LuaValue>()
    }
    b.staticMethod("getMouseCursor") {_ => [LuaValue.of(Int64(UiMouse.getMouseCursor()))]}
    b.staticMethod("setMouseCursor") {
        args =>
            UiMouse.setMouseCursor(Int32(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    b.install(vm)
}
