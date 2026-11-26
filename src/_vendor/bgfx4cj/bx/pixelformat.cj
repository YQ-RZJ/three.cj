/**
 * @file bx 像素格式转换
 * @brief bx 库的像素格式转换函数
 * @explain 本文件包含纯仓颉实现的像素格式转换函数，用于 bgfx/bimg 的纹理像素格式转换。
 *         包括 Unorm/Snorm 转换、半精度浮点转换、以及多种像素格式的 pack/unpack 函数。
 * @note 支持的格式：A8/R8/RG8/RGB8/RGBA8/BGRA8/R16/RG16/RGBA16/R32F/RGBA32F/
 *       RGB9E5F/B5G6R5/R5G6B5/RGBA4/BGRA4/RGB5A1/BGR5A1/RGB10A2/RG11B10F。
 */
protected package three._vendor.bgfx4cj.bx

import std.math.*

// =============================================================================
// Encoding type enum
// =============================================================================

/**
 * @brief 像素编码类型枚举
 * @explain 定义像素通道数据的编码方式，用于 pack/unpack 函数中的类型选择。
 */
public enum EncodingType {
    /** @brief 无符号归一化整数（[0, 1] 映射到 [0, 2ⁿ-1]） */
    | Unorm
    /** @brief 有符号整数 */
    | Int
    /** @brief 无符号整数 */
    | Uint
    /** @brief 浮点数 */
    | Float
    /** @brief 有符号归一化整数（[-1, 1] 映射到 [-(2ⁿ⁻¹-1), 2ⁿ⁻¹-1]） */
    | Snorm

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Unorm => 0
            case Int => 1
            case Uint => 2
            case Float => 3
            case Snorm => 4
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): EncodingType {
        match (v) {
            case 0 => Unorm
            case 1 => Int
            case 2 => Uint
            case 3 => Float
            case _ => Snorm
        }
    }
}

// =============================================================================
// Unorm / Snorm conversion
// =============================================================================

/** @brief 将 [0,1] 范围浮点数转换为无符号归一化整数 */
public func toUnorm(value: Float32, scale: Float32): UInt32 {
    return UInt32(round(clamp(value, 0.0f32, 1.0f32) * scale))
}

/** @brief 将无符号归一化整数转换为 [0,1] 范围浮点数 */
public func fromUnorm(value: UInt32, scale: Float32): Float32 {
    return Float32(value) / scale
}

/** @brief 将 [-1,1] 范围浮点数转换为有符号归一化整数 */
public func toSnorm(value: Float32, scale: Float32): Int32 {
    return Int32(round(clamp(value, -1.0f32, 1.0f32) * scale))
}

/** @brief 将有符号归一化整数转换为 [-1,1] 范围浮点数 */
public func fromSnorm(value: Int32, scale: Float32): Float32 {
    return max(-1.0f32, Float32(value) / scale)
}

// =============================================================================
// Half-float (16-bit) conversion
// =============================================================================

/** @brief 将 16 位半精度浮点数转换为 32 位单精度浮点数 */
public func halfToFloat(h: UInt16): Float32 {
    let hExp = UInt32(h) & 0x7c00u32
    let hMant = UInt32(h) & 0x03ffu32
    let hSign = UInt32(h) & 0x8000u32

    // Zero / denormal
    if (hExp == 0u32) {
        if (hMant == 0u32) {
            // Zero - preserve sign
            return bitsToFloat(hSign << 16)
        }
        // Denormal - normalize it
        var mant = hMant
        var exp = 0u32
        while ((mant & 0x0400u32) == 0u32) {
            mant <<= 1
            exp++
        }
        exp++ // account for hidden bit
        mant &= 0x03ffu32
        let fExp = (127u32 - 15u32 - exp + 1u32) << 23
        let fBits = (hSign << 16) | fExp | (mant << 13)
        return bitsToFloat(fBits)
    }

    // Inf / NaN
    if (hExp == 0x7c00u32) {
        if (hMant == 0u32) {
            // Infinity
            return bitsToFloat((hSign << 16) | 0x7f800000u32)
        }
        // NaN - preserve mantissa, ensure non-zero
        return bitsToFloat((hSign << 16) | 0x7f800000u32 | (hMant << 13))
    }

    // Normal number
    let fExp = (hExp + ((127u32 - 15u32) << 10)) << 13
    let fMant = hMant << 13
    return bitsToFloat((hSign << 16) | fExp | fMant)
}

/** @brief 将 32 位单精度浮点数转换为 16 位半精度浮点数 */
public func floatToHalf(f: Float32): UInt16 {
    let bits = floatToBits(f)
    let sign = (bits >> 16) & 0x8000u32
    let exp = (bits >> 23) & 0xffu32
    let mant = bits & 0x7fffffu32

    // Zero
    if (exp == 0u32 && mant == 0u32) {
        return UInt16(sign)
    }

    // Inf / NaN
    if (exp == 0xffu32) {
        if (mant == 0u32) {
            // Infinity
            return UInt16(sign | 0x7c00u32)
        }
        // NaN - preserve mantissa, ensure non-zero
        return UInt16(sign | 0x7c00u32 | (mant >> 13))
    }

    // Overflow -> Inf
    var newExp = Int32(exp) - 127 + 15
    if (newExp >= 0x1f) {
        return UInt16(sign | 0x7c00u32)
    }

    // Underflow -> zero or denormal
    if (newExp <= 0) {
        if (14 - newExp >= 24) {
            // Too small - return zero
            return UInt16(sign)
        }
        // Denormal
        let mantWithImplicit = mant | 0x800000u32
        let shift = UInt32(14 - newExp)
        let newMant = mantWithImplicit >> shift
        return UInt16(sign | (newMant & 0x7ffu32))
    }

    // Normal
    return UInt16(sign | (UInt32(newExp) << 10) | (mant >> 13))
}

// =============================================================================
// A8 (8-bit alpha)
// =============================================================================

/** @brief 打包 8 位 alpha 通道，从 src[3] 提取 */
public func packA8(src: Array<Float32>): UInt8 {
    return UInt8(toUnorm(src[3], 255.0f32) & 0xffu32)
}

/** @brief 解包 8 位 alpha 通道到 RGBA 数组 */
public func unpackA8(src: UInt8): Array<Float32> {
    let aa = fromUnorm(UInt32(src), 255.0f32)
    return [aa, aa, aa, aa]
}

// =============================================================================
// R8 (8-bit red)
// =============================================================================

/** @brief 打包 8 位红色通道（无符号归一化） */
public func packR8(src: Array<Float32>): UInt8 {
    return UInt8(toUnorm(src[0], 255.0f32) & 0xffu32)
}

/** @brief 解包 8 位红色通道（无符号归一化） */
public func unpackR8(src: UInt8): Array<Float32> {
    return [fromUnorm(UInt32(src), 255.0f32), 0.0f32, 0.0f32, 1.0f32]
}

// R8S (signed)
/** @brief 打包 8 位红色通道（有符号归一化） */
public func packR8S(src: Array<Float32>): Int8 {
    return Int8(toSnorm(src[0], 127.0f32) & 0xff)
}

/** @brief 解包 8 位红色通道（有符号归一化） */
public func unpackR8S(src: Int8): Array<Float32> {
    return [fromSnorm(Int32(src), 127.0f32), 0.0f32, 0.0f32, 1.0f32]
}

// R8I (signed integer)
/** @brief 打包 8 位红色通道（有符号整数） */
public func packR8I(src: Array<Float32>): Int8 {
    return Int8(Int32(src[0]) & 0xff)
}

/** @brief 解包 8 位红色通道（有符号整数） */
public func unpackR8I(src: Int8): Array<Float32> {
    return [Float32(Int32(src)), 0.0f32, 0.0f32, 1.0f32]
}

// R8U (unsigned integer)
/** @brief 打包 8 位红色通道（无符号整数） */
public func packR8U(src: Array<Float32>): UInt8 {
    return UInt8(UInt32(src[0]) & 0xffu32)
}

/** @brief 解包 8 位红色通道（无符号整数） */
public func unpackR8U(src: UInt8): Array<Float32> {
    return [Float32(UInt32(src)), 0.0f32, 0.0f32, 1.0f32]
}

// =============================================================================
// RG8 (2x 8-bit)
// =============================================================================

/** @brief 打包 8+8 位 RG（无符号归一化） */
public func packRg8(src: Array<Float32>): (UInt8, UInt8) {
    return (
        UInt8(toUnorm(src[0], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[1], 255.0f32) & 0xffu32)
    )
}

/** @brief 解包 8+8 位 RG（无符号归一化） */
public func unpackRg8(src0: UInt8, src1: UInt8): Array<Float32> {
    return [fromUnorm(UInt32(src0), 255.0f32), fromUnorm(UInt32(src1), 255.0f32), 0.0f32, 1.0f32]
}

/** @brief 打包 8+8 位 RG（有符号归一化） */
public func packRg8S(src: Array<Float32>): (Int8, Int8) {
    return (
        Int8(toSnorm(src[0], 127.0f32) & 0xff),
        Int8(toSnorm(src[1], 127.0f32) & 0xff)
    )
}

/** @brief 解包 8+8 位 RG（有符号归一化） */
public func unpackRg8S(src0: Int8, src1: Int8): Array<Float32> {
    return [fromSnorm(Int32(src0), 127.0f32), fromSnorm(Int32(src1), 127.0f32), 0.0f32, 1.0f32]
}

// =============================================================================
// RGB8 (3x 8-bit)
// =============================================================================

/** @brief 打包 8+8+8 位 RGB（无符号归一化） */
public func packRgb8(src: Array<Float32>): (UInt8, UInt8, UInt8) {
    return (
        UInt8(toUnorm(src[0], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[1], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[2], 255.0f32) & 0xffu32)
    )
}

/** @brief 解包 8+8+8 位 RGB（无符号归一化） */
public func unpackRgb8(src0: UInt8, src1: UInt8, src2: UInt8): Array<Float32> {
    return [
        fromUnorm(UInt32(src0), 255.0f32),
        fromUnorm(UInt32(src1), 255.0f32),
        fromUnorm(UInt32(src2), 255.0f32),
        1.0f32
    ]
}

/** @brief 打包 8+8+8 位 RGB（有符号归一化） */
public func packRgb8S(src: Array<Float32>): (Int8, Int8, Int8) {
    return (
        Int8(toSnorm(src[0], 127.0f32) & 0xff),
        Int8(toSnorm(src[1], 127.0f32) & 0xff),
        Int8(toSnorm(src[2], 127.0f32) & 0xff)
    )
}

/** @brief 解包 8+8+8 位 RGB（有符号归一化） */
public func unpackRgb8S(src0: Int8, src1: Int8, src2: Int8): Array<Float32> {
    return [
        fromSnorm(Int32(src0), 127.0f32),
        fromSnorm(Int32(src1), 127.0f32),
        fromSnorm(Int32(src2), 127.0f32),
        1.0f32
    ]
}

// =============================================================================
// RGBA8 / BGRA8 (4x 8-bit)
// =============================================================================

/** @brief 打包 8+8+8+8 位 RGBA（无符号归一化） */
public func packRgba8(src: Array<Float32>): (UInt8, UInt8, UInt8, UInt8) {
    return (
        UInt8(toUnorm(src[0], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[1], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[2], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[3], 255.0f32) & 0xffu32)
    )
}

/** @brief 解包 8+8+8+8 位 RGBA（无符号归一化） */
public func unpackRgba8(src0: UInt8, src1: UInt8, src2: UInt8, src3: UInt8): Array<Float32> {
    return [
        fromUnorm(UInt32(src0), 255.0f32),
        fromUnorm(UInt32(src1), 255.0f32),
        fromUnorm(UInt32(src2), 255.0f32),
        fromUnorm(UInt32(src3), 255.0f32)
    ]
}

/** @brief 打包 8+8+8+8 位 BGRA（无符号归一化，交换 R/B 通道） */
public func packBgra8(src: Array<Float32>): (UInt8, UInt8, UInt8, UInt8) {
    return (
        UInt8(toUnorm(src[2], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[1], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[0], 255.0f32) & 0xffu32),
        UInt8(toUnorm(src[3], 255.0f32) & 0xffu32)
    )
}

/** @brief 解包 8+8+8+8 位 BGRA（无符号归一化，交换 R/B 通道） */
public func unpackBgra8(src0: UInt8, src1: UInt8, src2: UInt8, src3: UInt8): Array<Float32> {
    return [
        fromUnorm(UInt32(src2), 255.0f32),
        fromUnorm(UInt32(src1), 255.0f32),
        fromUnorm(UInt32(src0), 255.0f32),
        fromUnorm(UInt32(src3), 255.0f32)
    ]
}

// =============================================================================
// R16 / R16S / R16F
// =============================================================================

/** @brief 打包 16 位红色通道（无符号归一化） */
public func packR16(src: Array<Float32>): UInt16 {
    return UInt16(toUnorm(src[0], 65535.0f32) & 0xffffu32)
}

/** @brief 解包 16 位红色通道（无符号归一化） */
public func unpackR16(src: UInt16): Array<Float32> {
    return [fromUnorm(UInt32(src), 65535.0f32), 0.0f32, 0.0f32, 1.0f32]
}

/** @brief 打包 16 位红色通道（有符号归一化） */
public func packR16S(src: Array<Float32>): Int16 {
    return Int16(toSnorm(src[0], 32767.0f32) & 0xffff)
}

/** @brief 解包 16 位红色通道（有符号归一化） */
public func unpackR16S(src: Int16): Array<Float32> {
    return [fromSnorm(Int32(src), 32767.0f32), 0.0f32, 0.0f32, 1.0f32]
}

/** @brief 打包 16 位红色通道（半精度浮点） */
public func packR16F(src: Array<Float32>): UInt16 {
    return floatToHalf(src[0])
}

/** @brief 解包 16 位红色通道（半精度浮点） */
public func unpackR16F(src: UInt16): Array<Float32> {
    return [halfToFloat(src), 0.0f32, 0.0f32, 1.0f32]
}

// =============================================================================
// RG16 / RG16F
// =============================================================================

/** @brief 打包 16+16 位 RG（无符号归一化） */
public func packRg16(src: Array<Float32>): (UInt16, UInt16) {
    return (
        UInt16(toUnorm(src[0], 65535.0f32) & 0xffffu32),
        UInt16(toUnorm(src[1], 65535.0f32) & 0xffffu32)
    )
}

/** @brief 解包 16+16 位 RG（无符号归一化） */
public func unpackRg16(src0: UInt16, src1: UInt16): Array<Float32> {
    return [fromUnorm(UInt32(src0), 65535.0f32), fromUnorm(UInt32(src1), 65535.0f32), 0.0f32, 1.0f32]
}

/** @brief 打包 16+16 位 RG（半精度浮点） */
public func packRg16F(src: Array<Float32>): (UInt16, UInt16) {
    return (floatToHalf(src[0]), floatToHalf(src[1]))
}

/** @brief 解包 16+16 位 RG（半精度浮点） */
public func unpackRg16F(src0: UInt16, src1: UInt16): Array<Float32> {
    return [halfToFloat(src0), halfToFloat(src1), 0.0f32, 1.0f32]
}

// =============================================================================
// RGBA16 / RGBA16F
// =============================================================================

/** @brief 打包 16+16+16+16 位 RGBA（无符号归一化） */
public func packRgba16(src: Array<Float32>): (UInt16, UInt16, UInt16, UInt16) {
    return (
        UInt16(toUnorm(src[0], 65535.0f32) & 0xffffu32),
        UInt16(toUnorm(src[1], 65535.0f32) & 0xffffu32),
        UInt16(toUnorm(src[2], 65535.0f32) & 0xffffu32),
        UInt16(toUnorm(src[3], 65535.0f32) & 0xffffu32)
    )
}

/** @brief 解包 16+16+16+16 位 RGBA（无符号归一化） */
public func unpackRgba16(src0: UInt16, src1: UInt16, src2: UInt16, src3: UInt16): Array<Float32> {
    return [
        fromUnorm(UInt32(src0), 65535.0f32),
        fromUnorm(UInt32(src1), 65535.0f32),
        fromUnorm(UInt32(src2), 65535.0f32),
        fromUnorm(UInt32(src3), 65535.0f32)
    ]
}

/** @brief 打包 16+16+16+16 位 RGBA（半精度浮点） */
public func packRgba16F(src: Array<Float32>): (UInt16, UInt16, UInt16, UInt16) {
    return (
        floatToHalf(src[0]),
        floatToHalf(src[1]),
        floatToHalf(src[2]),
        floatToHalf(src[3])
    )
}

/** @brief 解包 16+16+16+16 位 RGBA（半精度浮点） */
public func unpackRgba16F(src0: UInt16, src1: UInt16, src2: UInt16, src3: UInt16): Array<Float32> {
    return [halfToFloat(src0), halfToFloat(src1), halfToFloat(src2), halfToFloat(src3)]
}

// =============================================================================
// R32I / R32U / R32F
// =============================================================================

/** @brief 打包 32 位红色通道（有符号整数） */
public func packR32I(src: Array<Float32>): Int32 {
    return Int32(src[0])
}

/** @brief 解包 32 位红色通道（有符号整数） */
public func unpackR32I(src: Int32): Array<Float32> {
    return [Float32(src), 0.0f32, 0.0f32, 1.0f32]
}

/** @brief 打包 32 位红色通道（无符号整数） */
public func packR32U(src: Array<Float32>): UInt32 {
    return UInt32(src[0])
}

/** @brief 解包 32 位红色通道（无符号整数） */
public func unpackR32U(src: UInt32): Array<Float32> {
    return [Float32(src), 0.0f32, 0.0f32, 1.0f32]
}

/** @brief 打包 32 位红色通道（浮点） */
public func packR32F(src: Array<Float32>): Float32 {
    return src[0]
}

/** @brief 解包 32 位红色通道（浮点） */
public func unpackR32F(src: Float32): Array<Float32> {
    return [src, 0.0f32, 0.0f32, 1.0f32]
}

// =============================================================================
// RGBA32F
// =============================================================================

/** @brief 打包 32+32+32+32 位 RGBA（浮点） */
public func packRgba32F(src: Array<Float32>): (Float32, Float32, Float32, Float32) {
    return (src[0], src[1], src[2], src[3])
}

/** @brief 解包 32+32+32+32 位 RGBA（浮点） */
public func unpackRgba32F(src0: Float32, src1: Float32, src2: Float32, src3: Float32): Array<Float32> {
    return [src0, src1, src2, src3]
}

// =============================================================================
// RGB9E5F (shared exponent)
// =============================================================================

/** @brief 打包 RGB9E5F：9 位尾数 RGB 共享 5 位指数 */
public func packRgb9E5F(src: Array<Float32>): UInt32 {
    let r = max(src[0], 0.0f32)
    let g = max(src[1], 0.0f32)
    let b = max(src[2], 0.0f32)
    let maxRgb = max(r, max(g, b))
    if (maxRgb == 0.0f32) {
        return 0u32
    }
    var exp = Int32(log2(maxRgb)) + 1 - 15
    if (exp < 0) {
        exp = 0
    }
    if (exp > 31) {
        exp = 31
    }
    let scale = Float32(1u32 << exp)
    let r9 = UInt32(r * 512.0f32 / scale) & 0x1ffu32
    let g9 = UInt32(g * 512.0f32 / scale) & 0x1ffu32
    let b9 = UInt32(b * 512.0f32 / scale) & 0x1ffu32
    return r9 | (g9 << 9) | (b9 << 18) | (UInt32(exp) << 27)
}

/** @brief 解包 RGB9E5F：9 位尾数 RGB 共享 5 位指数 */
public func unpackRgb9E5F(packed: UInt32): Array<Float32> {
    let r9 = packed & 0x1ffu32
    let g9 = (packed >> 9) & 0x1ffu32
    let b9 = (packed >> 18) & 0x1ffu32
    let exp = (packed >> 27) & 0x1fu32
    let scale = Float32(1u32 << exp) / 512.0f32
    return [
        Float32(r9) * scale,
        Float32(g9) * scale,
        Float32(b9) * scale,
        1.0f32
    ]
}

// =============================================================================
// B5G6R5 / R5G6B5
// =============================================================================

/** @brief 打包 5+6+5 位 BGR */
public func packB5G6R5(src: Array<Float32>): UInt16 {
    let b = UInt32(toUnorm(src[2], 31.0f32) & 0x1fu32)
    let g = UInt32(toUnorm(src[1], 63.0f32) & 0x3fu32)
    let r = UInt32(toUnorm(src[0], 31.0f32) & 0x1fu32)
    return UInt16(b | (g << 5) | (r << 11))
}

/** @brief 解包 5+6+5 位 BGR */
public func unpackB5G6R5(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let b = (v & 0x1fu32)
    let g = ((v >> 5) & 0x3fu32)
    let r = ((v >> 11) & 0x1fu32)
    return [
        fromUnorm(r, 31.0f32),
        fromUnorm(g, 63.0f32),
        fromUnorm(b, 31.0f32),
        1.0f32
    ]
}

/** @brief 打包 5+6+5 位 RGB */
public func packR5G6B5(src: Array<Float32>): UInt16 {
    let r = UInt32(toUnorm(src[0], 31.0f32) & 0x1fu32)
    let g = UInt32(toUnorm(src[1], 63.0f32) & 0x3fu32)
    let b = UInt32(toUnorm(src[2], 31.0f32) & 0x1fu32)
    return UInt16(r | (g << 5) | (b << 11))
}

/** @brief 解包 5+6+5 位 RGB */
public func unpackR5G6B5(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let r = (v & 0x1fu32)
    let g = ((v >> 5) & 0x3fu32)
    let b = ((v >> 11) & 0x1fu32)
    return [
        fromUnorm(r, 31.0f32),
        fromUnorm(g, 63.0f32),
        fromUnorm(b, 31.0f32),
        1.0f32
    ]
}

// =============================================================================
// RGBA4 / BGRA4
// =============================================================================

/** @brief 打包 4+4+4+4 位 RGBA */
public func packRgba4(src: Array<Float32>): UInt16 {
    let r = UInt32(toUnorm(src[0], 15.0f32) & 0xfu32)
    let g = UInt32(toUnorm(src[1], 15.0f32) & 0xfu32)
    let b = UInt32(toUnorm(src[2], 15.0f32) & 0xfu32)
    let a = UInt32(toUnorm(src[3], 15.0f32) & 0xfu32)
    return UInt16(r | (g << 4) | (b << 8) | (a << 12))
}

/** @brief 解包 4+4+4+4 位 RGBA */
public func unpackRgba4(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let r = (v & 0xfu32)
    let g = ((v >> 4) & 0xfu32)
    let b = ((v >> 8) & 0xfu32)
    let a = ((v >> 12) & 0xfu32)
    return [
        fromUnorm(r, 15.0f32),
        fromUnorm(g, 15.0f32),
        fromUnorm(b, 15.0f32),
        fromUnorm(a, 15.0f32)
    ]
}

/** @brief 打包 4+4+4+4 位 BGRA */
public func packBgra4(src: Array<Float32>): UInt16 {
    let b = UInt32(toUnorm(src[2], 15.0f32) & 0xfu32)
    let g = UInt32(toUnorm(src[1], 15.0f32) & 0xfu32)
    let r = UInt32(toUnorm(src[0], 15.0f32) & 0xfu32)
    let a = UInt32(toUnorm(src[3], 15.0f32) & 0xfu32)
    return UInt16(b | (g << 4) | (r << 8) | (a << 12))
}

/** @brief 解包 4+4+4+4 位 BGRA */
public func unpackBgra4(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let b = (v & 0xfu32)
    let g = ((v >> 4) & 0xfu32)
    let r = ((v >> 8) & 0xfu32)
    let a = ((v >> 12) & 0xfu32)
    return [
        fromUnorm(r, 15.0f32),
        fromUnorm(g, 15.0f32),
        fromUnorm(b, 15.0f32),
        fromUnorm(a, 15.0f32)
    ]
}

// =============================================================================
// RGB5A1 / BGR5A1
// =============================================================================

/** @brief 打包 5+5+5+1 位 RGB */
public func packRgb5a1(src: Array<Float32>): UInt16 {
    let r = UInt32(toUnorm(src[0], 31.0f32) & 0x1fu32)
    let g = UInt32(toUnorm(src[1], 31.0f32) & 0x1fu32)
    let b = UInt32(toUnorm(src[2], 31.0f32) & 0x1fu32)
    let a = if (src[3] > 0.5f32) { 1u32 } else { 0u32 }
    return UInt16(r | (g << 5) | (b << 10) | (a << 15))
}

/** @brief 解包 5+5+5+1 位 RGB */
public func unpackRgb5a1(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let r = (v & 0x1fu32)
    let g = ((v >> 5) & 0x1fu32)
    let b = ((v >> 10) & 0x1fu32)
    let a = ((v >> 15) & 0x1u32)
    return [
        fromUnorm(r, 31.0f32),
        fromUnorm(g, 31.0f32),
        fromUnorm(b, 31.0f32),
        Float32(a)
    ]
}

/** @brief 打包 5+5+5+1 位 BGR */
public func packBgr5a1(src: Array<Float32>): UInt16 {
    let b = UInt32(toUnorm(src[2], 31.0f32) & 0x1fu32)
    let g = UInt32(toUnorm(src[1], 31.0f32) & 0x1fu32)
    let r = UInt32(toUnorm(src[0], 31.0f32) & 0x1fu32)
    let a = if (src[3] > 0.5f32) { 1u32 } else { 0u32 }
    return UInt16(b | (g << 5) | (r << 10) | (a << 15))
}

/** @brief 解包 5+5+5+1 位 BGR */
public func unpackBgr5a1(src: UInt16): Array<Float32> {
    let v = UInt32(src)
    let b = (v & 0x1fu32)
    let g = ((v >> 5) & 0x1fu32)
    let r = ((v >> 10) & 0x1fu32)
    let a = ((v >> 15) & 0x1u32)
    return [
        fromUnorm(r, 31.0f32),
        fromUnorm(g, 31.0f32),
        fromUnorm(b, 31.0f32),
        Float32(a)
    ]
}

// =============================================================================
// RGB10A2
// =============================================================================

/** @brief 打包 10+10+10+2 位 RGB */
public func packRgb10A2(src: Array<Float32>): UInt32 {
    let r = toUnorm(src[0], 1023.0f32) & 0x3ffu32
    let g = toUnorm(src[1], 1023.0f32) & 0x3ffu32
    let b = toUnorm(src[2], 1023.0f32) & 0x3ffu32
    let a = toUnorm(src[3], 3.0f32) & 0x3u32
    return r | (g << 10) | (b << 20) | (a << 30)
}

/** @brief 解包 10+10+10+2 位 RGB */
public func unpackRgb10A2(src: UInt32): Array<Float32> {
    let r = (src & 0x3ffu32)
    let g = ((src >> 10) & 0x3ffu32)
    let b = ((src >> 20) & 0x3ffu32)
    let a = ((src >> 30) & 0x3u32)
    return [
        fromUnorm(r, 1023.0f32),
        fromUnorm(g, 1023.0f32),
        fromUnorm(b, 1023.0f32),
        fromUnorm(a, 3.0f32)
    ]
}

// =============================================================================
// RG11B10F (unsigned float packed)
// =============================================================================

/** @brief 打包 11+11+10 位 RG（无符号浮点） */
public func packRG11B10F(src: Array<Float32>): UInt32 {
    let r = UInt32(max(0.0f32, min(src[0], 65024.0f32)) * (32.0f32 / 64.0f32)) & 0x7ffu32
    let g = UInt32(max(0.0f32, min(src[1], 65024.0f32)) * (32.0f32 / 64.0f32)) & 0x7ffu32
    let b = UInt32(max(0.0f32, min(src[2], 65024.0f32)) * (32.0f32 / 512.0f32)) & 0x3ffu32
    return r | (g << 11) | (b << 22)
}

/** @brief 解包 11+11+10 位 RG（无符号浮点） */
public func unpackRG11B10F(src: UInt32): Array<Float32> {
    let r = (src & 0x7ffu32)
    let g = ((src >> 11) & 0x7ffu32)
    let b = ((src >> 22) & 0x3ffu32)
    return [
        Float32(r) * (64.0f32 / 32.0f32),
        Float32(g) * (64.0f32 / 32.0f32),
        Float32(b) * (512.0f32 / 32.0f32),
        1.0f32
    ]
}
