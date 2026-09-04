/**
 * @file[zh-cn] 立方体渲染目标
 * @brief[zh-cn] 立方体渲染目标，用于立方体贴图渲染
 * @explain[zh-cn] 
 * CubeRenderTarget 封装了立方体贴图渲染目标的纹理和尺寸信息，
 * 用于环境贴图、反射探针等需要六面体渲染的场景。
 *
 * @file[en] CubeRenderTarget
 * @brief[en] Cube render target, used for cube map rendering
 * @explain[en] 
 * CubeRenderTarget encapsulates the texture and dimension information of a cube map render target,
 * used for environment mapping, reflection probes, and other scenarios requiring six-face rendering.
 */
package three.rendering.common

import three.core.math.*
import three.rendering.textures.*

/**
 * @brief[zh-cn] 立方体渲染目标，用于立方体贴图渲染
 * @explain[zh-cn] 
 * 封装立方体贴图渲染目标的纹理和尺寸信息，用于环境贴图、反射探针等。
 *
 * @brief[en] Cube render target, used for cube map rendering
 * @explain[en] 
 * Encapsulates the texture and dimension information of a cube map render target, used for environment mapping, reflection probes, etc.
 */
public open class CubeRenderTarget {
    /**
     * @brief[zh-cn] 关联的纹理
     *
     * @brief[en] Associated texture
     */
    public var texture: Texture

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
     * @brief[zh-cn] 构造立方体渲染目标，指定尺寸
     * @param[zh-cn] width 宽度
     * height 高度
     *
     * @brief[en] Constructs a cube render target with specified dimensions
     * @param[en] width Width
     * height Height
     */
    public init(width: Int64, height: Int64) {
        this.texture = Texture()
        this.width = width; this.height = height
    }

    /**
     * @brief[zh-cn] 设置渲染目标尺寸
     * @param[zh-cn] w 新宽度
     * h 新高度
     *
     * @brief[en] Sets the render target dimensions
     * @param[en] w New width
     * h New height
     */
    public func setSize(w: Int64, h: Int64): Unit { this.width = w; this.height = h }
}
