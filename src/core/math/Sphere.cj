/**
 * @file[zh-cn] Sphere
 * @brief[zh-cn] 球体
 * @explain[zh-cn] 表示三维空间中的球体。
 *
 * @file[en] Sphere
 * @brief[en] Sphere
 * @explain[en] Represents a sphere in 3D space.
 */
package three.core.math

import std.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 球体类，用中心点和半径表示
 *
 * @brief[en] Sphere class, represented by center and radius
 */
@JsonAdapter
public class Sphere {
    /**
     * @brief[zh-cn] 球心
     *
     * @brief[en] Center
     */
    public var center: Vector3
    /**
     * @brief[zh-cn] 半径
     *
     * @brief[en] Radius
     */
    public var radius: Float64

    public init() {
        this.center = Vector3()
        this.radius = -1.0
    }

    public init(center: Vector3, radius: Float64) {
        this.center = center.clone()
        this.radius = radius
    }

    /**
     * @brief[zh-cn] 设置球体的中心和半径
     * @param[zh-cn] center 球心
     * radius 半径
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the center and radius of the sphere
     * @param[en] center Center
     * radius Radius
     * @return[en] This instance
     */
    public func set(center: Vector3, radius: Float64): Sphere {
        this.center.copy(center)
        this.radius = radius
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前球体
     * @return[zh-cn] 新的球体实例
     *
     * @brief[en] Clone current sphere
     * @return[en] New sphere instance
     */
    public func clone(): Sphere {
        return Sphere(this.center, this.radius)
    }

    /**
     * @brief[zh-cn] 复制另一个球体的值到当前实例
     * @param[zh-cn] s 源球体
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another sphere to this instance
     * @param[en] s Source sphere
     * @return[en] This instance
     */
    public func copy(s: Sphere): Sphere {
        this.center.copy(s.center)
        this.radius = s.radius
        return this
    }

    /**
     * @brief[zh-cn] 将球体置空（半径设为 -1）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Make the sphere empty (set radius to -1)
     * @return[en] This instance
     */
    public func makeEmpty(): Sphere {
        this.center.set(0.0, 0.0, 0.0)
        this.radius = -1.0
        return this
    }

    /**
     * @brief[zh-cn] 判断球体是否为空
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Check if the sphere is empty
     * @return[en] Whether empty
     */
    public func isEmpty(): Bool {
        return this.radius < 0.0
    }

    /**
     * @brief[zh-cn] 判断点是否在球体内
     * @param[zh-cn] point 目标点
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if point is inside the sphere
     * @param[en] point Target point
     * @return[en] Whether contained
     */
    public func containsPoint(point: Vector3): Bool {
        return point.distanceToSquared(this.center) <= this.radius * this.radius
    }

    /**
     * @brief[zh-cn] 计算点到球面的距离
     * @param[zh-cn] point 目标点
     * @return[zh-cn] 距离
     *
     * @brief[en] Compute distance from point to sphere surface
     * @param[en] point Target point
     * @return[en] Distance
     */
    public func distanceToPoint(point: Vector3): Float64 {
        return point.distanceTo(this.center) - this.radius
    }

    /**
     * @brief[zh-cn] 判断是否与另一个球体相交
     * @param[zh-cn] s 另一个球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if intersects with another sphere
     * @param[en] s Another sphere
     * @return[en] Whether intersecting
     */
    public func intersectsSphere(s: Sphere): Bool {
        let rad = this.radius + s.radius
        return this.center.distanceToSquared(s.center) <= rad * rad
    }

    /**
     * @brief[zh-cn] 判断是否与平面相交
     * @param[zh-cn] plane 平面
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if intersects with a plane
     * @param[en] plane Plane
     * @return[en] Whether intersecting
     */
    public func intersectsPlane(plane: Plane): Bool {
        return abs(plane.distanceToPoint(this.center)) <= this.radius
    }

    /**
     * @brief[zh-cn] 判断是否与包围盒相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if intersects with a bounding box
     * @param[en] box Bounding box
     * @return[en] Whether intersecting
     */
    public func intersectsBox(box: Box3): Bool {
        return box.intersectsSphere(this)
    }

    /**
     * @brief[zh-cn] 将点限制在球面上
     * @param[zh-cn] point 点
     * target 目标向量
     * @return[zh-cn] 限制后的点
     *
     * @brief[en] Clamp point to sphere surface
     * @param[en] point Point
     * target Target vector
     * @return[en] Clamped point
     */
    public func clampPoint(point: Vector3, target: Vector3): Vector3 {
        let deltaLengthSq = this.center.distanceToSquared(point)
        if (deltaLengthSq > this.radius * this.radius) {
            target.copy(point).sub(this.center).normalize().multiplyScalar(this.radius).add(this.center)
        } else {
            target.copy(point)
        }
        return target
    }

    /**
     * @brief[zh-cn] 获取球体的包围盒（创建新包围盒）
     * @return[zh-cn] 包围盒
     *
     * @brief[en] Get bounding box of the sphere (creates new box)
     * @return[en] Bounding box
     */
    public func getBoundingBox(): Box3 {
        return this.getBoundingBox(Box3())
    }

    /**
     * @brief[zh-cn] 获取球体的包围盒
     * @param[zh-cn] target 目标包围盒
     * @return[zh-cn] 包围盒
     *
     * @brief[en] Get bounding box of the sphere
     * @param[en] target Target bounding box
     * @return[en] Bounding box
     */
    public func getBoundingBox(target: Box3): Box3 {
        if (this.isEmpty()) {
            target.makeEmpty()
        } else {
            target.set(this.center, this.center)
            target.expandByScalar(this.radius)
        }
        return target
    }

    /**
     * @brief[zh-cn] 应用 4x4 矩阵变换球体
     * @param[zh-cn] matrix 变换矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply 4x4 matrix transformation to sphere
     * @param[en] matrix Transformation matrix
     * @return[en] This instance
     */
    public func applyMatrix4(matrix: Matrix4): Sphere {
        this.center.applyMatrix4(matrix)
        this.radius *= Vector3(matrix.elements[0], matrix.elements[1], matrix.elements[2]).length()
        return this
    }

    /**
     * @brief[zh-cn] 从点集设置球体
     * @param[zh-cn] points 点集合
     * optionalCenter 可选的中心点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set sphere from point set
     * @param[en] points Point collection
     * optionalCenter Optional center point
     * @return[en] This instance
     */
    public func setFromPoints(points: ArrayList<Vector3>, optionalCenter!: Option<Vector3> = None): Sphere {
        let center = match (optionalCenter) {
            case Some(c) => c
            case None => this.center
        }
        var maxRadiusSq = 0.0
        for (p in points) {
            let d = center.distanceToSquared(p)
            if (d > maxRadiusSq) {
                maxRadiusSq = d
            }
        }
        this.center.copy(center)
        this.radius = sqrt(maxRadiusSq)
        return this
    }

    /**
     * @brief[zh-cn] 平移球体
     * @param[zh-cn] offset 偏移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Translate sphere
     * @param[en] offset Offset
     * @return[en] This instance
     */
    public func translate(offset: Vector3): Sphere {
        this.center.add(offset)
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个球体相等
     * @param[zh-cn] s 比较的球体
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another sphere
     * @param[en] s Sphere to compare
     * @return[en] Whether equal
     */
    public func equals(s: Sphere): Bool {
        return this.center.equals(s.center) && this.radius == s.radius
    }

    /**
     * @brief[zh-cn] 扩展球体以包含给定点
     * @param[zh-cn] point 要包含的点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Expand sphere to include a given point
     * @param[en] point Point to include
     * @return[en] This instance
     */
    public func expandByPoint(point: Vector3): Sphere {
        if (this.isEmpty()) {
            this.center.copy(point)
            this.radius = 0.0
            return this
        }

        let v1 = Vector3().subVectors(point, this.center)
        let lengthSq = v1.lengthSq()

        if (lengthSq > (this.radius * this.radius)) {
            // 计算最小包围球
            let length = sqrt(lengthSq)
            let delta = (length - this.radius) * 0.5
            this.center.addScaledVector(v1, delta / length)
            this.radius += delta
        }

        return this
    }

    /**
     * @brief[zh-cn] 扩展球体以包含另一个球体
     * @param[zh-cn] sphere 要包含的球体
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Expand sphere to include another sphere
     * @param[en] sphere Sphere to include
     * @return[en] This instance
     */
    public func union(sphere: Sphere): Sphere {
        if (sphere.isEmpty()) {
            return this
        }

        if (this.isEmpty()) {
            this.copy(sphere)
            return this
        }

        if (this.center.equals(sphere.center)) {
            this.radius = max(this.radius, sphere.radius)
        } else {
            let v2 = Vector3().subVectors(sphere.center, this.center).setLength(sphere.radius)
            this.expandByPoint(Vector3().copy(sphere.center).add(v2))
            this.expandByPoint(Vector3().copy(sphere.center).sub(v2))
        }

        return this
    }

    /**
     * @brief[zh-cn] 从 JSON 反序列化设置包围球
     * @explain[zh-cn] 从 JSON HashMap 中反序列化包围球的中心坐标和半径，并更新当前实例
     * @param[zh-cn] json 序列化的包围球 HashMap
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Deserialize sphere from JSON
     * @explain[en] Deserializes sphere center and radius from a JSON HashMap and updates this instance
     * @param[en] json Serialized bounding sphere HashMap
     * @return[en] Reference to this instance
     */
    public func fromJSON(json: HashMap<String, Any>): Sphere {
        match (json.get("radius")) {
            case Some(r) =>
                match (r) {
                    case v: Float64 => this.radius = v
                    case i: Int64 => this.radius = Float64(i)
                    case _ => ()
                }
            case None => ()
        }
        match (json.get("center")) {
            case Some(c) =>
                match (c) {
                    case arr: Array<Float64> => this.center.fromArray(arr)
                    case list: ArrayList<Any> =>
                        let a = Array<Float64>(list.size, { _ => 0.0 })
                        for (i in 0..list.size) {
                            match (list[i]) {
                                case v: Float64 => a[i] = v
                                case n: Int64 => a[i] = Float64(n)
                                case _ => ()
                            }
                        }
                        this.center.fromArray(a)
                    case _ => ()
                }
            case None => ()
        }
        return this
    }
}
