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
 * @file[zh-cn] 渲染对象
 * @brief[zh-cn] 渲染对象，封装一次 draw 调用的完整 per-draw 状态
 * @explain[zh-cn] 
 * RenderObject 封装 object/geometry/material/context/camera/scene 等 per-draw 状态，
 * 提供 onAdd/onRemove/onUpdate/onDispose 生命周期钩子。
 * 实现 IRenderObject 占位接口。
 * 对照源码: three.js/src/renderers/common/RenderObject.js (975 行)
 *
 * @file[en] RenderObject
 * @brief[en] Render object, encapsulating the complete per-draw state of a draw call
 * @explain[en] 
 * RenderObject encapsulates per-draw state such as object/geometry/material/context/camera/scene,
 * providing onAdd/onRemove/onUpdate/onDispose lifecycle hooks.
 * Implements the IRenderObject placeholder interface.
 * Corresponding source: three.js/src/renderers/common/RenderObject.js (975 lines)
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import std.collection.*

/**
 * @brief[zh-cn] 渲染对象
 * @explain[zh-cn] 
 * 封装 object/geometry/material/context/camera/scene 等 per-draw 状态，
 * 提供 onAdd/onRemove/onUpdate/onDispose 生命周期钩子。
 * 实现 IRenderObject 占位接口。
 *
 * @brief[en] Render object
 * @explain[en] 
 * Encapsulates per-draw state such as object/geometry/material/context/camera/scene,
 * providing onAdd/onRemove/onUpdate/onDispose lifecycle hooks.
 * Implements the IRenderObject placeholder interface.
 */
public open class RenderObject <: IRenderObject {
    /**
     * @brief[zh-cn] 唯一标识
     *
     * @brief[en] Unique identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 渲染对象（Mesh/Line/Points 等 Object3D 子类）
     *
     * @brief[en] Render object (Mesh/Line/Points etc., Object3D subclass)
     */
    public var `object`: Object3D

    /**
     * @brief[zh-cn] mesh 别名（兼容 ThreeRenderer 中 ro.mesh 访问）
     *
     * @brief[en] mesh alias (for compatible ro.mesh access in ThreeRenderer)
     */
    public var mesh: Object3D

    /**
     * @brief[zh-cn] 几何体
     *
     * @brief[en] Geometry
     */
    public var geometry: BufferGeometry

    /**
     * @brief[zh-cn] 材质
     *
     * @brief[en] Material
     */
    public var material: Material

    /**
     * @brief[zh-cn] 渲染上下文
     *
     * @brief[en] Render context
     */
    public var context: RenderContext

    /**
     * @brief[zh-cn] 相机
     *
     * @brief[en] Camera
     */
    public var camera: Camera

    /**
     * @brief[zh-cn] 场景
     *
     * @brief[en] Scene
     */
    public var scene: Scene

    /**
     * @brief[zh-cn] 渲染顺序
     *
     * @brief[en] Render order
     */
    public var renderOrder: Float64 = 0.0

    /**
     * @brief[zh-cn] 组顺序
     *
     * @brief[en] Group order
     */
    public var groupOrder: Float64 = 0.0

    /**
     * @brief[zh-cn] 深度值（相机空间 z，用于排序）
     *
     * @brief[en] Depth value (camera-space z, used for sorting)
     */
    public var z: Float64 = 0.0

    /**
     * @brief[zh-cn] 世界矩阵（对象到世界空间）
     *
     * @brief[en] World matrix (object to world space)
     */
    public var worldMatrix: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 模型视图矩阵
     *
     * @brief[en] Model-view matrix
     */
    public var modelViewMatrix: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 法线矩阵
     *
     * @brief[en] Normal matrix
     */
    public var normalMatrix: Matrix3 = Matrix3()

    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether initialized
     */
    public var initialized: Bool = false

    /**
     * @brief[zh-cn] 绑定组列表
     *
     * @brief[en] Bind group list
     */
    public var bindings: ArrayList<Binding> = ArrayList<Binding>()

    /**
     * @brief[zh-cn] 节点链（用于变换层级遍历）
     *
     * @brief[en] Node chain (for transform hierarchy traversal)
     */
    public var nodeChain: ArrayList<Object3D> = ArrayList<Object3D>()

    /**
     * @brief[zh-cn] 位置（从 worldMatrix 提取，用于排序/遮挡查询）
     *
     * @brief[en] Position (extracted from worldMatrix, used for sorting/occlusion queries)
     */
    public var position: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 排序键（用于透明对象排序）
     *
     * @brief[en] Sort key (used for transparent object sorting)
     */
    public var sortKey: Float64 = 0.0

    /**
     * @brief[zh-cn] 完整构造器
     * @param[zh-cn] id 唯一标识
     * object 渲染对象
     * geometry 几何体
     * material 材质
     * context 渲染上下文
     * camera 相机
     * scene 场景
     *
     * @brief[en] Full constructor
     * @param[en] id Unique identifier
     * object Render object
     * geometry Geometry
     * material Material
     * context Render context
     * camera Camera
     * scene Scene
     */
    public init(id: Int64, `object`: Object3D, geometry: BufferGeometry, material: Material,
                context: RenderContext, camera: Camera, scene: Scene) {
        this.id = id
        this.`object` = `object`
        this.mesh = `object`
        this.geometry = geometry
        this.material = material
        this.context = context
        this.camera = camera
        this.scene = scene
        this.renderOrder = `object`.renderOrder
    }

    /**
     * @brief[zh-cn] 简化构造器（兼容旧式调用），不传 context/camera/scene 时使用默认值
     * @param[zh-cn] id 唯一标识
     * mesh 渲染对象
     * geometry 几何体
     * material 材质
     * worldMatrix 世界矩阵（仅用于提取 position）
     *
     * @brief[en] Simplified constructor (for backward compatibility), uses defaults when context/camera/scene are not provided
     * @param[en] id Unique identifier
     * mesh Render object
     * geometry Geometry
     * material Material
     * worldMatrix World matrix (used only for extracting position)
     */
    public init(id: Int64, mesh: Object3D, geometry: BufferGeometry, material: Material,
                worldMatrix: Matrix4) {
        this.id = id
        this.`object` = mesh
        this.mesh = mesh
        this.geometry = geometry
        this.material = material
        this.context = RenderContext()
        this.camera = Camera()
        this.scene = Scene()
        this.renderOrder = mesh.renderOrder
        this.worldMatrix = worldMatrix
        this.position = worldMatrix.getPosition()
        this.sortKey = 0.0
    }

    // ===== 变换矩阵 =====

    /**
     * @brief[zh-cn] 更新变换矩阵，从根节点逐级计算 world matrix
     *
     * @brief[en] Update transform matrices, computing world matrix from root node level by level
     */
    public func updateWorldMatrix(): Unit {
        var root: Option<Object3D> = Some(this.`object`)
        var chain = ArrayList<Object3D>()
        while (true) {
            match (root) {
                case Some(r) =>
                    chain.add(r)
                    root = r.parent
                case None => break
            }
        }
        // 从根到叶逐级计算 world matrix
        for (i in chain.size - 1..0) {
            let node = chain[i]
            node.updateWorldMatrix(false, false, false)
        }
        this.worldMatrix = this.`object`.matrixWorld.clone()
        this.nodeChain = chain
    }

    // ===== IRenderObject 实现 =====

    /**
     * @brief[zh-cn] 返回 world matrix（16 个 Float64 列主序）
     * @return[zh-cn] 世界矩阵元素数组
     *
     * @brief[en] Return world matrix (16 Float64 elements in column-major order)
     * @return[en] World matrix elements array
     */
    public func getMatrix(): Array<Float64> {
        return this.worldMatrix.elements
    }

    /**
     * @brief[zh-cn] 返回几何体 ID
     * @return[zh-cn] 几何体哈希 ID
     *
     * @brief[en] Return geometry ID
     * @return[en] Geometry hash ID
     */
    public func getGeometryId(): Int64 {
        return this.geometry.uuid.hashCode()
    }

    /**
     * @brief[zh-cn] 返回材质 ID
     * @return[zh-cn] 材质哈希 ID
     *
     * @brief[en] Return material ID
     * @return[en] Material hash ID
     */
    public func getMaterialId(): Int64 {
        return this.material.uuid.hashCode()
    }

    /**
     * @brief[zh-cn] 返回对象 ID
     * @return[zh-cn] 对象 ID
     *
     * @brief[en] Return object ID
     * @return[en] Object ID
     */
    public func getObjectId(): Int64 {
        return this.`object`.id
    }

    /**
     * @brief[zh-cn] 返回节点链
     * @return[zh-cn] 节点链列表
     *
     * @brief[en] Return node chain
     * @return[en] Node chain list
     */
    public func getNodeChain(): ArrayList<Object3D> {
        return this.nodeChain
    }

    /**
     * @brief[zh-cn] 返回组顺序
     * @return[zh-cn] 组顺序值
     *
     * @brief[en] Return group order
     * @return[en] Group order value
     */
    public func getGroupOrder(): Float64 {
        return this.groupOrder
    }

    /**
     * @brief[zh-cn] 返回渲染顺序
     * @return[zh-cn] 渲染顺序值
     *
     * @brief[en] Return render order
     * @return[en] Render order value
     */
    public func getRenderOrder(): Float64 {
        return this.renderOrder
    }

    // ===== 生命周期钩子 =====

    /**
     * @brief[zh-cn] 添加到渲染器时调用
     *
     * @brief[en] Called when added to the renderer
     */
    public func onAdd(): Unit {
        this.initialized = true
    }

    /**
     * @brief[zh-cn] 从渲染器移除时调用
     *
     * @brief[en] Called when removed from the renderer
     */
    public func onRemove(): Unit {
        this.initialized = false
    }

    /**
     * @brief[zh-cn] 属性更新时调用
     *
     * @brief[en] Called when properties are updated
     */
    public func onUpdate(): Unit {
        this.updateWorldMatrix()
    }

    /**
     * @brief[zh-cn] 释放时调用
     *
     * @brief[en] Called when disposed
     */
    public func onDispose(): Unit {
        this.initialized = false
        this.bindings.clear()
    }

    // ===== getHash =====

    /**
     * @brief[zh-cn] 返回渲染对象哈希（用于去重缓存）
     * @return[zh-cn] 渲染对象哈希值
     *
     * @brief[en] Return render object hash (used for deduplication cache)
     * @return[en] Render object hash value
     */
    public func getHash(): Int64 {
        return this.id
    }
}
