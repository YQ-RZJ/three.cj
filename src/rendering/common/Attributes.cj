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
 * @file[zh-cn] 属性管理
 * @brief[zh-cn] 管理顶点属性与后端缓冲区的映射
 * @explain[zh-cn] 
 * Attributes 继承自 DataMap，负责将 BufferAttribute 与后端 GPU 缓冲区关联，
 * 提供 get/update/destroy 生命周期方法。子类（如 BgfxAttributes）实现具体 GPU 端操作。
 *
 * @file[en] Attributes
 * @brief[en] Manages the mapping between vertex attributes and backend buffers
 * @explain[en] 
 * Attributes extends DataMap and is responsible for associating BufferAttribute with backend GPU buffers,
 * providing get/update/destroy lifecycle methods. Subclasses (e.g., BgfxAttributes) implement specific GPU-side operations.
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
 * @brief[zh-cn] 管理顶点属性与后端缓冲区的映射
 * @explain[zh-cn] 
 * 继承 DataMap，将 BufferAttribute 与后端 GPU 缓冲区关联。
 * 提供 get/update/destroy 生命周期方法，子类实现具体 GPU 端操作。
 *
 * @brief[en] Manages the mapping between vertex attributes and backend buffers
 * @explain[en] 
 * Extends DataMap, associating BufferAttribute with backend GPU buffers.
 * Provides get/update/destroy lifecycle methods; subclasses implement specific GPU-side operations.
 */
public open class Attributes <: DataMap {
    /**
     * @brief[zh-cn] 后端引用
     *
     * @brief[en] Reference to the backend
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 构造属性管理器
     * @param[zh-cn] backend 渲染后端实例
     *
     * @brief[en] Constructs an attributes manager
     * @param[en] backend Rendering backend instance
     */
    public init(backend: Backend) {
        super()
        this.backend = backend
    }

    /**
     * @brief[zh-cn] 获取属性对应的后端缓冲区句柄
     * @param[zh-cn] attribute 顶点属性
     * @return[zh-cn] 缓冲区句柄
     *
     * @brief[en] Gets the backend buffer handle for the given attribute
     * @param[en] attribute Vertex attribute
     * @return[en] Buffer handle
     */
    public func get(attribute: BufferAttribute): Int64 { return 0 }

    /**
     * @brief[zh-cn] 更新属性对应的缓冲区数据
     * @param[zh-cn] attribute 顶点属性
     *
     * @brief[en] Updates the buffer data for the given attribute
     * @param[en] attribute Vertex attribute
     */
    public func update(attribute: BufferAttribute): Unit { }

    /**
     * @brief[zh-cn] 更新实例化属性对应的缓冲区数据
     * @param[zh-cn] attribute 实例化顶点属性
     *
     * @brief[en] Updates the buffer data for the given instanced attribute
     * @param[en] attribute Instanced vertex attribute
     */
    public func updateInstanced(attribute: InstancedBufferAttribute): Unit { }

    /**
     * @brief[zh-cn] 销毁属性对应的缓冲区
     * @param[zh-cn] attribute 顶点属性
     *
     * @brief[en] Destroys the buffer for the given attribute
     * @param[en] attribute Vertex attribute
     */
    public func destroy(attribute: BufferAttribute): Unit { }
}
