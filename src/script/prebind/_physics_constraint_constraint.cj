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
 * @file[zh-cn] physics_constraint_constraint PhysicsConstraint 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.constraint.PhysicsConstraint 绑定为 Lua 类型
 * three.physics.constraint.PhysicsConstraint
 * @explain[zh-cn] 覆盖构造（world / handle）、handle / releasable 只读属性、
 * isEnabled / setEnabled（链式）/ release，以及九个静态便捷工厂：
 * fixed / point / hinge / slider / distance / cone / swingTwist / gear / sixDOF。
 * 工厂参数与仓颉签名一致（刚体句柄为 PhysicsBodyHandle 值对象，锚点/轴为 Vector3）。
 *
 * @file[en] physics_constraint_constraint  Lua binding of PhysicsConstraint
 * (three.script.prebind)
 * @brief[en] Binds three.physics.constraint.PhysicsConstraint as the Lua type
 * three.physics.constraint.PhysicsConstraint
 * @explain[en] Covers construction (world / handle), the read-only handle / releasable
 * properties, isEnabled / setEnabled (chainable) / release, and the nine static convenience
 * factories: fixed / point / hinge / slider / distance / cone / swingTwist / gear / sixDOF.
 * Factory parameters match the Cangjie signatures (body handles are PhysicsBodyHandle value
 * objects; anchors/axes are Vector3).
 */
package three.script.prebind

import three.physics.constraint.PhysicsConstraint
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsConstraint 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.physics.constraint.PhysicsConstraint）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsConstraint
 * @param[en] vm The target virtual machine (class table installed at
 * three.physics.constraint.PhysicsConstraint)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsConstraint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.constraint.PhysicsConstraint")
    // ===== 构造：new(world, handle) =====
    b.constructor {
        args => PhysicsConstraint(world: prebindAs<PhysicsWorld>(args, 0),
            handle: prebindAs<PhysicsConstraintHandle>(args, 1))
    }
    // ===== 只读状态 =====
    b.property("handle", getter: Some({ref => physicsConstraintHandleToLua(ref.cast<PhysicsConstraint>().handle)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsConstraint>().releasable)}))
    // ===== 开关 / 释放 =====
    b.method("isEnabled") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsConstraint>().isEnabled())]
    }
    b.method("setEnabled") {
        ref, args =>
            ref.cast<PhysicsConstraint>().setEnabled(prebindBool(args, 0, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsConstraint>().release())]
    }
    // ===== 静态工厂 =====
    b.staticMethod("fixed") {
        args => [prebindRegister(
            PhysicsConstraint.fixed(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("point") {
        args => [prebindRegister(
            PhysicsConstraint.point(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3)),
            "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("hinge") {
        args => [prebindRegister(
            PhysicsConstraint.hinge(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                limitMin: prebindNum(args, 5, default: -3.14159265358979),
                limitMax: prebindNum(args, 6, default: 3.14159265358979)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("slider") {
        args => [prebindRegister(
            PhysicsConstraint.slider(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindNum(args, 5), prebindNum(args, 6)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("distance") {
        args => [prebindRegister(
            PhysicsConstraint.distance(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindNum(args, 5), prebindNum(args, 6)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("cone") {
        args => [prebindRegister(
            PhysicsConstraint.cone(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindNum(args, 5)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("swingTwist") {
        args => [prebindRegister(
            PhysicsConstraint.swingTwist(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindAs<Vector3>(args, 5), prebindNum(args, 6), prebindNum(args, 7)),
            "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("gear") {
        args => [prebindRegister(
            PhysicsConstraint.gear(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), prebindAs<Vector3>(args, 4),
                prebindNum(args, 5)), "three.physics.constraint.PhysicsConstraint")]
    }
    b.staticMethod("sixDOF") {
        args => [prebindRegister(
            PhysicsConstraint.sixDOF(prebindAs<PhysicsWorld>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                prebindAs<PhysicsBodyHandle>(args, 2), prebindAs<Vector3>(args, 3), axisX: prebindAs<Vector3>(args, 4)),
            "three.physics.constraint.PhysicsConstraint")]
    }
    b.install(vm)
}
