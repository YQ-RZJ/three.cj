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
 * @file[zh-cn] Box2
 * @brief[zh-cn] 2D 包围盒
 * @explain[zh-cn] 表示二维空间中的轴对齐包围盒 (AABB)，用最小点和最大点表示。
 *
 * @file[en] Box2
 * @brief[en] 2D bounding box
 * @explain[en] Represents an axis-aligned bounding box (AABB) in 2D space, defined by min and max points.
 */
package three.core.math

import std.math.*
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 2D 轴对齐包围盒类，用最小点和最大点表示
 * @explain[zh-cn] 支持设置、包含检测、交集/并集运算等操作
 *
 * @brief[en] 2D axis-aligned bounding box class, defined by min and max points
 * @explain[en] Supports set, containment test, intersection/union operations etc.
 */
@JsonAdapter
public class Box2 {
    /**
     * @brief[zh-cn] 包围盒的下边界
     *
     * @brief[en] Lower bound of the bounding box
     */
    public var min: Vector2
    /**
     * @brief[zh-cn] 包围盒的上边界
     *
     * @brief[en] Upper bound of the bounding box
     */
    public var max: Vector2

    /**
     * @brief[zh-cn] 构造空包围盒（min=+Inf, max=-Inf）
     *
     * @brief[en] Construct an empty bounding box (min=+Inf, max=-Inf)
     */
    public init() {
        this.min = Vector2(Float64.Inf, Float64.Inf)
        this.max = Vector2(-Float64.Inf, -Float64.Inf)
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
    public init(min: Vector2, max: Vector2) {
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
    public func set(min: Vector2, max: Vector2): Box2 {
        this.min.copy(min)
        this.max.copy(max)
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
    public func setFromPoints(points: ArrayList<Vector2>): Box2 {
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
    public func setFromCenterAndSize(center: Vector2, size: Vector2): Box2 {
        let halfSize = Vector2().copy(size).multiplyScalar(0.5)
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
    public func clone(): Box2 {
        return Box2().copy(this)
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
    public func copy(b: Box2): Box2 {
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
    public func makeEmpty(): Box2 {
        this.min.set(Float64.Inf, Float64.Inf)
        this.max.set(-Float64.Inf, -Float64.Inf)
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
        return this.max.x < this.min.x || this.max.y < this.min.y
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
    public func getCenter(target: Vector2): Vector2 {
        if (this.isEmpty()) {
            return target.set(0.0, 0.0)
        }
        return target.addVectors(this.min, this.max).multiplyScalar(0.5)
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
    public func getSize(target: Vector2): Vector2 {
        if (this.isEmpty()) {
            return target.set(0.0, 0.0)
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
    public func expandByPoint(point: Vector2): Box2 {
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
    public func expandByVector(v: Vector2): Box2 {
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
    public func expandByScalar(s: Float64): Box2 {
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
    public func containsPoint(point: Vector2): Bool {
        return point.x >= this.min.x && point.x <= this.max.x &&
            point.y >= this.min.y && point.y <= this.max.y
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
    public func containsBox(b: Box2): Bool {
        return this.min.x <= b.min.x && b.max.x <= this.max.x &&
            this.min.y <= b.min.y && b.max.y <= this.max.y
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
    public func getParameter(point: Vector2, target: Vector2): Vector2 {
        return target.set(
            (point.x - this.min.x) / (this.max.x - this.min.x),
            (point.y - this.min.y) / (this.max.y - this.min.y)
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
    public func intersectsBox(b: Box2): Bool {
        return b.max.x >= this.min.x && b.min.x <= this.max.x &&
            b.max.y >= this.min.y && b.min.y <= this.max.y
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
    public func clampPoint(point: Vector2, target: Vector2): Vector2 {
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
    public func distanceToPoint(point: Vector2): Float64 {
        let clampedPoint = Vector2().copy(point).clamp(this.min, this.max)
        return clampedPoint.distanceTo(point)
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
    public func intersect(b: Box2): Box2 {
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
    public func union(b: Box2): Box2 {
        this.min.min(b.min)
        this.max.max(b.max)
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
    public func translate(offset: Vector2): Box2 {
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
    public func equals(b: Box2): Bool {
        return this.min.equals(b.min) && this.max.equals(b.max)
    }
}
