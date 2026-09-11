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
 * @file[zh-cn] Box3
 * @brief[zh-cn] 3D 包围盒
 * @explain[zh-cn] 表示三维空间中的轴对齐包围盒 (AABB)，用最小点和最大点表示。支持从对象、缓冲属性、点集等设置包围盒，以及包含检测、交集/并集运算、三角形相交测试等。
 *
 * @file[en] Box3
 * @brief[en] 3D bounding box
 * @explain[en] Represents an axis-aligned bounding box (AABB) in 3D space, defined by min and max points. Supports setting from objects, buffer attributes, point sets, as well as containment tests, intersection/union operations, triangle intersection tests, etc.
 */
package three.core.math

import std.math.*
import std.collection.*
import three.core.interfaces.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 3D 轴对齐包围盒类，用最小点和最大点表示
 * @explain[zh-cn] 支持从对象/缓冲属性/点集设置，包含检测、交集/并集运算、SAT 三角形相交测试等
 *
 * @brief[en] 3D axis-aligned bounding box class, defined by min and max points
 * @explain[en] Supports setting from objects/buffer attributes/point sets, containment tests, intersection/union operations, SAT triangle intersection test, etc.
 */
@JsonAdapter
public class Box3 {
    /**
     * @brief[zh-cn] 包围盒的下边界
     *
     * @brief[en] Lower bound of the bounding box
     */
    public var min: Vector3
    /**
     * @brief[zh-cn] 包围盒的上边界
     *
     * @brief[en] Upper bound of the bounding box
     */
    public var max: Vector3

    /**
     * @brief[zh-cn] 构造空包围盒（min=+Inf, max=-Inf）
     *
     * @brief[en] Construct an empty bounding box (min=+Inf, max=-Inf)
     */
    public init() {
        this.min = Vector3(Float64.Inf, Float64.Inf, Float64.Inf)
        this.max = Vector3(-Float64.Inf, -Float64.Inf, -Float64.Inf)
    }

    /**
     * @brief[zh-cn] 用指定的最小点和最大点构造包围盒
     * @param[zh-cn] min 最小点
     * max 最大点
     *
     * @brief[en] Construct a bounding box with specified min and max points
     * @param[en] min Minimum point
     * max Maximum point
     */
    public init(min: Vector3, max: Vector3) {
        this.min = min.clone()
        this.max = max.clone()
    }

    /**
     * @brief[zh-cn] 设置包围盒的上下边界
     * @param[zh-cn] min 最小点
     * max 最大点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the min and max bounds of the bounding box
     * @param[en] min Minimum point
     * max Maximum point
     * @return[en] This instance
     */
    public func set(min: Vector3, max: Vector3): Box3 {
        this.min.copy(min)
        this.max.copy(max)
        return this
    }

    /**
     * @brief[zh-cn] 从浮点数组设置包围盒（每3个元素一个点）
     * @param[zh-cn] array 包含坐标数据的数组
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from a float array (every 3 elements form a point)
     * @param[en] array Array containing coordinate data
     * @return[en] This instance
     */
    public func setFromArray(array: Array<Float64>): Box3 {
        this.makeEmpty()
        var i = 0
        let _vector = Vector3()
        while (i < array.size) {
            this.expandByPoint(_vector.fromArray(array, offset: i))
            i += 3
        }
        return this
    }

    /**
     * @brief[zh-cn] 从顶点属性设置包围盒，使其包含属性中的全部位置数据
     * @explain[zh-cn] 从缓冲属性设置包围盒
     * @param[zh-cn] attribute 顶点属性（AttributeReader 接口，由 BufferAttribute 实现）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from a vertex attribute, containing all position data
     * @explain[en] JS reference: Box3.setFromBufferAttribute
     * @param[en] attribute Vertex attribute (AttributeReader interface, implemented by BufferAttribute)
     * @return[en] This instance
     */
    public func setFromBufferAttribute(attribute: AttributeReader): Box3 {
        this.makeEmpty()
        let _vector = Vector3()
        for (i in 0..attribute.count) {
            this.expandByPoint(_vector.fromBufferAttribute(attribute, i))
        }
        return this
    }

    /**
     * @brief[zh-cn] 从对象（含子对象）设置包围盒
     * @explain[zh-cn] 从对象设置包围盒
     * @param[zh-cn] object 实现 IBox3Expandable 的对象（Object3D 及子类）
     * precise 是否精确计算（当前实现走保守路径）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from an object (including children)
     * @explain[en] JS reference: Box3.setFromObject
     * @param[en] object Object implementing IBox3Expandable (Object3D and subclasses)
     * precise Whether to compute precisely (current implementation uses conservative path)
     * @return[en] This instance
     */
    public func setFromObject(object: IBox3Expandable, precise!: Bool = false): Box3 {
        this.makeEmpty()
        return this.expandByObject(object, precise)
    }

    /**
     * @brief[zh-cn] 递归展开对象（含子对象）的几何体包围盒并合并
     * @explain[zh-cn] precise=true 时逐顶点遍历 position 属性；precise=false 时用几何体 boundingBox 保守路径
     * @param[zh-cn] object 实现 IBox3Expandable 的对象
     * precise 是否精确计算
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Recursively expand by object (including children) geometry bounding boxes and merge
     * @explain[en] JS reference: Box3.expandByObject. When precise=true, traverses position attribute per vertex; when precise=false, uses geometry boundingBox conservative path
     * @param[en] object Object implementing IBox3Expandable
     * precise Whether to compute precisely
     * @return[en] This instance
     */
    public func expandByObject(object: IBox3Expandable, precise: Bool): Box3 {
        object.updateWorldMatrix(false, false, false)

        if (precise && object.getPreciseVertexCount() > 0) {
            for (i in 0..object.getPreciseVertexCount()) {
                let p = object.getPreciseVertexPosition(i)
                this.expandByPoint(Vector3(p[0], p[1], p[2]))
            }
        } else {
            match (object.getWorldBoundingBox()) {
                case Some(bb) =>
                    let minV = bb[0]; let maxV = bb[1]
                    let worldBox = Box3(
                        Vector3(minV[0], minV[1], minV[2]),
                        Vector3(maxV[0], maxV[1], maxV[2])
                    )
                    this.union(worldBox)
                case None => ()
            }
        }

        for (i in 0..object.getChildCount()) {
            this.expandByObject(object.getChildAt(i), precise)
        }
        return this
    }

    /**
     * @brief[zh-cn] 从点集设置包围盒
     * @param[zh-cn] points 点集合
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from a set of points
     * @param[en] points Point collection
     * @return[en] This instance
     */
    public func setFromPoints(points: ArrayList<Vector3>): Box3 {
        this.makeEmpty()
        for (p in points) {
            this.expandByPoint(p)
        }
        return this
    }

    /**
     * @brief[zh-cn] 从中心和大小设置包围盒
     * @param[zh-cn] center 中心点
     * size 尺寸
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from center and size
     * @param[en] center Center point
     * size Size
     * @return[en] This instance
     */
    public func setFromCenterAndSize(center: Vector3, size: Vector3): Box3 {
        let halfSize = Vector3().copy(size).multiplyScalar(0.5)
        this.min.copy(center).sub(halfSize)
        this.max.copy(center).add(halfSize)
        return this
    }

    /**
     * @brief[zh-cn] 克隆当前包围盒
     * @return[zh-cn] 新的包围盒实例
     *
     * @brief[en] Clone the current bounding box
     * @return[en] New bounding box instance
     */
    public func clone(): Box3 {
        return Box3().copy(this)
    }

    /**
     * @brief[zh-cn] 复制另一个包围盒的值到当前实例
     * @param[zh-cn] b 源包围盒
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Copy values from another bounding box to this instance
     * @param[en] b Source bounding box
     * @return[en] This instance
     */
    public func copy(b: Box3): Box3 {
        this.min.copy(b.min)
        this.max.copy(b.max)
        return this
    }

    /**
     * @brief[zh-cn] 将包围盒置空（使其不包含任何点）
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Make the bounding box empty (containing no points)
     * @return[en] This instance
     */
    public func makeEmpty(): Box3 {
        this.min.set(Float64.Inf, Float64.Inf, Float64.Inf)
        this.max.set(-Float64.Inf, -Float64.Inf, -Float64.Inf)
        return this
    }

    /**
     * @brief[zh-cn] 判断包围盒是否为空
     * @return[zh-cn] 是否为空
     *
     * @brief[en] Check if the bounding box is empty
     * @return[en] Whether the box is empty
     */
    public func isEmpty(): Bool {
        return this.max.x < this.min.x || this.max.y < this.min.y || this.max.z < this.min.z
    }

    /**
     * @brief[zh-cn] 获取包围盒的中心点（创建新向量）
     * @return[zh-cn] 中心点
     *
     * @brief[en] Get the center point of the bounding box (creates a new vector)
     * @return[en] Center point
     */
    public func getCenter(): Vector3 {
        return this.getCenter(Vector3())
    }

    /**
     * @brief[zh-cn] 获取包围盒的中心点
     * @param[zh-cn] target 目标向量，用于存储结果
     * @return[zh-cn] 中心点
     *
     * @brief[en] Get the center point of the bounding box
     * @param[en] target Target vector for storing the result
     * @return[en] Center point
     */
    public func getCenter(target: Vector3): Vector3 {
        if (this.isEmpty()) {
            return target.set(0.0, 0.0, 0.0)
        }
        return target.addVectors(this.min, this.max).multiplyScalar(0.5)
    }

    /**
     * @brief[zh-cn] 获取包围盒的尺寸（创建新向量）
     * @return[zh-cn] 尺寸向量
     *
     * @brief[en] Get the size of the bounding box (creates a new vector)
     * @return[en] Size vector
     */
    public func getSize(): Vector3 {
        return this.getSize(Vector3())
    }

    /**
     * @brief[zh-cn] 获取包围盒的尺寸
     * @param[zh-cn] target 目标向量，用于存储结果
     * @return[zh-cn] 尺寸向量
     *
     * @brief[en] Get the size of the bounding box
     * @param[en] target Target vector for storing the result
     * @return[en] Size vector
     */
    public func getSize(target: Vector3): Vector3 {
        if (this.isEmpty()) {
            return target.set(0.0, 0.0, 0.0)
        }
        return target.subVectors(this.max, this.min)
    }

    /**
     * @brief[zh-cn] 扩展包围盒以包含给定点
     * @param[zh-cn] point 要包含的点
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Expand the bounding box to include a given point
     * @param[en] point Point to include
     * @return[en] This instance
     */
    public func expandByPoint(point: Vector3): Box3 {
        this.min.min(point)
        this.max.max(point)
        return this
    }

    /**
     * @brief[zh-cn] 按向量扩展包围盒
     * @param[zh-cn] v 扩展向量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Expand the bounding box by a vector
     * @param[en] v Expansion vector
     * @return[en] This instance
     */
    public func expandByVector(v: Vector3): Box3 {
        this.min.sub(v)
        this.max.add(v)
        return this
    }

    /**
     * @brief[zh-cn] 按标量扩展包围盒
     * @param[zh-cn] s 扩展标量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Expand the bounding box by a scalar
     * @param[en] s Expansion scalar
     * @return[en] This instance
     */
    public func expandByScalar(s: Float64): Box3 {
        this.min.addScalar(-s)
        this.max.addScalar(s)
        return this
    }

    /**
     * @brief[zh-cn] 判断点是否在包围盒内
     * @param[zh-cn] point 要检测的点
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if a point is inside the bounding box
     * @param[en] point Point to test
     * @return[en] Whether the point is contained
     */
    public func containsPoint(point: Vector3): Bool {
        return point.x >= this.min.x && point.x <= this.max.x &&
            point.y >= this.min.y && point.y <= this.max.y &&
            point.z >= this.min.z && point.z <= this.max.z
    }

    /**
     * @brief[zh-cn] 判断是否完全包含另一个包围盒
     * @param[zh-cn] b 另一个包围盒
     * @return[zh-cn] 是否包含
     *
     * @brief[en] Check if this bounding box fully contains another
     * @param[en] b Another bounding box
     * @return[en] Whether the box is fully contained
     */
    public func containsBox(b: Box3): Bool {
        return this.min.x <= b.min.x && b.max.x <= this.max.x &&
            this.min.y <= b.min.y && b.max.y <= this.max.y &&
            this.min.z <= b.min.z && b.max.z <= this.max.z
    }

    /**
     * @brief[zh-cn] 获取点在包围盒中的参数化位置（0-1 范围）
     * @param[zh-cn] point 要检测的点
     * target 目标向量
     * @return[zh-cn] 参数化位置
     *
     * @brief[en] Get the parameterized position of a point within the bounding box (0-1 range)
     * @param[en] point Point to test
     * target Target vector
     * @return[en] Parameterized position
     */
    public func getParameter(point: Vector3, target: Vector3): Vector3 {
        return target.set(
            (point.x - this.min.x) / (this.max.x - this.min.x),
            (point.y - this.min.y) / (this.max.y - this.min.y),
            (point.z - this.min.z) / (this.max.z - this.min.z)
        )
    }

    /**
     * @brief[zh-cn] 判断是否与另一个包围盒相交
     * @param[zh-cn] b 另一个包围盒
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if this bounding box intersects another
     * @param[en] b Another bounding box
     * @return[en] Whether the boxes intersect
     */
    public func intersectsBox(b: Box3): Bool {
        return b.max.x >= this.min.x && b.min.x <= this.max.x &&
            b.max.y >= this.min.y && b.min.y <= this.max.y &&
            b.max.z >= this.min.z && b.min.z <= this.max.z
    }

    /**
     * @brief[zh-cn] 判断是否与球体相交
     * @param[zh-cn] sphere 球体
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if this bounding box intersects a sphere
     * @param[en] sphere Sphere
     * @return[en] Whether they intersect
     */
    public func intersectsSphere(sphere: Sphere): Bool {
        let clampedPoint = Vector3().copy(sphere.center).clamp(this.min, this.max)
        return clampedPoint.distanceToSquared(sphere.center) <= (sphere.radius * sphere.radius)
    }

    /**
     * @brief[zh-cn] 判断是否与平面相交
     * @param[zh-cn] plane 平面
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if this bounding box intersects a plane
     * @param[en] plane Plane
     * @return[en] Whether they intersect
     */
    public func intersectsPlane(plane: Plane): Bool {
        var minVal: Float64 = 0.0
        var maxVal: Float64 = 0.0

        if (plane.normal.x > 0.0) {
            minVal = plane.normal.x * this.min.x
            maxVal = plane.normal.x * this.max.x
        } else {
            minVal = plane.normal.x * this.max.x
            maxVal = plane.normal.x * this.min.x
        }

        if (plane.normal.y > 0.0) {
            minVal += plane.normal.y * this.min.y
            maxVal += plane.normal.y * this.max.y
        } else {
            minVal += plane.normal.y * this.max.y
            maxVal += plane.normal.y * this.min.y
        }

        if (plane.normal.z > 0.0) {
            minVal += plane.normal.z * this.min.z
            maxVal += plane.normal.z * this.max.z
        } else {
            minVal += plane.normal.z * this.max.z
            maxVal += plane.normal.z * this.min.z
        }

        return (minVal <= -plane.constant && maxVal >= -plane.constant)
    }

    /**
     * @brief[zh-cn] 将点限制在包围盒内
     * @param[zh-cn] point 要限制的点
     * target 目标向量
     * @return[zh-cn] 限制后的点
     *
     * @brief[en] Clamp a point within the bounding box
     * @param[en] point Point to clamp
     * target Target vector
     * @return[en] Clamped point
     */
    public func clampPoint(point: Vector3, target: Vector3): Vector3 {
        return target.copy(point).clamp(this.min, this.max)
    }

    /**
     * @brief[zh-cn] 计算点到包围盒的欧几里得距离
     * @param[zh-cn] point 要计算距离的点
     * @return[zh-cn] 距离
     *
     * @brief[en] Compute the Euclidean distance from a point to the bounding box
     * @param[en] point Point to compute distance to
     * @return[en] Distance
     */
    public func distanceToPoint(point: Vector3): Float64 {
        let clampedPoint = Vector3().copy(point).clamp(this.min, this.max)
        return clampedPoint.distanceTo(point)
    }

    /**
     * @brief[zh-cn] 获取包围盒的外接球（创建新球体）
     * @return[zh-cn] 外接球
     *
     * @brief[en] Get the bounding sphere of the bounding box (creates a new sphere)
     * @return[en] Bounding sphere
     */
    public func getBoundingSphere(): Sphere {
        return this.getBoundingSphere(Sphere())
    }

    /**
     * @brief[zh-cn] 获取包围盒的外接球
     * @param[zh-cn] target 目标球体
     * @return[zh-cn] 外接球
     *
     * @brief[en] Get the bounding sphere of the bounding box
     * @param[en] target Target sphere
     * @return[en] Bounding sphere
     */
    public func getBoundingSphere(target: Sphere): Sphere {
        if (this.isEmpty()) {
            target.makeEmpty()
        } else {
            this.getCenter(target.center)
            target.radius = Vector3().subVectors(this.max, target.center).length()
        }
        return target
    }

    /**
     * @brief[zh-cn] 计算与另一个包围盒的交集
     * @param[zh-cn] b 另一个包围盒
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Compute the intersection with another bounding box
     * @param[en] b Another bounding box
     * @return[en] This instance
     */
    public func intersect(b: Box3): Box3 {
        this.min.max(b.min)
        this.max.min(b.max)
        if (this.isEmpty()) {
            this.makeEmpty()
        }
        return this
    }

    /**
     * @brief[zh-cn] 计算与另一个包围盒的并集
     * @param[zh-cn] b 另一个包围盒
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Compute the union with another bounding box
     * @param[en] b Another bounding box
     * @return[en] This instance
     */
    public func union(b: Box3): Box3 {
        this.min.min(b.min)
        this.max.max(b.max)
        return this
    }

    /**
     * @brief[zh-cn] 应用 4x4 矩阵变换包围盒
     * @param[zh-cn] matrix 变换矩阵
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Apply a 4x4 matrix transformation to the bounding box
     * @param[en] matrix Transformation matrix
     * @return[en] This instance
     */
    public func applyMatrix4(matrix: Matrix4): Box3 {
        if (this.isEmpty()) {
            return this
        }
        let _points = Array<Vector3>(8, { _ => Vector3() })
        _points[0].set(this.min.x, this.min.y, this.min.z).applyMatrix4(matrix)
        _points[1].set(this.min.x, this.min.y, this.max.z).applyMatrix4(matrix)
        _points[2].set(this.min.x, this.max.y, this.min.z).applyMatrix4(matrix)
        _points[3].set(this.min.x, this.max.y, this.max.z).applyMatrix4(matrix)
        _points[4].set(this.max.x, this.min.y, this.min.z).applyMatrix4(matrix)
        _points[5].set(this.max.x, this.min.y, this.max.z).applyMatrix4(matrix)
        _points[6].set(this.max.x, this.max.y, this.min.z).applyMatrix4(matrix)
        _points[7].set(this.max.x, this.max.y, this.max.z).applyMatrix4(matrix)
        this.setFromPoints(_points)
        return this
    }

    /**
     * @brief[zh-cn] 从点集设置包围盒（Array 版本）
     * @param[zh-cn] points 点数组
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from a point set (Array version)
     * @param[en] points Point array
     * @return[en] This instance
     */
    public func setFromPoints(points: Array<Vector3>): Box3 {
        this.makeEmpty()
        for (p in points) {
            this.expandByPoint(p)
        }
        return this
    }

    /**
     * @brief[zh-cn] 平移包围盒
     * @param[zh-cn] offset 偏移量
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Translate the bounding box
     * @param[en] offset Translation offset
     * @return[en] This instance
     */
    public func translate(offset: Vector3): Box3 {
        this.min.add(offset)
        this.max.add(offset)
        return this
    }

    /**
     * @brief[zh-cn] 判断是否与另一个包围盒相等
     * @param[zh-cn] b 另一个包围盒
     * @return[zh-cn] 是否相等
     *
     * @brief[en] Check if this bounding box equals another
     * @param[en] b Another bounding box
     * @return[en] Whether the boxes are equal
     */
    public func equals(b: Box3): Bool {
        return this.min.equals(b.min) && this.max.equals(b.max)
    }

    /**
     * @brief[zh-cn] 判断是否与三角形相交（使用 SAT 分离轴定理）
     * @param[zh-cn] triangle 三角形
     * @return[zh-cn] 是否相交
     *
     * @brief[en] Check if this bounding box intersects a triangle (using SAT - Separating Axis Theorem)
     * @param[en] triangle Triangle
     * @return[en] Whether they intersect
     */
    public func intersectsTriangle(triangle: Triangle): Bool {
        if (this.isEmpty()) {
            return false
        }

        let center = Vector3()
        this.getCenter(center)
        let extents = Vector3().subVectors(this.max, center)

        let v0 = Vector3().subVectors(triangle.a, center)
        let v1 = Vector3().subVectors(triangle.b, center)
        let v2 = Vector3().subVectors(triangle.c, center)

        let f0 = Vector3().subVectors(v1, v0)
        let f1 = Vector3().subVectors(v2, v1)
        let f2 = Vector3().subVectors(v0, v2)

        let axes = Array<Float64>(27, { _ => 0.0 })
        axes[0] = 0.0; axes[1] = -f0.z; axes[2] = f0.y
        axes[3] = 0.0; axes[4] = -f1.z; axes[5] = f1.y
        axes[6] = 0.0; axes[7] = -f2.z; axes[8] = f2.y
        axes[9] = f0.z; axes[10] = 0.0; axes[11] = -f0.x
        axes[12] = f1.z; axes[13] = 0.0; axes[14] = -f1.x
        axes[15] = f2.z; axes[16] = 0.0; axes[17] = -f2.x
        axes[18] = -f0.y; axes[19] = f0.x; axes[20] = 0.0
        axes[21] = -f1.y; axes[22] = f1.x; axes[23] = 0.0
        axes[24] = -f2.y; axes[25] = f2.x; axes[26] = 0.0

        if (!satForAxes(axes, v0, v1, v2, extents)) {
            return false
        }

        let faceAxes = Array<Float64>(9, { _ => 0.0 })
        faceAxes[0] = 1.0; faceAxes[1] = 0.0; faceAxes[2] = 0.0
        faceAxes[3] = 0.0; faceAxes[4] = 1.0; faceAxes[5] = 0.0
        faceAxes[6] = 0.0; faceAxes[7] = 0.0; faceAxes[8] = 1.0

        if (!satForAxes(faceAxes, v0, v1, v2, extents)) {
            return false
        }

        let triangleNormal = Vector3().crossVectors(f0, f1)
        let triAxes = Array<Float64>(3, { _ => 0.0 })
        triAxes[0] = triangleNormal.x; triAxes[1] = triangleNormal.y; triAxes[2] = triangleNormal.z

        return satForAxes(triAxes, v0, v1, v2, extents)
    }

    /**
     * @brief[zh-cn] 从 JSON 反序列化设置包围盒
     * @explain[zh-cn] 从 JSON 对象恢复包围盒
     * @param[zh-cn] json 序列化的包围盒 HashMap
     * @return[zh-cn] 当前实例
     *
     * @brief[en] Set the bounding box from JSON deserialization
     * @explain[en] JS reference: Box3.fromJSON(json)
     * @param[en] json Serialized bounding box HashMap
     * @return[en] This instance
     */
    public func fromJSON(json: HashMap<String, Any>): Box3 {
        match (json.get("min")) {
            case Some(m) =>
                match (m) {
                    case arr: Array<Float64> => this.min.fromArray(arr)
                    case list: ArrayList<Any> =>
                        let a = Array<Float64>(list.size, { _ => 0.0 })
                        for (i in 0..list.size) {
                            match (list[i]) {
                                case v: Float64 => a[i] = v
                                case n: Int64 => a[i] = Float64(n)
                                case _ => ()
                            }
                        }
                        this.min.fromArray(a)
                    case _ => ()
                }
            case None => ()
        }
        match (json.get("max")) {
            case Some(m) =>
                match (m) {
                    case arr: Array<Float64> => this.max.fromArray(arr)
                    case list: ArrayList<Any> =>
                        let a = Array<Float64>(list.size, { _ => 0.0 })
                        for (i in 0..list.size) {
                            match (list[i]) {
                                case v: Float64 => a[i] = v
                                case n: Int64 => a[i] = Float64(n)
                                case _ => ()
                            }
                        }
                        this.max.fromArray(a)
                    case _ => ()
                }
            case None => ()
        }
        return this
    }
}

/**
 * @brief[zh-cn] SAT 分离轴测试辅助函数
 * @param[zh-cn] axes 轴数组，每 3 个元素组成一个轴
 * v0 三角形顶点 0（相对于 AABB 中心）
 * v1 三角形顶点 1（相对于 AABB 中心）
 * v2 三角形顶点 2（相对于 AABB 中心）
 * extents AABB 的半范围
 * @return[zh-cn] 是否在所有轴上都重叠（true 表示可能相交）
 *
 * @brief[en] SAT (Separating Axis Theorem) test helper function
 * @param[en] axes Axis array, every 3 elements form an axis
 * v0 Triangle vertex 0 (relative to AABB center)
 * v1 Triangle vertex 1 (relative to AABB center)
 * v2 Triangle vertex 2 (relative to AABB center)
 * extents AABB half-extents
 * @return[en] Whether overlapping on all axes (true means possibly intersecting)
 */
internal func satForAxes(axes: Array<Float64>, v0: Vector3, v1: Vector3, v2: Vector3, extents: Vector3): Bool {
    let testAxis = Vector3()
    var i: Int64 = 0
    while (i <= axes.size - 3) {
        testAxis.set(axes[i], axes[i + 1], axes[i + 2])
        let r = extents.x * abs(testAxis.x) + extents.y * abs(testAxis.y) + extents.z * abs(testAxis.z)
        let p0 = v0.dot(testAxis)
        let p1 = v1.dot(testAxis)
        let p2 = v2.dot(testAxis)
        if (max(-max(p0, max(p1, p2)), min(p0, min(p1, p2))) > r) {
            return false
        }
        i += 3
    }
    return true
}
