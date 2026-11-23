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
 * @file[zh-cn] core_math_ray 射线 Ray 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Ray 绑定为 Lua 类型 three.core.math.Ray
 * @explain[zh-cn] 覆盖构造（new/无参与双参）、实例方法（set/clone/copy/at/lookAt/recast/
 * closestPointToPoint/distanceToPoint/distanceSqToPoint/distanceSqToSegment/
 * intersectSphere/intersectsSphere/distanceToPlane/intersectPlane/intersectsPlane/
 * intersectBox/intersectsBox/intersectTriangle/applyMatrix4/equals）与属性 origin/
 * direction（读写）。互变异构方法均返回自身（Lua 链式可用）。at/closestPointToPoint
 * 按参数个数分派无参与 target 两版；intersectSphere/intersectPlane/intersectBox/
 * intersectTriangle 返回 Option<Vector3>：命中时返回 target，未命中返回 nil。
 *
 * @file[en] core_math_ray Lua binding of the ray Ray (three.script.prebind)
 * @brief[en] Binds three.core.math.Ray as the Lua type three.core.math.Ray
 * @explain[en] Covers construction (new / no-arg / two-arg), instance methods
 * (set/clone/copy/at/lookAt/recast/closestPointToPoint/distanceToPoint/
 * distanceSqToPoint/distanceSqToSegment/intersectSphere/intersectsSphere/
 * distanceToPlane/intersectPlane/intersectsPlane/intersectBox/intersectsBox/
 * intersectTriangle/applyMatrix4/equals) and properties origin/direction (read-write).
 * Mutating methods return self for Lua chaining. at/closestPointToPoint dispatch
 * between no-arg and target versions by argument count; intersectSphere/intersectPlane/
 * intersectBox/intersectTriangle return Option<Vector3>: the target on hit, nil otherwise.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Ray 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Ray）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Ray
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Ray)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRay(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Ray")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 2) {
            Ray(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
        } else {
            Ray()
        }
    }
    // ===== 属性 =====
    b.property("origin", getter: Some({ref => prebindRegister(ref.cast<Ray>().origin, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Ray>().origin = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    b.property("direction", getter: Some({ref => prebindRegister(ref.cast<Ray>().direction, "three.core.math.Vector3")}),
        setter: Some({ref, v => ref.cast<Ray>().direction = LuaObjectRegistry.getAs<Vector3>(v.objectId())}))
    // ===== 设置 =====
    b.method("set") {
        ref, args =>
            ref.cast<Ray>().set(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Ray>().clone(), "three.core.math.Ray")]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Ray>().copy(prebindAs<Ray>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // at(t) / at(t, target)
    b.method("at") {
        ref, args =>
            let v = ref.cast<Ray>()
            if (args.size >= 2) {
                v.at(args[0].numberValue(), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.at(args[0].numberValue()), "three.core.math.Vector3")]
            }
    }
    b.method("lookAt") {
        ref, args =>
            ref.cast<Ray>().lookAt(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("recast") {
        ref, args =>
            ref.cast<Ray>().recast(args[0].numberValue())
            [LuaValue.Object(ref.id)]
    }
    // closestPointToPoint(point) / closestPointToPoint(point, target)
    b.method("closestPointToPoint") {
        ref, args =>
            let v = ref.cast<Ray>()
            if (args.size >= 2) {
                v.closestPointToPoint(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
                [LuaValue.Object(args[1].objectId())]
            } else {
                [prebindRegister(v.closestPointToPoint(prebindAs<Vector3>(args, 0)), "three.core.math.Vector3")]
            }
    }
    // ===== 距离 =====
    b.method("distanceToPoint") {
        ref, args => [LuaValue.of(ref.cast<Ray>().distanceToPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("distanceSqToPoint") {
        ref, args => [LuaValue.of(ref.cast<Ray>().distanceSqToPoint(prebindAs<Vector3>(args, 0)))]
    }
    b.method("distanceSqToSegment") {
        ref, args =>
            let op1: Option<Vector3> = if (args.size > 2 && args[2].isObject) {
                Some(prebindAs<Vector3>(args, 2))
            } else {
                None
            }
            let op2: Option<Vector3> = if (args.size > 3 && args[3].isObject) {
                Some(prebindAs<Vector3>(args, 3))
            } else {
                None
            }
            [LuaValue.of(
                ref
                    .cast<Ray>()
                    .distanceSqToSegment(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1),
                        optionalPointOnRay: op1, optionalPointOnSegment: op2))]
    }
    // ===== 球体 =====
    b.method("intersectSphere") {
        ref, args =>
            let r = ref.cast<Ray>().intersectSphere(prebindAs<Sphere>(args, 0), prebindAs<Vector3>(args, 1))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[1].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.method("intersectsSphere") {
        ref, args => [LuaValue.of(ref.cast<Ray>().intersectsSphere(prebindAs<Sphere>(args, 0)))]
    }
    // ===== 平面 =====
    b.method("distanceToPlane") {
        ref, args => [LuaValue.of(ref.cast<Ray>().distanceToPlane(prebindAs<Plane>(args, 0)))]
    }
    b.method("intersectPlane") {
        ref, args =>
            let r = ref.cast<Ray>().intersectPlane(prebindAs<Plane>(args, 0), prebindAs<Vector3>(args, 1))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[1].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.method("intersectsPlane") {
        ref, args => [LuaValue.of(ref.cast<Ray>().intersectsPlane(prebindAs<Plane>(args, 0)))]
    }
    // ===== 包围盒 =====
    b.method("intersectBox") {
        ref, args =>
            let r = ref.cast<Ray>().intersectBox(prebindAs<Box3>(args, 0), prebindAs<Vector3>(args, 1))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[1].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    b.method("intersectsBox") {
        ref, args => [LuaValue.of(ref.cast<Ray>().intersectsBox(prebindAs<Box3>(args, 0)))]
    }
    // ===== 三角形 =====
    b.method("intersectTriangle") {
        ref, args =>
            let r = ref
                .cast<Ray>()
                .intersectTriangle(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Vector3>(args, 2),
                    args[3].boolValue(), prebindAs<Vector3>(args, 4))
            if (let Some(_) <- r) {
                [LuaValue.Object(args[4].objectId())]
            } else {
                [LuaValue.Nil]
            }
    }
    // ===== 变换/比较 =====
    b.method("applyMatrix4") {
        ref, args =>
            ref.cast<Ray>().applyMatrix4(prebindAs<Matrix4>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("equals") {
        ref, args => [LuaValue.of(ref.cast<Ray>().equals(prebindAs<Ray>(args, 0)))]
    }
    b.install(vm)
}
