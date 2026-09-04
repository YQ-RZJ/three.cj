/**
 * @file[zh-cn] 骨骼辅助对象
 * @brief[zh-cn] 骨骼辅助对象，用于可视化骨骼层级结构
 * @explain[zh-cn] 
 * 对应 Three.js helpers/SkeletonHelper.js。用线段连接父子骨骼，
 * 不同颜色区分不同骨骼段。
 *
 * @file[en] Skeleton Helper
 * @brief[en] Skeleton helper for visualizing bone hierarchy
 * @explain[en] 
 * Corresponds to Three.js helpers/SkeletonHelper.js. Connects parent-child bones
 * with line segments, using different colors for different bone segments.
 */
package three.rendering.helpers

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import std.collection.*

/**
 * @brief[zh-cn] 骨骼辅助对象，用于可视化 Skeleton 骨骼层级
 * @explain[zh-cn] 
 * 用线段连接父子骨骼，不同颜色区分不同骨骼段。
 *
 * @brief[en] Skeleton helper for visualizing Skeleton bone hierarchy
 * @explain[en] 
 * Connects parent-child bones with line segments, using different colors for different bone segments.
 */
public class SkeletonHelper <: LineSegments {
    /**
     * @brief[zh-cn] 根对象
     *
     * @brief[en] Root object
     */
    public var root: Object3D

    /**
     * @brief[zh-cn] 骨骼列表
     *
     * @brief[en] Bone list
     */
    public var bones: ArrayList<Bone>

    /**
     * @brief[zh-cn] 构造骨骼辅助对象
     * @param[zh-cn] object 骨骼层级根对象，通常是 SkinnedMesh 或包含 Bone 的 Object3D
     *
     * @brief[en] Construct a skeleton helper
     * @param[en] object Root object of the bone hierarchy, typically a SkinnedMesh or Object3D containing Bones
     */
    public init(object: Object3D) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.kind = "SkeletonHelper"
        this.root = object
        this.bones = getBoneList(object)
        this.matrix = object.matrixWorld
        this.matrixAutoUpdate = false

        
        // 缺 vertexColors 时 color 属性不参与渲染；缺 transparent/depth 标志时骨骼线被深度遮挡
        this.material.vertexColors = true
        this.material.depthTest = false
        this.material.depthWrite = false
        this.material.transparent = true

        let vertices = ArrayList<Float64>()
        let colors = ArrayList<Float64>()

        for (i in 0..this.bones.size) {
            let bone = this.bones[i]
            
            if (bone.parent.isSome() && isBoneObject(bone.parent.getOrThrow())) {
                vertices.add(0.0); vertices.add(0.0); vertices.add(0.0)
                vertices.add(0.0); vertices.add(0.0); vertices.add(0.0)
                colors.add(0.0); colors.add(0.0); colors.add(0.0)
                colors.add(0.0); colors.add(0.0); colors.add(0.0)
            }
        }

        this.geometry.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.geometry.setAttribute("color", BufferAttribute(colors.toArray(), 3))

        
        this.setColors(Color(0x0000ff), Color(0x00ff00))
    }

    /**
     * @brief[zh-cn] 更新矩阵世界，计算骨骼位置
     * @param[zh-cn] force 是否强制更新
     *
     * @brief[en] Update world matrix, computing bone positions
     * @param[en] force Whether to force update
     */
    public override func updateMatrixWorld(force: Bool): Unit {
        let bones = this.bones
        let geometry = this.geometry
        let position = geometry.getAttribute("position")
        let matrixWorldInv = Matrix4().copy(this.root.matrixWorld).invert()
        let boneMatrix = Matrix4()
        let vector = Vector3()

        match (position) {
            case Some(pos) =>
                var j = 0
                for (i in 0..bones.size) {
                    let bone = bones[i]
                    
                    if (bone.parent.isSome() && isBoneObject(bone.parent.getOrThrow())) {
                        boneMatrix.multiplyMatrices(matrixWorldInv, bone.matrixWorld)
                        vector.setFromMatrixPosition(boneMatrix)
                        pos.setXYZ(j, vector.x, vector.y, vector.z)
                        boneMatrix.multiplyMatrices(matrixWorldInv, bone.parent.getOrThrow().matrixWorld)
                        vector.setFromMatrixPosition(boneMatrix)
                        pos.setXYZ(j + 1, vector.x, vector.y, vector.z)
                        j += 2
                    }
                }
                pos.version += 1
            case None => ()
        }
        super.updateMatrixWorld(force)
    }

    /**
     * @brief[zh-cn] 设置骨骼颜色
     * @param[zh-cn] color1 起始颜色（蓝色 0x0000ff）
     * color2 结束颜色（绿色 0x00ff00）
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set bone colors
     * @param[en] color1 Start color (blue 0x0000ff)
     * color2 End color (green 0x00ff00)
     * @return[en] Self reference
     */
    public func setColors(color1: Color, color2: Color): SkeletonHelper {
        let geometry = this.geometry
        let colorAttribute = geometry.getAttribute("color")
        match (colorAttribute) {
            case Some(attr) =>
                var i = 0
                while (i < attr.count) {
                    attr.setXYZ(i, color1.r, color1.g, color1.b)
                    attr.setXYZ(i + 1, color2.r, color2.g, color2.b)
                    i += 2
                }
                attr.version += 1
            case None => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.geometry.dispose()
        this.material.dispose()
    }
}

/**
 * @brief[zh-cn] 递归收集骨骼列表
 * @param[zh-cn] object 要遍历的对象
 * @return[zh-cn] 骨骼数组
 *
 * @brief[en] Recursively collect bone list
 * @param[en] object Object to traverse
 * @return[en] Bone array
 */
func getBoneList(object: Object3D): ArrayList<Bone> {
    let boneList = ArrayList<Bone>()
    match (object) {
        case b: Bone => boneList.add(b)
        case _ => ()
    }
    for (i in 0..object.children.size) {
        let childBones = getBoneList(object.children[i])
        for (b in childBones) {
            boneList.add(b)
        }
    }
    return boneList
}

/**
 * @brief[zh-cn] 判断对象是否为 Bone
 * @param[zh-cn] object 要判断的对象
 * @return[zh-cn] 是否为 Bone
 *
 * @brief[en] Check if the object is a Bone
 * @param[en] object Object to check
 * @return[en] Whether the object is a Bone
 */
func isBoneObject(object: Object3D): Bool {
    match (object) {
        case _: Bone => true
        case _ => false
    }
}
