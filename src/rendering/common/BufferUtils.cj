/**
 * @file[zh-cn] 缓冲区工具
 * @brief[zh-cn] 缓冲区数据类型转换工具类
 * @explain[zh-cn] 
 * BufferUtils 提供 Float64 与 Float32 数组之间的类型转换工具方法，
 * 用于渲染管线中 CPU 侧数据到 GPU 侧数据的转换。
 *
 * @file[en] BufferUtils
 * @brief[en] Buffer data type conversion utility class
 * @explain[en] 
 * BufferUtils provides utility methods for type conversion between Float64 and Float32 arrays,
 * used in the render pipeline for converting CPU-side data to GPU-side data.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 缓冲区数据类型转换工具类
 * @explain[zh-cn] 
 * 提供 Float64 与 Float32 数组之间的相互转换。
 *
 * @brief[en] Buffer data type conversion utility class
 * @explain[en] 
 * Provides bidirectional conversion between Float64 and Float32 arrays.
 */
public open class BufferUtils {
    /**
     * @brief[zh-cn] 将 Float64 数组转换为 Float32 数组
     * @param[zh-cn] data Float64 数组
     * @return[zh-cn] 转换后的 Float32 数组
     *
     * @brief[en] Converts a Float64 array to a Float32 array
     * @param[en] data Float64 array
     * @return[en] Converted Float32 array
     */
    public static func fromArray(data: Array<Float64>): Array<Float32> {
        return Array<Float32>(data.size, { i => Float32(data[i]) })
    }

    /**
     * @brief[zh-cn] 将 Float32 数组转换为 Float64 数组
     * @param[zh-cn] data Float32 数组
     * @return[zh-cn] 转换后的 Float64 数组
     *
     * @brief[en] Converts a Float32 array to a Float64 array
     * @param[en] data Float32 array
     * @return[en] Converted Float64 array
     */
    public static func toArray(data: Array<Float32>): Array<Float64> {
        return Array<Float64>(data.size, { i => Float64(data[i]) })
    }
}
