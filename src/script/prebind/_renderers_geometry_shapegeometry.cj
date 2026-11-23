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
 * @file[zh-cn] renderers_geometry_shapegeometry 形状几何体的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.ShapeGeometry 绑定为 Lua 类型
 * three.renderers.geometry.ShapeGeometry
 * @explain[zh-cn] 覆盖构造：shape（Shape 对象，必需）、curveSegments（Int64，默认 12）。
 * shape 缺失或类型不符时以空 Shape 兜底，构造异常在绑定内捕获，不逃逸到 Lua。
 * 继承自 BufferGeometry 的成员由 BufferGeometry 绑定提供。跳过 parameters
 * （HashMap<String, Any> 泛型容器）。Shape 自身的 Lua 绑定不在本文件范围内。
 *
 * @file[en] renderers_geometry_shapegeometry  Lua binding of ShapeGeometry
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.ShapeGeometry as the Lua type
 * three.renderers.geometry.ShapeGeometry
 * @explain[en] Covers the constructor: shape (a Shape object, required) and curveSegments
 * (Int64, default 12). When shape is missing or not an object, an empty Shape is used as
 * the fallback; construction exceptions are caught inside the binding and never escape to
 * Lua. Members inherited from BufferGeometry are provided by the BufferGeometry binding.
 * parameters (HashMap<String, Any> generic container) is skipped. The Lua binding of Shape
 * itself is out of scope for this file.
 */
package three.script.prebind

import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ShapeGeometry 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.ShapeGeometry）
 *
 * @brief[en] Installs the Lua binding of ShapeGeometry
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.geometry.ShapeGeometry)
 */
public func installShapeGeometry(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.ShapeGeometry")
    // ===== 构造 =====
    b.constructor { args =>
        let curveSegments = prebindInt(args, 1, default: 12)
        try {
            if (args.size >= 1 && args[0].isObject) {
                ShapeGeometry(prebindAs<Shape>(args, 0), curveSegments: curveSegments)
            } else {
                ShapeGeometry(Shape(), curveSegments: curveSegments)
            }
        } catch (_: Exception) {
            ShapeGeometry(Shape(), curveSegments: curveSegments)
        }
    }
    _prebindRgcBufferGeometryMembers(b, vm)
    b.install(vm)
}
