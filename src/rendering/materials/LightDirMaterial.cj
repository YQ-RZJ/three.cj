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
 * @file[zh-cn] 光源方向N·L可视化材质
 * @brief[zh-cn] 光源方向N·L可视化材质（bgfx4cj扩展），将N·L映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将 N·L 直接映射为灰度：朝光面=白、背光面=黑、半角度=灰，无环境光。
 * 用于 debug mode 4：验证方向光 u_lightDir0 是否正确传递。
 * 关联 ShaderLibs 程序名 "lightdir"。
 *
 * @file[en] Light Direction N·L Visualization Material
 * @brief[en] Light direction N·L visualization material (bgfx4cj extension), maps N·L to grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps N·L directly to grayscale: lit face=white, shadow face=black, half angle=gray, no ambient.
 * Used in debug mode 4 to verify that directional light u_lightDir0 is correctly passed.
 * Associated ShaderLibs program name "lightdir".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 光源方向N·L可视化材质，将N·L映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将 N·L 直接映射为灰度：朝光面=白、背光面=黑、半角度=灰，无环境光。
 * 用于 debug mode 4：验证方向光 u_lightDir0 是否正确传递。
 *
 * @brief[en] Light direction N·L visualization material, maps N·L to grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps N·L directly to grayscale: lit face=white, shadow face=black, half angle=gray, no ambient.
 * Used in debug mode 4 to verify that directional light u_lightDir0 is correctly passed.
 */
public class LightDirMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的光源方向可视化材质
     *
     * @brief[en] Construct a new light direction visualization material
     */
    public init() {
        super()
        this.kind = "LightDirMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定LightDirMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given LightDirMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: LightDirMaterial): LightDirMaterial {
        super.copy(source)
        return this
    }
}
