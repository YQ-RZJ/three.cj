/**
 * @file SyncTest
 * @brief test_network: Lockstep 帧同步 + SnapshotBuffer 快照插值测试（纯逻辑，无网络）
 *
 * 检测 three.network.sync 能力：
 * - LockstepSession：玩家管理 / 输入调度 / 全员就绪推进 / 超时空输入补齐 / reset
 * - SnapshotBuffer：追加去重 / 线性插值 / 越界不外推 / history 裁剪 / clear
 */
package threeNetworkTest

import three.network.sync.*

// ===== 局部断言辅助（避免与 main.cj 的 private check 冲突） =====

private var _syncPass: Int64 = 0
private var _syncFail: Int64 = 0

private func ck(name: String, cond: Bool): Unit {
    if (cond) {
        _syncPass += 1
        println("  [PASS] ${name}")
    } else {
        _syncFail += 1
        println("  [FAIL] ${name}")
    }
}

/// lockstep onAdvance 回调状态容器（lambda 不能捕获可变变量）
class LockstepState {
    var advanced: Int64 = 0
    var lastTick: Int64 = -1
    var lastInputs: Int64 = 0
}

// ===== 测试函数（由 main.cj 调用） =====

/// LockstepSession 基础推进流程
func test_lockstep_advance(): Unit {
    println("[S1] LockstepSession 全员就绪推进")
    let session = LockstepSession(1)
    ck("本地玩家后加入玩家 2", session.addPlayer(2))
    ck("重复加入被拒绝", !session.addPlayer(2))
    ck("初始 confirmedTick = -1", session.confirmedTick == -1)
    ck("未知玩家提交被拒", !session.submitRemoteInput(99, 0, [0x1u8]))

    let state = LockstepState()
    session.onAdvance = Some({ tick, _ids, inputs =>
        state.advanced += 1
        state.lastTick = tick
        state.lastInputs = Int64(inputs.size)
    })

    // tick 0：远端玩家输入就绪；本地输入被调度到 tick1（inputDelay=2），
    // 这里直接以远端通道为本地玩家补 tick0 输入，模拟输入延迟为 0 的对齐场景
    ck("玩家 2 tick0 输入", session.submitRemoteInput(2, 0, [0x1u8]))
    session.update(0.06)
    ck("输入未齐不推进", state.advanced == 0)
    ck("本地玩家 tick0 输入", session.submitRemoteInput(1, 0, [0x0Au8]))
    // tick 推进按节拍：再次到达 tickInterval 后推进
    session.update(0.06)
    ck("全员就绪推进 1 tick", state.advanced == 1)
    ck("推进到 tick0", state.lastTick == 0 && session.confirmedTick == 0)
    ck("输入对齐玩家数", state.lastInputs == 2)
    println("")
}

/// LockstepSession 超时强制推进 + reset
func test_lockstep_timeout(): Unit {
    println("[S2] LockstepSession 超时补齐")
    let session = LockstepSession(1)
    session.addPlayer(2)
    session.maxWaitMs = 100.0
    let state = LockstepState()
    session.onAdvance = Some({ _tick, _ids, inputs =>
        state.advanced += 1
        state.lastInputs = Int64(inputs.size)
    })
    // 只有本地输入，远端不响应 → 超时跨 update 累积：第二次 update 后超时强制推进
    session.submitLocalInput([0x01u8])
    session.update(0.4)
    ck("首次 update 未超时不推进", state.advanced == 0)
    session.update(0.4)
    ck("超时强制推进", state.advanced == 1)
    ck("空输入补齐（对齐玩家数）", state.lastInputs == 2)
    ck("confirmedTick = 0", session.confirmedTick == 0)
    session.reset()
    ck("reset 后回到 -1", session.confirmedTick == -1)
    println("")
}

/// SnapshotBuffer 插值与容量控制
func test_snapshot_buffer(): Unit {
    println("[S3] SnapshotBuffer 快照插值")
    let buf = SnapshotBuffer(historyMs: 1000.0)
    buf.addSnapshot(100.0, [0.0, 0.0])
    let out = Array<Float32>(2, repeat: 0.0)
    ck("快照不足不可采样", !buf.sample(100.0, out))

    buf.addSnapshot(200.0, [10.0, 20.0])
    ck("两帧可采样", buf.sample(150.0, out))
    ck("线性插值 x = 5", Float64(out[0]) == 5.0)
    ck("线性插值 y = 10", Float64(out[1]) == 10.0)

    buf.addSnapshot(150.0, [99.0, 99.0])
    ck("乱序快照被丢弃", buf.count == 2)
    buf.addSnapshot(200.0, [11.0, 21.0])
    ck("相同时间戳覆盖", buf.count == 2)
    buf.addSnapshot(300.0, [1.0, 2.0, 3.0])
    ck("分量数不一致被忽略", buf.count == 2)

    ck("早于最早不外推", !buf.sample(50.0, out))
    ck("晚于最晚不外推", !buf.sample(500.0, out))

    // history 裁剪：推入远期快照后早期被裁掉；
    // 引擎刻意保留一对跨越边界的快照（最后一个 < cutoff 的及其后一个）
    buf.addSnapshot(2500.0, [30.0, 60.0])
    buf.addSnapshot(2600.0, [40.0, 80.0])
    var oldestOk = false
    match (buf.oldestTimeMs) {
        case Some(t) => oldestOk = t == 200.0
        case None => ()
    }
    ck("history 裁剪（保留边界对）", oldestOk && buf.count == 3)

    buf.clear()
    ck("clear 清空", buf.count == 0 && buf.components == 0)
    println("")
}

/// sync 子包结果汇总（供 main.cj 合并统计）
func syncPassCount(): Int64 { _syncPass }
func syncFailCount(): Int64 { _syncFail }
