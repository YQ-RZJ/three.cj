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
 * @file[zh-cn] bgfx 场景对象管理
 * @brief[zh-cn] 替代 WebGLObjects，管理 Object3D 的渲染数据更新
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLObjects.js。WebGLObjects 负责在每帧更新几何体和实例化网格的缓冲数据。
 *
 * @file[en] bgfx Scene Object Management
 * @brief[en] Replaces WebGLObjects, manages Object3D render data updates
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLObjects.js. WebGLObjects updates geometry and instanced mesh buffer data each frame.
 */
package three.rendering.bgfx

import std.collection.*

/**
 * @brief[zh-cn] bgfx 场景对象管理
 * @explain[zh-cn] 对照 WebGLObjects，管理 Object3D 的渲染数据更新。跟踪每帧更新的对象，避免重复更新。
 *
 * @brief[en] bgfx scene object management
 * @explain[en] Corresponds to WebGLObjects, manages Object3D render data updates. Tracks per-frame updated objects to avoid redundant updates.
 */
public class BgfxObjects {
    /**
     * @brief[zh-cn] 更新映射（对象 ID -> 上次更新的帧号）
     *
     * @brief[en] Update map (object ID -> frame number of last update)
     */
    private var updateMap: HashMap<Int64, Int64>
    /**
     * @brief[zh-cn] 几何体管理
     *
     * @brief[en] Geometry manager
     */
    private var geometries: BgfxGeometries
    /**
     * @brief[zh-cn] 属性管理
     *
     * @brief[en] Attribute manager
     */
    private var attributes: BgfxAttributes
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(geometries!: BgfxGeometries, attributes!: BgfxAttributes, info!: BgfxInfo) {
        this.updateMap = HashMap<Int64, Int64>()
        this.geometries = geometries
        this.attributes = attributes
        this.info = info
    }

    /**
     * @brief[zh-cn] 更新对象的渲染数据
     * @explain[zh-cn] 对照 WebGLObjects.update()，每帧最多更新一次几何体
     * @param[zh-cn] objectId 对象 ID
     * geometryId 几何体 ID
     * isInstancedMesh 是否为实例化网格
     * isSkinnedMesh 是否为蒙皮网格
     * @return[zh-cn] 几何体缓冲数据 ID
     *
     * @brief[en] Updates object render data
     * @explain[en] Corresponds to WebGLObjects.update(), updates geometry at most once per frame
     * @param[en] objectId Object ID
     * geometryId Geometry ID
     * isInstancedMesh Whether it is an instanced mesh
     * isSkinnedMesh Whether it is a skinned mesh
     * @return[en] Geometry buffer data ID
     */
    public func update(objectId: Int64, geometryId: Int64, isInstancedMesh: Bool, isSkinnedMesh: Bool): Int64 {
        let frame = info.render.frame

        // 更新几何体（每帧最多一次）
        match (updateMap.get(geometryId)) {
            case Some(lastFrame) =>
                if (lastFrame != frame) {
                    geometries.update(geometryId)
                    updateMap.add(geometryId, frame)
                }
            case None =>
                geometries.update(geometryId)
                updateMap.add(geometryId, frame)
        }

        // 实例化网格需要更新实例矩阵
        if (isInstancedMesh) {
            match (updateMap.get(objectId)) {
                case Some(lastFrame) =>
                    if (lastFrame != frame) {
                        // 更新实例属性
                        updateMap.add(objectId, frame)
                    }
                case None =>
                    updateMap.add(objectId, frame)
            }
        }

        return geometryId
    }

    /**
     * @brief[zh-cn] 释放所有更新映射
     * @explain[zh-cn] 对照 WebGLObjects.dispose()
     *
     * @brief[en] Disposes all update mappings
     * @explain[en] Corresponds to WebGLObjects.dispose()
     */
    public func dispose(): Unit {
        updateMap = HashMap<Int64, Int64>()
    }
}
