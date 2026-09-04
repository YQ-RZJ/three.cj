/**
 * @file[zh-cn] AudioContext 音频上下文单例，管理 OpenAL 设备/上下文 + 专用音频线程
 * @brief[zh-cn] 音频上下文单例：管理 OpenAL 设备/上下文与专用音频线程
 * @explain[zh-cn] 对应 Three.js 的 AudioContext（管理 Web Audio API 的 AudioContext 实例），
 * Three.cj 使用 OpenAL 的 Device + Context 作为底层实现。
 * 线程模型（对齐 BgfxRenderer._execBgfx）：
 * - 所有 OpenAL/EFX API 调用必须经 _execAudio 序列化到专用音频系统线程执行。
 * 原因：OpenAL context 是线程局部的（alcMakeContextCurrent 仅对调用线程生效），
 * 集中到单线程可避免多线程竞争 + 与渲染/物理/主逻辑线程隔离。
 * - initialize()/shutdown() 也在音频线程执行（alcMakeContextCurrent 必须在
 * 后续发出 OpenAL 调用的同一线程上调用）。
 * - execAudio(cmd) 公开线程序列化入口：供 AudioLoader/StreamingAudio 等外部模块
 * 的 OpenAL 调用排队到音频线程，避免数据竞争。
 * 死锁约束（同 BgfxRenderer）：execAudio 不可重入——闭包内只能包含原始 OpenAL
 * 调用，不能再调其它走 execAudio 的方法，否则自我等待死锁。
 *
 * @file[en] AudioContext  Audio context singleton managing the OpenAL device/context and a dedicated audio thread
 * @brief[en] Audio context singleton managing the OpenAL device/context and a dedicated audio thread
 * @explain[en] Corresponds to Three.js AudioContext (which manages a Web Audio API
 * AudioContext); Three.cj uses the OpenAL Device + Context as the backend.
 * Threading model (aligned with BgfxRenderer._execBgfx):
 * - All OpenAL/EFX API calls must be serialized onto a dedicated audio system
 * thread via _execAudio, because the OpenAL context is thread-local
 * (alcMakeContextCurrent only affects the calling thread), and a single thread
 * avoids races and isolates audio from render/physics/main-logic threads.
 * - initialize()/shutdown() also run on the audio thread (alcMakeContextCurrent
 * must be called on the same thread that later issues OpenAL calls).
 * - execAudio(cmd) is the public serialization entry point: external modules such
 * as AudioLoader/StreamingAudio queue their OpenAL calls onto the audio thread
 * to avoid data races.
 * Deadlock constraint (same as BgfxRenderer): execAudio is not reentrant — the
 * closure must contain only raw OpenAL calls and must not call other methods that
 * go through execAudio, or it will self-deadlock.
 */
package three.audio.device

import openalsoft4cj.alc.*
import openalsoft4cj.al.*
import std.collection.*
import three.core.thread.*

/**
 * @brief[zh-cn] 音频上下文单例，管理 OpenAL 设备和上下文 + 专用音频线程
 * @explain[zh-cn] 懒初始化单例；所有 OpenAL/EFX 调用经 execAudio 序列化到音频线程执行，
 * 避免多线程竞争并保证 OpenAL context 仅在所属线程上使用。
 *
 * @brief[en] Audio context singleton managing the OpenAL device/context and a dedicated audio thread
 * @explain[en] A lazily-initialized singleton; all OpenAL/EFX calls are serialized onto
 * the audio thread via execAudio, avoiding races and keeping the OpenAL context
 * on its owning thread.
 */
public class AudioContext {
    /**
     * @brief[zh-cn] 单例实例
     */
    private static var _instance: Option<AudioContext> = None

    /**
     * @brief[zh-cn] OpenAL 设备句柄
     */
    private var _device: CPointer<Unit>

    /**
     * @brief[zh-cn] OpenAL 上下文句柄
     */
    private var _context: CPointer<Unit>

    /**
     * @brief[zh-cn] 是否已初始化
     */
    private var _initialized: Bool

    // ===== 音频同步原语（对齐 BgfxRenderer._renderMtx/_renderCmdCnd） =====
    // 使用 three.core.thread 的系统级 Mutex/Condition（基于 sdl4cj，而非 std.sync），
    // 因为需要跨用户态与系统线程同步。
    /**
     * @brief[zh-cn] 音频线程互斥锁
     */
    private var _audioMtx = Mutex()
    /**
     * @brief[zh-cn] 音频命令条件变量
     */
    private var _audioCmdCnd = Condition()
    /**
     * @brief[zh-cn] 音频完成条件变量
     */
    private var _audioDoneCnd = Condition()
    /**
     * @brief[zh-cn] 待执行的音频命令
     */
    private var _audioCmd: Option<() -> Unit> = None
    /**
     * @brief[zh-cn] 命令是否执行完成
     */
    private var _audioDone: Bool = false
    /**
     * @brief[zh-cn] 是否退出音频线程
     */
    private var _audioExit: Bool = false
    /**
     * @brief[zh-cn] 音频系统线程
     */
    private var _audioSThread: Option<SThread<Unit>> = None
    /**
     * @brief[zh-cn] 初始化结果
     */
    private var _initResult: Bool = false

    /**
     * @brief[zh-cn] 获取单例实例（懒初始化）
     *
     * @brief[en] Returns the singleton instance (lazily initialized)
     */
    public static prop context: AudioContext {
        get() {
            match (_instance) {
                case Some(inst) => inst
                case None =>
                    let inst = AudioContext()
                    _instance = Some(inst)
                    inst
            }
        }
    }

    /**
     * @brief[zh-cn] 获取 OpenAL 设备句柄
     *
     * @brief[en] Returns the OpenAL device handle
     */
    public prop device: CPointer<Unit> {
        get() { _device }
    }

    /**
     * @brief[zh-cn] 获取 OpenAL 上下文句柄
     *
     * @brief[en] Returns the OpenAL context handle
     */
    public prop alcContext: CPointer<Unit> {
        get() { _context }
    }

    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether the context has been initialized
     */
    public prop initialized: Bool {
        get() { _initialized }
    }

    /**
     * @brief[zh-cn] 创建音频上下文实例（私有，通过 context 单例访问）
     *
     * @brief[en] Creates an audio context instance (private; access via the context singleton)
     */
    private init() {
        this._device = CPointer<Unit>()
        this._context = CPointer<Unit>()
        this._initialized = false
    }

    // ===== 音频线程基础设施（对照 BgfxRenderer._initRenderThread/_renderLoop/_execBgfx） =====

    /**
     * @brief[zh-cn] 启动专用音频线程（若尚未启动）
     */
    private func _initAudioThread(): Unit {
        if (this._audioSThread.isSome()) { return }
        // Mutex/Condition 已在字段声明处初始化
        this._audioSThread = SThread{ this._audioLoop(); () }
    }

    /**
     * @brief[zh-cn] 音频线程主循环：等待命令、执行、通知完成，直至收到退出信号
     */
    private func _audioLoop(): Unit {
        while (!this._audioExit) {
            this._audioMtx.lock()
            while (this._audioCmd.isNone() && !this._audioExit) {
                this._audioCmdCnd.wait(this._audioMtx)
            }
            match (this._audioCmd) {
                case Some(cmd) =>
                    cmd()
                    this._audioCmd = None
                    this._audioDone = true
                    this._audioDoneCnd.signal()
                case None => ()
            }
            this._audioMtx.unlock()
        }
    }

    /**
     * @brief[zh-cn] 内部线程序列化：将 cmd 提交到音频线程同步执行并等待完成
     * @param[zh-cn] cmd 待执行的闭包（仅包含原始 OpenAL 调用）
     *
     * @note[zh-cn] 闭包内只能包含原始 OpenAL 调用，禁止嵌套调用其它走 execAudio 的方法。
     */
    private func _execAudio(cmd: () -> Unit): Unit {
        if (this._audioSThread.isNone()) {
            this._initAudioThread()
        }
        this._audioMtx.lock()
        this._audioCmd = Some(cmd)
        this._audioDone = false
        this._audioCmdCnd.signal()
        while (!this._audioDone) {
            this._audioDoneCnd.wait(this._audioMtx)
        }
        this._audioMtx.unlock()
    }

    /**
     * @brief[zh-cn] 公开线程序列化入口，将 OpenAL API 调用提交到音频线程同步执行
     * @param[zh-cn] cmd 待执行的闭包（仅包含原始 OpenAL 调用）
     *
     * @brief[en] Public thread-serialization entry point that submits an OpenAL API call
     * to the audio thread and executes it synchronously
     * @param[en] cmd The closure to execute (raw OpenAL calls only)
     *
     * @note[zh-cn] 外部模块（如 AudioLoader/StreamingAudio/EffectComposer）的 OpenAL 调用必须经
     * 此方法排队到音频线程，避免数据竞争；闭包按提交顺序在音频线程执行，
     * 内部若再调用其它走 _execAudio 的方法（如 initialize）会自我等待死锁。
     * @note[en] External modules (e.g. AudioLoader/StreamingAudio/EffectComposer) must queue
     * their OpenAL calls through this method to avoid data races. Closures run on the
     * audio thread in submission order; calling other _execAudio-based methods
     * (e.g. initialize) from inside the closure self-deadlocks.
     * @example[zh-cn] 用法示例
     * context.execAudio({
     * alSourceQueueBuffers_cj(source, 1, bufPtr)
     * })
     * @example[en] Usage example
     * context.execAudio({
     * alSourceQueueBuffers_cj(source, 1, bufPtr)
     * })
     */
    public func execAudio(cmd: () -> Unit): Unit {
        this._execAudio(cmd)
    }

    /**
     * @brief[zh-cn] 初始化音频上下文（打开设备 + 创建上下文 + 在音频线程激活上下文）
     * @return[zh-cn] 是否初始化成功
     *
     * @brief[en] Initializes the audio context (opens the device, creates the context and
     * makes it current on the audio thread)
     * @return[en] Whether initialization succeeded
     *
     * @note[zh-cn] alcMakeContextCurrent 必须在后续发出 OpenAL 调用的同一线程（音频线程）
     * 上调用，故整个初始化流程在 _execAudio 闭包内完成。
     * @note[en] alcMakeContextCurrent must be called on the same thread (the audio thread)
     * that later issues OpenAL calls, so the whole initialization runs inside an
     * _execAudio closure.
     */
    public func initialize(): Bool {
        if (_initialized) { return true }
        this._initResult = false
        _execAudio({ =>
            // 打开默认音频设备
            let devName = unsafe { LibC.mallocCString("") }
            this._device = alcOpenDevice_cj(devName)
            unsafe { LibC.free(devName) }

            if (this._device.isNull()) {
                println("[AudioContext] 无法打开默认音频设备")
                return
            }

            // 创建上下文
            this._context = alcCreateContext_cj(this._device, CPointer<Int32>())
            if (this._context.isNull()) {
                println("[AudioContext] 无法创建上下文")
                alcCloseDevice_cj(this._device)
                this._device = CPointer<Unit>()
                return
            }

            // 在音频线程上激活上下文（OpenAL context 是线程局部的）
            alcMakeContextCurrent_cj(this._context)
            this._initResult = true
        })
        this._initialized = this._initResult
        return this._initialized
    }

    /**
     * @brief[zh-cn] 关闭音频上下文并释放资源
     *
     * @brief[en] Shuts down the audio context and releases resources
     *
     * @note[zh-cn] 清理在音频线程执行，确保 OpenAL 调用在 context 所属线程上发出。
     * @note[en] Cleanup runs on the audio thread to ensure OpenAL calls are issued on the
     * thread that owns the context.
     */
    public func shutdown(): Unit {
        if (!_initialized) { return }
        _execAudio({ =>
            alcMakeContextCurrent_cj(CPointer<Unit>())
            alcDestroyContext_cj(this._context)
            alcCloseDevice_cj(this._device)
            this._device = CPointer<Unit>()
            this._context = CPointer<Unit>()
        })
        this._initialized = false
        // 通知音频线程退出
        this._audioMtx.lock()
        this._audioExit = true
        this._audioCmdCnd.signal()
        this._audioMtx.unlock()
    }

    /**
     * @brief[zh-cn] 获取当前上下文的 OpenAL 错误码
     * @return[zh-cn] AL 错误码（AL_NO_ERROR = 0 表示无错误）
     *
     * @brief[en] Returns the current OpenAL error code of the context
     * @return[en] The AL error code (AL_NO_ERROR = 0 means no error)
     */
    public func getError(): UInt32 {
        let errBox = Array<UInt32>(1, { _ => 0u32 })
        _execAudio({ => errBox[0] = alcGetError_cj(this._device) })
        return errBox[0]
    }

    // ===== 全局多普勒设置（OpenAL alDopplerFactor / alDopplerVelocity / alSpeedOfSound） =====
    // 多普勒效应：声源/监听器相对速度变化导致音调偏移。
    // 配合 PositionalAudio.setVelocity 使用：源速度 + 监听器速度差驱动多普勒偏移。

    /**
     * @brief[zh-cn] 设置全局多普勒因子
     * @param[zh-cn] factor 多普勒因子（0.0 = 关闭多普勒，1.0 = 物理正确，越大越夸张）
     *
     * @brief[en] Sets the global Doppler factor
     * @param[en] factor Doppler factor (0.0 = disables Doppler, 1.0 = physically correct,
     * larger values exaggerate the effect)
     *
     * @note[zh-cn] OpenAL 默认值为 1.0；配合 PositionalAudio.setVelocity 使用。
     * @note[en] The OpenAL default is 1.0; use together with PositionalAudio.setVelocity.
     */
    public func setDopplerFactor(factor: Float32): Unit {
        if (!_initialized) { return }
        _execAudio({ => alDopplerFactor_cj(factor) })
    }

    /**
     * @brief[zh-cn] 设置多普勒速度因子
     * @param[zh-cn] velocity 多普勒速度因子
     *
     * @brief[en] Sets the Doppler velocity factor
     * @param[en] velocity Doppler velocity factor
     *
     * @deprecated[zh-cn] 旧 API，对应 AL_DOPPLER_VELOCITY，已废弃；新代码建议改用 setSpeedOfSound。
     * @deprecated[en] Legacy API corresponding to AL_DOPPLER_VELOCITY; use setSpeedOfSound instead.
     */
    public func setDopplerVelocity(velocity: Float32): Unit {
        if (!_initialized) { return }
        _execAudio({ => alDopplerVelocity_cj(velocity) })
    }

    /**
     * @brief[zh-cn] 设置参考声速
     * @param[zh-cn] speed 声速（米/秒，默认 343.3），多普勒计算的参考值；越大 → 多普勒效应越弱
     *
     * @brief[en] Sets the reference speed of sound
     * @param[en] speed Speed of sound in m/s (default 343.3), used as the Doppler reference;
     * larger values weaken the Doppler effect
     */
    public func setSpeedOfSound(speed: Float32): Unit {
        if (!_initialized) { return }
        _execAudio({ => alSpeedOfSound_cj(speed) })
    }

    // ===== HRTF 支持（ALC_SOFT_HRTF 扩展） =====
    // HRTF（Head-Related Transfer Function）让耳机输出具备空间感，
    // 依赖设备能力与 OpenAL Soft 的 HRTF 扩展支持。

    /**
     * @brief[zh-cn] 启用/禁用 HRTF（耳机空间化渲染）
     * @param[zh-cn] enabled true = 启用，false = 禁用
     *
     * @brief[en] Enables or disables HRTF (headphone spatial rendering)
     * @param[en] enabled true = enabled, false = disabled
     *
     * @note[zh-cn] 对应 ALC_SOFT_HRTF：alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf)，
     * 其中 hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT。
     * @note[en] Maps to ALC_SOFT_HRTF: alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf),
     * where hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT.
     */
    public func setHrtfEnabled(enabled: Bool): Unit {
        if (!_initialized) { return }
        let dev = this._device
        let hrtfVal = Int32(if (enabled) { ALC_HRTF_ENABLED_SOFT } else { ALC_HRTF_DISABLED_SOFT })
        _execAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(hrtfVal) }
            alcGetIntegerv_cj(dev, ALC_HRTF_SOFT, 1, valPtr)
            unsafe { LibC.free(valPtr) }
        })
    }

    /**
     * @brief[zh-cn] 查询当前 HRTF 状态
     * @return[zh-cn] ALC_HRTF_DISABLED_SOFT(0) / ALC_HRTF_ENABLED_SOFT(1) /
     * ALC_HRTF_DENIED_SOFT(2) / ALC_HRTF_REQUIRED_SOFT(3) /
     * ALC_HRTF_HEADPHONES_DETECTED_SOFT(4) / ALC_HRTF_UNSUPPORTED_FORMAT_SOFT(5)
     *
     * @brief[en] Queries the current HRTF status
     * @return[en] ALC_HRTF_DISABLED_SOFT(0) / ALC_HRTF_ENABLED_SOFT(1) /
     * ALC_HRTF_DENIED_SOFT(2) / ALC_HRTF_REQUIRED_SOFT(3) /
     * ALC_HRTF_HEADPHONES_DETECTED_SOFT(4) / ALC_HRTF_UNSUPPORTED_FORMAT_SOFT(5)
     */
    public func getHrtfStatus(): Int32 {
        if (!_initialized) { return Int32(ALC_HRTF_DISABLED_SOFT) }
        let dev = this._device
        let statusBox = Array<Int32>(1, { _ => 0 })
        _execAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(0) }
            alcGetIntegerv_cj(dev, ALC_HRTF_STATUS_SOFT, 1, valPtr)
            statusBox[0] = unsafe { valPtr.read() }
            unsafe { LibC.free(valPtr) }
        })
        return statusBox[0]
    }

    /**
     * @brief[zh-cn] 获取可用 HRTF 数量
     * @return[zh-cn] HRTF 数量（0 = 设备不支持 HRTF）
     *
     * @brief[en] Returns the number of available HRTFs
     * @return[en] Number of HRTFs (0 = device does not support HRTF)
     */
    public func getHrtfCount(): Int32 {
        if (!_initialized) { return 0 }
        let dev = this._device
        let countBox = Array<Int32>(1, { _ => 0 })
        _execAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(0) }
            alcGetIntegerv_cj(dev, ALC_NUM_HRTF_SPECIFIERS_SOFT, 1, valPtr)
            countBox[0] = unsafe { valPtr.read() }
            unsafe { LibC.free(valPtr) }
        })
        return countBox[0]
    }

    /**
     * @brief[zh-cn] 获取指定索引的 HRTF 名称
     * @param[zh-cn] index HRTF 索引（0 ~ getHrtfCount()-1）
     * @return[zh-cn] HRTF 名称字符串；索引无效返回空串
     *
     * @brief[en] Returns the HRTF name at the given index
     * @param[en] index HRTF index (0 ~ getHrtfCount()-1)
     * @return[en] The HRTF name string; empty string if the index is invalid
     */
    public func getHrtfName(index: Int32): String {
        if (!_initialized) { return "" }
        let dev = this._device
        let nameBox = Array<String>(1, { _ => "" })
        _execAudio({ =>
            let cs = alcGetStringiSOFT_cj(dev, ALC_HRTF_SPECIFIER_SOFT, index)
            nameBox[0] = if (cs.isNull()) { "" } else { unsafe { cs.toString() } }
        })
        return nameBox[0]
    }

    /**
     * @brief[zh-cn] 枚举全部可用 HRTF 名称列表
     * @return[zh-cn] HRTF 名称列表（可能为空 = 设备不支持）
     *
     * @brief[en] Enumerates all available HRTF names into a list
     * @return[en] List of HRTF names (may be empty = device does not support HRTF)
     */
    public func getHrtfList(): ArrayList<String> {
        let list = ArrayList<String>()
        let n = this.getHrtfCount()
        for (i in 0..n) {
            list.add(this.getHrtfName(i))
        }
        return list
    }

    /**
     * @brief[zh-cn] 选择指定 HRTF
     * @param[zh-cn] id HRTF ID（0 ~ getHrtfCount()-1），-1 = 恢复自动选择
     *
     * @brief[en] Selects a specific HRTF
     * @param[en] id HRTF ID (0 ~ getHrtfCount()-1), -1 = restore automatic selection
     *
     * @note[zh-cn] 需先调用 setHrtfEnabled(true) 后生效；对应 ALC_SOFT_HRTF 的
     * ALC_HRTF_ID_SOFT 设置。
     * @note[en] Takes effect after calling setHrtfEnabled(true); maps to the
     * ALC_HRTF_ID_SOFT setting of ALC_SOFT_HRTF.
     */
    public func selectHrtf(id: Int32): Unit {
        if (!_initialized) { return }
        let dev = this._device
        _execAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(id) }
            alcGetIntegerv_cj(dev, ALC_HRTF_SOFT, Int32(ALC_HRTF_ID_SOFT), valPtr)
            unsafe { LibC.free(valPtr) }
        })
    }
}
