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
 * @file[zh-cn] Framebuffer 纹理
 * @brief[zh-cn] 渲染目标某附属（color/depth/stencil）的纹理封装
 * @explain[zh-cn] Framebuffer 纹理：渲染目标某附属（color/depth/stencil）的纹理封装。渲染器内部按 framebuffer 附属配置自动设置纹理参数；用户无需手动上传数据。默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false。

 * @file[en] Framebuffer Texture
 * @brief[en] Texture encapsulation for a render target attachment (color/depth/stencil)
 * @explain[en] Framebuffer texture: texture encapsulation for a render target attachment (color/depth/stencil). The renderer automatically sets texture parameters based on framebuffer attachment configuration; users do not need to manually upload data. Defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] Framebuffer 纹理类
 * @explain[zh-cn] 渲染目标附属的纹理封装，默认 magFilter/minFilter=NearestFilter、generateMipmaps=false、flipY=false。

 * @brief[en] Framebuffer texture class
 * @explain[en] Texture encapsulation for render target attachment, defaults magFilter/minFilter=NearestFilter, generateMipmaps=false, flipY=false.
 */
public open class FramebufferTexture <: Texture {

    /**
     * @brief[zh-cn] 构造一个新的 Framebuffer 纹理
     * @param[zh-cn] width 纹理宽度（像素）
     * height 纹理高度（像素）
     * format 像素格式，默认 RGBAFormat

     * @brief[en] Construct a new Framebuffer texture
     * @param[en] width Texture width in pixels
     * height Texture height in pixels
     * format Pixel format, defaults to RGBAFormat
     */
    public init(width: Int64, height: Int64, format!: Int64 = RGBAFormat) {
        super(image: Array<UInt8>(), width: width, height: height, format: format)
        this.kind = "FramebufferTexture"
        this.magFilter = NearestFilter
        this.minFilter = NearestFilter
        this.generateMipmaps = false
        this.flipY = false
        this.unpackAlignment = 1
        this._needsUpdateFlag = true
    }
}
