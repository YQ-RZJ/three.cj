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
 * @file[zh-cn] 纹理管理
 * @brief[zh-cn] 纹理管理类，负责纹理和采样器的创建、更新与销毁
 * @explain[zh-cn] Textures 继承自 DataMap，持有后端引用和渲染统计信息，提供纹理/采样器的生命周期管理方法，并在创建和销毁时更新内存计数。
 *
 * @file[en] Textures
 * @brief[en] Textures management class, responsible for creating, updating, and destroying textures and samplers
 * @explain[en] Textures extends DataMap, holding a backend reference and rendering statistics, providing lifecycle management methods for textures/samplers, and updating memory counts on creation and destruction.
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
 * @brief[zh-cn] 纹理管理类
 * @explain[zh-cn] 继承 DataMap，管理纹理和采样器的创建、更新、销毁操作，并在操作时维护渲染内存统计。
 *
 * @brief[en] Textures management class
 * @explain[en] Extends DataMap, managing texture and sampler creation, update, and destruction operations, while maintaining rendering memory statistics.
 */
public open class Textures <: DataMap {

    /**
     * @brief[zh-cn] 渲染后端引用
     *
     * @brief[en] Rendering backend reference
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 渲染统计信息
     *
     * @brief[en] Rendering statistics info
     */
    public var info: Info

    /**
     * @brief[zh-cn] 构造器
     * @param[zh-cn] backend 渲染后端实例
     * info 渲染统计信息
     *
     * @brief[en] Constructor
     * @param[en] backend Rendering backend instance
     * info Rendering statistics info
     */
    public init(backend: Backend, info: Info) {
        super()
        this.backend = backend; this.info = info
    }

    /**
     * @brief[zh-cn] 创建纹理，递增纹理内存计数
     * @param[zh-cn] texture 纹理对象
     *
     * @brief[en] Create a texture, incrementing the texture memory count
     * @param[en] texture Texture object
     */
    public func createTexture(texture: Texture): Unit { this.info.memory.textures += 1 }

    /**
     * @brief[zh-cn] 更新纹理
     * @param[zh-cn] texture 纹理对象
     *
     * @brief[en] Update a texture
     * @param[en] texture Texture object
     */
    public func updateTexture(texture: Texture): Unit { }

    /**
     * @brief[zh-cn] 销毁纹理，递减纹理内存计数
     * @param[zh-cn] texture 纹理对象
     *
     * @brief[en] Destroy a texture, decrementing the texture memory count
     * @param[en] texture Texture object
     */
    public func destroyTexture(texture: Texture): Unit { this.info.memory.textures -= 1 }

    /**
     * @brief[zh-cn] 创建采样器
     * @param[zh-cn] sampler 采样器对象
     *
     * @brief[en] Create a sampler
     * @param[en] sampler Sampler object
     */
    public func createSampler(sampler: Sampler): Unit { }

    /**
     * @brief[zh-cn] 获取最大各向异性过滤值
     * @return[zh-cn] 最大各向异性过滤值
     *
     * @brief[en] Get the maximum anisotropy filtering value
     * @return[en] Maximum anisotropy filtering value
     */
    public func getMaxAnisotropy(): Int64 { return this.backend.getMaxAnisotropy() }
}
