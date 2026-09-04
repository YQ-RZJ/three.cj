/**
 * @file[zh-cn] Line3
 * @brief[zh-cn] 三维线段
 * @explain[zh-cn] 表示三维空间中的线段，由起点和终点定义。
 *
 * @file[en] Line3
 * @brief[en] Line segment in 3D space
 * @explain[en] Represents a line segment in 3D space, defined by start and end points.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] 三维线段类，由起点和终点定义
 * @explain[zh-cn] 支持中心点计算、最近点参数、点到线段距离、两线段最近距离、矩阵变换等操作
 *
 * @brief[en] 3D line segment class, defined by start and end points
 * @explain[en] Supports center point computation, closest point parameter, point-to-line distance, line-to-line closest distance, matrix transformation, etc.
 */
public class Line3 {
    /**
     * @brief[zh-cn] 线段起点
     *
     * @brief[en] Start point of the line segment
     */
    public var start: Vector3
    /**
     * @brief[zh-cn] 线段终点
     *
     * @brief[en] End point of the line segment
     */
    public var end: Vector3

    public init() {
        this.start = Vector3()
        this.end = Vector3()
    }

    public init(start: Vector3, end: Vector3) {
        this.start = start.clone()
        this.end = end.clone()
    }

    /**
     * @brief[zh-cn] 设置线段的起点和终点
     * @param[zh-cn] start 起点
     * end 终点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the start and end points of the line segment
     * @param[en] start Start point
     * end End point
     * @return[en] This instance
     */
    public func set(start: Vector3, end: Vector3): Line3 {
        this.start.copy(start)
        this.end.copy(end)
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前线段
     * @return[zh-cn] 新的线段实例
     *
     * @brief[en] Clone the current line segment
     * @return[en] New line segment instance
     */
    public func clone(): Line3 {
        return Line3(this.start, this.end)
    }

    /**
     * @brief[zh-cn] 复制另一个线段的值到当前实例
     * @param[zh-cn] l 源线段
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another line segment to this instance
     * @param[en] l Source line segment
     * @return[en] This instance
     */
    public func copy(l: Line3): Line3 {
        this.start.copy(l.start)
        this.end.copy(l.end)
        return this
    }

    /**
     * @brief[zh-cn] 获取线段中心点
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 中心点
     *
     * @brief[en] Get the center point of the line segment
     * @param[en] target Target vector
     * @return[en] Center point
     */
    public func getCenter(target: Vector3): Vector3 {
        return target.addVectors(this.start, this.end).multiplyScalar(0.5)
    }

    /**
     * @brief[zh-cn] 获取线段中心点（创建新向量）
     * @return[zh-cn] 中心点
     *
     * @brief[en] Get the center point of the line segment (creates a new vector)
     * @return[en] Center point
     */
    public func getCenter(): Vector3 {
        return this.getCenter(Vector3())
    }

    /**
     * @brief[zh-cn] 计算线段的方向向量（终点 - 起点）
     * @param[zh-cn] target 目标向量
     * @return[zh-cn] 方向向量
     *
     * @brief[en] Compute the direction vector of the line segment (end - start)
     * @param[en] target Target vector
     * @return[en] Direction vector
     */
    public func delta(target: Vector3): Vector3 {
        return target.subVectors(this.end, this.start)
    }

    /**
     * @brief[zh-cn] 计算线段的方向向量（创建新向量）
     * @return[zh-cn] 方向向量
     *
     * @brief[en] Compute the direction vector of the line segment (creates a new vector)
     * @return[en] Direction vector
     */
    public func delta(): Vector3 {
        return this.delta(Vector3())
    }

    /**
     * @brief[zh-cn] 计算线段的长度
     * @return[zh-cn] 长度
     *
     * @brief[en] Compute the length of the line segment
     * @return[en] Length
     */
    public func distance(): Float64 {
        return this.start.distanceTo(this.end)
    }

    /**
     * @brief[zh-cn] 计算线段长度的平方
     * @return[zh-cn] 长度的平方
     *
     * @brief[en] Compute the squared length of the line segment
     * @return[en] Squared length
     */
    public func distanceSq(): Float64 {
        return this.start.distanceToSquared(this.end)
    }

    /**
     * @brief[zh-cn] 获取线段上指定参数位置的点
     * @param[zh-cn] t 参数值，0 为起点，1 为终点
     * target 目标向量
     * @return[zh-cn] 线段上的点
     *
     * @brief[en] Get the point at a specified parameter position on the line segment
     * @param[en] t Parameter value, 0 for start, 1 for end
     * target Target vector
     * @return[en] Point on the line segment
     */
    public func at(t: Float64, target: Vector3): Vector3 {
        return this.delta(target).multiplyScalar(t).add(this.start)
    }

    /**
     * @brief[zh-cn] 获取线段上指定参数位置的点（创建新向量）
     * @param[zh-cn] t 参数值，0 为起点，1 为终点
     * @return[zh-cn] 线段上的点
     *
     * @brief[en] Get the point at a specified parameter position on the line segment (creates a new vector)
     * @param[en] t Parameter value, 0 for start, 1 for end
     * @return[en] Point on the line segment
     */
    public func at(t: Float64): Vector3 {
        return this.at(t, Vector3())
    }

    /**
     * @brief[zh-cn] 计算点到线段的最近点参数
     * @param[zh-cn] point 点
     * clampToLine 是否限制在线段范围内，默认为 true
     * @return[zh-cn] 参数值
     *
     * @brief[en] Compute the closest point parameter on the line segment to a given point
     * @param[en] point Point
     * clampToLine Whether to clamp to the line segment range, default true
     * @return[en] Parameter value
     */
    public func closestPointToPointParameter(point: Vector3, clampToLine!: Bool = true): Float64 {
        let startP = Vector3().subVectors(point, this.start)
        let startEnd = Vector3().subVectors(this.end, this.start)
        let t = startP.dot(startEnd) / startEnd.dot(startEnd)
        if (clampToLine) {
            return clamp(t, 0.0, 1.0)
        }
        return t
    }

    /**
     * @brief[zh-cn] 计算点到线段的最近点
     * @param[zh-cn] point 点
     * target 目标向量
     * clampToLine 是否限制在线段范围内，默认为 true
     * @return[zh-cn] 最近点
     *
     * @brief[en] Compute the closest point on the line segment to a given point
     * @param[en] point Point
     * target Target vector
     * clampToLine Whether to clamp to the line segment range, default true
     * @return[en] Closest point
     */
    public func closestPointToPoint(point: Vector3, target: Vector3, clampToLine!: Bool = true): Vector3 {
        let t = this.closestPointToPointParameter(point, clampToLine: clampToLine)
        return this.delta(target).multiplyScalar(t).add(this.start)
    }

    /**
     * @brief[zh-cn] 计算点到线段的最近点（创建新向量）
     * @param[zh-cn] point 点
     * clampToLine 是否限制在线段范围内，默认为 true
     * @return[zh-cn] 最近点
     *
     * @brief[en] Compute the closest point on the line segment to a given point (creates a new vector)
     * @param[en] point Point
     * clampToLine Whether to clamp to the line segment range, default true
     * @return[en] Closest point
     */
    public func closestPointToPoint(point: Vector3, clampToLine!: Bool = true): Vector3 {
        return this.closestPointToPoint(point, Vector3(), clampToLine: clampToLine)
    }

    /**
     * @brief[zh-cn] 计算两条线段之间的最近距离平方
     * @explain[zh-cn] Real-Time Collision Detection 5.1.9
     * @param[zh-cn] line 另一条线段
     * c1 本线段上的最近点（输出）
     * c2 另一线段上的最近点（输出）
     * @return[zh-cn] 最近距离的平方
     *
     * @brief[en] Compute the squared closest distance between two line segments
     * @explain[en] JS reference: Line3.distanceSqToLine3, Real-Time Collision Detection 5.1.9
     * @param[en] line Another line segment
     * c1 Closest point on this line segment (output)
     * c2 Closest point on the other line segment (output)
     * @return[en] Squared closest distance
     */
    public func distanceSqToLine3(line: Line3, c1: Vector3, c2: Vector3): Float64 {
        let EPSILON = 1e-8 * 1e-8
        var s: Float64 = 0.0
        var t: Float64 = 0.0

        let p1 = this.start
        let p2 = line.start
        let q1 = this.end
        let q2 = line.end

        let d1 = Vector3().subVectors(q1, p1)
        let d2 = Vector3().subVectors(q2, p2)
        let r = Vector3().subVectors(p1, p2)

        let a = d1.dot(d1)
        let e = d2.dot(d2)
        let f = d2.dot(r)

        if (a <= EPSILON && e <= EPSILON) {
            // 两条线段都退化为点
            c1.copy(p1)
            c2.copy(p2)
            c1.sub(c2)
            return c1.dot(c1)
        }

        if (a <= EPSILON) {
            // 第一条线段退化为点
            s = 0.0
            t = clamp(f / e, 0.0, 1.0)
        } else {
            let c = d1.dot(r)
            if (e <= EPSILON) {
                // 第二条线段退化为点
                t = 0.0
                s = clamp(-c / a, 0.0, 1.0)
            } else {
                // 一般非退化情况
                let b = d1.dot(d2)
                let denom = a * e - b * b
                if (denom != 0.0) {
                    s = clamp((b * f - c * e) / denom, 0.0, 1.0)
                } else {
                    s = 0.0
                }
                t = (b * s + f) / e
                if (t < 0.0) {
                    t = 0.0
                    s = clamp(-c / a, 0.0, 1.0)
                } else if (t > 1.0) {
                    t = 1.0
                    s = clamp((b - c) / a, 0.0, 1.0)
                }
            }
        }

        c1.copy(p1).addScaledVector(d1, s)
        c2.copy(p2).addScaledVector(d2, t)
        return c1.distanceToSquared(c2)
    }

    /**
     * @brief[zh-cn] 应用 4x4 变换矩阵到线段（起点与终点分别变换）
     * @explain[zh-cn] 对线段应用 4x4 变换矩阵
     * @param[zh-cn] matrix 变换矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply a 4x4 transformation matrix to the line segment (start and end points transformed separately)
     * @explain[en] JS reference: Line3.applyMatrix4
     * @param[en] matrix Transformation matrix
     * @return[en] This instance
     */
    public func applyMatrix4(matrix: Matrix4): Line3 {
        this.start.applyMatrix4(matrix)
        this.end.applyMatrix4(matrix)
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个线段相等
     * @param[zh-cn] l 另一个线段
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if this line segment equals another
     * @param[en] l Another line segment
     * @return[en] Whether they are equal
     */
    public func equals(l: Line3): Bool {
        return this.start.equals(l.start) && this.end.equals(l.end)
    }

    /**
     * @brief[zh-cn] 从数组设置线段分量
     * @param[zh-cn] array 包含分量值的数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set line segment components from an array
     * @param[en] array Array containing component values
     * offset Starting index, default 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Line3 {
        this.start.fromArray(array, offset: offset)
        this.end.fromArray(array, offset: offset + 3)
        return this
    }

    /**
     * @brief[zh-cn] 将线段分量写入数组
     * @param[zh-cn] array 目标数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 包含分量值的数组
     *
     * @brief[en] Write line segment components to an array
     * @param[en] array Target array
     * offset Starting index, default 0
     * @return[en] Array containing component values
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        this.start.toArray(array, offset: offset)
        this.end.toArray(array, offset: offset + 3)
        return array
    }
}
