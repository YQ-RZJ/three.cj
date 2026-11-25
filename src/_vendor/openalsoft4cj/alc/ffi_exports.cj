/**
 * @file openalsoft4cj.alc 公共函数包装
 * @brief OpenAL Context 管理 API（alc.h）的仓颉安全包装函数
 * @explain 本文件为每个 alc foreign 函数提供 `_cj` 后缀的公共包装，
 *         所有 foreign 调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。
 * @note ALCdevice / ALCcontext 使用 CPointer<Unit> 表示不透明句柄。
 */
protected package three._vendor.openalsoft4cj.alc

// =============================================================================
// Context management（上下文管理）
// =============================================================================

/**
 * @brief 在指定设备上创建并附加一个上下文
 * @param device 设备句柄（CPointer<Unit>）
 * @param attrlist 上下文属性列表（以 0 结尾，可为空指针）
 * @return 新上下文句柄，失败返回空指针
 */
public func alcCreateContext_cj(device: CPointer<Unit>, attrlist: CPointer<Int32>): CPointer<Unit> {
    unsafe {
        alcCreateContext(device, attrlist)
    }
}

/**
 * @brief 将给定上下文设为进程级当前上下文
 * @param context 上下文句柄，空指针清除当前上下文
 * @return 成功返回 1，失败返回 0
 */
public func alcMakeContextCurrent_cj(context: CPointer<Unit>): UInt8 {
    unsafe {
        alcMakeContextCurrent(context)
    }
}

/**
 * @brief 恢复处理给定上下文的更新
 * @param context 上下文句柄
 */
public func alcProcessContext_cj(context: CPointer<Unit>): Unit {
    unsafe {
        alcProcessContext(context)
    }
}

/**
 * @brief 挂起给定上下文的更新
 * @param context 上下文句柄
 */
public func alcSuspendContext_cj(context: CPointer<Unit>): Unit {
    unsafe {
        alcSuspendContext(context)
    }
}

/**
 * @brief 从设备移除并销毁上下文
 * @param context 上下文句柄
 */
public func alcDestroyContext_cj(context: CPointer<Unit>): Unit {
    unsafe {
        alcDestroyContext(context)
    }
}

/**
 * @brief 获取当前激活的上下文
 * @return 上下文句柄，无则返回空指针
 */
public func alcGetCurrentContext_cj(): CPointer<Unit> {
    unsafe {
        alcGetCurrentContext()
    }
}

/**
 * @brief 获取上下文所属的设备
 * @param context 上下文句柄
 * @return 设备句柄
 */
public func alcGetContextsDevice_cj(context: CPointer<Unit>): CPointer<Unit> {
    unsafe {
        alcGetContextsDevice(context)
    }
}

// =============================================================================
// Device management（设备管理）
// =============================================================================

/**
 * @brief 打开指定名称的播放设备
 * @param devicename 设备名，空字符串表示默认设备
 * @return 设备句柄，失败返回空指针
 */
public func alcOpenDevice_cj(devicename: CString): CPointer<Unit> {
    unsafe {
        alcOpenDevice(devicename)
    }
}

/**
 * @brief 关闭给定播放设备
 * @param device 设备句柄
 * @return 成功返回 1，失败返回 0
 */
public func alcCloseDevice_cj(device: CPointer<Unit>): UInt8 {
    unsafe {
        alcCloseDevice(device)
    }
}

// =============================================================================
// Error support（错误支持）
// =============================================================================

/**
 * @brief 获取设备最近一次错误码
 * @param device 设备句柄（可为空指针）
 * @return 错误码（AlcErrorCode 枚举值）
 */
public func alcGetError_cj(device: CPointer<Unit>): UInt32 {
    unsafe {
        alcGetError(device)
    }
}

// =============================================================================
// Extension support（扩展支持）
// =============================================================================

/**
 * @brief 查询设备是否支持指定扩展
 * @param device 设备句柄（空指针查询设备无关扩展）
 * @param extname 扩展名字符串
 * @return 1 支持，0 不支持
 */
public func alcIsExtensionPresent_cj(device: CPointer<Unit>, extname: CString): UInt8 {
    unsafe {
        alcIsExtensionPresent(device, extname)
    }
}

/**
 * @brief 获取扩展函数地址（设备特定）
 * @param device 设备句柄
 * @param funcname 函数名字符串
 * @return 函数指针
 */
public func alcGetProcAddress_cj(device: CPointer<Unit>, funcname: CString): CPointer<Unit> {
    unsafe {
        alcGetProcAddress(device, funcname)
    }
}

/**
 * @brief 获取扩展枚举值（设备特定）
 * @param device 设备句柄
 * @param enumname 枚举名字符串
 * @return 枚举数值
 */
public func alcGetEnumValue_cj(device: CPointer<Unit>, enumname: CString): UInt32 {
    unsafe {
        alcGetEnumValue(device, enumname)
    }
}

// =============================================================================
// Query functions（查询函数）
// =============================================================================

/**
 * @brief 查询设备信息字符串
 * @param device 设备句柄
 * @param param 查询参数（ALC_DEVICE_SPECIFIER 等）
 * @return C 字符串指针
 */
public func alcGetString_cj(device: CPointer<Unit>, param: UInt32): CString {
    unsafe {
        alcGetString(device, param)
    }
}

/**
 * @brief 查询设备整型数组信息
 * @param device 设备句柄
 * @param param 查询参数
 * @param size 数组大小
 * @param values 输出数组指针
 */
public func alcGetIntegerv_cj(device: CPointer<Unit>, param: UInt32, size: Int32, values: CPointer<Int32>): Unit {
    unsafe {
        alcGetIntegerv(device, param, size, values)
    }
}

// =============================================================================
// Capture（音频捕获，alc.h 1.0 capture 扩展）
// =============================================================================

/**
 * @brief 打开音频捕获设备
 * @param devicename 设备名（空字符串/空指针表示默认设备）
 * @param frequency 采样率（Hz）
 * @param format 采样格式（AL_FORMAT_MONO16/STEREO16 等）
 * @param buffersize 内部缓冲大小（采样帧数）
 * @return 捕获设备句柄，失败返回空指针
 */
public func alcCaptureOpenDevice_cj(devicename: CString, frequency: UInt32, format: UInt32, buffersize: Int32): CPointer<Unit> {
    unsafe {
        alcCaptureOpenDevice(devicename, frequency, format, buffersize)
    }
}

/**
 * @brief 关闭音频捕获设备
 * @param device 捕获设备句柄
 * @return 成功返回 1，失败返回 0
 */
public func alcCaptureCloseDevice_cj(device: CPointer<Unit>): UInt8 {
    unsafe {
        alcCaptureCloseDevice(device)
    }
}

/**
 * @brief 开始捕获音频
 * @param device 捕获设备句柄
 */
public func alcCaptureStart_cj(device: CPointer<Unit>): Unit {
    unsafe {
        alcCaptureStart(device)
    }
}

/**
 * @brief 停止捕获音频
 * @param device 捕获设备句柄
 */
public func alcCaptureStop_cj(device: CPointer<Unit>): Unit {
    unsafe {
        alcCaptureStop(device)
    }
}

/**
 * @brief 读取已捕获的音频样本
 * @param device 捕获设备句柄
 * @param buffer 输出缓冲（PCM 数据）
 * @param samples 要读取的采样帧数
 */
public func alcCaptureSamples_cj(device: CPointer<Unit>, buffer: CPointer<Unit>, samples: Int32): Unit {
    unsafe {
        alcCaptureSamples(device, buffer, samples)
    }
}

// =============================================================================
// alext.h 扩展：ALC_SOFT / ALC_EXT 系列
// =============================================================================

/**
 * @brief 将上下文设为线程局部当前上下文（ALC_EXT_thread_local_context）
 * @param context 上下文句柄
 * @return 成功返回 1，失败返回 0
 */
public func alcSetThreadContext_cj(context: CPointer<Unit>): UInt8 {
    unsafe {
        alcSetThreadContext(context)
    }
}

/**
 * @brief 获取线程局部当前上下文（ALC_EXT_thread_local_context）
 * @return 上下文句柄，无则返回空指针
 */
public func alcGetThreadContext_cj(): CPointer<Unit> {
    unsafe {
        alcGetThreadContext()
    }
}

/**
 * @brief 打开回环设备（ALC_SOFT_loopback）
 * @param deviceName 设备名
 * @return 设备句柄，失败返回空指针
 */
public func alcLoopbackOpenDeviceSOFT_cj(deviceName: CString): CPointer<Unit> {
    unsafe {
        alcLoopbackOpenDeviceSOFT(deviceName)
    }
}

/**
 * @brief 查询回环设备是否支持指定渲染格式（ALC_SOFT_loopback）
 * @param device 设备句柄
 * @param freq 采样率
 * @param channels 声道布局
 * @param `type` 样本类型
 * @return 1 支持，0 不支持
 */
public func alcIsRenderFormatSupportedSOFT_cj(device: CPointer<Unit>, freq: Int32, channels: UInt32, `type`: UInt32): UInt8 {
    unsafe {
        alcIsRenderFormatSupportedSOFT(device, freq, channels, `type`)
    }
}

/**
 * @brief 渲染指定数量的样本到缓冲（ALC_SOFT_loopback）
 * @param device 设备句柄
 * @param buffer 输出缓冲
 * @param samples 样本帧数
 */
public func alcRenderSamplesSOFT_cj(device: CPointer<Unit>, buffer: CPointer<Unit>, samples: Int32): Unit {
    unsafe {
        alcRenderSamplesSOFT(device, buffer, samples)
    }
}

/**
 * @brief 暂停设备处理（ALC_SOFT_pause_device）
 * @param device 设备句柄
 */
public func alcDevicePauseSOFT_cj(device: CPointer<Unit>): Unit {
    unsafe {
        alcDevicePauseSOFT(device)
    }
}

/**
 * @brief 恢复设备处理（ALC_SOFT_pause_device）
 * @param device 设备句柄
 */
public func alcDeviceResumeSOFT_cj(device: CPointer<Unit>): Unit {
    unsafe {
        alcDeviceResumeSOFT(device)
    }
}

/**
 * @brief 按索引查询设备字符串（ALC_SOFT_HRTF 等）
 * @param device 设备句柄
 * @param paramName 参数标识
 * @param index 索引
 * @return C 字符串指针
 */
public func alcGetStringiSOFT_cj(device: CPointer<Unit>, paramName: UInt32, index: Int32): CString {
    unsafe {
        alcGetStringiSOFT(device, paramName, index)
    }
}

/**
 * @brief 重置设备属性（ALC_SOFT_HRTF 等）
 * @param device 设备句柄
 * @param attribs 属性列表（以 0 结尾）
 * @return 成功返回 1，失败返回 0
 */
public func alcResetDeviceSOFT_cj(device: CPointer<Unit>, attribs: CPointer<Int32>): UInt8 {
    unsafe {
        alcResetDeviceSOFT(device, attribs)
    }
}

/**
 * @brief 查询设备 64 位整型数组信息（ALC_SOFT_device_clock 等）
 * @param device 设备句柄
 * @param pname 参数标识
 * @param size 数组大小
 * @param values 输出数组指针
 */
public func alcGetInteger64vSOFT_cj(device: CPointer<Unit>, pname: UInt32, size: Int32, values: CPointer<Int64>): Unit {
    unsafe {
        alcGetInteger64vSOFT(device, pname, size, values)
    }
}
