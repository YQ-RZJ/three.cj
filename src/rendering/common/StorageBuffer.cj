/**
 * @file[zh-cn] 存储缓冲
 * @brief[zh-cn] 存储缓冲类，用于 GPU 计算/存储的缓冲资源
 * @explain[zh-cn] StorageBuffer 继承自 DataMap，表示可在计算着色器中读写的缓冲存储资源。对照源码: three.js/src/renderers/common/StorageBuffer.js
 *
 * @file[en] Storage Buffer
 * @brief[en] Storage buffer class, used for GPU compute/storage buffer resources
 * @explain[en] StorageBuffer extends DataMap, representing a buffer storage resource that can be read and written in compute shaders. Reference: three.js/src/renderers/common/StorageBuffer.js
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
 * @brief[zh-cn] 存储缓冲类
 * @explain[zh-cn] 继承 DataMap，用于 GPU 计算管线的缓冲存储资源，支持后端数据映射。
 *
 * @brief[en] Storage buffer class
 * @explain[en] Extends DataMap, used for GPU compute pipeline buffer storage resources, supporting backend data mapping.
 */
public open class StorageBuffer <: DataMap {

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() { super() }
}
