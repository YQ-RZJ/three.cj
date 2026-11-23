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
 * @file[zh-cn] renderers_geometry_cubicbeziercurve3 三维三次贝塞尔曲线 CubicBezierCurve3 的 Lua 绑定
 * @brief[zh-cn] 将 three.renderers.geometry.CubicBezierCurve3 绑定为 Lua 类型
 * @explain[zh-cn] 复用 Curve 成员（getPoint/copy 等虚分派生效），绑定控制点 v0/v1/v2/v3
 * （Vector3 读写）与四参构造（各参缺省为零向量）。fromJSON(HashMap) 不绑定。
 *
 * @file[en] renderers_geometry_cubicbeziercurve3  Lua binding of the 3D CubicBezierCurve3
 * @brief[en] Binds three.renderers.geometry.CubicBezierCurve3 as a Lua type
 * @explain[en] Reuses the Curve members (getPoint/copy etc. take effect through virtual dispatch)
 * and binds the control points v0/v1/v2/v3 (read-write Vector3) plus the four-argument constructor
 * (each defaulting to the zero vector). fromJSON(HashMap) is not bound.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CubicBezierCurve3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.CubicBezierCurve3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CubicBezierCurve3
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.CubicBezierCurve3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCubicBezierCurve3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.CubicBezierCurve3")
    b.constructor {
        args => CubicBezierCurve3(v0: prebindVec3(args, 0), v1: prebindVec3(args, 1), v2: prebindVec3(args, 2),
            v3: prebindVec3(args, 3))
    }
    _prebindRgcCurveMembers(b)
    b.property("v0", getter: Some({ref => prebindRegister(ref.cast<CubicBezierCurve3>().v0, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<CubicBezierCurve3>().v0 = prebindAsValue<Vector3>(v)}))
    b.property("v1", getter: Some({ref => prebindRegister(ref.cast<CubicBezierCurve3>().v1, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<CubicBezierCurve3>().v1 = prebindAsValue<Vector3>(v)}))
    b.property("v2", getter: Some({ref => prebindRegister(ref.cast<CubicBezierCurve3>().v2, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<CubicBezierCurve3>().v2 = prebindAsValue<Vector3>(v)}))
    b.property("v3", getter: Some({ref => prebindRegister(ref.cast<CubicBezierCurve3>().v3, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<CubicBezierCurve3>().v3 = prebindAsValue<Vector3>(v)}))
    b.install(vm)
}
