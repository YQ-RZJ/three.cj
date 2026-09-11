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
 * @file[zh-cn] GpuSkinningJob
 * @brief[zh-cn] GPU 蒙皮 Job（compute shader 加速）
 * @explain[zh-cn] 定义 GPU 蒙皮的数据结构和接口。当 bgfx compute shader 可用时，
 *                  使用 GPU 并行计算顶点蒙皮；否则回退到 CPU SkinningJob。
 *                  蒙皮计算（顶点 × 加权关节矩阵）是高度并行的，天然适合 GPU compute。
 *
 * @file[en] GpuSkinningJob
 * @brief[en] GPU skinning job (compute shader acceleration)
 * @explain[en] Defines GPU skinning data structures and interfaces.
 *              When bgfx compute shaders are available, uses GPU parallel computation;
 *              otherwise falls back to CPU SkinningJob.
 * @explain[en] Skinning computation (vertex × weighted joint matrices) is highly parallel
 *              and naturally suited to GPU compute.
 */
package three.animation.skeletal

import three.core.math.*

/**
 * @brief[zh-cn] 蒙皮计算模式
 *
 * @brief[en] Skinning compute mode
 */
public enum SkinningMode {
    | CPU       // 纯 CPU SkinningJob
    | GPU       // GPU compute shader（需要 bgfx compute 支持）
    | Auto      // 自动选择（优先 GPU，不可用时回退 CPU）
}

/**
 * @brief[zh-cn] GPU 蒙皮输入数据
 * @explain[zh-cn] 封装上传到 GPU 缓冲区所需的全部数据
 *
 * @brief[en] GPU skinning input data
 * @explain[en] Encapsulates all data required for uploading to GPU buffers
 */
public class GpuSkinningInput {
    /**
     * @brief[zh-cn] 顶点数量
     *
     * @brief[en] Number of vertices
     */
    public let numVertices: Int

    /**
     * @brief[zh-cn] 关节数量
     *
     * @brief[en] Number of joints
     */
    public let numJoints: Int

    /**
     * @brief[zh-cn] 每顶点影响数（1-4）
     *
     * @brief[en] Number of influences per vertex (1-4)
     */
    public let numInfluences: Int

    /**
     * @brief[zh-cn] 绑定姿势顶点位置（Float32 × 3 × numVertices）
     *
     * @brief[en] Bind-pose vertex positions (Float32 × 3 × numVertices)
     */
    public let bindPositions: Array<Float32>

    /**
     * @brief[zh-cn] 绑定姿势顶点法线（Float32 × 3 × numVertices，可选）
     *
     * @brief[en] Bind-pose vertex normals (Float32 × 3 × numVertices, optional)
     */
    public let bindNormals: ?Array<Float32>

    /**
     * @brief[zh-cn] 关节索引（Int16 × numInfluences × numVertices，转为 Float32 上传）
     *
     * @brief[en] Joint indices (Int16 × numInfluences × numVertices, uploaded as Float32)
     */
    public let jointIndices: Array<Float32>

    /**
     * @brief[zh-cn] 关节权重（Float32 × numInfluences × numVertices）
     *
     * @brief[en] Joint weights (Float32 × numInfluences × numVertices)
     */
    public let jointWeights: Array<Float32>

    /**
     * @brief[zh-cn] 关节矩阵（Float32 × 16 × numJoints，列主序 4x4）
     *
     * @brief[en] Joint matrices (Float32 × 16 × numJoints, column-major 4x4)
     */
    public var jointMatrices: Array<Float32>

    public init(
        numVertices: Int,
        numJoints: Int,
        numInfluences: Int,
        bindPositions: Array<Float32>,
        bindNormals: ?Array<Float32>,
        jointIndices: Array<Float32>,
        jointWeights: Array<Float32>,
        jointMatrices: Array<Float32>
    ) {
        this.numVertices = numVertices
        this.numJoints = numJoints
        this.numInfluences = numInfluences
        this.bindPositions = bindPositions
        this.bindNormals = bindNormals
        this.jointIndices = jointIndices
        this.jointWeights = jointWeights
        this.jointMatrices = jointMatrices
    }
}

/**
 * @brief[zh-cn] GPU 蒙皮输出数据
 *
 * @brief[en] GPU skinning output data
 */
public class GpuSkinningOutput {
    /**
     * @brief[zh-cn] 蒙皮后顶点位置（Float32 × 3 × numVertices）
     *
     * @brief[en] Skinned vertex positions (Float32 × 3 × numVertices)
     */
    public var skinnedPositions: Array<Float32>

    /**
     * @brief[zh-cn] 蒙皮后顶点法线（Float32 × 3 × numVertices，可选）
     *
     * @brief[en] Skinned vertex normals (Float32 × 3 × numVertices, optional)
     */
    public var skinnedNormals: ?Array<Float32>

    public init(numVertices: Int) {
        this.skinnedPositions = Array<Float32>(numVertices * 3, { _ => 0.0f32 })
        this.skinnedNormals = None
    }
}

/**
 * @brief[zh-cn] GPU 蒙皮 Job
 * @explain[zh-cn] 蒙皮计算管线：
 *                  1. 准备 GpuSkinningInput（绑定姿势 + 权重 + 关节矩阵）
 *                  2. 调用 run() 执行蒙皮
 *                  3. 从 GpuSkinningOutput 读取结果
 *
 *                  GPU 模式下，compute shader 的工作项为每个顶点：
 *                  ```
 *                  // GLSL/HLSL compute shader 伪代码
 *                  for each vertex i:
 *                      pos = vec3(0)
 *                      for j in 0..numInfluences:
 *                          bone_idx = jointIndices[i * numInfluences + j]
 *                          weight = jointWeights[i * numInfluences + j]
 *                          pos += weight * (jointMatrices[bone_idx] * vec4(bindPositions[i], 1)).xyz
 *                      skinnedPositions[i] = pos
 *                  ```
 *
 * @brief[en] GPU skinning job
 * @explain[en] Skinning pipeline:
 *                  1. Prepare GpuSkinningInput (bind pose + weights + joint matrices)
 *                  2. Call run() to perform skinning
 *                  3. Read the results from GpuSkinningOutput
 *
 *                  In GPU mode, the compute shader work item for each vertex:
 *                  ```
 *                  // GLSL/HLSL compute shader pseudocode
 *                  for each vertex i:
 *                      pos = vec3(0)
 *                      for j in 0..numInfluences:
 *                          bone_idx = jointIndices[i * numInfluences + j]
 *                          weight = jointWeights[i * numInfluences + j]
 *                          pos += weight * (jointMatrices[bone_idx] * vec4(bindPositions[i], 1)).xyz
 *                      skinnedPositions[i] = pos
 *                  ```
 */
public class GpuSkinningJob {
    /**
     * @brief[zh-cn] 蒙皮模式
     *
     * @brief[en] Skinning mode
     */
    public var mode: SkinningMode

    /**
     * @brief[zh-cn] 蒙皮输入
     *
     * @brief[en] Skinning input
     */
    public var input: ?GpuSkinningInput

    /**
     * @brief[zh-cn] 蒙皮输出
     *
     * @brief[en] Skinning output
     */
    public var output: ?GpuSkinningOutput

    /**
     * @brief[zh-cn] CPU fallback：内部使用的 SkinningJob
     *
     * @brief[en] CPU fallback: internally used SkinningJob
     */
    private var _cpuJob: SkinningJob

    public init() {
        this.mode = SkinningMode.Auto
        this.input = None
        this.output = None
        this._cpuJob = SkinningJob()
    }

    /**
     * @brief[zh-cn] 验证输入合法性
     *
     * @brief[en] Validates the inputs
     */
    public func validate(): Bool {
        match (this.input) {
            case Some(inp) =>
                if (inp.numVertices <= 0 || inp.numJoints <= 0) { return false }
                if (inp.numInfluences < 1 || inp.numInfluences > 4) { return false }
                if (inp.bindPositions.size != inp.numVertices * 3) { return false }
                if (inp.jointIndices.size != inp.numVertices * inp.numInfluences) { return false }
                if (inp.jointWeights.size != inp.numVertices * inp.numInfluences) { return false }
                if (inp.jointMatrices.size != inp.numJoints * 16) { return false }
                true
            case None => false
        }
    }

    /**
     * @brief[zh-cn] 执行蒙皮
     * @return[zh-cn] true 表示成功
     * @explain[zh-cn] 根据 mode 选择执行路径：
     *                  - CPU：使用 SkinningJob 在 CPU 上执行
     *                  - GPU：需要 bgfx compute shader 支持（当前回退到 CPU）
     *                  - Auto：优先 GPU，不可用时回退 CPU
     *
     * @brief[en] Runs the skinning
     * @return[en] true on success
     * @explain[en] Selects the execution path according to mode:
     *                  - CPU: executes on the CPU using SkinningJob
     *                  - GPU: requires bgfx compute shader support (currently falls back to CPU)
     *                  - Auto: prefers GPU, falls back to CPU when unavailable
     */
    public func run(): Bool {
        if (!this.validate()) { return false }

        match (this.input) {
            case Some(inp) =>
                let effectiveMode = this.mode

                // 当前实现：GPU compute 尚未集成，统一走 CPU fallback
                // TODO: 当 bgfx compute shader 支持可用时，在此添加 GPU 路径
                let isGpuPath = match (effectiveMode) {
                    case SkinningMode.GPU => true
                    case SkinningMode.Auto => true
                    case _ => false
                }
                if (isGpuPath) {
                    // 回退到 CPU
                    return this._runCpu(inp)
                }

                this._runCpu(inp)
            case None => false
        }
    }

    /**
     * @brief[zh-cn] CPU fallback 执行路径
     *
     * @brief[en] CPU fallback execution path
     */
    private func _runCpu(inp: GpuSkinningInput): Bool {
        // 将 GpuSkinningInput 转换为 SkinningJob 的输入格式
        let posArr = inp.bindPositions

        // 构建关节索引（Int16 数组）
        let jointIndices = Array<Int16>(inp.numVertices * inp.numInfluences, { i =>
            Int16(inp.jointIndices[i])
        })

        let weights = SkinWeights(inp.numInfluences, jointIndices, inp.jointWeights)
        let skinInput = SkinInput(inp.numVertices, posArr)

        this._cpuJob.jointMatrices = inp.jointMatrices
        this._cpuJob.weights = weights
        this._cpuJob.input = skinInput

        if (this._cpuJob.validate() && this._cpuJob.run()) {
            // 准备输出
            let out = GpuSkinningOutput(inp.numVertices)
            out.skinnedPositions = this._cpuJob.output.positions

            match (this._cpuJob.output.normals) {
                case Some(normals) => out.skinnedNormals = Some(normals)
                case None => ()
            }

            this.output = Some(out)
            return true
        }

        false
    }
}
