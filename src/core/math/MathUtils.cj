/**
 * @file[zh-cn] MathUtils
 * @brief[zh-cn] 数学工具函数
 * @explain[zh-cn] 提供常用的数学工具函数集合。
 *
 * @file[en] MathUtils
 * @brief[en] Math utilities
 * @explain[en] Provides a collection of commonly used math utility functions.
 */
package three.core.math

import std.math.*
import std.random.*

/**
 * @brief[zh-cn] 圆周率常量
 *
 * @brief[en] Pi constant
 */
public const PI: Float64 = 3.14159265358979323846

/**
 * @brief[zh-cn] 2的自然对数常量
 *
 * @brief[en] Natural logarithm of 2 constant
 */
public const LN2: Float64 = 0.6931471805599453

/**
 * @brief[zh-cn] 度转弧度常量
 *
 * @brief[en] Degrees to radians constant
 */
public let DEG2RAD: Float64 = PI / 180.0

/**
 * @brief[zh-cn] 弧度转度常量
 *
 * @brief[en] Radians to degrees constant
 */
public let RAD2DEG: Float64 = 180.0 / PI

/**
 * @brief[zh-cn] 数学工具类，提供常用的数学函数集合
 *
 * @brief[en] Math utility class providing a collection of commonly used math functions
 */
public class MathUtils {
    /**
     * @brief[zh-cn] 生成 UUID 用的查找表
     */
    private static let _lut: Array<String> = [
        "00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f",
        "10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f",
        "20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f",
        "30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f",
        "40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f",
        "50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f",
        "60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f",
        "70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f",
        "80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f",
        "90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f",
        "a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af",
        "b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf",
        "c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf",
        "d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df",
        "e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef",
        "f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"
    ]

    /**
     * @brief[zh-cn] 伪随机数生成器种子
     */
    private static var _seed: Int64 = 1234567

    /**
     * @brief[zh-cn] 生成 UUID（通用唯一标识符）
     * @return[zh-cn] UUID 字符串
     *
     * @brief[en] Generate UUID (Universally Unique Identifier)
     * @return[en] UUID string
     */
    public static func generateUUID(): String {
        // http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript/21963136#21963136
        let d0 = Random().nextInt64() & 0xffffffff
        let d1 = Random().nextInt64() & 0xffffffff
        let d2 = Random().nextInt64() & 0xffffffff
        let d3 = Random().nextInt64() & 0xffffffff
        let uuid = _lut[Int64(d0 & 0xff)] + _lut[Int64((d0 >> 8) & 0xff)] +
            _lut[Int64((d0 >> 16) & 0xff)] + _lut[Int64((d0 >> 24) & 0xff)] + "-" +
            _lut[Int64(d1 & 0xff)] + _lut[Int64((d1 >> 8) & 0xff)] + "-" +
            _lut[Int64((d1 >> 16) & 0x0f | 0x40)] + _lut[Int64((d1 >> 24) & 0xff)] + "-" +
            _lut[Int64((d2 & 0x3f) | 0x80)] + _lut[Int64((d2 >> 8) & 0xff)] + "-" +
            _lut[Int64((d2 >> 16) & 0xff)] + _lut[Int64((d2 >> 24) & 0xff)] +
            _lut[Int64(d3 & 0xff)] + _lut[Int64((d3 >> 8) & 0xff)] +
            _lut[Int64((d3 >> 16) & 0xff)] + _lut[Int64((d3 >> 24) & 0xff)]
        return uuid.toAsciiLower()
    }

    /**
     * @brief[zh-cn] 将值限制在 [min, max] 范围内
     * @param[zh-cn] v 要限制的值
     * min 最小值
     * max 最大值
     * @return[zh-cn] 限制后的值
     *
     * @brief[en] Clamp value to the [min, max] range
     * @param[en] v Value to clamp
     * min Minimum value
     * max Maximum value
     * @return[en] Clamped value
     */
    public static func clamp(v: Float64, min: Float64, max: Float64): Float64 {
        return if (v < min) { min } else if (v > max) { max } else { v }
    }

    /**
     * @brief[zh-cn] 计算欧几里得取模：((n % m) + m) % m
     * @param[zh-cn] n 被除数
     * m 除数
     * @return[zh-cn] 欧几里得取模结果
     *
     * @brief[en] Compute Euclidean modulo: ((n % m) + m) % m
     * @param[en] n Dividend
     * m Divisor
     * @return[en] Euclidean modulo result
     */
    public static func euclideanModulo(n: Int64, m: Int64): Int64 {
        return ((n % m) + m) % m
    }

    /**
     * @brief[zh-cn] 计算浮点数欧几里得取模：结果始终为非负数
     * @param[zh-cn] n 被除数
     * m 除数
     * @return[zh-cn] 欧几里得取模结果
     *
     * @brief[en] Compute float Euclidean modulo: result is always non-negative
     * @param[en] n Dividend
     * m Divisor
     * @return[en] Euclidean modulo result
     */
    public static func euclideanModulo(n: Float64, m: Float64): Float64 {
        let r = n - floor(n / m) * m
        return if (r < 0.0) { r + m } else { r }
    }

    /**
     * @brief[zh-cn] 将值从范围 [a1, a2] 线性映射到范围 [b1, b2]
     * @param[zh-cn] x 要映射的值
     * a1 范围 A 的最小值
     * a2 范围 A 的最大值
     * b1 范围 B 的最小值
     * b2 范围 B 的最大值
     * @return[zh-cn] 映射后的值
     *
     * @brief[en] Map value linearly from range [a1, a2] to range [b1, b2]
     * @param[en] x Value to map
     * a1 Range A minimum
     * a2 Range A maximum
     * b1 Range B minimum
     * b2 Range B maximum
     * @return[en] Mapped value
     */
    public static func mapLinear(x: Float64, a1: Float64, a2: Float64, b1: Float64, b2: Float64): Float64 {
        return b1 + (x - a1) * (b2 - b1) / (a2 - a1)
    }

    /**
     * @brief[zh-cn] 返回给定值在起点和终点之间的闭区间 [0, 1] 中的百分比
     * @param[zh-cn] x 起点值
     * y 终点值
     * value 介于起点和终点之间的值
     * @return[zh-cn] 插值因子
     *
     * @brief[en] Return the percentage of the given value between start and end in the closed interval [0, 1]
     * @param[en] x Start value
     * y End value
     * value Value between start and end
     * @return[en] Interpolation factor
     */
    public static func inverseLerp(x: Float64, y: Float64, value: Float64): Float64 {
        if (x != y) {
            return (value - x) / (y - x)
        } else {
            return 0.0
        }
    }

    /**
     * @brief[zh-cn] 线性插值：t = 0 返回 x，t = 1 返回 y
     * @param[zh-cn] x 起点值
     * y 终点值
     * t 插值因子，闭区间 [0, 1]
     * @return[zh-cn] 插值结果
     *
     * @brief[en] Linear interpolation: t = 0 returns x, t = 1 returns y
     * @param[en] x Start value
     * y End value
     * t Interpolation factor, closed interval [0, 1]
     * @return[en] Interpolated result
     */
    public static func lerp(x: Float64, y: Float64, t: Float64): Float64 {
        return (1.0 - t) * x + t * y
    }

    /**
     * @brief[zh-cn] 使用弹簧阻尼方式平滑插值，帧率无关
     * @explain[zh-cn] 参考：http://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
     * @param[zh-cn] x 当前值
     * y 目标值
     * lambda 阻尼系数，值越大变化越突然
     * dt 时间增量（秒）
     * @return[zh-cn] 插值结果
     *
     * @brief[en] Smooth interpolation using spring damping, frame rate independent
     * @explain[en] Reference: http://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
     * @param[en] x Current value
     * y Target value
     * lambda Damping coefficient, larger values mean more abrupt changes
     * dt Time delta in seconds
     * @return[en] Interpolated result
     */
    public static func damp(x: Float64, y: Float64, lambda: Float64, dt: Float64): Float64 {
        return lerp(x, y, 1.0 - exp(-lambda * dt))
    }

    /**
     * @brief[zh-cn] 返回在 0 和给定 length 之间交替的值
     * @param[zh-cn] x 要乒乓的值
     * length 乒乓到的正值，默认为 1
     * @return[zh-cn] 交替后的值
     *
     * @brief[en] Return a value that alternates between 0 and the given length
     * @param[en] x Value to ping-pong
     * length Positive value to ping-pong to, default 1
     * @return[en] Alternated value
     */
    public static func pingpong(x: Float64, length!: Float64 = 1.0): Float64 {
        return length - abs(euclideanModulo(x, length * 2.0) - length)
    }

    /**
     * @brief[zh-cn] 返回 x 在 [min, max] 之间移动的平滑百分比，值域 [0, 1]
     * @explain[zh-cn] 参考：http://en.wikipedia.org/wiki/Smoothstep
     * @param[zh-cn] x 要评估的值
     * min 最小值，低于此值返回 0
     * max 最大值，高于此值返回 1
     * @return[zh-cn] 平滑插值结果
     *
     * @brief[en] Return the smooth percentage of x moving between [min, max], range [0, 1]
     * @explain[en] Reference: http://en.wikipedia.org/wiki/Smoothstep
     * @param[en] x Value to evaluate
     * min Minimum value, returns 0 below this
     * max Maximum value, returns 1 above this
     * @return[en] Smooth interpolation result
     */
    public static func smoothstep(x: Float64, min: Float64, max: Float64): Float64 {
        if (x <= min) { return 0.0 }
        if (x >= max) { return 1.0 }
        let t = (x - min) / (max - min)
        return t * t * (3.0 - 2.0 * t)
    }

    /**
     * @brief[zh-cn] smoothstep 的变体，在 x=0 和 x=1 处具有零一阶和二阶导数
     * @explain[zh-cn] 参考：https://en.wikipedia.org/wiki/Smoothstep#Variations
     * @param[zh-cn] x 要评估的值
     * min 最小值，低于此值返回 0
     * max 最大值，高于此值返回 1
     * @return[zh-cn] 更平滑的插值结果
     *
     * @brief[en] Variant of smoothstep with zero first and second derivatives at x=0 and x=1
     * @explain[en] Reference: https://en.wikipedia.org/wiki/Smoothstep#Variations
     * @param[en] x Value to evaluate
     * min Minimum value, returns 0 below this
     * max Maximum value, returns 1 above this
     * @return[en] Smoother interpolation result
     */
    public static func smootherstep(x: Float64, min: Float64, max: Float64): Float64 {
        if (x <= min) { return 0.0 }
        if (x >= max) { return 1.0 }
        let t = (x - min) / (max - min)
        return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
    }

    /**
     * @brief[zh-cn] 返回 [low, high] 区间内的随机整数
     * @param[zh-cn] low 下界
     * high 上界
     * @return[zh-cn] 随机整数
     *
     * @brief[en] Return a random integer in the [low, high] range
     * @param[en] low Lower bound
     * high Upper bound
     * @return[en] Random integer
     */
    public static func randInt(low: Int64, high: Int64): Int64 {
        return low + Int64(Random().nextFloat64() * Float64(high - low + 1))
    }

    /**
     * @brief[zh-cn] 返回 [low, high] 区间内的随机浮点数
     * @param[zh-cn] low 下界
     * high 上界
     * @return[zh-cn] 随机浮点数
     *
     * @brief[en] Return a random float in the [low, high] range
     * @param[en] low Lower bound
     * high Upper bound
     * @return[en] Random float
     */
    public static func randFloat(low: Float64, high: Float64): Float64 {
        return low + Random().nextFloat64() * (high - low)
    }

    /**
     * @brief[zh-cn] 返回 [-range/2, range/2] 区间内的随机浮点数
     * @param[zh-cn] range 范围
     * @return[zh-cn] 随机浮点数
     *
     * @brief[en] Return a random float in the [-range/2, range/2] range
     * @param[en] range Range
     * @return[en] Random float
     */
    public static func randFloatSpread(range: Float64): Float64 {
        return range * (0.5 - Random().nextFloat64())
    }

    /**
     * @brief[zh-cn] 返回 [0, 1] 区间内的确定性伪随机浮点数（Mulberry32 生成器）
     * @param[zh-cn] s 可选的整数种子
     * @return[zh-cn] 伪随机浮点数
     *
     * @brief[en] Return a deterministic pseudo-random float in [0, 1] (Mulberry32 generator)
     * @param[en] s Optional integer seed
     * @return[en] Pseudo-random float
     */
    public static func seededRandom(s!: Option<Int64> = None): Float64 {
        if (s.isSome()) {
            _seed = s.getOrThrow()
        }
        // Mulberry32 生成器
        var t = _seed + 0x6D2B79F5
        _seed = t
        t = ((t ^ (t >> 15)) * (t | 1)) & 0xFFFFFFFF
        t = (t ^ (t + ((t ^ (t >> 7)) * (t | 61)) & 0xFFFFFFFF)) & 0xFFFFFFFF
        return Float64((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296.0
    }

    /**
     * @brief[zh-cn] 将角度转换为弧度
     * @param[zh-cn] degrees 角度值
     * @return[zh-cn] 弧度值
     *
     * @brief[en] Convert degrees to radians
     * @param[en] degrees Degree value
     * @return[en] Radian value
     */
    public static func degToRad(degrees: Float64): Float64 {
        return degrees * DEG2RAD
    }

    /**
     * @brief[zh-cn] 将弧度转换为角度
     * @param[zh-cn] radians 弧度值
     * @return[zh-cn] 角度值
     *
     * @brief[en] Convert radians to degrees
     * @param[en] radians Radian value
     * @return[en] Degree value
     */
    public static func radToDeg(radians: Float64): Float64 {
        return radians * RAD2DEG
    }

    /**
     * @brief[zh-cn] 判断给定数值是否为 2 的幂
     * @param[zh-cn] value 要检查的值
     * @return[zh-cn] 是否为 2 的幂
     *
     * @brief[en] Check if the given value is a power of two
     * @param[en] value Value to check
     * @return[en] Whether the value is a power of two
     */
    public static func isPowerOfTwo(value: Int64): Bool {
        return (value & (value - 1)) == 0 && value != 0
    }

    /**
     * @brief[zh-cn] 返回大于或等于给定数的最小 2 的幂
     * @param[zh-cn] value 要查找的值，必须大于 0
     * @return[zh-cn] 最小的 2 的幂
     *
     * @brief[en] Return the smallest power of two greater than or equal to the given value
     * @param[en] value Value to find, must be greater than 0
     * @return[en] Smallest power of two
     */
    public static func ceilPowerOfTwo(value: Int64): Int64 {
        return Int64(pow(2.0, ceil(log(Float64(value)) / LN2)))
    }

    /**
     * @brief[zh-cn] 返回小于或等于给定数的最大 2 的幂
     * @param[zh-cn] value 要查找的值，必须大于 0
     * @return[zh-cn] 最大的 2 的幂
     *
     * @brief[en] Return the largest power of two less than or equal to the given value
     * @param[en] value Value to find, must be greater than 0
     * @return[en] Largest power of two
     */
    public static func floorPowerOfTwo(value: Int64): Int64 {
        return Int64(pow(2.0, floor(log(Float64(value)) / LN2)))
    }

    /**
     * @brief[zh-cn] 从内禀真欧拉角设置四元数
     * @explain[zh-cn] 旋转按 order 指定的轴顺序应用：先旋转角度 a，再旋转角度 b，最后旋转角度 c。参考：https://en.wikipedia.org/wiki/Euler_angles
     * @param[zh-cn] q 要设置的四元数
     * a 第一个轴的旋转角度（弧度）
     * b 第二个轴的旋转角度（弧度）
     * c 第三个轴的旋转角度（弧度）
     * order 轴顺序字符串，如 "XYX"、"XZX"、"YXY" 等
     *
     * @brief[en] Set quaternion from intrinsic proper Euler angles
     * @explain[en] Rotations are applied in the axis order specified: first angle a, then angle b, finally angle c. Reference: https://en.wikipedia.org/wiki/Euler_angles
     * @param[en] q Quaternion to set
     * a First axis rotation angle in radians
     * b Second axis rotation angle in radians
     * c Third axis rotation angle in radians
     * order Axis order string, e.g. "XYX", "XZX", "YXY", etc.
     */
    public static func setQuaternionFromProperEuler(q: Quaternion, a: Float64, b: Float64, c: Float64, order: String): Unit {
        let cosB = cos(b / 2.0)
        let sinB = sin(b / 2.0)
        let cos13 = cos((a + c) / 2.0)
        let sin13 = sin((a + c) / 2.0)
        let cos1_3 = cos((a - c) / 2.0)
        let sin1_3 = sin((a - c) / 2.0)
        let cos3_1 = cos((c - a) / 2.0)
        let sin3_1 = sin((c - a) / 2.0)

        if (order == "XYX") {
            q.set(cosB * sin13, sinB * cos1_3, sinB * sin1_3, cosB * cos13)
        } else if (order == "YZY") {
            q.set(sinB * sin1_3, cosB * sin13, sinB * cos1_3, cosB * cos13)
        } else if (order == "ZXZ") {
            q.set(sinB * cos1_3, sinB * sin1_3, cosB * sin13, cosB * cos13)
        } else if (order == "XZX") {
            q.set(cosB * sin13, sinB * sin3_1, sinB * cos3_1, cosB * cos13)
        } else if (order == "YXY") {
            q.set(sinB * cos3_1, cosB * sin13, sinB * sin3_1, cosB * cos13)
        } else if (order == "ZYZ") {
            q.set(sinB * sin3_1, sinB * cos3_1, cosB * sin13, cosB * cos13)
        }
    }

    /**
     * @brief[zh-cn] 根据类型数组的类型对值进行反归一化，将 [0,1] 范围的浮点值转换为对应类型的整数值
     * @param[zh-cn] value 要反归一化的值
     * componentType 组件类型标识（0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8）
     * @return[zh-cn] 反归一化后的值
     *
     * @brief[en] Denormalize a value based on the typed array type, converting [0,1] float to the corresponding integer type
     * @param[en] value Value to denormalize
     * componentType Component type identifier (0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8)
     * @return[en] Denormalized value
     */
    public static func denormalize(value: Float64, componentType: Int64): Float64 {
        if (componentType == 0) {
            // Float32Array
            return value
        } else if (componentType == 1) {
            // Uint32Array
            return value / 4294967295.0
        } else if (componentType == 2) {
            // Uint16Array
            return value / 65535.0
        } else if (componentType == 3) {
            // Uint8Array
            return value / 255.0
        } else if (componentType == 4) {
            // Int32Array
            return max(value / 2147483647.0, -1.0)
        } else if (componentType == 5) {
            // Int16Array
            return max(value / 32767.0, -1.0)
        } else if (componentType == 6) {
            // Int8Array
            return max(value / 127.0, -1.0)
        } else {
            throw Exception("THREE.MathUtils: Invalid component type.")
        }
    }

    /**
     * @brief[zh-cn] 根据类型数组的类型对值进行归一化，将整数值转换为 [0,1] 范围的浮点值
     * @param[zh-cn] value 要归一化的浮点值
     * componentType 组件类型标识（0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8）
     * @return[zh-cn] 归一化后的值
     *
     * @brief[en] Normalize a value based on the typed array type, converting integer to [0,1] float
     * @param[en] value Float value to normalize
     * componentType Component type identifier (0=Float32, 1=Uint32, 2=Uint16, 3=Uint8, 4=Int32, 5=Int16, 6=Int8)
     * @return[en] Normalized value
     */
    public static func normalize(value: Float64, componentType: Int64): Float64 {
        if (componentType == 0) {
            // Float32Array
            return value
        } else if (componentType == 1) {
            // Uint32Array
            return round(value * 4294967295.0)
        } else if (componentType == 2) {
            // Uint16Array
            return round(value * 65535.0)
        } else if (componentType == 3) {
            // Uint8Array
            return round(value * 255.0)
        } else if (componentType == 4) {
            // Int32Array
            return round(value * 2147483647.0)
        } else if (componentType == 5) {
            // Int16Array
            return round(value * 32767.0)
        } else if (componentType == 6) {
            // Int8Array
            return round(value * 127.0)
        } else {
            throw Exception("THREE.MathUtils: Invalid component type.")
        }
    }
}
