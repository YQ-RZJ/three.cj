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
 * @file[zh-cn] Matrix4F
 * @brief[zh-cn] Float32 精度的 4x4 矩阵
 * @explain[zh-cn] 与 Matrix4 (Float64) 功能等价，但使用 Float32 存储以减少内存占用。
 *                  主要用于骨骼动画内部计算（LocalToModelJob 等）。
 *
 * @file[en] Matrix4F
 * @brief[en] Float32-precision 4x4 matrix
 * @explain[en] Equivalent to Matrix4 (Float64) but uses Float32 storage.
 *              Primarily used for skeletal animation internal computation.
 */
package three.core.math

import std.math.*

/**
 * @brief[zh-cn] Float32 4x4 矩阵类（列主序存储）
 *
 * @brief[en] Float32 4x4 matrix class (column-major storage)
 */
public class Matrix4F {
    /**
     * @brief[zh-cn] 16 个矩阵元素，列主序存储
     * @explain[zh-cn] element[col*4 + row]，即元素 0-3 为第0列，4-7 为第1列，依此类推。
     *
     * @brief[en] 16 matrix elements, stored in column-major order
     * @explain[en] element[col*4 + row], i.e. elements 0-3 form column 0, 4-7 column 1, and so on.
     */
    public var elements: Array<Float32>

    public init() {
        this.elements = Array<Float32>(16, { i => if (i % 5 == 0) { 1.0f32} else { 0.0f32} })
    }

    public init(elements: Array<Float32>) {
        this.elements = elements
    }

    // ===== Core =====

    public func clone(): Matrix4F {
        Matrix4F(this.elements.clone())
    }

    public func copy(m: Matrix4F): Matrix4F {
        for (i in 0..16) {
            this.elements[i] = m.elements[i]
        }
        return this
    }

    public func identity(): Matrix4F {
        for (i in 0..16) {
            this.elements[i] = if (i % 5 == 0) { 1.0f32} else { 0.0f32}
        }
        return this
    }

    public func set(
        n11: Float32, n12: Float32, n13: Float32, n14: Float32,
        n21: Float32, n22: Float32, n23: Float32, n24: Float32,
        n31: Float32, n32: Float32, n33: Float32, n34: Float32,
        n41: Float32, n42: Float32, n43: Float32, n44: Float32
    ): Matrix4F {
        let te = this.elements
        te[0] = n11; te[4] = n12; te[8] = n13; te[12] = n14
        te[1] = n21; te[5] = n22; te[9] = n23; te[13] = n24
        te[2] = n31; te[6] = n32; te[10] = n33; te[14] = n34
        te[3] = n41; te[7] = n42; te[11] = n43; te[15] = n44
        return this
    }

    // ===== Multiply =====

    public func multiply(m: Matrix4F): Matrix4F {
        this.multiplyMatrices(this, m)
    }

    public func premultiply(m: Matrix4F): Matrix4F {
        this.multiplyMatrices(m, this)
    }

    public func multiplyMatrices(a: Matrix4F, b: Matrix4F): Matrix4F {
        let ae = a.elements
        let be = b.elements
        let te = this.elements

        let a11 = ae[0]; let a12 = ae[4]; let a13 = ae[8]; let a14 = ae[12]
        let a21 = ae[1]; let a22 = ae[5]; let a23 = ae[9]; let a24 = ae[13]
        let a31 = ae[2]; let a32 = ae[6]; let a33 = ae[10]; let a34 = ae[14]
        let a41 = ae[3]; let a42 = ae[7]; let a43 = ae[11]; let a44 = ae[15]

        let b11 = be[0]; let b12 = be[4]; let b13 = be[8]; let b14 = be[12]
        let b21 = be[1]; let b22 = be[5]; let b23 = be[9]; let b24 = be[13]
        let b31 = be[2]; let b32 = be[6]; let b33 = be[10]; let b34 = be[14]
        let b41 = be[3]; let b42 = be[7]; let b43 = be[11]; let b44 = be[15]

        te[0] = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41
        te[4] = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42
        te[8] = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43
        te[12] = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44

        te[1] = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41
        te[5] = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42
        te[9] = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43
        te[13] = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44

        te[2] = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41
        te[6] = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42
        te[10] = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43
        te[14] = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44

        te[3] = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41
        te[7] = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42
        te[11] = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43
        te[15] = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44

        return this
    }

    public func multiplyScalar(s: Float32): Matrix4F {
        let te = this.elements
        for (i in 0..16) {
            te[i] *= s
        }
        return this
    }

    // ===== Determinant & Inverse =====

    public func determinant(): Float32 {
        let te = this.elements
        let n11 = te[0]; let n12 = te[4]; let n13 = te[8]; let n14 = te[12]
        let n21 = te[1]; let n22 = te[5]; let n23 = te[9]; let n24 = te[13]
        let n31 = te[2]; let n32 = te[6]; let n33 = te[10]; let n34 = te[14]
        let n41 = te[3]; let n42 = te[7]; let n43 = te[11]; let n44 = te[15]

        let t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44
        let t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44
        let t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44
        let t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34

        n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14
    }

    public func invert(): Matrix4F {
        let te = this.elements
        let n11 = te[0]; let n12 = te[4]; let n13 = te[8]; let n14 = te[12]
        let n21 = te[1]; let n22 = te[5]; let n23 = te[9]; let n24 = te[13]
        let n31 = te[2]; let n32 = te[6]; let n33 = te[10]; let n34 = te[14]
        let n41 = te[3]; let n42 = te[7]; let n43 = te[11]; let n44 = te[15]

        let t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44
        let t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44
        let t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44
        let t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34

        let det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14
        if (det == 0.0f32) {
            return this.identity()
        }
        let invDet = 1.0f32/ det

        te[0] = t11 * invDet
        te[1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * invDet
        te[2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * invDet
        te[3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * invDet

        te[4] = t12 * invDet
        te[5] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * invDet
        te[6] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * invDet
        te[7] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * invDet

        te[8] = t13 * invDet
        te[9] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * invDet
        te[10] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * invDet
        te[11] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * invDet

        te[12] = t14 * invDet
        te[13] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * invDet
        te[14] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * invDet
        te[15] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * invDet

        return this
    }

    // ===== Transpose =====

    public func transpose(): Matrix4F {
        let te = this.elements
        var tmp: Float32
        tmp = te[1]; te[1] = te[4]; te[4] = tmp
        tmp = te[2]; te[2] = te[8]; te[8] = tmp
        tmp = te[3]; te[3] = te[12]; te[12] = tmp
        tmp = te[6]; te[6] = te[9]; te[9] = tmp
        tmp = te[7]; te[7] = te[13]; te[13] = tmp
        tmp = te[11]; te[11] = te[14]; te[14] = tmp
        return this
    }

    // ===== Build transforms =====

    public func makeTranslation(x: Float32, y: Float32, z: Float32): Matrix4F {
        this.identity()
        let te = this.elements
        te[12] = x; te[13] = y; te[14] = z
        return this
    }

    public func makeScale(x: Float32, y: Float32, z: Float32): Matrix4F {
        this.identity()
        let te = this.elements
        te[0] = x; te[5] = y; te[10] = z
        return this
    }

    public func makeRotationX(theta: Float32): Matrix4F {
        let c = cos(theta)
        let s = sin(theta)
        this.identity()
        let te = this.elements
        te[5] = c; te[6] = s; te[9] = -s; te[10] = c
        return this
    }

    public func makeRotationY(theta: Float32): Matrix4F {
        let c = cos(theta)
        let s = sin(theta)
        this.identity()
        let te = this.elements
        te[0] = c; te[2] = -s; te[8] = s; te[10] = c
        return this
    }

    public func makeRotationZ(theta: Float32): Matrix4F {
        let c = cos(theta)
        let s = sin(theta)
        this.identity()
        let te = this.elements
        te[0] = c; te[1] = s; te[4] = -s; te[5] = c
        return this
    }

    /**
     * @brief[zh-cn] 从四元数构建旋转矩阵
     * @param[zh-cn] x 四元数 x
     * @param[zh-cn] y 四元数 y
     * @param[zh-cn] z 四元数 z
     * @param[zh-cn] w 四元数 w
     *
     * @brief[en] Build a rotation matrix from a quaternion
     * @param[en] x Quaternion x
     * @param[en] y Quaternion y
     * @param[en] z Quaternion z
     * @param[en] w Quaternion w
     */
    public func makeRotationFromQuaternion(x: Float32, y: Float32, z: Float32, w: Float32): Matrix4F {
        let x2 = x + x
        let y2 = y + y
        let z2 = z + z
        let xx = x * x2
        let xy = x * y2
        let xz = x * z2
        let yy = y * y2
        let yz = y * z2
        let zz = z * z2
        let wx = w * x2
        let wy = w * y2
        let wz = w * z2

        this.identity()
        let te = this.elements
        te[0] = 1.0f32- (yy + zz)
        te[4] = xy - wz
        te[8] = xz + wy

        te[1] = xy + wz
        te[5] = 1.0f32- (xx + zz)
        te[9] = yz - wx

        te[2] = xz - wy
        te[6] = yz + wx
        te[10] = 1.0f32- (xx + yy)

        return this
    }

    /**
     * @brief[zh-cn] 从位置、四元数、缩放组合为矩阵
     * @param[zh-cn] px 位置 x
     * @param[zh-cn] py 位置 y
     * @param[zh-cn] pz 位置 z
     * @param[zh-cn] qx 旋转四元数 x
     * @param[zh-cn] qy 旋转四元数 y
     * @param[zh-cn] rz 旋转四元数 z
     * @param[zh-cn] qw 旋转四元数 w
     * @param[zh-cn] sx 缩放 x
     * @param[zh-cn] sy 缩放 y
     * @param[zh-cn] sz 缩放 z
     *
     * @brief[en] Compose a matrix from position, quaternion and scale
     * @param[en] px Position x
     * @param[en] py Position y
     * @param[en] pz Position z
     * @param[en] qx Rotation quaternion x
     * @param[en] qy Rotation quaternion y
     * @param[en] rz Rotation quaternion z
     * @param[en] qw Rotation quaternion w
     * @param[en] sx Scale x
     * @param[en] sy Scale y
     * @param[en] sz Scale z
     */
    public func compose(
        px: Float32, py: Float32, pz: Float32,
        qx: Float32, qy: Float32, qz: Float32, qw: Float32,
        sx: Float32, sy: Float32, sz: Float32
    ): Matrix4F {
        let x2 = qx + qx; let y2 = qy + qy; let z2 = qz + qz
        let xx = qx * x2; let xy = qx * y2; let xz = qx * z2
        let yy = qy * y2; let yz = qy * z2; let zz = qz * z2
        let wx = qw * x2; let wy = qw * y2; let wz = qw * z2

        let te = this.elements
        te[0] = sx * (1.0f32- (yy + zz)); te[4] = sx * (xy - wz); te[8] = sx * (xz + wy); te[12] = px
        te[1] = sy * (xy + wz); te[5] = sy * (1.0f32- (xx + zz)); te[9] = sy * (yz - wx); te[13] = py
        te[2] = sz * (xz - wy); te[6] = sz * (yz + wx); te[10] = sz * (1.0f32- (xx + yy)); te[14] = pz
        te[3] = 0.0f32; te[7] = 0.0f32; te[11] = 0.0f32; te[15] = 1.0f32

        return this
    }

    // ===== Conversion =====

    /**
     * @brief[zh-cn] 从 Matrix4 (Float64) 转换为 Matrix4F
     *
     * @brief[en] Convert from Matrix4 (Float64) to Matrix4F
     */
    public static func fromMatrix4(m: Matrix4): Matrix4F {
        Matrix4F(Array<Float32>(16, { i => Float32(m.elements[i]) }))
    }

    /**
     * @brief[zh-cn] 转换为 Array<Float32>（长度16）
     *
     * @brief[en] Convert to Array<Float32> (length 16)
     */
    public func toArray(): Array<Float32> {
        this.elements.clone()
    }
}
