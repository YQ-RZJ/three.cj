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
 * @file[zh-cn] network_sync_snapshotbuffer SnapshotBuffer 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.network.sync.SnapshotBuffer 绑定为 Lua 类型
 * three.network.sync.SnapshotBuffer
 * @explain[zh-cn] 覆盖构造（historyMs）、count / components / oldestTimeMs / newestTimeMs
 * 只读属性、addSnapshot / clear，以及采样接口：
 * - sample(timeMs, out)：与引擎签名一致，把插值结果就地写回 Lua 表 out（按 1 基下标），
 *   返回是否采样成功；out 为普通 Lua 表时也可用；
 * - sampleValues(timeMs)：绑定层便利方法，按当前分量数分配结果并返回 (ok, 数组)。
 * 无快照时 oldestTimeMs / newestTimeMs 返回 nil。
 *
 * @file[en] network_sync_snapshotbuffer  Lua binding of SnapshotBuffer (three.script.prebind)
 * @brief[en] Binds three.network.sync.SnapshotBuffer as the Lua type
 * three.network.sync.SnapshotBuffer
 * @explain[en] Covers construction (historyMs), the read-only count / components /
 * oldestTimeMs / newestTimeMs properties, addSnapshot / clear and the sampling interface:
 * - sample(timeMs, out): matches the engine signature, writing interpolated results into the
 *   Lua table out in place (1-based indices) and returning whether sampling succeeded; a plain
 *   Lua table works as out;
 * - sampleValues(timeMs): a binding-level convenience allocating a result of the current
 *   component count and returning (ok, array).
 * oldestTimeMs / newestTimeMs return nil when there are no snapshots.
 */
package three.script.prebind

import three.network.sync.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SnapshotBuffer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.network.sync.SnapshotBuffer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SnapshotBuffer
 * @param[en] vm The target virtual machine (class table installed at three.network.sync.SnapshotBuffer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSnapshotBuffer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.network.sync.SnapshotBuffer")
    // ===== 构造：new(historyMs?) =====
    b.constructor {
        args => SnapshotBuffer(historyMs: prebindNum(args, 0, default: 1000.0))
    }
    // ===== 只读属性 =====
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<SnapshotBuffer>().count)}))
    b.property("components", getter: Some({ref => LuaValue.of(ref.cast<SnapshotBuffer>().components)}))
    b.property("oldestTimeMs", getter: Some({
        ref => match (ref.cast<SnapshotBuffer>().oldestTimeMs) {
            case Some(t) => LuaValue.of(t)
            case None => LuaValue.Nil
        }
    }))
    b.property("newestTimeMs", getter: Some({
        ref => match (ref.cast<SnapshotBuffer>().newestTimeMs) {
            case Some(t) => LuaValue.of(t)
            case None => LuaValue.Nil
        }
    }))
    // ===== 追加快照（values: Float32 数组） =====
    b.method("addSnapshot") {
        ref, args =>
            ref.cast<SnapshotBuffer>().addSnapshot(prebindNum(args, 0), prebindF32Array(vm, args, 1))
            Array<LuaValue>()
    }
    // ===== 采样：就地写回 Lua 表 =====
    b.method("sample") {
        ref, args =>
            let buf = ref.cast<SnapshotBuffer>()
            let n = buf.components
            if (args.size < 2 || !args[1].isTable || n <= 0) {
                [LuaValue.Boolean(false)]
            } else {
                let t = LuaTable(vm: vm, ref: Int32(args[1].refId()))
                let out = Array<Float32>(n, {_ => 0.0f32})
                let ok = buf.sample(prebindNum(args, 0), out)
                if (ok) {
                    for (i in 0..n) {
                        t.setIndex(Int32(i + 1), LuaValue.of(Float64(out[i])))
                    }
                }
                [LuaValue.Boolean(ok)]
            }
    }
    // ===== 采样：返回结果数组 =====
    b.method("sampleValues") {
        ref, args =>
            let buf = ref.cast<SnapshotBuffer>()
            let n = buf.components
            if (n <= 0) {
                [LuaValue.Boolean(false), prebindF32ArrayToLua(Array<Float32>())]
            } else {
                let out = Array<Float32>(n, {_ => 0.0f32})
                let ok = buf.sample(prebindNum(args, 0), out)
                [LuaValue.Boolean(ok), prebindF32ArrayToLua(out)]
            }
    }
    // ===== 清空 =====
    b.method("clear") {
        ref, _ =>
            ref.cast<SnapshotBuffer>().clear()
            Array<LuaValue>()
    }
    b.install(vm)
}
