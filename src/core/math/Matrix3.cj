/**
 * @file[zh-cn] Matrix3
 * @brief[zh-cn] 3x3 矩阵
 * @explain[zh-cn] 表示 3x3 矩阵，列主序存储。
 *
 * @file[en] Matrix3
 * @brief[en] 3x3 matrix
 * @explain[en] Represents a 3x3 matrix stored in column-major order.
 */
package three.core.math

import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 3x3 矩阵类，列主序存储
 * @explain[zh-cn] 矩阵元素存储在 elements 数组中，按列主序排列。构造函数和 set() 方法的参数按行主序提供。
 *
 * @brief[en] 3x3 matrix class, stored in column-major order
 * @explain[en] Matrix elements are stored in the elements array in column-major order. Constructor and set() method parameters are provided in row-major order.
 */
@JsonAdapter
public class Matrix3 {
    /**
     * @brief[zh-cn] 矩阵元素，列主序存储
     *
     * @brief[en] Matrix elements, stored in column-major order
     */
    public var elements: Array<Float64>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为单位矩阵
     *
     * @brief[en] Default constructor, initializes to identity matrix
     */
    public init() { this.elements = Array<Float64>(9, { _ => 0.0 }); this.identity() }

    /**
     * @brief[zh-cn] 使用指定元素构造 3x3 矩阵（行主序参数）
     * @param[zh-cn] n11 第 1 行第 1 列元素
     * n12 第 1 行第 2 列元素
     * n13 第 1 行第 3 列元素
     * n21 第 2 行第 1 列元素
     * n22 第 2 行第 2 列元素
     * n23 第 2 行第 3 列元素
     * n31 第 3 行第 1 列元素
     * n32 第 3 行第 2 列元素
     * n33 第 3 行第 3 列元素
     *
     * @brief[en] Constructs a 3x3 matrix with specified elements (row-major parameters)
     * @param[en] n11 Row 1, Column 1 element
     * n12 Row 1, Column 2 element
     * n13 Row 1, Column 3 element
     * n21 Row 2, Column 1 element
     * n22 Row 2, Column 2 element
     * n23 Row 2, Column 3 element
     * n31 Row 3, Column 1 element
     * n32 Row 3, Column 2 element
     * n33 Row 3, Column 3 element
     */
    public init(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64) {
        this.elements = Array<Float64>(9, { _ => 0.0 })
        this.set(n11, n12, n13, n21, n22, n23, n31, n32, n33)
    }

    /**
     * @brief[zh-cn] 按行主序设置矩阵元素
     * @param[zh-cn] n11 第 1 行第 1 列元素
     * n12 第 1 行第 2 列元素
     * n13 第 1 行第 3 列元素
     * n21 第 2 行第 1 列元素
     * n22 第 2 行第 2 列元素
     * n23 第 2 行第 3 列元素
     * n31 第 3 行第 1 列元素
     * n32 第 3 行第 2 列元素
     * n33 第 3 行第 3 列元素
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets matrix elements in row-major order
     * @param[en] n11 Row 1, Column 1 element
     * n12 Row 1, Column 2 element
     * n13 Row 1, Column 3 element
     * n21 Row 2, Column 1 element
     * n22 Row 2, Column 2 element
     * n23 Row 2, Column 3 element
     * n31 Row 3, Column 1 element
     * n32 Row 3, Column 2 element
     * n33 Row 3, Column 3 element
     * @return[en] This instance
     */
    public func set(n11: Float64, n12: Float64, n13: Float64, n21: Float64, n22: Float64, n23: Float64, n31: Float64, n32: Float64, n33: Float64): Matrix3 {
        let te = this.elements; te[0] = n11; te[3] = n12; te[6] = n13; te[1] = n21; te[4] = n22; te[7] = n23; te[2] = n31; te[5] = n32; te[8] = n33; return this
    }

    /**
     * @brief[zh-cn] 设置矩阵为单位矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the matrix to the identity matrix
     * @return[en] This instance
     */
    public func identity(): Matrix3 { return this.set(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0) }

    /**
     * @brief[zh-cn] 创建此矩阵的副本
     * @return[zh-cn] 新的 Matrix3 实例
     *
     * @brief[en] Creates a copy of this matrix
     * @return[en] New Matrix3 instance
     */
    public func clone(): Matrix3 { let te = this.elements; return Matrix3(te[0], te[3], te[6], te[1], te[4], te[7], te[2], te[5], te[8]) }

    /**
     * @brief[zh-cn] 将另一个矩阵的值复制到此矩阵
     * @param[zh-cn] m 源矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copies another matrix's values to this matrix
     * @param[en] m Source matrix
     * @return[en] This instance
     */
    public func copy(m: Matrix3): Matrix3 { let te = this.elements; let me = m.elements; for (i in 0..9) { te[i] = me[i] }; return this }

    /**
     * @brief[zh-cn] 将矩阵的每个元素乘以标量
     * @param[zh-cn] s 标量值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies each element of the matrix by a scalar
     * @param[en] s Scalar value
     * @return[en] This instance
     */
    public func multiplyScalar(s: Float64): Matrix3 { for (i in 0..9) { this.elements[i] *= s }; return this }

    /**
     * @brief[zh-cn] 计算矩阵的行列式
     * @return[zh-cn] 行列式值
     *
     * @brief[en] Computes the determinant of the matrix
     * @return[en] Determinant value
     */
    public func determinant(): Float64 {
        let te = this.elements; let a = te[0]; let b = te[1]; let c = te[2]; let d = te[3]; let e = te[4]; let f = te[5]; let g = te[6]; let h = te[7]; let i = te[8]
        return a * e * i - a * f * h - b * d * i + b * f * g + c * d * h - c * e * g
    }

    /**
     * @brief[zh-cn] 从 4x4 矩阵中提取 3x3 逆矩阵
     * @param[zh-cn] m 源 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Extracts the 3x3 inverse from a 4x4 matrix
     * @param[en] m Source 4x4 matrix
     * @return[en] This instance
     */
    public func getInverse(m: Matrix4): Matrix3 {
        let me = m.elements; let m11 = me[0]; let m21 = me[1]; let m31 = me[2]; let m12 = me[4]; let m22 = me[5]; let m32 = me[6]; let m13 = me[8]; let m23 = me[9]; let m33 = me[10]
        let det = this.determinant()
        if (det == 0.0) { return this.identity() }
        let detInv = 1.0 / det; let te = this.elements
        te[0] = (m22 * m33 - m32 * m23) * detInv; te[3] = (m13 * m32 - m12 * m33) * detInv; te[6] = (m12 * m23 - m13 * m22) * detInv
        te[1] = (m23 * m31 - m21 * m33) * detInv; te[4] = (m11 * m33 - m13 * m31) * detInv; te[7] = (m13 * m21 - m11 * m23) * detInv
        te[2] = (m21 * m32 - m31 * m22) * detInv; te[5] = (m12 * m31 - m11 * m32) * detInv; te[8] = (m11 * m22 - m12 * m21) * detInv
        return this
    }

    /**
     * @brief[zh-cn] 转置矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Transposes the matrix
     * @return[en] This instance
     */
    public func transpose(): Matrix3 { let te = this.elements; var tmp: Float64; tmp = te[1]; te[1] = te[3]; te[3] = tmp; tmp = te[2]; te[2] = te[6]; te[6] = tmp; tmp = te[5]; te[5] = te[7]; te[7] = tmp; return this }

    /**
     * @brief[zh-cn] 检查此矩阵是否与另一个矩阵相等
     * @param[zh-cn] m 要比较的矩阵
     * @return[zh-cn] 如果所有元素相等则返回 true
     *
     * @brief[en] Checks if this matrix equals another matrix
     * @param[en] m Matrix to compare
     * @return[en] True if all elements are equal
     */
    public func equals(m: Matrix3): Bool { for (i in 0..9) { if (this.elements[i] != m.elements[i]) { return false } }; return true }

    /**
     * @brief[zh-cn] 将此矩阵与另一个矩阵相乘
     * @param[zh-cn] m 右操作数矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Multiplies this matrix by another matrix
     * @param[en] m Right-hand side matrix
     * @return[en] This instance
     */
    public func multiply(m: Matrix3): Matrix3 { return this.multiplyMatrices(this, m) }

    /**
     * @brief[zh-cn] 计算两个矩阵的乘积并存储到此矩阵
     * @param[zh-cn] a 左操作数矩阵
     * b 右操作数矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Computes the product of two matrices and stores it in this matrix
     * @param[en] a Left-hand side matrix
     * b Right-hand side matrix
     * @return[en] This instance
     */
    public func multiplyMatrices(a: Matrix3, b: Matrix3): Matrix3 {
        let ae = a.elements; let be = b.elements; let te = this.elements
        let a11 = ae[0]; let a12 = ae[3]; let a13 = ae[6]
        let a21 = ae[1]; let a22 = ae[4]; let a23 = ae[7]
        let a31 = ae[2]; let a32 = ae[5]; let a33 = ae[8]
        let b11 = be[0]; let b12 = be[3]; let b13 = be[6]
        let b21 = be[1]; let b22 = be[4]; let b23 = be[7]
        let b31 = be[2]; let b32 = be[5]; let b33 = be[8]
        te[0] = a11*b11 + a12*b21 + a13*b31; te[3] = a11*b12 + a12*b22 + a13*b32; te[6] = a11*b13 + a12*b23 + a13*b33
        te[1] = a21*b11 + a22*b21 + a23*b31; te[4] = a21*b12 + a22*b22 + a23*b32; te[7] = a21*b13 + a22*b23 + a23*b33
        te[2] = a31*b11 + a32*b21 + a33*b31; te[5] = a31*b12 + a32*b22 + a33*b32; te[8] = a31*b13 + a32*b23 + a33*b33
        return this
    }

    /**
     * @brief[zh-cn] 缩放矩阵的前两列
     * @param[zh-cn] v 缩放值
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Scales the first two columns of the matrix
     * @param[en] v Scale value
     * @return[en] This instance
     */
    public func scale(v: Float64): Matrix3 { let te = this.elements; te[0] *= v; te[3] *= v; te[6] *= v; te[1] *= v; te[4] *= v; te[7] *= v; return this }

    /**
     * @brief[zh-cn] 从 4x4 矩阵计算法线矩阵
     * @param[zh-cn] m 源 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Computes the normal matrix from a 4x4 matrix
     * @param[en] m Source 4x4 matrix
     * @return[en] This instance
     */
    public func getNormalMatrix(m: Matrix4): Matrix3 {
        let me = m.elements; let m11 = me[0]; let m21 = me[1]; let m31 = me[2]; let m12 = me[4]; let m22 = me[5]; let m32 = me[6]; let m13 = me[8]; let m23 = me[9]; let m33 = me[10]
        let det = m11*(m22*m33 - m32*m23) - m12*(m21*m33 - m31*m23) + m13*(m21*m32 - m31*m22)
        if (det == 0.0) { return this.identity() }
        let detInv = 1.0/det; let te = this.elements
        te[0] = (m22*m33 - m32*m23)*detInv; te[3] = (m13*m32 - m12*m33)*detInv; te[6] = (m12*m23 - m13*m22)*detInv
        te[1] = (m23*m31 - m21*m33)*detInv; te[4] = (m11*m33 - m13*m31)*detInv; te[7] = (m13*m21 - m11*m23)*detInv
        te[2] = (m21*m32 - m31*m22)*detInv; te[5] = (m12*m31 - m11*m32)*detInv; te[8] = (m11*m22 - m12*m21)*detInv
        return this
    }

    /**
     * @brief[zh-cn] 从数组中读取矩阵元素（列主序）
     * @param[zh-cn] array 源数组
     * offset 数组中的起始偏移量，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Reads matrix elements from an array (column-major order)
     * @param[en] array Source array
     * offset Starting offset in the array, defaults to 0
     * @return[en] This instance
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Matrix3 { for (i in 0..9) { this.elements[i] = array[i + offset] }; return this }

    /**
     * @brief[zh-cn] 将矩阵元素写入数组（列主序）
     * @param[zh-cn] array 目标数组
     * offset 起始偏移量，默认为 0
     * @return[zh-cn] 包含矩阵元素的数组
     *
     * @brief[en] Writes matrix elements into an array (column-major order)
     * @param[en] array Target array
     * offset Starting offset, defaults to 0
     * @return[en] Array containing matrix elements
     */
    public func toArray(array: Array<Float64>, offset!: Int64 = 0): Array<Float64> { for (i in 0..9) { array[i + offset] = this.elements[i] }; return array }

    /**
     * @brief[zh-cn] 将转置后的矩阵元素写入数组
     * @param[zh-cn] r 目标数组
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Writes transposed matrix elements into an array
     * @param[en] r Target array
     * @return[en] This instance
     */
    public func transposeIntoArray(r: Array<Float64>): Matrix3 { let te = this.elements; r[0] = te[0]; r[1] = te[1]; r[2] = te[2]; r[3] = te[3]; r[4] = te[4]; r[5] = te[5]; r[6] = te[6]; r[7] = te[7]; r[8] = te[8]; return this }

    /**
     * @brief[zh-cn] 设置 UV 变换矩阵
     * @param[zh-cn] tx X 轴平移量
     * ty Y 轴平移量
     * sx X 轴缩放因子
     * sy Y 轴缩放因子
     * rotation 旋转角度（弧度）
     * cx 旋转中心 X 坐标
     * cy 旋转中心 Y 坐标
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets the UV transform matrix
     * @param[en] tx X-axis translation
     * ty Y-axis translation
     * sx X-axis scale factor
     * sy Y-axis scale factor
     * rotation Rotation angle in radians
     * cx Rotation center X coordinate
     * cy Rotation center Y coordinate
     * @return[en] This instance
     */
    public func setUvTransform(tx: Float64, ty: Float64, sx: Float64, sy: Float64, rotation: Float64, cx: Float64, cy: Float64): Matrix3 {
        let c = cos(rotation); let s = sin(rotation)
        return this.set(sx*c, sx*(-s), -cx*(sx*c) + cy*(sx*(-s)) + tx, sy*s, sy*c, -cx*(sy*s) + cy*(sy*c) + ty, 0.0, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 从 4x4 矩阵中提取 3x3 子矩阵
     * @param[zh-cn] m 源 4x4 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Extracts a 3x3 submatrix from a 4x4 matrix
     * @param[en] m Source 4x4 matrix
     * @return[en] This instance
     */
    public func setFromMatrix4(m: Matrix4): Matrix3 {
        let me = m.elements; let te = this.elements
        te[0] = me[0]; te[3] = me[4]; te[6] = me[8]; te[1] = me[1]; te[4] = me[5]; te[7] = me[9]; te[2] = me[2]; te[5] = me[6]; te[8] = me[10]
        return this
    }

    /**
     * @brief[zh-cn] 提取矩阵的基向量
     * @param[zh-cn] xAxis x 轴基向量
     * yAxis y 轴基向量
     * zAxis z 轴基向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Extracts the basis vectors from the matrix
     * @param[en] xAxis X-axis basis vector
     * yAxis Y-axis basis vector
     * zAxis Z-axis basis vector
     * @return[en] This instance
     */
    public func extractBasis(xAxis: Vector3, yAxis: Vector3, zAxis: Vector3): Matrix3 {
        xAxis.setFromMatrix3Column(this, 0)
        yAxis.setFromMatrix3Column(this, 1)
        zAxis.setFromMatrix3Column(this, 2)
        return this
    }

    /**
     * @brief[zh-cn] 前置乘以给定矩阵：m * this
     * @param[zh-cn] m 矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Pre-multiplies by the given matrix: m * this
     * @param[en] m Matrix
     * @return[en] This instance
     */
    public func premultiply(m: Matrix3): Matrix3 {
        return this.multiplyMatrices(m, this)
    }

    /**
     * @brief[zh-cn] 求逆矩阵（使用解析方法）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Computes the inverse matrix (using analytical method)
     * @return[en] This instance
     */
    public func invert(): Matrix3 {
        let te = this.elements
        let n11 = te[0]; let n21 = te[1]; let n31 = te[2]
        let n12 = te[3]; let n22 = te[4]; let n32 = te[5]
        let n13 = te[6]; let n23 = te[7]; let n33 = te[8]
        let t11 = n33 * n22 - n32 * n23
        let t12 = n32 * n13 - n33 * n12
        let t13 = n23 * n12 - n22 * n13
        let det = n11 * t11 + n21 * t12 + n31 * t13
        if (det == 0.0) { return this.set(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) }
        let detInv = 1.0 / det
        te[0] = t11 * detInv
        te[1] = (n31 * n23 - n33 * n21) * detInv
        te[2] = (n32 * n21 - n31 * n22) * detInv
        te[3] = t12 * detInv
        te[4] = (n33 * n11 - n31 * n13) * detInv
        te[5] = (n31 * n12 - n32 * n11) * detInv
        te[6] = t13 * detInv
        te[7] = (n21 * n13 - n23 * n11) * detInv
        te[8] = (n22 * n11 - n21 * n12) * detInv
        return this
    }

    /**
     * @brief[zh-cn] 设置为 2D 平移矩阵
     * @param[zh-cn] x X 轴平移量
     * y Y 轴平移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets as a 2D translation matrix
     * @param[en] x X-axis translation
     * y Y-axis translation
     * @return[en] This instance
     */
    public func makeTranslation(x: Float64, y: Float64): Matrix3 {
        return this.set(1.0, 0.0, x, 0.0, 1.0, y, 0.0, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 设置为 2D 旋转矩阵
     * @param[zh-cn] theta 旋转角度（弧度），逆时针方向
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets as a 2D rotation matrix
     * @param[en] theta Rotation angle in radians, counterclockwise
     * @return[en] This instance
     */
    public func makeRotation(theta: Float64): Matrix3 {
        let c = cos(theta)
        let s = sin(theta)
        return this.set(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 设置为 2D 缩放矩阵
     * @param[zh-cn] x X 轴缩放量
     * y Y 轴缩放量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Sets as a 2D scale matrix
     * @param[en] x X-axis scale
     * y Y-axis scale
     * @return[en] This instance
     */
    public func makeScale(x: Float64, y: Float64): Matrix3 {
        return this.set(x, 0.0, 0.0, 0.0, y, 0.0, 0.0, 0.0, 1.0)
    }

    /**
     * @brief[zh-cn] 旋转矩阵（deprecated，用 makeRotation 替代）
     * @explain[zh-cn] 对当前矩阵做前置旋转（负角度，逆时针）
     * @param[zh-cn] theta 旋转角度（弧度）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Rotates the matrix (cf. JS: Matrix3.rotate, deprecated - use makeRotation instead)
     * @explain[en] Pre-multiplies a rotation (negative angle, counterclockwise) to this matrix
     * @param[en] theta Rotation angle in radians
     * @return[en] This instance
     */
    public func rotate(theta: Float64): Matrix3 {
        return this.premultiply(Matrix3().makeRotation(-theta))
    }

    /**
     * @brief[zh-cn] 平移矩阵（deprecated，用 makeTranslation 替代）
     * @explain[zh-cn] 对当前矩阵做前置平移
     * @param[zh-cn] tx X 轴平移量
     * ty Y 轴平移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Translates the matrix (cf. JS: Matrix3.translate, deprecated - use makeTranslation instead)
     * @explain[en] Pre-multiplies a translation to this matrix
     * @param[en] tx X-axis translation
     * ty Y-axis translation
     * @return[en] This instance
     */
    public func translate(tx: Float64, ty: Float64): Matrix3 {
        return this.premultiply(Matrix3().makeTranslation(tx, ty))
    }
}
