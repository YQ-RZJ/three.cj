/**
 * @file openalsoft4cj.efx 公共函数包装
 * @brief OpenAL EFX 扩展（efx.h）的仓颉安全包装函数
 * @explain 本文件为每个 efx foreign 函数提供 `_cj` 后缀的公共包装，
 *         所有 foreign 调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。
 * @note 每个函数对应一个 C 端 EFX 函数，功能与 C API 一致。
 */
protected package three._vendor.openalsoft4cj.efx

// =============================================================================
// Effect objects（效果对象）
// =============================================================================

/**
 * @brief 生成效果对象
 * @param n 数量
 * @param effects 输出效果 ID 数组指针
 */
public func alGenEffects_cj(n: Int32, effects: CPointer<UInt32>): Unit {
    unsafe {
        alGenEffects(n, effects)
    }
}

/**
 * @brief 删除效果对象
 * @param n 数量
 * @param effects 效果 ID 数组指针
 */
public func alDeleteEffects_cj(n: Int32, effects: CPointer<UInt32>): Unit {
    unsafe {
        alDeleteEffects(n, effects)
    }
}

/**
 * @brief 验证效果 ID 是否有效
 * @param effect 效果 ID
 * @return 1 有效，0 无效
 */
public func alIsEffect_cj(effect: UInt32): UInt8 {
    unsafe {
        alIsEffect(effect)
    }
}

/**
 * @brief 设置效果整型参数
 * @param effect 效果 ID
 * @param param 参数标识（AL_EFFECT_TYPE 等）
 * @param iValue 参数值
 */
public func alEffecti_cj(effect: UInt32, param: UInt32, iValue: Int32): Unit {
    unsafe {
        alEffecti(effect, param, iValue)
    }
}

/**
 * @brief 设置效果整型数组参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param piValues 数组指针
 */
public func alEffectiv_cj(effect: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alEffectiv(effect, param, piValues)
    }
}

/**
 * @brief 设置效果浮点参数
 * @param effect 效果 ID
 * @param param 参数标识（AL_REVERB_DENSITY 等）
 * @param flValue 参数值
 */
public func alEffectf_cj(effect: UInt32, param: UInt32, flValue: Float32): Unit {
    unsafe {
        alEffectf(effect, param, flValue)
    }
}

/**
 * @brief 设置效果浮点数组参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param pflValues 数组指针
 */
public func alEffectfv_cj(effect: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alEffectfv(effect, param, pflValues)
    }
}

/**
 * @brief 查询效果整型参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param iValue 输出值指针
 */
public func alGetEffecti_cj(effect: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit {
    unsafe {
        alGetEffecti(effect, param, iValue)
    }
}

/**
 * @brief 查询效果整型数组参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param piValues 输出数组指针
 */
public func alGetEffectiv_cj(effect: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alGetEffectiv(effect, param, piValues)
    }
}

/**
 * @brief 查询效果浮点参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param flValue 输出值指针
 */
public func alGetEffectf_cj(effect: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit {
    unsafe {
        alGetEffectf(effect, param, flValue)
    }
}

/**
 * @brief 查询效果浮点数组参数
 * @param effect 效果 ID
 * @param param 参数标识
 * @param pflValues 输出数组指针
 */
public func alGetEffectfv_cj(effect: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alGetEffectfv(effect, param, pflValues)
    }
}

// =============================================================================
// Filter objects（滤波器对象）
// =============================================================================

/**
 * @brief 生成滤波器对象
 * @param n 数量
 * @param filters 输出滤波器 ID 数组指针
 */
public func alGenFilters_cj(n: Int32, filters: CPointer<UInt32>): Unit {
    unsafe {
        alGenFilters(n, filters)
    }
}

/**
 * @brief 删除滤波器对象
 * @param n 数量
 * @param filters 滤波器 ID 数组指针
 */
public func alDeleteFilters_cj(n: Int32, filters: CPointer<UInt32>): Unit {
    unsafe {
        alDeleteFilters(n, filters)
    }
}

/**
 * @brief 验证滤波器 ID 是否有效
 * @param filter 滤波器 ID
 * @return 1 有效，0 无效
 */
public func alIsFilter_cj(filter: UInt32): UInt8 {
    unsafe {
        alIsFilter(filter)
    }
}

/**
 * @brief 设置滤波器整型参数
 * @param filter 滤波器 ID
 * @param param 参数标识（AL_FILTER_TYPE 等）
 * @param iValue 参数值
 */
public func alFilteri_cj(filter: UInt32, param: UInt32, iValue: Int32): Unit {
    unsafe {
        alFilteri(filter, param, iValue)
    }
}

/**
 * @brief 设置滤波器整型数组参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param piValues 数组指针
 */
public func alFilteriv_cj(filter: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alFilteriv(filter, param, piValues)
    }
}

/**
 * @brief 设置滤波器浮点参数
 * @param filter 滤波器 ID
 * @param param 参数标识（AL_LOWPASS_GAIN 等）
 * @param flValue 参数值
 */
public func alFilterf_cj(filter: UInt32, param: UInt32, flValue: Float32): Unit {
    unsafe {
        alFilterf(filter, param, flValue)
    }
}

/**
 * @brief 设置滤波器浮点数组参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param pflValues 数组指针
 */
public func alFilterfv_cj(filter: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alFilterfv(filter, param, pflValues)
    }
}

/**
 * @brief 查询滤波器整型参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param iValue 输出值指针
 */
public func alGetFilteri_cj(filter: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit {
    unsafe {
        alGetFilteri(filter, param, iValue)
    }
}

/**
 * @brief 查询滤波器整型数组参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param piValues 输出数组指针
 */
public func alGetFilteriv_cj(filter: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alGetFilteriv(filter, param, piValues)
    }
}

/**
 * @brief 查询滤波器浮点参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param flValue 输出值指针
 */
public func alGetFilterf_cj(filter: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit {
    unsafe {
        alGetFilterf(filter, param, flValue)
    }
}

/**
 * @brief 查询滤波器浮点数组参数
 * @param filter 滤波器 ID
 * @param param 参数标识
 * @param pflValues 输出数组指针
 */
public func alGetFilterfv_cj(filter: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alGetFilterfv(filter, param, pflValues)
    }
}

// =============================================================================
// Auxiliary Effect Slot objects（辅助效果槽对象）
// =============================================================================

/**
 * @brief 生成辅助效果槽对象
 * @param n 数量
 * @param effectslots 输出效果槽 ID 数组指针
 */
public func alGenAuxiliaryEffectSlots_cj(n: Int32, effectslots: CPointer<UInt32>): Unit {
    unsafe {
        alGenAuxiliaryEffectSlots(n, effectslots)
    }
}

/**
 * @brief 删除辅助效果槽对象
 * @param n 数量
 * @param effectslots 效果槽 ID 数组指针
 */
public func alDeleteAuxiliaryEffectSlots_cj(n: Int32, effectslots: CPointer<UInt32>): Unit {
    unsafe {
        alDeleteAuxiliaryEffectSlots(n, effectslots)
    }
}

/**
 * @brief 验证辅助效果槽 ID 是否有效
 * @param effectslot 效果槽 ID
 * @return 1 有效，0 无效
 */
public func alIsAuxiliaryEffectSlot_cj(effectslot: UInt32): UInt8 {
    unsafe {
        alIsAuxiliaryEffectSlot(effectslot)
    }
}

/**
 * @brief 设置辅助效果槽整型参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识（AL_EFFECTSLOT_EFFECT 等）
 * @param iValue 参数值
 */
public func alAuxiliaryEffectSloti_cj(effectslot: UInt32, param: UInt32, iValue: Int32): Unit {
    unsafe {
        alAuxiliaryEffectSloti(effectslot, param, iValue)
    }
}

/**
 * @brief 设置辅助效果槽整型数组参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param piValues 数组指针
 */
public func alAuxiliaryEffectSlotiv_cj(effectslot: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alAuxiliaryEffectSlotiv(effectslot, param, piValues)
    }
}

/**
 * @brief 设置辅助效果槽浮点参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识（AL_EFFECTSLOT_GAIN 等）
 * @param flValue 参数值
 */
public func alAuxiliaryEffectSlotf_cj(effectslot: UInt32, param: UInt32, flValue: Float32): Unit {
    unsafe {
        alAuxiliaryEffectSlotf(effectslot, param, flValue)
    }
}

/**
 * @brief 设置辅助效果槽浮点数组参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param pflValues 数组指针
 */
public func alAuxiliaryEffectSlotfv_cj(effectslot: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alAuxiliaryEffectSlotfv(effectslot, param, pflValues)
    }
}

/**
 * @brief 查询辅助效果槽整型参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param iValue 输出值指针
 */
public func alGetAuxiliaryEffectSloti_cj(effectslot: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit {
    unsafe {
        alGetAuxiliaryEffectSloti(effectslot, param, iValue)
    }
}

/**
 * @brief 查询辅助效果槽整型数组参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param piValues 输出数组指针
 */
public func alGetAuxiliaryEffectSlotiv_cj(effectslot: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit {
    unsafe {
        alGetAuxiliaryEffectSlotiv(effectslot, param, piValues)
    }
}

/**
 * @brief 查询辅助效果槽浮点参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param flValue 输出值指针
 */
public func alGetAuxiliaryEffectSlotf_cj(effectslot: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit {
    unsafe {
        alGetAuxiliaryEffectSlotf(effectslot, param, flValue)
    }
}

/**
 * @brief 查询辅助效果槽浮点数组参数
 * @param effectslot 效果槽 ID
 * @param param 参数标识
 * @param pflValues 输出数组指针
 */
public func alGetAuxiliaryEffectSlotfv_cj(effectslot: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit {
    unsafe {
        alGetAuxiliaryEffectSlotfv(effectslot, param, pflValues)
    }
}
