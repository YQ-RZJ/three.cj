/**
 * @file[zh-cn] FontLoader 字体加载器
 * @brief[zh-cn] 对应 Three.js loaders/FontLoader.js 的仓颉侧实现，加载 JSON 格式字体数据
 * @explain[zh-cn] 使用 std.fs 从本地文件系统加载 JSON 格式字体文件，主要供 TextGeometry 使用。
 *
 * @file[en] FontLoader  Font loader
 * @brief[en] Cangjie implementation corresponding to Three.js loaders/FontLoader.js, loads JSON-format font data
 * @explain[en] Loads JSON-format font files from the local file system using std.fs, primarily for TextGeometry usage.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 字体加载器，加载 JSON 格式的字体文件
 * @explain[zh-cn] 用于加载 Typeface.js 格式的字体数据，主要供 TextGeometry 使用。从本地文件系统读取 JSON 格式字体文件，返回 JSON 字符串。
 *
 * @brief[en] Font loader, loads JSON-format font files
 * @explain[en] Used to load Typeface.js format font data, primarily for TextGeometry. Reads JSON-format font files from the local file system, returning JSON strings.
 *
 * @extends Loader
 */
public class FontLoader <: Loader {
    public init(manager!: LoadingManager = LoadingManager()) {
        super(manager: manager)
    }

    /**
     * @param[zh-cn] url 字体文件路径
     * @param[zh-cn] onLoad 加载完成回调，参数为 JSON 字符串
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Font file path
     * @param[en] onLoad Load complete callback, parameter is JSON string
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载字体
     * 使用 std.fs.File.readFrom 读取字体 JSON 文件
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

            let jsonStr = String.fromUtf8(bytes)

            this.manager.itemEnd(url)
            onLoad(StringLoadResult(jsonStr))
        } catch (e: Exception) {
            this.manager.itemError(url)
            onError(e.toString())
        }
    }
}