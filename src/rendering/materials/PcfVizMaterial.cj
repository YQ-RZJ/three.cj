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
 * @file[zh-cn] PCF采样结果可视化材质
 * @brief[zh-cn] PCF采样结果可视化材质（bgfx4cj扩展），输出黑白二值阴影检测结果
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。绑定 shadowMap + shadowMatrix，3x3 PCF 采样后输出黑白二值
 * （在阴影中=黑、不在=白），超出阴影 UV 范围输出红，提示阴影矩阵边界问题。
 * 用于 debug mode 8：验证 shadowMap 是否生成、PCF 采样坐标是否正确。
 * 关联 ShaderLibs 程序名 "pcf"。
 *
 * @file[en] PCF Visualization Material
 * @brief[en] PCF sampling visualization material (bgfx4cj extension), outputs black/white binary shadow detection result
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Binds shadowMap + shadowMatrix, performs 3x3 PCF sampling and outputs black/white binary
 * (in shadow=black, not in shadow=white), outputs red outside shadow UV range to indicate shadow matrix boundary issues.
 * Used in debug mode 8 to verify shadowMap generation and PCF sampling coordinate correctness.
 * Associated ShaderLibs program name "pcf".
 */
package three.rendering.materials

/**
 * @brief[zh-cn] PCF采样结果可视化材质，输出黑白二值阴影检测结果
 * @explain[zh-cn] 
 * 对应 Three.js 无（bgfx4cj 扩展）。3x3 PCF 采样后输出黑白二值。
 * 用于 debug mode 8：验证 shadowMap 是否生成、PCF 采样坐标是否正确。
 *
 * @brief[en] PCF sampling visualization material, outputs black/white binary shadow detection result
 * @explain[en] 
 * No Three.js counterpart (bgfx4cj extension). Outputs black/white binary after 3x3 PCF sampling.
 * Used in debug mode 8 to verify shadowMap generation and PCF sampling coordinate correctness.
 */
public class PcfVizMaterial <: Material {
    /**
     * @brief[zh-cn] 构造一个新的PCF可视化材质
     *
     * @brief[en] Construct a new PCF visualization material
     */
    public init() {
        super()
        this.kind = "PcfVizMaterial"
        this.transparent = false
    }

    /**
     * @brief[zh-cn] 将给定PcfVizMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given PcfVizMaterial to this instance
     * @param[en] source Source material
     * @return[en] This instance
     */
    public func copy(source: PcfVizMaterial): PcfVizMaterial {
        super.copy(source)
        return this
    }
}
