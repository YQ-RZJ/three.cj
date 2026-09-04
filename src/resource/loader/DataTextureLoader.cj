/**
 * @file[zh-cn] DataTextureLoader 数据纹理加载器
 * @brief[zh-cn] 加载 RGBE/EXR/TGA 等二进制纹理格式
 * @explain[zh-cn] 数据纹理加载器抽象基类，加载 RGBE、EXR、TGA 等二进制纹理格式。子类需实现 parse() 方法解析具体格式。
 *
 * @file[en] DataTextureLoader  Data texture loader
 * @brief[en] Loads RGBE/EXR/TGA binary texture formats
 * @explain[en] Abstract base class for data texture loaders, loading RGBE, EXR, TGA and other binary texture formats. Subclasses must implement parse() for specific formats.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.utils.constants.*
import three.rendering.textures.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 数据纹理加载器抽象基类，加载 RGBE、EXR、TGA 等二进制纹理格式
 * @explain[zh-cn] 子类需实现 parse() 方法解析具体格式。
 *
 * @brief[en] Abstract base class for data texture loaders, loading RGBE, EXR, TGA binary texture formats
 * @explain[en] Subclasses must implement parse() to parse specific formats.
 *
 * @extends Loader
 */
public open class DataTextureLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 纹理文件路径
     * @param[zh-cn] onLoad 加载完成回调，参数为 DataTexture
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Texture file path
     * @param[en] onLoad Load complete callback, parameter is DataTexture
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载数据纹理
     * 使用 std.fs.File.readFrom 读取二进制纹理文件，并调用 parse 解析，
     * 然后通过 _applyTexData 将解析结果应用到 DataTexture。
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

            
            let texData = this.parse(bytes)
            let texture = DataTexture(Array<UInt8>(), 0, 0)
            this._applyTexData(texture, texData)

            this.manager.itemEnd(url)
            onLoad(texture)
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }

    /**
     * @param[zh-cn] buffer 原始二进制数据
     * @return[zh-cn] 解析后的纹理数据
     *
     * @param[en] buffer Raw binary data
     * @return[en] Parsed texture data
     *
     * 解析二进制数据为纹理数据（子类实现）
     */
    public open func parse(buffer: Array<UInt8>): HashMap<String, Any> {
        return HashMap<String, Any>()
    }

    /**
     * @param[zh-cn] buffer 原始二进制数据
     * @return[zh-cn] DataTexture 对象
     *
     * @param[en] buffer Raw binary data
     * @return[en] DataTexture object
     *
     * 从内存中的二进制数据创建纹理
     */
    public func createDataTexture(buffer: Array<UInt8>): DataTexture {
        let texture = DataTexture(Array<UInt8>(), 0, 0)
        this._applyTexData(texture, this.parse(buffer))
        return texture
    }

    /**
     * @param[zh-cn] texture 目标 DataTexture
     * @param[zh-cn] texData 解析出的纹理数据（HashMap，子类 parse 返回）
     *
     * @param[en] texture Target DataTexture
     * @param[en] texData Parsed texture data (HashMap, returned by subclass parse)
     *
     * 将解析出的纹理数据应用到 DataTexture
     * 应用字段：image/data、width/height、wrapS/wrapT、magFilter/minFilter、
     * anisotropy、colorSpace、flipY、format、type、mipmaps、generateMipmaps
     */
    public func _applyTexData(texture: DataTexture, texData: HashMap<String, Any>): Unit {
        
        match (texData.get("image")) {
            case Some(v) =>
                match (v) {
                    case bytes: Array<UInt8> => texture.image = bytes
                    case hm: HashMap<String, Any> =>
                        match (hm.get("data")) {
                            case Some(d) => match (d) { case db: Array<UInt8> => texture.image = db; case _ => () }
                            case None => ()
                        }
                    case _ => ()
                }
            case None => ()
        }
        match (texData.get("data")) {
            case Some(v) =>
                match (v) {
                    case bytes: Array<UInt8> => texture.image = bytes
                    case _ => ()
                }
            case None => ()
        }

        // 宽高
        _setFromJsonInt(texData, "width", { v => texture.width = v })
        _setFromJsonInt(texData, "height", { v => texture.height = v })

        // 环绕/过滤
        _setFromJsonInt(texData, "wrapS", { v => texture.wrapS = v })
        _setFromJsonInt(texData, "wrapT", { v => texture.wrapT = v })
        _setFromJsonInt(texData, "magFilter", { v => texture.magFilter = v })
        _setFromJsonInt(texData, "minFilter", { v => texture.minFilter = v })
        _setFromJsonInt(texData, "anisotropy", { v => texture.anisotropy = v })
        _setFromJsonInt(texData, "format", { v => texture.format = v })
        _setFromJsonInt(texData, "type", { v => texture.`type` = v })

        // 颜色空间 / 翻转
        _setFromJsonStr(texData, "colorSpace", { v => texture.colorSpace = v })
        _setFromJsonBool(texData, "flipY", { v => texture.flipY = v })
        _setFromJsonBool(texData, "generateMipmaps", { v => texture.generateMipmaps = v })

        
        match (texData.get("mipmaps")) {
            case Some(v) =>
                match (v) {
                    case list: ArrayList<Any> =>
                        texture.mipmaps = list
                        texture.minFilter = LinearMipmapLinearFilter
                    case _ => ()
                }
            case None => ()
        }

        
        match (texData.get("mipmapCount")) {
            case Some(v) =>
                match (v) {
                    case i: Int64 => if (i == 1) { texture.minFilter = LinearFilter }
                    case _ => ()
                }
            case None => ()
        }

        texture.needsUpdate = true
    }
}

// ===== 数据读取辅助 =====

internal func _setFromJsonInt(map: HashMap<String, Any>, key: String, setter: (Int64) -> Unit): Unit {
    match (map.get(key)) {
        case Some(v) => match (v) { case i: Int64 => setter(i); case f: Float64 => setter(Int64(f)); case _ => () }
        case None => ()
    }
}

internal func _setFromJsonStr(map: HashMap<String, Any>, key: String, setter: (String) -> Unit): Unit {
    match (map.get(key)) {
        case Some(v) => match (v) { case s: String => setter(s); case _ => () }
        case None => ()
    }
}

internal func _setFromJsonBool(map: HashMap<String, Any>, key: String, setter: (Bool) -> Unit): Unit {
    match (map.get(key)) {
        case Some(v) => match (v) { case b: Bool => setter(b); case _ => () }
        case None => ()
    }
}