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
 * @file[zh-cn] renderers_geometry_shapeutils ShapeUtils 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.ShapeUtils 的静态工具方法绑定为 Lua 静态方法
 * @explain[zh-cn] 绑定 area(Array<Vector2>)、isClockWise(Array<Vector2>)、
 * triangulateShape(ArrayList<Vector2>, ArrayList<ArrayList<Vector2>>)。Vector2 参数经
 * prebindObjList<Vector2> 读取，Jagged 孔洞列表由外层 Lua 数组逐项转换；
 * 返回的 Array<Array<UInt32>> 转为嵌套 Lua 数值数组。该类无实例成员。
 *
 * @file[en] renderers_geometry_shapeutils  Lua binding of ShapeUtils (three.script.prebind)
 * @brief[en] Binds the static utility methods of three.renderers.geometry.ShapeUtils
 * @explain[en] Binds area(Array<Vector2>), isClockWise(Array<Vector2>) and
 * triangulateShape(ArrayList<Vector2>, ArrayList<ArrayList<Vector2>>). Vector2 arguments are read
 * through prebindObjList<Vector2>; the jagged hole list is converted element by element from the
 * outer Lua array; the returned Array<Array<UInt32>> becomes a nested Lua numeric array.
 * The class has no instance members.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ShapeUtils 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.ShapeUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ShapeUtils
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.ShapeUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShapeUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.ShapeUtils")
    b.staticMethod("area") {
        args => [LuaValue.of(ShapeUtils.area(prebindObjList<Vector2>(vm, args, 0).toArray()))]
    }
    b.staticMethod("isClockWise") {
        args => [LuaValue.of(ShapeUtils.isClockWise(prebindObjList<Vector2>(vm, args, 0).toArray()))]
    }
    b.staticMethod("triangulateShape") {
        args =>
            let contour = prebindObjList<Vector2>(vm, args, 0)
            let holes = ArrayList<ArrayList<Vector2>>()
            for (holeValue in prebindArray(vm, args, 1)) {
                holes.add(prebindObjList<Vector2>(vm, [holeValue], 0))
            }
            let faces = ShapeUtils.triangulateShape(contour, holes)
            var out = Array<LuaValue>(faces.size, {_ => LuaValue.Nil})
            for (i in 0..faces.size) {
                let face = faces[i]
                var inner = Array<LuaValue>(face.size, {_ => LuaValue.Nil})
                for (j in 0..face.size) {
                    inner[j] = LuaValue.of(Int64(face[j]))
                }
                out[i] = LuaValue.Array(inner)
            }
            [LuaValue.Array(out)]
    }
    b.install(vm)
}
