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
 * @file[zh-cn] renderers_geometry_lathegeometry 车削几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.LatheGeometry 绑定为 Lua 类型
 * three.renderers.geometry.LatheGeometry
 * @explain[zh-cn] 覆盖构造：points（Array<Vector2>，Lua 对象数组，经 prebindObjList 读取）、
 * segments（Int64，默认 12）、phiStart（Float64，默认 0）、phiLength（Float64，默认 2π）。
 * 继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供，本文件不重复绑定。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_lathegeometry  Lua binding of LatheGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.LatheGeometry as the Lua type
 * three.renderers.geometry.LatheGeometry
 * @explain[en] Covers the constructor: points (Array<Vector2>, read from a Lua object array
 * via prebindObjList), segments (Int64, default 12), phiStart (Float64, default 0) and
 * phiLength (Float64, default 2π). Members inherited from BufferGeometry are provided by
 * the BufferGeometry binding and are not duplicated here. parameters
 * (HashMap<String, Any> generic container) is skipped.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LatheGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.LatheGeometry）
 *
 * @brief[en] Installs the Lua binding of LatheGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.LatheGeometry)
 */
public func installLatheGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.LatheGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        let points = prebindObjList<Vector2>(vm, args, 0).toArray()
        let segments = prebindInt(args, 1, default: 12)
        let phiStart = prebindNum(args, 2, default: 0.0)
        let phiLength = prebindNum(args, 3, default: PI * 2.0)
        try {
            LatheGeometry(
                points,
                segments: segments,
                phiStart: phiStart,
                phiLength: phiLength
            )
        } catch (_: Exception) {
            LatheGeometry(
                Array<Vector2>(),
                segments: segments,
                phiStart: phiStart,
                phiLength: phiLength
            )
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
