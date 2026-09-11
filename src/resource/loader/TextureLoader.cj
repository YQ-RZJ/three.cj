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
 * @file[zh-cn] TextureLoader 纹理加载器
 * @brief[zh-cn] 对应 Three.js loaders/TextureLoader.js，加载图片为纹理
 * @explain[zh-cn] JS 内部使用 ImageLoader 加载图片（浏览器解码为 Image）；仓颉侧 ImageLoader 已内置 bimg 解码为 RGBA8 Source，此处消费解码结果（data/width/height）填充 Texture。
 *
 * @file[en] TextureLoader  Texture loader
 * @brief[en] Loads images as textures
 * @explain[en] JS internally uses ImageLoader to load images (browser decodes to Image); Cangjie side ImageLoader has built-in bimg decoding to RGBA8 Source, here consuming the decoded result (data/width/height) to fill Texture.
 */
package three.resource.loader

import three.core.interfaces.ILoadResult
import three.rendering.textures.*
import std.fs.*
import std.io.*

/**
 * @brief[zh-cn] 纹理加载器，用于加载图片并创建 Texture 对象
 * @explain[zh-cn] 内部使用 ImageLoader（内置 bimg 解码），回调中把解码后的 RGBA8 像素（source.data）与宽高（source.width/height）写入 Texture。
 *
 * @brief[en] Texture loader, loads images and creates Texture objects
 * @explain[en] Internally uses ImageLoader (with built-in bimg decoding), filling decoded RGBA8 pixels (source.data) and dimensions (source.width/height) into Texture in the callback.
 *
 * @extends Loader
 */
public class TextureLoader <: Loader {
    public init(manager: LoadingManager) {
        super(manager: manager)
    }

    public init() {
        super()
    }

    /**
     * @brief[zh-cn] 开始加载纹理
     * @explain[zh-cn] 使用 ImageLoader 加载图片并解码，然后创建 Texture；仓颉侧 ImageLoader 内置 bimg 解码，回调中填充解码像素与尺寸。
     * @param[zh-cn] url 图片文件路径
     * onLoad 加载完成回调，参数为 Texture
     * onProgress 进度回调
     * onError 错误回调
     *
     * @brief[en] Start loading texture
     * @explain[en] Uses ImageLoader to load and decode images, then creates Texture. Cangjie side ImageLoader has built-in bimg decoding, filling decoded pixels and dimensions in the callback.
     * @param[en] url Image file path
     * onLoad Load complete callback, parameter is Texture
     * onProgress Progress callback
     * onError Error callback
     */
    public override func load(url: String, onLoad: (ILoadResult) -> Unit, onProgress: (Int64) -> Unit, onError: (String) -> Unit): Unit {
        
        let texture = Texture()

        
        //         loader.setCrossOrigin(this.crossOrigin);
        //         loader.setPath(this.path);
        //         loader.load(url, function(image) { texture.image = image; ... });
        let loader = ImageLoader(this.manager)
        loader.setCrossOrigin(this.crossOrigin)
        loader.setPath(this.path)

        loader.load(url, { image =>
            
            match (image) {
                case src: Source =>
                    texture.image = src.data
                    if (src.width > 0) { texture.width = src.width }
                    if (src.height > 0) { texture.height = src.height }
                case bytes: Array<UInt8> =>
                    texture.image = bytes
                case _ => ()
            }
            texture.needsUpdate = true
            onLoad(texture)
        }, onProgress, onError)
    }
}
