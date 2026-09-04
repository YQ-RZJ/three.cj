/**
 * @file[zh-cn] CubeTextureLoader 立方体贴图加载器
 * @brief[zh-cn] 加载 6 面立方体贴图
 * @explain[zh-cn] 加载 6 张图片组成立方体贴图，顺序：pos-x, neg-x, pos-y, neg-y, pos-z, neg-z。
 *
 * @file[en] CubeTextureLoader  Cube texture loader
 * @brief[en] Loads 6-face cube textures
 * @explain[en] Loads 6 images to form a cube texture map, order: pos-x, neg-x, pos-y, neg-y, pos-z, neg-z.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.utils.constants.*
import three.rendering.textures.*
import std.fs.*
import std.io.*
import std.collection.*

/**
 * @brief[zh-cn] 立方体贴图加载器，加载 6 张图片组成立方体贴图
 * @explain[zh-cn] 顺序：pos-x, neg-x, pos-y, neg-y, pos-z, neg-z
 *
 * @brief[en] Cube texture loader, loads 6 images to form a cube texture
 * @explain[en] Order: pos-x, neg-x, pos-y, neg-y, pos-z, neg-z
 *
 * @extends Loader
 */
public class CubeTextureLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] urls 6 个面的文件路径数组（顺序：pos-x, neg-x, pos-y, neg-y, pos-z, neg-z）
     * @param[zh-cn] onLoad 加载完成回调，参数为 CubeTexture
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     * @return[zh-cn] CubeTexture 对象
     *
     * @param[en] urls Array of 6 face file paths (order: pos-x, neg-x, pos-y, neg-y, pos-z, neg-z)
     * @param[en] onLoad Load complete callback, parameter is CubeTexture
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     * @return[en] CubeTexture object
     *
     * 开始加载立方体贴图
     * 使用 std.fs.File.readFrom 读取 6 面图片文件，全部 6 面加载完成后
     * 以 images 数组构造 CubeTexture。
     */
    public func load(urls: Array<String>, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): CubeTexture {
        
        let images = ArrayList<Array<UInt8>>()

        for (i in 0..urls.size) {
            try {
                let url = urls[i]
                let fullPath = if (this.path != "") { this.path + "/" + url } else { url }
                let filePath = Path(fullPath)
                let bytes = File.readFrom(filePath)
                images.add(bytes)
                onProgress(i + 1)
            } catch (e: Exception) {
                this.manager.itemError(urls[i])
                onError(e.toString())
                return CubeTexture(images: Array<Array<UInt8>>())
            }
        }

        
        let texture = CubeTexture(images: images.toArray())
        texture.colorSpace = SRGBColorSpace
        texture.needsUpdate = true
        onLoad(texture)
        return texture
    }
}