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
 * @file[zh-cn] Skeleton
 * @brief[zh-cn] 骨骼，管理一组 Bone 及其逆矩阵的辅助类
 * @explain[zh-cn] 供 SkinnedMesh 顶点蒙皮变换使用。各 Bone 的 matrixWorld 与其 inverseMatrix 相乘得 offsetMatrix，
 * 逐顶点按 skinIndex/skinWeight 加权混合这些 offsetMatrix 完成蒙皮变形。
 * boneTexture 是 boneMatrices 的 GPU 贴图封装（大骨骼用）。
 *
 * @file[en] Skeleton
 * @brief[en] Skeleton, auxiliary class managing a set of Bones and their inverse matrices
 * @explain[en] Used by SkinnedMesh for vertex skinning transforms. Each Bone's matrixWorld × inverseMatrix = offsetMatrix,
 * per-vertex weighted blending of offsetMatrices via skinIndex/skinWeight completes skinning deformation.
 * boneTexture is the GPU texture wrapper of boneMatrices (for large skeletons).
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.utils.constants.*
import three.rendering.textures.DataTexture
import three.utils.memory.AutoFreePtr
import three.core.interfaces.IPropertyBindingRoot
import three.animation.skeletal.*
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*
import three.utils.log.*
import three.utils.log.macros.*

/**
 * @brief[zh-cn] 骨骼类，管理一组 Bone 及其逆矩阵
 * @explain[zh-cn] 供 SkinnedMesh 顶点蒙皮变换使用，boneTexture 是 boneMatrices 的 GPU 贴图封装
 *
 * @brief[en] Skeleton class, manages a set of Bones and their inverse matrices
 * @explain[en] Used by SkinnedMesh for vertex skinning transforms, boneTexture is the GPU texture wrapper of boneMatrices
 */
@JsonAdapter
public class Skeleton <: IPropertyBindingRoot {
    /**
     * @brief[zh-cn] 髀骨数组
     *
     * @brief[en] Bone array
     */
    public var bones: ArrayList<Bone>

    /**
     * @brief[zh-cn] 各髀骨的逆矩阵（世界空间 → 髀骨局部空间）
     *
     * @brief[en] Inverse matrices of each bone (world space → bone local space)
     */
    public var boneInverses: ArrayList<Matrix4>

    /**
     * @brief[zh-cn] 髀骨偏移矩阵的扁平数组（每髀骨 16 个 Float64），渲染时内部使用
     * @explain[zh-cn] 派生缓存：update() 每帧由 bones.matrixWorld × boneInverses 重算，不参与 JSON 序列化
     *
     * @brief[en] Flattened bone offset matrix array (16 Float64 per bone), used internally for rendering
     * @explain[en] Derived cache: recomputed each frame by update() from bones.matrixWorld × boneInverses, not serialized
     */
    @JsonIgnore
    public var boneMatrices: Option<Array<Float64>>

    /**
     * @brief[zh-cn] boneMatrices 的 GPU 贴图封装（大骨骼用，替代 boneMatrices 数组上传）
     *
     * @brief[en] GPU texture wrapper of boneMatrices (for large skeletons, replaces array upload)
     */
    @JsonIgnore
    public var boneTexture: Option<DataTexture>

    /**
     * @brief[zh-cn] 类型标签
     *
     * @brief[en] Type label
     */
    public var kind: String

    /**
     * @brief[zh-cn] 唯一标识
     *
     * @brief[en] Unique identifier
     */
    public var uuid: String

    /**
     * @brief[zh-cn] 获取唯一标识（IPropertyBindingRoot 接口实现）
     * @return[zh-cn] UUID 字符串
     *
     * @brief[en] Get unique identifier (IPropertyBindingRoot interface implementation)
     * @return[en] UUID string
     */
    public func getUuid(): String { return this.uuid }

    /**
     * @brief[zh-cn] 构造一个新的骨骼
     * @param[zh-cn] bones 髀骨数组，默认空数组
     * boneInverses 髀骨逆矩阵数组，默认空数组（空时自动 calculateInverses）
     *
     * @brief[en] Construct a new skeleton
     * @param[en] bones Bone array, default empty
     * boneInverses Bone inverse matrix array, default empty (auto calculateInverses when empty)
     */
    public init(bones!: ArrayList<Bone> = ArrayList<Bone>(), boneInverses!: ArrayList<Matrix4> = ArrayList<Matrix4>()) {
        this.uuid = MathUtils.generateUUID()
        this.bones = ArrayList<Bone>()
        for (b in bones) { this.bones.add(b) }
        this.boneInverses = boneInverses
        this.boneMatrices = None
        this.boneTexture = None
        this.kind = "Skeleton"
        this._init()
    }

    /**
     * @brief[zh-cn] 内部初始化：boneInverses 为空时自动计算；数量与 bones 不匹配时重建
     *
     * @brief[en] Internal initialization: auto-calculates when boneInverses is empty; rebuilds when count mismatch
     */
    public func _init(): Unit {
        if (this.boneInverses.size == 0) {
            this.calculateInverses()
        } else {
            if (this.bones.size != this.boneInverses.size) {
                this.boneInverses = ArrayList<Matrix4>()
                for (i in 0..this.bones.size) { this.boneInverses.add(Matrix4()) }
            }
        }
    }

    /**
     * @brief[zh-cn] 计算各髀骨的逆矩阵（matrixWorld.invert()）
     *
     * @brief[en] Calculate inverse matrices for each bone (matrixWorld.invert())
     */
    public func calculateInverses(): Unit {
        this.boneInverses = ArrayList<Matrix4>()
        for (i in 0..this.bones.size) {
            let inverse = Matrix4()
            inverse.copy(this.bones[i].matrixWorld).invert()
            this.boneInverses.add(inverse)
        }
    }

    /**
     * @brief[zh-cn] 将各髀骨 pose 到初始姿势，随后重算各髀骨的 matrix/position/quaternion/scale
     *
     * @brief[en] Pose each bone to its initial pose, then recalculate each bone's matrix/position/quaternion/scale
     */
    public func pose(): Unit {
        for (i in 0..this.bones.size) {
            this.bones[i].matrixWorld.copy(this.boneInverses[i]).invert()
        }
        for (i in 0..this.bones.size) {
            let bone = this.bones[i]
            match (bone.parent) {
                case Some(parent) =>
                    bone.matrix.copy(parent.matrixWorld).invert()
                    bone.matrix.multiply(bone.matrixWorld)
                case None =>
                    bone.matrix.copy(bone.matrixWorld)
            }
            bone.matrix.decompose(bone.position, bone.quaternion, bone.scale)
        }
    }

    /**
     * @brief[zh-cn] 更新各髀骨的 offsetMatrix 并写入 boneMatrices
     * @explain[zh-cn] 渲染器每帧调用；本方法不更新髀骨的 matrixWorld（由 Object3D.updateMatrixWorld 完成）
     *
     * @brief[en] Update each bone's offsetMatrix and write to boneMatrices
     * @explain[en] Called by renderer each frame; does not update bone's matrixWorld (done by Object3D.updateMatrixWorld)
     */
    public func update(): Unit {
        // 与 JS side 一致：复用已分配的 boneMatrices 数组（避免每帧重分配）。
        let boneMatricesArr = match (this.boneMatrices) {
            case Some(arr) => arr
            case None => Array<Float64>(this.bones.size * 16, { _ => 0.0 })
        }
        for (i in 0..this.bones.size) {
            let matrix = this.bones[i].matrixWorld
            let offsetMatrix = Matrix4().multiplyMatrices(matrix, this.boneInverses[i])
            offsetMatrix.toArray(boneMatricesArr, offset: i * 16)
        }
        this.boneMatrices = Some(boneMatricesArr)
    }

    /**
     * @brief[zh-cn] 从 JSON 反序列化设置骨骼
     * @explain[zh-cn] 解析 bones/boneInverses 字段，通过 bones 字典（uuid→Bone）查找 Bone 实例并组装
     * @param[zh-cn] json 序列化的骨骼 JSON
     * bones 骨骼字典（uuid → Bone 实例）
     * @return[zh-cn] 返回 this 以支持链式调用
     *
     * @brief[en] Set up skeleton from JSON deserialization
     * @explain[en] Parses bones/boneInverses fields, looks up Bone instances via uuid→Bone dictionary
     * @param[en] json Serialized skeleton JSON
     * bones Bone dictionary (uuid → Bone instance)
     * @return[en] Returns this for method chaining
     */
    public func fromJSON(json: HashMap<String, Any>, bones: HashMap<String, Bone>): Skeleton {
        this.uuid = match (json.get("uuid")) {
            case Some(u) => match (u) { case s: String => s; case _ => MathUtils.generateUUID() }
            case None => MathUtils.generateUUID()
        }
        this.bones.clear()
        this.boneInverses.clear()
        let boneList = match (json.get("bones")) {
            case Some(arr) => match (arr) { case a: ArrayList<Any> => a; case _ => ArrayList<Any>() }
            case None => ArrayList<Any>()
        }
        let inverseList = match (json.get("boneInverses")) {
            case Some(arr) => match (arr) { case a: ArrayList<Any> => a; case _ => ArrayList<Any>() }
            case None => ArrayList<Any>()
        }
        for (i in 0..boneList.size) {
            let uuid = match (boneList[i]) { case s: String => s; case _ => "" }
            
            var bone = match (bones.get(uuid)) {
                case Some(b) => b
                case None =>
                    // 骨骼未找到，创建默认骨骼
                    Bone()
            }
            this.bones.add(bone)
            // 解析 boneInverses
            if (i < inverseList.size) {
                match (inverseList[i]) {
                    case arr: Array<Float64> => this.boneInverses.add(Matrix4().fromArray(arr))
                    case _ => this.boneInverses.add(Matrix4())
                }
            } else {
                this.boneInverses.add(Matrix4())
            }
        }
        this._init()
        return this
    }

    /**
     * @brief[zh-cn] 生成 boneTexture（将 boneMatrices 打包为 DataTexture），大骨骼用以省上传开销
     * @explain[zh-cn] 仅在 bone 数量超过常数阈值时调用。每矩阵占 4 像素（RGBA 列存储）
     *
     * @brief[en] Generate boneTexture (pack boneMatrices into DataTexture), for large skeletons to save upload cost
     * @explain[en] Only called when bone count exceeds constant threshold. 4 pixels per matrix (RGBA column storage)
     */
    public func computeBoneTexture(): Unit {
        // layout (1 matrix = 4 pixels): RGBA RGBA RGBA RGBA => column1, column2, column3, column4
        //      8x8  pixel texture max   16 bones * 4 pixels = (8 * 8)
        //     16x16 pixel texture max   64 bones * 4 pixels = (16 * 16)
        //     32x32 pixel texture max  256 bones * 4 pixels = (32 * 32)
        //     64x64 pixel texture max 1024 bones * 4 pixels = (64 * 64)
        let nBones = Int64(this.bones.size)
        var size = sqrt(Float64(nBones * 4))
        size = ceil(size / 4.0) * 4.0
        if (size < 4.0) { size = 4.0 }
        let sizeI = Int64(size)

        // boneMatrices: size * size * 4 floats（每 RGBA 像素 4 floats）
        
        let totalFloats = sizeI * sizeI * 4
        let boneMatricesArr = Array<Float64>(totalFloats, { _ => 0.0 })
        match (this.boneMatrices) {
            case Some(src) =>
                let copyLen = if (Int64(src.size) < totalFloats) { Int64(src.size) } else { totalFloats }
                for (i in 0..copyLen) { boneMatricesArr[i] = src[i] }
            case None => ()
        }

        // Float32 → UInt8 字节视图：每 float 4 字节（little-endian IEEE754）
        
        // 仓颉侧 DataTexture 接受 Array<UInt8>，故将 Float64 视图转字节。
        let bytes = Array<UInt8>(totalFloats * 4, { _ => 0u8 })
        var bi = 0
        for (i in 0..totalFloats) {
            // Float64 → Float32 截断后取 4 字节（IEEE754 little-endian）
            // 对照 extras/DataUtils.cj：通过内存操作读取 Float32 的位模式为 UInt32
            let f = Float32(boneMatricesArr[i])
            let bits = unsafe {
                let holder = AutoFreePtr<Float32>(LibC.malloc<Float32>())
                holder.get().write(f)
                let result = CPointer<UInt32>(holder.get()).read()
                holder.dispose()
                result
            }
            bytes[bi] = UInt8(bits & 0xFFu32)
            bytes[bi + 1] = UInt8((bits >> 8) & 0xFFu32)
            bytes[bi + 2] = UInt8((bits >> 16) & 0xFFu32)
            bytes[bi + 3] = UInt8((bits >> 24) & 0xFFu32)
            bi += 4
        }

        let boneTexture = DataTexture(bytes, sizeI, sizeI, format: RGBAFormat, `type`: FloatType)
        boneTexture.needsUpdate = true

        this.boneMatrices = Some(boneMatricesArr)
        this.boneTexture = Some(boneTexture)
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新骨骼实例
     * @return[zh-cn] 新骨骼实例
     *
     * @brief[en] Return a new skeleton instance with the same values as this instance
     * @return[en] New skeleton instance
     */
    public func clone(): Skeleton {
        return Skeleton(bones: this.bones, boneInverses: this.boneInverses)
    }

    /**
     * @brief[zh-cn] 按名称查找髀骨
     * @param[zh-cn] name 髀骨名称
     * @return[zh-cn] 找到的髀骨，或 None
     *
     * @brief[en] Find bone by name
     * @param[en] name Bone name
     * @return[en] Found bone, or None
     */
    public func getBoneByName(name: String): Option<Bone> {
        for (i in 0..this.bones.size) {
            if (this.bones[i].name == name) { return Some(this.bones[i]) }
        }
        return None
    }

    /**
     * @brief[zh-cn] 释放本实例分配的 GPU 相关资源（boneTexture 贴图）
     *
     * @brief[en] Release GPU-related resources allocated by this instance (boneTexture)
     */
    public func dispose(): Unit {
        match (this.boneTexture) {
            case Some(_) => this.boneTexture = None
            case None => ()
        }
    }

    // 将本骨骼序列化为 JSON（手写 toJSON 兼容层已移除，改用 fastjson 宏）。

    /**
     * @brief[zh-cn] 从 SkeletonData 同步骨骼数据
     * @param[zh-cn] skelData 骨骼计算数据
     * @explain[zh-cn] 将 SkeletonData 的关节层级映射到当前 Skeleton 的 Bone 数组。
     *                  1. 清空现有 bones
     *                  2. 为每个关节创建 Bone，设置名称和父关系
     *                  3. 从 SoA 休息姿势提取局部变换，设置到 Bone 的 position/quaternion/scale
     *                  4. 调用 updateMatrixWorld 更新全局矩阵
     *
     * @brief[en] Synchronizes bone data from SkeletonData
     * @param[en] skelData Skeleton computation data
     * @explain[en] Maps the joint hierarchy of SkeletonData onto the Bone array of the current Skeleton.
     *                  1. Clear the existing bones
     *                  2. Create a Bone for each joint, setting name and parent relationships
     *                  3. Extract local transforms from the SoA rest pose and apply them to each Bone's position/quaternion/scale
     *                  4. Call updateMatrixWorld to update world matrices
     */
    public func syncFromSkeletonData(skelData: SkeletonData): Unit {
        this.bones = ArrayList<Bone>()
        let numJoints = skelData.numJoints()
        if (numJoints == 0) { return }

        // 创建所有 Bone
        for (i in 0..numJoints) {
            let bone = Bone()
            bone.name = skelData.jointName(i)
            this.bones.add(bone)
        }
        // 调试：输出运行时骨骼顺序（与 glTF skin.joints 顺序对比）
        var names = ""
        for (i in 0..numJoints) {
            names += "${i}:${skelData.jointName(i)} "
        }
        @LogDebug(["Skeleton", "sync-order ${names}"])

        // 休息姿势（SoA 布局，每个 SoaTransform 含 4 个关节）
        let restPoses = skelData.jointRestPoses()

        // 设置父子关系和局部变换（通过 add 建立 parent/children 双向链接）
        for (i in 0..numJoints) {
            let parentIdx = skelData.jointParent(i)
            if (parentIdx >= 0) {
                this.bones[parentIdx].add(this.bones[i])
            }

            // 从 SoaTransform 提取局部变换
            let soaIdx = i / 4
            let slot = i % 4
            if (soaIdx < restPoses.size) {
                let t = restPoses[soaIdx].getTranslation(slot)
                let r = restPoses[soaIdx].getRotation(slot)
                let s = restPoses[soaIdx].getScale(slot)
                this.bones[i].position.set(Float64(t.x), Float64(t.y), Float64(t.z))
                this.bones[i].quaternion.set(Float64(r.x), Float64(r.y), Float64(r.z), Float64(r.w))
                this.bones[i].scale.set(Float64(s.x), Float64(s.y), Float64(s.z))
            }
        }

        // 更新所有 Bone 的 matrixWorld
        for (i in 0..numJoints) {
            this.bones[i].updateMatrix()
            this.bones[i].updateMatrixWorld(true)
        }

        // 计算逆矩阵
        this.calculateInverses()
    }
}