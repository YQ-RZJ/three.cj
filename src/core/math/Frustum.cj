/**
 * @file[zh-cn] Frustum
 * @brief[zh-cn] 视锥体
 * @explain[zh-cn] 表示由6个平面定义的视锥体，用于视锥体裁剪。通过 IFrustumCullable 接口获取对象世界包围球，避免 math 与 core 包的循环依赖。
 *
 * @file[en] Frustum
 * @brief[en] Frustum
 * @explain[en] Represents a frustum defined by 6 planes, used for frustum culling. Obtains object world bounding sphere via IFrustumCullable interface, avoiding circular dependency between math and core packages.
 */
package three.core.math

import std.math.*
import three.core.interfaces.*
import three.utils.constants.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 视锥体类，由6个平面定义
 * @explain[zh-cn] 支持从投影矩阵设置、点/球体/包围盒/3D 对象相交测试
 *
 * @brief[en] Frustum class, defined by 6 planes
 * @explain[en] Supports setting from projection matrix, point/sphere/bounding box/3D object intersection tests
 */
@JsonAdapter
public class Frustum {
    /**
     * @brief[zh-cn] 视锥体的6个裁剪平面
     *
     * @brief[en] The 6 clipping planes of the frustum
     */
    public var planes: Array<Plane>
    /**
     * @brief[zh-cn] 类型标记（is+类名 冗余成员，不参与序列化）
     *
     * @brief[en] Type marker (is+ClassName redundant member, not serialized)
     */
    @JsonIgnore
    public let isFrustum: Bool = true
    public init() {
        this.planes = Array<Plane>(6, { _ => Plane() })
    }

    /**
     * @brief[zh-cn] 设置视锥体的6个平面
     * @param[zh-cn] p0 第0个平面
     * p1 第1个平面
     * p2 第2个平面
     * p3 第3个平面
     * p4 第4个平面
     * p5 第5个平面
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the 6 planes of the frustum
     * @param[en] p0 The 0th plane
     * p1 The 1st plane
     * p2 The 2nd plane
     * p3 The 3rd plane
     * p4 The 4th plane
     * p5 The 5th plane
     * @return[en] This instance
     */
    public func set(p0: Plane, p1: Plane, p2: Plane, p3: Plane, p4: Plane, p5: Plane): Frustum {
        this.planes[0].copy(p0)
        this.planes[1].copy(p1)
        this.planes[2].copy(p2)
        this.planes[3].copy(p3)
        this.planes[4].copy(p4)
        this.planes[5].copy(p5)
        return this
    }

    /**
     * @brief[zh-cn] 从投影矩阵设置视锥体
     * @explain[zh-cn] 注：JS 侧为右手系（WebGL，NDC z∈[-1,1]）；bgfx 后端为左手系（WebGPUCoordinateSystem，NDC z∈[0,1]），因此默认 coordinateSystem 取 WebGPUCoordinateSystem，near/far 平面按左手系约定提取。
     * @param[zh-cn] m 投影矩阵（或 projScreen = projectionMatrix × matrixWorldInverse）
     * coordinateSystem 坐标系（WebGL 2000 / WebGPU 2001），默认 WebGPU（左手系）
     * reversedDepth 是否反向深度（WebGPU 反向 Z [1,0]），默认 false
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the frustum from a projection matrix
     * @explain[en] JS reference: Frustum.setFromProjectionMatrix. Note: JS uses right-handed system (WebGL, NDC z∈[-1,1]); bgfx backend uses left-handed system (WebGPUCoordinateSystem, NDC z∈[0,1]), so default coordinateSystem is WebGPUCoordinateSystem, near/far planes extracted per left-handed convention.
     * @param[en] m Projection matrix (or projScreen = projectionMatrix × matrixWorldInverse)
     * coordinateSystem Coordinate system (WebGL 2000 / WebGPU 2001), default WebGPU (left-handed)
     * reversedDepth Whether reversed depth (WebGPU reverse Z [1,0]), default false
     * @return[en] This instance
     */
    public func setFromProjectionMatrix(m: Matrix4, coordinateSystem!: Int64 = WebGPUCoordinateSystem, reversedDepth!: Bool = false): Frustum {
        let me = m.elements
        let me0 = me[0]; let me1 = me[1]; let me2 = me[2]; let me3 = me[3]
        let me4 = me[4]; let me5 = me[5]; let me6 = me[6]; let me7 = me[7]
        let me8 = me[8]; let me9 = me[9]; let me10 = me[10]; let me11 = me[11]
        let me12 = me[12]; let me13 = me[13]; let me14 = me[14]; let me15 = me[15]

        // left / right / bottom / top（左右手系一致）
        this.planes[0].setComponents(me3 - me0, me7 - me4, me11 - me8, me15 - me12).normalize()
        this.planes[1].setComponents(me3 + me0, me7 + me4, me11 + me8, me15 + me12).normalize()
        this.planes[2].setComponents(me3 + me1, me7 + me5, me11 + me9, me15 + me13).normalize()
        this.planes[3].setComponents(me3 - me1, me7 - me5, me11 - me9, me15 - me13).normalize()

        if (reversedDepth) {
            // 反向深度：far = row3，near = row4 - row3
            this.planes[4].setComponents(me2, me6, me10, me14).normalize()
            this.planes[5].setComponents(me3 - me2, me7 - me6, me11 - me10, me15 - me14).normalize()
        } else {
            // far = row4 - row3
            this.planes[4].setComponents(me3 - me2, me7 - me6, me11 - me10, me15 - me14).normalize()
            if (coordinateSystem == WebGLCoordinateSystem) {
                // 右手系（NDC z∈[-1,1]）：near = row4 + row3
                this.planes[5].setComponents(me3 + me2, me7 + me6, me11 + me10, me15 + me14).normalize()
            } else {
                // 左手系 WebGPU/bgfx（NDC z∈[0,1]）：near = row3
                this.planes[5].setComponents(me2, me6, me10, me14).normalize()
            }
        }
        return this
    }

    /**
     * @brief[zh-cn] 判断点是否在视锥体内
     * @param[zh-cn] point 要检测的点
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if a point is inside the frustum
     * @param[en] point Point to test
     * @return[en] Whether the point is contained
     */
    public func containsPoint(point: Vector3): Bool {
        for (p in this.planes) {
            if (p.distanceToPoint(point) < 0.0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 判断球体是否与视锥体相交
     * @param[zh-cn] sphere 球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a sphere intersects the frustum
     * @param[en] sphere Sphere
     * @return[en] Whether they intersect
     */
    public func intersectsSphere(sphere: Sphere): Bool {
        for (p in this.planes) {
            if (p.distanceToPoint(sphere.center) < -sphere.radius) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 判断包围盒是否与视锥体相交
     * @param[zh-cn] box 包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a bounding box intersects the frustum
     * @param[en] box Bounding box
     * @return[en] Whether they intersect
     */
    public func intersectsBox(box: Box3): Bool {
        let _vector = Vector3()
        for (i in 0..6) {
            let p = this.planes[i]
            // 计算包围盒在平面法线方向上的极值点
            let nx = if (p.normal.x > 0.0) { box.min.x } else { box.max.x }
            let ny = if (p.normal.y > 0.0) { box.min.y } else { box.max.y }
            let nz = if (p.normal.z > 0.0) { box.min.z } else { box.max.z }
            _vector.set(nx, ny, nz)
            if (p.distanceToPoint(_vector) < 0.0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 判断 3D 对象是否与视锥体相交
     * @explain[zh-cn] 通过 IFrustumCullable 接口获取对象世界包围球；无法计算包围球时视为可见
     * @param[zh-cn] object 实现 IFrustumCullable 的对象（Object3D 及子类）
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a 3D object intersects the frustum
     * @explain[en] JS reference: Frustum.intersectsObject. Obtains object world bounding sphere via IFrustumCullable interface; when bounding sphere cannot be computed, the object is treated as visible
     * @param[en] object Object implementing IFrustumCullable (Object3D and subclasses)
     * @return[en] Whether they intersect
     */
    public func intersectsObject(object: IFrustumCullable): Bool {
        match (object.getWorldBoundingSphere()) {
            case Some(ball) =>
                let sphere = Sphere(Vector3(ball[0], ball[1], ball[2]), ball[3])
                return this.intersectsSphere(sphere)
            case None =>
                // 无几何体无法计算包围球 → 不裁剪
                return true
        }
    }

    /**
     * @brief[zh-cn] 判断精灵是否与视锥体相交
     * @explain[zh-cn] Sprite 覆写了 getWorldBoundingSphere（中心 + 0.7071+offset 半径）
     * @param[zh-cn] sprite 精灵（Sprite <: Object3D <: IFrustumCullable）
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if a sprite intersects the frustum
     * @explain[en] JS reference: Frustum.intersectsSprite. Sprite overrides getWorldBoundingSphere (center + 0.7071+offset radius)
     * @param[en] sprite Sprite (Sprite <: Object3D <: IFrustumCullable)
     * @return[en] Whether they intersect
     */
    public func intersectsSprite(sprite: IFrustumCullable): Bool {
        return this.intersectsObject(sprite)
    }

    /**
     * @brief[zh-cn] 克隆当前视锥体
     * @return[zh-cn] 新的视锥体实例
     *
     * @brief[en] Clone the current frustum
     * @return[en] New frustum instance
     */
    public func clone(): Frustum {
        let f = Frustum()
        for (i in 0..6) {
            f.planes[i].copy(this.planes[i])
        }
        return f
    }

    /**
     * @brief[zh-cn] 复制另一个视锥体的值到当前实例
     * @param[zh-cn] f 源视锥体
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another frustum to this instance
     * @param[en] f Source frustum
     * @return[en] This instance
     */
    public func copy(f: Frustum): Frustum {
        for (i in 0..6) {
            this.planes[i].copy(f.planes[i])
        }
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个视锥体相等
     * @param[zh-cn] f 另一个视锥体
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if this frustum equals another
     * @param[en] f Another frustum
     * @return[en] Whether they are equal
     */
    public func equals(f: Frustum): Bool {
        for (i in 0..6) {
            if (!this.planes[i].equals(f.planes[i])) {
                return false
            }
        }
        return true
    }
}
