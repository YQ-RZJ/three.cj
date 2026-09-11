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
 * @file[zh-cn] 缓冲区属性
 * @brief[zh-cn] 存储顶点属性数据（位置、法线、UV、颜色等），对应 Three.js BufferAttribute.js
 * @explain[zh-cn] 这是 Three.js 中最核心的数据结构之一。
 * 每个属性持有一个 Array<Float64> 数据，按 itemSize 划分顶点。
 * 支持归一化、applyMatrix3/4、setXYZW、copyArray 等操作。
 * 在 bgfx 渲染后端中，对应 bgfx 顶点缓冲区。
 *
 * @file[en] Buffer Attribute
 * @brief[en] Stores vertex attribute data (position, normal, UV, color, etc.), corresponding to Three.js BufferAttribute.js
 * @explain[en] This is one of the most core data structures in Three.js.
 * Each attribute holds an Array<Float64> data array, partitioned by itemSize per vertex.
 * Supports normalization, applyMatrix3/4, setXYZW, copyArray, etc.
 * In the bgfx rendering backend, corresponds to bgfx vertex buffer.
 *
 * @package three.rendering.buffer
 */
package three.rendering.buffer

import three.core.math.*
import three.utils.constants.*
import three.core.interfaces.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 缓冲区属性类，存储顶点属性数据
 * @explain[zh-cn] 缓冲区属性持有顶点数据数组，通过 itemSize 描述每个顶点的数据项数量。
 * 一个属性数组应该有 `itemSize * numVertices` 个元素。
 *
 * @brief[en] Buffer attribute class, stores vertex attribute data
 * @explain[en] Buffer attribute holds vertex data array, described by itemSize as the number of data items per vertex.
 * An attribute array should have `itemSize * numVertices` elements.
 */
@JsonAdapter
public open class BufferAttribute <: AttributeReader {
    /**
     * @brief[zh-cn] 类型字符串，用于多态判断
     *
     * @brief[en] Type string for polymorphic dispatch
     */
    public var kind: String

    /**
     * @brief[zh-cn] 属性名称
     *
     * @brief[en] Attribute name
     */
    public var name: String

    /**
     * @brief[zh-cn] 数据数组，存储顶点属性数据，应有 itemSize * count 个元素
     *
     * @brief[en] Data array storing vertex attribute data, should have itemSize * count elements
     */
    public var array: Array<Float64>

    /**
     * @brief[zh-cn] 数据分组大小：每个顶点关联的数组元素数量
     *
     * @brief[en] Data group size: number of array elements per vertex
     */
    public var itemSize: Int64

    /**
     * @brief[zh-cn] 此属性存储的数据项总数，由 array.size / itemSize 计算
     *
     * @brief[en] Total number of data items stored in this attribute, computed as array.size / itemSize
     */
    @JsonIgnore
    private var _count: Int64 = 0
    @JsonIgnore
    public mut prop count: Int64 {
        get() { this._count }
        set(v) { this._count = v }
    }

    /**
     * @brief[zh-cn] 是否对整数数据进行归一化
     * @explain[zh-cn] 仅适用于整数数据。归一化时，整数范围会映射到 [0,1] 浮点范围
     *
     * @brief[en] Whether to normalize integer data
     * @explain[en] Only applicable to integer data. When normalized, integer range maps to [0,1] floating point range
     */
    public var normalized: Bool

    /**
     * @brief[zh-cn] 数据存储的预期使用模式，用于 GPU 优化
     * @explain[zh-cn] 可选值：StaticDrawUsage、DynamicDrawUsage、StreamDrawUsage 等
     *
     * @brief[en] Expected usage pattern for data storage, for GPU optimization
     * @explain[en] Options: StaticDrawUsage, DynamicDrawUsage, StreamDrawUsage, etc.
     */
    public var usage: Int64

    /**
     * @brief[zh-cn] 配置在着色器中使用的 GPU 数据类型
     * @explain[zh-cn] 仅对整数数组有效；浮点数组不可配置
     *
     * @brief[en] Configure GPU data type used in shaders
     * @explain[en] Only effective for integer arrays; float arrays are not configurable
     */
    public var gpuType: Int64

    /**
     * @brief[zh-cn] 版本号，每次 needsUpdate 设为 true 时递增
     *
     * @brief[en] Version number, incremented each time needsUpdate is set to true
     */
    public var version: Int64

    /**
     * @brief[zh-cn] 更新范围列表，用于只更新存储向量的部分组件
     * @explain[zh-cn] 使用 addUpdateRange() 添加范围
     *
     * @brief[en] Update range list, for updating only part of stored vector components
     * @explain[en] Use addUpdateRange() to add ranges
     */
    @JsonIgnore
    public var updateRanges: ArrayList<(Int64, Int64)>

    /**
     * @brief[zh-cn] 上传回调，在渲染器将数据传输到 GPU 后执行
     *
     * @brief[en] Upload callback, executed after renderer transfers data to GPU
     */
    @JsonIgnore
    public var onUploadCallback: () -> Unit

    /**
     * @brief[zh-cn] 无参构造（供 fastjson 反序列化使用）
     *
     * @brief[en] No-arg constructor (for fastjson deserialization)
     */
    public init() {
        this.kind = "BufferAttribute"
        this.name = ""
        this.array = Array<Float64>(0, { _ => 0.0 })
        this.itemSize = 0
        this._count = 0
        this.normalized = false
        this.usage = StaticDrawUsage
        this.gpuType = FloatType
        this.version = 0
        this.updateRanges = ArrayList<(Int64, Int64)>()
        this.onUploadCallback = { => }
    }

    /**
     * @brief[zh-cn] 构造一个新的缓冲区属性
     * @param[zh-cn] array 存储属性数据的数组
     * itemSize 每个顶点的数据项数量
     * normalized 是否归一化，默认为 false
     *
     * @brief[en] Construct a new buffer attribute
     * @param[en] array Array storing attribute data
     * itemSize Number of data items per vertex
     * normalized Whether to normalize, default false
     */
    public init(array: Array<Float64>, itemSize: Int64, normalized!: Bool = false) {
        this.kind = "BufferAttribute"
        this.name = ""
        this.array = array
        this.itemSize = itemSize
        this._count = array.size / itemSize
        this.normalized = false
        this.usage = StaticDrawUsage
        this.gpuType = FloatType
        this.version = 0
        this.updateRanges = ArrayList<(Int64, Int64)>()
        this.onUploadCallback = { => }
    }

    /**
     * @brief[zh-cn] 标记属性需要更新到 GPU
     * @explain[zh-cn] 调用此方法会使版本号递增
     *
     * @brief[en] Mark attribute as needing update to GPU
     * @explain[en] Calling this method increments the version number
     */
    public func markNeedsUpdate(): Unit {
        this.version += 1
    }

    /**
     * @brief[zh-cn] 设置此缓冲区属性的使用模式
     * @param[zh-cn] value 使用模式（如 StaticDrawUsage、DynamicDrawUsage 等）
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set the usage pattern of this buffer attribute
     * @param[en] value Usage pattern (e.g. StaticDrawUsage, DynamicDrawUsage)
     * @return[en] Reference to this instance
     */
    public func setUsage(value: Int64): BufferAttribute {
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
        this.updateRanges.add((start, count))
    }

    /**
     * 清除所有更新范围
     */
    public func clearUpdateRanges(): Unit {
        this.updateRanges.clear()
    }

    /**
     * @brief[zh-cn] 从另一个缓冲区属性复制数据到当前实例
     * @param[zh-cn] source 源缓冲区属性
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy data from another buffer attribute to this instance
     * @param[en] source Source buffer attribute
     * @return[en] Reference to this instance
     */
    public func copy(source: BufferAttribute): BufferAttribute {
        this.name = source.name
        this.array = Array<Float64>(source.array.size, { i => source.array[i] })
        this.itemSize = source.itemSize
        this._count = source.count
        this.normalized = source.normalized
        this.usage = source.usage
        this.gpuType = source.gpuType
        return this
    }

    /**
     * @brief[zh-cn] 从另一个缓冲区属性复制一个向量到当前属性
     * @param[zh-cn] index1 当前属性中的目标索引
     * attribute 源缓冲区属性
     * index2 源属性中的源索引
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy a vector from another buffer attribute to this attribute
     * @param[en] index1 Target index in this attribute
     * attribute Source buffer attribute
     * index2 Source index in source attribute
     * @return[en] Reference to this instance
     */
    public func copyAt(index1: Int64, attribute: BufferAttribute, index2: Int64): BufferAttribute {
        let i1 = index1 * this.itemSize
        let i2 = index2 * attribute.itemSize
        for (i in 0..this.itemSize) {
            this.array[i1 + i] = attribute.array[i2 + i]
        }
        return this
    }

    /**
     * @brief[zh-cn] 将给定数组数据复制到此缓冲区属性
     * @param[zh-cn] arr 要复制的数组
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy given array data to this buffer attribute
     * @param[en] arr Array to copy
     * @return[en] Reference to this instance
     */
    public func copyArray(arr: Array<Float64>): BufferAttribute {
        this.array = Array<Float64>(arr.size, { i => arr[i] })
        return this
    }

    /**
     * @brief[zh-cn] 将给定的 3x3 矩阵应用到当前属性，仅适用于 itemSize 为 2 或 3 的情况
     * @param[zh-cn] m 要应用的 3x3 矩阵
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Apply the given 3x3 matrix to this attribute, only applicable when itemSize is 2 or 3
     * @param[en] m 3x3 matrix to apply
     * @return[en] Reference to this instance
     */
    public func applyMatrix3(m: Matrix3): BufferAttribute {
        if (this.itemSize == 2) {
            let v2 = Vector2()
            for (i in 0..this.count) {
                v2.set(this.getX(i), this.getY(i))
                v2.applyMatrix3(m)
                this.setXY(i, v2.x, v2.y)
            }
        } else if (this.itemSize == 3) {
            let v3 = Vector3()
            for (i in 0..this.count) {
                v3.set(this.getX(i), this.getY(i), this.getZ(i))
                v3.applyMatrix3(m)
                this.setXYZ(i, v3.x, v3.y, v3.z)
            }
        }
        return this
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
    public func applyMatrix4(m: Matrix4): BufferAttribute {
        let v = Vector3()
        for (i in 0..this.count) {
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
    public func applyNormalMatrix(m: Matrix3): BufferAttribute {
        let v = Vector3()
        for (i in 0..this.count) {
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
    public func transformDirection(m: Matrix4): BufferAttribute {
        let v = Vector3()
        for (i in 0..this.count) {
            v.set(this.getX(i), this.getY(i), this.getZ(i))
            v.transformDirection(m)
            this.setXYZ(i, v.x, v.y, v.z)
        }
        return this
    }

    /**
     * @brief[zh-cn] 设置缓冲区属性中的数组数据
     * @param[zh-cn] value 要设置的数据数组
     * offset 偏移量，默认为 0
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Set array data in this buffer attribute
     * @param[en] value Data array to set
     * offset Offset, default 0
     * @return[en] Reference to this instance
     */
    public func set(value: Array<Float64>, offset!: Int64 = 0): BufferAttribute {
        for (i in 0..value.size) {
            this.array[offset + i] = value[i]
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
        var value = this.array[index * this.itemSize + component]
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
    public func setComponent(index: Int64, component: Int64, value: Float64): BufferAttribute {
        var v = value
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.array[index * this.itemSize + component] = v
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
        var x = this.array[index * this.itemSize]
        if (this.normalized) {
            x = MathUtils.denormalize(x, 0)
        }
        return x
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
    public func setX(index: Int64, x: Float64): BufferAttribute {
        var v = x
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.array[index * this.itemSize] = v
        return this
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
        var y = this.array[index * this.itemSize + 1]
        if (this.normalized) {
            y = MathUtils.denormalize(y, 0)
        }
        return y
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
    public func setY(index: Int64, y: Float64): BufferAttribute {
        var v = y
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.array[index * this.itemSize + 1] = v
        return this
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
        var z = this.array[index * this.itemSize + 2]
        if (this.normalized) {
            z = MathUtils.denormalize(z, 0)
        }
        return z
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
    public func setZ(index: Int64, z: Float64): BufferAttribute {
        var v = z
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.array[index * this.itemSize + 2] = v
        return this
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
        var w = this.array[index * this.itemSize + 3]
        if (this.normalized) {
            w = MathUtils.denormalize(w, 0)
        }
        return w
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
    public func setW(index: Int64, w: Float64): BufferAttribute {
        var v = w
        if (this.normalized) {
            v = MathUtils.normalize(v, 0)
        }
        this.array[index * this.itemSize + 3] = v
        return this
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
    public func setXY(index: Int64, x: Float64, y: Float64): BufferAttribute {
        var vx = x
        var vy = y
        let base = index * this.itemSize
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
        }
        this.array[base] = vx
        this.array[base + 1] = vy
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
    public func setXYZ(index: Int64, x: Float64, y: Float64, z: Float64): BufferAttribute {
        var vx = x
        var vy = y
        var vz = z
        let base = index * this.itemSize
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
            vz = MathUtils.normalize(vz, 0)
        }
        this.array[base] = vx
        this.array[base + 1] = vy
        this.array[base + 2] = vz
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
    public func setXYZW(index: Int64, x: Float64, y: Float64, z: Float64, w: Float64): BufferAttribute {
        var vx = x
        var vy = y
        var vz = z
        var vw = w
        let base = index * this.itemSize
        if (this.normalized) {
            vx = MathUtils.normalize(vx, 0)
            vy = MathUtils.normalize(vy, 0)
            vz = MathUtils.normalize(vz, 0)
            vw = MathUtils.normalize(vw, 0)
        }
        this.array[base] = vx
        this.array[base + 1] = vy
        this.array[base + 2] = vz
        this.array[base + 3] = vw
        return this
    }

    /**
     * @param[zh-cn] callback 回调函数
     * @return[zh-cn] 当前实例的引用
     *
     * 设置上传回调函数
     *
     * 在渲染器将数组数据传输到 GPU 后执行，
     * 可用于在上传后执行清理操作（当 CPU 端不再需要数据时）。
     *
     * @param[en] callback Callback function
     * @return[en] Reference to this instance
     */
    public func onUpload(callback: () -> Unit): BufferAttribute {
        this.onUploadCallback = callback
        return this
    }

    /**
     * @brief[zh-cn] 创建此缓冲区属性的副本
     * @return[zh-cn] 新的 BufferAttribute 实例
     *
     * @brief[en] Create a copy of this buffer attribute
     * @return[en] New BufferAttribute instance
     */
    public func clone(): BufferAttribute {
        let attr = BufferAttribute(
            Array<Float64>(this.array.size, { i => this.array[i] }),
            this.itemSize,
            normalized: this.normalized
        )
        return attr.copy(this)
    }

    /**
     * @brief[zh-cn] 返回本属性在 JSON 序列化时对应的 JS TypedArray 名
     * @explain[zh-cn] 对应 JS: `this.array.constructor.name`。仓颉侧统一用 `Array<Float64>` 存储，
     * 故由各子类按其对应的 JS TypedArray 名覆写此方法；基类默认返回 `"Float64Array"`。
     * @return[zh-cn] JS TypedArray 子类名，如 `"Float32Array"`、`"Uint16Array"`
     *
     * @brief[en] Return the JS TypedArray name corresponding to this attribute for JSON serialization
     * @explain[en] Corresponding to JS: `this.array.constructor.name`. Cangjie side uniformly uses `Array<Float64>`,
     * so each subclass overrides this method with its corresponding JS TypedArray name; base class defaults to `"Float64Array"`.
     * @return[en] JS TypedArray subclass name, e.g. `"Float32Array"`, `"Uint16Array"`
     */
    public open func getArrayType(): String {
        return "Float64Array"
    }

    /**
     * @brief[zh-cn] 释放此缓冲区属性占用的资源
     * @explain[zh-cn] 在 bgfx 渲染后端中，此方法用于通知缓冲区不再需要
     *
     * @brief[en] Dispose resources occupied by this buffer attribute
     * @explain[en] In the bgfx rendering backend, this method is used to notify that the buffer is no longer needed
     */
    public func dispose(): Unit {
        // 触发 dispose 事件（EventDispatcher 派生类才需要）
        // 基类仅清空数组引用
        this.array = Array<Float64>(0, { _ => 0.0 })
    }
}

/**
 * @brief[zh-cn] Float32 缓冲区属性（仓颉侧统一用 Float64 数组存储）
 * @explain[zh-cn] 与 BufferAttribute 相同，只是显式表达 float 类型语义
 *
 * @brief[en] Float32 buffer attribute (Cangjie side uniformly uses Float64 array storage)
 * @explain[en] Same as BufferAttribute, but explicitly expresses float type semantics
 */
public class Float32BufferAttribute <: BufferAttribute {
    public init(array: Array<Float64>, itemSize: Int64, normalized!: Bool = false) {
        super(array, itemSize, normalized: normalized)
        this.kind = "Float32BufferAttribute"
    }

    
    /**
     * @brief[zh-cn] 返回对应 JS TypedArray 名 "Float32Array"
     *
     * @brief[en] Return corresponding JS TypedArray name "Float32Array"
     */
    public override func getArrayType(): String {
        return "Float32Array"
    }
}

/**
 * @brief[zh-cn] Uint16 缓冲区属性（仓颉侧用 Float64 数组存储索引值）
 *
 * @brief[en] Uint16 buffer attribute (Cangjie side uses Float64 array to store index values)
 */
public class Uint16BufferAttribute <: BufferAttribute {
    public init(array: Array<Float64>, itemSize: Int64, normalized!: Bool = false) {
        super(array, itemSize, normalized: normalized)
        this.kind = "Uint16BufferAttribute"
    }

    
    /**
     * @brief[zh-cn] 返回对应 JS TypedArray 名 "Uint16Array"
     *
     * @brief[en] Return corresponding JS TypedArray name "Uint16Array"
     */
    public override func getArrayType(): String {
        return "Uint16Array"
    }
}

/**
 * @brief[zh-cn] Uint32 缓冲区属性（仓颉侧用 Float64 数组存储索引值）
 *
 * @brief[en] Uint32 buffer attribute (Cangjie side uses Float64 array to store index values)
 */
public class Uint32BufferAttribute <: BufferAttribute {
    public init(array: Array<Float64>, itemSize: Int64, normalized!: Bool = false) {
        super(array, itemSize, normalized: normalized)
        this.kind = "Uint32BufferAttribute"
    }

    
    /**
     * @brief[zh-cn] 返回对应 JS TypedArray 名 "Uint32Array"
     *
     * @brief[en] Return corresponding JS TypedArray name "Uint32Array"
     */
    public override func getArrayType(): String {
        return "Uint32Array"
    }
}
