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
 * @file[zh-cn] window_ui_uidragdrop UiDragDrop.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui 的拖放组件绑定为 Lua 类型：UiDragDropSource、UiDragDropTarget、
 * UiSetDragDropPayload、UiAcceptDragDropPayload、UiGetDragDropPayload
 * @explain[zh-cn] 覆盖范围：五个拖放控件的构造、draw() 以及 UiAcceptDragDropPayload.onAccept(callback)
 * 与基类 UiWidget.getId()。Lua 侧用法：
 *   local src = three.window.ui.UiDragDropSource.new(0, function() ... end)
 *   src.draw()
 *   local tgt = three.window.ui.UiDragDropTarget.new(function() ... end)
 *   tgt.draw()
 * 适配约定：
 * - 构造按位置参数读取：UiDragDropSource(flags, content)、UiDragDropTarget(content)、
 *   UiSetDragDropPayload(type, flags)、UiAcceptDragDropPayload(type, flags)、UiGetDragDropPayload(type)；
 * - 可选参数用 prebindInt / prebindStr 的默认值越界安全读取，type 字符串直接用 prebindStr；
 * - content: () -> Unit 闭包参数经 prebindOptCallback 包装为仓颉闭包，缺省为空闭包，回调异常在闭包内
 *   捕获并吞掉；
 * - UiAcceptDragDropPayload.onAccept(callback) 返回自身，绑定为链式调用；
 * - draw(): Bool 直接以 LuaValue.of(...) 返回，异常返回 false；
 * - 绑定层无 __index 继承链，故每个控件重复登记基类 UiWidget 的 getId()。
 * 跳过成员及原因：
 * - 无 public 成员因类型不可映射而被跳过（本文件五个类均不含 VoidPtr / CPointer / ImVec4 / 接口实例
 *   类型的公开成员）；
 * - 私有字段 _flags/_type/_onAccept 无 public getter/setter，保持私有；
 * - UiGetDragDropPayload 的 _type 仅作占位（当前实现未参与查询），其值只能经构造设置，无独立成员。
 *
 * @file[en] window_ui_uidragdrop  Lua binding of UiDragDrop.cj (three.script.prebind)
 * @brief[en] Binds the three.window.ui drag-and-drop widgets as Lua types: UiDragDropSource,
 * UiDragDropTarget, UiSetDragDropPayload, UiAcceptDragDropPayload and UiGetDragDropPayload
 * @explain[en] Coverage: constructors and draw() of all five widgets, plus
 * UiAcceptDragDropPayload.onAccept(callback) and the inherited UiWidget.getId(). Lua usage:
 *   local src = three.window.ui.UiDragDropSource.new(0, function() ... end)
 *   src.draw()
 *   local tgt = three.window.ui.UiDragDropTarget.new(function() ... end)
 *   tgt.draw()
 * Conventions:
 * - Constructors read positional arguments: UiDragDropSource(flags, content),
 *   UiDragDropTarget(content), UiSetDragDropPayload(type, flags),
 *   UiAcceptDragDropPayload(type, flags), UiGetDragDropPayload(type);
 * - Optional arguments use the prebindInt / prebindStr defaults (out-of-range safe); the type string
 *   is read with prebindStr;
 * - content: () -> Unit parameters are wrapped with prebindOptCallback into Cangjie closures (a no-op
 *   closure when absent); callback exceptions are caught inside the closure;
 * - UiAcceptDragDropPayload.onAccept(callback) returns the receiver, so it is bound as a chainable call;
 * - draw(): Bool is returned through LuaValue.of(...) and becomes false on exception;
 * - The binding layer has no __index inheritance chain, so every widget re-registers the UiWidget
 *   base method getId().
 * Skipped members and reasons:
 * - No public member is skipped for unmappable types (none of the five classes has a public
 *   VoidPtr / CPointer / ImVec4 / interface-typed member);
 * - Private fields _flags/_type/_onAccept have no public getters/setters and stay private;
 * - UiGetDragDropPayload._type is only a placeholder (unused by the current implementation); it can only
 *   be set through the constructor and has no separate member.
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
 * @brief[en] Wraps an optional Lua callback into a Cangjie no-arg closure (no-op when absent; callback
 * exceptions are caught inside the closure)
 * @param[en] vm The target virtual machine
 * @param[en] args The Lua argument array
 * @param[en] idx The callback argument index
 * @return[en] The no-arg closure
 */
private func _prebindUiddCallback(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
 * @brief[en] Executes a widget draw() and wraps it as a Lua result (false on exception)
 * @param[en] fn The widget draw() call
 * @return[en] A single-element Lua result (Bool)
 */
private func _prebindUiddBool(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiDragDropSource 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragDropSource）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragDropSource
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragDropSource)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragDropSource(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragDropSource")
    b.constructor {
        args => UiDragDropSource(flags: Int32(prebindInt(args, 0)), content: _prebindUiddCallback(vm, args, 1))
    }
    b.method("draw") {ref, _ => _prebindUiddBool({=> ref.cast<UiDragDropSource>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragDropSource>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiDragDropTarget 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiDragDropTarget）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiDragDropTarget
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiDragDropTarget)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiDragDropTarget(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiDragDropTarget")
    b.constructor {
        args => UiDragDropTarget(content: _prebindUiddCallback(vm, args, 0))
    }
    b.method("draw") {ref, _ => _prebindUiddBool({=> ref.cast<UiDragDropTarget>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiDragDropTarget>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiSetDragDropPayload 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiSetDragDropPayload）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiSetDragDropPayload
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiSetDragDropPayload)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiSetDragDropPayload(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiSetDragDropPayload")
    b.constructor {
        args => UiSetDragDropPayload(`type`: prebindStr(args, 0), flags: Int32(prebindInt(args, 1)))
    }
    b.method("draw") {ref, _ => _prebindUiddBool({=> ref.cast<UiSetDragDropPayload>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiSetDragDropPayload>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiAcceptDragDropPayload 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiAcceptDragDropPayload）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiAcceptDragDropPayload
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiAcceptDragDropPayload)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiAcceptDragDropPayload(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiAcceptDragDropPayload")
    b.constructor {
        args => UiAcceptDragDropPayload(`type`: prebindStr(args, 0), flags: Int32(prebindInt(args, 1)))
    }
    b.method("onAccept") {
        ref, args =>
            ref.cast<UiAcceptDragDropPayload>().onAccept(_prebindUiddCallback(vm, args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("draw") {ref, _ => _prebindUiddBool({=> ref.cast<UiAcceptDragDropPayload>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiAcceptDragDropPayload>().getId())]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiGetDragDropPayload 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiGetDragDropPayload）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiGetDragDropPayload
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiGetDragDropPayload)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiGetDragDropPayload(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiGetDragDropPayload")
    b.constructor {
        args => UiGetDragDropPayload(`type`: prebindStr(args, 0, default: ""))
    }
    b.method("draw") {ref, _ => _prebindUiddBool({=> ref.cast<UiGetDragDropPayload>().draw()})}
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiGetDragDropPayload>().getId())]}
    b.install(vm)
}
