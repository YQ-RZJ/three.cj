/**
 * @file bx 数学常量
 * @brief bx 库的数学常量、浮点布局常量和程序退出码
 * @explain 本文件包含纯仓颉实现的 bx 库常量，包括圆周率、自然常数、
 *         半精度/单精度/双精度浮点数位布局常量。
 * @note 这些常量源于 bx 库的 header-only 内容，在纯仓颉中重新实现。
 */
protected package three._vendor.bgfx4cj.bx

// =============================================================================
// Program exit codes
// =============================================================================

/** @brief 程序正常退出码 */
public const BX_EXIT_SUCCESS: Int32 = 0
/** @brief 程序异常退出码 */
public const BX_EXIT_FAILURE: Int32 = 1

// =============================================================================
// Math constants
// =============================================================================

/** @brief 圆周率 π */
public const BX_PI: Float32 = 3.1415926535897932384626433832795f32

/** @brief 圆周率的两倍，即 τ（Tau） */
public const BX_PI2: Float32 = 6.2831853071795864769252867665590f32

/** @brief π 的倒数，1/π */
public const BX_INV_PI: Float32 = 1.0f32 / BX_PI

/** @brief 2π 的倒数，1/(2π) */
public const BX_INV_PI2: Float32 = 1.0f32 / BX_PI2

/** @brief 二分之π，π/2 */
public const BX_PI_HALF: Float32 = 1.5707963267948966192313216916398f32

/** @brief 四分之π，π/4 */
public const BX_PI_QUARTER: Float32 = 0.7853981633974483096156608458199f32

/** @brief 2 的平方根，√2 */
public const BX_SQRT2: Float32 = 1.4142135623730950488016887242097f32

/** @brief 自然对数 ln(10) */
public const BX_LOG_NAT_10: Float32 = 2.3025850929940456840179914546844f32

/** @brief 以 2 为底的 e 的对数，log₂(e) */
public const BX_INV_LOG_NAT_2: Float32 = 1.4426950408889634073599246810019f32

/** @brief 2 的自然对数，ln(2) */
public const BX_LOG_NAT_2: Float32 = 0.6931471805599453094172321214582f32

/** @brief 自然常数 e */
public const BX_E: Float32 = 2.7182818284590452353602874713527f32

/** @brief bx 数学使用的近零 epsilon 值 */
public const BX_NEAR_ZERO: Float32 = 1.0f32 / 268435456.0f32

// =============================================================================
// Half-precision floating-point bit layout
// =============================================================================

/** @brief 半精度浮点数符号位位数 */
public const BX_HALF_SIGN_NUM_BITS: UInt8 = 1
/** @brief 半精度浮点数符号位偏移 */
public const BX_HALF_SIGN_BIT_SHIFT: UInt8 = 15
/** @brief 半精度浮点数符号位掩码 */
public const BX_HALF_SIGN_MASK: UInt16 = 0x8000u16
/** @brief 半精度浮点数指数位位数 */
public const BX_HALF_EXPONENT_NUM_BITS: UInt8 = 5
/** @brief 半精度浮点数指数位偏移 */
public const BX_HALF_EXPONENT_BIT_SHIFT: UInt8 = 10
/** @brief 半精度浮点数指数位掩码 */
public const BX_HALF_EXPONENT_MASK: UInt16 = 0x7c00u16
/** @brief 半精度浮点数指数偏移量 */
public const BX_HALF_EXPONENT_BIAS: UInt32 = 15
/** @brief 半精度浮点数尾数位位数 */
public const BX_HALF_MANTISSA_NUM_BITS: UInt8 = 10
/** @brief 半精度浮点数尾数位偏移 */
public const BX_HALF_MANTISSA_BIT_SHIFT: UInt8 = 0
/** @brief 半精度浮点数尾数位掩码 */
public const BX_HALF_MANTISSA_MASK: UInt16 = 0x03ffu16

// =============================================================================
// Single-precision floating-point bit layout
// =============================================================================

/** @brief 单精度浮点数符号位位数 */
public const BX_FLOAT_SIGN_NUM_BITS: UInt8 = 1
/** @brief 单精度浮点数符号位偏移 */
public const BX_FLOAT_SIGN_BIT_SHIFT: UInt8 = 31
/** @brief 单精度浮点数符号位掩码 */
public const BX_FLOAT_SIGN_MASK: UInt32 = 0x80000000u32
/** @brief 单精度浮点数指数位位数 */
public const BX_FLOAT_EXPONENT_NUM_BITS: UInt8 = 8
/** @brief 单精度浮点数指数位偏移 */
public const BX_FLOAT_EXPONENT_BIT_SHIFT: UInt8 = 23
/** @brief 单精度浮点数指数位掩码 */
public const BX_FLOAT_EXPONENT_MASK: UInt32 = 0x7f800000u32
/** @brief 单精度浮点数指数偏移量 */
public const BX_FLOAT_EXPONENT_BIAS: UInt32 = 127
/** @brief 单精度浮点数尾数位位数 */
public const BX_FLOAT_MANTISSA_NUM_BITS: UInt8 = 23
/** @brief 单精度浮点数尾数位偏移 */
public const BX_FLOAT_MANTISSA_BIT_SHIFT: UInt8 = 0
/** @brief 单精度浮点数尾数位掩码 */
public const BX_FLOAT_MANTISSA_MASK: UInt32 = 0x007fffffu32

/** @brief 最小正规格化单精度浮点数 */
public const BX_FLOAT_SMALLEST: Float32 = 1.175494351e-38f32

/** @brief 最大可表示单精度浮点数 */
public const BX_FLOAT_LARGEST: Float32 = 3.40282347E38f32

/** @brief 单精度浮点无穷大（所有指数位为 1，尾数为 0） */
public const BX_FLOAT_INFINITY_BITS: UInt32 = 0x7f800000u32

/** @brief 单精度浮点 NaN（所有指数位为 1，尾数非零） */
public const BX_FLOAT_NAN_BITS: UInt32 = 0x7fc00000u32

// =============================================================================
// Double-precision floating-point bit layout
// =============================================================================

/** @brief 双精度浮点数符号位位数 */
public const BX_DOUBLE_SIGN_NUM_BITS: UInt8 = 1
/** @brief 双精度浮点数符号位偏移 */
public const BX_DOUBLE_SIGN_BIT_SHIFT: UInt8 = 63
/** @brief 双精度浮点数符号位掩码 */
public const BX_DOUBLE_SIGN_MASK: UInt64 = 0x8000000000000000u64
/** @brief 双精度浮点数指数位位数 */
public const BX_DOUBLE_EXPONENT_NUM_BITS: UInt8 = 11
/** @brief 双精度浮点数指数位偏移 */
public const BX_DOUBLE_EXPONENT_SHIFT: UInt8 = 52
/** @brief 双精度浮点数指数位掩码 */
public const BX_DOUBLE_EXPONENT_MASK: UInt64 = 0x7ff0000000000000u64
/** @brief 双精度浮点数指数偏移量 */
public const BX_DOUBLE_EXPONENT_BIAS: UInt32 = 1023
/** @brief 双精度浮点数尾数位位数 */
public const BX_DOUBLE_MANTISSA_NUM_BITS: UInt8 = 52
/** @brief 双精度浮点数尾数位偏移 */
public const BX_DOUBLE_MANTISSA_SHIFT: UInt8 = 0
/** @brief 双精度浮点数尾数位掩码 */
public const BX_DOUBLE_MANTISSA_MASK: UInt64 = 0x000fffffffffffffu64

/** @brief 最小正规格化双精度浮点数 */
public const BX_DOUBLE_SMALLEST: Float64 = 2.2250738585072014e-308f64

/** @brief 最大可表示双精度浮点数 */
public const BX_DOUBLE_LARGEST: Float64 = 1.7976931348623157E308f64

// =============================================================================
// INT32 / INT64 max masks (used by isNan/isFinite to clear sign bit)
// =============================================================================

/** @brief Int32 最大值掩码（清除符号位，用于 isNaN/isFinite 判断） */
public const INT32_MAX_MASK: UInt32 = 0x7fffffffu32
/** @brief Int64 最大值掩码（清除符号位，用于 isNaN/isFinite 判断） */
public const INT64_MAX_MASK: UInt64 = 0x7fffffffffffffffu64
