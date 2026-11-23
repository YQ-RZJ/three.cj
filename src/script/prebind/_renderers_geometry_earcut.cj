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
 * @file[zh-cn] renderers_geometry_earcut Earcut 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.Earcut 的静态三角剖分方法绑定为 Lua 静态方法
 * @explain[zh-cn] 绑定 Earcut.triangulate(data, holeIndices, dim = 2)：data 经 prebindFloatArray
 * 读取为 Array<Float64>，holeIndices 经 prebindI64List 转换为 Array<Int64>，
 * 返回的 Array<UInt32> 由 prebindU32ArrayToLua 转为 Lua 数值数组。该类无实例成员。
 *
 * @file[en] renderers_geometry_earcut  Lua binding of Earcut (three.script.prebind)
 * @brief[en] Binds the static triangulation method of three.renderers.geometry.Earcut
 * @explain[en] Binds Earcut.triangulate(data, holeIndices, dim = 2): data is read through
 * prebindFloatArray into Array<Float64>, holeIndices is converted through prebindI64List into
 * Array<Int64>, and the returned Array<UInt32> is converted by prebindU32ArrayToLua into a Lua
 * numeric array. The class has no instance members.
 */
package three.script.prebind

import std.collection.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Earcut 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.Earcut）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Earcut
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.Earcut)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEarcut(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.Earcut")
    b.staticMethod("triangulate") {
        args => [prebindU32ArrayToLua(
            Earcut.triangulate(prebindFloatArray(vm, args, 0), prebindI64List(vm, args, 1).toArray(),
                dim: prebindInt(args, 2, default: 2)))]
    }
    // ===== 面积差异百分比（包级函数，以静态方法暴露） =====
    b.staticMethod("deviation") {
        args => [LuaValue.of(
            deviation(prebindFloatArray(vm, args, 0), prebindI64List(vm, args, 1).toArray(),
                prebindInt(args, 2, default: 2), prebindU32Array(vm, args, 3)))]
    }
    b.install(vm)
}
