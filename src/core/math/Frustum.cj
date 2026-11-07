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
     * @brief[zh-cn] 判断球（[cx,cy,cz,radius] 四元数组）是否与视锥体相交
     * @explain[zh-cn] 零分配重载：getWorldBoundingSphere 返回的正是这个四元数组，
     * 逐对象 new Sphere + new Vector3 在 800 对象场景下是每帧 800 次堆分配，纯属浪费。
     * 数学与 intersectsSphere(Sphere) 完全一致。
     *
     * @brief[en] Check if a sphere ([cx,cy,cz,radius]) intersects the frustum, with zero allocation
     * @explain[en] Zero-allocation overload: getWorldBoundingSphere returns exactly this 4-element array,
     * so per-object `new Sphere` + `new Vector3` costs 800 heap allocations per frame in an 800-object
     * scene. Mathematically identical to intersectsSphere(Sphere).
     * @param[en] sphere Sphere as [centerX, centerY, centerZ, radius]
     * @return[en] Whether they intersect
     */
    public func intersectsSphereArray(sphere: Array<Float64>): Bool {
        let cx = sphere[0]
        let cy = sphere[1]
        let cz = sphere[2]
        let radius = sphere[3]
        for (i in 0..6) {
            let p = this.planes[i]
            if (p.normal.x * cx + p.normal.y * cy + p.normal.z * cz + p.constant < -radius) {
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
        return this.intersectsBoxComponents(
            box.min.x, box.min.y, box.min.z,
            box.max.x, box.max.y, box.max.z
        )
    }

    /**
     * @brief[zh-cn] 判断包围盒分量是否与视锥体相交（零分配重载）
     * @explain[zh-cn] 直接以 6 个标量参数做 p-vertex 测试，不构造 Vector3/Box3 实例。
     *             剔除与 BVH 遍历等高频路径上，每次调用都 new Vector3() 会把纯标量
     *             运算变成堆分配（10 万对象场景 = 每帧 10 万次分配），此处全部展开为
     *             局部标量比较。
     *
     *             取包围盒在平面法线方向上的"最负点"（p-vertex）：让 n·p 尽可能小。
     *             法线分量 > 0 时取该轴的最大值，< 0 时取最小值。
     *             （此前取反了：用 n-vertex 规则会让 n·p 偏大，误判为"在平面外侧"，
     *               导致位于视锥边缘的包围盒被过度剔除。）
     * @param[zh-cn] minX 包围盒最小 X
     * minY 包围盒最小 Y
     * minZ 包围盒最小 Z
     * maxX 包围盒最大 X
     * maxY 包围盒最大 Y
     * maxZ 包围盒最大 Z
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if bounding-box components intersect the frustum (zero-allocation overload)
     * @explain[en] Performs the p-vertex test directly on 6 scalar arguments without
     *             constructing Vector3/Box3 instances. On hot culling and BVH traversal
     *             paths a per-call `new Vector3()` turns pure scalar math into heap
     *             allocation (100k objects = 100k allocations per frame); everything is
     *             expanded into local scalar comparisons here.
     * @param[en] minX Box min X
     * minY Box min Y
     * minZ Box min Z
     * maxX Box max X
     * maxY Box max Y
     * maxZ Box max Z
     * @return[en] Whether they intersect
     */
    public func intersectsBoxComponents(
        minX: Float64, minY: Float64, minZ: Float64,
        maxX: Float64, maxY: Float64, maxZ: Float64
    ): Bool {
        for (i in 0..6) {
            let p = this.planes[i]
            let n = p.normal
            let nx = if (n.x > 0.0) { maxX } else { minX }
            let ny = if (n.y > 0.0) { maxY } else { minY }
            let nz = if (n.z > 0.0) { maxZ } else { minZ }
            if (n.x * nx + n.y * ny + n.z * nz + p.constant < 0.0) {
                return false
            }
        }
        return true
    }

    /**
     * @brief[zh-cn] 判断球体分量是否与视锥体相交（零分配重载）
     * @explain[zh-cn] 与 intersectsSphereArray 同义，但直接接收 4 个标量，
     *             便于在 SoA 布局（Bvh 的 _centerX/_centerY/_centerZ + 半径数组）
     *             上免去数组下标与临时对象。
     *
     * @brief[en] Check if sphere components intersect the frustum (zero-allocation overload)
     * @explain[en] Equivalent to intersectsSphereArray but takes 4 scalars directly,
     *             which suits SoA layouts (Bvh's _centerX/_centerY/_centerZ plus radius
     *             array) without array indexing or temporary objects.
     */
    public func intersectsSphereComponents(cx: Float64, cy: Float64, cz: Float64, radius: Float64): Bool {
        for (i in 0..6) {
            let p = this.planes[i]
            let n = p.normal
            if (n.x * cx + n.y * cy + n.z * cz + p.constant < -radius) {
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
        if (let Some(ball) <- object.getWorldBoundingSphere()) {
            // 零分配：getWorldBoundingSphere 返回 [cx,cy,cz,radius]，直接做平面距离测试，
            // 避免逐对象 new Sphere + new Vector3（800 对象场景下每帧 800 次堆分配）。
            return this.intersectsSphereArray(ball)
        }
        // 无几何体无法计算包围球 → 不裁剪
        return true
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
