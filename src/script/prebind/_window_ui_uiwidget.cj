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
 * @file[zh-cn] window_ui_uiwidget UiWidget.cj 前半部分控件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.window.ui 中 UiWidget 基类及前半部分 38 个具体控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiWidget、UiText、UiButton、
 * UiSmallButton、UiCheckbox、UiSliderFloat、UiSliderInt、UiInputText、UiInputFloat、UiCombo、
 * UiSelectable、UiSeparator、UiSameLine、UiSpacing、UiTreeNode、UiTreeNodeEx、UiCollapsingHeader、
 * UiTooltip、UiSetTooltip、UiProgressBar、UiListBox、UiImage、UiImageButton、UiColorEdit4、
 * UiColorPicker4、UiDragFloat、UiDragInt、UiInputInt、UiInputDouble、UiVSliderFloat、UiDisabled、
 * UiClipRect、UiSetNextItemWidth、UiSetNextItemOpen、UiSeparatorText、UiPlotLines、UiPlotHistogram、
 * UiValue、UiItemQuery，共 39 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数经 prebindNum/prebindInt/prebindBool/prebindStr 的 default 形参
 *   越界安全读取，取源码中的默认值；
 * - PtrArray<Int32>/PtrArray<Float32>/PtrArray<Float64> 参数直接接收 Lua 侧已绑定的
 *   three.utils.memory.PtrArrayInt32/Float32/Float64 实例；
 * - Vector2 参数缺失、nil 或非对象时回落到默认值（UiButton/UiProgressBar/UiImage/UiImageButton/
 *   UiVSliderFloat/UiClipRect/UiPlotLines/UiPlotHistogram）；Vector2 返回值经 prebindRegister
 *   注册为 three.core.math.Vector2；
 * - () -> Unit 参数（UiTooltip(content)、UiDisabled(…, content)、UiClipRect(…, content)、
 *   onClick(callback)、withContent(content)）经 prebindOptCallback 包装为仓颉闭包，回调异常在
 *   闭包内捕获并吞掉，缺省传空闭包；UiDisabled 额外兼容「首个参数即函数」的 UiDisabled(fn) 形态；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false；
 * - Int32/Int64/UInt32 数值以 Int64(...) 返回、以 Int32(...) 回写；Float32/Float64 以
 *   Float64(...) 返回、以 Float32(...) 回写；UInt64 纹理 ID 与 UIntNative 缓冲区大小按数字入参；
 * - UiItemQuery 为无状态工具类，只用 staticMethod 暴露，无构造。
 * 跳过成员及原因：
 * - 无 public 成员因类型不可映射而被跳过（前半部分不含 CPointer/VoidPtr/ImVec4/ImTextureRef/
 *   接口实例类型的公开成员）；
 * - UiInputText 的 internal getBufPtr() 返回裸 CPointer<Int8>，缓冲区所有权归控件本身，不属于
 *   脚本接口（文本读写请用 getText/setText），故不绑定；析构 ~init 同样不是脚本接口；
 * - UiInputText 的 _buf/_bufSize/_hint/_flags 等均为 private 字段，仅经构造与 getText/setText
 *   访问，无独立成员可绑定；
 * - 后半部分（UiArrowButton 起）的控件不在本文件范围内。
 *
 * @file[en] window_ui_uiwidget  Lua binding of the first half of UiWidget.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiWidget plus the 38 concrete widgets of the first half as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiWidget, UiText, UiButton,
 * UiSmallButton, UiCheckbox, UiSliderFloat, UiSliderInt, UiInputText, UiInputFloat, UiCombo,
 * UiSelectable, UiSeparator, UiSameLine, UiSpacing, UiTreeNode, UiTreeNodeEx, UiCollapsingHeader,
 * UiTooltip, UiSetTooltip, UiProgressBar, UiListBox, UiImage, UiImageButton, UiColorEdit4,
 * UiColorPicker4, UiDragFloat, UiDragInt, UiInputInt, UiInputDouble, UiVSliderFloat, UiDisabled,
 * UiClipRect, UiSetNextItemWidth, UiSetNextItemOpen, UiSeparatorText, UiPlotLines, UiPlotHistogram,
 * UiValue and UiItemQuery — 39 install functions (one installXxx(vm) per class).
 * Conventions:
 * - Constructors take positional arguments; optional arguments are read through prebindNum/prebindInt/
 *   prebindBool/prebindStr with the source defaults and are out-of-range safe;
 * - PtrArray<Int32>/PtrArray<Float32>/PtrArray<Float64> parameters accept the already bound Lua types
 *   three.utils.memory.PtrArrayInt32/Float32/Float64;
 * - Vector2 parameters fall back to the default when missing, nil or not an object
 *   (UiButton/UiProgressBar/UiImage/UiImageButton/UiVSliderFloat/UiClipRect/UiPlotLines/
 *   UiPlotHistogram); Vector2 results are registered as three.core.math.Vector2 via prebindRegister;
 * - () -> Unit parameters (UiTooltip(content), UiDisabled(..., content), UiClipRect(..., content),
 *   onClick(callback), withContent(content)) are wrapped with prebindOptCallback; exceptions raised by
 *   the Lua callback are caught inside the Cangjie closure, and a no-op closure is used when absent.
 *   UiDisabled additionally accepts the content-only form UiDisabled(fn);
 * - Every Bool-returning draw() is bound and returns false if an exception occurs;
 * - Int32/Int64/UInt32 values are returned as Int64(...) and written back with Int32(...); Float32/
 *   Float64 values are returned as Float64(...) and written back with Float32(...); UInt64 texture IDs
 *   and UIntNative buffer sizes are passed as numbers;
 * - UiItemQuery is stateless and exposed through staticMethod only (no constructor).
 * Skipped members and reasons:
 * - No public member is skipped for unmappable types (the first half has no public CPointer/VoidPtr/
 *   ImVec4/ImTextureRef/interface-typed members);
 * - UiInputText.getBufPtr() is internal and returns a raw CPointer<Int8> owned by the widget, so it is
 *   not a script API (use getText/setText); the destructor ~init is not a script API either;
 * - UiInputText private fields (_buf/_bufSize/_hint/_flags) are reachable only through the constructor
 *   and getText/setText, so there is no separate member to bind;
 * - Widgets of the second half (starting at UiArrowButton) are out of scope for this file.
 */
package three.script.prebind

import three.core.math.*
import three.utils.memory.PtrArray
import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为任意 UiWidget 子类绑定器安装基类成员（getId）
 * @explain[zh-cn] Lua 类表之间没有继承关系，因此每个 UiWidget 子类的绑定都要单独安装基类成员。
 * 按 UiWidget 强转即可作用于任意子类实例。
 * @param[zh-cn] b 目标类绑定器
 *
 * @brief[en] Installs the base-class members (getId) on any UiWidget subclass binder
 * @explain[en] Lua class tables do not inherit, so every UiWidget subclass binding installs the
 * base members itself. Casting to UiWidget works for every subclass instance.
 * @param[en] b The target class binder
 */
internal func prebindInstallUiWidgetBase(b: LuaClassBinder): Unit {
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiWidget>().getId())]}
}

/**
 * @brief[zh-cn] 读取可选 Vector2 参数（缺失 / nil / 非对象时返回默认值）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] 解析到的 Vector2
 *
 * @brief[en] Reads an optional Vector2 argument (falls back to the default when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default value
 * @return[en] The resolved Vector2
 */
private func _prebindUiwVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
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
 * @brief[en] Wraps an optional Lua callback into a Cangjie no-arg closure (no-op when absent; callback
 * exceptions are caught inside the closure)
 * @param[en] vm The target virtual machine
 * @param[en] args The Lua argument array
 * @param[en] idx The callback argument index
 * @return[en] The no-arg closure
 */
private func _prebindUiwCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
private func _prebindUiwDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiWidget 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiWidget）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiWidget
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiWidget)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiWidget(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiWidget")
    b.constructor {
        args =>
            let id = prebindStr(args, 0, default: "")
            if (id.isEmpty()) {
                UiWidget()
            } else {
                UiWidget(id: id)
            }
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiWidget>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiWidget>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiText 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiText）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiText
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiText)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiText(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiText")
    b.constructor {
        args => UiText(text: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiText>().draw()})}
    b.method("getText") {ref, _ => [LuaValue.of(ref.cast<UiText>().getText())]}
    b.method("setText") {
        ref, args =>
            ref.cast<UiText>().setText(prebindStr(args, 0))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiButton")
    b.constructor {
        args => UiButton(label: prebindStr(args, 0), size: _prebindUiwVec2(args, 1, default: Vector2(0.0, 0.0)))
    }
    b.method("onClick") {
        ref, args =>
            ref.cast<UiButton>().onClick(_prebindUiwCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiButton>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSmallButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSmallButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSmallButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSmallButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSmallButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSmallButton")
    b.constructor {
        args => UiSmallButton(label: prebindStr(args, 0))
    }
    b.method("onClick") {
        ref, args =>
            ref.cast<UiSmallButton>().onClick(_prebindUiwCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSmallButton>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiCheckbox 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCheckbox）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCheckbox
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiCheckbox)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCheckbox(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCheckbox")
    b.constructor {
        args => UiCheckbox(label: prebindStr(args, 0), value: prebindAs<PtrArray<Int32>>(args, 1))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiCheckbox>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Int64(ref.cast<UiCheckbox>().getValue()))]}
    b.method("setValue") {
        ref, args =>
            ref.cast<UiCheckbox>().setValue(Int32(prebindInt(args, 0)))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderFloat 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderFloat）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderFloat
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderFloat)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderFloat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderFloat")
    b.constructor {
        args => UiSliderFloat(label: prebindStr(args, 0), value: prebindAs<PtrArray<Float32>>(args, 1),
            min: Float32(prebindNum(args, 2, default: 0.0)), max: Float32(prebindNum(args, 3, default: 1.0)),
            format: prebindStr(args, 4, default: "%.3f"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSliderFloat>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Float64(ref.cast<UiSliderFloat>().getValue()))]}
    b.method("setValue") {
        ref, args =>
            ref.cast<UiSliderFloat>().setValue(Float32(prebindNum(args, 0)))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSliderInt 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSliderInt）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSliderInt
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSliderInt)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSliderInt(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSliderInt")
    b.constructor {
        args => UiSliderInt(label: prebindStr(args, 0), value: prebindAs<PtrArray<Int32>>(args, 1),
            min: Int32(prebindInt(args, 2, default: 0)), max: Int32(prebindInt(args, 3, default: 100)),
            format: prebindStr(args, 4, default: "%d"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSliderInt>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Int64(ref.cast<UiSliderInt>().getValue()))]}
    b.method("setValue") {
        ref, args =>
            ref.cast<UiSliderInt>().setValue(Int32(prebindInt(args, 0)))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputText 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputText）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputText
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputText)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputText(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputText")
    b.constructor {
        args =>
            let n = prebindInt(args, 1, default: 256)
            let bufSize = if (n > 0) {
                UIntNative(n)
            } else {
                UIntNative(256)
            }
            UiInputText(label: prebindStr(args, 0), bufSize: bufSize, hint: prebindStr(args, 2, default: ""),
                flags: Int32(prebindInt(args, 3)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiInputText>().draw()})}
    b.method("getText") {ref, _ => [LuaValue.of(ref.cast<UiInputText>().getText())]}
    b.method("setText") {
        ref, args =>
            try {
                ref.cast<UiInputText>().setText(prebindStr(args, 0))
            } catch (_: Exception) {
                ()
            }
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputFloat 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputFloat）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputFloat
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputFloat)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputFloat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputFloat")
    b.constructor {
        args => UiInputFloat(label: prebindStr(args, 0), value: prebindAs<PtrArray<Float32>>(args, 1),
            step: Float32(prebindNum(args, 2, default: 0.1)), stepFast: Float32(prebindNum(args, 3, default: 1.0)),
            format: prebindStr(args, 4, default: "%.3f"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiInputFloat>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Float64(ref.cast<UiInputFloat>().getValue()))]}
    b.method("setValue") {
        ref, args =>
            ref.cast<UiInputFloat>().setValue(Float32(prebindNum(args, 0)))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiCombo 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCombo）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCombo
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiCombo)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCombo(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCombo")
    b.constructor {
        args => UiCombo(label: prebindStr(args, 0), currentItem: prebindAs<PtrArray<Int32>>(args, 1),
            items: prebindStr(args, 2))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiCombo>().draw()})}
    b.method("getCurrentIndex") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiCombo>().getCurrentIndex()))]
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSelectable 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSelectable）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSelectable
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSelectable)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSelectable(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSelectable")
    b.constructor {
        args => UiSelectable(label: prebindStr(args, 0), selected: prebindBool(args, 1),
            flags: Int32(prebindInt(args, 2)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSelectable>().draw()})}
    b.method("isSelected") {ref, _ => [LuaValue.of(ref.cast<UiSelectable>().isSelected())]}
    b.method("setSelected") {
        ref, args =>
            ref.cast<UiSelectable>().setSelected(prebindBool(args, 0))
            []
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSeparator 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSeparator）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSeparator
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSeparator)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSeparator(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSeparator")
    b.constructor {_ => UiSeparator()}
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSeparator>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSameLine 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSameLine）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSameLine
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSameLine)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSameLine(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSameLine")
    b.constructor {
        args => UiSameLine(offset: Float32(prebindNum(args, 0)), spacing: Float32(prebindNum(args, 1, default: -1.0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSameLine>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSpacing 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSpacing）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSpacing
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSpacing)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSpacing(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSpacing")
    b.constructor {_ => UiSpacing()}
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSpacing>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTreeNode 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTreeNode）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTreeNode
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTreeNode)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTreeNode(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTreeNode")
    b.constructor {
        args => UiTreeNode(label: prebindStr(args, 0))
    }
    b.method("withContent") {
        ref, args =>
            ref.cast<UiTreeNode>().withContent(_prebindUiwCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiTreeNode>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTreeNodeEx 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTreeNodeEx）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTreeNodeEx
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTreeNodeEx)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTreeNodeEx(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTreeNodeEx")
    b.constructor {
        args => UiTreeNodeEx(label: prebindStr(args, 0), flags: Int32(prebindInt(args, 1)))
    }
    b.method("withContent") {
        ref, args =>
            ref.cast<UiTreeNodeEx>().withContent(_prebindUiwCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiTreeNodeEx>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiCollapsingHeader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCollapsingHeader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCollapsingHeader
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiCollapsingHeader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCollapsingHeader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCollapsingHeader")
    b.constructor {
        args => UiCollapsingHeader(label: prebindStr(args, 0), flags: Int32(prebindInt(args, 1)))
    }
    b.method("withContent") {
        ref, args =>
            ref.cast<UiCollapsingHeader>().withContent(_prebindUiwCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiCollapsingHeader>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTooltip 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTooltip）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTooltip
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTooltip)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTooltip(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTooltip")
    b.constructor {
        args => UiTooltip(content: _prebindUiwCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiTooltip>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSetTooltip 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSetTooltip）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSetTooltip
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSetTooltip)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSetTooltip(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSetTooltip")
    b.constructor {
        args => UiSetTooltip(text: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSetTooltip>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiProgressBar 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiProgressBar）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiProgressBar
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiProgressBar)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiProgressBar(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiProgressBar")
    b.constructor {
        args => UiProgressBar(fraction: Float32(prebindNum(args, 0)),
            size: _prebindUiwVec2(args, 1, default: Vector2(-1.0, 0.0)), overlay: prebindStr(args, 2, default: ""))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiProgressBar>().draw()})}
    b.method("setFraction") {
        ref, args =>
            ref.cast<UiProgressBar>().setFraction(Float32(prebindNum(args, 0)))
            []
    }
    b.method("getFraction") {
        ref, _ => [LuaValue.of(Float64(ref.cast<UiProgressBar>().getFraction()))]
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiListBox 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiListBox）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiListBox
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiListBox)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiListBox(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiListBox")
    b.constructor {
        args => UiListBox(label: prebindStr(args, 0), currentItem: prebindAs<PtrArray<Int32>>(args, 1),
            items: prebindStr(args, 2), heightInItems: Int32(prebindInt(args, 3, default: -1)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiListBox>().draw()})}
    b.method("getCurrentIndex") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiListBox>().getCurrentIndex()))]
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiImage 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiImage）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiImage
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiImage)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiImage(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiImage")
    b.constructor {
        args => UiImage(texId: UInt64(prebindInt(args, 0)), size: _prebindUiwVec2(args, 1, default: Vector2(64.0, 64.0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiImage>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiImageButton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiImageButton）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiImageButton
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiImageButton)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiImageButton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiImageButton")
    b.constructor {
        args => UiImageButton(strId: prebindStr(args, 0), texId: UInt64(prebindInt(args, 1)),
            size: _prebindUiwVec2(args, 2, default: Vector2(64.0, 64.0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiImageButton>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiColorEdit4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColorEdit4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColorEdit4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColorEdit4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColorEdit4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColorEdit4")
    b.constructor {
        args => UiColorEdit4(label: prebindStr(args, 0), col: prebindAs<PtrArray<Float32>>(args, 1),
            flags: Int32(prebindInt(args, 2)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiColorEdit4>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiColorPicker4 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColorPicker4）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColorPicker4
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColorPicker4)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColorPicker4(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColorPicker4")
    b.constructor {
        args => UiColorPicker4(label: prebindStr(args, 0), col: prebindAs<PtrArray<Float32>>(args, 1),
            flags: Int32(prebindInt(args, 2)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiColorPicker4>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragFloat 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragFloat）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragFloat
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragFloat)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragFloat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragFloat")
    b.constructor {
        args => UiDragFloat(label: prebindStr(args, 0), value: prebindAs<PtrArray<Float32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Float32(prebindNum(args, 3)),
            max: Float32(prebindNum(args, 4)), format: prebindStr(args, 5, default: "%.3f"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiDragFloat>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Float64(ref.cast<UiDragFloat>().getValue()))]}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragInt 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragInt）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragInt
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragInt)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragInt(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragInt")
    b.constructor {
        args => UiDragInt(label: prebindStr(args, 0), value: prebindAs<PtrArray<Int32>>(args, 1),
            speed: Float32(prebindNum(args, 2, default: 1.0)), min: Int32(prebindInt(args, 3)),
            max: Int32(prebindInt(args, 4)), format: prebindStr(args, 5, default: "%d"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiDragInt>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Int64(ref.cast<UiDragInt>().getValue()))]}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputInt 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputInt）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputInt
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputInt)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputInt(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputInt")
    b.constructor {
        args => UiInputInt(label: prebindStr(args, 0), value: prebindAs<PtrArray<Int32>>(args, 1),
            step: Int32(prebindInt(args, 2, default: 1)), stepFast: Int32(prebindInt(args, 3, default: 100)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiInputInt>().draw()})}
    b.method("getValue") {ref, _ => [LuaValue.of(Int64(ref.cast<UiInputInt>().getValue()))]}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiInputDouble 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputDouble）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputDouble
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputDouble)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputDouble(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputDouble")
    b.constructor {
        args => UiInputDouble(label: prebindStr(args, 0), value: prebindAs<PtrArray<Float64>>(args, 1),
            step: prebindNum(args, 2, default: 0.1), stepFast: prebindNum(args, 3, default: 1.0),
            format: prebindStr(args, 4, default: "%.6f"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiInputDouble>().draw()})}
    b.method("getValue") {
        ref, _ => [LuaValue.of(ref.cast<UiInputDouble>().getValue())]
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiVSliderFloat 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiVSliderFloat）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiVSliderFloat
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiVSliderFloat)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiVSliderFloat(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiVSliderFloat")
    b.constructor {
        args => UiVSliderFloat(label: prebindStr(args, 0), value: prebindAs<PtrArray<Float32>>(args, 1),
            size: _prebindUiwVec2(args, 2, default: Vector2(0.0, 0.0)), min: Float32(prebindNum(args, 3, default: 0.0)),
            max: Float32(prebindNum(args, 4, default: 1.0)), format: prebindStr(args, 5, default: "%.3f"))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiVSliderFloat>().draw()})}
    b.method("getValue") {
        ref, _ => [LuaValue.of(Float64(ref.cast<UiVSliderFloat>().getValue()))]
    }
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDisabled 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDisabled）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDisabled
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDisabled)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDisabled(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDisabled")
    b.constructor {
        args =>
            let contentOnly = args.size > 0 && args[0].isFunction
            let disabled = if (contentOnly) {
                true
            } else {
                prebindBool(args, 0, default: true)
            }
            let content = if (contentOnly) {
                _prebindUiwCallback(vm, args, 0)
            } else {
                _prebindUiwCallback(vm, args, 1)
            }
            UiDisabled(disabled: disabled, content: content)
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiDisabled>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiClipRect 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiClipRect）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiClipRect
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiClipRect)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiClipRect(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiClipRect")
    b.constructor {
        args => UiClipRect(min: _prebindUiwVec2(args, 0, default: Vector2(0.0, 0.0)),
            max: _prebindUiwVec2(args, 1, default: Vector2(0.0, 0.0)), content: _prebindUiwCallback(vm, args, 2))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiClipRect>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSetNextItemWidth 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSetNextItemWidth）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSetNextItemWidth
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSetNextItemWidth)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSetNextItemWidth(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSetNextItemWidth")
    b.constructor {
        args => UiSetNextItemWidth(width: Float32(prebindNum(args, 0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSetNextItemWidth>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSetNextItemOpen 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSetNextItemOpen）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSetNextItemOpen
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSetNextItemOpen)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSetNextItemOpen(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSetNextItemOpen")
    b.constructor {
        args => UiSetNextItemOpen(isOpen: prebindBool(args, 0, default: true), cond: Int32(prebindInt(args, 1)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSetNextItemOpen>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSeparatorText 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSeparatorText）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSeparatorText
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSeparatorText)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSeparatorText(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSeparatorText")
    b.constructor {
        args => UiSeparatorText(label: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiSeparatorText>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiPlotLines 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiPlotLines）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiPlotLines
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiPlotLines)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiPlotLines(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiPlotLines")
    b.constructor {
        args => UiPlotLines(label: prebindStr(args, 0), values: prebindAs<PtrArray<Float32>>(args, 1),
            offset: Int32(prebindInt(args, 2)), overlay: prebindStr(args, 3, default: ""),
            scaleMin: Float32(prebindNum(args, 4, default: 3.4028235e38)),
            scaleMax: Float32(prebindNum(args, 5, default: 3.4028235e38)),
            size: _prebindUiwVec2(args, 6, default: Vector2(0.0, 0.0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiPlotLines>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiPlotHistogram 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiPlotHistogram）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiPlotHistogram
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiPlotHistogram)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiPlotHistogram(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiPlotHistogram")
    b.constructor {
        args => UiPlotHistogram(label: prebindStr(args, 0), values: prebindAs<PtrArray<Float32>>(args, 1),
            offset: Int32(prebindInt(args, 2)), overlay: prebindStr(args, 3, default: ""),
            scaleMin: Float32(prebindNum(args, 4, default: 3.4028235e38)),
            scaleMax: Float32(prebindNum(args, 5, default: 3.4028235e38)),
            size: _prebindUiwVec2(args, 6, default: Vector2(0.0, 0.0)))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiPlotHistogram>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiValue 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiValue）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiValue
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiValue)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiValue(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiValue")
    b.constructor {
        args => UiValue(prefix: prebindStr(args, 0), value: Float32(prebindNum(args, 1)),
            format: prebindStr(args, 2, default: ""))
    }
    b.method("draw") {ref, _ => _prebindUiwDraw({=> ref.cast<UiValue>().draw()})}
    b.method("setValue") {
        ref, args =>
            ref.cast<UiValue>().setValue(Float32(prebindNum(args, 0)))
            []
    }
    b.method("getValue") {ref, _ => [LuaValue.of(Float64(ref.cast<UiValue>().getValue()))]}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiItemQuery 的 Lua 绑定（纯静态工具类，无构造）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiItemQuery）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiItemQuery (stateless utility class, no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiItemQuery)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiItemQuery(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiItemQuery")
    // ===== 悬停 / 激活 / 焦点 =====
    b.staticMethod("isItemHovered") {
        args => [LuaValue.of(UiItemQuery.isItemHovered(flags: Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isItemActive") {
        _ => [LuaValue.of(UiItemQuery.isItemActive())]
    }
    b.staticMethod("isItemFocused") {
        _ => [LuaValue.of(UiItemQuery.isItemFocused())]
    }
    b.staticMethod("isItemClicked") {
        args => [LuaValue.of(UiItemQuery.isItemClicked(mouseButton: Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isItemVisible") {
        _ => [LuaValue.of(UiItemQuery.isItemVisible())]
    }
    b.staticMethod("isItemEdited") {
        _ => [LuaValue.of(UiItemQuery.isItemEdited())]
    }
    b.staticMethod("isItemActivated") {
        _ => [LuaValue.of(UiItemQuery.isItemActivated())]
    }
    b.staticMethod("isItemDeactivated") {
        _ => [LuaValue.of(UiItemQuery.isItemDeactivated())]
    }
    b.staticMethod("isItemDeactivatedAfterEdit") {
        _ => [LuaValue.of(UiItemQuery.isItemDeactivatedAfterEdit())]
    }
    b.staticMethod("isItemToggledOpen") {
        _ => [LuaValue.of(UiItemQuery.isItemToggledOpen())]
    }
    b.staticMethod("isAnyItemHovered") {
        _ => [LuaValue.of(UiItemQuery.isAnyItemHovered())]
    }
    b.staticMethod("isAnyItemActive") {
        _ => [LuaValue.of(UiItemQuery.isAnyItemActive())]
    }
    b.staticMethod("isAnyItemFocused") {
        _ => [LuaValue.of(UiItemQuery.isAnyItemFocused())]
    }
    // ===== 几何查询 =====
    b.staticMethod("getItemID") {
        _ => [LuaValue.of(Int64(UiItemQuery.getItemID()))]
    }
    b.staticMethod("getItemRectMin") {
        _ => [prebindRegister(UiItemQuery.getItemRectMin(), "three.core.math.Vector2")]
    }
    b.staticMethod("getItemRectMax") {
        _ => [prebindRegister(UiItemQuery.getItemRectMax(), "three.core.math.Vector2")]
    }
    b.staticMethod("getItemRectSize") {
        _ => [prebindRegister(UiItemQuery.getItemRectSize(), "three.core.math.Vector2")]
    }
    b.staticMethod("setItemDefaultFocus") {
        _ =>
            UiItemQuery.setItemDefaultFocus()
            []
    }
    b.staticMethod("setNextItemAllowOverlap") {
        _ =>
            UiItemQuery.setNextItemAllowOverlap()
            []
    }
    // ===== ID 栈 =====
    b.staticMethod("pushID") {
        args =>
            try {
                UiItemQuery.pushID(prebindStr(args, 0))
            } catch (_: Exception) {
                ()
            }
            []
    }
    b.staticMethod("pushIDInt") {
        args =>
            UiItemQuery.pushIDInt(Int32(prebindInt(args, 0)))
            []
    }
    b.staticMethod("popID") {
        _ =>
            UiItemQuery.popID()
            []
    }
    // ===== 焦点 =====
    b.staticMethod("setKeyboardFocusHere") {
        args =>
            UiItemQuery.setKeyboardFocusHere(offset: Int32(prebindInt(args, 0)))
            []
    }
    b.install(vm)
}
