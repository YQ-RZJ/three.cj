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
 * @file[zh-cn] 2x2 矩阵
 * @file[en] 2x2 Matrix
 * @brief[zh-cn] 表示 2x2 矩阵，列主序存储
 * @brief[en] Represents a 2x2 matrix stored in column-major order
 * @explain[zh-cn] 构造函数和 set() 方法的参数按行主序提供，
 *       但内部 elements 数组按列主序存储。
 *       例如：set(11, 12, 21, 22) 对应 elements = [11, 21, 12, 22]
 *
 * @explain[en] Constructor and set() method parameters are provided in row-major order,
 *       but the internal elements array is stored in column-major order.
 *       For example: set(11, 12, 21, 22) corresponds to elements = [11, 21, 12, 22]
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] 2x2 矩阵类，列主序存储
 * @brief[en] 2x2 matrix class, stored in column-major order
 * @explain[zh-cn] 矩阵元素存储在 elements 数组中，按列主序排列：
 *       elements = [n11, n21, n12, n22]
 *       其中 n11, n12 为第一行，n21, n22 为第二行。
 *
 * @explain[en] Matrix elements are stored in the elements array in column-major order:
 *       elements = [n11, n21, n12, n22]
 *       where n11, n12 are the first row, n21, n22 are the second row.
 */
public class Matrix2 {
    /**
     * @brief[zh-cn] 矩阵元素，列主序存储
     * @brief[en] Matrix elements, stored in column-major order
     */
    public var elements: Array<Float64>

    /**
     * @brief[zh-cn] 构造一个新的 2x2 矩阵，如果提供参数则按行主序设置矩阵元素
     * @brief[en] Construct a new 2x2 matrix, set elements in row-major order if parameters are provided
     *
     * @param[zh-cn] n11 第 1 行第 1 列元素
     * @param[zh-cn] n12 第 1 行第 2 列元素
     * @param[zh-cn] n21 第 2 行第 1 列元素
     * @param[zh-cn] n22 第 2 行第 2 列元素
     *
     * @param[en] n11 Element at row 1, column 1
     * @param[en] n12 Element at row 1, column 2
     * @param[en] n21 Element at row 2, column 1
     * @param[en] n22 Element at row 2, column 2
     */
    public init(n11!: Float64 = 1.0, n12!: Float64 = 0.0, n21!: Float64 = 0.0, n22!: Float64 = 1.0) {
        this.elements = Array<Float64>(4, { _ => 0.0 })
        this.set(n11, n12, n21, n22)
    }

    /**
     * @brief[zh-cn] 设置矩阵为单位矩阵
     * @brief[en] Set the matrix to the identity matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func identity(): Matrix2 {
        this.elements[0] = 1.0; this.elements[1] = 0.0
        this.elements[2] = 0.0; this.elements[3] = 1.0
        return this
    }

    /**
     * @brief[zh-cn] 按行主序设置矩阵元素
     * @brief[en] Set matrix elements in row-major order
     *
     * @param[zh-cn] n11 第 1 行第 1 列元素
     * @param[zh-cn] n12 第 1 行第 2 列元素
     * @param[zh-cn] n21 第 2 行第 1 列元素
     * @param[zh-cn] n22 第 2 行第 2 列元素
     *
     * @param[en] n11 Element at row 1, column 1
     * @param[en] n12 Element at row 1, column 2
     * @param[en] n21 Element at row 2, column 1
     * @param[en] n22 Element at row 2, column 2
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func set(n11: Float64, n12: Float64, n21: Float64, n22: Float64): Matrix2 {
        this.elements[0] = n11; this.elements[1] = n21
        this.elements[2] = n12; this.elements[3] = n22
        return this
    }

    /**
     * @brief[zh-cn] 计算矩阵的行列式
     * @brief[en] Calculate the determinant of the matrix
     *
     * @return[zh-cn] 行列式值
     * @return[en] The determinant value
     */
    public func determinant(): Float64 {
        return this.elements[0] * this.elements[3] - this.elements[1] * this.elements[2]
    }

    /**
     * @brief[zh-cn] 创建此矩阵的副本
     * @brief[en] Create a copy of this matrix
     *
     * @return[zh-cn] 新的 Matrix2 实例
     * @return[en] A new Matrix2 instance
     */
    public func clone(): Matrix2 {
        let m = Matrix2()
        m.copy(this)
        return m
    }

    /**
     * @brief[zh-cn] 将另一个矩阵的值复制到此矩阵
     * @brief[en] Copy values from another matrix to this matrix
     *
     * @param[zh-cn] m 源矩阵
     *
     * @param[en] m Source matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func copy(m: Matrix2): Matrix2 {
        for (i in 0..4) {
            this.elements[i] = m.elements[i]
        }
        return this
    }

    /**
     * @brief[zh-cn] 将此矩阵的值复制到目标矩阵
     * @brief[en] Copy values from this matrix to a target matrix
     *
     * @param[zh-cn] m 目标矩阵
     *
     * @param[en] m Target matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func copyTo(m: Matrix2): Matrix2 {
        for (i in 0..4) {
            m.elements[i] = this.elements[i]
        }
        return this
    }

    /**
     * @brief[zh-cn] 计算矩阵的逆矩阵，如果行列式为 0 则将矩阵重置为单位矩阵
     * @brief[en] Calculate the inverse of the matrix, reset to identity if determinant is 0
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func inverse(): Matrix2 {
        let te = this.elements
        let a = te[0]; let b = te[1]; let c = te[2]; let d = te[3]
        let det = a * d - b * c
        if (det == 0.0) { return this.identity() }
        let detInv = 1.0 / det
        te[0] = d * detInv; te[1] = -b * detInv
        te[2] = -c * detInv; te[3] = a * detInv
        return this
    }

    /**
     * @brief[zh-cn] 转置矩阵
     * @brief[en] Transpose the matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func transpose(): Matrix2 {
        let te = this.elements
        let tmp = te[1]
        te[1] = te[2]
        te[2] = tmp
        return this
    }

    /**
     * @brief[zh-cn] 检查此矩阵是否与另一个矩阵相等
     * @brief[en] Check if this matrix equals another matrix
     *
     * @param[zh-cn] m 要比较的矩阵
     *
     * @param[en] m The matrix to compare with
     *
     * @return[zh-cn] 如果所有元素相等则返回 true
     * @return[en] Returns true if all elements are equal
     */
    public func equals(m: Matrix2): Bool {
        for (i in 0..4) {
            if (this.elements[i] != m.elements[i]) { return false }
        }
        return true
    }

    /**
     * @brief[zh-cn] 从数组中读取矩阵元素（列主序）
     * @brief[en] Read matrix elements from an array (column-major order)
     *
     * @param[zh-cn] array 源数组
     * @param[zh-cn] offset 数组中的起始偏移量，默认为 0
     *
     * @param[en] array Source array
     * @param[en] offset Starting offset in the array, defaults to 0
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func fromArray(array: Array<Float64>, offset!: Int64 = 0): Matrix2 {
        for (i in 0..4) {
            this.elements[i] = array[i + offset]
        }
        return this
    }

    /**
     * @brief[zh-cn] 将矩阵元素写入数组（列主序）
     * @brief[en] Write matrix elements to an array (column-major order)
     *
     * @param[zh-cn] array 目标数组，如果为 None 则创建新数组
     * @param[zh-cn] offset 数组中的起始偏移量，默认为 0
     *
     * @param[en] array Target array, creates a new array if None
     * @param[en] offset Starting offset in the array, defaults to 0
     *
     * @return[zh-cn] 包含矩阵元素的数组
     * @return[en] Array containing the matrix elements
     */
    public func toArray(array!: Option<Array<Float64>> = None, offset!: Int64 = 0): Array<Float64> {
        let arr = match (array) {
            case Some(a) => a
            case None => Array<Float64>(4, { _ => 0.0 })
        }
        arr[offset] = this.elements[0]
        arr[offset + 1] = this.elements[1]
        arr[offset + 2] = this.elements[2]
        arr[offset + 3] = this.elements[3]
        return arr
    }

    /**
     * @brief[zh-cn] 将此矩阵与另一个矩阵相乘
     * @brief[en] Multiply this matrix by another matrix
     *
     * @param[zh-cn] m 右操作数矩阵
     *
     * @param[en] m Right-hand side matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func multiply(m: Matrix2): Matrix2 {
        return this.multiplyMatrices(this, m)
    }

    /**
     * @brief[zh-cn] 计算两个矩阵的乘积并存储到此矩阵
     * @brief[en] Calculate the product of two matrices and store in this matrix
     *
     * @param[zh-cn] a 左操作数矩阵
     * @param[zh-cn] b 右操作数矩阵
     *
     * @param[en] a Left-hand side matrix
     * @param[en] b Right-hand side matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func multiplyMatrices(a: Matrix2, b: Matrix2): Matrix2 {
        let ae = a.elements
        let be = b.elements
        let te = this.elements
        let a11 = ae[0]; let a12 = ae[2]
        let a21 = ae[1]; let a22 = ae[3]
        let b11 = be[0]; let b12 = be[2]
        let b21 = be[1]; let b22 = be[3]
        te[0] = a11 * b11 + a12 * b21
        te[2] = a11 * b12 + a12 * b22
        te[1] = a21 * b11 + a22 * b21
        te[3] = a21 * b12 + a22 * b22
        return this
    }

    /**
     * @brief[zh-cn] 将矩阵的每个元素乘以标量
     * @brief[en] Multiply each element of the matrix by a scalar
     *
     * @param[zh-cn] s 标量值
     *
     * @param[en] s Scalar value
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func multiplyScalar(s: Float64): Matrix2 {
        this.elements[0] *= s; this.elements[1] *= s
        this.elements[2] *= s; this.elements[3] *= s
        return this
    }

    /**
     * @brief[zh-cn] 创建旋转矩阵
     * @brief[en] Create a rotation matrix
     *
     * @param[zh-cn] theta 旋转角度（弧度）
     *
     * @param[en] theta Rotation angle in radians
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func makeRotation(theta: Float64): Matrix2 {
        let c = cos(theta)
        let s = sin(theta)
        this.set(c, -s, s, c)
        return this
    }

    /**
     * @brief[zh-cn] 创建缩放矩阵
     * @brief[en] Create a scaling matrix
     *
     * @param[zh-cn] sx X 轴缩放因子
     * @param[zh-cn] sy Y 轴缩放因子
     *
     * @param[en] sx X-axis scale factor
     * @param[en] sy Y-axis scale factor
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func makeScale(sx: Float64, sy: Float64): Matrix2 {
        this.set(sx, 0.0, 0.0, sy)
        return this
    }

    /**
     * @brief[zh-cn] 创建平移矩阵
     * @brief[en] Create a translation matrix
     *
     * @param[zh-cn] tx X 轴平移量
     * @param[zh-cn] ty Y 轴平移量
     *
     * @param[en] tx X-axis translation amount
     * @param[en] ty Y-axis translation amount
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func makeTranslation(tx: Float64, ty: Float64): Matrix2 {
        this.set(1.0, tx, 0.0, ty)
        return this
    }

    /**
     * @brief[zh-cn] 从 3x3 矩阵中提取 2x2 子矩阵
     * @brief[en] Extract a 2x2 sub-matrix from a 3x3 matrix
     *
     * @param[zh-cn] m 源 3x3 矩阵
     *
     * @param[en] m Source 3x3 matrix
     *
     * @return[zh-cn] 当前矩阵实例（支持链式调用）
     * @return[en] Current matrix instance (supports chaining)
     */
    public func setFromMatrix3(m: Matrix3): Matrix2 {
        let me = m.elements
        this.set(me[0], me[3], me[1], me[4])
        return this
    }
}
