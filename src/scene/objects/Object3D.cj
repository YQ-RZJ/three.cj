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
 * @explain[zh-cn] Object3D 是 Three.js 场景图的核心节点类，提供位置、旋转、缩放、矩阵变换、
 * 层级关系（parent/children）、射线检测、包围盒计算等功能。
 * 所有可见对象（Mesh、Line、Points、Sprite 等）和容器（Group、Scene 等）均继承此类。
 *
 * @file[en] Object3D
 * @brief[en] 3D object base class, parent of all scene objects
 * @explain[en] Object3D is the core node class of the Three.js scene graph, providing position, rotation, scale,
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
    /** parent：与 children 构成循环引用，序列化忽略（与 three.js 一致，由 add/remove 维护） */
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
        // 对照 Three.js: Object.defineProperty(this, 'id', { value: _object3DId ++ })
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
    }

    public open func add(child: Object3D): Object3D {
        if (refEq(child, this)) { return this }
        match (child.parent) {
            case Some(p) => p.remove(child)
            case None => ()
        }
        this.children.add(child)
        child.parent = Some(this)
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
                child.dispatchEvent(Event("removed"))
                this.dispatchEvent(Event("childremoved"))
                return this
            }
            i += 1
        }
        return this
    }

    public func removeFromParent(): Unit {
        match (this.parent) {
            case Some(p) => p.remove(this)
            case None => ()
        }
    }

    public func clear(): Unit {
        for (child in this.children) {
            child.parent = None
        }
        this.children.clear()
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

    public open func updateMatrixWorld(force: Bool): Unit {
        if (this.matrixAutoUpdate) { this.updateMatrix() }
        let needsUpdate = force || this.matrixWorldNeedsUpdate
        if (needsUpdate) {
            if (this.matrixWorldAutoUpdate) {
                match (this.parent) {
                    case Some(p) => this.matrixWorld.multiplyMatrices(p.matrixWorld, this.matrix)
                    case None => this.matrixWorld.copy(this.matrix)
                }
            }
            this.matrixWorldNeedsUpdate = false
        }
        for (child in this.children) {
            child.updateMatrixWorld(needsUpdate)
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
        match (this.parent) {
            case Some(p) =>
                let pm = Matrix4().extractRotation(p.matrixWorld)
                let pq = Quaternion().setFromRotationMatrix(pm)
                this.quaternion.premultiply(pq.invert())
            case None => ()
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
            match (result) {
                case Some(obj) => return Some(obj)
                case None => ()
            }
        }
        return None
    }

    public func getObjectByName(name: String): Option<Object3D> {
        if (this.name == name) { return Some(this) }
        for (child in this.children) {
            let result = child.getObjectByName(name)
            match (result) {
                case Some(obj) => return Some(obj)
                case None => ()
            }
        }
        return None
    }

    public func traverseAncestors(callback: (Object3D) -> Unit): Unit {
        match (this.parent) {
            case Some(p) =>
                callback(p)
                p.traverseAncestors(callback)
            case None => ()
        }
    }

    public open func updateWorldMatrix(updateParents: Bool, updateChildren: Bool, force: Bool): Unit {
        if (updateParents) {
            match (this.parent) {
                case Some(p) => p.updateWorldMatrix(true, false, force)
                case None => ()
            }
        }
        if (this.matrixAutoUpdate || this.matrixWorldNeedsUpdate || force) {
            this.updateMatrix()
        }
        // BUG FIX: 更新 matrixWorld 从 matrix（Three.js 中 updateWorldMatrix 的关键步骤）
        if (this.matrixWorldAutoUpdate) {
            match (this.parent) {
                case Some(p) => this.matrixWorld.multiplyMatrices(p.matrixWorld, this.matrix)
                case None => this.matrixWorld.copy(this.matrix)
            }
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
     * @return[zh-cn] Some([cx, cy, cz, radius]) 或 None（无几何体）
     * @return[en] Some([cx, cy, cz, radius]) or None (no geometry)
     *
     * 计算对象的世界空间包围球
     * open：允许 Sprite 等子类覆写特殊包围球计算
     */
    public open func getWorldBoundingSphere(): Option<Array<Float64>> {
        match (this.getCullingGeometry()) {
            case Some(geom) =>
                geom.computeBoundingSphere()
                match (geom.getBoundingSphere()) {
                    case Some(s) =>
                        
                        let sphere = Sphere().copy(s).applyMatrix4(this.matrixWorld)
                        return Some([sphere.center.x, sphere.center.y, sphere.center.z, sphere.radius])
                    case None => None
                }
            case None => None
        }
    }

    /**
     * @return[zh-cn] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) 或 None（无几何体）
     * @return[en] Some(([minX,minY,minZ], [maxX,maxY,maxZ])) or None (no geometry)
     *
     * 计算对象自身（不含子对象）的世界空间包围盒
     */
    public func getWorldBoundingBox(): Option<(Array<Float64>, Array<Float64>)> {
        match (this.getCullingGeometry()) {
            case Some(geom) =>
                geom.computeBoundingBox()
                match (geom.getBoundingBox()) {
                    case Some(bb) =>
                        
                        let minW = Vector3().copy(bb.min).applyMatrix4(this.matrixWorld)
                        let maxW = Vector3().copy(bb.max).applyMatrix4(this.matrixWorld)
                        return Some(([minW.x, minW.y, minW.z], [maxW.x, maxW.y, maxW.z]))
                    case None => None
                }
            case None => None
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
        match (this.getCullingGeometry()) {
            case Some(geom) =>
                match (geom.getAttributeReader("position")) {
                    case Some(attr) => return attr.count
                    case None => return 0
                }
            case None => return 0
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
        match (this.getCullingGeometry()) {
            case Some(geom) =>
                match (geom.getAttributeReader("position")) {
                    case Some(attr) =>
                        let v = Vector3().fromBufferAttribute(attr, i).applyMatrix4(this.matrixWorld)
                        return [v.x, v.y, v.z]
                    case None => return [0.0, 0.0, 0.0]
                }
            case None => return [0.0, 0.0, 0.0]
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