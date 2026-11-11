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
 * @file[zh-cn] SkinnedMesh
 * @brief[zh-cn] 蒙皮网格，带骨骼蒙皮变形的 Mesh
 * @explain[zh-cn] 每位顶点按 skinIndex/skinWeight 加权混合若干髀骨的 offsetMatrix。
 * bindMatrix/bindMatrixInverse 定义绑定姿势；bindMode 控制是否随本对象矩阵更新（Attached）或固定（Detached）。
 * 继承 Mesh；raycast 处理 bone transform 后的顶点位置（通过 override getVertexPosition）。
 *
 * @file[en] SkinnedMesh
 * @brief[en] Skinned mesh, a Mesh with bone skinning deformation
 * @explain[en] Each vertex is weighted by skinIndex/skinWeight across multiple bone offsetMatrices.
 * bindMatrix/bindMatrixInverse define bind pose; bindMode controls whether to follow object matrix (Attached) or fixed (Detached).
 * Extends Mesh; raycast handles bone-transformed vertex positions (via override getVertexPosition).
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.utils.constants.*
import three.animation.skeletal.*
import three.profiler.*
import three.profiler.macros.*
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 蒙皮网格，带骨骼蒙皮变形的 Mesh
 * @explain[zh-cn] bindMatrix/bindMatrixInverse 定义绑定姿势；bindMode 控制 Attached/Detached 模式。
 *                  JSON 序列化：bindMode/bindMatrix/skeleton 持久化；bindMatrixInverse 为派生量
 *                  （updateMatrixWorld 每帧重算）、_bindPositions/_bindNormals 为运行时蒙皮缓存，均忽略。
 *
 * @brief[en] Skinned mesh, a Mesh with bone skinning deformation
 * @explain[en] bindMatrix/bindMatrixInverse define bind pose; bindMode controls Attached/Detached mode.
 *              JSON serialization: bindMode/bindMatrix/skeleton are persisted; bindMatrixInverse is
 *              derived (recomputed each frame by updateMatrixWorld) and _bindPositions/_bindNormals
 *              are runtime skinning caches, both ignored.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Mesh]
public class SkinnedMesh <: Mesh {

    /**
     * @brief[zh-cn] 骨骼实例（管理 bones/boneInverses/boneMatrices）
     *
     * @brief[en] Skeleton instance (manages bones/boneInverses/boneMatrices)
     */
    public var skeleton: Skeleton

    /**
     * @brief[zh-cn] 绑定姿势模式：AttachedBindMode（随本对象矩阵）或 DetachedBindMode（固定 bindMatrix）
     *
     * @brief[en] Bind pose mode: AttachedBindMode (follows object matrix) or DetachedBindMode (fixed bindMatrix)
     */
    public var bindMode: String

    /**
     * @brief[zh-cn] 绑定姿势矩阵（世界空间）
     *
     * @brief[en] Bind pose matrix (world space)
     */
    public var bindMatrix: Matrix4

    /**
     * @brief[zh-cn] 绑定姿势矩阵的逆（派生量：updateMatrixWorld 每帧由 bindMatrix/matrixWorld 重算，不参与 JSON）
     *
     * @brief[en] Inverse of the bind pose matrix (derived: recomputed each frame by updateMatrixWorld, not serialized)
     */
    @JsonIgnore
    public var bindMatrixInverse: Matrix4

    /**
     * @brief[zh-cn] 绑定姿势的原始顶点位置缓存（运行时蒙皮缓存，不参与 JSON）
     * @explain[zh-cn] 首次 applySkinningJob 时从 position 属性记录；
     *                  之后每帧都从该缓存做蒙皮，避免变形结果逐帧累积。
     *
     * @brief[en] Cache of the original bind-pose vertex positions (runtime skinning cache, excluded from JSON)
     * @explain[en] Recorded from the position attribute on the first applySkinningJob call;
     *                  every subsequent frame skins from this cache to avoid deformation accumulating frame by frame.
     */
    @JsonIgnore
    private var _bindPositions: ?Array<Float32>

    /**
     * @brief[zh-cn] 绑定姿势的原始顶点法线缓存（运行时蒙皮缓存，不参与 JSON）
     *
     * @brief[en] Cache of the original bind-pose vertex normals (runtime skinning cache, excluded from JSON)
     */
    @JsonIgnore
    private var _bindNormals: ?Array<Float32>

    /**
     * @brief[zh-cn] 蒙皮权重缓存（关节索引 + 权重，运行时蒙皮缓存，不参与 JSON）
     * @explain[zh-cn] skinIndex/skinWeight 是静态数据（逐帧不变），每帧重建
     *                  权重数组是纯浪费：首次构建后缓存复用，顶点数变化时重建。
     *
     * @brief[en] Cached skin weights (joint indices + weights; runtime cache, excluded from JSON)
     * @explain[en] skinIndex/skinWeight are static data; rebuilding the weight arrays
     *              every frame is pure waste. Cached after the first build and
     *              rebuilt only when the vertex count changes.
     */
    @JsonIgnore
    private var _skinWeightsCache: ?SkinWeights

    /**
     * @brief[zh-cn] 关节矩阵暂存缓冲（boneWorld × boneInverse，运行时缓存，不参与 JSON）
     *
     * @brief[en] Scratch buffer for joint matrices (runtime cache, excluded from JSON)
     */
    @JsonIgnore
    private var _jointMatrixBuf: ?Array<Float32>

    /**
     * @brief[zh-cn] 矩阵乘法暂存对象（避免逐骨骼分配 Matrix4，运行时缓存，不参与 JSON）
     *
     * @brief[en] Scratch matrix for multiplications (avoids per-bone Matrix4 allocation)
     */
    @JsonIgnore
    private var _matrixScratch: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 构造一个新的蒙皮网格
     * @param[zh-cn] geometry 顶点/索引几何
     * material 材质
     *
     * @brief[en] Construct a new skinned mesh
     * @param[en] geometry Vertex/index geometry
     * material Material
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material()) {
        super(geometry: geometry, material: material)
        this.bindMode = AttachedBindMode
        this.bindMatrix = Matrix4()
        this.bindMatrixInverse = Matrix4()
        this.skeleton = Skeleton()
        this._bindPositions = None
        this._bindNormals = None
        this._skinWeightsCache = None
        this._jointMatrixBuf = None
    }

    /**
     * @brief[zh-cn] 绑定骨骼到本网格
     * @explain[zh-cn] bindMatrix 未传时用本对象 matrixWorld
     * @param[zh-cn] skeleton 骨骼实例
     * bindMatrix 自定义绑定矩阵，默认 None 表示用本对象 matrixWorld
     *
     * @brief[en] Bind skeleton to this mesh
     * @explain[en] When bindMatrix is not provided, uses this object's matrixWorld
     * @param[en] skeleton Skeleton instance
     * bindMatrix Custom bind matrix, default None means use this object's matrixWorld
     */
    public func bind(skeleton: Skeleton, bindMatrix!: Option<Matrix4> = None): Unit {
        this.skeleton = skeleton
        if (let Some(m) <- bindMatrix) {
            this.bindMatrix.copy(m)
        } else {
            this.updateMatrixWorld(true)
            this.skeleton.calculateInverses()
            this.bindMatrix.copy(this.matrixWorld)
        }
        this.bindMatrixInverse.copy(this.bindMatrix).invert()
    }

    /**
     * @brief[zh-cn] 将骨骼 pose 到初始姿势
     *
     * @brief[en] Pose skeleton to initial pose
     */
    public func pose(): Unit {
        this.skeleton.pose()
    }

    /**
     * @brief[zh-cn] 归一化 skinWeight 属性：各顶点权重缩放为总和 1，避免渲染瑕疵
     *
     * @brief[en] Normalize skinWeight attribute: scale each vertex's weights to sum to 1, avoiding rendering artifacts
     */
    public func normalizeSkinWeights(): Unit {
        let geo = this.geometry
        if (let Some(skinWeight) <- geo.getAttribute("skinWeight")) {
            for (i in 0..skinWeight.count) {
                let x = skinWeight.getX(i)
                let y = skinWeight.getY(i)
                let z = skinWeight.getZ(i)
                let scale = 1.0 / (abs(x) + abs(y) + abs(z))
                if (scale != Float64.Inf) {
                    skinWeight.setXYZ(i, x * scale, y * scale, z * scale)
                } else {
                    skinWeight.setXYZ(i, 1.0, 0.0, 0.0)
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 更新本对象及其骨骼的世界矩阵
     * @param[zh-cn] force 是否强制更新
     *
     * @brief[en] Update this object's and its skeleton's world matrices
     * @param[en] force Whether to force update
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        super.updateMatrixWorld(force)
        if (this.bindMode == AttachedBindMode) {
            this.bindMatrixInverse.copy(this.matrixWorld).invert()
        } else if (this.bindMode == DetachedBindMode) {
            this.bindMatrixInverse.copy(this.bindMatrix).invert()
        }
    }

    /**
     * @brief[zh-cn] 计算几何包围盒
     *
     * @brief[en] Compute geometry bounding box
     */
    public func computeBoundingBox(): Unit {
        if (let Some(_) <- this.geometry.boundingBox) {
            ()
        } else {
            this.geometry.computeBoundingBox()
        }
    }

    /**
     * @brief[zh-cn] 计算几何包围球
     *
     * @brief[en] Compute geometry bounding sphere
     */
    public func computeBoundingSphere(): Unit {
        if (let Some(_) <- this.geometry.boundingSphere) {
            ()
        } else {
            this.geometry.computeBoundingSphere()
        }
    }

    /**
     * @brief[zh-cn] 应用髀骨变换到指定顶点位置，返回变换后位置
     * @explain[zh-cn] 按 skinIndex/skinWeight 加权混合 offsetMatrix（matrixWorld × boneInverses[i]），
     * 随后用 bindMatrixInverse 把结果从髀骨空间换回本对象局部空间
     * @param[zh-cn] index 顶点索引
     * target 接收结果的目标向量
     * @return[zh-cn] 变换后的顶点位置
     *
     * @brief[en] Apply bone transform to the specified vertex position and return the transformed position
     * @explain[en] Weighted blending of offsetMatrix (matrixWorld × boneInverses[i]) via skinIndex/skinWeight,
     * then transforms result from bone space back to object local space via bindMatrixInverse
     * @param[en] index Vertex index
     * target Target vector to receive the result
     * @return[en] Transformed vertex position
     */
    public func applyBoneTransform(index: Int64, target: Vector3): Vector3 {
        let skeleton = this.skeleton
        let geometry = this.geometry

        // _skinIndex.fromBufferAttribute(geometry.attributes.skinIndex, index) — 仓颉侧用 getX/Y/Z/W 拼装
        var skinIndex = Vector4()
        var skinWeight = Vector4()
        if (let Some(skinIndexAttr) <- geometry.getAttribute("skinIndex")) {
            skinIndex = skinIndex.set(skinIndexAttr.getX(index), skinIndexAttr.getY(index), skinIndexAttr.getZ(index), skinIndexAttr.getW(index))
        }
        if (let Some(skinWeightAttr) <- geometry.getAttribute("skinWeight")) {
            skinWeight = skinWeight.set(skinWeightAttr.getX(index), skinWeightAttr.getY(index), skinWeightAttr.getZ(index), skinWeightAttr.getW(index))
        }

        // target 为 Vector3：_baseVector.set(...target, 1); target.set(0,0,0)
        let baseVector = Vector4(target.x, target.y, target.z, 1.0)
        target.set(0.0, 0.0, 0.0)

        // _baseVector.applyMatrix4(this.bindMatrix)
        baseVector.applyMatrix4(this.bindMatrix)

        // 逐 4 个权值加权混合 offsetMatrix（matrixWorld × boneInverses[i]）
        let matrix4 = Matrix4()
        let vector4 = Vector4()
        for (i in 0..4) {
            let weight = skinWeight.getComponent(Int64(i))
            if (weight != 0.0) {
                let boneIndex = Int64(skinIndex.getComponent(Int64(i)))
                // _matrix4.multiplyMatrices(skeleton.bones[boneIndex].matrixWorld, skeleton.boneInverses[boneIndex])
                let boneMatrixWorld = skeleton.bones[boneIndex].matrixWorld
                let boneInverse = skeleton.boneInverses[boneIndex]
                matrix4.multiplyMatrices(boneMatrixWorld, boneInverse)
                // target.addScaledVector(_vector4.copy(_baseVector).applyMatrix4(_matrix4), weight)
                vector4.copy(baseVector).applyMatrix4(matrix4)
                target.addScaledVector(Vector3(vector4.x, vector4.y, vector4.z), weight)
            }
        }

        // target.applyMatrix4(this.bindMatrixInverse) — 从髀骨空间换回本对象局部空间
        return target.applyMatrix4(this.bindMatrixInverse)
    }

    /**
     * @brief[zh-cn] 取指定顶点位置（蒙皮变换后），覆写 Mesh.getVertexPosition
     * @explain[zh-cn] SkinnedMesh override 为 applyBoneTransform 以应用蒙皮变形
     * @param[zh-cn] index 顶点索引
     * target 接收结果的目标向量
     * @return[zh-cn] 蒙皮变换后的顶点位置
     *
     * @brief[en] Get specified vertex position (after skinning transform), overrides Mesh.getVertexPosition
     * @explain[en] SkinnedMesh overrides to applyBoneTransform for skinning deformation
     * @param[en] index Vertex index
     * target Target vector to receive the result
     * @return[en] Vertex position after skinning transform
     */
    public override func getVertexPosition(index: Int64, target: Vector3): Vector3 {
        return this.applyBoneTransform(index, target)
    }

    /**
     * @brief[zh-cn] 射线相交检测（复用基类 Mesh.raycast，命中处 getVertexPosition 已被覆写为 applyBoneTransform）
     * @param[zh-cn] raycaster 射线发射器
     * intersects 命中结果累加数组
     *
     * @brief[en] Ray intersection test (reuses base Mesh.raycast, getVertexPosition overridden to applyBoneTransform)
     * @param[en] raycaster The raycaster
     * intersects Intersection result accumulator
     */
    public override func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        // 直接复用基类 Mesh.raycast：命中处 getVertexPosition 已被本类 override 为 applyBoneTransform
        super.raycast(raycaster, intersects)
    }

    /**
     * @brief[zh-cn] 使用 SkinningJob 批量蒙皮所有顶点
     * @explain[zh-cn] 从 skeleton 的 boneWorldMatrices 构建关节矩阵数组，
     *                  读取 geometry 的 skinIndex/skinWeight，
     *                  调用 SkinningJob 进行批量 CPU 蒙皮。
     *                  结果直接写入 geometry 的 position 属性。
     *
     * @brief[en] Skins all vertices in batch using SkinningJob
     * @explain[en] Builds the joint matrix array from the skeleton's boneWorldMatrices,
     *                  reads skinIndex/skinWeight from the geometry,
     *                  and invokes SkinningJob to perform batch CPU skinning.
     *                  Results are written directly into the geometry's position attribute.
     */
    @Zone[three.scene.entity.SkinnedMesh.applySkinningJob, name=applySkinningJob]
    public func applySkinningJob(): Unit {
        let geo = this.geometry
        let skeleton = this.skeleton
        let numBones = skeleton.bones.size

        // 构建关节矩阵数组：offset = bone.matrixWorld × boneInverse（世界姿势 × 逆绑定矩阵），
        // 每个矩阵 16 个 Float32（列主序）；缓冲与乘法对象复用，免逐帧分配
        let jointMatrices = if (let Some(buf) <- this._jointMatrixBuf) {
            if (buf.size == numBones * 16) {
                buf
            } else {
                let fresh = Array<Float32>(numBones * 16, { _ => 0.0f32 })
                this._jointMatrixBuf = Some(fresh)
                fresh
            }
        } else {
            let fresh = Array<Float32>(numBones * 16, { _ => 0.0f32 })
            this._jointMatrixBuf = Some(fresh)
            fresh
        }
        let mtx = this._matrixScratch
        for (b in 0..numBones) {
            mtx.multiplyMatrices(skeleton.bones[b].matrixWorld, skeleton.boneInverses[b])
            let dst = b * 16
            let src = mtx.elements
            for (e in 0..16) {
                jointMatrices[dst + e] = Float32(src[e])
            }
        }

        // 读取 skinIndex 和 skinWeight
        var idxAttrOpt = geo.getAttribute("skinIndex")
        var wgtAttrOpt = geo.getAttribute("skinWeight")

        if (let Some(idxAttr) <- idxAttrOpt && let Some(wgtAttr) <- wgtAttrOpt && let Some(posAttr) <- geo.getAttribute("position")) {
            let numVertices = idxAttr.count
            let numInfluences = 4

            // 位置输入：优先使用绑定姿势缓存，避免逐帧蒙皮结果累积变形
            let posArr = if (let Some(cached) <- this._bindPositions) {
                cached
            } else {
                let fresh = Array<Float32>(numVertices * 3, { _ => 0.0f32 })
                for (i in 0..numVertices) {
                    fresh[i * 3] = Float32(posAttr.getX(i))
                    fresh[i * 3 + 1] = Float32(posAttr.getY(i))
                    fresh[i * 3 + 2] = Float32(posAttr.getZ(i))
                }
                this._bindPositions = Some(fresh)
                fresh
            }

            // 法线输入：同样缓存绑定姿势法线
            var normalsOpt: ?Array<Float32> = None
            if (let Some(normAttr) <- geo.getAttribute("normal")) {
                normalsOpt = if (let Some(cached) <- this._bindNormals) {
                    Some(cached)
                } else {
                    let fresh = Array<Float32>(numVertices * 3, { _ => 0.0f32 })
                    for (i in 0..numVertices) {
                        fresh[i * 3] = Float32(normAttr.getX(i))
                        fresh[i * 3 + 1] = Float32(normAttr.getY(i))
                        fresh[i * 3 + 2] = Float32(normAttr.getZ(i))
                    }
                    this._bindNormals = Some(fresh)
                    Some(fresh)
                }
            }

            // 权重（关节索引 + 权重）是静态数据：首次构建后缓存复用
            let weights = if (let Some(cached) <- this._skinWeightsCache) {
                if (cached.jointIndices.size == numVertices * numInfluences) {
                    cached
                } else {
                    this._buildSkinWeights(idxAttr, wgtAttr, numVertices, numInfluences)
                }
            } else {
                this._buildSkinWeights(idxAttr, wgtAttr, numVertices, numInfluences)
            }

            let skinInput = SkinInput(numVertices, posArr, normals: normalsOpt)
            let job = SkinningJob()
            job.jointMatrices = jointMatrices
            job.weights = weights
            job.input = skinInput

            if (job.validate() && job.run()) {
                var resultPositions = job.output.positions
                // 写回 position：非归一化属性直接写底层数组（免逐顶点方法调用）
                let posData = posAttr.array
                let posStride = posAttr.itemSize
                if (posAttr.normalized) {
                    for (i in 0..numVertices) {
                        posAttr.setXYZ(i, Float64(resultPositions[i * 3]), Float64(resultPositions[i * 3 + 1]), Float64(resultPositions[i * 3 + 2]))
                    }
                } else {
                    for (i in 0..numVertices) {
                        let base = i * posStride
                        posData[base] = Float64(resultPositions[i * 3])
                        posData[base + 1] = Float64(resultPositions[i * 3 + 1])
                        posData[base + 2] = Float64(resultPositions[i * 3 + 2])
                    }
                }
                posAttr.version += 1
                if (let Some(normAttr) <- geo.getAttribute("normal")) {
                    if (let Some(resultNormals) <- job.output.normals) {
                        for (i in 0..numVertices) {
                            normAttr.setXYZ(i, Float64(resultNormals[i * 3]), Float64(resultNormals[i * 3 + 1]), Float64(resultNormals[i * 3 + 2]))
                        }
                        normAttr.version += 1
                    }
                }
            }
        }
    }

    /**
     * @brief[zh-cn] 由 skinIndex/skinWeight 属性构建蒙皮权重（首次调用时缓存）
     * @param[zh-cn] idxAttr skinIndex 属性
     * wgtAttr skinWeight 属性
     * numVertices 顶点数
     * numInfluences 影响数
     * @return[zh-cn] 构建好的权重对象
     *
     * @brief[en] Builds skin weights from the skinIndex/skinWeight attributes (cached on first use)
     * @param[en] idxAttr skinIndex attribute
     * wgtAttr skinWeight attribute
     * numVertices Number of vertices
     * numInfluences Number of influences
     * @return[en] The built weights object
     */
    private func _buildSkinWeights(idxAttr: BufferAttribute, wgtAttr: BufferAttribute,
                                   numVertices: Int64, numInfluences: Int): SkinWeights {
        let jointIndices = Array<Int16>(numVertices * numInfluences, { _ => 0i16 })
        let jointWeights = Array<Float32>(numVertices * numInfluences, { _ => 0.0f32 })
        for (v in 0..numVertices) {
            let base = v * numInfluences
            jointIndices[base] = Int16(idxAttr.getX(v))
            jointIndices[base + 1] = Int16(idxAttr.getY(v))
            jointIndices[base + 2] = Int16(idxAttr.getZ(v))
            jointIndices[base + 3] = Int16(idxAttr.getW(v))
            jointWeights[base] = Float32(wgtAttr.getX(v))
            jointWeights[base + 1] = Float32(wgtAttr.getY(v))
            jointWeights[base + 2] = Float32(wgtAttr.getZ(v))
            jointWeights[base + 3] = Float32(wgtAttr.getW(v))
        }
        let weights = SkinWeights(numInfluences, jointIndices, jointWeights)
        this._skinWeightsCache = Some(weights)
        return weights
    }

    /**
     * @brief[zh-cn] 将给定蒙皮网格实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given skinned mesh instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: SkinnedMesh =>
                this.bindMode = s.bindMode
                this.bindMatrix.copy(s.bindMatrix)
                this.bindMatrixInverse.copy(s.bindMatrixInverse)
                this.skeleton = s.skeleton
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新蒙皮网格实例
     * @return[zh-cn] 新蒙皮网格实例
     *
     * @brief[en] Return a new skinned mesh instance with the same values as this instance
     * @return[en] New skinned mesh instance
     */
    public override func clone(): Object3D {
        let obj = SkinnedMesh(geometry: BufferGeometry(), material: MeshBasicMaterial())
        return obj.copy(this, true)
    }
}
