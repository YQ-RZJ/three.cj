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
 * @file[zh-cn] 计算管线
 * @brief[zh-cn] 计算着色器管线，继承 Pipeline 用于 GPU 计算任务
 * @explain[zh-cn] 
 * ComputePipeline 继承自 Pipeline，用于管理 GPU 计算着色器管线。
 * 包含计算着色器代码，由后端（如 WebGPU/bgfx）执行 compute dispatch。
 *
 * @file[en] ComputePipeline
 * @brief[en] Compute shader pipeline, extending Pipeline for GPU compute tasks
 * @explain[en] 
 * ComputePipeline extends Pipeline and is used to manage GPU compute shader pipelines.
 * Contains compute shader code, executed by the backend (e.g., WebGPU/bgfx) via compute dispatch.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 计算着色器管线
 * @explain[zh-cn] 
 * 继承 Pipeline，包含计算着色器代码，用于 GPU 计算任务。
 *
 * @brief[en] Compute shader pipeline
 * @explain[en] 
 * Extends Pipeline, containing compute shader code for GPU compute tasks.
 */
public open class ComputePipeline <: Pipeline {
    /**
     * @brief[zh-cn] 计算着色器代码
     *
     * @brief[en] Compute shader code
     */
    public var computeShader: String

    /**
     * @brief[zh-cn] 构造默认计算管线
     *
     * @brief[en] Constructs a default compute pipeline
     */
    public init() {
        super()
        this.computeShader = ""
    }
}
