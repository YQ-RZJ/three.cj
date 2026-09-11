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
 * @file[zh-cn] SoaFloat4x4
 * @brief[zh-cn] SoA 格式的四元组 4x4 矩阵
 * @explain[zh-cn] 将 4 个 4x4 矩阵的 16 个浮点分量分别连续存储，用于将 SoaTransform 转换为模型空间矩阵。
 *
 * @file[en] SoaFloat4x4
 * @brief[en] Structure-of-Arrays layout for 4 4x4 matrices
 * @explain[en] Stores 4 4x4 matrices in SoA layout for converting SoaTransform to model-space matrices.
 */
package three.core.math.soa

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] SoA 4x4 矩阵结构体，存储 4 个矩阵
 * @explain[zh-cn] 每个矩阵为列主序（column-major），即 m[col*4 + row]。
 *                  SoA 布局：m0[0..15], m1[0..15], m2[0..15], m3[0..15]
 *
 * @brief[en] SoA 4x4 matrix struct storing 4 matrices in column-major order
 * @explain[en] Each matrix is column-major, i.e. m[col*4 + row].
 *              SoA layout: m0[0..15], m1[0..15], m2[0..15], m3[0..15]
 */
public class SoaFloat4x4 {
    /**
     * @brief[zh-cn] 4 个矩阵的分量，每个矩阵 16 个 Float32（列主序）
     * @explain[zh-cn] layout: [m0[0], m0[1], ..., m0[15], m1[0], ..., m3[15]]
     *
     * @brief[en] Components of 4 matrices, each 16 Float32 (column-major)
     * @explain[en] Layout: [m0[0], m0[1], ..., m0[15], m1[0], ..., m3[15]]
     */
    public var m: Array<Float32>

    /**
     * @brief[zh-cn] 默认构造函数，初始化为 4 个单位矩阵
     *
     * @brief[en] Default constructor, initializes to 4 identity matrices
     */
    public init() {
        this.m = Array<Float32>(64, { i =>
            let localIdx = i % 16
            // 单位矩阵：对角线为 1
            if (localIdx % 5 == 0) { 1.0f32} else { 0.0f32}
        })
    }

    /**
     * @brief[zh-cn] 从原始数组构造
     * @param[zh-cn] data 64 个元素的数组（4 个矩阵 × 16 分量）
     *
     * @brief[en] Construct from raw 64-element array
     * @param[en] data Array of 64 elements (4 matrices × 16 components)
     */
    public init(data: Array<Float32>) {
        this.m = data
    }

    // --- Matrix accessors (matrix = 0..3, element = 0..15) ---

    /**
     * @brief[zh-cn] 获取指定矩阵的指定元素
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @param[zh-cn] element 元素索引 (0-15, 列主序)
     *
     * @brief[en] Get element from a specific matrix
     * @param[en] matrix Matrix index (0-3)
     * @param[en] element Element index (0-15, column-major)
     */
    public func get(matrix: Int, element: Int): Float32 {
        this.m[matrix * 16 + element]
    }

    /**
     * @brief[zh-cn] 设置指定矩阵的指定元素
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @param[zh-cn] element 元素索引 (0-15)
     * @param[zh-cn] value 值
     *
     * @brief[en] Set element of a specific matrix
     * @param[en] matrix Matrix index (0-3)
     * @param[en] element Element index (0-15)
     * @param[en] value Value
     */
    public func set(matrix: Int, element: Int, value: Float32): Unit {
        this.m[matrix * 16 + element] = value
    }

    /**
     * @brief[zh-cn] 从 SoaTransform 构建 4 个模型空间 4x4 矩阵
     * @param[zh-cn] transform SoA 格式的变换
     * @return[zh-cn] 包含 4 个模型空间矩阵的 SoaFloat4x4
     * @explain[zh-cn] 对每个槽位计算 S * R * T（缩放 × 旋转 × 平移），结果为列主序矩阵。
     *
     * @brief[en] Build 4 model-space 4x4 matrices from a SoaTransform
     * @param[en] transform SoA-format transform
     * @return[en] SoaFloat4x4 containing the 4 model-space matrices
     * @explain[en] For each slot, computes S * R * T (scale × rotation × translation) as column-major matrix.
     */
    public static func fromTransform(transform: SoaTransform): SoaFloat4x4 {
        let result = SoaFloat4x4()

        for (i in 0..4) {
            let tx = transform.translations[i * 3]
            let ty = transform.translations[i * 3 + 1]
            let tz = transform.translations[i * 3 + 2]

            let rx = transform.rotations[i * 4]
            let ry = transform.rotations[i * 4 + 1]
            let rz = transform.rotations[i * 4 + 2]
            let rw = transform.rotations[i * 4 + 3]

            let sx = transform.scales[i * 3]
            let sy = transform.scales[i * 3 + 1]
            let sz = transform.scales[i * 3 + 2]

            // 旋转矩阵元素（四元数 → 旋转矩阵）
            let x2 = rx + rx
            let y2 = ry + ry
            let z2 = rz + rz
            let xx = rx * x2
            let xy = rx * y2
            let xz = rx * z2
            let yy = ry * y2
            let yz = ry * z2
            let zz = rz * z2
            let wx = rw * x2
            let wy = rw * y2
            let wz = rw * z2

            // S * R * T, 列主序
            let base = i * 16
            result.m[base + 0] = sx * (1.0f32- (yy + zz))
            result.m[base + 1] = sx * (xy + wz)
            result.m[base + 2] = sx * (xz - wy)
            result.m[base + 3] = 0.0f32

            result.m[base + 4] = sy * (xy - wz)
            result.m[base + 5] = sy * (1.0f32- (xx + zz))
            result.m[base + 6] = sy * (yz + wx)
            result.m[base + 7] = 0.0f32

            result.m[base + 8] = sz * (xz + wy)
            result.m[base + 9] = sz * (yz - wx)
            result.m[base + 10] = sz * (1.0f32- (xx + yy))
            result.m[base + 11] = 0.0f32

            result.m[base + 12] = tx
            result.m[base + 13] = ty
            result.m[base + 14] = tz
            result.m[base + 15] = 1.0f32
        }

        return result
    }

    /**
     * @brief[zh-cn] 获取指定矩阵的第0列（前3个分量）
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @return[zh-cn] (m[0], m[1], m[2])
     *
     * @brief[en] Get column 0 (first 3 elements) of a specific matrix
     * @param[en] matrix Matrix index (0-3)
     * @return[en] (m[0], m[1], m[2])
     */
    public func getColumn0(matrix: Int): Vector3F {
        let base = matrix * 16
        Vector3F(this.m[base], this.m[base + 1], this.m[base + 2])
    }

    /**
     * @brief[zh-cn] 获取指定矩阵的第1列（第4-6个分量）
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @return[zh-cn] Vector3F
     *
     * @brief[en] Get column 1 of a specific matrix
     * @param[en] matrix Matrix index (0-3)
     * @return[en] Vector3F
     */
    public func getColumn1(matrix: Int): Vector3F {
        let base = matrix * 16 + 4
        Vector3F(this.m[base], this.m[base + 1], this.m[base + 2])
    }

    /**
     * @brief[zh-cn] 获取指定矩阵的第2列（第8-10个分量）
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @return[zh-cn] Vector3F
     *
     * @brief[en] Get column 2 of a specific matrix
     * @param[en] matrix Matrix index (0-3)
     * @return[en] Vector3F
     */
    public func getColumn2(matrix: Int): Vector3F {
        let base = matrix * 16 + 8
        Vector3F(this.m[base], this.m[base + 1], this.m[base + 2])
    }

    /**
     * @brief[zh-cn] 获取指定矩阵的平移分量（第3列前3个元素）
     * @param[zh-cn] matrix 矩阵索引 (0-3)
     * @return[zh-cn] Vector3F
     *
     * @brief[en] Get translation from a specific matrix (column 3, first 3 elements)
     * @param[en] matrix Matrix index (0-3)
     * @return[en] Vector3F
     */
    public func getTranslation(matrix: Int): Vector3F {
        let base = matrix * 16 + 12
        Vector3F(this.m[base], this.m[base + 1], this.m[base + 2])
    }
}
