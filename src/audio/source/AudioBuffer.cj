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
 * @file[zh-cn] AudioBuffer 音频缓冲区，存储解码后的 PCM 数据
 * @brief[zh-cn] 封装 OpenAL Buffer，管理 PCM 数据的生命周期
 * @explain[zh-cn] 所有 OpenAL Buffer API 调用经 AudioContext.execAudio 序列化到
 * 音频线程，避免与其它 OpenAL 调用竞争（OpenAL context 线程局部）。
 * 流式播放支持：除静态 create 外，提供 createChunk 用于流式分段填充。
 *
 * @file[en] AudioBuffer Audio buffer that stores decoded PCM data
 * @brief[en] Wraps an OpenAL Buffer and manages the PCM data lifecycle
 * @explain[en] All OpenAL Buffer API calls are serialized onto the audio thread via
 * AudioContext.execAudio to avoid races with other OpenAL calls
 * (the OpenAL context is thread-local). For streaming playback, in addition
 * to the static create, createChunk fills buffers chunk by chunk.
 */
package three.audio.source

import openalsoft4cj.al.*
import three.core.interfaces.ILoadResult

import three.audio.device.*
import three.audio.listener.*

/**
 * @brief[zh-cn] 音频缓冲区，存储解码后的 PCM 数据
 * @explain[zh-cn] 实现 ILoadResult，供 Audio / PositionalAudio 绑定到 OpenAL 源。
 *
 * @brief[en] Audio buffer that stores decoded PCM data
 * @explain[en] Implements ILoadResult for binding to an OpenAL source via
 * Audio / PositionalAudio.
 */
public class AudioBuffer <: ILoadResult {
    /**
     * @brief[zh-cn] OpenAL 缓冲区 ID
     *
     * @brief[en] The OpenAL buffer ID
     */
    public var bufferId: UInt32

    /**
     * @brief[zh-cn] 声道数
     *
     * @brief[en] Number of channels
     */
    public var channels: UInt32

    /**
     * @brief[zh-cn] 采样率
     *
     * @brief[en] Sample rate
     */
    public var sampleRate: UInt32

    /**
     * @brief[zh-cn] 采样格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16 等）
     *
     * @brief[en] Sample format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16, etc.)
     */
    public var format: UInt32

    /**
     * @brief[zh-cn] PCM 数据总帧数
     *
     * @brief[en] Total number of PCM frames
     */
    public var frameCount: UInt64

    /**
     * @brief[zh-cn] PCM 数据字节大小
     *
     * @brief[en] PCM data size in bytes
     */
    public var dataSize: Int32

    /**
     * @brief[zh-cn] 是否已释放
     *
     * @brief[en] Whether the buffer has been disposed
     */
    private var _disposed: Bool

    /**
     * @brief[zh-cn] 创建空的音频缓冲区（随后由 create / createChunk 填充）
     *
     * @brief[en] Creates an empty audio buffer (filled later by create / createChunk)
     */
    public init() {
        this.bufferId = 0u32
        this.channels = 0u32
        this.sampleRate = 0u32
        this.format = 0u32
        this.frameCount = 0u64
        this.dataSize = 0
        this._disposed = false
    }

    /**
     * @brief[zh-cn] 根据 PCM 数据创建并填充 OpenAL 缓冲区（静态缓冲）
     * @param[zh-cn] pcmData PCM 数据指针（16-bit 交错格式）
     * frameCount 总帧数
     * channels 声道数（1=单声道, 2=立体声）
     * sampleRate 采样率
     * @return[zh-cn] 创建的 AudioBuffer 实例
     *
     * @brief[en] Creates and fills an OpenAL buffer from PCM data (static buffer)
     * @param[en] pcmData PCM data pointer (16-bit interleaved format)
     * frameCount Total number of frames
     * channels Number of channels (1=mono, 2=stereo)
     * sampleRate Sample rate
     * @return[en] The created AudioBuffer instance
     *
     * @note[zh-cn] OpenAL 调用经 context.execAudio 在音频线程执行。
     * @note[en] OpenAL calls run on the audio thread via context.execAudio.
     */
    public static func create(pcmData: CPointer<Unit>, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer {
        let buf = AudioBuffer()
        buf.channels = channels
        buf.sampleRate = sampleRate
        buf.frameCount = frameCount

        // 确定格式
        buf.format = if (channels == 1u32) { AL_FORMAT_MONO16 } else { AL_FORMAT_STEREO16 }

        AudioContext.context.execAudio({ =>
            // 生成 OpenAL 缓冲
            let bufPtr = unsafe { LibC.malloc<UInt32>() }
            alGenBuffers_cj(1, bufPtr)
            buf.bufferId = unsafe { bufPtr.read() }
            unsafe { LibC.free(bufPtr) }

            // 填充数据：s16 交错 PCM 字节数 = 帧数 × 声道数 × 2
            buf.dataSize = Int32(Int64(frameCount) * Int64(channels) * 2)
            alBufferData_cj(buf.bufferId, buf.format, pcmData, buf.dataSize, Int32(sampleRate))
        })

        return buf
    }

    /**
     * @brief[zh-cn] 创建流式分段缓冲区（用于 StreamingAudio 的队列缓冲）
     * @explain[zh-cn] 与 create 的区别：仅生成并填充一个 OpenAL Buffer，frameCount
     * 为该分段内的帧数（非整曲总帧数）。调用方负责在用完后调 dispose 释放。
     * @param[zh-cn] pcmData 该分段的 PCM 数据指针
     * frameCount 该分段的帧数
     * channels 声道数
     * sampleRate 采样率
     * @return[zh-cn] 创建的 AudioBuffer 实例（bufferId 已就绪）
     *
     * @brief[en] Creates a streaming chunk buffer (for StreamingAudio's queued buffers)
     * @explain[en] Unlike create, only generates and fills a single OpenAL Buffer;
     * frameCount is the frame count of this chunk (not the whole track).
     * The caller is responsible for calling dispose after use.
     * @param[en] pcmData The PCM data pointer of this chunk
     * frameCount The frame count of this chunk
     * channels Number of channels
     * sampleRate Sample rate
     * @return[en] The created AudioBuffer instance (bufferId is ready)
     */
    public static func createChunk(pcmData: CPointer<Unit>, frameCount: UInt64, channels: UInt32, sampleRate: UInt32): AudioBuffer {
        let buf = AudioBuffer()
        buf.channels = channels
        buf.sampleRate = sampleRate
        buf.frameCount = frameCount
        buf.format = if (channels == 1u32) { AL_FORMAT_MONO16 } else { AL_FORMAT_STEREO16 }

        AudioContext.context.execAudio({ =>
            let bufPtr = unsafe { LibC.malloc<UInt32>() }
            alGenBuffers_cj(1, bufPtr)
            buf.bufferId = unsafe { bufPtr.read() }
            unsafe { LibC.free(bufPtr) }

            buf.dataSize = Int32(Int64(frameCount) * Int64(channels) * 2)
            alBufferData_cj(buf.bufferId, buf.format, pcmData, buf.dataSize, Int32(sampleRate))
        })

        return buf
    }

    /**
     * @brief[zh-cn] 释放 OpenAL 缓冲区资源
     *
     * @brief[en] Releases the OpenAL buffer resource
     *
     * @note[zh-cn] OpenAL 调用经 context.execAudio 在音频线程执行。
     * @note[en] OpenAL calls run on the audio thread via context.execAudio.
     */
    public func dispose(): Unit {
        if (_disposed) { return }
        if (bufferId != 0u32) {
            let delId = bufferId
            AudioContext.context.execAudio({ =>
                let delPtr = unsafe { LibC.malloc<UInt32>() }
                unsafe { delPtr.write(delId) }
                alDeleteBuffers_cj(1, delPtr)
                unsafe { LibC.free(delPtr) }
            })
            bufferId = 0u32
        }
        _disposed = true
    }
}
