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
