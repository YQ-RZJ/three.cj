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
 * @file[zh-cn] physics_backend_joltbackend JoltBackend 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.physics.backend.JoltBackend 绑定为 Lua 类型
 * three.physics.backend.JoltBackend
 * @explain[zh-cn] 覆盖后端生命周期（initialize / release / isInitialized / setGravity /
 * optimizeBroadPhase / backendName）、刚体创建销毁、transform / 速度 / 材质 / 运动类型 /
 * 对象层读写、update 步进、射线与碰撞查询、力/力矩/冲量/质量/重力因子、
 * moveKinematic 与约束全套控制接口。
 * 查询适配：raycastAll / collidePoint / collideShape / castShape 在绑定层内部分配结果
 * 列表并返回 Lua 对象数组；raycast 就地填充传入的 PhysicsRayHit。
 * 传感器监听：IPhysicsSensorListener 为接口（不绑定），Lua 侧以含 onContact /
 * onBodyActivated / onBodyDeactivated 的表传入 setContactListener；由于回调可能发生在
 * 物理线程，绑定层统一投递到 LuaDeferredTaskQueue，并在 update() 末尾抽干执行。
 *
 * @file[en] physics_backend_joltbackend  Lua binding of JoltBackend (three.script.prebind)
 * @brief[en] Binds three.physics.backend.JoltBackend as the Lua type
 * three.physics.backend.JoltBackend
 * @explain[en] Covers backend lifecycle (initialize / release / isInitialized / setGravity /
 * optimizeBroadPhase / backendName), body creation/destruction, transform / velocity /
 * material / motion-type / object-layer read-write, update stepping, ray and collision
 * queries, force/torque/impulse/mass/gravity-factor, moveKinematic and the full constraint
 * control interface.
 * Query adaptation: raycastAll / collidePoint / collideShape / castShape allocate the result
 * lists inside the binding and return Lua object arrays; raycast fills the passed PhysicsRayHit
 * in place.
 * Sensor listening: IPhysicsSensorListener is an interface (not bound); Lua passes a table with
 * onContact / onBodyActivated / onBodyDeactivated to setContactListener. Since callbacks may
 * fire on the physics thread, the binding posts them into LuaDeferredTaskQueue and drains it at
 * the end of update().
 */
package three.script.prebind

import three.physics.backend.JoltBackend
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] Jolt 传感器回调任务队列（进程内单例）
 *
 * @brief[en] Jolt sensor callback task queue (process-wide)
 */
private let _joltSensorTasks: LuaDeferredTaskQueue = LuaDeferredTaskQueue()

/**
 * @brief[zh-cn] 安全执行一条 Jolt 传感器回调
 * @param[zh-cn] cb 回调
 * @param[zh-cn] args 参数
 *
 * @brief[en] Runs one Jolt sensor callback safely
 * @param[en] cb The callback
 * @param[en] args The arguments
 */
private func _callJoltCallback(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_) {
        // 回调自身出错：跳过，不向引擎抛出
    }
}

/**
 * @brief[zh-cn] IPhysicsSensorListener 的 Lua 适配器（Jolt 直连后端）
 *
 * @brief[en] Lua adapter for IPhysicsSensorListener (direct Jolt backend)
 */
class _LuaJoltSensorListener <: IPhysicsSensorListener {
    private let _onContact: Option<LuaCallback>
    private let _onActivated: Option<LuaCallback>
    private let _onDeactivated: Option<LuaCallback>

    init(onContact: Option<LuaCallback>, onActivated: Option<LuaCallback>, onDeactivated: Option<LuaCallback>) {
        this._onContact = onContact
        this._onActivated = onActivated
        this._onDeactivated = onDeactivated
    }

    public func onContact(bodyID1: UInt32, bodyID2: UInt32, event: PhysicsContactEvent): Unit {
        if (let Some(cb) <- this._onContact) {
            _joltSensorTasks.post({
                => _callJoltCallback(cb,
                    [LuaValue.of(Float64(bodyID1)), LuaValue.of(Float64(bodyID2)),
                        LuaValue.of(physicsContactEventValue(event))])
            })
        }
    }

    public func onBodyActivated(bodyID: UInt32): Unit {
        if (let Some(cb) <- this._onActivated) {
            _joltSensorTasks.post({=> _callJoltCallback(cb, [LuaValue.of(Float64(bodyID))])})
        }
    }

    public func onBodyDeactivated(bodyID: UInt32): Unit {
        if (let Some(cb) <- this._onDeactivated) {
            _joltSensorTasks.post({=> _callJoltCallback(cb, [LuaValue.of(Float64(bodyID))])})
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
private func _joltHitsToLua<T>(hits: ArrayList<T>, className: String): LuaValue {
    let n = hits.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(hits[i], className)
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 JoltBackend 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.physics.backend.JoltBackend）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of JoltBackend
 * @param[en] vm The target virtual machine (class table installed at
 * three.physics.backend.JoltBackend)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installJoltBackend(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.backend.JoltBackend")
    // ===== 构造 / 生命周期 =====
    b.constructor {_ => JoltBackend()}
    b.method("initialize") {
        ref, args => [LuaValue.of(
            ref
                .cast<JoltBackend>()
                .initialize(UInt32(prebindInt(args, 0, default: 1024) & 0xFFFFFFFF), prebindAs<Vector3>(args, 1)))]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<JoltBackend>().release())]
    }
    b.method("isInitialized") {
        ref, _ => [LuaValue.of(ref.cast<JoltBackend>().isInitialized())]
    }
    b.method("setGravity") {
        ref, args =>
            ref.cast<JoltBackend>().setGravity(prebindAs<Vector3>(args, 0))
            Array<LuaValue>()
    }
    b.method("optimizeBroadPhase") {
        ref, _ =>
            ref.cast<JoltBackend>().optimizeBroadPhase()
            Array<LuaValue>()
    }
    b.method("backendName") {
        ref, _ => [LuaValue.of(ref.cast<JoltBackend>().backendName())]
    }
    // ===== 刚体 =====
    b.method("createBody") {
        ref, args => [physicsBodyHandleToLua(ref.cast<JoltBackend>().createBody(prebindAs<PhysicsBodyDesc>(args, 0)))]
    }
    b.method("destroyBody") {
        ref, args =>
            ref.cast<JoltBackend>().destroyBody(prebindAs<PhysicsBodyHandle>(args, 0))
            Array<LuaValue>()
    }
    b.method("isBodyActive") {
        ref, args => [LuaValue.of(ref.cast<JoltBackend>().isBodyActive(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setIsSensor") {
        ref, args =>
            ref.cast<JoltBackend>().setIsSensor(prebindAs<PhysicsBodyHandle>(args, 0), prebindBool(args, 1))
            Array<LuaValue>()
    }
    // ===== transform / 速度 =====
    b.method("setPosition") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setPosition(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getPosition") {
        ref, args => [prebindRegister(ref.cast<JoltBackend>().getPosition(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("setRotation") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setRotation(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Quaternion>(args, 1),
                    physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getRotation") {
        ref, args => [prebindRegister(ref.cast<JoltBackend>().getRotation(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Quaternion")]
    }
    b.method("setLinearVelocity") {
        ref, args =>
            ref.cast<JoltBackend>().setLinearVelocity(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getLinearVelocity") {
        ref, args => [prebindRegister(ref.cast<JoltBackend>().getLinearVelocity(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("setAngularVelocity") {
        ref, args =>
            ref.cast<JoltBackend>().setAngularVelocity(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getAngularVelocity") {
        ref, args => [prebindRegister(ref.cast<JoltBackend>().getAngularVelocity(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Vector3")]
    }
    // ===== 材质 / 运动类型 / 对象层 =====
    b.method("setFriction") {
        ref, args =>
            ref.cast<JoltBackend>().setFriction(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getFriction") {
        ref, args => [LuaValue.of(ref.cast<JoltBackend>().getFriction(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setRestitution") {
        ref, args =>
            ref.cast<JoltBackend>().setRestitution(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getRestitution") {
        ref, args => [LuaValue.of(ref.cast<JoltBackend>().getRestitution(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setMotionType") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setMotionType(prebindAs<PhysicsBodyHandle>(args, 0), physicsMotionTypeFrom(prebindInt(args, 1)),
                    physicsActivationFrom(prebindInt(args, 2, default: 0)))
            Array<LuaValue>()
    }
    b.method("getMotionType") {
        ref, args => [LuaValue.of(
            physicsMotionTypeValue(ref.cast<JoltBackend>().getMotionType(prebindAs<PhysicsBodyHandle>(args, 0))))]
    }
    b.method("setObjectLayer") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setObjectLayer(prebindAs<PhysicsBodyHandle>(args, 0), physicsLayerFrom(prebindInt(args, 1)))
            Array<LuaValue>()
    }
    b.method("getObjectLayer") {
        ref, args => [LuaValue.of(
            physicsLayerValue(ref.cast<JoltBackend>().getObjectLayer(prebindAs<PhysicsBodyHandle>(args, 0))))]
    }
    // ===== 步进（末尾抽干传感器回调） =====
    b.method("update") {
        ref, args =>
            let err = ref
                .cast<JoltBackend>()
                .update(Float32(prebindNum(args, 0, default: 1.0 / 60.0)), Int32(prebindInt(args, 1, default: 1)))
            _joltSensorTasks.drain()
            [LuaValue.of(Float64(err))]
    }
    // ===== 查询 =====
    b.method("raycast") {
        ref, args => [LuaValue.of(
            ref
                .cast<JoltBackend>()
                .raycast(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<PhysicsRayHit>(args, 2)))]
    }
    b.method("raycastAll") {
        ref, args =>
            let hits = ArrayList<PhysicsRayHit>()
            ref.cast<JoltBackend>().raycastAll(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), hits)
            [_joltHitsToLua<PhysicsRayHit>(hits, "three.physics.common.PhysicsRayHit")]
    }
    b.method("collidePoint") {
        ref, args =>
            let hits = ArrayList<PhysicsPointHit>()
            ref.cast<JoltBackend>().collidePoint(prebindAs<Vector3>(args, 0), hits)
            [_joltHitsToLua<PhysicsPointHit>(hits, "three.physics.common.PhysicsPointHit")]
    }
    b.method("collideShape") {
        ref, args =>
            let hits = ArrayList<PhysicsShapeHit>()
            ref
                .cast<JoltBackend>()
                .collideShape(prebindAs<PhysicsShape>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Quaternion>(args, 2), hits)
            [_joltHitsToLua<PhysicsShapeHit>(hits, "three.physics.common.PhysicsShapeHit")]
    }
    b.method("castShape") {
        ref, args =>
            let hits = ArrayList<PhysicsShapeHit>()
            ref
                .cast<JoltBackend>()
                .castShape(prebindAs<PhysicsShape>(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Quaternion>(args, 2),
                    prebindAs<Vector3>(args, 3), hits)
            [_joltHitsToLua<PhysicsShapeHit>(hits, "three.physics.common.PhysicsShapeHit")]
    }
    // ===== 传感器监听 =====
    b.method("setContactListener") {
        ref, args =>
            let backend = ref.cast<JoltBackend>()
            if (args.size < 1 || args[0].isNil || !args[0].isTable) {
                backend.setContactListener(Option<IPhysicsSensorListener>.None)
            } else {
                let t = LuaTable(vm: vm, ref: Int32(args[0].refId()))
                backend.setContactListener(
                    Some(
                        _LuaJoltSensorListener(prebindOptCallbackOf(vm, t.get("onContact")),
                            prebindOptCallbackOf(vm, t.get("onBodyActivated")),
                            prebindOptCallbackOf(vm, t.get("onBodyDeactivated")))))
            }
            Array<LuaValue>()
    }
    b.method("pumpCallbacks") {
        _, _ => [LuaValue.of(_joltSensorTasks.drain())]
    }
    // ===== 力 / 力矩 / 冲量 / 质量 / 重力因子 =====
    b.method("addForce") {
        ref, args =>
            ref.cast<JoltBackend>().addForce(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addForceAtPosition") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .addForceAtPosition(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Vector3>(args, 2))
            Array<LuaValue>()
    }
    b.method("addTorque") {
        ref, args =>
            ref.cast<JoltBackend>().addTorque(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addImpulse") {
        ref, args =>
            ref.cast<JoltBackend>().addImpulse(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("addAngularImpulse") {
        ref, args =>
            ref.cast<JoltBackend>().addAngularImpulse(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("getMass") {
        ref, args => [LuaValue.of(ref.cast<JoltBackend>().getMass(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("setMass") {
        ref, args =>
            ref.cast<JoltBackend>().setMass(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getInverseInertia") {
        ref, args => [prebindRegister(ref.cast<JoltBackend>().getInverseInertia(prebindAs<PhysicsBodyHandle>(args, 0)),
            "three.core.math.Matrix4")]
    }
    b.method("setGravityFactor") {
        ref, args =>
            ref.cast<JoltBackend>().setGravityFactor(prebindAs<PhysicsBodyHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getGravityFactor") {
        ref, args => [LuaValue.of(ref.cast<JoltBackend>().getGravityFactor(prebindAs<PhysicsBodyHandle>(args, 0)))]
    }
    b.method("moveKinematic") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .moveKinematic(prebindAs<PhysicsBodyHandle>(args, 0), prebindAs<Vector3>(args, 1),
                    prebindAs<Quaternion>(args, 2), Float32(prebindNum(args, 3)))
            Array<LuaValue>()
    }
    // ===== 约束 =====
    b.method("createConstraint") {
        ref, args => [physicsConstraintHandleToLua(
            ref
                .cast<JoltBackend>()
                .createConstraint(prebindAs<PhysicsConstraintDesc>(args, 0), prebindAs<PhysicsBodyHandle>(args, 1),
                    prebindAs<PhysicsBodyHandle>(args, 2)))]
    }
    b.method("destroyConstraint") {
        ref, args =>
            ref.cast<JoltBackend>().destroyConstraint(prebindAs<PhysicsConstraintHandle>(args, 0))
            Array<LuaValue>()
    }
    b.method("isConstraintEnabled") {
        ref, args => [LuaValue.of(
            ref.cast<JoltBackend>().isConstraintEnabled(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.method("setConstraintEnabled") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintEnabled(prebindAs<PhysicsConstraintHandle>(args, 0), prebindBool(args, 1, default: true))
            Array<LuaValue>()
    }
    b.method("setConstraintMotorState") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintMotorState(prebindAs<PhysicsConstraintHandle>(args, 0),
                    physicsMotorStateFrom(prebindInt(args, 1)))
            Array<LuaValue>()
    }
    b.method("setConstraintTargetAngularVelocity") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintTargetAngularVelocity(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setConstraintTargetAngle") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintTargetAngle(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getConstraintCurrentAngle") {
        ref, args => [LuaValue.of(
            ref.cast<JoltBackend>().getConstraintCurrentAngle(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.method("setSliderTargetVelocity") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setSliderTargetVelocity(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setSliderTargetPosition") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setSliderTargetPosition(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("getSliderCurrentPosition") {
        ref, args => [LuaValue.of(
            ref.cast<JoltBackend>().getSliderCurrentPosition(prebindAs<PhysicsConstraintHandle>(args, 0)))]
    }
    b.method("setConstraintLimits") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintLimits(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1),
                    prebindNum(args, 2))
            Array<LuaValue>()
    }
    b.method("setConstraintMaxFriction") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setConstraintMaxFriction(prebindAs<PhysicsConstraintHandle>(args, 0), prebindNum(args, 1))
            Array<LuaValue>()
    }
    b.method("setSixDOFMotorState") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setSixDOFMotorState(prebindAs<PhysicsConstraintHandle>(args, 0), prebindInt(args, 1),
                    physicsMotorStateFrom(prebindInt(args, 2)))
            Array<LuaValue>()
    }
    b.method("setSixDOFTargetPosition") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setSixDOFTargetPosition(prebindAs<PhysicsConstraintHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.method("setSixDOFTargetVelocity") {
        ref, args =>
            ref
                .cast<JoltBackend>()
                .setSixDOFTargetVelocity(prebindAs<PhysicsConstraintHandle>(args, 0), prebindAs<Vector3>(args, 1))
            Array<LuaValue>()
    }
    b.install(vm)
}
