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
 * @file[zh-cn] 绑定集合
 * @brief[zh-cn] 管线绑定集合管理器，管理多个 BindGroup 的创建与更新
 * @explain[zh-cn] 
 * Bindings 继承自 DataMap，负责管理管线绑定组（BindGroup）的创建、更新、设置和销毁。
 * 子类（如 BgfxBindingStates）实现具体的后端绑定操作。
 *
 * @file[en] Bindings
 * @brief[en] Pipeline bindings collection manager, managing the creation and update of multiple BindGroups
 * @explain[en] 
 * Bindings extends DataMap and is responsible for managing the creation, update, setup, and destruction of pipeline bind groups (BindGroup).
 * Subclasses (e.g., BgfxBindingStates) implement specific backend binding operations.
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
 * @brief[zh-cn] 管线绑定集合管理器
 * @explain[zh-cn] 
 * 管理 BindGroup 的创建、更新、设置和销毁。子类实现具体的后端绑定操作。
 *
 * @brief[en] Pipeline bindings collection manager
 * @explain[en] 
 * Manages the creation, update, setup, and destruction of BindGroups. Subclasses implement specific backend binding operations.
 */
public open class Bindings <: DataMap {
    /**
     * @brief[zh-cn] 后端引用
     *
     * @brief[en] Reference to the backend
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 构造绑定集合管理器
     * @param[zh-cn] backend 渲染后端实例
     *
     * @brief[en] Constructs a bindings collection manager
     * @param[en] backend Rendering backend instance
     */
    public init(backend: Backend) {
        super()
        this.backend = backend
    }

    /**
     * @brief[zh-cn] 创建绑定组
     * @return[zh-cn] 新创建的绑定组
     *
     * @brief[en] Creates a bind group
     * @return[en] Newly created bind group
     */
    public func createBindGroup(): BindGroup { return BindGroup() }

    /**
     * @brief[zh-cn] 更新绑定组
     * @param[zh-cn] group 绑定组
     *
     * @brief[en] Updates a bind group
     * @param[en] group Bind group
     */
    public func updateBindGroup(group: BindGroup): Unit { }

    /**
     * @brief[zh-cn] 设置绑定组与管线的关联
     * @param[zh-cn] group 绑定组
     * pipeline 渲染管线
     *
     * @brief[en] Sets up the association between a bind group and a pipeline
     * @param[en] group Bind group
     * pipeline Render pipeline
     */
    public func setupBindGroup(group: BindGroup, pipeline: RenderPipeline): Unit { }

    /**
     * @brief[zh-cn] 销毁绑定组
     * @param[zh-cn] group 绑定组
     *
     * @brief[en] Destroys a bind group
     * @param[en] group Bind group
     */
    public func destroyBindGroup(group: BindGroup): Unit { }
}
