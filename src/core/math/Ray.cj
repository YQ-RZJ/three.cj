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
 * @file[zh-cn] Ray
 * @brief[zh-cn] 射线
 * @explain[zh-cn] 表示三维空间中的射线，由起点和方向定义。
 *
 * @file[en] Ray
 * @brief[en] Ray
 * @explain[en] Represents a ray in 3D space, defined by origin and direction.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] 射线类，由起点和方向向量定义
 *
 * @brief[en] Ray class, defined by origin and direction vector
 */
public class Ray {
    /**
     * @brief[zh-cn] 射线起点
     *
     * @brief[en] Ray origin
     */
    public var origin: Vector3
    /**
     * @brief[zh-cn] 射线方向（应为单位向量）
     *
     * @brief[en] Ray direction (should be a unit vector)
     */
    public var direction: Vector3

    public init() {
        this.origin = Vector3()
        this.direction = Vector3(0.0, 0.0, 1.0)
    }

    public init(origin: Vector3, direction: Vector3) {
        this.origin = origin.clone()
        this.direction = direction.clone()
    }

    /**
     * @brief[zh-cn] 设置射线的起点和方向
     * @param[zh-cn] origin 起点
     * direction 方向
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the origin and direction of the ray
     * @param[en] origin Origin
     * direction Direction
     * @return[en] This instance
     */
    public func set(origin: Vector3, direction: Vector3): Ray {
        this.origin.copy(origin)
        this.direction.copy(direction)
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前射线
     * @return[zh-cn] 新的射线实例
     *
     * @brief[en] Clone current ray
     * @return[en] New ray instance
     */
    public func clone(): Ray {
        return Ray(this.origin, this.direction)
    }

    /**
     * @brief[zh-cn] 复制另一条射线的值到当前实例
     * @param[zh-cn] r 源射线
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another ray to this instance
     * @param[en] r Source ray
     * @return[en] This instance
     */
    public func copy(r: Ray): Ray {
        this.origin.copy(r.origin)
        this.direction.copy(r.direction)
        return this
    }

    /**
     * @brief[zh-cn] 获取射线上参数 t 处的点
     * @param[zh-cn] t 参数值
     * target 目标向量
     * @return[zh-cn] 射线上的点
     *
     * @brief[en] Get the point at parameter t on the ray
     * @param[en] t Parameter value
     * target Target vector
     * @return[en] Point on the ray
     */
    public func at(t: Float64, target: Vector3): Vector3 {
        return target.copy(this.direction).multiplyScalar(t).add(this.origin)
    }

    /**
     * @brief[zh-cn] 获取射线上参数 t 处的点（创建新向量）
     * @param[zh-cn] t 参数值
     * @return[zh-cn] 射线上的点
     *
     * @brief[en] Get the point at parameter t on the ray (creates new vector)
     * @param[en] t Parameter value
     * @return[en] Point on the ray
     */
    public func at(t: Float64): Vector3 {
        return this.at(t, Vector3())
    }

    /**
     * @brief[zh-cn] 使射线朝向目标点
     * @param[zh-cn] v 目标点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Point the ray at a target point
     * @param[en] v Target point
     * @return[en] This instance
     */
    public func lookAt(v: Vector3): Ray {
        this.direction.copy(v).sub(this.origin).normalize()
        return this
    }

    /**
     * @brief[zh-cn] 沿射线方向移动起点
     * @param[zh-cn] t 移动距离
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Move the ray origin along its direction
     * @param[en] t Distance to move
     * @return[en] This instance
     */
    public func recast(t: Float64): Ray {
        this.origin.copy(this.at(t))
        return this
    }

    /**
     * @brief[zh-cn] 计算点到射线的最近点
     * @param[zh-cn] point 点
     * target 目标向量
     * @return[zh-cn] 最近点
     *
     * @brief[en] Compute the closest point on the ray to a given point
     * @param[en] point Point
     * target Target vector
     * @return[en] Closest point
     */
    public func closestPointToPoint(point: Vector3, target: Vector3): Vector3 {
        target.subVectors(point, this.origin)
        let directionDistance = target.dot(this.direction)
        if (directionDistance < 0.0) {
            return target.copy(this.origin)
        }
        return target.copy(this.direction).multiplyScalar(directionDistance).add(this.origin)
    }

    /**
     * @brief[zh-cn] 计算点到射线的最近点（创建新向量）
     * @param[zh-cn] point 点
     * @return[zh-cn] 最近点
     *
     * @brief[en] Compute the closest point on the ray to a given point (creates new vector)
     * @param[en] point Point
     * @return[en] Closest point
     */
    public func closestPointToPoint(point: Vector3): Vector3 {
        return this.closestPointToPoint(point, Vector3())
    }

    /**
     * @brief[zh-cn] 计算点到射线的距离
     * @param[zh-cn] point 目标点
     * @return[zh-cn] 距离
     *
     * @brief[en] Compute distance from point to ray
     * @param[en] point Target point
     * @return[en] Distance
     */
    public func distanceToPoint(point: Vector3): Float64 {
        return sqrt(this.distanceSqToPoint(point))
    }

    /**
     * @brief[zh-cn] 计算点到射线距离的平方
     * @param[zh-cn] point 目标点
     * @return[zh-cn] 距离的平方
     *
     * @brief[en] Compute squared distance from point to ray
     * @param[en] point Target point
     * @return[en] Squared distance
     */
    public func distanceSqToPoint(point: Vector3): Float64 {
        let directionDistance = Vector3().subVectors(point, this.origin).dot(this.direction)
        if (directionDistance < 0.0) {
            return this.origin.distanceToSquared(point)
        }
        let closestPoint = Vector3().copy(this.direction).multiplyScalar(directionDistance).add(this.origin)
        return closestPoint.distanceToSquared(point)
    }

    /**
     * @brief[zh-cn] 计算射线与线段之间的最短距离平方
     * @param[zh-cn] v0 线段起点
     * v1 线段终点
     * optionalPointOnRay 射线上最近点（可选）
     * optionalPointOnSegment 线段上最近点（可选）
     * @return[zh-cn] 距离平方
     *
     * @brief[en] Compute squared shortest distance between ray and line segment
     * @param[en] v0 Segment start point
     * v1 Segment end point
     * optionalPointOnRay Closest point on ray (optional)
     * optionalPointOnSegment Closest point on segment (optional)
     * @return[en] Squared distance
     */
    public func distanceSqToSegment(v0: Vector3, v1: Vector3, optionalPointOnRay!: Option<Vector3> = None, optionalPointOnSegment!: Option<Vector3> = None): Float64 {
        let segCenter = Vector3().addVectors(v0, v1).multiplyScalar(0.5)
        let segDir = Vector3().subVectors(v1, v0).normalize()
        let diff = Vector3().subVectors(this.origin, segCenter)
        let segExtent = v0.distanceTo(v1) * 0.5
        let a01 = -this.direction.dot(segDir)
        let b0 = diff.dot(this.direction)
        let b1 = -diff.dot(segDir)
        let c = diff.lengthSq()
        let det = abs(1.0 - a01 * a01)
        var s0: Float64; var s1: Float64; var sqrDist: Float64; var extDet: Float64

        if (det > 0.0) {
            s0 = a01 * b1 - b0
            s1 = a01 * b0 - b1
            extDet = segExtent * det
            if (s0 >= 0.0) {
                if (s1 >= -extDet) {
                    if (s1 <= extDet) {
                        // 区域 0：最近点在内部
                        let invDet = 1.0 / det
                        s0 *= invDet
                        s1 *= invDet
                        sqrDist = s0 * (s0 + a01 * s1 + 2.0 * b0) + s1 * (a01 * s0 + s1 + 2.0 * b1) + c
                    } else {
                        // 区域 1
                        s1 = segExtent
                        s0 = max(0.0, -(a01 * s1 + b0))
                        sqrDist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
                    }
                } else {
                    // 区域 5
                    s1 = -segExtent
                    s0 = max(0.0, -(a01 * s1 + b0))
                    sqrDist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
                }
            } else {
                if (s1 >= -extDet) {
                    if (s1 <= extDet) {
                        // 区域 3
                        s0 = 0.0
                        s1 = clamp(b1, -segExtent, segExtent)
                        sqrDist = s1 * (s1 + 2.0 * b1) + c
                    } else {
                        // 区域 2
                        s0 = max(0.0, -(a01 * segExtent + b0))
                        s1 = if (s0 > 0.0) { segExtent } else { clamp(b1, -segExtent, segExtent) }
                        sqrDist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
                    }
                } else {
                    // 区域 4
                    s0 = max(0.0, a01 * segExtent - b0)
                    s1 = if (s0 > 0.0) { -segExtent } else { clamp(b1, -segExtent, segExtent) }
                    sqrDist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
                }
            }
        } else {
            // 射线与线段平行
            s1 = if (a01 > 0.0) { -segExtent } else { segExtent }
            s0 = max(0.0, -(a01 * s1 + b0))
            sqrDist = -s0 * s0 + s1 * (s1 + 2.0 * b1) + c
        }

        // 设置可选的最近点
        if (let Some(pt) <- optionalPointOnRay) {
            pt.copy(this.origin).addScaledVector(this.direction, s0)
        }
        if (let Some(pt) <- optionalPointOnSegment) {
            pt.copy(segCenter).addScaledVector(segDir, s1)
        }

        return max(0.0, sqrDist)
    }

    /**
     * @brief[zh-cn] 计算射线与球体的交点
     * @param[zh-cn] sphere 球体
     * target 目标向量
     * @return[zh-cn] 交点，如果不相交返回 None
     *
     * @brief[en] Compute intersection point of ray with sphere
     * @param[en] sphere Sphere
     * target Target vector
     * @return[en] Intersection point, or None if not intersecting
     */
    public func intersectSphere(sphere: Sphere, target: Vector3): Option<Vector3> {
        let v1 = Vector3().subVectors(sphere.center, this.origin)
        let tca = v1.dot(this.direction)
        let d2 = v1.dot(v1) - tca * tca
        let radius2 = sphere.radius * sphere.radius
        if (d2 > radius2) { return None }
        let thc = sqrt(radius2 - d2)
        let t0 = tca - thc
        let t1 = tca + thc
        if (t0 < 0.0 && t1 < 0.0) { return None }
        let t = if (t0 < 0.0) { t1 } else { t0 }
        return Some(this.at(t, target))
    }

    /**
     * @brief[zh-cn] 判断射线是否与球体相交
     * @param[zh-cn] sphere 球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if ray intersects with sphere
     * @param[en] sphere Sphere
     * @return[en] Whether intersecting
     */
    public func intersectsSphere(sphere: Sphere): Bool {
        return this.distanceSqToPoint(sphere.center) <= (sphere.radius * sphere.radius)
    }

    /**
     * @brief[zh-cn] 计算射线到平面的距离
     * @param[zh-cn] plane 平面
     * @return[zh-cn] 距离，如果平行返回 -1
     *
     * @brief[en] Compute distance from ray to plane
     * @param[en] plane Plane
     * @return[en] Distance, returns -1 if parallel
     */
    public func distanceToPlane(plane: Plane): Float64 {
        let denominator = plane.normal.dot(this.direction)
        if (denominator == 0.0) {
            if (plane.distanceToPoint(this.origin) == 0.0) { return 0.0 }
            return -1.0
        }
        let t = -(this.origin.dot(plane.normal) + plane.constant) / denominator
        return if (t >= 0.0) { t } else { -1.0 }
    }

    /**
     * @brief[zh-cn] 计算射线与平面的交点
     * @param[zh-cn] plane 平面
     * target 目标向量
     * @return[zh-cn] 交点，如果不相交返回 None
     *
     * @brief[en] Compute intersection point of ray with plane
     * @param[en] plane Plane
     * target Target vector
     * @return[en] Intersection point, or None if not intersecting
     */
    public func intersectPlane(plane: Plane, target: Vector3): Option<Vector3> {
        let t = this.distanceToPlane(plane)
        if (t < 0.0) { return None }
        return Some(this.at(t, target))
    }

    /**
     * @brief[zh-cn] 判断射线是否与平面相交
     * @param[zh-cn] plane 平面
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if ray intersects with plane
     * @param[en] plane Plane
     * @return[en] Whether intersecting
     */
    public func intersectsPlane(plane: Plane): Bool {
        let t = this.distanceToPlane(plane)
        return t >= 0.0
    }

    /**
     * @brief[zh-cn] 计算射线与包围盒的交点
     * @param[zh-cn] box 包围盒
     * target 目标向量
     * @return[zh-cn] 交点，如果不相交返回 None
     *
     * @brief[en] Compute intersection point of ray with bounding box
     * @param[en] box Bounding box
     * target Target vector
     * @return[en] Intersection point, or None if not intersecting
     */
    public func intersectBox(box: Box3, target: Vector3): Option<Vector3> {
        let invdirX = 1.0 / this.direction.x
        let invdirY = 1.0 / this.direction.y
        let invdirZ = 1.0 / this.direction.z
        var tmin: Float64; var tmax: Float64; var tymin: Float64; var tymax: Float64; var tzmin: Float64; var tzmax: Float64

        if (invdirX >= 0.0) {
            tmin = (box.min.x - this.origin.x) * invdirX
            tmax = (box.max.x - this.origin.x) * invdirX
        } else {
            tmin = (box.max.x - this.origin.x) * invdirX
            tmax = (box.min.x - this.origin.x) * invdirX
        }

        if (invdirY >= 0.0) {
            tymin = (box.min.y - this.origin.y) * invdirY
            tymax = (box.max.y - this.origin.y) * invdirY
        } else {
            tymin = (box.max.y - this.origin.y) * invdirY
            tymax = (box.min.y - this.origin.y) * invdirY
        }

        if (tmin > tymax || tymin > tmax) { return None }
        if (tymin > tmin) { tmin = tymin }
        if (tymax < tmax) { tmax = tymax }

        if (invdirZ >= 0.0) {
            tzmin = (box.min.z - this.origin.z) * invdirZ
            tzmax = (box.max.z - this.origin.z) * invdirZ
        } else {
            tzmin = (box.max.z - this.origin.z) * invdirZ
            tzmax = (box.min.z - this.origin.z) * invdirZ
        }

        if (tmin > tzmax || tzmin > tmax) { return None }
        if (tzmin > tmin) { tmin = tzmin }
        if (tzmax < tmax) { tmax = tzmax }

        if (tmax < 0.0) { return None }
        return Some(this.at(if (tmin >= 0.0) { tmin } else { tmax }, target))
    }

    /**
     * @brief[zh-cn] 判断射线是否与包围盒相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if ray intersects with bounding box
     * @param[en] box Bounding box
     * @return[en] Whether intersecting
     */
    public func intersectsBox(box: Box3): Bool {
        return this.intersectBox(box, Vector3()).isSome()
    }

    /**
     * @brief[zh-cn] 计算射线与三角形的交点（Watertight 算法）
     * @explain[zh-cn] 参考：Woop, Benthin, Wald, "Watertight Ray/Triangle Intersection", JCGT vol. 2 no. 1 (2013)
     * @param[zh-cn] a 三角形顶点 a
     * b 三角形顶点 b
     * c 三角形顶点 c
     * backfaceCulling 是否启用背面剔除
     * target 目标向量
     * @return[zh-cn] 交点，如果不相交返回 None
     *
     * @brief[en] Compute intersection point of ray with triangle (Watertight algorithm)
     * @explain[en] Reference: Woop, Benthin, Wald, "Watertight Ray/Triangle Intersection", JCGT vol. 2 no. 1 (2013)
     * @param[en] a Triangle vertex a
     * b Triangle vertex b
     * c Triangle vertex c
     * backfaceCulling Whether to enable backface culling
     * target Target vector
     * @return[en] Intersection point, or None if not intersecting
     */
    public func intersectTriangle(a: Vector3, b: Vector3, c: Vector3, backfaceCulling: Bool, target: Vector3): Option<Vector3> {
        let origin = this.origin
        let direction = this.direction
        let dx = direction.x; let dy = direction.y; let dz = direction.z

        // 三角形顶点相对于射线原点
        let aox = a.x - origin.x; let aoy = a.y - origin.y; let aoz = a.z - origin.z
        let box = b.x - origin.x; let boy = b.y - origin.y; let boz = b.z - origin.z
        let cox = c.x - origin.x; let coy = c.y - origin.y; let coz = c.z - origin.z

        // 选择射线方向绝对值最大的轴作为投影轴 kz
        let adx = abs(dx); let ady = abs(dy); let adz = abs(dz)
        var dkx: Float64; var dky: Float64; var dkz: Float64
        var akx: Float64; var aky: Float64; var akz: Float64
        var bkx: Float64; var bky: Float64; var bkz: Float64
        var ckx: Float64; var cky: Float64; var ckz: Float64

        if (adx >= ady && adx >= adz) {
            dkz = dx; akz = aox; bkz = box; ckz = cox
            if (dx >= 0.0) {
                dkx = dy; dky = dz
                akx = aoy; aky = aoz; bkx = boy; bky = boz; ckx = coy; cky = coz
            } else {
                dkx = dz; dky = dy
                akx = aoz; aky = aoy; bkx = boz; bky = boy; ckx = coz; cky = coy
            }
        } else if (ady >= adz) {
            dkz = dy; akz = aoy; bkz = boy; ckz = coy
            if (dy >= 0.0) {
                dkx = dz; dky = dx
                akx = aoz; aky = aox; bkx = boz; bky = box; ckx = coz; cky = cox
            } else {
                dkx = dx; dky = dz
                akx = aox; aky = aoz; bkx = box; bky = boz; ckx = cox; cky = coz
            }
        } else {
            dkz = dz; akz = aoz; bkz = boz; ckz = coz
            if (dz >= 0.0) {
                dkx = dx; dky = dy
                akx = aox; aky = aoy; bkx = box; bky = boy; ckx = cox; cky = coy
            } else {
                dkx = dy; dky = dx
                akx = aoy; aky = aox; bkx = boy; bky = box; ckx = coy; cky = cox
            }
        }

        // 零方向没有最大轴，不可能相交
        if (dkz == 0.0) { return None }

        // 剪切常数，使射线与 +kz 轴对齐
        let sx = dkx / dkz; let sy = dky / dkz; let sz = 1.0 / dkz

        // 剪切并缩放后的顶点
        let ax = akx - sx * akz; let ay = aky - sy * akz
        let bx = bkx - sx * bkz; let by = bky - sy * bkz
        let cx = ckx - sx * ckz; let cy = cky - sy * ckz

        // 缩放的重心坐标（有符号边函数）
        let u = cx * by - cy * bx
        let v = ax * cy - ay * cx
        let w = bx * ay - by * ax

        if (backfaceCulling) {
            if (u < 0.0 || v < 0.0 || w < 0.0) { return None }
        } else {
            if ((u < 0.0 || v < 0.0 || w < 0.0) && (u > 0.0 || v > 0.0 || w > 0.0)) { return None }
        }

        let det = u + v + w
        // 射线与三角形共面
        if (det == 0.0) { return None }

        // 缩放后的命中距离
        let tScaled = sz * (u * akz + v * bkz + w * ckz)
        if (det > 0.0) {
            if (tScaled < 0.0) { return None }
        } else {
            if (tScaled > 0.0) { return None }
        }

        return Some(this.at(tScaled / det, target))
    }

    /**
     * @brief[zh-cn] 应用 4x4 矩阵变换射线
     * @param[zh-cn] m 变换矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply 4x4 matrix transformation to ray
     * @param[en] m Transformation matrix
     * @return[en] This instance
     */
    public func applyMatrix4(m: Matrix4): Ray {
        this.origin.applyMatrix4(m)
        this.direction.transformDirection(m)
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一条射线相等
     * @param[zh-cn] r 比较的射线
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another ray
     * @param[en] r Ray to compare
     * @return[en] Whether equal
     */
    public func equals(r: Ray): Bool {
        return this.origin.equals(r.origin) && this.direction.equals(r.direction)
    }
}
