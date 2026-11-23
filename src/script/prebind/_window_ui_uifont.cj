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
 * @file[zh-cn] window_ui_uifont UiFont.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 UiGlyphRanges、UiFontData、UiFontConfig、UiFontGlyphRangesBuilder、
 * UiFontAtlas、UiFont、UiFontGlyph、UiFontBaked 八个类绑定为 Lua 类型
 * @explain[zh-cn] 覆盖字形范围的空值判断/释放、内存字体数据构造/释放、字体配置的全部类型化
 * 字段、字形范围构建器、图集静态工厂（添加默认/文件/内存字体、构建、状态查询、清除、
 * 九种标准字形范围）、字体的加载查询与文本尺寸、字形只读字段、烘焙字体的字形查找。
 * 适配约定（Lua 类名统一为 three.window.ui.<类名>）：
 * - UiGlyphRanges / UiFontConfig / UiFontGlyphRangesBuilder / UiFontData 用 new() 构造；
 *   UiFontAtlas 为纯静态工具类（无构造）；UiFont / UiFontGlyph / UiFontBaked 只能由图集或
 *   查询方法返回，故不绑 constructor；
 * - 对象返回值（UiFont / UiGlyphRanges / UiFontBaked / UiFontGlyph）经 prebindRegister 注册为
 *   对应的 three.window.ui.<类名>；对象参数经 prebindAs<T> 读取，缺省时回落到新实例；
 * - UiFontData(bytes) 接受 Lua 数值数组，经 prebindBytes 转为 UInt8 数组；
 * - 元组返回 (Float32, Float32) / (Float32, Float32, Float32, Float32) 统一转为 Lua 数组；
 *   UiFontConfig 的 getGlyphOffset→[x, y]、setGlyphOffset(x, y) 拆为两个数值参数；
 * - Int32/UInt32 以 Int64(...) 返回、Int32(...)/UInt32(... & 0xFFFFFFFF) 回写；UInt16 码点以
 *   UInt16(... & 0xFFFF) 回写；Float32 以 Float64(...) 返回、Float32(...) 回写；
 * - 绑定 lambda 内异常一律在 _prebindUifUnit/_prebindUifValue/_prebindUifBool 内捕获，
 *   不向 Lua 逃逸（失败时 Unit 返回空、取值返回 nil、布尔返回 false）。
 * 跳过成员及原因：
 * - UiFontConfig.getFontData()/setFontData(VoidPtr)：参数/返回值是裸内存指针，Lua 侧无指针
 *   类型可传，字体数据请改用 UiFontData + addFontFromMemoryTTF；
 * - UiFont.init(fontPtr: VoidPtr)、UiFontGlyph.init(ptr: VoidPtr)、UiFontBaked.init(ptr: VoidPtr)：
 *   构造参数为底层不透明指针，Lua 无法持有，故不绑 constructor（改由图集/查询方法返回）；
 * - UiFont.getHandle()：返回裸 ImFont 指针（低级接口），Lua 侧无映射，不绑定；
 * - UiGlyphRanges.getRanges()（internal，CPointer<UInt16>）、UiFontConfig.getHandle()/
 *   UiFontData 的 internal 构造与 getPointer 等内部成员不在脚本接口范围内，不绑定；
 * - 各析构 ~init 不是脚本接口，不绑定（显式释放请调用 finalize）。
 *
 * @file[en] window_ui_uifont  Lua binding of UiFont.cj (three.script.prebind)
 * @brief[en] Binds the eight classes UiGlyphRanges, UiFontData, UiFontConfig,
 * UiFontGlyphRangesBuilder, UiFontAtlas, UiFont, UiFontGlyph and UiFontBaked as Lua types
 * @explain[en] Covers glyph-range null checks/finalize, in-memory font data construction/finalize,
 * all typed font-config fields, the glyph-range builder, the atlas static factories (add default/
 * file/memory fonts, build, state queries, clears, nine standard glyph ranges), font load queries
 * and text size, glyph read-only fields, and baked-font glyph lookup.
 * Adaptation rules (Lua class names are three.window.ui.<ClassName>):
 * - UiGlyphRanges / UiFontConfig / UiFontGlyphRangesBuilder / UiFontData are created with new();
 *   UiFontAtlas is a pure static utility (no constructor); UiFont / UiFontGlyph / UiFontBaked are
 *   only returned by the atlas or query methods, so their constructors are not bound;
 * - object results (UiFont / UiGlyphRanges / UiFontBaked / UiFontGlyph) are registered as the
 *   matching three.window.ui.<ClassName> via prebindRegister; object arguments are read with
 *   prebindAs<T> and fall back to a fresh instance when absent;
 * - UiFontData(bytes) accepts a Lua number array converted with prebindBytes into UInt8 bytes;
 * - tuple returns (Float32, Float32) / (Float32, Float32, Float32, Float32) become Lua arrays;
 *   UiFontConfig.getGlyphOffset returns [x, y] and setGlyphOffset takes two number arguments;
 * - Int32/UInt32 are returned as Int64(...) and written back with Int32(...)/UInt32(... & 0xFFFFFFFF);
 *   UInt16 code points are written back with UInt16(... & 0xFFFF); Float32 values are returned as
 *   Float64(...) and written back with Float32(...);
 * - exceptions inside binding lambdas are caught by _prebindUifUnit/_prebindUifValue/
 *   _prebindUifBool and never escape to Lua (Unit → empty, value → nil, Bool → false on failure).
 * Skipped members and reasons:
 * - UiFontConfig.getFontData()/setFontData(VoidPtr): the parameter/result is a raw memory pointer
 *   with no Lua-side type, so font data should use UiFontData + addFontFromMemoryTTF instead;
 * - UiFont.init(fontPtr: VoidPtr), UiFontGlyph.init(ptr: VoidPtr), UiFontBaked.init(ptr: VoidPtr):
 *   the constructor takes an opaque low-level pointer that Lua cannot hold, so no constructor is
 *   bound (instances come from the atlas or query methods);
 * - UiFont.getHandle(): returns a raw ImFont pointer (low-level interface) with no Lua mapping;
 * - UiGlyphRanges.getRanges() (internal, CPointer<UInt16>) and the internal UiFontConfig.getHandle()/
 *   UiFontData constructors and getPointer are not script APIs and are not bound;
 * - destructors ~init are not script APIs and are not bound (use finalize for explicit release).
 */
package three.script.prebind

import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选 UiFontConfig 参数（缺失 / nil / 非对象时新建默认配置）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @return[zh-cn] 字体配置对象
 *
 * @brief[en] Reads an optional UiFontConfig argument (creates a default config when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @return[en] The font config object
 */
private func _prebindUifFontConfig(args: Array<LuaValue>, idx: Int64): UiFontConfig {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<UiFontConfig>(args, idx)
    }
    return UiFontConfig()
}

/**
 * @brief[zh-cn] 读取可选 UiGlyphRanges 参数（缺失 / nil / 非对象时新建空范围）
 * @param[zh-cn] args Lua 参数数组
 * @param[zh-cn] idx 参数下标
 * @return[zh-cn] 字形范围对象
 *
 * @brief[en] Reads an optional UiGlyphRanges argument (creates an empty range when missing/nil/not an object)
 * @param[en] args The Lua argument array
 * @param[en] idx The argument index
 * @return[en] The glyph ranges object
 */
private func _prebindUifGlyphRanges(args: Array<LuaValue>, idx: Int64): UiGlyphRanges {
    if (args.size > idx && args[idx].isObject) {
        return prebindAs<UiGlyphRanges>(args, idx)
    }
    return UiGlyphRanges()
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
private func _prebindUifUnit(fn: () -> Unit): Array<LuaValue> {
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
private func _prebindUifValue(fn: () -> LuaValue): Array<LuaValue> {
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
private func _prebindUifBool(fn: () -> Bool): Array<LuaValue> {
    try {
        return [LuaValue.of(fn())]
    } catch (_: Exception) {
        return [LuaValue.of(false)]
    }
}

/**
 * @brief[zh-cn] 安装 UiGlyphRanges 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiGlyphRanges）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiGlyphRanges
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiGlyphRanges)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiGlyphRanges(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiGlyphRanges")
    b.constructor {_ => UiGlyphRanges()}
    b.method("isNull") {ref, _ => _prebindUifBool({=> ref.cast<UiGlyphRanges>().isNull()})}
    b.method("finalize") {
        ref, _ => _prebindUifUnit({=> ref.cast<UiGlyphRanges>().finalize()})
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontData
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontData")
    b.constructor {
        args => UiFontData(prebindBytes(vm, args, 0))
    }
    b.method("finalize") {
        ref, _ => _prebindUifUnit({=> ref.cast<UiFontData>().finalize()})
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontConfig 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontConfig）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontConfig
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontConfig)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontConfig(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontConfig")
    b.constructor {_ => UiFontConfig()}
    b.method("finalize") {
        ref, _ => _prebindUifUnit({=> ref.cast<UiFontConfig>().finalize()})
    }

    // ---- MergeMode：合并到上一个字体 ----
    b.method("getMergeMode") {
        ref, _ => _prebindUifBool({=> ref.cast<UiFontConfig>().getMergeMode()})
    }
    b.method("setMergeMode") {
        ref, args => _prebindUifUnit({=> ref.cast<UiFontConfig>().setMergeMode(prebindBool(args, 0))})
    }

    // ---- PixelSnapH：像素对齐 ----
    b.method("getPixelSnapH") {
        ref, _ => _prebindUifBool({=> ref.cast<UiFontConfig>().getPixelSnapH()})
    }
    b.method("setPixelSnapH") {
        ref, args => _prebindUifUnit({=> ref.cast<UiFontConfig>().setPixelSnapH(prebindBool(args, 0))})
    }

    // ---- Oversample：超采样 ----
    b.method("getOversampleH") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontConfig>().getOversampleH()))})
    }
    b.method("setOversampleH") {
        ref, args => _prebindUifUnit({=> ref.cast<UiFontConfig>().setOversampleH(Int32(prebindInt(args, 0)))})
    }
    b.method("getOversampleV") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontConfig>().getOversampleV()))})
    }
    b.method("setOversampleV") {
        ref, args => _prebindUifUnit({=> ref.cast<UiFontConfig>().setOversampleV(Int32(prebindInt(args, 0)))})
    }

    // ---- EllipsisChar：省略号字符 ----
    b.method("getEllipsisChar") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontConfig>().getEllipsisChar()))})
    }
    b.method("setEllipsisChar") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setEllipsisChar(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
        })
    }

    // ---- SizePixels：像素大小 ----
    b.method("getSizePixels") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Float64(ref.cast<UiFontConfig>().getSizePixels()))})
    }
    b.method("setSizePixels") {
        ref, args => _prebindUifUnit({=> ref.cast<UiFontConfig>().setSizePixels(Float32(prebindNum(args, 0)))})
    }

    // ---- GlyphRanges：字形范围 ----
    b.method("getGlyphRanges") {
        ref, _ => _prebindUifValue({
            => prebindRegister(ref.cast<UiFontConfig>().getGlyphRanges(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.method("setGlyphRanges") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setGlyphRanges(prebindAs<UiGlyphRanges>(args, 0))
        })
    }

    // ---- GlyphOffset：字形像素偏移 ----
    b.method("getGlyphOffset") {
        ref, _ => _prebindUifValue(
            {
                =>
                    let (x, y) = ref.cast<UiFontConfig>().getGlyphOffset()
                    LuaValue.Array([LuaValue.of(Float64(x)), LuaValue.of(Float64(y))])
            }
        )
    }
    b.method("setGlyphOffset") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setGlyphOffset(Float32(prebindNum(args, 0)), Float32(prebindNum(args, 1)))
        })
    }

    // ---- 字形前进宽度约束 ----
    b.method("getGlyphMinAdvanceX") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Float64(ref.cast<UiFontConfig>().getGlyphMinAdvanceX()))})
    }
    b.method("setGlyphMinAdvanceX") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setGlyphMinAdvanceX(Float32(prebindNum(args, 0)))
        })
    }
    b.method("getGlyphMaxAdvanceX") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Float64(ref.cast<UiFontConfig>().getGlyphMaxAdvanceX()))})
    }
    b.method("setGlyphMaxAdvanceX") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setGlyphMaxAdvanceX(Float32(prebindNum(args, 0)))
        })
    }
    b.method("getGlyphExtraAdvanceX") {
        ref, _ => _prebindUifValue({
            => LuaValue.of(Float64(ref.cast<UiFontConfig>().getGlyphExtraAdvanceX()))
        })
    }
    b.method("setGlyphExtraAdvanceX") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setGlyphExtraAdvanceX(Float32(prebindNum(args, 0)))
        })
    }

    // ---- FontNo：字体序号 ----
    b.method("getFontNo") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontConfig>().getFontNo()))})
    }
    b.method("setFontNo") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setFontNo(UInt32(prebindInt(args, 0) & 0xFFFFFFFF))
        })
    }

    // ---- 光栅化参数 ----
    b.method("getRasterizerMultiply") {
        ref, _ => _prebindUifValue({
            => LuaValue.of(Float64(ref.cast<UiFontConfig>().getRasterizerMultiply()))
        })
    }
    b.method("setRasterizerMultiply") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setRasterizerMultiply(Float32(prebindNum(args, 0)))
        })
    }
    b.method("getRasterizerDensity") {
        ref, _ => _prebindUifValue({
            => LuaValue.of(Float64(ref.cast<UiFontConfig>().getRasterizerDensity()))
        })
    }
    b.method("setRasterizerDensity") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setRasterizerDensity(Float32(prebindNum(args, 0)))
        })
    }
    b.method("getExtraSizeScale") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Float64(ref.cast<UiFontConfig>().getExtraSizeScale()))})
    }
    b.method("setExtraSizeScale") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setExtraSizeScale(Float32(prebindNum(args, 0)))
        })
    }

    // ---- FontData：内存字体数据 ----
    b.method("getFontDataSize") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontConfig>().getFontDataSize()))})
    }
    b.method("setFontDataSize") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setFontDataSize(Int32(prebindInt(args, 0)))
        })
    }
    b.method("getFontDataOwnedByAtlas") {
        ref, _ => _prebindUifBool({=> ref.cast<UiFontConfig>().getFontDataOwnedByAtlas()})
    }
    b.method("setFontDataOwnedByAtlas") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontConfig>().setFontDataOwnedByAtlas(prebindBool(args, 0))
        })
    }

    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontGlyphRangesBuilder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontGlyphRangesBuilder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontGlyphRangesBuilder
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontGlyphRangesBuilder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontGlyphRangesBuilder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontGlyphRangesBuilder")
    b.constructor {_ => UiFontGlyphRangesBuilder()}
    b.method("finalize") {
        ref, _ => _prebindUifUnit({=> ref.cast<UiFontGlyphRangesBuilder>().finalize()})
    }
    b.method("addChar") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontGlyphRangesBuilder>().addChar(UInt16(prebindInt(args, 0) & 0xFFFF))
        })
    }
    b.method("addText") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontGlyphRangesBuilder>().addText(prebindStr(args, 0))
        })
    }
    b.method("addRanges") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFontGlyphRangesBuilder>().addRanges(prebindAs<UiGlyphRanges>(args, 0))
        })
    }
    b.method("buildRanges") {
        ref, _ => _prebindUifValue({
            => prebindRegister(ref.cast<UiFontGlyphRangesBuilder>().buildRanges(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontAtlas 的 Lua 绑定（纯静态工具类，无构造）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontAtlas）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontAtlas (pure static utility, no constructor)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontAtlas)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontAtlas(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontAtlas")

    b.staticMethod("setDefaultFont") {
        args => _prebindUifUnit({
            => UiFontAtlas.setDefaultFont(prebindAs<UiFont>(args, 0))
        })
    }
    b.staticMethod("addFontDefault") {
        args => _prebindUifValue({
            => prebindRegister(UiFontAtlas.addFontDefault(fontConfig: _prebindUifFontConfig(args, 0)),
                "three.window.ui.UiFont")
        })
    }
    b.staticMethod("addFontFromFileTTF") {
        args => _prebindUifValue({
            => prebindRegister(
                UiFontAtlas.addFontFromFileTTF(prebindStr(args, 0), Float32(prebindNum(args, 1)),
                    fontConfig: _prebindUifFontConfig(args, 2), glyphRanges: _prebindUifGlyphRanges(args, 3)),
                "three.window.ui.UiFont")
        })
    }
    b.staticMethod("addFontFromMemoryTTF") {
        args => _prebindUifValue({
            => prebindRegister(
                UiFontAtlas.addFontFromMemoryTTF(prebindAs<UiFontData>(args, 0), Float32(prebindNum(args, 1)),
                    fontConfig: _prebindUifFontConfig(args, 2), glyphRanges: _prebindUifGlyphRanges(args, 3)),
                "three.window.ui.UiFont")
        })
    }

    b.staticMethod("build") {_ => _prebindUifBool({=> UiFontAtlas.build()})}
    b.staticMethod("isBuilt") {_ => _prebindUifBool({=> UiFontAtlas.isBuilt()})}
    b.staticMethod("clear") {_ => _prebindUifUnit({=> UiFontAtlas.clear()})}
    b.staticMethod("clearInputData") {
        _ => _prebindUifUnit({=> UiFontAtlas.clearInputData()})
    }
    b.staticMethod("clearFonts") {_ => _prebindUifUnit({=> UiFontAtlas.clearFonts()})}

    // ---- 标准字形范围（借用 ImGui 静态数据，不释放）----
    b.staticMethod("getGlyphRangesDefault") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesDefault(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesChineseSimplifiedCommon") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesChineseSimplifiedCommon(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesChineseFull") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesChineseFull(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesJapanese") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesJapanese(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesKorean") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesKorean(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesGreek") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesGreek(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesCyrillic") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesCyrillic(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesThai") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesThai(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.staticMethod("getGlyphRangesVietnamese") {
        _ => _prebindUifValue({
            => prebindRegister(UiFontAtlas.getGlyphRangesVietnamese(), "three.window.ui.UiGlyphRanges")
        })
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFont 的 Lua 绑定（无构造，实例由图集返回）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFont）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFont (no constructor; instances come from the atlas)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFont)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFont(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFont")
    b.method("isLoaded") {ref, _ => _prebindUifBool({=> ref.cast<UiFont>().isLoaded()})}
    b.method("getDebugName") {
        ref, _ => _prebindUifValue({=> LuaValue.of(ref.cast<UiFont>().getDebugName())})
    }
    b.method("calcTextSize") {
        ref, args => _prebindUifValue(
            {
                =>
                    let (w, h) = ref
                        .cast<UiFont>()
                        .calcTextSize(prebindStr(args, 0), fontSize: Float32(prebindNum(args, 1)),
                            wrapWidth: Float32(prebindNum(args, 2, default: -1.0)))
                    LuaValue.Array([LuaValue.of(Float64(w)), LuaValue.of(Float64(h))])
            }
        )
    }
    b.method("isGlyphInFont") {
        ref, args => _prebindUifBool({
            => ref.cast<UiFont>().isGlyphInFont(UInt16(prebindInt(args, 0) & 0xFFFF))
        })
    }
    b.method("addRemapChar") {
        ref, args => _prebindUifUnit({
            => ref.cast<UiFont>().addRemapChar(UInt16(prebindInt(args, 0) & 0xFFFF), UInt16(prebindInt(args, 1) & 0xFFFF))
        })
    }
    b.method("getFontBaked") {
        ref, args => _prebindUifValue({
            => prebindRegister(
                ref
                    .cast<UiFont>()
                    .getFontBaked(fontSize: Float32(prebindNum(args, 0)),
                        density: Float32(prebindNum(args, 1, default: 1.0))), "three.window.ui.UiFontBaked")
        })
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontGlyph 的 Lua 绑定（无构造，实例由 UiFontBaked 返回）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontGlyph）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontGlyph (no constructor; instances come from UiFontBaked)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontGlyph)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontGlyph(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontGlyph")
    b.method("isValid") {ref, _ => _prebindUifBool({=> ref.cast<UiFontGlyph>().isValid()})}
    b.method("getCodepoint") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontGlyph>().getCodepoint()))})
    }
    b.method("isVisible") {ref, _ => _prebindUifBool({=> ref.cast<UiFontGlyph>().isVisible()})}
    b.method("isColored") {ref, _ => _prebindUifBool({=> ref.cast<UiFontGlyph>().isColored()})}
    b.method("getAdvanceX") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Float64(ref.cast<UiFontGlyph>().getAdvanceX()))})
    }
    b.method("getRect") {
        ref, _ => _prebindUifValue(
            {
                =>
                    let (x0, y0, x1, y1) = ref.cast<UiFontGlyph>().getRect()
                    LuaValue.Array(
                        [LuaValue.of(Float64(x0)), LuaValue.of(Float64(y0)), LuaValue.of(Float64(x1)),
                            LuaValue.of(Float64(y1))])
            }
        )
    }
    b.method("getUV") {
        ref, _ => _prebindUifValue(
            {
                =>
                    let (u0, v0, u1, v1) = ref.cast<UiFontGlyph>().getUV()
                    LuaValue.Array(
                        [LuaValue.of(Float64(u0)), LuaValue.of(Float64(v0)), LuaValue.of(Float64(u1)),
                            LuaValue.of(Float64(v1))])
            }
        )
    }
    b.method("getPackId") {
        ref, _ => _prebindUifValue({=> LuaValue.of(Int64(ref.cast<UiFontGlyph>().getPackId()))})
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 UiFontBaked 的 Lua 绑定（无构造，实例由 UiFont 返回）
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiFontBaked）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiFontBaked (no constructor; instances come from UiFont)
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiFontBaked)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiFontBaked(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiFontBaked")
    b.method("findGlyph") {
        ref, args => _prebindUifValue({
            => prebindRegister(ref.cast<UiFontBaked>().findGlyph(UInt16(prebindInt(args, 0) & 0xFFFF)),
                "three.window.ui.UiFontGlyph")
        })
    }
    b.method("findGlyphNoFallback") {
        ref, args => _prebindUifValue({
            => prebindRegister(ref.cast<UiFontBaked>().findGlyphNoFallback(UInt16(prebindInt(args, 0) & 0xFFFF)),
                "three.window.ui.UiFontGlyph")
        })
    }
    b.method("getCharAdvance") {
        ref, args => _prebindUifValue({
            => LuaValue.of(Float64(ref.cast<UiFontBaked>().getCharAdvance(UInt16(prebindInt(args, 0) & 0xFFFF))))
        })
    }
    b.method("clearOutputData") {
        ref, _ => _prebindUifUnit({=> ref.cast<UiFontBaked>().clearOutputData()})
    }
    b.install(vm)
}
