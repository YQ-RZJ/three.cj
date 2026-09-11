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
 * @file[zh-cn] ShapeUtils 形状工具函数
 * @brief[zh-cn] 对应 Three.js extras/ShapeUtils.js，提供 2D 多边形面积、绕向判断与三角剖分
 * @explain[zh-cn] 提供 2D 多边形（contour）的面积计算、绕向判断，以及带孔洞（holes）的复合形状的三角剖分功能
 *
 * @file[en] ShapeUtils shape utility functions
 * @brief[en] Corresponds to Three.js extras/ShapeUtils.js, provides 2D polygon area, winding direction and triangulation
 * @explain[en] Provides 2D polygon area calculation, winding direction determination, and triangulation of compound shapes with holes
 *
 * @package three.rendering.geometry
 */
package three.rendering.geometry

import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 形状工具类，提供 2D 多边形的面积计算、绕向判断与三角剖分功能
 * @explain[zh-cn] 提供 2D 多边形（contour）的面积计算、绕向判断，以及带孔洞（holes）的复合形状的三角剖分功能。参见：https://three.js.org/docs/#api/en/extras/ShapeUtils
 *
 * @brief[en] Shape utility class, provides 2D polygon area calculation, winding direction and triangulation
 * @explain[en] Provides 2D polygon area calculation, winding direction determination, and triangulation of compound shapes with holes. See: https://three.js.org/docs/#api/en/extras/ShapeUtils
 */
public class ShapeUtils {
    /**
     * @brief[zh-cn] 计算 2D 轮廓多边形的面积
     * @explain[zh-cn] 采用鞋带公式（shoelace formula）沿闭合边累加坐标差，最终乘 0.5 得到有符号面积：顺时针绕向为负，逆时针为正
     * @param[zh-cn] contour 顶点数组，按顺序定义多边形边界
     * @return[zh-cn] 有符号面积，正值表示逆时针，负值表示顺时针
     *
     * @brief[en] Calculate the area of a 2D contour polygon
     * @explain[en] Uses the shoelace formula to accumulate coordinate differences along closed edges, multiplied by 0.5 to get signed area: negative for clockwise, positive for counterclockwise
     * @param[en] contour Vertex array defining polygon boundary in order
     * @return[en] Signed area, positive for counterclockwise, negative for clockwise
     */
    public static func area(contour: Array<Vector2>): Float64 {
        let n = contour.size
        var a = 0.0
        // JS 用 p = n - 1, q = 0 起始，逐次 p = q, q++ 形成闭合遍历
        var p = n - 1
        for (q in 0..n) {
            a += contour[p].x * contour[q].y - contour[q].x * contour[p].y
            p = q
        }
        return a * 0.5
    }

    /**
     * @brief[zh-cn] 判断轮廓是否为顺时针绕向
     * @explain[zh-cn] 通过 area 返回值的符号判断：area < 0 即顺时针
     * @param[zh-cn] pts 顶点数组
     * @return[zh-cn] true 表示顺时针，false 表示逆时针
     *
     * @brief[en] Determine whether the contour has clockwise winding
     * @explain[en] Determines by the sign of the area return value: area < 0 means clockwise
     * @param[en] pts Vertex array
     * @return[en] true for clockwise, false for counterclockwise
     */
    public static func isClockWise(pts: Array<Vector2>): Bool {
        return ShapeUtils.area(pts) < 0.0
    }

    /**
     * @brief[zh-cn] 对带孔洞的复合形状进行三角剖分
     * @explain[zh-cn] 将轮廓 contour 与若干孔洞 holes 拼合后调用 Earcut.triangulate，把平面坐标数组剖分为若干三角面，每个面用 3 个顶点序号表示
     * @param[zh-cn] contour 外轮廓顶点数组（会被就地修改：去除与首点重复的尾点）
     * holes 各孔洞的顶点数组列表（同样会被就地修改）
     * @return[zh-cn] 三角面数组，每个元素为长度 3 的序号数组（对应 contour+holes 拼合后的顶点序号）
     *
     * @brief[en] Triangulate a compound shape with holes
     * @explain[en] Combines contour with holes and calls Earcut.triangulate, splitting the planar coordinate array into triangular faces, each represented by 3 vertex indices
     * @param[en] contour Outer contour vertex array (modified in-place: removes trailing duplicate of first point)
     * holes List of hole vertex arrays (also modified in-place)
     * @return[en] Triangle face array, each element is a length-3 index array (corresponding to combined contour+holes vertex indices)
     */
    public static func triangulateShape(contour: ArrayList<Vector2>, holes: ArrayList<ArrayList<Vector2>>): Array<Array<UInt32>> {
        let vertices = ArrayList<Float64>() // 平面坐标数组 [x0,y0, x1,y1, ...]
        let holeIndices = ArrayList<Int64>() // 各孔洞在 vertices 中的起始顶点序号
        let faces = ArrayList<Array<UInt32>>() // 最终三角面数组

        removeDupEndPts(contour)
        addContour(vertices, contour)

        var holeIndex = contour.size
        for (i in 0..holes.size) {
            let hole = holes[i]
            removeDupEndPts(hole)
            holeIndices.add(holeIndex)
            holeIndex += hole.size
            addContour(vertices, hole)
        }

        // Earcut.triangulate 接收 Array，手动把 ArrayList 转为 Array
        let verticesArr = Array<Float64>(vertices.size, { k => vertices[k] })
        let holeIndicesArr = Array<Int64>(holeIndices.size, { k => holeIndices[k] })
        let triangles = Earcut.triangulate(verticesArr, holeIndicesArr, dim: 2)

        // 每 3 个连续序号组成一个三角面
        var idx = 0
        while (idx < triangles.size) {
            let cur = idx
            let face = Array<UInt32>(3, { k => triangles[cur + k] })
            faces.add(face)
            idx += 3
        }

        // ArrayList<Array<UInt32>> → Array<Array<UInt32>>
        return Array<Array<UInt32>>(faces.size, { k => faces[k] })
    }

    /**
     * @brief[zh-cn] 去除与首点重复的尾点，避免 Earcut 退化
     *
     * @brief[en] Remove trailing point duplicating the first point to avoid Earcut degeneration
     */
    private static func removeDupEndPts(points: ArrayList<Vector2>): Unit {
        let l = points.size
        if (l > 2 && points[l - 1].equals(points[0])) {
            points.remove((l - 1)..l)
        }
    }

    /**
     * @brief[zh-cn] 把 contour 的 x、y 顺序追加到 vertices 数组
     *
     * @brief[en] Append contour's x, y coordinates to vertices array in order
     */
    private static func addContour(vertices: ArrayList<Float64>, contour: ArrayList<Vector2>): Unit {
        for (i in 0..contour.size) {
            vertices.add(contour[i].x)
            vertices.add(contour[i].y)
        }
    }
}
