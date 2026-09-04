/**
 * @file[zh-cn] 渲染对象管线
 * @brief[zh-cn] 渲染对象与管线的关联对
 * @explain[zh-cn] 
 * RenderObjectPipeline 将一个 RenderObject 与一个 RenderPipeline 关联，
 * 用于渲染调度时快速查找对象对应的管线。
 *
 * @file[en] RenderObjectPipeline
 * @brief[en] Association pair between a render object and a pipeline
 * @explain[en] 
 * RenderObjectPipeline associates a RenderObject with a RenderPipeline,
 * used for quickly looking up the pipeline corresponding to an object during render scheduling.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染对象与管线的关联对
 * @explain[zh-cn] 
 * 将 RenderObject 与 RenderPipeline 关联，用于渲染调度。
 *
 * @brief[en] Association pair between a render object and a pipeline
 * @explain[en] 
 * Associates a RenderObject with a RenderPipeline for render scheduling.
 */
public open class RenderObjectPipeline <: Pipeline {
    /**
     * @brief[zh-cn] 渲染对象
     *
     * @brief[en] Render object
     */
    public var renderObject: RenderObject

    /**
     * @brief[zh-cn] 渲染管线
     *
     * @brief[en] Render pipeline
     */
    public var pipeline: RenderPipeline

    /**
     * @brief[zh-cn] 构造渲染对象管线关联
     * @param[zh-cn] renderObject 渲染对象
     * pipeline 渲染管线
     *
     * @brief[en] Constructs a render object pipeline association
     * @param[en] renderObject Render object
     * pipeline Render pipeline
     */
    public init(renderObject: RenderObject, pipeline: RenderPipeline) {
        super()
        this.renderObject = renderObject; this.pipeline = pipeline
    }
}
