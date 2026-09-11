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
 * @file[zh-cn] 混合模式
 * @brief[zh-cn] 混合模式描述，定义颜色混合方程和因子
 * @explain[zh-cn] 
 * BlendMode 封装了渲染管线的颜色混合配置，包含混合模式、方程、源因子和目标因子。
 * 对应 Three.js 中的混合状态配置。
 *
 * @file[en] BlendMode
 * @brief[en] Blend mode description, defining color blending equation and factors
 * @explain[en] 
 * BlendMode encapsulates the color blending configuration for the render pipeline,
 * including blend mode, equation, source factor, and destination factor.
 * Corresponds to the blending state configuration in Three.js.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 混合模式描述，定义颜色混合方程和因子
 * @explain[zh-cn] 
 * 封装渲染管线的颜色混合配置：模式、方程、源因子和目标因子。
 *
 * @brief[en] Blend mode description, defining color blending equation and factors
 * @explain[en] 
 * Encapsulates the color blending configuration for the render pipeline: mode, equation, source factor, and destination factor.
 */
public open class BlendMode {
    /**
     * @brief[zh-cn] 混合模式
     *
     * @brief[en] Blend mode
     */
    public var mode: Int64

    /**
     * @brief[zh-cn] 混合方程
     *
     * @brief[en] Blend equation
     */
    public var equation: Int64

    /**
     * @brief[zh-cn] 源混合因子
     *
     * @brief[en] Source blend factor
     */
    public var srcFactor: Int64

    /**
     * @brief[zh-cn] 目标混合因子
     *
     * @brief[en] Destination blend factor
     */
    public var dstFactor: Int64

    /**
     * @brief[zh-cn] 构造默认混合模式（全部为零）
     *
     * @brief[en] Constructs a default blend mode (all zeros)
     */
    public init() { this.mode = 0; this.equation = 0; this.srcFactor = 1; this.dstFactor = 0 }

    /**
     * @brief[zh-cn] 构造指定参数的混合模式
     * @param[zh-cn] mode 混合模式
     * equation 混合方程
     * srcFactor 源混合因子
     * dstFactor 目标混合因子
     *
     * @brief[en] Constructs a blend mode with specified parameters
     * @param[en] mode Blend mode
     * equation Blend equation
     * srcFactor Source blend factor
     * dstFactor Destination blend factor
     */
    public init(mode: Int64, equation: Int64, srcFactor: Int64, dstFactor: Int64) { this.mode = mode; this.equation = equation; this.srcFactor = srcFactor; this.dstFactor = dstFactor }
}
