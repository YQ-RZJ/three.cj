/**
 * @file[zh-cn] 管线基类
 * @brief[zh-cn] 渲染管线基类，管理管线 ID 和绑定组
 * @explain[zh-cn] 
 * Pipeline 是渲染管线和计算管线的公共基类，包含管线标识符和关联的 BindGroup。
 * 子类包括 RenderPipeline 和 ComputePipeline。
 *
 * @file[en] Pipeline
 * @brief[en] Render pipeline base class, managing pipeline ID and bind group
 * @explain[en] 
 * Pipeline is the common base class for render and compute pipelines, containing a pipeline identifier and an associated BindGroup.
 * Subclasses include RenderPipeline and ComputePipeline.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染管线基类
 * @explain[zh-cn] 
 * 包含管线标识符和关联的 BindGroup，是 RenderPipeline 和 ComputePipeline 的公共基类。
 *
 * @brief[en] Render pipeline base class
 * @explain[en] 
 * Contains a pipeline identifier and an associated BindGroup, serving as the common base for RenderPipeline and ComputePipeline.
 */
public open class Pipeline {
    /**
     * @brief[zh-cn] 管线标识符
     *
     * @brief[en] Pipeline identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 关联的绑定组
     *
     * @brief[en] Associated bind group
     */
    public var bindGroup: BindGroup

    /**
     * @brief[zh-cn] 构造默认管线
     *
     * @brief[en] Constructs a default pipeline
     */
    public init() { this.id = 0; this.bindGroup = BindGroup() }

    /**
     * @brief[zh-cn] 获取关联的绑定组
     * @return[zh-cn] 绑定组
     *
     * @brief[en] Gets the associated bind group
     * @return[en] Bind group
     */
    public func getBindGroup(): BindGroup { return this.bindGroup }
}
