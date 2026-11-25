/**
 * @file bx 缓动函数
 * @brief bx 库的缓动函数和缓动类型枚举
 * @explain 本文件包含纯仓颉实现的 bx 缓动函数库，提供 31 种缓动类型
 *         （Linear/Quad/Cubic/Quart/Quint/Sine/Expo/Circ/Elastic/Back/Bounce）
 *         每种包含 In/Out/InOut/OutIn 四种变体。
 * @note 适用于动画、插值和过渡效果的计算。
 */
protected package three._vendor.bgfx4cj.bx

// =============================================================================
// Easing enum
// =============================================================================

/**
 * @brief 缓动类型枚举
 * @explain 定义 31 种缓动函数类型，每种包含 In/Out/InOut/OutIn 变体。
 * @note `Count` 用于边界检查，不是实际的缓动类型。
 */
public enum Easing {
    /** @brief 线性插值，无缓动效果 */
    | Linear
    /** @brief 阶跃函数，t<0.5 返回 0，否则返回 1 */
    | Step
    /** @brief 平滑阶跃，使用 Hermite 插值 */
    | SmoothStep
    /** @brief 二次方缓入，从慢到快 */
    | InQuad
    /** @brief 二次方缓出，从快到慢 */
    | OutQuad
    /** @brief 二次方缓入缓出 */
    | InOutQuad
    /** @brief 二次方缓出缓入 */
    | OutInQuad
    /** @brief 三次方缓入 */
    | InCubic
    /** @brief 三次方缓出 */
    | OutCubic
    /** @brief 三次方缓入缓出 */
    | InOutCubic
    /** @brief 三次方缓出缓入 */
    | OutInCubic
    /** @brief 四次方缓入 */
    | InQuart
    /** @brief 四次方缓出 */
    | OutQuart
    /** @brief 四次方缓入缓出 */
    | InOutQuart
    /** @brief 四次方缓出缓入 */
    | OutInQuart
    /** @brief 五次方缓入 */
    | InQuint
    /** @brief 五次方缓出 */
    | OutQuint
    /** @brief 五次方缓入缓出 */
    | InOutQuint
    /** @brief 五次方缓出缓入 */
    | OutInQuint
    /** @brief 正弦缓入 */
    | InSine
    /** @brief 正弦缓出 */
    | OutSine
    /** @brief 正弦缓入缓出 */
    | InOutSine
    /** @brief 正弦缓出缓入 */
    | OutInSine
    /** @brief 指数缓入 */
    | InExpo
    /** @brief 指数缓出 */
    | OutExpo
    /** @brief 指数缓入缓出 */
    | InOutExpo
    /** @brief 指数缓出缓入 */
    | OutInExpo
    /** @brief 圆形缓入 */
    | InCirc
    /** @brief 圆形缓出 */
    | OutCirc
    /** @brief 圆形缓入缓出 */
    | InOutCirc
    /** @brief 圆形缓出缓入 */
    | OutInCirc
    /** @brief 弹性缓入 */
    | InElastic
    /** @brief 弹性缓出 */
    | OutElastic
    /** @brief 弹性缓入缓出 */
    | InOutElastic
    /** @brief 弹性缓出缓入 */
    | OutInElastic
    /** @brief 回退缓入 */
    | InBack
    /** @brief 回退缓出 */
    | OutBack
    /** @brief 回退缓入缓出 */
    | InOutBack
    /** @brief 回退缓出缓入 */
    | OutInBack
    /** @brief 弹跳缓入 */
    | InBounce
    /** @brief 弹跳缓出 */
    | OutBounce
    /** @brief 弹跳缓入缓出 */
    | InOutBounce
    /** @brief 弹跳缓出缓入 */
    | OutInBounce
    /** @brief 枚举成员总数，用于边界检查 */
    | Count

    /** @brief 将枚举值转换为 UInt32 */
    public func value(): UInt32 {
        match (this) {
            case Linear => 0
            case Step => 1
            case SmoothStep => 2
            case InQuad => 3
            case OutQuad => 4
            case InOutQuad => 5
            case OutInQuad => 6
            case InCubic => 7
            case OutCubic => 8
            case InOutCubic => 9
            case OutInCubic => 10
            case InQuart => 11
            case OutQuart => 12
            case InOutQuart => 13
            case OutInQuart => 14
            case InQuint => 15
            case OutQuint => 16
            case InOutQuint => 17
            case OutInQuint => 18
            case InSine => 19
            case OutSine => 20
            case InOutSine => 21
            case OutInSine => 22
            case InExpo => 23
            case OutExpo => 24
            case InOutExpo => 25
            case OutInExpo => 26
            case InCirc => 27
            case OutCirc => 28
            case InOutCirc => 29
            case OutInCirc => 30
            case InElastic => 31
            case OutElastic => 32
            case InOutElastic => 33
            case OutInElastic => 34
            case InBack => 35
            case OutBack => 36
            case InOutBack => 37
            case OutInBack => 38
            case InBounce => 39
            case OutBounce => 40
            case InOutBounce => 41
            case OutInBounce => 42
            case Count => 43
        }
    }

    /** @brief 从 UInt32 转换回枚举值 */
    public static func fromValue(v: UInt32): Easing {
        match (v) {
            case 0 => Linear
            case 1 => Step
            case 2 => SmoothStep
            case 3 => InQuad
            case 4 => OutQuad
            case 5 => InOutQuad
            case 6 => OutInQuad
            case 7 => InCubic
            case 8 => OutCubic
            case 9 => InOutCubic
            case 10 => OutInCubic
            case 11 => InQuart
            case 12 => OutQuart
            case 13 => InOutQuart
            case 14 => OutInQuart
            case 15 => InQuint
            case 16 => OutQuint
            case 17 => InOutQuint
            case 18 => OutInQuint
            case 19 => InSine
            case 20 => OutSine
            case 21 => InOutSine
            case 22 => OutInSine
            case 23 => InExpo
            case 24 => OutExpo
            case 25 => InOutExpo
            case 26 => OutInExpo
            case 27 => InCirc
            case 28 => OutCirc
            case 29 => InOutCirc
            case 30 => OutInCirc
            case 31 => InElastic
            case 32 => OutElastic
            case 33 => InOutElastic
            case 34 => OutInElastic
            case 35 => InBack
            case 36 => OutBack
            case 37 => InOutBack
            case 38 => OutInBack
            case 39 => InBounce
            case 40 => OutBounce
            case 41 => InOutBounce
            case 42 => OutInBounce
            case _ => Count
        }
    }
}

// =============================================================================
// Easing function type alias
// =============================================================================

/**
 * @brief 缓动函数类型别名
 * @param Float32 输入时间 t（范围 [0, 1]）
 * @return Float32 缓动后的输出值（范围 [0, 1]）
 */
public type EaseFn = (Float32) -> Float32

// =============================================================================
// Internal helpers (mirror C++ templates easeOut / easeMix)
// =============================================================================

internal func easeOutOf(ease: EaseFn, t: Float32): Float32 {
    return 1.0f32 - ease(1.0f32 - t)
}

internal func easeMixOf(easeFrom0toH: EaseFn, easeFromHto1: EaseFn, t: Float32): Float32 {
    if (t < 0.5f32) {
        return easeFrom0toH(2.0f32 * t) * 0.5f32
    }
    return easeFromHto1(2.0f32 * t - 1.0f32) * 0.5f32 + 0.5f32
}

// =============================================================================
// Easing functions
// =============================================================================

/** @brief 线性缓动函数，直接返回输入值 */
public func easeLinear(t: Float32): Float32 {
    return t
}

/** @brief 阶跃缓动函数，t<0.5 返回 0，否则返回 1 */
public func easeStep(t: Float32): Float32 {
    if (t < 0.5f32) {
        return 0.0f32
    }
    return 1.0f32
}

/** @brief 平滑阶跃缓动函数，使用 Hermite 插值（3t² - 2t³） */
public func easeSmoothStep(t: Float32): Float32 {
    return square(t) * (3.0f32 - 2.0f32 * t)
}

/** @brief 二次方缓入函数：t² */
public func easeInQuad(t: Float32): Float32 {
    return square(t)
}

/** @brief 二次方缓出函数：1 - (1-t)² */
public func easeOutQuad(t: Float32): Float32 {
    return easeOutOf(easeInQuad, t)
}

/** @brief 二次方缓入缓出函数 */
public func easeInOutQuad(t: Float32): Float32 {
    return easeMixOf(easeInQuad, easeOutQuad, t)
}

/** @brief 二次方缓出缓入函数 */
public func easeOutInQuad(t: Float32): Float32 {
    return easeMixOf(easeOutQuad, easeInQuad, t)
}

/** @brief 三次方缓入函数：t³ */
public func easeInCubic(t: Float32): Float32 {
    return t * t * t
}

/** @brief 三次方缓出函数 */
public func easeOutCubic(t: Float32): Float32 {
    return easeOutOf(easeInCubic, t)
}

/** @brief 三次方缓入缓出函数 */
public func easeInOutCubic(t: Float32): Float32 {
    return easeMixOf(easeInCubic, easeOutCubic, t)
}

/** @brief 三次方缓出缓入函数 */
public func easeOutInCubic(t: Float32): Float32 {
    return easeMixOf(easeOutCubic, easeInCubic, t)
}

/** @brief 四次方缓入函数：t⁴ */
public func easeInQuart(t: Float32): Float32 {
    return t * t * t * t
}

/** @brief 四次方缓出函数 */
public func easeOutQuart(t: Float32): Float32 {
    return easeOutOf(easeInQuart, t)
}

/** @brief 四次方缓入缓出函数 */
public func easeInOutQuart(t: Float32): Float32 {
    return easeMixOf(easeInQuart, easeOutQuart, t)
}

/** @brief 四次方缓出缓入函数 */
public func easeOutInQuart(t: Float32): Float32 {
    return easeMixOf(easeOutQuart, easeInQuart, t)
}

/** @brief 五次方缓入函数：t⁵ */
public func easeInQuint(t: Float32): Float32 {
    return t * t * t * t * t
}

/** @brief 五次方缓出函数 */
public func easeOutQuint(t: Float32): Float32 {
    return easeOutOf(easeInQuint, t)
}

/** @brief 五次方缓入缓出函数 */
public func easeInOutQuint(t: Float32): Float32 {
    return easeMixOf(easeInQuint, easeOutQuint, t)
}

/** @brief 五次方缓出缓入函数 */
public func easeOutInQuint(t: Float32): Float32 {
    return easeMixOf(easeOutQuint, easeInQuint, t)
}

/** @brief 正弦缓入函数：1 - cos(t·π/2) */
public func easeInSine(t: Float32): Float32 {
    return 1.0f32 - cos(t * BX_PI_HALF)
}

/** @brief 正弦缓出函数 */
public func easeOutSine(t: Float32): Float32 {
    return easeOutOf(easeInSine, t)
}

/** @brief 正弦缓入缓出函数 */
public func easeInOutSine(t: Float32): Float32 {
    return easeMixOf(easeInSine, easeOutSine, t)
}

/** @brief 正弦缓出缓入函数 */
public func easeOutInSine(t: Float32): Float32 {
    return easeMixOf(easeOutSine, easeInSine, t)
}

/** @brief 指数缓入函数：2^(10·(t-1)) - 0.001 */
public func easeInExpo(t: Float32): Float32 {
    return pow(2.0f32, 10.0f32 * (t - 1.0f32)) - 0.001f32
}

/** @brief 指数缓出函数 */
public func easeOutExpo(t: Float32): Float32 {
    return easeOutOf(easeInExpo, t)
}

/** @brief 指数缓入缓出函数 */
public func easeInOutExpo(t: Float32): Float32 {
    return easeMixOf(easeInExpo, easeOutExpo, t)
}

/** @brief 指数缓出缓入函数 */
public func easeOutInExpo(t: Float32): Float32 {
    return easeMixOf(easeOutExpo, easeInExpo, t)
}

/** @brief 圆形缓入函数：1 - sqrt(1 - t²) */
public func easeInCirc(t: Float32): Float32 {
    return -(sqrt(1.0f32 - t * t) - 1.0f32)
}

/** @brief 圆形缓出函数 */
public func easeOutCirc(t: Float32): Float32 {
    return easeOutOf(easeInCirc, t)
}

/** @brief 圆形缓入缓出函数 */
public func easeInOutCirc(t: Float32): Float32 {
    return easeMixOf(easeInCirc, easeOutCirc, t)
}

/** @brief 圆形缓出缓入函数 */
public func easeOutInCirc(t: Float32): Float32 {
    return easeMixOf(easeOutCirc, easeInCirc, t)
}

/** @brief 弹性缓出函数：带振荡衰减的弹簧效果 */
public func easeOutElastic(t: Float32): Float32 {
    return pow(2.0f32, -10.0f32 * t) * sin((t - 0.3f32 / 4.0f32) * (2.0f32 * BX_PI) / 0.3f32) + 1.0f32
}

/** @brief 弹性缓入函数 */
public func easeInElastic(t: Float32): Float32 {
    return easeOutOf(easeOutElastic, t)
}

/** @brief 弹性缓入缓出函数 */
public func easeInOutElastic(t: Float32): Float32 {
    return easeMixOf(easeInElastic, easeOutElastic, t)
}

/** @brief 弹性缓出缓入函数 */
public func easeOutInElastic(t: Float32): Float32 {
    return easeMixOf(easeOutElastic, easeInElastic, t)
}

/** @brief 回退缓入函数：先反向再正向 */
public func easeInBack(t: Float32): Float32 {
    return easeInCubic(t) - t * sin(t * BX_PI)
}

/** @brief 回退缓出函数 */
public func easeOutBack(t: Float32): Float32 {
    return easeOutOf(easeInBack, t)
}

/** @brief 回退缓入缓出函数 */
public func easeInOutBack(t: Float32): Float32 {
    return easeMixOf(easeInBack, easeOutBack, t)
}

/** @brief 回退缓出缓入函数 */
public func easeOutInBack(t: Float32): Float32 {
    return easeMixOf(easeOutBack, easeInBack, t)
}

/** @brief 弹跳缓出函数：模拟球落地弹跳效果 */
public func easeOutBounce(t: Float32): Float32 {
    if (4.0f32 / 11.0f32 > t) {
        return 121.0f32 / 16.0f32 * t * t
    }
    if (8.0f32 / 11.0f32 > t) {
        return 363.0f32 / 40.0f32 * t * t -
            99.0f32 / 10.0f32 * t +
            17.0f32 / 5.0f32
    }
    if (9.0f32 / 10.0f32 > t) {
        return 4356.0f32 / 361.0f32 * t * t -
            35442.0f32 / 1805.0f32 * t +
            16061.0f32 / 1805.0f32
    }
    return 54.0f32 / 5.0f32 * t * t -
        513.0f32 / 25.0f32 * t +
        268.0f32 / 25.0f32
}

/** @brief 弹跳缓入函数 */
public func easeInBounce(t: Float32): Float32 {
    return easeOutOf(easeOutBounce, t)
}

/** @brief 弹跳缓入缓出函数 */
public func easeInOutBounce(t: Float32): Float32 {
    return easeMixOf(easeInBounce, easeOutBounce, t)
}

/** @brief 弹跳缓出缓入函数 */
public func easeOutInBounce(t: Float32): Float32 {
    return easeMixOf(easeOutBounce, easeInBounce, t)
}

// =============================================================================
// Ease function table lookup
// =============================================================================

/**
 * @brief 根据 Easing 枚举值获取对应的缓动函数
 * @param e 缓动类型枚举值
 * @return 对应的缓动函数引用
 */
public func getEaseFunc(e: Easing): EaseFn {
    match (e) {
        case Linear => easeLinear
        case Step => easeStep
        case SmoothStep => easeSmoothStep
        case InQuad => easeInQuad
        case OutQuad => easeOutQuad
        case InOutQuad => easeInOutQuad
        case OutInQuad => easeOutInQuad
        case InCubic => easeInCubic
        case OutCubic => easeOutCubic
        case InOutCubic => easeInOutCubic
        case OutInCubic => easeOutInCubic
        case InQuart => easeInQuart
        case OutQuart => easeOutQuart
        case InOutQuart => easeInOutQuart
        case OutInQuart => easeOutInQuart
        case InQuint => easeInQuint
        case OutQuint => easeOutQuint
        case InOutQuint => easeInOutQuint
        case OutInQuint => easeOutInQuint
        case InSine => easeInSine
        case OutSine => easeOutSine
        case InOutSine => easeInOutSine
        case OutInSine => easeOutInSine
        case InExpo => easeInExpo
        case OutExpo => easeOutExpo
        case InOutExpo => easeInOutExpo
        case OutInExpo => easeOutInExpo
        case InCirc => easeInCirc
        case OutCirc => easeOutCirc
        case InOutCirc => easeInOutCirc
        case OutInCirc => easeOutInCirc
        case InElastic => easeInElastic
        case OutElastic => easeOutElastic
        case InOutElastic => easeInOutElastic
        case OutInElastic => easeOutInElastic
        case InBack => easeInBack
        case OutBack => easeOutBack
        case InOutBack => easeInOutBack
        case OutInBack => easeOutInBack
        case InBounce => easeInBounce
        case OutBounce => easeOutBounce
        case InOutBounce => easeInOutBounce
        case OutInBounce => easeOutInBounce
        case Count => easeLinear
    }
}