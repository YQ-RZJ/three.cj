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
 * @file[zh-cn] PMREM 生成器
 * @brief[zh-cn] PMREMGenerator 预过滤 Mipmap 环境贴图生成器
 * @explain[zh-cn] PMREMGenerator 用于从场景生成预过滤 Mipmap 环境贴图。仓颉侧 scenes 包与 extras 存在循环依赖，经 interfaces 包 IScene 接口持有。

 * @file[en] PMREM Generator
 * @brief[en] PMREMGenerator pre-filtered mipmap environment map generator
 * @explain[en] PMREMGenerator is used to generate pre-filtered mipmap environment maps from scenes. Cangjie side scenes package and extras have circular dependency, held via interfaces package IScene interface. 
 */
package three.rendering.textures

import three.scene.interfaces.IScene

/**
 * @brief[zh-cn] PMREM 生成器类
 * @explain[zh-cn] 预过滤 Mipmap 环境贴图生成器，从场景生成环境贴图。

 * @brief[en] PMREM generator class
 * @explain[en] Pre-filtered mipmap environment map generator, generates environment maps from scenes.
 */
public class PMREMGenerator {
    /**
     * @brief[zh-cn] 类型标签

     * @brief[en] Type tag
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造 PMREM 生成器

     * @brief[en] Construct PMREM generator
     */
    public init() { this.kind = "PMREMGenerator" }

    /**
     * @brief[zh-cn] 从场景生成预过滤 Mipmap 环境贴图
     * @param[zh-cn] scene 场景接口
     * sigma 模糊强度
     * near 近裁剪面
     * far 远裁剪面
     * @return[zh-cn] 生成的环境贴图

     * @brief[en] Generate pre-filtered mipmap environment map from scene
     * @param[en] scene Scene interface
     * sigma Blur strength
     * near Near clipping plane
     * far Far clipping plane
     * @return[en] Generated environment map
     */
    public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Any { return 0 }
}
