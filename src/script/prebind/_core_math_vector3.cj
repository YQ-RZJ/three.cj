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
 * @file[zh-cn] core_math_vector3 3D 向量 Vector3 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Vector3 绑定为 Lua 类型 three.core.math.Vector3
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/copy/add/sub/multiply/divide/
 * normalize/lerp/clone/applyMatrix3/applyMatrix4/applyQuaternion/数组互转等）与属性
 * （x/y/z）。互变异构方法均返回自身（Lua 链式可用）。运算符重载以
 * __add/__sub/__mul/__div/__unm 方法形式暴露。
 *
 * @file[en] core_math_vector3  Lua binding of the 3D vector Vector3 (three.script.prebind)
 * @brief[en] Binds three.core.math.Vector3 as the Lua type three.core.math.Vector3
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/copy/add/sub/multiply/divide/normalize/lerp/clone/applyMatrix3/applyMatrix4/
 * applyQuaternion/array round-trip etc.) and properties (x/y/z). Mutating methods
 * return self for Lua chaining. Operator overloads are exposed as
 * __add/__sub/__mul/__div/__unm methods.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Vector3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Vector3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Vector3
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Vector3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
protected func installVector3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Vector3")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Vector3(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
        } else {
            Vector3()
        }
    }
    // ===== 属性 =====
    b.property("x", getter: Some({ref => LuaValue.of(ref.cast<Vector3>().x)}),
        setter: Some({ref, v => ref.cast<Vector3>().x = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Vector3>().y)}),
        setter: Some({ref, v => ref.cast<Vector3>().y = v.numberValue()}))
    b.property("z", getter: Some({ref => LuaValue.of(ref.cast<Vector3>().z)}),
        setter: Some({ref, v => ref.cast<Vector3>().z = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            let v = ref.cast<Vector3>()
            v.set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setScalar") {
        ref, args =>
            ref.cast<Vector3>().setScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setX") {
        ref, args =>
            ref.cast<Vector3>().setX(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setY") {
        ref, args =>
            ref.cast<Vector3>().setY(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setZ") {
        ref, args =>
            ref.cast<Vector3>().setZ(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setComponent") {
        ref, args =>
            ref.cast<Vector3>().setComponent(args[0].intValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("getComponent") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().getComponent(args[0].intValue()))]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Vector3>().clone(), "three.core.math.Vector3")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Vector3>().copy(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 加法 =====
    b.method("add") {
        ref, args =>
            ref.cast<Vector3>().add(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScalar") {
        ref, args =>
            ref.cast<Vector3>().addScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("addVectors") {
        ref, args =>
            ref.cast<Vector3>().addVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addScaledVector") {
        ref, args =>
            ref.cast<Vector3>().addScaledVector(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 减法 =====
    b.method("sub") {
        ref, args =>
            ref.cast<Vector3>().sub(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("subScalar") {
        ref, args =>
            ref.cast<Vector3>().subScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("subVectors") {
        ref, args =>
            ref.cast<Vector3>().subVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 乘法 =====
    b.method("multiply") {
        ref, args =>
            ref.cast<Vector3>().multiply(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyScalar") {
        ref, args =>
            ref.cast<Vector3>().multiplyScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("multiplyVectors") {
        ref, args =>
            ref.cast<Vector3>().multiplyVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 除法 =====
    b.method("divide") {
        ref, args =>
            ref.cast<Vector3>().divide(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("divideScalar") {
        ref, args =>
            ref.cast<Vector3>().divideScalar(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 点积/叉积 =====
    b.method("dot") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().dot(prebindAs<Vector3>(args, 0)))]
    }
    b.method("cross") {
        ref, args =>
            ref.cast<Vector3>().cross(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("crossVectors") {
        ref, args =>
            ref.cast<Vector3>().crossVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    // ===== 长度 =====
    b.method("lengthSq") {ref, _ => [LuaValue.of(ref.cast<Vector3>().lengthSq())]}
    b.method("length") {ref, _ => [LuaValue.of(ref.cast<Vector3>().length())]}
    b.method("manhattanLength") {ref, _ => [LuaValue.of(ref.cast<Vector3>().manhattanLength())]}
    // ===== 归一化 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Vector3>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("setLength") {
        ref, args =>
            ref.cast<Vector3>().setLength(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 距离 =====
    b.method("distanceTo") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().distanceTo(prebindAs<Vector3>(args, 0)))]
    }
    b.method("distanceToSquared") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().distanceToSquared(prebindAs<Vector3>(args, 0)))]
    }
    b.method("manhattanDistanceTo") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().manhattanDistanceTo(prebindAs<Vector3>(args, 0)))]
    }
    // ===== 线性插值 =====
    b.method("lerp") {
        ref, args =>
            ref.cast<Vector3>().lerp(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("lerpVectors") {
        ref, args =>
            ref
                .cast<Vector3>()
                .lerpVectors(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // ===== 取负 =====
    b.method("negate") {
        ref, _ =>
            ref.cast<Vector3>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().equals(prebindAs<Vector3>(args, 0)))]
    }
    // ===== 极值 =====
    b.method("min") {
        ref, args =>
            ref.cast<Vector3>().min(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("max") {
        ref, args =>
            ref.cast<Vector3>().max(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("clamp") {
        ref, args =>
            ref.cast<Vector3>().clamp(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clampScalar") {
        ref, args =>
            ref.cast<Vector3>().clampScalar(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clampLength") {
        ref, args =>
            ref.cast<Vector3>().clampLength(args[0].numberValue(), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("floor") {
        ref, _ =>
            ref.cast<Vector3>().floor()
            [LuaValue.Object(ref.id)]
    }
    b.method("ceil") {
        ref, _ =>
            ref.cast<Vector3>().ceil()
            [LuaValue.Object(ref.id)]
    }
    b.method("round") {
        ref, _ =>
            ref.cast<Vector3>().round()
            [LuaValue.Object(ref.id)]
    }
    b.method("roundToZero") {
        ref, _ =>
            ref.cast<Vector3>().roundToZero()
            [LuaValue.Object(ref.id)]
    }
    // ===== 矩阵变换 =====
    b.method("applyMatrix3") {
        ref, args =>
            ref.cast<Vector3>().applyMatrix3(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyNormalMatrix") {
        ref, args =>
            ref.cast<Vector3>().applyNormalMatrix(prebindAs<Matrix3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Vector3>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyQuaternion") {
        ref, args =>
            ref.cast<Vector3>().applyQuaternion(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("transformDirection") {
        ref, args =>
            ref.cast<Vector3>().transformDirection(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 角度 =====
    b.method("angleTo") {
        ref, args => [LuaValue.of(ref.cast<Vector3>().angleTo(prebindAs<Vector3>(args, 0)))]
    }
    // ===== 投影/反射 =====
    b.method("projectOnVector") {
        ref, args =>
            ref.cast<Vector3>().projectOnVector(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("projectOnPlane") {
        ref, args =>
            ref.cast<Vector3>().projectOnPlane(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("reflect") {
        ref, args =>
            ref.cast<Vector3>().reflect(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 坐标设置 =====
    b.method("setFromSpherical") {
        ref, args =>
            ref.cast<Vector3>().setFromSpherical(prebindAs<Spherical>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromSphericalCoords") {
        ref, args =>
            ref
                .cast<Vector3>()
                .setFromSphericalCoords(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCylindrical") {
        ref, args =>
            ref.cast<Vector3>().setFromCylindrical(prebindAs<Cylindrical>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCylindricalCoords") {
        ref, args =>
            ref
                .cast<Vector3>()
                .setFromCylindricalCoords(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrixPosition") {
        ref, args =>
            ref.cast<Vector3>().setFromMatrixPosition(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrixScale") {
        ref, args =>
            ref.cast<Vector3>().setFromMatrixScale(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrixColumn") {
        ref, args =>
            ref.cast<Vector3>().setFromMatrixColumn(prebindAs<Matrix4>(args, 0), args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromMatrix3Column") {
        ref, args =>
            ref.cast<Vector3>().setFromMatrix3Column(prebindAs<Matrix3>(args, 0), args[1].intValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromEuler") {
        ref, args =>
            ref.cast<Vector3>().setFromEuler(prebindAs<Euler>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromColor") {
        ref, args =>
            ref.cast<Vector3>().setFromColor(prebindAs<Color>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 数组操作 =====
    b.method("fromArray") {
        ref, args =>
            ref.cast<Vector3>().fromArray(args[0].toArrayFloat(), offset: prebindInt(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("toArray") {
        ref, _ =>
            var arr = Array<Float64>(3, {_ => 0.0})
            ref.cast<Vector3>().toArray(arr)
            [LuaValue.of(arr)]
    }
    // ===== 随机 =====
    b.method("random") {
        ref, _ =>
            ref.cast<Vector3>().random()
            [LuaValue.Object(ref.id)]
    }
    b.method("randomDirection") {
        ref, _ =>
            ref.cast<Vector3>().randomDirection()
            [LuaValue.Object(ref.id)]
    }
    // ===== 欧拉/轴角/投影 =====
    b.method("applyEuler") {
        ref, args =>
            ref.cast<Vector3>().applyEuler(prebindAs<Euler>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("applyAxisAngle") {
        ref, args =>
            ref.cast<Vector3>().applyAxisAngle(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("project") {
        ref, args =>
            ref.cast<Vector3>().project(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("unproject") {
        ref, args =>
            ref.cast<Vector3>().unproject(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 运算符（程序性调用） =====
    b.method("__add") {
        ref, args => [prebindRegister(ref.cast<Vector3>() + prebindAs<Vector3>(args, 0), "three.core.math.Vector3")]
    }
    b.method("__sub") {
        ref, args => [prebindRegister(ref.cast<Vector3>() - prebindAs<Vector3>(args, 0), "three.core.math.Vector3")]
    }
    b.method("__mul") {
        ref, args => [prebindRegister(ref.cast<Vector3>() * args[0].numberValue(), "three.core.math.Vector3")]
    }
    b.method("__div") {
        ref, args => [prebindRegister(ref.cast<Vector3>() / args[0].numberValue(), "three.core.math.Vector3")]
    }
    b.method("__unm") {
        ref, _ => [prebindRegister(-ref.cast<Vector3>(), "three.core.math.Vector3")]
    }
    b.install(vm)
}
