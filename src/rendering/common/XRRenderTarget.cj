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
 * @file[zh-cn] XR 渲染目标
 * @brief[zh-cn] XR 渲染目标类，定义 XR 渲染的帧缓冲尺寸
 * @explain[zh-cn] XRRenderTarget 表示 XR（扩展现实）渲染使用的渲染目标，持有宽度和高度属性。对照源码: three.js/src/renderers/common/XRRenderTarget.js
 *
 * @file[en] XR Render Target
 * @brief[en] XR render target class, defining the frame buffer dimensions for XR rendering
 * @explain[en] XRRenderTarget represents the render target used for XR (Extended Reality) rendering, holding width and height properties. Reference: three.js/src/renderers/common/XRRenderTarget.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] XR 渲染目标类
 * @explain[zh-cn] 定义 XR 渲染帧缓冲的宽度和高度尺寸。
 *
 * @brief[en] XR render target class
 * @explain[en] Defines the width and height dimensions of the XR rendering frame buffer.
 */
public open class XRRenderTarget {

    /**
     * @brief[zh-cn] 渲染目标宽度
     *
     * @brief[en] Render target width
     */
    public var width: Int64

    /**
     * @brief[zh-cn] 渲染目标高度
     *
     * @brief[en] Render target height
     */
    public var height: Int64

    /**
     * @brief[zh-cn] 构造器，指定渲染目标的宽高
     * @param[zh-cn] width 渲染目标宽度
     * height 渲染目标高度
     *
     * @brief[en] Constructor with specified render target dimensions
     * @param[en] width Render target width
     * height Render target height
     */
    public init(width: Int64, height: Int64) { this.width = width; this.height = height }
}
