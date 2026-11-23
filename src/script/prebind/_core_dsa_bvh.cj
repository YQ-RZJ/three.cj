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
 * @file[zh-cn] core_dsa_bvh 包围体层次结构 Bvh 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.Bvh 绑定为 Lua 类型 three.core.dsa.Bvh
 * @explain[zh-cn] 覆盖构造（new）、只读属性（nodeCount/elementCount）、构建
 * （build/refit/updateCenters/updateBounds）、包围盒读取（getElementBounds）与
 * 视锥/射线查询（queryFrustum/queryRay/getRootBounds）。构建与更新的六个分量数组
 * 以 Lua 数值表传入（toArrayFloat 通道）；查询输出数组（ArrayList<Int64> 输出参数）
 * 转换为 Lua 整数表返回。叉乘积/运算符重载等不涉及。
 *
 * @file[en] core_dsa_bvh  Lua binding of the bounding volume hierarchy Bvh (three.script.prebind)
 * @brief[en] Binds three.core.dsa.Bvh as the Lua type three.core.dsa.Bvh
 * @explain[en] Covers construction (new), read-only props (nodeCount/elementCount), build
 * (build/refit/updateCenters/updateBounds), bounds read (getElementBounds) and frustum/ray
 * queries (queryFrustum/queryRay/getRootBounds). The six component arrays are passed as Lua
 * number tables (toArrayFloat channel); the ArrayList<Int64> output parameters are converted
 * to Lua integer tables on return.
 */
package three.script.prebind

import std.collection.*
import three.core.dsa.Bvh
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Bvh 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.Bvh）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Bvh
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.Bvh)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBvh(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.Bvh")
    // ===== 构造 =====
    b.constructor {_ => Bvh()}
    // ===== 属性 =====
    b.property("nodeCount", getter: Some({ref => LuaValue.of(ref.cast<Bvh>().nodeCount)}))
    b.property("elementCount", getter: Some({ref => LuaValue.of(ref.cast<Bvh>().elementCount)}))
    // ===== 空判断 =====
    b.method("isEmpty") {
        ref, _ => [LuaValue.of(ref.cast<Bvh>().isEmpty())]
    }
    // ===== 构建 =====
    b.method("build") {
        ref, args =>
            ref
                .cast<Bvh>()
                .build(args[0].toArrayFloat(), args[1].toArrayFloat(), args[2].toArrayFloat(), args[3].toArrayFloat(),
                    args[4].toArrayFloat(), args[5].toArrayFloat())
            []
    }
    b.method("refit") {
        ref, _ =>
            ref.cast<Bvh>().refit()
            []
    }
    b.method("updateCenters") {
        ref, args =>
            ref.cast<Bvh>().updateCenters(args[0].toArrayFloat(), args[1].toArrayFloat(), args[2].toArrayFloat())
            []
    }
    b.method("updateBounds") {
        ref, args =>
            ref
                .cast<Bvh>()
                .updateBounds(args[0].toArrayFloat(), args[1].toArrayFloat(), args[2].toArrayFloat(),
                    args[3].toArrayFloat(), args[4].toArrayFloat(), args[5].toArrayFloat())
            []
    }
    // ===== 包围盒读取（输出数组回传） =====
    b.method("getElementBounds") {
        ref, args =>
            let outCenter = args[1].toArrayFloat()
            let outHalf = args[2].toArrayFloat()
            ref.cast<Bvh>().getElementBounds(args[0].intValue(), outCenter, outHalf)
            [LuaValue.of(outCenter), LuaValue.of(outHalf)]
    }
    // ===== 视锥查询 =====
    b.method("queryFrustum") {
        ref, args =>
            let src = args[1].toArrayInt()
            let out = ArrayList<Int64>()
            for (v in src) {
                out.add(v)
            }
            ref.cast<Bvh>().queryFrustum(prebindAs<Frustum>(args, 0), out)
            [LuaValue.of(Array<Int64>(out.size, {i => out[i]}))]
    }
    // ===== 射线查询 =====
    b.method("queryRay") {
        ref, args =>
            let src = args[3].toArrayInt()
            let out = ArrayList<Int64>()
            for (v in src) {
                out.add(v)
            }
            ref.cast<Bvh>().queryRay(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), args[2].numberValue(),
                out)
            [LuaValue.of(Array<Int64>(out.size, {i => out[i]}))]
    }
    // ===== 根包围盒 =====
    b.method("getRootBounds") {
        ref, args => [LuaValue.of(ref.cast<Bvh>().getRootBounds(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1)))]
    }
    b.install(vm)
}
