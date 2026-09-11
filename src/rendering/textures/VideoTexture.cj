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
 * @file[zh-cn] Video 纹理
 * @brief[zh-cn] 由 HTMLVideoElement 构造的纹理，每次 requestVideoFrameCallback 回调时重传 GPU
 * @explain[zh-cn] Video 纹理：由 HTMLVideoElement 构造的纹理，每次 requestVideoFrameCallback 回调时重传 GPU。bgfx4cj 跨平台后端无 DOM video API，本类保留接口签名以对齐 JS side，实际像素数据由调用方通过 image 字段直接传入。默认 generateMipmaps=false、flipY=false、minFilter=LinearFilter。

 * @file[en] Video Texture
 * @brief[en] Texture constructed from HTMLVideoElement, re-uploaded to GPU on each requestVideoFrameCallback
 * @explain[en] Video texture: texture constructed from HTMLVideoElement, re-uploaded to GPU on each requestVideoFrameCallback. bgfx4cj cross-platform backend has no DOM video API, this class preserves interface signature to align with JS side, actual pixel data is passed directly by callers via image field. Defaults generateMipmaps=false, flipY=false, minFilter=LinearFilter. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] Video 纹理类
 * @explain[zh-cn] 由 HTMLVideoElement 构造的纹理，默认 generateMipmaps=false、flipY=false、minFilter=LinearFilter。bgfx4cj 后端无 DOM video API，像素数据由调用方通过 image 字段直接传入。

 * @brief[en] Video texture class
 * @explain[en] Texture constructed from HTMLVideoElement, defaults generateMipmaps=false, flipY=false, minFilter=LinearFilter. bgfx4cj backend has no DOM video API, pixel data is passed directly by callers via image field.
 */
public open class VideoTexture <: Texture {

    /**
     * @brief[zh-cn] 构造一个新的 Video 纹理
     * @param[zh-cn] video Video 像素数据
     * mapping UV 映射模式，默认 UVMapping
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 LinearFilter
     * minFilter 缩小过滤器，默认 LinearFilter
     * format 像素格式，默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * anisotropy 各向异性等级，默认 1

     * @brief[en] Construct a new Video texture
     * @param[en] video Video pixel data
     * mapping UV mapping mode, defaults to UVMapping
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to LinearFilter
     * minFilter Minification filter, defaults to LinearFilter
     * format Pixel format, defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * anisotropy Anisotropy level, defaults to 1
     */
    public init(video: Array<UInt8>, mapping!: Int64 = UVMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1) {
        super(image: video, mapping: mapping, wrapS: wrapS, wrapT: wrapT, magFilter: magFilter, minFilter: minFilter, format: format, `type`: `type`, anisotropy: anisotropy)
        this.kind = "VideoTexture"
        this.generateMipmaps = false
        this.flipY = false
        this.minFilter = LinearFilter
    }

    /**
     * @brief[zh-cn] 更新纹理内容，bgfx4cj 下为 stub（像素数据由调用方通过 image 字段直接传入）

     * @brief[en] Update texture content, stub under bgfx4cj (pixel data passed directly by callers via image field)
     */
    public func update(): Unit {
        this.version += 1
        this.needsUpdate = true
    }

    /**
     * @brief[zh-cn] 释放本实例分配的 GPU 相关资源

     * @brief[en] Release GPU-related resources allocated by this instance
     */
    public override func dispose(): Unit {
        super.dispose()
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新 Video 纹理实例
     * @return[zh-cn] 克隆的 Video 纹理实例

     * @brief[en] Return a new Video texture instance with the same values as this instance
     * @return[en] Cloned Video texture instance
     */
    public open override func clone(): Texture {
        let t = VideoTexture(this.image)
        return t.copy(this)
    }
}
