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
 * @file[zh-cn] AudioContext 音频上下文单例，管理 OpenAL 设备/上下文 + 专用音频线程
 * @brief[zh-cn] 音频上下文单例：管理 OpenAL 设备/上下文与专用音频线程
 * @explain[zh-cn] 提供音频上下文单例（对标 Web Audio API 的 AudioContext 角色），
 * 本引擎使用 OpenAL 的 Device + Context 作为底层实现。
 * 线程模型（依据《多线程改造计划》阶段 3，对齐 ThreeRenderer._execBgfx /
 * PhysicsWorld._execPhysics）：
 * - 所有 OpenAL/EFX API 调用必须序列化到专用音频系统线程执行。
 * 原因：OpenAL context 是线程局部的（alcMakeContextCurrent 仅对调用线程生效），
 * 集中到单线程可避免多线程竞争 + 与渲染/物理/主逻辑线程隔离。
 * - 命令通道：SPSC 无锁队列（_audioQueue）+ FrameFence 完成序号（按批推进）+
 * 信号量唤醒；高频路径无 Mutex，唤醒次数由"命令数"降为"批次数"。
 * - 完成同步：execAudio（同步，等执行完）与 postAudio（投递即返回）两条路径；
 * 有返回值/必须保序生效的调用走 execAudio，纯写入可走 postAudio。
 * - initialize()/shutdown() 也在音频线程执行（alcMakeContextCurrent 必须在后续
 * 发出 OpenAL 调用的同一线程上调用），且必须走同步路径。
 * - 音频线程自身的调用走"同线程快路径"直接执行（不入队），因此不再有
 * "execAudio 不可重入（嵌套死锁）"的限制。
 * - 单生产者约束：跨线程投递必须来自同一外部线程（当前为主/窗口泵线程）；
 * 音频线程内部调用走快路径不入队。
 *
 * @file[en] AudioContext  Audio context singleton managing the OpenAL device/context and a dedicated audio thread
 * @brief[en] Audio context singleton managing the OpenAL device/context and a dedicated audio thread
 * @explain[en] Provides an audio context singleton (playing the role of the Web Audio API
 * AudioContext); this engine uses the OpenAL Device + Context as the backend.
 * Threading model (per Phase 3 of the multi-threading plan, aligned with
 * ThreeRenderer._execBgfx / PhysicsWorld._execPhysics):
 * - All OpenAL/EFX API calls must be serialized onto a dedicated audio system
 * thread, because the OpenAL context is thread-local (alcMakeContextCurrent only
 * affects the calling thread), and a single thread avoids races and isolates
 * audio from render/physics/main-logic threads.
 * - Command channel: SPSC lock-free queue (_audioQueue) + FrameFence completion
 * sequence (advanced per batch) + semaphore wakeup; the hot path has no Mutex and
 * wakeups drop from per-command to per-batch.
 * - Completion: two paths, execAudio (synchronous) and postAudio (fire-and-forget).
 * Calls returning values or requiring "already effective" ordering use execAudio;
 * pure writes may use postAudio.
 * - initialize()/shutdown() also run on the audio thread (alcMakeContextCurrent
 * must be called on the same thread that later issues OpenAL calls) and must use
 * the synchronous path.
 * - Calls from the audio thread itself take a same-thread fast path (no enqueue),
 * so the old "execAudio is not reentrant (nested deadlock)" restriction is gone.
 * - Single-producer constraint: cross-thread submissions must come from one
 * external thread (currently the main/window-pump thread); audio-thread internal
 * calls take the fast path and never enqueue.
 */
package three.audio.device

import openalsoft4cj.alc.*
import openalsoft4cj.al.*
import std.collection.*
import std.sync.{ AtomicBool, AtomicInt64, AtomicUInt64 }
import three.core.thread.*
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*
import three.utils.safe.IReleasable

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
public class AudioContext <: IReleasable {
    /**
     * @brief[zh-cn] 单例实例
     *
     * @brief[en] The singleton instance
     */
    private static var _instance: Option<AudioContext> = None

    /**
     * @brief[zh-cn] OpenAL 设备句柄
     *
     * @brief[en] The OpenAL device handle
     */
    private var _device: CPointer<Unit>

    /**
     * @brief[zh-cn] OpenAL 上下文句柄
     *
     * @brief[en] The OpenAL context handle
     */
    private var _context: CPointer<Unit>

    /**
     * @brief[zh-cn] 是否已初始化（原子：跨线程无锁读写）
     *
     * @brief[en] Whether initialized (atomic: lock-free cross-thread access)
     */
    private let _initialized = AtomicBool(false)

    // ===== 音频命令通道（依据《多线程改造计划》阶段 3 重构）=====
    // 旧模型：单命令槽（_audioCmd）+ Mutex + 双条件变量 + 完成布尔标记。
    //   瓶颈：每条命令一次"写槽 + signal + 等待完成"的完整同步往返；命令无法
    //   批量排空，唤醒次数 = 命令数；命令积压时只能串行往返。
    // 新模型（本文件，对齐 ThreeRenderer._renderQueue / PhysicsWorld._physicsQueue）：
    // - 命令队列 → SPSCQueue（无锁环形缓冲，push/pop 无 CAS 无 Mutex）；
    // - 完成同步 → FrameFence（原子提交/完成序号 + 等待路径条件变量），
    //   完成序号按"批"推进，唤醒次数由命令数降为批次数；
    // - 唤醒 → _audioWake 信号量（一次性通知，无谓词状态）；
    // - 退出标志 → AtomicBool（无锁读写）。
    // 多提交者并发安全说明：跨线程投递必须来自同一外部线程（当前为窗口泵线程
    // onFrame）；音频线程自身的调用走"同线程快路径"直接执行（不入队）。
    private let _audioQueue = SPSCQueue<() -> Unit>(capacity: 1024)
    /**
     * @brief[zh-cn] 命令到达 / 退出信号（一次性通知，无谓词重查）
     *
     * @brief[en] Command-arrival / exit signal (one-shot, no predicate re-check)
     */
    private let _audioWake = Semaphore(initVal: 0)
    /**
     * @brief[zh-cn] 音频命令完成栅栏（按批推进完成序号）
     *
     * @brief[en] Audio command completion fence (advances the done sequence per batch)
     */
    private let _audioFence = FrameFence()
    /**
     * @brief[zh-cn] 是否退出音频线程（原子）
     *
     * @brief[en] Whether to exit the audio thread (atomic)
     */
    private let _audioExit = AtomicBool(false)
    /**
     * @brief[zh-cn] 音频线程的 SDL 系统线程 ID（同线程快路径判定用）
     *
     * @brief[en] SDL system thread id of the audio thread (used by the same-thread fast path)
     */
    private let _audioThreadId = AtomicUInt64(0u64)
    /**
     * @brief[zh-cn] 音频系统线程
     *
     * @brief[en] The audio system thread
     */
    private var _audioSThread: Option<SThread<Unit>> = None
    /**
     * @brief[zh-cn] 初始化结果（音频线程写、初始化方在同步等待后读）
     *
     * @brief[en] Initialization result (written on the audio thread, read after the sync wait)
     */
    private var _initResult: Bool = false

    // ===== 异步变换槽（渲染线程写 / 音频线程读，全程无锁）=====
    /**
     * @brief[zh-cn] 变换槽注册表（仅注册/注销时短暂持锁）
     * @explain[zh-cn] 每帧的音频参数同步（监听器位置/朝向、空间音源位置/方向/速度）
     *               若走 execAudio 的同步往返，渲染线程要为每个音源各阻塞一次
     *               （实测单次 70~180µs），N 个音源即 N 倍帧时间。
     *               改为：渲染线程只把新值写入槽内并推进版本号，音频线程在自己的
     *               循环里取走新版本并下发 OpenAL，渲染线程零阻塞。
     *               槽数据的读写不再经过 _audioMtx（见 AudioTransformSlot 的 seqlock）；
     *               _audioMtx 只保护本列表的增删，音频线程用 _slotSnapshot 做无锁遍历。
     *
     * @brief[en] The transform slot registry (the lock is held only during register/unregister)
     * @explain[en] Per-frame audio parameter syncs (listener pose, spatial source
     *               position/direction/velocity) would block the render thread once per
     *               source (measured 70~180µs each) through a synchronous execAudio round
     *               trip, i.e. N times the frame time for N sources. Instead the render
     *               thread only writes the new values into the slot and advances the
     *               version, and the audio thread picks up new versions in its own loop
     *               and submits them to OpenAL. Slot data no longer goes through
     *               _audioMtx (see the seqlock in AudioTransformSlot); _audioMtx only
     *               guards list add/remove, while the audio thread iterates its own
     *               lock-free _slotSnapshot.
     */
    private var _transformSlots: ArrayList<AudioTransformSlot> = ArrayList<AudioTransformSlot>()
    /**
     * @brief[zh-cn] 变换槽注册/注销版本（原子计数器，卷动时音频线程刷新快照）
     *
     * @brief[en] Transform-slot registry version (atomic; the audio thread refreshes its snapshot when it changes)
     */
    private let _slotVersion = AtomicInt64(0)
    /**
     * @brief[zh-cn] 音频线程私有的槽快照（无锁遍历，不在锁内调用 OpenAL）
     *
     * @brief[en] Audio-thread-private slot snapshot (lock-free iteration, no OpenAL calls under a lock)
     */
    private var _slotSnapshot: ArrayList<AudioTransformSlot> = ArrayList<AudioTransformSlot>()
    /**
     * @brief[zh-cn] 已同步的注册表版本
     *
     * @brief[en] The registry version already synced into the snapshot
     */
    private var _slotSnapshotVersion: Int64 = -1
    /**
     * @brief[zh-cn] 是否有待下发的变换（原子标志，供音频线程判断是否需要下发）
     *
     * @brief[en] Whether any transform is pending (atomic; lets the audio thread decide to apply)
     */
    private let _hasPendingTransform = AtomicBool(false)
    /**
     * @brief[zh-cn] 变换槽注册表互斥锁（仅保护 _transformSlots 的增删）
     *
     * @brief[en] Transform-slot registry mutex (guards _transformSlots add/remove only)
     */
    private var _audioMtx = Mutex()
    /**
     * @brief[zh-cn] 变换下发暂存缓冲（音频线程专用，预分配 C 内存）
     * @explain[zh-cn] 布局：[0..3)=位置 [3..6)=朝向/方向 [6..9)=上方向/速度 [9]=主音量。
     *               音频线程把槽内字段复制到这里再交给 OpenAL，渲染线程只写槽内字段，
     *               双方无需各自持有 C 内存，也避免了每帧 malloc/free。
     *
     * @brief[en] The staging buffer for transform submission (audio-thread only, preallocated C memory)
     * @explain[en] Layout: [0..3)=position, [3..6)=orientation/direction, [6..9)=up axis/velocity,
     *               [9]=master gain. The audio thread copies the slot fields into it before
     *               handing them to OpenAL; the render thread only writes the slot fields,
     *               so neither side owns C memory and no per-frame malloc/free is needed.
     */
    private let _transformStaging: CPointer<Float32>


    /**
     * @brief[zh-cn] 获取单例实例（懒初始化）
     *
     * @brief[en] Returns the singleton instance (lazily initialized)
     */
    public static prop context: AudioContext {
        get() {
            if (let Some(inst) <- _instance) {
                inst
            } else {
                let fresh = AudioContext()
                _instance = Some(fresh)
                fresh
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
    protected prop alcContext: CPointer<Unit> {
        get() { _context }
    }

    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether the context has been initialized
     */
    public prop initialized: Bool {
        get() { _initialized.load() }
    }

    /**
     * @brief[zh-cn] 创建音频上下文实例（私有，通过 context 单例访问）
     *
     * @brief[en] Creates an audio context instance (private; access via the context singleton)
     */
    private init() {
        this._device = CPointer<Unit>()
        this._context = CPointer<Unit>()
        this._transformStaging = unsafe { LibC.malloc<Float32>(count: 10) }
        for (i in 0..10) {
            unsafe { this._transformStaging.write(i, 0.0f32) }
        }
    }

    // ===== 音频线程基础设施（对照 ThreeRenderer._initRenderThread/_renderLoop/_execBgfx） =====

    /**
     * @brief[zh-cn] 启动专用音频线程（若尚未启动）
     *
     * @brief[en] Starts the dedicated audio thread (if not yet started)
     */
    private func _initAudioThread(): Unit {
        if (this._audioSThread.isSome()) { return }
        this._audioSThread = SThread{ this._audioLoop(); () }
    }

    /**
     * @brief[zh-cn] 当前调用方是否就在音频线程上（同线程快路径判定）
     * @return[zh-cn] 在音频线程上返回 true
     *
     * @brief[en] Whether the caller runs on the audio thread (same-thread fast-path test)
     * @return[en] true when on the audio thread
     */
    private func _isAudioThread(): Bool {
        let tid = this._audioThreadId.load()
        return tid != 0u64 && getCurrentThreadId() == tid
    }

    /**
     * @brief[zh-cn] 音频线程主循环：批量排空命令、下发变换，无事可做时睡在信号量上
     * @explain[zh-cn] 与旧实现（单槽 + 条件变量、逐条命令一次锁/唤醒）相比：
     * - 命令一次排空整批，整批结束后 advanceBy(n) 推进完成序号（唤醒次数降为批次数）；
     * - 变换下发由原子标志驱动，渲染线程只写槽 + signal，无同步往返；
     * - 无事可做时睡在 _audioWake 信号量上（一次性通知，无需谓词重查）。
     *
     * @brief[en] The audio thread main loop: drains commands in batches, applies transforms,
     * and sleeps on the semaphore when idle
     * @explain[en] Compared with the old single-slot + condition-variable model (one
     * lock/wakeup per command): a whole batch is drained at once and advanceBy(n)
     * advances the done sequence once per batch; transform submission is driven by an
     * atomic flag so the render thread only writes the slot and signals; when idle the
     * thread sleeps on the _audioWake semaphore (one-shot, no predicate re-check).
     */
    @Zone[three.audio.device.AudioContext.audioLoop, name=audioThreadLoop]
    private func _audioLoop(): Unit {
        // 记录音频线程的 SDL 系统线程 ID：_execAudio/postAudio 用它判定"调用方已在音频线程"
        this._audioThreadId.store(getCurrentThreadId())
        while (!this._audioExit.load()) {
            // 批量排空（无锁）：整批执行完再推进完成序号
            let n = this._drainAndExec()
            if (n > 0) {
                this._audioFence.advanceBy(n)
            }
            // 变换下发必须在音频线程执行（OpenAL context 仅在本线程激活）
            if (this._hasPendingTransform.load() && !this._audioExit.load()) {
                this._applyPendingTransforms()
            }
            // 无命令且无待下发变换：睡到有新投递（队列空检查是近似的，
            // 但如果漏掉一次投递，投递方已 signal，wait 会立即返回）
            if (!this._audioExit.load() && this._audioQueue.isEmpty()) {
                this._audioWake.wait()
            }
        }
        // 退出路径：残留命令不得再执行（上下文已销毁），但必须按"已提交-已完成"
        // 缺口推进完成序号，唤醒仍可能在等待的提交者，避免任何人悬挂。
        let outstanding = this._audioFence.submitted() - this._audioFence.done()
        if (outstanding > 0) {
            this._audioFence.advanceBy(outstanding)
        }
    }

    /**
     * @brief[zh-cn] 批量排空命令队列并在音频线程执行（无锁 pop）
     * @return[zh-cn] 本批实际执行的命令数
     * @explain[zh-cn] 单条命令失败仅记录日志（异常隔离），不终止排空，
     *               保证其提交者的完成序号仍会被推进（否则提交者永久等待）。
     *
     * @brief[en] Drain the command queue in batches on the audio thread (lock-free pop)
     * @return[en] Number of commands executed in this batch
     * @explain[en] A failing command is only logged (isolation) and does not stop the drain,
     * so its submitter's done sequence is still advanced (otherwise it would wait forever).
     */
    private func _drainAndExec(): Int64 {
        var n: Int64 = 0
        while (true) {
            if (let Some(cmd) <- this._audioQueue.pop()) {
                try {
                    cmd()
                } catch (e: Exception) {
                    @LogError(["AudioContext._audioLoop: audio cmd failed: ${e}"])
                } catch (e: Error) {
                    @LogError(["AudioContext._audioLoop: audio cmd failed: ${e}"])
                }
                n += 1
            } else { break }
        }
        return n
    }

    /**
     * @brief[zh-cn] 内部线程序列化：将 cmd 提交到音频线程同步执行并等待完成
     * @param[zh-cn] cmd 待执行的闭包（原始 OpenAL 调用或其它音频线程操作）
     * @explain[zh-cn] 调用方已在音频线程时走同线程快路径直接执行（不入队），
     *               因此闭包内再调用走 execAudio 的方法不会再自我等待死锁。
     *
     * @brief[en] Internal thread serialization: submits cmd to the audio thread for
     * synchronous execution and waits for completion
     * @param[en] cmd The closure to execute (raw OpenAL calls or other audio-thread work)
     * @explain[en] When the caller already runs on the audio thread the closure executes
     * directly (no enqueue), so nesting execAudio-based calls can no longer self-deadlock.
     */
    @Zone[three.audio.device.AudioContext.execAudio, name=audioExecAudio]
    private func _execAudio(cmd: () -> Unit): Unit {
        if (this._isAudioThread()) {
            cmd()
            return
        }
        let seq = this._enqueue(cmd)
        if (seq == 0) { return }
        // 同步等待：完成序号追上我这条命令后返回
        this._audioFence.waitUntil(seq)
    }

    /**
     * @brief[zh-cn] 投递命令到音频线程命令队列（SPSC push + 信号量唤醒）
     * @param[zh-cn] cmd 待执行的闭包
     * @return[zh-cn] 本次投递的完成序号（0 表示音频线程已退出，命令被丢弃）
     * @explain[zh-cn] - 先检查退出标志（无锁原子读）：已退出则丢弃并返回 0，绝不入队；
     * - submit 一个完成序号（占用序号空间，防止后续等待型提交被提前满足）；
     * - SPSC 入队（无锁）；队列满（极端积压）时短暂自旋等待消费端排空；
     * - 信号量唤醒音频线程（一次性通知，无需谓词重查）。
     *
     * @brief[en] Posts a command into the audio command queue (SPSC push + semaphore wake)
     * @param[en] cmd Closure to execute
     * @return[en] Completion sequence of this submission (0 if the audio thread already exited and the command was dropped)
     * @explain[en] - checks the exit flag first (lock-free atomic read): drop and return 0 when exiting;
     * - submits a completion sequence (reserves sequence space so later waiting submissions cannot be satisfied early);
     * - enqueues via SPSC (lock-free); on full it briefly spins for the consumer to drain;
     * - wakes the audio thread via the semaphore (one-shot, no predicate re-check).
     */
    private func _enqueue(cmd: () -> Unit): Int64 {
        if (this._audioExit.load()) { return 0 }
        if (this._audioSThread.isNone()) {
            this._initAudioThread()
        }
        let seq = this._audioFence.submit()
        while (!this._audioQueue.push(cmd)) {
            if (this._audioExit.load()) { return 0 }
            sleepNS(1000)
        }
        this._audioWake.signal()
        return seq
    }

    /**
     * @brief[zh-cn] 公开线程序列化入口，将 OpenAL API 调用提交到音频线程同步执行
     * @param[zh-cn] cmd 待执行的闭包（仅包含原始 OpenAL 调用）
     * @note[zh-cn] 外部模块（如 AudioLoader/StreamingAudio/AudioRecorder）的 OpenAL 调用必须经
     * 此方法排队到音频线程，避免数据竞争；闭包按提交顺序在音频线程执行。
     * 需要读取执行结果（如 alGenBuffers 回填句柄）时必须用本方法；
     * 纯写入且不关心何时生效的调用可用 postAudio（不阻塞调用方）。
     * @example[zh-cn] 用法示例
     * context.execAudio({
     * alSourceQueueBuffers_cj(source, 1, bufPtr)
     * })
     *
     * @brief[en] Public thread-serialization entry point that submits an OpenAL API call
     * to the audio thread and executes it synchronously
     * @param[en] cmd The closure to execute (raw OpenAL calls only)
     * @note[en] External modules (e.g. AudioLoader/StreamingAudio/AudioRecorder) must queue
     * their OpenAL calls through this method to avoid data races; closures run on the
     * audio thread in submission order. Use this method when the result is needed
     * (e.g. handles filled by alGenBuffers); pure writes that do not care when they
     * take effect may use postAudio (never blocks the caller).
     * @example[en] Usage example
     * context.execAudio({
     * alSourceQueueBuffers_cj(source, 1, bufPtr)
     * })
     */
    public func execAudio(cmd: () -> Unit): Unit {
        this._execAudio(cmd)
    }

    /**
     * @brief[zh-cn] 公开投递入口：把 OpenAL 调用排到音频线程执行但**不等待**
     * @param[zh-cn] cmd 待执行的闭包（仅包含原始 OpenAL 调用，且不读取任何回填结果）
     * @explain[zh-cn] 适用于"纯写入"型调用（设置参数、停止/播放等），提交后立即返回，
     * 不产生线程往返等待。命令与 execAudio 共用同一条 FIFO 队列，严格按提交顺序执行：
     * 后续任何 execAudio（同步）调用都会等到本命令执行完毕，故"先写参数、后同步读状态"
     * 的顺序仍然成立。
     *
     * @brief[en] Public post entry: queues an OpenAL call onto the audio thread **without waiting**
     * @param[en] cmd Closure to execute (raw OpenAL calls only; must not read back any result)
     * @explain[en] Meant for pure writes (setting parameters, play/stop, ...): returns immediately
     * with no round-trip wait. Posted commands share the same FIFO queue with execAudio and
     * execute strictly in submission order, so a later synchronous execAudio waits for them,
     * preserving "write parameter, then read state" ordering.
     */
    public func postAudio(cmd: () -> Unit): Unit {
        if (this._isAudioThread()) {
            cmd()
            return
        }
        this._enqueue(cmd)
    }


    /**
     * @brief[zh-cn] 注册一个音频变换槽
     * @param[zh-cn] slot 变换槽（调用方持有，生命周期内不得释放）
     *
     * @brief[en] Registers an audio transform slot
     * @param[en] slot The transform slot (owned by the caller, must outlive the registration)
     */
    public func registerTransformSlot(slot: AudioTransformSlot): Unit {
        this._audioMtx.lock()
        this._transformSlots.add(slot)
        this._slotVersion.fetchAdd(1)
        this._audioMtx.unlock()
    }

    /**
     * @brief[zh-cn] 注销一个音频变换槽
     * @param[zh-cn] slot 变换槽
     * @explain[zh-cn] 注销同时使槽失效（sourceId 置 0 + 版本推进），
     *               保证音频线程手上的旧快照不会向已释放的源继续下发。
     *
     * @brief[en] Unregisters an audio transform slot
     * @param[en] slot The transform slot
     * @explain[en] Unregistering also invalidates the slot (source id zeroed + version
     * advanced) so the audio thread's stale snapshot cannot keep writing to a
     * released source.
     */
    public func unregisterTransformSlot(slot: AudioTransformSlot): Unit {
        this._audioMtx.lock()
        var i = 0
        while (i < this._transformSlots.size) {
            if (refEq(this._transformSlots[i], slot)) {
                this._transformSlots.remove(i..i + 1)
            } else {
                i++
            }
        }
        this._slotVersion.fetchAdd(1)
        this._audioMtx.unlock()
        slot.invalidate()
    }

    /**
     * @brief[zh-cn] 异步提交一个音频对象的变换参数（渲染线程调用，不阻塞）
     * @param[zh-cn] slot 变换槽
     * @param[zh-cn] px 位置 X
     * @param[zh-cn] py 位置 Y
     * @param[zh-cn] pz 位置 Z
     * @param[zh-cn] ox 朝向/方向 X
     * @param[zh-cn] oy 朝向/方向 Y
     * @param[zh-cn] oz 朝向/方向 Z
     * @param[zh-cn] ux 上方向/速度 X
     * @param[zh-cn] uy 上方向/速度 Y
     * @param[zh-cn] uz 上方向/速度 Z
     * @param[zh-cn] gain 主音量（仅监听器槽生效）
     * @explain[zh-cn] 渲染线程用 seqlock 写入参数（版本 +1 → 写字段 → 版本 +1）后立即返回；
     *               音频线程在自己的循环里取走新版本并调用 OpenAL。
     *               全程无 Mutex、无线程等待（依据《多线程改造计划》阶段 3）。
     *
     * @brief[en] Asynchronously submits an audio object's transform (render thread, non-blocking)
     * @param[en] slot The transform slot
     * @param[en] px Position X
     * @param[en] py Position Y
     * @param[en] pz Position Z
     * @param[en] ox Orientation/direction X
     * @param[en] oy Orientation/direction Y
     * @param[en] oz Orientation/direction Z
     * @param[en] ux Up axis/velocity X
     * @param[en] uy Up axis/velocity Y
     * @param[en] uz Up axis/velocity Z
     * @param[en] gain Master gain (effective for listener slots only)
     * @explain[en] The render thread writes the values under the slot's seqlock (version +1 →
     * write fields → version +1) and returns immediately; the audio thread picks up the new
     * version in its own loop and calls OpenAL. No Mutex and no waiting (Phase 3 of the plan).
     */
    public func postTransform(
        slot: AudioTransformSlot,
        px: Float32, py: Float32, pz: Float32,
        ox: Float32, oy: Float32, oz: Float32,
        ux: Float32, uy: Float32, uz: Float32,
        gain: Float32
    ): Unit {
        // seqlock 写入段：版本变奇数表示"写入中"，读者本轮跳过
        slot._version.fetchAdd(1)
        slot.px = px
        slot.py = py
        slot.pz = pz
        slot.ox = ox
        slot.oy = oy
        slot.oz = oz
        slot.ux = ux
        slot.uy = uy
        slot.uz = uz
        slot.gain = gain
        // 版本变偶数表示"参数稳定"，音频线程可安全复制
        slot._version.fetchAdd(1)
        this._hasPendingTransform.store(true)
        this._audioWake.signal()
    }

    /**
     * @brief[zh-cn] 音频线程侧：刷新槽快照（仅在注册表版本变化时持锁复制）
     * @explain[zh-cn] 注册/注销是低频操作，音频线程把列表复制到自己的 _slotSnapshot 后
     *               即可无锁遍历，避免每帧在锁内扫描列表、也避免边遍历边增删的竞态。
     *
     * @brief[en] Audio-thread side: refreshes the slot snapshot (locks only when the registry version changed)
     * @explain[en] Register/unregister are low-frequency; copying the list into the audio
     * thread's own _slotSnapshot allows lock-free iteration and avoids racing with
     * add/remove during traversal.
     */
    private func _refreshSlotSnapshot(): Unit {
        let v = this._slotVersion.load()
        if (v == this._slotSnapshotVersion) { return }
        let snap = ArrayList<AudioTransformSlot>()
        this._audioMtx.lock()
        for (slot in this._transformSlots) {
            snap.add(slot)
        }
        this._audioMtx.unlock()
        this._slotSnapshot = snap
        this._slotSnapshotVersion = v
    }

    /**
     * @brief[zh-cn] 快照中是否还有未下发的新版本（用于决定是否继续保持待下发标志）
     * @return[zh-cn] 存在未下发版本返回 true
     *
     * @brief[en] Whether the snapshot still holds versions not yet submitted
     * @return[en] true if any unsent version exists
     */
    private func _anySlotPending(): Bool {
        for (slot in this._slotSnapshot) {
            if (slot._version.load() != slot._consumedVersion) {
                return true
            }
        }
        return false
    }

    /**
     * @brief[zh-cn] 音频线程侧：取走所有新版本槽并下发到 OpenAL
     * @explain[zh-cn] 在音频线程中调用（此时 OpenAL 上下文已在本线程激活）。
     *               遍历音频线程私有的槽快照（无锁），对每个槽用 seqlock 读取参数：
     *               版本为奇数（写入中）或复制期间被覆盖时本轮跳过、下一轮重取；
     *               读取一致才记录为已消费版本并下发。每次只取一个槽，保证暂存缓冲
     *               在 OpenAL 调用期间不被其它槽覆盖。源已释放（sourceId 为 0）的槽跳过。
     *
     * @brief[en] Audio-thread side: takes all slots with new versions and submits them to OpenAL
     * @explain[en] Called on the audio thread (where the OpenAL context is current). It walks
     * the audio thread's private snapshot (lock-free) and reads each slot's parameters under
     * the seqlock: an odd version (being written) or a version change during the copy makes
     * this round skip the slot and retry later; only a consistent read is marked as consumed
     * and submitted. One slot per round so the staging buffer is not overwritten by other
     * slots while OpenAL runs. Slots whose source was released (sourceId zero) are skipped.
     */
    @Zone[three.audio.device.AudioContext.applyTransforms, name=audioApplyTransforms]
    private func _applyPendingTransforms(): Unit {
        let staging = this._transformStaging
        // 指针算术属于不安全操作，需在 unsafe 上下文中取得偏移指针
        let orientPtr = unsafe { staging + 3 }
        let velocityPtr = unsafe { staging + 6 }
        this._refreshSlotSnapshot()
        while (true) {
            var picked = false
            var srcId = 0u32
            var isListener = false
            var gainVal = 1.0f32
            for (slot in this._slotSnapshot) {
                let v1 = slot._version.load()
                // 已消费或正在写入（奇数）→ 跳过
                if (v1 == slot._consumedVersion || v1 % 2 != 0) { continue }
                unsafe {
                    staging.write(0, slot.px)
                    staging.write(1, slot.py)
                    staging.write(2, slot.pz)
                    staging.write(3, slot.ox)
                    staging.write(4, slot.oy)
                    staging.write(5, slot.oz)
                    staging.write(6, slot.ux)
                    staging.write(7, slot.uy)
                    staging.write(8, slot.uz)
                    staging.write(9, slot.gain)
                }
                // 复制期间写者再次提交 → 快照可能撕裂，本轮丢弃，下一轮重取
                if (slot._version.load() != v1) { continue }
                slot._consumedVersion = v1
                picked = true
                srcId = slot.sourceId
                isListener = slot.isListener
                gainVal = slot.gain
                break
            }
            if (!picked) { break }

            // 上下文已销毁（shutdown 之后）时不再向 OpenAL 下发
            if (this._context.isNull()) { continue }
            if (isListener) {
                alListenerfv_cj(AL_POSITION, staging)
                alListenerfv_cj(AL_ORIENTATION, orientPtr)
                alListenerf_cj(AL_GAIN, gainVal)
            } else if (srcId != 0u32) {
                alSourcefv_cj(srcId, AL_POSITION, staging)
                alSourcefv_cj(srcId, AL_DIRECTION, orientPtr)
                alSourcefv_cj(srcId, AL_VELOCITY, velocityPtr)
            }
        }
        // 先清标志再复检：清标志之后到来的新提交会自己重新置位（写者 store(true)），
        // 因此不会丢唤醒；复检捕获"清标志前一刻已写入但尚未被本机看到"的情况。
        this._hasPendingTransform.store(false)
        if (this._anySlotPending()) {
            this._hasPendingTransform.store(true)
        }
    }

    /**
     * @brief[zh-cn] 初始化音频上下文（打开设备 + 创建上下文 + 在音频线程激活上下文）
     * @return[zh-cn] 是否初始化成功
     * @note[zh-cn] alcMakeContextCurrent 必须在后续发出 OpenAL 调用的同一线程（音频线程）
     * 上调用，故整个初始化流程在 _execAudio 闭包内完成。
     *
     * @brief[en] Initializes the audio context (opens the device, creates the context and
     * makes it current on the audio thread)
     * @return[en] Whether initialization succeeded
     * @note[en] alcMakeContextCurrent must be called on the same thread (the audio thread)
     * that later issues OpenAL calls, so the whole initialization runs inside an
     * _execAudio closure.
     */
    public func initialize(): Bool {
        if (this._initialized.load()) { return true }
        this._initResult = false
        _execAudio({ =>
            // 打开默认音频设备
            let devName = unsafe { LibC.mallocCString("") }
            this._device = alcOpenDevice_cj(devName)
            unsafe { LibC.free(devName) }

            if (this._device.isNull()) {
                @LogError(["AudioContext", "无法打开默认音频设备"])
                return
            }

            // 创建上下文
            this._context = alcCreateContext_cj(this._device, CPointer<Int32>())
            if (this._context.isNull()) {
                @LogError(["AudioContext", "无法创建上下文"])
                alcCloseDevice_cj(this._device)
                this._device = CPointer<Unit>()
                return
            }

            // 在音频线程上激活上下文（OpenAL context 是线程局部的）
            alcMakeContextCurrent_cj(this._context)
            this._initResult = true
        })
        this._initialized.store(this._initResult)
        return this._initResult
    }

    /**
     * @brief[zh-cn] 资源是否有效（已初始化且设备句柄可用）
     * @return[zh-cn] 有效返回 true
     *
     * @brief[en] Whether the resource is valid (initialized with a usable device handle)
     * @return[en] Returns true when valid
     */
    public prop releasable: Bool {
        get() { this._initialized.load() && !this._device.isNull() }
    }

    /**
     * @brief[zh-cn] 关闭音频上下文并释放资源
     * @note[zh-cn] 清理在音频线程执行，确保 OpenAL 调用在 context 所属线程上发出；
     *               未初始化时为幂等空操作。
     *
     * @brief[en] Shuts down the audio context and releases resources
     * @note[en] Cleanup runs on the audio thread to ensure OpenAL calls are issued on the
     * thread that owns the context; idempotent no-op when not initialized.
     */
    public func release(): Bool {
        if (!this._initialized.load()) { return false }
        _execAudio({ =>
            alcMakeContextCurrent_cj(CPointer<Unit>())
            alcDestroyContext_cj(this._context)
            alcCloseDevice_cj(this._device)
            this._device = CPointer<Unit>()
            this._context = CPointer<Unit>()
        })
        this._initialized.store(false)
        // 通知音频线程退出：置原子退出标志 + 信号量唤醒。
        // 音频线程退出时会按"已提交-已完成"缺口推进完成序号，唤醒仍可能在等待的提交者；
        // 退出后 _enqueue 直接丢弃命令（不再入队、不会挂住调用方）。
        this._audioExit.store(true)
        this._audioWake.signal()
        return true
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
     * @note[zh-cn] OpenAL 默认值为 1.0；配合 PositionalAudio.setVelocity 使用。
     *
     * @brief[en] Sets the global Doppler factor
     * @param[en] factor Doppler factor (0.0 = disables Doppler, 1.0 = physically correct,
     * larger values exaggerate the effect)
     * @note[en] The OpenAL default is 1.0; use together with PositionalAudio.setVelocity.
     */
    public func setDopplerFactor(factor: Float32): Unit {
        if (!this._initialized.load()) { return }
        // 纯写入型全局参数：投递即可，不阻塞调用方
        this.postAudio({ => alDopplerFactor_cj(factor) })
    }

    /**
     * @brief[zh-cn] 设置多普勒速度因子
     * @param[zh-cn] velocity 多普勒速度因子
     * @deprecated[zh-cn] 旧 API，对应 AL_DOPPLER_VELOCITY，已废弃；新代码建议改用 setSpeedOfSound。
     *
     * @brief[en] Sets the Doppler velocity factor
     * @param[en] velocity Doppler velocity factor
     * @deprecated[en] Legacy API corresponding to AL_DOPPLER_VELOCITY; use setSpeedOfSound instead.
     */
    public func setDopplerVelocity(velocity: Float32): Unit {
        if (!this._initialized.load()) { return }
        this.postAudio({ => alDopplerVelocity_cj(velocity) })
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
        if (!this._initialized.load()) { return }
        this.postAudio({ => alSpeedOfSound_cj(speed) })
    }

    // ===== HRTF 支持（ALC_SOFT_HRTF 扩展） =====
    // HRTF（Head-Related Transfer Function）让耳机输出具备空间感，
    // 依赖设备能力与 OpenAL Soft 的 HRTF 扩展支持。

    /**
     * @brief[zh-cn] 启用/禁用 HRTF（耳机空间化渲染）
     * @param[zh-cn] enabled true = 启用，false = 禁用
     * @note[zh-cn] 对应 ALC_SOFT_HRTF：alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf)，
     * 其中 hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT。
     *
     * @brief[en] Enables or disables HRTF (headphone spatial rendering)
     * @param[en] enabled true = enabled, false = disabled
     * @note[en] Maps to ALC_SOFT_HRTF: alcGetIntegerv(device, ALC_HRTF_SOFT, 1, &hrtf),
     * where hrtf = ALC_HRTF_ENABLED_SOFT / ALC_HRTF_DISABLED_SOFT.
     */
    public func setHrtfEnabled(enabled: Bool): Unit {
        if (!this._initialized.load()) { return }
        let dev = this._device
        let hrtfVal = Int32(if (enabled) { ALC_HRTF_ENABLED_SOFT } else { ALC_HRTF_DISABLED_SOFT })
        this.postAudio({ =>
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
        if (!this._initialized.load()) { return Int32(ALC_HRTF_DISABLED_SOFT) }
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
        if (!this._initialized.load()) { return 0 }
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
        if (!this._initialized.load()) { return "" }
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
     * @note[zh-cn] 需先调用 setHrtfEnabled(true) 后生效；对应 ALC_SOFT_HRTF 的
     * ALC_HRTF_ID_SOFT 设置。
     *
     * @brief[en] Selects a specific HRTF
     * @param[en] id HRTF ID (0 ~ getHrtfCount()-1), -1 = restore automatic selection
     * @note[en] Takes effect after calling setHrtfEnabled(true); maps to the
     * ALC_HRTF_ID_SOFT setting of ALC_SOFT_HRTF.
     */
    public func selectHrtf(id: Int32): Unit {
        if (!this._initialized.load()) { return }
        let dev = this._device
        this.postAudio({ =>
            let valPtr = unsafe { LibC.malloc<Int32>() }
            unsafe { valPtr.write(id) }
            alcGetIntegerv_cj(dev, ALC_HRTF_SOFT, Int32(ALC_HRTF_ID_SOFT), valPtr)
            unsafe { LibC.free(valPtr) }
        })
    }
}
