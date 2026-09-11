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
 * @file[zh-cn] 深度图灰度可视化材质
 * @brief[zh-cn] 深度图灰度可视化材质（bgfx4cj扩展），将线性深度归一化映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将线性深度归一化映射为灰度：近=白、远=黑。
 * 用于 debug mode 1：直观验证场景深度分布是否正确。
 * 关联 ShaderLibs 程序名 "depthviz"（BgfxBackend._getOrCreateProgram 按 kind 映射）。
 *
 * @file[en] Depth Visualization Material
 * @brief[en] Depth visualization material (bgfx4cj extension), maps linear depth to grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps linear depth to normalized grayscale: near=white, far=black.
 * Used in debug mode 1 to visually verify scene depth distribution correctness.
 * Associated ShaderLibs program name "depthviz" (BgfxBackend._getOrCreateProgram maps by kind).
 */
package three.rendering.materials

/**
 * @brief[zh-cn] 深度图灰度可视化材质，将线性深度归一化映射为灰度
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。将线性深度归一化映射为灰度：近=白、远=黑。
 * 用于 debug mode 1：直观验证场景深度分布是否正确。
 *
 * @brief[en] Depth visualization material, maps linear depth to normalized grayscale
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Maps linear depth to normalized grayscale: near=white, far=black.
 * Used in debug mode 1 to visually verify scene depth distribution correctness.
 */
public class DepthVizMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的深度图灰度可视化材质
     *
     * @brief[en] Construct a new depth visualization material
     */
    public init() {
        super()
        this.kind = "DepthVizMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定DepthVizMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given DepthVizMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: DepthVizMaterial): DepthVizMaterial {
        super.copy(source)
        return this
    }
}
