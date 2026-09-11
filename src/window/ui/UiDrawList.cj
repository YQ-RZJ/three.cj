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
 * @file[zh-cn] UiDrawList.cj — ImGui DrawList 自定义绘制封装
 * @brief[zh-cn] 封装 ImDrawList 的全部绘制方法，提供面向对象的绘制接口
 * @explain[zh-cn] 通过 UiDrawList.window()/background()/foreground() 获取 DrawList 实例，支持线条、矩形、圆形、文本、路径、贝塞尔曲线、剪裁等完整绘制能力。用法示例：
 *   let dl = UiDrawList.window()
 *   dl.addLine(x1, y1, x2, y2, color, thickness)
 *   dl.addRect(x1, y1, x2, y2, color, rounding, thickness)
 *   dl.addCircle(cx, cy, radius, color)
 *   dl.addText(x, y, color, "Hello")
 *   dl.pathClear(); dl.pathMoveTo(x0, y0); dl.pathLineTo(x1, y1); dl.pathStroke(color, thickness)
 *
 * @file[en] UiDrawList.cj — ImGui DrawList Custom Drawing Wrapper
 * @brief[en] Wraps all ImDrawList drawing methods into an OOP drawing interface
 * @explain[en] Obtain a DrawList via UiDrawList.window()/background()/foreground(); supports lines, rects, circles, text, paths, Bézier curves, clipping, and more.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*

/**
 * @brief[zh-cn] ImGui DrawList 封装类
 * @explain[zh-cn] 提供自定义绘制能力：线条、矩形、圆形、文本、路径等。
 *         通过静态方法获取窗口/前景/背景 DrawList。
 *
 * @brief[en] ImGui DrawList wrapper class
 * @explain[en] Provides custom drawing capabilities: lines, rects, circles, text, paths, etc.
 *         Obtain via static methods for window/foreground/background DrawList.
 */
public class UiDrawList {
    /// 底层 ImDrawList 指针
    private var _dl: CPointer<Unit>

    public init(dl!: CPointer<Unit>) {
        this._dl = dl
    }

    // ===== 静态获取方法 =====

    /**
     * @brief[zh-cn] 获取当前窗口 DrawList
     * @return[zh-cn] UiDrawList 实例
     *
     * @brief[en] Returns the current window DrawList
     * @return[en] UiDrawList instance
     */
    public static func window(): UiDrawList {
        return UiDrawList(dl: igGetWindowDrawList_cj())
    }

    /**
     * @brief[zh-cn] 获取背景 DrawList
     * @return[zh-cn] UiDrawList 实例
     *
     * @brief[en] Returns the background DrawList
     * @return[en] UiDrawList instance
     */
    public static func background(): UiDrawList {
        return UiDrawList(dl: igGetBackgroundDrawList_Nil_cj())
    }

    /**
     * @brief[zh-cn] 获取前景 DrawList
     * @return[zh-cn] UiDrawList 实例
     *
     * @brief[en] Returns the foreground DrawList
     * @return[en] UiDrawList instance
     */
    public static func foreground(): UiDrawList {
        return UiDrawList(dl: igGetForegroundDrawList_Nil_cj())
    }

    // ===== 基础绘制 =====

    /**
     * @brief[zh-cn] 绘制线条
     * @param[zh-cn] p1 起点
     * @param[zh-cn] p2 终点
     * @param[zh-cn] col 颜色（IM_COL32 格式）
     * @param[zh-cn] thickness 线宽
     *
     * @brief[en] Draws a line
     * @param[en] p1 Start point
     * @param[en] p2 End point
     * @param[en] col Color (IM_COL32 format)
     * @param[en] thickness Line width
     */
    public func addLine(p1: Vector2, p2: Vector2,
                        col: UInt32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddLine_cj(this._dl, ImVec2(Float32(p1.x), Float32(p1.y)), ImVec2(Float32(p2.x), Float32(p2.y)), col, thickness)
    }

    /**
     * @brief[zh-cn] 绘制矩形边框
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Draws a rectangle border
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func addRect(min: Vector2, max: Vector2,
                        col: UInt32, rounding!: Float32 = 0.0,
                        thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit {
        ImDrawList_AddRect_cj(this._dl, ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y)), col, rounding, thickness, flags)
    }

    /**
     * @brief[zh-cn] 绘制填充矩形
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Draws a filled rectangle
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func addRectFilled(min: Vector2, max: Vector2,
                              col: UInt32, rounding!: Float32 = 0.0,
                              flags!: Int32 = 0): Unit {
        ImDrawList_AddRectFilled_cj(this._dl, ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y)), col, rounding, flags)
    }

    /**
     * @brief[zh-cn] 绘制多色填充矩形
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Draws a multi-color filled rectangle
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func addRectFilledMultiColor(min: Vector2, max: Vector2,
                                        colUprLeft: UInt32, colUprRight: UInt32,
                                        colBotRight: UInt32, colBotLeft: UInt32): Unit {
        ImDrawList_AddRectFilledMultiColor_cj(this._dl, ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y)),
                                              colUprLeft, colUprRight, colBotRight, colBotLeft)
    }

    /**
     * @brief[zh-cn] 绘制三角形边框
     * @param[zh-cn] a 顶点 A
     * @param[zh-cn] b 顶点 B
     * @param[zh-cn] c 顶点 C
     *
     * @brief[en] Draws a triangle border
     * @param[en] a Vertex A
     * @param[en] b Vertex B
     * @param[en] c Vertex C
     */
    public func addTriangle(a: Vector2, b: Vector2, c: Vector2,
                            col: UInt32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddTriangle_cj(this._dl, ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)), ImVec2(Float32(c.x), Float32(c.y)), col, thickness)
    }

    /**
     * @brief[zh-cn] 绘制填充三角形
     * @param[zh-cn] a 顶点 A
     * @param[zh-cn] b 顶点 B
     * @param[zh-cn] c 顶点 C
     *
     * @brief[en] Draws a filled triangle
     * @param[en] a Vertex A
     * @param[en] b Vertex B
     * @param[en] c Vertex C
     */
    public func addTriangleFilled(a: Vector2, b: Vector2, c: Vector2, col: UInt32): Unit {
        ImDrawList_AddTriangleFilled_cj(this._dl, ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)), ImVec2(Float32(c.x), Float32(c.y)), col)
    }

    /**
     * @brief[zh-cn] 绘制圆形边框
     * @param[zh-cn] center 圆心
     *
     * @brief[en] Draws a circle border
     * @param[en] center Center point
     */
    public func addCircle(center: Vector2, radius: Float32, col: UInt32,
                          numSegments!: Int32 = 0, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddCircle_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, col, numSegments, thickness)
    }

    /**
     * @brief[zh-cn] 绘制填充圆形
     * @param[zh-cn] center 圆心
     *
     * @brief[en] Draws a filled circle
     * @param[en] center Center point
     */
    public func addCircleFilled(center: Vector2, radius: Float32, col: UInt32,
                                numSegments!: Int32 = 0): Unit {
        ImDrawList_AddCircleFilled_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, col, numSegments)
    }

    /**
     * @brief[zh-cn] 绘制椭圆边框
     * @param[zh-cn] center 椭圆中心
     * @param[zh-cn] radius 椭圆半径（x, y 两个方向）
     *
     * @brief[en] Draws an ellipse border
     * @param[en] center Ellipse center
     * @param[en] radius Ellipse radius (x and y directions)
     */
    public func addEllipse(center: Vector2, radius: Vector2,
                           col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0,
                           thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddEllipse_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), ImVec2(Float32(radius.x), Float32(radius.y)),
                                 col, rot, numSegments, thickness)
    }

    /**
     * @brief[zh-cn] 绘制填充椭圆
     * @param[zh-cn] center 椭圆中心
     * @param[zh-cn] radius 椭圆半径（x, y 两个方向）
     *
     * @brief[en] Draws a filled ellipse
     * @param[en] center Ellipse center
     * @param[en] radius Ellipse radius (x and y directions)
     */
    public func addEllipseFilled(center: Vector2, radius: Vector2,
                                 col: UInt32, rot!: Float32 = 0.0, numSegments!: Int32 = 0): Unit {
        ImDrawList_AddEllipseFilled_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), ImVec2(Float32(radius.x), Float32(radius.y)),
                                       col, rot, numSegments)
    }

    // ===== 文本绘制 =====

    /**
     * @brief[zh-cn] 绘制文本
     * @param[zh-cn] pos 文本位置
     *
     * @brief[en] Draws text
     * @param[en] pos Text position
     */
    public func addText(pos: Vector2, col: UInt32, text: String): Unit {
        let cs = unsafe { LibC.mallocCString(text) }
        ImDrawList_AddText_Vec2_cj(this._dl, ImVec2(Float32(pos.x), Float32(pos.y)), col, cs, CString(CPointer<UInt8>()))
        unsafe { LibC.free(cs) }
    }

    // ===== 贝塞尔曲线 =====

    /**
     * @brief[zh-cn] 绘制三次贝塞尔曲线
     * @param[zh-cn] p1 控制点 1
     * @param[zh-cn] p2 控制点 2
     * @param[zh-cn] p3 控制点 3
     * @param[zh-cn] p4 控制点 4
     *
     * @brief[en] Draws a cubic Bézier curve
     * @param[en] p1 Control point 1
     * @param[en] p2 Control point 2
     * @param[en] p3 Control point 3
     * @param[en] p4 Control point 4
     */
    public func addBezierCubic(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2,
                               col: UInt32, thickness!: Float32 = 1.0,
                               numSegments!: Int32 = 0): Unit {
        ImDrawList_AddBezierCubic_cj(this._dl,
            ImVec2(Float32(p1.x), Float32(p1.y)), ImVec2(Float32(p2.x), Float32(p2.y)),
            ImVec2(Float32(p3.x), Float32(p3.y)), ImVec2(Float32(p4.x), Float32(p4.y)),
            col, thickness, numSegments)
    }

    /**
     * @brief[zh-cn] 绘制二次贝塞尔曲线
     * @param[zh-cn] p1 控制点 1
     * @param[zh-cn] p2 控制点 2
     * @param[zh-cn] p3 控制点 3
     *
     * @brief[en] Draws a quadratic Bézier curve
     * @param[en] p1 Control point 1
     * @param[en] p2 Control point 2
     * @param[en] p3 Control point 3
     */
    public func addBezierQuadratic(p1: Vector2, p2: Vector2, p3: Vector2,
                                   col: UInt32,
                                   thickness!: Float32 = 1.0, numSegments!: Int32 = 0): Unit {
        ImDrawList_AddBezierQuadratic_cj(this._dl,
            ImVec2(Float32(p1.x), Float32(p1.y)), ImVec2(Float32(p2.x), Float32(p2.y)),
            ImVec2(Float32(p3.x), Float32(p3.y)),
            col, thickness, numSegments)
    }

    // ===== 路径绘制 =====

    /**
     * @brief[zh-cn] 清空路径
     *
     * @brief[en] Clears the path
     */
    public func pathClear(): Unit {
        ImDrawList_PathClear_cj(this._dl)
    }

    /**
     * @brief[zh-cn] 路径移动到点
     * @param[zh-cn] p 目标点
     *
     * @brief[en] Moves path to a point
     * @param[en] p Target point
     */
    public func pathMoveTo(p: Vector2): Unit {
        // imgui4cj 当前未导出 ImDrawList_PathMoveTo，使用 PathLineTo 作为兼容实现
        ImDrawList_PathLineTo_cj(this._dl, ImVec2(Float32(p.x), Float32(p.y)))
    }

    /**
     * @brief[zh-cn] 路径画线到点
     * @param[zh-cn] p 目标点
     *
     * @brief[en] Draws a line to a point on the path
     * @param[en] p Target point
     */
    public func pathLineTo(p: Vector2): Unit {
        ImDrawList_PathLineTo_cj(this._dl, ImVec2(Float32(p.x), Float32(p.y)))
    }

    /**
     * @brief[zh-cn] 路径描边
     *
     * @brief[en] Strokes the path
     */
    public func pathStroke(col: UInt32, flags!: Int32 = 0, thickness!: Float32 = 1.0): Unit {
        ImDrawList_PathStroke_cj(this._dl, col, thickness, flags)
    }

    /**
     * @brief[zh-cn] 路径填充（凸多边形）
     *
     * @brief[en] Fills the path (convex polygon)
     */
    public func pathFillConvex(col: UInt32): Unit {
        ImDrawList_PathFillConvex_cj(this._dl, col)
    }

    /**
     * @brief[zh-cn] 路径圆弧
     * @param[zh-cn] center 圆弧中心
     *
     * @brief[en] Draws a path arc
     * @param[en] center Arc center
     */
    public func pathArcTo(center: Vector2, radius: Float32,
                          aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit {
        ImDrawList_PathArcTo_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, aMin, aMax, numSegments)
    }

    /**
     * @brief[zh-cn] 路径矩形
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Draws a path rectangle
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func pathRect(min: Vector2, max: Vector2,
                         rounding!: Float32 = 0.0, flags!: Int32 = 0): Unit {
        ImDrawList_PathRect_cj(this._dl, ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y)), rounding, flags)
    }

    // ===== 剪裁 =====

    /**
     * @brief[zh-cn] 压入剪裁矩形
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Pushes a clip rectangle
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func pushClipRect(min: Vector2, max: Vector2,
                             intersectWithCurrent!: Bool = false): Unit {
        ImDrawList_PushClipRect_cj(this._dl, ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y)),
                                   if (intersectWithCurrent) { 1 } else { 0 })
    }

    /**
     * @brief[zh-cn] 弹出剪裁矩形
     *
     * @brief[en] Pops the clip rectangle
     */
    public func popClipRect(): Unit {
        ImDrawList_PopClipRect_cj(this._dl)
    }

    // ===== 状态查询 =====

    /**
     * @brief[zh-cn] 获取剪裁矩形最小点
     * @return[zh-cn] 最小点
     *
     * @brief[en] Returns the clip rectangle minimum
     * @return[en] Minimum point
     */
    public func getClipRectMin(): Vector2 {
        let v = ImDrawList_GetClipRectMin_cj(this._dl)
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 获取剪裁矩形最大点
     * @return[zh-cn] 最大点
     *
     * @brief[en] Returns the clip rectangle maximum
     * @return[en] Maximum point
     */
    public func getClipRectMax(): Vector2 {
        let v = ImDrawList_GetClipRectMax_cj(this._dl)
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 判断矩形是否可见
     * @param[zh-cn] min 矩形最小点
     * @param[zh-cn] max 矩形最大点
     *
     * @brief[en] Determine whether the rectangle is visible
     * @param[en] min Rectangle minimum
     * @param[en] max Rectangle maximum
     */
    public func isRectVisible(min: Vector2, max: Vector2): Bool {
        return igIsRectVisible_Vec2_cj(ImVec2(Float32(min.x), Float32(min.y)), ImVec2(Float32(max.x), Float32(max.y))) != 0
    }

    // ===== 水平/垂直线段 =====
    // ===== Horizontal/Vertical Line Segments =====

    /**
     * @brief[zh-cn] 绘制水平线段
     *
     * @brief[en] Draws a horizontal line segment
     */
    public func addLineH(x1: Float32, x2: Float32, y: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddLineH_cj(this._dl, x1, x2, y, col, thickness)
    }

    /**
     * @brief[zh-cn] 绘制垂直线段
     *
     * @brief[en] Draws a vertical line segment
     */
    public func addLineV(y1: Float32, y2: Float32, x: Float32, col: UInt32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddLineV_cj(this._dl, y1, y2, x, col, thickness)
    }

    // ===== 四边形 =====
    // ===== Quads =====

    /**
     * @brief[zh-cn] 绘制四边形边框
     *
     * @brief[en] Draws a quad border
     */
    public func addQuad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddQuad_cj(this._dl,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)),
            ImVec2(Float32(c.x), Float32(c.y)), ImVec2(Float32(d.x), Float32(d.y)),
            col, thickness)
    }

    /**
     * @brief[zh-cn] 绘制填充四边形
     *
     * @brief[en] Draws a filled quad
     */
    public func addQuadFilled(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: UInt32): Unit {
        ImDrawList_AddQuadFilled_cj(this._dl,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)),
            ImVec2(Float32(c.x), Float32(c.y)), ImVec2(Float32(d.x), Float32(d.y)),
            col)
    }

    // ===== 正多边形 =====
    // ===== Regular Polygons =====

    /**
     * @brief[zh-cn] 绘制正多边形边框
     *
     * @brief[en] Draws a regular polygon border
     */
    public func addNgon(center: Vector2, radius: Float32, col: UInt32, numSides: Int32, thickness!: Float32 = 1.0): Unit {
        ImDrawList_AddNgon_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, col, numSides, thickness)
    }

    /**
     * @brief[zh-cn] 绘制填充正多边形
     *
     * @brief[en] Draws a filled regular polygon
     */
    public func addNgonFilled(center: Vector2, radius: Float32, col: UInt32, numSides: Int32): Unit {
        ImDrawList_AddNgonFilled_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, col, numSides)
    }

    // ===== 图片 =====
    // ===== Images =====

    /**
     * @brief[zh-cn] 绘制图片
     * @param[zh-cn] texRef 纹理引用指针
     * @param[zh-cn] pMin 左上角
     * @param[zh-cn] pMax 右下角
     * @param[zh-cn] uvMin UV 左上角（默认 0,0）
     * @param[zh-cn] uvMax UV 右下角（默认 1,1）
     * @param[zh-cn] tintCol 色调颜色（默认白色=不着色）
     *
     * @brief[en] Draws an image
     * @param[en] texRef Texture reference pointer
     * @param[en] pMin Top-left corner
     * @param[en] pMax Bottom-right corner
     * @param[en] uvMin UV top-left (default 0,0)
     * @param[en] uvMax UV bottom-right (default 1,1)
     * @param[en] tintCol Tint color (default white=no tint)
     */
    public func addImage(texRef: CPointer<Unit>, pMin: Vector2, pMax: Vector2,
                         uvMin!: ImVec2 = ImVec2(0.0, 0.0), uvMax!: ImVec2 = ImVec2(1.0, 1.0),
                         tintCol!: UInt32 = 0xFFFFFFFF): Unit {
        ImDrawList_AddImage_cj(this._dl, texRef,
            ImVec2(Float32(pMin.x), Float32(pMin.y)), ImVec2(Float32(pMax.x), Float32(pMax.y)),
            uvMin, uvMax, tintCol)
    }

    /**
     * @brief[zh-cn] 绘制四点映射图片
     * @param[zh-cn] texRef 纹理引用指针
     * @param[zh-cn] a,b,c,d 四个顶点
     *
     * @brief[en] Draws a quad-mapped image
     * @param[en] texRef Texture reference pointer
     * @param[en] a,b,c,d Four vertices
     */
    public func addImageQuad(texRef: CPointer<Unit>, a: Vector2, b: Vector2, c: Vector2, d: Vector2,
                              uvA!: ImVec2 = ImVec2(0.0, 0.0), uvB!: ImVec2 = ImVec2(1.0, 0.0),
                              uvC!: ImVec2 = ImVec2(1.0, 1.0), uvD!: ImVec2 = ImVec2(0.0, 1.0),
                              tintCol!: UInt32 = 0xFFFFFFFF): Unit {
        ImDrawList_AddImageQuad_cj(this._dl, texRef,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)),
            ImVec2(Float32(c.x), Float32(c.y)), ImVec2(Float32(d.x), Float32(d.y)),
            uvA, uvB, uvC, uvD, tintCol)
    }

    /**
     * @brief[zh-cn] 绘制圆角图片
     * @param[zh-cn] texRef 纹理引用指针
     * @param[zh-cn] pMin 左上角
     * @param[zh-cn] pMax 右下角
     * @param[zh-cn] rounding 圆角半径
     *
     * @brief[en] Draws a rounded image
     * @param[en] texRef Texture reference pointer
     * @param[en] pMin Top-left corner
     * @param[en] pMax Bottom-right corner
     * @param[en] rounding Corner rounding radius
     */
    public func addImageRounded(texRef: CPointer<Unit>, pMin: Vector2, pMax: Vector2,
                                 rounding: Float32, uvMin!: ImVec2 = ImVec2(0.0, 0.0),
                                 uvMax!: ImVec2 = ImVec2(1.0, 1.0), tintCol!: UInt32 = 0xFFFFFFFF): Unit {
        ImDrawList_AddImageRounded_cj(this._dl, texRef,
            ImVec2(Float32(pMin.x), Float32(pMin.y)), ImVec2(Float32(pMax.x), Float32(pMax.y)),
            uvMin, uvMax, tintCol, rounding, 0)
    }

    // ===== 多边形/折线 =====
    // ===== Polylines / Polygons =====

    /**
     * @brief[zh-cn] 绘制折线（开放或闭合多边形）
     * @param[zh-cn] points 顶点数组
     * @param[zh-cn] col 颜色
     * @param[zh-cn] thickness 线宽
     * @param[zh-cn] flags ImDrawFlags
     *
     * @brief[en] Draws a polyline (open or closed polygon)
     * @param[en] points Vertex array
     * @param[en] col Color
     * @param[en] thickness Line width
     * @param[en] flags ImDrawFlags
     */
    public func addPolyline(points: CPointer<ImVec2>, numPoints: Int32, col: UInt32,
                            thickness!: Float32 = 1.0, flags!: Int32 = 0): Unit {
        ImDrawList_AddPolyline_cj(this._dl, points, numPoints, col, thickness, flags)
    }

    /**
     * @brief[zh-cn] 绘制凸多边形填充
     *
     * @brief[en] Draws a convex polygon fill
     */
    public func addConvexPolyFilled(points: CPointer<ImVec2>, numPoints: Int32, col: UInt32): Unit {
        ImDrawList_AddConvexPolyFilled_cj(this._dl, points, numPoints, col)
    }

    /**
     * @brief[zh-cn] 绘制凹多边形填充
     *
     * @brief[en] Draws a concave polygon fill
     */
    public func addConcavePolyFilled(points: CPointer<ImVec2>, numPoints: Int32, col: UInt32): Unit {
        ImDrawList_AddConcavePolyFilled_cj(this._dl, points, numPoints, col)
    }

    // ===== 路径扩展 =====
    // ===== Path Extensions =====

    /**
     * @brief[zh-cn] 路径画线到点（合并重复点）
     *
     * @brief[en] Path line to point (merges duplicates)
     */
    public func pathLineToMergeDuplicate(p: Vector2): Unit {
        ImDrawList_PathLineToMergeDuplicate_cj(this._dl, ImVec2(Float32(p.x), Float32(p.y)))
    }

    /**
     * @brief[zh-cn] 路径填充（凹多边形）
     *
     * @brief[en] Path fill (concave polygon)
     */
    public func pathFillConcave(col: UInt32): Unit {
        ImDrawList_PathFillConcave_cj(this._dl, col)
    }

    /**
     * @brief[zh-cn] 路径椭圆弧
     *
     * @brief[en] Path elliptical arc
     */
    public func pathEllipticalArcTo(center: Vector2, radius: Vector2, rot: Float32,
                                     aMin: Float32, aMax: Float32, numSegments!: Int32 = 0): Unit {
        ImDrawList_PathEllipticalArcTo_cj(this._dl,
            ImVec2(Float32(center.x), Float32(center.y)), ImVec2(Float32(radius.x), Float32(radius.y)),
            rot, aMin, aMax, numSegments)
    }

    /**
     * @brief[zh-cn] 路径三次贝塞尔曲线
     *
     * @brief[en] Path cubic Bézier curve
     */
    public func pathBezierCubicCurveTo(p2: Vector2, p3: Vector2, p4: Vector2, numSegments!: Int32 = 0): Unit {
        ImDrawList_PathBezierCubicCurveTo_cj(this._dl,
            ImVec2(Float32(p2.x), Float32(p2.y)),
            ImVec2(Float32(p3.x), Float32(p3.y)),
            ImVec2(Float32(p4.x), Float32(p4.y)),
            numSegments)
    }

    /**
     * @brief[zh-cn] 路径二次贝塞尔曲线
     *
     * @brief[en] Path quadratic Bézier curve
     */
    public func pathBezierQuadraticCurveTo(p2: Vector2, p3: Vector2, numSegments!: Int32 = 0): Unit {
        ImDrawList_PathBezierQuadraticCurveTo_cj(this._dl,
            ImVec2(Float32(p2.x), Float32(p2.y)),
            ImVec2(Float32(p3.x), Float32(p3.y)),
            numSegments)
    }

    /**
     * @brief[zh-cn] 快速路径圆弧（固定细分，更高效）
     *
     * @brief[en] Fast path arc (fixed subdivisions, more efficient)
     */
    public func pathArcToFast(center: Vector2, radius: Float32, aMinOf12: Int32, aMaxOf12: Int32): Unit {
        ImDrawList_PathArcToFast_cj(this._dl, ImVec2(Float32(center.x), Float32(center.y)), radius, aMinOf12, aMaxOf12)
    }

    // ===== 通道分割（高级：多图层绘制） =====
    // ===== Channel Split (advanced: multi-layer drawing) =====

    /**
     * @brief[zh-cn] 分割绘制通道
     * @param[zh-cn] channels 通道数量
     *
     * @brief[en] Splits drawing channels
     * @param[en] channels Number of channels
     */
    public func channelsSplit(channels: Int32): Unit {
        ImDrawList_ChannelsSplit_cj(this._dl, channels)
    }

    /**
     * @brief[zh-cn] 合并绘制通道
     *
     * @brief[en] Merges drawing channels
     */
    public func channelsMerge(): Unit {
        ImDrawList_ChannelsMerge_cj(this._dl)
    }

    /**
     * @brief[zh-cn] 切换到指定通道
     * @param[zh-cn] channel 通道索引
     *
     * @brief[en] Switches to the specified channel
     * @param[en] channel Channel index
     */
    public func channelsSetCurrent(channel: Int32): Unit {
        ImDrawList_ChannelsSetCurrent_cj(this._dl, channel)
    }

    // ===== 纹理管理 =====
    // ===== Texture Management =====

    /**
     * @brief[zh-cn] 压入纹理
     *
     * @brief[en] Pushes a texture
     */
    public func pushTexture(texRef: CPointer<Unit>): Unit {
        ImDrawList_PushTexture_cj(this._dl, texRef)
    }

    /**
     * @brief[zh-cn] 弹出纹理
     *
     * @brief[en] Pops a texture
     */
    public func popTexture(): Unit {
        ImDrawList_PopTexture_cj(this._dl)
    }

    // ===== 原始顶点操作（高级） =====
    // ===== Primitive Vertex Operations (advanced) =====

    /**
     * @brief[zh-cn] 预分配顶点/索引缓冲
     * @param[zh-cn] vtxCount 顶点数
     * @param[zh-cn] idxCount 索引数
     *
     * @brief[en] Pre-allocates vertex/index buffers
     * @param[en] vtxCount Vertex count
     * @param[en] idxCount Index count
     */
    public func primReserve(vtxCount: Int32, idxCount: Int32): Unit {
        ImDrawList_PrimReserve_cj(this._dl, idxCount, vtxCount)
    }

    /**
     * @brief[zh-cn] 取消预分配
     *
     * @brief[en] Un-reserves pre-allocated buffers
     */
    public func primUnreserve(vtxCount: Int32, idxCount: Int32): Unit {
        ImDrawList_PrimUnreserve_cj(this._dl, idxCount, vtxCount)
    }

    /**
     * @brief[zh-cn] 添加原始矩形（无 UV 变换，最快）
     * @param[zh-cn] a 左上角
     * @param[zh-cn] c 右下角
     *
     * @brief[en] Adds a primitive rectangle (no UV transform, fastest)
     * @param[en] a Top-left corner
     * @param[en] c Bottom-right corner
     */
    public func primRect(a: Vector2, c: Vector2, col: UInt32): Unit {
        ImDrawList_PrimRect_cj(this._dl,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(c.x), Float32(c.y)), col)
    }

    /**
     * @brief[zh-cn] 添加原始矩形（带 UV）
     * @param[zh-cn] a 左上角
     * @param[zh-cn] c 右下角
     * @param[zh-cn] uvA UV 左上
     * @param[zh-cn] uvC UV 右下
     *
     * @brief[en] Adds a primitive rectangle (with UV)
     * @param[en] a Top-left corner
     * @param[en] c Bottom-right corner
     * @param[en] uvA UV top-left
     * @param[en] uvC UV bottom-right
     */
    public func primRectUV(a: Vector2, c: Vector2, uvA: ImVec2, uvC: ImVec2, col: UInt32): Unit {
        ImDrawList_PrimRectUV_cj(this._dl,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(c.x), Float32(c.y)),
            uvA, uvC, col)
    }

    /**
     * @brief[zh-cn] 添加原始四边形（带 UV）
     * @param[zh-cn] a,b,c,d 四个顶点
     * @param[zh-cn] uvA~uvD 对应 UV
     *
     * @brief[en] Adds a primitive quad (with UV)
     * @param[en] a,b,c,d Four vertices
     * @param[en] uvA~uvD Corresponding UVs
     */
    public func primQuadUV(a: Vector2, b: Vector2, c: Vector2, d: Vector2,
                            uvA: ImVec2, uvB: ImVec2, uvC: ImVec2, uvD: ImVec2, col: UInt32): Unit {
        ImDrawList_PrimQuadUV_cj(this._dl,
            ImVec2(Float32(a.x), Float32(a.y)), ImVec2(Float32(b.x), Float32(b.y)),
            ImVec2(Float32(c.x), Float32(c.y)), ImVec2(Float32(d.x), Float32(d.y)),
            uvA, uvB, uvC, uvD, col)
    }

    // ===== 克隆 =====
    // ===== Clone =====

    /**
     * @brief[zh-cn] 克隆当前 DrawList 输出（绘制数据快照）
     *
     * @brief[en] Clones the current DrawList output (drawing data snapshot)
     */
    public func cloneOutput(): CPointer<Unit> {
        return ImDrawList_CloneOutput_cj(this._dl)
    }
}
