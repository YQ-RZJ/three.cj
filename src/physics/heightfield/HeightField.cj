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
 * @file[zh-cn] HeightField 高度场高层封装（three.physics.heightfield 子包）
 * @brief[zh-cn] 在 jolt4cj 的 HeightFieldShapeSettings + BodyCreationSettings FFI 之上，
 * 提供面向 three 的地形碰撞层
 * @explain[zh-cn] 高度场 = (N×N) 高度采样网格 → JPH_HeightFieldShape → 静态刚体。
 * 采样为行主序（y 行 × x 列），位置 = offset + (x,0,z)*scale；x/z 缩放由 scale.x/scale.z
 * 控制，高度直接存于采样值（scale.y 恒为 1）。顶点为世界空间（three 左手系），
 * 创建时自动转换为 Jolt 右手系。
 *
 * @file[en] HeightField high-level wrapper (three.physics.heightfield sub-package)
 * @brief[en] Provides a three-oriented terrain collision layer on top of the jolt4cj
 * HeightFieldShapeSettings + BodyCreationSettings FFI
 * @explain[en] A height field = an (N×N) grid of height samples → JPH_HeightFieldShape →
 * a static body. Samples are row-major (y row × x column); position = offset +
 * (x,0,z)*scale; horizontal scale is controlled by scale.x/scale.z, height is stored in
 * the sample value (scale.y fixed at 1). Samples are in world space (three left-handed);
 * converted to the Jolt right-handed system automatically at creation.
 */
package three.physics.heightfield

import std.collection.ArrayList
import three.core.math.*
import three.physics.*
import three.physics.interfaces.*
import three.physics.backend.*
import three.physics.world.*
import jolt4cj.jolt.*
import three.utils.log.*
import three.utils.log.macros.*

// =============================================================================
// PhysicsHeightFieldDesc 高度场描述
// =============================================================================

/**
 * @brief[zh-cn] 高度场地形描述
 * @explain[zh-cn] samples 为 (count × count) 行主序高度值（世界空间 Y 向上），
 * count 必须 ≥ 2 且建议为 (2^k + 1)。sizeX/sizeZ 为世界空间总尺寸。
 *
 * @brief[en] Height-field terrain description
 * @explain[en] samples is a (count × count) row-major height array (world-space Y up);
 * count must be ≥ 2 and preferably (2^k + 1). sizeX/sizeZ are the world-space extents.
 */
public class PhysicsHeightFieldDesc {
    /**
     * @brief[zh-cn] 高度采样（行主序：index = y * count + x）
     *
     * @brief[en] Height samples (row-major: index = y * count + x)
     */
    public var samples: ArrayList<Float64> = ArrayList<Float64>()

    /**
     * @brief[zh-cn] 每边采样数（N，网格为 N×N）
     *
     * @brief[en] Sample count per side (N; grid is N×N)
     */
    public var sampleCount: Int64 = 0

    /**
     * @brief[zh-cn] 世界空间 X 向总尺寸（米）
     *
     * @brief[en] World-space extent along X (meters)
     */
    public var sizeX: Float64 = 100.0

    /**
     * @brief[zh-cn] 世界空间 Z 向总尺寸（米）
     *
     * @brief[en] World-space extent along Z (meters)
     */
    public var sizeZ: Float64 = 100.0

    /**
     * @brief[zh-cn] 地形中心世界坐标（高度场平面中心）
     *
     * @brief[en] Terrain center in world space (center of the height-field plane)
     */
    public var center: Vector3 = Vector3(0.0, 0.0, 0.0)

    /**
     * @brief[zh-cn] 摩擦系数
     *
     * @brief[en] Friction coefficient
     */
    public var friction: Float64 = 0.5

    /**
     * @brief[zh-cn] 弹性系数
     *
     * @brief[en] Restitution coefficient
     */
    public var restitution: Float64 = 0.0

    /**
     * @brief[zh-cn] 构造高度场描述
     *
     * @brief[en] Creates a height-field description
     */
    public init() {}
}

// =============================================================================
// PhysicsHeightField 运行时高度场
// =============================================================================

/**
 * @brief[zh-cn] 高度场运行时对象
 * @explain[zh-cn] 持有地形刚体 ID；表面投影查询与销毁均经 PhysicsWorld 序列化到
 * 物理线程执行。
 *
 * @brief[en] Runtime height field
 * @explain[en] Holds the terrain body ID; surface projection queries and disposal are
 * serialized onto the physics thread via PhysicsWorld.
 */
public class PhysicsHeightField {
    private let _world: PhysicsWorld
    private var _bodyID: UInt32
    private let _center: Vector3
    private var _sampleCount: Int64
    private var _sizeX: Float64
    private var _sizeZ: Float64
    private var _disposed: Bool = false

    internal init(world!: PhysicsWorld, bodyID!: UInt32, center!: Vector3,
        sampleCount!: Int64, sizeX!: Float64, sizeZ!: Float64) {
        this._world = world
        this._bodyID = bodyID
        this._center = center
        this._sampleCount = sampleCount
        this._sizeX = sizeX
        this._sizeZ = sizeZ
    }

    /**
     * @brief[zh-cn] 高度场是否有效（创建成功且未销毁）
     *
     * @brief[en] Whether the height field is valid (created successfully and not disposed)
     */
    public prop isValid: Bool {
        get() {
            !this._disposed && this._bodyID != 0
        }
    }

    /**
     * @brief[zh-cn] 地形刚体 ID（可配合碰撞查询使用）
     *
     * @brief[en] The terrain body ID (usable with collision queries)
     */
    public prop bodyID: UInt32 {
        get() {
            this._bodyID
        }
    }

    /**
     * @brief[zh-cn] 每边采样数
     *
     * @brief[en] The sample count per side
     */
    public prop sampleCount: Int64 {
        get() {
            this._sampleCount
        }
    }

    /**
     * @brief[zh-cn] 把世界坐标点投影到地形表面（取地表高度）
     * @param[zh-cn] x 世界 X 坐标
     * z 世界 Z 坐标
     * @return[zh-cn] 表面点（three 左手系）；地形外或无效时返回 y = -3.4e38 的点
     *
     * @brief[en] Projects a world-space point onto the terrain surface (ground height)
     * @param[en] x World X coordinate
     * z World Z coordinate
     * @return[en] The surface point (three left-handed); a point with y = -3.4e38 when
     * outside the terrain or invalid
     */
    public func projectOntoSurface(x: Float64, z: Float64): Vector3 {
        if (!this.isValid) {
            return Vector3(x, -3.4e38, z)
        }
        let w = this._world
        let bodyID = this._bodyID
        let c = this._center
        let wx = x
        let wz = z
        return w.execPhysicsResult<Vector3>({
            =>
            match (w.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull()) {
                        Vector3(wx, -3.4e38, wz)
                    } else {
                        let bodyIface = jb.nativeBodyInterface()
                        let bodyPtr = JPH_PhysicsSystem_GetBodyPtr_cj(system, bodyID)
                        if (bodyPtr.isNull()) {
                            Vector3(wx, -3.4e38, wz)
                        } else {
                            let shape = JPH_Body_GetShape_cj(bodyPtr)
                            if (shape.isNull()) {
                                Vector3(wx, -3.4e38, wz)
                            } else {
                                // LH 世界 (wx, wz) → RH 世界 (wx, 0, -wz) →
                                // 形状局部 = RH 世界 - 刚体位置(RH: cx, cy, -cz)
                                //   = (wx - cx, -cy, cz - wz)
                                // （ProjectOntoSurface 只用 x/z 定位格元，y 被忽略）
                                let inP = JoltNative.allocVec3Raw(
                                    Vector3(wx - c.x, -c.y, c.z - wz))
                                let outP = unsafe { LibC.malloc<JPHVec3>(count: 1) }
                                let outSub = unsafe { LibC.malloc<UInt32>(count: 1) }
                                let hit = JPH_HeightFieldShape_ProjectOntoSurface_cj(
                                    shape, inP, outP, outSub)
                                if (hit == 0) {
                                    unsafe {
                                        LibC.free(inP)
                                        LibC.free(outP)
                                        LibC.free(outSub)
                                    }
                                    Vector3(wx, -3.4e38, wz)
                                } else {
                                    let v = unsafe { outP.read() }
                                    unsafe {
                                        LibC.free(inP)
                                        LibC.free(outP)
                                        LibC.free(outSub)
                                    }
                                    // 局部(RH) → 世界(RH: +body) → LH(z 取反)
                                    Vector3(Float64(v.x) + c.x, Float64(v.y) + c.y,
                                        c.z - Float64(v.z))
                                }
                            }
                        }
                    }
                case _ => Vector3(wx, -3.4e38, wz)
            }
        })
    }

    /**
     * @brief[zh-cn] 销毁高度场地形（从世界移除并释放刚体）
     *
     * @brief[en] Disposes the height-field terrain (removes from the world and releases the body)
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
// PhysicsHeightFieldFactory 高度场工厂
// =============================================================================

/**
 * @brief[zh-cn] 高度场工厂
 * @explain[zh-cn] 在指定物理世界内创建地形：高度采样 → JPH_HeightFieldShapeSettings →
 * JPH_HeightFieldShapeSettings_CreateShape → 静态刚体（CreateAndAddBody）。
 * 失败（非 Jolt 后端、采样不足）时返回 isValid=false 的对象。
 *
 * @brief[en] Height-field factory
 * @explain[en] Creates terrain in the given physics world: height samples →
 * JPH_HeightFieldShapeSettings → CreateShape → a static body (CreateAndAddBody).
 * On failure (non-Jolt backend, insufficient samples) returns an object with
 * isValid=false.
 */
public class PhysicsHeightFieldFactory {
    private let _desc: PhysicsHeightFieldDesc

    /**
     * @brief[zh-cn] 构造高度场工厂
     * @param[zh-cn] desc 高度场描述
     *
     * @brief[en] Creates a height-field factory
     * @param[en] desc The height-field description
     */
    public init(desc!: PhysicsHeightFieldDesc) {
        this._desc = desc
    }

    /**
     * @brief[zh-cn] 在指定物理世界创建运行时高度场
     * @param[zh-cn] world 目标物理世界
     * @return[zh-cn] 运行时高度场
     *
     * @brief[en] Creates a runtime height field in the given physics world
     * @param[en] world The target physics world
     * @return[en] The runtime height field
     */
    public func createHeightField(world: PhysicsWorld): PhysicsHeightField {
        let desc = this._desc
        return world.execPhysicsResult<PhysicsHeightField>({
            =>
            match (world.backend) {
                case jb: JoltBackend =>
                    let system = jb.nativeSystemHandle()
                    if (system.isNull() || desc.sampleCount < 2 || desc.samples.size <
                        desc.sampleCount * desc.sampleCount) {
                        PhysicsHeightField(world: world, bodyID: 0, center: desc.center,
                            sampleCount: desc.sampleCount, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
                    } else {
                        let bodyIface = jb.nativeBodyInterface()
                        // 高度采样转 Float32（行主序）
                        let n = desc.sampleCount
                        let samples = unsafe { LibC.malloc<Float32>(count: desc.samples.size) }
                        for (i in 0..desc.samples.size) {
                            unsafe { (samples + i).write(Float32(desc.samples[i])) }
                        }
                        // mOffset/mScale 是形状（= 刚体）局部空间量，而刚体本身已整体
                        // 放在 desc.center，因此 offset 只能写"相对质心的网格角点"，
                        // 不能放世界坐标（旧实现误放世界角点，网格整体偏移一个 center，
                        // 导致 projectOntoSurface 的查询点全部落在形状外）。
                        // LH 局部最小角 (-sizeX/2, -center.y, -sizeZ/2)
                        //   → RH 镜像 (-sizeX/2, -center.y, +sizeZ/2)；
                        // offset.y = -center.y 把"世界高度采样"换算为相对刚体质心的
                        // 局部高度（scale.y = 1，高度直接存于采样值）；
                        // scale.z 随右手系镜像取反。
                        let offset = JoltNative.allocVec3Raw(Vector3(
                            -desc.sizeX / 2.0, -desc.center.y, desc.sizeZ / 2.0))
                        let scale = JoltNative.allocVec3Raw(Vector3(
                            desc.sizeX / Float64(n - 1), 1.0,
                            -desc.sizeZ / Float64(n - 1)))
                        let settings = JPH_HeightFieldShapeSettings_Create_cj(
                            samples, offset, scale, UInt32(n), CPointer<UInt8>())
                        unsafe {
                            LibC.free(samples)
                            LibC.free(offset)
                            LibC.free(scale)
                        }
                        if (settings.isNull()) {
                            PhysicsHeightField(world: world, bodyID: 0, center: desc.center,
                                sampleCount: n, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
                        } else {
                            let shape = JPH_HeightFieldShapeSettings_CreateShape_cj(settings)
                            if (shape.isNull()) {
                                PhysicsHeightField(world: world, bodyID: 0, center: desc.center,
                                    sampleCount: n, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
                            } else {
                                // 静态刚体（MotionType_Static = 0，对象层 NonMoving = 0）
                                // 注：形状设置无独立 Destroy 导出，settings 由 CreateShape 消耗
                                // 刚体位姿统一走 LH→RH 转换（pos 的 z 取反、quat 镜像），
                                // 与形状 offset/scale 的局部镜像约定保持一致
                                let pos = JoltNative.allocVec3(desc.center)
                                let rot = JoltNative.allocQuat(Quaternion(0.0, 0.0, 0.0, 1.0))
                                let bcs = JPH_BodyCreationSettings_Create3_cj(shape, pos, rot, 0, 0)
                                JPH_BodyCreationSettings_SetFriction_cj(bcs, Float32(desc.friction))
                                JPH_BodyCreationSettings_SetRestitution_cj(bcs, Float32(desc.restitution))
                                let bodyID = JPH_BodyInterface_CreateAndAddBody_cj(bodyIface, bcs, 1)
                                JPH_BodyCreationSettings_Destroy_cj(bcs)
                                // 加入世界后形状引用已由刚体持有，再释放临时引用
                                if (bodyID != 0 && bodyID != 0xFFFFFFFF) {
                                    JPH_Shape_Destroy_cj(shape)
                                }
                                unsafe {
                                    LibC.free(pos)
                                    LibC.free(rot)
                                }
                                if (bodyID == 0 || bodyID == 0xFFFFFFFF) {
                                    @LogError(["PhysicsHeightFieldFactory", "CreateAndAddBody 失败"])
                                    PhysicsHeightField(world: world, bodyID: 0, center: desc.center,
                                        sampleCount: n, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
                                } else {
                                    PhysicsHeightField(world: world, bodyID: bodyID, center: desc.center,
                                        sampleCount: n, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
                                }
                            }
                        }
                    }
                case _ =>
                    // 非 Jolt 后端：无高度场能力
                    PhysicsHeightField(world: world, bodyID: 0, center: desc.center,
                        sampleCount: desc.sampleCount, sizeX: desc.sizeX, sizeZ: desc.sizeZ)
            }
        })
    }
}
