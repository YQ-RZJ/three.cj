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
 * @file[zh-cn] SnapshotBuffer 实体状态快照缓冲与插值（three.network.sync 子包）
 * @brief[zh-cn] 面向状态同步（C/S snapshot 模型）的时间序列快照缓冲 + 线性插值采样
 * @explain[zh-cn] 补齐 FPS/MOBA 类状态同步模型的客户端表现层核心（对照 Source 引擎
 * entity interpolation / Unreal 延迟补偿的表现侧）：
 * - 服务端按固定节奏广播实体状态（位置/朝向/动画参数等压平为 Float32 向量），
 *   客户端 addSnapshot(serverTime, values) 存入；本地渲染时刻取
 *   renderTime = 服务器时间 - interpDelayMs（典型 100ms），sample(renderTime, out)
 *   在相邻两快照间线性插值，消除网络抖动带来的卡顿/回跳。
 * - 时间约定：timeMs 单调递增（用服务器时间戳，不与本机时钟混合）；
 *   sample(t) 落在最早快照之前或最晚快照之后返回 false（不做外推）。
 * - 容量控制：只保留最近 historyMs 毫秒的快照（保留一对夹住边界的快照）。
 * - 泛型性：Float32 向量由业务自行约定布局（如 [x,y,z, yaw, pitch, animTime...]），
 *   本类不关心语义；每个快照向量长度须一致（不一致的 addSnapshot 被忽略并告警）。
 * 典型用法：
 * let buf = SnapshotBuffer(historyMs: 1000.0)
 * // 网络线程收到快照 → 转投主循环后：
 * buf.addSnapshot(serverTimeMs, [x, y, z, yaw])
 * // 渲染帧：
 * let out = Array<Float32>(4, repeat: 0.0)
 * if (buf.sample(renderTimeMs, out)) { entity.position = (out[0], out[1], out[2]) }
 *
 * @file[en] SnapshotBuffer  Entity-state snapshot buffer with interpolation
 * (three.network.sync sub-package)
 * @brief[en] Time-series snapshot buffer + linear-interpolation sampling for the
 * client-side presentation of the C/S snapshot model
 * @explain[en] Fills in the client presentation core of the state-sync model used by
 * FPS/MOBA games (mirroring Source engine entity interpolation / the presentation side of
 * Unreal lag compensation):
 * - The server broadcasts entity state (position/orientation/animation params flattened
 *   into a Float32 vector) at a fixed cadence; the client stores it via
 *   addSnapshot(serverTime, values); at local render time, take
 *   renderTime = server time - interpDelayMs (typically 100ms) and use
 *   sample(renderTime, out) to linearly interpolate between adjacent snapshots, smoothing
 *   out jitter-induced stalls/teleports.
 * - Time convention: timeMs is monotonically increasing (use server timestamps, never mix
 *   with the local clock); sample(t) returns false before the oldest or after the newest
 *   snapshot (no extrapolation).
 * - Capacity: only snapshots within the last historyMs are kept (one bounding pair is
 *   preserved).
 * - Genericity: the Float32 vector layout is up to the business (e.g.
 *   [x,y,z, yaw, pitch, animTime...]); this class is semantics-agnostic; every snapshot
 *   vector must share one length (mismatched addSnapshot calls are ignored with a warning).
 * Usage:
 * let buf = SnapshotBuffer(historyMs: 1000.0)
 * // snapshot received on a network thread - forward to the main loop, then:
 * buf.addSnapshot(serverTimeMs, [x, y, z, yaw])
 * // render frame:
 * let out = Array<Float32>(4, repeat: 0.0)
 * if (buf.sample(renderTimeMs, out)) { entity.position = (out[0], out[1], out[2]) }
 */
package three.network.sync

import std.collection.ArrayList
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 快照缓冲（时间序列 + 线性插值）
 * @explain[zh-cn] 纯数据结构，无线程同步（约定主循环单线程访问；
 * 网络线程收到的快照由用户转投主循环后再调用）。
 *
 * @brief[en] Snapshot buffer (time series + linear interpolation)
 * @explain[en] Pure data structure with no internal synchronization (intended for
 * single-thread main-loop access; forward snapshots received on network threads to the
 * main loop before calling).
 */
public class SnapshotBuffer {
    /** 历史保留时长（毫秒） */
    private let _historyMs: Float64

    /** 快照序列（时间严格递增） */
    private var _snaps: ArrayList<(Float64, Array<Float32>)>

    /** 每快照分量数（首快照确立） */
    private var _componentCount: Int64

    /**
     * @brief[zh-cn] 构造快照缓冲
     * @param[zh-cn] historyMs 历史保留时长（毫秒，默认 1000）
     *
     * @brief[en] Constructs a snapshot buffer
     * @param[en] historyMs History retention in ms (default 1000)
     */
    public init(historyMs!: Float64 = 1000.0) {
        this._historyMs = historyMs
        this._snaps = ArrayList<(Float64, Array<Float32>)>()
        this._componentCount = 0
    }

    /**
     * @brief[zh-cn] 当前快照数量
     *
     * @brief[en] Current snapshot count
     */
    public prop count: Int64 {
        get() { _snaps.size }
    }

    /**
     * @brief[zh-cn] 追加快照
     * @param[zh-cn] timeMs 服务器时间戳（毫秒，须不小于上一快照时间）
     * values 状态向量（长度须与既有快照一致）
     *
     * @brief[en] Appends a snapshot
     * @param[en] timeMs Server timestamp in ms (must be ≥ the previous snapshot time)
     * values State vector (length must match existing snapshots)
     */
    public func addSnapshot(timeMs: Float64, values: Array<Float32>): Unit {
        // 时间必须不早于最后一帧（网络乱序到达时丢弃更早的快照）
        if (_snaps.size > 0) {
            let last = _snaps[_snaps.size - 1]
            if (timeMs < last[0]) {
                return
            }
        }
        // 分量数一致性（首快照确立，后续不一致忽略）
        if (_componentCount == 0) {
            _componentCount = Int64(values.size)
        } else if (Int64(values.size) != _componentCount) {
            @LogWarn(["SnapshotBuffer: snapshot has ${values.size} components, expected ${_componentCount} - ignored"])
            return
        }
        // 相同时间戳：覆盖最后一帧
        if (_snaps.size > 0) {
            let last = _snaps[_snaps.size - 1]
            if (timeMs == last[0]) {
                _snaps[_snaps.size - 1] = (timeMs, values.clone())
                return
            }
        }
        _snaps.add((timeMs, values.clone()))
        this._trim()
    }

    /**
     * @brief[zh-cn] 在相邻快照间线性插值采样
     * @param[zh-cn] timeMs 采样时刻（毫秒；建议 = 服务器时间 - 插值延迟）
     * out 输出向量（长度须等于快照分量数，结果写入此数组）
     * @return[zh-cn] 采样成功返回 true；快照不足/时刻越界/长度不符返回 false
     *
     * @brief[en] Linearly interpolates between adjacent snapshots
     * @param[en] timeMs Sample time in ms (recommended: server time - interpolation delay)
     * out Output vector (length must equal the snapshot component count)
     * @return[en] True on success; false when snapshots are insufficient, the time is out
     * of range, or the length mismatches
     */
    public func sample(timeMs: Float64, out: Array<Float32>): Bool {
        if (_snaps.size < 2 || Int64(out.size) != _componentCount) {
            return false
        }
        // 早于最早快照 / 晚于最晚快照：不外推
        let oldest = _snaps[0]
        let newest = _snaps[_snaps.size - 1]
        if (timeMs < oldest[0] || timeMs > newest[0]) {
            return false
        }
        // 从尾向前找夹住 timeMs 的相邻对（插值采样集中于序列末端）
        var i = _snaps.size - 2
        while (i >= 0) {
            let s0 = _snaps[i]
            let s1 = _snaps[i + 1]
            if (timeMs >= s0[0]) {
                let span = s1[0] - s0[0]
                let alpha = if (span > 0.0) { (timeMs - s0[0]) / span } else { 0.0 }
                for (c in 0.._componentCount) {
                    let a = Float64(s0[1][c])
                    let b = Float64(s1[1][c])
                    out[c] = Float32(a + (b - a) * alpha)
                }
                return true
            }
            i -= 1
        }
        return false
    }

    /**
     * @brief[zh-cn] 最早快照时间（毫秒；无快照返回 None）
     *
     * @brief[en] Oldest snapshot time in ms (None when empty)
     */
    public prop oldestTimeMs: Option<Float64> {
        get() {
            if (_snaps.size == 0) {
                return None<Float64>
            }
            return Some(_snaps[0][0])
        }
    }

    /**
     * @brief[zh-cn] 最晚快照时间（毫秒；无快照返回 None）
     *
     * @brief[en] Newest snapshot time in ms (None when empty)
     */
    public prop newestTimeMs: Option<Float64> {
        get() {
            if (_snaps.size == 0) {
                return None<Float64>
            }
            return Some(_snaps[_snaps.size - 1][0])
        }
    }

    /**
     * @brief[zh-cn] 每快照分量数（无快照时为 0）
     *
     * @brief[en] Component count per snapshot (0 when empty)
     */
    public prop components: Int64 {
        get() { _componentCount }
    }

    /**
     * @brief[zh-cn] 清空全部快照
     *
     * @brief[en] Clears all snapshots
     */
    public func clear(): Unit {
        _snaps.clear()
        _componentCount = 0
    }

    /** 裁剪超龄快照（保留一对夹住 history 边界的快照，保证旧端可采样） */
    private func _trim(): Unit {
        if (_snaps.size < 2) {
            return
        }
        let newestTime = _snaps[_snaps.size - 1][0]
        let cutoff = newestTime - this._historyMs
        var removeCount: Int64 = 0
        // 保留第一个时间 ≥ cutoff 的快照之前的一对（即最后一个 < cutoff 的及其后一个）
        while (removeCount + 2 < _snaps.size && _snaps[removeCount + 1][0] < cutoff) {
            removeCount += 1
        }
        for (_i in 0..removeCount) {
            _snaps.remove(at: 0)
        }
    }
}
