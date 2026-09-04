/**
 * @file[zh-cn] 交错缓冲区
 * @brief[zh-cn] 将多个属性（如位置、法线、UV、颜色）打包到单个数组缓冲区中
 * @explain[zh-cn] "交错"意味着多个可能不同类型的属性被打包到单个数组缓冲区中。
 * 参考：https://blog.tojicode.com/2011/05/interleaved-array-basics.html
 * "Interleaved" means multiple attributes of possibly different types are packed into a single array buffer.
 * Reference: https://blog.tojicode.com/2011/05/interleaved-array-basics.html
 *
 * @file[en] Interleaved Buffer
 * @brief[en] Packs multiple attributes (position, normal, UV, color) into a single array buffer
 *
 * @package three.rendering.buffer
 */
package three.rendering.buffer

import three.core.math.*
import three.utils.constants.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 更新范围，用于标记需要更新到 GPU 的数据范围
 *
 * @brief[en] Update range, marks data range that needs to be updated to GPU
 */
@JsonAdapter
public class UpdateRange {
    /** 起始位置 */
    public var start: Int64
    /** 元素数量 */
    public var count: Int64

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init(start: Int64, count: Int64) {
        this.start = start
        this.count = count
    }
    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        this.start = 0
        this.count = 0
    }
}

/**
 * @brief[zh-cn] 交错缓冲区类，将多个属性数据打包到单个数组中
 *
 * @brief[en] Interleaved buffer class, packs multiple attribute data into a single array
 */
@JsonAdapter
public open class InterleavedBuffer {
    /**
     * @brief[zh-cn] 存储属性数据的数组
     *
     * @brief[en] Array storing attribute data
     */
    public var array: Array<Float64>

    /**
     * @brief[zh-cn] 每个顶点的类型化数组元素数量（步长）
     *
     * @brief[en] Number of typed array elements per vertex (stride)
     */
    public var stride: Int64

    /**
     * @brief[zh-cn] 数组中的元素总数
     *
     * @brief[en] Total number of elements in the array
     */
    public var count: Int64

    /**
     * @brief[zh-cn] 数据存储的预期使用模式，用于优化目的
     * @explain[zh-cn] 可选值：StaticDrawUsage, DynamicDrawUsage, StreamDrawUsage 等，默认为 StaticDrawUsage
     *
     * @brief[en] Expected usage pattern for data storage, for optimization purposes
     * @explain[en] Options: StaticDrawUsage, DynamicDrawUsage, StreamDrawUsage, etc. Default is StaticDrawUsage
     */
    public var usage: Int64

    /**
     * @brief[zh-cn] 更新范围列表，用于只更新存储向量的部分组件
     * @explain[zh-cn] 使用 addUpdateRange() 函数添加范围
     *
     * @brief[en] Update range list, for updating only part of stored vector components
     * @explain[en] Use addUpdateRange() to add ranges
     */
    public var updateRanges: ArrayList<UpdateRange>

    /**
     * @brief[zh-cn] 版本号，每次 needsUpdate 设为 true 时递增
     *
     * @brief[en] Version number, incremented each time needsUpdate is set to true
     */
    public var version: Int64

    /**
     * @brief[zh-cn] 此交错缓冲区的唯一标识符（let 不可变，不参与序列化）
     *
     * @brief[en] Unique identifier of this interleaved buffer (let immutable, not serialized)
     */
    @JsonIgnore
    public let uuid: String

    /**
     * @brief[zh-cn] 上传回调函数，在渲染器将属性数组数据传输到 GPU 后执行（函数类型，不支持序列化）
     *
     * @brief[en] Upload callback, executed after renderer transfers attribute array data to GPU (function type, not serializable)
     */
    @JsonIgnore
    public var onUploadCallback: () -> Unit

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        this.array = Array<Float64>(0, { _ => 0.0 })
        this.stride = 0
        this.count = 0
        this.usage = StaticDrawUsage
        this.updateRanges = ArrayList<UpdateRange>()
        this.version = 0
        this.uuid = MathUtils.generateUUID()
        this.onUploadCallback = { => }
    }

    /**
     * @brief[zh-cn] 构造交错缓冲区
     * @param[zh-cn] array 存储属性数据的数组
     * stride 每个顶点的元素数量
     *
     * @brief[en] Construct interleaved buffer
     * @param[en] array Array storing attribute data
     * stride Number of elements per vertex
     */
    public init(array: Array<Float64>, stride: Int64) {
        this.array = array
        this.stride = stride
        this.count = array.size / stride
        this.usage = StaticDrawUsage
        this.updateRanges = ArrayList<UpdateRange>()
        this.version = 0
        this.uuid = MathUtils.generateUUID()
        this.onUploadCallback = { => }
    }

    /**
     * @brief[zh-cn] 标记数据需要更新到 GPU
     * @explain[zh-cn] 调用此方法会使版本号递增
     *
     * @brief[en] Mark data as needing update to GPU
     * @explain[en] Calling this method increments the version number
     */
    public func markNeedsUpdate(): Unit {
        this.version++
    }

    /**
     * @brief[zh-cn] 设置此交错缓冲区的使用模式
     * @param[zh-cn] value 使用模式（如 StaticDrawUsage, DynamicDrawUsage 等）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the usage pattern of this interleaved buffer
     * @param[en] value Usage pattern (e.g. StaticDrawUsage, DynamicDrawUsage)
     * @return[en] Current instance
     */
    public func setUsage(value: Int64): InterleavedBuffer {
        this.usage = value
        return this
    }

    /**
     * @brief[zh-cn] 添加需要更新到 GPU 的数据范围
     * @param[zh-cn] start 起始位置
     * count 要更新的组件数量
     *
     * @brief[en] Add data range that needs to be updated to GPU
     * @param[en] start Start position
     * count Number of components to update
     */
    public func addUpdateRange(start: Int64, count: Int64): Unit {
        this.updateRanges.add(UpdateRange(start, count))
    }

    /**
     * @brief[zh-cn] 清除所有更新范围
     *
     * @brief[en] Clear all update ranges
     */
    public func clearUpdateRanges(): Unit {
        this.updateRanges.clear()
    }

    /**
     * @brief[zh-cn] 从另一个交错缓冲区复制数据到当前实例
     * @param[zh-cn] source 源交错缓冲区
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy data from another interleaved buffer to this instance
     * @param[en] source Source interleaved buffer
     * @return[en] Current instance
     */
    public func copy(source: InterleavedBuffer): InterleavedBuffer {
        this.array = Array<Float64>(source.array.size, { i => source.array[i] })
        this.count = source.count
        this.stride = source.stride
        this.usage = source.usage
        return this
    }

    /**
     * @brief[zh-cn] 从另一个交错缓冲区复制一个向量到当前缓冲区
     * @param[zh-cn] index1 当前缓冲区中的目标索引
     * interleavedBuffer 源交错缓冲区
     * index2 源缓冲区中的源索引
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy a vector from another interleaved buffer to this buffer
     * @param[en] index1 Target index in this buffer
     * interleavedBuffer Source interleaved buffer
     * index2 Source index in source buffer
     * @return[en] Current instance
     */
    public func copyAt(index1: Int64, interleavedBuffer: InterleavedBuffer, index2: Int64): InterleavedBuffer {
        let i1 = index1 * this.stride
        let i2 = index2 * interleavedBuffer.stride
        for (i in 0..this.stride) {
            this.array[i1 + i] = interleavedBuffer.array[i2 + i]
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置交错缓冲区中的数组数据
     * @param[zh-cn] value 要设置的数据数组
     * offset 偏移量，默认为 0
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set array data in this interleaved buffer
     * @param[en] value Data array to set
     * offset Offset, default 0
     * @return[en] Current instance
     */
    public func set(value: Array<Float64>, offset!: Int64 = 0): InterleavedBuffer {
        for (i in 0..value.size) {
            this.array[offset + i] = value[i]
        }
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前交错缓冲区
     * @return[zh-cn] 新的交错缓冲区实例
     *
     * @brief[en] Clone this interleaved buffer
     * @return[en] New interleaved buffer instance
     */
    public open func clone(): InterleavedBuffer {
        let newArray = Array<Float64>(this.array.size, { i => this.array[i] })
        let ib = InterleavedBuffer(newArray, this.stride)
        ib.setUsage(this.usage)
        return ib
    }

    /**
     * @brief[zh-cn] 设置上传回调函数
     * @explain[zh-cn] 在渲染器将数组数据传输到 GPU 后执行，可用于在上传后执行清理操作
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set upload callback function
     * @explain[en] Executed after renderer transfers array data to GPU, can be used for cleanup after upload
     * @param[en] callback Callback function
     * @return[en] Current instance
     */
    public func onUpload(callback: () -> Unit): InterleavedBuffer {
        this.onUploadCallback = callback
        return this
    }
}
