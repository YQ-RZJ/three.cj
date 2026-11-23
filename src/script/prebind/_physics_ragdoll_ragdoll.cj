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
 * @file[zh-cn] physics_ragdoll_ragdoll 布娃娃的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 PhysicsSkeleton / PhysicsSkeletonPose / RagdollJoint /
 * RagdollPartSettings / PhysicsRagdollSettings / PhysicsRagdoll 绑定为 Lua 类型
 * @explain[zh-cn] 骨骼（addJoint / jointName / jointParentIndex / jointCount / release）、
 * 姿态（setJointState / getJointState 返回 平移+旋转 两个值 / setJointMatrix /
 * getJointMatrix / calculateJointMatrices / calculateJointStates / release）、
 * 关节（11 个字段 + 静态 cone 工厂）、部件（shape 只读，position / rotation /
 * motionType / layer / mass / toParent 可读写）、设置（stabilize /
 * disableParentChildCollisions / minSeparationDistance + createRagdoll）、
 * 运行时布娃娃（skeleton / bodyCount / constraintCount / addToWorld / removeFromWorld /
 * activate / isActive / setPose / getPose / driveToPoseUsingMotors /
 * driveToPoseUsingKinematics / getBodyID / getRootTransform（返回 位置+旋转 两个值）/
 * release）。
 *
 * @file[en] physics_ragdoll_ragdoll  Lua bindings of the ragdoll (three.script.prebind)
 * @brief[en] Binds PhysicsSkeleton / PhysicsSkeletonPose / RagdollJoint /
 * RagdollPartSettings / PhysicsRagdollSettings / PhysicsRagdoll as Lua types
 * @explain[en] Skeleton (addJoint / jointName / jointParentIndex / jointCount / release),
 * pose (setJointState / getJointState returning translation+rotation as two values /
 * setJointMatrix / getJointMatrix / calculateJointMatrices / calculateJointStates / release),
 * joint (11 fields + the static cone factory), part (shape read-only; position / rotation /
 * motionType / layer / mass / toParent read-write), settings (stabilize /
 * disableParentChildCollisions / minSeparationDistance + createRagdoll) and the runtime
 * ragdoll (skeleton / bodyCount / constraintCount / addToWorld / removeFromWorld / activate /
 * isActive / setPose / getPose / driveToPoseUsingMotors / driveToPoseUsingKinematics /
 * getBodyID / getRootTransform returning position+rotation as two values / release).
 */
package three.script.prebind

import three.physics.ragdoll.*
import three.physics.world.PhysicsWorld
import three.physics._interfaces.*
import three.physics.common.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PhysicsSkeleton 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsSkeleton
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsSkeleton(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.PhysicsSkeleton")
    b.constructor {_ => PhysicsSkeleton()}
    b.method("addJoint") {
        ref, args => [LuaValue.of(
            ref.cast<PhysicsSkeleton>().addJoint(prebindStr(args, 0), parentIndex: prebindInt(args, 1, default: -1)))]
    }
    b.property("jointCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSkeleton>().jointCount)}))
    b.method("jointName") {
        ref, args => [LuaValue.of(ref.cast<PhysicsSkeleton>().jointName(prebindInt(args, 0)))]
    }
    b.method("jointParentIndex") {
        ref, args => [LuaValue.of(ref.cast<PhysicsSkeleton>().jointParentIndex(prebindInt(args, 0)))]
    }
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSkeleton>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsSkeleton>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsSkeletonPose 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsSkeletonPose
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsSkeletonPose(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.PhysicsSkeletonPose")
    b.constructor {
        args => PhysicsSkeletonPose(prebindAs<PhysicsSkeleton>(args, 0))
    }
    b.property("jointCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSkeletonPose>().jointCount)}))
    b.method("setJointState") {
        ref, args =>
            ref
                .cast<PhysicsSkeletonPose>()
                .setJointState(prebindInt(args, 0), prebindAs<Vector3>(args, 1), prebindAs<Quaternion>(args, 2))
            Array<LuaValue>()
    }
    b.method("getJointState") {
        ref, args =>
            let (pos, rot) = ref.cast<PhysicsSkeletonPose>().getJointState(prebindInt(args, 0))
            [prebindRegister(pos, "three.core.math.Vector3"), prebindRegister(rot, "three.core.math.Quaternion")]
    }
    b.method("setJointMatrix") {
        ref, args =>
            ref.cast<PhysicsSkeletonPose>().setJointMatrix(prebindInt(args, 0), prebindAs<Matrix4>(args, 1))
            Array<LuaValue>()
    }
    b.method("getJointMatrix") {
        ref, args => [prebindRegister(ref.cast<PhysicsSkeletonPose>().getJointMatrix(prebindInt(args, 0)),
            "three.core.math.Matrix4")]
    }
    b.method("calculateJointMatrices") {
        ref, _ =>
            ref.cast<PhysicsSkeletonPose>().calculateJointMatrices()
            Array<LuaValue>()
    }
    b.method("calculateJointStates") {
        ref, _ =>
            ref.cast<PhysicsSkeletonPose>().calculateJointStates()
            Array<LuaValue>()
    }
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsSkeletonPose>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsSkeletonPose>().release())]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RagdollJoint 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RagdollJoint
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRagdollJoint(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.RagdollJoint")
    b.constructor {_ => RagdollJoint()}
    b.property("position1", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().position1, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().position1 = prebindAsValue<Vector3>(v)}))
    b.property("position2", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().position2, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().position2 = prebindAsValue<Vector3>(v)}))
    b.property("twistAxis1", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().twistAxis1, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().twistAxis1 = prebindAsValue<Vector3>(v)}))
    b.property("twistAxis2", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().twistAxis2, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().twistAxis2 = prebindAsValue<Vector3>(v)}))
    b.property("planeAxis1", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().planeAxis1, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().planeAxis1 = prebindAsValue<Vector3>(v)}))
    b.property("planeAxis2", getter: Some({
        ref => prebindRegister(ref.cast<RagdollJoint>().planeAxis2, "three.core.math.Vector3")
    }), setter: Some({ref, v => ref.cast<RagdollJoint>().planeAxis2 = prebindAsValue<Vector3>(v)}))
    b.property("normalHalfConeAngle", getter: Some({
        ref => LuaValue.of(Float64(ref.cast<RagdollJoint>().normalHalfConeAngle))
    }), setter: Some({
        ref, v => ref.cast<RagdollJoint>().normalHalfConeAngle = Float32(v.numberValue())
    }))
    b.property("planeHalfConeAngle", getter: Some({
        ref => LuaValue.of(Float64(ref.cast<RagdollJoint>().planeHalfConeAngle))
    }), setter: Some({
        ref, v => ref.cast<RagdollJoint>().planeHalfConeAngle = Float32(v.numberValue())
    }))
    b.property("twistMinAngle", getter: Some({ref => LuaValue.of(Float64(ref.cast<RagdollJoint>().twistMinAngle))}),
        setter: Some({
            ref, v => ref.cast<RagdollJoint>().twistMinAngle = Float32(v.numberValue())
        }))
    b.property("twistMaxAngle", getter: Some({ref => LuaValue.of(Float64(ref.cast<RagdollJoint>().twistMaxAngle))}),
        setter: Some({
            ref, v => ref.cast<RagdollJoint>().twistMaxAngle = Float32(v.numberValue())
        }))
    b.property("maxFrictionTorque", getter: Some({
        ref => LuaValue.of(Float64(ref.cast<RagdollJoint>().maxFrictionTorque))
    }), setter: Some({
        ref, v => ref.cast<RagdollJoint>().maxFrictionTorque = Float32(v.numberValue())
    }))
    b.staticMethod("cone") {
        args => [prebindRegister(
            RagdollJoint.cone(prebindAs<Vector3>(args, 0), prebindAs<Vector3>(args, 1), Float32(prebindNum(args, 2)),
                twistMin: Float32(prebindNum(args, 3, default: -3.1415927)),
                twistMax: Float32(prebindNum(args, 4, default: 3.1415927)),
                maxFrictionTorque: Float32(prebindNum(args, 5))), "three.physics.ragdoll.RagdollJoint")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 RagdollPartSettings 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RagdollPartSettings
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRagdollPartSettings(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.RagdollPartSettings")
    b.constructor {
        args =>
            let joint = if (args.size >= 7 && !args[6].isNil) {
                Some(prebindAs<RagdollJoint>(args, 6))
            } else {
                None<RagdollJoint>
            }
            RagdollPartSettings(shape: prebindAs<PhysicsShape>(args, 0), position: prebindVec3(args, 1),
                rotation: prebindQuat(args, 2), motionType: physicsMotionTypeFrom(prebindInt(args, 3, default: 2)),
                layer: UInt32(prebindInt(args, 4, default: 1) & 0xFFFFFFFF), mass: Float32(prebindNum(args, 5)),
                toParent: joint)
    }
    b.property("shape", getter: Some({ref => physicsShapeToLua(ref.cast<RagdollPartSettings>().shape)}))
    b.property("position", getter: Some({
        ref => prebindRegister(ref.cast<RagdollPartSettings>().position, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<RagdollPartSettings>().position = prebindAsValue<Vector3>(v)
    }))
    b.property("rotation", getter: Some({
        ref => prebindRegister(ref.cast<RagdollPartSettings>().rotation, "three.core.math.Quaternion")
    }), setter: Some({
        ref, v => ref.cast<RagdollPartSettings>().rotation = prebindAsValue<Quaternion>(v)
    }))
    b.property("motionType", getter: Some({
        ref => LuaValue.of(physicsMotionTypeValue(ref.cast<RagdollPartSettings>().motionType))
    }), setter: Some({
        ref, v => ref.cast<RagdollPartSettings>().motionType = physicsMotionTypeFrom(v.intValue())
    }))
    b.property("layer", getter: Some({ref => LuaValue.of(Float64(ref.cast<RagdollPartSettings>().layer))}),
        setter: Some({
            ref, v => ref.cast<RagdollPartSettings>().layer = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("mass", getter: Some({ref => LuaValue.of(Float64(ref.cast<RagdollPartSettings>().mass))}),
        setter: Some({ref, v => ref.cast<RagdollPartSettings>().mass = Float32(v.numberValue())}))
    b.property("toParent", getter: Some({
        ref => match (ref.cast<RagdollPartSettings>().toParent) {
            case Some(j) => prebindRegister(j, "three.physics.ragdoll.RagdollJoint")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isNil) {
            ref.cast<RagdollPartSettings>().toParent = None
        } else {
            ref.cast<RagdollPartSettings>().toParent = Some(prebindAsValue<RagdollJoint>(v))
        }
    }))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsRagdollSettings 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsRagdollSettings
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsRagdollSettings(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.PhysicsRagdollSettings")
    b.constructor {
        args => PhysicsRagdollSettings(skeleton: prebindAs<PhysicsSkeleton>(args, 0),
            parts: prebindObjList<RagdollPartSettings>(vm, args, 1).toArray())
    }
    b.property("stabilize", getter: Some({ref => LuaValue.of(ref.cast<PhysicsRagdollSettings>().stabilize)}),
        setter: Some({
            ref, v => ref.cast<PhysicsRagdollSettings>().stabilize = v.boolValue()
        }))
    b.property("disableParentChildCollisions", getter: Some({
        ref => LuaValue.of(ref.cast<PhysicsRagdollSettings>().disableParentChildCollisions)
    }), setter: Some({
        ref, v => ref.cast<PhysicsRagdollSettings>().disableParentChildCollisions = v.boolValue()
    }))
    b.property("minSeparationDistance", getter: Some({
        ref => LuaValue.of(Float64(ref.cast<PhysicsRagdollSettings>().minSeparationDistance))
    }), setter: Some({
        ref, v => ref.cast<PhysicsRagdollSettings>().minSeparationDistance = Float32(v.numberValue())
    }))
    b.method("createRagdoll") {
        ref, args => [prebindRegister(ref.cast<PhysicsRagdollSettings>().createRagdoll(prebindAs<PhysicsWorld>(args, 0)),
            "three.physics.ragdoll.PhysicsRagdoll")]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 PhysicsRagdoll 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PhysicsRagdoll
 * @param[en] vm The target virtual machine
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPhysicsRagdoll(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.physics.ragdoll.PhysicsRagdoll")
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PhysicsRagdoll>().releasable)}))
    b.property("skeleton", getter: Some({
        ref => prebindRegister(ref.cast<PhysicsRagdoll>().skeleton, "three.physics.ragdoll.PhysicsSkeleton")
    }))
    b.property("bodyCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsRagdoll>().bodyCount)}))
    b.property("constraintCount", getter: Some({ref => LuaValue.of(ref.cast<PhysicsRagdoll>().constraintCount)}))
    b.method("addToWorld") {
        ref, args =>
            ref.cast<PhysicsRagdoll>().addToWorld(activation: physicsActivationFrom(prebindInt(args, 0, default: 0)))
            Array<LuaValue>()
    }
    b.method("removeFromWorld") {
        ref, _ =>
            ref.cast<PhysicsRagdoll>().removeFromWorld()
            Array<LuaValue>()
    }
    b.method("activate") {
        ref, _ =>
            ref.cast<PhysicsRagdoll>().activate()
            Array<LuaValue>()
    }
    b.method("isActive") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsRagdoll>().isActive())]
    }
    b.method("setPose") {
        ref, args =>
            ref.cast<PhysicsRagdoll>().setPose(prebindAs<PhysicsSkeletonPose>(args, 0))
            Array<LuaValue>()
    }
    b.method("getPose") {
        ref, args =>
            ref.cast<PhysicsRagdoll>().getPose(prebindAs<PhysicsSkeletonPose>(args, 0))
            Array<LuaValue>()
    }
    b.method("driveToPoseUsingMotors") {
        ref, args =>
            ref.cast<PhysicsRagdoll>().driveToPoseUsingMotors(prebindAs<PhysicsSkeletonPose>(args, 0))
            Array<LuaValue>()
    }
    b.method("driveToPoseUsingKinematics") {
        ref, args =>
            ref
                .cast<PhysicsRagdoll>()
                .driveToPoseUsingKinematics(prebindAs<PhysicsSkeletonPose>(args, 0), Float32(prebindNum(args, 1)))
            Array<LuaValue>()
    }
    b.method("getBodyID") {
        ref, args => [LuaValue.of(Float64(ref.cast<PhysicsRagdoll>().getBodyID(prebindInt(args, 0))))]
    }
    b.method("getRootTransform") {
        ref, _ =>
            let (pos, rot) = ref.cast<PhysicsRagdoll>().getRootTransform()
            [prebindRegister(pos, "three.core.math.Vector3"), prebindRegister(rot, "three.core.math.Quaternion")]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PhysicsRagdoll>().release())]
    }
    b.install(vm)
}
