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
 * @file[zh-cn] Lockstep 确定性帧同步会话（three.network.sync 子包）
 * @brief[zh-cn] 定长 tick + 输入延迟 + 全员输入就绪推进的 lockstep 帧同步
 * @explain[zh-cn] 补齐 RTS/格斗类游戏常用的确定性帧同步核心（对照 Unity Lockstep / RTS 教材模型）：
 * - tick 节拍：update(dt) 累积时间，每满 tickIntervalMs 推进一个逻辑 tick；
 *   本类只做"节拍与输入汇集"，不涉网络（输入经 Connection/ReliableChannel 收发后
 *   由用户调用 submitRemoteInput 喂入），保持纯逻辑可单测。
 * - 输入延迟：submitLocalInput 把本地输入调度到 confirmedTick + inputDelayTicks 生效，
 *   为传输留出窗口（对抗网络抖动的经典手段）。
 * - 推进条件：目标 tick 收齐全部玩家的输入才 onAdvance（确定性模拟的前提）；
 *   maxWaitMs > 0 时超时用空输入补齐强制推进（防单点卡帧拖死全场；
 *   @todo 更严谨的做法是记录超时玩家并做 desync 检测）。
 * - 确定性要求：onAdvance 里用户模拟必须只用 (tick, inputs) 派生状态，
 *   不读真实时钟/随机数（或用可播种随机）；输入数据建议经 PacketWriter 编码。
 * 典型用法：
 * let session = LockstepSession(localPlayerId: 1)
 * session.addPlayer(2)
 * session.onAdvance = Some({ tick, ids, inputs => /* 确定性模拟一步 */ })
 * // 每帧：
 * session.submitLocalInput(collectInput())
 * session.update(dt)
 * // 收到远端输入（网络线程投递）：
 * session.submitRemoteInput(2, tick, data)
 *
 * @file[en] Lockstep  Deterministic lockstep session (three.network.sync sub-package)
 * @brief[en] Fixed-rate ticks + input delay + all-inputs-ready advancement lockstep
 * @explain[en] Fills in the deterministic lockstep core used by RTS/fighting games
 * (mirroring the classic Unity Lockstep / RTS tutorial model):
 * - Tick pacing: update(dt) accumulates time and advances one logic tick per
 *   tickIntervalMs; this class only does "pacing and input gathering" and knows nothing
 *   about the network (inputs travel via Connection/ReliableChannel and are fed back
 *   through submitRemoteInput), staying pure-logic and unit-testable.
 * - Input delay: submitLocalInput schedules local input to take effect at
 *   confirmedTick + inputDelayTicks, leaving a window for transport (the classic remedy
 *   against network jitter).
 * - Advancement: a target tick advances (onAdvance) only when every player's input for
 *   it has arrived (the precondition of deterministic simulation); with maxWaitMs > 0 a
 *   timeout force-advances using empty inputs (so one stalled peer cannot freeze the
 *   game; @todo a stricter approach records timed-out players for desync detection).
 * - Determinism: the simulation inside onAdvance must derive state only from
 *   (tick, inputs), never reading the real clock or unseeded randomness; encode input
 *   payloads with PacketWriter.
 * Usage:
 * let session = LockstepSession(localPlayerId: 1)
 * session.addPlayer(2)
 * session.onAdvance = Some({ tick, ids, inputs => /* one deterministic step */ })
 * // every frame:
 * session.submitLocalInput(collectInput())
 * session.update(dt)
 * // on remote input (delivered from the network thread):
 * session.submitRemoteInput(2, tick, data)
 */
package three.network.sync

import std.collection.ArrayList
import std.collection.HashMap

/**
 * @brief[zh-cn] lockstep 帧同步会话
 * @explain[zh-cn] 纯逻辑（无线程/无 IO）：所有 public 方法单线程调用（主循环）；
 * 网络线程收到的输入经线程安全队列转交（用户侧保证）。
 *
 * @brief[en] Lockstep session
 * @explain[en] Pure logic (no threads/no IO): call every public method from one thread
 * (the main loop); inputs arriving on network threads should be forwarded through a
 * thread-safe queue on the user side.
 */
public class LockstepSession {
    /**
     * @brief[zh-cn] 逻辑 tick 间隔（毫秒，默认 50 = 20tps）
     *
     * @brief[en] Logic tick interval in ms (default 50 = 20 tps)
     */
    public var tickIntervalMs: Float64 = 50.0

    /**
     * @brief[zh-cn] 本地输入延迟 tick 数（默认 2，为传输留窗口）
     *
     * @brief[en] Local input delay in ticks (default 2, transport window)
     */
    public var inputDelayTicks: Int64 = 2

    /**
     * @brief[zh-cn] 等待全员输入的超时（毫秒；0 = 无限等待，默认 250）
     *
     * @brief[en] Timeout waiting for all inputs in ms (0 = wait forever, default 250)
     */
    public var maxWaitMs: Float64 = 250.0

    /**
     * @brief[zh-cn] tick 推进回调（参数：tick 号、玩家 id 序列、与 id 对齐的输入载荷）
     *
     * @brief[en] Tick-advance callback (params: tick number, player ids, input payloads
     * aligned with the ids)
     */
    public var onAdvance: Option<(Int64, Array<Int32>, Array<Array<UInt8>>) -> Unit> = None

    /** 参与玩家（含本地玩家） */
    private var _players: ArrayList<Int32>

    /** 已收输入：tick → (playerId → 载荷) */
    private var _inputs: HashMap<Int64, HashMap<Int32, Array<UInt8>>>

    /** 已确认推进到的 tick */
    private var _confirmedTick: Int64

    /** 时间累积（毫秒，update(dt) 累加） */
    private var _accumMs: Float64

    /** 开始等待目标 tick 输入的时刻（累计毫秒） */
    private var _waitStartMs: Float64

    /** 累计总时长（毫秒，超时判定基准） */
    private var _elapsedMs: Float64

    /** 本地玩家 id */
    private let _localPlayerId: Int32

    /**
     * @brief[zh-cn] 构造帧同步会话
     * @param[zh-cn] localPlayerId 本地玩家 id（自动加入玩家列表）
     *
     * @brief[en] Constructs a lockstep session
     * @param[en] localPlayerId Local player id (auto-added to the player list)
     */
    public init(localPlayerId: Int32) {
        this._players = ArrayList<Int32>()
        this._players.add(localPlayerId)
        this._inputs = HashMap<Int64, HashMap<Int32, Array<UInt8>>>()
        this._confirmedTick = -1
        this._accumMs = 0.0
        this._waitStartMs = 0.0
        this._elapsedMs = 0.0
        this._localPlayerId = localPlayerId
    }

    /**
     * @brief[zh-cn] 本地玩家 id
     *
     * @brief[en] Local player id
     */
    public prop localPlayerId: Int32 {
        get() { _localPlayerId }
    }

    /**
     * @brief[zh-cn] 已确认推进到的 tick（下一目标为 confirmedTick + 1）
     *
     * @brief[en] Last confirmed tick (next target is confirmedTick + 1)
     */
    public prop confirmedTick: Int64 {
        get() { _confirmedTick }
    }

    /**
     * @brief[zh-cn] 当前目标 tick（等待输入中的 tick）
     *
     * @brief[en] Current target tick (the tick waiting for inputs)
     */
    public prop targetTick: Int64 {
        get() { _confirmedTick + 1 }
    }

    /**
     * @brief[zh-cn] 加入玩家
     * @param[zh-cn] id 玩家 id
     * @return[zh-cn] 新加入返回 true；已存在返回 false
     *
     * @brief[en] Adds a player
     * @param[en] id Player id
     * @return[en] True when newly added; false when already present
     */
    public func addPlayer(id: Int32): Bool {
        for (p in _players) {
            if (p == id) {
                return false
            }
        }
        _players.add(id)
        return true
    }

    /**
     * @brief[zh-cn] 移除玩家（其未消费输入一并清除）
     * @param[zh-cn] id 玩家 id
     *
     * @brief[en] Removes a player (its unconsumed inputs are dropped too)
     * @param[en] id Player id
     */
    public func removePlayer(id: Int32): Unit {
        var idx = -1
        var i: Int64 = 0
        for (p in _players) {
            if (p == id) {
                idx = i
            }
            i += 1
        }
        if (idx >= 0) {
            _players.remove(at: idx)
        }
        for ((_, byPlayer) in _inputs) {
            byPlayer.remove(id)
        }
    }

    /**
     * @brief[zh-cn] 提交本地输入（调度到 confirmedTick + inputDelayTicks 生效）
     * @param[zh-cn] data 输入载荷（建议 PacketWriter 编码；同 tick 重复提交覆盖）
     *
     * @brief[en] Submits local input (scheduled for confirmedTick + inputDelayTicks)
     * @param[en] data Input payload (PacketWriter recommended; resubmission for the same
     * tick overwrites)
     */
    public func submitLocalInput(data: Array<UInt8>): Unit {
        let tick = this._confirmedTick + this.inputDelayTicks
        this._putInput(tick, this._localPlayerId, data)
    }

    /**
     * @brief[zh-cn] 提交远端玩家输入（网络层收到后喂入）
     * @param[zh-cn] playerId 玩家 id（须已加入会话）
     * tick 输入对应的 tick 号
     * data 输入载荷
     * @return[zh-cn] 接受返回 true；玩家不存在返回 false
     *
     * @brief[en] Submits a remote player's input (feed from the network layer)
     * @param[en] playerId Player id (must be joined)
     * tick The tick the input belongs to
     * data Input payload
     * @return[en] True when accepted; false when the player is unknown
     */
    public func submitRemoteInput(playerId: Int32, tick: Int64, data: Array<UInt8>): Bool {
        var known = false
        for (p in _players) {
            if (p == playerId) {
                known = true
            }
        }
        if (!known) {
            return false
        }
        this._putInput(tick, playerId, data)
        return true
    }

    /**
     * @brief[zh-cn] 主循环每帧驱动：累积时间并按节拍推进 tick
     * @param[zh-cn] dt 帧间隔（秒）
     *
     * @brief[en] Per-frame main-loop driver: accumulates time and advances ticks on beat
     * @param[en] dt Frame delta (seconds)
     */
    public func update(dt: Float64): Unit {
        this._accumMs += dt * 1000.0
        this._elapsedMs += dt * 1000.0
        while (this._accumMs >= this.tickIntervalMs) {
            this._accumMs -= this.tickIntervalMs
            this._tryAdvance()
        }
    }

    /**
     * @brief[zh-cn] 清空会话状态（重开一局时使用；玩家列表保留）
     *
     * @brief[en] Resets session state (for restarting a match; player list is kept)
     */
    public func reset(): Unit {
        this._inputs.clear()
        this._confirmedTick = -1
        this._accumMs = 0.0
        this._waitStartMs = 0.0
        this._elapsedMs = 0.0
    }

    // ===== 内部 =====

    /** 尝试推进一个 tick：全员输入就绪 → 推进；超时 → 空输入补齐强制推进 */
    private func _tryAdvance(): Unit {
        let target = this._confirmedTick + 1
        let byPlayerOpt = this._inputs.get(target)
        // 1. 检查是否全员就绪
        var allReady = true
        if (let Some(byPlayer) <- byPlayerOpt) {
            for (p in _players) {
                if (!byPlayer.contains(p)) {
                    allReady = false
                }
            }
        } else {
            allReady = _players.size == 0
        }
        // 2. 未就绪 → 超时判定
        if (!allReady) {
            if (this._waitStartMs <= 0.0) {
                this._waitStartMs = this._elapsedMs
            }
            if (!(this.maxWaitMs > 0.0 && this._elapsedMs - this._waitStartMs >= this.maxWaitMs)) {
                return
            }
            // 超时：缺输入的玩家以空输入补齐（记录告警，语义为"该玩家本 tick 无操作"）
        }
        // 3. 组装推进参数（缺的补空输入）
        let ids = Array<Int32>(_players.size, { i => _players[i] })
        let payloadList = ArrayList<Array<UInt8>>()
        for (p in _players) {
            if (let Some(byPlayer) <- byPlayerOpt && let Some(data) <- byPlayer.get(p)) {
                payloadList.add(data)
            } else {
                payloadList.add(Array<UInt8>())
            }
        }
        let inputs = Array<Array<UInt8>>(payloadList.size, { i => payloadList[i] })
        // 4. 推进并清理
        this._confirmedTick = target
        this._waitStartMs = 0.0
        this._inputs.remove(target)
        if (let Some(cb) <- this.onAdvance) { cb(target, ids, inputs) }
    }

    /** 放入一条输入（无则建 tick 桶） */
    private func _putInput(tick: Int64, playerId: Int32, data: Array<UInt8>): Unit {
        let bucketOpt = this._inputs.get(tick)
        if (let Some(bucket) <- bucketOpt) {
            bucket.add(playerId, data)
        } else {
            let bucket = HashMap<Int32, Array<UInt8>>()
            bucket.add(playerId, data)
            this._inputs.add(tick, bucket)
        }
    }
}
