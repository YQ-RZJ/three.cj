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
 * @file[zh-cn] renderers_geometry_octahedrongeometry 八面体几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.OctahedronGeometry 绑定为 Lua 类型
 * three.renderers.geometry.OctahedronGeometry
 * @explain[zh-cn] 覆盖构造：radius（Float64，默认 1.0）、detail（Int64，默认 0）。
 * 继承自 PolyhedronGeometry/BufferGeometry 的成员由对应绑定提供，本文件不重复绑定。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）与静态 fromJSON（HashMap<String, Any>
 * 泛型容器参数）。
 *
 * @file[en] renderers_geometry_octahedrongeometry  Lua binding of OctahedronGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.OctahedronGeometry as the Lua type
 * three.renderers.geometry.OctahedronGeometry
 * @explain[en] Covers the constructor: radius (Float64, default 1.0) and detail (Int64,
 * default 0). Members inherited from PolyhedronGeometry/BufferGeometry are provided by
 * their bindings and are not duplicated here. parameters (HashMap<String, Any> generic
 * container) and the static fromJSON (HashMap<String, Any> generic-container parameter)
 * are skipped.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 OctahedronGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.OctahedronGeometry）
 *
 * @brief[en] Installs the Lua binding of OctahedronGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.OctahedronGeometry)
 */
public func installOctahedronGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.OctahedronGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        OctahedronGeometry(
            radius: prebindNum(args, 0, default: 1.0),
            detail: prebindInt(args, 1, default: 0)
        )
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
