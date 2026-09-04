/**
 * @file[zh-cn] 存储纹理
 * @brief[zh-cn] 存储纹理类，用于 GPU 计算/存储的纹理资源
 * @explain[zh-cn] StorageTexture 继承自 DataMap，表示可在计算着色器中读写的纹理存储资源。对照源码: three.js/src/renderers/common/StorageTexture.js
 *
 * @file[en] Storage Texture
 * @brief[en] Storage texture class, used for GPU compute/storage texture resources
 * @explain[en] StorageTexture extends DataMap, representing a texture storage resource that can be read and written in compute shaders. Reference: three.js/src/renderers/common/StorageTexture.js
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
 * @brief[zh-cn] 存储纹理类
 * @explain[zh-cn] 继承 DataMap，用于 GPU 计算管线的纹理存储资源，支持后端数据映射。
 *
 * @brief[en] Storage texture class
 * @explain[en] Extends DataMap, used for GPU compute pipeline texture storage resources, supporting backend data mapping.
 */
public open class StorageTexture <: DataMap {

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() { super() }
}
