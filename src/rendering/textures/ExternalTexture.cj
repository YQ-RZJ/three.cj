/**
 * @file[zh-cn] 外部纹理
 * @brief[zh-cn] 由外部源构造的纹理，数据不在 GPU 内存中而是引用外部缓冲
 * @explain[zh-cn] 外部纹理：由外部源（如 WebGPU externalTexture、camera frame、video frame 等）构造的纹理，数据不在 GPU 内存中而是引用外部缓冲。仅 WebGPURenderer 支持；bgfx4cj 后端下保留接口签名。

 * @file[en] External Texture
 * @brief[en] Texture constructed from external sources, data not in GPU memory but referencing external buffers
 * @explain[en] External texture: texture constructed from external sources (e.g., WebGPU externalTexture, camera frame, video frame, etc.), data not in GPU memory but referencing external buffers. Only supported by WebGPURenderer; bgfx4cj backend preserves interface signature. 
 */
package three.rendering.textures

import three.core.math.MathUtils
import std.collection.*
import bgfx4cj.bgfx.TextureHandle

/**
 * @brief[zh-cn] 外部纹理类
 * @explain[zh-cn] 由外部源构造的纹理，数据引用外部缓冲而非 GPU 内存。bgfx4cj 后端下保留接口签名。

 * @brief[en] External texture class
 * @explain[en] Texture constructed from external sources, data references external buffers instead of GPU memory. bgfx4cj backend preserves interface signature.
 */
public open class ExternalTexture <: Texture {

    /**
     * @brief[zh-cn] 外部纹理缓冲引用（渲染器内部按平台具体解释）

     * @brief[en] External texture buffer reference (interpreted by platform in the renderer)
     */
    public var sourceTexture: Option<TextureHandle>

    /**
     * @brief[zh-cn] 构造一个新的外部纹理
     * @param[zh-cn] sourceTexture 外部源纹理，默认 None

     * @brief[en] Construct a new external texture
     * @param[en] sourceTexture External source texture, defaults to None
     */
    public init(sourceTexture!: ?TextureHandle = None) {
        super()
        this.kind = "ExternalTexture"
        this.sourceTexture = sourceTexture
    }

    /**
     * @brief[zh-cn] 将给定外部纹理实例的值复制到本实例
     * @param[zh-cn] source 源纹理
     * @return[zh-cn] 当前实例

     * @brief[en] Copy values from the given external texture instance to this instance
     * @param[en] source Source texture
     * @return[en] This instance
     */
    public override func copy(source: Texture): Texture {
        super.copy(source)
        match (source) {
            case s: ExternalTexture => this.sourceTexture = s.sourceTexture
            case _ => ()
        }
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新外部纹理实例
     * @return[zh-cn] 克隆的外部纹理实例

     * @brief[en] Return a new external texture instance with the same values as this instance
     * @return[en] Cloned external texture instance
     */
    public override func clone(): Texture {
        let t = ExternalTexture()
        return t.copy(this)
    }
}
