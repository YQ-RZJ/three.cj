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
 * @file[zh-cn] renderers_geometry_extrudegeometry 挤出几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.ExtrudeGeometry 绑定为 Lua 类型
 * three.renderers.geometry.ExtrudeGeometry
 * @explain[zh-cn] 绑定无参构造（默认矩形轮廓、depth=1）。init(shape, options) 重载的
 * options 为 HashMap<String, Any> 泛型容器，任意 Any 值无法安全映射，故跳过并在 Lua 侧
 * 仅暴露无参构造。继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供。
 * 跳过 parameters（HashMap<String, Any> 泛型容器）。
 *
 * @file[en] renderers_geometry_extrudegeometry  Lua binding of ExtrudeGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.ExtrudeGeometry as the Lua type
 * three.renderers.geometry.ExtrudeGeometry
 * @explain[en] Binds the no-arg constructor (default rectangular contour, depth=1). The
 * init(shape, options) overload takes a HashMap<String, Any> generic container whose
 * arbitrary Any values have no safe mapping, so it is skipped and only the no-arg
 * constructor is exposed to Lua. Members inherited from BufferGeometry are provided by
 * the BufferGeometry binding. parameters (HashMap<String, Any> generic container) is
 * skipped.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ExtrudeGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.ExtrudeGeometry）
 *
 * @brief[en] Installs the Lua binding of ExtrudeGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.ExtrudeGeometry)
 */
public func installExtrudeGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.ExtrudeGeometry")
    // ===== 构造（无参） =====
    b.constructor { _ => ExtrudeGeometry() }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
