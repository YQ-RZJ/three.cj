/**
 * @file[zh-cn] 实例化存储缓冲属性
 * @brief[zh-cn] 实例化存储缓冲属性类，用于 GPU 实例化计算的缓冲属性存储资源
 * @explain[zh-cn] StorageInstancedBufferAttribute 继承自 DataMap，表示可在计算着色器中读写的实例化缓冲属性存储资源，支持逐实例数据。对照源码: three.js/src/renderers/common/StorageInstancedBufferAttribute.js
 *
 * @file[en] Storage Instanced Buffer Attribute
 * @brief[en] Storage instanced buffer attribute class, used for GPU instanced compute buffer attribute storage resources
 * @explain[en] StorageInstancedBufferAttribute extends DataMap, representing an instanced buffer attribute storage resource that can be read and written in compute shaders, supporting per-instance data. Reference: three.js/src/renderers/common/StorageInstancedBufferAttribute.js
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
 * @brief[zh-cn] 实例化存储缓冲属性类
 * @explain[zh-cn] 继承 DataMap，用于 GPU 实例化计算管线的缓冲属性存储资源，支持逐实例数据访问。
 *
 * @brief[en] Storage instanced buffer attribute class
 * @explain[en] Extends DataMap, used for GPU instanced compute pipeline buffer attribute storage resources, supporting per-instance data access.
 */
public open class StorageInstancedBufferAttribute <: DataMap {

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() { super() }
}
