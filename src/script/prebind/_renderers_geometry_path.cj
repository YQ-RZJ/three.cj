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
 * @file[zh-cn] renderers_geometry_path 2D 路径 Path 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.Path 绑定为 Lua 类型并导出共用成员安装函数
 * @explain[zh-cn] 在 CurvePath + Curve 成员之上绑定：currentPoint（Vector3 读写）、
 * fromPoints（Array<Vector3> 参数经 prebindObjList<Vector3> 读取）、moveTo/lineTo/
 * quadraticCurveTo/bezierCurveTo/absarc/absellipse/arc/ellipse/splineThru 绘制方法。
 * 子类 Shape 绑定复用 _prebindRgcPathMembers。
 * 跳过成员及原因：
 * - fromJSON(HashMap<String, Any>)：任意值容器无法安全映射为 Lua 值。
 *
 * @file[en] renderers_geometry_path  Lua binding of the 2D Path (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.Path and exports the shared member installer
 * @explain[en] On top of the CurvePath + Curve members it binds: currentPoint (read-write Vector3),
 * fromPoints (the Array<Vector3> argument is read through prebindObjList<Vector3>) and the drawing
 * methods moveTo/lineTo/quadraticCurveTo/bezierCurveTo/absarc/absellipse/arc/ellipse/splineThru.
 * The Shape subclass binding reuses _prebindRgcPathMembers.
 * Skipped members and reasons:
 * - fromJSON(HashMap<String, Any>): arbitrary value containers cannot be mapped safely.
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 Path 的成员（构造除外）
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机
 *
 * @brief[en] Installs the Path members (except the constructor) on a class binder
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine
 */
internal func _prebindRgcPathMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    b.property("currentPoint",
        getter: Some({ref => prebindRegister(ref.cast<Path>().currentPoint, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Path>().currentPoint = prebindAsValue<Vector3>(v)}))
    b.method("fromPoints") {
        ref, args =>
            ref.cast<Path>().fromPoints(prebindObjList<Vector3>(vm, args, 0).toArray())
            []
    }
    b.method("moveTo") {
        ref, args =>
            ref.cast<Path>().moveTo(prebindNum(args, 0), prebindNum(args, 1))
            []
    }
    b.method("lineTo") {
        ref, args =>
            ref.cast<Path>().lineTo(prebindNum(args, 0), prebindNum(args, 1))
            []
    }
    b.method("quadraticCurveTo") {
        ref, args =>
            ref
                .cast<Path>()
                .quadraticCurveTo(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3))
            []
    }
    b.method("bezierCurveTo") {
        ref, args =>
            ref
                .cast<Path>()
                .bezierCurveTo(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5))
            []
    }
    b.method("absarc") {
        ref, args =>
            ref
                .cast<Path>()
                .absarc(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindBool(args, 5))
            []
    }
    b.method("absellipse") {
        ref, args =>
            ref
                .cast<Path>()
                .absellipse(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5), prebindBool(args, 6), prebindNum(args, 7))
            []
    }
    b.method("splineThru") {
        ref, args =>
            ref.cast<Path>().splineThru(prebindObjList<Vector3>(vm, args, 0).toArray())
            []
    }
    b.method("arc") {
        ref, args =>
            ref
                .cast<Path>()
                .arc(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindBool(args, 5), prebindNum(args, 6))
            []
    }
    b.method("ellipse") {
        ref, args =>
            ref
                .cast<Path>()
                .ellipse(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2), prebindNum(args, 3),
                    prebindNum(args, 4), prebindNum(args, 5), prebindBool(args, 6), prebindNum(args, 7))
            []
    }
}

/**
 * @brief[zh-cn] 安装 Path 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.Path）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Path
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.Path)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPath(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.Path")
    b.constructor {
        args => if (args.size > 0 && !args[0].isNil) {
            Path(prebindObjList<Vector3>(vm, args, 0).toArray())
        } else {
            Path()
        }
    }
    _prebindRgcCurveMembers(b)
    _prebindRgcCurvePathMembers(b)
    _prebindRgcPathMembers(b, vm)
    b.install(vm)
}
