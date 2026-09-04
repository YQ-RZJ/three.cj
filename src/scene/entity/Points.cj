/**
 * @file[zh-cn] Points
 * @brief[zh-cn] 点集渲染对象，将一组顶点渲染为独立像素方块
 * @explain[zh-cn] 常用于粒子、点云、3D 扫描数据等。各顶点的大小由 material.size 决定，
 * material.sizeAttenuation 控制是否远小近大。继承 Object3D；
 * raycast 退化为按射线到顶点的距离判定（threshold 阈值内）。
 *
 * @file[en] Points
 * @brief[en] Points rendering object, renders a set of vertices as independent pixel squares
 * @explain[en] Commonly used for particles, point clouds, 3D scan data, etc. Vertex size determined by material.size,
 * material.sizeAttenuation controls distance attenuation. Extends Object3D;
 * raycast degenerates to distance-based threshold check from ray to vertex.
 */
package three.scene.entity
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.rendering.interfaces.IGeometryProvider
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 点集渲染对象，将一组顶点渲染为独立像素方块
 * @explain[zh-cn] 常用于粒子、点云、3D 扫描数据等，raycast 退化为距离阈值判定
 *
 * @brief[en] Points rendering object, renders a set of vertices as independent pixel squares
 * @explain[en] Commonly used for particles, point clouds, 3D scan data; raycast degenerates to distance threshold check
 */
@JsonAdapter[withSuperClass = Object3D]
public class Points <: Object3D {
    /**
     * @brief[zh-cn] 顶点/索引几何
     *
     * @brief[en] Vertex/index geometry
     */
    public var geometry: BufferGeometry

    /**
     * @brief[zh-cn] 点材质
     *
     * @brief[en] Points material
     */
    public var material: Material

    /**
     * @brief[zh-cn] morph target 名称→索引字典（动画混合形状）
     *
     * @brief[en] morph target name→index dictionary (animation blend shapes)
     */
    public var morphTargetDictionary: HashMap<String, Int64>

    /**
     * @brief[zh-cn] morph target 影响系数数组
     *
     * @brief[en] morph target influence coefficients array
     */
    public var morphTargetInfluences: Array<Float64>

    /**
     * @brief[zh-cn] 构造一个新的点集
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 点材质，默认空 Material
     *
     * @brief[en] Construct a new points set
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Points material, default empty Material
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material()) {
        super()
        this.kind = "Points"
        this.geometry = geometry
        this.material = material
        this.morphTargetDictionary = HashMap<String, Int64>()
        this.morphTargetInfluences = Array<Float64>()
    }

    /**
     * @brief[zh-cn] 将给定点集实例的值复制到本实例
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given points instance to this instance
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case s: Points =>
                this.geometry = s.geometry.clone()
                this.material = s.material.clone()
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新点集实例
     * @return[zh-cn] 新点集实例
     *
     * @brief[en] Return a new points instance with the same values as this instance
     * @return[en] New points instance
     */
    public override func clone(): Object3D {
        let obj = Points()
        return obj.copy(this, true)
    }

    /**
     * @brief[zh-cn] 更新 morph target 字典与影响系数
     * @explain[zh-cn] 从 geometry.morphAttributes.position 取所有 morph 顶点属性，填充字典与系数数组
     *
     * @brief[en] Update morph target dictionary and influence coefficients
     * @explain[en] Extracts all morph vertex attributes from geometry.morphAttributes.position to fill dictionary and coefficient array
     */
    public func updateMorphTargets(): Unit {
        let morphAttributes = this.geometry.morphAttributes
        match (morphAttributes.get("position")) {
            case Some(attrArr) =>
                // morphAttributes.position 是 ArrayList<BufferAttribute>，逐项建字典
                this.morphTargetInfluences = Array<Float64>(attrArr.size, { _ => 0.0 })
                this.morphTargetDictionary = HashMap<String, Int64>()
                for (i in 0..attrArr.size) {
                    // 与 JS side 一致：用 morphAttribute.name 或 "morphTarget" + i 作为键
                    let name = "morphTarget" + i.toString()
                    this.morphTargetDictionary.add(name, i)
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 视锥剔除测试
     * @param[zh-cn] frustum 视锥体
     * @return[zh-cn] 与视锥相交返回 true
     *
     * @brief[en] Frustum culling test
     * @param[en] frustum The frustum
     * @return[en] Returns true if intersects with frustum
     */
    public func intersectsFrustum(frustum: Frustum): Bool {
        return frustum.intersectsObject(this)
    }

    /**
     * @brief[zh-cn] 射线相交检测
     * @explain[zh-cn] 将射线变换到本对象局部空间，逐顶点测试到射线的距离是否 ≤ threshold。
     * @param[zh-cn] raycaster 射线发射器
     * intersects 命中结果累加数组
     *
     * @brief[en] Ray intersection test
     * @explain[en] Transforms ray to local space, tests distance from ray to each vertex against threshold.
     * @param[en] raycaster The raycaster
     * intersects Intersection result accumulator
     */
    public func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        let geometry = this.geometry
        let matrixWorld = this.matrixWorld

        // threshold: raycaster.params.Points.threshold（世界单位）
        // 仓颉：params 已具体化为 RaycasterParams（pointsThreshold 字段）
        var threshold = raycaster.params.pointsThreshold
        let drawRange = geometry.drawRange

        // Checking boundingSphere distance to ray
        
        match (geometry.boundingSphere) {
            case None => geometry.computeBoundingSphere()
            case Some(_) => ()
        }
        let sphere = Sphere()
        match (geometry.boundingSphere) {
            case Some(bs) =>
                sphere.copy(bs)
                sphere.applyMatrix4(matrixWorld)
                sphere.radius = sphere.radius + threshold
                if (raycaster.ray.intersectsSphere(sphere) == false) { return }
            case None => return
        }

        // transform ray to local space
        let invMatrix = Matrix4().copy(matrixWorld).invert()
        let ray = Ray().copy(raycaster.ray)
        ray.applyMatrix4(invMatrix)

        // localThreshold = threshold / ((scale.x + scale.y + scale.z) / 3)
        let scaleSum = this.scale.x + this.scale.y + this.scale.z
        let localThreshold = threshold / (scaleSum / 3.0)
        let localThresholdSq = localThreshold * localThreshold

        // index / non-index 分支
        match (geometry.index) {
            case Some(indexAttr) =>
                let start = if (drawRange[0] > 0) { drawRange[0] } else { 0 }
                let end = if (Int64(indexAttr.count) < drawRange[0] + drawRange[1]) { Int64(indexAttr.count) } else { drawRange[0] + drawRange[1] }
                for (i in start..end) {
                    let a = Int64(indexAttr.getX(i))
                    // _position.fromBufferAttribute(positionAttribute, a) — 仓颉侧用 getX/Y/Z 拼装
                    let position = Vector3()
                    match (geometry.getAttribute("position")) {
                        case Some(posAttr) =>
                            position.set(posAttr.getX(a), posAttr.getY(a), posAttr.getZ(a))
                        case None => ()
                    }
                    // testPoint：rayPointDistanceSq < localThresholdSq 时命中
                    let rayPointDistanceSq = ray.distanceSqToPoint(position)
                    if (rayPointDistanceSq < localThresholdSq) {
                        let intersectPoint = Vector3()
                        ray.closestPointToPoint(position, intersectPoint)
                        intersectPoint.applyMatrix4(matrixWorld)
                        let distance = raycaster.ray.origin.distanceTo(intersectPoint)
                        if (distance >= raycaster.near && distance <= raycaster.far) {
                            // 对照 JS testPoint 命中对象：{distance, distanceToRay, point, index, face:null, faceIndex:null, barycoord:null, object}
                            let intersection = Intersection()
                            intersection.distance = distance
                            intersection.distanceToRay = sqrt(rayPointDistanceSq)
                            intersection.point = intersectPoint
                            intersection.index = a
                            intersection.obj = Some(this)
                            intersects.add(intersection)
                        }
                    }
                }
            case None =>
                match (geometry.getAttribute("position")) {
                    case Some(positionAttr) =>
                        let start = if (drawRange[0] > 0) { drawRange[0] } else { 0 }
                        let end = if (Int64(positionAttr.count) < drawRange[0] + drawRange[1]) { Int64(positionAttr.count) } else { drawRange[0] + drawRange[1] }
                        for (i in start..end) {
                            // _position.fromBufferAttribute(positionAttribute, i) — 仓颉侧用 getX/Y/Z 拼装
                            let position = Vector3(positionAttr.getX(i), positionAttr.getY(i), positionAttr.getZ(i))
                            // testPoint：rayPointDistanceSq < localThresholdSq 时命中
                            let rayPointDistanceSq = ray.distanceSqToPoint(position)
                            if (rayPointDistanceSq < localThresholdSq) {
                                let intersectPoint = Vector3()
                                ray.closestPointToPoint(position, intersectPoint)
                                intersectPoint.applyMatrix4(matrixWorld)
                                let distance = raycaster.ray.origin.distanceTo(intersectPoint)
                                if (distance >= raycaster.near && distance <= raycaster.far) {
                                    // 对照 JS testPoint 命中对象：{distance, distanceToRay, point, index, face:null, faceIndex:null, barycoord:null, object}
                                    let intersection = Intersection()
                                    intersection.distance = distance
                                    intersection.distanceToRay = sqrt(rayPointDistanceSq)
                                    intersection.point = intersectPoint
                                    intersection.index = i
                                    intersection.obj = Some(this)
                                    intersects.add(intersection)
                                }
                            }
                        }
                    case None => ()
                }
        }
    }

    /**
     * @brief[zh-cn] 提供本点云几何体供裁剪/包围盒计算（覆写 Object3D 钩子）
     * @return[zh-cn] 本点云几何体
     *
     * @brief[en] Provide this point cloud geometry for culling/bounding box calculation (overrides Object3D hook)
     * @return[en] This point cloud geometry
     */
    public override func getCullingGeometry(): Option<IGeometryProvider> {
        return Some(this.geometry)
    }
}
