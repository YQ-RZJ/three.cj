/**
 * @file[zh-cn] 形状路径
 * @brief[zh-cn] 管理多个子路径的容器类，用于构建复杂 2D 形状
 * @explain[zh-cn] 
 * ShapePath 提供 moveTo/lineTo/bezierCurveTo 等方法创建子路径，
 * 并可将子路径转换为 Shape 对象数组。
 * 对应 Three.js extras/core/ShapePath.js。
 *
 * @file[en] Shape Path
 * @brief[en] Container class managing multiple sub-paths for building complex 2D shapes
 * @explain[en] 
 * ShapePath provides moveTo/lineTo/bezierCurveTo methods to create sub-paths,
 * and can convert sub-paths into an array of Shape objects.
 * Corresponds to Three.js extras/core/ShapePath.js.
 */
package three.rendering.geometry

import three.core.math.*
import std.collection.*

public class ShapePath {
    // 子路径列表：元素均为 Path（moveTo 创建）。具体化为 ArrayList<Path> 替代原 ArrayList<Any>。
    public var subPaths: ArrayList<Path>
    public var currentPath: Option<Path>

    public init() {
        this.subPaths = ArrayList<Path>()
        this.currentPath = None
    }
    public func moveTo(x: Float64, y: Float64): Unit {
        let p = Path()
        p.moveTo(x, y)
        this.currentPath = Some(p)
        this.subPaths.add(p)
    }
    public func lineTo(x: Float64, y: Float64): Unit {
        match (this.currentPath) {
            case Some(p) => p.lineTo(x, y)
            case None => ()
        }
    }
    public func quadraticCurveTo(cpx: Float64, cpy: Float64, x: Float64, y: Float64): Unit {
        match (this.currentPath) {
            case Some(p) => p.quadraticCurveTo(cpx, cpy, x, y)
            case None => ()
        }
    }
    /**
     * @brief[zh-cn] 从当前点画三次贝塞尔曲线到指定位置
     * @param[zh-cn] cp1x 第一个控制点 X 坐标
     * cp1y 第一个控制点 Y 坐标
     * cp2x 第二个控制点 X 坐标
     * cp2y 第二个控制点 Y 坐标
     * x 目标 X 坐标
     * y 目标 Y 坐标
     *
     * @brief[en] Draws a cubic Bezier curve from the current point to the specified position
     * @param[en] cp1x First control point X coordinate
     * cp1y First control point Y coordinate
     * cp2x Second control point X coordinate
     * cp2y Second control point Y coordinate
     * x Target X coordinate
     * y Target Y coordinate
     */
    public func bezierCurveTo(cp1x: Float64, cp1y: Float64, cp2x: Float64, cp2y: Float64, x: Float64, y: Float64): Unit {
        match (this.currentPath) {
            case Some(p) => p.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)
            case None => ()
        }
    }
    public func splineThru(points: Array<Vector3>): Unit {
        match (this.currentPath) {
            case Some(p) => p.splineThru(points)
            case None => ()
        }
    }
    /**
     * @brief[zh-cn] 将所有子路径转换为 Shape 对象数组
     * @return[zh-cn] Shape 对象数组
     *
     * @brief[en] Converts all sub-paths to an array of Shape objects
     * @return[en] Array of Shape objects
     */
    public func toShapes(): Array<Shape> {
        let shapes = ArrayList<Shape>()
        for (i in 0..this.subPaths.size) {
            // subPaths 已具体化为 ArrayList<Path>，直接使用
            shapes.add(Shape(this.subPaths[i].getPoints(5)))
        }
        return shapes.toArray()
    }
}