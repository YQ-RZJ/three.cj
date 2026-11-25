/**
 * @file openalsoft4cj.efx CFFI 函数声明（efx.h）
 * @brief OpenAL EFX（Effects Extension）C API 的 foreign 函数声明
 * @explain 本文件包含 efx.h 中全部函数（Effect / Filter / AuxiliaryEffectSlot）
 *        的 foreign 声明。枚举字段使用 UInt32 底层表示。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 */
protected package three._vendor.openalsoft4cj.efx

// =============================================================================
// Effect objects（效果对象）
// =============================================================================

@FastNative
foreign func alGenEffects(n: Int32, effects: CPointer<UInt32>): Unit

@FastNative
foreign func alDeleteEffects(n: Int32, effects: CPointer<UInt32>): Unit

@FastNative
foreign func alIsEffect(effect: UInt32): UInt8

@FastNative
foreign func alEffecti(effect: UInt32, param: UInt32, iValue: Int32): Unit

@FastNative
foreign func alEffectiv(effect: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alEffectf(effect: UInt32, param: UInt32, flValue: Float32): Unit

@FastNative
foreign func alEffectfv(effect: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit

@FastNative
foreign func alGetEffecti(effect: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit

@FastNative
foreign func alGetEffectiv(effect: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alGetEffectf(effect: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit

@FastNative
foreign func alGetEffectfv(effect: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit

// =============================================================================
// Filter objects（滤波器对象）
// =============================================================================

@FastNative
foreign func alGenFilters(n: Int32, filters: CPointer<UInt32>): Unit

@FastNative
foreign func alDeleteFilters(n: Int32, filters: CPointer<UInt32>): Unit

@FastNative
foreign func alIsFilter(filter: UInt32): UInt8

@FastNative
foreign func alFilteri(filter: UInt32, param: UInt32, iValue: Int32): Unit

@FastNative
foreign func alFilteriv(filter: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alFilterf(filter: UInt32, param: UInt32, flValue: Float32): Unit

@FastNative
foreign func alFilterfv(filter: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit

@FastNative
foreign func alGetFilteri(filter: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit

@FastNative
foreign func alGetFilteriv(filter: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alGetFilterf(filter: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit

@FastNative
foreign func alGetFilterfv(filter: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit

// =============================================================================
// Auxiliary Effect Slot objects（辅助效果槽对象）
// =============================================================================

@FastNative
foreign func alGenAuxiliaryEffectSlots(n: Int32, effectslots: CPointer<UInt32>): Unit

@FastNative
foreign func alDeleteAuxiliaryEffectSlots(n: Int32, effectslots: CPointer<UInt32>): Unit

@FastNative
foreign func alIsAuxiliaryEffectSlot(effectslot: UInt32): UInt8

@FastNative
foreign func alAuxiliaryEffectSloti(effectslot: UInt32, param: UInt32, iValue: Int32): Unit

@FastNative
foreign func alAuxiliaryEffectSlotiv(effectslot: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alAuxiliaryEffectSlotf(effectslot: UInt32, param: UInt32, flValue: Float32): Unit

@FastNative
foreign func alAuxiliaryEffectSlotfv(effectslot: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit

@FastNative
foreign func alGetAuxiliaryEffectSloti(effectslot: UInt32, param: UInt32, iValue: CPointer<Int32>): Unit

@FastNative
foreign func alGetAuxiliaryEffectSlotiv(effectslot: UInt32, param: UInt32, piValues: CPointer<Int32>): Unit

@FastNative
foreign func alGetAuxiliaryEffectSlotf(effectslot: UInt32, param: UInt32, flValue: CPointer<Float32>): Unit

@FastNative
foreign func alGetAuxiliaryEffectSlotfv(effectslot: UInt32, param: UInt32, pflValues: CPointer<Float32>): Unit
