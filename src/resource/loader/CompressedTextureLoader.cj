/**
 * @file[zh-cn] CompressedTextureLoader 压缩纹理加载器
 * @brief[zh-cn] 加载 S3TC/ASTC/ETC 等压缩纹理
 * @explain[zh-cn] 压缩纹理加载器抽象基类，子类需实现 parse() 方法解析具体格式（如 DDS/KTX/PVR）。
 *
 * @file[en] CompressedTextureLoader  Compressed texture loader
 * @brief[en] Loads S3TC/ASTC/ETC compressed textures
 * @explain[en] Abstract base class for compressed texture loaders. Subclasses must implement parse() for specific formats (e.g., DDS/KTX/PVR).
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.utils.constants.*
import three.rendering.textures.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 压缩纹理加载器抽象基类，用于加载 S3TC、ASTC、ETC 等压缩纹理格式
 * @explain[zh-cn] 子类需实现 parse() 方法解析具体格式。
 *
 * @brief[en] Abstract base class for compressed texture loaders, for loading S3TC, ASTC, ETC compressed texture formats
 * @explain[en] Subclasses must implement parse() to parse specific formats.
 *
 * @extends Loader
 */
public open class CompressedTextureLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 纹理文件路径
     * @param[zh-cn] onLoad 加载完成回调
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Texture file path
     * @param[en] onLoad Load complete callback
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载压缩纹理
     * 使用 std.fs.File.readFrom 读取压缩纹理文件，调用 parse 解析，
     * 并将解析结果（width/height/format/mipmaps 等）应用到 CompressedTexture。
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        try {
            this.manager.itemStart(url)
            onProgress(0)

            let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
            let filePath = Path(fullPath)
            let bytes = File.readFrom(filePath)
            let total = bytes.size
            onProgress(total)

            
            let texData = this.parse(bytes, true)

            
            // texture.image = images; texture.format = texDatas.format; texture.needsUpdate = true;
            let width = _texDataInt(texData, "width", 0)
            let height = _texDataInt(texData, "height", 0)
            let format = _texDataInt(texData, "format", RGBAFormat)
            let compressedTexture = CompressedTexture(Array<UInt8>(), width, height, format: format)

            
            match (texData.get("mipmapCount")) {
                case Some(v) =>
                    match (v) {
                        case i: Int64 => if (i == 1) { compressedTexture.minFilter = LinearFilter }
                        case f: Float64 => if (Int64(f) == 1) { compressedTexture.minFilter = LinearFilter }
                        case _ => ()
                    }
                case None => ()
            }

            
            match (texData.get("mipmaps")) {
                case Some(v) =>
                    match (v) {
                        case list: ArrayList<Any> => compressedTexture.mipmaps = list
                        case _ => ()
                    }
                case None => ()
            }

            compressedTexture.needsUpdate = true

            this.manager.itemEnd(url)
            onLoad(compressedTexture)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @param[zh-cn] buffer 原始二进制数据
     * @param[zh-cn] isCubemap 是否为立方体贴图
     * @return[zh-cn] 纹理数据对象
     *
     * @param[en] buffer Raw binary data
     * @param[en] isCubemap Whether it is a cubemap
     * @return[en] Texture data object
     *
     * 解析二进制数据为纹理数据（子类实现）
     */
    public open func parse(buffer: Array<UInt8>, isCubemap: Bool): HashMap<String, Any> {
        return HashMap<String, Any>()
    }
}

// 从 texData HashMap 中读取整数值（兼容 Int64/Float64）
internal func _texDataInt(map: HashMap<String, Any>, key: String, defaultVal: Int64): Int64 {
    match (map.get(key)) {
        case Some(v) =>
            match (v) {
                case i: Int64 => return i
                case f: Float64 => return Int64(f)
                case _ => return defaultVal
            }
        case None => return defaultVal
    }
}