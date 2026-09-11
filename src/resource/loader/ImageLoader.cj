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
 * @file[zh-cn] ImageLoader 图片加载器
 * @brief[zh-cn] 用于加载图片资源
 * @explain[zh-cn] 仓颉侧无浏览器 Image 对象，使用 bgfx4cj.bimg 解码图片字节为 RGBA8，返回 Source（含 data/width/height）。支持 Cache 缓存、manager.resolveURL、path 拼接。
 *
 * @file[en] ImageLoader  Image loader
 * @brief[en] For loading image resources
 * @explain[en] Cangjie side has no browser Image object; uses bgfx4cj.bimg to decode image bytes to RGBA8, returning Source (with data/width/height). Supports Cache, manager.resolveURL, path concatenation.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.resource.cache.*
import three.rendering.textures.Source
import three.utils.log.Logger
import three.utils.memory.AutoFreePtr
import bgfx4cj.bimg.*
import std.collection.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 图片加载器，用于加载图片资源
 * @explain[zh-cn] 仓颉侧通过 bimg_image_parse_decode_cj 将图片字节解码为 RGBA8，返回 Source（data 为解码像素、width/height 为图像尺寸）。
 *
 * @brief[en] Image loader, for loading image resources
 * @explain[en] Cangjie side decodes image bytes to RGBA8 via bimg_image_parse_decode_cj, returning Source (data as decoded pixels, width/height as image dimensions).
 *
 * @extends Loader
 */
public class ImageLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @param[zh-cn] url 图片文件路径
     * @param[zh-cn] onLoad 加载完成回调，参数为 Source（data=RGBA8 像素、width/height 尺寸）
     * @param[zh-cn] onProgress 进度回调
     * @param[zh-cn] onError 错误回调
     *
     * @param[en] url Image file path
     * @param[en] onLoad Load complete callback, parameter is Source (data=RGBA8 pixels, width/height dimensions)
     * @param[en] onProgress Progress callback
     * @param[en] onError Error callback
     *
     * 开始加载图片
     * 使用 std.fs.File.readFrom 读取图片文件，并用 bimg 解码为 RGBA8
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        
        var resolvedUrl = url
        if (this.path != "") { resolvedUrl = this.path + resolvedUrl }

        
        resolvedUrl = this.manager.resolveURL(resolvedUrl)

        
        let cacheKey = "image:" + resolvedUrl
        let cached = Cache.get(cacheKey)

        
        if (cached.isSome()) {
            this.manager.itemStart(resolvedUrl)
            onLoad(cached.getOrThrow())
            this.manager.itemEnd(resolvedUrl)
            return
        }

        try {
            this.manager.itemStart(resolvedUrl)

            let bytes = File.readFrom(resolvedUrl)

            
            let source = _decodeImage(bytes)
            if (source.isNone()) {
                throw IOException("ImageLoader: 图片解码失败 " + resolvedUrl)
            }

            
            Cache.add(cacheKey, source.getOrThrow())

            this.manager.itemEnd(resolvedUrl)
            onLoad(source.getOrThrow())
        } catch (e: Exception) {
            
            Cache.remove(cacheKey)
            this.manager.itemError(resolvedUrl)
            this.manager.itemEnd(resolvedUrl)
            onError(e.toString())
        }
    }

    /**
     * @param[zh-cn] bytes 图片文件原始字节（PNG/JPEG/BMP/TGA 等）
     * @return[zh-cn] Option<Source>，解码失败返回 None
     *
     * @param[en] bytes Raw image file bytes (PNG/JPEG/BMP/TGA etc.)
     * @return[en] Option<Source>, returns None if decoding fails
     *
     * 内置 bimg 解码：将图片字节解码为 RGBA8 并构造 Source
     * 使用 bimg 调用范式（allocator → parse_decode → 读 ImageContainer → free）
     */
    private func _decodeImage(bytes: Array<UInt8>): Option<Source> {
        if (bytes.size == 0) { return None }
        let allocator = bimg_get_default_allocator_cj()
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(bytes.size)) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..bytes.size) { (dataPtr + i).write(bytes[i]) }
        }
        // 解析并解码图像到 RGBA8 格式 (67 = TextureFormat.RGBA8)
        let dstFormat: UInt32 = 67u32
        let ic = bimg_image_parse_decode_cj(allocator, unsafe { CPointer<Unit>(dataPtr) }, UInt32(bytes.size), dstFormat, CPointer<BimgError>())
        dataPtrHolder.dispose()
        if (ic.isNull()) {
            return None
        }
        let imgWidth = bimg_ic_get_width_cj(ic)
        let imgHeight = bimg_ic_get_height_cj(ic)
        let imgData = bimg_ic_get_data_cj(ic)
        let imgSize = bimg_ic_get_size_cj(ic)
        if (imgWidth == 0u32 || imgHeight == 0u32 || imgSize == 0u32) {
            bimg_image_free_cj(ic)
            return None
        }
        // 复制 RGBA 像素数据到仓颉数组
        let rgbaData = Array<UInt8>(Int64(imgSize), { i =>
            unsafe { (CPointer<UInt8>(imgData) + i).read() }
        })
        // 释放 ImageContainer
        bimg_image_free_cj(ic)
        return Some(Source(data: rgbaData, width: Int64(imgWidth), height: Int64(imgHeight)))
    }
}
