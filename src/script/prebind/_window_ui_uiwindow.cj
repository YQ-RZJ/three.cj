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
 * @file[zh-cn] window_ui_uiwindow UiWindow.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiWindow 绑定为 Lua 类型 three.window.ui.UiWindow
 * @explain[zh-cn] 覆盖：两个构造（普通窗口 / 带 PtrArrayInt32 open 的关闭按钮窗口，第二参数为对象时按
 * open 数组解析，否则按 flags 数值解析）、实例方法 begin()/end()/draw(content)、全部静态方法
 * （create/createWithClose、setNextWindow* 定位与约束、isWindow* 状态查询、getWindow* 尺寸查询、
 * beginChild/endChild、getScroll 系列 / setScroll 系列）。适配约定：
 * - draw(content) 的 Lua 函数经 prebindOptCallback 包装为无参闭包，回调内异常在闭包内捕获并吞掉，
 *   缺省传空闭包；draw 自身异常返回 false；
 * - Vector2 参数缺失 / nil / 非对象时回落到默认值，Vector2 返回值经 prebindRegister 注册为
 *   three.core.math.Vector2；
 * - 整型以 Int32(...) 回写，Bool 以 Lua 布尔返回，Float32 以 Float64(...) 返回、Float32(...) 回写；
 * - 静态工厂返回新实例，经 prebindRegister 注册为 three.window.ui.UiWindow。
 * 跳过成员及原因：
 * - 无 public 成员因类型不可映射而被跳过；
 * - private 字段 _title/_flags/_open/_openValue 不属于脚本接口，仅经构造与 begin() 内部使用，故不暴露。
 *
 * @file[en] window_ui_uiwindow  Lua binding of UiWindow.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiWindow as the Lua type three.window.ui.UiWindow
 * @explain[en] Coverage: both constructors (plain window / close-button window with a PtrArrayInt32
 * open array — when the second argument is an object it is treated as the open array, otherwise as
 * the numeric flags), instance methods begin()/end()/draw(content), and every static method
 * (create/createWithClose, setNextWindow* positioning/constraints, isWindow* state queries,
 * getWindow* size queries, beginChild/endChild, the getScroll set / setScroll set). Conventions:
 * - The Lua function given to draw(content) is wrapped by prebindOptCallback into a no-arg closure;
 *   exceptions raised by the callback are caught inside the closure, a no-op closure is used when
 *   absent, and draw itself returns false if an exception occurs;
 * - Vector2 arguments fall back to the default when missing/nil/not an object, and Vector2 results
 *   are registered as three.core.math.Vector2 via prebindRegister;
 * - Integers are written back with Int32(...), Bool is returned as a Lua boolean, and Float32 is
 *   returned as Float64(...) and written back with Float32(...);
 * - Static factories return new instances registered as three.window.ui.UiWindow.
 * Skipped members and reasons:
 * - No public member is skipped for unmappable types;
 * - The private fields _title/_flags/_open/_openValue are not a script API (used only by the
 *   constructors and begin()), so they are not exposed.
 */
package three.script.prebind

import three.core.math.*
import three.utils.memory.PtrArray
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
private func _prebindUiwContent(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
 * @brief[zh-cn] 执行窗口 draw() 并包装为 Lua 返回值（异常返回 false）
 * @param[zh-cn] fn 窗口 draw() 调用
 * @return[zh-cn] 单元素 Lua 返回值（Bool）
 *
 * @brief[en] Executes the window draw() and wraps it as a Lua return value (false on exception)
 * @param[en] fn The window draw() call
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
 * @brief[zh-cn] 安装 UiWindow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiWindow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiWindow
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiWindow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiWindow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiWindow")
    b.constructor {
        args =>
            let title = prebindStr(args, 0)
            if (args.size > 1 && !args[1].isNil && args[1].isObject) {
                UiWindow(title: title, open: prebindAs<PtrArray<Int32>>(args, 1), flags: Int32(prebindInt(args, 2)))
            } else {
                UiWindow(title: title, flags: Int32(prebindInt(args, 1)))
            }
    }
    b.method("begin") {ref, _ => [LuaValue.of(ref.cast<UiWindow>().begin())]}
    b.method("end") {
        ref, _ =>
            ref.cast<UiWindow>().end()
            []
    }
    b.method("draw") {
        ref, args => _prebindUiwDraw({=> ref.cast<UiWindow>().draw(_prebindUiwContent(vm, args, 0))})
    }

    // ===== 静态工厂 / Static factories =====
    b.staticMethod("create") {
        args => [prebindRegister(UiWindow.create(prebindStr(args, 0), flags: Int32(prebindInt(args, 1))),
            "three.window.ui.UiWindow")]
    }
    b.staticMethod("createWithClose") {
        args => [prebindRegister(UiWindow.createWithClose(prebindStr(args, 0), flags: Int32(prebindInt(args, 1))),
            "three.window.ui.UiWindow")]
    }

    // ===== 窗口定位 / Window positioning =====
    b.staticMethod("setNextWindowPos") {
        args =>
            UiWindow.setNextWindowPos(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                cond: Int32(prebindInt(args, 2)), pivotX: Float32(prebindNum(args, 3, default: 0.0)),
                pivotY: Float32(prebindNum(args, 4, default: 0.0)))
            []
    }
    b.staticMethod("setNextWindowPosVec") {
        args =>
            UiWindow.setNextWindowPosVec(_prebindUiwVec2(args, 0, default: Vector2(0.0, 0.0)),
                cond: Int32(prebindInt(args, 1)), pivot: _prebindUiwVec2(args, 2, default: Vector2(0.0, 0.0)))
            []
    }
    b.staticMethod("setNextWindowSize") {
        args =>
            UiWindow.setNextWindowSize(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                cond: Int32(prebindInt(args, 2)))
            []
    }
    b.staticMethod("setNextWindowCollapsed") {
        args =>
            UiWindow.setNextWindowCollapsed(prebindBool(args, 0), cond: Int32(prebindInt(args, 1)))
            []
    }
    b.staticMethod("setNextWindowFocus") {
        _ =>
            UiWindow.setNextWindowFocus()
            []
    }
    b.staticMethod("setNextWindowBgAlpha") {
        args =>
            UiWindow.setNextWindowBgAlpha(Float32(prebindNum(args, 0)))
            []
    }
    b.staticMethod("setNextWindowSizeConstraints") {
        args =>
            UiWindow.setNextWindowSizeConstraints(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                Float32(prebindNum(args, 2)), Float32(prebindNum(args, 3)))
            []
    }

    // ===== 状态查询 / State queries =====
    b.staticMethod("isWindowAppearing") {_ => [LuaValue.of(UiWindow.isWindowAppearing())]}
    b.staticMethod("isWindowCollapsed") {_ => [LuaValue.of(UiWindow.isWindowCollapsed())]}
    b.staticMethod("isWindowFocused") {
        args => [LuaValue.of(UiWindow.isWindowFocused(flags: Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("isWindowHovered") {
        args => [LuaValue.of(UiWindow.isWindowHovered(flags: Int32(prebindInt(args, 0))))]
    }
    b.staticMethod("getWindowPos") {
        _ => [prebindRegister(UiWindow.getWindowPos(), "three.core.math.Vector2")]
    }
    b.staticMethod("getWindowSize") {
        _ => [prebindRegister(UiWindow.getWindowSize(), "three.core.math.Vector2")]
    }
    b.staticMethod("getWindowWidth") {_ => [LuaValue.of(Float64(UiWindow.getWindowWidth()))]}
    b.staticMethod("getWindowHeight") {_ => [LuaValue.of(Float64(UiWindow.getWindowHeight()))]}

    // ===== 子窗口 / Child windows =====
    b.staticMethod("beginChild") {
        args => [LuaValue.of(
            UiWindow.beginChild(prebindStr(args, 0), w: Float32(prebindNum(args, 1, default: 0.0)),
                h: Float32(prebindNum(args, 2, default: 0.0)), childFlags: Int32(prebindInt(args, 3)),
                windowFlags: Int32(prebindInt(args, 4))))]
    }
    b.staticMethod("endChild") {
        _ =>
            UiWindow.endChild()
            []
    }

    // ===== 滚动 / Scrolling =====
    b.staticMethod("getScrollX") {_ => [LuaValue.of(Float64(UiWindow.getScrollX()))]}
    b.staticMethod("getScrollY") {_ => [LuaValue.of(Float64(UiWindow.getScrollY()))]}
    b.staticMethod("getScrollMaxX") {_ => [LuaValue.of(Float64(UiWindow.getScrollMaxX()))]}
    b.staticMethod("getScrollMaxY") {_ => [LuaValue.of(Float64(UiWindow.getScrollMaxY()))]}
    b.staticMethod("setScrollX") {
        args =>
            UiWindow.setScrollX(Float32(prebindNum(args, 0)))
            []
    }
    b.staticMethod("setScrollY") {
        args =>
            UiWindow.setScrollY(Float32(prebindNum(args, 0)))
            []
    }
    b.staticMethod("setScrollHereY") {
        args =>
            UiWindow.setScrollHereY(centerYRatio: Float32(prebindNum(args, 0, default: 0.5)))
            []
    }
    b.staticMethod("setScrollHereX") {
        args =>
            UiWindow.setScrollHereX(centerXRatio: Float32(prebindNum(args, 0, default: 0.5)))
            []
    }
    b.install(vm)
}
