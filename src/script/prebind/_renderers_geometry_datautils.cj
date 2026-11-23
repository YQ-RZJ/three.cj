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
 * @file[zh-cn] renderers_geometry_datautils DataUtils 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.DataUtils 的半精度浮点静态方法绑定为 Lua 静态方法
 * @explain[zh-cn] 绑定 toHalfFloat(Float64): UInt16（Lua 侧以整数返回）与
 * fromHalfFloat(UInt16): Float64（入参取低 16 位）。包级同名顶层函数无法通过类表绑定，故只绑定
 * 类内静态方法；该类无实例成员。
 *
 * @file[en] renderers_geometry_datautils  Lua binding of DataUtils (three.script.prebind)
 * @brief[en] Binds the half-float static methods of three.renderers.geometry.DataUtils
 * @explain[en] Binds toHalfFloat(Float64): UInt16 (returned as an integer to Lua) and
 * fromHalfFloat(UInt16): Float64 (the low 16 bits of the argument are used). The package-level
 * functions of the same name cannot be reached through a class table, so only the class statics
 * are bound; the class has no instance members.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 DataUtils 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.DataUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DataUtils
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.DataUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDataUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.DataUtils")
    b.staticMethod("toHalfFloat") {
        args => [LuaValue.of(Int64(DataUtils.toHalfFloat(prebindNum(args, 0))))]
    }
    b.staticMethod("fromHalfFloat") {
        args => [LuaValue.of(DataUtils.fromHalfFloat(UInt16(args[0].intValue() & 0xFFFF)))]
    }
    b.install(vm)
}
