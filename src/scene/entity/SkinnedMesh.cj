/**
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
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 蒙皮网格，带骨骼蒙皮变形的 Mesh
 * @explain[zh-cn] bindMatrix/bindMatrixInverse 定义绑定姿势；bindMode 控制 Attached/Detached 模式
 *
 * @brief[en] Skinned mesh, a Mesh with bone skinning deformation
 * @explain[en] bindMatrix/bindMatrixInverse define bind pose; bindMode controls Attached/Detached mode
 */
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
     * @brief[zh-cn] 绑定姿势矩阵的逆
     *
     * @brief[en] Inverse of the bind pose matrix
     */
    public var bindMatrixInverse: Matrix4

    /**
     * @brief[zh-cn] 构造一个新的蒙皮网格
     * @param[zh-cn] geometry 顶点/索引几何
     * material 材质
     *
     * @brief[en] Construct a new skinned mesh
     * @param[en] geometry Vertex/index geometry
     * material Material
     */
    public init(geometry: BufferGeometry, material: Material) {
        super(geometry: geometry, material: material)
        this.kind = "SkinnedMesh"
        this.bindMode = AttachedBindMode
        this.bindMatrix = Matrix4()
        this.bindMatrixInverse = Matrix4()
        this.skeleton = Skeleton()
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
        match (bindMatrix) {
            case Some(m) => this.bindMatrix.copy(m)
            case None =>
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
        match (geo.getAttribute("skinWeight")) {
            case Some(skinWeight) =>
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
            case None => ()
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
        match (this.geometry.boundingBox) {
            case Some(_) => ()
            case None => this.geometry.computeBoundingBox()
        }
    }

    /**
     * @brief[zh-cn] 计算几何包围球
     *
     * @brief[en] Compute geometry bounding sphere
     */
    public func computeBoundingSphere(): Unit {
        match (this.geometry.boundingSphere) {
            case Some(_) => ()
            case None => this.geometry.computeBoundingSphere()
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
        match (geometry.getAttribute("skinIndex")) {
            case Some(skinIndexAttr) =>
                skinIndex = skinIndex.set(skinIndexAttr.getX(index), skinIndexAttr.getY(index), skinIndexAttr.getZ(index), skinIndexAttr.getW(index))
            case None => ()
        }
        match (geometry.getAttribute("skinWeight")) {
            case Some(skinWeightAttr) =>
                skinWeight = skinWeight.set(skinWeightAttr.getX(index), skinWeightAttr.getY(index), skinWeightAttr.getZ(index), skinWeightAttr.getW(index))
            case None => ()
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
        let obj = SkinnedMesh(BufferGeometry(), Material())
        return obj.copy(this, true)
    }
}