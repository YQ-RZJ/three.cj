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
 * @file[zh-cn] renderers_geometry_shapepath ShapePath 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.ShapePath 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 subPaths（只读 Path 对象数组）、currentPath（Option<Path>，无值时读 nil）、
 * moveTo/lineTo/quadraticCurveTo/bezierCurveTo/splineThru 绘制方法，以及 toShapes（返回注册的
 * Shape 对象数组）。
 *
 * @file[en] renderers_geometry_shapepath  Lua binding of ShapePath (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.ShapePath as a Lua type
 * @explain[en] Binds subPaths (read-only Path object array), currentPath (Option<Path>, nil when
 * absent), the drawing methods moveTo/lineTo/quadraticCurveTo/bezierCurveTo/splineThru and
 * toShapes (returns a registered Shape object array).
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ShapePath 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.ShapePath）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ShapePath
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.ShapePath)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShapePath(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.ShapePath")
    b.constructor {_ => ShapePath()}
    // ===== 子路径 =====
    b.property(
        "subPaths",
        getter: Some(
            {
                ref =>
                    let paths = ref.cast<ShapePath>().subPaths
                    let n = paths.size
                    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
                    for (i in 0..n) {
                        out[i] = prebindRegister(paths[i], "three.renderers.geometry.Path")
                    }
                    LuaValue.Array(out)
            }
        )
    )
    b.property("currentPath", getter: Some({
        ref => match (ref.cast<ShapePath>().currentPath) {
            case Some(p) => prebindRegister(p, "three.renderers.geometry.Path")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil || !v.isObject) {
            ref.cast<ShapePath>().currentPath = None
        } else {
            ref.cast<ShapePath>().currentPath = Some(prebindAsValue<Path>(v))
        }
    }))
    // ===== 绘制 =====
    b.method("moveTo") {
        ref, args =>
            ref.cast<ShapePath>().moveTo(prebindNum(args, 0), prebindNum(args, 1))
            []
    }
    b.method("lineTo") {
        ref, args =>
            ref.cast<ShapePath>().lineTo(prebindNum(args, 0), prebindNum(args, 1))
            []
    }
    b.method("quadraticCurveTo") {
        ref, args =>
            ref
                .cast<ShapePath>()
                .quadraticCurveTo(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3))
            []
    }
    b.method("bezierCurveTo") {
        ref, args =>
            ref
                .cast<ShapePath>()
                .bezierCurveTo(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5))
            []
    }
    b.method("splineThru") {
        ref, args =>
            ref.cast<ShapePath>().splineThru(prebindObjList<Vector3>(vm, args, 0).toArray())
            []
    }
    // ===== 转换 =====
    b.method("toShapes") {
        ref, _ =>
            let shapes = ref.cast<ShapePath>().toShapes()
            let n = shapes.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = prebindRegister(shapes[i], "three.renderers.geometry.Shape")
            }
            [LuaValue.Array(out)]
    }
    b.install(vm)
}
