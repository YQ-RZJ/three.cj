/**
 * @file[zh-cn] Uniform 缓冲
 * @brief[zh-cn] Uniform 缓冲类，用于管理着色器 uniform 数据
 * @explain[zh-cn] UniformBuffer 封装了着色器 uniform 数据的存储和更新，持有名称、数据数组和字节长度属性，提供数据设置和更新方法。对照源码: three.js/src/renderers/common/UniformBuffer.js
 *
 * @file[en] Uniform Buffer
 * @brief[en] Uniform buffer class, used for managing shader uniform data
 * @explain[en] UniformBuffer encapsulates storage and updating of shader uniform data, holding name, data array, and byte length properties, providing data setting and update methods. Reference: three.js/src/renderers/common/UniformBuffer.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] Uniform 缓冲类
 * @explain[zh-cn] 管理着色器 uniform 数据的存储缓冲，持有名称、Float32 数据数组和字节长度，支持数据设置与更新。
 *
 * @brief[en] Uniform buffer class
 * @explain[en] Manages the storage buffer for shader uniform data, holding name, Float32 data array, and byte length, supporting data setting and updating.
 */
public open class UniformBuffer {

    /**
     * @brief[zh-cn] 缓冲名称
     *
     * @brief[en] Buffer name
     */
    public var name: String

    /**
     * @brief[zh-cn] 缓冲数据数组
     *
     * @brief[en] Buffer data array
     */
    public var data: Array<Float32>

    /**
     * @brief[zh-cn] 缓冲字节长度
     *
     * @brief[en] Buffer byte length
     */
    public var byteLength: Int64

    /**
     * @brief[zh-cn] 构造器，指定名称和字节长度
     * @param[zh-cn] name 缓冲名称
     * byteLength 缓冲字节长度
     *
     * @brief[en] Constructor with specified name and byte length
     * @param[en] name Buffer name
     * byteLength Buffer byte length
     */
    public init(name: String, byteLength: Int64) { this.name = name; this.byteLength = byteLength; this.data = Array<Float32>(byteLength / 4, { _ => 0.0f32 }) }

    /**
     * @brief[zh-cn] 设置缓冲数据
     * @param[zh-cn] data 新的数据数组
     *
     * @brief[en] Set buffer data
     * @param[en] data New data array
     */
    public func setData(data: Array<Float32>): Unit { this.data = data }

    /**
     * @brief[zh-cn] 更新缓冲数据到 GPU
     *
     * @brief[en] Update buffer data to GPU
     */
    public func update(): Unit { }
}
