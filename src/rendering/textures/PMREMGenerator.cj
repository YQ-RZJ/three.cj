/**
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
