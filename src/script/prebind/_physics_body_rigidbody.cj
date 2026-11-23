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
 * @file[zh-cn] physics_body_rigidbody RigidBody 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.body.RigidBody 绑定为 Lua 类型 three.physics.body.RigidBody
 * @explain[zh-cn] 覆盖构造（world / shape / layer）、链式构建（setShape / setPosition /
 * setRotation / setRotationEuler / setDynamic / setKinematic / setStatic / setFriction /
 * setRestitution / setActivation / setLayer / setSensor）、attach（绑定 Object3D）与
 * release，以及运行时控制（速度 / 位置 / 旋转 / 运动类型 / 力 / 力矩 / 冲量 / 质量 /
 * 重力因子 / moveKinematic）与只读状态（handle / attached / boundObject / world /
 * isSensor / releasable）。
 * 链式方法返回自身对象，便于 Lua 侧 `body:setShape(s):setDynamic():setPosition(...)`。
 * 运行时 get* 在未 attach 时按引擎语义返回零值 / 单位四元数。
 *
 * @file[en] physics_body_rigidbody  Lua binding of RigidBody (three.script.prebind)
 * @brief[en] Binds three.physics.body.RigidBody as the Lua type three.physics.body.RigidBody
 * @explain[en] Covers construction (world / shape / layer), chainable building (setShape /
 * setPosition / setRotation / setRotationEuler / setDynamic / setKinematic / setStatic /
 * setFriction / setRestitution / setActivation / setLayer / setSensor), attach (binds an
 * Object3D) and release, plus runtime control (velocity / position / rotation / motion type /
 * force / torque / impulse / mass / gravity factor / moveKinematic) and read-only state
 * (handle / attached / boundObject / world / isSensor / releasable).
 * Chainable methods return the object itself so Lua can write
 * `body:setShape(s):setDynamic():setPosition(...)`.
 * The runtime get* methods return zero values / identity quaternions when not attached,
 * matching engine semantics.
 */
package three.script.prebind

import three.physics.body.RigidBody
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.scene.objects.Object3D
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RigidBody 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.physics.body.RigidBody）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RigidBody
 * @param[en] vm The target virtual machine (class table installed at three.physics.body.RigidBody)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRigidBody(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.body.RigidBody")
    // ===== 构造：new(world, shape?, layer?) =====
    b.constructor {
        args =>
            let world = prebindAs<PhysicsWorld>(args, 0)
            if (args.size >= 2 && args[1].isObject) {
                RigidBody(world: world, shape: prebindAs<PhysicsShape>(args, 1),
                    layer: physicsLayerFrom(prebindInt(args, 2, default: 1)))
            } else {
                RigidBody(world: world, layer: physicsLayerFrom(prebindInt(args, 1, default: 1)))
            }
    }
    // ===== 链式构建 =====
    b.method("setShape") {
        ref, args =>
            ref.cast<RigidBody>().setShape(prebindAs<PhysicsShape>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setPosition") {
        ref, args =>
            ref.cast<RigidBody>().setPosition(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setRotation") {
        ref, args =>
            ref.cast<RigidBody>().setRotation(prebindAs<Quaternion>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setRotationEuler") {
        ref, args =>
            ref.cast<RigidBody>().setRotationEuler(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setDynamic") {
        ref, _ =>
            ref.cast<RigidBody>().setDynamic()
            [LuaValue.Object(ref.id)]
    }
    b.method("setKinematic") {
        ref, _ =>
            ref.cast<RigidBody>().setKinematic()
            [LuaValue.Object(ref.id)]
    }
    b.method("setStatic") {
        ref, _ =>
            ref.cast<RigidBody>().setStatic()
            [LuaValue.Object(ref.id)]
    }
    b.method("setFriction") {
        ref, args =>
            ref.cast<RigidBody>().setFriction(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setRestitution") {
        ref, args =>
            ref.cast<RigidBody>().setRestitution(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setActivation") {
        ref, args =>
            ref.cast<RigidBody>().setActivation(physicsActivationFrom(prebindInt(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setLayer") {
        ref, args =>
            ref.cast<RigidBody>().setLayer(physicsLayerFrom(prebindInt(args, 0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("setSensor") {
        ref, args =>
            ref.cast<RigidBody>().setSensor(prebindBool(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 创建 / 绑定 / 销毁 =====
    b.method("attach") {
        ref, args =>
            ref.cast<RigidBody>().attach(prebindAs<Object3D>(args, 0), syncToObj: prebindBool(args, 1, default: true))
            [LuaValue.Object(ref.id)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<RigidBody>().release())]
    }
    // ===== 只读状态 =====
    b.property("handle", getter: Some({ref => physicsBodyHandleToLua(ref.cast<RigidBody>().handle)}))
    b.property("attached", getter: Some({ref => LuaValue.of(ref.cast<RigidBody>().attached)}))
    b.property("boundObject", getter: Some({
        ref => match (ref.cast<RigidBody>().boundObject) {
            case Some(obj) => prebindRegister(obj, "three.scene.objects.Object3D")
            case None => LuaValue.Nil
        }
    }))
    b.property("world", getter: Some({
        ref => prebindRegister(ref.cast<RigidBody>().world, "three.physics.world.PhysicsWorld")
    }))
    b.property("isSensor", getter: Some({ref => LuaValue.of(ref.cast<RigidBody>().isSensor)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<RigidBody>().releasable)}))
    // ===== 运行时：速度 / 位置 / 旋转 / 运动类型 =====
    b.method("setLinearVelocity") {
        ref, args =>
            ref.cast<RigidBody>().setLinearVelocity(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setAngularVelocity") {
        ref, args =>
            ref.cast<RigidBody>().setAngularVelocity(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("getLinearVelocity") {
        ref, _ => [prebindRegister(ref.cast<RigidBody>().getLinearVelocity(), "three.core.math.Vector3")]
    }
    b.method("getAngularVelocity") {
        ref, _ => [prebindRegister(ref.cast<RigidBody>().getAngularVelocity(), "three.core.math.Vector3")]
    }
    b.method("setPositionRuntime") {
        ref, args =>
            ref
                .cast<RigidBody>()
                .setPositionRuntime(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2),
                    activation: physicsActivationFrom(prebindInt(args, 3, default: 0)))
            Array<LuaValue>()
    }
    b.method("setRotationRuntime") {
        ref, args =>
            ref
                .cast<RigidBody>()
                .setRotationRuntime(prebindAs<Quaternion>(args, 0),
                    activation: physicsActivationFrom(prebindInt(args, 1, default: 0)))
            Array<LuaValue>()
    }
    b.method("setMotionTypeRuntime") {
        ref, args =>
            ref
                .cast<RigidBody>()
                .setMotionTypeRuntime(physicsMotionTypeFrom(prebindInt(args, 0)),
                    activation: physicsActivationFrom(prebindInt(args, 1, default: 0)))
            Array<LuaValue>()
    }
    b.method("isActive") {
        ref, _ => [LuaValue.of(ref.cast<RigidBody>().isActive())]
    }
    b.method("getPosition") {
        ref, _ => [prebindRegister(ref.cast<RigidBody>().getPosition(), "three.core.math.Vector3")]
    }
    b.method("getRotation") {
        ref, _ => [prebindRegister(ref.cast<RigidBody>().getRotation(), "three.core.math.Quaternion")]
    }
    // ===== 运行时：力 / 力矩 / 冲量 =====
    b.method("addForce") {
        ref, args =>
            ref.cast<RigidBody>().addForce(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("addForceV") {
        ref, args =>
            ref.cast<RigidBody>().addForceV(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("addForceAtPosition") {
        ref, args =>
            ref.cast<RigidBody>().addForceAtPosition(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("addTorque") {
        ref, args =>
            ref.cast<RigidBody>().addTorque(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("addImpulse") {
        ref, args =>
            ref.cast<RigidBody>().addImpulse(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("addAngularImpulse") {
        ref, args =>
            ref.cast<RigidBody>().addAngularImpulse(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    // ===== 运行时：质量 / 重力因子 / 运动学移动 =====
    b.method("getMass") {
        ref, _ => [LuaValue.of(ref.cast<RigidBody>().getMass())]
    }
    b.method("setMass") {
        ref, args =>
            ref.cast<RigidBody>().setMass(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setGravityFactor") {
        ref, args =>
            ref.cast<RigidBody>().setGravityFactor(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("getGravityFactor") {
        ref, _ => [LuaValue.of(ref.cast<RigidBody>().getGravityFactor())]
    }
    b.method("moveKinematic") {
        ref, args =>
            ref
                .cast<RigidBody>()
                .moveKinematic(prebindAs<Vector3>(args, 0), prebindAs<Quaternion>(args, 1), Float32(prebindNum(args, 2)))
            Array<LuaValue>()
    }
    b.install(vm)
}
