/**
 * @file[zh-cn] Canvas 纹理
 * @brief[zh-cn] 由像素内存缓冲区构造的纹理，支持通过 update() 持续更新内容
 * @explain[zh-cn] Canvas 纹理：由像素内存缓冲区构造的纹理，支持通过 update() 持续更新内容。调用方可直接修改 this.image 数组内容后调用 update()，渲染器自动重传 GPU。无 DOM Canvas 时，由原生侧写入像素数据到 image 实现帧更新。

 * @file[en] Canvas Texture
 * @brief[en] Texture constructed from pixel memory buffer, supports continuous content update via update()
 * @explain[en] Canvas texture: texture constructed from pixel memory buffer, supports continuous content update via update(). Callers can directly modify this.image array content and call update(), the renderer automatically re-uploads to GPU. Without DOM Canvas, native side writes pixel data to image for frame updates. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] Canvas 纹理类
 * @explain[zh-cn] 由像素内存缓冲区构造的纹理，继承自 Texture，默认 needsUpdate=true。

 * @brief[en] Canvas texture class
 * @explain[en] Texture constructed from pixel memory buffer, extends Texture, defaults needsUpdate=true.
 */
public open class CanvasTexture <: Texture {

    /**
     * @brief[zh-cn] 构造一个新的 Canvas 纹理
     * @param[zh-cn] canvas 像素内存数据
     * width 纹理宽度（像素）
     * height 纹理高度（像素）
     * mapping UV 映射模式，默认 UVMapping
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 LinearFilter
     * minFilter 缩小过滤器，默认 LinearMipmapLinearFilter
     * format 像素格式，默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * anisotropy 各向异性等级，默认 1

     * @brief[en] Construct a new Canvas texture
     * @param[en] canvas Pixel memory data
     * width Texture width in pixels
     * height Texture height in pixels
     * mapping UV mapping mode, defaults to UVMapping
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to LinearFilter
     * minFilter Minification filter, defaults to LinearMipmapLinearFilter
     * format Pixel format, defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * anisotropy Anisotropy level, defaults to 1
     */
    public init(canvas: Array<UInt8>, width: Int64, height: Int64, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1) {
        super(image: canvas, width: width, height: height, mapping: mapping, wrapS: wrapS, wrapT: wrapT, magFilter: magFilter, minFilter: minFilter, format: format, `type`: `type`, anisotropy: anisotropy)
        this.kind = "CanvasTexture"
        this._needsUpdateFlag = true
    }

    /**
     * @brief[zh-cn] 更新纹理内容，渲染器下一帧重传 GPU

     * @brief[en] Update texture content, renderer re-uploads to GPU on next frame
     */
    public func update(): Unit {
        this.needsUpdate = true
    }
}
