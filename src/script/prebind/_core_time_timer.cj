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
 * @file[zh-cn] core_time_timer 高性能计时器 Timer 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.time.Timer 绑定为 Lua 类型 three.core.time.Timer
 * @explain[zh-cn] 覆盖构造（new）、属性（useFixedDelta/fixedDelta 可读写）与方法
 * （getDelta/getElapsed/getTimescale 查询，setTimescale/reset/update 链式返回自身，
 * release 返回 Bool，start/stop 兼容入口）。
 *
 * @file[en] core_time_timer  Lua binding of the high-performance timer Timer
 * (three.script.prebind)
 * @brief[en] Binds three.core.time.Timer as the Lua type three.core.time.Timer
 * @explain[en] Covers construction (new), properties (useFixedDelta/fixedDelta read-write)
 * and methods (getDelta/getElapsed/getTimescale queries; setTimescale/reset/update return
 * self for chaining; release returns Bool; start/stop are legacy entry points).
 */
package three.script.prebind

import three.core.time.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Timer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.time.Timer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Timer
 * @param[en] vm The target virtual machine (class table installed at three.core.time.Timer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTimer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.time.Timer")
    // ===== 构造 =====
    b.constructor {_ => Timer()}
    // ===== 属性 =====
    b.property("useFixedDelta", getter: Some({ref => LuaValue.of(ref.cast<Timer>().useFixedDelta)}),
        setter: Some({ref, v => ref.cast<Timer>().useFixedDelta = v.boolValue()}))
    b.property("fixedDelta", getter: Some({ref => LuaValue.of(ref.cast<Timer>().fixedDelta)}),
        setter: Some({ref, v => ref.cast<Timer>().fixedDelta = v.numberValue()}))
    // ===== 查询 =====
    b.method("getDelta") {
        ref, _ => [LuaValue.of(ref.cast<Timer>().getDelta())]
    }
    b.method("getElapsed") {
        ref, _ => [LuaValue.of(ref.cast<Timer>().getElapsed())]
    }
    b.method("getTimescale") {
        ref, _ => [LuaValue.of(ref.cast<Timer>().getTimescale())]
    }
    // ===== 链式设置 =====
    b.method("setTimescale") {
        ref, args =>
            ref.cast<Timer>().setTimescale(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("reset") {
        ref, _ =>
            ref.cast<Timer>().reset()
            [LuaValue.Object(ref.id)]
    }
    b.method("update") {
        ref, args =>
            ref.cast<Timer>().update(timestamp: prebindNum(args, 0, default: -1.0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 生命周期 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<Timer>().release())]
    }
    b.method("start") {
        ref, _ =>
            ref.cast<Timer>().start()
            []
    }
    b.method("stop") {
        ref, _ =>
            ref.cast<Timer>().stop()
            []
    }
    b.install(vm)
}
