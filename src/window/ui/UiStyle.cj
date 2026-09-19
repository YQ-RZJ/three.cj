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
 * @file[zh-cn] UiStyle.cj — ImGui 样式管理类
 * @brief[zh-cn] 封装 ImGui 样式系统：颜色、变量、预设主题
 * @explain[zh-cn] 提供主题切换（dark/light/classic）、颜色压栈/弹栈、样式变量压栈/弹栈、字体管理、INI 持久化、颜色工具等完整的样式控制能力。用法示例：
 *   UiStyle.dark()  // 使用预设主题
 *   let style = UiStyle()
 *   style.pushColor(ImGuiCol.WindowBg, 0.1, 0.1, 0.15, 1.0)
 *   style.pushVar(ImGuiStyleVar.WindowRounding, 8.0)
 *   // ... 绘制控件 ...
 *   style.popColor(1)
 *   style.popVar(1)
 *   style.saveIni("style.ini")  // 保存/加载
 *
 * @file[en] UiStyle.cj — ImGui Style Management
 * @brief[en] Wrappers for ImGui style system: colors, variables, preset themes
 * @explain[en] Provides theme switching (dark/light/classic), color/style push/pop, font management, INI persistence, and color utility tools.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*
import three.utils.memory.VoidPtr

/**
 * @brief[zh-cn] ImGui 样式管理类
 *
 * @brief[en] ImGui style management class
 */
public class UiStyle {
    // ===== 预设主题 =====

    /**
     * @brief[zh-cn] 应用暗色主题
     *
     * @brief[en] Applies the dark theme
     */
    public static func dark(): Unit {
        igStyleColorsDark_cj(CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 应用亮色主题
     *
     * @brief[en] Applies the light theme
     */
    public static func light(): Unit {
        igStyleColorsLight_cj(CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 应用经典主题
     *
     * @brief[en] Applies the classic theme
     */
    public static func classic(): Unit {
        igStyleColorsClassic_cj(CPointer<Unit>())
    }

    // ===== 颜色操作 =====

    /**
     * @brief[zh-cn] 压入颜色样式
     * @param[zh-cn] idx 颜色索引（ImGuiCol 枚举值）
     * @param[zh-cn] color 颜色（RGB 分量范围 [0, 1]，alpha 默认 1.0）
     *
     * @brief[en] Pushes a color style
     * @param[en] idx Color index (ImGuiCol enum value)
     * @param[en] color Color (RGB components in [0, 1], alpha defaults to 1.0)
     */
    public func pushColor(idx: Int32, color: Color): Unit {
        igPushStyleColor_Vec4_cj(idx, ImVec4(Float32(color.r), Float32(color.g), Float32(color.b), 1.0))
    }

    /**
     * @brief[zh-cn] 压入颜色样式（UInt32 格式）
     * @param[zh-cn] idx 颜色索引
     * @param[zh-cn] col 颜色值（IM_COL32 格式）
     *
     * @brief[en] Pushes a color style (UInt32 format)
     * @param[en] idx Color index
     * @param[en] col Color value (IM_COL32 format)
     */
    public func pushColorU32(idx: Int32, col: UInt32): Unit {
        igPushStyleColor_U32_cj(idx, col)
    }

    /**
     * @brief[zh-cn] 弹出颜色样式
     * @param[zh-cn] count 弹出数量
     *
     * @brief[en] Pops color styles
     * @param[en] count Number of styles to pop
     */
    public func popColor(count!: Int32 = 1): Unit {
        igPopStyleColor_cj(count)
    }

    // ===== 变量操作 =====

    /**
     * @brief[zh-cn] 压入浮点样式变量
     * @param[zh-cn] idx 变量索引（ImGuiStyleVar 枚举值）
     * @param[zh-cn] val 浮点值
     *
     * @brief[en] Pushes a float style variable
     * @param[en] idx Variable index (ImGuiStyleVar enum value)
     * @param[en] val Float value
     */
    public func pushVarFloat(idx: Int32, val: Float32): Unit {
        igPushStyleVar_Float_cj(idx, val)
    }

    /**
     * @brief[zh-cn] 压入 Vec2 样式变量
     * @param[zh-cn] idx 变量索引
     * @param[zh-cn] value Vector2 值
     *
     * @brief[en] Pushes a Vec2 style variable
     * @param[en] idx Variable index
     * @param[en] value Vector2 value
     */
    public func pushVarVec2(idx: Int32, value: Vector2): Unit {
        igPushStyleVar_Vec2_cj(idx, ImVec2(Float32(value.x), Float32(value.y)))
    }

    /**
     * @brief[zh-cn] 弹出样式变量
     * @param[zh-cn] count 弹出数量
     *
     * @brief[en] Pops style variables
     * @param[en] count Number of variables to pop
     */
    public func popVar(count!: Int32 = 1): Unit {
        igPopStyleVar_cj(count)
    }

    // ===== 查询 =====

    /// 获取样式对象指针（内部）
    internal func getStyle(): CPointer<Unit> {
        return igGetStyle_cj()
    }

    /**
     * @brief[zh-cn] 获取颜色值
     * @param[zh-cn] idx 颜色索引
     * @return[zh-cn] ImVec4 颜色值
     *
     * @brief[en] Returns the color value
     * @param[en] idx Color index
     * @return[en] ImVec4 color value
     */
    public func getColor(idx: Int32): ImVec4 {
        return unsafe { igGetStyleColorVec4_cj(idx).read() }
    }

    /**
     * @brief[zh-cn] 获取颜色名称
     * @param[zh-cn] idx 颜色索引
     * @return[zh-cn] 颜色名称字符串
     *
     * @brief[en] Returns the color name
     * @param[en] idx Color index
     * @return[en] Color name string
     */
    public func getColorName(idx: Int32): String {
        return igGetStyleColorName_cj(idx)
    }

    // ===== 字体 =====

    /**
     * @brief[zh-cn] 压入字体
     * @param[zh-cn] font 字体对象
     * @param[zh-cn] fontSizeBaseUnscaled 基础字号
     *
     * @brief[en] Pushes a font
     * @param[en] font Font object
     * @param[en] fontSizeBaseUnscaled Base font size
     */
    public func pushFont(font: UiFont, fontSizeBaseUnscaled!: Float32 = 0.0): Unit {
        igPushFont_cj(font.getHandle().value, fontSizeBaseUnscaled)
    }

    /**
     * @brief[zh-cn] 弹出字体
     *
     * @brief[en] Pops the font
     */
    public func popFont(): Unit {
        igPopFont_cj()
    }

    /**
     * @brief[zh-cn] 获取当前字体
     * @return[zh-cn] 当前字体对象
     *
     * @brief[en] Returns the current font
     * @return[en] Current font object
     */
    public func getFont(): UiFont {
        return UiFont(Box(igGetFont_cj()))
    }

    /**
     * @brief[zh-cn] 获取当前字号
     * @return[zh-cn] 当前字号
     *
     * @brief[en] Returns the current font size
     * @return[en] Current font size
     */
    public func getFontSize(): Float32 {
        return igGetFontSize_cj()
    }

    // ===== 窗口操作 =====

    /**
     * @brief[zh-cn] 显示样式编辑器
     * @param[zh-cn] ref 样式引用（null=编辑全局样式）
     *
     * @brief[en] Shows the style editor
     * @param[en] ref Style reference (null = edit global style)
     */
    public func showStyleEditor(ref!: VoidPtr = Box(CPointer<Unit>())): Unit {
        igShowStyleEditor_cj(ref.value)
    }

    /**
     * @brief[zh-cn] 显示样式选择器
     * @param[zh-cn] label 标签
     * @return[zh-cn] 是否选择了新样式
     *
     * @brief[en] Shows the style selector
     * @param[en] label Label text
     * @return[en] Whether a new style was selected
     */
    public func showStyleSelector(label: String): Bool {
        let cs = unsafe { LibC.mallocCString(label) }
        let r = igShowStyleSelector_cj(cs) != 0
        unsafe { LibC.free(cs) }
        return r
    }

    /**
     * @brief[zh-cn] 显示字体选择器
     * @param[zh-cn] label 标签
     *
     * @brief[en] Shows the font selector
     * @param[en] label Label text
     */
    public func showFontSelector(label: String): Unit {
        let cs = unsafe { LibC.mallocCString(label) }
        igShowFontSelector_cj(cs)
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 显示用户指南
     *
     * @brief[en] Shows the user guide
     */
    public func showUserGuide(): Unit {
        igShowUserGuide_cj()
    }

    // ===== 缩放 =====

    /**
     * @brief[zh-cn] 缩放所有样式尺寸
     * @param[zh-cn] scaleFactor 缩放因子
     *
     * @brief[en] Scales all style sizes
     * @param[en] scaleFactor Scale factor
     */
    public func scaleAllSizes(scaleFactor: Float32): Unit {
        let style = this.getStyle()
        if (!style.isNull()) {
            ImGuiStyle_ScaleAllSizes_cj(style, scaleFactor)
        }
    }

    /**
     * @brief[zh-cn] 设置主字体缩放（Style.FontScaleMain）
     * @explain[zh-cn] ImGui 1.92 起 IO.FontGlobalScale 已移除，改用 ImGuiStyle.FontScaleMain。
     * @param[zh-cn] scale 缩放因子（1.0 = 原始大小）
     *
     * @brief[en] Sets the main font scale (Style.FontScaleMain)
     * @param[en] scale Scale factor (1.0 = original size)
     */
    public static func setFontGlobalScale(scale: Float32): Unit {
        let style = igGetStyle_cj()
        if (!style.isNull()) {
            ImGuiStyle_Set_FontScaleMain_cj(style, scale)
        }
    }

    /**
     * @brief[zh-cn] 获取主字体缩放（Style.FontScaleMain）
     * @return[zh-cn] 缩放因子
     *
     * @brief[en] Gets the main font scale (Style.FontScaleMain)
     * @return[en] Scale factor
     */
    public static func getFontGlobalScale(): Float32 {
        let style = igGetStyle_cj()
        if (style.isNull()) { return 1.0f32 }
        return ImGuiStyle_Get_FontScaleMain_cj(style)
    }

    /**
     * @brief[zh-cn] 获取 ImGui 显示区域尺寸（IO.DisplaySize）
     * @return[zh-cn] (width, height) 像素尺寸
     *
     * @brief[en] Gets the ImGui display area size (IO.DisplaySize)
     * @return[en] (width, height) in pixels
     */
    public static func getDisplaySize(): (Float32, Float32) {
        let io = ImGui_GetIO_cj()
        if (io.isNull()) { return (0.0f32, 0.0f32) }
        let v = ImGuiIO_Get_DisplaySize_cj(io)
        return (v.x, v.y)
    }

    // ===== 栈操作（Item / TextWrap / ItemFlag） =====
    // ===== Stack Operations (Item / TextWrap / ItemFlag) =====

    /**
     * @brief[zh-cn] 压入控件宽度（覆盖自动计算）
     * @param[zh-cn] itemWidth 控件宽度
     *
     * @brief[en] Pushes item width (overrides auto-calculation)
     * @param[en] itemWidth Item width
     */
    public static func pushItemWidth(itemWidth: Float32): Unit { igPushItemWidth_cj(itemWidth) }
    /**
     * @brief[zh-cn] 弹出控件宽度
     *
     * @brief[en] Pops item width
     */
    public static func popItemWidth(): Unit { igPopItemWidth_cj() }
    /**
     * @brief[zh-cn] 计算当前控件宽度
     * @return[zh-cn] 当前控件宽度
     *
     * @brief[en] Calculates the current item width
     * @return[en] Current item width
     */
    public static func calcItemWidth(): Float32 { return igCalcItemWidth_cj() }

    /**
     * @brief[zh-cn] 压入文本自动换行位置（0.0=窗口右边缘）
     * @param[zh-cn] wrapPosX 换行位置 X，默认 0.0（窗口右边缘）
     *
     * @brief[en] Pushes text wrap position (0.0=window right edge)
     * @param[en] wrapPosX Wrap position X, defaults to 0.0 (window right edge)
     */
    public static func pushTextWrapPos(wrapPosX!: Float32 = 0.0f32): Unit { igPushTextWrapPos_cj(wrapPosX) }
    /**
     * @brief[zh-cn] 弹出文本换行位置
     *
     * @brief[en] Pops text wrap position
     */
    public static func popTextWrapPos(): Unit { igPopTextWrapPos_cj() }

    /**
     * @brief[zh-cn] 压入控件标志（ImGuiItemFlags）
     * @param[zh-cn] flags ImGuiItemFlags
     * @param[zh-cn] cond 条件（true=生效）
     *
     * @brief[en] Pushes item flags (ImGuiItemFlags)
     * @param[en] flags ImGuiItemFlags
     * @param[en] cond Condition (true=active)
     */
    public static func pushItemFlag(flags: Int32, cond: Bool): Unit { igPushItemFlag_cj(flags, if (cond) { 1 } else { 0 }) }
    /**
     * @brief[zh-cn] 弹出控件标志
     *
     * @brief[en] Pops item flags
     */
    public static func popItemFlag(): Unit { igPopItemFlag_cj() }

    // ===== 帧信息 =====
    // ===== Frame Info =====

    /**
     * @brief[zh-cn] 获取 ImGui 运行时间（秒）
     * @return[zh-cn] 自 ImGui 初始化以来的运行秒数
     *
     * @brief[en] Gets the ImGui running time (seconds)
     * @return[en] Seconds elapsed since ImGui initialization
     */
    public static func getTime(): Float64 { return igGetTime_cj() }
    /**
     * @brief[zh-cn] 获取 ImGui 帧计数
     * @return[zh-cn] 已渲染帧数
     *
     * @brief[en] Gets the ImGui frame count
     * @return[en] Number of rendered frames
     */
    public static func getFrameCount(): Int32 { return igGetFrameCount_cj() }
    /**
     * @brief[zh-cn] 获取当前全局缩放因子
     * @return[zh-cn] 当前全局缩放因子
     *
     * @brief[en] Gets the current global scale factor
     * @return[en] Current global scale factor
     */
    public static func getScale(): Float32 { return igGetScale_cj() }

    // ===== 文本尺寸 =====
    // ===== Text Size =====

    /**
     * @brief[zh-cn] 计算文本渲染尺寸
     * @param[zh-cn] text 文本
     * @param[zh-cn] hideTextAfterDoubleHash 是否在 ## 后截断
     * @param[zh-cn] wrapWidth 换行宽度（-1.0=不换行）
     * @return[zh-cn] (width, height)
     *
     * @brief[en] Calculates text rendering size
     * @param[en] text Text
     * @param[en] hideTextAfterDoubleHash Whether to truncate after ##
     * @param[en] wrapWidth Wrap width (-1.0=no wrap)
     * @return[en] (width, height)
     */
    public static func calcTextSize(text: String, hideTextAfterDoubleHash!: Bool = true, wrapWidth!: Float32 = -1.0f32): (Float32, Float32) {
        let cs = unsafe { LibC.mallocCString(text) }
        let v = igCalcTextSize_cj(cs, CString(CPointer<UInt8>()),
            if (hideTextAfterDoubleHash) { 1 } else { 0 }, wrapWidth)
        unsafe { LibC.free(cs) }
        return (v.x, v.y)
    }

    // ===== 剪贴板 =====
    // ===== Clipboard =====

    /**
     * @brief[zh-cn] 获取剪贴板文本
     * @return[zh-cn] 剪贴板文本内容
     *
     * @brief[en] Gets clipboard text
     * @return[en] Clipboard text content
     */
    public static func getClipboardText(): String { return igGetClipboardText_cj() }
    /**
     * @brief[zh-cn] 设置剪贴板文本
     * @param[zh-cn] text 要写入剪贴板的文本
     *
     * @brief[en] Sets clipboard text
     * @param[en] text Text to write to the clipboard
     */
    public static func setClipboardText(text: String): Unit {
        unsafe { let cs = LibC.mallocCString(text); igSetClipboardText_cj(cs); LibC.free(cs) }
    }

    // ===== 颜色转换 =====
    // ===== Color Conversion =====

    /**
     * @brief[zh-cn] RGB → HSV
     * @param[zh-cn] r 红色分量（0~1）
     * @param[zh-cn] g 绿色分量（0~1）
     * @param[zh-cn] b 蓝色分量（0~1）
     * @return[zh-cn] (h, s, v) HSV 分量
     *
     * @brief[en] RGB → HSV
     * @param[en] r Red component (0~1)
     * @param[en] g Green component (0~1)
     * @param[en] b Blue component (0~1)
     * @return[en] (h, s, v) HSV components
     */
    public static func rgbToHSV(r: Float32, g: Float32, b: Float32): (Float32, Float32, Float32) {
        let hp = unsafe { LibC.malloc<Float32>() }
        let sp = unsafe { LibC.malloc<Float32>() }
        let vp = unsafe { LibC.malloc<Float32>() }
        igColorConvertRGBtoHSV_cj(r, g, b, hp, sp, vp)
        let h = unsafe { hp.read() }
        let s = unsafe { sp.read() }
        let vv = unsafe { vp.read() }
        unsafe { LibC.free(hp); LibC.free(sp); LibC.free(vp) }
        return (h, s, vv)
    }
    /**
     * @brief[zh-cn] HSV → RGB
     * @param[zh-cn] h 色相（0~360）
     * @param[zh-cn] s 饱和度（0~1）
     * @param[zh-cn] v 明度（0~1）
     * @return[zh-cn] (r, g, b) RGB 分量
     *
     * @brief[en] HSV → RGB
     * @param[en] h Hue (0~360)
     * @param[en] s Saturation (0~1)
     * @param[en] v Value (0~1)
     * @return[en] (r, g, b) RGB components
     */
    public static func hsvToRGB(h: Float32, s: Float32, v: Float32): (Float32, Float32, Float32) {
        let rp = unsafe { LibC.malloc<Float32>() }
        let gp = unsafe { LibC.malloc<Float32>() }
        let bp = unsafe { LibC.malloc<Float32>() }
        igColorConvertHSVtoRGB_cj(h, s, v, rp, gp, bp)
        let r = unsafe { rp.read() }
        let g = unsafe { gp.read() }
        let b = unsafe { bp.read() }
        unsafe { LibC.free(rp); LibC.free(gp); LibC.free(bp) }
        return (r, g, b)
    }

    // ===== 颜色查询 =====
    // ===== Color Query =====

    /**
     * @brief[zh-cn] 按 ImGuiCol 获取颜色值（Vec4）
     * @param[zh-cn] idx 颜色索引（ImGuiCol 枚举值）
     * @return[zh-cn] 颜色值（RGBA，分量范围 [0, 1]）
     *
     * @brief[en] Gets color value by ImGuiCol (Vec4)
     * @param[en] idx Color index (ImGuiCol enum value)
     * @return[en] Color value (RGBA, components in [0, 1])
     */
    public static func getColorVec4(idx: Int32): ImVec4 {
        return unsafe { igGetStyleColorVec4_cj(idx).read() }
    }

    // ===== INI 持久化 =====

    /**
     * @brief[zh-cn] 从文件加载 INI 设置
     * @param[zh-cn] filename 文件路径
     *
     * @brief[en] Loads INI settings from file
     * @param[en] filename File path
     */
    public func loadIni(filename: String): Unit {
        let cs = unsafe { LibC.mallocCString(filename) }
        igLoadIniSettingsFromDisk_cj(cs)
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 从内存加载 INI 设置
     * @param[zh-cn] data INI 数据
     *
     * @brief[en] Loads INI settings from memory
     * @param[en] data INI data
     */
    public func loadIniFromMemory(data: String): Unit {
        unsafe {
            let cs = LibC.mallocCString(data)
            igLoadIniSettingsFromMemory_cj(cs, UIntNative(data.size))
            LibC.free(cs)
        }
    }

    /**
     * @brief[zh-cn] 保存 INI 设置到文件
     * @param[zh-cn] filename 文件路径
     *
     * @brief[en] Saves INI settings to file
     * @param[en] filename File path
     */
    public func saveIni(filename: String): Unit {
        let cs = unsafe { LibC.mallocCString(filename) }
        igSaveIniSettingsToDisk_cj(cs)
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 保存 INI 设置到内存
     * @return[zh-cn] INI 字符串
     *
     * @brief[en] Saves INI settings to memory
     * @return[en] INI string
     */
    public func saveIniToMemory(): String {
        let sizePtr = unsafe { LibC.malloc<UIntNative>() }
        unsafe { sizePtr.write(UIntNative(0)) }
        return igSaveIniSettingsToMemory_cj(sizePtr)
    }

    // ===== 颜色工具 =====

    /**
     * @brief[zh-cn] 将 RGBA 转换为 ImU32 颜色
     * @param[zh-cn] r 红色分量（0~255）
     * @param[zh-cn] g 绿色分量（0~255）
     * @param[zh-cn] b 蓝色分量（0~255）
     * @param[zh-cn] a 透明度分量（0~255）
     * @return[zh-cn] ImU32 打包颜色值
     *
     * @brief[en] Converts RGBA to ImU32 color
     * @param[en] r Red component (0~255)
     * @param[en] g Green component (0~255)
     * @param[en] b Blue component (0~255)
     * @param[en] a Alpha component (0~255)
     * @return[en] Packed ImU32 color value
     */
    public static func col32(r: UInt32, g: UInt32, b: UInt32, a: UInt32): UInt32 {
        return imCol32(r, g, b, a)
    }

    /**
     * @brief[zh-cn] 将 ImU32 转换为 ImVec4
     * @param[zh-cn] col ImU32 打包颜色值
     * @return[zh-cn] ImVec4 颜色值（RGBA，分量范围 [0, 1]）
     *
     * @brief[en] Converts ImU32 to ImVec4
     * @param[en] col Packed ImU32 color value
     * @return[en] ImVec4 color value (RGBA, components in [0, 1])
     */
    public static func u32ToVec4(col: UInt32): ImVec4 {
        return igColorConvertU32ToFloat4_cj(col)
    }

    /**
     * @brief[zh-cn] 将 ImVec4 转换为 ImU32
     * @param[zh-cn] col ImVec4 颜色值（RGBA，分量范围 [0, 1]）
     * @return[zh-cn] ImU32 打包颜色值
     *
     * @brief[en] Converts ImVec4 to ImU32
     * @param[en] col ImVec4 color value (RGBA, components in [0, 1])
     * @return[en] Packed ImU32 color value
     */
    public static func vec4ToU32(col: ImVec4): UInt32 {
        return igColorConvertFloat4ToU32_cj(col)
    }
}
