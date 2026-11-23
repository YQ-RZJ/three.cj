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
 * @file[zh-cn] renderers_geometry_cylindergeometry 圆柱几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.CylinderGeometry 绑定为 Lua 类型
 * three.renderers.geometry.CylinderGeometry
 * @explain[zh-cn] 覆盖构造：radiusTop/radiusBottom/height（Float64，默认 1.0）、
 * radialSegments（Int64，默认 8）、heightSegments（Int64，默认 1）、openEnded（Bool，
 * 默认 false）、thetaStart（Float64，默认 0）、thetaLength（Float64，默认 2π）。
 * 参数按位置读取。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供，本文件不重复
 * 绑定。跳过 parameters（HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_cylindergeometry  Lua binding of CylinderGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.CylinderGeometry as the Lua type
 * three.renderers.geometry.CylinderGeometry
 * @explain[en] Covers the constructor: radiusTop/radiusBottom/height (Float64, default
 * 1.0), radialSegments (Int64, default 8), heightSegments (Int64, default 1), openEnded
 * (Bool, default false), thetaStart (Float64, default 0) and thetaLength (Float64,
 * default 2π). Arguments are read positionally. Members inherited from BufferGeometry are
 * provided by the BufferGeometry binding and are not duplicated here. parameters
 * (HashMap<String, Any> generic container) is skipped.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CylinderGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.CylinderGeometry）
 *
 * @brief[en] Installs the Lua binding of CylinderGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.CylinderGeometry)
 */
public func installCylinderGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.CylinderGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        CylinderGeometry(
            radiusTop: prebindNum(args, 0, default: 1.0),
            radiusBottom: prebindNum(args, 1, default: 1.0),
            height: prebindNum(args, 2, default: 1.0),
            radialSegments: prebindInt(args, 3, default: 8),
            heightSegments: prebindInt(args, 4, default: 1),
            openEnded: prebindBool(args, 5, default: false),
            thetaStart: prebindNum(args, 6, default: 0.0),
            thetaLength: prebindNum(args, 7, default: PI * 2.0)
        )
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
