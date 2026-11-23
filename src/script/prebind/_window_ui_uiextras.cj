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
 * @file[zh-cn] window_ui_uiextras UiExtras.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiExtras.cj 的补充控件与系统能力绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiChildWindow、
 * UiInputTextMultiline、UiRadioButton、UiRadioButtonGroup、UiInvisibleButton、UiCheckboxFlags、
 * UiTheme、UiStyleColor、UiComboPreview、UiItemFlags、UiSystem，共 11 个安装函数。
 * 适配约定：
 * - 构造按位置参数读取，可选参数经 prebindNum/prebindInt/prebindBool/prebindStr 的默认值越界安全读取；
 * - PtrArray<Int32> 共享值参数（UiRadioButtonGroup.value、UiCheckboxFlags.flags）经
 *   prebindAs<PtrArray<Int32>>(args, i) 接收；UiInputTextMultiline 的 bufSize 在仓颉侧是
 *   UIntNative（非缓冲区指针），按整数入参并强制为正数；
 * - () -> Unit 闭包参数（UiChildWindow.draw(content)、UiComboPreview(content)、
 *   UiItemFlags(content)）经 prebindOptCallback 包装，缺省为空闭包，回调异常在闭包内捕获并吞掉；
 * - Vector2 返回值（UiSystem.ioMousePos/ioMouseDelta）经 prebindRegister 注册为
 *   three.core.math.Vector2；Color4 参数（UiStyleColor.fromVec4）经 prebindAs<Color4> 读取；
 * - Bool 返回直接以 LuaValue.of(...) 返回、Unit 方法返回 []；Int32 返回 Int64(...)、Float32 返回
 *   Float64(...)、UInt32 返回 Int64(...)，回写用 Int32(...)/UInt32(... & 0xFFFFFFFF)/Float32(...)；
 * - UiTheme / UiStyleColor / UiSystem 为纯静态工具类，只用 staticMethod 暴露，不注册 constructor
 *   （其 public init() 不承载状态）；
 * - UiWidget 子类重复登记基类 getId()（绑定层无 __index 继承链）；
 * - 所有绑定 lambda 内的异常均被包装函数捕获，不会逃逸到 Lua 调用栈之外。
 * 跳过成员及原因：
 * - UiInputTextMultiline._buf（CPointer<Int8>）为私有缓冲区实现细节，文本读写只经 getText/setText，
 *   不绑定；析构逻辑不是脚本接口；
 * - UiChildWindow._id/_w/_h/_childFlags/_windowFlags、UiItemFlags._option/_enabled/_content 等均为私有
 *   字段，无 public getter/setter，保持私有；
 * - UiSystem 不含 VoidPtr / ImGuiStyle 成员（全部为静态查询函数），故本文件无因裸指针/ImGuiStyle
 *   而跳过的 public 成员。
 *
 * @file[en] window_ui_uiextras  Lua binding of UiExtras.cj (three.script.prebind)
 * @brief[en] Binds the supplementary widgets and system utilities of three.window.ui.UiExtras.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiChildWindow,
 * UiInputTextMultiline, UiRadioButton, UiRadioButtonGroup, UiInvisibleButton, UiCheckboxFlags,
 * UiTheme, UiStyleColor, UiComboPreview, UiItemFlags and UiSystem — 11 install functions.
 * Conventions:
 * - Constructors read positional arguments; optional arguments use the prebindNum/prebindInt/
 *   prebindBool/prebindStr defaults and are out-of-range safe;
 * - Shared PtrArray<Int32> value parameters (UiRadioButtonGroup.value, UiCheckboxFlags.flags) go through
 *   prebindAs<PtrArray<Int32>>(args, i); UiInputTextMultiline's bufSize is a UIntNative (not a buffer
 *   pointer) on the Cangjie side, so it is read as an integer and forced positive;
 * - () -> Unit closure parameters (UiChildWindow.draw(content), UiComboPreview(content),
 *   UiItemFlags(content)) are wrapped with prebindOptCallback (no-op when absent; callback exceptions
 *   are caught inside the closure);
 * - Vector2 results (UiSystem.ioMousePos/ioMouseDelta) are registered as three.core.math.Vector2 via
 *   prebindRegister; the Color4 parameter (UiStyleColor.fromVec4) is read with prebindAs<Color4>;
 * - Bool results use LuaValue.of(...), Unit methods return []; Int32 is returned as Int64(...), Float32
 *   as Float64(...) and UInt32 as Int64(...); writes use Int32(...)/UInt32(... & 0xFFFFFFFF)/Float32(...);
 * - UiTheme / UiStyleColor / UiSystem are pure static utilities exposed through staticMethod only, with
 *   no constructor (their public init() carries no state);
 * - UiWidget subclasses re-register the base getId() (the binding layer has no __index inheritance chain);
 * - Exceptions inside every binding lambda are caught by the wrappers and never escape to Lua.
 * Skipped members and reasons:
 * - UiInputTextMultiline._buf (CPointer<Int8>) is a private buffer implementation detail; text is read and
 *   written only through getText/setText, so it is not bound; destruction is not a script API either;
 * - UiChildWindow._id/_w/_h/_childFlags/_windowFlags and UiItemFlags._option/_enabled/_content are private
 *   fields without public getters/setters and stay private;
 * - UiSystem has no VoidPtr / ImGuiStyle members (only static query functions), so this file skips no
 *   public member because of raw pointers or ImGuiStyle.
 */
package three.script.prebind

import three.core.math.*
import three.utils.memory.PtrArray
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
 * @brief[en] Wraps an optional Lua callback into a Cangjie no-arg closure (no-op when absent; callback
 * exceptions are caught inside the closure)
 * @param[en] vm The target virtual machine
 * @param[en] args The Lua argument array
 * @param[en] idx The callback argument index
 * @return[en] The no-arg closure
 */
private func _prebindUiexCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
 * @brief[zh-cn] 执行 Bool 方法并包装为 Lua 返回值（异常返回 false）
 * @param[zh-cn] fn 待执行的调用
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a Bool method and wraps it as a Lua result (false on exception)
 * @param[en] fn The call to execute
 * @return[en] A single-element Lua result
 */
private func _prebindUiexBool(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 执行 Unit 方法并吞掉异常（异常不逃逸到 Lua）
 * @param[zh-cn] fn 待执行的调用
 * @return[zh-cn] 空返回值数组
 *
 * @brief[en] Executes a Unit method, swallowing exceptions (nothing escapes to Lua)
 * @param[en] fn The call to execute
 * @return[en] An empty result array
 */
private func _prebindUiexUnit(fn: () -> Unit): Array<LuaValue> {
    try {
        fn()
    } catch (_: Exception) {
        ()
    }
    return []
}

/**
 * @brief[zh-cn] 执行 UInt32 查询并包装为 Int64 的 Lua 数值（异常返回 0）
 * @param[zh-cn] fn 待执行的查询
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a UInt32 query and wraps it as an Int64 Lua number (0 on exception)
 * @param[en] fn The query to execute
 * @return[en] A single-element Lua result
 */
private func _prebindUiexU32(fn: () -> UInt32): Array<LuaValue> {
    try {
        return [LuaValue.of(Int64(fn()))]
    } catch (_: Exception) {
        return [LuaValue.of(Int64(0))]
    }
}

/**
 * @brief[zh-cn] 执行 Vector2 查询并注册为 three.core.math.Vector2（异常返回零向量）
 * @param[zh-cn] fn 待执行的查询
 * @return[zh-cn] 单元素 Lua 返回值
 *
 * @brief[en] Executes a Vector2 query and registers it as three.core.math.Vector2 (zero vector on exception)
 * @param[en] fn The query to execute
 * @return[en] A single-element Lua result
 */
private func _prebindUiexVec2Result(fn: () -> Vector2): Array<LuaValue> {
    try {
        return [prebindRegister(fn(), "three.core.math.Vector2")]
    } catch (_: Exception) {
        return [prebindRegister(Vector2(0.0, 0.0), "three.core.math.Vector2")]
    }
}

/**
 * @brief[zh-cn] 安装 UiChildWindow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiChildWindow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiChildWindow
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiChildWindow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiChildWindow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiChildWindow")
    b.constructor {
        args => UiChildWindow(id: prebindStr(args, 0), w: Float32(prebindNum(args, 1)), h: Float32(prebindNum(args, 2)),
            childFlags: Int32(prebindInt(args, 3)), windowFlags: Int32(prebindInt(args, 4)))
    }
    b.method("begin") {ref, _ => _prebindUiexBool({=> ref.cast<UiChildWindow>().begin()})}
    b.method("end") {ref, _ => _prebindUiexUnit({=> ref.cast<UiChildWindow>().end()})}
    b.method("draw") {
        ref, args => _prebindUiexBool({
            => ref.cast<UiChildWindow>().draw(_prebindUiexCallback(vm, args, 0))
        })
    }
    b.staticMethod("create") {
        args => try {
            [prebindRegister(
                UiChildWindow.create(prebindStr(args, 0), w: Float32(prebindNum(args, 1)),
                    h: Float32(prebindNum(args, 2))), "three.window.ui.UiChildWindow")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputTextMultiline 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputTextMultiline）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputTextMultiline
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputTextMultiline)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputTextMultiline(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputTextMultiline")
    b.constructor {
        args =>
            let n = prebindInt(args, 1, default: 1024)
            let bufSize = if (n > 0) {
                UIntNative(n)
            } else {
                UIntNative(1024)
            }
            UiInputTextMultiline(label: prebindStr(args, 0), bufSize: bufSize, w: Float32(prebindNum(args, 2)),
                h: Float32(prebindNum(args, 3)), flags: Int32(prebindInt(args, 4)))
    }
    b.method("draw") {
        ref, _ => _prebindUiexBool({=> ref.cast<UiInputTextMultiline>().draw()})
    }
    b.method("getText") {
        ref, _ => [LuaValue.of(ref.cast<UiInputTextMultiline>().getText())]
    }
    b.method("setText") {
        ref, args => _prebindUiexUnit({=> ref.cast<UiInputTextMultiline>().setText(prebindStr(args, 0))})
    }
    b.method("getId") {
        ref, _ => [LuaValue.of(ref.cast<UiInputTextMultiline>().getId())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiRadioButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiRadioButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiRadioButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiRadioButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiRadioButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiRadioButton")
    b.constructor {
        args => UiRadioButton(label: prebindStr(args, 0), active: prebindBool(args, 1))
    }
    b.method("draw") {ref, _ => _prebindUiexBool({=> ref.cast<UiRadioButton>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiRadioButton>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiRadioButtonGroup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiRadioButtonGroup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiRadioButtonGroup
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiRadioButtonGroup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiRadioButtonGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiRadioButtonGroup")
    b.constructor {
        args => UiRadioButtonGroup(label: prebindStr(args, 0), value: prebindAs<PtrArray<Int32>>(args, 1),
            buttonValue: Int32(prebindInt(args, 2)))
    }
    b.method("draw") {
        ref, _ => _prebindUiexBool({=> ref.cast<UiRadioButtonGroup>().draw()})
    }
    b.method("getId") {
        ref, _ => [LuaValue.of(ref.cast<UiRadioButtonGroup>().getId())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInvisibleButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInvisibleButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInvisibleButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInvisibleButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInvisibleButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInvisibleButton")
    b.constructor {
        args => UiInvisibleButton(id: prebindStr(args, 0), w: Float32(prebindNum(args, 1)),
            h: Float32(prebindNum(args, 2)), flags: Int32(prebindInt(args, 3)))
    }
    b.method("draw") {ref, _ => _prebindUiexBool({=> ref.cast<UiInvisibleButton>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiInvisibleButton>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiCheckboxFlags 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCheckboxFlags）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCheckboxFlags
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiCheckboxFlags)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCheckboxFlags(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCheckboxFlags")
    b.constructor {
        args => UiCheckboxFlags(label: prebindStr(args, 0), flags: prebindAs<PtrArray<Int32>>(args, 1),
            flagsValue: Int32(prebindInt(args, 2)))
    }
    b.method("draw") {ref, _ => _prebindUiexBool({=> ref.cast<UiCheckboxFlags>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiCheckboxFlags>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTheme 的 Lua 绑定（纯静态工具类，无构造）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTheme）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTheme (static-only utility, no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTheme)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTheme(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTheme")
    b.staticMethod("applyDark") {
        _ => _prebindUiexUnit({=> UiTheme.applyDark()})
    }
    b.staticMethod("applyLight") {
        _ => _prebindUiexUnit({=> UiTheme.applyLight()})
    }
    b.staticMethod("applyClassic") {
        _ => _prebindUiexUnit({=> UiTheme.applyClassic()})
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiStyleColor 的 Lua 绑定（纯静态工具类，无构造）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiStyleColor）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiStyleColor (static-only utility, no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiStyleColor)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiStyleColor(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiStyleColor")
    b.staticMethod("getU32") {
        args => _prebindUiexU32({
            => UiStyleColor.getU32(Int32(prebindInt(args, 0)), alphaMul: Float32(prebindNum(args, 1, default: 1.0)))
        })
    }
    b.staticMethod("fromVec4") {
        args => _prebindUiexU32({=> UiStyleColor.fromVec4(prebindAs<Color4>(args, 0))})
    }
    b.staticMethod("fromU32") {
        args => _prebindUiexU32({
            => UiStyleColor.fromU32(UInt32(prebindInt(args, 0) & 0xFFFFFFFF),
                alphaMul: Float32(prebindNum(args, 1, default: 1.0)))
        })
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiComboPreview 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiComboPreview）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiComboPreview
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiComboPreview)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiComboPreview(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiComboPreview")
    b.constructor {
        args => UiComboPreview(content: _prebindUiexCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiexBool({=> ref.cast<UiComboPreview>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiComboPreview>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiItemFlags 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiItemFlags）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiItemFlags
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiItemFlags)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiItemFlags(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiItemFlags")
    b.constructor {
        args => UiItemFlags(option: Int32(prebindInt(args, 0)), enabled: prebindBool(args, 1),
            content: _prebindUiexCallback(vm, args, 2))
    }
    b.method("draw") {ref, _ => _prebindUiexBool({=> ref.cast<UiItemFlags>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiItemFlags>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSystem 的 Lua 绑定（纯静态工具类，无构造）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSystem）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSystem (static-only utility, no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSystem)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSystem(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSystem")
    // ===== 剪贴板 =====
    b.staticMethod("getClipboardText") {
        _ => [LuaValue.of(UiSystem.getClipboardText())]
    }
    b.staticMethod("setClipboardText") {
        args => _prebindUiexUnit({=> UiSystem.setClipboardText(prebindStr(args, 0))})
    }
    // ===== 鼠标拖拽 =====
    b.staticMethod("isMouseDragging") {
        args => _prebindUiexBool({
            => UiSystem.isMouseDragging(button: Int32(prebindInt(args, 0)),
                lockThreshold: Float32(prebindNum(args, 1, default: -1.0)))
        })
    }
    b.staticMethod("resetMouseDragDelta") {
        args => _prebindUiexUnit({=> UiSystem.resetMouseDragDelta(button: Int32(prebindInt(args, 0)))})
    }
    // ===== 输入捕获 =====
    b.staticMethod("wantCaptureMouseNextFrame") {
        args => _prebindUiexUnit({=> UiSystem.wantCaptureMouseNextFrame(prebindBool(args, 0))})
    }
    b.staticMethod("wantCaptureKeyboardNextFrame") {
        args => _prebindUiexUnit({=> UiSystem.wantCaptureKeyboardNextFrame(prebindBool(args, 0))})
    }
    // ===== IO 运行时状态查询 =====
    b.staticMethod("isMouseCaptured") {
        _ => _prebindUiexBool({=> UiSystem.isMouseCaptured()})
    }
    b.staticMethod("isKeyboardCaptured") {
        _ => _prebindUiexBool({=> UiSystem.isKeyboardCaptured()})
    }
    b.staticMethod("wantsTextInput") {
        _ => _prebindUiexBool({=> UiSystem.wantsTextInput()})
    }
    b.staticMethod("framerate") {
        _ => try {
            [LuaValue.of(Float64(UiSystem.framerate()))]
        } catch (_: Exception) {
            [LuaValue.of(Float64(0.0))]
        }
    }
    b.staticMethod("ioMousePos") {
        _ => _prebindUiexVec2Result({=> UiSystem.ioMousePos()})
    }
    b.staticMethod("ioMouseDelta") {
        _ => _prebindUiexVec2Result({=> UiSystem.ioMouseDelta()})
    }
    b.staticMethod("isIoMouseDown") {
        args => _prebindUiexBool({=> UiSystem.isIoMouseDown(Int32(prebindInt(args, 0)))})
    }
    b.staticMethod("ioMouseWheel") {
        _ => try {
            [LuaValue.of(Float64(UiSystem.ioMouseWheel()))]
        } catch (_: Exception) {
            [LuaValue.of(Float64(0.0))]
        }
    }
    b.staticMethod("ioMouseWheelH") {
        _ => try {
            [LuaValue.of(Float64(UiSystem.ioMouseWheelH()))]
        } catch (_: Exception) {
            [LuaValue.of(Float64(0.0))]
        }
    }
    b.staticMethod("isKeyCtrl") {_ => _prebindUiexBool({=> UiSystem.isKeyCtrl()})}
    b.staticMethod("isKeyShift") {_ => _prebindUiexBool({=> UiSystem.isKeyShift()})}
    b.staticMethod("isKeyAlt") {_ => _prebindUiexBool({=> UiSystem.isKeyAlt()})}
    b.staticMethod("isKeySuper") {_ => _prebindUiexBool({=> UiSystem.isKeySuper()})}
    b.staticMethod("keyMods") {
        _ => try {
            [LuaValue.of(Int64(UiSystem.keyMods()))]
        } catch (_: Exception) {
            [LuaValue.of(Int64(0))]
        }
    }
    b.install(vm)
}
