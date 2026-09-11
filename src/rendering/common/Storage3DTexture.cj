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
 * @file[zh-cn] 3D 存储纹理
 * @brief[zh-cn] 3D 存储纹理类，用于 GPU 计算/存储的 3D 纹理资源
 * @explain[zh-cn] Storage3DTexture 表示可在计算着色器中读写的三维纹理存储资源，kind 属性标识纹理类型。对照源码: three.js/src/renderers/common/Storage3DTexture.js
 *
 * @file[en] Storage 3D Texture
 * @brief[en] Storage 3D texture class, used for GPU compute/storage 3D texture resources
 * @explain[en] Storage3DTexture represents a 3D texture storage resource that can be read and written in compute shaders, with a kind property identifying the texture type. Reference: three.js/src/renderers/common/Storage3DTexture.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] 3D 存储纹理类
 * @explain[zh-cn] 用于 GPU 计算管线的 3D 纹理存储资源，kind 属性标识纹理类型为 "Storage3DTexture"。
 *
 * @brief[en] Storage 3D texture class
 * @explain[en] 3D texture storage resource for GPU compute pipelines, kind property identifies the texture type as "Storage3DTexture".
 */
public open class Storage3DTexture {

    /**
     * @brief[zh-cn] 纹理类型标识
     *
     * @brief[en] Texture type identifier
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造器，初始化 kind 为 "Storage3DTexture"
     *
     * @brief[en] Constructor, initializes kind to "Storage3DTexture"
     */
    public init() {
        this.kind = "Storage3DTexture"
    }
}
