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
 * @file[zh-cn] Object3D
 * @brief[zh-cn] 3D 对象基类，所有场景对象的父类
 * @explain[zh-cn] Object3D 是本场景图的核心节点类，提供位置、旋转、缩放、矩阵变换、
 * 层级关系（parent/children）、射线检测、包围盒计算等功能。
 * 所有可见对象（Mesh、Line、Points、Sprite 等）和容器（Group、Scene 等）均继承此类。
 *
 * @file[en] Object3D
 * @brief[en] 3D object base class, parent of all scene objects
 * @explain[en] Object3D is the core node class of this scene graph, providing position, rotation, scale,
 * matrix transforms, hierarchical relationships (parent/children), ray casting, bounding box calculation, etc.
 * All visible objects (Mesh, Line, Points, Sprite, etc.) and containers (Group, Scene, etc.) inherit from this class.
 */
package three.scene.objects

import three.core.math.*
import three.rendering.buffer.*
import three.core.event.*
import three.core.interfaces.*
import three.core.interfaces.ILoadResult
import three.animation.interfaces.IAnimationClip
import three.rendering.interfaces.IGeometryProvider
import std.collection.*
import std.math.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*
import std.io.*

/**
 * @brief[zh-cn] 3D 对象基类，所有场景对象的父类
 * @explain[zh-cn] 提供位置、旋转、缩放、矩阵变换、层级关系、射线检测、包围盒计算等功能
 *
 * @brief[en] 3D object base class, parent of all scene objects
 * @explain[en] Provides position, rotation, scale, matrix transforms, hierarchical relationships, ray casting, bounding box calculation, etc.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; ignorePrivate = true]
public open class Object3D <: EventDispatcher & IFrustumCullable & IBox3Expandable & ILoadResult & IPropertyBindingRoot {
    @JsonIgnore
    private static var object3DId: Int64 = 0
    /**
     * @brief[zh-cn] 场景结构版本号（全局）
     * @explain[zh-cn] 任何对象的增删（add/remove/clear/attach）都会递增该版本。
     *               渲染器的空间索引据此判断缓存的对象列表与 BVH 是否失效，
     *               无需每帧遍历整棵场景树做结构比对。
     *
     * @brief[en] Global scene structure version
     * @explain[en] Any object insertion/removal (add/remove/clear/attach) increments this
     *               version. The renderer's spatial index uses it to detect whether the
     *               cached object list and BVH are stale, avoiding a full scene-graph
     *               walk every frame just to compare structure.
     */
    @JsonIgnore
    public static var structureVersion: Int64 = 0
    public var position: Vector3
    public var quaternion: Quaternion
    public var scale: Vector3
    public var modelViewMatrix: Matrix4
    public var normalMatrix: Matrix3
    public var matrix: Matrix4
    public var matrixWorld: Matrix4
    public var matrixAutoUpdate: Bool
    public var matrixWorldAutoUpdate: Bool
    public var matrixWorldNeedsUpdate: Bool
    public var layers: Layers
    public var visible: Bool
    public var children: ArrayList<Object3D>
    public var up: Vector3
    // kind 由 @JsonAdapter(polymorphic) 宏自动生成：多态类型判别 prop（返回类名），无需手写
    public var id: Int64
    public var uuid: String

    // IPropertyBindingRoot 接口实现（2026-08-20）：供 PropertyBinding 以接口持有节点引用
    public func getUuid(): String { return this.uuid }
    /** parent：与 children 构成循环引用，序列化忽略（与主流引擎惯例一致，由 add/remove 维护） */
    @JsonIgnore
    public var parent: Option<Object3D>
    public var name: String
    public var castShadow: Bool
    public var receiveShadow: Bool
    public var frustumCulled: Bool
    public var renderOrder: Float64
    /** animations：动画剪辑列表（接口类型 IAnimationClip），通过 @JsonCustom 自定义序列化 */
    public var animations: ArrayList<IAnimationClip>
    @JsonCustom["animations"]
    public open mut prop animationsJson: String {
        get() {
            // 默认实现：空数组，子类可覆盖
            "[]"
        }
        set(v) {
            // 默认实现：不恢复，子类可覆盖
        }
    }
    // userData：用户自定义数据容器（JSON 值）。2026-08-20 回退：删除 JsonValue 后改回 HashMap<String, Any>（fastjson 原方式）。
    // 通过 @JsonCustom 自定义序列化，将 HashMap 序列化为 JSON 字符串
    public var userData: HashMap<String, Any>
    @JsonCustom["userData"]
    public open mut prop userDataJson: String {
        get() {
            let stream = ByteBuffer()
            let writer = JsonStreamWriter(stream)
            JsonUtil.toModelStream(this.userData, writer)
            writer.flush()
            return String.fromUtf8(readToEnd(stream))
        }
        set(v) {
            this.userData = JsonUtil.streamFromJsonForHashMapAny(JsonStreamReader(ByteBuffer(v.toArray())))
        }
    }
    public var rotation: Euler
    public var pivot: Vector3
    public var isStatic: Bool
    /** customDepthMaterial/customDistanceMaterial：材质接口类型（IMaterial），通过 @JsonCustom 自定义序列化 */
    @JsonIgnore
    public var customDepthMaterial: Option<IMaterial>
    @JsonCustom["customDepthMaterial"]
    public open mut prop customDepthMaterialJson: String {
        get() {
            // 默认实现：null，子类可覆盖
            "null"
        }
        set(v) {
            // 默认实现：不恢复，子类可覆盖
        }
    }
    @JsonIgnore
    public var customDistanceMaterial: Option<IMaterial>
    @JsonCustom["customDistanceMaterial"]
    public open mut prop customDistanceMaterialJson: String {
        get() {
            // 默认实现：null，子类可覆盖
            "null"
        }
        set(v) {
            // 默认实现：不恢复，子类可覆盖
        }
    }

    // ===== 世界包围球缓存（视锥剔除用）=====
    // 缓存 getWorldBoundingSphere() 结果（[cx, cy, cz, radius]），matrixWorld 实际重算时置脏，
    // 避免 Renderer 每帧全场景剔除时重复 computeBoundingSphere（顶点遍历）+ applyMatrix4。
    // 对照主流渲染器：projectObject 每帧调用 frustum.intersectsObject → geometry.boundingSphere
    // （几何体侧缓存）+ Object3D.matrixWorld 变换；此处把两级缓存合并为对象级 [cx,cy,cz,r] 缓存。
    @JsonIgnore
    private var _worldBoundingSphereCache: Option<Array<Float64>>
    /** 缓存脏标记：matrixWorld 重算或手动 invalidateWorldBounds() 后置 true，下次取值时重算 */
    @JsonIgnore
    private var _worldBoundingSphereDirty: Bool
    /**
     * @brief[zh-cn] 世界包围球缓存是否已失效
     * @explain[zh-cn] 空间索引据此做增量更新：只有失效的对象才需要重新读取包围球，
     *               静态场景下每帧无需重算任何包围球。
     *
     * @brief[en] Whether the cached world bounding sphere is stale
     * @explain[en] The spatial index uses this for incremental updates: only stale
     *               objects need their bounds re-read, so a static scene recomputes
     *               no bounding spheres per frame.
     */
    @JsonIgnore
    public prop worldBoundingSphereDirty: Bool {
        get() { return this._worldBoundingSphereDirty }
    }
    /**
     * @brief[zh-cn] 本帧空间剔除结果（由渲染器的空间索引写入）
     * @explain[zh-cn] 空间索引用 BVH 批量回答"该对象是否落在视锥内"，把结果写在此标记上；
     *               场景树遍历据此跳过视锥外的对象，避免逐对象重复做 6 平面测试。
     *               默认 true（保守可见）：未被索引收录的对象（如本帧新增）不会被误剔除。
     *
     * @brief[en] This frame's spatial culling result (written by the renderer's spatial index)
     * @explain[en] The spatial index answers in bulk via the BVH whether the object falls
     *               inside the frustum and writes the result here; the scene-graph walk
     *               uses it to skip objects outside the frustum, avoiding a repeated
     *               6-plane test per object. Defaults to true (conservatively visible) so
     *               objects not covered by the index (e.g. newly added) are never wrongly
     *               culled.
     */
    @JsonIgnore
    public var cullVisible: Bool = true
    /**
     * @brief[zh-cn] 上次 compose 使用的局部变换分量（position 3 + quaternion 4 + scale 3 + pivot 3）
     * @explain[zh-cn] 变化检测用：局部变换未变时跳过矩阵 compose 与世界矩阵重算，
     *               静态场景下每帧每对象仅需十余次浮点比较。
     *
     * @brief[en] Local transform components used by the last compose
     *            (position 3 + quaternion 4 + scale 3 + pivot 3)
     * @explain[en] Used for change detection: when the local transform is unchanged,
     *               the matrix compose and the world matrix update are skipped, so a
     *               static scene costs only a dozen float comparisons per object.
     */
    @JsonIgnore
    private var _lastTransform: Array<Float64> = Array<Float64>(13, { _ => 0.0 })
    /**
     * @brief[zh-cn] 局部变换是否已参与过 compose（首次必须 compose）
     *
     * @brief[en] Whether the local transform has ever been composed (first call must compose)
     */
    @JsonIgnore
    private var _transformInited: Bool = false
    /**
     * @brief[zh-cn] 世界矩阵重算的临时缓冲（与旧值比较后才写回）
     * @explain[zh-cn] 重算结果先写入临时矩阵，与当前 matrixWorld 逐分量比较：
     *               真正变化才写回并失效世界包围球缓存，避免静态对象每帧重算包围球。
     *
     * @brief[en] Temporary buffer for the world matrix update (compared before being written back)
     * @explain[en] The recomputed matrix is written to a temporary buffer and compared
     *               component-wise with the current matrixWorld; only a real change is
     *               written back and invalidates the world bounding sphere cache.
     */
    @JsonIgnore
    private var _tmpWorldMatrix: Matrix4 = Matrix4()
    /**
     * @brief[zh-cn] 父级递归下传的上下文是否有效
     * @explain[zh-cn] 世界矩阵的递归必须经由虚方法 updateMatrixWorld 下发，因为子类
     *               会重写它做额外工作（相机逆矩阵、骨骼绑定矩阵、Helper 变换、
     *               音频空间化同步等）。父级在调用子级前把"父级世界矩阵本轮是否
     *               变化""父级是否为单位阵"写入上下文字段，子级消费一次后即失效，
     *               避免外部直接调用时误用陈旧上下文。
     *
     * @brief[en] Whether the context passed down by the parent recursion is still valid
     * @explain[en] The world-matrix recursion must go through the virtual method
     *               updateMatrixWorld, because subclasses override it to do extra work
     *               (camera inverse matrix, skinning bind matrix, helper transforms,
     *               audio spatialization sync). The parent writes "did the parent's
     *               world matrix change" and "is the parent the identity" into the
     *               context fields before calling the child; the child consumes them
     *               once and invalidates them, so an external direct call never uses
     *               stale context.
     */
    @JsonIgnore
    private var _ctxValid: Bool = false
    /**
     * @brief[zh-cn] 父级世界矩阵本轮是否变化
     *
     * @brief[en] Whether the parent's world matrix changed in this round
     */
    @JsonIgnore
    private var _ctxParentChanged: Bool = true
    /**
     * @brief[zh-cn] 父级世界矩阵是否为单位阵（单位阵时本节点世界矩阵 = 局部矩阵）
     *
     * @brief[en] Whether the parent's world matrix is the identity (then this node's world matrix equals its local matrix)
     */
    @JsonIgnore
    private var _ctxParentIsIdentity: Bool = false

    public init() {
        super()
        this.position = Vector3()
        // 用局部变量建立 Euler↔Quaternion 双向联动，避免捕获 this
        let rot = Euler()
        let quat = Quaternion()
        rot.onChange({ => quat.setFromEuler(rot) })
        quat.onChange({ => rot.setFromQuaternion(quat, rot.order, false) })
        this.rotation = rot
        this.quaternion = quat
        this.scale = Vector3(1.0, 1.0, 1.0)
        this.modelViewMatrix = Matrix4()
        this.normalMatrix = Matrix3()
        this.matrix = Matrix4()
        this.matrixWorld = Matrix4()
        this.matrixAutoUpdate = true
        this.matrixWorldNeedsUpdate = false
        this.layers = Layers()
        this.visible = true
        this.children = ArrayList<Object3D>()
        this.up = Vector3(0.0, 1.0, 0.0)
        // BUGFIX: this.id 永远为 0 导致 RenderObjects 缓存键冲突
        // 对照通用实现: Object.defineProperty(this, 'id', { value: _object3DId ++ })
        this.id = Object3D.object3DId
        this.parent = None
        this.name = ""
        this.castShadow = false
        this.receiveShadow = false
        this.frustumCulled = true
        this.renderOrder = 0.0
        this.animations = ArrayList<IAnimationClip>()
        this.userData = HashMap<String, Any>()
        this.matrixWorldAutoUpdate = true
        this.pivot = Vector3()
        this.isStatic = false
        this.uuid = "Object3D_" + object3DId.toString()
        Object3D.object3DId += 1
        this.customDepthMaterial = None
        this.customDistanceMaterial = None
        this._worldBoundingSphereCache = None
        this._worldBoundingSphereDirty = true
    }

    public open func add(child: Object3D): Object3D {
        if (refEq(child, this)) { return this }
        if (let Some(p) <- child.parent) {
            p.remove(child)
        }
        this.children.add(child)
        child.parent = Some(this)
        Object3D.structureVersion += 1
        child.dispatchEvent(Event("added"))
        this.dispatchEvent(Event("childadded"))
        return this
    }

    public open func remove(child: Object3D): Object3D {
        var i = 0
        while (i < this.children.size) {
            if (refEq(this.children[i], child)) {
                this.children.remove(i..i + 1)
                child.parent = None
                Object3D.structureVersion += 1
                child.dispatchEvent(Event("removed"))
                this.dispatchEvent(Event("childremoved"))
                return this
            }
            i += 1
        }
        return this
    }

    public func removeFromParent(): Unit {
        if (let Some(p) <- this.parent) {
            p.remove(this)
        }
    }

    public func clear(): Unit {
        for (child in this.children) {
            child.parent = None
        }
        this.children.clear()
        Object3D.structureVersion += 1
    }

    public func updateMatrix(): Unit {
        this.matrix.compose(this.position, this.quaternion, this.scale)
        let px = this.pivot.x; let py = this.pivot.y; let pz = this.pivot.z
        if (px != 0.0 || py != 0.0 || pz != 0.0) {
            let te = this.matrix.elements
            te[12] += px - te[0] * px - te[4] * py - te[8] * pz
            te[13] += py - te[1] * px - te[5] * py - te[9] * pz
            te[14] += pz - te[2] * px - te[6] * py - te[10] * pz
        }
        this.matrixWorldNeedsUpdate = true
    }

    /**
     * @brief[zh-cn] 变化检测版矩阵重算：局部变换未变化时跳过 compose
     * @explain[zh-cn] 渲染循环每帧对整棵场景树调用 updateMatrixWorld，静态场景下
     *               绝大多数对象的 position/quaternion/scale 没有任何变化——原实现
     *               每帧每对象都重算一次 compose（并把世界矩阵标脏，迫使剔除阶段
     *               每帧重算世界包围球）。此处先比较局部变换分量，未变则直接返回。
     * @return 是否实际执行了 compose
     *
     * @brief[en] Change-detecting matrix update: skips the compose when the local transform is unchanged
     * @explain[en] The render loop calls updateMatrixWorld on the whole scene tree every
     *               frame, yet in a static scene almost no object changes its
     *               position/quaternion/scale — the previous implementation recomposed
     *               every object every frame (and dirtied the world matrix, forcing the
     *               culling stage to recompute world bounding spheres). This compares the
     *               local transform components first and returns early when unchanged.
     * @return Whether a compose actually happened
     */
    private func updateMatrixIfChanged(): Bool {
        let p = this.position
        let q = this.quaternion
        let s = this.scale
        let pv = this.pivot
        if (this._transformInited) {
            let t = this._lastTransform
            if (t[0] == p.x && t[1] == p.y && t[2] == p.z &&
                t[3] == q.x && t[4] == q.y && t[5] == q.z && t[6] == q.w &&
                t[7] == s.x && t[8] == s.y && t[9] == s.z &&
                t[10] == pv.x && t[11] == pv.y && t[12] == pv.z) {
                return false
            }
        }
        this.updateMatrix()
        let t = this._lastTransform
        t[0] = p.x
        t[1] = p.y
        t[2] = p.z
        t[3] = q.x
        t[4] = q.y
        t[5] = q.z
        t[6] = q.w
        t[7] = s.x
        t[8] = s.y
        t[9] = s.z
        t[10] = pv.x
        t[11] = pv.y
        t[12] = pv.z
        this._transformInited = true
        return true
    }

    public open func updateMatrixWorld(force: Bool): Unit {
        // 上下文：父级递归下发时携带"父级世界矩阵本轮是否变化""父级是否为单位阵"；
        // 外部直接调用时无从得知父级状态 → 保守按"父级已变"处理。
        var parentChanged = true
        var parentIsIdentity = false
        if (this._ctxValid) {
            parentChanged = this._ctxParentChanged
            parentIsIdentity = this._ctxParentIsIdentity
            this._ctxValid = false
        } else {
            parentIsIdentity = this._parentWorldIsIdentity()
        }
        this._updateMatrixWorld(force, parentChanged, parentIsIdentity)
    }

    /**
     * @brief[zh-cn] 判断父节点的世界矩阵是否为单位阵
     * @explain[zh-cn] 父级世界矩阵为单位阵时，本节点的世界矩阵 = 局部矩阵，
     *               可跳过 4×4 矩阵乘法（16 元素比较 vs 64 乘 48 加）。
     *               直接读取父级 matrixWorld 元素判定，不缓存标志，
     *               外部直接改写 matrixWorld 也不会导致误判。
     *
     * @brief[en] Whether the parent's world matrix is the identity
     * @explain[en] When the parent's world matrix is the identity, this node's world
     *               matrix equals its local matrix, so the 4x4 multiply (64 multiplies,
     *               48 adds) can be replaced by a 16-element comparison. The check reads
     *               the parent's matrixWorld elements directly instead of caching a
     *               flag, so external writes to matrixWorld cannot cause a wrong answer.
     * @return[zh-cn] 父级世界矩阵是否为单位阵（无父级时为 true）
     *
     * @brief[en] Whether the parent's world matrix is the identity (true when there is no parent)
     */
    private func _parentWorldIsIdentity(): Bool {
        if (let Some(p) <- this.parent) {
            return p._isWorldMatrixIdentity()
        }
        return true
    }

    /**
     * @brief[zh-cn] 判断本节点的世界矩阵是否为单位阵
     *
     * @brief[en] Whether this node's world matrix is the identity
     */
    private func _isWorldMatrixIdentity(): Bool {
        let te = this.matrixWorld.elements
        return te[0] == 1.0 && te[1] == 0.0 && te[2] == 0.0 && te[3] == 0.0 &&
               te[4] == 0.0 && te[5] == 1.0 && te[6] == 0.0 && te[7] == 0.0 &&
               te[8] == 0.0 && te[9] == 0.0 && te[10] == 1.0 && te[11] == 0.0 &&
               te[12] == 0.0 && te[13] == 0.0 && te[14] == 0.0 && te[15] == 1.0
    }

    /**
     * @brief[zh-cn] 世界矩阵递归更新（内部实现，带变化判定）
     * @explain[zh-cn] parentChanged 表示父级的世界矩阵在本轮更新中确实发生了变化。
     *               只有"本地矩阵变了"或"父级世界矩阵变了"时才重算世界矩阵；重算
     *               结果先写入临时矩阵，与旧值逐分量比较，真正变化才写回并失效
     *               世界包围球缓存。静态场景下整棵子树每帧仅做浮点比较，
     *               既省掉矩阵乘法，也不再迫使剔除阶段每帧重算包围球。
     *
     * @brief[en] Recursive world-matrix update (internal, change-aware)
     * @explain[en] parentChanged tells whether the parent's world matrix actually
     *               changed in this round. The world matrix is recomputed only when
     *               the local matrix or the parent's world matrix changed; the result
     *               is written to a temporary matrix and compared component-wise with
     *               the current one, so only a real change is written back and
     *               invalidates the world bounding sphere cache. In a static scene the
     *               whole subtree costs only float comparisons per frame, saving both
     *               the matrix multiplication and the per-frame bounding sphere rebuild.
     *
     * @param[zh-cn] force 是否强制向下传播更新
     * @param[zh-cn] parentChanged 父级世界矩阵是否已变化
     * @param[zh-cn] parentIsIdentity 父级世界矩阵是否为单位阵（单位阵时世界矩阵 = 局部矩阵，可跳过 4×4 乘法）
     */
    private func _updateMatrixWorld(force: Bool, parentChanged: Bool, parentIsIdentity: Bool): Unit {
        // 外部置脏（helper/physics 直接改 matrix 后标记）也算本地矩阵可能已变
        let preDirty = this.matrixWorldNeedsUpdate
        // 本地矩阵是否变化：matrixAutoUpdate=false 的对象由外部直接改 matrix，保守按已变处理
        var localChanged = if (this.matrixAutoUpdate) {
            this.updateMatrixIfChanged()
        } else {
            true
        }
        if (preDirty) { localChanged = true }
        let needsUpdate = force || this.matrixWorldNeedsUpdate
        var worldChanged = false
        if (needsUpdate) {
            if (this.matrixWorldAutoUpdate) {
                if (localChanged || parentChanged) {
                    let tmp = this._tmpWorldMatrix
                    if (parentIsIdentity) {
                        // 父级为单位阵：世界矩阵 = 局部矩阵，省掉 64 乘 48 加的 4×4 乘法
                        tmp.copy(this.matrix)
                    } else {
                        if (let Some(p) <- this.parent) {
                            tmp.multiplyMatrices(p.matrixWorld, this.matrix)
                        } else {
                            tmp.copy(this.matrix)
                        }
                    }
                    // 真正变化才写回并失效世界包围球缓存
                    if (!this.matrixWorld.equals(tmp)) {
                        this.matrixWorld.copy(tmp)
                        this._worldBoundingSphereDirty = true
                        worldChanged = true
                    }
                }
            }
            this.matrixWorldNeedsUpdate = false
        }
        if (this.children.size > 0) {
            // 只有存在子节点时才需要判定自身世界矩阵是否为单位阵（叶子节点无人问津）
            let selfIsIdentity = this._isWorldMatrixIdentity()
            for (child in this.children) {
                // 必须经虚方法 updateMatrixWorld 下发：子类会重写它追加自身工作
                // （相机逆矩阵、骨骼绑定矩阵、Helper 变换、音频空间化同步等），
                // 直接调用私有实现会绕过这些重写。
                // 优化信息通过上下文字段传递，避免虚方法签名膨胀。
                child._ctxParentChanged = worldChanged
                child._ctxParentIsIdentity = selfIsIdentity
                child._ctxValid = true
                child.updateMatrixWorld(needsUpdate)
                child._ctxValid = false
            }
        }
    }

    public func lookAt(target: Vector3): Unit {
        this.updateWorldMatrix(true, false, false)
        let pos = Vector3(this.matrixWorld.elements[12], this.matrixWorld.elements[13], this.matrixWorld.elements[14])
        let m = Matrix4()
        m.lookAt(pos, target, this.up)
        this.quaternion.setFromRotationMatrix(m)
        // 【关键修正】Matrix4.lookAt 存储的旋转部分是 [x,y,z]^T（列主序下 x 轴 = (x.x, y.x, z.x)）。
        // setFromRotationMatrix 按列主序读取后得到的四元数对应转置后的旋转。
        // 共轭（negate xyz）后得到正确的世界朝向：相机右轴 = x, 上轴 = y, 前轴 = z。
        this.quaternion.x = -this.quaternion.x
        this.quaternion.y = -this.quaternion.y
        this.quaternion.z = -this.quaternion.z
        if (let Some(p) <- this.parent) {
            let pm = Matrix4().extractRotation(p.matrixWorld)
            let pq = Quaternion().setFromRotationMatrix(pm)
            this.quaternion.premultiply(pq.invert())
        }
        // 更新矩阵，将新的 quaternion 反映到 matrix 中
        this.updateMatrix()
    }

    public open func copy(source: Object3D, recursive: Bool): Object3D {
        this.name = source.name
        this.position.copy(source.position)
        this.quaternion.copy(source.quaternion)
        this.scale.copy(source.scale)
        this.modelViewMatrix.copy(source.modelViewMatrix)
        this.normalMatrix.copy(source.normalMatrix)
        this.matrix.copy(source.matrix)
        this.matrixWorld.copy(source.matrixWorld)
        this.matrixAutoUpdate = source.matrixAutoUpdate
        this.matrixWorldAutoUpdate = source.matrixWorldAutoUpdate
        this.matrixWorldNeedsUpdate = source.matrixWorldNeedsUpdate
        this.visible = source.visible
        this.castShadow = source.castShadow
        this.receiveShadow = source.receiveShadow
        this.frustumCulled = source.frustumCulled
        this.renderOrder = source.renderOrder
        this.up.copy(source.up)
        // kind 为宏生成的多态判别 prop（按实际类名虚分发），不可复制也无需复制
        this.layers = source.layers
        this.animations = source.animations
        
        // 仓颉侧：使用 cjfast_json 实现 userData 深拷贝
        this.userData = deepCopyUserData(source.userData)
        this.pivot = source.pivot
        this.isStatic = source.isStatic
        this.customDepthMaterial = source.customDepthMaterial
        this.customDistanceMaterial = source.customDistanceMaterial
        // 包围球缓存不随 copy 继承：源对象缓存基于其自身 matrixWorld，标记脏以安全重算
        this._worldBoundingSphereDirty = true
        if (recursive) {
            for (child in source.children) {
                this.add(child.clone())
            }
        }
        return this
    }

    public open func clone(): Object3D {
        let obj = Object3D()
        obj.copy(this, true)
        return obj
    }

    public func applyMatrix4(matrix: Matrix4): Unit {
        if (this.matrixAutoUpdate) { this.updateMatrix() }
        this.matrix.premultiply(matrix)
        this.matrix.decompose(this.position, this.quaternion, this.scale)
    }

    public func applyQuaternion(q: Quaternion): Unit {
        this.quaternion.premultiply(q)
        this.matrixWorldNeedsUpdate = true
    }

    public func setRotationFromAxisAngle(axis: Vector3, angle: Float64): Unit {
        this.quaternion.setFromAxisAngle(axis, angle)
    }

    public func setRotationFromEuler(euler: Euler): Unit {
        this.quaternion.setFromEuler(euler)
    }

    public func setRotationFromMatrix(m: Matrix4): Unit {
        this.quaternion.setFromRotationMatrix(m)
    }

    public func setRotationFromQuaternion(q: Quaternion): Unit {
        this.quaternion.copy(q)
    }

    public func rotateOnAxis(axis: Vector3, angle: Float64): Unit {
        let q = Quaternion().setFromAxisAngle(axis, angle)
        this.quaternion.multiply(q)
    }

    public func rotateOnWorldAxis(axis: Vector3, angle: Float64): Unit {
        let q = Quaternion().setFromAxisAngle(axis, angle)
        this.quaternion.copy(q.clone().multiply(this.quaternion))
    }

    public func rotateX(angle: Float64): Unit {
        this.rotateOnAxis(Vector3(1.0, 0.0, 0.0), angle)
    }

    public func rotateY(angle: Float64): Unit {
        this.rotateOnAxis(Vector3(0.0, 1.0, 0.0), angle)
    }

    public func rotateZ(angle: Float64): Unit {
        this.rotateOnAxis(Vector3(0.0, 0.0, 1.0), angle)
    }

    public func translateOnAxis(axis: Vector3, distance: Float64): Unit {
        let v = axis.clone().applyQuaternion(this.quaternion).multiplyScalar(distance)
        this.position.add(v)
    }

    public func translateX(distance: Float64): Unit {
        this.translateOnAxis(Vector3(1.0, 0.0, 0.0), distance)
    }

    public func translateY(distance: Float64): Unit {
        this.translateOnAxis(Vector3(0.0, 1.0, 0.0), distance)
    }

    public func translateZ(distance: Float64): Unit {
        this.translateOnAxis(Vector3(0.0, 0.0, 1.0), distance)
    }

    public func localToWorld(vector: Vector3): Vector3 {
        this.updateMatrixWorld(true)
        return vector.applyMatrix4(this.matrixWorld)
    }

    public func worldToLocal(vector: Vector3): Vector3 {
        this.updateMatrixWorld(true)
        let m = Matrix4().copy(this.matrixWorld).invert()
        return vector.applyMatrix4(m)
    }

    public func getObjectById(id: Int64): Option<Object3D> {
        if (this.id == id) { return Some(this) }
        for (child in this.children) {
            let result = child.getObjectById(id)
            if (let Some(obj) <- result) {
                return Some(obj)
            }
        }
        return None
    }

    public func getObjectByName(name: String): Option<Object3D> {
        if (this.name == name) { return Some(this) }
        for (child in this.children) {
            let result = child.getObjectByName(name)
            if (let Some(obj) <- result) {
                return Some(obj)
            }
        }
        return None
    }

    public func traverseAncestors(callback: (Object3D) -> Unit): Unit {
        if (let Some(p) <- this.parent) {
            callback(p)
            p.traverseAncestors(callback)
        }
    }

    public open func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit {
        if (updateParents) {
            if (let Some(p) <- this.parent) {
                p.updateWorldMatrix(true, false, force)
            }
        }
        if (this.matrixAutoUpdate || this.matrixWorldNeedsUpdate || force) {
            this.updateMatrix()
        }
        // BUG FIX: 更新 matrixWorld 从 matrix（updateWorldMatrix 的关键步骤）
        if (this.matrixWorldAutoUpdate) {
            if (let Some(p) <- this.parent) {
                this.matrixWorld.multiplyMatrices(p.matrixWorld, this.matrix)
            } else {
                this.matrixWorld.copy(this.matrix)
            }
            // matrixWorld 实际重算 → 世界包围球缓存失效
            this._worldBoundingSphereDirty = true
        }
        if (updateChildren) {
            for (child in this.children) {
                child.updateWorldMatrix(false, true, force)
            }
        }
    }

    public func getWorldPosition(target: Vector3): Vector3 {
        this.updateMatrixWorld(true)
        return target.set(this.matrixWorld.elements[12], this.matrixWorld.elements[13], this.matrixWorld.elements[14])
    }

    public func getWorldQuaternion(target: Quaternion): Quaternion {
        this.updateMatrixWorld(true)
        return target.setFromRotationMatrix(this.matrixWorld)
    }

    public func getWorldScale(target: Vector3): Vector3 {
        this.updateMatrixWorld(true)
        let te = this.matrixWorld.elements
        return target.set(Vector3(te[0], te[1], te[2]).length(), Vector3(te[4], te[5], te[6]).length(), Vector3(te[8], te[9], te[10]).length())
    }

    public open func getWorldDirection(target: Vector3): Vector3 {
        this.updateMatrixWorld(true)
        let te = this.matrixWorld.elements
        // 左手系：矩阵 Z 轴指向物体前方 +Z
        return target.set(te[8], te[9], te[10]).normalize()
    }

    public func attach(object: Object3D): Object3D {
        let m1 = Matrix4()
        this.updateWorldMatrix(true, false, false)
        m1.copy(this.matrixWorld).invert()
        if (object.parent.isSome()) {
            object.parent.getOrThrow().updateWorldMatrix(true, false, false)
            m1.multiply(object.parent.getOrThrow().matrixWorld)
        }
        object.applyMatrix4(m1)
        object.removeFromParent()
        object.parent = Some(this)
        this.children.add(object)
        Object3D.structureVersion += 1
        object.updateWorldMatrix(false, true, false)
        object.dispatchEvent(Event("added"))
        this.dispatchEvent(Event("childadded"))
        return this
    }

    public func getObjectsByProperty(name: String, value: Any, result: ArrayList<Object3D>): ArrayList<Object3D> {
        let propVal = this.getProperty(name)
        
        match (propVal) {
            case s1: String =>
                match (value) {
                    case s2: String => if (s1 == s2) { result.add(this) }
                    case _ => ()
                }
            case i1: Int64 =>
                match (value) {
                    case i2: Int64 => if (i1 == i2) { result.add(this) }
                    case f2: Float64 => if (Float64(i1) == f2) { result.add(this) }
                    case _ => ()
                }
            case f1: Float64 =>
                match (value) {
                    case f2: Float64 => if (f1 == f2) { result.add(this) }
                    case i2: Int64 => if (f1 == Float64(i2)) { result.add(this) }
                    case _ => ()
                }
            case _ => ()
        }
        for (child in this.children) { child.getObjectsByProperty(name, value, result) }
        return result
    }

    public open func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {}

    public func onBeforeShadow(): Unit {}
    public func onAfterShadow(): Unit {}
    public func onBeforeRender(): Unit {}
    public func onAfterRender(): Unit {}

    public func getProperty(name: String): Any {
        
        match (name) {
            case "id" => return this.id
            case "name" => return this.name
            case "uuid" => return this.uuid
            case "type" => return this.kind
            case _ => return 0
        }
    }

    public open func traverse(callback: (Object3D) -> Unit): Unit {
        callback(this)
        for (child in this.children) {
            child.traverse(callback)
        }
    }

    public func traverseVisible(callback: (Object3D) -> Unit): Unit {
        if (!this.visible) { return }
        callback(this)
        for (child in this.children) {
            child.traverseVisible(callback)
        }
    }

    public operator func ==(other: Object3D): Bool {
        return this.id == other.id
    }

    // ===== three.interfaces 接口实现 =====

    /**
     * 供裁剪/包围盒计算获取几何体的钩子
     * protected：仅供 Three.cj 内部（子类覆写、math 包经接口调用）
     * 默认无几何体；Mesh/Line/Points 等子类覆写返回 this.geometry
     */
    protected open func getCullingGeometry(): Option<IGeometryProvider> {
        return None
    }

    /**
     * @brief[zh-cn] 手动失效世界包围球缓存
     * @explain[zh-cn] 更换几何体、直接改写 geometry 顶点数据等绕过 updateMatrixWorld 的场景，
     * 需调用此方法强制下次 getWorldBoundingSphere() 重算，否则剔除可能使用过期包围球。
     *
     * @brief[en] Manually invalidate the world bounding sphere cache
     * @explain[en] When replacing geometry or writing vertex data directly (bypassing updateMatrixWorld),
     * call this to force getWorldBoundingSphere() to recompute, otherwise culling may use a stale sphere.
     */
    public func invalidateWorldBounds(): Unit {
        this._worldBoundingSphereDirty = true
    }

    /**
     * @return[zh-cn] Some([cx, cy, cz, radius]) 或 None（无几何体）
     * @return[en] Some([cx, cy, cz, radius]) or None (no geometry)
     *
     * 计算对象的世界空间包围球（带缓存：脏时重算，否则直接返回缓存值。
     * 前提是 matrixWorld 已是最新——渲染循环在收集前统一调用 updateMatrixWorld）
     * open：允许 Sprite 等子类覆写特殊包围球计算
     */
    public open func getWorldBoundingSphere(): Option<Array<Float64>> {
        if (!this._worldBoundingSphereDirty) {
            if (let Some(cached) <- this._worldBoundingSphereCache) {
                return Some(cached)
            }
        }
        if (let Some(geom) <- this.getCullingGeometry()) {
            geom.computeBoundingSphere()
            if (let Some(s) <- geom.getBoundingSphere()) {
                // 零分配重算：原实现每帧每对象 new Sphere + new Vector3 + new Array(4)
                // （800 对象场景 = 每帧 2400 次堆分配，剔除阶段的主要开销）。
                // 此处按 Sphere.applyMatrix4 的语义直接展开变换：
                //   中心 = matrixWorld * center（含 w 除法），半径 *= 第一列长度。
                // 结果就地写入已缓存的数组，不再分配新数组。
                let e = this.matrixWorld.elements
                let cx = s.center.x
                let cy = s.center.y
                let cz = s.center.z
                let w = 1.0 / (e[3] * cx + e[7] * cy + e[11] * cz + e[15])
                let tx = (e[0] * cx + e[4] * cy + e[8] * cz + e[12]) * w
                let ty = (e[1] * cx + e[5] * cy + e[9] * cz + e[13]) * w
                let tz = (e[2] * cx + e[6] * cy + e[10] * cz + e[14]) * w
                let sx = e[0]
                let sy = e[1]
                let sz = e[2]
                let radius = s.radius * sqrt(sx * sx + sy * sy + sz * sz)
                if (let Some(buf) <- this._worldBoundingSphereCache) {
                    buf[0] = tx
                    buf[1] = ty
                    buf[2] = tz
                    buf[3] = radius
                } else {
                    this._worldBoundingSphereCache = Some([tx, ty, tz, radius])
                }
                this._worldBoundingSphereDirty = false
                return this._worldBoundingSphereCache
            } else {
                return None
            }
        } else {
            return None
        }
    }

    /**
     * @return[zh-cn] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) 或 None（无几何体）
     * @return[en] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) or None (no geometry)
     *
     * 计算对象自身（不含子对象）的世界空间包围盒
     */
    public func getWorldBoundingBox(): Option<(Array<Float64>, Array<Float64>)> {
        if (let Some(geom) <- this.getCullingGeometry()) {
            geom.computeBoundingBox()
            if (let Some(bb) <- geom.getBoundingBox()) {
                // 保守变换：Box3.applyMatrix4 变换全部 8 个角点再取 min/max，
                // 旋转/缩放下结果仍是"包含变换后几何体的轴对齐盒"。
                // 此前只变换 min/max 两个角点，旋转物体下得到的 AABB 偏小（非保守），剔除会误删。
                let box = Box3(Vector3().copy(bb.min), Vector3().copy(bb.max)).applyMatrix4(this.matrixWorld)
                return Some(([box.min.x, box.min.y, box.min.z], [box.max.x, box.max.y, box.max.z]))
            } else {
                return None
            }
        } else {
            return None
        }
    }

    /**
     * @return[zh-cn] 子对象数量
     * @return[en] Number of child objects
     *
     * 子对象数量
     */
    public func getChildCount(): Int64 {
        return this.children.size
    }

    /**
     * @param[zh-cn] i 子对象索引
     * @return[zh-cn] 子对象（Object3D 实现了 IBox3Expandable）
     * @param[en] i Child object index
     * @return[en] Child object (Object3D implements IBox3Expandable)
     *
     * 第 i 个子对象
     */
    public func getChildAt(i: Int64): IBox3Expandable {
        return this.children[i]
    }

    /**
     * @return[zh-cn] 顶点数（0 表示不支持精确遍历）
     * @return[en] Vertex count (0 means precise traversal is not supported)
     *
     * 精确模式逐顶点遍历的顶点数
     * open：允许 Mesh 覆写（排除 InstancedMesh）
     * 返回 position 属性顶点数；无几何体/无 position 属性返回 0
     */
    public open func getPreciseVertexCount(): Int64 {
        if (let Some(geom) <- this.getCullingGeometry()) {
            if (let Some(attr) <- geom.getAttributeReader("position")) {
                return attr.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }

    /**
     * @param[zh-cn] i 顶点索引
     * @return[zh-cn] 世界空间坐标 [x, y, z]
     * @param[en] i Vertex index
     * @return[en] World-space coordinates [x, y, z]
     *
     * 第 i 个顶点的世界空间位置
     * 基类默认直接读 position 属性（无 morph/skin）；Mesh 覆写以应用蒙皮/变形
     */
    public open func getPreciseVertexPosition(i: Int64): Array<Float64> {
        if (let Some(geom) <- this.getCullingGeometry()) {
            if (let Some(attr) <- geom.getAttributeReader("position")) {
                let v = Vector3().fromBufferAttribute(attr, i).applyMatrix4(this.matrixWorld)
                return [v.x, v.y, v.z]
            } else {
                return [0.0, 0.0, 0.0]
            }
        } else {
            return [0.0, 0.0, 0.0]
        }
    }
}

/**
 * @param[zh-cn] source 源 userData
 * @return[zh-cn] 深拷贝后的新 HashMap
 * @param[en] source Source userData
 * @return[en] Deep-copied new HashMap
 *
 * 深拷贝 userData HashMap
 */
public func deepCopyUserData(source: HashMap<String, Any>): HashMap<String, Any> {
    let result = HashMap<String, Any>()
    for ((k, v) in source) {
        result.add(k, v)
    }
    return result
}