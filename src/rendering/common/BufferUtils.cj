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
