/**
 * @file[zh-cn] 实例化交错缓冲区
 * @brief[zh-cn] 交错缓冲区的实例化版本，支持每个属性值的重复次数
 * @explain[zh-cn] 在 InterleavedBuffer 的基础上增加 meshPerAttribute 属性，用于实例化渲染。
 *
 * @file[en] Instanced Interleaved Buffer
 * @brief[en] Instanced version of interleaved buffer, supports per-attribute value repeat count
 * @explain[en] Adds meshPerAttribute property on top of InterleavedBuffer for instanced rendering.
 *
 * @package three.rendering.buffer
 */
package three.rendering.buffer

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 实例化交错缓冲区类，继承自 InterleavedBuffer
 * @explain[zh-cn] 定义每个属性值在实例间重复的次数
 *
 * @brief[en] Instanced interleaved buffer class, extends InterleavedBuffer
 * @explain[en] Defines the number of times each attribute value is repeated across instances
 */
@JsonAdapter[withSuperClass = InterleavedBuffer]
public class InstancedInterleavedBuffer <: InterleavedBuffer {
    /**
     * @brief[zh-cn] 定义此缓冲区属性值在每个实例间重复的次数，默认为 1
     *
     * @brief[en] Defines the number of times each attribute value is repeated across instances, default 1
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
     * @brief[zh-cn] 构造实例化交错缓冲区
     * @param[zh-cn] array 存储属性数据的数组
     * stride 每个顶点的元素数量
     * meshPerAttribute 每个属性值的重复次数，默认为 1
     *
     * @brief[en] Construct instanced interleaved buffer
     * @param[en] array Array storing attribute data
     * stride Number of elements per vertex
     * meshPerAttribute Number of times each attribute value is repeated, default 1
     */
    public init(array: Array<Float64>, stride: Int64, meshPerAttribute!: Int64 = 1) {
        super(array, stride)
        this.meshPerAttribute = meshPerAttribute
    }

    /**
     * @param[zh-cn] source 源交错缓冲区
     * @return[zh-cn] 当前实例
     *
     * 从另一个实例化交错缓冲区复制数据到当前实例
     *
     * @param[en] source Source interleaved buffer
     * @return[en] This instance
     */
    public func copy(source: InstancedInterleavedBuffer): InstancedInterleavedBuffer {
        super.copy(source)
        this.meshPerAttribute = source.meshPerAttribute
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前实例化交错缓冲区
     * @return[zh-cn] 新的实例化交错缓冲区实例
     *
     * @brief[en] Clone this instanced interleaved buffer
     * @return[en] New instanced interleaved buffer instance
     */
    public func clone(): InstancedInterleavedBuffer {
        let newArray = Array<Float64>(this.array.size, { i => this.array[i] })
        let ib = InstancedInterleavedBuffer(newArray, this.stride, meshPerAttribute: this.meshPerAttribute)
        ib.setUsage(this.usage)
        return ib
    }
}
