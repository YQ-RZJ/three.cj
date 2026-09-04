/**
 * @file[zh-cn] 交错缓冲区属性
 * @brief[zh-cn] 引用 InterleavedBuffer 中不同 offset 的属性视图，对应 Three.js InterleavedBufferAttribute.js
 * @explain[zh-cn] "交错"指多个属性（位置、法线、UV、颜色等）被打包到同一数组缓冲区中。
 * 本类不持有数据，而是通过 data/offset/itemSize 描述一个属性视图。
 *
 * @file[en] Interleaved Buffer Attribute
 * @brief[en] Attribute view referencing different offsets in InterleavedBuffer, corresponding to Three.js InterleavedBufferAttribute.js
 * @explain[en] "Interleaved" means multiple attributes (position, normal, UV, color, etc.) are packed into the same array buffer.
 * This class does not hold data, but describes an attribute view through data/offset/itemSize.
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
 * @brief[zh-cn] 交错缓冲区属性
 * @explain[zh-cn] 引用 InterleavedBuffer 中的交错数据，通过 offset 描述属性在缓冲区中的起始位置。
 * 与 BufferAttribute 不同，本类不独占数据，多个属性可共享同一个 InterleavedBuffer。
 *
 * @brief[en] Interleaved buffer attribute
 * @explain[en] References interleaved data in InterleavedBuffer, describing the attribute's starting position in the buffer via offset.
 * Unlike BufferAttribute, this class does not exclusively own data; multiple attributes can share the same InterleavedBuffer.
 */
@JsonAdapter
public class InterleavedBufferAttribute {
    /**
     * @brief[zh-cn] 缓冲区属性名称
     *
     * @brief[en] Buffer attribute name
     */
    public var name: String

    /**
     * @brief[zh-cn] 持有交错数据的缓冲区
     *
     * @brief[en] Buffer holding interleaved data
     */
    public var data: InterleavedBuffer

    /**
     * @brief[zh-cn] 数据项大小，参见 BufferAttribute.itemSize
     *
     * @brief[en] Data item size, see BufferAttribute.itemSize
     */
    public var itemSize: Int64

    /**
     * @brief[zh-cn] 属性在缓冲区中的偏移量
     *
     * @brief[en] Attribute offset in the buffer
     */
    public var offset: Int64

    /**
     * @brief[zh-cn] 是否对整数数据进行归一化，参见 BufferAttribute.normalized
     *
     * @brief[en] Whether to normalize integer data, see BufferAttribute.normalized
     */
    public var normalized: Bool

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        this.name = ""
        this.data = InterleavedBuffer()
        this.itemSize = 0
        this.offset = 0
        this.normalized = false
    }

    /**
     * @brief[zh-cn] 构造一个新的交错缓冲区属性
     * @param[zh-cn] interleavedBuffer 持有交错数据的缓冲区
     * itemSize 数据项大小
     * offset 属性在缓冲区中的偏移量
     * normalized 是否归一化，默认为 false
     *
     * @brief[en] Construct a new interleaved buffer attribute
     * @param[en] interleavedBuffer Buffer holding interleaved data
     * itemSize Data item size
     * offset Attribute offset in the buffer
     * normalized Whether to normalize, default false
     */
    public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64, normalized!: Bool = false) {
        this.name = ""
        this.data = interleavedBuffer
        this.itemSize = itemSize
        this.offset = offset
        this.normalized = normalized
    }

    /**
     * @brief[zh-cn] 兼容重载：3 参数形式（normalized 默认 false）
     * @param[zh-cn] interleavedBuffer 持有交错数据的缓冲区
     * itemSize 数据项大小
     * offset 属性在缓冲区中的偏移量
     *
     * @brief[en] Compatible overload: 3-parameter form (normalized defaults to false)
     * @param[en] interleavedBuffer Buffer holding interleaved data
     * itemSize Data item size
     * offset Attribute offset in the buffer
     */
    public init(interleavedBuffer: InterleavedBuffer, itemSize: Int64, offset: Int64) {
        this.name = ""
        this.data = interleavedBuffer
        this.itemSize = itemSize
        this.offset = offset
        this.normalized = false
    }

    /**
     * @brief[zh-cn] 此缓冲区属性的数据项数量
     * @return[zh-cn] 数据项数量
     *
     * @brief[en] Number of data items in this buffer attribute
     * @return[en] Number of data items
     */
    public func count(): Int64 {
        return this.data.count
    }

    /**
     * @brief[zh-cn] 获取持有交错数据的数组
     * @return[zh-cn] 底层数据数组
     *
     * @brief[en] Get the array holding interleaved data
     * @return[en] Underlying data array
     */
    public func array(): Array<Float64> {
        return this.data.array
    }

    /**
     * @brief[zh-cn] 标记属性需要更新到 GPU
     * @explain[zh-cn] 代理到底层 InterleavedBuffer 的 needsUpdate 标志。设置为 true 时底层缓冲区的 version 会自动递增。
     * @param[zh-cn] value 是否需要更新
     *
     * @brief[en] Mark attribute as needing update to GPU
     * @explain[en] Delegates to the underlying InterleavedBuffer's needsUpdate flag. When set to true, the underlying buffer's version is automatically incremented.
     * @param[en] value Whether needs update
     */
    public func setNeedsUpdate(value: Bool): Unit {
        if (value) {
            this.data.markNeedsUpdate()
        }
    }

    /**
     * @brief[zh-cn] 将给定的 4x4 矩阵应用到当前属性，仅适用于 itemSize 为 3 的情况
     * @param[zh-cn] m 要应用的 4x4 矩阵
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Apply the given 4x4 matrix to this attribute, only applicable when itemSize is 3
     * @param[en] m 4x4 matrix to apply
     * @return[en] Reference to this instance
     */
    public func applyMatrix4(m: Matrix4): InterleavedBufferAttribute {
        let v = Vector3()
        for (i in 0..this.data.count) {
            v.set(this.getX(i), this.getY(i), this.getZ(i))
            v.applyMatrix4(m)
            this.setXYZ(i, v.x, v.y, v.z)
        }
        return this
    }

    /**
     * @brief[zh-cn] 将给定的 3x3 法线矩阵应用到当前属性，仅适用于 itemSize 为 3 的情况
     * @param[zh-cn] m 要应用的 3x3 法线矩阵
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Apply the given 3x3 normal matrix to this attribute, only applicable when itemSize is 3
     * @param[en] m 3x3 normal matrix to apply
     * @return[en] Reference to this instance
     */
    public func applyNormalMatrix(m: Matrix3): InterleavedBufferAttribute {
        let v = Vector3()
        for (i in 0..this.data.count) {
            v.set(this.getX(i), this.getY(i), this.getZ(i))
            v.applyNormalMatrix(m)
            this.setXYZ(i, v.x, v.y, v.z)
        }
        return this
    }

    /**
     * @brief[zh-cn] 将给定的 4x4 矩阵应用到当前属性（仅适用于方向向量），仅适用于 itemSize 为 3 的情况
     * @param[zh-cn] m 要应用的 4x4 矩阵
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Apply the given 4x4 matrix to this attribute (only for direction vectors), only applicable when itemSize is 3
     * @param[en] m 4x4 matrix to apply
     * @return[en] Reference to this instance
     */
    public func transformDirection(m: Matrix4): InterleavedBufferAttribute {
        let v = Vector3()
        for (i in 0..this.data.count) {
            v.set(this.getX(i), this.getY(i), this.getZ(i))
            v.transformDirection(m)
            this.setXYZ(i, v.x, v.y, v.z)
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回指定索引处向量的指定分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * component 分量索引
     * @return[zh-cn] 该分量的值
     *
     * @brief[en] Return the specified component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * component Component index
     * @return[en] Value of the component
     */
    public func getComponent(index: Int64, component: Int64): Float64 {
        var value = this.data.array[index * this.data.stride + this.offset + component]
        if (this.normalized) {
            value = MathUtils.denormalize(value, 0)
        }
        return value
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量指定分量的值
     * @param[zh-cn] index 缓冲区属性中的索引
     * component 分量索引
     * value 要设置的值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the value of the specified component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * component Component index
     * value Value to set
     * @return[en] Reference to this instance
     */
    public func setComponent(index: Int64, component: Int64, value: Float64): InterleavedBufferAttribute {
        var v = value
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.data.array[index * this.data.stride + this.offset + component] = v
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 x 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * x 要设置的 x 值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the x component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * x x value to set
     * @return[en] Reference to this instance
     */
    public func setX(index: Int64, x: Float64): InterleavedBufferAttribute {
        var v = x
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.data.array[index * this.data.stride + this.offset] = v
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 y 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * y 要设置的 y 值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the y component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * y y value to set
     * @return[en] Reference to this instance
     */
    public func setY(index: Int64, y: Float64): InterleavedBufferAttribute {
        var v = y
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.data.array[index * this.data.stride + this.offset + 1] = v
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 z 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * z 要设置的 z 值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the z component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * z z value to set
     * @return[en] Reference to this instance
     */
    public func setZ(index: Int64, z: Float64): InterleavedBufferAttribute {
        var v = z
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.data.array[index * this.data.stride + this.offset + 2] = v
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 w 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * w 要设置的 w 值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the w component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * w w value to set
     * @return[en] Reference to this instance
     */
    public func setW(index: Int64, w: Float64): InterleavedBufferAttribute {
        var v = w
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.data.array[index * this.data.stride + this.offset + 3] = v
        return this
    }

    /**
     * @brief[zh-cn] 返回指定索引处向量的 x 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * @return[zh-cn] x 分量的值
     *
     * @brief[en] Return the x component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * @return[en] Value of the x component
     */
    public func getX(index: Int64): Float64 {
        var x = this.data.array[index * this.data.stride + this.offset]
        if (this.normalized) {
            x = MathUtils.denormalize(x, 0)
        }
        return x
    }

    /**
     * @brief[zh-cn] 返回指定索引处向量的 y 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * @return[zh-cn] y 分量的值
     *
     * @brief[en] Return the y component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * @return[en] Value of the y component
     */
    public func getY(index: Int64): Float64 {
        var y = this.data.array[index * this.data.stride + this.offset + 1]
        if (this.normalized) {
            y = MathUtils.denormalize(y, 0)
        }
        return y
    }

    /**
     * @brief[zh-cn] 返回指定索引处向量的 z 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * @return[zh-cn] z 分量的值
     *
     * @brief[en] Return the z component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * @return[en] Value of the z component
     */
    public func getZ(index: Int64): Float64 {
        var z = this.data.array[index * this.data.stride + this.offset + 2]
        if (this.normalized) {
            z = MathUtils.denormalize(z, 0)
        }
        return z
    }

    /**
     * @brief[zh-cn] 返回指定索引处向量的 w 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * @return[zh-cn] w 分量的值
     *
     * @brief[en] Return the w component of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * @return[en] Value of the w component
     */
    public func getW(index: Int64): Float64 {
        var w = this.data.array[index * this.data.stride + this.offset + 3]
        if (this.normalized) {
            w = MathUtils.denormalize(w, 0)
        }
        return w
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 x 和 y 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * x x 分量的值
     * y y 分量的值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the x and y components of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * x Value of the x component
     * y Value of the y component
     * @return[en] Reference to this instance
     */
    public func setXY(index: Int64, x: Float64, y: Float64): InterleavedBufferAttribute {
        var vx = x
        var vy = y
        let base = index * this.data.stride + this.offset
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
        }
        this.data.array[base] = vx
        this.data.array[base + 1] = vy
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 x、y、z 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * x x 分量的值
     * y y 分量的值
     * z z 分量的值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the x, y, z components of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * x Value of the x component
     * y Value of the y component
     * z Value of the z component
     * @return[en] Reference to this instance
     */
    public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): InterleavedBufferAttribute {
        var vx = x
        var vy = y
        var vz = z
        let base = index * this.data.stride + this.offset
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
            vz = MathUtils.normalize(vz, 0)
        }
        this.data.array[base] = vx
        this.data.array[base + 1] = vy
        this.data.array[base + 2] = vz
        return this
    }

    /**
     * @brief[zh-cn] 设置指定索引处向量的 x、y、z、w 分量
     * @param[zh-cn] index 缓冲区属性中的索引
     * x x 分量的值
     * y y 分量的值
     * z z 分量的值
     * w w 分量的值
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the x, y, z, w components of the vector at the given index
     * @param[en] index Index in the buffer attribute
     * x Value of the x component
     * y Value of the y component
     * z Value of the z component
     * w Value of the w component
     * @return[en] Reference to this instance
     */
    public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): InterleavedBufferAttribute {
        var vx = x
        var vy = y
        var vz = z
        var vw = w
        let base = index * this.data.stride + this.offset
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
            vz = MathUtils.normalize(vz, 0)
            vw = MathUtils.normalize(vw, 0)
        }
        this.data.array[base] = vx
        this.data.array[base + 1] = vy
        this.data.array[base + 2] = vz
        this.data.array[base + 3] = vw
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前交错缓冲区属性
     * @explain[zh-cn] 由于本类不持有数据（数据由 InterleavedBuffer 持有），克隆后的实例与原实例共享同一个底层缓冲区。
     * @return[zh-cn] 新的 InterleavedBufferAttribute 实例
     *
     * @brief[en] Clone this interleaved buffer attribute
     * @explain[en] Since this class does not hold data (data is held by InterleavedBuffer), the cloned instance shares the same underlying buffer with the original.
     * @return[en] New InterleavedBufferAttribute instance
     */
    public func clone(): InterleavedBufferAttribute {
        return InterleavedBufferAttribute(this.data, this.itemSize, this.offset, normalized: this.normalized)
    }
}
