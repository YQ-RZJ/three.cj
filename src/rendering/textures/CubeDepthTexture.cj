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
 * @file[zh-cn] 立方体深度纹理
 * @brief[zh-cn] 立方体贴图格式的深度纹理，6 面对应 ±X/±Y/±Z 六面深度
 * @explain[zh-cn] 立方体深度纹理：立方体贴图格式的深度纹理，6 面对应 ±X/±Y/±Z 六面深度。继承 DepthTexture。默认 format=DepthFormat、mapping=CubeReflectionMapping、generateMipmaps=false、flipY=false。

 * @file[en] Cube Depth Texture
 * @brief[en] Cube map format depth texture, 6 faces correspond to ±X/±Y/±Z depth
 * @explain[en] Cube depth texture: cube map format depth texture, 6 faces correspond to ±X/±Y/±Z depth. Extends DepthTexture. Defaults format=DepthFormat, mapping=CubeReflectionMapping, generateMipmaps=false, flipY=false. 
 */
package three.rendering.textures
import three.utils.constants.*

/**
 * @brief[zh-cn] 立方体深度纹理类
 * @explain[zh-cn] 立方体贴图格式的深度纹理，继承 DepthTexture，默认 mapping=CubeReflectionMapping。

 * @brief[en] Cube depth texture class
 * @explain[en] Cube map format depth texture, extends DepthTexture, defaults mapping=CubeReflectionMapping.
 */
public open class CubeDepthTexture <: DepthTexture {

    /**
     * @brief[zh-cn] 构造一个新的立方体深度纹理
     * @param[zh-cn] width 单面宽度（像素）
     * height 单面高度（像素）

     * @brief[en] Construct a new cube depth texture
     * @param[en] width Single face width in pixels
     * height Single face height in pixels
     */
    public init(width: Int64, height: Int64) {
        super(width, height)
        this.kind = "CubeDepthTexture"
        this.mapping = CubeReflectionMapping
    }
}
