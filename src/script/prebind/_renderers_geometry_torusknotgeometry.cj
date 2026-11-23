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
 * @file[zh-cn] renderers_geometry_torusknotgeometry 环面纽结几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.TorusKnotGeometry 绑定为 Lua 类型
 * three.renderers.geometry.TorusKnotGeometry
 * @explain[zh-cn] 覆盖构造：radius（Float64，默认 1.0）、tube（Float64，默认 0.4）、
 * tubularSegments（Int64，默认 64）、radialSegments（Int64，默认 8）、p（Int64，
 * 默认 2）、q（Int64，默认 3）。参数按位置读取。继承自 BufferGeometry 的成员由
 * BufferGeometry 绑定提供，本文件不重复绑定。跳过 parameters
 * （HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_torusknotgeometry  Lua binding of TorusKnotGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.TorusKnotGeometry as the Lua type
 * three.renderers.geometry.TorusKnotGeometry
 * @explain[en] Covers the constructor: radius (Float64, default 1.0), tube (Float64,
 * default 0.4), tubularSegments (Int64, default 64), radialSegments (Int64, default 8),
 * p (Int64, default 2) and q (Int64, default 3). Arguments are read positionally. Members
 * inherited from BufferGeometry are provided by the BufferGeometry binding and are not
 * duplicated here. parameters (HashMap<String, Any> generic container) is skipped.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TorusKnotGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.TorusKnotGeometry）
 *
 * @brief[en] Installs the Lua binding of TorusKnotGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.TorusKnotGeometry)
 */
public func installTorusKnotGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.TorusKnotGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        TorusKnotGeometry(
            radius: prebindNum(args, 0, default: 1.0),
            tube: prebindNum(args, 1, default: 0.4),
            tubularSegments: prebindInt(args, 2, default: 64),
            radialSegments: prebindInt(args, 3, default: 8),
            p: prebindInt(args, 4, default: 2),
            q: prebindInt(args, 5, default: 3)
        )
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
