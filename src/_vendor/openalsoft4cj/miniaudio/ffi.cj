/**
 * @file openalsoft4cj.miniaudio CFFI 函数声明
 * @brief miniaudio 解码 API 的 foreign 函数声明
 * @explain 本文件包含 miniaudio 解码核心函数的 foreign 声明：
 *         - ma_decode_file: 将整个音频文件解码为内存中的 PCM
 *         - ma_decode_memory: 从内存数据解码为 PCM
 *         - ma_free: 释放 ma_decode_* 分配的内存
 *         - ma_decoder_init_file / ma_decoder_uninit: 打开/关闭解码器
 *         - ma_decoder_get_format / ma_decoder_get_length_in_pcm_frames:
 *           查询解码器格式信息
 *         - ma_decoder_read_pcm_frames: 从解码器读取 PCM 帧
 * @note 本文件的函数是包级私有，外部调用请使用 ffi_exports.cj 中的 _cj 包装。
 *       ma_decoder 为不透明句柄，FFI 层使用 CPointer<Unit> 表示
 *       （与 ALCdevice/ALCcontext 的处理方式一致）。
 *       ma_decoder_config 传 NULL 使用默认配置（输出 s16 交错 PCM）。
 */
protected package three._vendor.openalsoft4cj.miniaudio

/**
 * @brief 解码整个音频文件为 PCM 数据（一次性）
 * @param pFilePath 音频文件路径（mp3/flac/ogg/wav 等，miniaudio 自动识别）
 * @param pConfig 解码配置，传 NULL 使用默认（输出 16-bit 交错 PCM）
 * @param pFrameCountOut 输出总采样帧数
 * @param ppPCMFramesOut 输出 PCM 数据指针（由内部分配，需用 ma_free 释放）
 * @return ma_result 错误码（见 types.cj MaResult）
 */
@FastNative
foreign func ma_decode_file(
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32

/**
 * @brief 从内存数据解码为 PCM 数据（一次性）
 * @param pData 音频数据指针
 * @param dataSize 数据字节数
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pFrameCountOut 输出总采样帧数
 * @param ppPCMFramesOut 输出 PCM 数据指针（由内部分配，需用 ma_free 释放）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decode_memory(
    pData: CPointer<Unit>,
    dataSize: UInt64,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32

/**
 * @brief 通过自定义 VFS 从文件解码为 PCM 数据（一次性）
 * @param pVFS 虚拟文件系统指针（ma_vfs，不透明；传 NULL 使用默认 VFS）
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pFrameCountOut 输出总采样帧数
 * @param ppPCMFramesOut 输出 PCM 数据指针（由内部分配，需用 ma_free 释放）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decode_from_vfs(
    pVFS: CPointer<Unit>,
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pFrameCountOut: CPointer<UInt64>,
    ppPCMFramesOut: CPointer<CPointer<Unit>>
): Int32

/**
 * @brief 释放 miniaudio 分配的内存
 * @param p 由 ma_decode_* 返回的数据指针
 * @param pAllocationCallbacks 分配回调，传 NULL 使用默认
 */
@FastNative
foreign func ma_free(p: CPointer<Unit>, pAllocationCallbacks: CPointer<Unit>): Unit

/**
 * @brief 从文件初始化解码器
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 */
foreign func ma_decoder_init_file(
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 从宽字符文件路径初始化解码器
 * @param pFilePath 音频文件路径（wchar_t*，UTF-16）
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 */
foreign func ma_decoder_init_file_w(
    pFilePath: CPointer<UInt16>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 从内存数据初始化解码器
 * @param pData 音频数据指针
 * @param dataSize 数据字节数
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_init_memory(
    pData: CPointer<Unit>,
    dataSize: UInt64,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 通过自定义 VFS 从文件初始化解码器
 * @param pVFS 虚拟文件系统指针（不透明，传 NULL 使用默认 VFS）
 * @param pFilePath 音频文件路径
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_init_vfs(
    pVFS: CPointer<Unit>,
    pFilePath: CString,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 通过自定义 VFS 从宽字符文件路径初始化解码器
 * @param pVFS 虚拟文件系统指针（不透明，传 NULL 使用默认 VFS）
 * @param pFilePath 音频文件路径（wchar_t*，UTF-16）
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_init_vfs_w(
    pVFS: CPointer<Unit>,
    pFilePath: CPointer<UInt16>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 使用自定义读写/寻址回调初始化解码器
 * @param onRead 读取回调（CFunc，见 MaDecoderReadProc 语义）
 * @param onSeek 寻址回调（CFunc，见 MaDecoderSeekProc 语义）
 * @param pUserData 用户数据指针
 * @param pConfig 解码配置，传 NULL 使用默认
 * @param pDecoder 输出解码器句柄（不透明，需用 ma_decoder_uninit 释放）
 * @return ma_result 错误码
 * @note 回调签名：read = (decoder, buf, bytesToRead, bytesRead) -> ma_result；
 *       seek = (decoder, byteOffset, origin) -> ma_result
 */
@FastNative
foreign func ma_decoder_init(
    onRead: CFunc<(CPointer<Unit>, CPointer<Unit>, UInt64, CPointer<UInt64>) -> Int32>,
    onSeek: CFunc<(CPointer<Unit>, Int64, UInt32) -> Int32>,
    pUserData: CPointer<Unit>,
    pConfig: CPointer<Unit>,
    pDecoder: CPointer<Unit>
): Int32

/**
 * @brief 反初始化解码器
 * @param pDecoder 解码器句柄
 * @return ma_result 错误码
 */
foreign func ma_decoder_uninit(pDecoder: CPointer<Unit>): Int32

/**
 * @brief 获取解码器当前可用 PCM 帧数
 * @param pDecoder 解码器句柄
 * @param pAvailableFrames 输出可用帧数
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_get_available_frames(
    pDecoder: CPointer<Unit>,
    pAvailableFrames: CPointer<UInt64>
): Int32

/**
 * @brief 获取解码器当前播放位置（PCM 帧数）
 * @param pDecoder 解码器句柄
 * @param pCursor 输出当前位置（帧）
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_get_cursor_in_pcm_frames(
    pDecoder: CPointer<Unit>,
    pCursor: CPointer<UInt64>
): Int32

/**
 * @brief 将解码器跳转到指定 PCM 帧
 * @param pDecoder 解码器句柄
 * @param frameIndex 目标帧索引
 * @return ma_result 错误码
 */
foreign func ma_decoder_seek_to_pcm_frame(
    pDecoder: CPointer<Unit>,
    frameIndex: UInt64
): Int32

/**
 * @brief 获取默认解码器配置（ma_decoder_config_init_default）
 * @return 默认解码器配置结构体（输出 s16 交错 PCM，声道/采样率跟随源文件）
 */
@FastNative
foreign func ma_decoder_config_init_default(): MaDecoderConfig

/**
 * @brief 初始化解码器配置（ma_decoder_config_init）
 * @param outputFormat 输出采样格式（MaFormat 值，0=使用源格式）
 * @param outputChannels 输出声道数（0=使用源声道）
 * @param outputSampleRate 输出采样率（0=使用源采样率）
 * @return 解码器配置结构体
 */
@FastNative
foreign func ma_decoder_config_init(
    outputFormat: UInt32,
    outputChannels: UInt32,
    outputSampleRate: UInt32
): MaDecoderConfig

/**
 * @brief 深拷贝解码器配置（ma_decoder_config_init_copy）
 * @param pConfig 源配置结构体指针
 * @return 拷贝后的解码器配置结构体
 */
@FastNative
foreign func ma_decoder_config_init_copy(pConfig: CPointer<MaDecoderConfig>): MaDecoderConfig

/**
 * @brief 获取解码器输出格式信息
 * @param pDecoder 解码器句柄
 * @param pFormat 输出采样格式（MaFormat 值）
 * @param pChannels 输出声道数
 * @param pSampleRate 输出采样率
 * @param pChannelMap 输出声道映射（可为空指针）
 * @param channelMapCap 声道映射缓冲容量
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_get_data_format(
    pDecoder: CPointer<Unit>,
    pFormat: CPointer<UInt32>,
    pChannels: CPointer<UInt32>,
    pSampleRate: CPointer<UInt32>,
    pChannelMap: CPointer<UInt8>,
    channelMapCap: UInt64
): Int32

/**
 * @brief 获取解码器总 PCM 帧数
 * @param pDecoder 解码器句柄
 * @param pLength 输出总帧数
 * @return ma_result 错误码
 */
@FastNative
foreign func ma_decoder_get_length_in_pcm_frames(
    pDecoder: CPointer<Unit>,
    pLength: CPointer<UInt64>
): Int32

/**
 * @brief 从解码器读取 PCM 帧
 * @param pDecoder 解码器句柄
 * @param pFramesOut 输出 PCM 缓冲
 * @param frameCount 请求读取的帧数
 * @param pFramesRead 输出实际读取的帧数
 * @return ma_result 错误码
 */
foreign func ma_decoder_read_pcm_frames(
    pDecoder: CPointer<Unit>,
    pFramesOut: CPointer<Unit>,
    frameCount: UInt64,
    pFramesRead: CPointer<UInt64>
): Int32
