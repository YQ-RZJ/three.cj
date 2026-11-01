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
 *
 * @file[en] RenderObject
 * @brief[en] Render object, encapsulating the complete per-draw state of a draw call
 * @explain[en] 
 * RenderObject encapsulates per-draw state such as object/geometry/material/context/camera/scene,
 * providing onAdd/onRemove/onUpdate/onDispose lifecycle hooks.
 * Implements the IRenderObject placeholder interface.
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
     * @brief[zh-cn] nodeChain 首节点（对象自身）的父引用快照，用于判断节点链是否失效
     * @explain[zh-cn]
     * 渲染循环在收集前已全量 updateMatrixWorld，链上的矩阵必然是最新的，
     * 因此逐 draw 重建 parent 链纯属浪费。此快照用于在"对象换父级"时
     * 仍能正确重建节点链，其余情况复用已有链。
     *
     * @brief[en] Snapshot of the object's parent reference used to detect chain invalidation
     * @explain[en]
     * The render loop fully updates the scene graph before collecting, so the chain's
     * matrices are always current and rebuilding the parent chain per draw is wasted
     * work. This snapshot still triggers a rebuild when the object is re-parented.
     */
    private var _chainParentRef: Int64 = 0

    /**
     * @brief[zh-cn] worldMatrix 是否为本对象独占
     * @explain[zh-cn] 简化构造与 resetFor 走的是"直接引用 mesh.matrixWorld"语义
     *               （matrixWorld 实例在引擎内原地更新，引用始终有效），此时
     *               worldMatrix 与 mesh 共享同一实例，**不可就地写入**，否则会
     *               污染 mesh 自身的矩阵。独占时才允许 copy 就地更新。
     *
     * @brief[en] Whether worldMatrix is exclusively owned by this object
     * @explain[en] The simplified constructor and resetFor use the "reference mesh.matrixWorld"
     *               semantics (the matrixWorld instance is updated in place, so the
     *               reference stays valid); there worldMatrix shares the mesh's instance
     *               and must **not** be written in place, or the mesh's own matrix would
     *               be corrupted. Only an owned matrix may be updated in place.
     */
    private var _ownsWorldMatrix: Bool = true

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
        this._ownsWorldMatrix = false
        this.position = worldMatrix.getPosition()
        this.sortKey = 0.0
    }

    /**
     * @brief[zh-cn] 复用渲染对象：按新的网格/几何体/材质重置各字段（池化路径）
     * @explain[zh-cn] 阴影深度 pass 与后期处理 pass 每帧都会为场景中每个 Mesh
     *               新建一个 RenderObject，而 RenderObject 构造器还会连带分配
     *               RenderContext / Camera / Scene / 多个 Matrix / Vector3 /
     *               ArrayList（单个对象 ≈ 10 次堆分配）。10 万对象 × 6 个 cube
     *               阴影面 = 每帧 600 万次分配。改为复用同一批对象：只重置
     *               引用与标量字段，不重新分配任何辅助对象。
     *               注意：worldMatrix 保持"引用 mesh.matrixWorld"语义
     *               （matrixWorld 实例在引擎内是原地更新的，引用始终有效）。
     *
     * @brief[en] Reuses this render object: resets it for a new mesh/geometry/material (pooling path)
     * @explain[en] The shadow depth pass and the post-processing passes create one
     *               RenderObject per scene Mesh every frame, and the constructor also
     *               allocates a RenderContext, Camera, Scene, several matrices, a
     *               Vector3 and ArrayLists (roughly 10 heap allocations per object).
     *               100k objects x 6 cube shadow faces = 6M allocations per frame.
     *               Reusing the same objects resets references and scalars only,
     *               without reallocating any helper object.
     *               Note: worldMatrix keeps the "references mesh.matrixWorld" semantics
     *               (the matrixWorld instance is updated in place, so the reference stays valid).
     *
     * @param[zh-cn] mesh 新的渲染对象（Mesh/Line/Points 等）
     * geometry 几何体
     * material 材质
     *
     * @brief[en] mesh The new render object (Mesh/Line/Points etc.)
     * geometry Geometry
     * material Material
     */
    public func resetFor(mesh: Object3D, geometry: BufferGeometry, material: Material): Unit {
        this.id = mesh.id
        this.`object` = mesh
        this.mesh = mesh
        this.geometry = geometry
        this.material = material
        this.worldMatrix = mesh.matrixWorld
        this._ownsWorldMatrix = false
        this.renderOrder = mesh.renderOrder
        this.sortKey = 0.0
        // 就地写入位置，避免 getPosition() 每次 new Vector3
        let e = mesh.matrixWorld.elements
        this.position.set(e[12], e[13], e[14])
    }

    // ===== 变换矩阵 =====

    /**
     * @brief[zh-cn] 更新变换矩阵，从根节点逐级计算 world matrix
     * @explain[zh-cn]
     * 完整版本：每次都重建 parent 链并从根到叶逐级重算 matrixWorld。
     * 适用于场景图尚未在本帧更新过的调用方。
     *
     * @brief[en] Update transform matrices, computing world matrix from root node level by level
     * @explain[en]
     * Full version: rebuilds the parent chain and recomputes matrixWorld from root
     * to leaf every time. Intended for callers whose scene graph has not been
     * updated this frame yet.
     */
    public func updateWorldMatrix(): Unit {
        let obj = this.`object`
        var root: Option<Object3D> = Some(obj)
        var chain = ArrayList<Object3D>()
        while (true) {
            if (let Some(r) <- root) {
                chain.add(r)
                root = r.parent
            } else {
                break
            }
        }
        // 从根到叶逐级计算 world matrix
        for (i in chain.size - 1..0) {
            let node = chain[i]
            node.updateWorldMatrix(false, false, false)
        }
        // 就地拷贝世界矩阵（原先 clone() 每次都新建一个 Matrix4 —— 主 pass 逐 draw
        // 调用 syncWorldMatrix，等于每个 draw 一次堆分配）
        this._syncWorldMatrixValue(obj)
        this.nodeChain = chain
        this._chainParentRef = RenderObject.parentRefOf(obj)
    }

    /**
     * @brief[zh-cn] 同步世界矩阵（场景图已在本帧全量更新过时使用）
     * @explain[zh-cn]
     * Renderer.render 在收集前已调用 scene.updateMatrixWorld(true)，链上所有
     * matrixWorld 均为最新，因此这里只需拷贝对象自身的世界矩阵；parent 链仅在
     * 对象换父级时才重建。避免每个 draw 重复遍历 parent 链并逐级重算矩阵。
     *
     * @brief[en] Sync the world matrix (use when the scene graph was already fully updated this frame)
     * @explain[en]
     * Renderer.render calls scene.updateMatrixWorld(true) before collecting, so every
     * matrixWorld on the chain is already current. Only the object's own world matrix
     * needs copying, and the parent chain is rebuilt just when the object is
     * re-parented. This avoids re-walking the parent chain and recomputing matrices
     * for every draw.
     */
    public func syncWorldMatrix(): Unit {
        let obj = this.`object`
        let parentRef = RenderObject.parentRefOf(obj)
        if (this.nodeChain.isEmpty() || this._chainParentRef != parentRef) {
            var root: Option<Object3D> = Some(obj)
            let chain = ArrayList<Object3D>()
            while (true) {
                if (let Some(r) <- root) {
                    chain.add(r)
                    root = r.parent
                } else {
                    break
                }
            }
            this.nodeChain = chain
            this._chainParentRef = parentRef
        }
        // 就地拷贝世界矩阵（原先 clone() 每次都新建一个 Matrix4 —— 主 pass 逐 draw
        // 调用 syncWorldMatrix，等于每个 draw 一次堆分配）
        this._syncWorldMatrixValue(obj)
    }

    /**
     * @brief[zh-cn] 同步世界矩阵的值（独占时就地拷贝，共享时保持引用）
     * @explain[zh-cn] 独占（_ownsWorldMatrix=true）：直接 copy 16 个元素，零分配。
     *               共享（与 mesh.matrixWorld 同一实例）：保持引用语义，不做任何写入
     *               —— 共享实例下就地写入会污染 mesh 自身的矩阵。
     * @param[zh-cn] obj 渲染对象
     *
     * @brief[en] Sync the world matrix value (in-place copy when owned, reference kept when shared)
     * @explain[en] Owned (_ownsWorldMatrix=true): copies the 16 elements directly, zero
     *               allocation. Shared (same instance as mesh.matrixWorld): keeps the
     *               reference semantics and writes nothing — an in-place write on a shared
     *               instance would corrupt the mesh's own matrix.
     * @param[en] obj Render object
     */
    private func _syncWorldMatrixValue(obj: Object3D): Unit {
        if (this._ownsWorldMatrix) {
            this.worldMatrix.copy(obj.matrixWorld)
        } else if (!refEq(this.worldMatrix, obj.matrixWorld)) {
            // 共享实例已指向别的 mesh：首次退化为独立拷贝，保持"不污染他人矩阵"的语义。
            // 拷贝后本实例变为独占，后续同步转为就地 copy，不会每帧重复 clone。
            this.worldMatrix = obj.matrixWorld.clone()
            this._ownsWorldMatrix = true
        }
    }

    /**
     * @brief[zh-cn] 取对象父引用的可比较指纹（0 表示无父节点）
     */
    private static func parentRefOf(obj: Object3D): Int64 {
        return if (let Some(p) <- obj.parent) { p.id } else { 0 }
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
        // 用几何体整数 id（原 uuid.hashCode() 每调用对 36 字符字符串重算哈希）
        return this.geometry.id
    }

    /**
     * @brief[zh-cn] 返回材质 ID
     * @return[zh-cn] 材质 ID
     *
     * @brief[en] Return material ID
     * @return[en] Material ID
     */
    public func getMaterialId(): Int64 {
        return this.material.id
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
