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
 * @file[zh-cn] core_time_clock 时钟 Clock 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.time.Clock 绑定为 Lua 类型 three.core.time.Clock
 * @explain[zh-cn] 覆盖构造（new/可选 autoStart）、属性（autoStart 可读写）与方法
 * （start/stop/getElapsedTime/getDelta）。自 r183 起已废弃，推荐使用 Timer。
 *
 * @file[en] core_time_clock  Lua binding of the clock Clock (three.script.prebind)
 * @brief[en] Binds three.core.time.Clock as the Lua type three.core.time.Clock
 * @explain[en] Covers construction (new / optional autoStart), property (autoStart
 * read-write) and methods (start/stop/getElapsedTime/getDelta). Deprecated since r183,
 * prefer Timer.
 */
package three.script.prebind

import three.core.time.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Clock 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.time.Clock）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Clock
 * @param[en] vm The target virtual machine (class table installed at three.core.time.Clock)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installClock(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.time.Clock")
    // ===== 构造 =====
    b.constructor {args => Clock(autoStart: prebindBool(args, 0, default: true))}
    // ===== 属性 =====
    b.property("autoStart", getter: Some({ref => LuaValue.of(ref.cast<Clock>().autoStart)}),
        setter: Some({ref, v => ref.cast<Clock>().autoStart = v.boolValue()}))
    // ===== 时间查询 =====
    b.method("getElapsedTime") {
        ref, _ => [LuaValue.of(ref.cast<Clock>().getElapsedTime())]
    }
    b.method("getDelta") {
        ref, _ => [LuaValue.of(ref.cast<Clock>().getDelta())]
    }
    // ===== 启停 =====
    b.method("start") {
        ref, _ =>
            ref.cast<Clock>().start()
            []
    }
    b.method("stop") {
        ref, _ =>
            ref.cast<Clock>().stop()
            []
    }
    b.install(vm)
}
