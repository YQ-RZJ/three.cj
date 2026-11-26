/**
 * @file openalsoft4cj.al CFFI 函数声明（al.h 核心）
 * @brief OpenAL 核心 C API 的 foreign 函数声明
 * @explain 本文件包含 al.h 中全部函数的 foreign 声明。仓颉枚举是引用类型，
 *         不满足 CType 约束，因此 ALenum/ALboolean 等 C 类型使用底层整数
 *         表示（UInt32 / UInt8），调用方通过 types.cj 中的枚举类型转换。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 */
protected package three._vendor.openalsoft4cj.al

// =============================================================================
// Renderer State management（渲染器状态管理）
// =============================================================================

@FastNative
foreign func alEnable(capability: UInt32): Unit

@FastNative
foreign func alDisable(capability: UInt32): Unit

@FastNative
foreign func alIsEnabled(capability: UInt32): UInt8

// =============================================================================
// Context state setting（上下文状态设置）
// =============================================================================

@FastNative
foreign func alDopplerFactor(value: Float32): Unit

@FastNative
foreign func alDopplerVelocity(value: Float32): Unit

@FastNative
foreign func alDistanceModel(distanceModel: UInt32): Unit

// =============================================================================
// Context state retrieval（上下文状态查询）
// =============================================================================

@FastNative
foreign func alGetString(param: UInt32): CString

@FastNative
foreign func alGetBooleanv(param: UInt32, values: CPointer<UInt8>): Unit

@FastNative
foreign func alGetIntegerv(param: UInt32, values: CPointer<Int32>): Unit

@FastNative
foreign func alGetFloatv(param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alGetDoublev(param: UInt32, values: CPointer<Float64>): Unit

@FastNative
foreign func alGetBoolean(param: UInt32): UInt8

@FastNative
foreign func alGetInteger(param: UInt32): Int32

@FastNative
foreign func alGetFloat(param: UInt32): Float32

@FastNative
foreign func alGetDouble(param: UInt32): Float64

@FastNative
foreign func alGetError(): UInt32

@FastNative
foreign func alIsExtensionPresent(extname: CString): UInt8

@FastNative
foreign func alGetProcAddress(fname: CString): CPointer<Unit>

@FastNative
foreign func alGetEnumValue(ename: CString): UInt32

// =============================================================================
// Listener parameters（监听器参数）
// =============================================================================

@FastNative
foreign func alListenerf(param: UInt32, value: Float32): Unit

@FastNative
foreign func alListener3f(param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit

@FastNative
foreign func alListenerfv(param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alListeneri(param: UInt32, value: Int32): Unit

@FastNative
foreign func alListener3i(param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit

@FastNative
foreign func alListeneriv(param: UInt32, values: CPointer<Int32>): Unit

@FastNative
foreign func alGetListenerf(param: UInt32, value: CPointer<Float32>): Unit

@FastNative
foreign func alGetListener3f(param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit

@FastNative
foreign func alGetListenerfv(param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alGetListeneri(param: UInt32, value: CPointer<Int32>): Unit

@FastNative
foreign func alGetListener3i(param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit

@FastNative
foreign func alGetListeneriv(param: UInt32, values: CPointer<Int32>): Unit

// =============================================================================
// Source objects（源对象）
// =============================================================================

@FastNative
foreign func alGenSources(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alDeleteSources(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alIsSource(source: UInt32): UInt8

@FastNative
foreign func alSourcef(source: UInt32, param: UInt32, value: Float32): Unit

@FastNative
foreign func alSource3f(source: UInt32, param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit

@FastNative
foreign func alSourcefv(source: UInt32, param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alSourcei(source: UInt32, param: UInt32, value: Int32): Unit

@FastNative
foreign func alSource3i(source: UInt32, param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit

@FastNative
foreign func alSourceiv(source: UInt32, param: UInt32, values: CPointer<Int32>): Unit

@FastNative
foreign func alGetSourcef(source: UInt32, param: UInt32, value: CPointer<Float32>): Unit

@FastNative
foreign func alGetSource3f(source: UInt32, param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit

@FastNative
foreign func alGetSourcefv(source: UInt32, param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alGetSourcei(source: UInt32, param: UInt32, value: CPointer<Int32>): Unit

@FastNative
foreign func alGetSource3i(source: UInt32, param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit

@FastNative
foreign func alGetSourceiv(source: UInt32, param: UInt32, values: CPointer<Int32>): Unit

@FastNative
foreign func alSourcePlay(source: UInt32): Unit

@FastNative
foreign func alSourceStop(source: UInt32): Unit

@FastNative
foreign func alSourceRewind(source: UInt32): Unit

@FastNative
foreign func alSourcePause(source: UInt32): Unit

@FastNative
foreign func alSourcePlayv(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alSourceStopv(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alSourceRewindv(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alSourcePausev(n: Int32, sources: CPointer<UInt32>): Unit

@FastNative
foreign func alSourceQueueBuffers(source: UInt32, nb: Int32, buffers: CPointer<UInt32>): Unit

@FastNative
foreign func alSourceUnqueueBuffers(source: UInt32, nb: Int32, buffers: CPointer<UInt32>): Unit

// =============================================================================
// Buffer objects（缓冲对象）
// =============================================================================

@FastNative
foreign func alGenBuffers(n: Int32, buffers: CPointer<UInt32>): Unit

@FastNative
foreign func alDeleteBuffers(n: Int32, buffers: CPointer<UInt32>): Unit

@FastNative
foreign func alIsBuffer(buffer: UInt32): UInt8

@FastNative
foreign func alBufferData(buffer: UInt32, format: UInt32, data: CPointer<Unit>, size: Int32, samplerate: Int32): Unit

@FastNative
foreign func alBufferf(buffer: UInt32, param: UInt32, value: Float32): Unit

@FastNative
foreign func alBuffer3f(buffer: UInt32, param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit

@FastNative
foreign func alBufferfv(buffer: UInt32, param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alBufferi(buffer: UInt32, param: UInt32, value: Int32): Unit

@FastNative
foreign func alBuffer3i(buffer: UInt32, param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit

@FastNative
foreign func alBufferiv(buffer: UInt32, param: UInt32, values: CPointer<Int32>): Unit

@FastNative
foreign func alGetBufferf(buffer: UInt32, param: UInt32, value: CPointer<Float32>): Unit

@FastNative
foreign func alGetBuffer3f(buffer: UInt32, param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit

@FastNative
foreign func alGetBufferfv(buffer: UInt32, param: UInt32, values: CPointer<Float32>): Unit

@FastNative
foreign func alGetBufferi(buffer: UInt32, param: UInt32, value: CPointer<Int32>): Unit

@FastNative
foreign func alGetBuffer3i(buffer: UInt32, param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit

@FastNative
foreign func alGetBufferiv(buffer: UInt32, param: UInt32, values: CPointer<Int32>): Unit

// =============================================================================
// 1.1 API
// =============================================================================

@FastNative
foreign func alSpeedOfSound(value: Float32): Unit

// =============================================================================
// alext.h 扩展：AL_SOFT / AL_EXT 系列
// =============================================================================

@FastNative
foreign func alBufferSubDataSOFT(buffer: UInt32, format: UInt32, data: CPointer<Unit>, offset: Int32, length: Int32): Unit

@FastNative
foreign func alBufferSamplesSOFT(buffer: UInt32, samplerate: UInt32, internalformat: UInt32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit

@FastNative
foreign func alBufferSubSamplesSOFT(buffer: UInt32, offset: Int32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit

@FastNative
foreign func alGetBufferSamplesSOFT(buffer: UInt32, offset: Int32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit

@FastNative
foreign func alIsBufferFormatSupportedSOFT(format: UInt32): UInt8

@FastNative
foreign func alSourcedSOFT(source: UInt32, param: UInt32, value: Float64): Unit

@FastNative
foreign func alSource3dSOFT(source: UInt32, param: UInt32, value1: Float64, value2: Float64, value3: Float64): Unit

@FastNative
foreign func alSourcedvSOFT(source: UInt32, param: UInt32, values: CPointer<Float64>): Unit

@FastNative
foreign func alGetSourcedSOFT(source: UInt32, param: UInt32, value: CPointer<Float64>): Unit

@FastNative
foreign func alGetSource3dSOFT(source: UInt32, param: UInt32, value1: CPointer<Float64>, value2: CPointer<Float64>, value3: CPointer<Float64>): Unit

@FastNative
foreign func alGetSourcedvSOFT(source: UInt32, param: UInt32, values: CPointer<Float64>): Unit

@FastNative
foreign func alSourcei64SOFT(source: UInt32, param: UInt32, value: Int64): Unit

@FastNative
foreign func alSource3i64SOFT(source: UInt32, param: UInt32, value1: Int64, value2: Int64, value3: Int64): Unit

@FastNative
foreign func alSourcei64vSOFT(source: UInt32, param: UInt32, values: CPointer<Int64>): Unit

@FastNative
foreign func alGetSourcei64SOFT(source: UInt32, param: UInt32, value: CPointer<Int64>): Unit

@FastNative
foreign func alGetSource3i64SOFT(source: UInt32, param: UInt32, value1: CPointer<Int64>, value2: CPointer<Int64>, value3: CPointer<Int64>): Unit

@FastNative
foreign func alGetSourcei64vSOFT(source: UInt32, param: UInt32, values: CPointer<Int64>): Unit

@FastNative
foreign func alDeferUpdatesSOFT(): Unit

@FastNative
foreign func alProcessUpdatesSOFT(): Unit

@FastNative
foreign func alGetStringiSOFT(pname: UInt32, index: Int32): CString

@FastNative
foreign func alEventControlSOFT(count: Int32, types: CPointer<UInt32>, enable: UInt8): Unit

@FastNative
foreign func alEventCallbackSOFT(callback: CFunc<(UInt32, UInt32, UInt32, Int32, CString, CPointer<Unit>) -> Unit>, userParam: CPointer<Unit>): Unit

@FastNative
foreign func alGetPointerSOFT(pname: UInt32): CPointer<Unit>

@FastNative
foreign func alGetPointervSOFT(pname: UInt32, values: CPointer<CPointer<Unit>>): Unit

@FastNative
foreign func alBufferCallbackSOFT(buffer: UInt32, format: UInt32, freq: Int32, callback: CFunc<(CPointer<Unit>, CPointer<Unit>, Int32) -> Int32>, userptr: CPointer<Unit>): Unit

@FastNative
foreign func alGetBufferPtrSOFT(buffer: UInt32, param: UInt32, ptr: CPointer<CPointer<Unit>>): Unit

@FastNative
foreign func alGetBuffer3PtrSOFT(buffer: UInt32, param: UInt32, ptr0: CPointer<CPointer<Unit>>, ptr1: CPointer<CPointer<Unit>>, ptr2: CPointer<CPointer<Unit>>): Unit

@FastNative
foreign func alGetBufferPtrvSOFT(buffer: UInt32, param: UInt32, ptr: CPointer<CPointer<Unit>>): Unit
