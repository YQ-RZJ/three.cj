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
 * @file[zh-cn] 四通道颜色
 * @brief[zh-cn] RGBA 四通道颜色表示
 * @explain[zh-cn] 
 * Color4 表示一个 RGBA 颜色，每个通道为 [0, 1] 范围的浮点数，
 * 提供 toUint32 方法转换为 UInt32 格式用于 GPU 传输。
 *
 * @file[en] Color4
 * @brief[en] RGBA four-channel color representation
 * @explain[en] 
 * Color4 represents an RGBA color where each channel is a float in the [0, 1] range,
 * providing a toUint32 method for converting to UInt32 format for GPU transfer.
 */
package three.rendering.common

/**
 * @brief[zh-cn] RGBA 四通道颜色表示
 * @explain[zh-cn] 
 * 每个 RGBA 通道为 [0, 1] 浮点数，支持 toUint32 转换为 GPU 友好的 UInt32 格式。
 *
 * @brief[en] RGBA four-channel color representation
 * @explain[en] 
 * Each RGBA channel is a float in [0, 1], supporting toUint32 conversion to GPU-friendly UInt32 format.
 */
public open class Color4 {
    /**
     * @brief[zh-cn] 红色通道
     *
     * @brief[en] Red channel
     */
    public var r: Float64

    /**
     * @brief[zh-cn] 绿色通道
     *
     * @brief[en] Green channel
     */
    public var g: Float64

    /**
     * @brief[zh-cn] 蓝色通道
     *
     * @brief[en] Blue channel
     */
    public var b: Float64

    /**
     * @brief[zh-cn] 透明度通道
     *
     * @brief[en] Alpha channel
     */
    public var a: Float64

    /**
     * @brief[zh-cn] 构造默认白色（1, 1, 1, 1）
     *
     * @brief[en] Constructs default white (1, 1, 1, 1)
     */
    public init() { this.r = 1.0; this.g = 1.0; this.b = 1.0; this.a = 1.0 }

    /**
     * @brief[zh-cn] 构造指定 RGBA 值的颜色
     * @param[zh-cn] r 红色通道
     * g 绿色通道
     * b 蓝色通道
     * a 透明度通道
     *
     * @brief[en] Constructs a color with specified RGBA values
     * @param[en] r Red channel
     * g Green channel
     * b Blue channel
     * a Alpha channel
     */
    public init(r: Float64, g: Float64, b: Float64, a: Float64) { this.r = r; this.g = g; this.b = b; this.a = a }

    /**
     * @brief[zh-cn] 将 RGBA 转换为 UInt32 格式（R<<24 | G<<16 | B<<8 | A）
     * @return[zh-cn] UInt32 颜色值
     *
     * @brief[en] Converts RGBA to UInt32 format (R<<24 | G<<16 | B<<8 | A)
     * @return[en] UInt32 color value
     */
    public func toUint32(): UInt32 { return (UInt32(this.r * 255.0) << 24) | (UInt32(this.g * 255.0) << 16) | (UInt32(this.b * 255.0) << 8) | UInt32(this.a * 255.0) }
}
