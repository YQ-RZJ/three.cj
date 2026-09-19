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
 * @file[zh-cn] AudioRecorder 麦克风音频捕获（ALC capture 扩展），录音能力
 * @brief[zh-cn] 录音器：封装 OpenAL ALC 1.1 capture 扩展实现麦克风捕获
 * @explain[zh-cn] 封装 OpenAL ALC 1.1 capture 扩展（alcCaptureOpenDevice / Start / Stop / Samples）：
 * - 打开默认/指定麦克风设备（指定采样率与格式）
 * - 启动/停止捕获
 * - 查询可用采样帧数、读取 PCM 数据
 * - 关闭设备释放资源
 * 线程模型（对齐 AudioContext）：所有 ALC capture 调用经 execAudio 序列化到
 * 专用音频线程执行，与 OpenAL 播放/EFX 调用隔离。
 * 用法：
 * let recorder = AudioRecorder()
 * recorder.open(frequency: 44100, channels: 1, sampleRate: 44100)
 * recorder.start()
 * // 每帧/定时：let n = recorder.getAvailableSamples(); recorder.readSamples(buf, n)
 * recorder.stop()
 * recorder.close()
 *
 * @file[en] AudioRecorder  Microphone audio capture (ALC capture extension), recording capability
 * @brief[en] Audio recorder: wraps the OpenAL ALC 1.1 capture extension for microphone capture
 * @explain[en] Wraps the OpenAL ALC 1.1 capture extension
 * (alcCaptureOpenDevice / Start / Stop / Samples):
 * - Opens the default/specified microphone device (with sample rate and format)
 * - Starts/stops capture
 * - Queries the number of available sample frames and reads PCM data
 * - Closes the device and releases resources
 * Threading model (aligned with AudioContext): all ALC capture calls are
 * serialized onto a dedicated audio thread via execAudio, isolated from
 * OpenAL playback/EFX calls.
 * Usage:
 * let recorder = AudioRecorder()
 * recorder.open(frequency: 44100, channels: 1, sampleRate: 44100)
 * recorder.start()
 * // per frame/timer: let n = recorder.getAvailableSamples(); recorder.readSamples(buf, n)
 * recorder.stop()
 * recorder.close()
 */
package three.audio.capture

import openalsoft4cj.alc.*
import openalsoft4cj.al.*

import three.audio.device.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 麦克风音频捕获器，封装 ALC capture 扩展
 * @explain[zh-cn] 打开默认/指定麦克风设备，支持开始/停止捕获、读取 PCM 数据。
 * 所有 ALC 调用经 AudioContext.execAudio 序列化到音频线程执行。
 *
 * @brief[en] Microphone audio recorder wrapping the ALC capture extension
 * @explain[en] Opens the default/specified microphone device, supports starting/stopping
 * capture and reading PCM data. All ALC calls are serialized onto the audio
 * thread via AudioContext.execAudio.
 */
public class AudioRecorder {
    /**
     * @brief[zh-cn] 捕获设备句柄
     *
     * @brief[en] The capture device handle
     */
    private var _captureDevice: CPointer<Unit>

    /**
     * @brief[zh-cn] 是否已打开
     *
     * @brief[en] Whether the device is opened
     */
    private var _opened: Bool

    /**
     * @brief[zh-cn] 是否捕获中
     *
     * @brief[en] Whether capture is in progress
     */
    private var _recording: Bool

    /**
     * @brief[zh-cn] 采样率
     *
     * @brief[en] The sampling rate
     */
    private var _frequency: UInt32

    /**
     * @brief[zh-cn] 声道数
     *
     * @brief[en] The number of channels
     */
    private var _channels: UInt32

    /**
     * @brief[zh-cn] 采样格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16）
     *
     * @brief[en] The sample format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16)
     */
    private var _format: UInt32

    public init() {
        this._captureDevice = CPointer<Unit>()
        this._opened = false
        this._recording = false
        this._frequency = 0u32
        this._channels = 0u32
        this._format = 0u32
    }

    /**
     * @brief[zh-cn] 是否已打开捕获设备
     *
     * @brief[en] Whether the capture device is opened
     */
    public prop opened: Bool {
        get() { _opened }
    }

    /**
     * @brief[zh-cn] 是否捕获中
     *
     * @brief[en] Whether capturing is in progress
     */
    public prop recording: Bool {
        get() { _recording }
    }

    /**
     * @brief[zh-cn] 采样率（Hz）
     *
     * @brief[en] Sample rate in Hz
     */
    public prop frequency: UInt32 {
        get() { _frequency }
    }

    /**
     * @brief[zh-cn] 声道数
     *
     * @brief[en] Channel count
     */
    public prop channels: UInt32 {
        get() { _channels }
    }

    /**
     * @brief[zh-cn] 采样格式（AL_FORMAT_MONO16 / AL_FORMAT_STEREO16）
     *
     * @brief[en] Sample format (AL_FORMAT_MONO16 / AL_FORMAT_STEREO16)
     */
    public prop format: UInt32 {
        get() { _format }
    }

    /**
     * @brief[zh-cn] 获取捕获设备句柄
     * @return[zh-cn] ALC 捕获设备句柄
     *
     * @brief[en] Returns the capture device handle
     * @return[en] The ALC capture device handle
     */
    public func getCaptureDevice(): CPointer<Unit> {
        return this._captureDevice
    }

    /**
     * @brief[zh-cn] 打开默认捕获设备（麦克风）
     * @param[zh-cn] frequency 采样率（Hz，如 44100 / 48000）
     * channels 声道数（1 = 单声道 / 2 = 立体声）
     * bufferSize 内部缓冲大小（帧数，建议 4096 以上）
     * @return[zh-cn] 是否成功打开
     *
     * @brief[en] Opens the default capture device (microphone)
     * @param[en] frequency Sample rate in Hz (e.g. 44100 / 48000)
     * channels Channel count (1 = mono / 2 = stereo)
     * bufferSize Internal buffer size in frames (recommended >= 4096)
     * @return[en] Whether the device was opened successfully
     *
     * @note[zh-cn] 对应 alcCaptureOpenDevice(NULL, frequency, format, buffersize)，在音频线程内执行。
     * @note[en] Maps to alcCaptureOpenDevice(NULL, frequency, format, buffersize), executed on the audio thread.
     */
    public func open(frequency: UInt32, channels: UInt32, bufferSize!: Int32 = 8192): Bool {
        if (this._opened) { return true }
        // 注意：闭包捕获的数组须用 let 声明（var 变量不能被 lambda 捕获）
        let okBox = Array<Bool>(1, { _ => false })
        let devBox = Array<CPointer<Unit>>(1, { _ => CPointer<Unit>() })
        let freq = frequency
        let ch = channels
        let format: UInt32 = if (channels == 1u32) { AL_FORMAT_MONO16 } else { AL_FORMAT_STEREO16 }
        AudioContext.context.execAudio({ =>
            // 打开默认捕获设备
            let devName = unsafe { LibC.mallocCString("") }
            let dev = alcCaptureOpenDevice_cj(devName, freq, format, bufferSize)
            unsafe { LibC.free(devName) }

            if (dev.isNull()) {
                @LogError(["AudioRecorder", "无法打开捕获设备"])
                okBox[0] = false
                return
            }
            devBox[0] = dev
            okBox[0] = true
        })
        // 闭包内不能修改 this（lambda 不能捕获可变变量），状态在闭包外更新
        if (okBox[0]) {
            this._captureDevice = devBox[0]
            this._frequency = freq
            this._channels = ch
            this._format = format
            this._opened = true
        }
        return okBox[0]
    }

    /**
     * @brief[zh-cn] 开始捕获
     * @return[zh-cn] 是否已开始（设备已打开）
     *
     * @brief[en] Starts capturing
     * @return[en] Whether capture has started (device opened)
     *
     * @note[zh-cn] 对应 alcCaptureStart(device)。
     * @note[en] Maps to alcCaptureStart(device).
     */
    public func start(): Bool {
        if (!this._opened || this._recording) { return this._recording }
        let dev = this._captureDevice
        AudioContext.context.execAudio({ => alcCaptureStart_cj(dev) })
        this._recording = true
        return true
    }

    /**
     * @brief[zh-cn] 停止捕获（保留已捕获数据，可继续读取）
     *
     * @brief[en] Stops capturing (keeps captured data, which can still be read)
     *
     * @note[zh-cn] 对应 alcCaptureStop(device)。
     * @note[en] Maps to alcCaptureStop(device).
     */
    public func stop(): Unit {
        if (!this._opened || !this._recording) { return }
        let dev = this._captureDevice
        AudioContext.context.execAudio({ => alcCaptureStop_cj(dev) })
        this._recording = false
    }

    /**
     * @brief[zh-cn] 获取当前可读取的采样帧数
     * @return[zh-cn] 可用帧数（0 = 暂无数据）
     *
     * @brief[en] Returns the number of sample frames currently available to read
     * @return[en] Number of available frames (0 = no data yet)
     *
     * @note[zh-cn] 对应 alcGetIntegerv(device, ALC_CAPTURE_SAMPLES, 1, &n)。
     * @note[en] Maps to alcGetIntegerv(device, ALC_CAPTURE_SAMPLES, 1, &n).
     */
    public func getAvailableSamples(): Int32 {
        if (!this._opened) { return 0 }
        let dev = this._captureDevice
        let valBox = Array<Int32>(1, { _ => 0 })
        AudioContext.context.execAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(0) }
            alcGetIntegerv_cj(dev, ALC_CAPTURE_SAMPLES, 1, valPtr)
            valBox[0] = unsafe { valPtr.read() }
            unsafe { LibC.free(valPtr) }
        })
        return valBox[0]
    }

    /**
     * @brief[zh-cn] 读取捕获的 PCM 数据
     * @param[zh-cn] buffer 目标缓冲（调用方分配，大小须 ≥ samples × 声道数 × 2 字节）
     * samples 要读取的采样帧数（≤ getAvailableSamples()）
     * @return[zh-cn] 实际读取的字节数（samples × 声道数 × 2）
     *
     * @brief[en] Reads captured PCM data
     * @param[en] buffer Target buffer (caller-allocated, size must be >= samples × channels × 2 bytes)
     * samples Number of sample frames to read (<= getAvailableSamples())
     * @return[en] Number of bytes actually read (samples × channels × 2)
     *
     * @note[zh-cn] 对应 alcCaptureSamples(device, buffer, samples)；数据为 16-bit 交错 PCM。
     * @note[en] Maps to alcCaptureSamples(device, buffer, samples); the data is 16-bit
     * interleaved PCM.
     */
    public func readSamples(buffer: CPointer<UInt8>, samples: Int32): Int32 {
        if (!this._opened || samples <= 0) { return 0 }
        let dev = this._captureDevice
        AudioContext.context.execAudio({ =>
            alcCaptureSamples_cj(dev, CPointer<Unit>(buffer), samples)
        })
        return samples * Int32(this._channels) * 2
    }

    /**
     * @brief[zh-cn] 关闭捕获设备并释放资源
     *
     * @brief[en] Closes the capture device and releases resources
     *
     * @note[zh-cn] 对应 alcCaptureCloseDevice(device)。
     * @note[en] Maps to alcCaptureCloseDevice(device).
     */
    public func close(): Unit {
        if (!this._opened) { return }
        let dev = this._captureDevice
        let wasRecording = this._recording
        AudioContext.context.execAudio({ =>
            if (wasRecording) {
                alcCaptureStop_cj(dev)
            }
            alcCaptureCloseDevice_cj(dev)
        })
        this._captureDevice = CPointer<Unit>()
        this._opened = false
        this._recording = false
    }
}
