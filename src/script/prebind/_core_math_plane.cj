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
 * @file[zh-cn] core_math_plane 平面 Plane 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Plane 绑定为 Lua 类型 three.core.math.Plane
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/setComponents/
 * setFromNormalAndCoplanarPoint/setFromCoplanarPoints/clone/copy/normalize/negate/
 * distanceToPoint/distanceToSphere/projectPoint/intersectLine/intersectsLine/
 * intersectsBox/intersectsSphere/coplanarPoint/applyMatrix4/translate/equals）与属性
 * normal/constant（读写）。互变异构方法均返回自身（Lua 链式可用）。
 * projectPoint/coplanarPoint 需传入 target 向量（写入并返回该对象）；
 * intersectLine 返回 Option<Vector3>：命中时返回 target，未命中返回 nil。
 *
 * @file[en] core_math_plane Lua binding of the plane Plane (three.script.prebind)
 * @brief[en] Binds three.core.math.Plane as the Lua type three.core.math.Plane
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/setComponents/setFromNormalAndCoplanarPoint/setFromCoplanarPoints/clone/copy/
 * normalize/negate/distanceToPoint/distanceToSphere/projectPoint/intersectLine/
 * intersectsLine/intersectsBox/intersectsSphere/coplanarPoint/applyMatrix4/translate/
 * equals) and properties normal/constant (read-write). Mutating methods return self
 * for Lua chaining. projectPoint/coplanarPoint take a target vector (written and
 * returned); intersectLine returns Option<Vector3>: the target on hit, nil otherwise.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Plane 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Plane）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Plane
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Plane)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPlane(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Plane")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Plane(prebindAs<Vector3>(args, 0), args[1].numberValue())
        } else {
            Plane()
        }
    }
    // ===== 属性 =====
    b.property("normal", getter: Some({ref => prebindRegister(ref.cast<Plane>().normal, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Plane>().normal = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("constant", getter: Some({ref => LuaValue.of(ref.cast<Plane>().constant)}),
        setter: Some({ref, v => ref.cast<Plane>().constant = v.numberValue()}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Plane>().set(prebindAs<Vector3>(args, 0), args[1].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setComponents") {
        ref, args =>
            ref
                .cast<Plane>()
                .setComponents(args[0].numberValue(), args[1].numberValue(), args[2].numberValue(),
                    args[3].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromNormalAndCoplanarPoint") {
        ref, args =>
            ref.cast<Plane>().setFromNormalAndCoplanarPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCoplanarPoints") {
        ref, args =>
            ref
                .cast<Plane>()
                .setFromCoplanarPoints(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Vector3>(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Plane>().clone(), "three.core.math.Plane")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Plane>().copy(prebindAs<Plane>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 归一化/取负 =====
    b.method("normalize") {
        ref, _ =>
            ref.cast<Plane>().normalize()
            [LuaValue.Object(ref.id)]
    }
    b.method("negate") {
        ref, _ =>
            ref.cast<Plane>().negate()
            [LuaValue.Object(ref.id)]
    }
    // ===== 距离 =====
    b.method("distanceToPoint") {
        ref, args => [LuaValue.of(ref.cast<Plane>().distanceToPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("distanceToSphere") {
        ref, args => [LuaValue.of(ref.cast<Plane>().distanceToSphere(prebindAs<Sphere>(args, 0)))]
    }
    // ===== 相交测试 =====
    b.method("projectPoint") {
        ref, args =>
            ref.cast<Plane>().projectPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(args[1].objectId())]
    }
    b.method("intersectLine") {
        ref, args =>
            let r = ref
                .cast<Plane>()
                .intersectLine(prebindAs<Line3>(args, 0), prebindAs<Vector3>(args, 1),
                    clampToLine: prebindBool(args, 2, default: true))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[1].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.method("intersectsLine") {
        ref, args => [LuaValue.of(ref.cast<Plane>().intersectsLine(prebindAs<Line3>(args, 0)))]
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Plane>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    b.method("intersectsSphere") {
        ref, args => [LuaValue.of(ref.cast<Plane>().intersectsSphere(prebindAs<Sphere>(args, 0)))]
    }
    b.method("coplanarPoint") {
        ref, args =>
            ref.cast<Plane>().coplanarPoint(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(args[0].objectId())]
    }
    // ===== 变换/平移 =====
    b.method("applyMatrix4") {
        ref, args =>
            let om: Option<Matrix3> = if (args.size > 1 && args[1].isObject) {
                Some(prebindAs<Matrix3>(args, 1))
            } else {
                None
            }
            ref.cast<Plane>().applyMatrix4(prebindAs<Matrix4>(args, 0), optionalNormalMatrix: om)
            [LuaValue.Object(ref.id)]
    }
    b.method("translate") {
        ref, args =>
            ref.cast<Plane>().translate(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 比较 =====
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Plane>().equals(prebindAs<Plane>(args, 0)))]
    }
    b.install(vm)
}
