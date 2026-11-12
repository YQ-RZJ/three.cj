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
 * @file[zh-cn] PhysicsWorld 物理世界门面 + 独立物理线程
 * @brief[zh-cn] 提供后端无关的物理世界门面，持有独立物理线程序列化所有后端调用
 * @explain[zh-cn] 线程模型（对齐 AudioContext._audioLoop / ThreeRenderer._renderLoop）：
 * - 持有独立 three.core.thread.SThread，所有后端调用经 _execPhysics 序列化到物理线程执行。
 * - 命令通道：SPSC 无锁队列（_physicsQueue）+ FrameFence 帧栅栏 + 信号量唤醒，
 *   依据《多线程改造计划》阶段 2 重构：批量排空、唤醒次数由命令数降为批次数。
 * - 死锁约束：_execPhysics 不可重入——闭包内只能包含对 backend 的原始调用，
 * 禁止嵌套调用其它走 _execPhysics 的方法，否则自我等待死锁。
 * 可插拔后端：
 * - PhysicsWorld 仅依赖 three.physics.interfaces.IPhysicsBackend。
 * - 构造时注入具体后端实例（默认 JoltBackend）；运行时可通过 setBackend 切换。
 * - 替换底层物理库只需新写一个 IPhysicsBackend 实现，无需改 world/body/binding。
 * 步进驱动：PhysicsWorld.update(dt) 由主渲染线程每帧调用；
 * - _execPhysics({ => backend.update(dt, steps) + 回读位姿写 back 快照 })
 * - 同步：update 返回后主线程读 front 快照，将刚体 transform 应用到绑定的 Object3D。
 * 回读与应用分处两端：物理线程只写快照数据（不触碰 Object3D），Object3D 由主线程
 * 独占写入；借助帧栅栏的 happens-before，快照交换零锁零往返（阶段 2 任务 2）。
 *
 * @file[en] PhysicsWorld Physics-world facade + dedicated physics thread
 * @brief[en] Provides a backend-agnostic physics-world facade with a dedicated physics thread serializing all backend calls
 * @explain[en] Threading model (aligned with AudioContext._audioLoop / ThreeRenderer._renderLoop):
 * - owns a dedicated three.core.thread.SThread; every backend call is serialized
 * to the physics thread via _execPhysics.
 * - sync primitives use three.core.thread's system-level Mutex/Condition
 * (based on sdl4cj, synchronizing across user and system threads).
 * - deadlock rule: _execPhysics is not reentrant - the closure may only contain
 * raw backend calls; never nest calls to other methods that go through
 * _execPhysics, or a self-wait deadlock occurs.
 * Pluggable backend:
 * - PhysicsWorld depends only on three.physics.interfaces.IPhysicsBackend.
 * - a concrete backend instance is injected at construction (JoltBackend by
 * default); it can be swapped at runtime via setBackend.
 * - replacing the underlying engine only needs a new IPhysicsBackend
 * implementation, without touching world/body/binding.
 * Stepping: PhysicsWorld.update(dt) is called by the main render thread every frame;
 * - _execPhysics({ => backend.update(dt, steps) + write back snapshot })
 * - synchronous: after update returns, the main thread reads the front snapshot and
 * applies body transforms to the bound Object3D. Read-back and application run on
 * different sides: the physics thread only writes snapshot data (never touches
 * Object3D); Object3D is written exclusively by the main thread. The frame fence
 * provides happens-before, so the snapshot swap is zero-lock, zero extra round-trip
 * (Phase 2 task 2).
 */
package three.physics.world

import three.core.math.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.scene.objects.*
import std.collection.*
import std.collection.concurrent.ConcurrentLinkedQueue
import std.sync.{ AtomicBool, AtomicInt64 }
import three.core.thread.*
import three.utils.safe.IReleasable
import three.profiler.*
import three.profiler.macros.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 绑定条目：Object3D ↔ 物理刚体句柄
 * @explain[zh-cn] 记录渲染对象与物理刚体的绑定关系，以及同步方向：
 * - syncToObj = true 时，物理→渲染（Dynamic/Kinematic 刚体由物理驱动）
 * - syncToObj = false 时，渲染→物理（Kinematic 由用户控制位置）
 * - offset 暂未使用，预留给质心校正等场景
 *
 * @brief[en] Binding entry: Object3D ↔ physics body handle
 * @explain[en] Records the binding between a render object and a physics body,
 * as well as the sync direction:
 * - syncToObj = true: physics→render (Dynamic/Kinematic bodies driven by physics)
 * - syncToObj = false: render→physics (Kinematic body position controlled by user)
 * - offset is currently unused, reserved for center-of-mass correction scenarios
 */
internal class PhysicsBinding {
    /**
     * @brief[zh-cn] 被绑定的渲染对象
     *
     * @brief[en] The bound render object
     */
    public var object3d: Object3D
    /**
     * @brief[zh-cn] 物理刚体句柄
     *
     * @brief[en] The physics body handle
     */
    public var handle: PhysicsBodyHandle
    /**
     * @brief[zh-cn] 同步方向：true=物理→渲染，false=渲染→物理
     *
     * @brief[en] Sync direction: true=physics→render, false=render→physics
     */
    public var syncToObj: Bool
    /**
     * @brief[zh-cn] 渲染对象相对物理刚体的局部偏移（暂未使用）
     *
     * @brief[en] Local offset of the render object relative to the physics body (currently unused)
     */
    public var offset: Vector3

    /**
     * @brief[zh-cn] 创建绑定条目
     * @param[zh-cn] object3d 被绑定的渲染对象
     * handle 物理刚体句柄
     * syncToObj 同步方向
     * offset 局部偏移（默认零向量）
     *
     * @brief[en] Creates a binding entry
     * @param[en] object3d The bound render object
     * handle The physics body handle
     * syncToObj Sync direction
     * offset Local offset (zero vector by default)
     */
    public init(object3d!: Object3D, handle!: PhysicsBodyHandle, syncToObj!: Bool, offset!: Vector3 = Vector3()) {
        this.object3d = object3d
        this.handle = handle
        this.syncToObj = syncToObj
        this.offset = offset
    }
}

/**
 * @brief[zh-cn] 位姿快照条目（阶段 2 任务 2 双缓冲快照的元素）
 * @explain[zh-cn] 物理线程每帧把活跃刚体的位姿（两处 FFI 的返回对象）直接存入快照，
 * 不触碰 Object3D；主线程在 update 返回后读取快照并应用到 Object3D。
 * 该设计把"回读（FFI）"留在物理线程、把"渲染对象写入"留在主线程，
 * 物理线程关键路径不再承担渲染对象的 bookkeeping。
 *
 * @brief[en] Transform-snapshot entry (element of the Phase 2 task 2 double-buffer snapshot)
 * @explain[en] Each frame the physics thread stores active bodies' poses (the objects
 * returned by the two FFI reads) directly into the snapshot without touching Object3D;
 * the main thread reads the snapshot after update returns and applies it to Object3D.
 * This keeps FFI read-back on the physics thread and render-object writes on the main
 * thread, so the physics thread's hot path does no render-object bookkeeping.
 */
internal class TransformSnapshot {
    /**
     * @brief[zh-cn] 目标渲染对象
     *
     * @brief[en] The target render object
     */
    public var object3d: Object3D
    /**
     * @brief[zh-cn] 世界坐标位置（backend 返回对象，直接引用复用）
     *
     * @brief[en] World-space position (backend-returned object, referenced directly)
     */
    public var pos: Vector3
    /**
     * @brief[zh-cn] 世界旋转（四元数）
     *
     * @brief[en] World rotation (quaternion)
     */
    public var rot: Quaternion

    /**
     * @brief[zh-cn] 创建快照条目
     *
     * @brief[en] Creates a snapshot entry
     */
    public init(object3d: Object3D, pos: Vector3, rot: Quaternion) {
        this.object3d = object3d
        this.pos = pos
        this.rot = rot
    }
}

/**
 * @brief[zh-cn] 传感器事件数据（阶段 2 任务 4 回调投递的队列元素）
 * @explain[zh-cn] Jolt 的接触/激活/休眠回调发生在物理线程（backend.update 内部），
 * 不直接调用用户监听器：先打包成该结构入队（ConcurrentLinkedQueue），
 * 主线程在 update() 末尾出队派发。kind 区分三类事件，激活/休眠时 bodyID2/event 无效。
 *
 * @brief[en] Sensor event data (queue element for Phase 2 task 4 callback posting)
 * @explain[en] Jolt's contact/activation/sleep callbacks fire on the physics thread
 * (inside backend.update); instead of calling the user listener directly, they are
 * packed into this structure and enqueued (ConcurrentLinkedQueue), then drained and
 * dispatched by the main thread at the end of update(). kind selects the event class;
 * bodyID2/event are meaningless for activation/sleep events.
 */
internal class SensorEventData {
    /// 事件种类：0=接触，1=激活，2=休眠
    public let kind: Int32
    /// 刚体 1 的 BodyID（接触事件两体均有效）
    public let bodyID1: UInt32
    /// 刚体 2 的 BodyID（仅接触事件有效）
    public let bodyID2: UInt32
    /// 接触事件类型（仅接触事件有效）
    public let event: PhysicsContactEvent

    /**
     * @brief[zh-cn] 创建事件数据
     *
     * @brief[en] Creates event data
     */
    public init(kind: Int32, bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent) {
        this.kind = kind
        this.bodyID1 = bodyID1
        this.bodyID2 = bodyID2
        this.event = event
    }
}

/**
 * @brief[zh-cn] 传感器事件投递适配器（阶段 2 任务 4）
 * @explain[zh-cn] 以 IPhysicsSensorListener 形式注册进后端，替换"直接调用用户监听器"：
 * 回调线程（物理线程/Jolt）只做一次入队（无锁队列，安全且不阻塞），
 * 用户回调的执行被推迟到主线程 update() 末尾的 _dispatchSensorEvents。
 * 该设计同时保住"回调内禁止调 _execPhysics"约束——入队不经过物理命令通道。
 *
 * @brief[en] Sensor-event delivery adapter (Phase 2 task 4)
 * @explain[en] Registered into the backend as an IPhysicsSensorListener, replacing
 * direct user-listener calls: the calling thread (physics/Jolt) only enqueues into a
 * lock-free queue (safe, non-blocking); user callbacks run later on the main thread
 * via _dispatchSensorEvents at the end of update(). This also preserves the
 * "no _execPhysics inside callbacks" rule — enqueueing bypasses the command channel.
 */
internal class SensorEventPoster <: IPhysicsSensorListener {
    /// 事件队列：回调线程入队，主线程出队
    private let _events: ConcurrentLinkedQueue<SensorEventData>

    public init(events: ConcurrentLinkedQueue<SensorEventData>) {
        this._events = events
    }

    public func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit {
        this._events.add(SensorEventData(0, bodyID1, bodyID2, event))
    }

    public func onBodyActivated(bodyID: UInt32): Unit {
        this._events.add(SensorEventData(1, bodyID, 0u32, PhysicsContactEvent.Added))
    }

    public func onBodyDeactivated(bodyID: UInt32): Unit {
        this._events.add(SensorEventData(2, bodyID, 0u32, PhysicsContactEvent.Added))
    }
}

/**
 * @brief[zh-cn] 物理世界门面
 * @explain[zh-cn] 典型用法：
 * let world = PhysicsWorld(JoltBackend())
 * world.init(1024, Vector3(0.0, -9.81, 0.0))
 * let body = world.createBody(desc)
 * world.bindObject(myMesh, body)
 * // 主循环
 * while (running) {
 * world.update(1.0f32 / 60.0f32, 1)
 * // 渲染 myMesh（transform 已被同步）
 * }
 * world.release()
 *
 * @brief[en] Physics-world facade
 * @explain[en] Typical usage:
 * let world = PhysicsWorld(JoltBackend())
 * world.init(1024, Vector3(0.0, -9.81, 0.0))
 * let body = world.createBody(desc)
 * world.bindObject(myMesh, body)
 * // main loop
 * while (running) {
 * world.update(1.0f32 / 60.0f32, 1)
 * // render myMesh (transform has already been synced)
 * }
 * world.release()
 */
public class PhysicsWorld <: IReleasable {
    /// 物理后端（可插拔）
    private var _backend: IPhysicsBackend

    /// 绑定映射：Object3D.id -> PhysicsBinding
    private var _bindings: HashMap<Int64, PhysicsBinding> = HashMap<Int64, PhysicsBinding>()

    /// ===== 物理同步原语（依据《多线程改造计划》阶段 2 重构） =====
    // 旧模型：单命令槽（_physicsCmd）+ Mutex + 双条件变量。
    //   瓶颈：每条后端调用一次"写槽 + signal + 等待完成"的完整同步往返；
    //   命令无法批量排空，唤醒次数 = 命令数；transform 回读逐刚体走 _execPhysics。
    // 新模型（本文件）：
    // - 命令队列 → SPSCQueue（无锁环形缓冲，push/pop 无 CAS 无 Mutex）；
    // - 完成同步 → FrameFence（原子提交/完成序号 + 等待路径条件变量），
    //   完成序号按"批"推进，唤醒次数由命令数降为批次数；
    // - 唤醒 → _physicsWake 信号量（一次性通知，无谓词状态）；
    // - 退出标志 → AtomicBool（无锁读写）。
    // 多提交者并发安全说明：跨线程投递必须来自同一外部线程（当前场景为主渲染线程）。
    // 渲染线程自身经 _execPhysicsSync 路径等待，物理线程自身不可再投递（见死锁约束）。
    private let _physicsQueue = SPSCQueue<() -> Unit>(capacity: 1024)
    private let _physicsWake = Semaphore(initVal: 0)
    private let _physicsFence = FrameFence()
    private let _physicsExit = AtomicBool(false)
    private var _physicsSThread: Option<SThread<Unit>> = None

    // ===== 双缓冲快照（阶段 2 任务 2） =====
    // 物理线程在每帧 update 闭包内写 _snapBack（只读位姿 FFI + 存快照，不触碰 Object3D）；
    // 主线程在 _execPhysics 返回后交换缓冲并读 _snapFront 应用到 Object3D。
    // 因 _execPhysics 是同步等待（fence 提供 happens-before），交换无竞争、无需原子标志；
    // 空快照（无活跃刚体/未步进）天然回退为"跳过同步"。容量按活跃绑定数自适应增长。
    private var _snapBack = ArrayList<TransformSnapshot>()
    private var _snapFront = ArrayList<TransformSnapshot>()

    // ===== 传感器回调投递（阶段 2 任务 4） =====
    // Jolt 接触/激活/休眠回调发生在物理线程（backend.update 内部）；为避免回调线程
    // 直接执行用户逻辑（竞态 + 死锁约束），后端只注册 _sensorPoster（入队），
    // 主循环在 update() 末尾统一出队派发到 _sensorListener（始终运行在主线程）。
    // 事件仅在 step 期间产生，故队列长度受"相邻两次 update 之间的事件数"约束。
    private let _sensorEvents: ConcurrentLinkedQueue<SensorEventData>
    private let _sensorPoster: SensorEventPoster
    private var _sensorListener: Option<IPhysicsSensorListener> = None

    /**
     * @brief[zh-cn] 构造物理世界
     * @param[zh-cn] backend 物理后端实例（默认 JoltBackend）；可替换为其他 IPhysicsBackend 实现
     *
     * @brief[en] Constructs the physics world
     * @param[en] backend The physics backend instance (JoltBackend by default); any IPhysicsBackend implementation may be used
     */
    public init(backend!: IPhysicsBackend = JoltBackend()) {
        this._backend = backend
        this._sensorEvents = ConcurrentLinkedQueue<SensorEventData>()
        this._sensorPoster = SensorEventPoster(this._sensorEvents)
    }

    /**
     * @brief[zh-cn] 当前后端实例
     * @explain[zh-cn] 供高级用户直接访问。
     *
     * @brief[en] The current backend instance
     * @explain[en] For direct access by advanced users.
     */
    public prop backend: IPhysicsBackend {
        get() {
            this._backend
        }
    }

    /**
     * @brief[zh-cn] 替换后端（运行时切换底层物理库）
     * @param[zh-cn] newBackend 新的后端实例
     * @note[zh-cn] 旧后端必须先 shutdown；新后端需 init 后方可使用。
     *
     * @brief[en] Replaces the backend (swaps the underlying physics engine at runtime)
     * @param[en] newBackend The new backend instance
     * @note[en] The old backend must be shut down first; the new backend must be initialized before use.
     */
    public func setBackend(newBackend: IPhysicsBackend): Unit {
        this._backend = newBackend
    }

    // =========================================================================
    // 线程基础设施（对照 AudioContext._initAudioThread/_audioLoop/_execAudio）
    // =========================================================================

    private func _initPhysicsThread(): Unit {
        if (this._physicsSThread.isSome()) {
            return
        }
        // Mutex/Condition 已在字段声明处初始化
        this._physicsSThread = SThread {
            this._physicsLoop();
        ()
        }
    }

    private func _physicsLoop(): Unit {
        while (!this._physicsExit.load()) {
            // 批量排空（无锁）：一次执行当前队列中的全部命令，整批完成后再推进完成序号。
            // 与旧实现（单槽 + 每次一条命令 lock/signal/broadcast）相比，
            // 锁与唤醒次数由"命令数"降为"批次数"。
            let n = this._drainAndExec()
            if (n > 0) {
                this._physicsFence.advanceBy(n)
            } else {
                // 无命令：睡到有新命令投递（信号量唤醒，一次性通知无需谓词重查）
                if (!this._physicsExit.load()) { this._physicsWake.wait() }
            }
        }
        // 退出路径：补齐"已提交-已完成"缺口，唤醒仍可能在等待的提交者，
        // 避免 shutdown 期间任何人悬挂（与旧实现退出分支等价）。
        let outstanding = this._physicsFence.submitted() - this._physicsFence.done()
        if (outstanding > 0) {
            this._physicsFence.advanceBy(outstanding)
        }
    }

    /**
     * @brief[zh-cn] 批量排空命令队列并在物理线程执行（无锁 pop）
     * @return[zh-cn] 本批实际执行的命令数
     * @explain[zh-cn] 循环 pop 直到队列空，逐条在物理线程执行闭包。
     *               单条命令失败仅记录日志（异常隔离），不终止排空，保证其提交者
     *               的完成序号仍会被推进。
     *
     * @brief[en] Drain the command queue in batches and execute on the physics thread (lock-free pop)
     * @return[en] Number of commands executed in this batch
     * @explain[en] Pops until empty, executing each closure on the physics thread.
     *              A single failing command is logged (isolation) and does not stop the
     *              drain, so its submitter's done sequence is still advanced.
     */
    private func _drainAndExec(): Int64 {
        var n: Int64 = 0
        while (true) {
            if (let Some(cmd) <- this._physicsQueue.pop()) {
                try {
                    cmd()
                } catch (e: Error) {
                    // 异常隔离：单条命令失败不能杀物理线程，否则其提交者永久等待
                    @LogWarn(["PhysicsWorld:", "cmd failed: " + e.toString()])
                }
                n += 1
            } else {
                break
            }
        }
        return n
    }

    /**
     * 内部线程序列化：将 cmd 提交到物理线程同步执行并等待完成。
     * 闭包内只能包含对 backend 的原始调用，禁止嵌套调用其它走 _execPhysics 的方法。
     */
    @Zone[three.physics.world.PhysicsWorld.execPhysics, name=physicsExec]
    private func _execPhysics(cmd: () -> Unit): Unit {
        if (this._physicsSThread.isNone()) {
            this._initPhysicsThread()
        }
        // 提交取序号 → 入队（满则自旋等待物理线程排空）→ 信号量唤醒 → 按序号等待完成
        let seq = this._enqueue(cmd)
        if (seq == 0) { return }
        this._physicsFence.waitUntil(seq)
    }

    /**
     * @brief[zh-cn] 投递一条命令到物理线程（异步，不等待完成）
     * @explain[zh-cn] 供确认无需回读结果/无需保序的调用使用（如低频状态设置），
     *               可批量合并执行。返回值 0 表示物理线程已退出，命令被丢弃。
     * @param[zh-cn] cmd 待执行闭包（遵守与 _execPhysics 相同的死锁约束）
     * @return[zh-cn] 投递序号（供内部诊断）；0 = 系统已退出
     *
     * @brief[en] Post a command to the physics thread (async, without waiting for completion)
     * @explain[en] For calls that need no result read-back and no ordering guarantee
     *               (e.g. low-frequency state sets); commands are batch-executed.
     *               A return of 0 means the physics thread has exited and the command is dropped.
     * @param[en] cmd Closure to run (same deadlock rule as _execPhysics)
     * @return[en] Post sequence (for diagnostics); 0 = system already exited
     */
    protected func _postPhysics(cmd: () -> Unit): Int64 {
        if (this._physicsSThread.isNone()) {
            this._initPhysicsThread()
        }
        return this._enqueue(cmd)
    }

    /**
     * @brief[zh-cn] 提交命令并取回序号（内部实现）
     * @return[zh-cn] 投递序号；物理线程已退出时返回 0
     */
    private func _enqueue(cmd: () -> Unit): Int64 {
        let seq = this._physicsFence.submit()
        while (!this._physicsQueue.push(cmd)) {
            // 队列满（极端积压）：等待物理线程排空后再试。
            // SPSC 单生产者前提下，满判定与重试之间无并发投递者，不会覆盖生产顺序。
            if (this._physicsExit.load()) { return 0 }
            sleepNS(1000)
        }
        this._physicsWake.signal()
        return seq
    }

    /**
     * @brief[zh-cn] 在物理线程上同步执行任意后端操作（模块内部设施，供 Jolt 特有高级封装使用）
     * @explain[zh-cn] protected：three.physics 模块内的布娃娃/车辆/软体等高级封装可用，
     * 不对模块外公开。闭包提交到物理线程同步执行，内部可安全调用 jolt4cj FFI。
     * 死锁约束：闭包内禁止再调用 PhysicsWorld 上走 _execPhysics 的方法
     * （包括本方法自身），否则自我等待死锁。闭包内只做底层 FFI 调用。
     *
     * @brief[en] Runs a backend action synchronously on the physics thread (module-internal, for Jolt-specific advanced wrappers)
     * @explain[en] protected: available to advanced wrappers inside the three.physics module,
     * not exported outside it. The closure runs synchronously on the physics thread; jolt4cj
     * FFI calls are safe inside it. It must not call any PhysicsWorld method that goes through
     * _execPhysics (including this one), or it will deadlock.
     */
    protected func execPhysics(cmd: () -> Unit): Unit {
        this._execPhysics(cmd)
    }

    /**
     * @brief[zh-cn] 在物理线程上执行并取回结果值（模块内部设施）
     *
     * @brief[en] Runs on the physics thread and returns a value (module-internal facility)
     */
    protected func execPhysicsResult<T>(cmd: () -> T): T {
        // 逃逸闭包不能捕获可变局部变量，故用 Box 持有结果（box 为 let，仅改其 value 字段）
        let box: Box<Option<T>> = Box<Option<T>>(None)
        this._execPhysics({=> box.value = Some(cmd())})
        if (let Some(v) <- box.value) {
            v
        } else {
            throw IllegalStateException("execPhysicsResult: empty result")
        }
    }

    // =========================================================================
    // 生命周期
    // =========================================================================

    /**
     * @brief[zh-cn] 启动物理世界（初始化后端 + 启动物理线程）
     * @param[zh-cn] maxBodies 世界最多刚体数（默认 1024）
     * gravity 全局重力（默认 (0, -9.81, 0)）
     * @return[zh-cn] 是否成功
     *
     * @brief[en] Starts the physics world (initializes the backend + starts the physics thread)
     * @param[en] maxBodies Maximum number of bodies in the world (default 1024)
     * gravity The global gravity (default (0, -9.81, 0))
     * @return[en] true on success
     */
    public func start(maxBodies!: UInt32 = 1024u32, gravity!: Vector3 = Vector3(0.0, -9.81, 0.0)): Bool {
        this._initPhysicsThread()
        let okBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({
            => okBox.value = be.initialize(maxBodies, gravity)
        })
        return okBox.value
    }

    /**
     * @brief[zh-cn] 销毁所有绑定/刚体 → 释放后端 → 通知物理线程退出
     *
     * @brief[en] destroys all bindings/bodies → releases the backend → notifies the physics thread to exit
     */
    public func release(): Bool {
        // 解除所有绑定（仅清映射，刚体由后端 release 内部清理）
        this._bindings.clear()

        let be = this._backend
        _execPhysics({=> be.release()})

        // 通知物理线程退出（无锁原子标志 + 信号量唤醒；残留命令由线程退出前缀额外推进补齐）
        this._physicsExit.store(true)
        this._physicsWake.signal()
        return true
    }

    /**
     * @brief[zh-cn] 后端是否已初始化
     * @return[zh-cn] 已初始化返回 true
     *
     * @brief[en] Whether the backend is initialized
     * @return[en] true if initialized
     */
    public func isInitialized(): Bool {
        return this._backend.isInitialized()
    }

    // =========================================================================
    // 世界设置
    // =========================================================================

    /**
     * @brief[zh-cn] 设置全局重力
     * @param[zh-cn] gravity 重力向量（如 (0, -9.81, 0)）
     *
     * @brief[en] Sets the global gravity
     * @param[en] gravity The gravity vector (e.g. (0, -9.81, 0))
     */
    public func setGravity(gravity: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.setGravity(gravity)})
    }

    /**
     * @brief[zh-cn] 优化 BroadPhase 包围盒树
     * @note[zh-cn] 在批量插入刚体后、正式模拟前调用一次。
     *
     * @brief[en] Optimizes the BroadPhase bounding-volume tree
     * @note[en] Call once after bulk-inserting bodies and before the main simulation.
     */
    public func optimizeBroadPhase(): Unit {
        let be = this._backend
        _execPhysics({=> be.optimizeBroadPhase()})
    }

    // =========================================================================
    // 形状/刚体（便捷构造 + 直接创建）
    // =========================================================================

    /**
     * @brief[zh-cn] 创建刚体（一步完成）
     * @param[zh-cn] desc 刚体创建描述
     * @return[zh-cn] 刚体句柄；失败返回 INVALID
     *
     * @brief[en] Creates a rigid body (single step)
     * @param[en] desc The body creation description
     * @return[en] The body handle, or INVALID on failure
     */
    public func createBody(desc: PhysicsBodyDesc): PhysicsBodyHandle {
        let handleBox: Box<PhysicsBodyHandle> = Box(PhysicsBodyHandle.INVALID)
        let be = this._backend
        _execPhysics({=> handleBox.value = be.createBody(desc)})
        return handleBox.value
    }

    /**
     * @brief[zh-cn] 销毁刚体并解除任何绑定
     * @param[zh-cn] handle 刚体句柄
     *
     * @brief[en] Destroys a body and unbinds any bindings
     * @param[en] handle The body handle
     */
    public func destroyBody(handle: PhysicsBodyHandle): Unit {
        // 先解除该刚体的全部绑定（同一刚体可能绑定多个 Object3D）
        let keysToRemove = ArrayList<Int64>()
        for ((k, b) in this._bindings) {
            if (b.handle.bodyID == handle.bodyID) {
                keysToRemove.add(k)
            }
        }
        for (k in keysToRemove) {
            this._bindings.remove(k)
        }
        let be = this._backend
        _execPhysics({=> be.destroyBody(handle)})
    }

    // =========================================================================
    // Object3D 绑定
    // =========================================================================

    /**
     * @brief[zh-cn] 绑定 Object3D 与已有刚体：步进后自动将刚体 transform 同步到 object3d
     * @param[zh-cn] object3d 被绑定的渲染对象
     * handle 物理刚体句柄
     * syncToObj true=物理→渲染（Dynamic/Kinematic 刚体）；
     * false=渲染→物理（Kinematic 由用户驱动时可选）
     *
     * @brief[en] Binds an Object3D to an existing body: the body transform is auto-synced to the object after each step
     * @param[en] object3d The rendering object to bind
     * handle The physics body handle
     * syncToObj true = physics→render (Dynamic/Kinematic bodies);
     * false = render→physics (optional when a Kinematic body is user-driven)
     */
    public func bindObject(object3d: Object3D, handle: PhysicsBodyHandle, syncToObj!: Bool = true): Unit {
        if (!handle.isValid()) {
            return
        }
        this._bindings[object3d.id] = PhysicsBinding(object3d: object3d, handle: handle, syncToObj: syncToObj)
    }

    /**
     * @brief[zh-cn] 解除 Object3D 的物理绑定（不销毁刚体）
     * @param[zh-cn] object3d 要解除绑定的渲染对象
     *
     * @brief[en] Unbinds an Object3D from physics (does not destroy the body)
     * @param[en] object3d The rendering object to unbind
     */
    public func unbindObject(object3d: Object3D): Unit {
        this._bindings.remove(object3d.id)
    }

    /**
     * @brief[zh-cn] 获取某 Object3D 绑定的刚体句柄
     * @param[zh-cn] object3d 渲染对象
     * @return[zh-cn] 刚体句柄；无绑定返回 INVALID
     *
     * @brief[en] Gets the body handle bound to an Object3D
     * @param[en] object3d The rendering object
     * @return[en] The body handle, or INVALID if not bound
     */
    internal func getBoundHandle(object3d: Object3D): PhysicsBodyHandle {
        if (let Some(b) <- this._bindings.get(object3d.id)) {
            b.handle
        } else {
            PhysicsBodyHandle.INVALID
        }
    }

    // =========================================================================
    // 步进 + Transform 同步
    // =========================================================================

    /**
     * @brief[zh-cn] 步进物理世界一帧 + 同步刚体 transform 到绑定的 Object3D
     * @explain[zh-cn] 线程约定：update 由主渲染线程每帧调用；
     * - 内部 _execPhysics 将 backend.update + 位姿回读（写 back 快照）序列化到物理线程；
     * - 返回前主线程交换缓冲并读 front 快照，把 transform 应用到 Object3D。
     * 这样 Object3D 的 position/quaternion 只在主线程写入，与渲染线程的
     * updateMatrixWorld（renderer.render 前调用）天然同线程，无竞争。
     * 语义保持同步：update 返回后，本帧步进结果已应用到 Object3D
     * （测试依赖"update 后读到的 transform 是最新值"）。
     * @param[zh-cn] deltaTime 时间步长（秒），典型 1/60
     * collisionSteps 每步内的碰撞细分次数（1/60s 一步取 1）
     * @return[zh-cn] 更新错误标志（0 = 完整完成）
     *
     * @brief[en] Steps the physics world by one frame + syncs body transforms to the bound Object3D
     * @explain[en] Threading contract: update is called by the main render thread every frame;
     * - internally _execPhysics serializes backend.update + pose read-back (into the back
     *   snapshot) onto the physics thread;
     * - before returning, the main thread swaps the buffers and reads the front snapshot,
     *   applying transforms to Object3D.
     * Object3D position/quaternion are thus only written on the main thread, so they never
     * race with the render thread's updateMatrixWorld (called before renderer.render).
     * Semantics stay synchronous: after update returns, this frame's step results are
     * already applied to Object3D (tests rely on reading the latest transform right after).
     * @param[en] deltaTime The time step (seconds), typically 1/60
     * collisionSteps The number of collision substeps per step (1 for a 1/60s step)
     * @return[en] The update error flags (0 = completed fully)
     */
    @Zone[three.physics.world.PhysicsWorld.update, name=physicsUpdate]
    public func update(deltaTime: Float32, collisionSteps!: Int32 = 1): UInt32 {
        let errBox: Box<UInt32> = Box(0u32)
        // 本轮回读缓冲：主线程唯一持有引用；物理线程仅在本批闭包内写它
        let back = this._snapBack
        _execPhysics(
            {
                =>
                    this._stepBackend(deltaTime, collisionSteps, errBox)
                    // 只做位姿回读并写入 back 快照（不再在物理线程触碰 Object3D）
                    this._fillSnapshot(back)
            }
        )
        // 交换缓冲（物理线程已因 fence 完成，无竞争），并在主线程把最新位姿应用到 Object3D
        let t = this._snapFront
        this._snapFront = this._snapBack
        this._snapBack = t
        this._applySnapshot(this._snapFront)
        // 派发本帧步进期间累积的传感器事件（用户回调运行在主线程）
        this._dispatchSensorEvents()
        return errBox.value
    }

    /**
     * @brief[zh-cn] 后端步进（在物理线程上执行，单独计时以便与 transform 回写分离）
     *
     * @brief[en] Backend step (runs on the physics thread; timed separately from the transform write-back)
     */
    @Zone[three.physics.world.PhysicsWorld.stepBackend, name=physicsStep]
    private func _stepBackend(deltaTime: Float32, collisionSteps: Int32, errBox: Box<UInt32>): Unit {
        errBox.value = this._backend.update(deltaTime, collisionSteps)
    }

    /**
     * @brief[zh-cn] 把物理刚体位姿回读到 back 快照（在物理线程上执行）
     * @explain[zh-cn] 每帧对全部绑定做 getPosition + getRotation（2 次 FFI/刚体），
     * 把返回值直接存入快照；对象数多时是物理线程侧的主要开销，单独计时观察。
     * 不再直接写 Object3D——渲染对象写入移到主线程 _applySnapshot。
     *
     * @brief[en] Reads body poses into the back snapshot (runs on the physics thread)
     * @explain[en] Runs getPosition + getRotation (2 FFI calls per body) for every binding and
     *              stores the results in the snapshot directly; the dominant physics-thread cost
     *              in scenes with many bodies, so it is timed separately.
     *              Object3D is no longer touched here — render-object writes moved to the
     *              main-thread _applySnapshot.
     */
    @Zone[three.physics.world.PhysicsWorld.syncBoundTransforms, name=physicsSync]
    private func _fillSnapshot(back: ArrayList<TransformSnapshot>): Unit {
        back.clear()
        let be = this._backend
        for ((_, b) in this._bindings) {
            if (!b.syncToObj) {
                continue
            }
            if (!b.handle.isValid()) {
                continue
            }
            // 休眠刚体本帧位姿不变（Jolt 只在活动态推进变换）：跳过 2 次位姿 FFI。
            // 稳态场景里绝大多数刚体处于休眠，这一跳过可去掉大半回读开销。
            if (!be.isBodyActive(b.handle)) {
                continue
            }
            back.add(TransformSnapshot(b.object3d, be.getPosition(b.handle), be.getRotation(b.handle)))
        }
    }

    /**
     * @brief[zh-cn] 把 front 快照应用到绑定的 Object3D（主线程执行）
     * @explain[zh-cn] update 返回前调用；与渲染线程 updateMatrixWorld 同线程，
     * 无需跨线程同步。矩阵更新标志沿用旧实现约定（matrixAutoUpdate=true 时由
     * renderer.render 触发重算）。
     *
     * @brief[en] Applies the front snapshot to the bound Object3Ds (main thread)
     * @explain[en] Called before update returns; same thread as the render loop's
     * updateMatrixWorld, so no cross-thread sync is needed. The matrix-update flag follows
     * the old convention (with matrixAutoUpdate=true, renderer.render recomputes matrices).
     */
    private func _applySnapshot(front: ArrayList<TransformSnapshot>): Unit {
        for (s in front) {
            s.object3d.position.set(s.pos.x, s.pos.y, s.pos.z)
            s.object3d.quaternion.set(s.rot.x, s.rot.y, s.rot.z, s.rot.w)
            // 触发矩阵更新（matrixAutoUpdate=true 时 renderer.render 会重算）
            s.object3d.matrixWorldNeedsUpdate = true
        }
    }

    /**
     * @brief[zh-cn] 派发传感器事件队列到用户监听器（主线程执行）
     * @explain[zh-cn] 在 update() 末尾、物理步进完成之后调用：清空 _sensorEvents 并
     * 把每条事件转发给 _sensorListener 的对应回调。此时用户回调总在主线程运行，
     * 且处于"本帧步进已完成"的语义下；无监听器时仅清空遗留事件。
     *
     * @brief[en] Dispatches the sensor-event queue to the user listener (main thread)
     * @explain[en] Called at the end of update(), after the physics step completes:
     * drains _sensorEvents and forwards each event to the matching _sensorListener
     * callback. User callbacks therefore always run on the main thread, in the
     * "this frame's step is done" semantics; with no listener the queue is just drained.
     */
    private func _dispatchSensorEvents(): Unit {
        if (let Some(listener) <- this._sensorListener) {
            while (let Some(e) <- this._sensorEvents.remove()) {
                match (e.kind) {
                    case 0 => listener.onContact(e.bodyID1, e.bodyID2, e.event)
                    case 1 => listener.onBodyActivated(e.bodyID1)
                    case 2 => listener.onBodyDeactivated(e.bodyID1)
                    case _ => ()
                }
            }
        } else {
            // 已注销监听器：丢弃遗留事件，避免队列无限累积
            while (let Some(_) <- this._sensorEvents.remove()) { () }
        }
    }

    // =========================================================================
    // 刚体属性读写（经 _execPhysics 序列化）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * position 新位置
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body position (world coordinates)
     * @param[en] handle The body handle
     * position The new position
     * activation The activation strategy (default Activate)
     */
    public func setPosition(handle: PhysicsBodyHandle, position: Vector3,
        activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({=> be.setPosition(handle, position, activation)})
    }

    /**
     * @brief[zh-cn] 获取刚体位置（世界坐标）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前位置
     *
     * @brief[en] Gets the body position (world coordinates)
     * @param[en] handle The body handle
     * @return[en] The body's current position
     */
    public func getPosition(handle: PhysicsBodyHandle): Vector3 {
        let posBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({=> posBox.value = be.getPosition(handle)})
        return posBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * rotation 新旋转
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body rotation (quaternion)
     * @param[en] handle The body handle
     * rotation The new rotation
     * activation The activation strategy (default Activate)
     */
    public func setRotation(handle: PhysicsBodyHandle, rotation: Quaternion,
        activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({=> be.setRotation(handle, rotation, activation)})
    }

    /**
     * @brief[zh-cn] 获取刚体旋转（四元数）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前旋转
     *
     * @brief[en] Gets the body rotation (quaternion)
     * @param[en] handle The body handle
     * @return[en] The body's current rotation
     */
    public func getRotation(handle: PhysicsBodyHandle): Quaternion {
        let rotBox: Box<Quaternion> = Box(Quaternion())
        let be = this._backend
        _execPhysics({=> rotBox.value = be.getRotation(handle)})
        return rotBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * velocity 线速度
     *
     * @brief[en] Sets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * velocity The linear velocity
     */
    public func setLinearVelocity(handle: PhysicsBodyHandle, velocity: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.setLinearVelocity(handle, velocity)})
    }

    /**
     * @brief[zh-cn] 获取刚体线速度（世界空间，米/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前线速度
     *
     * @brief[en] Gets the body linear velocity (world space, m/s)
     * @param[en] handle The body handle
     * @return[en] The body's current linear velocity
     */
    public func getLinearVelocity(handle: PhysicsBodyHandle): Vector3 {
        let vBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({=> vBox.value = be.getLinearVelocity(handle)})
        return vBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * angularVelocity 角速度
     *
     * @brief[en] Sets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * angularVelocity The angular velocity
     */
    public func setAngularVelocity(handle: PhysicsBodyHandle, angularVelocity: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.setAngularVelocity(handle, angularVelocity)})
    }

    /**
     * @brief[zh-cn] 获取刚体角速度（世界空间，弧度/秒）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前角速度
     *
     * @brief[en] Gets the body angular velocity (world space, rad/s)
     * @param[en] handle The body handle
     * @return[en] The body's current angular velocity
     */
    public func getAngularVelocity(handle: PhysicsBodyHandle): Vector3 {
        let vBox: Box<Vector3> = Box(Vector3())
        let be = this._backend
        _execPhysics({=> vBox.value = be.getAngularVelocity(handle)})
        return vBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体摩擦系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * friction 摩擦系数
     *
     * @brief[en] Sets the body friction coefficient (0~1)
     * @param[en] handle The body handle
     * friction The friction coefficient
     */
    public func setFriction(handle: PhysicsBodyHandle, friction: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setFriction(handle, friction)})
    }

    /**
     * @brief[zh-cn] 获取刚体摩擦系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前摩擦系数
     *
     * @brief[en] Gets the body friction coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current friction coefficient
     */
    public func getFriction(handle: PhysicsBodyHandle): Float64 {
        let fBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({=> fBox.value = be.getFriction(handle)})
        return fBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体弹性系数（0~1）
     * @param[zh-cn] handle 刚体句柄
     * restitution 弹性系数
     *
     * @brief[en] Sets the body restitution coefficient (0~1)
     * @param[en] handle The body handle
     * restitution The restitution coefficient
     */
    public func setRestitution(handle: PhysicsBodyHandle, restitution: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setRestitution(handle, restitution)})
    }

    /**
     * @brief[zh-cn] 获取刚体弹性系数
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前弹性系数
     *
     * @brief[en] Gets the body restitution coefficient
     * @param[en] handle The body handle
     * @return[en] The body's current restitution coefficient
     */
    public func getRestitution(handle: PhysicsBodyHandle): Float64 {
        let rBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({=> rBox.value = be.getRestitution(handle)})
        return rBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体运动类型（运行时切换 Static/Kinematic/Dynamic）
     * @param[zh-cn] handle 刚体句柄
     * motionType 目标运动类型
     * activation 激活策略（默认 Activate）
     *
     * @brief[en] Sets the body motion type (switch Static/Kinematic/Dynamic at runtime)
     * @param[en] handle The body handle
     * motionType The target motion type
     * activation The activation strategy (default Activate)
     */
    public func setMotionType(handle: PhysicsBodyHandle, motionType: PhysicsMotionType,
        activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        let be = this._backend
        _execPhysics({=> be.setMotionType(handle, motionType, activation)})
    }

    /**
     * @brief[zh-cn] 获取刚体运动类型
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前运动类型
     *
     * @brief[en] Gets the body motion type
     * @param[en] handle The body handle
     * @return[en] The body's current motion type
     */
    public func getMotionType(handle: PhysicsBodyHandle): PhysicsMotionType {
        let mtBox: Box<PhysicsMotionType> = Box(PhysicsMotionType.Static)
        let be = this._backend
        _execPhysics({=> mtBox.value = be.getMotionType(handle)})
        return mtBox.value
    }

    /**
     * @brief[zh-cn] 查询刚体是否处于活动（模拟）状态
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 活动返回 true
     *
     * @brief[en] Queries whether a body is in the active (simulating) state
     * @param[en] handle The body handle
     * @return[en] true if active
     */
    public func isBodyActive(handle: PhysicsBodyHandle): Bool {
        let aBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({=> aBox.value = be.isBodyActive(handle)})
        return aBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体是否为传感器
     * @param[zh-cn] handle 刚体句柄
     * isSensor 是否传感器（只检测碰撞、不产生物理响应）
     *
     * @brief[en] Sets whether a body is a sensor
     * @param[en] handle The body handle
     * isSensor Whether the body is a sensor (collision-only, no physical response)
     */
    public func setIsSensor(handle: PhysicsBodyHandle, isSensor: Bool): Unit {
        let be = this._backend
        _execPhysics({=> be.setIsSensor(handle, isSensor)})
    }

    // =========================================================================
    // 射线查询
    // =========================================================================

    /**
     * @brief[zh-cn] 世界射线检测（最近命中）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * hit 命中结果输出（命中时有效）
     * @return[zh-cn] 是否命中
     *
     * @brief[en] World ray cast (closest hit)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * hit The hit-result output (valid when a hit occurs)
     * @return[en] true if anything was hit
     */
    public func raycast(origin: Vector3, direction: Vector3, hit: PhysicsRayHit): Bool {
        let okBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({=> okBox.value = be.raycast(origin, direction, hit)})
        return okBox.value
    }

    // =========================================================================
    // 碰撞查询（完整能力：批量射线 / 点碰撞 / 形状碰撞 / 形状投射）
    // =========================================================================

    /**
     * @brief[zh-cn] 世界射线批量检测（收集所有命中，按距离升序）
     * @param[zh-cn] origin 射线起点（世界坐标）
     * direction 射线方向（长度即最大检测距离）
     * @return[zh-cn] 命中列表（按 fraction 升序）
     *
     * @brief[en] World ray batch cast (collects all hits, sorted by distance ascending)
     * @param[en] origin The ray origin (world coordinates)
     * direction The ray direction (its length is the max cast distance)
     * @return[en] The hit list (sorted by fraction ascending)
     */
    public func raycastAll(origin: Vector3, direction: Vector3): ArrayList<PhysicsRayHit> {
        let hits = ArrayList<PhysicsRayHit>()
        let be = this._backend
        _execPhysics({=> be.raycastAll(origin, direction, hits)})
        return hits
    }

    /**
     * @brief[zh-cn] 世界点碰撞检测（检测点位于哪些形状内部/表面）
     * @param[zh-cn] point 世界坐标检测点
     * @return[zh-cn] 命中列表
     *
     * @brief[en] World point collision test (which shapes contain or touch the point)
     * @param[en] point The test point in world coordinates
     * @return[en] The hit list
     */
    public func collidePoint(point: Vector3): ArrayList<PhysicsPointHit> {
        let hits = ArrayList<PhysicsPointHit>()
        let be = this._backend
        _execPhysics({=> be.collidePoint(point, hits)})
        return hits
    }

    /**
     * @brief[zh-cn] 形状 vs 世界碰撞检测（查询形状摆到 pose 后与场景求交）
     * @param[zh-cn] shape 查询形状描述
     * position 查询形状位置（世界坐标）
     * rotation 查询形状旋转
     * @return[zh-cn] 命中列表
     *
     * @brief[en] Shape-vs-world collision test (intersects the scene with the query shape placed at the pose)
     * @param[en] shape The query shape description
     * position The query shape position (world coordinates)
     * rotation The query shape rotation
     * @return[en] The hit list
     */
    public func collideShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion): ArrayList<PhysicsShapeHit> {
        let hits = ArrayList<PhysicsShapeHit>()
        let be = this._backend
        _execPhysics({=> be.collideShape(shape, position, rotation, hits)})
        return hits
    }

    /**
     * @brief[zh-cn] 形状投射（shape 沿 direction 扫掠，检测首个/全部阻挡）
     * @param[zh-cn] shape 投射形状描述
     * position 投射起点位置（世界坐标）
     * rotation 投射形状旋转
     * direction 投射方向（长度即最大扫掠距离）
     * @return[zh-cn] 命中列表（按 fraction 升序；空 = 无阻挡）
     *
     * @brief[en] Shape cast (sweeps shape along direction, detecting the first/all blockers)
     * @param[en] shape The cast shape description
     * position The cast start position (world coordinates)
     * rotation The cast shape rotation
     * direction The cast direction (its length is the max sweep distance)
     * @return[en] The hit list (sorted by fraction ascending; empty = no blocker)
     */
    public func castShape(shape: PhysicsShape, position: Vector3, rotation: Quaternion, direction: Vector3): ArrayList<PhysicsShapeHit> {
        let hits = ArrayList<PhysicsShapeHit>()
        let be = this._backend
        _execPhysics({=> be.castShape(shape, position, rotation, direction, hits)})
        return hits
    }

    /**
     * @brief[zh-cn] 注册碰撞事件监听器（接触回调 + 激活/休眠回调）
     * @param[zh-cn] listener 监听器；None 注销
     * @explain[zh-cn] 阶段 2 任务 4：用户监听器只由主线程持有；后端注册的是
     * 投递适配器 _sensorPoster（回调线程仅入队），真实回调在 update() 末尾
     * _dispatchSensorEvents 中于主线程执行。
     *
     * @brief[en] Registers a collision event listener (contact + activation/sleep callbacks)
     * @param[en] listener The listener, or None to unregister
     * @explain[en] Phase 2 task 4: the user listener is owned by the main thread only;
     * the backend registers the _sensorPoster adapter (callback threads only enqueue),
     * and the real callbacks are dispatched on the main thread via _dispatchSensorEvents
     * at the end of update().
     */
    public func setContactListener(listener: Option<IPhysicsSensorListener>): Unit {
        this._sensorListener = listener
        let be = this._backend
        if (let Some(_) <- listener) {
            _execPhysics({=> be.setContactListener(Some(this._sensorPoster))})
        } else {
            _execPhysics({=> be.setContactListener(None)})
        }
    }

    // =========================================================================
    // 力 / 力矩 / 冲量（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 在刚体质心施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     *
     * @brief[en] Applies a force at the body's center of mass (newtons)
     * @param[en] handle The body handle
     * force The force vector
     */
    public func addForce(handle: PhysicsBodyHandle, force: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.addForce(handle, force)})
    }

    /**
     * @brief[zh-cn] 在刚体指定世界位置施加力（牛顿）
     * @param[zh-cn] handle 刚体句柄
     * force 力向量
     * point 作用点（世界坐标）
     *
     * @brief[en] Applies a force at a specified world position on the body (newtons)
     * @param[en] handle The body handle
     * force The force vector
     * point The point of application (world coordinates)
     */
    public func addForceAtPosition(handle: PhysicsBodyHandle, force: Vector3, point: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.addForceAtPosition(handle, force, point)})
    }

    /**
     * @brief[zh-cn] 施加力矩（牛顿·米）
     * @param[zh-cn] handle 刚体句柄
     * torque 力矩向量
     *
     * @brief[en] Applies a torque (newton-meters)
     * @param[en] handle The body handle
     * torque The torque vector
     */
    public func addTorque(handle: PhysicsBodyHandle, torque: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.addTorque(handle, torque)})
    }

    /**
     * @brief[zh-cn] 在刚体质心施加冲量（冲量 = 力 × 时间）
     * @param[zh-cn] handle 刚体句柄
     * impulse 冲量向量
     *
     * @brief[en] Applies an impulse at the body's center of mass (impulse = force × time)
     * @param[en] handle The body handle
     * impulse The impulse vector
     */
    public func addImpulse(handle: PhysicsBodyHandle, impulse: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.addImpulse(handle, impulse)})
    }

    /**
     * @brief[zh-cn] 施加角冲量
     * @param[zh-cn] handle 刚体句柄
     * angularImpulse 角冲量向量
     *
     * @brief[en] Applies an angular impulse
     * @param[en] handle The body handle
     * angularImpulse The angular impulse vector
     */
    public func addAngularImpulse(handle: PhysicsBodyHandle, angularImpulse: Vector3): Unit {
        let be = this._backend
        _execPhysics({=> be.addAngularImpulse(handle, angularImpulse)})
    }

    // =========================================================================
    // 质量 / 惯量（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 获取刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前质量
     *
     * @brief[en] Gets the body mass (kilograms)
     * @param[en] handle The body handle
     * @return[en] The body's current mass
     */
    public func getMass(handle: PhysicsBodyHandle): Float64 {
        let mBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({=> mBox.value = be.getMass(handle)})
        return mBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体质量（千克）
     * @param[zh-cn] handle 刚体句柄
     * mass 目标质量
     *
     * @brief[en] Sets the body mass (kilograms)
     * @param[en] handle The body handle
     * mass The target mass
     */
    public func setMass(handle: PhysicsBodyHandle, mass: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setMass(handle, mass)})
    }

    /**
     * @brief[zh-cn] 获取刚体逆惯量（3x3，输出 4x4 矩阵左上角）
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前逆惯量矩阵
     *
     * @brief[en] Gets the body inverse inertia (3x3, in the top-left of the returned 4x4)
     * @param[en] handle The body handle
     * @return[en] The body's current inverse-inertia matrix
     */
    public func getInverseInertia(handle: PhysicsBodyHandle): Matrix4 {
        let mBox: Box<Matrix4> = Box(Matrix4())
        let be = this._backend
        _execPhysics({=> mBox.value = be.getInverseInertia(handle)})
        return mBox.value
    }

    /**
     * @brief[zh-cn] 设置刚体重力因子（1 = 正常重力，0 = 无重力）
     * @param[zh-cn] handle 刚体句柄
     * gravityFactor 重力因子
     *
     * @brief[en] Sets the body gravity factor (1 = normal gravity, 0 = no gravity)
     * @param[en] handle The body handle
     * gravityFactor The gravity factor
     */
    public func setGravityFactor(handle: PhysicsBodyHandle, gravityFactor: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setGravityFactor(handle, gravityFactor)})
    }

    /**
     * @brief[zh-cn] 获取刚体重力因子
     * @param[zh-cn] handle 刚体句柄
     * @return[zh-cn] 刚体当前重力因子
     *
     * @brief[en] Gets the body gravity factor
     * @param[en] handle The body handle
     * @return[en] The body's current gravity factor
     */
    public func getGravityFactor(handle: PhysicsBodyHandle): Float64 {
        let gBox: Box<Float64> = Box(1.0)
        let be = this._backend
        _execPhysics({=> gBox.value = be.getGravityFactor(handle)})
        return gBox.value
    }

    // =========================================================================
    // 运动学（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 运动学刚体移动到指定位置/旋转
     * @param[zh-cn] handle 刚体句柄
     * position 目标位置（世界坐标）
     * rotation 目标旋转
     * deltaTime 时间步长（秒）
     * @note[zh-cn] 每帧调用，由 deltaTime 步长驱动。
     *
     * @brief[en] Moves a kinematic body to the given position/rotation
     * @param[en] handle The body handle
     * position The target position (world coordinates)
     * rotation The target rotation
     * deltaTime The time step (seconds)
     * @note[en] Call every frame; driven by the deltaTime step.
     */
    public func moveKinematic(handle: PhysicsBodyHandle, position: Vector3, rotation: Quaternion, deltaTime: Float32): Unit {
        let be = this._backend
        _execPhysics({=> be.moveKinematic(handle, position, rotation, deltaTime)})
    }

    // =========================================================================
    // 约束（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 创建约束并加入世界（连接两个刚体）
     * @param[zh-cn] desc 约束创建描述
     * bodyA 约束刚体 1
     * bodyB 约束刚体 2
     * @return[zh-cn] 约束句柄；失败返回 INVALID
     *
     * @brief[en] Creates a constraint and adds it to the world (connecting two bodies)
     * @param[en] desc The constraint creation description
     * bodyA The first constrained body
     * bodyB The second constrained body
     * @return[en] The constraint handle, or INVALID on failure
     */
    public func createConstraint(desc: PhysicsConstraintDesc, bodyA: PhysicsBodyHandle, bodyB: PhysicsBodyHandle): PhysicsConstraintHandle {
        let cBox: Box<PhysicsConstraintHandle> = Box(PhysicsConstraintHandle.INVALID)
        let be = this._backend
        _execPhysics({=> cBox.value = be.createConstraint(desc, bodyA, bodyB)})
        return cBox.value
    }

    /**
     * @brief[zh-cn] 销毁约束并从世界移除（句柄立即失效）
     * @param[zh-cn] handle 约束句柄
     *
     * @brief[en] Destroys a constraint and removes it from the world (the handle becomes invalid immediately)
     * @param[en] handle The constraint handle
     */
    public func destroyConstraint(handle: PhysicsConstraintHandle): Unit {
        let be = this._backend
        _execPhysics({=> be.destroyConstraint(handle)})
    }

    /**
     * @brief[zh-cn] 约束是否启用
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 启用返回 true
     *
     * @brief[en] Whether the constraint is enabled
     * @param[en] handle The constraint handle
     * @return[en] true if enabled
     */
    public func isConstraintEnabled(handle: PhysicsConstraintHandle): Bool {
        let eBox: Box<Bool> = Box(false)
        let be = this._backend
        _execPhysics({=> eBox.value = be.isConstraintEnabled(handle)})
        return eBox.value
    }

    /**
     * @brief[zh-cn] 设置约束是否启用
     * @param[zh-cn] handle 约束句柄
     * enabled 是否启用
     *
     * @brief[en] Sets whether the constraint is enabled
     * @param[en] handle The constraint handle
     * enabled Whether the constraint is enabled
     */
    public func setConstraintEnabled(handle: PhysicsConstraintHandle, enabled: Bool): Unit {
        let be = this._backend
        _execPhysics({=> be.setConstraintEnabled(handle, enabled)})
    }

    // =========================================================================
    // 约束电机运行时控制（经物理线程转发）
    // =========================================================================

    /**
     * @brief[zh-cn] 设置约束电机状态（Hinge/Slider：Off/Velocity/Position）
     * @param[zh-cn] handle 约束句柄
     * state 电机状态
     *
     * @brief[en] Sets the constraint motor state (Hinge/Slider: Off/Velocity/Position)
     * @param[en] handle The constraint handle
     * state The motor state
     */
    public func setConstraintMotorState(handle: PhysicsConstraintHandle, state: PhysicsMotorState): Unit {
        let be = this._backend
        _execPhysics({=> be.setConstraintMotorState(handle, state)})
    }

    /**
     * @brief[zh-cn] 设置铰链约束电机目标角速度（速度模式，弧度/秒）
     * @param[zh-cn] handle 约束句柄
     * angularVelocity 目标角速度
     *
     * @brief[en] Sets the hinge motor target angular velocity (velocity mode, rad/s)
     * @param[en] handle The constraint handle
     * angularVelocity The target angular velocity
     */
    public func setConstraintTargetAngularVelocity(handle: PhysicsConstraintHandle, angularVelocity: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setConstraintTargetAngularVelocity(handle, angularVelocity)})
    }

    /**
     * @brief[zh-cn] 设置铰链约束电机目标角度（位置模式，弧度）
     * @param[zh-cn] handle 约束句柄
     * angle 目标角度
     *
     * @brief[en] Sets the hinge motor target angle (position mode, radians)
     * @param[en] handle The constraint handle
     * angle The target angle
     */
    public func setConstraintTargetAngle(handle: PhysicsConstraintHandle, angle: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setConstraintTargetAngle(handle, angle)})
    }

    /**
     * @brief[zh-cn] 读取铰链约束当前角度（弧度）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前角度
     *
     * @brief[en] Reads the hinge constraint current angle (radians)
     * @param[en] handle The constraint handle
     * @return[en] The current angle
     */
    public func getConstraintCurrentAngle(handle: PhysicsConstraintHandle): Float64 {
        let aBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({=> aBox.value = be.getConstraintCurrentAngle(handle)})
        return aBox.value
    }

    /**
     * @brief[zh-cn] 设置滑块约束电机目标速度（速度模式，米/秒）
     * @param[zh-cn] handle 约束句柄
     * velocity 目标速度
     *
     * @brief[en] Sets the slider motor target velocity (velocity mode, m/s)
     * @param[en] handle The constraint handle
     * velocity The target velocity
     */
    public func setSliderTargetVelocity(handle: PhysicsConstraintHandle, velocity: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setSliderTargetVelocity(handle, velocity)})
    }

    /**
     * @brief[zh-cn] 设置滑块约束电机目标位置（位置模式，米）
     * @param[zh-cn] handle 约束句柄
     * position 目标位置
     *
     * @brief[en] Sets the slider motor target position (position mode, meters)
     * @param[en] handle The constraint handle
     * position The target position
     */
    public func setSliderTargetPosition(handle: PhysicsConstraintHandle, position: Float64): Unit {
        let be = this._backend
        _execPhysics({=> be.setSliderTargetPosition(handle, position)})
    }

    /**
     * @brief[zh-cn] 读取滑块约束当前位置（米）
     * @param[zh-cn] handle 约束句柄
     * @return[zh-cn] 当前位置
     *
     * @brief[en] Reads the slider constraint current position (meters)
     * @param[en] handle The constraint handle
     * @return[en] The current position
     */
    public func getSliderCurrentPosition(handle: PhysicsConstraintHandle): Float64 {
        let pBox: Box<Float64> = Box(0.0)
        let be = this._backend
        _execPhysics({=> pBox.value = be.getSliderCurrentPosition(handle)})
        return pBox.value
    }
}
