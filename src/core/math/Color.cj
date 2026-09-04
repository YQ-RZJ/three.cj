/**
 * @file[zh-cn] Color
 * @brief[zh-cn] 颜色
 * @explain[zh-cn] 表示 RGB 颜色，分量范围为 [0, 1]。Color 实例由线性工作颜色空间（默认为 LinearSRGBColorSpace）中的 RGB 分量表示。使用 SRGBColorSpace（如十六进制和 CSS 字符串）的输入会自动转换到工作颜色空间。
 *
 * @file[en] Color
 * @brief[en] Color
 * @explain[en] Represents RGB color with component range [0, 1]. Color instances are represented by RGB components in the linear working color space (default LinearSRGBColorSpace). Inputs using SRGBColorSpace (e.g., hexadecimal and CSS strings) are automatically converted to the working color space.
 */
package three.core.math

import std.math.*
import std.collection.*
import three.utils.constants.*
import three.core.interfaces.*
import std.convert.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 颜色类，使用 RGB 分量表示，范围 [0, 1]
 * @explain[zh-cn] Color 实例由线性工作颜色空间（默认为 LinearSRGBColorSpace）中的 RGB 分量表示。使用 SRGBColorSpace（如十六进制和 CSS 字符串）的输入会自动转换到工作颜色空间。
 *
 * @brief[en] Color class, represented by RGB components, range [0, 1]
 * @explain[en] Color instances are represented by RGB components in the linear working color space (default LinearSRGBColorSpace). Inputs using SRGBColorSpace (e.g., hexadecimal and CSS strings) are automatically converted to the working color space.
 */
@JsonAdapter
public class Color <: IBackground {
    /**
     * @brief[zh-cn] 红色分量
     *
     * @brief[en] Red component
     */
    public var r: Float64
    /**
     * @brief[zh-cn] 绿色分量
     *
     * @brief[en] Green component
     */
    public var g: Float64
    /**
     * @brief[zh-cn] 蓝色分量
     *
     * @brief[en] Blue component
     */
    public var b: Float64
    /**
     * @brief[zh-cn] CSS 颜色名称到十六进制值的映射表（延迟初始化）
     *
     * @brief[en] CSS color name to hexadecimal value mapping table (lazy initialization)
     */
    @JsonIgnore
    public static prop NAMES: HashMap<String, UInt32> {
        get() {
            if (_names.isEmpty()) {
                initColorNames(_names)
            }
            _names
        }
    }
    @JsonIgnore
    private static let _names: HashMap<String, UInt32> = HashMap<String, UInt32>()

    public init() { this.r = 1.0; this.g = 1.0; this.b = 1.0 }
    public init(r: Float64, g: Float64, b: Float64) { this.r = r; this.g = g; this.b = b }
    // 4 参数构造（r, g, b, a）：a（alpha）为便利占位——Color 本身无 alpha 字段，
    // 供 ShaderMaterial 自定义 uniform 传 vec4 数据（如 u_steps.x 档数）或
    // 与 three.js 惯例对齐的 RGBA 写法使用；alpha 分量被忽略。
    public init(r: Float64, g: Float64, b: Float64, a: Float64) { this.r = r; this.g = g; this.b = b }
    public init(r: Int64, g: Int64, b: Int64) {
        // 整数字节值（0-255）→ Float64（0.0-1.0），供 Color(0x30, 0x30, 0x60) 形式使用
        this.r = Float64(r) / 255.0
        this.g = Float64(g) / 255.0
        this.b = Float64(b) / 255.0
    }
    public init(r: UInt8, g: UInt8, b: UInt8) {
        this.r = Float64(r) / 255.0
        this.g = Float64(g) / 255.0
        this.b = Float64(b) / 255.0
    }
    public init(hex: UInt32) {
        this.r = Float64((hex >> 16) & 0xFFu32) / 255.0
        this.g = Float64((hex >> 8) & 0xFFu32) / 255.0
        this.b = Float64(hex & 0xFFu32) / 255.0
    }

    /**
     * @brief[zh-cn] 设置 RGB 分量
     * @param[zh-cn] r 红色分量
     * g 绿色分量
     * b 蓝色分量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set RGB components
     * @param[en] r Red component
     * g Green component
     * b Blue component
     * @return[en] This instance
     */
    public func set(r: Float64, g: Float64, b: Float64): Color {
        this.r = r; this.g = g; this.b = b; return this
    }

    /**
     * @brief[zh-cn] 将所有分量设置为相同值
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set all components to the same value
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func setScalar(s: Float64): Color {
        this.r = s; this.g = s; this.b = s; return this
    }

    /**
     * @brief[zh-cn] 从十六进制值设置颜色
     * @param[zh-cn] hex 十六进制颜色值
     * colorSpace 颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set color from hexadecimal value
     * @param[en] hex Hexadecimal color value
     * colorSpace Color space
     * @return[en] This instance
     */
    public func setHex(hex: UInt32, colorSpace!: String = SRGBColorSpace): Color {
        this.r = Float64((hex >> 16) & 0xFFu32) / 255.0
        this.g = Float64((hex >> 8) & 0xFFu32) / 255.0
        this.b = Float64(hex & 0xFFu32) / 255.0
        ColorManagement.colorSpaceToWorking(this, colorSpace)
        return this
    }

    /**
     * @brief[zh-cn] 设置 RGB 分量（指定颜色空间）
     * @param[zh-cn] r 红色分量
     * g 绿色分量
     * b 蓝色分量
     * colorSpace 颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set RGB components (with specified color space)
     * @param[en] r Red component
     * g Green component
     * b Blue component
     * colorSpace Color space
     * @return[en] This instance
     */
    public func setRGB(r: Float64, g: Float64, b: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color {
        this.r = r; this.g = g; this.b = b
        ColorManagement.colorSpaceToWorking(this, colorSpace)
        return this
    }

    /**
     * @brief[zh-cn] 从 HSL 值设置颜色
     * @param[zh-cn] h 色相
     * s 饱和度
     * l 亮度
     * colorSpace 颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set color from HSL values
     * @param[en] h Hue
     * s Saturation
     * l Lightness
     * colorSpace Color space
     * @return[en] This instance
     */
    public func setHSL(h: Float64, s: Float64, l: Float64, colorSpace!: String = ColorManagement.workingColorSpace): Color {
        let hue = MathUtils.euclideanModulo(h, 1.0)
        let sat = clamp(s, 0.0, 1.0)
        let light = clamp(l, 0.0, 1.0)
        if (sat == 0.0) {
            this.r = light; this.g = light; this.b = light
        } else {
            let q = if (light <= 0.5) { light * (1.0 + sat) } else { light + sat - light * sat }
            let p = 2.0 * light - q
            this.r = hue2rgb(p, q, hue + 1.0 / 3.0)
            this.g = hue2rgb(p, q, hue)
            this.b = hue2rgb(p, q, hue - 1.0 / 3.0)
        }
        ColorManagement.colorSpaceToWorking(this, colorSpace)
        return this
    }

    /**
     * @brief[zh-cn] 从 CSS 样式字符串设置颜色
     * @param[zh-cn] style CSS 样式字符串
     * colorSpace 颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set color from CSS style string
     * @param[en] style CSS style string
     * colorSpace Color space
     * @return[en] This instance
     */
    public func setStyle(style: String, colorSpace!: String = SRGBColorSpace): Color {
        // 尝试匹配 rgb/rgba/hsl/hsla 函数格式
        if (let Some(m) <- matchFunctionStyle(style)) {
            let (name, components) = m
            if (name == "rgb" || name == "rgba") {
                if (let Some(c) <- matchRgbComponents(components)) {
                    return this.setRGB(min(255.0, c[0]) / 255.0, min(255.0, c[1]) / 255.0, min(255.0, c[2]) / 255.0, colorSpace: colorSpace)
                }
                if (let Some(c) <- matchRgbPercentComponents(components)) {
                    return this.setRGB(min(100.0, c[0]) / 100.0, min(100.0, c[1]) / 100.0, min(100.0, c[2]) / 100.0, colorSpace: colorSpace)
                }
            } else if (name == "hsl" || name == "hsla") {
                if (let Some(c) <- matchHslComponents(components)) {
                    return this.setHSL(c[0] / 360.0, c[1] / 100.0, c[2] / 100.0, colorSpace: colorSpace)
                }
            }
        } else if (let Some(hex) <- matchHexStyle(style)) {
            let len = hex.size
            if (len == 3) {
                let runes = hex.toRuneArray()
                let rVal = parseHexDigit(runes[0])
                let gVal = parseHexDigit(runes[1])
                let bVal = parseHexDigit(runes[2])
                return this.setRGB(Float64(rVal) / 15.0, Float64(gVal) / 15.0, Float64(bVal) / 15.0, colorSpace: colorSpace)
            } else if (len == 6) {
                return this.setHex(parseHexString(hex), colorSpace: colorSpace)
            }
        } else if (style.size > 0) {
            return this.setColorName(style, colorSpace: colorSpace)
        }
        return this
    }

    /**
     * @brief[zh-cn] 从颜色名称设置颜色
     * @param[zh-cn] style 颜色名称
     * colorSpace 颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set color from color name
     * @param[en] style Color name
     * colorSpace Color space
     * @return[en] This instance
     */
    public func setColorName(style: String, colorSpace!: String = SRGBColorSpace): Color {
        let lowerStyle = style.toAsciiLower()
        let hex = Color.NAMES.get(lowerStyle)
        match (hex) {
            case Some(h) => this.setHex(h, colorSpace: colorSpace)
            case None => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 克隆颜色
     * @return[zh-cn] 新的颜色实例
     *
     * @brief[en] Clone the color
     * @return[en] New color instance
     */
    public func clone(): Color { return Color(this.r, this.g, this.b) }

    /**
     * @brief[zh-cn] 复制另一个颜色的值
     * @param[zh-cn] c 源颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another color
     * @param[en] c Source color
     * @return[en] This instance
     */
    public func copy(c: Color): Color { this.r = c.r; this.g = c.g; this.b = c.b; return this }

    /**
     * @brief[zh-cn] 复制颜色并从 sRGB 转换到线性空间
     * @param[zh-cn] color 源颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy color and convert from sRGB to linear space
     * @param[en] color Source color
     * @return[en] This instance
     */
    public func copySRGBToLinear(color: Color): Color {
        this.r = ColorManagement.sRGBToLinear(color.r)
        this.g = ColorManagement.sRGBToLinear(color.g)
        this.b = ColorManagement.sRGBToLinear(color.b)
        return this
    }

    /**
     * @brief[zh-cn] 复制颜色并从线性空间转换到 sRGB
     * @param[zh-cn] color 源颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy color and convert from linear space to sRGB
     * @param[en] color Source color
     * @return[en] This instance
     */
    public func copyLinearToSRGB(color: Color): Color {
        this.r = ColorManagement.linearToSRGB(color.r)
        this.g = ColorManagement.linearToSRGB(color.g)
        this.b = ColorManagement.linearToSRGB(color.b)
        return this
    }

    /**
     * @brief[zh-cn] 将当前颜色从 sRGB 转换到线性空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Convert current color from sRGB to linear space
     * @return[en] This instance
     */
    public func convertSRGBToLinear(): Color { this.copySRGBToLinear(this); return this }

    /**
     * @brief[zh-cn] 将当前颜色从线性空间转换到 sRGB
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Convert current color from linear space to sRGB
     * @return[en] This instance
     */
    public func convertLinearToSRGB(): Color { this.copyLinearToSRGB(this); return this }

    /**
     * @brief[zh-cn] 获取十六进制值
     * @param[zh-cn] colorSpace 颜色空间
     * @return[zh-cn] 十六进制颜色值
     *
     * @brief[en] Get hexadecimal value
     * @param[en] colorSpace Color space
     * @return[en] Hexadecimal color value
     */
    public func getHex(colorSpace!: String = SRGBColorSpace): UInt32 {
        let c = Color().copy(this)
        ColorManagement.workingToColorSpace(c, colorSpace)
        return (UInt32(round(clamp(c.r, 0.0, 1.0) * 255.0)) << 16) |
               (UInt32(round(clamp(c.g, 0.0, 1.0) * 255.0)) << 8) |
               UInt32(round(clamp(c.b, 0.0, 1.0) * 255.0))
    }

    /**
     * @brief[zh-cn] 获取十六进制字符串
     * @param[zh-cn] colorSpace 颜色空间
     * @return[zh-cn] 十六进制颜色字符串
     *
     * @brief[en] Get hexadecimal string
     * @param[en] colorSpace Color space
     * @return[en] Hexadecimal color string
     */
    public func getHexString(colorSpace!: String = SRGBColorSpace): String {
        let hex = this.getHex(colorSpace: colorSpace)
        let hexChars = "0123456789abcdef"
        let runes = Array<Rune>(6, { i =>
            let shift = (5 - i) * 4
            let idx = Int64((hex >> UInt32(shift)) & 0xFu32)
            Rune(Int32(hexChars[idx]))
        })
        return String(runes)
    }

    /**
     * @brief[zh-cn] 获取 HSL 值并存储到目标对象
     * @param[zh-cn] target 目标 HSL 对象
     * colorSpace 颜色空间
     * @return[zh-cn] 目标 HSL 对象
     *
     * @brief[en] Get HSL values and store into target object
     * @param[en] target Target HSL object
     * colorSpace Color space
     * @return[en] Target HSL object
     */
    public func getHSL(target: HSL, colorSpace!: String = ColorManagement.workingColorSpace): HSL {
        let c = Color().copy(this)
        ColorManagement.workingToColorSpace(c, colorSpace)
        let r = c.r; let g = c.g; let b = c.b
        let maxVal = max(max(r, g), b)
        let minVal = min(min(r, g), b)
        var hue: Float64 = 0.0
        var saturation: Float64 = 0.0
        let lightness = (minVal + maxVal) / 2.0
        if (maxVal != minVal) {
            let delta = maxVal - minVal
            saturation = if (lightness <= 0.5) { delta / (maxVal + minVal) } else { delta / (2.0 - maxVal - minVal) }
            if (maxVal == r) {
                hue = (g - b) / delta + (if (g < b) { 6.0 } else { 0.0 })
            } else if (maxVal == g) {
                hue = (b - r) / delta + 2.0
            } else {
                hue = (r - g) / delta + 4.0
            }
            hue /= 6.0
        }
        target.h = hue; target.s = saturation; target.l = lightness
        return target
    }

    /**
     * @brief[zh-cn] 获取 HSL 值（便捷方法，返回元组）
     * @return[zh-cn] HSL 元组 (h, s, l)
     *
     * @brief[en] Get HSL values (convenience method, returns tuple)
     * @return[en] HSL tuple (h, s, l)
     */
    public func getHSL(): (Float64, Float64, Float64) {
        let maxVal = max(max(this.r, this.g), this.b)
        let minVal = min(min(this.r, this.g), this.b)
        var h = 0.0
        let l = (maxVal + minVal) / 2.0
        if (maxVal == minVal) { return (0.0, 0.0, l) }
        let d = maxVal - minVal
        let s = if (l <= 0.5) { d / (maxVal + minVal) } else { d / (2.0 - maxVal - minVal) }
        if (maxVal == this.r) { h = (this.g - this.b) / d + (if (this.g < this.b) { 6.0 } else { 0.0 }) }
        else if (maxVal == this.g) { h = (this.b - this.r) / d + 2.0 }
        else { h = (this.r - this.g) / d + 4.0 }
        h /= 6.0
        return (h, s, l)
    }

    /**
     * @brief[zh-cn] 获取 RGB 值并存储到目标颜色
     * @param[zh-cn] target 目标颜色对象
     * colorSpace 颜色空间
     * @return[zh-cn] 目标颜色对象
     *
     * @brief[en] Get RGB values and store into target color
     * @param[en] target Target color object
     * colorSpace Color space
     * @return[en] Target color object
     */
    public func getRGB(target: Color, colorSpace!: String = ColorManagement.workingColorSpace): Color {
        let c = Color().copy(this)
        ColorManagement.workingToColorSpace(c, colorSpace)
        target.r = c.r; target.g = c.g; target.b = c.b
        return target
    }

    /**
     * @brief[zh-cn] 获取 CSS 样式字符串
     * @param[zh-cn] colorSpace 颜色空间
     * @return[zh-cn] CSS 样式字符串
     *
     * @brief[en] Get CSS style string
     * @param[en] colorSpace Color space
     * @return[en] CSS style string
     */
    public func getStyle(colorSpace!: String = SRGBColorSpace): String {
        let c = Color().copy(this)
        ColorManagement.workingToColorSpace(c, colorSpace)
        if (colorSpace != SRGBColorSpace && colorSpace != LinearSRGBColorSpace && colorSpace != "") {
            return "color(" + colorSpace.toString() + " " + c.r.format(".3") + " " + c.g.format(".3") + " " + c.b.format(".3") + ")"
        }
        return "rgb(" + Int64(round(c.r * 255.0)).toString() + "," +
               Int64(round(c.g * 255.0)).toString() + "," +
               Int64(round(c.b * 255.0)).toString() + ")"
    }

    /**
     * @brief[zh-cn] 偏移 HSL 值
     * @param[zh-cn] h 色相偏移量
     * s 饱和度偏移量
     * l 亮度偏移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Offset HSL values
     * @param[en] h Hue offset
     * s Saturation offset
     * l Lightness offset
     * @return[en] This instance
     */
    public func offsetHSL(h: Float64, s: Float64, l: Float64): Color {
        let hsl = HSL()
        this.getHSL(hsl)
        return this.setHSL(hsl.h + h, hsl.s + s, hsl.l + l)
    }

    /**
     * @brief[zh-cn] 添加另一个颜色的 RGB 值
     * @param[zh-cn] c 要添加的颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Add RGB values of another color
     * @param[en] c Color to add
     * @return[en] This instance
     */
    public func add(c: Color): Color { this.r += c.r; this.g += c.g; this.b += c.b; return this }

    /**
     * @brief[zh-cn] 添加两个颜色的 RGB 值并存储结果
     * @param[zh-cn] a 第一个颜色
     * b 第二个颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Add RGB values of two colors and store the result
     * @param[en] a First color
     * b Second color
     * @return[en] This instance
     */
    public func addColors(a: Color, b: Color): Color { this.r = a.r + b.r; this.g = a.g + b.g; this.b = a.b + b.b; return this }

    /**
     * @brief[zh-cn] 给 RGB 分量添加标量值
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Add a scalar value to RGB components
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func addScalar(s: Float64): Color { this.r += s; this.g += s; this.b += s; return this }

    /**
     * @brief[zh-cn] 减去另一个颜色的 RGB 值（结果不低于 0）
     * @param[zh-cn] c 要减去的颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Subtract RGB values of another color (result not less than 0)
     * @param[en] c Color to subtract
     * @return[en] This instance
     */
    public func sub(c: Color): Color {
        this.r = max(0.0, this.r - c.r); this.g = max(0.0, this.g - c.g); this.b = max(0.0, this.b - c.b); return this
    }

    /**
     * @brief[zh-cn] 乘以另一个颜色的 RGB 值
     * @param[zh-cn] c 要乘以的颜色
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiply by RGB values of another color
     * @param[en] c Color to multiply by
     * @return[en] This instance
     */
    public func multiply(c: Color): Color { this.r *= c.r; this.g *= c.g; this.b *= c.b; return this }

    /**
     * @brief[zh-cn] 乘以标量值
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiply by a scalar value
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func multiplyScalar(s: Float64): Color { this.r *= s; this.g *= s; this.b *= s; return this }

    /**
     * @brief[zh-cn] 线性插值 RGB 值
     * @param[zh-cn] c 目标颜色
     * alpha 插值因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Linearly interpolate RGB values
     * @param[en] c Target color
     * alpha Interpolation factor
     * @return[en] This instance
     */
    public func lerp(c: Color, alpha: Float64): Color {
        this.r += (c.r - this.r) * alpha; this.g += (c.g - this.g) * alpha; this.b += (c.b - this.b) * alpha; return this
    }

    /**
     * @brief[zh-cn] 在两个颜色之间线性插值并存储结果
     * @param[zh-cn] c1 第一个颜色
     * c2 第二个颜色
     * alpha 插值因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Linearly interpolate between two colors and store result
     * @param[en] c1 First color
     * c2 Second color
     * alpha Interpolation factor
     * @return[en] This instance
     */
    public func lerpColors(c1: Color, c2: Color, alpha: Float64): Color {
        this.r = c1.r + (c2.r - c1.r) * alpha; this.g = c1.g + (c2.g - c1.g) * alpha; this.b = c1.b + (c2.b - c1.b) * alpha; return this
    }

    /**
     * @brief[zh-cn] 在 HSL 空间线性插值
     * @param[zh-cn] c 目标颜色
     * alpha 插值因子
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Linearly interpolate in HSL space
     * @param[en] c Target color
     * alpha Interpolation factor
     * @return[en] This instance
     */
    public func lerpHSL(c: Color, alpha: Float64): Color {
        let hslA = HSL(); let hslB = HSL()
        this.getHSL(hslA); c.getHSL(hslB)
        return this.setHSL(hslA.h + (hslB.h - hslA.h) * alpha, hslA.s + (hslB.s - hslA.s) * alpha, hslA.l + (hslB.l - hslA.l) * alpha)
    }

    /**
     * @brief[zh-cn] 从三维向量设置 RGB 分量
     * @param[zh-cn] v 三维向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set RGB components from a 3D vector
     * @param[en] v 3D vector
     * @return[en] This instance
     */
    public func setFromVector3(v: Vector3): Color { this.r = v.x; this.g = v.y; this.b = v.z; return this }

    /**
     * @brief[zh-cn] 应用 3x3 矩阵变换颜色
     * @param[zh-cn] m 3x3 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply 3x3 matrix transformation to color
     * @param[en] m 3x3 matrix
     * @return[en] This instance
     */
    public func applyMatrix3(m: Matrix3): Color {
        let r = this.r; let g = this.g; let b = this.b; let e = m.elements
        this.r = e[0] * r + e[3] * g + e[6] * b; this.g = e[1] * r + e[4] * g + e[7] * b; this.b = e[2] * r + e[5] * g + e[8] * b
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个颜色相等
     * @param[zh-cn] c 比较的颜色
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another color
     * @param[en] c Color to compare
     * @return[en] Whether equal
     */
    public func equals(c: Color): Bool { return this.r == c.r && this.g == c.g && this.b == c.b }

    /**
     * @brief[zh-cn] 从顶点属性读取 RGB 分量
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * index 顶点索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Read RGB components from vertex attribute (aligned with JS: Color.fromBufferAttribute)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * index Vertex index
     * @return[en] This instance
     */
    public func fromBufferAttribute(attribute: AttributeReader, index: Int64): Color {
        this.r = attribute.getX(index)
        this.g = attribute.getY(index)
        this.b = attribute.getZ(index)
        return this
    }

    /**
     * @brief[zh-cn] 从数组读取 RGB 分量
     * @param[zh-cn] array 源数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Read RGB components from array
     * @param[en] array Source array
     * offset Starting index, defaults to 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Color {
        this.r = array[offset]; this.g = array[offset + 1]; this.b = array[offset + 2]; return this
    }

    /**
     * @brief[zh-cn] 将 RGB 分量写入数组
     * @param[zh-cn] array 目标数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 包含 RGB 分量的数组
     *
     * @brief[en] Write RGB components to array
     * @param[en] array Target array
     * offset Starting index, defaults to 0
     * @return[en] Array containing RGB components
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        array[offset] = this.r; array[offset + 1] = this.g; array[offset + 2] = this.b; return array
    }

    /**
     * @brief[zh-cn] 从十六进制值复制颜色
     * @param[zh-cn] hex 十六进制颜色值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy color from hexadecimal value
     * @param[en] hex Hexadecimal color value
     * @return[en] This instance
     */
    public func copyHex(hex: UInt32): Color { return this.setHex(hex) }

    /**
     * @brief[zh-cn] 在颜色空间之间复制转换颜色
     * @param[zh-cn] srcColor 源颜色
     * srcColorSpace 源颜色空间
     * dstColorSpace 目标颜色空间
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy and convert color between color spaces
     * @param[en] srcColor Source color
     * srcColorSpace Source color space
     * dstColorSpace Destination color space
     * @return[en] This instance
     */
    public func copyColorSpace(srcColor: Color, srcColorSpace: String, dstColorSpace: String): Color {
        this.copy(srcColor); ColorManagement.convert(this, srcColorSpace, dstColorSpace); return this
    }

    public operator func +(c: Color): Color { return Color(this.r + c.r, this.g + c.g, this.b + c.b) }
    public operator func *(s: Float64): Color { return Color(this.r * s, this.g * s, this.b * s) }
}

/**
 * @brief[zh-cn] HSL 颜色值容器，用于 getHSL 方法的 target 参数
 *
 * @brief[en] HSL color value container, used as target parameter for getHSL method
 */
public class HSL {
    /**
     * @brief[zh-cn] 色相
     *
     * @brief[en] Hue
     */
    public var h: Float64 = 0.0
    /**
     * @brief[zh-cn] 饱和度
     *
     * @brief[en] Saturation
     */
    public var s: Float64 = 0.0
    /**
     * @brief[zh-cn] 亮度
     *
     * @brief[en] Lightness
     */
    public var l: Float64 = 0.0
    public init() {}
    public init(h: Float64, s: Float64, l: Float64) { this.h = h; this.s = s; this.l = l }
}

/**
 * @brief[zh-cn] HSL 转 RGB 辅助函数
 *
 * @brief[en] HSL to RGB helper function
 */
internal func hue2rgb(p: Float64, q: Float64, t: Float64): Float64 {
    var tt = t
    if (tt < 0.0) { tt += 1.0 }
    if (tt > 1.0) { tt -= 1.0 }
    if (tt < 1.0 / 6.0) { return p + (q - p) * 6.0 * tt }
    if (tt < 1.0 / 2.0) { return q }
    if (tt < 2.0 / 3.0) { return p + (q - p) * 6.0 * (2.0 / 3.0 - tt) }
    return p
}

/**
 * @brief[zh-cn] 匹配 CSS 函数格式（如 rgb(...)、hsl(...)）
 *
 * @brief[en] Match CSS function format (e.g., rgb(...), hsl(...))
 */
internal func matchFunctionStyle(style: String): Option<(String, String)> {
    let openIdx = style.indexOf('(')
    if (openIdx.isNone()) { return None }
    let openPos = openIdx.getOrThrow()
    let name = style[0..openPos].trimAscii().toAsciiLower()
    let closeIdx = style.indexOf(')', openPos + 1)
    if (closeIdx.isNone()) { return None }
    let closePos = closeIdx.getOrThrow()
    let components = style[(openPos + 1)..closePos]
    return Some((name, components))
}

/**
 * @brief[zh-cn] 匹配 rgb(r,g,b) 格式的参数
 *
 * @brief[en] Match rgb(r,g,b) format parameters
 */
internal func matchRgbComponents(components: String): Option<Array<Float64>> {
    let parts = components.split(",")
    if (parts.size < 3) { return None }
    var result = Array<Float64>(3, { _ => 0.0 })
    for (i in 0..3) {
        let trimmed = parts[i].trimAscii()
        if (let Some(v) <- parseNumber(trimmed)) {
            result[i] = v
        } else {
            return None
        }
    }
    return Some(result)
}

/**
 * @brief[zh-cn] 匹配 rgb(r%,g%,b%) 格式的参数
 *
 * @brief[en] Match rgb(r%,g%,b%) format parameters
 */
internal func matchRgbPercentComponents(components: String): Option<Array<Float64>> {
    let parts = components.split(",")
    if (parts.size < 3) { return None }
    var result = Array<Float64>(3, { _ => 0.0 })
    for (i in 0..3) {
        let trimmed = parts[i].trimAscii()
        if (trimmed.endsWith("%")) {
            let numStr = trimmed[0..(trimmed.size - 1)]
            if (let Some(v) <- parseNumber(numStr)) {
                result[i] = v
            } else {
                return None
            }
        } else {
            return None
        }
    }
    return Some(result)
}

/**
 * @brief[zh-cn] 匹配 hsl(h,s%,l%) 格式的参数
 *
 * @brief[en] Match hsl(h,s%,l%) format parameters
 */
internal func matchHslComponents(components: String): Option<Array<Float64>> {
    let parts = components.split(",")
    if (parts.size < 3) { return None }
    var result = Array<Float64>(3, { _ => 0.0 })
    if (let Some(v) <- parseNumber(parts[0].trimAscii())) {
        result[0] = v
    } else {
        return None
    }
    for (i in 1..3) {
        let trimmed = parts[i].trimAscii()
        if (trimmed.endsWith("%")) {
            let numStr = trimmed[0..(trimmed.size - 1)]
            if (let Some(v) <- parseNumber(numStr)) {
                result[i] = v
            } else {
                return None
            }
        } else {
            return None
        }
    }
    return Some(result)
}

/**
 * @brief[zh-cn] 匹配十六进制颜色格式（#xxx 或 #xxxxxx）
 *
 * @brief[en] Match hexadecimal color format (#xxx or #xxxxxx)
 */
internal func matchHexStyle(style: String): Option<String> {
    let trimmed = style.trimAscii()
    if (!trimmed.startsWith("#")) { return None }
    let hex = trimmed[1..].toAsciiLower()
    // 验证是否为有效的十六进制字符串
    for (c in hex.toRuneArray()) {
        if (!((c >= r'0' && c <= r'9') || (c >= r'a' && c <= r'f'))) {
            return None
        }
    }
    let len = hex.size
    if (len == 3 || len == 6) {
        return Some(hex)
    }
    return None
}

/**
 * @brief[zh-cn] 解析字符串为数字
 *
 * @brief[en] Parse string to number
 */
internal func parseNumber(s: String): Option<Float64> {
    try {
        return Some(Float64.parse(s.trimAscii()))
    } catch (_: Exception) {
        return None
    }
}

/**
 * @brief[zh-cn] 解析单个十六进制字符为数值
 *
 * @brief[en] Parse a single hex character to numeric value
 */
internal func parseHexDigit(c: Rune): UInt32 {
    if (c >= r'0' && c <= r'9') {
        return UInt32(c) - UInt32(r'0')
    } else if (c >= r'a' && c <= r'f') {
        return UInt32(c) - UInt32(r'a') + 10
    } else if (c >= r'A' && c <= r'F') {
        return UInt32(c) - UInt32(r'A') + 10
    }
    return 0u32
}

/**
 * @brief[zh-cn] 解析十六进制字符串为 UInt32
 *
 * @brief[en] Parse hexadecimal string to UInt32
 */
internal func parseHexString(hex: String): UInt32 {
    var result: UInt32 = 0u32
    for (c in hex.toRuneArray()) {
        result = (result << 4) | parseHexDigit(c)
    }
    return result
}

/**
 * @brief[zh-cn] 初始化 CSS 颜色名称映射表
 *
 * @brief[en] Initialize CSS color name mapping table
 */
internal func initColorNames(map: HashMap<String, UInt32>): Unit {
    map.add("aliceblue", 0xF0F8FFu32)
    map.add("antiquewhite", 0xFAEBD7u32)
    map.add("aqua", 0x00FFFFu32)
    map.add("aquamarine", 0x7FFFD4u32)
    map.add("azure", 0xF0FFFFu32)
    map.add("beige", 0xF5F5DCu32)
    map.add("bisque", 0xFFE4C4u32)
    map.add("black", 0x000000u32)
    map.add("blanchedalmond", 0xFFEBCDu32)
    map.add("blue", 0x0000FFu32)
    map.add("blueviolet", 0x8A2BE2u32)
    map.add("brown", 0xA52A2Au32)
    map.add("burlywood", 0xDEB887u32)
    map.add("cadetblue", 0x5F9EA0u32)
    map.add("chartreuse", 0x7FFF00u32)
    map.add("chocolate", 0xD2691Eu32)
    map.add("coral", 0xFF7F50u32)
    map.add("cornflowerblue", 0x6495EDu32)
    map.add("cornsilk", 0xFFF8DCu32)
    map.add("crimson", 0xDC143Cu32)
    map.add("cyan", 0x00FFFFu32)
    map.add("darkblue", 0x00008Bu32)
    map.add("darkcyan", 0x008B8Bu32)
    map.add("darkgoldenrod", 0xB8860Bu32)
    map.add("darkgray", 0xA9A9A9u32)
    map.add("darkgreen", 0x006400u32)
    map.add("darkgrey", 0xA9A9A9u32)
    map.add("darkkhaki", 0xBDB76Bu32)
    map.add("darkmagenta", 0x8B008Bu32)
    map.add("darkolivegreen", 0x556B2Fu32)
    map.add("darkorange", 0xFF8C00u32)
    map.add("darkorchid", 0x9932CCu32)
    map.add("darkred", 0x8B0000u32)
    map.add("darksalmon", 0xE9967Au32)
    map.add("darkseagreen", 0x8FBC8Fu32)
    map.add("darkslateblue", 0x483D8Bu32)
    map.add("darkslategray", 0x2F4F4Fu32)
    map.add("darkslategrey", 0x2F4F4Fu32)
    map.add("darkturquoise", 0x00CED1u32)
    map.add("darkviolet", 0x9400D3u32)
    map.add("deeppink", 0xFF1493u32)
    map.add("deepskyblue", 0x00BFFFu32)
    map.add("dimgray", 0x696969u32)
    map.add("dimgrey", 0x696969u32)
    map.add("dodgerblue", 0x1E90FFu32)
    map.add("firebrick", 0xB22222u32)
    map.add("floralwhite", 0xFFFAF0u32)
    map.add("forestgreen", 0x228B22u32)
    map.add("fuchsia", 0xFF00FFu32)
    map.add("gainsboro", 0xDCDCDCu32)
    map.add("ghostwhite", 0xF8F8FFu32)
    map.add("gold", 0xFFD700u32)
    map.add("goldenrod", 0xDAA520u32)
    map.add("gray", 0x808080u32)
    map.add("green", 0x008000u32)
    map.add("greenyellow", 0xADFF2Fu32)
    map.add("grey", 0x808080u32)
    map.add("honeydew", 0xF0FFF0u32)
    map.add("hotpink", 0xFF69B4u32)
    map.add("indianred", 0xCD5C5Cu32)
    map.add("indigo", 0x4B0082u32)
    map.add("ivory", 0xFFFFF0u32)
    map.add("khaki", 0xF0E68Cu32)
    map.add("lavender", 0xE6E6FAu32)
    map.add("lavenderblush", 0xFFF0F5u32)
    map.add("lawngreen", 0x7CFC00u32)
    map.add("lemonchiffon", 0xFFFACDu32)
    map.add("lightblue", 0xADD8E6u32)
    map.add("lightcoral", 0xF08080u32)
    map.add("lightcyan", 0xE0FFFFu32)
    map.add("lightgoldenrodyellow", 0xFAFAD2u32)
    map.add("lightgray", 0xD3D3D3u32)
    map.add("lightgreen", 0x90EE90u32)
    map.add("lightgrey", 0xD3D3D3u32)
    map.add("lightpink", 0xFFB6C1u32)
    map.add("lightsalmon", 0xFFA07Au32)
    map.add("lightseagreen", 0x20B2AAu32)
    map.add("lightskyblue", 0x87CEFAu32)
    map.add("lightslategray", 0x778899u32)
    map.add("lightslategrey", 0x778899u32)
    map.add("lightsteelblue", 0xB0C4DEu32)
    map.add("lightyellow", 0xFFFFE0u32)
    map.add("lime", 0x00FF00u32)
    map.add("limegreen", 0x32CD32u32)
    map.add("linen", 0xFAF0E6u32)
    map.add("magenta", 0xFF00FFu32)
    map.add("maroon", 0x800000u32)
    map.add("mediumaquamarine", 0x66CDAAu32)
    map.add("mediumblue", 0x0000CDu32)
    map.add("mediumorchid", 0xBA55D3u32)
    map.add("mediumpurple", 0x9370DBu32)
    map.add("mediumseagreen", 0x3CB371u32)
    map.add("mediumslateblue", 0x7B68EEu32)
    map.add("mediumspringgreen", 0x00FA9Au32)
    map.add("mediumturquoise", 0x48D1CCu32)
    map.add("mediumvioletred", 0xC71585u32)
    map.add("midnightblue", 0x191970u32)
    map.add("mintcream", 0xF5FFFAu32)
    map.add("mistyrose", 0xFFE4E1u32)
    map.add("moccasin", 0xFFE4B5u32)
    map.add("navajowhite", 0xFFDEADu32)
    map.add("navy", 0x000080u32)
    map.add("oldlace", 0xFDF5E6u32)
    map.add("olive", 0x808000u32)
    map.add("olivedrab", 0x6B8E23u32)
    map.add("orange", 0xFFA500u32)
    map.add("orangered", 0xFF4500u32)
    map.add("orchid", 0xDA70D6u32)
    map.add("palegoldenrod", 0xEEE8AAu32)
    map.add("palegreen", 0x98FB98u32)
    map.add("paleturquoise", 0xAFEEEEu32)
    map.add("palevioletred", 0xDB7093u32)
    map.add("papayawhip", 0xFFEFD5u32)
    map.add("peachpuff", 0xFFDAB9u32)
    map.add("peru", 0xCD853Fu32)
    map.add("pink", 0xFFC0CBu32)
    map.add("plum", 0xDDA0DDu32)
    map.add("powderblue", 0xB0E0E6u32)
    map.add("purple", 0x800080u32)
    map.add("rebeccapurple", 0x663399u32)
    map.add("red", 0xFF0000u32)
    map.add("rosybrown", 0xBC8F8Fu32)
    map.add("royalblue", 0x4169E1u32)
    map.add("saddlebrown", 0x8B4513u32)
    map.add("salmon", 0xFA8072u32)
    map.add("sandybrown", 0xF4A460u32)
    map.add("seagreen", 0x2E8B57u32)
    map.add("seashell", 0xFFF5EEu32)
    map.add("sienna", 0xA0522Du32)
    map.add("silver", 0xC0C0C0u32)
    map.add("skyblue", 0x87CEEBu32)
    map.add("slateblue", 0x6A5ACDu32)
    map.add("slategray", 0x708090u32)
    map.add("slategrey", 0x708090u32)
    map.add("snow", 0xFFFAFAu32)
    map.add("springgreen", 0x00FF7Fu32)
    map.add("steelblue", 0x4682B4u32)
    map.add("tan", 0xD2B48Cu32)
    map.add("teal", 0x008080u32)
    map.add("thistle", 0xD8BFD8u32)
    map.add("tomato", 0xFF6347u32)
    map.add("turquoise", 0x40E0D0u32)
    map.add("violet", 0xEE82EEu32)
    map.add("wheat", 0xF5DEB3u32)
    map.add("white", 0xFFFFFFu32)
    map.add("whitesmoke", 0xF5F5F5u32)
    map.add("yellow", 0xFFFF00u32)
    map.add("yellowgreen", 0x9ACD32u32)
}
