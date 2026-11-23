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
 * @file[zh-cn] window_ui_uilayout UiLayout.cj 布局辅助控件的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiLayout.cj 中 11 个 public 布局控件绑定为 Lua 类型
 * @explain[zh-cn] 覆盖范围（Lua 类名统一为 three.window.ui.<类名>）：UiGroup、UiIndent、
 * UiUnindent、UiNewLine、UiDummy、UiTextWrapped、UiTextColored、UiTextDisabled、UiBullet、
 * UiDisabledBlock、UiColumns，共 11 个安装函数（每个类一个 installXxx(vm)）。
 * 适配约定：
 * - 构造按位置参数传入；可选参数经 prebindNum/prebindInt/prebindBool/prebindStr 的 default 形参
 *   越界安全读取，取源码中的默认值；
 * - () -> Unit 参数（UiGroup/UiDisabledBlock/UiColumns 的 content、UiBullet.withContent）经
 *   prebindOptCallback 包装为仓颉闭包，缺少时传空闭包，回调异常在闭包内捕获并吞掉；
 *   UiDisabledBlock 额外兼容「首个参数即函数」的 UiDisabledBlock(fn) 形态（disabled 取默认 true）；
 * - Vector2 参数（UiDummy.size）用对象探测，缺失、nil 或非对象时回落到 (0, 0)；
 * - Color 参数（UiTextColored.color）同样用对象探测，缺失或非对象时回落到白色 Color(1, 1, 1)，
 *   Lua 侧使用已绑定的 three.core.math.Color；
 * - 返回 Bool 的 draw() 全部绑定，内部异常返回 false；
 * - 返回自身的链式方法（UiBullet.withContent）返回 [LuaValue.Object(ref.id)]；
 * - 绑定层无 __index 继承链，因此不重复登记基类 UiWidget 的 getId()（与 window_ui_uiwidget.cj
 *   的写法一致）；Lua 侧需要 ID 时请使用 UiWidget 的绑定。
 * 跳过成员及原因：
 * - 所有类的字段（_content/_w/_size/_text/_color/_disabled/_count/_id/_border）均为 private，
 *   只能经构造与成员方法访问，无独立 public 成员可绑定；
 * - 本文件不含 CPointer/VoidPtr/ImVec4/接口实例类型的 public 成员，故无因类型不可映射而跳过的
 *   成员；ImVec4/Color 仅在 draw() 内部使用，未出现在公开签名中。
 *
 * @file[en] window_ui_uilayout  Lua binding of the UiLayout.cj layout widgets (three.script.prebind)
 * @brief[en] Binds the 11 public layout widgets of three.window.ui.UiLayout.cj as Lua types
 * @explain[en] Coverage (Lua class names are three.window.ui.<ClassName>): UiGroup, UiIndent,
 * UiUnindent, UiNewLine, UiDummy, UiTextWrapped, UiTextColored, UiTextDisabled, UiBullet,
 * UiDisabledBlock and UiColumns — 11 install functions (one installXxx(vm) per class).
 * Conventions:
 * - Constructors take positional arguments; optional arguments are read through prebindNum/
 *   prebindInt/prebindBool/prebindStr with the source defaults and are out-of-range safe;
 * - () -> Unit parameters (content of UiGroup/UiDisabledBlock/UiColumns, UiBullet.withContent)
 *   are wrapped with prebindOptCallback into Cangjie closures; a no-op closure is used when
 *   absent and callback exceptions are caught inside the closure. UiDisabledBlock additionally
 *   accepts the content-only form UiDisabledBlock(fn) (disabled defaults to true);
 * - The Vector2 parameter (UiDummy.size) is probed as an object and falls back to (0, 0) when
 *   missing, nil or not an object;
 * - The Color parameter (UiTextColored.color) is probed the same way and falls back to the white
 *   Color(1, 1, 1); on the Lua side the bound three.core.math.Color is used;
 * - Every Bool-returning draw() is bound and returns false if an exception occurs;
 * - Self-returning chain methods (UiBullet.withContent) return [LuaValue.Object(ref.id)];
 * - The binding layer has no __index inheritance chain, so the inherited UiWidget.getId() is not
 *   re-registered (same as window_ui_uiwidget.cj); use the UiWidget binding when an ID is needed.
 * Skipped members and reasons:
 * - All fields (_content/_w/_size/_text/_color/_disabled/_count/_id/_border) are private and are
 *   reachable only through constructors and methods, so there is no separate public member to bind;
 * - No public member here uses CPointer/VoidPtr/ImVec4/interface instances, so nothing is skipped
 *   for unmappable types; ImVec4/Color are used only inside draw() and never appear in public
 *   signatures.
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
private func _prebindUilVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<Vector2>(args, idx)
    }
    return default
}

/**
 * @brief[zh-cn] 读取可选 Color 参数（缺失 / nil / 非对象时返回默认值）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @param[zh-cn] default 缺省值
 * @return[zh-cn] 解析到的 Color
 *
 * @brief[en] Reads an optional Color argument (default when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default value
 * @return[en] The resolved Color
 */
private func _prebindUilColor(args: Array<LuaValue>, idx: Int64, default!: Color): Color {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<Color>(args, idx)
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
private func _prebindUilCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
private func _prebindUilDraw(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiGroup 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiGroup）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiGroup
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiGroup)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiGroup(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiGroup")
    b.constructor {
        args => UiGroup(content: _prebindUilCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiGroup>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiIndent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiIndent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiIndent
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiIndent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiIndent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiIndent")
    b.constructor {
        args => UiIndent(w: Float32(prebindNum(args, 0)))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiIndent>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiUnindent 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiUnindent）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiUnindent
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiUnindent)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiUnindent(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiUnindent")
    b.constructor {
        args => UiUnindent(w: Float32(prebindNum(args, 0)))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiUnindent>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiNewLine 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiNewLine）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiNewLine
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiNewLine)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiNewLine(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiNewLine")
    b.constructor {_ => UiNewLine()}
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiNewLine>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDummy 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDummy）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDummy
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDummy)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDummy(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDummy")
    b.constructor {
        args => UiDummy(size: _prebindUilVec2(args, 0, default: Vector2(0.0, 0.0)))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiDummy>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTextWrapped 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextWrapped）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextWrapped
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextWrapped)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextWrapped(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextWrapped")
    b.constructor {
        args => UiTextWrapped(text: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiTextWrapped>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTextColored 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextColored）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextColored
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextColored)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextColored(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextColored")
    b.constructor {
        args => UiTextColored(text: prebindStr(args, 0), color: _prebindUilColor(args, 1, default: Color(1.0, 1.0, 1.0)))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiTextColored>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiTextDisabled 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiTextDisabled）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiTextDisabled
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiTextDisabled)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiTextDisabled(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiTextDisabled")
    b.constructor {
        args => UiTextDisabled(text: prebindStr(args, 0))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiTextDisabled>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiBullet 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiBullet）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiBullet
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiBullet)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiBullet(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiBullet")
    b.constructor {_ => UiBullet()}
    b.method("withContent") {
        ref, args =>
            ref.cast<UiBullet>().withContent(_prebindUilCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiBullet>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDisabledBlock 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDisabledBlock）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDisabledBlock
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDisabledBlock)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDisabledBlock(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDisabledBlock")
    b.constructor {
        args =>
            let contentOnly = args.size > 0 && args[0].isFunction
            let disabled = if (contentOnly) {
                true
            } else {
                prebindBool(args, 0, default: true)
            }
            let content = if (contentOnly) {
                _prebindUilCallback(vm, args, 0)
            } else {
                _prebindUilCallback(vm, args, 1)
            }
            UiDisabledBlock(disabled: disabled, content: content)
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiDisabledBlock>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiColumns 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiColumns）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiColumns
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiColumns)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiColumns(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiColumns")
    b.constructor {
        args => UiColumns(count: Int32(prebindInt(args, 0, default: 2)), id: prebindStr(args, 1, default: ""),
            border: prebindBool(args, 2, default: false), content: _prebindUilCallback(vm, args, 3))
    }
    b.method("draw") {ref, _ => _prebindUilDraw({=> ref.cast<UiColumns>().draw()})}
    prebindInstallUiWidgetBase(b)
    b.install(vm)
}
