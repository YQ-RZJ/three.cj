/**
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
