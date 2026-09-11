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
 * @file[zh-cn] Plane
 * @brief[zh-cn] 平面
 * @explain[zh-cn] 表示三维空间中的无限平面，使用 Hessian 法式表示。
 *
 * @file[en] Plane
 * @brief[en] Plane
 * @explain[en] Represents an infinite plane in 3D space using Hessian normal form.
 */
package three.core.math

import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 平面类，使用单位法向量和常数表示
 * @explain[zh-cn] Hessian 法式：normal · point + constant = 0
 *
 * @brief[en] Plane class, represented by unit normal and constant
 * @explain[en] Hessian normal form: normal · point + constant = 0
 */
@JsonAdapter
public class Plane {
    /**
     * @brief[zh-cn] 平面法向量（单位向量）
     *
     * @brief[en] Plane normal vector (unit vector)
     */
    public var normal: Vector3
    /**
     * @brief[zh-cn] 从原点到平面的有符号距离
     *
     * @brief[en] Signed distance from origin to plane
     */
    public var constant: Float64
    public init() {
        this.normal = Vector3(1.0, 0.0, 0.0)
        this.constant = 0.0
    }

    public init(normal: Vector3, constant: Float64) {
        this.normal = normal.clone()
        this.constant = constant
    }

    /**
     * @brief[zh-cn] 设置平面分量
     * @param[zh-cn] normal 法向量
     * constant 常数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set plane components
     * @param[en] normal Normal vector
     * constant Constant
     * @return[en] This instance
     */
    public func set(normal: Vector3, constant: Float64): Plane {
        this.normal.copy(normal)
        this.constant = constant
        return this
    }

    /**
     * @brief[zh-cn] 通过分量值设置平面
     * @param[zh-cn] x 法向量 x 分量
     * y 法向量 y 分量
     * z 法向量 z 分量
     * w 常数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set plane by component values
     * @param[en] x Normal vector x component
     * y Normal vector y component
     * z Normal vector z component
     * w Constant
     * @return[en] This instance
     */
    public func setComponents(x: Float64, y: Float64, z: Float64, w: Float64): Plane {
        this.normal.set(x, y, z)
        this.constant = w
        return this
    }

    /**
     * @brief[zh-cn] 从法向量和共面点设置平面
     * @param[zh-cn] normal 法向量
     * point 共面点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set plane from normal and coplanar point
     * @param[en] normal Normal vector
     * point Coplanar point
     * @return[en] This instance
     */
    public func setFromNormalAndCoplanarPoint(normal: Vector3, point: Vector3): Plane {
        this.normal.copy(normal)
        this.constant = -point.dot(this.normal)
        return this
    }

    /**
     * @brief[zh-cn] 从三个共面点设置平面
     * @param[zh-cn] a 第一个点
     * b 第二个点
     * c 第三个点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set plane from three coplanar points
     * @param[en] a First point
     * b Second point
     * c Third point
     * @return[en] This instance
     */
    public func setFromCoplanarPoints(a: Vector3, b: Vector3, c: Vector3): Plane {
        let normal = Vector3().subVectors(c, b).cross(Vector3().subVectors(a, b)).normalize()
        this.setFromNormalAndCoplanarPoint(normal, a)
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前平面
     * @return[zh-cn] 新的平面实例
     *
     * @brief[en] Clone current plane
     * @return[en] New plane instance
     */
    public func clone(): Plane {
        return Plane(this.normal, this.constant)
    }

    /**
     * @brief[zh-cn] 复制另一个平面的值到当前实例
     * @param[zh-cn] p 源平面
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another plane to this instance
     * @param[en] p Source plane
     * @return[en] This instance
     */
    public func copy(p: Plane): Plane {
        this.normal.copy(p.normal)
        this.constant = p.constant
        return this
    }

    /**
     * @brief[zh-cn] 归一化法向量并调整常数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Normalize normal vector and adjust constant
     * @return[en] This instance
     */
    public func normalize(): Plane {
        let inverseNormalLength = 1.0 / this.normal.length()
        this.normal.multiplyScalar(inverseNormalLength)
        this.constant *= inverseNormalLength
        return this
    }

    /**
     * @brief[zh-cn] 反转平面（法向量和常数取反）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Negate plane (negate normal and constant)
     * @return[en] This instance
     */
    public func negate(): Plane {
        this.constant *= -1.0
        this.normal.negate()
        return this
    }

    /**
     * @brief[zh-cn] 计算点到平面的有符号距离
     * @param[zh-cn] point 目标点
     * @return[zh-cn] 有符号距离
     *
     * @brief[en] Compute signed distance from point to plane
     * @param[en] point Target point
     * @return[en] Signed distance
     */
    public func distanceToPoint(point: Vector3): Float64 {
        return this.normal.dot(point) + this.constant
    }

    /**
     * @brief[zh-cn] 计算球体到平面的有符号距离
     * @param[zh-cn] sphere 目标球体
     * @return[zh-cn] 有符号距离
     *
     * @brief[en] Compute signed distance from sphere to plane
     * @param[en] sphere Target sphere
     * @return[en] Signed distance
     */
    public func distanceToSphere(sphere: Sphere): Float64 {
        return this.distanceToPoint(sphere.center) - sphere.radius
    }

    /**
     * @brief[zh-cn] 将点投影到平面上
     * @param[zh-cn] point 要投影的点
     * target 目标向量
     * @return[zh-cn] 投影点
     *
     * @brief[en] Project point onto the plane
     * @param[en] point Point to project
     * target Target vector
     * @return[en] Projected point
     */
    public func projectPoint(point: Vector3, target: Vector3): Vector3 {
        return target.copy(point).addScaledVector(this.normal, -this.distanceToPoint(point))
    }

    /**
     * @brief[zh-cn] 计算直线与平面的交点
     * @param[zh-cn] line 直线
     * target 目标向量
     * clampToLine 是否限制在线段范围内，默认为 true
     * @return[zh-cn] 交点，如果不相交返回 None
     *
     * @brief[en] Compute intersection point of line and plane
     * @param[en] line Line
     * target Target vector
     * clampToLine Whether to clamp to line segment range, defaults to true
     * @return[en] Intersection point, or None if not intersecting
     */
    public func intersectLine(line: Line3, target: Vector3, clampToLine!: Bool = true): Option<Vector3> {
        let direction = line.delta(Vector3())
        let denominator = this.normal.dot(direction)
        if (denominator == 0.0) {
            if (this.distanceToPoint(line.start) == 0.0) {
                return Some(target.copy(line.start))
            }
            return None
        }
        let t = -(line.start.dot(this.normal) + this.constant) / denominator
        if (clampToLine && (t < 0.0 || t > 1.0)) {
            return None
        }
        return Some(target.copy(line.start).addScaledVector(direction, t))
    }

    /**
     * @brief[zh-cn] 判断线段是否与平面相交
     * @param[zh-cn] line 线段
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if line segment intersects the plane
     * @param[en] line Line segment
     * @return[en] Whether intersecting
     */
    public func intersectsLine(line: Line3): Bool {
        let startSign = this.distanceToPoint(line.start)
        let endSign = this.distanceToPoint(line.end)
        return (startSign < 0.0 && endSign > 0.0) || (endSign < 0.0 && startSign > 0.0)
    }

    /**
     * @brief[zh-cn] 判断包围盒是否与平面相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if bounding box intersects the plane
     * @param[en] box Bounding box
     * @return[en] Whether intersecting
     */
    public func intersectsBox(box: Box3): Bool {
        return box.intersectsPlane(this)
    }

    /**
     * @brief[zh-cn] 判断球体是否与平面相交
     * @param[zh-cn] sphere 球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if sphere intersects the plane
     * @param[en] sphere Sphere
     * @return[en] Whether intersecting
     */
    public func intersectsSphere(sphere: Sphere): Bool {
        return sphere.intersectsPlane(this)
    }

    /**
     * @brief[zh-cn] 获取平面上的共面点（原点在平面上的投影）
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 共面点
     *
     * @brief[en] Get coplanar point on the plane (projection of origin onto the plane)
     * @param[en] target Target vector
     * @return[en] Coplanar point
     */
    public func coplanarPoint(target: Vector3): Vector3 {
        return target.copy(this.normal).multiplyScalar(-this.constant)
    }

    /**
     * @brief[zh-cn] 应用 4x4 矩阵变换平面
     * @param[zh-cn] matrix 变换矩阵
     * optionalNormalMatrix 可选的法线矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply 4x4 matrix transformation to plane
     * @param[en] matrix Transformation matrix
     * optionalNormalMatrix Optional normal matrix
     * @return[en] This instance
     */
    public func applyMatrix4(matrix: Matrix4, optionalNormalMatrix!: Option<Matrix3> = None): Plane {
        let normalMatrix = match (optionalNormalMatrix) {
            case Some(m) => m
            case None => Matrix3().getNormalMatrix(matrix)
        }
        let referencePoint = this.coplanarPoint(Vector3()).applyMatrix4(matrix)
        let normal = this.normal.applyMatrix3(normalMatrix).normalize()
        this.normal.copy(normal)
        this.constant = -referencePoint.dot(this.normal)
        return this
    }

    /**
     * @brief[zh-cn] 平移平面
     * @param[zh-cn] offset 偏移向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Translate plane
     * @param[en] offset Offset vector
     * @return[en] This instance
     */
    public func translate(offset: Vector3): Plane {
        this.constant -= offset.dot(this.normal)
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个平面相等
     * @param[zh-cn] p 比较的平面
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if equal to another plane
     * @param[en] p Plane to compare
     * @return[en] Whether equal
     */
    public func equals(p: Plane): Bool {
        return this.normal.equals(p.normal) && this.constant == p.constant
    }
}
