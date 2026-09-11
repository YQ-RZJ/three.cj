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
 * @file[zh-cn] bgfx 渲染列表
 * @brief[zh-cn] 替代 WebGLRenderLists，按透明度/距离排序渲染对象
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLRenderLists.js。WebGLRenderLists 负责按渲染顺序（不透明、半透明、透明）排序对象。
 *
 * @file[en] bgfx Render Lists
 * @brief[en] Replaces WebGLRenderLists, sorts render objects by transparency/distance
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLRenderLists.js. WebGLRenderLists sorts objects by render order (opaque, transmissive, transparent).
 */
package three.rendering.bgfx

import std.collection.*
import std.sort.*

/**
 * @brief[zh-cn] 渲染项
 * @explain[zh-cn] 对照 WebGLRenderLists 中的 renderItem
 *
 * @brief[en] Render item
 * @explain[en] Corresponds to renderItem in WebGLRenderLists
 */
public class RenderItem {
    /**
     * @brief[zh-cn] 对象 ID
     *
     * @brief[en] Object ID
     */
    public var id: Int64 = 0
    /**
     * @brief[zh-cn] 对象引用 ID
     *
     * @brief[en] Object reference ID
     */
    public var objectId: Int64 = 0
    /**
     * @brief[zh-cn] 渲染顺序
     *
     * @brief[en] Render order
     */
    public var renderOrder: Int64 = 0
    /**
     * @brief[zh-cn] 组顺序
     *
     * @brief[en] Group order
     */
    public var groupOrder: Int64 = 0
    /**
     * @brief[zh-cn] 材质 ID
     *
     * @brief[en] Material ID
     */
    public var materialId: Int64 = 0
    /**
     * @brief[zh-cn] 材质变体
     *
     * @brief[en] Material variant
     */
    public var materialVariant: Int64 = 0
    /**
     * @brief[zh-cn] 深度值（用于排序）
     *
     * @brief[en] Depth value (for sorting)
     */
    public var z: Float64 = 0.0
    /**
     * @brief[zh-cn] 着色器程序 ID
     *
     * @brief[en] Shader program ID
     */
    public var programId: Int64 = -1

    public init() {}
}

/**
 * @brief[zh-cn] 渲染列表
 * @explain[zh-cn] 对照 WebGLRenderList，管理不透明、半透明和透明渲染对象列表
 *
 * @brief[en] Render list
 * @explain[en] Corresponds to WebGLRenderList, manages opaque, transmissive, and transparent render object lists
 */
public class BgfxRenderList {
    /**
     * @brief[zh-cn] 渲染项池
     *
     * @brief[en] Render item pool
     */
    private var renderItems: ArrayList<RenderItem>
    /**
     * @brief[zh-cn] 当前渲染项索引
     *
     * @brief[en] Current render item index
     */
    private var renderItemsIndex: Int64 = 0
    /**
     * @brief[zh-cn] 不透明对象列表
     *
     * @brief[en] Opaque object list
     */
    private var opaque: ArrayList<RenderItem>
    /**
     * @brief[zh-cn] 半透明对象列表
     *
     * @brief[en] Transmissive object list
     */
    private var transmissive: ArrayList<RenderItem>
    /**
     * @brief[zh-cn] 透明对象列表
     *
     * @brief[en] Transparent object list
     */
    private var transparent: ArrayList<RenderItem>

    public init() {
        this.renderItems = ArrayList<RenderItem>()
        this.renderItemsIndex = 0
        this.opaque = ArrayList<RenderItem>()
        this.transmissive = ArrayList<RenderItem>()
        this.transparent = ArrayList<RenderItem>()
    }

    /**
     * @brief[zh-cn] 初始化渲染列表
     * @explain[zh-cn] 对照 WebGLRenderList.init()，每帧调用
     *
     * @brief[en] Initializes render list
     * @explain[en] Corresponds to WebGLRenderList.init(), called each frame
     */
    public func `init`(): Unit {
        renderItemsIndex = 0
        opaque = ArrayList<RenderItem>()
        transmissive = ArrayList<RenderItem>()
        transparent = ArrayList<RenderItem>()
    }

    /**
     * 获取或创建渲染项
     */
    private func getNextRenderItem(): RenderItem {
        if (renderItemsIndex < renderItems.size) {
            let item = renderItems[Int64(renderItemsIndex)]
            renderItemsIndex += 1
            return item
        } else {
            let item = RenderItem()
            renderItems.add(item)
            renderItemsIndex += 1
            return item
        }
    }

    /**
     * @brief[zh-cn] 添加渲染项
     * @explain[zh-cn] 对照 WebGLRenderList.push()，根据材质类型分类到不透明/半透明/透明列表
     *
     * @brief[en] Adds render item
     * @explain[en] Corresponds to WebGLRenderList.push(), classifies into opaque/transmissive/transparent list by material type
     */
    public func push(id: Int64, objectId: Int64, renderOrder: Int64, groupOrder: Int64,
                     materialId: Int64, materialVariant: Int64, z: Float64, programId: Int64): Unit {
        let item = getNextRenderItem()
        item.id = id
        item.objectId = objectId
        item.renderOrder = renderOrder
        item.groupOrder = groupOrder
        item.materialId = materialId
        item.materialVariant = materialVariant
        item.z = z
        item.programId = programId

        // 根据材质类型分类
        if (materialVariant == 0) {
            opaque.add(item)
        } else if (materialVariant == 1) {
            transmissive.add(item)
        } else {
            transparent.add(item)
        }
    }

    /**
     * @brief[zh-cn] 获取不透明对象列表
     * @return[zh-cn] 不透明对象列表
     *
     * @brief[en] Gets opaque object list
     * @return[en] Opaque object list
     */
    public func getOpaque(): ArrayList<RenderItem> {
        return opaque
    }

    /**
     * @brief[zh-cn] 获取半透明对象列表
     * @return[zh-cn] 半透明对象列表
     *
     * @brief[en] Gets transmissive object list
     * @return[en] Transmissive object list
     */
    public func getTransmissive(): ArrayList<RenderItem> {
        return transmissive
    }

    /**
     * @brief[zh-cn] 获取透明对象列表
     * @return[zh-cn] 透明对象列表
     *
     * @brief[en] Gets transparent object list
     * @return[en] Transparent object list
     */
    public func getTransparent(): ArrayList<RenderItem> {
        return transparent
    }

    /**
     * @brief[zh-cn] 排序渲染列表
     * @explain[zh-cn] 对照 WebGLRenderList.finish()，不透明按组顺序/渲染顺序/材质排序，透明按深度逆序
     *
     * @brief[en] Sorts render lists
     * @explain[en] Corresponds to WebGLRenderList.finish(), opaque sorted by group/render order/material, transparent sorted by depth descending
     */
    public func finish(): Unit {
        // 不透明对象按组顺序、渲染顺序、材质 ID、深度排序
        sort(opaque, by: { a: RenderItem, b: RenderItem =>
            if (a.groupOrder != b.groupOrder) {
                if (a.groupOrder < b.groupOrder) { Ordering.LT } else { Ordering.GT }
            } else if (a.renderOrder != b.renderOrder) {
                if (a.renderOrder < b.renderOrder) { Ordering.LT } else { Ordering.GT }
            } else if (a.materialId != b.materialId) {
                if (a.materialId < b.materialId) { Ordering.LT } else { Ordering.GT }
            } else {
                if (a.id < b.id) { Ordering.LT } else if (a.id > b.id) { Ordering.GT } else { Ordering.EQ }
            }
        })
        // 透明对象按组顺序、渲染顺序、深度逆序排序
        sort(transparent, by: { a: RenderItem, b: RenderItem =>
            if (a.groupOrder != b.groupOrder) {
                if (a.groupOrder < b.groupOrder) { Ordering.LT } else { Ordering.GT }
            } else if (a.renderOrder != b.renderOrder) {
                if (a.renderOrder < b.renderOrder) { Ordering.LT } else { Ordering.GT }
            } else if (a.z != b.z) {
                if (b.z > a.z) { Ordering.LT } else { Ordering.GT }
            } else {
                if (a.id < b.id) { Ordering.LT } else if (a.id > b.id) { Ordering.GT } else { Ordering.EQ }
            }
        })
    }
}

/**
 * @brief[zh-cn] bgfx 渲染列表管理
 * @explain[zh-cn] 对照 WebGLRenderLists，管理多个渲染列表的缓存
 *
 * @brief[en] bgfx render list management
 * @explain[en] Corresponds to WebGLRenderLists, manages caching of multiple render lists
 */
public class BgfxRenderLists {
    /**
     * @brief[zh-cn] 渲染列表缓存（场景 ID -> 渲染列表）
     *
     * @brief[en] Render list cache (scene ID -> render list)
     */
    private var lists: HashMap<Int64, BgfxRenderList>

    public init() {
        this.lists = HashMap<Int64, BgfxRenderList>()
    }

    /**
     * @brief[zh-cn] 获取渲染列表
     * @explain[zh-cn] 对照 WebGLRenderLists.get()
     * @param[zh-cn] sceneId 场景 ID
     * @return[zh-cn] 渲染列表
     *
     * @brief[en] Gets render list
     * @explain[en] Corresponds to WebGLRenderLists.get()
     * @param[en] sceneId Scene ID
     * @return[en] Render list
     */
    public func get(sceneId: Int64): BgfxRenderList {
        match (lists.get(sceneId)) {
            case Some(list) => return list
            case None =>
                let list = BgfxRenderList()
                lists.add(sceneId, list)
                return list
        }
    }

    /**
     * @brief[zh-cn] 释放所有渲染列表
     *
     * @brief[en] Disposes all render lists
     */
    public func dispose(): Unit {
        lists = HashMap<Int64, BgfxRenderList>()
    }
}
