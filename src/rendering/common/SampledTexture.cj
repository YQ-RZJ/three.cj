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
 * @file[zh-cn] 采样纹理
 * @brief[zh-cn] 采样纹理类，关联纹理对象与采样器
 * @explain[zh-cn] SampledTexture 继承自 Sampler，在采样器基础上增加纹理引用、绑定组索引和名称属性，用于渲染管线中将纹理与采样器参数组合绑定到着色器。
 *
 * @file[en] Sampled Texture
 * @brief[en] Sampled texture class, associating a texture object with a sampler
 * @explain[en] SampledTexture extends Sampler, adding texture reference, bind group index, and name properties on top of sampler parameters, used to combine texture and sampler parameters for shader binding in the rendering pipeline.
 */
package three.rendering.common

import three.rendering.textures.*

/**
 * @brief[zh-cn] 采样纹理类，关联纹理与采样器参数
 * @explain[zh-cn] 继承 Sampler，额外持有纹理对象引用、绑定组索引和名称，用于在渲染管线中统一管理纹理采样资源。
 *
 * @brief[en] Sampled texture class, associating a texture with sampler parameters
 * @explain[en] Extends Sampler, additionally holding a texture reference, bind group index, and name, used for unified management of texture sampling resources in the rendering pipeline.
 */
public open class SampledTexture <: Sampler {

    /**
     * @brief[zh-cn] 关联的纹理对象
     *
     * @brief[en] Associated texture object
     */
    public var texture: Texture

    /**
     * @brief[zh-cn] 绑定组索引
     *
     * @brief[en] Bind group index
     */
    public var bindGroupIndex: Int64

    /**
     * @brief[zh-cn] 纹理名称
     *
     * @brief[en] Texture name
     */
    public var name: String

    /**
     * @brief[zh-cn] 使用纹理对象构造采样纹理
     * @param[zh-cn] texture 纹理对象
     *
     * @brief[en] Construct a sampled texture with a texture object
     * @param[en] texture Texture object
     */
    public init(texture: Texture) {
        super()
        this.texture = texture; this.bindGroupIndex = 0; this.name = ""
    }

    /**
     * @brief[zh-cn] 使用纹理对象和名称构造采样纹理
     * @param[zh-cn] texture 纹理对象
     * name 纹理名称
     *
     * @brief[en] Construct a sampled texture with a texture object and name
     * @param[en] texture Texture object
     * name Texture name
     */
    public init(texture: Texture, name: String) {
        super()
        this.texture = texture; this.bindGroupIndex = 0; this.name = name
    }
}
