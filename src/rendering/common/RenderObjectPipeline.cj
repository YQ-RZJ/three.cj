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
