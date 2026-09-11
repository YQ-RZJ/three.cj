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
 * @file[zh-cn] bgfx 变形目标管理
 * @brief[zh-cn] 替代 WebGLMorphtargets，管理变形目标数据
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLMorphtargets.js。WebGLMorphtargets 负责管理变形目标的权重和属性绑定。
 *
 * @file[en] bgfx Morph Target Management
 * @brief[en] Replaces WebGLMorphtargets, manages morph target data
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLMorphtargets.js. WebGLMorphtargets manages morph target weights and attribute bindings.
 */
package three.rendering.bgfx

import std.collection.*

/**
 * @brief[zh-cn] 变形目标信息
 * @explain[zh-cn] 存储单个几何体的变形目标数量和权重数据
 *
 * @brief[en] Morph target info
 * @explain[en] Stores morph target count and weight data for a single geometry
 */
public class MorphTargetInfo {
    /**
     * @brief[zh-cn] 变形目标数量
     *
     * @brief[en] Morph target count
     */
    public var count: Int64 = 0
    /**
     * @brief[zh-cn] 权重数组
     *
     * @brief[en] Weights array
     */
    public var weights: Array<Float32>

    public init(count: Int64) {
        this.count = count
        this.weights = Array<Float32>(count, { _ => 0.0f32 })
    }
}

/**
 * @brief[zh-cn] bgfx 变形目标管理
 * @explain[zh-cn] 对照 WebGLMorphtargets，管理变形目标的权重更新
 *
 * @brief[en] bgfx morph target management
 * @explain[en] Corresponds to WebGLMorphtargets, manages morph target weight updates
 */
public class BgfxMorphtargets {
    /**
     * @brief[zh-cn] 变形目标缓存（几何体 ID -> MorphTargetInfo）
     *
     * @brief[en] Morph target cache (geometry ID -> MorphTargetInfo)
     */
    private var morphTargets: HashMap<Int64, MorphTargetInfo>

    public init() {
        this.morphTargets = HashMap<Int64, MorphTargetInfo>()
    }

    /**
     * @brief[zh-cn] 获取变形目标信息
     * @param[zh-cn] geometryId 几何体 ID
     * count 变形目标数量
     * @return[zh-cn] 变形目标信息
     *
     * @brief[en] Gets morph target info
     * @param[en] geometryId Geometry ID
     * count Morph target count
     * @return[en] Morph target info
     */
    public func get(geometryId: Int64, count: Int64): MorphTargetInfo {
        match (morphTargets.get(geometryId)) {
            case Some(info) => return info
            case None =>
                let info = MorphTargetInfo(count)
                morphTargets.add(geometryId, info)
                return info
        }
    }

    /**
     * @brief[zh-cn] 更新变形目标权重
     * @explain[zh-cn] 对照 WebGLMorphtargets.update()
     * @param[zh-cn] geometryId 几何体 ID
     * weights 权重数组
     *
     * @brief[en] Updates morph target weights
     * @explain[en] Corresponds to WebGLMorphtargets.update()
     * @param[en] geometryId Geometry ID
     * weights Weights array
     */
    public func update(geometryId: Int64, weights: Array<Float32>): Unit {
        match (morphTargets.get(geometryId)) {
            case Some(info) =>
                let len = if (weights.size < info.weights.size) { weights.size } else { info.weights.size }
                for (i in 0..len) {
                    info.weights[i] = weights[i]
                }
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 释放变形目标
     * @param[zh-cn] geometryId 几何体 ID
     *
     * @brief[en] Disposes morph target
     * @param[en] geometryId Geometry ID
     */
    public func dispose(geometryId: Int64): Unit {
        morphTargets.remove(geometryId)
    }

    /**
     * @brief[zh-cn] 释放所有变形目标
     *
     * @brief[en] Disposes all morph targets
     */
    public func disposeAll(): Unit {
        morphTargets = HashMap<Int64, MorphTargetInfo>()
    }
}
