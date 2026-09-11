/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
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