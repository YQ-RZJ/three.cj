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
 * @file[zh-cn] 立方体纹理
 * @brief[zh-cn] 由 6 张 2D 贴图组成的立方体贴图，用于环境反射、折射、天空盒等
 * @explain[zh-cn] 6 面对应 ±X/±Y/±Z 六面；mapping 默认 CubeReflectionMapping。flipY override 为 false（立方体贴图无需 Y 翻转）。

 * @file[en] Cube Texture
 * @brief[en] Cube map texture composed of 6 2D textures, used for environment reflection, refraction, skybox, etc.
 * @explain[en] 6 faces correspond to ±X/±Y/±Z; mapping defaults to CubeReflectionMapping. flipY is overridden to false (cube maps don't need Y flip). 
 */
package three.rendering.textures
import three.utils.constants.*
import std.math.*

/**
 * @brief[zh-cn] 立方体纹理类
 * @explain[zh-cn] 由 6 张 2D 贴图组成的立方体贴图，用于环境反射、折射、天空盒等。flipY 默认为 false。

 * @brief[en] Cube texture class
 * @explain[en] Cube map texture composed of 6 2D textures, used for environment reflection, refraction, skybox, etc. flipY defaults to false.
 */
public open class CubeTexture <: Texture {

    /**
     * @brief[zh-cn] 6 面像素数组，按 ±X/±Y/±Z 顺序

     * @brief[en] 6-face pixel arrays, in ±X/±Y/±Z order
     */
    public var images: Array<Array<UInt8>>

    /**
     * @brief[zh-cn] 构造一个新的立方体纹理
     * @param[zh-cn] images 6 面像素数组，按 ±X/±Y/±Z 顺序
     * mapping UV 映射模式，默认 CubeReflectionMapping
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 LinearFilter
     * minFilter 缩小过滤器，默认 LinearMipmapLinearFilter
     * format 像素格式，默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * anisotropy 各向异性等级，默认 1
     * colorSpace 颜色空间，默认空

     * @brief[en] Construct a new cube texture
     * @param[en] images 6-face pixel arrays, in ±X/±Y/±Z order
     * mapping UV mapping mode, defaults to CubeReflectionMapping
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to LinearFilter
     * minFilter Minification filter, defaults to LinearMipmapLinearFilter
     * format Pixel format, defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * anisotropy Anisotropy level, defaults to 1
     * colorSpace Color space, defaults to empty
     */
    public init(images!: Array<Array<UInt8>> = Array<Array<UInt8>>(), mapping!: Int64 = CubeReflectionMapping, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "") {
        super(image: Array<UInt8>(), mapping: mapping, wrapS: wrapS, wrapT: wrapT, magFilter: magFilter, minFilter: minFilter, format: format, `type`: `type`, anisotropy: anisotropy, colorSpace: colorSpace)
        this.kind = "CubeTexture"
        this.flipY = false
        // 保存 6 面像素数据（CubeTexturePass 上传 bgfx cube 纹理用）
        this.images = images
        if (images.size >= 6) {
            // 从第 0 面推导尺寸（RGBA 4 字节/像素）
            let faceSize = images[0].size / 4
            let side = Int64(sqrt(Float64(faceSize)))
            this.width = side
            this.height = side
        }
    }
}
