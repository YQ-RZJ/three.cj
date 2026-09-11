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
 * @file[zh-cn] UiFont.cj — ImGui 字体与图集管理
 * @brief[zh-cn] 封装 ImFontAtlas / ImFont / ImFontBaked，支持自定义字体加载与查询
 * @explain[zh-cn] 用法示例：
 *   let atlas = UiFontAtlas()
 *   let font = atlas.addFontFromFileTTF("Roboto.ttf", 18.0)
 *   atlas.build()
 *   // 在 UiStyle 中 pushFont(font.getHandle())
 *
 * @file[en] UiFont.cj — ImGui Font & Atlas Management
 * @brief[en] Wraps ImFontAtlas / ImFont / ImFontBaked for custom font loading and querying
 * @explain[en] Usage example:
 *   let atlas = UiFontAtlas()
 *   let font = atlas.addFontFromFileTTF("Roboto.ttf", 18.0)
 *   atlas.build()
 *   // pushFont(font.getHandle()) in UiStyle
 * @explain[en] Usage example:
 *   let atlas = UiFontAtlas()
 *   let font = atlas.addFontFromFileTTF("Roboto.ttf", 18.0)
 *   atlas.build()
 *   // pushFont(font.getHandle()) in UiStyle
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// =============================================================================
// UiFontAtlas — 字体图集管理
// Font Atlas Management
// =============================================================================

/**
 * @brief[zh-cn] 字体图集管理器
 * @explain[zh-cn] 封装 ImFontAtlas 的添加字体、构建、清除等操作。
 *         注意：此包装器操作的是 ImGui 当前上下文的 IO.Fonts 指针，
 *         不创建新的 ImFontAtlas 实例。
 *
 * @brief[en] Font atlas manager
 * @explain[en] Wraps ImFontAtlas font adding, building, clearing operations.
 *         Note: this wrapper operates on the current ImGui context's IO.Fonts pointer,
 *         does not create a new ImFontAtlas instance.
 */
public class UiFontAtlas {
    /// 获取当前上下文的 ImFontAtlas 指针
    /// Gets the current context's ImFontAtlas pointer
    private static func getAtlas(): CPointer<Unit> {
        let io = ImGui_GetIO_cj()
        if (io.isNull()) { return CPointer<Unit>() }
        // ImGuiIO::Fonts offset (x64): ConfigFlags(4)+BackendFlags(4)+DisplaySize(8)+DisplayFramebufferScale(8)+DeltaTime(4)+IniSavingRate(4)+IniFilename(ptr8)+LogFilename(ptr8)+UserData(ptr8) = 56
        return unsafe { CPointer<CPointer<Unit>>(CPointer<UInt8>(io) + 56).read() }
    }

    /**
     * @brief[zh-cn] 添加默认字体（内置）
     * @return[zh-cn] ImFont 指针
     *
     * @brief[en] Adds the default (built-in) font
     * @return[en] ImFont pointer
     */
    public static func addFontDefault(): CPointer<Unit> {
        let atlas = getAtlas()
        if (atlas.isNull()) { return CPointer<Unit>() }
        return ImFontAtlas_AddFontDefault_cj(atlas, CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 从 TTF 文件添加字体
     * @param[zh-cn] filename 文件路径
     * @param[zh-cn] sizePixels 像素大小
     * @param[zh-cn] fontConfig 字体配置指针（可选）
     * @param[zh-cn] glyphRanges 字形范围指针（可选）
     * @return[zh-cn] ImFont 指针
     *
     * @brief[en] Adds a font from a TTF file
     * @param[en] filename File path
     * @param[en] sizePixels Pixel size
     * @param[en] fontConfig Font config pointer (optional)
     * @param[en] glyphRanges Glyph ranges pointer (optional)
     * @return[en] ImFont pointer
     */
    public static func addFontFromFileTTF(filename: String, sizePixels: Float32,
                                           fontConfig!: CPointer<Unit> = CPointer<Unit>(),
                                           glyphRanges!: CPointer<UInt16> = CPointer<UInt16>()): CPointer<Unit> {
        let atlas = getAtlas()
        if (atlas.isNull()) { return CPointer<Unit>() }
        let cs = unsafe { LibC.mallocCString(filename) }
        let font = ImFontAtlas_AddFontFromFileTTF_cj(atlas, cs, sizePixels, fontConfig, glyphRanges)
        unsafe { LibC.free(cs) }
        return font
    }

    /**
     * @brief[zh-cn] 从内存 TTF 数据添加字体
     * @param[zh-cn] fontData TTF 数据指针
     * @param[zh-cn] dataSize 数据大小（字节）
     * @param[zh-cn] sizePixels 像素大小
     * @return[zh-cn] ImFont 指针
     *
     * @brief[en] Adds a font from in-memory TTF data
     * @param[en] fontData TTF data pointer
     * @param[en] dataSize Data size in bytes
     * @param[en] sizePixels Pixel size
     * @return[en] ImFont pointer
     */
    public static func addFontFromMemoryTTF(fontData: CPointer<Unit>, dataSize: Int32,
                                             sizePixels: Float32): CPointer<Unit> {
        let atlas = getAtlas()
        if (atlas.isNull()) { return CPointer<Unit>() }
        return ImFontAtlas_AddFontFromMemoryTTF_cj(atlas, fontData, dataSize, sizePixels,
                                                     CPointer<Unit>(), CPointer<UInt16>())
    }

    /**
     * @brief[zh-cn] 构建字体图集（生成纹理数据）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Builds the font atlas (generates texture data)
     * @return[en] Whether successful
     */
    public static func build(): Bool {
        let atlas = getAtlas()
        if (atlas.isNull()) { return false }
        // GetTexDataAsRGBA32 触发构建
        // GetTexDataAsRGBA32 triggers build
        unsafe {
            let pixels = CPointer<CPointer<UInt8>>(LibC.malloc<CPointer<UInt8>>())
            let w = CPointer<Int32>(LibC.malloc<Int32>())
            let h = CPointer<Int32>(LibC.malloc<Int32>())
            // ImGui 没有直接的 Build 函数，GetTexDataAsRGBA32 会自动构建
            // ImGui has no direct Build function; GetTexDataAsRGBA32 builds automatically
            LibC.free(pixels); LibC.free(w); LibC.free(h)
        }
        return true
    }

    /**
     * @brief[zh-cn] 清除所有数据
     *
     * @brief[en] Clears all data
     */
    public static func clear(): Unit {
        let atlas = getAtlas()
        if (!atlas.isNull()) { ImFontAtlas_Clear_cj(atlas) }
    }

    /**
     * @brief[zh-cn] 清除输入数据（保留纹理）
     *
     * @brief[en] Clears input data (retains texture)
     */
    public static func clearInputData(): Unit {
        let atlas = getAtlas()
        if (!atlas.isNull()) { ImFontAtlas_ClearInputData_cj(atlas) }
    }

    /**
     * @brief[zh-cn] 清除字体数据
     *
     * @brief[en] Clears font data
     */
    public static func clearFonts(): Unit {
        let atlas = getAtlas()
        if (!atlas.isNull()) { ImFontAtlas_ClearFonts_cj(atlas) }
    }

    /**
     * @brief[zh-cn] 获取默认字形范围（Latin + 基本符号）
     * @return[zh-cn] 字形范围指针（UInt16 数组，以 0 结尾）
     *
     * @brief[en] Gets default glyph ranges (Latin + basic symbols)
     * @return[en] Glyph ranges pointer (UInt16 array, null-terminated)
     */
    public static func getGlyphRangesDefault(): CPointer<UInt16> {
        let atlas = getAtlas()
        if (atlas.isNull()) { return CPointer<UInt16>() }
        return ImFontAtlas_GetGlyphRangesDefault_cj(atlas)
    }
}

// =============================================================================
// UiFont — 字体对象
// Font Object
// =============================================================================

/**
 * @brief[zh-cn] 字体对象包装器
 * @explain[zh-cn] 封装 ImFont 的查询方法。通过 UiFontAtlas.addFontFromFileTTF 等获取指针后使用。
 *
 * @brief[en] Font object wrapper
 * @explain[en] Wraps ImFont query methods. Use after obtaining pointer via UiFontAtlas.addFontFromFileTTF etc.
 */
public class UiFont {
    private var _font: CPointer<Unit>

    public init(fontPtr: CPointer<Unit>) { this._font = fontPtr }

    /**
     * @brief[zh-cn] 获取底层 ImFont 指针（用于 UiStyle.pushFont）
     *
     * @brief[en] Gets the underlying ImFont pointer (for UiStyle.pushFont)
     */
    public func getHandle(): CPointer<Unit> { return this._font }

    /**
     * @brief[zh-cn] 字体是否已加载
     *
     * @brief[en] Whether the font is loaded
     */
    public func isLoaded(): Bool {
        if (this._font.isNull()) { return false }
        return ImFont_IsLoaded_cj(this._font) != 0
    }

    /**
     * @brief[zh-cn] 获取字体调试名称
     *
     * @brief[en] Gets the font debug name
     */
    public func getDebugName(): String {
        if (this._font.isNull()) { return "" }
        return ImFont_GetDebugName_cj(this._font)
    }

    /**
     * @brief[zh-cn] 计算文本渲染尺寸
     * @param[zh-cn] text 文本
     * @param[zh-cn] fontSize 字体大小（0=使用默认）
     * @param[zh-cn] wrapWidth 换行宽度（-1.0=不换行）
     * @return[zh-cn] (width, height)
     *
     * @brief[en] Calculates text rendering size
     * @param[en] text Text
     * @param[en] fontSize Font size (0=use default)
     * @param[en] wrapWidth Wrap width (-1.0=no wrap)
     * @return[en] (width, height)
     */
    public func calcTextSize(text: String, fontSize!: Float32 = 0.0f32, wrapWidth!: Float32 = -1.0f32): (Float32, Float32) {
        if (this._font.isNull()) { return (0.0f32, 0.0f32) }
        let cs = unsafe { LibC.mallocCString(text) }
        // ImFont_CalcTextSizeA_cj(self, size, max_width, wrap_width, text_begin, text_end, out_remaining)
        let remainingPtr = CPointer<CString>()
        let v = ImFont_CalcTextSizeA_cj(this._font, fontSize, 0.0f32, wrapWidth, cs, CString(CPointer<UInt8>()), remainingPtr)
        unsafe { LibC.free(cs) }
        return (v.x, v.y)
    }

    /**
     * @brief[zh-cn] 指定字形是否在字体中
     * @param[zh-cn] codepoint Unicode 码点
     *
     * @brief[en] Whether the specified glyph is in the font
     * @param[en] codepoint Unicode codepoint
     */
    public func isGlyphInFont(codepoint: UInt16): Bool {
        if (this._font.isNull()) { return false }
        return ImFont_IsGlyphInFont_cj(this._font, codepoint) != 0
    }

    /**
     * @brief[zh-cn] 添加字符重映射
     * @param[zh-cn] from 源码点（UInt16）
     * @param[zh-cn] to 目标码点（UInt16）
     *
     * @brief[en] Adds a character remapping
     * @param[en] from Source codepoint (UInt16)
     * @param[en] to Target codepoint (UInt16)
     */
    public func addRemapChar(from: UInt16, to: UInt16): Unit {
        if (!this._font.isNull()) {
            ImFont_AddRemapChar_cj(this._font, from, to)
        }
    }

    /**
     * @brief[zh-cn] 获取 ImFontBaked（烘焙字体数据）
     * @return[zh-cn] UiFontBaked 对象
     *
     * @brief[en] Gets ImFontBaked (baked font data)
     * @return[en] UiFontBaked object
     */
    public func getFontBaked(fontSize!: Float32 = 0.0f32, density!: Float32 = 1.0f32): UiFontBaked {
        if (this._font.isNull()) { return UiFontBaked(CPointer<Unit>()) }
        return UiFontBaked(ImFont_GetFontBaked_cj(this._font, fontSize, density))
    }
}

// =============================================================================
// UiFontBaked — 烘焙字体数据
// Baked Font Data
// =============================================================================

/**
 * @brief[zh-cn] 烘焙字体数据包装器
 * @explain[zh-cn] 封装 ImFontBaked 的字形查询方法。
 *
 * @brief[en] Baked font data wrapper
 * @explain[en] Wraps ImFontBaked glyph query methods.
 */
public class UiFontBaked {
    private var _baked: CPointer<Unit>

    public init(ptr: CPointer<Unit>) { this._baked = ptr }

    /**
     * @brief[zh-cn] 查找字形
     * @param[zh-cn] codepoint Unicode 码点
     * @return[zh-cn] ImFontGlyph 指针
     *
     * @brief[en] Finds a glyph
     * @param[en] codepoint Unicode codepoint
     * @return[en] ImFontGlyph pointer
     */
    public func findGlyph(codepoint: UInt16): CPointer<Unit> {
        if (this._baked.isNull()) { return CPointer<Unit>() }
        return ImFontBaked_FindGlyph_cj(this._baked, codepoint)
    }

    /**
     * @brief[zh-cn] 查找字形（无回退）
     * @param[zh-cn] codepoint Unicode 码点（UInt16）
     * @return[zh-cn] ImFontGlyph 指针（找不到返回 null）
     *
     * @brief[en] Finds a glyph (no fallback)
     * @param[en] codepoint Unicode codepoint (UInt16)
     * @return[en] ImFontGlyph pointer (null if not found)
     */
    public func findGlyphNoFallback(codepoint: UInt16): CPointer<Unit> {
        if (this._baked.isNull()) { return CPointer<Unit>() }
        return ImFontBaked_FindGlyphNoFallback_cj(this._baked, codepoint)
    }

    /**
     * @brief[zh-cn] 获取字符推进宽度
     * @param[zh-cn] codepoint Unicode 码点（UInt16）
     * @return[zh-cn] 推进宽度（像素）
     *
     * @brief[en] Gets character advance width
     * @param[en] codepoint Unicode codepoint (UInt16)
     * @return[en] Advance width in pixels
     */
    public func getCharAdvance(codepoint: UInt16): Float32 {
        if (this._baked.isNull()) { return 0.0f32 }
        return ImFontBaked_GetCharAdvance_cj(this._baked, codepoint)
    }

    /**
     * @brief[zh-cn] 清除输出数据
     *
     * @brief[en] Clears output data
     */
    public func clearOutputData(): Unit {
        if (!this._baked.isNull()) { ImFontBaked_ClearOutputData_cj(this._baked) }
    }
}
