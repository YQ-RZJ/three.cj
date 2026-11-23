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
 * @file[zh-cn] renderers_geometry_tubegeometry 管道几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.TubeGeometry 绑定为 Lua 类型
 * three.renderers.geometry.TubeGeometry
 * @explain[zh-cn] 覆盖构造：path（Curve 对象，必需）、tubularSegments（Int64，默认 64）、
 * radius（Float64，默认 1.0）、radialSegments（Int64，默认 8）、closed（Bool，
 * 默认 false）。path 缺失、类型不符或构造失败时以默认 LineCurve3 兜底，异常在绑定内
 * 捕获，不逃逸到 Lua。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）。Curve 各子类的 Lua 绑定不在本文件
 * 范围内。
 *
 * @file[en] renderers_geometry_tubegeometry  Lua binding of TubeGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.TubeGeometry as the Lua type
 * three.renderers.geometry.TubeGeometry
 * @explain[en] Covers the constructor: path (a Curve object, required), tubularSegments
 * (Int64, default 64), radius (Float64, default 1.0), radialSegments (Int64, default 8)
 * and closed (Bool, default false). When path is missing, not an object, or construction
 * fails, a default LineCurve3 is used as the fallback and exceptions are caught inside the
 * binding, never escaping to Lua. Members inherited from BufferGeometry are provided by
 * the BufferGeometry binding. parameters (HashMap<String, Any> generic container) is
 * skipped. Lua bindings of Curve subclasses are out of scope for this file.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TubeGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.TubeGeometry）
 *
 * @brief[en] Installs the Lua binding of TubeGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.TubeGeometry)
 */
public func installTubeGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.TubeGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        let tubularSegments = prebindInt(args, 1, default: 64)
        let radius = prebindNum(args, 2, default: 1.0)
        let radialSegments = prebindInt(args, 3, default: 8)
        let closed = prebindBool(args, 4, default: false)
        try {
            if (args.size >= 1 && args[0].isObject) {
                TubeGeometry(
                    prebindAs<Curve>(args, 0),
                    tubularSegments: tubularSegments,
                    radius: radius,
                    radialSegments: radialSegments,
                    closed: closed
                )
            } else {
                TubeGeometry(
                    LineCurve3(v1: Vector3(0.0, 0.0, 0.0), v2: Vector3(0.0, 1.0, 0.0)),
                    tubularSegments: tubularSegments,
                    radius: radius,
                    radialSegments: radialSegments,
                    closed: closed
                )
            }
        } catch (_: Exception) {
            TubeGeometry(
                LineCurve3(v1: Vector3(0.0, 0.0, 0.0), v2: Vector3(0.0, 1.0, 0.0)),
                tubularSegments: tubularSegments,
                radius: radius,
                radialSegments: radialSegments,
                closed: closed
            )
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
