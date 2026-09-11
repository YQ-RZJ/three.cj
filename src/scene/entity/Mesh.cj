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
 * @file[zh-cn] Mesh
 * @brief[zh-cn] 网格渲染对象，3D 场景中最常用的三角形面片渲染实体
 * @explain[zh-cn] 网格由 BufferGeometry（顶点/索引）和 Material（着色参数）组成，
 * 支持 morphTarget 变形动画和射线相交检测（raycast）。继承 Object3D 并实现 IMesh 接口。
 *
 * @file[en] Mesh
 * @brief[en] Mesh rendering object, the most commonly used triangle face rendering entity in 3D scenes
 * @explain[en] A mesh consists of BufferGeometry (vertices/indices) and Material (shading parameters),
 * supporting morphTarget animation and ray intersection testing (raycast). Extends Object3D and implements IMesh.
 */
package three.scene.entity

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.rendering.interfaces.IGeometryProvider
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.rendering.cameras.*
import three.scene.interfaces.IMesh
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 网格渲染对象，3D 场景中最常用的三角形面片渲染实体
 * @explain[zh-cn] 由 BufferGeometry 和 Material 组成，支持 morphTarget 变形动画和射线相交检测
 *
 * @brief[en] Mesh rendering object, the most commonly used triangle face rendering entity in 3D scenes
 * @explain[en] Consists of BufferGeometry and Material, supporting morphTarget animation and ray intersection testing
 */
@JsonAdapter[polymorphic = true ; withSuperClass = Object3D]
public open class Mesh <: Object3D & IMesh {
    /**
     * @brief[zh-cn] 顶点/索引几何
     *
     * @brief[en] Vertex/index geometry
     */
    public var geometry: BufferGeometry
    /**
     * @brief[zh-cn] 材质
     *
     * @brief[en] Material
     */
    public var material: Material
    /**
     * @brief[zh-cn] morph target 名称→索引字典（动画混合形状）
     *
     * @brief[en] morph target name→index dictionary (animation blend shapes)
     */
    public var morphTargetDictionary: HashMap<String, Int64>
    /**
     * @brief[zh-cn] morph target 影响系数数组
     *
     * @brief[en] morph target influence coefficients array
     */
    public var morphTargetInfluences: Array<Float64>
    /**
     * @brief[zh-cn] 实例计数（InstancedMesh 使用）
     *
     * @brief[en] Instance count (used by InstancedMesh)
     */
    public var count: Int64

    /**
     * @brief[zh-cn] 构造一个新的网格
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 材质，默认空 Material
     *
     * @brief[en] Construct a new mesh
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Material, default empty Material
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = Material()) {
        super()
        this.geometry = geometry
        this.material = material
        this.morphTargetDictionary = HashMap<String, Int64>()
        this.morphTargetInfluences = Array<Float64>()
        this.count = 1
    }

    /**
     * @brief[zh-cn] 将给定网格实例的值复制到本实例
     * @param[zh-cn] source 源网格
     * recursive 是否递归复制子对象
     * @return[zh-cn] 返回 this
     *
     * @brief[en] Copy values from the given mesh instance to this instance
     * @param[en] source Source mesh
     * recursive Whether to recursively copy children
     * @return[en] Returns this
     */
    public func copy(source: Mesh, recursive!: Bool = true): Mesh {
        super.copy(source, recursive)
        this.geometry = source.geometry.clone()
        this.material = source.material.clone()
        return this
    }

    /**
     * @brief[zh-cn] 更新 morph target 字典与影响系数
     *
     * @brief[en] Update morph target dictionary and influence coefficients
     */
    public open func updateMorphTargets(): Unit {
        let morphAttributes = this.geometry.attributes
        if (morphAttributes.contains("morphTarget0")) {
            let dict = HashMap<String, Int64>()
            var i = 0
            while (morphAttributes.contains("morphTarget" + i.toString())) {
                dict.add("morphTarget" + i.toString(), i)
                i += 1
            }
            this.morphTargetDictionary = dict
            this.morphTargetInfluences = Array<Float64>(i, { _ => 0.0 })
        }
    }

    /**
     * @brief[zh-cn] 获取指定顶点位置
     * @param[zh-cn] index 顶点索引
     * target 接收结果的目标向量
     * @return[zh-cn] 顶点位置
     *
     * @brief[en] Get the position of the specified vertex
     * @param[en] index Vertex index
     * target Target vector to receive the result
     * @return[en] Vertex position
     */
    public open func getVertexPosition(index: Int64, target: Vector3): Vector3 {
        let posOpt = this.geometry.getAttribute("position")
        match (posOpt) {
            case Some(attr) => return target.set(attr.getX(index), attr.getY(index), attr.getZ(index))
            case None => return target
        }
    }

    /**
     * @brief[zh-cn] 视锥剔除测试
     * @param[zh-cn] frustum 视锥体
     * @return[zh-cn] 与视锥相交返回 true
     *
     * @brief[en] Frustum culling test
     * @param[en] frustum The frustum
     * @return[en] Returns true if intersects with frustum
     */
    public func intersectsFrustum(frustum: Frustum): Bool {
        return frustum.intersectsObject(this)
    }

    /**
     * @brief[zh-cn] 射线相交检测
     * @param[zh-cn] raycaster 射线发射器
     * intersects 命中结果累加数组
     *
     * @brief[en] Ray intersection test
     * @param[en] raycaster The raycaster
     * intersects Intersection result accumulator
     */
    public open func raycast(raycaster: Raycaster, intersects: ArrayList<Intersection>): Unit {
        let geometry = this.geometry
        let matrixWorld = this.matrixWorld

        // bounding sphere test in world space
        let sphere = Sphere()
        match (geometry.boundingSphere) {
            case Some(bs) => sphere.copy(bs)
            case None => return
        }
        sphere.applyMatrix4(matrixWorld)

        let ray = Ray()
        ray.copy(raycaster.ray)
        if (sphere.containsPoint(ray.origin) == false) {
            let hit = ray.intersectSphere(sphere, Vector3())
            match (hit) {
                case Some(pt) =>
                    let distSq = ray.origin.distanceToSquared(pt)
                    let farSq = (raycaster.far - raycaster.near)
                    if (distSq > farSq * farSq) { return }
                case None => return
            }
        }

        // transform ray to local space
        let invMatrix = Matrix4().copy(matrixWorld).invert()
        ray.copy(raycaster.ray)
        // apply inverse matrix to ray origin and direction
        ray.origin.applyMatrix4(invMatrix)
        // 方向只旋转不平移（applyMatrix4 含平移会污染方向——矩阵更新后导致相交失败）
        ray.direction.transformDirection(invMatrix)

        // bounding box test in local space
        match (geometry.boundingBox) {
            case Some(box) =>
                if (box.isEmpty() == false) {
                    let boxHit = ray.intersectBox(box, Vector3())
                    match (boxHit) {
                        case None => return
                        case Some(_) => ()
                    }
                }
            case None => ()
        }

        // triangle intersection
        let posOpt = geometry.getAttribute("position")
        let indexAttrOpt = geometry.index
        match (posOpt) {
            case Some(posAttr) =>
                if (posAttr.count < 3) { return }
                let (triCount, useIndex) = match (indexAttrOpt) {
                    case Some(idxAttr) => (idxAttr.count / 3, true)
                    case None => (posAttr.count / 3, false)
                }
                for (i in 0..triCount) {
                    let a: Int64; let b: Int64; let c: Int64
                    if (useIndex) {
                        match (indexAttrOpt) {
                            case Some(idxAttr) =>
                                a = Int64(idxAttr.getX(i * 3))
                                b = Int64(idxAttr.getX(i * 3 + 1))
                                c = Int64(idxAttr.getX(i * 3 + 2))
                            case None => continue
                        }
                    } else {
                        a = i * 3; b = i * 3 + 1; c = i * 3 + 2
                    }
                    
                    let pA = Vector3()
                    let pB = Vector3()
                    let pC = Vector3()
                    this.getVertexPosition(a, pA)
                    this.getVertexPosition(b, pB)
                    this.getVertexPosition(c, pC)
                    let tri = Triangle(pA, pB, pC)
                    
                    let side = match (this.material) { case m: Material => m.side; case _ => 0 }
                    let hitPoint = if (side == 1) {
                        ray.intersectTriangle(pC, pB, pA, true, Vector3())
                    } else {
                        ray.intersectTriangle(pA, pB, pC, (side == 0), Vector3())
                    }
                    match (hitPoint) {
                        case Some(pt) =>
                            // world space intersection point
                            let worldPt = pt.clone().applyMatrix4(matrixWorld)
                            let dist = raycaster.ray.origin.distanceTo(worldPt)
                            if (dist < raycaster.near || dist > raycaster.far) {
                                continue
                            }
                            
                            let barycoord = Vector3()
                            tri.getBarycoord(pt, barycoord)
                            // uv/uv1/normal 插值（对照 JS Triangle.getInterpolatedAttribute）
                            var uvVal: ?Vector2 = None
                            match (geometry.getAttribute("uv")) {
                                case Some(uvAttr) =>
                                    let uA = Vector3(uvAttr.getX(a), uvAttr.getY(a), 0.0)
                                    let uB = Vector3(uvAttr.getX(b), uvAttr.getY(b), 0.0)
                                    let uC = Vector3(uvAttr.getX(c), uvAttr.getY(c), 0.0)
                                    let uvTarget = Vector3()
                                    match (tri.getInterpolation(pt, uA, uB, uC, uvTarget)) {
                                        case Some(_) => uvVal = Some(Vector2(uvTarget.x, uvTarget.y))
                                        case None => ()
                                    }
                                case None => ()
                            }
                            var uv1Val: ?Vector2 = None
                            match (geometry.getAttribute("uv1")) {
                                case Some(uv1Attr) =>
                                    let uA = Vector3(uv1Attr.getX(a), uv1Attr.getY(a), 0.0)
                                    let uB = Vector3(uv1Attr.getX(b), uv1Attr.getY(b), 0.0)
                                    let uC = Vector3(uv1Attr.getX(c), uv1Attr.getY(c), 0.0)
                                    let uvTarget = Vector3()
                                    match (tri.getInterpolation(pt, uA, uB, uC, uvTarget)) {
                                        case Some(_) => uv1Val = Some(Vector2(uvTarget.x, uvTarget.y))
                                        case None => ()
                                    }
                                case None => ()
                            }
                            var normalVal: ?Vector3 = None
                            match (geometry.getAttribute("normal")) {
                                case Some(nAttr) =>
                                    let nA = Vector3(nAttr.getX(a), nAttr.getY(a), nAttr.getZ(a))
                                    let nB = Vector3(nAttr.getX(b), nAttr.getY(b), nAttr.getZ(b))
                                    let nC = Vector3(nAttr.getX(c), nAttr.getY(c), nAttr.getZ(c))
                                    let nTarget = Vector3()
                                    match (tri.getInterpolation(pt, nA, nB, nC, nTarget)) {
                                        case Some(_) =>
                                            
                                            if (nTarget.dot(ray.direction) > 0.0) {
                                                nTarget.multiplyScalar(-1.0)
                                            }
                                            normalVal = Some(nTarget)
                                        case None => ()
                                    }
                                case None => ()
                            }
                            // face: { a, b, c, normal, materialIndex }
                            let faceNormal = Vector3()
                            tri.getNormal(faceNormal)
                            let face = Face(a: a, b: b, c: c, normal: faceNormal, materialIndex: 0)
                            // 构建完整 Intersection
                            let intersection = Intersection()
                            intersection.distance = dist
                            intersection.point = worldPt
                            intersection.obj = Some(this)
                            intersection.faceIndex = i
                            intersection.uv = uvVal
                            intersection.uv1 = uv1Val
                            intersection.normal = normalVal
                            intersection.barycoord = Some(barycoord)
                            intersection.face = Some(face)
                            intersects.add(intersection)
                        case None => ()
                    }
                }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 提供本网格几何体供裁剪/包围盒计算（覆写 Object3D 钩子）
     * @return[zh-cn] 本网格几何体
     *
     * @brief[en] Provide this mesh geometry for culling/bounding box calculation (overrides Object3D hook)
     * @return[en] This mesh geometry
     */
    public override func getCullingGeometry(): Option<IGeometryProvider> {
        return Some(this.geometry)
    }

    /**
     * @brief[zh-cn] 精确模式逐顶点遍历的顶点数（覆写 Object3D）
     * @explain[zh-cn] precise 分支要求非 InstancedMesh（InstancedMesh 走保守路径）
     * @return[zh-cn] 顶点数（InstancedMesh/无 position 属性返回 0）
     *
     * @brief[en] Vertex count for precise mode per-vertex traversal (overrides Object3D)
     * @explain[en] precise branch requires non-InstancedMesh (InstancedMesh uses conservative path)
     * @return[en] Vertex count (returns 0 for InstancedMesh or missing position attribute)
     */
    public override func getPreciseVertexCount(): Int64 {
        
        if (this is InstancedMesh) {
            return 0
        }
        return super.getPreciseVertexCount()
    }

    /**
     * @brief[zh-cn] 第 i 个顶点的世界空间位置（覆写 Object3D）
     * @explain[zh-cn] 基类默认直接读 position 属性（无 morph/skin）；Mesh 覆写以应用蒙皮/变形
     * @param[zh-cn] i 顶点索引
     * @return[zh-cn] 世界空间坐标 [x, y, z]
     *
     * @brief[en] World space position of vertex i (overrides Object3D)
     * @explain[en] Base class reads position attribute directly (no morph/skin); Mesh overrides to apply skinning/morphing
     * @param[en] i Vertex index
     * @return[en] World space coordinates [x, y, z]
     */
    public override func getPreciseVertexPosition(i: Int64): Array<Float64> {
        let v = Vector3()
        this.getVertexPosition(i, v)
        v.applyMatrix4(this.matrixWorld)
        return [v.x, v.y, v.z]
    }
}

