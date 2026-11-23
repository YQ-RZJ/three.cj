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
 * otherwise be required by Sections 4(a), 5(b) and 6(d) of the License.
 *
 * @file[zh-cn] core_dsa_spatialhashgrid 空间哈希网格的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.SpatialHashGrid 绑定为 Lua 类型 three.core.dsa.SpatialHashGrid
 * @explain[zh-cn] 覆盖构造（new，格子边长可选）、只读属性（cellSize/elementCount/cellCount）、
 * 登记（insert）、球/盒邻域查询（querySphere/queryAabb）与清空（clear）。查询的
 * ArrayList<Int64> 输出参数转换为 Lua 整数表返回。
 *
 * @file[en] core_dsa_spatialhashgrid  Lua binding of the spatial hash grid (three.script.prebind)
 * @brief[en] Binds three.core.dsa.SpatialHashGrid as the Lua type three.core.dsa.SpatialHashGrid
 * @explain[en] Covers construction (new, optional cell size), read-only props (cellSize/
 * elementCount/cellCount), registration (insert), sphere/box neighborhood queries
 * (querySphere/queryAabb) and clear. The ArrayList<Int64> outputs are returned as Lua integer tables.
 */
package three.script.prebind

import std.collection.*
import three.core.dsa.SpatialHashGrid
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SpatialHashGrid 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.SpatialHashGrid）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SpatialHashGrid
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.SpatialHashGrid)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSpatialHashGrid(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.SpatialHashGrid")
    // ===== 构造 =====
    b.constructor {
        args => SpatialHashGrid(prebindNum(args, 0, default: 1.0))
    }
    // ===== 属性 =====
    b.property("cellSize", getter: Some({ref => LuaValue.of(ref.cast<SpatialHashGrid>().cellSize)}))
    b.property("elementCount", getter: Some({ref => LuaValue.of(ref.cast<SpatialHashGrid>().elementCount)}))
    b.property("cellCount", getter: Some({ref => LuaValue.of(ref.cast<SpatialHashGrid>().cellCount)}))
    // ===== 登记 =====
    b.method("insert") {
        ref, args =>
            ref
                .cast<SpatialHashGrid>()
                .insert(args[0].intValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                    args[4].numberValue())
            []
    }
    // ===== 球邻域查询 =====
    b.method("querySphere") {
        ref, args =>
            let src = args[4].toArrayInt()
            let out = ArrayList<Int64>()
            for (v in src) {
                out.add(v)
            }
            ref
                .cast<SpatialHashGrid>()
                .querySphere(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                    out)
            [LuaValue.of(Array<Int64>(out.size, {i => out[i]}))]
    }
    // ===== 盒邻域查询 =====
    b.method("queryAabb") {
        ref, args =>
            let src = args[6].toArrayInt()
            let out = ArrayList<Int64>()
            for (v in src) {
                out.add(v)
            }
            ref
                .cast<SpatialHashGrid>()
                .queryAabb(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(), args[3].numberValue(),
                    args[4].numberValue(), args[5].numberValue(), out)
            [LuaValue.of(Array<Int64>(out.size, {i => out[i]}))]
    }
    // ===== 清空 =====
    b.method("clear") {
        ref, _ =>
            ref.cast<SpatialHashGrid>().clear()
            []
    }
    b.install(vm)
}
