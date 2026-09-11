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
 * @file[zh-cn] 存储数组纹理
 * @brief[zh-cn] 存储数组纹理类，用于 GPU 计算的纹理数组存储资源
 * @explain[zh-cn] StorageArrayTexture 继承自 DataMap，表示可在计算着色器中读写的纹理数组存储资源。对照源码: three.js/src/renderers/common/StorageArrayTexture.js
 *
 * @file[en] Storage Array Texture
 * @brief[en] Storage array texture class, used for GPU compute texture array storage resources
 * @explain[en] StorageArrayTexture extends DataMap, representing a texture array storage resource that can be read and written in compute shaders. Reference: three.js/src/renderers/common/StorageArrayTexture.js
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import std.collection.*

/**
 * @brief[zh-cn] 存储数组纹理类
 * @explain[zh-cn] 继承 DataMap，用于 GPU 计算管线的纹理数组存储资源，支持后端数据映射。
 *
 * @brief[en] Storage array texture class
 * @explain[en] Extends DataMap, used for GPU compute pipeline texture array storage resources, supporting backend data mapping.
 */
public open class StorageArrayTexture <: DataMap {

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() { super() }
}
