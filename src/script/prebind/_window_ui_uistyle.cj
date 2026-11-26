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
 * @file[zh-cn] window_ui_uistyle UiStyle.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiStyle 绑定为 Lua 类型 three.window.ui.UiStyle
 * @explain[zh-cn] 覆盖预设主题（dark/light/classic）、颜色与样式变量的压栈/弹栈、颜色查询、
 * 字体压栈/查询、样式编辑器展示、INI 持久化、控件宽度/换行/标志栈、帧信息、文本尺寸、
 * 剪贴板、颜色换算，以及 ImGuiStyle 常用字段的读写。
 * 适配约定：
 * - 主题、帧信息、文本尺寸、剪贴板、颜色换算、ImGuiStyle 字段读写等静态能力一律用
 *   b.staticMethod；压栈/弹栈与字体等依赖当前上下文的实例方法用 b.method，实例经
 *   new() 创建（UiStyle 为公开默认构造）；
 * - (Float32, Float32) / (Float32, Float32, Float32) 元组返回统一转为 Lua 数组 [a, b(, c)]；
 * - Color / Color4 参数经 prebindAs<Color> / prebindAs<Color4> 读取，返回值经 prebindRegister
 *   注册为 three.core.math.Color / three.core.math.Color4；
 * - Vector2 参数按对象探测（缺失 / nil / 非对象回落默认值），返回值注册为
 *   three.core.math.Vector2；
 * - ImVec4 改用 4 个数值（x, y, z, w）的 Lua 数组表示：u32ToVec4 返回数组，
 *   vec4ToU32 接受数组；
 * - 整型以 Int64(...) 返回、Int32(...)/UInt32(... & 0xFFFFFFFF) 回写；浮点以 Float64(...)
 *   返回、Float32(...) 回写；
 * - 绑定 lambda 内异常一律在 _prebindUistUnit/_prebindUistValue/_prebindUistBool 内捕获，
 *   不向 Lua 逃逸（失败时 Unit 返回空、取值返回 nil、布尔返回 false）。
 * 跳过成员及原因：
 * - read()/write(style: ImGuiStyle)：ImGuiStyle 是 imgui4cj 的 FFI 结构体，无 Lua 侧类型映射，
 *   且字段布局不稳定，故不绑定；常用字段已由 getAlpha/setAlpha、getItemSpacing/setItemSpacing、
 *   getWindowPadding/setWindowPadding、getFramePadding/setFramePadding、getFrameRounding/
 *   setFrameRounding、getColorVec4/setColor 等逐项覆盖；
 * - showStyleEditor(ref: VoidPtr)：参数是裸指针（null 表示全局样式），Lua 侧无指针类型可传，
 *   故不绑定；
 * - getStyle()（internal，返回 CPointer<Unit>）与私有字段不在脚本接口范围内，不绑定。
 *
 * @file[en] window_ui_uistyle  Lua binding of UiStyle.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiStyle as the Lua type three.window.ui.UiStyle
 * @explain[en] Covers preset themes (dark/light/classic), color/style-variable push & pop, color
 * queries, font push & queries, the style editor, INI persistence, item-width/text-wrap/item-flag
 * stacks, frame info, text size, clipboard, color conversion, and the commonly used ImGuiStyle
 * fields.
 * Adaptation rules:
 * - Static capabilities (themes, frame info, text size, clipboard, color conversion, ImGuiStyle
 *   field access) use b.staticMethod; push/pop and font operations that depend on the current
 *   context are instance methods (b.method) with instances created via new() (UiStyle has a public
 *   default constructor);
 * - (Float32, Float32) / (Float32, Float32, Float32) tuple returns become Lua arrays [a, b(, c)];
 * - Color / Color4 arguments are read with prebindAs<Color> / prebindAs<Color4>, and results are
 *   registered as three.core.math.Color / three.core.math.Color4 via prebindRegister;
 * - Vector2 arguments are probed as objects (missing / nil / non-object falls back to the default),
 *   and results are registered as three.core.math.Vector2;
 * - ImVec4 is represented as a Lua array of 4 numbers (x, y, z, w): u32ToVec4 returns such an
 *   array, vec4ToU32 accepts one;
 * - integers are returned as Int64(...) and written back with Int32(...)/UInt32(... & 0xFFFFFFFF);
 *   floats are returned as Float64(...) and written back with Float32(...);
 * - exceptions inside binding lambdas are caught by _prebindUistUnit/_prebindUistValue/
 *   _prebindUistBool and never escape to Lua (Unit → empty, value → nil, Bool → false on failure).
 * Skipped members and reasons:
 * - read()/write(style: ImGuiStyle): ImGuiStyle is an imgui4cj FFI struct with no Lua-side type
 *   mapping and an unstable field layout, so it is not bound; the common fields are covered
 *   individually by getAlpha/setAlpha, getItemSpacing/setItemSpacing, getWindowPadding/
 *   setWindowPadding, getFramePadding/setFramePadding, getFrameRounding/setFrameRounding,
 *   getColorVec4/setColor and the like;
 * - showStyleEditor(ref: VoidPtr): the parameter is a raw pointer (null means the global style)
 *   and Lua has no pointer type to pass, so it is not bound;
 * - getStyle() (internal, returns CPointer<Unit>) and private fields are outside the script API
 *   and are not bound.
 */
package three.script.prebind

import three._vendor.imgui4cj.imgui.ImVec4
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
private func _prebindUistVec2(args: Array<LuaValue>, idx: Int64, default!: Vector2): Vector2 {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<Vector2>(args, idx)
    }
    return default
}

/**
 * @brief[zh-cn] 读取 Lua 数组参数为 ImVec4（x, y, z, w；不足 4 个元素按 0 处理）
 * @param[zh-cn] vm 目标虚拟机
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @return[zh-cn] ImVec4 值
 *
 * @brief[en] Reads a Lua array argument as ImVec4 (x, y, z, w; missing elements become 0)
 * @param[en] vm The target virtual machine
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @return[en] The ImVec4 value
 */
private func _prebindUistImVec4(vm: LuaVM, args: Array<LuaValue>, idx: Int64): ImVec4 {
    let a = prebindFloatArray(vm, args, idx)
    var x = 0.0f32
    var y = 0.0f32
    var z = 0.0f32
    var w = 0.0f32
    if (a.size > 0) {
        x = Float32(a[0])
    }
    if (a.size > 1) {
        y = Float32(a[1])
    }
    if (a.size > 2) {
        z = Float32(a[2])
    }
    if (a.size > 3) {
        w = Float32(a[3])
    }
    return ImVec4(x, y, z, w)
}

/**
 * @brief[zh-cn] 将 ImVec4 转为 Lua 数组 [x, y, z, w]
 * @param[zh-cn] v ImVec4 值
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts an ImVec4 into the Lua array [x, y, z, w]
 * @param[en] v The ImVec4 value
 * @return[en] Lua array value
 */
private func _prebindUistVec4ToLua(v: ImVec4): LuaValue {
    LuaValue.Array(
        [LuaValue.of(Float64(v.x)), LuaValue.of(Float64(v.y)), LuaValue.of(Float64(v.z)), LuaValue.of(Float64(v.w))])
}

/**
 * @brief[zh-cn] 执行无返回值绑定体（异常在内部捕获，返回空数组）
 * @param[zh-cn] fn 绑定体
 * @return[zh-cn] 空返回值数组
 *
 * @brief[en] Runs a Unit-returning binding body (exceptions caught inside, empty result)
 * @param[en] fn The binding body
 * @return[en] The empty return-value array
 */
private func _prebindUistUnit(fn: () -> Unit): Array<LuaValue> {
    try {
        fn()
    } catch (_: Exception) {
        ()
    }
    return []
}

/**
 * @brief[zh-cn] 执行取值绑定体（异常在内部捕获，失败返回 nil）
 * @param[zh-cn] fn 绑定体
 * @return[zh-cn] 单元素返回值数组
 *
 * @brief[en] Runs a value-returning binding body (exceptions caught inside, nil on failure)
 * @param[en] fn The binding body
 * @return[en] The single-element return-value array
 */
private func _prebindUistValue(fn: () -> LuaValue): Array<LuaValue> {
    try {
        return [fn()]
    } catch (_: Exception) {
        return [LuaValue.Nil]
    }
}

/**
 * @brief[zh-cn] 执行布尔绑定体（异常在内部捕获，失败返回 false）
 * @param[zh-cn] fn 绑定体
 * @return[zh-cn] 单元素返回值数组
 *
 * @brief[en] Runs a Bool-returning binding body (exceptions caught inside, false on failure)
 * @param[en] fn The binding body
 * @return[en] The single-element return-value array
 */
private func _prebindUistBool(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiStyle 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiStyle）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiStyle
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiStyle)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiStyle(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiStyle")
    b.constructor {_ => UiStyle()}

    // ===== 预设主题 =====
    b.staticMethod("dark") {_ => _prebindUistUnit({=> UiStyle.dark()})}
    b.staticMethod("light") {_ => _prebindUistUnit({=> UiStyle.light()})}
    b.staticMethod("classic") {_ => _prebindUistUnit({=> UiStyle.classic()})}

    // ===== 颜色操作 =====
    b.method("pushColor") {
        ref, args => _prebindUistUnit({
            => ref.cast<UiStyle>().pushColor(Int32(prebindInt(args, 0)), prebindAs<Color>(args, 1))
        })
    }
    b.method("pushColorU32") {
        ref, args => _prebindUistUnit({
            => ref.cast<UiStyle>().pushColorU32(Int32(prebindInt(args, 0)), UInt32(prebindInt(args, 1) & 0xFFFFFFFF))
        })
    }
    b.method("popColor") {
        ref, args => _prebindUistUnit({
            => ref.cast<UiStyle>().popColor(count: Int32(prebindInt(args, 0, default: 1)))
        })
    }

    // ===== 变量操作 =====
    b.method("pushVarFloat") {
        ref, args => _prebindUistUnit({
            => ref.cast<UiStyle>().pushVarFloat(Int32(prebindInt(args, 0)), Float32(prebindNum(args, 1)))
        })
    }
    b.method("pushVarVec2") {
        ref, args => _prebindUistUnit({
            => ref
                .cast<UiStyle>()
                .pushVarVec2(Int32(prebindInt(args, 0)), _prebindUistVec2(args, 1, default: Vector2(0.0, 0.0)))
        })
    }
    b.method("popVar") {
        ref, args => _prebindUistUnit({
            => ref.cast<UiStyle>().popVar(count: Int32(prebindInt(args, 0, default: 1)))
        })
    }

    // ===== 查询 =====
    b.method("getColor") {
        ref, args => _prebindUistValue({
            => prebindRegister(ref.cast<UiStyle>().getColor(Int32(prebindInt(args, 0))), "three.core.math.Color4")
        })
    }
    b.method("getColorName") {
        ref, args => _prebindUistValue({
            => LuaValue.of(ref.cast<UiStyle>().getColorName(Int32(prebindInt(args, 0))))
        })
    }

    // ===== 字体 =====
    b.method("pushFont") {
        ref, args => _prebindUistUnit({
            => ref
                .cast<UiStyle>()
                .pushFont(prebindAs<UiFont>(args, 0), fontSizeBaseUnscaled: Float32(prebindNum(args, 1)))
        })
    }
    b.method("popFont") {
        ref, _ => _prebindUistUnit({=> ref.cast<UiStyle>().popFont()})
    }
    b.method("getFont") {
        ref, _ => _prebindUistValue({
            => prebindRegister(ref.cast<UiStyle>().getFont(), "three.window.ui.UiFont")
        })
    }
    b.method("getFontSize") {
        ref, _ => _prebindUistValue({=> LuaValue.of(Float64(ref.cast<UiStyle>().getFontSize()))})
    }

    // ===== 窗口操作 =====
    b.method("showStyleSelector") {
        ref, args => _prebindUistBool({=> ref.cast<UiStyle>().showStyleSelector(prebindStr(args, 0))})
    }
    b.method("showFontSelector") {
        ref, args => _prebindUistUnit({=> ref.cast<UiStyle>().showFontSelector(prebindStr(args, 0))})
    }
    b.method("showUserGuide") {
        ref, _ => _prebindUistUnit({=> ref.cast<UiStyle>().showUserGuide()})
    }

    // ===== 缩放 =====
    b.method("scaleAllSizes") {
        ref, args => _prebindUistUnit({=> ref.cast<UiStyle>().scaleAllSizes(Float32(prebindNum(args, 0)))})
    }
    b.staticMethod("setFontGlobalScale") {
        args => _prebindUistUnit({=> UiStyle.setFontGlobalScale(Float32(prebindNum(args, 0)))})
    }
    b.staticMethod("getFontGlobalScale") {
        _ => _prebindUistValue({=> LuaValue.of(Float64(UiStyle.getFontGlobalScale()))})
    }
    b.staticMethod("getDisplaySize") {
        _ => _prebindUistValue(
            {
                =>
                    let (w, h) = UiStyle.getDisplaySize()
                    LuaValue.Array([LuaValue.of(Float64(w)), LuaValue.of(Float64(h))])
            }
        )
    }

    // ===== 栈操作（Item / TextWrap / ItemFlag） =====
    b.staticMethod("pushItemWidth") {
        args => _prebindUistUnit({=> UiStyle.pushItemWidth(Float32(prebindNum(args, 0)))})
    }
    b.staticMethod("popItemWidth") {
        _ => _prebindUistUnit({=> UiStyle.popItemWidth()})
    }
    b.staticMethod("calcItemWidth") {
        _ => _prebindUistValue({=> LuaValue.of(Float64(UiStyle.calcItemWidth()))})
    }
    b.staticMethod("pushTextWrapPos") {
        args => _prebindUistUnit({=> UiStyle.pushTextWrapPos(wrapPosX: Float32(prebindNum(args, 0, default: 0.0)))})
    }
    b.staticMethod("popTextWrapPos") {
        _ => _prebindUistUnit({=> UiStyle.popTextWrapPos()})
    }
    b.staticMethod("pushItemFlag") {
        args => _prebindUistUnit({
            => UiStyle.pushItemFlag(Int32(prebindInt(args, 0)), prebindBool(args, 1))
        })
    }
    b.staticMethod("popItemFlag") {
        _ => _prebindUistUnit({=> UiStyle.popItemFlag()})
    }

    // ===== 帧信息 =====
    b.staticMethod("getTime") {
        _ => _prebindUistValue({=> LuaValue.of(UiStyle.getTime())})
    }
    b.staticMethod("getFrameCount") {
        _ => _prebindUistValue({=> LuaValue.of(Int64(UiStyle.getFrameCount()))})
    }
    b.staticMethod("getScale") {
        _ => _prebindUistValue({=> LuaValue.of(Float64(UiStyle.getScale()))})
    }

    // ===== 文本尺寸 =====
    b.staticMethod("calcTextSize") {
        args => _prebindUistValue(
            {
                =>
                    let (w, h) = UiStyle.calcTextSize(prebindStr(args, 0),
                        hideTextAfterDoubleHash: prebindBool(args, 1, default: true),
                        wrapWidth: Float32(prebindNum(args, 2, default: -1.0)))
                    LuaValue.Array([LuaValue.of(Float64(w)), LuaValue.of(Float64(h))])
            }
        )
    }

    // ===== 剪贴板 =====
    b.staticMethod("getClipboardText") {
        _ => _prebindUistValue({=> LuaValue.of(UiStyle.getClipboardText())})
    }
    b.staticMethod("setClipboardText") {
        args => _prebindUistUnit({=> UiStyle.setClipboardText(prebindStr(args, 0))})
    }

    // ===== 颜色转换 =====
    b.staticMethod("rgbToHSV") {
        args => _prebindUistValue(
            {
                =>
                    let (h, s, v) = UiStyle.rgbToHSV(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                        Float32(prebindNum(args, 2)))
                    LuaValue.Array([LuaValue.of(Float64(h)), LuaValue.of(Float64(s)), LuaValue.of(Float64(v))])
            }
        )
    }
    b.staticMethod("hsvToRGB") {
        args => _prebindUistValue(
            {
                =>
                    let (r, g, bl) = UiStyle.hsvToRGB(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)),
                        Float32(prebindNum(args, 2)))
                    LuaValue.Array([LuaValue.of(Float64(r)), LuaValue.of(Float64(g)), LuaValue.of(Float64(bl))])
            }
        )
    }

    // ===== INI 持久化 =====
    b.method("loadIni") {
        ref, args => _prebindUistUnit({=> ref.cast<UiStyle>().loadIni(prebindStr(args, 0))})
    }
    b.method("loadIniFromMemory") {
        ref, args => _prebindUistUnit({=> ref.cast<UiStyle>().loadIniFromMemory(prebindStr(args, 0))})
    }
    b.method("saveIni") {
        ref, args => _prebindUistUnit({=> ref.cast<UiStyle>().saveIni(prebindStr(args, 0))})
    }
    b.method("saveIniToMemory") {
        ref, _ => _prebindUistValue({=> LuaValue.of(ref.cast<UiStyle>().saveIniToMemory())})
    }

    // ===== 颜色工具 =====
    b.staticMethod("col32") {
        args => _prebindUistValue({
            => LuaValue.of(
                Int64(UiStyle.col32(UInt32(prebindInt(args, 0) & 0xFFFFFFFF), UInt32(prebindInt(args, 1) & 0xFFFFFFFF),
                    UInt32(prebindInt(args, 2) & 0xFFFFFFFF), UInt32(prebindInt(args, 3) & 0xFFFFFFFF))))
        })
    }
    b.staticMethod("u32ToVec4") {
        args => _prebindUistValue({
            => _prebindUistVec4ToLua(UiStyle.u32ToVec4(UInt32(prebindInt(args, 0) & 0xFFFFFFFF)))
        })
    }
    b.staticMethod("vec4ToU32") {
        args => _prebindUistValue({
            => LuaValue.of(Int64(UiStyle.vec4ToU32(_prebindUistImVec4(vm, args, 0))))
        })
    }

    // ===== ImGuiStyle 字段访问 =====
    b.staticMethod("getAlpha") {
        _ => _prebindUistValue({=> LuaValue.of(Float64(UiStyle.getAlpha()))})
    }
    b.staticMethod("setAlpha") {
        args => _prebindUistUnit({=> UiStyle.setAlpha(Float32(prebindNum(args, 0)))})
    }
    b.staticMethod("getItemSpacing") {
        _ => _prebindUistValue({
            => prebindRegister(UiStyle.getItemSpacing(), "three.core.math.Vector2")
        })
    }
    b.staticMethod("setItemSpacing") {
        args => _prebindUistUnit({
            => UiStyle.setItemSpacing(_prebindUistVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.staticMethod("getWindowPadding") {
        _ => _prebindUistValue({
            => prebindRegister(UiStyle.getWindowPadding(), "three.core.math.Vector2")
        })
    }
    b.staticMethod("setWindowPadding") {
        args => _prebindUistUnit({
            => UiStyle.setWindowPadding(_prebindUistVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.staticMethod("getFramePadding") {
        _ => _prebindUistValue({
            => prebindRegister(UiStyle.getFramePadding(), "three.core.math.Vector2")
        })
    }
    b.staticMethod("setFramePadding") {
        args => _prebindUistUnit({
            => UiStyle.setFramePadding(_prebindUistVec2(args, 0, default: Vector2(0.0, 0.0)))
        })
    }
    b.staticMethod("getFrameRounding") {
        _ => _prebindUistValue({=> LuaValue.of(Float64(UiStyle.getFrameRounding()))})
    }
    b.staticMethod("setFrameRounding") {
        args => _prebindUistUnit({=> UiStyle.setFrameRounding(Float32(prebindNum(args, 0)))})
    }
    b.staticMethod("getColorVec4") {
        args => _prebindUistValue({
            => prebindRegister(UiStyle.getColorVec4(Int32(prebindInt(args, 0))), "three.core.math.Color4")
        })
    }
    b.staticMethod("setColor") {
        args => _prebindUistUnit({
            => UiStyle.setColor(Int32(prebindInt(args, 0)), prebindAs<Color4>(args, 1))
        })
    }

    b.install(vm)
}
