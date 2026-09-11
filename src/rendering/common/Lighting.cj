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
 * @file[zh-cn] 光照
 * @brief[zh-cn] 光照信息聚合类，管理环境光、方向光、点光源和聚光灯列表
 * @explain[zh-cn] 
 * Lighting 聚合场景中的所有光源信息，按类型分类为环境光、方向光、点光源和聚光灯，
 * 在渲染 pass 中供着色器绑定光照参数。每帧开始时调用 reset 清空光源列表。
 *
 * @file[en] Lighting
 * @brief[en] Lighting information aggregation class, managing ambient, directional, point, and spot light lists
 * @explain[en] 
 * Lighting aggregates all light source information in the scene, categorizing them by type into ambient, directional, point, and spot lights,
 * for shader light parameter binding during the render pass. Call reset at the start of each frame to clear the light lists.
 */
package three.rendering.common

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 光照信息聚合类
 * @explain[zh-cn] 
 * 按类型分类管理场景光源，每帧开始时调用 reset 清空列表。
 *
 * @brief[en] Lighting information aggregation class
 * @explain[en] 
 * Manages scene lights by type; call reset at the start of each frame to clear lists.
 */
public open class Lighting {
    /**
     * @brief[zh-cn] 环境光颜色
     *
     * @brief[en] Ambient light color
     */
    public var ambient: Vector3

    /**
     * @brief[zh-cn] 方向光列表
     *
     * @brief[en] Directional light list
     */
    public var directional: ArrayList<Vector3>

    /**
     * @brief[zh-cn] 点光源列表
     *
     * @brief[en] Point light list
     */
    public var point: ArrayList<Vector3>

    /**
     * @brief[zh-cn] 聚光灯列表
     *
     * @brief[en] Spot light list
     */
    public var spot: ArrayList<Vector3>

    /**
     * @brief[zh-cn] 构造默认光照信息
     *
     * @brief[en] Constructs default lighting information
     */
    public init() {
        this.ambient = Vector3(0.2, 0.2, 0.2)
        this.directional = ArrayList<Vector3>(); this.point = ArrayList<Vector3>(); this.spot = ArrayList<Vector3>()
    }

    /**
     * @brief[zh-cn] 重置光照信息，清空所有光源列表
     *
     * @brief[en] Resets lighting information, clearing all light lists
     */
    public func reset(): Unit {
        this.ambient.set(0.2, 0.2, 0.2)
        this.directional.clear(); this.point.clear(); this.spot.clear()
    }
}
