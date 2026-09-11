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
 * @file[zh-cn] Ragdoll 布娃娃高级封装（three.physics.ragdoll 子包）
 * @brief[zh-cn] 在 jolt4cj 的 Skeleton/SkeletonPose/RagdollSettings/Ragdoll FFI 之上
 * 提供面向 three 的布娃娃物理层
 * @explain[zh-cn] 布娃娃由"骨骼 + 每个骨骼部件的碰撞形状/质量/到父级关节约束"构成，
 * 创建后加入物理世界即可获得带有关节约束的角色残躯模拟，可用于死亡反应、软体角色等。
 * 公开类型（公共 API 不出现任何指针）：
 * - PhysicsSkeleton       ：骨骼（关节名 + 父关节层级）
 * - PhysicsSkeletonPose   ：骨骼姿态（关节位移/旋转/矩阵），用于驱动与读回
 * - RagdollJoint          ：部件到父级的摆动-扭转关节描述（锥角/扭转限位/摩擦）
 * - RagdollPartSettings   ：单个布娃娃部件描述（形状/位姿/运动类型/层/质量/关节）
 * - PhysicsRagdollSettings：布娃娃设置（骨骼 + 部件数组），可创建 PhysicsRagdoll
 * - PhysicsRagdoll        ：运行时布娃娃（加入/移除世界、激活、姿态驱动、根变换读回）
 * 坐标系：全部使用 three 左手系（Vector3/Quaternion/Matrix4），底层 JPH 右手系转换
 * 由模块内部 JoltNative 工具完成。
 * 线程模型：所有运行时 FFI 调用经 PhysicsWorld 物理线程序列化执行（execPhysics）。
 * 典型用法：
 * let skel = PhysicsSkeleton()
 * skel.addJoint("root")
 * skel.addJoint("spine", parentIndex: 0)
 * let parts = [
 *     RagdollPartSettings(shape: PhysicsShape.box(...), position: ...),
 *     RagdollPartSettings(shape: PhysicsShape.sphere(...), position: ...,
 *                         toParent: Some(RagdollJoint.cone(...)))]
 * let settings = PhysicsRagdollSettings(skel, parts)
 * let ragdoll = settings.createRagdoll(world)
 * ragdoll.addToWorld()
 * // 每帧可用 pose 驱动：ragdoll.driveToPoseUsingMotors(pose)
 *
 * @file[en] Ragdoll high-level wrapper (three.physics.ragdoll sub-package)
 * @brief[en] Provides a three-oriented ragdoll physics layer on top of the jolt4cj
 * Skeleton/SkeletonPose/RagdollSettings/Ragdoll FFI
 * @explain[en] A ragdoll consists of a "skeleton + per-bone collision shape/mass/parent
 * joint constraint"; once created and added to the physics world it simulates a jointed
 * character body, useful for death reactions and soft characters. All public APIs use
 * three left-handed math types (no pointers). Runtime FFI calls are serialized onto the
 * PhysicsWorld physics thread.
 */
package three.physics.ragdoll

import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.Logger

// =============================================================================
// 内部枚举映射辅助
// =============================================================================

/// three 运动类型 → JPH MotionType 数值（Static=0/Kinematic=1/Dynamic=2，顺序一致）
internal func ragdollMotionTypeValue(m: PhysicsMotionType): UInt32 {
    match (m) {
        case PhysicsMotionType.Static => 0
        case PhysicsMotionType.Kinematic => 1
        case PhysicsMotionType.Dynamic => 2
    }
}

/// three 激活策略 → JPH Activation 数值（Activate=0/DontActivate=1）
internal func ragdollActivationValue(a: PhysicsActivation): UInt32 {
    match (a) {
        case PhysicsActivation.Activate => 0
        case PhysicsActivation.DontActivate => 1
    }
}

// =============================================================================
// PhysicsSkeleton 骨骼
// =============================================================================

/**
 * @brief[zh-cn] 布娃娃骨骼：关节层级（名称 + 父关节索引）
 * @explain[zh-cn] 关节必须按"父先于子"的顺序添加（Jolt 要求父关节索引小于子关节）。
 * 底层 JPH_Skeleton 句柄由本类管理，dispose() 释放；布娃娃设置/姿态会对骨骼
 * 持有引用计数，dispose 后仍被引用的骨骼不会被真正销毁。
 *
 * @brief[en] Ragdoll skeleton: joint hierarchy (name + parent joint index)
 * @explain[en] Joints must be added parent-before-child (Jolt requires parent indices to
 * be smaller than child indices). The underlying JPH_Skeleton handle is managed by this
 * class and released in dispose(); ragdoll settings/poses hold reference counts on the
 * skeleton, so a disposed skeleton stays alive while referenced.
 */
public class PhysicsSkeleton {
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    private var _disposed: Bool = false

    /**
     * @brief[zh-cn] 创建空骨骼
     *
     * @brief[en] Creates an empty skeleton
     */
    public init() {
        this._handle = JPH_Skeleton_Create_cj()
    }

    /**
     * @brief[zh-cn] 添加一个关节
     * @param[zh-cn] name 关节名称（唯一，用于姿态映射/调试）
     * parentIndex 父关节索引；-1（默认）表示根关节
     * @return[zh-cn] 新关节的索引
     *
     * @brief[en] Adds a joint
     * @param[en] name The joint name (unique; used for pose mapping/debug)
     * parentIndex The parent joint index; -1 (default) means a root joint
     * @return[en] The index of the new joint
     */
    public func addJoint(name: String, parentIndex!: Int64 = -1): Int64 {
        if (this._disposed || this._handle.isNull()) {
            return -1
        }
        let nameCs = unsafe { LibC.mallocCString(name) }
        let namePtr = nameCs.getChars()
        let idx: UInt32 = unsafe {
            if (parentIndex >= 0) {
                JPH_Skeleton_AddJoint2_cj(this._handle, namePtr, Int32(parentIndex))
            } else {
                JPH_Skeleton_AddJoint_cj(this._handle, namePtr)
            }
        }
        unsafe { LibC.free(nameCs) }
        return Int64(idx)
    }

    /**
     * @brief[zh-cn] 关节数量
     *
     * @brief[en] The number of joints
     */
    public prop jointCount: Int64 {
        get() {
            if (this._disposed || this._handle.isNull()) {
                return 0
            }
            return Int64(JPH_Skeleton_GetJointCount_cj(this._handle))
        }
    }

    /**
     * @brief[zh-cn] 获取指定关节的名称
     * @param[zh-cn] index 关节索引
     * @return[zh-cn] 关节名称；索引无效返回空串
     *
     * @brief[en] Gets the name of a joint
     * @param[en] index The joint index
     * @return[en] The joint name; an empty string for an invalid index
     */
    public func jointName(index: Int64): String {
        if (this._disposed || this._handle.isNull() || index < 0) {
            return ""
        }
        let j = unsafe { LibC.malloc<JPHSkeletonJoint>() }
        JPH_Skeleton_GetJoint_cj(this._handle, Int32(index), j)
        var result = ""
        unsafe {
            let joint = j.read()
            if (!joint.name.isNull()) {
                let cs = CString(joint.name)
                result = cs.toString()
            }
            LibC.free(j)
        }
        return result
    }

    /**
     * @brief[zh-cn] 获取指定关节的父关节索引
     * @param[zh-cn] index 关节索引
     * @return[zh-cn] 父关节索引；根关节或无效索引返回 -1
     *
     * @brief[en] Gets the parent joint index of a joint
     * @param[en] index The joint index
     * @return[en] The parent joint index; -1 for a root joint or invalid index
     */
    public func jointParentIndex(index: Int64): Int64 {
        if (this._disposed || this._handle.isNull() || index < 0) {
            return -1
        }
        let j = unsafe { LibC.malloc<JPHSkeletonJoint>() }
        JPH_Skeleton_GetJoint_cj(this._handle, Int32(index), j)
        var parent = -1
        unsafe {
            parent = Int64(j.read().parentJointIndex)
            LibC.free(j)
        }
        return parent
    }

    /**
     * @brief[zh-cn] 释放底层骨骼句柄
     *
     * @brief[en] Releases the underlying skeleton handle
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._handle.isNull()) {
            JPH_Skeleton_Destroy_cj(this._handle)
            this._handle = CPointer<Unit>()
        }
    }

    /// 模块内部：获取原生句柄（同包高级封装使用，不对外公开）
    internal func nativeHandle(): CPointer<Unit> {
        return this._handle
    }
}

// =============================================================================
// PhysicsSkeletonPose 骨骼姿态
// =============================================================================

/**
 * @brief[zh-cn] 骨骼姿态：每个关节的局部位移/旋转（或关节矩阵）
 * @explain[zh-cn] 姿态用于把动画结果写入布娃娃（setPose / driveToPose*），
 * 也用于从布娃娃读回当前姿态（getPose）。关节状态为相对父关节的局部变换。
 * 坐标使用 three 左手系，底层自动转换。
 *
 * @brief[en] Skeleton pose: per-joint local translation/rotation (or joint matrices)
 * @explain[en] A pose is used to write animation results into a ragdoll (setPose /
 * driveToPose*) and to read the current ragdoll pose back (getPose). Joint states are
 * local transforms relative to the parent joint. Uses three left-handed coordinates;
 * conversion is automatic.
 */
public class PhysicsSkeletonPose {
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    private var _disposed: Bool = false

    /**
     * @brief[zh-cn] 创建关联指定骨骼的姿态
     * @param[zh-cn] skeleton 目标骨骼
     *
     * @brief[en] Creates a pose associated with the given skeleton
     * @param[en] skeleton The target skeleton
     */
    public init(skeleton: PhysicsSkeleton) {
        this._handle = JPH_SkeletonPose_Create_cj()
        if (!this._handle.isNull()) {
            JPH_SkeletonPose_SetSkeleton_cj(this._handle, skeleton.nativeHandle())
        }
    }

    /**
     * @brief[zh-cn] 根偏移（整个姿态相对世界的平移）
     *
     * @brief[en] The root offset (world translation of the whole pose)
     */
    public mut prop rootOffset: Vector3 {
        get() {
            if (this._handle.isNull()) {
                return Vector3()
            }
            let buf = unsafe { LibC.malloc<JPHVec3>() }
            JPH_SkeletonPose_GetRootOffset_cj(this._handle, buf)
            let v = JoltNative.readVec3(buf)
            unsafe { LibC.free(buf) }
            return v
        }
        set(v) {
            if (this._handle.isNull()) {
                return
            }
            let buf = JoltNative.allocVec3(v)
            JPH_SkeletonPose_SetRootOffset_cj(this._handle, buf)
            unsafe { LibC.free(buf) }
        }
    }

    /**
     * @brief[zh-cn] 姿态中的关节数量
     *
     * @brief[en] The number of joints in the pose
     */
    public prop jointCount: Int64 {
        get() {
            if (this._disposed || this._handle.isNull()) {
                return 0
            }
            return Int64(JPH_SkeletonPose_GetJointCount_cj(this._handle))
        }
    }

    /**
     * @brief[zh-cn] 设置指定关节的局部状态
     * @param[zh-cn] index 关节索引
     * translation 相对父关节的局部位移（three 左手系）
     * rotation 相对父关节的局部旋转
     *
     * @brief[en] Sets the local state of a joint
     * @param[en] index The joint index
     * translation Local translation relative to the parent joint (three left-handed)
     * rotation Local rotation relative to the parent joint
     */
    public func setJointState(index: Int64, translation: Vector3, rotation: Quaternion): Unit {
        if (this._handle.isNull()) {
            return
        }
        let tBuf = JoltNative.allocVec3(translation)
        let rBuf = JoltNative.allocQuat(rotation)
        JPH_SkeletonPose_SetJointState_cj(this._handle, Int32(index), tBuf, rBuf)
        unsafe {
            LibC.free(tBuf);
            LibC.free(rBuf)
        }
    }

    /**
     * @brief[zh-cn] 读取指定关节的局部状态
     * @param[zh-cn] index 关节索引
     * @return[zh-cn] (局部位移, 局部旋转) 元组
     *
     * @brief[en] Reads the local state of a joint
     * @param[en] index The joint index
     * @return[en] A (local translation, local rotation) tuple
     */
    public func getJointState(index: Int64): (Vector3, Quaternion) {
        if (this._handle.isNull()) {
            return (Vector3(), Quaternion())
        }
        let tBuf = unsafe { LibC.malloc<JPHVec3>() }
        let rBuf = unsafe { LibC.malloc<JPHQuat>() }
        JPH_SkeletonPose_GetJointState_cj(this._handle, Int32(index), tBuf, rBuf)
        let t = JoltNative.readVec3(tBuf)
        let r = JoltNative.readQuat(rBuf)
        unsafe {
            LibC.free(tBuf);
            LibC.free(rBuf)
        }
        return (t, r)
    }

    /**
     * @brief[zh-cn] 设置指定关节的局部矩阵
     * @param[zh-cn] index 关节索引
     * matrix 局部变换矩阵（three 左手系列主序）
     *
     * @brief[en] Sets the local matrix of a joint
     * @param[en] index The joint index
     * matrix The local transform matrix (three left-handed, column-major)
     */
    public func setJointMatrix(index: Int64, matrix: Matrix4): Unit {
        if (this._handle.isNull()) {
            return
        }
        let buf = JoltNative.allocMat4(matrix)
        JPH_SkeletonPose_SetJointMatrix_cj(this._handle, Int32(index), buf)
        unsafe { LibC.free(buf) }
    }

    /**
     * @brief[zh-cn] 读取指定关节的局部矩阵
     * @param[zh-cn] index 关节索引
     * @return[zh-cn] 局部变换矩阵（three 左手系）
     *
     * @brief[en] Reads the local matrix of a joint
     * @param[en] index The joint index
     * @return[en] The local transform matrix (three left-handed)
     */
    public func getJointMatrix(index: Int64): Matrix4 {
        if (this._handle.isNull()) {
            return Matrix4()
        }
        let buf = unsafe { LibC.malloc<JPHMat4>() }
        JPH_SkeletonPose_GetJointMatrix_cj(this._handle, Int32(index), buf)
        let m = JoltNative.readMat4(buf)
        unsafe { LibC.free(buf) }
        return m
    }

    /**
     * @brief[zh-cn] 由关节状态（位移/旋转）计算全部关节矩阵
     *
     * @brief[en] Calculates all joint matrices from the joint states (translation/rotation)
     */
    public func calculateJointMatrices(): Unit {
        if (this._handle.isNull()) {
            return
        }
        JPH_SkeletonPose_CalculateJointMatrices_cj(this._handle)
    }

    /**
     * @brief[zh-cn] 由关节矩阵反算全部关节状态（位移/旋转）
     *
     * @brief[en] Calculates all joint states (translation/rotation) from the joint matrices
     */
    public func calculateJointStates(): Unit {
        if (this._handle.isNull()) {
            return
        }
        JPH_SkeletonPose_CalculateJointStates_cj(this._handle)
    }

    /**
     * @brief[zh-cn] 释放底层姿态句柄
     *
     * @brief[en] Releases the underlying pose handle
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._handle.isNull()) {
            JPH_SkeletonPose_Destroy_cj(this._handle)
            this._handle = CPointer<Unit>()
        }
    }

    /// 模块内部：获取原生句柄
    internal func nativeHandle(): CPointer<Unit> {
        return this._handle
    }
}

// =============================================================================
// RagdollJoint 部件到父级的摆动-扭转关节
// =============================================================================

/**
 * @brief[zh-cn] 布娃娃部件到父部件的摆动-扭转关节描述
 * @explain[zh-cn] 对应 JPH SwingTwistConstraintSettings（局部到质心空间）：
 * - 锚点 position1/position2：分别在子/父部件质心空间中的关节位置
 * - twistAxis：扭转轴（沿骨骼长度方向，如四肢指向）
 * - normalHalfConeAngle/planeHalfConeAngle：两个方向的摆动半锥角（弧度），
 *   两者相等时为锥形限位，不等时为金字塔形限位
 * - twistMinAngle/twistMaxAngle：绕扭转轴的扭转限位（弧度）
 * - maxFrictionTorque：最大摩擦扭矩（维持姿态的阻力）
 *
 * @brief[en] Swing-twist joint description from a ragdoll part to its parent
 * @explain[en] Corresponds to JPH SwingTwistConstraintSettings (local-to-COM space):
 * - anchors position1/position2: joint positions in child/parent body COM space
 * - twistAxis: the twist axis (along the bone direction, e.g. limb direction)
 * - normalHalfConeAngle/planeHalfConeAngle: swing half-cone angles (radians) in the two
 *   directions; equal values give a cone limit, unequal values a pyramid limit
 * - twistMinAngle/twistMaxAngle: twist limits around the twist axis (radians)
 * - maxFrictionTorque: maximum friction torque (resistance holding the pose)
 */
public class RagdollJoint {
    /** @brief[zh-cn] 子部件质心空间中的锚点 */
    /** @brief[en] Anchor in the child part's COM space */
    public var position1: Vector3 = Vector3()
    /** @brief[zh-cn] 父部件质心空间中的锚点 */
    /** @brief[en] Anchor in the parent part's COM space */
    public var position2: Vector3 = Vector3()
    /** @brief[zh-cn] 子部件扭转轴 */
    /** @brief[en] Twist axis on the child part */
    public var twistAxis1: Vector3 = Vector3(0.0, 1.0, 0.0)
    /** @brief[zh-cn] 父部件扭转轴 */
    /** @brief[en] Twist axis on the parent part */
    public var twistAxis2: Vector3 = Vector3(0.0, 1.0, 0.0)
    /** @brief[zh-cn] 子部件平面轴 */
    /** @brief[en] Plane axis on the child part */
    public var planeAxis1: Vector3 = Vector3(0.0, 0.0, 1.0)
    /** @brief[zh-cn] 父部件平面轴 */
    /** @brief[en] Plane axis on the parent part */
    public var planeAxis2: Vector3 = Vector3(0.0, 0.0, 1.0)
    /** @brief[zh-cn] 法线方向摆动半锥角（弧度） */
    /** @brief[en] Normal-direction swing half-cone angle (radians) */
    public var normalHalfConeAngle: Float32 = 0.0f32
    /** @brief[zh-cn] 平面方向摆动半锥角（弧度） */
    /** @brief[en] Plane-direction swing half-cone angle (radians) */
    public var planeHalfConeAngle: Float32 = 0.0f32
    /** @brief[zh-cn] 最小扭转角（弧度） */
    /** @brief[en] Minimum twist angle (radians) */
    public var twistMinAngle: Float32 = -3.1415927f32
    /** @brief[zh-cn] 最大扭转角（弧度） */
    /** @brief[en] Maximum twist angle (radians) */
    public var twistMaxAngle: Float32 = 3.1415927f32
    /** @brief[zh-cn] 最大摩擦扭矩 */
    /** @brief[en] Maximum friction torque */
    public var maxFrictionTorque: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 创建关节描述
     *
     * @brief[en] Creates a joint description
     */
    public init() {}

    /**
     * @brief[zh-cn] 便捷工厂：锥形摆动关节（两个方向摆动范围相同）
     * @param[zh-cn] anchor 关节锚点（子/父质心空间共用同一锚点）
     * twistAxis 扭转轴（沿骨骼方向）
     * halfConeAngle 摆动半锥角（弧度）；越小关节越"硬"
     * twistMin 最小扭转角（弧度，默认 -π 自由扭转）
     * twistMax 最大扭转角（弧度，默认 +π）
     * maxFrictionTorque 最大摩擦扭矩（默认 0）
     * @return[zh-cn] 锥形关节描述
     *
     * @brief[en] Convenience factory: a cone swing joint (equal swing range in both directions)
     * @param[en] anchor The joint anchor (same anchor in child/parent COM space)
     * twistAxis The twist axis (along the bone direction)
     * halfConeAngle The swing half-cone angle (radians); smaller is stiffer
     * twistMin Minimum twist angle (radians, default -π free twist)
     * twistMax Maximum twist angle (radians, default +π)
     * maxFrictionTorque Maximum friction torque (default 0)
     * @return[en] A cone joint description
     */
    public static func cone(anchor: Vector3, twistAxis: Vector3, halfConeAngle: Float32,
        twistMin!: Float32 = -3.1415927f32, twistMax!: Float32 = 3.1415927f32, maxFrictionTorque!: Float32 = 0.0f32): RagdollJoint {
        let j = RagdollJoint()
        j.position1 = anchor
        j.position2 = anchor
        j.twistAxis1 = twistAxis
        j.twistAxis2 = twistAxis
        j.normalHalfConeAngle = halfConeAngle
        j.planeHalfConeAngle = halfConeAngle
        j.twistMinAngle = twistMin
        j.twistMaxAngle = twistMax
        j.maxFrictionTorque = maxFrictionTorque
        return j
    }
}

// =============================================================================
// RagdollPartSettings 布娃娃部件
// =============================================================================

/**
 * @brief[zh-cn] 布娃娃单个部件描述（一个物理刚体 + 可选的到父级关节）
 * @explain[zh-cn] 部件索引与骨骼关节索引一一对应：第 i 个部件对应第 i 个关节。
 * 根部件（索引 0）的 toParent 应为 None；其余部件通过 toParent 连接到父部件。
 *
 * @brief[en] Description of a single ragdoll part (a physics body + optional parent joint)
 * @explain[en] Part indices correspond one-to-one to skeleton joint indices: part i
 * corresponds to joint i. The root part (index 0) should have toParent = None; other
 * parts connect to their parent via toParent.
 */
public class RagdollPartSettings {
    /** @brief[zh-cn] 部件碰撞形状 */
    /** @brief[en] The part collision shape */
    public let shape: PhysicsShape
    /** @brief[zh-cn] 部件初始位置（世界空间，three 左手系） */
    /** @brief[en] The part initial position (world space, three left-handed) */
    public var position: Vector3 = Vector3()
    /** @brief[zh-cn] 部件初始旋转 */
    /** @brief[en] The part initial rotation */
    public var rotation: Quaternion = Quaternion()
    /** @brief[zh-cn] 运动类型（布娃娃部件通常为 Dynamic） */
    /** @brief[en] Motion type (ragdoll parts are usually Dynamic) */
    public var motionType: PhysicsMotionType = PhysicsMotionType.Dynamic
    /** @brief[zh-cn] 对象层（0=NonMoving，1=Moving） */
    /** @brief[en] Object layer (0=NonMoving, 1=Moving) */
    public var layer: UInt32 = 1
    /** @brief[zh-cn] 质量（千克）；<=0 表示由形状自动计算 */
    /** @brief[en] Mass (kg); <=0 means auto-computed from the shape */
    public var mass: Float32 = 0.0f32
    /** @brief[zh-cn] 到父部件的关节；根部件为 None */
    /** @brief[en] The joint to the parent part; None for the root part */
    public var toParent: Option<RagdollJoint> = None

    /**
     * @brief[zh-cn] 创建部件描述
     * @param[zh-cn] shape 碰撞形状（PhysicsShape.box/sphere/capsule/...）
     * position 初始位置
     * rotation 初始旋转
     * motionType 运动类型
     * layer 对象层
     * mass 质量（<=0 自动）
     * toParent 到父级关节
     *
     * @brief[en] Creates a part description
     * @param[en] shape The collision shape (PhysicsShape.box/sphere/capsule/...)
     * position The initial position
     * rotation The initial rotation
     * motionType The motion type
     * layer The object layer
     * mass The mass (<=0 auto)
     * toParent The parent joint
     */
    public init(shape!: PhysicsShape, position!: Vector3 = Vector3(), rotation!: Quaternion = Quaternion(),
        motionType!: PhysicsMotionType = PhysicsMotionType.Dynamic, layer!: UInt32 = 1, mass!: Float32 = 0.0f32,
        toParent!: Option<RagdollJoint> = None) {
        this.shape = shape
        this.position = position
        this.rotation = rotation
        this.motionType = motionType
        this.layer = layer
        this.mass = mass
        this.toParent = toParent
    }
}

// =============================================================================
// PhysicsRagdollSettings 布娃娃设置
// =============================================================================

/**
 * @brief[zh-cn] 布娃娃设置：骨骼 + 部件数组，可创建运行时布娃娃
 * @explain[zh-cn] 本类为纯数据描述，不持有原生句柄；createRagdoll 时在物理线程内
 * 一次性构建原生 RagdollSettings 并实例化 Ragdoll。创建前会自动稳定化
 * （Stabilize，计算各部件质量/惯量使关节处无初始应力）并禁用父子部件碰撞。
 *
 * @brief[en] Ragdoll settings: a skeleton + parts array, able to create a runtime ragdoll
 * @explain[en] This is a pure-data description holding no native handle; createRagdoll
 * builds the native RagdollSettings and instantiates the Ragdoll in one pass on the
 * physics thread. Before creation it automatically stabilizes (Stabilize: computes
 * masses/inertia so joints have no initial stress) and disables parent-child collisions.
 */
public class PhysicsRagdollSettings {
    private let _skeleton: PhysicsSkeleton
    private let _parts: Array<RagdollPartSettings>
    /** @brief[zh-cn] 创建前是否自动稳定化（默认 true） */
    /** @brief[en] Whether to auto-stabilize before creation (default true) */
    public var stabilize: Bool = true
    /** @brief[zh-cn] 是否禁用父子部件间碰撞（默认 true） */
    /** @brief[en] Whether to disable collisions between parent/child parts (default true) */
    public var disableParentChildCollisions: Bool = true
    /** @brief[zh-cn] 父子部件最小分离距离（米） */
    /** @brief[en] Minimum parent-child separation distance (meters) */
    public var minSeparationDistance: Float32 = 0.0f32

    /**
     * @brief[zh-cn] 创建布娃娃设置
     * @param[zh-cn] skeleton 骨骼（部件数须与关节数一致）
     * parts 部件数组（索引与关节索引对应）
     *
     * @brief[en] Creates ragdoll settings
     * @param[en] skeleton The skeleton (part count must equal joint count)
     * parts The parts array (indices correspond to joint indices)
     */
    public init(skeleton!: PhysicsSkeleton, parts!: Array<RagdollPartSettings>) {
        this._skeleton = skeleton
        this._parts = parts
    }

    /**
     * @brief[zh-cn] 在指定物理世界中创建运行时布娃娃
     * @explain[zh-cn] 全部原生构建在物理线程内完成；返回的布娃娃尚未加入世界，
     * 需调用 addToWorld()。失败（如后端非 Jolt、句柄为空）时返回 isValid=false 的对象。
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 运行时布娃娃
     *
     * @brief[en] Creates a runtime ragdoll in the given physics world
     * @explain[en] All native construction happens on the physics thread; the returned
     * ragdoll is not yet added to the world — call addToWorld(). On failure (e.g. a
     * non-Jolt backend or null handles) returns an object with isValid=false.
     * @param[en] world The target physics world
     * @return[en] The runtime ragdoll
     */
    public func createRagdoll(world: PhysicsWorld): PhysicsRagdoll {
        let parts = this._parts
        let skel = this._skeleton
        let doStabilize = this.stabilize
        let doDisableCollision = this.disableParentChildCollisions
        let sepDist = this.minSeparationDistance
        return world.execPhysicsResult<PhysicsRagdoll>({
            =>
            // 闭包在物理线程执行，全程使用表达式风格（块末表达式为返回值），
            // 不在闭包内使用 return（避免非局部返回跨线程）。
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull()) {
                        PhysicsRagdoll(world: world, handle: CPointer<Unit>(), skeleton: skel)
                    } else {
                        let settings = JPH_RagdollSettings_Create_cj()
                        if (settings.isNull()) {
                            PhysicsRagdoll(world: world, handle: CPointer<Unit>(), skeleton: skel)
                        } else {
                            JPH_RagdollSettings_SetSkeleton_cj(settings, skel.nativeHandle())
                            JPH_RagdollSettings_ResizeParts_cj(settings, Int32(parts.size))
                            for (i in 0..parts.size) {
                                let part = parts[i]
                                // 形状：创建原生形状 → 设置给部件 → 释放本地引用（部件内部 AddRef）
                                let shp = jb.createNativeShape(part.shape)
                                if (!shp.isNull()) {
                                    JPH_RagdollSettings_SetPartShape_cj(settings, Int32(i), shp)
                                    jb.destroyNativeShape(shp)
                                }
                                let posBuf = JoltNative.allocVec3(part.position)
                                JPH_RagdollSettings_SetPartPosition_cj(settings, Int32(i), posBuf)
                                unsafe { LibC.free(posBuf) }
                                let rotBuf = JoltNative.allocQuat(part.rotation)
                                JPH_RagdollSettings_SetPartRotation_cj(settings, Int32(i), rotBuf)
                                unsafe { LibC.free(rotBuf) }
                                JPH_RagdollSettings_SetPartMotionType_cj(settings, Int32(i),
                                    ragdollMotionTypeValue(part.motionType))
                                JPH_RagdollSettings_SetPartObjectLayer_cj(settings, Int32(i), part.layer)
                                if (part.mass > 0.0f32) {
                                    JPH_RagdollSettings_SetPartMassProperties_cj(settings, Int32(i), part.mass)
                                }
                                // 到父级的摆动-扭转关节
                                match (part.toParent) {
                                    case Some(joint) =>
                                        let js = unsafe {
                                            LibC.malloc<JPHSwingTwistConstraintSettings>()
                                        }
                                        unsafe {
                                            JPH_SwingTwistConstraintSettings_Init_cj(js)
                                        }
                                        let p1 = JoltNative.allocVec3(joint.position1)
                                        let p2 = JoltNative.allocVec3(joint.position2)
                                        let t1 = JoltNative.allocVec3(joint.twistAxis1)
                                        let t2 = JoltNative.allocVec3(joint.twistAxis2)
                                        let pl1 = JoltNative.allocVec3(joint.planeAxis1)
                                        let pl2 = JoltNative.allocVec3(joint.planeAxis2)
                                        unsafe {
                                            var s = js.read()
                                            // 局部到质心空间 = 0
                                            s.space = 0u32
                                            s.position1 = p1.read()
                                            s.position2 = p2.read()
                                            s.twistAxis1 = t1.read()
                                            s.twistAxis2 = t2.read()
                                            s.planeAxis1 = pl1.read()
                                            s.planeAxis2 = pl2.read()
                                            // 两向锥角相等 → 锥形(0)，否则金字塔形(1)
                                            s.swingType = if (joint.normalHalfConeAngle == joint.planeHalfConeAngle) {
                                                0u32
                                            } else {
                                                1u32
                                            }
                                            s.normalHalfConeAngle = joint.normalHalfConeAngle
                                            s.planeHalfConeAngle = joint.planeHalfConeAngle
                                            s.twistMinAngle = joint.twistMinAngle
                                            s.twistMaxAngle = joint.twistMaxAngle
                                            s.maxFrictionTorque = joint.maxFrictionTorque
                                            js.write(s)
                                        }
                                        unsafe {
                                            LibC.free(p1);
                                            LibC.free(p2)
                                            LibC.free(t1);
                                            LibC.free(t2)
                                            LibC.free(pl1);
                                            LibC.free(pl2)
                                        }
                                        JPH_RagdollSettings_SetPartToParent_cj(settings, Int32(i), CPointer<Unit>(js))
                                        unsafe { LibC.free(js) }
                                    case None => ()
                                }
                            }
                            if (doStabilize) {
                                JPH_RagdollSettings_Stabilize_cj(settings)
                            }
                            if (doDisableCollision) {
                                // jointMatrices 传空：Jolt 内部按骨骼当前姿态计算分离
                                JPH_RagdollSettings_DisableParentChildCollisions_cj(settings, CPointer<JPHMat4>(),
                                    sepDist)
                            }
                            JPH_RagdollSettings_CalculateBodyIndexToConstraintIndex_cj(settings)
                            let ragdollHandle = JPH_RagdollSettings_CreateRagdoll_cj(settings, system, 0u32, 0u64)
                            JPH_RagdollSettings_Destroy_cj(settings)
                            PhysicsRagdoll(world: world, handle: ragdollHandle, skeleton: skel)
                        }
                    }
                case _ =>
                    Logger.warn(["PhysicsRagdoll", "布娃娃仅支持 Jolt 后端"])
                    PhysicsRagdoll(world: world, handle: CPointer<Unit>(), skeleton: skel)
            }
        })
    }
}

// =============================================================================
// PhysicsRagdoll 运行时布娃娃
// =============================================================================

/**
 * @brief[zh-cn] 运行时布娃娃：加入物理世界后进行关节刚体模拟
 * @explain[zh-cn] 由 PhysicsRagdollSettings.createRagdoll 创建。典型流程：
 * addToWorld() → 模拟中可 driveToPoseUsingMotors(pose) 把布娃娃拉向动画姿态、
 * 或 getPose 读回当前姿态 → 不用时 removeFromWorld() + dispose()。
 * 所有运行时调用在物理线程执行；公开 API 仅使用 three 数学类型。
 *
 * @brief[en] Runtime ragdoll: jointed rigid-body simulation once added to the world
 * @explain[en] Created by PhysicsRagdollSettings.createRagdoll. Typical flow:
 * addToWorld() → during simulation driveToPoseUsingMotors(pose) pulls the ragdoll
 * toward an animated pose, or getPose reads the current pose back → when done,
 * removeFromWorld() + dispose(). All runtime calls execute on the physics thread;
 * the public API only uses three math types.
 */
public class PhysicsRagdoll {
    private let _world: PhysicsWorld
    private var _handle: CPointer<Unit> = CPointer<Unit>()
    private let _skeleton: PhysicsSkeleton
    private var _disposed: Bool = false
    // 是否已加入物理世界：销毁前必须先移出，否则 ~Ragdoll 只销毁刚体，
    // ConstraintManager 中残留的关节约束会持有悬空 Body 指针（僵尸约束）
    private var _inWorld: Bool = false

    internal init(world!: PhysicsWorld, handle!: CPointer<Unit>, skeleton!: PhysicsSkeleton) {
        this._world = world
        this._handle = handle
        this._skeleton = skeleton
    }

    /**
     * @brief[zh-cn] 布娃娃是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the ragdoll is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && !this._handle.isNull()
        }
    }

    /**
     * @brief[zh-cn] 布娃娃关联的骨骼
     *
     * @brief[en] The skeleton associated with the ragdoll
     */
    public prop skeleton: PhysicsSkeleton {
        get() {
            this._skeleton
        }
    }

    /**
     * @brief[zh-cn] 刚体（部件）数量
     *
     * @brief[en] The number of rigid bodies (parts)
     */
    public prop bodyCount: Int64 {
        get() {
            if (!this.isValid) {
                return 0
            }
            let h = this._handle
            return this._world.execPhysicsResult<Int64>({
                => Int64(JPH_Ragdoll_GetBodyCount_cj(h))
            })
        }
    }

    /**
     * @brief[zh-cn] 关节约束数量
     *
     * @brief[en] The number of joint constraints
     */
    public prop constraintCount: Int64 {
        get() {
            if (!this.isValid) {
                return 0
            }
            let h = this._handle
            return this._world.execPhysicsResult<Int64>({
                => Int64(JPH_Ragdoll_GetConstraintCount_cj(h))
            })
        }
    }

    /**
     * @brief[zh-cn] 将布娃娃加入物理世界
     * @param[zh-cn] activation 激活策略（默认立即激活）
     *
     * @brief[en] Adds the ragdoll to the physics world
     * @param[en] activation The activation mode (default: activate immediately)
     */
    public func addToWorld(activation!: PhysicsActivation = PhysicsActivation.Activate): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        let act = ragdollActivationValue(activation)
        this._world.execPhysics({
            => JPH_Ragdoll_AddToPhysicsSystem_cj(h, act, 1u8)
        })
        this._inWorld = true
    }

    /**
     * @brief[zh-cn] 将布娃娃从物理世界移除（可再次 addToWorld 加入）
     *
     * @brief[en] Removes the ragdoll from the physics world (it can be re-added with addToWorld)
     */
    public func removeFromWorld(): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        this._world.execPhysics({
            => JPH_Ragdoll_RemoveFromPhysicsSystem_cj(h, 1u8)
        })
        this._inWorld = false
    }

    /**
     * @brief[zh-cn] 激活（唤醒）布娃娃
     *
     * @brief[en] Activates (wakes) the ragdoll
     */
    public func activate(): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        this._world.execPhysics({
            => JPH_Ragdoll_Activate_cj(h, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 布娃娃是否处于活动（未休眠）状态
     *
     * @brief[en] Whether the ragdoll is active (not sleeping)
     */
    public func isActive(): Bool {
        if (!this.isValid) {
            return false
        }
        let h = this._handle
        return this._world.execPhysicsResult<Bool>({
            => JPH_Ragdoll_IsActive_cj(h, 1u8) != 0u8
        })
    }

    /**
     * @brief[zh-cn] 直接设置布娃娃姿态（瞬间到位，不产生速度）
     * @param[zh-cn] pose 目标姿态
     *
     * @brief[en] Sets the ragdoll pose directly (instant, no velocity introduced)
     * @param[en] pose The target pose
     */
    public func setPose(pose: PhysicsSkeletonPose): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        let poseH = pose.nativeHandle()
        this._world.execPhysics({
            => JPH_Ragdoll_SetPose_cj(h, poseH, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 读取布娃娃当前姿态到给定姿态对象
     * @param[zh-cn] pose 输出姿态（调用后其关节状态被填充）
     *
     * @brief[en] Reads the current ragdoll pose into the given pose object
     * @param[en] pose The output pose (its joint states are filled after the call)
     */
    public func getPose(pose: PhysicsSkeletonPose): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        let poseH = pose.nativeHandle()
        this._world.execPhysics({
            => JPH_Ragdoll_GetPose_cj(h, poseH, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 用关节电机把布娃娃驱动向目标姿态（产生力矩，适合活动角色）
     * @param[zh-cn] pose 目标姿态
     *
     * @brief[en] Drives the ragdoll toward the target pose using joint motors (applies torque; suited to active characters)
     * @param[en] pose The target pose
     */
    public func driveToPoseUsingMotors(pose: PhysicsSkeletonPose): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        let poseH = pose.nativeHandle()
        this._world.execPhysics({
            => JPH_Ragdoll_DriveToPoseUsingMotors_cj(h, poseH)
        })
    }

    /**
     * @brief[zh-cn] 用运动学方式把布娃娃插值驱动到目标姿态（直接搬动刚体，适合死亡动画过渡）
     * @param[zh-cn] pose 目标姿态
     * deltaTime 本帧时间步长（秒）
     *
     * @brief[en] Kinematically drives the ragdoll toward the target pose (moves bodies directly; suited to death-animation blending)
     * @param[en] pose The target pose
     * deltaTime This frame's time step (seconds)
     */
    public func driveToPoseUsingKinematics(pose: PhysicsSkeletonPose, deltaTime: Float32): Unit {
        if (!this.isValid) {
            return
        }
        let h = this._handle
        let poseH = pose.nativeHandle()
        this._world.execPhysics({
            => JPH_Ragdoll_DriveToPoseUsingKinematics_cj(h, poseH, deltaTime, 1u8)
        })
    }

    /**
     * @brief[zh-cn] 获取指定部件刚体的 BodyID
     * @param[zh-cn] bodyIndex 部件索引
     * @return[zh-cn] 刚体 BodyID（可用于碰撞回调/查询）
     *
     * @brief[en] Gets the BodyID of a part's rigid body
     * @param[en] bodyIndex The part index
     * @return[en] The body BodyID (usable in collision callbacks/queries)
     */
    public func getBodyID(bodyIndex: Int64): UInt32 {
        if (!this.isValid) {
            return 0xFFFFFFFF
        }
        let h = this._handle
        return this._world.execPhysicsResult<UInt32>({
            => JPH_Ragdoll_GetBodyID_cj(h, Int32(bodyIndex))
        })
    }

    /**
     * @brief[zh-cn] 获取布娃娃根变换（世界空间位置与旋转）
     * @return[zh-cn] (根位置, 根旋转) 元组（three 左手系）
     *
     * @brief[en] Gets the ragdoll root transform (world-space position and rotation)
     * @return[en] A (root position, root rotation) tuple (three left-handed)
     */
    public func getRootTransform(): (Vector3, Quaternion) {
        if (!this.isValid) {
            return (Vector3(), Quaternion())
        }
        let h = this._handle
        return this._world.execPhysicsResult<(Vector3, Quaternion)>(
            {
                =>
                    let posBuf = unsafe { LibC.malloc<JPHVec3>() }
                    let rotBuf = unsafe { LibC.malloc<JPHQuat>() }
                    JPH_Ragdoll_GetRootTransform_cj(h, posBuf, rotBuf, 1u8)
                    let pos = JoltNative.readVec3(posBuf)
                    let rot = JoltNative.readQuat(rotBuf)
                    unsafe {
                        LibC.free(posBuf);
                        LibC.free(rotBuf)
                    }
                    (pos, rot)
            }
        )
    }

    /**
     * @brief[zh-cn] 销毁布娃娃（会自动从物理世界移除并释放全部刚体/约束）
     *
     * @brief[en] Destroys the ragdoll (automatically removes it from the world and releases all bodies/constraints)
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        if (!this._handle.isNull()) {
            let h = this._handle
            let inWorld = this._inWorld
            this._world.execPhysics({
                =>
                    // 必须先移出物理世界：JPH Ragdoll 析构只销毁刚体，
                    // 不移除约束；否则 ConstraintManager 残留僵尸约束
                    if (inWorld) {
                        JPH_Ragdoll_RemoveFromPhysicsSystem_cj(h, 1u8)
                    }
                    JPH_Ragdoll_Destroy_cj(h)
            })
            this._handle = CPointer<Unit>()
            this._inWorld = false
        }
    }
}
