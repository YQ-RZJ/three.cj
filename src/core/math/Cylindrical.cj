/**
 * @file[zh-cn] Cylindrical
 * @brief[zh-cn] 圆柱坐标
 * @explain[zh-cn] 表示三维空间中的圆柱坐标 (radius, theta, y)。参考：https://en.wikipedia.org/wiki/Cylindrical_coordinate_system
 *
 * @file[en] Cylindrical
 * @brief[en] Cylindrical coordinates
 * @explain[en] Represents a point in 3D space using cylindrical coordinates (radius, theta, y). Reference: https://en.wikipedia.org/wiki/Cylindrical_coordinate_system
 */
package three.core.math

import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 圆柱坐标类，用于表示三维空间中的点
 * @explain[zh-cn] 使用 (radius, theta, y) 表示空间位置，radius 为到 xz 平面上某点的距离，theta 为从正 z 轴逆时针测量的角度，y 为高度
 *
 * @brief[en] Cylindrical coordinates class for representing points in 3D space
 * @explain[en] Uses (radius, theta, y) to represent spatial position, where radius is the distance from origin to a point on the xz plane, theta is the angle measured counterclockwise from the positive z axis, and y is the height
 */
@JsonAdapter
public class Cylindrical {
    /**
     * @brief[zh-cn] 从原点到 xz 平面上某点的距离
     *
     * @brief[en] Distance from origin to a point on the xz plane
     */
    public var radius: Float64
    /**
     * @brief[zh-cn] 在 xz 平面上从正 z 轴逆时针测量的角度（弧度）
     *
     * @brief[en] Angle measured counterclockwise from the positive z axis on the xz plane (radians)
     */
    public var theta: Float64
    /**
     * @brief[zh-cn] xz 平面以上的高度
     *
     * @brief[en] Height above the xz plane
     */
    public var y: Float64

    /**
     * @brief[zh-cn] 构造默认圆柱坐标 (1, 0, 0)
     *
     * @brief[en] Construct default cylindrical coordinates (1, 0, 0)
     */
    public init() {
        this.radius = 1.0
        this.theta = 0.0
        this.y = 0.0
    }

    /**
     * @brief[zh-cn] 用指定分量构造圆柱坐标
     * @param[zh-cn] radius 半径
     * theta 角度（弧度）
     * y 高度
     *
     * @brief[en] Construct cylindrical coordinates with specified components
     * @param[en] radius Radius
     * theta Angle (radians)
     * y Height
     */
    public init(radius: Float64, theta: Float64, y: Float64) {
        this.radius = radius
        this.theta = theta
        this.y = y
    }

    /**
     * @brief[zh-cn] 设置圆柱坐标分量
     * @param[zh-cn] radius 半径
     * theta 角度（弧度）
     * y 高度
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set cylindrical coordinate components
     * @param[en] radius Radius
     * theta Angle (radians)
     * y Height
     * @return[en] This instance
     */
    public func set(radius: Float64, theta: Float64, y: Float64): Cylindrical {
        this.radius = radius
        this.theta = theta
        this.y = y
        return this
    }

    /**
     * @brief[zh-cn] 复制另一个圆柱坐标的值到当前实例
     * @param[zh-cn] other 要复制的圆柱坐标
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another cylindrical coordinate to this instance
     * @param[en] other Cylindrical coordinate to copy
     * @return[en] This instance
     */
    public func copy(other: Cylindrical): Cylindrical {
        this.radius = other.radius
        this.theta = other.theta
        this.y = other.y
        return this
    }

    /**
     * @brief[zh-cn] 从笛卡尔坐标向量设置圆柱坐标
     * @param[zh-cn] v 包含笛卡尔坐标的向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set cylindrical coordinates from a Cartesian coordinate vector
     * @param[en] v Vector containing Cartesian coordinates
     * @return[en] This instance
     */
    public func setFromVector3(v: Vector3): Cylindrical {
        return this.setFromCartesianCoords(v.x, v.y, v.z)
    }

    /**
     * @brief[zh-cn] 从笛卡尔坐标设置圆柱坐标
     * @param[zh-cn] x x 坐标
     * y y 坐标
     * z z 坐标
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set cylindrical coordinates from Cartesian coordinates
     * @param[en] x x coordinate
     * y y coordinate
     * z z coordinate
     * @return[en] This instance
     */
    public func setFromCartesianCoords(x: Float64, y: Float64, z: Float64): Cylindrical {
        this.radius = sqrt(x * x + z * z)
        this.theta = atan2(x, z)
        this.y = y
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前圆柱坐标
     * @return[zh-cn] 新的圆柱坐标实例
     *
     * @brief[en] Clone the current cylindrical coordinates
     * @return[en] New cylindrical coordinate instance
     */
    public func clone(): Cylindrical {
        return Cylindrical().copy(this)
    }
}
