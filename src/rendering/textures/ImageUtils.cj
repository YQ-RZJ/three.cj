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
 * @file[zh-cn] 图像工具函数
 * @brief[zh-cn] 对应 Three.js extras/ImageUtils.js，提供图像数据 URI 获取与 sRGB→Linear 转换
 * @explain[zh-cn] 仓颉侧无 DOM/HTMLCanvas，相关分支已裁剪为纯数据操作；保留接口与 JS 对齐。

 * @file[en] Image Utilities
 * @brief[en] Corresponding to Three.js extras/ImageUtils.js, provides image data URI retrieval and sRGB→Linear conversion
 * @explain[en] Cangjie side has no DOM/HTMLCanvas, related branches are trimmed to pure data operations; preserves interface alignment with JS. 
 */
package three.rendering.textures

import std.collection.*
import three.core.math.*

/**
 * @brief[zh-cn] 图像工具类
 * @explain[zh-cn] 提供 Image → data URI、sRGB → Linear 颜色空间转换等静态方法。仓颉侧无浏览器 DOM，本类仅保留与 Three.js 接口一致的方法签名，内部实现以像素数组操作替代 Canvas/ImageData。

 * @brief[en] Image utilities class
 * @explain[en] Provides static methods for Image → data URI, sRGB → Linear color space conversion, etc. Cangjie side has no browser DOM, this class only preserves method signatures consistent with Three.js, internal implementation uses pixel array operations instead of Canvas/ImageData.
 */
public class ImageUtils {
    /**
     * @brief[zh-cn] 返回图像的 data URI 字符串
     * @param[zh-cn] image 图像的字节数据（仓颉侧替代 HTMLImageElement）
     * type MIME 类型，默认 "image/png"
     * @return[zh-cn] data URI 字符串（仓颉侧返回空字符串占位）

     * @brief[en] Return the data URI string of the image
     * @param[en] image Image byte data (Cangjie side replacement for HTMLImageElement)
     * type MIME type, defaults to "image/png"
     * @return[en] Data URI string (Cangjie side returns empty string as placeholder)
     */
    public static func getDataURL(image: Array<UInt8>, `type`: String): String {
        return ""
    }

    /**
     * @brief[zh-cn] 缺省类型为 image/png 的便捷重载
     * @param[zh-cn] image 图像的字节数据
     * @return[zh-cn] data URI 字符串

     * @brief[en] Convenience overload with default type image/png
     * @param[en] image Image byte data
     * @return[en] Data URI string
     */
    public static func getDataURL(image: Array<UInt8>): String {
        return ImageUtils.getDataURL(image, "image/png")
    }

    /**
     * @brief[zh-cn] 将 sRGB 颜色空间的图像数据转换为 Linear 颜色空间
     * @param[zh-cn] image RGBA 字节序列（length = width*height*4）
     * @return[zh-cn] 转换后的新字节数组（不修改入参）

     * @brief[en] Convert image data from sRGB color space to Linear color space
     * @param[en] image RGBA byte sequence (length = width*height*4)
     * @return[en] New byte array after conversion (does not modify input)
     */
    public static func sRGBToLinear(image: Array<UInt8>): Array<UInt8> {
        let out = Array<UInt8>(image.size, { _ => 0 })
        for (i in 0..image.size) {
            let linear = ColorManagement.sRGBToLinear(Float64(image[i]) / 255.0) * 255.0
            // 使用截断到整数，避免越界
            let v = if (linear <= 0.0) { 0 } else if (linear >= 255.0) { 255 } else { Int64(linear) }
            out[i] = UInt8(v)
        }
        return out
    }
}
