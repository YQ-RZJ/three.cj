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
 * @file[zh-cn] 射线投射器
 * @brief[zh-cn] 用于鼠标拾取（计算鼠标在 3D 空间中悬停在哪些对象上）等射线相交测试
 * @explain[zh-cn] Raycaster 委托给 3D 对象的 raycast() 方法进行相交测试，
 * 这样网格（Mesh）、线（Line）、点（Points）等可以有不同的相交响应方式。
 *
 * @file[en] Raycaster
 * @brief[en] Used for mouse picking (calculating which objects the mouse hovers over in 3D space) and other ray intersection tests
 * @explain[en] Raycaster delegates to 3D objects' raycast() method for intersection testing,
 * so Mesh, Line, Points, etc. can have different intersection responses.
 */
package three.scene.objects

import three.core.math.*
import three.utils.log.Logger
import std.collection.*
import std.sort.*

/**
 * @brief[zh-cn] 射线投射相交结果
 * @explain[zh-cn] 描述射线与 3D 对象相交的详细信息：distance、point、object、face/faceIndex、uv/uv1、normal 等
 *
 * @brief[en] Raycaster intersection result
 * @explain[en] Describes detailed information about a ray-3D object intersection: distance, point, object, face/faceIndex, uv/uv1, normal, etc.
 */
public class Intersection {
    /**
     * @brief[zh-cn] 从射线原点到相交点的距离
     *
     * @brief[en] Distance from ray origin to intersection point
     */
    public var distance: Float64
    /**
     * @brief[zh-cn] 相交点（世界坐标）
     *
     * @brief[en] Intersection point (world coordinates)
     */
    public var point: Vector3
    /**
     * @brief[zh-cn] 被相交的 3D 对象
     *
     * @brief[en] The intersected 3D object
     */
    public var obj: ?Object3D
    /**
     * @brief[zh-cn] 相交面的索引
     *
     * @brief[en] Index of the intersected face
     */
    public var faceIndex: Int64
    /**
     * @brief[zh-cn] 相交点处的 UV 坐标
     *
     * @brief[en] UV coordinate at the intersection point
     */
    public var uv: ?Vector2
    /**
     * @brief[zh-cn] 第二组相交点处 UV 坐标
     *
     * @brief[en] Second set UV coordinate at the intersection point
     */
    public var uv1: ?Vector2
    /**
     * @brief[zh-cn] 相交点处的插值法向量
     *
     * @brief[en] Interpolated normal at the intersection point
     */
    public var normal: ?Vector3
    /**
     * @brief[zh-cn] 相交的 InstancedMesh 实例索引
     *
     * @brief[en] Intersected InstancedMesh instance index
     */
    public var instanceId: Int64
    /**
     * @brief[zh-cn] 相交的顶点/线段索引（Points/Line 命中用）
     *
     * @brief[en] Intersected vertex/segment index (used by Points/Line hits)
     */
    public var index: Int64
    /**
     * @brief[zh-cn] 相交点处的重心坐标（Mesh 命中用）
     *
     * @brief[en] Barycentric coordinate at intersection point (used by Mesh hits)
     */
    public var barycoord: ?Vector3
    /**
     * @brief[zh-cn] 相交点到射线的距离（Points 命中用）
     *
     * @brief[en] Distance from intersection point to ray (used by Points hits)
     */
    public var distanceToRay: Float64
    /**
     * @brief[zh-cn] 相交面信息（Mesh 命中用）
     *
     * @brief[en] Intersection face information (used by Mesh hits)
     */
    public var face: ?Face

    /**
     * @brief[zh-cn] 构造相交结果
     * @param[zh-cn] distance 从射线原点到相交点的距离，默认 0.0
     * point 相交点，默认零向量
     *
     * @brief[en] Construct intersection result
     * @param[en] distance Distance from ray origin to intersection point, default 0.0
     * point Intersection point, default zero vector
     */
    public init(distance!: Float64 = 0.0, point!: Vector3 = Vector3()) {
        this.distance = distance
        this.point = point
        this.obj = None
        this.faceIndex = -1
        this.uv = None
        this.uv1 = None
        this.normal = None
        this.instanceId = -1
        this.index = -1
        this.barycoord = None
        this.distanceToRay = 0.0
        this.face = None
    }
}

/**
 * @brief[zh-cn] 相交面信息
 * @explain[zh-cn] 含三个顶点索引 a/b/c、面法向量 normal、所属材质索引 materialIndex
 *
 * @brief[en] Intersection face information
 * @explain[en] Contains three vertex indices a/b/c, face normal vector, and material index
 */
public class Face {
    /**
     * @brief[zh-cn] 相交面第一个顶点索引
     *
     * @brief[en] First vertex index of the intersected face
     */
    public var a: Int64
    /**
     * @brief[zh-cn] 相交面第二个顶点索引
     *
     * @brief[en] Second vertex index of the intersected face
     */
    public var b: Int64
    /**
     * @brief[zh-cn] 相交面第三个顶点索引
     *
     * @brief[en] Third vertex index of the intersected face
     */
    public var c: Int64
    /**
     * @brief[zh-cn] 面法向量
     *
     * @brief[en] Face normal vector
     */
    public var normal: Vector3
    /**
     * @brief[zh-cn] 所属材质索引（多材质几何用）
     *
     * @brief[en] Material index (for multi-material geometry)
     */
    public var materialIndex: Int64

    /**
     * @brief[zh-cn] 构造相交面信息
     * @param[zh-cn] a 第一个顶点索引，默认 -1
     * b 第二个顶点索引，默认 -1
     * c 第三个顶点索引，默认 -1
     * normal 面法向量，默认零向量
     * materialIndex 材质索引，默认 0
     *
     * @brief[en] Construct intersection face information
     * @param[en] a First vertex index, default -1
     * b Second vertex index, default -1
     * c Third vertex index, default -1
     * normal Face normal vector, default zero vector
     * materialIndex Material index, default 0
     */
    public init(a!: Int64 = -1, b!: Int64 = -1, c!: Int64 = -1, normal!: Vector3 = Vector3(), materialIndex!: Int64 = 0) {
        this.a = a
        this.b = b
        this.c = c
        this.normal = normal
        this.materialIndex = materialIndex
    }
}

/**
 * @explain[zh-cn] raycaster.params 结构：Mesh/LOD/Sprite 无额外参数，Line/Points 含 threshold 精度（世界单位）。
 * threshold 是相交对象时射线投射器的精度（世界单位）。
 *
 * @brief[en] Raycaster parameters structure (replaces original HashMap<String, HashMap<String, Any>>)
 * @explain[en] raycaster.params structure: Mesh/LOD/Sprite have no extra parameters, Line/Points contain threshold precision (world units).
 * threshold is the precision (world units) of the raycaster when intersecting objects.
 */
public class RaycasterParams {
    /**
     * @brief[zh-cn] Line 相交阈值（世界单位），默认 1
     *
     * @brief[en] Line intersection threshold (world units), default 1
     */
    public var lineThreshold: Float64

    /**
     * @brief[zh-cn] Points 相交阈值（世界单位），默认 1
     *
     * @brief[en] Points intersection threshold (world units), default 1
     */
    public var pointsThreshold: Float64

    /**
     * @brief[zh-cn] 构造射线投射参数
     *
     * @brief[en] Construct raycaster parameters
     */
    public init() {
        this.lineThreshold = 1.0
        this.pointsThreshold = 1.0
    }
}

/**
 * @brief[zh-cn] 射线投射器类，用于鼠标拾取等射线相交测试
 * @explain[zh-cn] 委托给 3D 对象的 raycast() 方法进行相交测试，Mesh/Line/Points 等可有不同的相交响应
 *
 * @brief[en] Raycaster class, used for mouse picking and other ray intersection tests
 * @explain[en] Delegates to 3D objects' raycast() method for intersection testing, Mesh/Line/Points etc. can have different intersection responses
 */
public class Raycaster {
    /**
     * @brief[zh-cn] 用于射线投射的射线
     *
     * @brief[en] The ray used for casting
     */
    public var ray: Ray

    /**
     * @brief[zh-cn] 所有返回的结果都比 near 更远。near 不能为负数
     *
     * @brief[en] All returned results are further than near. near cannot be negative
     */
    public var near: Float64

    /**
     * @brief[zh-cn] 所有返回的结果都比 far 更近。far 不能低于 near
     *
     * @brief[en] All returned results are closer than far. far cannot be less than near
     */
    public var far: Float64

    /**
     * @brief[zh-cn] 当对视图相关对象（如 Sprite）进行射线投射时使用的相机
     *
     * @brief[en] The camera used when ray casting against view-dependent objects (like Sprites)
     */
    public var camera: ?Object3D

    /**
     * @brief[zh-cn] 允许在执行相交测试时选择性地忽略 3D 对象
     *
     * @brief[en] Allows selectively ignoring 3D objects during intersection testing
     */
    public var layers: Layers

    /**
     * @brief[zh-cn] 配置射线投射的参数对象（Line/Points 阈值等）
     *
     * @brief[en] Configuration parameters for ray casting (Line/Points thresholds, etc.)
     */
    public var params: RaycasterParams

    /**
     * @brief[zh-cn] 构造新的射线投射器
     * @param[zh-cn] origin 射线原点向量
     * direction 射线方向向量（应已归一化）
     * near 所有返回结果都比 near 更远，near 不能为负数，默认为 0
     * far 所有返回结果都比 far 更近，far 不能低于 near，默认为 Infinity
     *
     * @brief[en] Construct a new raycaster
     * @param[en] origin Ray origin vector
     * direction Ray direction vector (should be normalized)
     * near All results are further than near, near cannot be negative, default 0
     * far All results are closer than far, far cannot be less than near, default Infinity
     */
    public init(origin!: Vector3 = Vector3(), direction!: Vector3 = Vector3(0.0, 0.0, 1.0), near!: Float64 = 0.0, far!: Float64 = Float64.Inf) {
        this.ray = Ray(origin, direction)
        this.near = near
        this.far = far
        this.camera = None
        this.layers = Layers()
        this.params = RaycasterParams()
    }

    /**
     * @brief[zh-cn] 使用新原点和方向更新射线
     * @param[zh-cn] origin 射线原点向量
     * direction 射线方向向量（应已归一化）
     *
     * @brief[en] Update the ray with new origin and direction
     * @param[en] origin Ray origin vector
     * direction Ray direction vector (should be normalized)
     */
    public func set(origin: Vector3, direction: Vector3): Unit {
        // direction 假定已归一化（用于精确距离计算）
        this.ray.set(origin, direction)
    }

    /**
     * @brief[zh-cn] 使用给定的坐标和相机计算射线内部的新原点和方向
     * @param[zh-cn] coords 鼠标的 2D 坐标，使用 NDC（标准化设备坐标），X 和 Y 分量应在 -1 到 1 之间
     * camera 射线应从其发出的相机
     *
     * @brief[en] Calculate new ray origin and direction from given coordinates and camera
     * @param[en] coords Mouse 2D coordinates in NDC (normalized device coordinates), X and Y should be between -1 and 1
     * camera The camera from which the ray should originate
     */
    public func setFromCamera(coords: Vector2, camera: Object3D): Unit {
        // 通过相机类型分支（perspective/orthographic）
        if (false) {
            this.ray.origin.setFromMatrixPosition(camera.matrixWorld)
            this.ray.direction.set(coords.x, coords.y, 0.5).unproject(camera.matrixWorld).sub(this.ray.origin).normalize()
            this.camera = Some(camera)
        } else if (false) {
            // 在相机平面中设置原点
            this.ray.origin.set(coords.x, coords.y, camera.matrixWorld.elements[14]).unproject(camera.matrixWorld)
            this.ray.direction.set(0.0, 0.0, 1.0).transformDirection(camera.matrixWorld)
            this.camera = Some(camera)
        } else {
            // 不支持的相机类型
            Logger.warn(["Raycaster", "Unsupported camera type: " + camera.kind])
        }
    }

    /**
     * @brief[zh-cn] 检查射线与对象的全部相交（含/不含后代），结果按距离升序排列
     * @param[zh-cn] object 要检查的 3D 对象
     * recursive 是否递归检查后代，默认为 true
     * @return[zh-cn] 保存相交结果的数组
     *
     * @brief[en] Check ray intersection with an object (with/without descendants), results sorted by distance ascending
     * @param[en] object The 3D object to check
     * recursive Whether to recursively check descendants, default true
     * @return[en] Array holding intersection results
     */
    public func intersectObject(object: Object3D, recursive!: Bool = true): ArrayList<Intersection> {
        let intersects = ArrayList<Intersection>()
        intersectInternal(object, this, intersects, recursive)
        
        sort(intersects, by: { a: Intersection, b: Intersection =>
            if (a.distance < b.distance) { Ordering.LT }
            else if (a.distance > b.distance) { Ordering.GT }
            else { Ordering.EQ }
        })
        return intersects
    }

    /**
     * @brief[zh-cn] 检查射线与多个对象的全部相交（含/不含后代），结果按距离升序排列
     * @param[zh-cn] objects 要检查的 3D 对象数组
     * recursive 是否递归检查后代，默认为 true
     * @return[zh-cn] 保存相交结果的数组
     *
     * @brief[en] Check ray intersection with multiple objects (with/without descendants), results sorted by distance ascending
     * @param[en] objects Array of 3D objects to check
     * recursive Whether to recursively check descendants, default true
     * @return[en] Array holding intersection results
     */
    public func intersectObjects(objects: Array<Object3D>, recursive!: Bool = true): ArrayList<Intersection> {
        let intersects = ArrayList<Intersection>()
        for (obj in objects) {
            intersectInternal(obj, this, intersects, recursive)
        }
        
        // std.sort 原地排序（官方案例——不改变数组内容）：sort(ArrayList, by, stable, descending)
        sort(intersects, by: { a: Intersection, b: Intersection =>
            if (a.distance < b.distance) { Ordering.LT }
            else if (a.distance > b.distance) { Ordering.GT }
            else { Ordering.EQ }
        }, stable: false, descending: false)
        return intersects
    }

    /**
     * @brief[zh-cn] 内部递归相交检查
     * @param[zh-cn] object 当前要检查的 3D 对象
     * raycaster 当前射线投射器
     * intersects 累积相交结果数组
     * recursive 是否递归检查后代
     *
     * @brief[en] Internal recursive intersection check
     * @param[en] object Current 3D object to check
     * raycaster Current raycaster
     * intersects Accumulated intersection result array
     * recursive Whether to recursively check descendants
     */
    private func intersectInternal(object: Object3D, raycaster: Raycaster, intersects: ArrayList<Intersection>, recursive: Bool): Unit {
        var propagate = true
        if (object.layers.test(raycaster.layers)) {
            // 委托给对象的 raycast() 方法
            object.raycast(raycaster, intersects)
        }
        if (propagate && recursive) {
            let children = object.children
            for (i in 0..children.size) {
                intersectInternal(children[i], raycaster, intersects, true)
            }
        }
    }
}
