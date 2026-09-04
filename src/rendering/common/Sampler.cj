/**
 * @file[zh-cn] 采样器
 * @brief[zh-cn] 纹理采样器类，定义纹理过滤和寻址模式
 * @explain[zh-cn] Sampler 封装了纹理采样相关的参数，包括放大/缩小过滤模式以及 S/T/R 三个方向的寻址模式。作为 SampledTexture 的基类，为渲染管线的纹理采样提供配置支持。
 *
 * @file[en] Sampler
 * @brief[en] Texture sampler class, defining texture filtering and addressing modes
 * @explain[en] Sampler encapsulates texture sampling parameters, including magnification/minification filter modes and S/T/R addressing modes. As the base class of SampledTexture, it provides configuration support for texture sampling in the rendering pipeline.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 纹理采样器类
 * @explain[zh-cn] 定义纹理的过滤模式（放大/缩小）和寻址模式（S/T/R 方向），供纹理绑定使用。0 表示使用后端默认值。
 *
 * @brief[en] Texture sampler class
 * @explain[en] Defines texture filter modes (magnification/minification) and addressing modes (S/T/R directions) for texture binding. 0 indicates using backend defaults.
 */
public open class Sampler {

    /**
     * @brief[zh-cn] 放大过滤模式
     *
     * @brief[en] Magnification filter mode
     */
    public var magFilter: UInt32;

    /**
     * @brief[zh-cn] 缩小过滤模式
     *
     * @brief[en] Minification filter mode
     */
    public var minFilter: UInt32

    /**
     * @brief[zh-cn] S 方向寻址模式
     *
     * @brief[en] S-direction addressing mode
     */
    public var wrapS: UInt32

    /**
     * @brief[zh-cn] T 方向寻址模式
     *
     * @brief[en] T-direction addressing mode
     */
    public var wrapT: UInt32

    /**
     * @brief[zh-cn] R 方向寻址模式
     *
     * @brief[en] R-direction addressing mode
     */
    public var wrapR: UInt32

    /**
     * @brief[zh-cn] 构造器，初始化所有采样参数为 0（使用后端默认值）
     *
     * @brief[en] Constructor, initializes all sampling parameters to 0 (using backend defaults)
     */
    public init() { this.magFilter = 0u32; this.minFilter = 0u32; this.wrapS = 0u32; this.wrapT = 0u32; this.wrapR = 0u32 }
}
