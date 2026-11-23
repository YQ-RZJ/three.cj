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
 * @file[zh-cn] physics_world_physicsworld PhysicsWorld 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.world.PhysicsWorld 绑定为 Lua 类型
 * three.physics.world.PhysicsWorld
 * @explain[zh-cn] 覆盖构造（可选后端）、backend / isInitialized 查询、start / release、
 * 重力与 BroadPhase、刚体创建销毁、Object3D 绑定、update 步进、transform / 速度 /
 * 摩擦 / 弹性 / 运动类型 / 传感器读写、射线与碰撞查询、力/力矩/冲量/质量/重力因子、
 * moveKinematic，以及约束的创建/销毁/开关/电机/滑块控制。
 * 传感器监听：IPhysicsSensorListener 为接口（不绑定），改由内部适配器
 * _LuaPhysicsSensorListener 承接；Lua 侧把一个含 onContact / onBodyActivated /
 * onBodyDeactivated 三个函数字段的表传给 setContactListener（传 nil 清除）。
 * 引擎在 update() 末尾于主线程派发事件，因此可直接调用 Lua；回调出错静默跳过。
 * 查询类方法（raycastAll / collidePoint / collideShape / castShape）返回命中对象数组，
 * raycast 就地填充传入的 PhysicsRayHit 并返回是否命中。
 * 注意：未调用 start() 前后端未初始化，刚体与查询操作不会产生有效结果。
 *
 * @file[en] physics_world_physicsworld  Lua binding of PhysicsWorld (three.script.prebind)
 * @brief[en] Binds three.physics.world.PhysicsWorld as the Lua type
 * three.physics.world.PhysicsWorld
 * @explain[en] Covers construction (optional backend), backend / isInitialized queries,
 * start / release, gravity and BroadPhase, body creation/destruction, Object3D binding,
 * update stepping, transform / velocity / friction / restitution / motion-type / sensor
 * read-write, ray and collision queries, force/torque/impulse/mass/gravity-factor,
 * moveKinematic, and constraint creation/destruction/enable/motor/slider control.
 * Sensor listening: IPhysicsSensorListener is an interface (not bound) and is replaced by the
 * internal adapter _LuaPhysicsSensorListener; Lua passes a table with the three function fields
 * onContact / onBodyActivated / onBodyDeactivated to setContactListener (nil clears).
 * The engine dispatches events on the main thread at the end of update(), so Lua can be called
 * directly; failing callbacks are silently skipped.
 * Query methods (raycastAll / collidePoint / collideShape / castShape) return object arrays;
 * raycast fills the passed PhysicsRayHit in place and returns whether it hit.
 * Note: the backend is not initialized before start(), so body/query calls produce no valid
 * results until then.
 */
package three.script.prebind

import three.physics.world.PhysicsWorld
import three.physics.backend.JoltBackend
import three.physics._interfaces.*
import three.physics.common.*
import three.scene.objects.Object3D
import three.core.math.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 在 Lua 线程安全执行一条传感器回调
 * @param[zh-cn] cb 目标回调
 * @param[zh-cn] args 回调参数
 *
 * @brief[en] Runs one sensor callback safely on the Lua thread
 * @param[en] cb The target callback
 * @param[en] args The callback arguments
 */
private func _callSensorCallback(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_) {
        // 回调自身出错：跳过，不向引擎抛出
    }
}

/**
 * @brief[zh-cn] IPhysicsSensorListener 的 Lua 函数适配器
 * @explain[zh-cn] 三个回调均可缺省；事件参数按数量转换为 Lua 数值 / 事件序号。
 *
 * @brief[en] Lua-function adapter for IPhysicsSensorListener
 * @explain[en] All three callbacks are optional; event arguments convert to Lua numbers /
 * event ordinals.
 */
class _LuaPhysicsSensorListener <: IPhysicsSensorListener {
    private let _onContact: Option<LuaCallback>
    private let _onActivated: Option<LuaCallback>
    private let _onDeactivated: Option<LuaCallback>

    init(onContact: Option<LuaCallback>, onActivated: Option<LuaCallback>, onDeactivated: Option<LuaCallback>) {
        this._onContact = onContact
        this._onActivated = onActivated
        this._onDeactivated = onDeactivated
    }

    /// 释放三个回调的注册表引用（幂等）
    func releaseCallbacks(): Unit {
        if (let Some(cb) <- this._onContact) {
            cb.release()
        }
        if (let Some(cb) <- this._onActivated) {
            cb.release()
        }
        if (let Some(cb) <- this._onDeactivated) {
            cb.release()
        }
    }

    public func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit {
        if (let Some(cb) <- this._onContact) {
            _callSensorCallback(cb,
                [LuaValue.of(Float64(bodyID1)), LuaValue.of(Float64(bodyID2)),
                    LuaValue.of(physicsContactEventValue(event))])
        }
    }

    public func onBodyActivated(bodyID: UInt32): Unit {
        if (let Some(cb) <- this._onActivated) {
            _callSensorCallback(cb, [LuaValue.of(Float64(bodyID))])
        }
    }

    public func onBodyDeactivated(bodyID: UInt32): Unit {
        if (let Some(cb) <- this._onDeactivated) {
            _callSensorCallback(cb, [LuaValue.of(Float64(bodyID))])
        }
    }
}

/**
 * @brief[zh-cn] 把命中结果列表转为 Lua 对象数组
 * @param[zh-cn] hits 命中结果列表
 * @param[zh-cn] className 绑定类名
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a hit-result list into a Lua object array
 * @param[en] hits The hit-result list
 * @param[en] className The bound class name
 * @return[en] The Lua array value
 */
private func _hitsToLua<T>(hits: ArrayList<T>, className: String): LuaValue {
    let n = hits.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(hits[i], className)
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 PhysicsWorld 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.physics.world.PhysicsWorld）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsWorld
 * @param[en] vm The target virtual machine (class table installed at
 * three.physics.world.PhysicsWorld)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsWorld(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.world.PhysicsWorld")
    // ===== 构造：new(backend?) =====
    b.constructor {
        args => if (args.size >= 1 && args[0].isObject) {
            PhysicsWorld(backend: LuaObjectRegistry.getAs<IPhysicsBackend>(args[0].objectId()))
        } else {
            PhysicsWorld()
        }
    }
    // ===== 后端 / 生命周期 =====
    b.property("backend", getter: Some({
        ref => match (ref.cast<PhysicsWorld>().backend) {
            case jb: JoltBackend => prebindRegister(jb, "three.physics.backend.JoltBackend")
            case _ => LuaValue.Nil
        }
    }))
    b.method("start") {
        ref, args =>
            let gravity = if (args.size >= 2) {
                prebindAs<Vector3>(args, 1)
            } else {
                Vector3(0.0, -9.81, 0.0)
            }
            [LuaValue.of(
                ref
                    .cast<PhysicsWorld>()
                    .start(maxBodies: UInt32(prebindInt(args, 0, default: 1024) & 0xFFFFFFFF), gravity: gravity))]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsWorld>().release())]
    }
    b.method("isInitialized") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsWorld>().isInitialized())]
    }
    b.method("setGravity") {
        ref, args =>
            ref.cast<PhysicsWorld>().setGravity(prebindAs<Vector3>(args, 0))
            Array<LuaValue>()
    }
    b.method("optimizeBroadPhase") {
        ref, _ =>
            ref.cast<PhysicsWorld>().optimizeBroadPhase()
            Array<LuaValue>()
    }
    // ===== 刚体 =====
    b.method("createBody") {
        ref, args => [physicsBodyHandleToLua(ref.cast<PhysicsWorld>().createBody(prebindAs<PhysicsBodyDesc>(args, 0)))]
    }
    b.method("destroyBody") {
        ref, args =>
            ref.cast<PhysicsWorld>().destroyBody(prebindAs<PhysicsBodyHandle>(args, 0))
            Array<LuaValue>()
    }
    b.method("bindObject") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .bindObject(prebindAs<Object3D>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                    syncToObj: prebindBool(args, 2, default: true))
            Array<LuaValue>()
    }
    b.method("unbindObject") {
        ref, args =>
            ref.cast<PhysicsWorld>().unbindObject(prebindAs<Object3D>(args, 0))
            Array<LuaValue>()
    }
    // ===== 步进 =====
    b.method("update") {
        ref, args => [LuaValue.of(
            Float64(ref
                .cast<PhysicsWorld>()
                .update(Float32(prebindNum(args, 0, default: 1.0 / 60.0)),
                    collisionSteps: Int32(prebindInt(args, 1, default: 1)))))]
    }
    // ===== 刚体 transform / 速度 =====
    b.method("setPosition") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setPosition(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    activation: physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getPosition") {
        ref, args => [prebindRegister(ref.cast<PhysicsWorld>().getPosition(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("setRotation") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setRotation(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Quaternion>(args, 1),
                    activation: physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getRotation") {
        ref, args => [prebindRegister(ref.cast<PhysicsWorld>().getRotation(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Quaternion")]
    }
    b.method("setLinearVelocity") {
        ref, args =>
            ref.cast<PhysicsWorld>().setLinearVelocity(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getLinearVelocity") {
        ref, args => [prebindRegister(ref.cast<PhysicsWorld>().getLinearVelocity(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("setAngularVelocity") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setAngularVelocity(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getAngularVelocity") {
        ref, args => [prebindRegister(ref.cast<PhysicsWorld>().getAngularVelocity(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    // ===== 材质 / 运动类型 / 传感器 =====
    b.method("setFriction") {
        ref, args =>
            ref.cast<PhysicsWorld>().setFriction(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getFriction") {
        ref, args => [LuaValue.of(ref.cast<PhysicsWorld>().getFriction(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setRestitution") {
        ref, args =>
            ref.cast<PhysicsWorld>().setRestitution(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getRestitution") {
        ref, args => [LuaValue.of(ref.cast<PhysicsWorld>().getRestitution(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setMotionType") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setMotionType(prebindAs<PhysicsBodyHandle>(args, 0), physicsMotionTypeFrom(prebindInt(args, 1)),
                    activation: physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getMotionType") {
        ref, args => [LuaValue.of(
            physicsMotionTypeValue(ref.cast<PhysicsWorld>().getMotionType(prebindAs<PhysicsBodyHandle>(args, 0))))]
    }
    b.method("isBodyActive") {
        ref, args => [LuaValue.of(ref.cast<PhysicsWorld>().isBodyActive(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setIsSensor") {
        ref, args =>
            ref.cast<PhysicsWorld>().setIsSensor(prebindAs<PhysicsBodyHandle>(args, 0), prebindBool(args, 1))
            Array<LuaValue>()
    }
    // ===== 查询 =====
    b.method("raycast") {
        ref, args => [LuaValue.of(
            ref
                .cast<PhysicsWorld>()
                .raycast(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<PhysicsRayHit>(args, 2)))]
    }
    b.method("raycastAll") {
        ref, args => [_hitsToLua(
            ref.cast<PhysicsWorld>().raycastAll(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1)),
            "three.physics.common.PhysicsRayHit")]
    }
    b.method("collidePoint") {
        ref, args => [_hitsToLua(ref.cast<PhysicsWorld>().collidePoint(prebindAs<Vector3>(args, 0)),
            "three.physics.common.PhysicsPointHit")]
    }
    b.method("collideShape") {
        ref, args => [_hitsToLua(
            ref
                .cast<PhysicsWorld>()
                .collideShape(prebindAs<PhysicsShape>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Quaternion>(args, 2)), "three.physics.common.PhysicsShapeHit")]
    }
    b.method("castShape") {
        ref, args => [_hitsToLua(
            ref
                .cast<PhysicsWorld>()
                .castShape(prebindAs<PhysicsShape>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Quaternion>(args, 2),
                    prebindAs<Vector3>(args, 3)), "three.physics.common.PhysicsShapeHit")]
    }
    // ===== 传感器监听（接口适配为 Lua 函数表） =====
    b.method("setContactListener") {
        ref, args =>
            let world = ref.cast<PhysicsWorld>()
            if (args.size < 1 || args[0].isNil || !args[0].isTable) {
                world.setContactListener(Option<IPhysicsSensorListener>.None)
            } else {
                let t = LuaTable(vm: vm, ref: Int32(args[0].refId()))
                world.setContactListener(
                    Some(
                        _LuaPhysicsSensorListener(prebindOptCallbackOf(vm, t.get("onContact")),
                            prebindOptCallbackOf(vm, t.get("onBodyActivated")),
                            prebindOptCallbackOf(vm, t.get("onBodyDeactivated")))))
            }
            Array<LuaValue>()
    }
    // ===== 力 / 力矩 / 冲量 / 质量 / 重力因子 =====
    b.method("addForce") {
        ref, args =>
            ref.cast<PhysicsWorld>().addForce(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addForceAtPosition") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .addForceAtPosition(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Vector3>(args, 2))
            Array<LuaValue>()
    }
    b.method("addTorque") {
        ref, args =>
            ref.cast<PhysicsWorld>().addTorque(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addImpulse") {
        ref, args =>
            ref.cast<PhysicsWorld>().addImpulse(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addAngularImpulse") {
        ref, args =>
            ref.cast<PhysicsWorld>().addAngularImpulse(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getMass") {
        ref, args => [LuaValue.of(ref.cast<PhysicsWorld>().getMass(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setMass") {
        ref, args =>
            ref.cast<PhysicsWorld>().setMass(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getInverseInertia") {
        ref, args => [prebindRegister(ref.cast<PhysicsWorld>().getInverseInertia(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Matrix4")]
    }
    b.method("setGravityFactor") {
        ref, args =>
            ref.cast<PhysicsWorld>().setGravityFactor(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getGravityFactor") {
        ref, args => [LuaValue.of(ref.cast<PhysicsWorld>().getGravityFactor(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("moveKinematic") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .moveKinematic(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Quaternion>(args, 2), Float32(prebindNum(args, 3)))
            Array<LuaValue>()
    }
    // ===== 约束 =====
    b.method("createConstraint") {
        ref, args => [physicsConstraintHandleToLua(
            ref
                .cast<PhysicsWorld>()
                .createConstraint(prebindAs<PhysicsConstraintDesc>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                    prebindAs<PhysicsBodyHandle>(args, 2)))]
    }
    b.method("destroyConstraint") {
        ref, args =>
            ref.cast<PhysicsWorld>().destroyConstraint(prebindAs<PhysicsConstraintHandle>(args, 0))
            Array<LuaValue>()
    }
    b.method("isConstraintEnabled") {
        ref, args => [LuaValue.of(
            ref.cast<PhysicsWorld>().isConstraintEnabled(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.method("setConstraintEnabled") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setConstraintEnabled(prebindAs<PhysicsConstraintHandle>(args, 0), prebindBool(args, 1, default: true))
            Array<LuaValue>()
    }
    b.method("setConstraintMotorState") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setConstraintMotorState(prebindAs<PhysicsConstraintHandle>(args, 0),
                    physicsMotorStateFrom(prebindInt(args, 1)))
            Array<LuaValue>()
    }
    b.method("setConstraintTargetAngularVelocity") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setConstraintTargetAngularVelocity(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setConstraintTargetAngle") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setConstraintTargetAngle(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getConstraintCurrentAngle") {
        ref, args => [LuaValue.of(
            ref.cast<PhysicsWorld>().getConstraintCurrentAngle(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.method("setSliderTargetVelocity") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setSliderTargetVelocity(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setSliderTargetPosition") {
        ref, args =>
            ref
                .cast<PhysicsWorld>()
                .setSliderTargetPosition(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getSliderCurrentPosition") {
        ref, args => [LuaValue.of(
            ref.cast<PhysicsWorld>().getSliderCurrentPosition(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.install(vm)
}
