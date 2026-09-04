/**
 * @file[zh-cn] 数据工具函数
 * @brief[zh-cn] 提供半精度浮点数转换功能
 * @explain[zh-cn] 
 * 对应 Three.js DataUtils.js。参考：Fast Half Float Conversions
 * http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf
 *
 * @file[en] Data Utility Functions
 * @brief[en] Provides half-precision float conversion functions
 * @explain[en] 
 * Corresponds to Three.js DataUtils.js. Reference: Fast Half Float Conversions
 * http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf
 */
package three.rendering.geometry

import std.math.*
import three.utils.log.Logger
import three.utils.memory.AutoFreePtr

/**
 * @param[zh-cn] val 输入浮点数
 * @return[zh-cn] 半精度浮点数的 16 位无符号整数表示
 *
 * 将单精度/双精度浮点数转换为半精度浮点数（FP16）
 *
 * 半精度浮点数使用 16 位存储，范围约为 [-65504, 65504]，
 * 精度约为 3 位十进制数字。
 *
 * @param[en] val Input floating-point number
 * @return[en] 16-bit unsigned integer representation of the half-precision float
 *
 * Convert a single/double-precision floating-point number to half-precision float (FP16)
 *
 * Half-precision floats use 16-bit storage, range approximately [-65504, 65504],
 * with approximately 3 decimal digits of precision.
 */
public func toHalfFloat(`val`: Float64): UInt16 {
    if (`val`.isNaN()) { return 0x7FFFu16 }
    if (`val` == Float64.Inf) { return 0x7C00u16 }
    if (`val` == -Float64.Inf) { return 0xFC00u16 }
    let absVal = abs(`val`)
    if (absVal > 65504.0) {
        Logger.warn(["DataUtils.toHalfFloat()", "Value out of range."])
        return if (`val` > 0.0) { 0x7C00u16 } else { 0xFC00u16 }
    }
    if (absVal < 0.00006103515625) { return if (`val` > 0.0) { 0x0000u16 } else { 0x8000u16 } }

    // 使用位运算提取浮点数的 IEEE 754 表示
    // Float64 转为 Float32（半精度使用 32 位浮点数的位模式）
    let f32 = Float32(`val`)
    // 通过内存操作读取 Float32 的位模式为 UInt32
    let bits = unsafe {
        let holder = AutoFreePtr<Float32>(LibC.malloc<Float32>())
        holder.get().write(f32)
        let result = CPointer<UInt32>(holder.get()).read()
        holder.dispose()
        result
    }
    let sign = (bits >> 16) & 0x8000u32
    let exponent = ((bits >> 23) & 0xFFu32) - 112u32
    let mantissa = bits & 0x007FFFFFu32
    let result = sign | (exponent << 10) | (mantissa >> 13)
    return UInt16(result)
}

/**
 * @param[zh-cn] val 半精度浮点数的 16 位无符号整数表示
 * @return[zh-cn] 转换后的双精度浮点数
 *
 * 将半精度浮点数（FP16）转换为双精度浮点数
 *
 * @param[en] val 16-bit unsigned integer representation of a half-precision float
 * @return[en] Converted double-precision floating-point number
 *
 * Convert a half-precision float (FP16) to a double-precision floating-point number
 */
public func fromHalfFloat(`val`: UInt16): Float64 {
    let s = (UInt32(`val`) >> 15) & 0x00000001u32
    let e = (UInt32(`val`) >> 10) & 0x0000001Fu32
    let m = UInt32(`val`) & 0x000003FFu32
    var result: UInt32
    if (e == 0u32) {
        if (m == 0u32) {
            result = s << 31
        } else {
            var e2 = 113u32
            var m2 = m
            while ((m2 & 0x0400u32) == 0u32) { m2 <<= 1; e2 -= 1u32 }
            result = (s << 31) | (e2 << 23) | ((m2 & 0x03FFu32) << 13)
        }
    } else if (e == 31u32) {
        result = (s << 31) | 0x7F800000u32 | (m << 13)
    } else {
        result = (s << 31) | ((e + 112u32) << 23) | (m << 13)
    }
    // 通过内存操作将 UInt32 位模式转为 Float32
    let f32 = unsafe {
        let holder = AutoFreePtr<UInt32>(LibC.malloc<UInt32>())
        holder.get().write(result)
        let result_f32 = CPointer<Float32>(holder.get()).read()
        holder.dispose()
        result_f32
    }
    return Float64(f32)
}

/**
 * 数据工具类，提供半精度浮点数转换的静态方法
 *
 * 此类是 toHalfFloat 和 fromHalfFloat 函数的面向对象封装，
 * 与 Three.js 的 DataUtils 类接口保持一致。
 */
public class DataUtils {
    /**
     * @param[zh-cn] val 输入浮点数
     * @return[zh-cn] 半精度浮点数的 16 位无符号整数表示
     *
     * 将单精度/双精度浮点数转换为半精度浮点数（FP16）
     *
     * @param[en] val Input floating-point number
     * @return[en] 16-bit unsigned integer representation of the half-precision float
     *
     * Convert a single/double-precision floating-point number to half-precision float (FP16)
     */
    public static func toHalfFloat(`val`: Float64): UInt16 {
        return toHalfFloat(`val`)
    }

    /**
     * @param[zh-cn] val 半精度浮点数的 16 位无符号整数表示
     * @return[zh-cn] 转换后的双精度浮点数
     *
     * 将半精度浮点数（FP16）转换为双精度浮点数
     *
     * @param[en] val 16-bit unsigned integer representation of a half-precision float
     * @return[en] Converted double-precision floating-point number
     *
     * Convert a half-precision float (FP16) to a double-precision floating-point number
     */
    public static func fromHalfFloat(`val`: UInt16): Float64 {
        return fromHalfFloat(`val`)
    }
}
