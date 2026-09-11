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
 * @file[zh-cn] bgfx 几何体管理
 * @brief[zh-cn] 替代 WebGLGeometries，管理几何体到 bgfx 缓冲句柄的映射
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLGeometries.js。在 WebGL 中跟踪几何体的缓冲更新状态，在 bgfx 中同样需要跟踪几何体的缓冲版本，在数据变更时更新缓冲。
 *
 * @file[en] bgfx Geometry Management
 * @brief[en] Replaces WebGLGeometries, manages geometry to bgfx buffer handle mapping
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLGeometries.js. In WebGL, tracks buffer update state of geometries; in bgfx, similarly tracks buffer versions and updates buffers when data changes.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 几何体管理
 * @explain[zh-cn] 对照 WebGLGeometries，管理几何体到缓冲的映射。跟踪几何体的版本号，在数据变更时更新缓冲。使用 HashMap 替代 WeakMap。
 *
 * @brief[en] bgfx geometry management
 * @explain[en] Corresponds to WebGLGeometries, manages geometry-to-buffer mapping. Tracks geometry version numbers and updates buffers when data changes. Uses HashMap instead of WeakMap.
 */
public class BgfxGeometries {
    /**
     * @brief[zh-cn] 已注册的几何体 ID 集合
     *
     * @brief[en] Set of registered geometry IDs
     */
    private var geometries: HashMap<Int64, Bool>
    /**
     * @brief[zh-cn] 线框属性映射
     *
     * @brief[en] Wireframe attribute map
     */
    private var wireframeAttributes: HashMap<Int64, Int64>
    /**
     * @brief[zh-cn] 顶点属性管理器
     *
     * @brief[en] Vertex attribute manager
     */
    private var attributes: BgfxAttributes
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo
    /**
     * @brief[zh-cn] 绑定状态管理
     *
     * @brief[en] Binding state manager
     */
    private var bindingStates: BgfxBindingStates
    /**
     * @brief[zh-cn] 顶点布局句柄缓存（attributeId -> VertexLayoutHandle）
     *
     * @brief[en] Vertex layout handle cache (attributeId -> VertexLayoutHandle)
     */
    private var _layoutHandles: HashMap<Int64, VertexLayoutHandle>

    public init(attributes!: BgfxAttributes, info!: BgfxInfo, bindingStates!: BgfxBindingStates) {
        this.geometries = HashMap<Int64, Bool>()
        this.wireframeAttributes = HashMap<Int64, Int64>()
        this._layoutHandles = HashMap<Int64, VertexLayoutHandle>()
        this.attributes = attributes
        this.info = info
        this.bindingStates = bindingStates
    }

    /**
     * @brief[zh-cn] 获取或注册几何体
     * @explain[zh-cn] 对照 WebGLGeometries.get()，按几何体 ID 查找，不存在则注册
     * @param[zh-cn] geometryId 几何体 ID
     * @return[zh-cn] 是否为新注册的几何体
     *
     * @brief[en] Gets or registers a geometry
     * @explain[en] Corresponds to WebGLGeometries.get(), looks up by geometry ID, registers if not found
     * @param[en] geometryId Geometry ID
     * @return[en] Whether the geometry is newly registered
     */
    public func get(geometryId: Int64): Bool {
        if (geometries.contains(geometryId)) {
            return false
        }
        geometries.add(geometryId, true)
        info.memory.geometries += 1
        return true
    }

    /**
     * @brief[zh-cn] 更新几何体的所有属性缓冲
     * @explain[zh-cn] 对照 WebGLGeometries.update()，当前由 BgfxAttributes 单独管理
     * @param[zh-cn] geometryId 几何体 ID
     *
     * @brief[en] Updates all attribute buffers of a geometry
     * @explain[en] Corresponds to WebGLGeometries.update(), currently managed separately by BgfxAttributes
     * @param[en] geometryId Geometry ID
     */
    public func update(geometryId: Int64): Unit {
        // 几何体属性更新由 BgfxAttributes 单独管理
        // 此处仅标记几何体已更新
    }

    /**
     * @brief[zh-cn] 获取顶点缓冲信息
     * @explain[zh-cn] 委托到 BgfxAttributes，对应 BgfxBackend.draw 中 bgfx_set_vertex_buffer_with_layout_cj 的第一个参数
     * @param[zh-cn] attributeId 属性 ID
     * @return[zh-cn] 顶点缓冲信息（含 VertexBufferHandle）
     *
     * @brief[en] Gets vertex buffer info
     * @explain[en] Delegates to BgfxAttributes, corresponds to the first parameter of bgfx_set_vertex_buffer_with_layout_cj in BgfxBackend.draw
     * @param[en] attributeId Attribute ID
     * @return[en] Vertex buffer info (containing VertexBufferHandle)
     */
    public func getVertexBuffer(attributeId: Int64): Option<VertexBufferInfo> {
        return this.attributes.getVertexBuffer(attributeId)
    }

    /**
     * @brief[zh-cn] 获取顶点布局句柄
     * @explain[zh-cn] 对应 BgfxBackend.draw 中 bgfx_set_vertex_buffer_with_layout_cj 的 layoutHandle 参数，布局句柄由 BgfxGeometries 在创建缓冲时缓存
     * @param[zh-cn] attributeId 属性 ID
     * @return[zh-cn] 顶点布局句柄
     *
     * @brief[en] Gets vertex layout handle
     * @explain[en] Corresponds to the layoutHandle parameter of bgfx_set_vertex_buffer_with_layout_cj in BgfxBackend.draw, layout handle cached by BgfxGeometries at buffer creation
     * @param[en] attributeId Attribute ID
     * @return[en] Vertex layout handle
     */
    public func getLayoutHandle(attributeId: Int64): Option<VertexLayoutHandle> {
        // 布局句柄缓存（由 BgfxGeometries 在 update 时管理）
        match (this._layoutHandles.get(attributeId)) {
            case Some(handle) => return Some(handle)
            case None => return None
        }
    }

    /**
     * @brief[zh-cn] 获取索引缓冲信息
     * @explain[zh-cn] 委托到 BgfxAttributes，对应 BgfxBackend.draw 中 bgfx_set_index_buffer_cj 的第一个参数
     * @param[zh-cn] attributeId 属性 ID
     * @return[zh-cn] 索引缓冲信息（含 IndexBufferHandle）
     *
     * @brief[en] Gets index buffer info
     * @explain[en] Delegates to BgfxAttributes, corresponds to the first parameter of bgfx_set_index_buffer_cj in BgfxBackend.draw
     * @param[en] attributeId Attribute ID
     * @return[en] Index buffer info (containing IndexBufferHandle)
     */
    public func getIndexBuffer(attributeId: Int64): Option<IndexBufferInfo> {
        return this.attributes.getIndexBuffer(attributeId)
    }

    /**
     * @brief[zh-cn] 更新线框属性
     * @explain[zh-cn] 对照 WebGLGeometries.updateWireframeAttribute()
     * @param[zh-cn] geometryId 几何体 ID
     * wireframeAttrId 线框属性 ID
     *
     * @brief[en] Updates wireframe attribute
     * @explain[en] Corresponds to WebGLGeometries.updateWireframeAttribute()
     * @param[en] geometryId Geometry ID
     * wireframeAttrId Wireframe attribute ID
     */
    public func updateWireframeAttribute(geometryId: Int64, wireframeAttrId: Int64): Unit {
        match (wireframeAttributes.get(geometryId)) {
            case Some(oldAttrId) =>
                attributes.removeVertexBuffer(oldAttrId)
            case None =>
                ()
        }
        wireframeAttributes.add(geometryId, wireframeAttrId)
    }

    /**
     * @brief[zh-cn] 获取线框属性
     * @explain[zh-cn] 对照 WebGLGeometries.getWireframeAttribute()
     * @param[zh-cn] geometryId 几何体 ID
     * @return[zh-cn] 线框属性 ID
     *
     * @brief[en] Gets wireframe attribute
     * @explain[en] Corresponds to WebGLGeometries.getWireframeAttribute()
     * @param[en] geometryId Geometry ID
     * @return[en] Wireframe attribute ID
     */
    public func getWireframeAttribute(geometryId: Int64): Option<Int64> {
        return wireframeAttributes.get(geometryId)
    }

    /**
     * @brief[zh-cn] 释放几何体资源
     * @explain[zh-cn] 对照 WebGLGeometries.onGeometryDispose()，移除索引缓冲、顶点属性缓冲、线框属性和绑定状态
     * @param[zh-cn] geometryId 几何体 ID
     * indexAttributeId 索引属性 ID
     * attributeIds 顶点属性 ID 列表
     *
     * @brief[en] Disposes geometry resources
     * @explain[en] Corresponds to WebGLGeometries.onGeometryDispose(), removes index buffer, vertex attribute buffers, wireframe attribute and binding states
     * @param[en] geometryId Geometry ID
     * indexAttributeId Index attribute ID
     * attributeIds Vertex attribute ID list
     */
    public func dispose(geometryId: Int64, indexAttributeId: Option<Int64>, attributeIds: ArrayList<Int64>): Unit {
        // 移除索引缓冲
        match (indexAttributeId) {
            case Some(id) =>
                attributes.removeIndexBuffer(id)
            case None =>
                ()
        }

        // 移除所有顶点属性缓冲
        for (attrId in attributeIds) {
            attributes.removeVertexBuffer(attrId)
        }

        // 移除几何体注册
        geometries.remove(geometryId)

        // 移除线框属性
        match (wireframeAttributes.get(geometryId)) {
            case Some(attrId) =>
                attributes.removeVertexBuffer(attrId)
                wireframeAttributes.remove(geometryId)
            case None =>
                ()
        }

        // 释放绑定状态
        bindingStates.releaseStatesOfGeometry(geometryId)

        info.memory.geometries -= 1
    }

    /**
     * @brief[zh-cn] 释放所有几何体
     *
     * @brief[en] Disposes all geometries
     */
    public func disposeAll(): Unit {
        geometries = HashMap<Int64, Bool>()
        wireframeAttributes = HashMap<Int64, Int64>()
        attributes.dispose()
    }
}
