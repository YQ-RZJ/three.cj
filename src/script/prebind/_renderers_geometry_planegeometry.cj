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
 * @file[zh-cn] renderers_geometry_planegeometry 平面几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.PlaneGeometry 绑定为 Lua 类型
 * three.renderers.geometry.PlaneGeometry
 * @explain[zh-cn] 覆盖构造：width/height（Float64，默认 1.0）、widthSegments/
 * heightSegments（Int64，默认 1）。参数按位置读取。继承自 BufferGeometry 的成员由
 * BufferGeometry 绑定提供，本文件不重复绑定。跳过 parameters
 * （HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_planegeometry  Lua binding of PlaneGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.PlaneGeometry as the Lua type
 * three.renderers.geometry.PlaneGeometry
 * @explain[en] Covers the constructor: width/height (Float64, default 1.0) and
 * widthSegments/heightSegments (Int64, default 1). Arguments are read positionally.
 * Members inherited from BufferGeometry are provided by the BufferGeometry binding and are
 * not duplicated here. parameters (HashMap<String, Any> generic container) is skipped.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PlaneGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.PlaneGeometry）
 *
 * @brief[en] Installs the Lua binding of PlaneGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.PlaneGeometry)
 */
public func installPlaneGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.PlaneGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        PlaneGeometry(
            width: prebindNum(args, 0, default: 1.0),
            height: prebindNum(args, 1, default: 1.0),
            widthSegments: prebindInt(args, 2, default: 1),
            heightSegments: prebindInt(args, 3, default: 1)
        )
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
