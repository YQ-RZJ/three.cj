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
 * @file[zh-cn] network_sync_lockstep LockstepSession 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.sync.LockstepSession 绑定为 Lua 类型
 * three.network.sync.LockstepSession
 * @explain[zh-cn] 覆盖构造（localPlayerId）、localPlayerId / confirmedTick / targetTick
 * 只读属性、tickIntervalMs / inputDelayTicks / maxWaitMs 可读写配置、
 * addPlayer / removePlayer / submitLocalInput / submitRemoteInput / update / reset，
 * 以及 onAdvance 推进回调。
 * onAdvance 由引擎在 Lua 线程的 update() 内同步触发，绑定层按
 * (tick, ids, inputs) 三参数回调，ids 为数值数组、inputs 为「字节数组的数组」；
 * 回调自身出错时静默跳过（不让异常穿过绑定层触发 lua_error 的 longjmp）。
 *
 * @file[en] network_sync_lockstep  Lua binding of LockstepSession (three.script.prebind)
 * @brief[en] Binds three.network.sync.LockstepSession as the Lua type
 * three.network.sync.LockstepSession
 * @explain[en] Covers construction (localPlayerId), the read-only localPlayerId /
 * confirmedTick / targetTick properties, the mutable tickIntervalMs / inputDelayTicks /
 * maxWaitMs settings, addPlayer / removePlayer / submitLocalInput / submitRemoteInput /
 * update / reset, and the onAdvance callback.
 * The engine fires onAdvance synchronously inside update() on the Lua thread; the binding
 * invokes it with (tick, ids, inputs), where ids is a number array and inputs is an array of
 * byte arrays. A failing callback is silently skipped (so no exception crosses the binding
 * layer and triggers lua_error's longjmp).
 */
package three.script.prebind

import three.network.sync.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安全执行一次 onAdvance 回调（参数转成 Lua 侧形态后调用）
 * @param[zh-cn] cb Lua 回调
 * @param[zh-cn] tick 逻辑 tick 号
 * @param[zh-cn] ids 玩家 id 数组
 * @param[zh-cn] inputs 与 ids 对齐的输入载荷数组
 *
 * @brief[en] Safely runs one onAdvance callback (converting the arguments to Lua form)
 * @param[en] cb The Lua callback
 * @param[en] tick The logic tick number
 * @param[en] ids The player id array
 * @param[en] inputs The input payloads aligned with ids
 */
private func _dispatchAdvance(cb: LuaCallback, tick: Int64, ids: Array<Int32>, inputs: Array<Array<UInt8>>): Unit {
    let luaIds = Array<LuaValue>(ids.size, {i => LuaValue.of(Int64(ids[i]))})
    let luaInputs = Array<LuaValue>(inputs.size, {i => prebindBytesToLua(inputs[i])})
    try {
        cb.call(args: [LuaValue.of(tick), LuaValue.Array(luaIds), LuaValue.Array(luaInputs)])
    } catch (e: LuaReentryLimitError) {
        // 重入超限是主动中止信号，不能被静默吞掉（否则与栈被打穿时的死循环无法区分）
        eprintln("LockstepSession.onAdvance 已中止：${e.message}")
    } catch (_) {
        // 回调自身出错：跳过，不向引擎抛出
    }
}

/**
 * @brief[zh-cn] 安装 LockstepSession 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.sync.LockstepSession）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LockstepSession
 * @param[en] vm The target virtual machine (class table installed at three.network.sync.LockstepSession)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLockstepSession(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.sync.LockstepSession")
    // ===== 构造：new(localPlayerId) =====
    b.constructor {
        args => LockstepSession(Int32(prebindInt(args, 0)))
    }
    // ===== 节拍 / 延迟配置 =====
    b.property("tickIntervalMs", getter: Some({ref => LuaValue.of(ref.cast<LockstepSession>().tickIntervalMs)}),
        setter: Some({ref, v => ref.cast<LockstepSession>().tickIntervalMs = v.numberValue()}))
    b.property("inputDelayTicks", getter: Some({ref => LuaValue.of(ref.cast<LockstepSession>().inputDelayTicks)}),
        setter: Some({ref, v => ref.cast<LockstepSession>().inputDelayTicks = v.intValue()}))
    b.property("maxWaitMs", getter: Some({ref => LuaValue.of(ref.cast<LockstepSession>().maxWaitMs)}),
        setter: Some({ref, v => ref.cast<LockstepSession>().maxWaitMs = v.numberValue()}))
    // ===== 状态（只读） =====
    b.property("localPlayerId", getter: Some({ref => LuaValue.of(Int64(ref.cast<LockstepSession>().localPlayerId))}))
    b.property("confirmedTick", getter: Some({ref => LuaValue.of(ref.cast<LockstepSession>().confirmedTick)}))
    b.property("targetTick", getter: Some({ref => LuaValue.of(ref.cast<LockstepSession>().targetTick)}))
    // ===== 推进回调（只写） =====
    b.property(
        "onAdvance",
        getter: Some({_ => LuaValue.Nil}),
        setter: Some(
            {
                ref, v =>
                    let session = ref.cast<LockstepSession>()
                    if (let Some(cb) <- prebindOptCallbackOf(vm, v)) {
                        session.onAdvance = Some({
                            tick: Int64, ids: Array<Int32>, inputs: Array<Array<UInt8>> => _dispatchAdvance(cb, tick,
                                ids, inputs)
                        })
                    } else {
                        session.onAdvance = None
                    }
            }
        )
    )
    // ===== 玩家管理 =====
    b.method("addPlayer") {
        ref, args => [LuaValue.of(ref.cast<LockstepSession>().addPlayer(Int32(prebindInt(args, 0))))]
    }
    b.method("removePlayer") {
        ref, args =>
            ref.cast<LockstepSession>().removePlayer(Int32(prebindInt(args, 0)))
            Array<LuaValue>()
    }
    // ===== 输入提交 =====
    b.method("submitLocalInput") {
        ref, args =>
            ref.cast<LockstepSession>().submitLocalInput(prebindBytes(vm, args, 0))
            Array<LuaValue>()
    }
    b.method("submitRemoteInput") {
        ref, args => [LuaValue.of(
            ref
                .cast<LockstepSession>()
                .submitRemoteInput(Int32(prebindInt(args, 0)), prebindInt(args, 1), prebindBytes(vm, args, 2)))]
    }
    // ===== 主循环驱动 =====
    b.method("update") {
        ref, args =>
            ref.cast<LockstepSession>().update(prebindNum(args, 0))
            Array<LuaValue>()
    }
    b.method("reset") {
        ref, _ =>
            ref.cast<LockstepSession>().reset()
            Array<LuaValue>()
    }
    b.install(vm)
}
