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
 * @file[zh-cn] window_ui_uicursor UiCursor.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiCursor（全静态）与 UiIdScope 绑定为 Lua 类型
 * @explain[zh-cn] 覆盖：UiCursor 的全部 public 静态方法（屏幕/窗口相对光标读写、内容区可用尺寸、
 * ID 栈 pushId/pushIdInt/popId、行高与帧高度量）；UiIdScope 的构造 (id, content)、draw() 与 getId()。
 * 适配约定：
 * - UiCursor 为纯静态工具类，只使用 staticMethod，不提供构造；
 * - Vector2 参数缺失 / nil / 非对象时回落到 Vector2(0,0)，Vector2 返回值经 prebindRegister 注册为
 *   three.core.math.Vector2；
 * - pushIdInt 以 Int32(...) 回写，Float32 返回值以 Float64(...) 返回；
 * - UiIdScope(content) 的 Lua 函数经 prebindOptCallback 包装为无参闭包，异常在闭包内捕获；draw()
 *   异常返回 false。
 * 跳过成员及原因：
 * - 无 public 成员因类型不可映射而被跳过；
 * - UiIdScope 的 private 字段 _id/_content 不属于脚本接口，仅经构造与 draw() 使用，故不暴露。
 *
 * @file[en] window_ui_uicursor  Lua binding of UiCursor.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiCursor (all-static) and UiIdScope as Lua types
 * @explain[en] Coverage: every public static method of UiCursor (screen/window-relative cursor
 * read/write, content-region available size, ID stack pushId/pushIdInt/popId, line and frame
 * metrics); plus UiIdScope's constructor (id, content), draw() and getId(). Conventions:
 * - UiCursor is a purely static utility: staticMethod only, no constructor;
 * - Vector2 arguments fall back to Vector2(0, 0) when missing/nil/not an object, and Vector2 results
 *   are registered as three.core.math.Vector2 via prebindRegister;
 * - pushIdInt writes back with Int32(...), Float32 results are returned as Float64(...);
 * - The Lua function given to UiIdScope(content) is wrapped by prebindOptCallback into a no-arg
 *   closure with exceptions caught inside; draw() returns false on exception.
 * Skipped members and reasons:
 * - No public member is skipped for unmappable types;
 * - UiIdScope's private fields _id/_content are not a script API (used only by its constructor and
 *   draw()), so they are not exposed.
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
 * @brief[en] Reads an optional Vector2 argument (falls back to the default when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @param[en] default The default value
 * @return[en] The resolved Vector2
 */
private func _prebindUicVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
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
private func _prebindUicContent(vm: LuaVM, args: Array<LuaValue>, idx: Int64): () -> Unit {
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
 * @brief[zh-cn] 安装 UiCursor 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiCursor）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiCursor
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiCursor)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiCursor(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiCursor")

    // ===== 屏幕坐标光标 / Screen-space cursor =====
    b.staticMethod("getCursorScreenPos") {
        _ => [prebindRegister(UiCursor.getCursorScreenPos(), "three.core.math.Vector2")]
    }
    b.staticMethod("setCursorScreenPos") {
        args =>
            UiCursor.setCursorScreenPos(_prebindUicVec2(args, 0, default: Vector2(0.0, 0.0)))
            []
    }

    // ===== 窗口相对光标 / Window-relative cursor =====
    b.staticMethod("getCursorPos") {
        _ => [prebindRegister(UiCursor.getCursorPos(), "three.core.math.Vector2")]
    }
    b.staticMethod("setCursorPos") {
        args =>
            UiCursor.setCursorPos(_prebindUicVec2(args, 0, default: Vector2(0.0, 0.0)))
            []
    }

    // ===== 内容区 / Content region =====
    b.staticMethod("getContentRegionAvail") {
        _ => [prebindRegister(UiCursor.getContentRegionAvail(), "three.core.math.Vector2")]
    }

    // ===== ID 栈 / ID stack =====
    b.staticMethod("pushId") {
        args =>
            UiCursor.pushId(prebindStr(args, 0))
            []
    }
    b.staticMethod("pushIdInt") {
        args =>
            UiCursor.pushIdInt(Int32(prebindInt(args, 0)))
            []
    }
    b.staticMethod("popId") {
        _ =>
            UiCursor.popId()
            []
    }

    // ===== 行高 / 帧高度量 / Line and frame metrics =====
    b.staticMethod("getTextLineHeight") {
        _ => [LuaValue.of(Float64(UiCursor.getTextLineHeight()))]
    }
    b.staticMethod("getTextLineHeightWithSpacing") {
        _ => [LuaValue.of(Float64(UiCursor.getTextLineHeightWithSpacing()))]
    }
    b.staticMethod("getFrameHeight") {_ => [LuaValue.of(Float64(UiCursor.getFrameHeight()))]}
    b.staticMethod("getFrameHeightWithSpacing") {
        _ => [LuaValue.of(Float64(UiCursor.getFrameHeightWithSpacing()))]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiIdScope 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiIdScope）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiIdScope
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiIdScope)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiIdScope(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiIdScope")
    b.constructor {
        args => UiIdScope(id: prebindStr(args, 0), content: _prebindUicContent(vm, args, 1))
    }
    b.method("draw") {
        ref, _ => try {
            [LuaValue.of(ref.cast<UiIdScope>().draw())]
        } catch (_: Exception) {
            [LuaValue.of(false)]
        }
    }
    b.method("getId") {ref, _ => [LuaValue.of(ref.cast<UiIdScope>().getId())]}
    b.install(vm)
}
