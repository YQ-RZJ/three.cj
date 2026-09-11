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
 * @file[zh-cn] 压缩立方体纹理
 * @brief[zh-cn] 立方体贴图的压缩格式版本，6 面对应 ±X/±Y/±Z 六面
 * @explain[zh-cn] 压缩立方体纹理：立方体贴图的压缩格式版本，6 面对应 ±X/±Y/±Z 六面。继承 CompressedTexture。默认 mapping=CubeReflectionMapping、flipY=false。

 * @file[en] Compressed Cube Texture
 * @brief[en] Compressed format version of cube map texture, 6 faces correspond to ±X/±Y/±Z
 * @explain[en] Compressed cube texture: compressed format version of cube map texture, 6 faces correspond to ±X/±Y/±Z. Extends CompressedTexture. Defaults mapping=CubeReflectionMapping, flipY=false. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 压缩立方体纹理类
 * @explain[zh-cn] 立方体贴图的压缩格式版本，6 面对应 ±X/±Y/±Z 六面。默认 mapping=CubeReflectionMapping、flipY=false。

 * @brief[en] Compressed cube texture class
 * @explain[en] Compressed format version of cube map texture, 6 faces correspond to ±X/±Y/±Z. Defaults mapping=CubeReflectionMapping, flipY=false.
 */
public open class CompressedCubeTexture <: CompressedTexture {

    /**
     * @brief[zh-cn] 构造一个新的压缩立方体纹理
     * @param[zh-cn] images 6 面压缩像素数组，按 ±X/±Y/±Z 顺序
     * width 单面宽度（像素）
     * height 单面高度（像素）
     * format 像素格式（压缩格式枚举），默认 RGBAFormat

     * @brief[en] Construct a new compressed cube texture
     * @param[en] images 6-face compressed pixel arrays, in ±X/±Y/±Z order
     * width Single face width in pixels
     * height Single face height in pixels
     * format Pixel format (compressed format enum), defaults to RGBAFormat
     */
    public init(images: Array<Array<UInt8>>, width: Int64, height: Int64, format!: Int64 = RGBAFormat) {
        super(Array<UInt8>(), width, height, format: format, mapping: CubeReflectionMapping)
        this.kind = "CompressedCubeTexture"
        this.flipY = false
        this.generateMipmaps = false
        this.unpackAlignment = 1
    }
}
