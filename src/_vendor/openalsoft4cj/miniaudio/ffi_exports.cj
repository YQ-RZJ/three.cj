/**
 * @file openalsoft4cj.miniaudio 公共函数包装
 * @brief miniaudio 解码 API 的仓颉安全包装函数
 * @explain 本文件为每个 miniaudio foreign 函数提供 `_cj` 后缀的公共包装，
 *         所有 foreign 调用被包裹在 unsafe 块中以满足仓颉 FFI 要求。
 * @note 与 al/alc/efx 子包一致，本层仅做 unsafe 包裹，参数与 C 函数一一对应，
 *         不做业务封装；解码流程（如分配缓冲、读取格式等）由调用方自行实现。
 */
protected package three._vendor.openalsoft4cj.miniaudio

/**
 * @brief 解码整个音频文件为 PCM 数据（安全包装）
 * @param pFilePath 音频文件路径（mp3/flac/ogg/wav 等）
 * @param pConfig 解码配置指针，传空指针使用默认配置（输出 s16 交错 PCM）
 * @param pFrameCountOut 输出总采样帧数指针
 * @param ppPCMFramesOut 输出 PCM 数据指针的指针（需用 ma_free_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decode_file_cj(
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32 {
    unsafe {
        ma_decode_file(pFilePath, pConfig, pFrameCountOut, ppPCMFramesOut)
    }
}

/**
 * @brief 从内存数据解码为 PCM 数据（安全包装）
 * @param pData 音频数据指针
 * @param dataSize 数据字节数
 * @param pConfig 解码配置指针，传空指针使用默认配置
 * @param pFrameCountOut 输出总采样帧数指针
 * @param ppPCMFramesOut 输出 PCM 数据指针的指针（需用 ma_free_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decode_memory_cj(
    pData: CPointer<Unit>,
    dataSize: UInt64,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32 {
    unsafe {
        ma_decode_memory(pData, dataSize, pConfig, pFrameCountOut, ppPCMFramesOut)
    }
}

/**
 * @brief 通过自定义 VFS 从文件解码为 PCM 数据（安全包装）
 * @param pVFS 虚拟文件系统指针（ma_vfs 不透明，传空指针使用默认 VFS）
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置指针，传空指针使用默认配置
 * @param pFrameCountOut 输出总采样帧数指针
 * @param ppPCMFramesOut 输出 PCM 数据指针的指针（需用 ma_free_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decode_from_vfs_cj(
    pVFS: CPointer<Unit>,
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32 {
    unsafe {
        ma_decode_from_vfs(pVFS, pFilePath, pConfig, pFrameCountOut, ppPCMFramesOut)
    }
}

/**
 * @brief 释放 miniaudio 分配的内存（安全包装）
 * @param p 由 ma_decode_file_cj 等返回的 PCM 数据指针
 * @param pAllocationCallbacks 分配回调指针，传空指针使用默认
 */
public func ma_free_cj(p: CPointer<Unit>, pAllocationCallbacks: CPointer<Unit>): Unit {
    unsafe {
        ma_free(p, pAllocationCallbacks)
    }
}

/**
 * @brief 从文件初始化解码器（安全包装）
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_file_cj(
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init_file(pFilePath, pConfig, pDecoder)
    }
}

/**
 * @brief 从宽字符文件路径初始化解码器（安全包装）
 * @param pFilePath 音频文件路径（wchar_t*，UTF-16）
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_file_w_cj(
    pFilePath: CPointer<UInt16>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init_file_w(pFilePath, pConfig, pDecoder)
    }
}

/**
 * @brief 从内存数据初始化解码器（安全包装）
 * @param pData 音频数据指针
 * @param dataSize 数据字节数
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_memory_cj(
    pData: CPointer<Unit>,
    dataSize: UInt64,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init_memory(pData, dataSize, pConfig, pDecoder)
    }
}

/**
 * @brief 通过自定义 VFS 从文件初始化解码器（安全包装）
 * @param pVFS 虚拟文件系统指针（不透明，传空指针使用默认 VFS）
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_vfs_cj(
    pVFS: CPointer<Unit>,
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init_vfs(pVFS, pFilePath, pConfig, pDecoder)
    }
}

/**
 * @brief 通过自定义 VFS 从宽字符文件路径初始化解码器（安全包装）
 * @param pVFS 虚拟文件系统指针（不透明，传空指针使用默认 VFS）
 * @param pFilePath 音频文件路径（wchar_t*，UTF-16）
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_vfs_w_cj(
    pVFS: CPointer<Unit>,
    pFilePath: CPointer<UInt16>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init_vfs_w(pVFS, pFilePath, pConfig, pDecoder)
    }
}

/**
 * @brief 使用自定义读写/寻址回调初始化解码器（安全包装）
 * @param onRead 读取回调（decoder, buf, bytesToRead, bytesRead）-> ma_result
 * @param onSeek 寻址回调（decoder, byteOffset, origin）-> ma_result
 * @param pUserData 用户数据指针
 * @param pConfig 解码配置指针，传空指针使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit_cj 释放）
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_init_cj(
    onRead: CFunc<(CPointer<Unit>, CPointer<Unit>, UInt64, CPointer<UInt64>) -> Int32>,
    onSeek: CFunc<(CPointer<Unit>, Int64, UInt32) -> Int32>,
    pUserData: CPointer<Unit>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32 {
    unsafe {
        ma_decoder_init(onRead, onSeek, pUserData, pConfig, pDecoder)
    }
}

/**
 * @brief 获取解码器当前可用 PCM 帧数（安全包装）
 * @param pDecoder 解码器句柄
 * @param pAvailableFrames 输出可用帧数指针
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_get_available_frames_cj(
    pDecoder: CPointer<Unit>,
    pAvailableFrames: CPointer<UInt64>
): Int32 {
    unsafe {
        ma_decoder_get_available_frames(pDecoder, pAvailableFrames)
    }
}

/**
 * @brief 获取解码器当前播放位置（PCM 帧数，安全包装）
 * @param pDecoder 解码器句柄
 * @param pCursor 输出当前位置（帧）指针
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_get_cursor_in_pcm_frames_cj(
    pDecoder: CPointer<Unit>,
    pCursor: CPointer<UInt64>
): Int32 {
    unsafe {
        ma_decoder_get_cursor_in_pcm_frames(pDecoder, pCursor)
    }
}

/**
 * @brief 将解码器跳转到指定 PCM 帧（安全包装）
 * @param pDecoder 解码器句柄
 * @param frameIndex 目标帧索引
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_seek_to_pcm_frame_cj(
    pDecoder: CPointer<Unit>,
    frameIndex: UInt64
): Int32 {
    unsafe {
        ma_decoder_seek_to_pcm_frame(pDecoder, frameIndex)
    }
}

/**
 * @brief 反初始化解码器（安全包装）
 * @param pDecoder 解码器句柄
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_uninit_cj(pDecoder: CPointer<Unit>): Int32 {
    unsafe {
        ma_decoder_uninit(pDecoder)
    }
}

/**
 * @brief 获取默认解码器配置（安全包装）
 * @return 默认解码器配置结构体（输出 s16 交错 PCM，声道/采样率跟随源文件）
 */
public func ma_decoder_config_init_default_cj(): MaDecoderConfig {
    unsafe {
        ma_decoder_config_init_default()
    }
}

/**
 * @brief 初始化解码器配置（安全包装）
 * @param outputFormat 输出采样格式（MaFormat 值，0=使用源格式）
 * @param outputChannels 输出声道数（0=使用源声道）
 * @param outputSampleRate 输出采样率（0=使用源采样率）
 * @return 解码器配置结构体
 */
public func ma_decoder_config_init_cj(
    outputFormat: UInt32,
    outputChannels: UInt32,
    outputSampleRate: UInt32
): MaDecoderConfig {
    unsafe {
        ma_decoder_config_init(outputFormat, outputChannels, outputSampleRate)
    }
}

/**
 * @brief 深拷贝解码器配置（安全包装）
 * @param pConfig 源配置结构体指针
 * @return 拷贝后的解码器配置结构体
 */
public func ma_decoder_config_init_copy_cj(pConfig: CPointer<MaDecoderConfig>): MaDecoderConfig {
    unsafe {
        ma_decoder_config_init_copy(pConfig)
    }
}

/**
 * @brief 获取解码器输出格式信息（安全包装）
 * @param pDecoder 解码器句柄
 * @param pFormat 输出采样格式指针（MaFormat 值）
 * @param pChannels 输出声道数指针
 * @param pSampleRate 输出采样率指针
 * @param pChannelMap 输出声道映射指针（可为空指针）
 * @param channelMapCap 声道映射缓冲容量
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_get_data_format_cj(
    pDecoder: CPointer<Unit>,
    pFormat: CPointer<UInt32>,
    pChannels: CPointer<UInt32>,
    pSampleRate: CPointer<UInt32>,
    pChannelMap: CPointer<UInt8>,
    channelMapCap: UInt64
): Int32 {
    unsafe {
        ma_decoder_get_data_format(pDecoder, pFormat, pChannels, pSampleRate, pChannelMap, channelMapCap)
    }
}

/**
 * @brief 获取解码器总 PCM 帧数（安全包装）
 * @param pDecoder 解码器句柄
 * @param pLength 输出总帧数指针
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_get_length_in_pcm_frames_cj(
    pDecoder: CPointer<Unit>,
    pLength: CPointer<UInt64>
): Int32 {
    unsafe {
        ma_decoder_get_length_in_pcm_frames(pDecoder, pLength)
    }
}

/**
 * @brief 从解码器读取 PCM 帧（安全包装）
 * @param pDecoder 解码器句柄
 * @param pFramesOut 输出 PCM 缓冲
 * @param frameCount 请求读取的帧数
 * @param pFramesRead 输出实际读取的帧数指针
 * @return ma_result 错误码（MaResult 枚举值）
 */
public func ma_decoder_read_pcm_frames_cj(
    pDecoder: CPointer<Unit>,
    pFramesOut: CPointer<Unit>,
    frameCount: UInt64,
    pFramesRead: CPointer<UInt64>
): Int32 {
    unsafe {
        ma_decoder_read_pcm_frames(pDecoder, pFramesOut, frameCount, pFramesRead)
    }
}
