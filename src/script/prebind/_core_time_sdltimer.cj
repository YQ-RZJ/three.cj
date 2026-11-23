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
 * @file[zh-cn] core_time_sdltimer SDL 定时器工具 SdlTimer 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.time.SdlTimer 绑定为 Lua 命名空间 three.core.time.SdlTimer
 * @explain[zh-cn] 纯静态类（无构造器），只注册 staticMethod 不安装 new：getTicks/
 * getTicksNS/getPerformanceCounter/getPerformanceFrequency（UInt64 返回值经 Float64
 * 装箱为 Lua number）与 delay/delayNS（毫秒/纳秒延时）。
 *
 * @file[en] core_time_sdltimer  Lua binding of the SDL timer utility SdlTimer
 * (three.script.prebind)
 * @brief[en] Binds three.core.time.SdlTimer as the Lua namespace three.core.time.SdlTimer
 * @explain[en] Pure static class (no constructor); only staticMethods are registered
 * without `new`: getTicks/getTicksNS/getPerformanceCounter/getPerformanceFrequency
 * (UInt64 results boxed as Lua numbers via Float64) and delay/delayNS (ms/ns delays).
 */
package three.script.prebind

import three.core.time.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SdlTimer 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.core.time.SdlTimer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SdlTimer (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at three.core.time.SdlTimer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSdlTimer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.time.SdlTimer")
    // ===== 时间查询（UInt64 经 Float64 装箱） =====
    b.staticMethod("getTicks") {_ => [LuaValue.of(Float64(SdlTimer.getTicks()))]}
    b.staticMethod("getTicksNS") {_ => [LuaValue.of(Float64(SdlTimer.getTicksNS()))]}
    b.staticMethod("getPerformanceCounter") {_ => [LuaValue.of(Float64(SdlTimer.getPerformanceCounter()))]}
    b.staticMethod("getPerformanceFrequency") {_ => [LuaValue.of(Float64(SdlTimer.getPerformanceFrequency()))]}
    // ===== 延时 =====
    b.staticMethod("delay") {
        args =>
            SdlTimer.delay(UInt32(args[0].intValue()))
            []
    }
    b.staticMethod("delayNS") {
        args =>
            SdlTimer.delayNS(UInt64(args[0].intValue()))
            []
    }
    b.install(vm)
}
