/**
 * @file[zh-cn] AudioLoader 音频文件加载器
 * @brief[zh-cn] 对应 Three.js loaders/AudioLoader.js，使用 miniaudio 解码音频文件为 PCM 数据
 * @explain[zh-cn] Three.js 使用 Web Audio API 的 decodeAudioData 解码，Three.cj 使用 miniaudio 的 ma_decode_file_cj 解码为 16-bit PCM。解码后创建 AudioBuffer（封装 OpenAL Buffer），可直接传给 Audio/PositionalAudio。
 *
 * @file[en] AudioLoader  Audio file loader
 * @brief[en] Decodes audio files to PCM data using miniaudio
 * @explain[en] Three.js uses Web Audio API's decodeAudioData for decoding, while Three.cj uses miniaudio's ma_decode_file_cj to decode to 16-bit PCM. After decoding, creates AudioBuffer (wrapping OpenAL Buffer) that can be passed to Audio/PositionalAudio.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.audio.source.AudioBuffer
import openalsoft4cj.miniaudio.*
import openalsoft4cj.al.*
import std.io.*

/**
 * @brief[zh-cn] 音频文件加载器
 * @explain[zh-cn] 音频文件加载器，继承 Loader。使用 miniaudio 解码本地音频文件（mp3/flac/ogg/wav 等），创建 AudioBuffer 实例（封装 OpenAL Buffer）。
 *
 * @brief[en] Audio file loader
 * @explain[en] Audio file loader, extends Loader. Uses miniaudio to decode local audio files (mp3/flac/ogg/wav etc.), creating AudioBuffer instances (wrapping OpenAL Buffer).
 */
public class AudioLoader <: Loader {

    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 音频文件路径（本地路径）
     * @return[zh-cn] 解码后的 AudioBuffer 实例
     *
     * @param[en] url Audio file path (local path)
     * @return[en] Decoded AudioBuffer instance
     *
     * 加载音频文件并创建 AudioBuffer，使用 miniaudio 将音频文件解码为 16-bit PCM，然后创建 OpenAL Buffer。
     * 支持 mp3、flac、ogg、wav 等格式。
     *
     * @throws[zh-cn] Exception 文件解码失败时抛出异常
     *
     * @throws[en] Exception Thrown when file decoding fails
     */
    public func load(url: String): AudioBuffer {
        var resolvedUrl = url
        if (this.path != "") {
            resolvedUrl = this.path + resolvedUrl
        }
        resolvedUrl = this.manager.resolveURL(resolvedUrl)

        this.manager.itemStart(resolvedUrl)

        let buffer = _decodeFile(resolvedUrl)

        this.manager.itemEnd(resolvedUrl)
        return buffer
    }

    /**
     * 带回调的加载方式
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            let buffer = this.load(url)
            onLoad(buffer)
        } catch (e: Exception) {
            onError(e.toString())
        }
    }

    /**
     * @param[zh-cn] data 音频文件的完整字节数据
     * @return[zh-cn] 解码后的 AudioBuffer 实例
     *
     * @param[en] data Complete byte data of the audio file
     * @return[en] Decoded AudioBuffer instance
     *
     * 从内存字节数组加载音频并创建 AudioBuffer
     * 使用 miniaudio 的 ma_decode_memory_cj 解码（支持 mp3/flac/ogg/wav 等）。
     *
     * 用途：OHOS 平台 rawfile 资源不能通过文件系统路径访问（FileIo.access 失败），
     * 需经 resourceManager.getRawFileContent 拿到字节后走内存解码；
     * 桌面平台亦可传 File.readFrom 读出的字节。
     *
     * @throws[zh-cn] Exception 解码失败时抛出异常
     *
     * @throws[en] Exception Thrown when decoding fails
     */
    public func loadFromBytes(data: Array<UInt8>): AudioBuffer {
        if (data.size == 0) {
            throw Exception("AudioLoader: 空音频数据")
        }
        // 将字节数组拷贝到 C 堆内存（miniaudio 从内存解码需要稳定指针）
        let pData = unsafe { LibC.malloc<UInt8>(count: Int64(data.size)) }
        unsafe {
            for (i in 0..data.size) {
                (pData + i).write(data[i])
            }
        }

        // 使用 miniaudio API 创建解码配置（输出 s16 交错 PCM，声道/采样率跟随源文件）
        let config = ma_decoder_config_init_cj(MaFormat.S16.value(), 0u32, 0u32)
        let cfgPtr = unsafe { LibC.malloc<MaDecoderConfig>() }
        unsafe { cfgPtr.write(config) }

        let frameCount = unsafe { LibC.malloc<UInt64>() }
        let pcmPtr = unsafe { LibC.malloc<CPointer<Unit>>() }
        unsafe {
            pcmPtr.write(CPointer<Unit>())
        }

        let result = ma_decode_memory_cj(CPointer<Unit>(pData), UInt64(data.size),
            CPointer<Unit>(cfgPtr), frameCount, pcmPtr)

        let frames = unsafe { frameCount.read() }
        let pcm = unsafe { pcmPtr.read() }

        // 从配置结构体读回实际格式（miniaudio 在解码后会回填 channels/sampleRate）
        let finalCfg = unsafe { cfgPtr.read() }
        let channels = finalCfg.channels
        let sampleRate = finalCfg.sampleRate

        // 释放临时内存
        unsafe {
            LibC.free(pData)
            LibC.free(cfgPtr)
            LibC.free(frameCount)
            LibC.free(pcmPtr)
        }

        if (result != MaResult.Success.value()) {
            throw Exception("AudioLoader: 解码音频数据失败, 错误码=${result.toString()}")
        }

        if (channels == 0u32 || sampleRate == 0u32 || frames == 0u64) {
            // PCM 数据无效时释放
            ma_free_cj(pcm, CPointer<Unit>())
            throw Exception("AudioLoader: 解码结果无效 (channels=${channels.toString()}, sampleRate=${sampleRate.toString()}, frames=${frames.toString()})")
        }

        // 创建 AudioBuffer（内部会调用 alGenBuffers + alBufferData 拷贝数据）
        let audioBuffer = AudioBuffer.create(pcm, frames, channels, sampleRate)

        // alBufferData 已拷贝数据，释放 miniaudio 的解码缓冲
        ma_free_cj(pcm, CPointer<Unit>())

        return audioBuffer
    }

    /**
     * @param[zh-cn] filePath 音频文件路径
     * @return[zh-cn] AudioBuffer 实例
     *
     * @param[en] filePath Audio file path
     * @return[en] AudioBuffer instance
     *
     * 解码音频文件为 16-bit PCM 并创建 AudioBuffer
     * 使用 miniaudio 的 ma_decode_file_cj 一次性解码整个文件。
     */
    private func _decodeFile(filePath: String): AudioBuffer {
        // 将仓颉字符串转为 CString
        let pathCs = unsafe { LibC.mallocCString(filePath) }

        // 使用 miniaudio API 创建解码配置（输出 s16 交错 PCM，声道/采样率跟随源文件）
        let config = ma_decoder_config_init_cj(MaFormat.S16.value(), 0u32, 0u32)
        let cfgPtr = unsafe { LibC.malloc<MaDecoderConfig>() }
        unsafe { cfgPtr.write(config) }

        let frameCount = unsafe { LibC.malloc<UInt64>() }
        let pcmPtr = unsafe { LibC.malloc<CPointer<Unit>>() }
        unsafe {
            pcmPtr.write(CPointer<Unit>())
        }

        let result = ma_decode_file_cj(pathCs, CPointer<Unit>(cfgPtr), frameCount, pcmPtr)

        let frames = unsafe { frameCount.read() }
        let pcm = unsafe { pcmPtr.read() }

        // 从配置结构体读回实际格式（miniaudio 在解码后会回填 channels/sampleRate）
        let finalCfg = unsafe { cfgPtr.read() }
        let channels = finalCfg.channels
        let sampleRate = finalCfg.sampleRate

        // 释放临时内存
        unsafe {
            LibC.free(pathCs)
            LibC.free(cfgPtr)
            LibC.free(frameCount)
            LibC.free(pcmPtr)
        }

        if (result != MaResult.Success.value()) {
            throw Exception("AudioLoader: 解码音频文件失败: ${filePath}, 错误码=${result.toString()}")
        }

        if (channels == 0u32 || sampleRate == 0u32 || frames == 0u64) {
            // PCM 数据无效时释放
            ma_free_cj(pcm, CPointer<Unit>())
            throw Exception("AudioLoader: 解码结果无效 (channels=${channels.toString()}, sampleRate=${sampleRate.toString()}, frames=${frames.toString()}): ${filePath}")
        }

        // 创建 AudioBuffer（内部会调用 alGenBuffers + alBufferData 拷贝数据）
        let audioBuffer = AudioBuffer.create(pcm, frames, channels, sampleRate)

        // alBufferData 已拷贝数据，释放 miniaudio 的解码缓冲
        ma_free_cj(pcm, CPointer<Unit>())

        return audioBuffer
    }
}
