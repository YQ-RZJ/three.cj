/**
 * @file openalsoft4cj.alc CFFI 函数声明（alc.h + alext.h ALC 部分）
 * @brief OpenAL Context 管理 C API 的 foreign 函数声明
 * @explain 本文件包含 alc.h 中全部函数以及 alext.h 中 ALC 扩展函数的
 *         foreign 声明。ALCdevice/ALCcontext 为不透明句柄，使用
 *         CPointer<Unit> 表示（见 types.cj）。
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 */
protected package three._vendor.openalsoft4cj.alc

// =============================================================================
// Context management（上下文管理）
// =============================================================================

foreign func alcCreateContext(device: CPointer<Unit>, attrlist: CPointer<Int32>): CPointer<Unit>

@FastNative
foreign func alcMakeContextCurrent(context: CPointer<Unit>): UInt8

@FastNative
foreign func alcProcessContext(context: CPointer<Unit>): Unit

@FastNative
foreign func alcSuspendContext(context: CPointer<Unit>): Unit

foreign func alcDestroyContext(context: CPointer<Unit>): Unit

@FastNative
foreign func alcGetCurrentContext(): CPointer<Unit>

@FastNative
foreign func alcGetContextsDevice(context: CPointer<Unit>): CPointer<Unit>

// =============================================================================
// Device management（设备管理）
// =============================================================================

foreign func alcOpenDevice(devicename: CString): CPointer<Unit>

foreign func alcCloseDevice(device: CPointer<Unit>): UInt8

// =============================================================================
// Error support（错误支持）
// =============================================================================

@FastNative
foreign func alcGetError(device: CPointer<Unit>): UInt32

// =============================================================================
// Extension support（扩展支持）
// =============================================================================

@FastNative
foreign func alcIsExtensionPresent(device: CPointer<Unit>, extname: CString): UInt8

@FastNative
foreign func alcGetProcAddress(device: CPointer<Unit>, funcname: CString): CPointer<Unit>

@FastNative
foreign func alcGetEnumValue(device: CPointer<Unit>, enumname: CString): UInt32

// =============================================================================
// Query functions（查询函数）
// =============================================================================

@FastNative
foreign func alcGetString(device: CPointer<Unit>, param: UInt32): CString

@FastNative
foreign func alcGetIntegerv(device: CPointer<Unit>, param: UInt32, size: Int32, values: CPointer<Int32>): Unit

// =============================================================================
// Capture（音频捕获，alc.h 1.0 capture 扩展）
// =============================================================================

@FastNative
foreign func alcCaptureOpenDevice(devicename: CString, frequency: UInt32, format: UInt32, buffersize: Int32): CPointer<Unit>

@FastNative
foreign func alcCaptureCloseDevice(device: CPointer<Unit>): UInt8

@FastNative
foreign func alcCaptureStart(device: CPointer<Unit>): Unit

@FastNative
foreign func alcCaptureStop(device: CPointer<Unit>): Unit

@FastNative
foreign func alcCaptureSamples(device: CPointer<Unit>, buffer: CPointer<Unit>, samples: Int32): Unit

// =============================================================================
// alext.h 扩展：ALC_SOFT / ALC_EXT 系列
// =============================================================================

@FastNative
foreign func alcSetThreadContext(context: CPointer<Unit>): UInt8

@FastNative
foreign func alcGetThreadContext(): CPointer<Unit>

@FastNative
foreign func alcLoopbackOpenDeviceSOFT(deviceName: CString): CPointer<Unit>

@FastNative
foreign func alcIsRenderFormatSupportedSOFT(device: CPointer<Unit>, freq: Int32, channels: UInt32, `type`: UInt32): UInt8

@FastNative
foreign func alcRenderSamplesSOFT(device: CPointer<Unit>, buffer: CPointer<Unit>, samples: Int32): Unit

@FastNative
foreign func alcDevicePauseSOFT(device: CPointer<Unit>): Unit

@FastNative
foreign func alcDeviceResumeSOFT(device: CPointer<Unit>): Unit

@FastNative
foreign func alcGetStringiSOFT(device: CPointer<Unit>, paramName: UInt32, index: Int32): CString

@FastNative
foreign func alcResetDeviceSOFT(device: CPointer<Unit>, attribs: CPointer<Int32>): UInt8

@FastNative
foreign func alcGetInteger64vSOFT(device: CPointer<Unit>, pname: UInt32, size: Int32, values: CPointer<Int64>): Unit
