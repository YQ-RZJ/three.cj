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
 * @file[zh-cn] 实例化缓冲属性
 * @brief[zh-cn] 继承 BufferAttribute，支持实例化渲染（meshPerAttribute），对应 Three.js InstancedBufferAttribute.js
 * @explain[zh-cn] 在 bgfx 渲染后端中，实例化缓冲对应 bgfx 的实例化顶点缓冲区。
 *
 * @file[en] Instanced Buffer Attribute
 * @brief[en] Extends BufferAttribute, supports instanced rendering (meshPerAttribute), corresponding to Three.js InstancedBufferAttribute.js
 * @explain[en] In the bgfx rendering backend, instanced buffer corresponds to bgfx instanced vertex buffer.
 *
 * @package three.rendering.buffer
 */
package three.rendering.buffer

import three.core.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 实例化缓冲属性，继承自 BufferAttribute
 * @explain[zh-cn] 实例化缓冲属性用于实例化渲染（instanced rendering），
 * 每个属性值可以在多个实例之间重复使用。
 *
 * @brief[en] Instanced buffer attribute, extends BufferAttribute
 * @explain[en] Instanced buffer attribute is used for instanced rendering,
 * where each attribute value can be reused across multiple instances.
 */
@JsonAdapter[withSuperClass = BufferAttribute]
public class InstancedBufferAttribute <: BufferAttribute {
    /**
     * @brief[zh-cn] 定义此缓冲区属性值在实例之间重复的次数
     * @explain[zh-cn] 值为 1 表示每个实例使用一个属性值；值为 2 表示每个属性值用于两个连续的实例，依此类推
     *
     * @brief[en] Defines the number of times this attribute value is repeated across instances
     * @explain[en] A value of 1 means each instance uses one attribute value; a value of 2 means each attribute value is used for two consecutive instances, etc.
     */
    public var meshPerAttribute: Int64

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        super()
        this.meshPerAttribute = 1
    }

    /**
     * @brief[zh-cn] 构造新的实例化缓冲属性
     * @param[zh-cn] array 存储属性数据的数组
     * itemSize 每个顶点的数据项数量
     * normalized 是否归一化，默认为 false
     * meshPerAttribute 每个属性值的重复次数，默认为 1
     *
     * @brief[en] Construct a new instanced buffer attribute
     * @param[en] array Array storing attribute data
     * itemSize Number of data items per vertex
     * normalized Whether to normalize, default false
     * meshPerAttribute Number of times each attribute value is repeated, default 1
     */
    public init(array: Array<Float64>, itemSize: Int64, normalized!: Bool = false, meshPerAttribute!: Int64 = 1) {
        super(array, itemSize, normalized: normalized)
        this.meshPerAttribute = meshPerAttribute
    }

    /**
     * @brief[zh-cn] 从另一个实例化缓冲属性复制数据到当前实例
     * @param[zh-cn] source 源实例化缓冲属性
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy data from another instanced buffer attribute to this instance
     * @param[en] source Source instanced buffer attribute
     * @return[en] Reference to this instance
     */
    public func copy(source: InstancedBufferAttribute): InstancedBufferAttribute {
        this.array = Array<Float64>(source.array.size, { i => source.array[i] })
        this.itemSize = source.itemSize
        this.count = source.count
        this.normalized = source.normalized
        this.meshPerAttribute = source.meshPerAttribute
        return this
    }
}
