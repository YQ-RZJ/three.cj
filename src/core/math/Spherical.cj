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
 * @file[zh-cn] Spherical
 * @brief[zh-cn] 球坐标
 * @explain[zh-cn] 表示三维空间中的球坐标 (radius, phi, theta)。
 *
 * @file[en] Spherical
 * @brief[en] Spherical coordinates
 * @explain[en] Represents a point in 3D space using spherical coordinates (radius, phi, theta).
 */
package three.core.math

import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 球坐标类，用于表示三维空间中的点
 * @explain[zh-cn] 参考：https://en.wikipedia.org/wiki/Spherical_coordinate_system
 *
 * @brief[en] Spherical coordinates class for representing points in 3D space
 * @explain[en] Reference: https://en.wikipedia.org/wiki/Spherical_coordinate_system
 */
@JsonAdapter
public class Spherical {
    /**
     * @brief[zh-cn] 半径，即从原点到点的欧几里得距离
     *
     * @brief[en] Radius, the Euclidean distance from origin to point
     */
    public var radius: Float64
    /**
     * @brief[zh-cn] 从 y（上）轴开始的极角（弧度）
     *
     * @brief[en] Polar angle from the y (up) axis in radians
     */
    public var phi: Float64
    /**
     * @brief[zh-cn] 绕 y（上）轴的方位角（弧度）
     *
     * @brief[en] Azimuthal angle around the y (up) axis in radians
     */
    public var theta: Float64

    public init() {
        this.radius = 1.0
        this.phi = 0.0
        this.theta = 0.0
    }

    public init(radius: Float64, phi: Float64, theta: Float64) {
        this.radius = radius
        this.phi = phi
        this.theta = theta
    }

    /**
     * @brief[zh-cn] 设置球坐标分量
     * @param[zh-cn] radius 半径
     * phi 极角（弧度）
     * theta 方位角（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set spherical coordinate components
     * @param[en] radius Radius
     * phi Polar angle in radians
     * theta Azimuthal angle in radians
     * @return[en] This instance
     */
    public func set(radius: Float64, phi: Float64, theta: Float64): Spherical {
        this.radius = radius
        this.phi = phi
        this.theta = theta
        return this
    }

    /**
     * @brief[zh-cn] 复制另一个球坐标的值到当前实例
     * @param[zh-cn] other 要复制的球坐标
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another spherical coordinates to this instance
     * @param[en] other Spherical coordinates to copy
     * @return[en] This instance
     */
    public func copy(other: Spherical): Spherical {
        this.radius = other.radius
        this.phi = other.phi
        this.theta = other.theta
        return this
    }

    /**
     * @brief[zh-cn] 将极角 phi 限制在 [0.000001, π - 0.000001] 范围内，避免极点奇异性
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Clamp polar angle phi to [0.000001, π - 0.000001] range to avoid pole singularity
     * @return[en] This instance
     */
    public func makeSafe(): Spherical {
        let EPS: Float64 = 0.000001
        this.phi = clamp(this.phi, EPS, PI - EPS)
        return this
    }

    /**
     * @brief[zh-cn] 从笛卡尔坐标向量设置球坐标
     * @param[zh-cn] v 包含笛卡尔坐标的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set spherical coordinates from Cartesian coordinate vector
     * @param[en] v Vector containing Cartesian coordinates
     * @return[en] This instance
     */
    public func setFromVector3(v: Vector3): Spherical {
        return this.setFromCartesianCoords(v.x, v.y, v.z)
    }

    /**
     * @brief[zh-cn] 从笛卡尔坐标设置球坐标
     * @param[zh-cn] x x 坐标
     * y y 坐标
     * z z 坐标
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set spherical coordinates from Cartesian coordinates
     * @param[en] x x coordinate
     * y y coordinate
     * z z coordinate
     * @return[en] This instance
     */
    public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Spherical {
        this.radius = sqrt(x * x + y * y + z * z)
        if (this.radius == 0.0) {
            this.theta = 0.0
            this.phi = 0.0
        } else {
            this.theta = atan2(x, z)
            this.phi = acos(clamp(y / this.radius, -1.0, 1.0))
        }
        return this
    }

    /**
     * @brief[zh-cn] 将球坐标转换为三维向量
     * @return[zh-cn] 对应的三维向量
     *
     * @brief[en] Convert spherical coordinates to 3D vector
     * @return[en] Corresponding 3D vector
     */
    public func toVector3(): Vector3 {
        let sinPhiRadius = sin(this.phi) * this.radius
        return Vector3(
            sinPhiRadius * sin(this.theta),
            cos(this.phi) * this.radius,
            sinPhiRadius * cos(this.theta)
        )
    }

    /**
     * @brief[zh-cn] 克隆当前球坐标
     * @return[zh-cn] 新的球坐标实例
     *
     * @brief[en] Clone current spherical coordinates
     * @return[en] New spherical coordinates instance
     */
    public func clone(): Spherical {
        return Spherical().copy(this)
    }
}
