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
 * @file[zh-cn] renderers_geometry_shape 2D 形状 Shape 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.Shape 绑定为 Lua 类型
 * @explain[zh-cn] 复用 Path/CurvePath/Curve 成员，并绑定 uuid 属性、holes（Path 对象数组，可读写）、
 * getPointsHoles（返回 Array<Array<Vector3>>，转换为嵌套 Lua 对象数组）。
 * 跳过成员及原因：
 * - extractPoints(): 返回 HashMap<String, Any>，任意值无法安全映射；
 * - fromJSON(): HashMap<String, Any> 参数无法安全映射。
 *
 * @file[en] renderers_geometry_shape  Lua binding of the 2D Shape (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.Shape as a Lua type
 * @explain[en] Reuses the Path/CurvePath/Curve members and binds the uuid property, holes
 * (a read-write array of Path objects) and getPointsHoles (Array<Array<Vector3>> converted into
 * a nested Lua object array).
 * Skipped members and reasons:
 * - extractPoints(): returns HashMap<String, Any>, arbitrary values cannot be mapped safely;
 * - fromJSON(): the HashMap<String, Any> argument cannot be mapped safely.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Shape 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.Shape）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Shape
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.Shape)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShape(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.Shape")
    b.constructor {
        args => if (args.size > 0 && !args[0].isNil) {
            Shape(prebindObjList<Vector3>(vm, args, 0).toArray())
        } else {
            Shape()
        }
    }
    _prebindRgcCurveMembers(b)
    _prebindRgcCurvePathMembers(b)
    _prebindRgcPathMembers(b, vm)
    // ===== 形状自身成员 =====
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<Shape>().uuid)}),
        setter: Some({ref, v => ref.cast<Shape>().uuid = v.stringValue()}))
    b.property(
        "holes",
        getter: Some(
            {
                ref =>
                    let holes = ref.cast<Shape>().holes
                    let n = holes.size
                    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
                    for (i in 0..n) {
                        out[i] = prebindRegister(holes[i], "three.renderers.geometry.Path")
                    }
                    LuaValue.Array(out)
            }
        ),
        setter: Some({
            ref, v => ref.cast<Shape>().holes = prebindObjList<Path>(vm, [v], 0)
        })
    )
    b.method("getPointsHoles") {
        ref, args =>
            let holes = ref.cast<Shape>().getPointsHoles(prebindInt(args, 0, default: 5))
            let n = holes.size
            var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
            for (i in 0..n) {
                out[i] = _prebindRgcVec3ArrayToLua(holes[i])
            }
            [LuaValue.Array(out)]
    }
    b.install(vm)
}
