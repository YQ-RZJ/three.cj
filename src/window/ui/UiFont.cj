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
 * @brief[zh-cn] 安全类型封装 ImFontAtlas / ImFont / ImFontGlyph / ImFontBaked，支持自定义字体（含中文/UTF-8）加载与查询
 * @explain[zh-cn] 用法示例：
 *   let font = UiFontAtlas.addFontFromFileTTF("msyh.ttf", 18.0f32,
 *       glyphRanges: UiFontAtlas.getGlyphRangesChineseSimplifiedCommon())
 *   UiFontAtlas.build()
 *   UiStyle.pushFont(font)
 *
 * @file[en] UiFont.cj — ImGui Font & Atlas Management
 * @brief[en] Safe-typed wrappers for ImFontAtlas / ImFont / ImFontGlyph / ImFontBaked, custom fonts (Chinese/UTF-8) supported
 * @explain[en] Usage example:
 *   let font = UiFontAtlas.addFontFromFileTTF("msyh.ttf", 18.0f32,
 *       glyphRanges: UiFontAtlas.getGlyphRangesChineseSimplifiedCommon())
 *   UiFontAtlas.build()
 *   UiStyle.pushFont(font)
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.VoidPtr

// =============================================================================
// UiGlyphRanges — 字形范围（安全类型）
// Glyph Ranges (safe type)
// =============================================================================

/**
 * @brief[zh-cn] 字形范围（Unicode 区间数组）安全包装
 * @explain[zh-cn] 对应 ImGui 的 const ImWchar* 字形范围数组，以 [from,to,from,to,...,0] 形式
 *         存储。标准范围（如中文简体常用）为 ImGui 静态数据，仅引用不释放；
 *         由 UiFontGlyphRangesBuilder.buildRanges() 构建的范围则拥有堆内存，析构时自动释放。
 *
 * @brief[en] Safe wrapper for glyph ranges (const ImWchar*)
 * @explain[en] Mirrors ImGui's const ImWchar* glyph-range array, stored as
 *         [from,to,from,to,...,0]. Standard ranges (e.g. Chinese Simplified Common)
 *         are ImGui static data and are referenced but never freed; ranges built by
 *         UiFontGlyphRangesBuilder.buildRanges() own heap memory and free it on finalize.
 */
public class UiGlyphRanges {
    private var _ranges: CPointer<UInt16>
    private var _owner: CPointer<Unit>  // ImVector_ImWchar*，仅在自身拥有时非空

    /**
     * @brief[zh-cn] 创建空范围（等价 NULL，AddFont* 将回退到默认范围）
     *
     * @brief[en] Creates an empty range (equivalent to NULL; AddFont* falls back to the default range)
     */
    public init() {
        this._ranges = CPointer<UInt16>()
        this._owner = CPointer<Unit>()
    }

    internal init(ranges: CPointer<UInt16>, owner: CPointer<Unit>) {
        this._ranges = ranges
        this._owner = owner
    }

    /// 供 FFI 层桥接（不对外暴露）
    internal func getRanges(): CPointer<UInt16> { return this._ranges }

    /**
     * @brief[zh-cn] 是否为空范围
     * @return[zh-cn] 为空返回 true
     *
     * @brief[en] Whether the range is empty
     * @return[en] true if empty
     */
    public func isNull(): Bool { return this._ranges.isNull() }

    /**
     * @brief[zh-cn] 释放自建范围占用的堆内存（标准静态范围无操作）
     *
     * @brief[en] Frees heap memory owned by a self-built range (no-op for standard static ranges)
     */
    public func finalize(): Unit {
        if (!this._owner.isNull()) {
            ImVector_ImWchar_destroy_cj(this._owner)
            this._owner = CPointer<Unit>()
        }
    }
}

// =============================================================================
// UiFontData — 内存字体数据（安全类型）
// In-memory Font Data (safe type)
// =============================================================================

/**
 * @brief[zh-cn] 内存字体数据（TTF/OTF 二进制）安全包装
 * @explain[zh-cn] 内部通过 LibC 申请连续堆内存存放字节数据，析构时自动释放。
 *         注意：ImGui 默认（FontDataOwnedByAtlas=false）不拷贝数据，要求数据在
 *         UiFontAtlas.build() 之前保持有效，因此请保持引用直到构建完成。
 *         若 FontConfig 设置 fontDataOwnedByAtlas=true，所有权将转移给图集，本对象不再释放。
 *
 * @brief[en] Safe wrapper for in-memory font data (TTF/OTF binary)
 * @explain[en] Allocates contiguous LibC heap memory for the byte data and frees it on finalize.
 *         Note: by default (FontDataOwnedByAtlas=false) ImGui does not copy the data, so it
 *         must remain valid until UiFontAtlas.build(); keep the reference until the build is done.
 *         If FontConfig sets fontDataOwnedByAtlas=true, ownership moves to the atlas and this
 *         object no longer frees it.
 */
public class UiFontData {
    private var _ptr: CPointer<UInt8>
    private var _size: Int64
    private var _transferred: Bool = false

    /**
     * @brief[zh-cn] 从字节数组构造（拷贝到 LibC 连续堆内存）
     * @param[zh-cn] bytes 字体文件原始字节
     *
     * @brief[en] Constructs from a byte array (copied into contiguous LibC heap memory)
     * @param[en] bytes Raw font file bytes
     */
    public init(bytes: Array<UInt8>) {
        this._size = bytes.size
        this._ptr = unsafe { LibC.malloc<UInt8>(count: bytes.size) }
        unsafe {
            for (i in 0..bytes.size) {
                this._ptr.write(i, bytes[i])
            }
        }
    }

    /// 包装已有堆数据（借用，不负责释放）
    internal init(ptr: CPointer<UInt8>, size: Int64) {
        this._ptr = ptr
        this._size = size
    }

    internal func getPointer(): CPointer<UInt8> { return this._ptr }
    internal func getDataSize(): Int32 { return Int32(this._size) }

    /// 所有权已转移给 ImGui 图集后调用，避免重复释放
    internal func markTransferred(): Unit { this._transferred = true }

    /**
     * @brief[zh-cn] 释放堆内存（所有权已转移给图集时无操作）
     *
     * @brief[en] Frees the heap memory (no-op when ownership was transferred to the atlas)
     */
    public func finalize(): Unit {
        if (!this._ptr.isNull() && !this._transferred) {
            unsafe { LibC.free(this._ptr) }
            this._ptr = CPointer<UInt8>()
        }
    }
}

// =============================================================================
// UiFontConfig — 字体配置（安全类型）
// Font Config (safe type)
// =============================================================================

/**
 * @brief[zh-cn] ImFontConfig 安全包装
 * @explain[zh-cn] 创建独立堆上的 ImFontConfig 实例，提供类型化字段访问。
 *         实例可反复使用；ImGui 在 AddFont* 时会拷贝配置，因此析构释放不影响已添加字体。
 *
 * @brief[en] Safe wrapper for ImFontConfig
 * @explain[en] Creates an ImFontConfig instance on its own heap allocation and provides
 *         typed field access. The instance is reusable; ImGui copies the config during
 *         AddFont*, so destroying it does not affect already-added fonts.
 */
public class UiFontConfig {
    private var _cfg: CPointer<Unit>

    /**
     * @brief[zh-cn] 创建默认字体配置（独立堆上的 ImFontConfig 实例）
     *
     * @brief[en] Creates a default font config (an ImFontConfig instance on its own heap allocation)
     */
    public init() {
        this._cfg = ImFontConfig_ImFontConfig_cj()
    }

    internal init(ptr: CPointer<Unit>) { this._cfg = ptr }

    /// 供 FFI 层桥接（不对外暴露）
    internal func getHandle(): CPointer<Unit> { return this._cfg }

    /**
     * @brief[zh-cn] 释放底层 ImFontConfig 实例
     *
     * @brief[en] Frees the underlying ImFontConfig instance
     */
    public func finalize(): Unit {
        if (!this._cfg.isNull()) {
            ImFontConfig_destroy_cj(this._cfg)
            this._cfg = CPointer<Unit>()
        }
    }

    // ---- MergeMode：合并到上一个字体（用于中文字体回退叠加）----
    /**
     * @brief[zh-cn] 是否合并到上一个字体（用于中文字体回退叠加）
     * @return[zh-cn] 合并模式开关
     *
     * @brief[en] Whether to merge into the previous font (used for Chinese fallback stacking)
     * @return[en] Merge mode flag
     */
    public func getMergeMode(): Bool { return ImFontConfig_Get_MergeMode_cj(this._cfg) != 0 }
    /**
     * @brief[zh-cn] 设置合并模式（合并到上一个字体）
     * @param[zh-cn] v 是否启用合并
     *
     * @brief[en] Sets the merge mode (merge into the previous font)
     * @param[en] v Whether to enable merging
     */
    public func setMergeMode(v: Bool): Unit { ImFontConfig_Set_MergeMode_cj(this._cfg, if (v) { 1 } else { 0 }) }

    // ---- PixelSnapH：像素对齐 ----
    /**
     * @brief[zh-cn] 是否启用像素对齐（PixelSnapH）
     * @return[zh-cn] 像素对齐开关
     *
     * @brief[en] Whether pixel snapping (PixelSnapH) is enabled
     * @return[en] Pixel snap flag
     */
    public func getPixelSnapH(): Bool { return ImFontConfig_Get_PixelSnapH_cj(this._cfg) != 0 }
    /**
     * @brief[zh-cn] 设置像素对齐（PixelSnapH）
     * @param[zh-cn] v 是否启用像素对齐
     *
     * @brief[en] Sets pixel snapping (PixelSnapH)
     * @param[en] v Whether to enable pixel snapping
     */
    public func setPixelSnapH(v: Bool): Unit { ImFontConfig_Set_PixelSnapH_cj(this._cfg, if (v) { 1 } else { 0 }) }

    // ---- Oversample：超采样（越大越清晰，消耗越大）----
    /**
     * @brief[zh-cn] 获取水平超采样倍数（越大越清晰，消耗越大）
     * @return[zh-cn] 水平超采样倍数
     *
     * @brief[en] Gets the horizontal oversampling factor (higher = crisper but more expensive)
     * @return[en] Horizontal oversampling factor
     */
    public func getOversampleH(): Int32 { return ImFontConfig_Get_OversampleH_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置水平超采样倍数
     * @param[zh-cn] v 水平超采样倍数
     *
     * @brief[en] Sets the horizontal oversampling factor
     * @param[en] v Horizontal oversampling factor
     */
    public func setOversampleH(v: Int32): Unit { ImFontConfig_Set_OversampleH_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 获取垂直超采样倍数（越大越清晰，消耗越大）
     * @return[zh-cn] 垂直超采样倍数
     *
     * @brief[en] Gets the vertical oversampling factor (higher = crisper but more expensive)
     * @return[en] Vertical oversampling factor
     */
    public func getOversampleV(): Int32 { return ImFontConfig_Get_OversampleV_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置垂直超采样倍数
     * @param[zh-cn] v 垂直超采样倍数
     *
     * @brief[en] Sets the vertical oversampling factor
     * @param[en] v Vertical oversampling factor
     */
    public func setOversampleV(v: Int32): Unit { ImFontConfig_Set_OversampleV_cj(this._cfg, v) }

    // ---- EllipsisChar：省略号字符（0=自动）----
    /**
     * @brief[zh-cn] 获取省略号字符（0=自动）
     * @return[zh-cn] 省略号字符码点
     *
     * @brief[en] Gets the ellipsis character (0 = auto)
     * @return[en] Ellipsis character code point
     */
    public func getEllipsisChar(): UInt32 { return ImFontConfig_Get_EllipsisChar_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置省略号字符（0=自动）
     * @param[zh-cn] v 省略号字符码点
     *
     * @brief[en] Sets the ellipsis character (0 = auto)
     * @param[en] v Ellipsis character code point
     */
    public func setEllipsisChar(v: UInt32): Unit { ImFontConfig_Set_EllipsisChar_cj(this._cfg, v) }

    // ---- SizePixels：像素大小 ----
    /**
     * @brief[zh-cn] 获取字体像素大小
     * @return[zh-cn] 字体像素大小
     *
     * @brief[en] Gets the font pixel size
     * @return[en] Font pixel size
     */
    public func getSizePixels(): Float32 { return ImFontConfig_Get_SizePixels_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置字体像素大小
     * @param[zh-cn] v 字体像素大小
     *
     * @brief[en] Sets the font pixel size
     * @param[en] v Font pixel size
     */
    public func setSizePixels(v: Float32): Unit { ImFontConfig_Set_SizePixels_cj(this._cfg, v) }

    // ---- GlyphRanges：字形范围 ----
    /**
     * @brief[zh-cn] 获取字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用，不释放）
     *
     * @brief[en] Gets the glyph ranges
     * @return[en] UiGlyphRanges object (borrowed, not freed)
     */
    public func getGlyphRanges(): UiGlyphRanges {
        return UiGlyphRanges(ImFontConfig_Get_GlyphRanges_cj(this._cfg), CPointer<Unit>())
    }
    /**
     * @brief[zh-cn] 设置字形范围
     * @param[zh-cn] ranges 字形范围
     *
     * @brief[en] Sets the glyph ranges
     * @param[en] ranges Glyph ranges
     */
    public func setGlyphRanges(ranges: UiGlyphRanges): Unit {
        ImFontConfig_Set_GlyphRanges_cj(this._cfg, ranges.getRanges())
    }

    // ---- GlyphOffset：字形像素偏移 ----
    /**
     * @brief[zh-cn] 获取字形像素偏移
     * @return[zh-cn] (x, y) 偏移量
     *
     * @brief[en] Gets the glyph pixel offset
     * @return[en] (x, y) offset
     */
    public func getGlyphOffset(): (Float32, Float32) {
        let v = ImFontConfig_Get_GlyphOffset_cj(this._cfg)
        return (v.x, v.y)
    }
    /**
     * @brief[zh-cn] 设置字形像素偏移
     * @param[zh-cn] x 水平偏移
     * @param[zh-cn] y 垂直偏移
     *
     * @brief[en] Sets the glyph pixel offset
     * @param[en] x Horizontal offset
     * @param[en] y Vertical offset
     */
    public func setGlyphOffset(x: Float32, y: Float32): Unit {
        ImFontConfig_Set_GlyphOffset_cj(this._cfg, ImVec2(x, y))
    }

    // ---- 字形前进宽度约束 ----
    /**
     * @brief[zh-cn] 获取字形最小前进宽度
     * @return[zh-cn] 最小前进宽度
     *
     * @brief[en] Gets the minimum glyph advance width
     * @return[en] Minimum advance width
     */
    public func getGlyphMinAdvanceX(): Float32 { return ImFontConfig_Get_GlyphMinAdvanceX_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置字形最小前进宽度
     * @param[zh-cn] v 最小前进宽度
     *
     * @brief[en] Sets the minimum glyph advance width
     * @param[en] v Minimum advance width
     */
    public func setGlyphMinAdvanceX(v: Float32): Unit { ImFontConfig_Set_GlyphMinAdvanceX_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 获取字形最大前进宽度
     * @return[zh-cn] 最大前进宽度
     *
     * @brief[en] Gets the maximum glyph advance width
     * @return[en] Maximum advance width
     */
    public func getGlyphMaxAdvanceX(): Float32 { return ImFontConfig_Get_GlyphMaxAdvanceX_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置字形最大前进宽度
     * @param[zh-cn] v 最大前进宽度
     *
     * @brief[en] Sets the maximum glyph advance width
     * @param[en] v Maximum advance width
     */
    public func setGlyphMaxAdvanceX(v: Float32): Unit { ImFontConfig_Set_GlyphMaxAdvanceX_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 获取字形额外前进宽度
     * @return[zh-cn] 额外前进宽度
     *
     * @brief[en] Gets the extra glyph advance width
     * @return[en] Extra advance width
     */
    public func getGlyphExtraAdvanceX(): Float32 { return ImFontConfig_Get_GlyphExtraAdvanceX_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置字形额外前进宽度
     * @param[zh-cn] v 额外前进宽度
     *
     * @brief[en] Sets the extra glyph advance width
     * @param[en] v Extra advance width
     */
    public func setGlyphExtraAdvanceX(v: Float32): Unit { ImFontConfig_Set_GlyphExtraAdvanceX_cj(this._cfg, v) }

    // ---- FontNo：字体序号（图集内第几个字体）----
    /**
     * @brief[zh-cn] 获取字体序号（图集内第几个字体）
     * @return[zh-cn] 字体序号
     *
     * @brief[en] Gets the font number (index of the font within the atlas)
     * @return[en] Font number
     */
    public func getFontNo(): UInt32 { return ImFontConfig_Get_FontNo_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置字体序号（图集内第几个字体）
     * @param[zh-cn] v 字体序号
     *
     * @brief[en] Sets the font number (index of the font within the atlas)
     * @param[en] v Font number
     */
    public func setFontNo(v: UInt32): Unit { ImFontConfig_Set_FontNo_cj(this._cfg, v) }

    // ---- 光栅化参数 ----
    /**
     * @brief[zh-cn] 获取光栅化倍增系数（调整字形亮度/加粗）
     * @return[zh-cn] 光栅化倍增系数
     *
     * @brief[en] Gets the rasterizer multiply (adjusts glyph brightness/boldness)
     * @return[en] Rasterizer multiply value
     */
    public func getRasterizerMultiply(): Float32 { return ImFontConfig_Get_RasterizerMultiply_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置光栅化倍增系数
     * @param[zh-cn] v 光栅化倍增系数
     *
     * @brief[en] Sets the rasterizer multiply
     * @param[en] v Rasterizer multiply value
     */
    public func setRasterizerMultiply(v: Float32): Unit { ImFontConfig_Set_RasterizerMultiply_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 获取光栅化密度（缩放采样分辨率）
     * @return[zh-cn] 光栅化密度
     *
     * @brief[en] Gets the rasterizer density (scales the sampling resolution)
     * @return[en] Rasterizer density
     */
    public func getRasterizerDensity(): Float32 { return ImFontConfig_Get_RasterizerDensity_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置光栅化密度
     * @param[zh-cn] v 光栅化密度
     *
     * @brief[en] Sets the rasterizer density
     * @param[en] v Rasterizer density
     */
    public func setRasterizerDensity(v: Float32): Unit { ImFontConfig_Set_RasterizerDensity_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 获取额外尺寸缩放
     * @return[zh-cn] 额外尺寸缩放系数
     *
     * @brief[en] Gets the extra size scale
     * @return[en] Extra size scale factor
     */
    public func getExtraSizeScale(): Float32 { return ImFontConfig_Get_ExtraSizeScale_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置额外尺寸缩放
     * @param[zh-cn] v 额外尺寸缩放系数
     *
     * @brief[en] Sets the extra size scale
     * @param[en] v Extra size scale factor
     */
    public func setExtraSizeScale(v: Float32): Unit { ImFontConfig_Set_ExtraSizeScale_cj(this._cfg, v) }

    // ---- FontData：内存字体数据 ----
    /**
     * @brief[zh-cn] 获取内存字体数据指针
     * @return[zh-cn] 字体数据指针（VoidPtr 包装）
     *
     * @brief[en] Gets the in-memory font data pointer
     * @return[en] Font data pointer (wrapped in VoidPtr)
     */
    public func getFontData(): VoidPtr { return Box(ImFontConfig_Get_FontData_cj(this._cfg)) }
    /**
     * @brief[zh-cn] 设置内存字体数据指针
     * @param[zh-cn] ptr 字体数据指针
     *
     * @brief[en] Sets the in-memory font data pointer
     * @param[en] ptr Font data pointer
     */
    public func setFontData(ptr: VoidPtr): Unit { ImFontConfig_Set_FontData_cj(this._cfg, ptr.value) }
    /**
     * @brief[zh-cn] 获取内存字体数据大小
     * @return[zh-cn] 字体数据大小（字节）
     *
     * @brief[en] Gets the in-memory font data size
     * @return[en] Font data size (bytes)
     */
    public func getFontDataSize(): Int32 { return ImFontConfig_Get_FontDataSize_cj(this._cfg) }
    /**
     * @brief[zh-cn] 设置内存字体数据大小
     * @param[zh-cn] v 字体数据大小（字节）
     *
     * @brief[en] Sets the in-memory font data size
     * @param[en] v Font data size (bytes)
     */
    public func setFontDataSize(v: Int32): Unit { ImFontConfig_Set_FontDataSize_cj(this._cfg, v) }
    /**
     * @brief[zh-cn] 字体数据所有权是否归图集所有
     * @return[zh-cn] 所有权归属开关
     *
     * @brief[en] Whether the font data is owned by the atlas
     * @return[en] Ownership flag
     */
    public func getFontDataOwnedByAtlas(): Bool { return ImFontConfig_Get_FontDataOwnedByAtlas_cj(this._cfg) != 0 }
    /**
     * @brief[zh-cn] 设置字体数据所有权是否归图集所有
     * @param[zh-cn] v 是否将所有权转移给图集
     *
     * @brief[en] Sets whether the font data is owned by the atlas
     * @param[en] v Whether to transfer ownership to the atlas
     */
    public func setFontDataOwnedByAtlas(v: Bool): Unit {
        ImFontConfig_Set_FontDataOwnedByAtlas_cj(this._cfg, if (v) { 1 } else { 0 })
    }
}

// =============================================================================
// UiFontGlyphRangesBuilder — 字形范围构建器（安全类型）
// Glyph Ranges Builder (safe type)
// =============================================================================

/**
 * @brief[zh-cn] 自定义字形范围构建器
 * @explain[zh-cn] 通过 AddChar / AddText（UTF-8）/ AddRanges 收集所需字符，再由
 *         buildRanges() 生成可传给 AddFont* 的 UiGlyphRanges。
 *         典型用途：把界面中实际出现的所有中文字符收集起来，缩小字形表体积。
 *
 * @brief[en] Custom glyph ranges builder
 * @explain[en] Collects desired characters via AddChar / AddText (UTF-8) / AddRanges, then
 *         buildRanges() produces a UiGlyphRanges that can be passed to AddFont*.
 *         Typical use: collect every Chinese character that actually appears in the UI to
 *         shrink the glyph table size.
 */
public class UiFontGlyphRangesBuilder {
    private var _builder: CPointer<Unit>

    /**
     * @brief[zh-cn] 创建字形范围构建器
     *
     * @brief[en] Creates a glyph ranges builder
     */
    public init() {
        this._builder = ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder_cj()
    }

    /**
     * @brief[zh-cn] 释放底层构建器资源
     *
     * @brief[en] Frees the underlying builder resources
     */
    public func finalize(): Unit {
        if (!this._builder.isNull()) {
            ImFontGlyphRangesBuilder_destroy_cj(this._builder)
            this._builder = CPointer<Unit>()
        }
    }

    /**
     * @brief[zh-cn] 添加单个字符（Unicode 码点，ImWchar 范围）
     * @param[zh-cn] c 字符码点
     *
     * @brief[en] Adds a single character (Unicode code point, ImWchar range)
     * @param[en] c Character code point
     */
    public func addChar(c: UInt16): Unit {
        if (!this._builder.isNull()) { ImFontGlyphRangesBuilder_AddChar_cj(this._builder, c) }
    }

    /**
     * @brief[zh-cn] 添加一段 UTF-8 文本（自动按码点逐个收录）
     * @param[zh-cn] text UTF-8 文本
     *
     * @brief[en] Adds a UTF-8 text (each code point is collected automatically)
     * @param[en] text UTF-8 text
     */
    public func addText(text: String): Unit {
        if (this._builder.isNull()) { return }
        let cs = unsafe { LibC.mallocCString(text) }
        ImFontGlyphRangesBuilder_AddText_cj(this._builder, cs, CString(CPointer<UInt8>()))
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 追加一组已有范围（如默认范围 + 自定义字符）
     * @param[zh-cn] ranges 要追加的字形范围
     *
     * @brief[en] Appends an existing range set (e.g. default ranges + custom characters)
     * @param[en] ranges Glyph ranges to append
     */
    public func addRanges(ranges: UiGlyphRanges): Unit {
        if (this._builder.isNull()) { return }
        if (ranges.isNull()) { return }
        ImFontGlyphRangesBuilder_AddRanges_cj(this._builder, ranges.getRanges())
    }

    /**
     * @brief[zh-cn] 构建最终字形范围（生成堆内存，由返回对象持有）
     * @return[zh-cn] UiGlyphRanges 对象（拥有堆内存，需调用 finalize 释放）
     *
     * @brief[en] Builds the final glyph ranges (heap memory generated and owned by the returned object)
     * @return[en] UiGlyphRanges object (owns heap memory; call finalize to free)
     */
    public func buildRanges(): UiGlyphRanges {
        if (this._builder.isNull()) { return UiGlyphRanges() }
        let vec = ImVector_ImWchar_create_cj()
        if (vec.isNull()) { return UiGlyphRanges() }
        ImFontGlyphRangesBuilder_BuildRanges_cj(this._builder, vec)
        return UiGlyphRanges(ImVector_ImWchar_Get_Data_cj(vec), vec)
    }
}

// =============================================================================
// UiFontAtlas — 字体图集管理
// Font Atlas Management
// =============================================================================

/**
 * @brief[zh-cn] 字体图集管理器（静态工具类）
 * @explain[zh-cn] 操作 ImGui 当前上下文的 IO.Fonts 指针，提供添加字体、构建、
 *         清除与标准字形范围查询。所有返回句柄均为安全类型（UiFont / UiGlyphRanges）。
 *
 * @brief[en] Font atlas manager (static utility)
 * @explain[en] Operates on the current ImGui context's IO.Fonts pointer, providing font
 *         addition, building, clearing, and standard glyph range queries. All returned
 *         handles are safe types (UiFont / UiGlyphRanges).
 */
public class UiFontAtlas {
    /// 获取当前上下文的 ImFontAtlas 指针（内部）
    private static func getAtlas(): CPointer<Unit> {
        let io = ImGui_GetIO_cj()
        if (io.isNull()) { return CPointer<Unit>() }
        return ImGuiIO_Get_Fonts_cj(io)
    }

    /**
     * @brief[zh-cn] 添加默认字体（内置 ProggyClean）
     * @param[zh-cn] fontConfig 字体配置（可选，默认新建）
     * @return[zh-cn] UiFont 字体对象
     *
     * @brief[en] Adds the default (built-in) font
     * @param[en] fontConfig Font config (optional; a new one is created by default)
     * @return[en] The UiFont object
     */
    public static func addFontDefault(fontConfig!: UiFontConfig = UiFontConfig()): UiFont {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiFont(Box(CPointer<Unit>())) }
        return UiFont(Box(ImFontAtlas_AddFontDefault_cj(atlas, fontConfig.getHandle())))
    }

    /**
     * @brief[zh-cn] 从 TTF/OTF 文件添加字体
     * @param[zh-cn] filename 文件路径
     * @param[zh-cn] sizePixels 像素大小
     * @param[zh-cn] fontConfig 字体配置（可选）
     * @param[zh-cn] glyphRanges 字形范围（可选，默认 Latin+基本符号）
     * @return[zh-cn] UiFont 字体对象
     *
     * @brief[en] Adds a font from a TTF/OTF file
     * @param[en] filename File path
     * @param[en] sizePixels Pixel size
     * @param[en] fontConfig Font config (optional)
     * @param[en] glyphRanges Glyph ranges (optional; defaults to Latin + basic symbols)
     * @return[en] The UiFont object
     */
    public static func addFontFromFileTTF(filename: String, sizePixels: Float32,
                                           fontConfig!: UiFontConfig = UiFontConfig(),
                                           glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiFont(Box(CPointer<Unit>())) }
        let cs = unsafe { LibC.mallocCString(filename) }
        let font = ImFontAtlas_AddFontFromFileTTF_cj(atlas, cs, sizePixels,
                                                       fontConfig.getHandle(), glyphRanges.getRanges())
        unsafe { LibC.free(cs) }
        return UiFont(Box(font))
    }

    /**
     * @brief[zh-cn] 从内存 TTF/OTF 数据添加字体
     * @param[zh-cn] fontData 内存字体数据（安全类型）
     * @param[zh-cn] sizePixels 像素大小
     * @param[zh-cn] fontConfig 字体配置（可选；若设 fontDataOwnedByAtlas=true，
     *                          数据所有权将转移给图集）
     * @param[zh-cn] glyphRanges 字形范围（可选）
     * @return[zh-cn] UiFont 字体对象
     *
     * @brief[en] Adds a font from in-memory TTF/OTF data
     * @param[en] fontData In-memory font data (safe type)
     * @param[en] sizePixels Pixel size
     * @param[en] fontConfig Font config (optional; setting fontDataOwnedByAtlas=true
     *              transfers data ownership to the atlas)
     * @param[en] glyphRanges Glyph ranges (optional)
     * @return[en] The UiFont object
     */
    public static func addFontFromMemoryTTF(fontData: UiFontData, sizePixels: Float32,
                                             fontConfig!: UiFontConfig = UiFontConfig(),
                                             glyphRanges!: UiGlyphRanges = UiGlyphRanges()): UiFont {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiFont(Box(CPointer<Unit>())) }
        if (fontConfig.getFontDataOwnedByAtlas()) { fontData.markTransferred() }
        let font = ImFontAtlas_AddFontFromMemoryTTF_cj(atlas, CPointer<Unit>(fontData.getPointer()),
                                                        fontData.getDataSize(), sizePixels,
                                                        fontConfig.getHandle(), glyphRanges.getRanges())
        return UiFont(Box(font))
    }

    /**
     * @brief[zh-cn] 构建字体图集（生成纹理数据）
     * @explain[zh-cn] 调用 ImFontAtlas.GetTexDataAsRGBA32 触发真实构建；
     *         已构建则直接返回成功。
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Builds the font atlas (generates texture data)
     * @explain[en] Triggers a real build via ImFontAtlas.GetTexDataAsRGBA32;
     *         returns success immediately if already built.
     * @return[en] Whether the build succeeded
     */
    public static func build(): Bool {
        let atlas = getAtlas()
        if (atlas.isNull()) { return false }
        if (ImFontAtlas_IsBuilt_cj(atlas) != 0) { return true }
        return unsafe {
            let pixels = LibC.malloc<CPointer<UInt8>>()
            let w = LibC.malloc<Int32>()
            let h = LibC.malloc<Int32>()
            let bpp = LibC.malloc<Int32>()
            ImFontAtlas_GetTexDataAsRGBA32_cj(atlas, pixels, w, h, bpp)
            let ok = (w.read() > 0) && (h.read() > 0)
            LibC.free(pixels)
            LibC.free(w)
            LibC.free(h)
            LibC.free(bpp)
            ok
        }
    }

    /**
     * @brief[zh-cn] 图集是否已构建
     * @return[zh-cn] 已构建返回 true
     *
     * @brief[en] Whether the atlas has been built
     * @return[en] true if built
     */
    public static func isBuilt(): Bool {
        let atlas = getAtlas()
        if (atlas.isNull()) { return false }
        return ImFontAtlas_IsBuilt_cj(atlas) != 0
    }

    /**
     * @brief[zh-cn] 清除所有数据
     *
     * @brief[en] Clears all atlas data
     */
    public static func clear(): Unit {
        let atlas = getAtlas()
        if (!atlas.isNull()) { ImFontAtlas_Clear_cj(atlas) }
    }

    /**
     * @brief[zh-cn] 清除输入数据（保留纹理）
     *
     * @brief[en] Clears input data (keeps the texture)
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

    // ---- 标准字形范围（均为 ImGui 静态数据，借用不释放）----

    /**
     * @brief[zh-cn] 默认字形范围（Latin + 基本符号）
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Default glyph ranges (Latin + basic symbols)
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesDefault(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesDefault_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 中文简体常用字形范围（约 2500 常用字，含默认+假名+片假名）
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Chinese Simplified common glyph ranges (~2500 common chars, includes default + kana + katakana)
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesChineseSimplifiedCommon(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 中文全量字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Full Chinese glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesChineseFull(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesChineseFull_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 日文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Japanese glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesJapanese(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesJapanese_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 韩文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Korean glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesKorean(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesKorean_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 希腊文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Greek glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesGreek(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesGreek_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 西里尔文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Cyrillic glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesCyrillic(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesCyrillic_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 泰文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Thai glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesThai(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesThai_cj(atlas), CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 越南文字形范围
     * @return[zh-cn] UiGlyphRanges 对象（借用 ImGui 静态数据，不释放）
     *
     * @brief[en] Vietnamese glyph ranges
     * @return[en] UiGlyphRanges object (borrows ImGui static data, not freed)
     */
    public static func getGlyphRangesVietnamese(): UiGlyphRanges {
        let atlas = getAtlas()
        if (atlas.isNull()) { return UiGlyphRanges() }
        return UiGlyphRanges(ImFontAtlas_GetGlyphRangesVietnamese_cj(atlas), CPointer<Unit>())
    }
}

// =============================================================================
// UiFont — 字体对象
// Font Object
// =============================================================================

/**
 * @brief[zh-cn] 字体对象（安全类型）
 * @explain[zh-cn] 封装 ImFont 查询方法。由 UiFontAtlas.addFont* 返回，
 *         可直接传入 UiStyle.pushFont。底层指针由 ImGui 图集托管，无需手动释放。
 *
 * @brief[en] Font object (safe type)
 * @explain[en] Wraps ImFont query methods. Returned by UiFontAtlas.addFont* and can be
 *         passed directly to UiStyle.pushFont. The underlying pointer is managed by the
 *         ImGui atlas, so no manual release is needed.
 */
public class UiFont {
    private var _font: CPointer<Unit>

    /**
     * @brief[zh-cn] 以底层 ImFont 指针构造
     * @param[zh-cn] fontPtr 底层 ImFont 指针
     *
     * @brief[en] Constructs from a raw ImFont pointer
     * @param[en] fontPtr Raw ImFont pointer
     */
    public init(fontPtr: VoidPtr) { this._font = fontPtr.value }

    /**
     * @brief[zh-cn] 获取底层 ImFont 指针（低级接口，一般场景不需要）
     * @return[zh-cn] 底层 ImFont 指针
     *
     * @brief[en] Gets the raw ImFont pointer (low-level interface, usually not needed)
     * @return[en] Raw ImFont pointer
     */
    public func getHandle(): VoidPtr { return Box(this._font) }

    /**
     * @brief[zh-cn] 字体是否已加载
     * @return[zh-cn] 已加载返回 true
     *
     * @brief[en] Whether the font is loaded
     * @return[en] true if loaded
     */
    public func isLoaded(): Bool {
        if (this._font.isNull()) { return false }
        return ImFont_IsLoaded_cj(this._font) != 0
    }

    /**
     * @brief[zh-cn] 获取字体调试名称
     * @return[zh-cn] 调试名称字符串，未加载时为空字符串
     *
     * @brief[en] Gets the font debug name
     * @return[en] Debug name string; empty string if not loaded
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
     * @param[en] fontSize Font size (0 = use default)
     * @param[en] wrapWidth Wrap width (-1.0 = no wrapping)
     * @return[en] (width, height)
     */
    public func calcTextSize(text: String, fontSize!: Float32 = 0.0f32, wrapWidth!: Float32 = -1.0f32): (Float32, Float32) {
        if (this._font.isNull()) { return (0.0f32, 0.0f32) }
        let cs = unsafe { LibC.mallocCString(text) }
        let remainingPtr = CPointer<CString>()
        let v = ImFont_CalcTextSizeA_cj(this._font, fontSize, 0.0f32, wrapWidth,
                                         cs, CString(CPointer<UInt8>()), remainingPtr)
        unsafe { LibC.free(cs) }
        return (v.x, v.y)
    }

    /**
     * @brief[zh-cn] 指定字形是否在字体中
     * @param[zh-cn] codepoint Unicode 码点（ImWchar 范围，<= 0xFFFF）
     * @return[zh-cn] 存在返回 true
     *
     * @brief[en] Whether the specified glyph is in the font
     * @param[en] codepoint Unicode code point (ImWchar range, <= 0xFFFF)
     * @return[en] true if present
     */
    public func isGlyphInFont(codepoint: UInt16): Bool {
        if (this._font.isNull()) { return false }
        return ImFont_IsGlyphInFont_cj(this._font, codepoint) != 0
    }

    /**
     * @brief[zh-cn] 添加字符重映射
     * @param[zh-cn] from 源码点
     * @param[zh-cn] to 目标码点
     *
     * @brief[en] Adds a character remapping
     * @param[en] from Source code point
     * @param[en] to Target code point
     */
    public func addRemapChar(from: UInt16, to: UInt16): Unit {
        if (!this._font.isNull()) {
            ImFont_AddRemapChar_cj(this._font, from, to)
        }
    }

    /**
     * @brief[zh-cn] 获取烘焙字体数据
     * @param[zh-cn] fontSize 字体大小（0=使用默认）
     * @param[zh-cn] density 光栅化密度
     * @return[zh-cn] UiFontBaked 对象
     *
     * @brief[en] Gets the baked font data
     * @param[en] fontSize Font size (0 = use default)
     * @param[en] density Rasterizer density
     * @return[en] UiFontBaked object
     */
    public func getFontBaked(fontSize!: Float32 = 0.0f32, density!: Float32 = 1.0f32): UiFontBaked {
        if (this._font.isNull()) { return UiFontBaked(Box(CPointer<Unit>())) }
        return UiFontBaked(Box(ImFont_GetFontBaked_cj(this._font, fontSize, density)))
    }
}

// =============================================================================
// UiFontGlyph — 字形数据（安全类型）
// Glyph Data (safe type)
// =============================================================================

/**
 * @brief[zh-cn] 字形数据（只读查询）
 * @explain[zh-cn] 封装 ImFontGlyph 的尺寸/UV/推进宽度等字段，由 UiFontBaked.findGlyph 返回。
 *
 * @brief[en] Glyph data (read-only queries)
 * @explain[en] Wraps ImFontGlyph fields such as size/UV/advance width; returned by
 *         UiFontBaked.findGlyph.
 */
public class UiFontGlyph {
    private var _glyph: CPointer<Unit>

    /**
     * @brief[zh-cn] 以底层 ImFontGlyph 指针构造
     * @param[zh-cn] ptr 底层 ImFontGlyph 指针
     *
     * @brief[en] Constructs from a raw ImFontGlyph pointer
     * @param[en] ptr Raw ImFontGlyph pointer
     */
    public init(ptr: VoidPtr) { this._glyph = ptr.value }

    /**
     * @brief[zh-cn] 是否有效（对应非空 ImFontGlyph）
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the glyph is valid (i.e. ImFontGlyph is non-null)
     * @return[en] true if valid
     */
    public func isValid(): Bool { return !this._glyph.isNull() }

    /**
     * @brief[zh-cn] 获取 Unicode 码点
     * @return[zh-cn] 码点值，无效时返回 0
     *
     * @brief[en] Gets the Unicode code point
     * @return[en] Code point; 0 if invalid
     */
    public func getCodepoint(): UInt32 {
        if (this._glyph.isNull()) { return 0u32 }
        return ImFontGlyph_Get_Codepoint_cj(this._glyph)
    }

    /**
     * @brief[zh-cn] 是否可见（可渲染）
     * @return[zh-cn] 可见返回 true
     *
     * @brief[en] Whether the glyph is visible (renderable)
     * @return[en] true if visible
     */
    public func isVisible(): Bool {
        if (this._glyph.isNull()) { return false }
        return ImFontGlyph_Get_Visible_cj(this._glyph) != 0
    }

    /**
     * @brief[zh-cn] 是否为彩色字形
     * @return[zh-cn] 彩色字形返回 true
     *
     * @brief[en] Whether the glyph is colored
     * @return[en] true if colored
     */
    public func isColored(): Bool {
        if (this._glyph.isNull()) { return false }
        return ImFontGlyph_Get_Colored_cj(this._glyph) != 0
    }

    /**
     * @brief[zh-cn] 获取推进宽度（像素）
     * @return[zh-cn] 推进宽度，无效时返回 0
     *
     * @brief[en] Gets the advance width (pixels)
     * @return[en] Advance width; 0 if invalid
     */
    public func getAdvanceX(): Float32 {
        if (this._glyph.isNull()) { return 0.0f32 }
        return ImFontGlyph_Get_AdvanceX_cj(this._glyph)
    }

    /**
     * @brief[zh-cn] 获取字形矩形
     * @return[zh-cn] (x0, y0, x1, y1)，无效时全为 0
     *
     * @brief[en] Gets the glyph rectangle
     * @return[en] (x0, y0, x1, y1); all zeros if invalid
     */
    public func getRect(): (Float32, Float32, Float32, Float32) {
        if (this._glyph.isNull()) { return (0.0f32, 0.0f32, 0.0f32, 0.0f32) }
        return (ImFontGlyph_Get_X0_cj(this._glyph), ImFontGlyph_Get_Y0_cj(this._glyph),
                ImFontGlyph_Get_X1_cj(this._glyph), ImFontGlyph_Get_Y1_cj(this._glyph))
    }

    /**
     * @brief[zh-cn] 获取字形 UV 坐标
     * @return[zh-cn] (u0, v0, u1, v1)，无效时全为 0
     *
     * @brief[en] Gets the glyph UV coordinates
     * @return[en] (u0, v0, u1, v1); all zeros if invalid
     */
    public func getUV(): (Float32, Float32, Float32, Float32) {
        if (this._glyph.isNull()) { return (0.0f32, 0.0f32, 0.0f32, 0.0f32) }
        return (ImFontGlyph_Get_U0_cj(this._glyph), ImFontGlyph_Get_V0_cj(this._glyph),
                ImFontGlyph_Get_U1_cj(this._glyph), ImFontGlyph_Get_V1_cj(this._glyph))
    }

    /**
     * @brief[zh-cn] 获取打包页 ID
     * @return[zh-cn] 打包页 ID，无效时返回 0
     *
     * @brief[en] Gets the packing page ID
     * @return[en] Packing page ID; 0 if invalid
     */
    public func getPackId(): Int32 {
        if (this._glyph.isNull()) { return 0 }
        return ImFontGlyph_Get_PackId_cj(this._glyph)
    }
}

// =============================================================================
// UiFontBaked — 烘焙字体数据
// Baked Font Data
// =============================================================================

/**
 * @brief[zh-cn] 烘焙字体数据（安全类型）
 * @explain[zh-cn] 封装 ImFontBaked 的字形查询方法；findGlyph 返回 UiFontGlyph 安全对象。
 *
 * @brief[en] Baked font data (safe type)
 * @explain[en] Wraps ImFontBaked glyph query methods; findGlyph returns safe UiFontGlyph objects.
 */
public class UiFontBaked {
    private var _baked: CPointer<Unit>

    /**
     * @brief[zh-cn] 以底层 ImFontBaked 指针构造
     * @param[zh-cn] ptr 底层 ImFontBaked 指针
     *
     * @brief[en] Constructs from a raw ImFontBaked pointer
     * @param[en] ptr Raw ImFontBaked pointer
     */
    public init(ptr: VoidPtr) { this._baked = ptr.value }

    /**
     * @brief[zh-cn] 查找字形（带缺省回退）
     * @param[zh-cn] codepoint Unicode 码点
     * @return[zh-cn] UiFontGlyph 对象，未找到时回退到缺省字形
     *
     * @brief[en] Finds a glyph (with default fallback)
     * @param[en] codepoint Unicode code point
     * @return[en] UiFontGlyph object; falls back to the default glyph when not found
     */
    public func findGlyph(codepoint: UInt16): UiFontGlyph {
        if (this._baked.isNull()) { return UiFontGlyph(Box(CPointer<Unit>())) }
        return UiFontGlyph(Box(ImFontBaked_FindGlyph_cj(this._baked, codepoint)))
    }

    /**
     * @brief[zh-cn] 查找字形（无回退）
     * @param[zh-cn] codepoint Unicode 码点
     * @return[zh-cn] UiFontGlyph 对象，未找到时可能无效
     *
     * @brief[en] Finds a glyph (no fallback)
     * @param[en] codepoint Unicode code point
     * @return[en] UiFontGlyph object; may be invalid when not found
     */
    public func findGlyphNoFallback(codepoint: UInt16): UiFontGlyph {
        if (this._baked.isNull()) { return UiFontGlyph(Box(CPointer<Unit>())) }
        return UiFontGlyph(Box(ImFontBaked_FindGlyphNoFallback_cj(this._baked, codepoint)))
    }

    /**
     * @brief[zh-cn] 获取字符推进宽度（像素）
     * @param[zh-cn] codepoint Unicode 码点
     * @return[zh-cn] 推进宽度，无效时返回 0
     *
     * @brief[en] Gets the character advance width (pixels)
     * @param[en] codepoint Unicode code point
     * @return[en] Advance width; 0 if invalid
     */
    public func getCharAdvance(codepoint: UInt16): Float32 {
        if (this._baked.isNull()) { return 0.0f32 }
        return ImFontBaked_GetCharAdvance_cj(this._baked, codepoint)
    }

    /**
     * @brief[zh-cn] 清除输出数据
     *
     * @brief[en] Clears the output data
     */
    public func clearOutputData(): Unit {
        if (!this._baked.isNull()) { ImFontBaked_ClearOutputData_cj(this._baked) }
    }
}
