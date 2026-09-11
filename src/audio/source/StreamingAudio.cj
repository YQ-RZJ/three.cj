/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] StreamingAudio 流式音频播放源
 * @brief[zh-cn] 支持大文件/长音频分段解码与播放的流式音频
 * @explain[zh-cn] 基于 OpenAL 的 alSourceQueueBuffers/alSourceUnqueueBuffers 队列缓冲机制，
 * 结合 miniaudio 的 ma_decoder 增量读取，实现流式播放：
 * - 不一次性将整个音频解码到内存，而是按 chunk 分段读取
 * - 预生成 N 个 OpenAL Buffer 轮换使用：已播放的 buffer 出队→重新填充→入队
 * - 调用方需每帧（或定时）调用 updateStream() 喂入新数据
 * 信号流：
 * File → ma_decoder → PCM chunk → alBufferData → OpenAL Buffer Queue → Source
 * 用法：
 * let stream = StreamingAudio(listener: listener)
 * stream.load("res/bgm.mp3")
 * stream.setLoop(true)
 * stream.play()
 * 每帧调用：
 * stream.updateStream()
 *
 * @file[en] StreamingAudio streaming audio playback source
 * @brief[en] Streaming audio that plays large files / long audio by chunked decode and playback
 * @explain[en] Implements streaming playback with the OpenAL queued-buffer mechanism
 * (alSourceQueueBuffers / alSourceUnqueueBuffers) plus incremental reads from a
 * miniaudio ma_decoder:
 * - Never decodes the whole audio into memory; reads chunk by chunk
 * - Pre-allocates N OpenAL buffers that rotate: played buffers are unqueued,
 * refilled, then re-queued
 * - The caller must call updateStream() every frame (or periodically) to feed data
 * Signal flow:
 * File → ma_decoder → PCM chunk → alBufferData → OpenAL Buffer Queue → Source
 * Usage:
 * let stream = StreamingAudio(listener: listener)
 * stream.load("res/bgm.mp3")
 * stream.setLoop(true)
 * stream.play()
 * Then each frame:
 * stream.updateStream()
 *
 * @note[zh-cn] 所有 OpenAL 调用经 context.execAudio 在音频线程执行；miniaudio decoder
 * 也在音频线程内访问，避免跨线程竞争。
 * @note[en] All OpenAL calls run on the audio thread via context.execAudio; the miniaudio
 * decoder is also accessed on the audio thread to avoid cross-thread races.
 */
package three.audio.source

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import openalsoft4cj.al.*
import openalsoft4cj.miniaudio.*

import three.audio.device.*
import three.audio.listener.*
import three.utils.log.Logger

/**
 * @brief[zh-cn] 流式音频，继承 Audio
 * @explain[zh-cn] 与静态 Audio 的区别：
 * - 不调用 setBuffer（不绑定单个 AL_BUFFER），改用队列缓冲
 * - 内部维护 miniaudio decoder 进行增量解码
 * - 需定期调用 updateStream() 维持播放
 *
 * @brief[en] Streaming audio extending Audio
 * @explain[en] Differences from static Audio:
 * - Does not call setBuffer (no single AL_BUFFER is bound); uses queued buffers instead
 * - Maintains an internal miniaudio decoder for incremental decoding
 * - Requires periodic updateStream() calls to keep playing
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Audio]
public open class StreamingAudio <: Audio {
    /**
     * @brief[zh-cn] miniaudio 解码器句柄（不透明，1024 字节缓冲）
     *
     * @brief[en] The miniaudio decoder handle (opaque, 1024-byte buffer)
     */
    private var _decoder: CPointer<UInt8>

    /**
     * @brief[zh-cn] 解码器是否已初始化
     *
     * @brief[en] Whether the decoder has been initialized
     */
    private var _decoderInitialized: Bool

    /**
     * @brief[zh-cn] 流式缓冲区 ID 数组（N 个轮换缓冲）
     *
     * @brief[en] Array of streaming buffer IDs (N rotating buffers)
     */
    private var _streamBufferIds: CPointer<UInt32>

    /**
     * @brief[zh-cn] 流式缓冲数量
     *
     * @brief[en] The number of streaming buffers
     */
    private var _streamBufferCount: Int32

    /**
     * @brief[zh-cn] 每个分段的帧数
     *
     * @brief[en] The number of frames per chunk
     */
    private var _chunkFrameCount: UInt64

    /**
     * @brief[zh-cn] 可复用的 PCM 读取缓冲
     *
     * @brief[en] The reusable PCM read buffer
     */
    private var _pcmReadBuffer: CPointer<UInt8>

    /**
     * @brief[zh-cn] PCM 读取缓冲字节大小
     *
     * @brief[en] The size of the PCM read buffer in bytes
     */
    private var _pcmReadBufferSize: Int64

    /**
     * @brief[zh-cn] 声道数（从解码器获取）
     *
     * @brief[en] The number of channels (from the decoder)
     */
    private var _channels: UInt32

    /**
     * @brief[zh-cn] 采样率（从解码器获取）
     *
     * @brief[en] The sample rate (from the decoder)
     */
    private var _sampleRate: UInt32

    /**
     * @brief[zh-cn] OpenAL 格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16）
     *
     * @brief[en] The OpenAL format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16)
     */
    private var _format: UInt32

    /**
     * @brief[zh-cn] 是否到达文件末尾
     *
     * @brief[en] Whether the end of the file has been reached
     */
    private var _eof: Bool

    /**
     * @brief[zh-cn] 文件路径（用于 loop 时重新初始化解码器）
     *
     * @brief[en] The file path (used to reinitialize the decoder when looping)
     */
    private var _filePath: String

    /**
     * @brief[zh-cn] 创建流式音频实例
     * @param[zh-cn] listener 关联的音频监听器
     *
     * @brief[en] Creates a streaming audio instance
     * @param[en] listener The associated audio listener
     */
    public init() {
        this(listener: AudioListener())
    }
    public init(listener!: AudioListener) {
        super(listener: listener)
        this._decoder = CPointer<UInt8>()
        this._decoderInitialized = false
        this._streamBufferIds = CPointer<UInt32>()
        this._streamBufferCount = 4   // 4 个轮换缓冲
        this._chunkFrameCount = 4096  // 每段 4096 帧
        this._pcmReadBuffer = CPointer<UInt8>()
        this._pcmReadBufferSize = 0
        this._channels = 0u32
        this._sampleRate = 0u32
        this._format = 0u32
        this._eof = false
        this._filePath = ""
        // 流式音频不使用 setBuffer 的静态缓冲机制
        this.sourceType = "streaming"
    }

    /**
     * @brief[zh-cn] 加载音频文件并初始化流式解码器
     * @param[zh-cn] filePath 音频文件路径（mp3/flac/ogg/wav 等）
     * @return[zh-cn] this（便于链式调用）
     * @explain[zh-cn] 在音频线程初始化 miniaudio 解码器，获取格式信息，生成流式缓冲并
     * 分配 PCM 读取缓冲。
     *
     * @brief[en] Loads an audio file and initializes the streaming decoder
     * @param[en] filePath Audio file path (mp3/flac/ogg/wav, etc.)
     * @return[en] this (for chaining)
     * @explain[en] Initializes the miniaudio decoder on the audio thread, reads the format
     * info, generates the streaming buffers and allocates the PCM read buffer.
     */
    public func load(filePath: String): StreamingAudio {
        if (!this.context.initialized) { return this }

        this._filePath = filePath
        let pathCs = unsafe { LibC.mallocCString(filePath) }
        let bufCount = this._streamBufferCount

        this.context.execAudio({ =>
            // 分配并初始化解码器
            this._decoder = unsafe { LibC.malloc<UInt8>(count: 1024) }
            let result = ma_decoder_init_file_cj(pathCs, CPointer<Unit>(), CPointer<Unit>(this._decoder))
            if (result != MaResult.Success.value()) {
                Logger.error(["StreamingAudio", "解码器初始化失败: ${filePath}, 错误码=${result.toString()}"])
                unsafe { LibC.free(this._decoder) }
                this._decoder = CPointer<UInt8>()
                return
            }
            this._decoderInitialized = true

            // 获取格式信息
            let fmtPtr = unsafe { LibC.malloc<UInt32>() }
            let chPtr = unsafe { LibC.malloc<UInt32>() }
            let srPtr = unsafe { LibC.malloc<UInt32>() }
            ma_decoder_get_data_format_cj(
                CPointer<Unit>(this._decoder), fmtPtr, chPtr, srPtr,
                CPointer<UInt8>(), 0
            )
            this._channels = unsafe { chPtr.read() }
            this._sampleRate = unsafe { srPtr.read() }
            unsafe { LibC.free(fmtPtr) }
            unsafe { LibC.free(chPtr) }
            unsafe { LibC.free(srPtr) }

            // 确定 OpenAL 格式（流式固定使用 s16 交错）
            this._format = if (this._channels == 1u32) { AL_FORMAT_MONO16 } else { AL_FORMAT_STEREO16 }

            // 生成流式缓冲
            this._streamBufferIds = unsafe { LibC.malloc<UInt32>(count: Int64(bufCount)) }
            alGenBuffers_cj(bufCount, this._streamBufferIds)

            // 分配 PCM 读取缓冲：chunkFrames × channels × 2 bytes(s16)
            this._pcmReadBufferSize = Int64(this._chunkFrameCount) * Int64(this._channels) * 2
            this._pcmReadBuffer = unsafe { LibC.malloc<UInt8>(count: this._pcmReadBufferSize) }
        })

        unsafe { LibC.free(pathCs) }
        this._eof = false
        return this
    }

    /**
     * @brief[zh-cn] 重写：创建流式源（不绑定单个 AL_BUFFER，改用队列）
     * @explain[zh-cn] 重写 Audio._createSource，跳过缓冲绑定，仅生成源并设置
     * AL_ROLLOFF_FACTOR 与 AL_SOURCE_RELATIVE。
     *
     * @brief[en] Override: creates the streaming source (no single AL_BUFFER bound; uses a queue instead)
     * @explain[en] Overrides Audio._createSource to skip buffer binding; only generates the
     * source and sets AL_ROLLOFF_FACTOR and AL_SOURCE_RELATIVE.
     */
    protected override func _createSource(): Unit {
        if (!this.context.initialized) { return }
        this.context.execAudio({ =>
            let srcPtr = unsafe { LibC.malloc<UInt32>() }
            alGenSources_cj(1, srcPtr)
            this.sourceId = unsafe { srcPtr.read() }
            unsafe { LibC.free(srcPtr) }
            // 不绑定 AL_BUFFER — 流式播放使用队列缓冲
            alSourcef_cj(this.sourceId, AL_ROLLOFF_FACTOR, 0.0f32)
            alSourcei_cj(this.sourceId, AL_SOURCE_RELATIVE, 1)
        })
    }

    /**
     * @brief[zh-cn] 重写：播放流式音频
     * @param[zh-cn] offset 播放起始偏移（秒，流式播放时被忽略）
     * @return[zh-cn] this（Audio 类型）
     * @explain[zh-cn] 重写 Audio.play，先填充初始缓冲队列再播放。
     *
     * @brief[en] Override: plays the streaming audio
     * @param[en] offset Playback start offset (seconds; ignored for streaming playback)
     * @return[en] this (of type Audio)
     * @explain[en] Overrides Audio.play: fills the initial buffer queue before playing.
     */
    public override func play(offset: Float64): Audio {
        if (!this.context.initialized) { return this }
        if (this.isPlaying) { return this }
        if (!this.hasPlaybackControl) { return this }
        if (!this._decoderInitialized) { return this }

        if (this.sourceId == 0u32) {
            this._createSource()
        }

        // 填充初始缓冲队列
        this._fillInitialBuffers()

        let srcId = this.sourceId
        let gainVal = Float32(this.gain * this.listener.gain)
        let pitchVal = Float32(this.playbackRate)
        let loopVal = Int32(if (this.loop) { 1 } else { 0 })
        this.isPlaying = true
        this.context.execAudio({ =>
            alSourcef_cj(srcId, AL_GAIN, gainVal)
            alSourcef_cj(srcId, AL_PITCH, pitchVal)
            alSourcei_cj(srcId, AL_LOOPING, loopVal)
            alSourcePlay_cj(srcId)
        })
        return this
    }

    /**
     * @brief[zh-cn] 重写：停止流式播放并重置解码器到起始位置
     * @return[zh-cn] this（Audio 类型）
     *
     * @brief[en] Override: stops streaming playback and resets the decoder to the start
     * @return[en] this (of type Audio)
     */
    public override func stop(): Audio {
        if (!this.hasPlaybackControl) { return this }
        if (this.sourceId != 0u32) {
            let srcId = this.sourceId
            // 停止并清空队列
            this.context.execAudio({ =>
                alSourceStop_cj(srcId)
                // 清空所有已排队的缓冲
                var queued: Int32 = 1
                let qBuf = unsafe { LibC.malloc<UInt32>(count: Int64(this._streamBufferCount)) }
                while (queued > 0) {
                    let qPtr = unsafe { LibC.malloc<Int32>() }
                    alGetSourcei_cj(srcId, AL_BUFFERS_QUEUED, qPtr)
                    queued = unsafe { qPtr.read() }
                    unsafe { LibC.free(qPtr) }
                    if (queued > 0) {
                        alSourceUnqueueBuffers_cj(srcId, queued, qBuf)
                    }
                }
                unsafe { LibC.free(qBuf) }
            })
        }
        this.isPlaying = false
        this.offset = 0.0
        this._eof = false
        // 重新初始化解码器到起始位置（miniaudio 无通用 seek-to-start，
        // 采用 uninit + init_file 重置）
        this._resetDecoder()
        return this
    }

    /**
     * @brief[zh-cn] 更新流：出队已播放缓冲 → 重新填充 → 入队
     * @return[zh-cn] this（便于链式调用）
     * @explain[zh-cn] 调用方应每帧（或定时）调用此方法以维持播放连续性。若解码器已到
     * EOF 且非循环，播放将自然结束。
     *
     * @brief[en] Updates the stream: unqueues played buffers, refills them, and re-queues
     * @return[en] this (for chaining)
     * @explain[en] The caller should call this method every frame (or periodically) to keep
     * playback continuous. If the decoder reaches EOF and looping is disabled, the
     * playback ends naturally.
     */
    public func updateStream(): StreamingAudio {
        if (!this.isPlaying) { return this }
        if (this.sourceId == 0u32) { return this }
        if (!this._decoderInitialized) { return this }

        let srcId = this.sourceId
        let decoder = this._decoder
        let pcmBuf = this._pcmReadBuffer
        let chunkFrames = this._chunkFrameCount
        let channels = this._channels
        let format = this._format
        let sampleRate = Int32(this._sampleRate)
        let isLoop = this.loop

        this.context.execAudio({ =>
            // 查询已处理的缓冲数
            let procPtr = unsafe { LibC.malloc<Int32>() }
            alGetSourcei_cj(srcId, AL_BUFFERS_PROCESSED, procPtr)
            let processed = unsafe { procPtr.read() }
            unsafe { LibC.free(procPtr) }

            if (processed > 0) {
                // 出队已处理的缓冲
                let unqBuf = unsafe { LibC.malloc<UInt32>(count: Int64(processed)) }
                alSourceUnqueueBuffers_cj(srcId, processed, unqBuf)

                for (i in 0..processed) {
                    let bufId = unsafe { (unqBuf + Int64(i)).read() }

                    if (!this._eof) {
                        // 从解码器读取 PCM
                        let framesReadPtr = unsafe { LibC.malloc<UInt64>() }
                        unsafe { framesReadPtr.write(0u64) }
                        ma_decoder_read_pcm_frames_cj(
                            CPointer<Unit>(decoder), CPointer<Unit>(pcmBuf),
                            chunkFrames, framesReadPtr
                        )
                        let actualFrames = unsafe { framesReadPtr.read() }
                        unsafe { LibC.free(framesReadPtr) }

                        if (actualFrames > 0u64) {
                            let dataSize = Int32(Int64(actualFrames) * Int64(channels) * 2)
                            alBufferData_cj(bufId, format, CPointer<Unit>(pcmBuf), dataSize, sampleRate)
                            // 重新入队
                            let qPtr = unsafe { LibC.malloc<UInt32>() }
                            unsafe { qPtr.write(bufId) }
                            alSourceQueueBuffers_cj(srcId, 1, qPtr)
                            unsafe { LibC.free(qPtr) }
                        } else {
                            // 到达 EOF
                            this._eof = true
                        }
                    }
                }
                unsafe { LibC.free(unqBuf) }
            }

            // 检查播放状态：如果队列空且 EOF，停止或循环
            if (this._eof) {
                let qPtr = unsafe { LibC.malloc<Int32>() }
                alGetSourcei_cj(srcId, AL_BUFFERS_QUEUED, qPtr)
                let stillQueued = unsafe { qPtr.read() }
                unsafe { LibC.free(qPtr) }

                if (stillQueued == 0) {
                    if (isLoop) {
                        // 循环：重置解码器并重新填充
                        this._eof = false
                        // 注意：_resetDecoder 会再次 execAudio，此处已在音频线程内，
                        // 直接调用底层解码器重置避免嵌套
                        ma_decoder_uninit_cj(CPointer<Unit>(decoder))
                        let pathCs = unsafe { LibC.mallocCString(this._filePath) }
                        ma_decoder_init_file_cj(pathCs, CPointer<Unit>(), CPointer<Unit>(decoder))
                        unsafe { LibC.free(pathCs) }
                        this._fillBuffersFromDecoder(srcId)
                        alSourcePlay_cj(srcId)
                    } else {
                        this.isPlaying = false
                    }
                }
            }
        })

        return this
    }

    /**
     * @brief[zh-cn] 填充初始缓冲队列（播放前调用）
     *
     * @brief[en] Fills the initial buffer queue (called before playback)
     */
    private func _fillInitialBuffers(): Unit {
        let srcId = this.sourceId
        this.context.execAudio({ => this._fillBuffersFromDecoder(srcId) })
    }

    /**
     * @brief[zh-cn] 从解码器读取数据填充所有流式缓冲并入队
     * @explain[zh-cn] 必须在音频线程内调用（由 _fillInitialBuffers 或 updateStream 的循环分支调用）。
     * @param[zh-cn] srcId OpenAL 源 ID
     *
     * @brief[en] Reads data from the decoder, fills all streaming buffers, and queues them
     * @explain[en] Must be called on the audio thread (invoked by _fillInitialBuffers or the loop branch of updateStream).
     * @param[en] srcId The OpenAL source ID
     */
    private func _fillBuffersFromDecoder(srcId: UInt32): Unit {
        let decoder = this._decoder
        let pcmBuf = this._pcmReadBuffer
        let chunkFrames = this._chunkFrameCount
        let channels = this._channels
        let format = this._format
        let sampleRate = Int32(this._sampleRate)
        let bufCount = this._streamBufferCount

        for (i in 0..bufCount) {
            if (this._eof) { break }

            let bufId = unsafe { (this._streamBufferIds + Int64(i)).read() }
            let framesReadPtr = unsafe { LibC.malloc<UInt64>() }
            unsafe { framesReadPtr.write(0u64) }
            ma_decoder_read_pcm_frames_cj(
                CPointer<Unit>(decoder), CPointer<Unit>(pcmBuf),
                chunkFrames, framesReadPtr
            )
            let actualFrames = unsafe { framesReadPtr.read() }
            unsafe { LibC.free(framesReadPtr) }

            if (actualFrames > 0u64) {
                let dataSize = Int32(Int64(actualFrames) * Int64(channels) * 2)
                alBufferData_cj(bufId, format, CPointer<Unit>(pcmBuf), dataSize, sampleRate)
                let qPtr = unsafe { LibC.malloc<UInt32>() }
                unsafe { qPtr.write(bufId) }
                alSourceQueueBuffers_cj(srcId, 1, qPtr)
                unsafe { LibC.free(qPtr) }
            } else {
                this._eof = true
            }
        }
    }

    /**
     * @brief[zh-cn] 重置解码器到起始位置（stop/loop 时调用）
     * @explain[zh-cn] 通过 uninit + init_file 实现，因为 miniaudio 无通用 seek-to-start。
     *
     * @brief[en] Resets the decoder to the start position (called on stop/loop)
     * @explain[en] Implemented via uninit + init_file, since miniaudio has no generic seek-to-start.
     */
    private func _resetDecoder(): Unit {
        if (!this._decoderInitialized) { return }
        let decoder = this._decoder
        let filePath = this._filePath
        this.context.execAudio({ =>
            ma_decoder_uninit_cj(CPointer<Unit>(decoder))
            let pathCs = unsafe { LibC.mallocCString(filePath) }
            let result = ma_decoder_init_file_cj(pathCs, CPointer<Unit>(), CPointer<Unit>(decoder))
            unsafe { LibC.free(pathCs) }
            if (result != MaResult.Success.value()) {
                Logger.error(["StreamingAudio", "解码器重置失败: ${filePath}"])
                this._decoderInitialized = false
            }
        })
    }

    /**
     * @brief[zh-cn] 释放流式音频资源（解码器 + 流式缓冲 + 源）
     *
     * @brief[en] Releases streaming audio resources (decoder + streaming buffers + source)
     */
    public func dispose(): Unit {
        this.stop()
        this.disconnect()

        let decoder = this._decoder
        let streamIds = this._streamBufferIds
        let bufCount = this._streamBufferCount
        let pcmBuf = this._pcmReadBuffer

        this.context.execAudio({ =>
            // 释放解码器
            if (this._decoderInitialized) {
                ma_decoder_uninit_cj(CPointer<Unit>(decoder))
                this._decoderInitialized = false
            }
            // 释放流式缓冲
            if (!streamIds.isNull()) {
                alDeleteBuffers_cj(bufCount, streamIds)
            }
            // 释放 PCM 读取缓冲
            if (!pcmBuf.isNull()) {
                unsafe { LibC.free(pcmBuf) }
            }
            // 释放解码器内存
            if (!decoder.isNull()) {
                unsafe { LibC.free(decoder) }
            }
            // 释放缓冲 ID 数组
            if (!streamIds.isNull()) {
                unsafe { LibC.free(streamIds) }
            }
        })

        this._decoder = CPointer<UInt8>()
        this._streamBufferIds = CPointer<UInt32>()
        this._pcmReadBuffer = CPointer<UInt8>()
    }
}
