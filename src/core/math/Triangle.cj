/**
 * @file[zh-cn] Triangle
 * @brief[zh-cn] 三角形
 * @explain[zh-cn] 表示三维空间中的三角形，由三个顶点定义。
 *
 * @file[en] Triangle
 * @brief[en] Triangle
 * @explain[en] Represents a triangle in 3D space, defined by three vertices.
 */
package three.core.math

import std.math.*
import three.core.interfaces.*

/**
 * @brief[zh-cn] 三角形类，由三个顶点定义
 *
 * @brief[en] Triangle class, defined by three vertices
 */
public class Triangle {
    /**
     * @brief[zh-cn] 顶点 a
     *
     * @brief[en] Vertex a
     */
    public var a: Vector3
    /**
     * @brief[zh-cn] 顶点 b
     *
     * @brief[en] Vertex b
     */
    public var b: Vector3
    /**
     * @brief[zh-cn] 顶点 c
     *
     * @brief[en] Vertex c
     */
    public var c: Vector3

    /**
     * @brief[zh-cn] 默认构造函数，初始化三个零向量顶点
     *
     * @brief[en] Default constructor, initializes three zero-vector vertices
     */
    public init() {
        this.a = Vector3()
        this.b = Vector3()
        this.c = Vector3()
    }

    /**
     * @brief[zh-cn] 使用指定顶点构造三角形
     * @param[zh-cn] a 顶点 a
     * b 顶点 b
     * c 顶点 c
     *
     * @brief[en] Construct triangle with specified vertices
     * @param[en] a Vertex a
     * b Vertex b
     * c Vertex c
     */
    public init(a: Vector3, b: Vector3, c: Vector3) {
        this.a = a.clone()
        this.b = b.clone()
        this.c = c.clone()
    }

    /**
     * @brief[zh-cn] 静态方法：计算三角形法向量
     * @param[zh-cn] a 顶点 a
     * b 顶点 b
     * c 顶点 c
     * target 目标向量
     * @return[zh-cn] 法向量
     *
     * @brief[en] Static method: compute triangle normal
     * @param[en] a Vertex a
     * b Vertex b
     * c Vertex c
     * target Target vector
     * @return[en] Normal vector
     */
    public static func computeNormal(a: Vector3, b: Vector3, c: Vector3, target: Vector3): Vector3 {
        target.subVectors(c, b)
        let v0 = Vector3().subVectors(a, b)
        target.cross(v0)
        let targetLengthSq = target.lengthSq()
        if (targetLengthSq > 0.0) {
            return target.multiplyScalar(1.0 / sqrt(targetLengthSq))
        }
        return target.set(0.0, 0.0, 0.0)
    }

    /**
     * @brief[zh-cn] 静态方法：计算重心坐标
     * @param[zh-cn] point 点
     * a 顶点 a
     * b 顶点 b
     * c 顶点 c
     * target 目标向量
     * @return[zh-cn] 重心坐标，退化三角形返回 None
     *
     * @brief[en] Static method: compute barycentric coordinates
     * @param[en] point Point
     * a Vertex a
     * b Vertex b
     * c Vertex c
     * target Target vector
     * @return[en] Barycentric coordinates, returns None for degenerate triangles
     */
    public static func computeBarycoord(point: Vector3, a: Vector3, b: Vector3, c: Vector3, target: Vector3): Option<Vector3> {
        let v0 = Vector3().subVectors(c, a)
        let v1 = Vector3().subVectors(b, a)
        let v2 = Vector3().subVectors(point, a)
        let dot00 = v0.dot(v0)
        let dot01 = v0.dot(v1)
        let dot02 = v0.dot(v2)
        let dot11 = v1.dot(v1)
        let dot12 = v1.dot(v2)
        let denom = dot00 * dot11 - dot01 * dot01
        // 共线或退化三角形
        if (denom == 0.0) {
            target.set(0.0, 0.0, 0.0)
            return None
        }
        let invDenom = 1.0 / denom
        let u = (dot11 * dot02 - dot01 * dot12) * invDenom
        let v = (dot00 * dot12 - dot01 * dot02) * invDenom
        // 重心坐标之和始终为 1
        return Some(target.set(1.0 - u - v, v, u))
    }

    /**
     * @brief[zh-cn] 静态方法：判断点是否在三角形内
     * @param[zh-cn] point 点
     * a 顶点 a
     * b 顶点 b
     * c 顶点 c
     * @return[zh-cn] 是否在三角形内
     *
     * @brief[en] Static method: test if a point is inside the triangle
     * @param[en] point Point
     * a Vertex a
     * b Vertex b
     * c Vertex c
     * @return[en] Whether the point is inside the triangle
     */
    public static func testContainsPoint(point: Vector3, a: Vector3, b: Vector3, c: Vector3): Bool {
        let v3 = Vector3()
        let result = Triangle.computeBarycoord(point, a, b, c, v3)
        if (result.isNone()) { return false }
        return (v3.x >= 0.0) && (v3.y >= 0.0) && ((v3.x + v3.y) <= 1.0)
    }

    /**
     * @brief[zh-cn] 静态方法：使用重心坐标插值
     * @param[zh-cn] point 插值点位置
     * p1 顶点 1
     * p2 顶点 2
     * p3 顶点 3
     * v1 顶点 1 的值
     * v2 顶点 2 的值
     * v3 顶点 3 的值
     * target 目标向量
     * @return[zh-cn] 插值结果，退化三角形返回 None
     *
     * @brief[en] Static method: interpolate using barycentric coordinates
     * @param[en] point Interpolation point position
     * p1 Vertex 1
     * p2 Vertex 2
     * p3 Vertex 3
     * v1 Value at vertex 1
     * v2 Value at vertex 2
     * v3 Value at vertex 3
     * target Target vector
     * @return[en] Interpolation result, returns None for degenerate triangles
     */
    public static func computeInterpolation(point: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option<Vector3> {
        let bary = Vector3()
        let result = Triangle.computeBarycoord(point, p1, p2, p3, bary)
        if (result.isNone()) {
            target.set(0.0, 0.0, 0.0)
            return None
        }
        target.set(0.0, 0.0, 0.0)
        target.addScaledVector(v1, bary.x)
        target.addScaledVector(v2, bary.y)
        target.addScaledVector(v3, bary.z)
        return Some(target)
    }

    /**
     * @brief[zh-cn] 静态方法：判断三角形是否朝向给定方向
     * @param[zh-cn] a 顶点 a
     * b 顶点 b
     * c 顶点 c
     * direction 方向向量（应为单位向量）
     * @return[zh-cn] 是否朝向给定方向
     *
     * @brief[en] Static method: test if the triangle is front-facing towards a given direction
     * @param[en] a Vertex a
     * b Vertex b
     * c Vertex c
     * direction Direction vector (should be a unit vector)
     * @return[en] Whether front-facing towards the given direction
     */
    public static func testIsFrontFacing(a: Vector3, b: Vector3, c: Vector3, direction: Vector3): Bool {
        let v0 = Vector3().subVectors(c, b)
        let v1 = Vector3().subVectors(a, b)
        return v0.cross(v1).dot(direction) < 0.0
    }

    /**
     * @brief[zh-cn] 设置三角形的顶点
     * @param[zh-cn] a 顶点 a
     * b 顶点 b
     * c 顶点 c
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the vertices of the triangle
     * @param[en] a Vertex a
     * b Vertex b
     * c Vertex c
     * @return[en] This instance
     */
    public func set(a: Vector3, b: Vector3, c: Vector3): Triangle {
        this.a.copy(a)
        this.b.copy(b)
        this.c.copy(c)
        return this
    }

    /**
     * @brief[zh-cn] 从点数组和索引设置三角形顶点
     * @param[zh-cn] points 点数组
     * i0 顶点 a 的索引
     * i1 顶点 b 的索引
     * i2 顶点 c 的索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set triangle vertices from point array and indices
     * @param[en] points Point array
     * i0 Index of vertex a
     * i1 Index of vertex b
     * i2 Index of vertex c
     * @return[en] This instance
     */
    public func setFromPointsAndIndices(points: Array<Vector3>, i0: Int64, i1: Int64, i2: Int64): Triangle {
        this.a.copy(points[i0])
        this.b.copy(points[i1])
        this.c.copy(points[i2])
        return this
    }

    /**
     * @brief[zh-cn] 从顶点属性与索引设置三角形顶点
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * i0 顶点 a 的索引
     * i1 顶点 b 的索引
     * i2 顶点 c 的索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set triangle vertices from vertex attribute and indices (aligned with JS: Triangle.setFromAttributeAndIndices)
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * i0 Index of vertex a
     * i1 Index of vertex b
     * i2 Index of vertex c
     * @return[en] This instance
     */
    public func setFromAttributeAndIndices(attribute: AttributeReader, i0: Int64, i1: Int64, i2: Int64): Triangle {
        this.a.fromBufferAttribute(attribute, i0)
        this.b.fromBufferAttribute(attribute, i1)
        this.c.fromBufferAttribute(attribute, i2)
        return this
    }

    /**
     * @brief[zh-cn] 插值顶点属性，用重心坐标对属性三个顶点的值做线性插值，写入 target
     * @param[zh-cn] attr 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * i1 顶点 a 的属性索引
     * i2 顶点 b 的属性索引
     * i3 顶点 c 的属性索引
     * barycoord 重心坐标
     * target 输出向量（写入插值结果）
     * @return[zh-cn] 插值后的 target
     *
     * @brief[en] Interpolate vertex attribute (aligned with JS: Triangle.getInterpolatedAttribute), linearly interpolate attribute values at three vertices using barycentric coordinates, write to target
     * @param[en] attr Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * i1 Attribute index of vertex a
     * i2 Attribute index of vertex b
     * i3 Attribute index of vertex c
     * barycoord Barycentric coordinates
     * target Output vector (writes interpolation result)
     * @return[en] The interpolated target
     */
    public static func getInterpolatedAttribute(attr: AttributeReader, i1: Int64, i2: Int64, i3: Int64, barycoord: Vector3, target: Vector3): Vector3 {
        let v40 = Vector3().fromBufferAttribute(attr, i1)
        let v41 = Vector3().fromBufferAttribute(attr, i2)
        let v42 = Vector3().fromBufferAttribute(attr, i3)
        target.setScalar(0.0)
        target.addScaledVector(v40, barycoord.x)
        target.addScaledVector(v41, barycoord.y)
        target.addScaledVector(v42, barycoord.z)
        return target
    }

    /**
     * @brief[zh-cn] 克隆当前三角形
     * @return[zh-cn] 新的三角形实例
     *
     * @brief[en] Clone this triangle
     * @return[en] A new triangle instance
     */
    public func clone(): Triangle {
        return Triangle(this.a, this.b, this.c)
    }

    /**
     * @brief[zh-cn] 复制另一个三角形的值
     * @param[zh-cn] t 源三角形
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another triangle
     * @param[en] t Source triangle
     * @return[en] This instance
     */
    public func copy(t: Triangle): Triangle {
        this.a.copy(t.a)
        this.b.copy(t.b)
        this.c.copy(t.c)
        return this
    }

    /**
     * @brief[zh-cn] 计算三角形面积
     * @return[zh-cn] 面积
     *
     * @brief[en] Calculate the area of the triangle
     * @return[en] Area
     */
    public func getArea(): Float64 {
        let v0 = Vector3().subVectors(this.c, this.b)
        let v1 = Vector3().subVectors(this.a, this.b)
        return v0.cross(v1).length() * 0.5
    }

    /**
     * @brief[zh-cn] 计算三角形的中点
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 中点
     *
     * @brief[en] Calculate the midpoint of the triangle
     * @param[en] target Target vector
     * @return[en] Midpoint
     */
    public func getMidpoint(target: Vector3): Vector3 {
        return target.addVectors(this.a, this.b).add(this.c).multiplyScalar(1.0 / 3.0)
    }

    /**
     * @brief[zh-cn] 计算三角形的中点（创建新向量）
     * @return[zh-cn] 中点
     *
     * @brief[en] Calculate the midpoint of the triangle (creates a new vector)
     * @return[en] Midpoint
     */
    public func getMidpoint(): Vector3 {
        return this.getMidpoint(Vector3())
    }

    /**
     * @brief[zh-cn] 计算三角形的法向量
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 法向量
     *
     * @brief[en] Calculate the normal vector of the triangle
     * @param[en] target Target vector
     * @return[en] Normal vector
     */
    public func getNormal(target: Vector3): Vector3 {
        return Triangle.computeNormal(this.a, this.b, this.c, target)
    }

    /**
     * @brief[zh-cn] 计算三角形的法向量（创建新向量）
     * @return[zh-cn] 法向量
     *
     * @brief[en] Calculate the normal vector of the triangle (creates a new vector)
     * @return[en] Normal vector
     */
    public func getNormal(): Vector3 {
        return this.getNormal(Vector3())
    }

    /**
     * @brief[zh-cn] 计算三角形所在的平面
     * @param[zh-cn] target 目标平面
     * @return[zh-cn] 平面
     *
     * @brief[en] Calculate the plane of the triangle
     * @param[en] target Target plane
     * @return[en] Plane
     */
    public func getPlane(target: Plane): Plane {
        return target.setFromCoplanarPoints(this.a, this.b, this.c)
    }

    /**
     * @brief[zh-cn] 计算三角形所在的平面（创建新平面）
     * @return[zh-cn] 平面
     *
     * @brief[en] Calculate the plane of the triangle (creates a new plane)
     * @return[en] Plane
     */
    public func getPlane(): Plane {
        return this.getPlane(Plane())
    }

    /**
     * @brief[zh-cn] 计算给定点的重心坐标
     * @param[zh-cn] point 点
     * target 目标向量
     * @return[zh-cn] 重心坐标，退化三角形返回 None
     *
     * @brief[en] Calculate barycentric coordinates for a given point
     * @param[en] point Point
     * target Target vector
     * @return[en] Barycentric coordinates, returns None for degenerate triangles
     */
    public func getBarycoord(point: Vector3, target: Vector3): Option<Vector3> {
        return Triangle.computeBarycoord(point, this.a, this.b, this.c, target)
    }

    /**
     * @brief[zh-cn] 计算给定点的重心坐标（创建新向量）
     * @param[zh-cn] point 点
     * @return[zh-cn] 重心坐标
     *
     * @brief[en] Calculate barycentric coordinates for a given point (creates a new vector)
     * @param[en] point Point
     * @return[en] Barycentric coordinates
     */
    public func getBarycoord(point: Vector3): Vector3 {
        let target = Vector3()
        let result = Triangle.computeBarycoord(point, this.a, this.b, this.c, target)
        return target
    }

    /**
     * @brief[zh-cn] 使用重心坐标插值
     * @param[zh-cn] point 插值点位置
     * v1 顶点 1 的值
     * v2 顶点 2 的值
     * v3 顶点 3 的值
     * target 目标向量
     * @return[zh-cn] 插值结果，退化三角形返回 None
     *
     * @brief[en] Interpolate using barycentric coordinates
     * @param[en] point Interpolation point position
     * v1 Value at vertex 1
     * v2 Value at vertex 2
     * v3 Value at vertex 3
     * target Target vector
     * @return[en] Interpolation result, returns None for degenerate triangles
     */
    public func getInterpolation(point: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, target: Vector3): Option<Vector3> {
        return Triangle.computeInterpolation(point, this.a, this.b, this.c, v1, v2, v3, target)
    }

    /**
     * @brief[zh-cn] 判断点是否在三角形内
     * @param[zh-cn] point 点
     * @return[zh-cn] 是否在三角形内
     *
     * @brief[en] Test if a point is inside the triangle
     * @param[en] point Point
     * @return[en] Whether the point is inside the triangle
     */
    public func containsPoint(point: Vector3): Bool {
        return Triangle.testContainsPoint(point, this.a, this.b, this.c)
    }

    /**
     * @brief[zh-cn] 判断三角形是否朝向给定方向
     * @param[zh-cn] direction 方向向量
     * @return[zh-cn] 是否朝向给定方向
     *
     * @brief[en] Test if the triangle is front-facing towards a given direction
     * @param[en] direction Direction vector
     * @return[en] Whether front-facing towards the given direction
     */
    public func isFrontFacing(direction: Vector3): Bool {
        return Triangle.testIsFrontFacing(this.a, this.b, this.c, direction)
    }

    /**
     * @brief[zh-cn] 判断三角形是否与包围盒相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Test if the triangle intersects with a bounding box
     * @param[en] box Bounding box
     * @return[en] Whether intersecting
     */
    public func intersectsBox(box: Box3): Bool {
        return box.intersectsTriangle(this)
    }

    /**
     * @brief[zh-cn] 计算三角形上离给定点最近的点
     * @param[zh-cn] p 点
     * target 目标向量
     * @return[zh-cn] 最近点
     *
     * @brief[en] Calculate the closest point on the triangle to a given point
     * @param[en] p Point
     * target Target vector
     * @return[en] Closest point
     */
    public func closestPointToPoint(p: Vector3, target: Vector3): Vector3 {
        let a = this.a; let b = this.b; let c = this.c
        let vab = Vector3().subVectors(b, a)
        let vac = Vector3().subVectors(c, a)
        let vap = Vector3().subVectors(p, a)
        let d1 = vab.dot(vap)
        let d2 = vac.dot(vap)
        if (d1 <= 0.0 && d2 <= 0.0) {
            // 顶点 A 的 Voronoi 区域
            return target.copy(a)
        }

        let vbp = Vector3().subVectors(p, b)
        let d3 = vab.dot(vbp)
        let d4 = vac.dot(vbp)
        if (d3 >= 0.0 && d4 <= d3) {
            // 顶点 B 的 Voronoi 区域
            return target.copy(b)
        }

        let vc = d1 * d4 - d3 * d2
        if (vc <= 0.0 && d1 >= 0.0 && d3 <= 0.0) {
            let v = d1 / (d1 - d3)
            // 边 AB 的区域
            return target.copy(a).addScaledVector(vab, v)
        }

        let vcp = Vector3().subVectors(p, c)
        let d5 = vab.dot(vcp)
        let d6 = vac.dot(vcp)
        if (d6 >= 0.0 && d5 <= d6) {
            // 顶点 C 的 Voronoi 区域
            return target.copy(c)
        }

        let vb = d5 * d2 - d1 * d6
        if (vb <= 0.0 && d2 >= 0.0 && d6 <= 0.0) {
            let w = d2 / (d2 - d6)
            // 边 AC 的区域
            return target.copy(a).addScaledVector(vac, w)
        }

        let va = d3 * d6 - d5 * d4
        if (va <= 0.0 && (d4 - d3) >= 0.0 && (d5 - d6) >= 0.0) {
            let vbc = Vector3().subVectors(c, b)
            let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
            // 边 BC 的区域
            return target.copy(b).addScaledVector(vbc, w)
        }

        // 面区域
        let denom = 1.0 / (va + vb + vc)
        let vv = vb * denom
        let w = vc * denom
        return target.copy(a).addScaledVector(vab, vv).addScaledVector(vac, w)
    }

    /**
     * @brief[zh-cn] 计算三角形上离给定点最近的点（创建新向量）
     * @param[zh-cn] p 点
     * @return[zh-cn] 最近点
     *
     * @brief[en] Calculate the closest point on the triangle to a given point (creates a new vector)
     * @param[en] p Point
     * @return[en] Closest point
     */
    public func closestPointToPoint(p: Vector3): Vector3 {
        return this.closestPointToPoint(p, Vector3())
    }

    /**
     * @brief[zh-cn] 判断是否与另一个三角形相等
     * @param[zh-cn] t 另一个三角形
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another triangle
     * @param[en] t Another triangle
     * @return[en] Whether equal
     */
    public func equals(t: Triangle): Bool {
        return t.a.equals(this.a) && t.b.equals(this.b) && t.c.equals(this.c)
    }
}
