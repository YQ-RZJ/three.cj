/**
 * @file openalsoft4cj.al 公共函数包装
 * @brief OpenAL 核心 API（al.h）的仓颉安全包装函数
 * @explain 本文件为每个 al foreign 函数提供 `_cj` 后缀的公共包装，
 *         所有 foreign 调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。
 * @note 每个函数对应一个 C 端 al 函数，功能与 C API 一致。
 */
protected package three._vendor.openalsoft4cj.al

// =============================================================================
// Renderer State management（渲染器状态管理）
// =============================================================================

/**
 * @brief 启用能力
 * @param capability 能力枚举值（如 AL_SOURCE_SPATIALIZE_SOFT 等）
 */
public func alEnable_cj(capability: UInt32): Unit {
    unsafe {
        alEnable(capability)
    }
}

/**
 * @brief 禁用能力
 * @param capability 能力枚举值
 */
public func alDisable_cj(capability: UInt32): Unit {
    unsafe {
        alDisable(capability)
    }
}

/**
 * @brief 查询能力是否启用
 * @param capability 能力枚举值
 * @return 1 表示启用，0 表示禁用
 */
public func alIsEnabled_cj(capability: UInt32): UInt8 {
    unsafe {
        alIsEnabled(capability)
    }
}

// =============================================================================
// Context state setting（上下文状态设置）
// =============================================================================

/**
 * @brief 设置多普勒因子（全局速度缩放）
 * @param value 多普勒因子（默认 1.0）
 */
public func alDopplerFactor_cj(value: Float32): Unit {
    unsafe {
        alDopplerFactor(value)
    }
}

/**
 * @brief 设置多普勒速度（已废弃）
 * @param value 多普勒速度倍数
 */
public func alDopplerVelocity_cj(value: Float32): Unit {
    unsafe {
        alDopplerVelocity(value)
    }
}

/**
 * @brief 设置距离衰减模型
 * @param distanceModel 距离模型（DistanceModel 枚举值 / AL_INVERSE_DISTANCE 等）
 */
public func alDistanceModel_cj(distanceModel: UInt32): Unit {
    unsafe {
        alDistanceModel(distanceModel)
    }
}

// =============================================================================
// Context state retrieval（上下文状态查询）
// =============================================================================

/**
 * @brief 查询上下文字符串信息
 * @param param 查询参数（AL_VENDOR/AL_VERSION/AL_RENDERER/AL_EXTENSIONS）
 * @return C 字符串指针
 */
public func alGetString_cj(param: UInt32): CString {
    unsafe {
        alGetString(param)
    }
}

/**
 * @brief 查询布尔数组参数
 * @param param 查询参数
 * @param values 输出数组指针
 */
public func alGetBooleanv_cj(param: UInt32, values: CPointer<UInt8>): Unit {
    unsafe {
        alGetBooleanv(param, values)
    }
}

/**
 * @brief 查询整型数组参数
 * @param param 查询参数
 * @param values 输出数组指针
 */
public func alGetIntegerv_cj(param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alGetIntegerv(param, values)
    }
}

/**
 * @brief 查询浮点数组参数
 * @param param 查询参数
 * @param values 输出数组指针
 */
public func alGetFloatv_cj(param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alGetFloatv(param, values)
    }
}

/**
 * @brief 查询双精度数组参数
 * @param param 查询参数
 * @param values 输出数组指针
 */
public func alGetDoublev_cj(param: UInt32, values: CPointer<Float64>): Unit {
    unsafe {
        alGetDoublev(param, values)
    }
}

/**
 * @brief 查询单个布尔参数
 * @param param 查询参数
 * @return 1 或 0
 */
public func alGetBoolean_cj(param: UInt32): UInt8 {
    unsafe {
        alGetBoolean(param)
    }
}

/**
 * @brief 查询单个整型参数
 * @param param 查询参数
 * @return 整型值
 */
public func alGetInteger_cj(param: UInt32): Int32 {
    unsafe {
        alGetInteger(param)
    }
}

/**
 * @brief 查询单个浮点参数
 * @param param 查询参数
 * @return 浮点值
 */
public func alGetFloat_cj(param: UInt32): Float32 {
    unsafe {
        alGetFloat(param)
    }
}

/**
 * @brief 查询单个双精度参数
 * @param param 查询参数
 * @return 双精度值
 */
public func alGetDouble_cj(param: UInt32): Float64 {
    unsafe {
        alGetDouble(param)
    }
}

/**
 * @brief 获取当前上下文最近一次错误码（读取后清除）
 * @return 错误码（ErrorCode 枚举值 / AL_NO_ERROR 等）
 */
public func alGetError_cj(): UInt32 {
    unsafe {
        alGetError()
    }
}

/**
 * @brief 查询扩展是否存在于当前上下文
 * @param extname 扩展名字符串
 * @return 1 存在，0 不存在
 */
public func alIsExtensionPresent_cj(extname: CString): UInt8 {
    unsafe {
        alIsExtensionPresent(extname)
    }
}

/**
 * @brief 获取函数地址（用于动态加载，context 特定）
 * @param fname 函数名字符串
 * @return 函数指针
 */
public func alGetProcAddress_cj(fname: CString): CPointer<Unit> {
    unsafe {
        alGetProcAddress(fname)
    }
}

/**
 * @brief 获取枚举值（context 特定）
 * @param ename 枚举名字符串
 * @return 枚举数值
 */
public func alGetEnumValue_cj(ename: CString): UInt32 {
    unsafe {
        alGetEnumValue(ename)
    }
}

// =============================================================================
// Listener parameters（监听器参数）
// =============================================================================

/**
 * @brief 设置监听器浮点参数
 * @param param 参数标识（AL_GAIN 等）
 * @param value 参数值
 */
public func alListenerf_cj(param: UInt32, value: Float32): Unit {
    unsafe {
        alListenerf(param, value)
    }
}

/**
 * @brief 设置监听器三维浮点参数
 * @param param 参数标识（AL_POSITION/AL_VELOCITY 等）
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alListener3f_cj(param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit {
    unsafe {
        alListener3f(param, value1, value2, value3)
    }
}

/**
 * @brief 设置监听器浮点数组参数
 * @param param 参数标识（AL_ORIENTATION 等）
 * @param values 数组指针
 */
public func alListenerfv_cj(param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alListenerfv(param, values)
    }
}

/**
 * @brief 设置监听器整型参数
 * @param param 参数标识
 * @param value 参数值
 */
public func alListeneri_cj(param: UInt32, value: Int32): Unit {
    unsafe {
        alListeneri(param, value)
    }
}

/**
 * @brief 设置监听器三维整型参数
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alListener3i_cj(param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit {
    unsafe {
        alListener3i(param, value1, value2, value3)
    }
}

/**
 * @brief 设置监听器整型数组参数
 * @param param 参数标识
 * @param values 数组指针
 */
public func alListeneriv_cj(param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alListeneriv(param, values)
    }
}

/**
 * @brief 查询监听器浮点参数
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetListenerf_cj(param: UInt32, value: CPointer<Float32>): Unit {
    unsafe {
        alGetListenerf(param, value)
    }
}

/**
 * @brief 查询监听器三维浮点参数
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetListener3f_cj(param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit {
    unsafe {
        alGetListener3f(param, value1, value2, value3)
    }
}

/**
 * @brief 查询监听器浮点数组参数
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetListenerfv_cj(param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alGetListenerfv(param, values)
    }
}

/**
 * @brief 查询监听器整型参数
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetListeneri_cj(param: UInt32, value: CPointer<Int32>): Unit {
    unsafe {
        alGetListeneri(param, value)
    }
}

/**
 * @brief 查询监听器三维整型参数
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetListener3i_cj(param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit {
    unsafe {
        alGetListener3i(param, value1, value2, value3)
    }
}

/**
 * @brief 查询监听器整型数组参数
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetListeneriv_cj(param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alGetListeneriv(param, values)
    }
}

// =============================================================================
// Source objects（源对象）
// =============================================================================

/**
 * @brief 生成源对象
 * @param n 数量
 * @param sources 输出源 ID 数组指针
 */
public func alGenSources_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alGenSources(n, sources)
    }
}

/**
 * @brief 删除源对象
 * @param n 数量
 * @param sources 源 ID 数组指针
 */
public func alDeleteSources_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alDeleteSources(n, sources)
    }
}

/**
 * @brief 验证源 ID 是否有效
 * @param source 源 ID
 * @return 1 有效，0 无效
 */
public func alIsSource_cj(source: UInt32): UInt8 {
    unsafe {
        alIsSource(source)
    }
}

/**
 * @brief 设置源浮点参数
 * @param source 源 ID
 * @param param 参数标识（AL_PITCH/AL_GAIN 等）
 * @param value 参数值
 */
public func alSourcef_cj(source: UInt32, param: UInt32, value: Float32): Unit {
    unsafe {
        alSourcef(source, param, value)
    }
}

/**
 * @brief 设置源三维浮点参数
 * @param source 源 ID
 * @param param 参数标识（AL_POSITION/AL_VELOCITY/AL_DIRECTION 等）
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alSource3f_cj(source: UInt32, param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit {
    unsafe {
        alSource3f(source, param, value1, value2, value3)
    }
}

/**
 * @brief 设置源浮点数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alSourcefv_cj(source: UInt32, param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alSourcefv(source, param, values)
    }
}

/**
 * @brief 设置源整型参数
 * @param source 源 ID
 * @param param 参数标识（AL_BUFFER/AL_LOOPING 等）
 * @param value 参数值
 */
public func alSourcei_cj(source: UInt32, param: UInt32, value: Int32): Unit {
    unsafe {
        alSourcei(source, param, value)
    }
}

/**
 * @brief 设置源三维整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alSource3i_cj(source: UInt32, param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit {
    unsafe {
        alSource3i(source, param, value1, value2, value3)
    }
}

/**
 * @brief 设置源整型数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alSourceiv_cj(source: UInt32, param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alSourceiv(source, param, values)
    }
}

/**
 * @brief 查询源浮点参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetSourcef_cj(source: UInt32, param: UInt32, value: CPointer<Float32>): Unit {
    unsafe {
        alGetSourcef(source, param, value)
    }
}

/**
 * @brief 查询源三维浮点参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetSource3f_cj(source: UInt32, param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit {
    unsafe {
        alGetSource3f(source, param, value1, value2, value3)
    }
}

/**
 * @brief 查询源浮点数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetSourcefv_cj(source: UInt32, param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alGetSourcefv(source, param, values)
    }
}

/**
 * @brief 查询源整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetSourcei_cj(source: UInt32, param: UInt32, value: CPointer<Int32>): Unit {
    unsafe {
        alGetSourcei(source, param, value)
    }
}

/**
 * @brief 查询源三维整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetSource3i_cj(source: UInt32, param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit {
    unsafe {
        alGetSource3i(source, param, value1, value2, value3)
    }
}

/**
 * @brief 查询源整型数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetSourceiv_cj(source: UInt32, param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alGetSourceiv(source, param, values)
    }
}

/**
 * @brief 播放源（设置状态为 AL_PLAYING）
 * @param source 源 ID
 */
public func alSourcePlay_cj(source: UInt32): Unit {
    unsafe {
        alSourcePlay(source)
    }
}

/**
 * @brief 停止源（若播放/暂停则置为 AL_STOPPED）
 * @param source 源 ID
 */
public func alSourceStop_cj(source: UInt32): Unit {
    unsafe {
        alSourceStop(source)
    }
}

/**
 * @brief 回卷源（置为 AL_INITIAL）
 * @param source 源 ID
 */
public func alSourceRewind_cj(source: UInt32): Unit {
    unsafe {
        alSourceRewind(source)
    }
}

/**
 * @brief 暂停源（若播放则置为 AL_PAUSED）
 * @param source 源 ID
 */
public func alSourcePause_cj(source: UInt32): Unit {
    unsafe {
        alSourcePause(source)
    }
}

/**
 * @brief 原子地播放一组源
 * @param n 源数量
 * @param sources 源 ID 数组指针
 */
public func alSourcePlayv_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alSourcePlayv(n, sources)
    }
}

/**
 * @brief 原子地停止一组源
 * @param n 源数量
 * @param sources 源 ID 数组指针
 */
public func alSourceStopv_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alSourceStopv(n, sources)
    }
}

/**
 * @brief 原子地回卷一组源
 * @param n 源数量
 * @param sources 源 ID 数组指针
 */
public func alSourceRewindv_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alSourceRewindv(n, sources)
    }
}

/**
 * @brief 原子地暂停一组源
 * @param n 源数量
 * @param sources 源 ID 数组指针
 */
public func alSourcePausev_cj(n: Int32, sources: CPointer<UInt32>): Unit {
    unsafe {
        alSourcePausev(n, sources)
    }
}

/**
 * @brief 向源排队缓冲
 * @param source 源 ID
 * @param nb 缓冲数量
 * @param buffers 缓冲 ID 数组指针
 */
public func alSourceQueueBuffers_cj(source: UInt32, nb: Int32, buffers: CPointer<UInt32>): Unit {
    unsafe {
        alSourceQueueBuffers(source, nb, buffers)
    }
}

/**
 * @brief 从源取回已处理缓冲
 * @param source 源 ID
 * @param nb 缓冲数量
 * @param buffers 输出缓冲 ID 数组指针
 */
public func alSourceUnqueueBuffers_cj(source: UInt32, nb: Int32, buffers: CPointer<UInt32>): Unit {
    unsafe {
        alSourceUnqueueBuffers(source, nb, buffers)
    }
}

// =============================================================================
// Buffer objects（缓冲对象）
// =============================================================================

/**
 * @brief 生成缓冲对象
 * @param n 数量
 * @param buffers 输出缓冲 ID 数组指针
 */
public func alGenBuffers_cj(n: Int32, buffers: CPointer<UInt32>): Unit {
    unsafe {
        alGenBuffers(n, buffers)
    }
}

/**
 * @brief 删除缓冲对象
 * @param n 数量
 * @param buffers 缓冲 ID 数组指针
 */
public func alDeleteBuffers_cj(n: Int32, buffers: CPointer<UInt32>): Unit {
    unsafe {
        alDeleteBuffers(n, buffers)
    }
}

/**
 * @brief 验证缓冲 ID 是否有效（含 NULL 缓冲）
 * @param buffer 缓冲 ID
 * @return 1 有效，0 无效
 */
public func alIsBuffer_cj(buffer: UInt32): UInt8 {
    unsafe {
        alIsBuffer(buffer)
    }
}

/**
 * @brief 向缓冲填充 PCM 数据
 * @param buffer 缓冲 ID
 * @param format 采样格式（BufferFormat 枚举值）
 * @param data PCM 数据指针
 * @param size 数据字节数
 * @param samplerate 采样率（Hz）
 */
public func alBufferData_cj(buffer: UInt32, format: UInt32, data: CPointer<Unit>, size: Int32, samplerate: Int32): Unit {
    unsafe {
        alBufferData(buffer, format, data, size, samplerate)
    }
}

/**
 * @brief 设置缓冲浮点参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value 参数值
 */
public func alBufferf_cj(buffer: UInt32, param: UInt32, value: Float32): Unit {
    unsafe {
        alBufferf(buffer, param, value)
    }
}

/**
 * @brief 设置缓冲三维浮点参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alBuffer3f_cj(buffer: UInt32, param: UInt32, value1: Float32, value2: Float32, value3: Float32): Unit {
    unsafe {
        alBuffer3f(buffer, param, value1, value2, value3)
    }
}

/**
 * @brief 设置缓冲浮点数组参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alBufferfv_cj(buffer: UInt32, param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alBufferfv(buffer, param, values)
    }
}

/**
 * @brief 设置缓冲整型参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value 参数值
 */
public func alBufferi_cj(buffer: UInt32, param: UInt32, value: Int32): Unit {
    unsafe {
        alBufferi(buffer, param, value)
    }
}

/**
 * @brief 设置缓冲三维整型参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alBuffer3i_cj(buffer: UInt32, param: UInt32, value1: Int32, value2: Int32, value3: Int32): Unit {
    unsafe {
        alBuffer3i(buffer, param, value1, value2, value3)
    }
}

/**
 * @brief 设置缓冲整型数组参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alBufferiv_cj(buffer: UInt32, param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alBufferiv(buffer, param, values)
    }
}

/**
 * @brief 查询缓冲浮点参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetBufferf_cj(buffer: UInt32, param: UInt32, value: CPointer<Float32>): Unit {
    unsafe {
        alGetBufferf(buffer, param, value)
    }
}

/**
 * @brief 查询缓冲三维浮点参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetBuffer3f_cj(buffer: UInt32, param: UInt32, value1: CPointer<Float32>, value2: CPointer<Float32>, value3: CPointer<Float32>): Unit {
    unsafe {
        alGetBuffer3f(buffer, param, value1, value2, value3)
    }
}

/**
 * @brief 查询缓冲浮点数组参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetBufferfv_cj(buffer: UInt32, param: UInt32, values: CPointer<Float32>): Unit {
    unsafe {
        alGetBufferfv(buffer, param, values)
    }
}

/**
 * @brief 查询缓冲整型参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetBufferi_cj(buffer: UInt32, param: UInt32, value: CPointer<Int32>): Unit {
    unsafe {
        alGetBufferi(buffer, param, value)
    }
}

/**
 * @brief 查询缓冲三维整型参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetBuffer3i_cj(buffer: UInt32, param: UInt32, value1: CPointer<Int32>, value2: CPointer<Int32>, value3: CPointer<Int32>): Unit {
    unsafe {
        alGetBuffer3i(buffer, param, value1, value2, value3)
    }
}

/**
 * @brief 查询缓冲整型数组参数
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetBufferiv_cj(buffer: UInt32, param: UInt32, values: CPointer<Int32>): Unit {
    unsafe {
        alGetBufferiv(buffer, param, values)
    }
}

// =============================================================================
// 1.1 API
// =============================================================================

/**
 * @brief 设置声速
 * @param value 声速（单位/秒，默认 343.3）
 */
public func alSpeedOfSound_cj(value: Float32): Unit {
    unsafe {
        alSpeedOfSound(value)
    }
}

// =============================================================================
// alext.h 扩展：AL_SOFT / AL_EXT 系列
// =============================================================================

/**
 * @brief 更新缓冲的部分数据（AL_SOFT_buffer_sub_data）
 * @param buffer 缓冲 ID
 * @param format 采样格式
 * @param data 新数据指针
 * @param offset 字节偏移
 * @param length 数据长度（字节）
 */
public func alBufferSubDataSOFT_cj(buffer: UInt32, format: UInt32, data: CPointer<Unit>, offset: Int32, length: Int32): Unit {
    unsafe {
        alBufferSubDataSOFT(buffer, format, data, offset, length)
    }
}

/**
 * @brief 以指定格式向缓冲写入样本（AL_SOFT_buffer_samples）
 * @param buffer 缓冲 ID
 * @param samplerate 采样率
 * @param internalformat 内部格式
 * @param samples 样本帧数
 * @param channels 声道布局
 * @param `type` 样本类型
 * @param data 样本数据指针
 */
public func alBufferSamplesSOFT_cj(buffer: UInt32, samplerate: UInt32, internalformat: UInt32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit {
    unsafe {
        alBufferSamplesSOFT(buffer, samplerate, internalformat, samples, channels, `type`, data)
    }
}

/**
 * @brief 向缓冲的部分区域写入样本（AL_SOFT_buffer_samples）
 * @param buffer 缓冲 ID
 * @param offset 帧偏移
 * @param samples 样本帧数
 * @param channels 声道布局
 * @param `type` 样本类型
 * @param data 样本数据指针
 */
public func alBufferSubSamplesSOFT_cj(buffer: UInt32, offset: Int32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit {
    unsafe {
        alBufferSubSamplesSOFT(buffer, offset, samples, channels, `type`, data)
    }
}

/**
 * @brief 从缓冲读取样本（AL_SOFT_buffer_samples）
 * @param buffer 缓冲 ID
 * @param offset 帧偏移
 * @param samples 样本帧数
 * @param channels 声道布局
 * @param `type` 样本类型
 * @param data 输出样本数据指针
 */
public func alGetBufferSamplesSOFT_cj(buffer: UInt32, offset: Int32, samples: Int32, channels: UInt32, `type`: UInt32, data: CPointer<Unit>): Unit {
    unsafe {
        alGetBufferSamplesSOFT(buffer, offset, samples, channels, `type`, data)
    }
}

/**
 * @brief 查询缓冲格式是否受支持（AL_SOFT_buffer_samples）
 * @param format 采样格式
 * @return 1 支持，0 不支持
 */
public func alIsBufferFormatSupportedSOFT_cj(format: UInt32): UInt8 {
    unsafe {
        alIsBufferFormatSupportedSOFT(format)
    }
}

/**
 * @brief 设置源双精度参数（AL_SOFT_direct_channels_remix 等）
 * @param source 源 ID
 * @param param 参数标识
 * @param value 参数值
 */
public func alSourcedSOFT_cj(source: UInt32, param: UInt32, value: Float64): Unit {
    unsafe {
        alSourcedSOFT(source, param, value)
    }
}

/**
 * @brief 设置源三维双精度参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alSource3dSOFT_cj(source: UInt32, param: UInt32, value1: Float64, value2: Float64, value3: Float64): Unit {
    unsafe {
        alSource3dSOFT(source, param, value1, value2, value3)
    }
}

/**
 * @brief 设置源双精度数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alSourcedvSOFT_cj(source: UInt32, param: UInt32, values: CPointer<Float64>): Unit {
    unsafe {
        alSourcedvSOFT(source, param, values)
    }
}

/**
 * @brief 查询源双精度参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetSourcedSOFT_cj(source: UInt32, param: UInt32, value: CPointer<Float64>): Unit {
    unsafe {
        alGetSourcedSOFT(source, param, value)
    }
}

/**
 * @brief 查询源三维双精度参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetSource3dSOFT_cj(source: UInt32, param: UInt32, value1: CPointer<Float64>, value2: CPointer<Float64>, value3: CPointer<Float64>): Unit {
    unsafe {
        alGetSource3dSOFT(source, param, value1, value2, value3)
    }
}

/**
 * @brief 查询源双精度数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetSourcedvSOFT_cj(source: UInt32, param: UInt32, values: CPointer<Float64>): Unit {
    unsafe {
        alGetSourcedvSOFT(source, param, values)
    }
}

/**
 * @brief 设置源 64 位整型参数（AL_SOFT_source_latency 等）
 * @param source 源 ID
 * @param param 参数标识
 * @param value 参数值
 */
public func alSourcei64SOFT_cj(source: UInt32, param: UInt32, value: Int64): Unit {
    unsafe {
        alSourcei64SOFT(source, param, value)
    }
}

/**
 * @brief 设置源三维 64 位整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 第 1 分量
 * @param value2 第 2 分量
 * @param value3 第 3 分量
 */
public func alSource3i64SOFT_cj(source: UInt32, param: UInt32, value1: Int64, value2: Int64, value3: Int64): Unit {
    unsafe {
        alSource3i64SOFT(source, param, value1, value2, value3)
    }
}

/**
 * @brief 设置源 64 位整型数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 数组指针
 */
public func alSourcei64vSOFT_cj(source: UInt32, param: UInt32, values: CPointer<Int64>): Unit {
    unsafe {
        alSourcei64vSOFT(source, param, values)
    }
}

/**
 * @brief 查询源 64 位整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value 输出值指针
 */
public func alGetSourcei64SOFT_cj(source: UInt32, param: UInt32, value: CPointer<Int64>): Unit {
    unsafe {
        alGetSourcei64SOFT(source, param, value)
    }
}

/**
 * @brief 查询源三维 64 位整型参数
 * @param source 源 ID
 * @param param 参数标识
 * @param value1 输出第 1 分量
 * @param value2 输出第 2 分量
 * @param value3 输出第 3 分量
 */
public func alGetSource3i64SOFT_cj(source: UInt32, param: UInt32, value1: CPointer<Int64>, value2: CPointer<Int64>, value3: CPointer<Int64>): Unit {
    unsafe {
        alGetSource3i64SOFT(source, param, value1, value2, value3)
    }
}

/**
 * @brief 查询源 64 位整型数组参数
 * @param source 源 ID
 * @param param 参数标识
 * @param values 输出数组指针
 */
public func alGetSourcei64vSOFT_cj(source: UInt32, param: UInt32, values: CPointer<Int64>): Unit {
    unsafe {
        alGetSourcei64vSOFT(source, param, values)
    }
}

/**
 * @brief 延迟更新（AL_SOFT_deferred_updates）
 */
public func alDeferUpdatesSOFT_cj(): Unit {
    unsafe {
        alDeferUpdatesSOFT()
    }
}

/**
 * @brief 处理挂起的更新（AL_SOFT_deferred_updates）
 */
public func alProcessUpdatesSOFT_cj(): Unit {
    unsafe {
        alProcessUpdatesSOFT()
    }
}

/**
 * @brief 按索引查询扩展字符串（AL_SOFT_events 等）
 * @param pname 参数标识
 * @param index 索引
 * @return C 字符串指针
 */
public func alGetStringiSOFT_cj(pname: UInt32, index: Int32): CString {
    unsafe {
        alGetStringiSOFT(pname, index)
    }
}

/**
 * @brief 控制事件通知（AL_SOFT_events）
 * @param count 事件类型数量
 * @param types 事件类型数组指针
 * @param enable 1 启用，0 禁用
 */
public func alEventControlSOFT_cj(count: Int32, types: CPointer<UInt32>, enable: UInt8): Unit {
    unsafe {
        alEventControlSOFT(count, types, enable)
    }
}

/**
 * @brief 设置事件回调（AL_SOFT_events）
 * @param callback 事件回调函数
 * @param userParam 用户数据指针
 */
public func alEventCallbackSOFT_cj(callback: CFunc<(UInt32, UInt32, UInt32, Int32, CString, CPointer<Unit>) -> Unit>, userParam: CPointer<Unit>): Unit {
    unsafe {
        alEventCallbackSOFT(callback, userParam)
    }
}

/**
 * @brief 查询指针类型参数（AL_SOFT_events 等）
 * @param pname 参数标识
 * @return 指针值
 */
public func alGetPointerSOFT_cj(pname: UInt32): CPointer<Unit> {
    unsafe {
        alGetPointerSOFT(pname)
    }
}

/**
 * @brief 查询指针数组参数
 * @param pname 参数标识
 * @param values 输出指针数组
 */
public func alGetPointervSOFT_cj(pname: UInt32, values: CPointer<CPointer<Unit>>): Unit {
    unsafe {
        alGetPointervSOFT(pname, values)
    }
}

/**
 * @brief 设置缓冲回调（AL_SOFT_callback_buffer）
 * @param buffer 缓冲 ID
 * @param format 采样格式
 * @param freq 采样率
 * @param callback 回调函数
 * @param userptr 用户数据指针
 */
public func alBufferCallbackSOFT_cj(buffer: UInt32, format: UInt32, freq: Int32, callback: CFunc<(CPointer<Unit>, CPointer<Unit>, Int32) -> Int32>, userptr: CPointer<Unit>): Unit {
    unsafe {
        alBufferCallbackSOFT(buffer, format, freq, callback, userptr)
    }
}

/**
 * @brief 查询缓冲数据指针
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param ptr 输出指针
 */
public func alGetBufferPtrSOFT_cj(buffer: UInt32, param: UInt32, ptr: CPointer<CPointer<Unit>>): Unit {
    unsafe {
        alGetBufferPtrSOFT(buffer, param, ptr)
    }
}

/**
 * @brief 查询缓冲三个数据指针
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param ptr0 输出指针 0
 * @param ptr1 输出指针 1
 * @param ptr2 输出指针 2
 */
public func alGetBuffer3PtrSOFT_cj(buffer: UInt32, param: UInt32, ptr0: CPointer<CPointer<Unit>>, ptr1: CPointer<CPointer<Unit>>, ptr2: CPointer<CPointer<Unit>>): Unit {
    unsafe {
        alGetBuffer3PtrSOFT(buffer, param, ptr0, ptr1, ptr2)
    }
}

/**
 * @brief 查询缓冲指针数组
 * @param buffer 缓冲 ID
 * @param param 参数标识
 * @param ptr 输出指针数组
 */
public func alGetBufferPtrvSOFT_cj(buffer: UInt32, param: UInt32, ptr: CPointer<CPointer<Unit>>): Unit {
    unsafe {
        alGetBufferPtrvSOFT(buffer, param, ptr)
    }
}
