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
 * @file[zh-cn] 绑定组
 * @brief[zh-cn] 管线绑定组，包含一组 Binding 及其关联的渲染管线
 * @explain[zh-cn] 
 * BindGroup 将一组 Binding 资源（uniform buffer、sampler 等）与一个 RenderPipeline 关联，
 * 对应 WebGPU 中的 BindGroup 概念。在渲染时，绑定组被一起绑定到管线。
 *
 * @file[en] BindGroup
 * @brief[en] Pipeline bind group, containing a set of Bindings and their associated render pipeline
 * @explain[en] 
 * BindGroup associates a set of Binding resources (uniform buffers, samplers, etc.) with a RenderPipeline,
 * corresponding to the BindGroup concept in WebGPU. During rendering, the bind group is bound to the pipeline as a whole.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.textures.*
import std.collection.*

/**
 * @brief[zh-cn] 管线绑定组，包含一组 Binding 及其关联的渲染管线
 * @explain[zh-cn] 
 * 将一组 Binding 资源与一个 RenderPipeline 关联，对应 WebGPU 的 BindGroup 概念。
 *
 * @brief[en] Pipeline bind group, containing a set of Bindings and their associated render pipeline
 * @explain[en] 
 * Associates a set of Binding resources with a RenderPipeline, corresponding to the BindGroup concept in WebGPU.
 */
public open class BindGroup {
    /**
     * @brief[zh-cn] 绑定组标识符
     *
     * @brief[en] Bind group identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 绑定列表
     *
     * @brief[en] List of bindings
     */
    public var bindings: ArrayList<Binding>

    /**
     * @brief[zh-cn] 关联的渲染管线
     *
     * @brief[en] Associated render pipeline
     */
    public var pipeline: RenderPipeline

    /**
     * @brief[zh-cn] 构造默认绑定组
     *
     * @brief[en] Constructs a default bind group
     */
    public init() { this.id = 0; this.bindings = ArrayList<Binding>(); this.pipeline = RenderPipeline() }

    /**
     * @brief[zh-cn] 添加绑定到绑定组
     * @param[zh-cn] binding 绑定对象
     *
     * @brief[en] Adds a binding to the bind group
     * @param[en] binding Binding object
     */
    public func addBinding(binding: Binding): Unit { this.bindings.add(binding) }

    /**
     * @brief[zh-cn] 按名称获取绑定
     * @param[zh-cn] name 绑定名称
     * @return[zh-cn] 匹配的绑定，未找到返回 None
     *
     * @brief[en] Gets a binding by name
     * @param[en] name Binding name
     * @return[en] Matched binding, or None if not found
     */
    public func getBinding(name: String): Option<Binding> {
        for (b in this.bindings) { if (b.name == name) { return Some(b) } }
        return None
    }
}
