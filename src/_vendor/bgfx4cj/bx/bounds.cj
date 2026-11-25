/**

 * @file bx 3D 几何体类型与相交检测

 * @brief bx 库的 3D 几何体类型定义和相交检测函数

 * @explain 本文件包含纯仓颉实现的 3D 几何体类型（Line/LineSegment/AABB/Capsule/

 *         Cone/Cylinder/Disk/OBB/Sphere/Triangle/Ray）和相交检测算法

 *         （射线-AABB/射线-球体/射线-平面/射线-三角形）。

 * @note 适用于碰撞检测、视锥剔除和拾取操作。

 */

protected package three._vendor.bgfx4cj.bx



import std.math.*



// =============================================================================

// Geometry types

// =============================================================================



/** @brief 由点+方向定义的无限直线 */

public struct Line {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 方向向量 */
    public var dir: Vec3



    public init() {

        pos = Vec3()

        dir = Vec3()

    }



    public init(pos: Vec3, dir: Vec3) {

        this.pos = pos

        this.dir = dir

    }

}



/** @brief 由起点和终点定义的线段 */

public struct LineSegment {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 终点 */
    public var end: Vec3



    public init() {

        pos = Vec3()

        end = Vec3()

    }



    public init(pos: Vec3, end: Vec3) {

        this.pos = pos

        this.end = end

    }

}



/** @brief 轴对齐包围盒 */

public struct Aabb {

    /** @brief 最小值 */
    public var min: Vec3

    /** @brief 最大值 */
    public var max: Vec3



    public init() {

        min = Vec3()

        max = Vec3()

    }



    public init(min: Vec3, max: Vec3) {

        this.min = min

        this.max = max

    }

}



/** @brief 胶囊体（扫掠球体） */

public struct Capsule {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 终点 */
    public var end: Vec3

    /** @brief 半径 */
    public var radius: Float32



    public init() {

        pos = Vec3()

        end = Vec3()

        radius = 0.0f32

    }



    public init(pos: Vec3, end: Vec3, radius: Float32) {

        this.pos = pos

        this.end = end

        this.radius = radius

    }

}



/** @brief 锥体 */

public struct Cone {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 终点 */
    public var end: Vec3

    /** @brief 半径 */
    public var radius: Float32



    public init() {

        pos = Vec3()

        end = Vec3()

        radius = 0.0f32

    }



    public init(pos: Vec3, end: Vec3, radius: Float32) {

        this.pos = pos

        this.end = end

        this.radius = radius

    }

}



/** @brief 圆柱体 */

public struct Cylinder {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 终点 */
    public var end: Vec3

    /** @brief 半径 */
    public var radius: Float32



    public init() {

        pos = Vec3()

        end = Vec3()

        radius = 0.0f32

    }



    public init(pos: Vec3, end: Vec3, radius: Float32) {

        this.pos = pos

        this.end = end

        this.radius = radius

    }

}



/** @brief 圆盘（3D 空间中的填充圆） */

public struct Disk {

    /** @brief 中心点 */
    public var center: Vec3

    /** @brief 法线向量 */
    public var normal: Vec3

    /** @brief 半径 */
    public var radius: Float32



    public init() {

        center = Vec3()

        normal = Vec3()

        radius = 0.0f32

    }



    public init(center: Vec3, normal: Vec3, radius: Float32) {

        this.center = center

        this.normal = normal

        this.radius = radius

    }

}



/** @brief 有向包围盒（16 元素矩阵） */

public struct Obb {

    /** @brief 变换矩阵（16 个 float） */
    public var mtx: Array<Float32>



    public init() {

        mtx = Array<Float32>(16, repeat: 0.0f32)

    }



    public init(mtx: Array<Float32>) {

        this.mtx = mtx

    }

}



/** @brief 包围球 */

public struct Sphere {

    /** @brief 中心点 */
    public var center: Vec3

    /** @brief 半径 */
    public var radius: Float32



    public init() {

        center = Vec3()

        radius = 0.0f32

    }



    public init(center: Vec3, radius: Float32) {

        this.center = center

        this.radius = radius

    }

}



/** @brief 3D 空间中的三角形 */

public struct Triangle {

    /** @brief 顶点 0 */
    public var v0: Vec3

    /** @brief 顶点 1 */
    public var v1: Vec3

    /** @brief 顶点 2 */
    public var v2: Vec3



    public init() {

        v0 = Vec3()

        v1 = Vec3()

        v2 = Vec3()

    }



    public init(v0: Vec3, v1: Vec3, v2: Vec3) {

        this.v0 = v0

        this.v1 = v1

        this.v2 = v2

    }

}



/** @brief 3D 空间中的射线 */

public struct Ray {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 方向向量 */
    public var dir: Vec3



    public init() {

        pos = Vec3()

        dir = Vec3()

    }



    public init(pos: Vec3, dir: Vec3) {

        this.pos = pos

        this.dir = dir

    }

}



/** @brief 相交检测命中结果 */

public struct Hit {

    /** @brief 位置/起点 */
    public var pos: Vec3

    /** @brief 平面 */
    public var plane: Plane



    public init() {

        pos = Vec3()

        plane = Plane()

    }



    public init(pos: Vec3, plane: Plane) {

        this.pos = pos

        this.plane = plane

    }

}



/** @brief 标量区间 [min, max] */

public struct Interval {

    /** @brief 最小值 */
    public var min: Float32

    /** @brief 最大值 */
    public var max: Float32



    public init(val: Float32) {

        min = val

        max = val

    }



    public init(min: Float32, max: Float32) {

        this.min = min

        this.max = max

    }



    public mut func set(val: Float32): Unit {

        min = val

        max = val

    }



    public mut func setCenter(val: Float32): Unit {

        let extents = (max - min) * 0.5f32

        min = val - extents

        max = val + extents

    }



    public mut func expand(val: Float32): Unit {

        min = bx_min(min, val)

        max = bx_max(max, val)

    }

}



// =============================================================================

// Point-at functions

// =============================================================================



/** @brief 获取射线上的点（参数t处） */

public func getPointAt(ray: Ray, t: Float32): Vec3 {

    return mad(ray.dir, t, ray.pos)

}



/** @brief 获取射线上的点（参数t处） */

public func getPointAt(line: Line, t: Float32): Vec3 {

    return mad(line.dir, t, line.pos)

}



/** @brief 获取射线上的点（参数t处） */

public func getPointAt(line: LineSegment, t: Float32): Vec3 {

    return lerp(line.pos, line.end, t)

}



// =============================================================================

// Center / extent queries

// =============================================================================



/** @brief 获取包围盒的中心点 */

public func getCenter(aabb: Aabb): Vec3 {

    return mul(add(aabb.min, aabb.max), 0.5f32)

}



/** @brief 获取包围盒的半径范围 */

public func getExtents(aabb: Aabb): Vec3 {

    return mul(sub(aabb.max, aabb.min), 0.5f32)

}



/** @brief 获取包围盒的中心点 */

public func getCenter(triangle: Triangle): Vec3 {

    return mul(add(add(triangle.v0, triangle.v1), triangle.v2), 1.0f32 / 3.0f32)

}



// =============================================================================

// AABB construction

// =============================================================================



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(extents: Vec3): Aabb {

    return Aabb(mul(extents, -1.0f32), extents)

}



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(center: Vec3, extents: Vec3): Aabb {

    return Aabb(sub(center, extents), add(center, extents))

}



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(sphere: Sphere): Aabb {

    let rr = Vec3(sphere.radius)

    return Aabb(sub(sphere.center, rr), add(sphere.center, rr))

}



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(triangle: Triangle): Aabb {

    return Aabb(

        Vec3(

            min3(triangle.v0.x, triangle.v1.x, triangle.v2.x),

            min3(triangle.v0.y, triangle.v1.y, triangle.v2.y),

            min3(triangle.v0.z, triangle.v1.z, triangle.v2.z)

        ),

        Vec3(

            max3(triangle.v0.x, triangle.v1.x, triangle.v2.x),

            max3(triangle.v0.y, triangle.v1.y, triangle.v2.y),

            max3(triangle.v0.z, triangle.v1.z, triangle.v2.z)

        )

    )

}



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(cylinder: Cylinder): Aabb {

    let rr = Vec3(cylinder.radius)

    var lo = sub(cylinder.pos, rr)

    var hi = add(cylinder.pos, rr)

    let tmpLo = sub(cylinder.end, rr)

    let tmpHi = add(cylinder.end, rr)

    lo = min(lo, tmpLo)

    hi = max(hi, tmpHi)

    lo = min(lo, tmpHi)

    hi = max(hi, tmpLo)

    return Aabb(lo, hi)

}



/** @brief 从半径范围创建轴对齐包围盒 */

public func toAabb(disk: Disk): Aabb {

    let n = abs(disk.normal)

    let e = mul(n, disk.radius)

    return Aabb(sub(disk.center, e), add(disk.center, e))

}



/** @brief 扩展轴对齐包围盒 */

public func aabbExpand(aabb: Aabb, factor: Float32): Aabb {

    let extents = getExtents(aabb)

    let center = getCenter(aabb)

    let newExtents = add(extents, Vec3(factor))

    return toAabb(center, newExtents)

}



/** @brief 扩展轴对齐包围盒 */

public func aabbExpand(aabb: Aabb, pos: Vec3): Aabb {

    return Aabb(min(aabb.min, pos), max(aabb.max, pos))

}



/** @brief 计算轴对齐包围盒的表面积 */

public func calcAreaAabb(aabb: Aabb): Float32 {

    let extents = getExtents(aabb)

    return (extents.x * extents.y + extents.y * extents.z + extents.z * extents.x) * 8.0f32

}



// =============================================================================

// Frustum

// =============================================================================



/** @brief 从视图投影矩阵构建 6 个视锥平面（近/远/左/右/上/下）

 *  @param planes 输出平面数组

 *  @param viewProj 视图投影矩阵（行主序，16 floats） */

/** @brief 从视图投影矩阵构建6个视锥平面 */

public func buildFrustumPlanes(planes: Array<Plane>, viewProj: Array<Float32>): Unit {

    // Row-major: row i = [m[i*4], m[i*4+1], m[i*4+2], m[i*4+3]]

    // Left plane:   row 3 + row 0

    planes[0] = Plane(

        Vec3(

            viewProj[3] + viewProj[0],

            viewProj[7] + viewProj[4],

            viewProj[11] + viewProj[8]

        ),

        viewProj[15] + viewProj[12]

    )

    // Right plane:  row 3 - row 0

    planes[1] = Plane(

        Vec3(

            viewProj[3] - viewProj[0],

            viewProj[7] - viewProj[4],

            viewProj[11] - viewProj[8]

        ),

        viewProj[15] - viewProj[12]

    )

    // Top plane:    row 3 - row 1

    planes[2] = Plane(

        Vec3(

            viewProj[3] - viewProj[1],

            viewProj[7] - viewProj[5],

            viewProj[11] - viewProj[9]

        ),

        viewProj[15] - viewProj[13]

    )

    // Bottom plane: row 3 + row 1

    planes[3] = Plane(

        Vec3(

            viewProj[3] + viewProj[1],

            viewProj[7] + viewProj[5],

            viewProj[11] + viewProj[9]

        ),

        viewProj[15] + viewProj[13]

    )

    // Near plane:   row 3 + row 2

    planes[4] = Plane(

        Vec3(

            viewProj[3] + viewProj[2],

            viewProj[7] + viewProj[6],

            viewProj[11] + viewProj[10]

        ),

        viewProj[15] + viewProj[14]

    )

    // Far plane:    row 3 - row 2

    planes[5] = Plane(

        Vec3(

            viewProj[3] - viewProj[2],

            viewProj[7] - viewProj[6],

            viewProj[11] - viewProj[10]

        ),

        viewProj[15] - viewProj[14]

    )

}



/** @brief 返回三个平面的交点 */

public func intersectPlanes(pa: Plane, pb: Plane, pc: Plane): Vec3 {

    let bcross = cross(pb.normal, pc.normal)

    let ccross = cross(pc.normal, pa.normal)

    let across = cross(pa.normal, pb.normal)

    let det = dot(pa.normal, bcross)

    let invDet = 1.0f32 / det

    return mul(

        add(

            mul(bcross, pa.dist),

            add(mul(ccross, pb.dist), mul(across, pc.dist))

        ),

        invDet

    )

}



/** @brief 从屏幕坐标 x,y 和逆视图投影矩阵创建射线 */

public func makeRay(x: Float32, y: Float32, invVp: Array<Float32>): Ray {

    let p0 = mulH(Vec3(x, y, 0.0f32), invVp)

    let p1 = mulH(Vec3(x, y, 1.0f32), invVp)

    return Ray(p0, normalize(sub(p1, p0)))

}



// =============================================================================

// Ray intersection tests

// =============================================================================



/** @brief 射线与 AABB 相交检测（slab 算法） */

public func intersectRayAabb(ray: Ray, aabb: Aabb): Bool {

    let invDir = Vec3(

        1.0f32 / ray.dir.x,

        1.0f32 / ray.dir.y,

        1.0f32 / ray.dir.z

    )



    let t1 = (aabb.min.x - ray.pos.x) * invDir.x

    let t2 = (aabb.max.x - ray.pos.x) * invDir.x

    let t3 = (aabb.min.y - ray.pos.y) * invDir.y

    let t4 = (aabb.max.y - ray.pos.y) * invDir.y

    let t5 = (aabb.min.z - ray.pos.z) * invDir.z

    let t6 = (aabb.max.z - ray.pos.z) * invDir.z



    let tmin = max3(min(t1, t2), min(t3, t4), min(t5, t6))

    let tmax = min3(max(t1, t2), max(t3, t4), max(t5, t6))



    if (tmax < 0.0f32 || tmin > tmax) {

        return false

    }

    return true

}



/** @brief 射线与球体相交检测 */

public func intersectRaySphere(ray: Ray, sphere: Sphere): Bool {

    let oc = sub(ray.pos, sphere.center)

    let a = dot(ray.dir, ray.dir)

    let b = 2.0f32 * dot(oc, ray.dir)

    let c = dot(oc, oc) - sphere.radius * sphere.radius

    let discriminant = b * b - 4.0f32 * a * c

    if (discriminant < 0.0f32) {

        return false

    }

    return true

}



/** @brief 射线与平面相交检测，返回 Hit（若相交） */

public func intersectRayPlane(ray: Ray, plane: Plane, doubleSided: Bool): ?Hit {

    let denom = dot(plane.normal, ray.dir)

    if (!doubleSided) {

        if (denom >= 0.0f32) {

            return None

        }

    } else {

        if (abs(denom) < 0.0001f32) {

            return None

        }

    }

    let t = -(dot(plane.normal, ray.pos) + plane.dist) / denom

    if (t < 0.0f32) {

        return None

    }

    return Some(Hit(mad(ray.dir, t, ray.pos), plane))

}



/** @brief 射线与三角形相交检测（Moller-Trumbore 算法） */

public func intersectRayTriangle(ray: Ray, triangle: Triangle): Bool {

    let edge1 = sub(triangle.v1, triangle.v0)

    let edge2 = sub(triangle.v2, triangle.v0)

    let pvec = cross(ray.dir, edge2)

    let det = dot(edge1, pvec)



    if (det < 0.0001f32) {

        return false

    }



    let tvec = sub(ray.pos, triangle.v0)

    let u = dot(tvec, pvec)

    if (u < 0.0f32 || u > det) {

        return false

    }



    let qvec = cross(tvec, edge1)

    let v = dot(ray.dir, qvec)

    if (v < 0.0f32 || u + v > det) {

        return false

    }



    return true

}



// =============================================================================

// Overlap tests

// =============================================================================



/** @brief 检测两个几何体是否重叠 */

public func overlap(interval: Interval, pos: Float32): Bool {

    return pos > interval.min && pos < interval.max

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(a: Interval, b: Interval): Bool {

    return a.max > b.min && b.max > a.min

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(aabb: Aabb, pos: Vec3): Bool {

    if (pos.x < aabb.min.x || pos.x > aabb.max.x) {

        return false

    }

    if (pos.y < aabb.min.y || pos.y > aabb.max.y) {

        return false

    }

    if (pos.z < aabb.min.z || pos.z > aabb.max.z) {

        return false

    }

    return true

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(a: Aabb, b: Aabb): Bool {

    if (a.max.x < b.min.x || a.min.x > b.max.x) {

        return false

    }

    if (a.max.y < b.min.y || a.min.y > b.max.y) {

        return false

    }

    if (a.max.z < b.min.z || a.min.z > b.max.z) {

        return false

    }

    return true

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(sphere: Sphere, aabb: Aabb): Bool {

    let closest = closestPoint(aabb, sphere.center)

    let distSq = distanceSq(closest, sphere.center)

    return distSq <= sphere.radius * sphere.radius

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(a: Sphere, b: Sphere): Bool {

    let totalR = a.radius + b.radius

    return distanceSq(a.center, b.center) <= totalR * totalR

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(sphere: Sphere, plane: Plane): Bool {

    let d = dot(plane.normal, sphere.center) + plane.dist

    return abs(d) <= sphere.radius

}



/** @brief 检测两个几何体是否重叠 */

public func overlap(aabb: Aabb, plane: Plane): Bool {

    let center = getCenter(aabb)

    let extents = getExtents(aabb)

    let r = dot(extents, Vec3(abs(plane.normal.x), abs(plane.normal.y), abs(plane.normal.z)))

    let d = dot(plane.normal, center) + plane.dist

    return abs(d) <= r

}



// =============================================================================

// Closest point queries

// =============================================================================



/** @brief 获取几何体上离给定点最近的点 */

public func closestPoint(line: Line, point: Vec3): Vec3 {

    let pa = sub(point, line.pos)

    let t = dot(pa, line.dir)

    return mad(line.dir, t, line.pos)

}



/** @brief 获取几何体上离给定点最近的点 */

public func closestPoint(line: LineSegment, point: Vec3): Vec3 {

    let ab = sub(line.end, line.pos)

    let t = dot(sub(point, line.pos), ab)

    if (t <= 0.0f32) {

        return line.pos

    }

    let denom = dot(ab, ab)

    if (t >= denom) {

        return line.end

    }

    return mad(ab, t / denom, line.pos)

}



/** @brief 获取几何体上离给定点最近的点 */

public func closestPoint(plane: Plane, point: Vec3): Vec3 {

    let d = dot(plane.normal, point) + plane.dist

    return sub(point, mul(plane.normal, d))

}



/** @brief 获取几何体上离给定点最近的点 */

public func closestPoint(aabb: Aabb, point: Vec3): Vec3 {

    return Vec3(

        max(aabb.min.x, min(point.x, aabb.max.x)),

        max(aabb.min.y, min(point.y, aabb.max.y)),

        max(aabb.min.z, min(point.z, aabb.max.z))

    )

}



/** @brief 获取几何体上离给定点最近的点 */

public func closestPoint(triangle: Triangle, point: Vec3): Vec3 {

    let ab = sub(triangle.v1, triangle.v0)

    let ac = sub(triangle.v2, triangle.v0)

    let ap = sub(point, triangle.v0)



    let d1 = dot(ab, ap)

    let d2 = dot(ac, ap)

    if (d1 <= 0.0f32 && d2 <= 0.0f32) {

        return triangle.v0

    }



    let bp = sub(point, triangle.v1)

    let d3 = dot(ab, bp)

    let d4 = dot(ac, bp)

    if (d3 >= 0.0f32 && d4 <= d3) {

        return triangle.v1

    }



    let vc = d1 * d4 - d3 * d2

    if (vc <= 0.0f32 && d1 >= 0.0f32 && d3 <= 0.0f32) {

        let v = d1 / (d1 - d3)

        return mad(ab, v, triangle.v0)

    }



    let cp = sub(point, triangle.v2)

    let d5 = dot(ab, cp)

    let d6 = dot(ac, cp)

    if (d6 >= 0.0f32 && d5 <= d6) {

        return triangle.v2

    }



    let vb = d5 * d2 - d1 * d6

    if (vb <= 0.0f32 && d2 >= 0.0f32 && d6 <= 0.0f32) {

        let w = d2 / (d2 - d6)

        return mad(ac, w, triangle.v0)

    }



    let va = d3 * d6 - d5 * d4

    if (va <= 0.0f32 && (d4 - d3) >= 0.0f32 && (d5 - d6) >= 0.0f32) {

        let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))

        return mad(sub(triangle.v2, triangle.v1), w, triangle.v1)

    }



    let denom = 1.0f32 / (va + vb + vc)

    let v = vb * denom

    let w = vc * denom

    return add(mad(ab, v, triangle.v0), mul(ac, w))

}



// =============================================================================

// Utility aliases for min/max with 3 args

// =============================================================================



internal func bx_min(a: Float32, b: Float32): Float32 {

    return min(a, b)

}



internal func bx_max(a: Float32, b: Float32): Float32 {

    return max(a, b)

}



internal func min3(a: Float32, b: Float32, c: Float32): Float32 {

    return min(min(a, b), c)

}



internal func max3(a: Float32, b: Float32, c: Float32): Float32 {

    return max(max(a, b), c)

}
