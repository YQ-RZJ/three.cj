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
 * @file[zh-cn] GltfTypes
 * @brief[zh-cn] glTF 解析中间数据类型
 * @explain[zh-cn] 存储 GltfLoader 解析出的 skins/animations 中间数据结构。
 *                  独立于 GltfLoader 以避免循环依赖（offline/glTFImportAdapter 可直接导入本包）。
 *
 * @file[en] GltfTypes
 * @brief[en] glTF intermediate data types
 * @explain[en] Stores intermediate data structures parsed from glTF skins/animations.
 *              Separate from GltfLoader to avoid circular dependencies
 *              (offline/glTFImportAdapter can directly import this package).
 */
package three.resource.loader

/**
 * @brief[zh-cn] glTF Animation Channel 解析结果
 *
 * @brief[en] Parsed glTF Animation Channel
 */
public class GltfAnimationChannel {
    /**
     * @brief[zh-cn] 采样器索引
     *
     * @brief[en] Sampler index
     */
    public let sampler: Int

    /**
     * @brief[zh-cn] 目标节点索引
     *
     * @brief[en] Target node index
     */
    public let targetNode: Int

    /**
     * @brief[zh-cn] 目标属性路径（translation/rotation/scale）
     *
     * @brief[en] Target property path (translation/rotation/scale)
     */
    public let targetPath: String

    /**
     * @brief[zh-cn] 创建 Animation Channel
     * @param[zh-cn] sampler 采样器索引
     * @param[zh-cn] targetNode 目标节点索引
     * @param[zh-cn] targetPath 目标属性路径
     *
     * @brief[en] Create an Animation Channel
     * @param[en] sampler Sampler index
     * @param[en] targetNode Target node index
     * @param[en] targetPath Target property path
     */
    public init(sampler: Int, targetNode: Int, targetPath: String) {
        this.sampler = sampler
        this.targetNode = targetNode
        this.targetPath = targetPath
    }
}

/**
 * @brief[zh-cn] glTF Animation Sampler 解析结果
 *
 * @brief[en] Parsed glTF Animation Sampler
 */
public class GltfAnimationSampler {
    /**
     * @brief[zh-cn] 时间输入 accessor 索引
     *
     * @brief[en] Time input accessor index
     */
    public let input: Int

    /**
     * @brief[zh-cn] 值输出 accessor 索引
     *
     * @brief[en] Value output accessor index
     */
    public let output: Int

    /**
     * @brief[zh-cn] 插值方式（LINEAR/STEP/CUBICSPLINE）
     *
     * @brief[en] Interpolation mode (LINEAR/STEP/CUBICSPLINE)
     */
    public let interpolation: String

    /**
     * @brief[zh-cn] 创建 Animation Sampler
     * @param[zh-cn] input 时间输入 accessor 索引
     * @param[zh-cn] output 值输出 accessor 索引
     * @param[zh-cn] interpolation 插值方式
     *
     * @brief[en] Create an Animation Sampler
     * @param[en] input Time input accessor index
     * @param[en] output Value output accessor index
     * @param[en] interpolation Interpolation mode
     */
    public init(input: Int, output: Int, interpolation: String) {
        this.input = input
        this.output = output
        this.interpolation = interpolation
    }
}

/**
 * @brief[zh-cn] glTF Animation 解析结果
 *
 * @brief[en] Parsed glTF Animation
 */
public class GltfAnimationData {
    /**
     * @brief[zh-cn] 动画名称
     *
     * @brief[en] Animation name
     */
    public let name: String

    /**
     * @brief[zh-cn] 动画通道列表
     *
     * @brief[en] Animation channel list
     */
    public let channels: Array<GltfAnimationChannel>

    /**
     * @brief[zh-cn] 动画采样器列表
     *
     * @brief[en] Animation sampler list
     */
    public let samplers: Array<GltfAnimationSampler>

    /**
     * @brief[zh-cn] 创建 Animation 数据
     * @param[zh-cn] name 动画名称
     * @param[zh-cn] channels 动画通道列表
     * @param[zh-cn] samplers 动画采样器列表
     *
     * @brief[en] Create Animation data
     * @param[en] name Animation name
     * @param[en] channels Animation channel list
     * @param[en] samplers Animation sampler list
     */
    public init(name: String, channels: Array<GltfAnimationChannel>, samplers: Array<GltfAnimationSampler>) {
        this.name = name
        this.channels = channels
        this.samplers = samplers
    }
}

/**
 * @brief[zh-cn] glTF Skin 解析结果
 *
 * @brief[en] Parsed glTF Skin
 */
public class GltfSkinData {
    /**
     * @brief[zh-cn] 蒙皮名称
     *
     * @brief[en] Skin name
     */
    public let name: String

    /**
     * @brief[zh-cn] 逆绑定矩阵列表
     *
     * @brief[en] Inverse bind matrix list
     */
    public let inverseBindMatrices: Array<Array<Float64>>

    /**
     * @brief[zh-cn] 骨骼根节点索引
     *
     * @brief[en] Skeleton root node index
     */
    public let skeletonRoot: Int

    /**
     * @brief[zh-cn] 关节节点索引列表
     *
     * @brief[en] Joint node index list
     */
    public let joints: Array<Int>

    /**
     * @brief[zh-cn] 创建 Skin 数据
     * @param[zh-cn] name 蒙皮名称
     * @param[zh-cn] inverseBindMatrices 逆绑定矩阵列表
     * @param[zh-cn] skeletonRoot 骨骼根节点索引
     * @param[zh-cn] joints 关节节点索引列表
     *
     * @brief[en] Create Skin data
     * @param[en] name Skin name
     * @param[en] inverseBindMatrices Inverse bind matrix list
     * @param[en] skeletonRoot Skeleton root node index
     * @param[en] joints Joint node index list
     */
    public init(name: String, inverseBindMatrices: Array<Array<Float64>>, skeletonRoot: Int, joints: Array<Int>) {
        this.name = name
        this.inverseBindMatrices = inverseBindMatrices
        this.skeletonRoot = skeletonRoot
        this.joints = joints
    }
}
