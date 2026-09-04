/**
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
