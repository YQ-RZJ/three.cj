/**
 * @file[zh-cn] 存储缓冲属性
 * @brief[zh-cn] 存储缓冲属性类，用于 GPU 计算的缓冲属性存储资源
 * @explain[zh-cn] StorageBufferAttribute 继承自 DataMap，表示可在计算着色器中读写的缓冲属性存储资源。仓颉：nodes 包已移除，IChainValue 不再实现；本类保持纯 DataMap 存储类型。对照源码: three.js/src/renderers/common/StorageBufferAttribute.js
 *
 * @file[en] Storage Buffer Attribute
 * @brief[en] Storage buffer attribute class, used for GPU compute buffer attribute storage resources
 * @explain[en] StorageBufferAttribute extends DataMap, representing a buffer attribute storage resource that can be read and written in compute shaders. Cangjie: nodes package removed, IChainValue no longer implemented; this class remains a pure DataMap storage type. Reference: three.js/src/renderers/common/StorageBufferAttribute.js
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
 * @brief[zh-cn] 存储缓冲属性类
 * @explain[zh-cn] 继承 DataMap，用于 GPU 计算管线的缓冲属性存储资源。仓颉版未实现 IChainValue 接口，保持纯存储类型。
 *
 * @brief[en] Storage buffer attribute class
 * @explain[en] Extends DataMap, used for GPU compute pipeline buffer attribute storage resources. Cangjie version does not implement IChainValue interface, keeping it as a pure storage type.
 */
public open class StorageBufferAttribute <: DataMap {

    /**
     * @brief[zh-cn] 构造器
     *
     * @brief[en] Constructor
     */
    public init() { super() }
}
