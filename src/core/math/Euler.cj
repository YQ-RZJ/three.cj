/**
 * @file[zh-cn] Euler
 * @brief[zh-cn] 欧拉角
 * @explain[zh-cn] 表示三维空间中的旋转，使用三个角度和旋转顺序。
 *
 * @file[en] Euler
 * @brief[en] Euler angles
 * @explain[en] Represents rotation in 3D space using three angles and rotation order.
 */
package three.core.math

import std.math.*
import std.deriving.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 欧拉角类，用三个角度 (x, y, z) 和旋转顺序 (order) 描述旋转
 * @explain[zh-cn] 旋转顺序决定旋转的应用次序。x/y/z/order 使用 mut prop，赋值时触发 _onChangeCallback
 *
 * @brief[en] Euler angles class, describing rotation using three angles (x, y, z) and rotation order
 * @explain[en] The rotation order determines the application sequence of rotations. x/y/z/order use mut prop, triggering _onChangeCallback on assignment
 */
@JsonAdapter
public class Euler {
    /**
     * @brief[zh-cn] x 轴旋转角度（弧度）—— 私有 backing field，JSON 字段名映射为 "x"
     */
    @JsonName["x"]
    private var _x: Float64
    /**
     * @brief[zh-cn] y 轴旋转角度（弧度）—— 私有 backing field，JSON 字段名映射为 "y"
     */
    @JsonName["y"]
    private var _y: Float64
    /**
     * @brief[zh-cn] z 轴旋转角度（弧度）—— 私有 backing field，JSON 字段名映射为 "z"
     */
    @JsonName["z"]
    private var _z: Float64
    /**
     * @brief[zh-cn] 旋转顺序 —— 私有 backing field（枚举类型，fastjson 暂不支持，序列化忽略）
     */
    @JsonIgnore
    private var _order: EulerOrder

    /**
     * @brief[zh-cn] x 轴旋转角度（弧度），赋值时触发 onChange 回调
     *
     * @brief[en] x-axis rotation angle in radians, triggers onChange callback on assignment
     */
    @JsonIgnore
    public mut prop x: Float64 {
        get() { _x }
        set(value) { _x = value; _onChangeCallback() }
    }
    /**
     * @brief[zh-cn] y 轴旋转角度（弧度），赋值时触发 onChange 回调
     *
     * @brief[en] y-axis rotation angle in radians, triggers onChange callback on assignment
     */
    @JsonIgnore
    public mut prop y: Float64 {
        get() { _y }
        set(value) { _y = value; _onChangeCallback() }
    }
    /**
     * @brief[zh-cn] z 轴旋转角度（弧度），赋值时触发 onChange 回调
     *
     * @brief[en] z-axis rotation angle in radians, triggers onChange callback on assignment
     */
    @JsonIgnore
    public mut prop z: Float64 {
        get() { _z }
        set(value) { _z = value; _onChangeCallback() }
    }
    /**
     * @brief[zh-cn] 旋转顺序，赋值时触发 onChange 回调
     *
     * @brief[en] Rotation order, triggers onChange callback on assignment
     */
    @JsonIgnore
    public mut prop order: EulerOrder {
        get() { _order }
        set(value) { _order = value; _onChangeCallback() }
    }
    /**
     * @brief[zh-cn] 默认旋转顺序（static 成员，不参与序列化）
     *
     * @brief[en] Default rotation order (static member, not serialized)
     */
    @JsonIgnore
    public static let DEFAULT_ORDER: EulerOrder = EulerOrder.XYZ

    /**
     * @brief[zh-cn] 变更回调函数，当欧拉角值改变时调用（函数类型，不支持序列化）
     */
    @JsonIgnore
    private var _onChangeCallback: () -> Unit

    public init() {
        this._x = 0.0
        this._y = 0.0
        this._z = 0.0
        this._order = EulerOrder.XYZ
        this._onChangeCallback = { => }
    }

    public init(x: Float64, y: Float64, z: Float64, order: EulerOrder) {
        this._x = x
        this._y = y
        this._z = z
        this._order = order
        this._onChangeCallback = { => }
    }

    public init(x: Float64, y: Float64, z: Float64) {
        this._x = x
        this._y = y
        this._z = z
        this._order = EulerOrder.XYZ
        this._onChangeCallback = { => }
    }

    /**
     * @brief[zh-cn] 设置欧拉角分量
     * @param[zh-cn] x x 轴旋转角度（弧度）
     * y y 轴旋转角度（弧度）
     * z z 轴旋转角度（弧度）
     * order 旋转顺序
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angle components
     * @param[en] x x-axis rotation angle in radians
     * y y-axis rotation angle in radians
     * z z-axis rotation angle in radians
     * order Rotation order
     * @return[en] This instance
     */
    public func set(x: Float64, y: Float64, z: Float64, order: EulerOrder): Euler {
        this._x = x
        this._y = y
        this._z = z
        this._order = order
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 设置欧拉角分量（保持当前旋转顺序）
     * @param[zh-cn] x x 轴旋转角度（弧度）
     * y y 轴旋转角度（弧度）
     * z z 轴旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angle components (keeping current rotation order)
     * @param[en] x x-axis rotation angle in radians
     * y y-axis rotation angle in radians
     * z z-axis rotation angle in radians
     * @return[en] This instance
     */
    public func set(x: Float64, y: Float64, z: Float64): Euler {
        this._x = x
        this._y = y
        this._z = z
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前欧拉角
     * @return[zh-cn] 新的欧拉角实例
     *
     * @brief[en] Clone current Euler angles
     * @return[en] New Euler angles instance
     */
    public func clone(): Euler {
        return Euler(this._x, this._y, this._z, this._order)
    }

    /**
     * @brief[zh-cn] 复制另一个欧拉角的值到当前实例
     * @param[zh-cn] e 源欧拉角
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another Euler angles to this instance
     * @param[en] e Source Euler angles
     * @return[en] This instance
     */
    public func copy(e: Euler): Euler {
        this._x = e._x
        this._y = e._y
        this._z = e._z
        this._order = e._order
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 从纯旋转矩阵设置欧拉角
     * @explain[zh-cn] 矩阵的上 3x3 部分必须是纯旋转矩阵（无缩放）
     * @param[zh-cn] m 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a pure rotation matrix
     * @explain[en] The upper 3x3 part of the matrix must be a pure rotation matrix (no scaling)
     * @param[en] m 4x4 matrix
     * @return[en] This instance
     */
    public func setFromRotationMatrix(m: Matrix4): Euler {
        return this.setFromRotationMatrix(m, this._order, true)
    }

    /**
     * @brief[zh-cn] 从纯旋转矩阵设置欧拉角（指定旋转顺序）
     * @param[zh-cn] m 4x4 矩阵
     * order 旋转顺序
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a pure rotation matrix with specified order
     * @param[en] m 4x4 matrix
     * order Rotation order
     * @return[en] This instance
     */
    public func setFromRotationMatrix(m: Matrix4, order: EulerOrder): Euler {
        return this.setFromRotationMatrix(m, order, true)
    }

    /**
     * @brief[zh-cn] 从纯旋转矩阵设置欧拉角（指定旋转顺序和是否更新回调）
     * @param[zh-cn] m 4x4 矩阵
     * order 旋转顺序
     * update 是否触发变更回调
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a pure rotation matrix with specified order and update flag
     * @param[en] m 4x4 matrix
     * order Rotation order
     * update Whether to trigger change callback
     * @return[en] This instance
     */
    public func setFromRotationMatrix(m: Matrix4, order: EulerOrder, update: Bool): Euler {
        let te = m.elements
        let m11 = te[0]; let m12 = te[4]; let m13 = te[8]
        let m21 = te[1]; let m22 = te[5]; let m23 = te[9]
        let m31 = te[2]; let m32 = te[6]; let m33 = te[10]

        match (order) {
            case EulerOrder.XYZ =>
                this._y = asin(clamp(m13, -1.0, 1.0))
                if (abs(m13) < 0.9999999) {
                    this._x = atan2(-m23, m33)
                    this._z = atan2(-m12, m11)
                } else {
                    this._x = atan2(m32, m22)
                    this._z = 0.0
                }
            case EulerOrder.YXZ =>
                this._x = asin(-clamp(m23, -1.0, 1.0))
                if (abs(m23) < 0.9999999) {
                    this._y = atan2(m13, m33)
                    this._z = atan2(m21, m22)
                } else {
                    this._y = atan2(-m31, m11)
                    this._z = 0.0
                }
            case EulerOrder.ZXY =>
                this._x = asin(clamp(m32, -1.0, 1.0))
                if (abs(m32) < 0.9999999) {
                    this._y = atan2(-m31, m33)
                    this._z = atan2(-m12, m22)
                } else {
                    this._y = 0.0
                    this._z = atan2(m21, m11)
                }
            case EulerOrder.ZYX =>
                this._y = asin(-clamp(m31, -1.0, 1.0))
                if (abs(m31) < 0.9999999) {
                    this._x = atan2(m32, m33)
                    this._z = atan2(m21, m11)
                } else {
                    this._x = 0.0
                    this._z = atan2(-m12, m22)
                }
            case EulerOrder.YZX =>
                this._z = asin(clamp(m21, -1.0, 1.0))
                if (abs(m21) < 0.9999999) {
                    this._x = atan2(-m23, m22)
                    this._y = atan2(-m31, m11)
                } else {
                    this._x = 0.0
                    this._y = atan2(m13, m33)
                }
            case EulerOrder.XZY =>
                this._z = asin(-clamp(m12, -1.0, 1.0))
                if (abs(m12) < 0.9999999) {
                    this._x = atan2(m32, m22)
                    this._y = atan2(m13, m11)
                } else {
                    this._x = atan2(-m23, m33)
                    this._y = 0.0
                }
        }

        this._order = order
        if (update) {
            this._onChangeCallback()
        }
        return this
    }

    /**
     * @brief[zh-cn] 从归一化四元数设置欧拉角
     * @param[zh-cn] q 归一化的四元数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a normalized quaternion
     * @param[en] q Normalized quaternion
     * @return[en] This instance
     */
    public func setFromQuaternion(q: Quaternion): Euler {
        return this.setFromQuaternion(q, this._order, true)
    }

    /**
     * @brief[zh-cn] 从归一化四元数设置欧拉角（指定旋转顺序）
     * @param[zh-cn] q 归一化的四元数
     * order 旋转顺序
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a normalized quaternion with specified order
     * @param[en] q Normalized quaternion
     * order Rotation order
     * @return[en] This instance
     */
    public func setFromQuaternion(q: Quaternion, order: EulerOrder): Euler {
        return this.setFromQuaternion(q, order, true)
    }

    /**
     * @brief[zh-cn] 从归一化四元数设置欧拉角（指定旋转顺序和是否更新回调）
     * @param[zh-cn] q 归一化的四元数
     * order 旋转顺序
     * update 是否触发变更回调
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a normalized quaternion with specified order and update flag
     * @param[en] q Normalized quaternion
     * order Rotation order
     * update Whether to trigger change callback
     * @return[en] This instance
     */
    public func setFromQuaternion(q: Quaternion, order: EulerOrder, update: Bool): Euler {
        let _matrix = Matrix4()
        _matrix.makeRotationFromQuaternion(q)
        return this.setFromRotationMatrix(_matrix, order, update)
    }

    /**
     * @brief[zh-cn] 从向量设置欧拉角
     * @param[zh-cn] v 向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a vector
     * @param[en] v Vector
     * @return[en] This instance
     */
    public func setFromVector3(v: Vector3): Euler {
        return this.set(v.x, v.y, v.z, this._order)
    }

    /**
     * @brief[zh-cn] 从向量设置欧拉角（指定旋转顺序）
     * @param[zh-cn] v 向量
     * order 旋转顺序
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angles from a vector with specified order
     * @param[en] v Vector
     * order Rotation order
     * @return[en] This instance
     */
    public func setFromVector3(v: Vector3, order: EulerOrder): Euler {
        return this.set(v.x, v.y, v.z, order)
    }

    /**
     * @brief[zh-cn] 重置旋转顺序（通过四元数中转，会丢失旋转圈数信息）
     * @param[zh-cn] newOrder 新的旋转顺序
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reorder rotation order (via quaternion, loses rotation turn information)
     * @param[en] newOrder New rotation order
     * @return[en] This instance
     */
    public func reorder(newOrder: EulerOrder): Euler {
        let _quaternion = Quaternion()
        _quaternion.setFromEuler(this)
        return this.setFromQuaternion(_quaternion, newOrder)
    }

    /**
     * @brief[zh-cn] 判断当前欧拉角是否与给定的欧拉角相等
     * @param[zh-cn] e 比较的欧拉角
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if current Euler angles equal the given Euler angles
     * @param[en] e Euler angles to compare
     * @return[en] Whether equal
     */
    public func equals(e: Euler): Bool {
        return this._x == e._x && this._y == e._y && this._z == e._z && this._order == e._order
    }

    /**
     * @brief[zh-cn] 从数组设置欧拉角分量
     * @explain[zh-cn] 数组前三个元素为 x, y, z 角度，第四个元素（如果存在）为旋转顺序索引
     * @param[zh-cn] array 包含分量值的数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set Euler angle components from array
     * @explain[en] The first three elements are x, y, z angles, the fourth element (if present) is the rotation order index
     * @param[en] array Array containing component values
     * offset Starting index, defaults to 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Euler {
        this._x = array[offset]
        this._y = array[offset + 1]
        this._z = array[offset + 2]
        if (array.size > offset + 3) {
            let orderIndex = Int64(array[offset + 3])
            match (orderIndex) {
                case 0 => this._order = EulerOrder.XYZ
                case 1 => this._order = EulerOrder.YXZ
                case 2 => this._order = EulerOrder.ZXY
                case 3 => this._order = EulerOrder.ZYX
                case 4 => this._order = EulerOrder.YZX
                case 5 => this._order = EulerOrder.XZY
                case _ => ()
            }
        }
        this._onChangeCallback()
        return this
    }

    /**
     * @brief[zh-cn] 将欧拉角分量写入数组
     * @param[zh-cn] array 目标数组
     * offset 起始索引，默认为 0
     * @return[zh-cn] 包含分量值的数组
     *
     * @brief[en] Write Euler angle components to array
     * @param[en] array Target array
     * offset Starting index, defaults to 0
     * @return[en] Array containing component values
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> {
        array[offset] = this._x
        array[offset + 1] = this._y
        array[offset + 2] = this._z
        return array
    }

    /**
     * @brief[zh-cn] 设置变更回调函数，当欧拉角的值被修改时调用
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set change callback function, called when Euler angle values are modified
     * @param[en] callback Callback function
     * @return[en] This instance
     */
    public func onChange(callback: () -> Unit): Euler {
        this._onChangeCallback = callback
        return this
    }
}

/**
 * @brief[zh-cn] 欧拉角旋转顺序枚举
 *
 * @brief[en] Euler angle rotation order enum
 */
@Derive[Equatable]
public enum EulerOrder {
    | XYZ
    | YXZ
    | ZXY
    | ZYX
    | YZX
    | XZY
}