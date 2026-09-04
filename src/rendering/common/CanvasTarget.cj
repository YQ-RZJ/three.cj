/**
 * @file[zh-cn] 画布目标
 * @brief[zh-cn] 画布渲染目标，描述画布尺寸
 * @explain[zh-cn] 
 * CanvasTarget 封装了画布的宽高尺寸信息，并提供 setSize 方法用于动态调整画布大小。
 *
 * @file[en] CanvasTarget
 * @brief[en] Canvas render target, describing canvas dimensions
 * @explain[en] 
 * CanvasTarget encapsulates the width and height dimensions of a canvas, and provides a setSize method for dynamically adjusting the canvas size.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 画布渲染目标，描述画布尺寸
 * @explain[zh-cn] 
 * 封装画布的宽高尺寸信息，支持动态调整。
 *
 * @brief[en] Canvas render target, describing canvas dimensions
 * @explain[en] 
 * Encapsulates the width and height dimensions of a canvas, supporting dynamic adjustment.
 */
public open class CanvasTarget {
    /**
     * @brief[zh-cn] 画布宽度
     *
     * @brief[en] Canvas width
     */
    public var width: Int64

    /**
     * @brief[zh-cn] 画布高度
     *
     * @brief[en] Canvas height
     */
    public var height: Int64

    /**
     * @brief[zh-cn] 构造画布目标，指定宽高
     * @param[zh-cn] width 画布宽度
     * height 画布高度
     *
     * @brief[en] Constructs a canvas target with specified width and height
     * @param[en] width Canvas width
     * height Canvas height
     */
    public init(width: Int64, height: Int64) { this.width = width; this.height = height }

    /**
     * @brief[zh-cn] 设置画布尺寸
     * @param[zh-cn] w 新宽度
     * h 新高度
     *
     * @brief[en] Sets the canvas size
     * @param[en] w New width
     * h New height
     */
    public func setSize(w: Int64, h: Int64): Unit { this.width = w; this.height = h }
}
