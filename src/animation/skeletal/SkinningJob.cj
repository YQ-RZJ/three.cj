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
 * @file[zh-cn] SkinningJob
 * @brief[zh-cn] CPU 端顶点蒙皮 Job
 * @explain[zh-cn] 使用关节矩阵和逐顶点权重/影响索引变换顶点位置、法线和切线。
 *                  支持 stride 灵活顶点布局和 1-4 影响数。
 *
 * @file[en] SkinningJob
 * @brief[en] CPU vertex skinning job
 * @explain[en] Transforms vertex positions, normals, and tangents using joint matrices
 *              and per-vertex weights/influence indices. Supports flexible stride and 1-4 influences.
 */
package three.animation.skeletal

import std.math.*
import three.core.math.*

/**
 * @brief[zh-cn] 蒙皮权重输入
 * @explain[zh-cn] 每个顶点的关节影响索引和权重
 *
 * @brief[en] Skinning weights input
 * @explain[en] Per-vertex joint influence indices and weights
 */
public class SkinWeights {
    /**
     * @brief[zh-cn] 影响数（1-4）
     *
     * @brief[en] Number of influences (1-4)
     */
    public let numInfluences: Int

    /**
     * @brief[zh-cn] 关节索引数组
     * @explain[zh-cn] 长度 = numVertices * numInfluences
     *
     * @brief[en] Joint index array
     * @explain[en] Length = numVertices * numInfluences
     */
    public let jointIndices: Array<Int16>

    /**
     * @brief[zh-cn] 权重数组
     * @explain[zh-cn] 长度 = numVertices * numInfluences
     *
     * @brief[en] Weight array
     * @explain[en] Length = numVertices * numInfluences
     */
    public let jointWeights: Array<Float32>

    public init(numInfluences: Int, jointIndices: Array<Int16>, jointWeights: Array<Float32>) {
        this.numInfluences = numInfluences
        this.jointIndices = jointIndices
        this.jointWeights = jointWeights
    }
}

/**
 * @brief[zh-cn] 蒙皮输入数据
 *
 * @brief[en] Skinning input data
 */
public class SkinInput {
    /**
     * @brief[zh-cn] 顶点数量
     *
     * @brief[en] Number of vertices
     */
    public let numVertices: Int

    /**
     * @brief[zh-cn] 位置输入缓冲区
     * @explain[zh-cn] 每个顶点 3 个 Float32，stride 字节指定间隔
     *
     * @brief[en] Position input buffer
     * @explain[en] 3 Float32 per vertex; the stride in bytes specifies the spacing
     */
    public let positions: Array<Float32>

    /**
     * @brief[zh-cn] 位置 stride（字节）
     * @explain[zh-cn] 0 表示紧凑（12 字节/顶点）
     *
     * @brief[en] Position stride in bytes
     * @explain[en] 0 means tightly packed (12 bytes per vertex)
     */
    public let positionStride: Int

    /**
     * @brief[zh-cn] 法线输入缓冲区（可选）
     *
     * @brief[en] Normal input buffer (optional)
     */
    public let normals: ?Array<Float32>

    /**
     * @brief[zh-cn] 法线 stride（字节）
     *
     * @brief[en] Normal stride in bytes
     */
    public let normalStride: Int

    /**
     * @brief[zh-cn] 切线输入缓冲区（可选）
     *
     * @brief[en] Tangent input buffer (optional)
     */
    public let tangents: ?Array<Float32>

    /**
     * @brief[zh-cn] 切线 stride（字节）
     *
     * @brief[en] Tangent stride in bytes
     */
    public let tangentStride: Int

    public init(
        numVertices: Int,
        positions: Array<Float32>,
        positionStride!: Int = 0,
        normals!: ?Array<Float32> = None,
        normalStride!: Int = 0,
        tangents!: ?Array<Float32> = None,
        tangentStride!: Int = 0
    ) {
        this.numVertices = numVertices
        this.positions = positions
        this.positionStride = positionStride
        this.normals = normals
        this.normalStride = normalStride
        this.tangents = tangents
        this.tangentStride = tangentStride
    }
}

/**
 * @brief[zh-cn] 蒙皮输出数据
 *
 * @brief[en] Skinning output data
 */
public class SkinOutput {
    /**
     * @brief[zh-cn] 位置输出缓冲区
     *
     * @brief[en] Position output buffer
     */
    public var positions: Array<Float32>

    /**
     * @brief[zh-cn] 法线输出缓冲区（可选）
     *
     * @brief[en] Normal output buffer (optional)
     */
    public var normals: ?Array<Float32>

    /**
     * @brief[zh-cn] 切线输出缓冲区（可选）
     *
     * @brief[en] Tangent output buffer (optional)
     */
    public var tangents: ?Array<Float32>

    public init() {
        this.positions = Array<Float32>(0, { _ => 0.0f32 })
        this.normals = None
        this.tangents = None
    }
}

/**
 * @brief[zh-cn] CPU 端顶点蒙皮 Job
 *
 * @brief[en] CPU vertex skinning job
 */
public class SkinningJob {
    /**
     * @brief[zh-cn] 关节模型空间矩阵数组
     * @explain[zh-cn] 长度 = numJoints，每个为 16 个 Float32（列主序 4x4 矩阵）
     *
     * @brief[en] Joint model-space matrix array
     * @explain[en] Length = numJoints, each is 16 Float32 (column-major 4x4 matrix)
     */
    public var jointMatrices: Array<Float32>

    /**
     * @brief[zh-cn] 蒙皮权重
     *
     * @brief[en] Skinning weights
     */
    public var weights: ?SkinWeights

    /**
     * @brief[zh-cn] 蒙皮输入
     *
     * @brief[en] Skinning input
     */
    public var input: ?SkinInput

    /**
     * @brief[zh-cn] 蒙皮输出
     *
     * @brief[en] Skinning output
     */
    public var output: SkinOutput

    public init() {
        this.jointMatrices = Array<Float32>(0, { _ => 0.0f32 })
        this.weights = None
        this.input = None
        this.output = SkinOutput()
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        let w = match (this.weights) {
            case Some(w) => w
            case None => return false
        }
        let inp = match (this.input) {
            case Some(i) => i
            case None => return false
        }

        let numVerts = inp.numVertices
        let numInfl = w.numInfluences
        if (numInfl < 1 || numInfl > 4) { return false }
        if (w.jointIndices.size != numVerts * numInfl) { return false }
        if (w.jointWeights.size != numVerts * numInfl) { return false }

        true
    }

    /**
     * @brief[zh-cn] 执行蒙皮
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 对每个顶点：
     *                  1. 读取关节索引和权重（1-4 个影响）
     *                  2. 累加加权的关节矩阵 * 原始位置/法线/切线
     *                  3. 写入输出缓冲区
     *
     * @brief[en] Runs the skinning
     * @return[en] true on success
     * @explain[en] For each vertex:
     *                  1. Reads the joint indices and weights (1-4 influences)
     *                  2. Accumulates the weighted joint matrix * original position/normal/tangent
     *                  3. Writes to the output buffers
     */
    public func run(): Bool {
        if (!this.validate()) { return false }

        let inp = match (this.input) {
            case Some(i) => i
            case None => return false
        }
        let w = match (this.weights) {
            case Some(ww) => ww
            case None => return false
        }
        let numVerts = inp.numVertices
        let numInfl = w.numInfluences

        let posStride = if (inp.positionStride > 0) { inp.positionStride / 4 } else { 3 }
        let normStride = if (inp.normalStride > 0) { inp.normalStride / 4 } else { 3 }
        let tanStride = if (inp.tangentStride > 0) { inp.tangentStride / 4 } else { 4 }

        // 可选输入缓冲区提前解包
        let inNormals = inp.normals
        let inTangents = inp.tangents

        // 准备输出
        this.output.positions = Array<Float32>(numVerts * 3, { _ => 0.0f32 })
        let outNormals: ?Array<Float32> = match (inNormals) {
            case Some(_) =>
                let arr = Array<Float32>(numVerts * 3, { _ => 0.0f32 })
                this.output.normals = Some(arr)
                Some(arr)
            case None => None
        }
        let outTangents: ?Array<Float32> = match (inTangents) {
            case Some(_) =>
                let arr = Array<Float32>(numVerts * 4, { _ => 0.0f32 })
                this.output.tangents = Some(arr)
                Some(arr)
            case None => None
        }

        for (v in 0..numVerts) {
            var ox: Float32 = 0.0f32
            var oy: Float32 = 0.0f32
            var oz: Float32 = 0.0f32

            var onx: Float32 = 0.0f32
            var ony: Float32 = 0.0f32
            var onz: Float32 = 0.0f32

            var otx: Float32 = 0.0f32
            var oty: Float32 = 0.0f32
            var otz: Float32 = 0.0f32
            var otw: Float32 = 0.0f32

            for (inf in 0..numInfl) {
                let idx = v * numInfl + inf
                let jointIdx = Int64(w.jointIndices[idx])
                let jointWeight = w.jointWeights[idx]

                if (jointWeight <= 0.0f32) { continue }

                let mBase = jointIdx * 16

                // 位置变换
                let px = inp.positions[v * posStride]
                let py = inp.positions[v * posStride + 1]
                let pz = inp.positions[v * posStride + 2]

                ox += (this.jointMatrices[mBase + 0] * px + this.jointMatrices[mBase + 4] * py + this.jointMatrices[mBase + 8] * pz + this.jointMatrices[mBase + 12]) * jointWeight
                oy += (this.jointMatrices[mBase + 1] * px + this.jointMatrices[mBase + 5] * py + this.jointMatrices[mBase + 9] * pz + this.jointMatrices[mBase + 13]) * jointWeight
                oz += (this.jointMatrices[mBase + 2] * px + this.jointMatrices[mBase + 6] * py + this.jointMatrices[mBase + 10] * pz + this.jointMatrices[mBase + 14]) * jointWeight

                // 法线变换（仅旋转部分，不包含平移）
                match (inNormals) {
                    case Some(n) =>
                        let nx = n[v * normStride]
                        let ny = n[v * normStride + 1]
                        let nz = n[v * normStride + 2]

                        onx += (this.jointMatrices[mBase + 0] * nx + this.jointMatrices[mBase + 4] * ny + this.jointMatrices[mBase + 8] * nz) * jointWeight
                        ony += (this.jointMatrices[mBase + 1] * nx + this.jointMatrices[mBase + 5] * ny + this.jointMatrices[mBase + 9] * nz) * jointWeight
                        onz += (this.jointMatrices[mBase + 2] * nx + this.jointMatrices[mBase + 6] * ny + this.jointMatrices[mBase + 10] * nz) * jointWeight
                    case None => ()
                }

                // 切线变换
                match (inTangents) {
                    case Some(t) =>
                        let tx = t[v * tanStride]
                        let ty = t[v * tanStride + 1]
                        let tz = t[v * tanStride + 2]
                        let tw = t[v * tanStride + 3]

                        otx += (this.jointMatrices[mBase + 0] * tx + this.jointMatrices[mBase + 4] * ty + this.jointMatrices[mBase + 8] * tz) * jointWeight
                        oty += (this.jointMatrices[mBase + 1] * tx + this.jointMatrices[mBase + 5] * ty + this.jointMatrices[mBase + 9] * tz) * jointWeight
                        otz += (this.jointMatrices[mBase + 2] * tx + this.jointMatrices[mBase + 6] * ty + this.jointMatrices[mBase + 10] * tz) * jointWeight
                        otw += tw * jointWeight
                    case None => ()
                }
            }

            this.output.positions[v * 3] = ox
            this.output.positions[v * 3 + 1] = oy
            this.output.positions[v * 3 + 2] = oz

            // 归一化法线
            match (outNormals) {
                case Some(norms) =>
                    let len = sqrt(onx * onx + ony * ony + onz * onz)
                    if (len > 1e-12f32) {
                        let inv = 1.0f32 / len
                        norms[v * 3] = onx * inv
                        norms[v * 3 + 1] = ony * inv
                        norms[v * 3 + 2] = onz * inv
                    } else {
                        norms[v * 3] = 0.0f32
                        norms[v * 3 + 1] = 1.0f32
                        norms[v * 3 + 2] = 0.0f32
                    }
                case None => ()
            }

            // 归一化切线
            match (outTangents) {
                case Some(tans) =>
                    let len = sqrt(otx * otx + oty * oty + otz * otz)
                    if (len > 1e-12f32) {
                        let inv = 1.0f32 / len
                        tans[v * 4] = otx * inv
                        tans[v * 4 + 1] = oty * inv
                        tans[v * 4 + 2] = otz * inv
                        tans[v * 4 + 3] = otw
                    } else {
                        tans[v * 4] = 1.0f32
                        tans[v * 4 + 1] = 0.0f32
                        tans[v * 4 + 2] = 0.0f32
                        tans[v * 4 + 3] = 1.0f32
                    }
                case None => ()
            }
        }

        true
    }
}
