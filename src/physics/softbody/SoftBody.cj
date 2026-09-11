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
 * @file[zh-cn] SoftBody 软体高层封装（three.physics.softbody 子包）
 * @brief[zh-cn] 在 jolt4cj 的 SoftBodySharedSettings/SoftBodyCreationSettings FFI 之上，
 * 提供面向 three 的软体物理层
 * @explain[zh-cn] 软体 = 共享设置（顶点 + 面 + 边约束）+ 创建设置 → 生成软体刚体。
 * 软体没有 transform/速度接口（Jolt 限制），渲染网格更新需读取顶点缓冲。
 * 所有公开 API 使用 three 左手系数学类型（无指针暴露），运行时 FFI 调用经
 * PhysicsWorld 序列化到物理线程执行。
 *
 * @file[en] SoftBody high-level wrapper (three.physics.softbody sub-package)
 * @brief[en] Provides a three-oriented soft-body physics layer on top of the
 * jolt4cj SoftBodySharedSettings/SoftBodyCreationSettings FFI
 * @explain[en] A soft body = shared settings (vertices + faces + edge constraints) +
 * creation settings → soft-body rigid body. Jolt soft bodies have no transform/velocity
 * interface; rendering-mesh updates require reading the vertex buffer.
 * All public APIs use three left-handed math types (no pointers exposed). Runtime FFI
 * calls are serialized onto the PhysicsWorld physics thread.
 */
package three.physics.softbody

import std.collection.ArrayList
import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.Logger

// =============================================================================
// PhysicsSoftBodyDesc 软体描述
// =============================================================================

/**
 * @brief[zh-cn] 软体描述
 * @explain[zh-cn] 由网格顶点/索引构建：顶点数组 + 三角形索引数组。
 * 顶点为世界空间（three 左手系），创建时自动转换为 Jolt 右手系。
 *
 * @brief[en] Soft body description
 * @explain[en] Built from mesh vertices/indices: vertex array + triangle index array.
 * Vertices are in world space (three left-handed); converted to the Jolt right-handed
 * system automatically at creation.
 */
public class PhysicsSoftBodyDesc {
    /**
     * @brief[zh-cn] 顶点位置列表（世界空间）
     *
     * @brief[en] Vertex positions (world space)
     */
    public var vertices: ArrayList<Vector3> = ArrayList<Vector3>()

    /**
     * @brief[zh-cn] 三角形索引列表（每 3 个一组）
     *
     * @brief[en] Triangle indices (groups of 3)
     */
    public var indices: ArrayList<UInt32> = ArrayList<UInt32>()

    /**
     * @brief[zh-cn] 边约束柔顺度（0 = 刚性）
     *
     * @brief[en] Edge-constraint compliance (0 = rigid)
     */
    public var compliance: Float64 = 0.00001

    /**
     * @brief[zh-cn] 弯曲约束类型（0 = 无）
     *
     * @brief[en] Bend constraint type (0 = none)
     */
    public var bendType: UInt32 = 0

    /**
     * @brief[zh-cn] 内部压力（封闭网格充气效果）
     *
     * @brief[en] Internal pressure (inflation for closed meshes)
     */
    public var pressure: Float64 = 0.0

    /**
     * @brief[zh-cn] 线阻尼
     *
     * @brief[en] Linear damping
     */
    public var linearDamping: Float64 = 0.1

    /**
     * @brief[zh-cn] 摩擦系数
     *
     * @brief[en] Friction coefficient
     */
    public var friction: Float64 = 0.2

    /**
     * @brief[zh-cn] 弹性系数
     *
     * @brief[en] Restitution coefficient
     */
    public var restitution: Float64 = 0.0

    /**
     * @brief[zh-cn] 重力因子（1 = 正常重力）
     *
     * @brief[en] Gravity factor (1 = normal gravity)
     */
    public var gravityFactor: Float64 = 1.0

    /**
     * @brief[zh-cn] 顶点半径（碰撞增厚）
     *
     * @brief[en] Vertex radius (collision thickness)
     */
    public var vertexRadius: Float64 = 0.0

    /**
     * @brief[zh-cn] 求解迭代次数
     *
     * @brief[en] Solver iteration count
     */
    public var numIterations: UInt32 = 5

    /**
     * @brief[zh-cn] 固定顶点索引列表（逆质量 = 0）
     *
     * @brief[en] Pinned vertex indices (inverse mass = 0)
     */
    public var pinnedVertices: ArrayList<Int64> = ArrayList<Int64>()

    /**
     * @brief[zh-cn] 对象层（Moving/Static）
     *
     * @brief[en] Object layer (Moving/Static)
     */
    public var layer: PhysicsLayer = PhysicsLayer.Moving

    /**
     * @brief[zh-cn] 构造软体描述
     *
     * @brief[en] Creates a soft-body description
     */
    public init() {}
}

// =============================================================================
// PhysicsSoftBody 运行时软体
// =============================================================================

/**
 * @brief[zh-cn] 软体运行时对象
 * @explain[zh-cn] 持有软体刚体 ID；销毁经 PhysicsWorld 序列化到物理线程执行。
 * 注：jolt4cj 当前未导出 SoftBodyMotionProperties 顶点读取 FFI，
 * 运行时顶点读取暂不可用，渲染侧需自行维护同步。
 *
 * @brief[en] Runtime soft body
 * @explain[en] Holds the soft-body body ID; disposal is serialized onto the physics
 * thread via PhysicsWorld. Note: jolt4cj currently does not export the
 * SoftBodyMotionProperties vertex-reading FFI, so runtime vertex reads are unavailable
 * for now — the render side must maintain synchronization itself.
 */
public class PhysicsSoftBody {
    private let _world: PhysicsWorld
    private var _bodyID: UInt32
    private var _disposed: Bool = false

    internal init(world!: PhysicsWorld, bodyID!: UInt32) {
        this._world = world
        this._bodyID = bodyID
    }

    /**
     * @brief[zh-cn] 软体是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the soft body is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && this._bodyID != 0
        }
    }

    /**
     * @brief[zh-cn] 软体刚体 ID
     *
     * @brief[en] The soft-body body ID
     */
    public prop bodyID: UInt32 {
        get() {
            this._bodyID
        }
    }

    /**
     * @brief[zh-cn] 销毁软体（从世界移除并释放刚体）
     *
     * @brief[en] Disposes the soft body (removes from the world and releases the body)
     */
    public func dispose(): Unit {
        if (this._disposed) {
            return
        }
        this._disposed = true
        let w = this._world
        let bodyID = this._bodyID
        w.execPhysics({
            =>
            match (w.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (!system.isNull()) {
                        let bodyIface = jb.nativeBodyInterface()
                        JPH_BodyInterface_RemoveAndDestroyBody_cj(bodyIface, bodyID)
                    }
                case _ => ()  // 非 Jolt 后端：无操作
            }
        })
        this._bodyID = 0
    }
}

// =============================================================================
// PhysicsSoftBodyFactory 软体工厂
// =============================================================================

/**
 * @brief[zh-cn] 软体工厂
 * @explain[zh-cn] 在指定物理世界内创建软体：SharedSettings（顶点/面/边约束）+
 * SoftBodyCreationSettings → BodyInterface_CreateAndAddSoftBody（一步创建并加入世界）。
 * 失败（非 Jolt 后端、空网格、创建失败）时返回 isValid=false 的对象。
 *
 * @brief[en] Soft-body factory
 * @explain[en] Creates a soft body in the given physics world: SharedSettings
 * (vertices/faces/edge constraints) + SoftBodyCreationSettings →
 * BodyInterface_CreateAndAddSoftBody (created and added in one step). On failure
 * (non-Jolt backend, empty mesh, creation failure) returns an object with
 * isValid=false.
 */
public class PhysicsSoftBodyFactory {
    private let _desc: PhysicsSoftBodyDesc

    /**
     * @brief[zh-cn] 构造软体工厂
     * @param[zh-cn] desc 软体描述
     *
     * @brief[en] Creates a soft-body factory
     * @param[en] desc The soft-body description
     */
    public init(desc!: PhysicsSoftBodyDesc) {
        this._desc = desc
    }

    /**
     * @brief[zh-cn] 在指定物理世界创建运行时软体
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 运行时软体
     *
     * @brief[en] Creates a runtime soft body in the given physics world
     * @param[en] world The target physics world
     * @return[en] The runtime soft body
     */
    public func createSoftBody(world: PhysicsWorld): PhysicsSoftBody {
        let desc = this._desc
        return world.execPhysicsResult<PhysicsSoftBody>({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull() || desc.vertices.size < 4 || desc.indices.size < 3) {
                        PhysicsSoftBody(world: world, bodyID: 0)
                    } else {
                        let bodyIface = jb.nativeBodyInterface()
                        // SharedSettings：顶点 + 面 + 边约束 + 优化
                        let shared = JPH_SoftBodySharedSettings_Create_cj()
                        let vtx = unsafe { LibC.malloc<JPHSoftVertex>(count: 1) }
                        for (i in 0..desc.vertices.size) {
                            let p = desc.vertices[i]
                            let pinned = desc.pinnedVertices.contains(i)
                            unsafe {
                                var v = JPHSoftVertex()
                                // three 左手系 → Jolt 右手系：z 取反
                                v.position = JPHVec3(x: Float32(p.x), y: Float32(p.y), z: Float32(-p.z))
                                v.velocity = JPHVec3()
                                v.invMass = if (pinned) { 0.0f32 } else { 1.0f32 }
                                vtx.write(v)
                            }
                            JPH_SoftBodySharedSettings_AddVertex_cj(shared, vtx)
                        }
                        unsafe { LibC.free(vtx) }
                        let face = unsafe { LibC.malloc<JPHSoftFace>(count: 1) }
                        for (i in 0..desc.indices.size / 3) {
                            unsafe {
                                let f = JPHSoftFace(vertex1: desc.indices[i * 3],
                                    vertex2: desc.indices[i * 3 + 1],
                                    vertex3: desc.indices[i * 3 + 2], materialIndex: 0)
                                face.write(f)
                            }
                            JPH_SoftBodySharedSettings_AddFace_cj(shared, face)
                        }
                        unsafe { LibC.free(face) }
                        // 生成边约束（compliance + 弯曲类型）并优化布局
                        JPH_SoftBodySharedSettings_CreateConstraints_cj(shared,
                            Float32(desc.compliance), desc.bendType)
                        JPH_SoftBodySharedSettings_Optimize_cj(shared)
                        // 创建设置
                        let cs = JPH_SoftBodyCreationSettings_Create_cj()
                        JPH_SoftBodyCreationSettings_SetSettings_cj(cs, shared)
                        JPH_SoftBodyCreationSettings_SetObjectLayer_cj(cs, _softLayerValue(desc.layer))
                        JPH_SoftBodyCreationSettings_SetPressure_cj(cs, Float32(desc.pressure))
                        JPH_SoftBodyCreationSettings_SetLinearDamping_cj(cs, Float32(desc.linearDamping))
                        JPH_SoftBodyCreationSettings_SetFriction_cj(cs, Float32(desc.friction))
                        JPH_SoftBodyCreationSettings_SetRestitution_cj(cs, Float32(desc.restitution))
                        JPH_SoftBodyCreationSettings_SetGravityFactor_cj(cs, Float32(desc.gravityFactor))
                        JPH_SoftBodyCreationSettings_SetVertexRadius_cj(cs, Float32(desc.vertexRadius))
                        JPH_SoftBodyCreationSettings_SetNumIterations_cj(cs, desc.numIterations)
                        // 一步创建并加入世界（DontActivate=1，与 JoltBackend 一致；软体由碰撞/步进唤醒）
                        let bodyID = JPH_BodyInterface_CreateAndAddSoftBody_cj(bodyIface, cs, 1)
                        JPH_SoftBodyCreationSettings_Destroy_cj(cs)
                        // shared settings 由软体持有，不销毁
                        if (bodyID == 0 || bodyID == 0xFFFFFFFF) {
                            JPH_SoftBodySharedSettings_Destroy_cj(shared)
                            Logger.error(["PhysicsSoftBodyFactory", "CreateAndAddSoftBody 失败"])
                            PhysicsSoftBody(world: world, bodyID: 0)
                        } else {
                            PhysicsSoftBody(world: world, bodyID: bodyID)
                        }
                    }
                case _ =>
                    // 非 Jolt 后端：无软体能力
                    PhysicsSoftBody(world: world, bodyID: 0)
            }
        })
    }
}

/// three 物理层 → Jolt 对象层值（与 JoltBackend 层映射一致：Moving=1，NonMoving/Static=0）
internal func _softLayerValue(layer: PhysicsLayer): UInt32 {
    match (layer) {
        case PhysicsLayer.Moving => 1
        case _ => 0
    }
}
