/**
 * @file[zh-cn] Line
 * @brief[zh-cn] 线渲染对象，从一组顶点按顺序连接的连续折线
 * @explain[zh-cn] 与 LineSegments 不同：Line 把顶点序列当作一条连续折线（v0-v1-v2-...），
 * 而 LineSegments 把顶点两两配对为独立线段。本类继承 Object3D，
 * 支持 computeLineDistances（折线累计距离）和 raycast（射线-线段相交检测）。
 *
 * @file[en] Line
 * @brief[en] Line rendering object, a continuous polyline from vertices connected in order
 * @explain[en] Unlike LineSegments: Line treats the vertex sequence as a continuous polyline (v0-v1-v2-...),
 * whereas LineSegments pairs vertices into independent segments. This class extends Object3D,
 * supporting computeLineDistances (cumulative polyline distance) and raycast (ray-segment intersection).
 */
package three.scene.entity

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.rendering.interfaces.IGeometryProvider
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*
import std.math.*
import three.core.math.*
import three.rendering.materials.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 线渲染对象，从一组顶点按顺序连接的连续折线
 *
 * @brief[en] Line rendering object, a continuous polyline from vertices connected in order
 */
@JsonAdapter[withSuperClass = Object3D]
public open class Line <: Object3D {
    /**
     * @brief[zh-cn] 顶点/索引几何
     *
     * @brief[en] Vertex/index geometry
     */
    public var geometry: BufferGeometry

    /**
     * @brief[zh-cn] 线材质
     *
     * @brief[en] Line material
     */
    public var material: Material

    /**
     * @brief[zh-cn] 构造一个新的线渲染对象
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 线材质，默认空 LineBasicMaterial
     *
     * @brief[en] Construct a new line rendering object
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Line material, default empty LineBasicMaterial
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial()) {
        super()
        this.kind = "Line"
        this.geometry = geometry
        this.material = material
    }

    /**
     * @brief[zh-cn] 计算并写入几何的 lineDistance 属性（各顶点沿折线累计距离）
     * @explain[zh-cn] 仅在材质使用 lineDistance/lineDistanceStart 时需要
     * @return[zh-cn] 返回 this 以支持链式调用
     *
     * @brief[en] Compute and write lineDistance attribute to geometry (cumulative distance along polyline)
     * @explain[en] Only needed when material uses lineDistance/lineDistanceStart
     * @return[en] Returns this for method chaining
     */
    public open func computeLineDistances(): Line {
        let geometry = this.geometry
        // 仅在几何有 position 属性时计算
        match (geometry.getAttribute("position")) {
            case Some(positionAttr) =>
                let count = positionAttr.count
                if (count < 2) {
                    return this
                }
                // 与 JS side 一致：先创建/取 lineDistance 属性，逐顶点累加距离
                // 通过 setX/setY 逐顶点写入 lineDistance 值
                let lineDistanceAttr = match (geometry.getAttribute("lineDistance")) {
                    case Some(attr) => attr
                    case None =>
                        let newAttr = Float32BufferAttribute(Array<Float64>(count, { _ => 0.0 }), 1)
                        geometry.setAttribute("lineDistance", newAttr)
                        newAttr
                }
                lineDistanceAttr.setX(0, 0.0)
                var totalDistance: Float64 = 0.0
                for (i in 1..count) {
                    let x1 = positionAttr.getX(i - 1)
                    let y1 = positionAttr.getY(i - 1)
                    let z1 = positionAttr.getZ(i - 1)
                    let x2 = positionAttr.getX(i)
                    let y2 = positionAttr.getY(i)
                    let z2 = positionAttr.getZ(i)
                    let dx = x2 - x1
                    let dy = y2 - y1
                    let dz = z2 - z1
                    totalDistance += sqrt(dx * dx + dy * dy + dz * dz)
                    lineDistanceAttr.setX(i, totalDistance)
                }
            case None => ()
        }
        return this
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
     * @explain[zh-cn] 将射线变换到本对象局部空间，逐段调用 Ray.distanceSqToSegment 判定命中。
     * 仓颉侧 isLineSegments/isLineLoop 是子类字段，基类用 kind 字符串下行判断。
     * @param[zh-cn] raycaster 射线发射器
     * intersects 命中结果累加数组
     *
     * @brief[en] Ray intersection test
     * @explain[en] Transforms ray to local space, checks each segment via Ray.distanceSqToSegment.
     * isLineSegments/isLineLoop are subclass fields; base class uses kind string for dispatch.
     * @param[en] raycaster The raycaster
     * intersects Intersection result accumulator
     */
    public func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        let geometry = this.geometry
        let matrixWorld = this.matrixWorld
        // threshold: raycaster.params.Line.threshold（世界单位）
        // 仓颉：params 已具体化为 RaycasterParams（lineThreshold 字段）
        var threshold = raycaster.params.lineThreshold
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

        // step: LineSegments=2, Line/LineLoop=1；isLineLoop 闭合处理
        // 仓颉侧用 kind 字符串下行判断（基类无 isLineSegments/isLineLoop 标志）
        let isLineSegments = (this.kind == "LineSegments")
        let isLineLoop = (this.kind == "LineLoop")
        let step = if (isLineSegments) { 2 } else { 1 }

        let indexAttrOpt = geometry.index
        match (indexAttrOpt) {
            case Some(indexAttr) =>
                let start = if (drawRange[0] > 0) { drawRange[0] } else { 0 }
                let end = if (Int64(indexAttr.count) < drawRange[0] + drawRange[1]) { Int64(indexAttr.count) } else { drawRange[0] + drawRange[1] }
                var i = start
                while (i + 1 < end) {
                    let a = Int64(indexAttr.getX(i))
                    let b = Int64(indexAttr.getX(i + 1))
                    // checkIntersection
                    match (geometry.getAttribute("position")) {
                        case Some(positionAttr) =>
                            let vStart = Vector3(positionAttr.getX(a), positionAttr.getY(a), positionAttr.getZ(a))
                            let vEnd = Vector3(positionAttr.getX(b), positionAttr.getY(b), positionAttr.getZ(b))
                            let intersectPointOnRay = Vector3()
                            let intersectPointOnSegment = Vector3()
                            let distSq = ray.distanceSqToSegment(vStart, vEnd, optionalPointOnRay: Some(intersectPointOnRay), optionalPointOnSegment: Some(intersectPointOnSegment))
                            if (distSq > localThresholdSq) {
                                // 不命中
                            } else {
                                // Move back to world space for distance calculation
                                intersectPointOnRay.applyMatrix4(matrixWorld)
                                let distance = raycaster.ray.origin.distanceTo(intersectPointOnRay)
                                if (distance >= raycaster.near && distance <= raycaster.far) {
                                    // 对照 JS checkIntersection 命中对象：{distance, point, index, face:null, faceIndex:null, barycoord:null, object}
                                    let intersection = Intersection()
                                    intersection.distance = distance
                                    intersection.point = intersectPointOnSegment.clone().applyMatrix4(matrixWorld)
                                    intersection.index = i
                                    intersection.obj = Some(this)
                                    intersects.add(intersection)
                                }
                            }
                        case None => ()
                    }
                    i += step
                }
                // isLineLoop 闭合段：end-1 → start
                if (isLineLoop && end > start) {
                    let a = Int64(indexAttr.getX(end - 1))
                    let b = Int64(indexAttr.getX(start))
                    match (geometry.getAttribute("position")) {
                        case Some(positionAttr) =>
                            let vStart = Vector3(positionAttr.getX(a), positionAttr.getY(a), positionAttr.getZ(a))
                            let vEnd = Vector3(positionAttr.getX(b), positionAttr.getY(b), positionAttr.getZ(b))
                            let intersectPointOnRay = Vector3()
                            let intersectPointOnSegment = Vector3()
                            let distSq = ray.distanceSqToSegment(vStart, vEnd, optionalPointOnRay: Some(intersectPointOnRay), optionalPointOnSegment: Some(intersectPointOnSegment))
                            if (distSq <= localThresholdSq) {
                                intersectPointOnRay.applyMatrix4(matrixWorld)
                                let distance = raycaster.ray.origin.distanceTo(intersectPointOnRay)
                                if (distance >= raycaster.near && distance <= raycaster.far) {
                                    let intersection = Intersection()
                                    intersection.distance = distance
                                    intersection.point = intersectPointOnSegment.clone().applyMatrix4(matrixWorld)
                                    intersection.index = end - 1
                                    intersection.obj = Some(this)
                                    intersects.add(intersection)
                                }
                            }
                        case None => ()
                    }
                }
            case None =>
                // non-indexed
                match (geometry.getAttribute("position")) {
                    case Some(positionAttr) =>
                        let start = if (drawRange[0] > 0) { drawRange[0] } else { 0 }
                        let end = if (Int64(positionAttr.count) < drawRange[0] + drawRange[1]) { Int64(positionAttr.count) } else { drawRange[0] + drawRange[1] }
                        var i = start
                        while (i + 1 < end) {
                            let a = i
                            let b = i + 1
                            let vStart = Vector3(positionAttr.getX(a), positionAttr.getY(a), positionAttr.getZ(a))
                            let vEnd = Vector3(positionAttr.getX(b), positionAttr.getY(b), positionAttr.getZ(b))
                            let intersectPointOnRay = Vector3()
                            let intersectPointOnSegment = Vector3()
                            let distSq = ray.distanceSqToSegment(vStart, vEnd, optionalPointOnRay: Some(intersectPointOnRay), optionalPointOnSegment: Some(intersectPointOnSegment))
                            if (distSq <= localThresholdSq) {
                                intersectPointOnRay.applyMatrix4(matrixWorld)
                                let distance = raycaster.ray.origin.distanceTo(intersectPointOnRay)
                                if (distance >= raycaster.near && distance <= raycaster.far) {
                                    let intersection = Intersection()
                                    intersection.distance = distance
                                    intersection.point = intersectPointOnSegment.clone().applyMatrix4(matrixWorld)
                                    intersection.index = i
                                    intersection.obj = Some(this)
                                    intersects.add(intersection)
                                }
                            }
                            i += step
                        }
                        // isLineLoop 闭合段：end-1 → start
                        if (isLineLoop && end > start) {
                            let a = end - 1
                            let b = start
                            let vStart = Vector3(positionAttr.getX(a), positionAttr.getY(a), positionAttr.getZ(a))
                            let vEnd = Vector3(positionAttr.getX(b), positionAttr.getY(b), positionAttr.getZ(b))
                            let intersectPointOnRay = Vector3()
                            let intersectPointOnSegment = Vector3()
                            let distSq = ray.distanceSqToSegment(vStart, vEnd, optionalPointOnRay: Some(intersectPointOnRay), optionalPointOnSegment: Some(intersectPointOnSegment))
                            if (distSq <= localThresholdSq) {
                                intersectPointOnRay.applyMatrix4(matrixWorld)
                                let distance = raycaster.ray.origin.distanceTo(intersectPointOnRay)
                                if (distance >= raycaster.near && distance <= raycaster.far) {
                                    let intersection = Intersection()
                                    intersection.distance = distance
                                    intersection.point = intersectPointOnSegment.clone().applyMatrix4(matrixWorld)
                                    intersection.index = end - 1
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
     * @brief[zh-cn] 将给定线实例的值复制到本实例
     * @explain[zh-cn] open：允许 Line 子类（LineSegments/LineLoop 及 BoxHelper 等 helper）继续 override copy
     * @param[zh-cn] source 源对象
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given line instance to this instance
     * @explain[en] open: allows Line subclasses (LineSegments/LineLoop and BoxHelper etc.) to override copy
     * @param[en] source Source object
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public open override func copy(source: Object3D, recursive: Bool): Object3D {
        super.copy(source, recursive)
        match (source) {
            case l: Line =>
                this.geometry = l.geometry.clone()
                this.material = l.material.clone()
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新线实例
     * @return[zh-cn] 新线实例
     *
     * @brief[en] Return a new line instance with the same values as this instance
     * @return[en] New line instance
     */
    public override func clone(): Object3D {
        let obj = Line()
        return obj.copy(this, true)
    }

    /**
     * @brief[zh-cn] 提供本线几何体供裁剪/包围盒计算（覆写 Object3D 钩子）
     * @return[zh-cn] 本线几何体
     *
     * @brief[en] Provide this line geometry for culling/bounding box calculation (overrides Object3D hook)
     * @return[en] This line geometry
     */
    public override func getCullingGeometry(): Option<IGeometryProvider> {
        return Some(this.geometry)
    }
}
