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
 * @file[zh-cn] renderers_geometry_polyhedrongeometry 多面体几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.PolyhedronGeometry 绑定为 Lua 类型
 * three.renderers.geometry.PolyhedronGeometry
 * @explain[zh-cn] 覆盖构造：vertices（Array<Float64>，经 prebindFloatArray 读取）、
 * indices（Array<Int64>，经 prebindI64List 读取）、radius（Float64，默认 1.0）、
 * detail（Int64，默认 0）。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）与静态 fromJSON
 * （HashMap<String, Any> 泛型容器参数）。
 *
 * @file[en] renderers_geometry_polyhedrongeometry  Lua binding of PolyhedronGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.PolyhedronGeometry as the Lua type
 * three.renderers.geometry.PolyhedronGeometry
 * @explain[en] Covers the constructor: vertices (Array<Float64>, read via prebindFloatArray),
 * indices (Array<Int64>, read via prebindI64List), radius (Float64, default 1.0) and detail
 * (Int64, default 0). Members inherited from BufferGeometry are provided by the
 * BufferGeometry binding. parameters (HashMap<String, Any> generic container) and the
 * static fromJSON (HashMap<String, Any> generic-container parameter) are skipped.
 */
package three.script.prebind

import std.collection.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PolyhedronGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.PolyhedronGeometry）
 *
 * @brief[en] Installs the Lua binding of PolyhedronGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.PolyhedronGeometry)
 */
public func installPolyhedronGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.PolyhedronGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        let vertices = prebindFloatArray(vm, args, 0)
        let indices = prebindI64List(vm, args, 1).toArray()
        let radius = prebindNum(args, 2, default: 1.0)
        let detail = prebindInt(args, 3, default: 0)
        try {
            PolyhedronGeometry(
                vertices: vertices,
                indices: indices,
                radius: radius,
                detail: detail
            )
        } catch (_: Exception) {
            PolyhedronGeometry(
                vertices: Array<Float64>(),
                indices: Array<Int64>(),
                radius: radius,
                detail: detail
            )
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
