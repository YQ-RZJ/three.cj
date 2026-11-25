/**
 * @file bx 数学库
 * @brief bx 库的纯仓颉数学实现（向量、矩阵、四元数、变换）
 * @explain 本文件包含完整的 3D 图形数学库，包括 Vec3/Quaternion/Plane 类型、
 *         4x4 矩阵运算（平移/旋转/缩放/透视/正交/LookAt）、
 *         颜色空间转换（RGB↔HSV）、位运算工具等。
 * @note 基本标量数学（sin/cos/sqrt/abs/floor/ceil/round）委托给 std.math。
 *       所有矩阵为行主序存储，16 个连续 float。
 */
protected package three._vendor.bgfx4cj.bx

import std.math.*

// =============================================================================
// Enums
// =============================================================================

/** @brief 坐标系左右手习惯 */
public enum Handedness {
    /** @brief 左手 */
    | Left
    /** @brief 右手 */
    | Right

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Left => 0
            case Right => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Handedness {
        match (v) {
            case 0 => Left
            case _ => Right
        }
    }
}

/** @brief 近/远平面排序约定 */
public enum NearFar {
    | Default
    | Reverse

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Default => 0
            case Reverse => 1
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): NearFar {
        match (v) {
            case 0 => Default
            case _ => Reverse
        }
    }
}

// =============================================================================
// Scalar math: angle conversion
// =============================================================================

/** @brief 角度转弧度 */
public func toRad(deg: Float32): Float32 {
    return deg * BX_PI / 180.0f32
}

/** @brief 弧度转角度 */
public func toDeg(rad: Float32): Float32 {
    return rad * 180.0f32 / BX_PI
}

// =============================================================================
// Scalar math: floating-point classification
// =============================================================================

/** @brief 将 Float32 的位表示转换为 UInt32 */
public func floatToBits(v: Float32): UInt32 {
    if (v.isNaN()) {
        return BX_FLOAT_NAN_BITS
    }
    if (v.isInf()) {
        if (v > 0.0f32) {
            return BX_FLOAT_INFINITY_BITS
        }
        return BX_FLOAT_INFINITY_BITS | 0x80000000u32
    }
    if (v == 0.0f32) {
        if (signBit(v)) {
            return 0x80000000u32
        }
        return 0u32
    }
    // Use Float64 math to extract components, then rebuild Float32 bits.
    let bits64 = Float64(v)
    let neg = bits64 < 0.0
    let mag = if (neg) { -bits64 } else { bits64 }
    var exp = 0
    var m = mag
    while (m >= 2.0) {
        m = m / 2.0
        exp++
    }
    while (m < 1.0 && m > 0.0) {
        m = m * 2.0
        exp--
    }
    // m in [1.0, 2.0)
    let biasedExp = exp + 127
    if (biasedExp <= 0) {
        // Denormal - too small for normal representation
        return if (neg) { 0x80000000u32 } else { 0u32 }
    }
    if (biasedExp >= 0xff) {
        return (if (neg) { 0x80000000u32 } else { 0u32 }) | BX_FLOAT_INFINITY_BITS
    }
    let mantissa = UInt32((m - 1.0) * 8388608.0)
    return (if (neg) { 0x80000000u32 } else { 0u32 }) | (UInt32(biasedExp) << 23) | (mantissa & 0x7fffffu32)
}

/** @brief 将 UInt32 的位表示转换为 Float32 */
public func bitsToFloat(bits: UInt32): Float32 {
    let sign = (bits >> 31) & 0x1u32
    let exp = (bits >> 23) & 0xffu32
    let mantissa = bits & 0x7fffffu32
    if (exp == 0u32 && mantissa == 0u32) {
        return if (sign == 0u32) { 0.0f32 } else { -0.0f32 }
    }
    if (exp == 0xffu32) {
        if (mantissa == 0u32) {
            return if (sign == 0u32) { Float32.Inf } else { -Float32.Inf }
        }
        return Float32.NaN
    }
    // Normal (denormal treated as zero for simplicity)
    if (exp == 0u32) {
        return if (sign == 0u32) { 0.0f32 } else { -0.0f32 }
    }
    let v = Float32((1u32 << 23) | mantissa) / 8388608.0f32
    let scale = Float32(pow(2.0, Float64(Int32(exp) - 127)))
    let result = v * scale
    return if (sign == 0u32) { result } else { -result }
}

/** @brief 检查是否为 NaN */
public func isNan(f: Float32): Bool {
    return f.isNaN()
}

/** @brief 检查是否为 NaN */
public func isNan(f: Float64): Bool {
    return f.isNaN()
}

/** @brief 检查是否为有限数 */
public func isFinite(f: Float32): Bool {
    return !f.isNaN() && !f.isInf()
}

/** @brief 检查是否为有限数 */
public func isFinite(f: Float64): Bool {
    return !f.isNaN() && !f.isInf()
}

/** @brief 检查是否为无穷大 */
public func isInfinite(f: Float32): Bool {
    return f.isInf()
}

/** @brief 检查是否为无穷大 */
public func isInfinite(f: Float64): Bool {
    return f.isInf()
}

// =============================================================================
// Scalar math: basic operations
// =============================================================================

/** @brief 向下取整 */
public func floor(f: Float32): Float32 {
    return Float32(floor(Float64(f)))
}

/** @brief 向上取整 */
public func ceil(f: Float32): Float32 {
    return Float32(ceil(Float64(f)))
}

/** @brief 对向量各分量取整 */
public func round(f: Float32): Float32 {
    return Float32(round(Float64(f)))
}

/** @brief 截断取整 */
public func trunc(f: Float32): Float32 {
    return Float32(trunc(Float64(f)))
}

/** @brief 获取小数部分 */
public func fract(f: Float32): Float32 {
    return f - trunc(f)
}

/** @brief 线性插值 */
public func lerp(a: Float32, b: Float32, t: Float32): Float32 {
    return mad(t, b, nms(t, a, a))
}

/** @brief 逆线性插值 */
public func invLerp(a: Float32, b: Float32, value: Float32): Float32 {
    return (value - a) / (b - a)
}

/** @brief 获取符号（-1, 0, 1） */
public func sign(a: Float32): Float32 {
    let pos = if (0.0f32 < a) { 1 } else { 0 }
    let neg = if (0.0f32 > a) { 1 } else { 0 }
    return Float32(pos - neg)
}

/** @brief 获取符号（-1, 0, 1） */
public func signBit(a: Float32): Bool {
    if (-0.0f32 == a) {
        return 0.0f32 != a
    }
    return 0.0f32 > a
}

/** @brief 获取符号（-1, 0, 1） */
public func signBit(a: Float64): Bool {
    if (-0.0 == a) {
        return 0.0 != a
    }
    return 0.0 > a
}

/** @brief 拷贝符号位 */
public func copySign(value: Float32, sign: Float32): Float32 {
    if (signBit(value) != signBit(sign)) {
        return -value
    }
    return value
}

/** @brief 对向量各分量取绝对值 */
public func abs(a: Float32): Float32 {
    if (a < 0.0f32) {
        return -a
    }
    return a
}

/** @brief 平方 */
public func square(a: Float32): Float32 {
    return a * a
}

/** @brief 负乘减：-(a * b - c) → c - a * b */
public func nms(a: Float32, b: Float32, c: Float32): Float32 {
    return c - a * b
}

/** @brief 加法 */
public func add(a: Float32, b: Float32): Float32 {
    return a + b
}

/** @brief 减法 */
public func sub(a: Float32, b: Float32): Float32 {
    return a - b
}

/** @brief 乘法 */
public func mul(a: Float32, b: Float32): Float32 {
    return a * b
}

/** @brief 乘加：a * b + c */
public func mad(a: Float32, b: Float32, c: Float32): Float32 {
    return a * b + c
}

/** @brief 倒数 */
public func rcp(a: Float32): Float32 {
    return 1.0f32 / a
}

/** @brief 倒数 */
public func rcpSafe(a: Float32): Float32 {
    return rcp(copySign(max(BX_FLOAT_SMALLEST, abs(a)), a))
}

/** @brief 除法 */
public func div(a: Float32, b: Float32): Float32 {
    return a * rcp(b)
}

/** @brief 除法 */
public func divSafe(a: Float32, b: Float32): Float32 {
    return a * rcpSafe(b)
}

/** @brief 取模 */
public func mod(a: Float32, b: Float32): Float32 {
    return a - b * floor(div(a, b))
}

/** @brief 检查两个值在容差内是否相等 */
public func isEqual(a: Float32, b: Float32, epsilon: Float32): Bool {
    let lhs = abs(a - b)
    let rhs = epsilon * max(1.0f32, abs(a), abs(b))
    return lhs <= rhs
}

/** @brief 检查两个值在容差内是否相等 */
public func isEqual(a: Array<Float32>, b: Array<Float32>, num: UInt32, epsilon: Float32): Bool {
    var result = isEqual(a[0], b[0], epsilon)
    var ii = 1
    while (result && ii < Int64(num)) {
        result = isEqual(a[ii], b[ii], epsilon)
        ii++
    }
    return result
}

/** @brief 将值包裹到[0, wrap)范围 */
public func wrap(a: Float32, wrapValue: Float32): Float32 {
    let tmp0 = mod(a, wrapValue)
    if (tmp0 < 0.0f32) {
        return wrapValue + tmp0
    }
    return tmp0
}

/** @brief 阶跃函数 */
public func step(edge: Float32, a: Float32): Float32 {
    if (a < edge) {
        return 0.0f32
    }
    return 1.0f32
}

/** @brief 脉冲函数 */
public func pulse(a: Float32, start: Float32, end: Float32): Float32 {
    return step(a, start) - step(a, end)
}

/** @brief 平滑阶跃 */
public func smoothStep(a: Float32): Float32 {
    return square(a) * (3.0f32 - 2.0f32 * a)
}

/** @brief 逆平滑阶跃 */
public func invSmoothStep(a: Float32): Float32 {
    return 0.5f32 - sin(asin(1.0f32 - 2.0f32 * a) / 3.0f32)
}

/** @brief 偏置函数 */
public func bias(t: Float32, b: Float32): Float32 {
    return t / (((1.0f32 / b - 2.0f32) * (1.0f32 - t)) + 1.0f32)
}

/** @brief 增益函数 */
public func gain(t: Float32, g: Float32): Float32 {
    if (t < 0.5f32) {
        return bias(t * 2.0f32, g) * 0.5f32
    }
    return bias(t * 2.0f32 - 1.0f32, 1.0f32 - g) * 0.5f32 + 0.5f32
}

/** @brief 角度差 */
public func angleDiff(a: Float32, b: Float32): Float32 {
    let dist = wrap(b - a, BX_PI2)
    return wrap(dist * 2.0f32, BX_PI2) - dist
}

/** @brief 角度线性插值 */
public func angleLerp(a: Float32, b: Float32, t: Float32): Float32 {
    return a + angleDiff(a, b) * t
}

// =============================================================================
// Scalar math: trigonometric and power (delegate to std.math)
// =============================================================================

/** @brief 正弦 */
public func sin(a: Float32): Float32 {
    return Float32(sin(Float64(a)))
}

/** @brief 余弦 */
public func cos(a: Float32): Float32 {
    return Float32(cos(Float64(a)))
}

/** @brief 正弦 */
public func sinh(a: Float32): Float32 {
    return 0.5f32 * (exp(a) - exp(-a))
}

/** @brief 余弦 */
public func cosh(a: Float32): Float32 {
    return 0.5f32 * (exp(a) + exp(-a))
}

/** @brief 正切 */
public func tan(a: Float32): Float32 {
    return Float32(tan(Float64(a)))
}

/** @brief 正切 */
public func tanh(a: Float32): Float32 {
    let tmp0 = exp(2.0f32 * a)
    let tmp1 = tmp0 - 1.0f32
    let tmp2 = tmp0 + 1.0f32
    return tmp1 / tmp2
}

/** @brief 反正弦 */
public func asin(a: Float32): Float32 {
    return BX_PI_HALF - acos(a)
}

/** @brief 反余弦 */
public func acos(a: Float32): Float32 {
    return Float32(acos(Float64(a)))
}

/** @brief 反正切 */
public func atan(a: Float32): Float32 {
    return Float32(atan(Float64(a)))
}

/** @brief 反正切 */
public func atan2(y: Float32, x: Float32): Float32 {
    return Float32(atan2(Float64(y), Float64(x)))
}

/** @brief 平方根 */
public func sqrt(a: Float32): Float32 {
    if (a < 0.0f32) {
        return Float32.NaN
    }
    return Float32(sqrt(Float64(a)))
}

/** @brief 反平方根 */
public func rsqrt(a: Float32): Float32 {
    if (a < BX_FLOAT_SMALLEST) {
        return Float32.Inf
    }
    return 1.0f32 / sqrt(a)
}

/** @brief 幂运算 */
public func pow(a: Float32, b: Float32): Float32 {
    if (abs(b) < BX_FLOAT_SMALLEST) {
        return 1.0f32
    }
    if (abs(a) < BX_FLOAT_SMALLEST) {
        return 0.0f32
    }
    return copySign(exp(b * log(abs(a))), a)
}

/** @brief 指数函数 e^x */
public func exp(a: Float32): Float32 {
    return Float32(exp(Float64(a)))
}

/** @brief 指数函数 e^x */
public func exp2(a: Float32): Float32 {
    return pow(2.0f32, a)
}

/** @brief 自然对数 */
public func log(a: Float32): Float32 {
    return Float32(log(Float64(a)))
}

/** @brief 自然对数 */
public func log2(a: Float32): Float32 {
    return Float32(log2(Float64(a)))
}

// =============================================================================
// Scalar math: color space conversion
// =============================================================================

/** @brief Gamma 转线性空间 */
public func toLinear(a: Float32): Float32 {
    let lo = a / 12.92f32
    let hi = pow((a + 0.055f32) / 1.055f32, 2.4f32)
    let sel = if (a <= 0.04045f32) { 1.0f32 } else { 0.0f32 }
    return lerp(hi, lo, sel)
}

/** @brief 线性空间转 Gamma */
public func toGamma(a: Float32): Float32 {
    let lo = a * 12.92f32
    let hi = pow(abs(a), 1.0f32 / 2.4f32) * 1.055f32 - 0.055f32
    let sel = if (a <= 0.0031308f32) { 1.0f32 } else { 0.0f32 }
    return lerp(hi, lo, sel)
}

// =============================================================================
// Vec3
// =============================================================================

/** @brief 3 分量向量 */
public struct Vec3 {
    /** @brief X 分量 */
    public var x: Float32
    /** @brief Y 分量 */
    public var y: Float32
    /** @brief Z 分量 */
    public var z: Float32

    public init() {
        x = 0.0f32
        y = 0.0f32
        z = 0.0f32
    }

    public init(v: Float32) {
        x = v
        y = v
        z = v
    }

    public init(x: Float32, y: Float32, z: Float32) {
        this.x = x
        this.y = y
        this.z = z
    }
}

/** @brief 对向量各分量取整 */
public func round(a: Vec3): Vec3 {
    return Vec3(round(a.x), round(a.y), round(a.z))
}

/** @brief 对向量各分量取绝对值 */
public func abs(a: Vec3): Vec3 {
    return Vec3(abs(a.x), abs(a.y), abs(a.z))
}

/** @brief 向量取反 */
public func neg(a: Vec3): Vec3 {
    return Vec3(-a.x, -a.y, -a.z)
}

/** @brief 加法 */
public func add(a: Vec3, b: Vec3): Vec3 {
    return Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
}

/** @brief 加法 */
public func add(a: Vec3, b: Float32): Vec3 {
    return Vec3(a.x + b, a.y + b, a.z + b)
}

/** @brief 减法 */
public func sub(a: Vec3, b: Vec3): Vec3 {
    return Vec3(a.x - b.x, a.y - b.y, a.z - b.z)
}

/** @brief 减法 */
public func sub(a: Vec3, b: Float32): Vec3 {
    return Vec3(a.x - b, a.y - b, a.z - b)
}

/** @brief 乘法 */
public func mul(a: Vec3, b: Vec3): Vec3 {
    return Vec3(a.x * b.x, a.y * b.y, a.z * b.z)
}

/** @brief 乘法 */
public func mul(a: Vec3, b: Float32): Vec3 {
    return Vec3(a.x * b, a.y * b, a.z * b)
}

/** @brief 除法 */
public func div(a: Vec3, b: Vec3): Vec3 {
    return mul(a, rcp(b))
}

/** @brief 除法 */
public func divSafe(a: Vec3, b: Vec3): Vec3 {
    return mul(a, rcpSafe(b))
}

/** @brief 除法 */
public func div(a: Vec3, b: Float32): Vec3 {
    return mul(a, rcp(b))
}

/** @brief 除法 */
public func divSafe(a: Vec3, b: Float32): Vec3 {
    return mul(a, rcpSafe(b))
}

/** @brief 负乘减：-(a*b - c) */
public func nms(a: Vec3, b: Float32, c: Vec3): Vec3 {
    return sub(c, mul(a, b))
}

/** @brief 负乘减：-(a*b - c) */
public func nms(a: Vec3, b: Vec3, c: Vec3): Vec3 {
    return sub(c, mul(a, b))
}

/** @brief 乘加：a*b + c */
public func mad(a: Vec3, b: Float32, c: Vec3): Vec3 {
    return add(mul(a, b), c)
}

/** @brief 乘加：a*b + c */
public func mad(a: Vec3, b: Vec3, c: Vec3): Vec3 {
    return add(mul(a, b), c)
}

/** @brief 向量点积 */
public func dot(a: Vec3, b: Vec3): Float32 {
    return a.x * b.x + a.y * b.y + a.z * b.z
}

/** @brief 向量叉积 */
public func cross(a: Vec3, b: Vec3): Vec3 {
    return Vec3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
}

/** @brief 向量长度 */
public func length(a: Vec3): Float32 {
    return sqrt(dot(a, a))
}

/** @brief 两点间距离的平方 */
public func distanceSq(a: Vec3, b: Vec3): Float32 {
    let ba = sub(b, a)
    return dot(ba, ba)
}

/** @brief 两点间距离 */
public func distance(a: Vec3, b: Vec3): Float32 {
    return length(sub(b, a))
}

/** @brief 线性插值 */
public func lerp(a: Vec3, b: Vec3, t: Float32): Vec3 {
    return Vec3(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t))
}

/** @brief 线性插值 */
public func lerp(a: Vec3, b: Vec3, t: Vec3): Vec3 {
    return Vec3(lerp(a.x, b.x, t.x), lerp(a.y, b.y, t.y), lerp(a.z, b.z, t.z))
}

/** @brief 向量归一化 */
public func normalize(a: Vec3): Vec3 {
    let len = length(a)
    return divSafe(a, len)
}

/** @brief 取最小值 */
public func min(a: Vec3, b: Vec3): Vec3 {
    return Vec3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))
}

/** @brief 取最大值 */
public func max(a: Vec3, b: Vec3): Vec3 {
    return Vec3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))
}

/** @brief 倒数 */
public func rcp(a: Vec3): Vec3 {
    return Vec3(rcp(a.x), rcp(a.y), rcp(a.z))
}

/** @brief 倒数 */
public func rcpSafe(a: Vec3): Vec3 {
    return Vec3(rcpSafe(a.x), rcpSafe(a.y), rcpSafe(a.z))
}

/** @brief 检查两个值在容差内是否相等 */
public func isEqual(a: Vec3, b: Vec3, epsilon: Float32): Bool {
    return isEqual(a.x, b.x, epsilon) &&
        isEqual(a.y, b.y, epsilon) &&
        isEqual(a.z, b.z, epsilon)
}

/** @brief 从单位法线构建正交切线/副切线框架 */
public func calcTangentFrame(n: Vec3): (Vec3, Vec3) {
    let nx = n.x
    let ny = n.y
    let nz = n.z

    var t = Vec3()
    if (abs(nx) > abs(nz)) {
        let invLen = rcpSafe(sqrt(nx * nx + nz * nz))
        t = Vec3(-nz * invLen, 0.0f32, nx * invLen)
    } else {
        let invLen = rcpSafe(sqrt(ny * ny + nz * nz))
        t = Vec3(0.0f32, nz * invLen, -ny * invLen)
    }
    let b = cross(n, t)
    return (t, b)
}

/** @brief 从单位法线和角度构建旋转后的切线/副切线框架 */
public func calcTangentFrame(n: Vec3, angle: Float32): (Vec3, Vec3) {
    let (t0, b0) = calcTangentFrame(n)
    let sa = sin(angle)
    let ca = cos(angle)
    let t = Vec3(
        -sa * b0.x + ca * t0.x,
        -sa * b0.y + ca * t0.y,
        -sa * b0.z + ca * t0.z
    )
    let b = cross(n, t)
    return (t, b)
}

/** @brief 将经纬度（[0,1]范围）转换为方向向量 */
public func fromLatLong(u: Float32, v: Float32): Vec3 {
    let phi = u * BX_PI2
    let theta = v * BX_PI
    let st = sin(theta)
    let sp = sin(phi)
    let ct = cos(theta)
    let cp = cos(phi)
    return Vec3(-st * sp, ct, -st * cp)
}

/** @brief 将方向向量转换为经纬度（[0,1]范围） */
public func toLatLong(dir: Vec3): (Float32, Float32) {
    let phi = atan2(dir.x, dir.z)
    let theta = acos(dir.y)
    let u = (BX_PI + phi) / BX_PI2
    let v = theta * BX_INV_PI
    return (u, v)
}

// =============================================================================
// Plane
// =============================================================================

/** @brief 由法线和到原点距离定义的3D平面 */
public struct Plane {
    /** @brief 法线向量 */
    public var normal: Vec3
    /** @brief 到原点的距离 */
    public var dist: Float32

    public init() {
        normal = Vec3(0.0f32, 1.0f32, 0.0f32)
        dist = 0.0f32
    }

    public init(normal: Vec3, dist: Float32) {
        this.normal = normal
        this.dist = dist
    }
}

/** @brief 检查两个值在容差内是否相等 */
public func isEqual(a: Plane, b: Plane, epsilon: Float32): Bool {
    return isEqual(a.normal, b.normal, epsilon) &&
        isEqual(a.dist, b.dist, epsilon)
}

/** @brief 两点间距离 */
public func distance(plane: Plane, pos: Vec3): Float32 {
    return dot(plane.normal, pos) + plane.dist
}

/** @brief 计算通过三个点（逆时针）的平面 */
public func calcPlane(va: Vec3, vb: Vec3, vc: Vec3): Plane {
    let normal = calcNormal(va, vb, vc)
    return calcPlane(normal, va)
}

/** @brief 计算通过指定点且具有给定法线的平面 */
public func calcPlane(normal: Vec3, pos: Vec3): Plane {
    return Plane(normal, -dot(normal, pos))
}

/** @brief 计算三角形的单位法线 */
public func calcNormal(va: Vec3, vb: Vec3, vc: Vec3): Vec3 {
    let ba = sub(vb, va)
    let ca = sub(vc, va)
    let baxca = cross(ba, ca)
    return normalize(baxca)
}

// =============================================================================
// Quaternion
// =============================================================================

/** @brief 用于表示3D旋转的单位四元数 */
public struct Quaternion {
    /** @brief X 分量 */
    public var x: Float32
    /** @brief Y 分量 */
    public var y: Float32
    /** @brief Z 分量 */
    public var z: Float32
    /** @brief W 分量 */
    public var w: Float32

    public init() {
        x = 0.0f32
        y = 0.0f32
        z = 0.0f32
        w = 1.0f32
    }

    public init(x: Float32, y: Float32, z: Float32, w: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }
}

/** @brief 四元数取逆 */
public func invert(a: Quaternion): Quaternion {
    return Quaternion(-a.x, -a.y, -a.z, a.w)
}

/** @brief 乘法 */
public func mulXyz(a: Quaternion, b: Quaternion): Vec3 {
    return Vec3(
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w
    )
}

/** @brief 加法 */
public func add(a: Quaternion, b: Quaternion): Quaternion {
    return Quaternion(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
}

/** @brief 减法 */
public func sub(a: Quaternion, b: Quaternion): Quaternion {
    return Quaternion(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
}

/** @brief 乘法 */
public func mul(a: Quaternion, b: Float32): Quaternion {
    return Quaternion(a.x * b, a.y * b, a.z * b, a.w * b)
}

/** @brief 乘法 */
public func mul(a: Quaternion, b: Quaternion): Quaternion {
    return Quaternion(
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
        a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
    )
}

/** @brief 用四元数旋转向量 */
public func mul(v: Vec3, q: Quaternion): Vec3 {
    let tmp0 = invert(q)
    let qv = Quaternion(v.x, v.y, v.z, 0.0f32)
    let tmp1 = mul(tmp0, qv)
    return mulXyz(tmp1, q)
}

/** @brief 向量点积 */
public func dot(a: Quaternion, b: Quaternion): Float32 {
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
}

/** @brief 向量归一化 */
public func normalize(a: Quaternion): Quaternion {
    let norm = dot(a, a)
    if (0.0f32 < norm) {
        let invNorm = rsqrt(norm)
        return mul(a, invNorm)
    }
    return Quaternion(0.0f32, 0.0f32, 0.0f32, 1.0f32)
}

/** @brief 线性插值 */
public func lerp(a: Quaternion, b: Quaternion, t: Float32): Quaternion {
    let sa = 1.0f32 - t
    let adotb = dot(a, b)
    let sb = sign(adotb) * t
    let aa = mul(a, sa)
    let bb = mul(b, sb)
    let qq = add(aa, bb)
    return normalize(qq)
}

/** @brief 检查两个值在容差内是否相等 */
public func isEqual(a: Quaternion, b: Quaternion, epsilon: Float32): Bool {
    return isEqual(a.x, b.x, epsilon) &&
        isEqual(a.y, b.y, epsilon) &&
        isEqual(a.z, b.z, epsilon) &&
        isEqual(a.w, b.w, epsilon)
}

/** @brief 从欧拉角（弧度，按X-Y-Z顺序）构建四元数 */
public func fromEuler(euler: Vec3): Quaternion {
    let sx = sin(euler.x * 0.5f32)
    let cx = cos(euler.x * 0.5f32)
    let sy = sin(euler.y * 0.5f32)
    let cy = cos(euler.y * 0.5f32)
    let sz = sin(euler.z * 0.5f32)
    let cz = cos(euler.z * 0.5f32)
    return Quaternion(
        sx * cy * cz - cx * sy * sz,
        cx * sy * cz + sx * cy * sz,
        cx * cy * sz - sx * sy * cz,
        cx * cy * cz + sx * sy * sz
    )
}

/** @brief 将四元数转换为欧拉角（弧度） */
public func toEuler(a: Quaternion): Vec3 {
    let xx = a.x
    let yy = a.y
    let zz = a.z
    let ww = a.w
    let xsq = square(xx)
    let ysq = square(yy)
    let zsq = square(zz)
    return Vec3(
        atan2(2.0f32 * (xx * ww - yy * zz), 1.0f32 - 2.0f32 * (xsq + zsq)),
        atan2(2.0f32 * (yy * ww + xx * zz), 1.0f32 - 2.0f32 * (ysq + zsq)),
        asin(2.0f32 * (xx * yy + zz * ww))
    )
}

/** @brief 从四元数提取X轴 */
public func toXAxis(a: Quaternion): Vec3 {
    let ysq = square(a.y)
    let zsq = square(a.z)
    return Vec3(
        1.0f32 - 2.0f32 * ysq - 2.0f32 * zsq,
        2.0f32 * a.x * a.y + 2.0f32 * a.z * a.w,
        2.0f32 * a.x * a.z - 2.0f32 * a.y * a.w
    )
}

/** @brief 从四元数提取Y轴 */
public func toYAxis(a: Quaternion): Vec3 {
    let xsq = square(a.x)
    let zsq = square(a.z)
    return Vec3(
        2.0f32 * a.x * a.y - 2.0f32 * a.z * a.w,
        1.0f32 - 2.0f32 * xsq - 2.0f32 * zsq,
        2.0f32 * a.y * a.z + 2.0f32 * a.x * a.w
    )
}

/** @brief 从四元数提取Z轴 */
public func toZAxis(a: Quaternion): Vec3 {
    let xsq = square(a.x)
    let ysq = square(a.y)
    return Vec3(
        2.0f32 * a.x * a.z + 2.0f32 * a.y * a.w,
        2.0f32 * a.y * a.z - 2.0f32 * a.x * a.w,
        1.0f32 - 2.0f32 * xsq - 2.0f32 * ysq
    )
}

/** @brief 从轴和角度（弧度）构建四元数 */
public func fromAxisAngle(axis: Vec3, angle: Float32): Quaternion {
    let ha = angle * 0.5f32
    let sa = sin(ha)
    return Quaternion(axis.x * sa, axis.y * sa, axis.z * sa, cos(ha))
}

/** @brief 将四元数转换为轴和角度 */
public func toAxisAngle(a: Quaternion): (Vec3, Float32) {
    let ww = a.w
    let sa = sqrt(1.0f32 - square(ww))
    let angle = 2.0f32 * acos(ww)
    if (0.001f32 > sa) {
        return (Vec3(a.x, a.y, a.z), angle)
    }
    let invSa = rcpSafe(sa)
    return (Vec3(a.x * invSa, a.y * invSa, a.z * invSa), angle)
}

/** @brief 绕X轴旋转的四元数 */
public func rotateX(ax: Float32): Quaternion {
    let hx = ax * 0.5f32
    return Quaternion(sin(hx), 0.0f32, 0.0f32, cos(hx))
}

/** @brief 绕Y轴旋转的四元数 */
public func rotateY(ay: Float32): Quaternion {
    let hy = ay * 0.5f32
    return Quaternion(0.0f32, sin(hy), 0.0f32, cos(hy))
}

/** @brief 绕Z轴旋转的四元数 */
public func rotateZ(az: Float32): Quaternion {
    let hz = az * 0.5f32
    return Quaternion(0.0f32, 0.0f32, sin(hz), cos(hz))
}

// =============================================================================
// 4x4 matrix (row-major storage, 16 contiguous floats)
// =============================================================================

/** @brief 将结果设置为4x4单位矩阵 */
public func mtxIdentity(result: Array<Float32>): Unit {
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = 1.0f32
    result[5] = 1.0f32
    result[10] = 1.0f32
    result[15] = 1.0f32
}


/** @brief 将结果设置为平移矩阵 */
public func mtxTranslate(result: Array<Float32>, tx: Float32, ty: Float32, tz: Float32): Unit {
    mtxIdentity(result)
    result[12] = tx
    result[13] = ty
    result[14] = tz
}


/** @brief 将结果设置为缩放矩阵 */
public func mtxScale(result: Array<Float32>, sx: Float32, sy: Float32, sz: Float32): Unit {
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = sx
    result[5] = sy
    result[10] = sz
    result[15] = 1.0f32
}


/** @brief 设置4x4缩放矩阵 */
public func mtxScale(result: Array<Float32>, scale: Float32): Unit {
    mtxScale(result, scale, scale, scale)
}


/** @brief 从法线、缩放和位置构建矩阵 */
public func mtxFromNormal(
    result: Array<Float32>,
    normal: Vec3,
    scale: Float32,
    pos: Vec3
): Unit {
    let (tangent, bitangent) = calcTangentFrame(normal)
    storeVec3(result, 0, mul(bitangent, scale))
    storeVec3(result, 4, mul(normal, scale))
    storeVec3(result, 8, mul(tangent, scale))
    result[3] = 0.0f32
    result[7] = 0.0f32
    result[11] = 0.0f32
    result[12] = pos.x
    result[13] = pos.y
    result[14] = pos.z
    result[15] = 1.0f32
}

/** @brief 从法线、缩放、位置和旋转角度构建矩阵 */
public func mtxFromNormal(
    result: Array<Float32>,
    normal: Vec3,
    scale: Float32,
    pos: Vec3,
    angle: Float32
): Unit {
    let (tangent, bitangent) = calcTangentFrame(normal, angle)
    storeVec3(result, 0, mul(bitangent, scale))
    storeVec3(result, 4, mul(normal, scale))
    storeVec3(result, 8, mul(tangent, scale))
    result[3] = 0.0f32
    result[7] = 0.0f32
    result[11] = 0.0f32
    result[12] = pos.x
    result[13] = pos.y
    result[14] = pos.z
    result[15] = 1.0f32
}

/** @brief 从四元数构建旋转矩阵 */
public func mtxFromQuaternion(result: Array<Float32>, rotation: Quaternion): Unit {
    let qx = rotation.x
    let qy = rotation.y
    let qz = rotation.z
    let qw = rotation.w
    let x2 = qx + qx
    let y2 = qy + qy
    let z2 = qz + qz
    let x2x = x2 * qx
    let x2y = x2 * qy
    let x2z = x2 * qz
    let x2w = x2 * qw
    let y2y = y2 * qy
    let y2z = y2 * qz
    let y2w = y2 * qw
    let z2z = z2 * qz
    let z2w = z2 * qw
    result[0] = 1.0f32 - (y2y + z2z)
    result[1] = x2y - z2w
    result[2] = x2z + y2w
    result[3] = 0.0f32
    result[4] = x2y + z2w
    result[5] = 1.0f32 - (x2x + z2z)
    result[6] = y2z - x2w
    result[7] = 0.0f32
    result[8] = x2z - y2w
    result[9] = y2z + x2w
    result[10] = 1.0f32 - (x2x + y2y)
    result[11] = 0.0f32
    result[12] = 0.0f32
    result[13] = 0.0f32
    result[14] = 0.0f32
    result[15] = 1.0f32
}


/** @brief 从四元数和平移构建旋转+平移矩阵 */
public func mtxFromQuaternion(
    result: Array<Float32>,
    rotation: Quaternion,
    translation: Vec3
): Unit {
    mtxFromQuaternion(result, rotation)
    let t = mulXyz0(translation, result)
    storeVec3(result, 12, neg(t))
}

/** @brief 用4x4矩阵变换Vec3（假设W=1） */
public func mul(vec: Vec3, mat: Array<Float32>): Vec3 {
    return Vec3(
        vec.x * mat[0] + vec.y * mat[4] + vec.z * mat[8] + mat[12],
        vec.x * mat[1] + vec.y * mat[5] + vec.z * mat[9] + mat[13],
        vec.x * mat[2] + vec.y * mat[6] + vec.z * mat[10] + mat[14]
    )
}


/** @brief 用4x4矩阵变换Vec3（假设W=0） */
public func mulXyz0(vec: Vec3, mat: Array<Float32>): Vec3 {
    return Vec3(
        vec.x * mat[0] + vec.y * mat[4] + vec.z * mat[8],
        vec.x * mat[1] + vec.y * mat[5] + vec.z * mat[9],
        vec.x * mat[2] + vec.y * mat[6] + vec.z * mat[10]
    )
}


/** @brief 用4x4矩阵变换Vec3（带透视除法） */
public func mulH(vec: Vec3, mat: Array<Float32>): Vec3 {
    let xx = vec.x * mat[0] + vec.y * mat[4] + vec.z * mat[8] + mat[12]
    let yy = vec.x * mat[1] + vec.y * mat[5] + vec.z * mat[9] + mat[13]
    let zz = vec.x * mat[2] + vec.y * mat[6] + vec.z * mat[10] + mat[14]
    let ww = vec.x * mat[3] + vec.y * mat[7] + vec.z * mat[11] + mat[15]
    let invW = sign(ww) / ww
    return Vec3(xx * invW, yy * invW, zz * invW)
}


/** @brief 4维向量乘以4x4矩阵（行向量*矩阵） */
public func vec4MulMtx(result: Array<Float32>, vec: Array<Float32>, mat: Array<Float32>): Unit {
    result[0] = vec[0] * mat[0] + vec[1] * mat[4] + vec[2] * mat[8] + vec[3] * mat[12]
    result[1] = vec[0] * mat[1] + vec[1] * mat[5] + vec[2] * mat[9] + vec[3] * mat[13]
    result[2] = vec[0] * mat[2] + vec[1] * mat[6] + vec[2] * mat[10] + vec[3] * mat[14]
    result[3] = vec[0] * mat[3] + vec[1] * mat[7] + vec[2] * mat[11] + vec[3] * mat[15]
}


/** @brief 两个4x4矩阵相乘（行主序存储）：result = a * b */
public func mtxMul(result: Array<Float32>, a: Array<Float32>, b: Array<Float32>): Unit {
    var row = 0
    while (row < 4) {
        let rowOff = row * 4
        var col = 0
        while (col < 4) {
            result[rowOff + col] = a[rowOff] * b[col] +
                a[rowOff + 1] * b[4 + col] +
                a[rowOff + 2] * b[8 + col] +
                a[rowOff + 3] * b[12 + col]
            col++
        }
        row++
    }
}


/** @brief 转置4x4矩阵 */
public func mtxTranspose(result: Array<Float32>, a: Array<Float32>): Unit {
    result[0] = a[0]
    result[4] = a[1]
    result[8] = a[2]
    result[12] = a[3]
    result[1] = a[4]
    result[5] = a[5]
    result[9] = a[6]
    result[13] = a[7]
    result[2] = a[8]
    result[6] = a[9]
    result[10] = a[10]
    result[14] = a[11]
    result[3] = a[12]
    result[7] = a[13]
    result[11] = a[14]
    result[15] = a[15]
}


// =============================================================================
// Internal helpers
// =============================================================================

internal func storeVec3(arr: Array<Float32>, offset: Int64, v: Vec3): Unit {
    arr[offset] = v.x
    arr[offset + 1] = v.y
    arr[offset + 2] = v.z
}

// =============================================================================
// View and projection matrices
// =============================================================================

/** @brief 构建 LookAt 视图矩阵（行主序，16 floats） */
public func mtxLookAt(
    result: Array<Float32>,
    eye: Vec3,
    at: Vec3,
    up!: Vec3 = Vec3(0.0f32, 1.0f32, 0.0f32),
    handedness!: Handedness = Handedness.Left
): Unit {
    let view = normalize(
        match(handedness){ case Handedness.Right => {=> sub(eye, at) }(); case _ => {=> sub(at, eye) }() }
    )

    let uxv = cross(up, view)
    let right = if (dot(uxv, uxv) == 0.0f32) {
        Vec3(match(handedness){ case Handedness.Left => {=> -1.0f32 }(); case _ => {=> 1.0f32 }() }, 0.0f32, 0.0f32)
    } else {
        normalize(uxv)
    }
    let upR = cross(view, right)

    result[0] = right.x
    result[1] = upR.x
    result[2] = view.x
    result[3] = 0.0f32
    result[4] = right.y
    result[5] = upR.y
    result[6] = view.y
    result[7] = 0.0f32
    result[8] = right.z
    result[9] = upR.z
    result[10] = view.z
    result[11] = 0.0f32
    result[12] = -dot(right, eye)
    result[13] = -dot(upR, eye)
    result[14] = -dot(view, eye)
    result[15] = 1.0f32
}

/** @brief 从 FOV（垂直）、宽高比、近远平面构建透视投影矩阵 */
public func mtxProj(
    result: Array<Float32>,
    fovy: Float32,
    aspect: Float32,
    near: Float32,
    far: Float32,
    homogeneousNdc: Bool,
    handedness!: Handedness = Handedness.Left
): Unit {
    let height = 1.0f32 / tan(toRad(fovy) * 0.5f32)
    let width = height / aspect
    mtxProjXYWH(result, 0.0f32, 0.0f32, width, height, near, far, homogeneousNdc, handedness)
}

/** @brief 从四个 FOV 边界（上/下/左/右正切值）构建透视投影矩阵 */
public func mtxProj(
    result: Array<Float32>,
    fov: Array<Float32>,
    near: Float32,
    far: Float32,
    homogeneousNdc: Bool,
    handedness!: Handedness = Handedness.Left
): Unit {
    mtxProj(result, fov[0], fov[1], fov[2], fov[3], near, far, homogeneousNdc, handedness:handedness)
}

/** @brief 从显式边界构建透视投影矩阵 */
public func mtxProj(
    result: Array<Float32>,
    ut: Float32,
    dt: Float32,
    lt: Float32,
    rt: Float32,
    near: Float32,
    far: Float32,
    homogeneousNdc: Bool,
    handedness!: Handedness = Handedness.Left
): Unit {
    let invDiffRl = 1.0f32 / (rt - lt)
    let invDiffUd = 1.0f32 / (ut - dt)
    let width = 2.0f32 * near * invDiffRl
    let height = 2.0f32 * near * invDiffUd
    let xx = (rt + lt) * invDiffRl
    let yy = (ut + dt) * invDiffUd
    mtxProjXYWH(result, xx, yy, width, height, near, far, homogeneousNdc, handedness)
}

internal func mtxProjXYWH(
    result: Array<Float32>,
    x: Float32,
    y: Float32,
    width: Float32,
    height: Float32,
    near: Float32,
    far: Float32,
    homogeneousNdc: Bool,
    handedness: Handedness
): Unit {
    let diff = far - near
    let aa = if (homogeneousNdc) { (far + near) / diff } else { far / diff }
    let bb = if (homogeneousNdc) { (2.0f32 * far * near) / diff } else { near * aa }

    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = width
    result[5] = height
    result[8] = match(handedness){ case Handedness.Right => {=> x }(); case _ => {=> -x }() }
    result[9] = match(handedness){ case Handedness.Right => {=> y }(); case _ => {=> -y }() }
    result[10] = match(handedness){ case Handedness.Right => {=> -aa }(); case _ => {=> aa }() }
    result[11] = match(handedness){ case Handedness.Right => {=> -1.0f32 }(); case _ => {=> 1.0f32 }() }
    result[14] = -bb
}

/** @brief 构建无限远平面透视投影矩阵 */
public func mtxProjInf(
    result: Array<Float32>,
    fovy: Float32,
    aspect: Float32,
    near: Float32,
    homogeneousNdc: Bool,
    handedness!: Handedness = Handedness.Left,
    nearFar!: NearFar = NearFar.Default
): Unit {
    let height = 1.0f32 / tan(toRad(fovy) * 0.5f32)
    let width = height / aspect
    mtxProjInfXYWH(result, 0.0f32, 0.0f32, width, height, near, homogeneousNdc, handedness, nearFar)
}

internal func mtxProjInfXYWH(
    result: Array<Float32>,
    x: Float32,
    y: Float32,
    width: Float32,
    height: Float32,
    near: Float32,
    homogeneousNdc: Bool,
    handedness: Handedness,
    nearFar: NearFar
): Unit {
    let aa: Float32
    let bb: Float32
    if (match(nearFar){ case NearFar.Reverse => {=> true }(); case _ => {=> false }() }) {
        aa = if (homogeneousNdc) { -1.0f32 } else { 0.0f32 }
        bb = if (homogeneousNdc) { -2.0f32 * near } else { -near }
    } else {
        aa = 1.0f32
        bb = if (homogeneousNdc) { 2.0f32 * near } else { near }
    }
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = width
    result[5] = height
    result[8] = match(handedness){ case Handedness.Right => {=> x }(); case _ => {=> -x }() }
    result[9] = match(handedness){ case Handedness.Right => {=> y }(); case _ => {=> -y }() }
    result[10] = match(handedness){ case Handedness.Right => {=> -aa }(); case _ => {=> aa }() }
    result[11] = match(handedness){ case Handedness.Right => {=> -1.0f32 }(); case _ => {=> 1.0f32 }() }
    result[14] = -bb
}

/** @brief 构建正交投影矩阵 */
public func mtxOrtho(
    result: Array<Float32>,
    left: Float32,
    right: Float32,
    bottom: Float32,
    top: Float32,
    near: Float32,
    far: Float32,
    offset: Float32,
    homogeneousNdc: Bool,
    handedness!: Handedness = Handedness.Left
): Unit {
    let aa = 2.0f32 / (right - left)
    let bb = 2.0f32 / (top - bottom)
    let cc = (if (homogeneousNdc) { 2.0f32 } else { 1.0f32 }) / (far - near)
    let dd = (left + right) / (left - right)
    let ee = (top + bottom) / (bottom - top)
    let ff = if (homogeneousNdc) {
        (near + far) / (near - far)
    } else {
        near / (near - far)
    }
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = aa
    result[5] = bb
    result[10] = match(handedness){ case Handedness.Right => {=> -cc }(); case _ => {=> cc }() }
    result[12] = dd + offset
    result[13] = ee
    result[14] = ff
    result[15] = 1.0f32
}

// =============================================================================
// Rotation matrices
// =============================================================================

/** @brief 构建绕X轴的旋转矩阵 */
public func mtxRotateX(result: Array<Float32>, ax: Float32): Unit {
    let sx = sin(ax)
    let cx = cos(ax)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = 1.0f32
    result[5] = cx
    result[6] = -sx
    result[9] = sx
    result[10] = cx
    result[15] = 1.0f32
}

/** @brief 构建绕Y轴的旋转矩阵 */
public func mtxRotateY(result: Array<Float32>, ay: Float32): Unit {
    let sy = sin(ay)
    let cy = cos(ay)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = cy
    result[2] = sy
    result[5] = 1.0f32
    result[8] = -sy
    result[10] = cy
    result[15] = 1.0f32
}

/** @brief 构建绕Z轴的旋转矩阵 */
public func mtxRotateZ(result: Array<Float32>, az: Float32): Unit {
    let sz = sin(az)
    let cz = cos(az)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = cz
    result[1] = -sz
    result[4] = sz
    result[5] = cz
    result[10] = 1.0f32
    result[15] = 1.0f32
}

/** @brief 构建绕X轴的旋转矩阵 */
public func mtxRotateXY(result: Array<Float32>, ax: Float32, ay: Float32): Unit {
    let sx = sin(ax)
    let cx = cos(ax)
    let sy = sin(ay)
    let cy = cos(ay)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = cy
    result[2] = sy
    result[4] = sx * sy
    result[5] = cx
    result[6] = -sx * cy
    result[8] = -cx * sy
    result[9] = sx
    result[10] = cx * cy
    result[15] = 1.0f32
}

/** @brief 构建绕X轴的旋转矩阵 */
public func mtxRotateXYZ(result: Array<Float32>, ax: Float32, ay: Float32, az: Float32): Unit {
    let sx = sin(ax)
    let cx = cos(ax)
    let sy = sin(ay)
    let cy = cos(ay)
    let sz = sin(az)
    let cz = cos(az)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = cy * cz
    result[1] = -cy * sz
    result[2] = sy
    result[4] = cz * sx * sy + cx * sz
    result[5] = cx * cz - sx * sy * sz
    result[6] = -cy * sx
    result[8] = -cx * cz * sy + sx * sz
    result[9] = cz * sx + cx * sy * sz
    result[10] = cx * cy
    result[15] = 1.0f32
}

/** @brief 构建绕Z轴的旋转矩阵 */
public func mtxRotateZYX(result: Array<Float32>, ax: Float32, ay: Float32, az: Float32): Unit {
    let sx = sin(ax)
    let cx = cos(ax)
    let sy = sin(ay)
    let cy = cos(ay)
    let sz = sin(az)
    let cz = cos(az)
    var i = 0
    while (i < 16) {
        result[i] = 0.0f32
        i++
    }
    result[0] = cy * cz
    result[1] = cz * sx * sy - cx * sz
    result[2] = cx * cz * sy + sx * sz
    result[4] = cy * sz
    result[5] = cx * cz + sx * sy * sz
    result[6] = -cz * sx + cx * sy * sz
    result[8] = -sy
    result[9] = cy * sx
    result[10] = cx * cy
    result[15] = 1.0f32
}

/** @brief 构建缩放-旋转-平移组合矩阵（SRT） */
public func mtxSRT(
    result: Array<Float32>,
    sx: Float32, sy: Float32, sz: Float32,
    ax: Float32, ay: Float32, az: Float32,
    tx: Float32, ty: Float32, tz: Float32
): Unit {
    let sx_ = sin(ax)
    let cx = cos(ax)
    let sy_ = sin(ay)
    let cy = cos(ay)
    let sz_ = sin(az)
    let cz = cos(az)

    let sxsz = sx_ * sz_
    let cycz = cy * cz

    result[0] = sx * (cycz - sxsz * sy_)
    result[1] = sx * -cx * sz_
    result[2] = sx * (cz * sy_ + cy * sxsz)
    result[3] = 0.0f32

    result[4] = sy * (cz * sx_ * sy_ + cy * sz_)
    result[5] = sy * cx * cz
    result[6] = sy * (sy_ * sz_ - cycz * sx_)
    result[7] = 0.0f32

    result[8] = sz * -cx * sy_
    result[9] = sz * sx_
    result[10] = sz * cx * cy
    result[11] = 0.0f32

    result[12] = tx
    result[13] = ty
    result[14] = tz
    result[15] = 1.0f32
}

// =============================================================================
// Matrix inverse / cofactor
// =============================================================================

/** @brief 对 16-float 数组中左上角的 3x3 矩阵求逆 */
public func mtx3Inverse(result: Array<Float32>, a: Array<Float32>): Unit {
    let xx = a[0]
    let xy = a[1]
    let xz = a[2]
    let yx = a[3]
    let yy = a[4]
    let yz = a[5]
    let zx = a[6]
    let zy = a[7]
    let zz = a[8]

    var det = 0.0f32
    det += xx * (yy * zz - yz * zy)
    det -= xy * (yx * zz - yz * zx)
    det += xz * (yx * zy - yy * zx)

    let invDet = 1.0f32 / det

    result[0] = (yy * zz - yz * zy) * invDet
    result[1] = -(xy * zz - xz * zy) * invDet
    result[2] = (xy * yz - xz * yy) * invDet
    result[3] = -(yx * zz - yz * zx) * invDet
    result[4] = (xx * zz - xz * zx) * invDet
    result[5] = -(xx * yz - xz * yx) * invDet
    result[6] = (yx * zy - yy * zx) * invDet
    result[7] = -(xx * zy - xy * zx) * invDet
    result[8] = (xx * yy - xy * yx) * invDet
}

/** @brief 对 4x4 矩阵求逆（行主序，16 floats） */
public func mtxInverse(result: Array<Float32>, a: Array<Float32>): Unit {
    let xx = a[0]
    let xy = a[1]
    let xz = a[2]
    let xw = a[3]
    let yx = a[4]
    let yy = a[5]
    let yz = a[6]
    let yw = a[7]
    let zx = a[8]
    let zy = a[9]
    let zz = a[10]
    let zw = a[11]
    let wx = a[12]
    let wy = a[13]
    let wz = a[14]
    let ww = a[15]

    var det = 0.0f32
    det += xx * (yy * (zz * ww - zw * wz) - yz * (zy * ww - zw * wy) + yw * (zy * wz - zz * wy))
    det -= xy * (yx * (zz * ww - zw * wz) - yz * (zx * ww - zw * wx) + yw * (zx * wz - zz * wx))
    det += xz * (yx * (zy * ww - zw * wy) - yy * (zx * ww - zw * wx) + yw * (zx * wy - zy * wx))
    det -= xw * (yx * (zy * wz - zz * wy) - yy * (zx * wz - zz * wx) + yz * (zx * wy - zy * wx))

    let invDet = 1.0f32 / det

    result[0] = (yy * (zz * ww - wz * zw) - yz * (zy * ww - wy * zw) + yw * (zy * wz - wy * zz)) * invDet
    result[1] = -(xy * (zz * ww - wz * zw) - xz * (zy * ww - wy * zw) + xw * (zy * wz - wy * zz)) * invDet
    result[2] = (xy * (yz * ww - wz * yw) - xz * (yy * ww - wy * yw) + xw * (yy * wz - wy * yz)) * invDet
    result[3] = -(xy * (yz * zw - zz * yw) - xz * (yy * zw - zy * yw) + xw * (yy * zz - zy * yz)) * invDet

    result[4] = -(yx * (zz * ww - wz * zw) - yz * (zx * ww - wx * zw) + yw * (zx * wz - wx * zz)) * invDet
    result[5] = (xx * (zz * ww - wz * zw) - xz * (zx * ww - wx * zw) + xw * (zx * wz - wx * zz)) * invDet
    result[6] = -(xx * (yz * ww - wz * yw) - xz * (yx * ww - wx * yw) + xw * (yx * wz - wx * yz)) * invDet
    result[7] = (xx * (yz * zw - zz * yw) - xz * (yx * zw - zx * yw) + xw * (yx * zz - zx * yz)) * invDet

    result[8] = (yx * (zy * ww - wy * zw) - yy * (zx * ww - wx * zw) + yw * (zx * wy - wx * zy)) * invDet
    result[9] = -(xx * (zy * ww - wy * zw) - xy * (zx * ww - wx * zw) + xw * (zx * wy - wx * zy)) * invDet
    result[10] = (xx * (yy * ww - wy * yw) - xy * (yx * ww - wx * yw) + xw * (yx * wy - wx * yy)) * invDet
    result[11] = -(xx * (yy * zw - zy * yw) - xy * (yx * zw - zx * yw) + xw * (yx * zy - zx * yy)) * invDet

    result[12] = -(yx * (zy * wz - wy * zz) - yy * (zx * wz - wx * zz) + yz * (zx * wy - wx * zy)) * invDet
    result[13] = (xx * (zy * wz - wy * zz) - xy * (zx * wz - wx * zz) + xz * (zx * wy - wx * zy)) * invDet
    result[14] = -(xx * (yy * wz - wy * yz) - xy * (yx * wz - wx * yz) + xz * (yx * wy - wx * yy)) * invDet
    result[15] = (xx * (yy * zz - zy * yz) - xy * (yx * zz - zx * yz) + xz * (yx * zy - zx * yy)) * invDet
}

/** @brief 计算 3x3 矩阵的余子式矩阵 */
public func mtx3Cofactor(result: Array<Float32>, a: Array<Float32>): Unit {
    let xx = a[0]
    let xy = a[1]
    let xz = a[2]
    let yx = a[3]
    let yy = a[4]
    let yz = a[5]
    let zx = a[6]
    let zy = a[7]
    let zz = a[8]

    result[0] = yy * zz - yz * zy
    result[1] = -(yx * zz - yz * zx)
    result[2] = yx * zy - yy * zx
    result[3] = -(xy * zz - xz * zy)
    result[4] = xx * zz - xz * zx
    result[5] = -(xx * zy - xy * zx)
    result[6] = xy * yz - xz * yy
    result[7] = -(xx * yz - xz * yx)
    result[8] = xx * yy - xy * yx
}

/** @brief 计算 4x4 矩阵的余子式矩阵 */
public func mtxCofactor(result: Array<Float32>, a: Array<Float32>): Unit {
    let xx = a[0]
    let xy = a[1]
    let xz = a[2]
    let xw = a[3]
    let yx = a[4]
    let yy = a[5]
    let yz = a[6]
    let yw = a[7]
    let zx = a[8]
    let zy = a[9]
    let zz = a[10]
    let zw = a[11]
    let wx = a[12]
    let wy = a[13]
    let wz = a[14]
    let ww = a[15]

    result[0] = yy * (zz * ww - wz * zw) - yz * (zy * ww - wy * zw) + yw * (zy * wz - wy * zz)
    result[1] = -(yx * (zz * ww - wz * zw) - yz * (zx * ww - wx * zw) + yw * (zx * wz - wx * zz))
    result[2] = yx * (zy * ww - wy * zw) - yy * (zx * ww - wx * zw) + yw * (zx * wy - wx * zy)
    result[3] = -(yx * (zy * wz - wy * zz) - yy * (zx * wz - wx * zz) + yz * (zx * wy - wx * zy))
    result[4] = -(xy * (zz * ww - wz * zw) - xz * (zy * ww - wy * zw) + xw * (zy * wz - wy * zz))
    result[5] = xx * (zz * ww - wz * zw) - xz * (zx * ww - wx * zw) + xw * (zx * wz - wx * zz)
    result[6] = -(xx * (zy * ww - wy * zw) - xy * (zx * ww - wx * zw) + xw * (zx * wy - wx * zy))
    result[7] = xx * (zy * wz - wy * zz) - xy * (zx * wz - wx * zz) + xz * (zx * wy - wx * zy)
    result[8] = xy * (yz * ww - wz * yw) - xz * (yy * ww - wy * yw) + xw * (yy * wz - wy * yz)
    result[9] = -(xx * (yz * ww - wz * yw) - xz * (yx * ww - wx * yw) + xw * (yx * wz - wx * yz))
    result[10] = xx * (yy * ww - wy * yw) - xy * (yx * ww - wx * yw) + xw * (yx * wy - wx * yy)
    result[11] = -(xx * (yy * wz - wy * yz) - xy * (yx * wz - wx * yz) + xz * (yx * wy - wx * yy))
    result[12] = -(xy * (yz * zw - zz * yw) - xz * (yy * zw - zy * yw) + xw * (yy * zz - zy * yz))
    result[13] = xx * (yz * zw - zz * yw) - xz * (yx * zw - zx * yw) + xw * (yx * zz - zx * yz)
    result[14] = -(xx * (yy * zw - zy * yw) - xy * (yx * zw - zx * yw) + xw * (yx * zy - zx * yy))
    result[15] = xx * (yy * zz - zy * yz) - xy * (yx * zz - zx * yz) + xz * (yx * zy - zx * yy)
}

// =============================================================================
// RGB <-> HSV color conversion
// =============================================================================

/** @brief RGB 转 HSV */
public func rgbToHsv(rgb: Array<Float32>): Array<Float32> {
    let rr = rgb[0]
    let gg = rgb[1]
    let bb = rgb[2]

    let s0 = step(bb, gg)
    let px = lerp(bb, gg, s0)
    let py = lerp(gg, bb, s0)
    let pz = lerp(-1.0f32, 0.0f32, s0)
    let pw = lerp(2.0f32 / 3.0f32, -1.0f32 / 3.0f32, s0)

    let s1 = step(px, rr)
    let qx = lerp(px, rr, s1)
    let qy = py
    let qz = lerp(pw, pz, s1)
    let qw = lerp(rr, px, s1)

    let dd = qx - min(qw, qy)
    let ee = 1.0e-10f32

    return [
        abs(qz + (qw - qy) / (6.0f32 * dd + ee)),
        dd / (qx + ee),
        qx
    ]
}

/** @brief HSV 转 RGB */
public func hsvToRgb(hsv: Array<Float32>): Array<Float32> {
    let hh = hsv[0]
    let ss = hsv[1]
    let vv = hsv[2]

    let px = abs(fract(hh + 1.0f32) * 6.0f32 - 3.0f32)
    let py = abs(fract(hh + 2.0f32 / 3.0f32) * 6.0f32 - 3.0f32)
    let pz = abs(fract(hh + 1.0f32 / 3.0f32) * 6.0f32 - 3.0f32)

    return [
        vv * lerp(1.0f32, clamp(px - 1.0f32, 0.0f32, 1.0f32), ss),
        vv * lerp(1.0f32, clamp(py - 1.0f32, 0.0f32, 1.0f32), ss),
        vv * lerp(1.0f32, clamp(pz - 1.0f32, 0.0f32, 1.0f32), ss)
    ]
}

// =============================================================================
// Bit manipulation utilities (used for texture size / mip computation)
// =============================================================================

/** @brief 计算 UInt32 中置 1 的位数 */
public func countBits(v: UInt32): UInt8 {
    var x = v
    var count: UInt8 = 0
    while (x != 0u32) {
        count++
        x = x & (x - 1u32)
    }
    return count
}

/** @brief 计算 UInt32 中前导零的个数 */
public func countLeadingZeros(v: UInt32): UInt8 {
    if (v == 0u32) {
        return 32u8
    }
    var n: UInt8 = 0
    var x = v
    if ((x & 0xffff0000u32) == 0u32) { n = n + 16u8; x = x << 16 }
    if ((x & 0xff000000u32) == 0u32) { n = n + 8u8;  x = x << 8 }
    if ((x & 0xf0000000u32) == 0u32) { n = n + 4u8;  x = x << 4 }
    if ((x & 0xc0000000u32) == 0u32) { n = n + 2u8;  x = x << 2 }
    if ((x & 0x80000000u32) == 0u32) { n = n + 1u8 }
    return n
}

/** @brief 计算 UInt32 中尾随零的个数 */
public func countTrailingZeros(v: UInt32): UInt8 {
    if (v == 0u32) {
        return 32u8
    }
    var n: UInt8 = 0
    var x = v
    if ((x & 0xffffu32) == 0u32) { n = n + 16u8; x = x >> 16 }
    if ((x & 0xffu32) == 0u32) { n = n + 8u8;  x = x >> 8 }
    if ((x & 0xfu32) == 0u32) { n = n + 4u8;  x = x >> 4 }
    if ((x & 0x3u32) == 0u32) { n = n + 2u8;  x = x >> 2 }
    if ((x & 0x1u32) == 0u32) { n = n + 1u8 }
    return n
}

/** @brief 查找第一个置 1 位的位置（1-indexed），无置位返回 0 */
public func findFirstSet(v: UInt32): UInt8 {
    if (v == 0u32) {
        return 0u8
    }
    return countTrailingZeros(v) + 1u8
}

/** @brief 查找最后一个置 1 位的位置（1-indexed），无置位返回 0 */
public func findLastSet(v: UInt32): UInt8 {
    if (v == 0u32) {
        return 0u8
    }
    return 32u8 - countLeadingZeros(v)
}

/** @brief 返回大于等于 v 的最小整数以 2 为底的对数 */
public func ceilLog2(v: UInt32): UInt8 {
    if (v < 1u32) {
        return 0u8
    }
    return 32u8 - countLeadingZeros(v - 1u32)
}

/** @brief 返回小于等于 v 的最大整数以 2 为底的对数 */
public func floorLog2(v: UInt32): UInt8 {
    if (v < 1u32) {
        return 0u8
    }
    return 31u8 - countLeadingZeros(v)
}

/** @brief 返回大于等于 v 的 2 的幂 */
public func nextPow2(v: UInt32): UInt32 {
    let log2 = ceilLog2(v)
    return 1u32 << log2
}

// =============================================================================
// Additional floating-point utilities
// =============================================================================

/** @brief 返回可排序的浮点数值（用于基数排序） */
public func floatFlip(value: UInt32): UInt32 {
    let mask = (UInt32(Int64(value) >> 31)) | 0x80000000u32
    return value ^ mask
}

/** @brief 将 Float64 的位表示重新解释为 UInt64 */
public func doubleToBits(v: Float64): UInt64 {
    if (v.isNaN()) {
        return 0x7ff8000000000000u64
    }
    if (v.isInf()) {
        if (v > 0.0) {
            return 0x7ff0000000000000u64
        }
        return 0xfff0000000000000u64
    }
    if (v == 0.0) {
        if (signBit(v)) {
            return 0x8000000000000000u64
        }
        return 0u64
    }
    // Use Float64 math to extract sign/exp/mantissa.
    let neg = v < 0.0
    let mag = if (neg) { -v } else { v }
    var exp = 0
    var m = mag
    while (m >= 2.0) {
        m = m / 2.0
        exp++
    }
    while (m < 1.0 && m > 0.0) {
        m = m * 2.0
        exp--
    }
    let biasedExp = exp + 1023
    if (biasedExp <= 0) {
        return if (neg) { 0x8000000000000000u64 } else { 0u64 }
    }
    if (biasedExp >= 0x7ff) {
        return (if (neg) { 0x8000000000000000u64 } else { 0u64 }) | 0x7ff0000000000000u64
    }
    let mantissa = UInt64((m - 1.0) * 4503599627370496.0)
    return (if (neg) { 0x8000000000000000u64 } else { 0u64 }) | (UInt64(biasedExp) << 52) | (mantissa & 0xfffffffffffffu64)
}

/** @brief 将 UInt64 的位表示重新解释为 Float64 */
public func bitsToDouble(bits: UInt64): Float64 {
    let sign = (bits >> 63) & 0x1u64
    let exp = (bits >> 52) & 0x7ffu64
    let mantissa = bits & 0xfffffffffffffu64
    if (exp == 0u64 && mantissa == 0u64) {
        return if (sign == 0u64) { 0.0 } else { -0.0 }
    }
    if (exp == 0x7ffu64) {
        if (mantissa == 0u64) {
            return if (sign == 0u64) { Float64.Inf } else { -Float64.Inf }
        }
        return Float64.NaN
    }
    if (exp == 0u64) {
        return if (sign == 0u64) { 0.0 } else { -0.0 }
    }
    let v = Float64((1u64 << 52) | mantissa) / 4503599627370496.0
    let scale = Float64(pow(2.0, Float64(Int64(exp) - 1023)))
    let result = v * scale
    return if (sign == 0u64) { result } else { -result }
}

/** @brief 计算 a * 2^exponent */
public func ldexp(a: Float32, exponent: Int32): Float32 {
    return a * Float32(pow(2.0, Float64(exponent)))
}

/** @brief 同时计算 a 的正弦和余弦 */
public func sinCosApprox(a: Float32): (Float32, Float32) {
    return (sin(a), cos(a))
}

