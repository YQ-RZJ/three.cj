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
 * @file[zh-cn] UiHelpers.cj — ImGui 辅助类型（ImColor / ImRect）
 * @brief[zh-cn] 封装 ImColor 和 ImRect，提供颜色构造与矩形运算工具
 * @explain[zh-cn] 用法示例：
 *   let col = UiColor.fromRGBA(1.0, 0.5, 0.2, 1.0)
 *   let rect = UiRect.fromPosSize(10.0, 20.0, 100.0, 50.0)
 *   if (rect.contains(50.0, 30.0)) { ... }
 *
 * @file[en] UiHelpers.cj — ImGui Helper Types (ImColor / ImRect)
 * @brief[en] Wraps ImColor and ImRect for color construction and rectangle math
 * @explain[en] Usage example:
 *   let col = UiColor.fromRGBA(1.0, 0.5, 0.2, 1.0)
 *   let rect = UiRect.fromPosSize(10.0, 20.0, 100.0, 50.0)
 *   if (rect.contains(50.0, 30.0)) { ... }
 * @explain[en] Usage example:
 *   let col = UiColor.fromRGBA(1.0, 0.5, 0.2, 1.0)
 *   let rect = UiRect.fromPosSize(10.0, 20.0, 100.0, 50.0)
 *   if (rect.contains(50.0, 30.0)) { ... }
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// =============================================================================
// UiColor — 颜色构造辅助
// Color Construction Helper
// =============================================================================

/**
 * @brief[zh-cn] 颜色构造辅助类
 * @explain[zh-cn] 封装 ImColor 的构造与转换方法。
 *         内部持有 ImVec4（RGBA float 0~1），可直接传给 ImGui 颜色 API。
 *
 * @brief[en] Color construction helper class
 * @explain[en] Wraps ImColor construction and conversion methods.
 *         Internally holds ImVec4 (RGBA float 0~1), passable directly to ImGui color APIs.
 */
public class UiColor {
    private var _col: ImVec4

    public init(col: ImVec4) { this._col = col }

    /**
     * @brief[zh-cn] 从 RGBA float 构造
     *
     * @brief[en] Constructs from RGBA float
     */
    public static func fromRGBA(r: Float32, g: Float32, b: Float32, a: Float32): UiColor {
        return UiColor(ImVec4(r, g, b, a))
    }

    /**
     * @brief[zh-cn] 从 HSV 构造
     *
     * @brief[en] Constructs from HSV
     */
    public static func fromHSV(h: Float32, s: Float32, v: Float32, a!: Float32 = 1.0f32): UiColor {
        let ptr = ImColor_HSV_cj(h, s, v, a)
        let colPtr = ImColor_ImColor_Vec4_cj(unsafe { CPointer<ImVec4>(ptr).read() })
        let vec = unsafe { CPointer<ImVec4>(colPtr).read() }
        return UiColor(vec)
    }

    /**
     * @brief[zh-cn] 从 ImU32（RGBA packed）构造
     *
     * @brief[en] Constructs from ImU32 (RGBA packed)
     */
    public static func fromU32(col: UInt32): UiColor {
        let ptr = ImColor_ImColor_U32_cj(col)
        let vec = unsafe { CPointer<ImVec4>(ptr).read() }
        return UiColor(vec)
    }

    /**
     * @brief[zh-cn] 获取底层 ImVec4
     *
     * @brief[en] Gets the underlying ImVec4
     */
    public func getVec4(): ImVec4 { return this._col }

    /**
     * @brief[zh-cn] 获取 R 分量
     *
     * @brief[en] Gets the R component
     */
    public func r(): Float32 { return this._col.x }
    /**
     * @brief[zh-cn] 获取 G 分量
     *
     * @brief[en] Gets the G component
     */
    public func g(): Float32 { return this._col.y }
    /**
     * @brief[zh-cn] 获取 B 分量
     *
     * @brief[en] Gets the B component
     */
    public func b(): Float32 { return this._col.z }
    /**
     * @brief[zh-cn] 获取 A 分量
     *
     * @brief[en] Gets the A component
     */
    public func a(): Float32 { return this._col.w }

    /**
     * @brief[zh-cn] 设置 HSV（就地修改）
     *
     * @brief[en] Sets HSV (in-place modification)
     */
    public func setHSV(h: Float32, s: Float32, v: Float32): Unit {
        let ptr = ImColor_HSV_cj(h, s, v, this._col.w)
        this._col = unsafe { CPointer<ImVec4>(ptr).read() }
    }

    /**
     * @brief[zh-cn] 转换为 ImU32
     *
     * @brief[en] Converts to ImU32
     */
    public func toU32(): UInt32 {
        return igColorConvertFloat4ToU32_cj(this._col)
    }
}

// =============================================================================
// UiRect — 矩形运算辅助
// Rectangle Math Helper
// =============================================================================

/**
 * @brief[zh-cn] 矩形运算辅助类
 * @explain[zh-cn] 封装 ImRect 的构造、查询和变换方法。
 *         内部持有 min/max 两个 ImVec2（左上角/右下角）。
 *
 * @brief[en] Rectangle math helper class
 * @explain[en] Wraps ImRect construction, query and transform methods.
 *         Internally holds min/max ImVec2 (top-left / bottom-right).
 */
public class UiRect {
    private var _min: ImVec2
    private var _max: ImVec2

    public init(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32) {
        this._min = ImVec2(minX, minY)
        this._max = ImVec2(maxX, maxY)
    }

    public init(min: ImVec2, max: ImVec2) {
        this._min = min
        this._max = max
    }

    /**
     * @brief[zh-cn] 从位置和尺寸构造
     *
     * @brief[en] Constructs from position and size
     */
    public static func fromPosSize(x: Float32, y: Float32, w: Float32, h: Float32): UiRect {
        return UiRect(x, y, x + w, y + h)
    }

    // ===== 查询 =====
    // ===== Queries =====

    /**
     * @brief[zh-cn] 矩形中心点
     *
     * @brief[en] Rectangle center point
     */
    public func getCenter(): ImVec2 {
        return ImRect_GetCenter_cj(this.toPtr())
    }

    /**
     * @brief[zh-cn] 矩形尺寸
     *
     * @brief[en] Rectangle size
     */
    public func getSize(): ImVec2 {
        return ImRect_GetSize_cj(this.toPtr())
    }

    /**
     * @brief[zh-cn] 宽度
     *
     * @brief[en] Width
     */
    public func getWidth(): Float32 { return this._max.x - this._min.x }
    /**
     * @brief[zh-cn] 高度
     *
     * @brief[en] Height
     */
    public func getHeight(): Float32 { return this._max.y - this._min.y }
    /**
     * @brief[zh-cn] 面积
     *
     * @brief[en] Area
     */
    public func getArea(): Float32 { return this.getWidth() * this.getHeight() }

    /**
     * @brief[zh-cn] 左上角
     *
     * @brief[en] Top-left corner
     */
    public func getTL(): ImVec2 { return ImRect_GetTL_cj(this.toPtr()) }
    /**
     * @brief[zh-cn] 右上角
     *
     * @brief[en] Top-right corner
     */
    public func getTR(): ImVec2 { return ImRect_GetTR_cj(this.toPtr()) }
    /**
     * @brief[zh-cn] 左下角
     *
     * @brief[en] Bottom-left corner
     */
    public func getBL(): ImVec2 { return ImRect_GetBL_cj(this.toPtr()) }
    /**
     * @brief[zh-cn] 右下角
     *
     * @brief[en] Bottom-right corner
     */
    public func getBR(): ImVec2 { return ImRect_GetBR_cj(this.toPtr()) }

    /**
     * @brief[zh-cn] 矩形是否反转（min > max）
     *
     * @brief[en] Whether the rectangle is inverted (min > max)
     */
    public func isInverted(): Bool {
        return ImRect_IsInverted_cj(this.toPtr()) != 0
    }

    // ===== 包含测试 =====
    // ===== Containment Tests =====

    /**
     * @brief[zh-cn] 点是否在矩形内
     *
     * @brief[en] Whether a point is inside the rectangle
     */
    public func contains(x: Float32, y: Float32): Bool {
        return ImRect_Contains_Vec2_cj(this.toPtr(), ImVec2(x, y)) != 0
    }

    /**
     * @brief[zh-cn] 另一个矩形是否完全在本矩形内
     *
     * @brief[en] Whether another rectangle is fully contained
     */
    public func containsRect(other: UiRect): Bool {
        return ImRect_Contains_Rect_cj(this.toPtr(), other.toPtr()) != 0
    }

    /**
     * @brief[zh-cn] 两个矩形是否重叠
     *
     * @brief[en] Whether two rectangles overlap
     */
    public func overlaps(other: UiRect): Bool {
        return ImRect_Overlaps_cj(this.toPtr(), other.toPtr()) != 0
    }

    // ===== 变换 =====
    // ===== Transforms =====

    /**
     * @brief[zh-cn] 扩展矩形（各方向扩大指定量）
     *
     * @brief[en] Expands the rectangle by the given amount in all directions
     */
    public func expand(amount: Float32): UiRect {
        let r = UiRect(this._min.x - amount, this._min.y - amount, this._max.x + amount, this._max.y + amount)
        return r
    }

    /**
     * @brief[zh-cn] 扩展矩形（分别指定 X/Y 扩展量）
     *
     * @brief[en] Expands the rectangle with separate X/Y amounts
     */
    public func expandVec(dx: Float32, dy: Float32): UiRect {
        return UiRect(this._min.x - dx, this._min.y - dy, this._max.x + dx, this._max.y + dy)
    }

    /**
     * @brief[zh-cn] 平移矩形
     *
     * @brief[en] Translates the rectangle
     */
    public func translate(dx: Float32, dy: Float32): UiRect {
        return UiRect(this._min.x + dx, this._min.y + dy, this._max.x + dx, this._max.y + dy)
    }

    /**
     * @brief[zh-cn] 添加点（扩展矩形以包含该点）
     *
     * @brief[en] Adds a point (expands rectangle to contain it)
     */
    public func addPoint(x: Float32, y: Float32): UiRect {
        return UiRect(
            if (x < this._min.x) { x } else { this._min.x },
            if (y < this._min.y) { y } else { this._min.y },
            if (x > this._max.x) { x } else { this._max.x },
            if (y > this._max.y) { y } else { this._max.y }
        )
    }

    /**
     * @brief[zh-cn] 裁剪（与另一个矩形求交）
     *
     * @brief[en] Clips (intersects with another rectangle)
     */
    public func clipWith(other: UiRect): UiRect {
        return UiRect(
            if (this._min.x > other._min.x) { this._min.x } else { other._min.x },
            if (this._min.y > other._min.y) { this._min.y } else { other._min.y },
            if (this._max.x < other._max.x) { this._max.x } else { other._max.x },
            if (this._max.y < other._max.y) { this._max.y } else { other._max.y }
        )
    }

    /**
     * @brief[zh-cn] 转换为 ImVec4（x=minX, y=minY, z=maxX, w=maxY）
     *
     * @brief[en] Converts to ImVec4 (x=minX, y=minY, z=maxX, w=maxY)
     */
    public func toVec4(): ImVec4 {
        return ImVec4(this._min.x, this._min.y, this._max.x, this._max.y)
    }

    // ===== 内部辅助 =====
    // ===== Internal Helpers =====

    private func toPtr(): CPointer<Unit> {
        return unsafe {
            let p = LibC.malloc<Int8>(count: Int64(16))
            CPointer<Float32>(p).write(this._min.x)
            (CPointer<Float32>(p) + 1).write(this._min.y)
            (CPointer<Float32>(p) + 2).write(this._max.x)
            (CPointer<Float32>(p) + 3).write(this._max.y)
            let r = ImRect_ImRect_Vec2_cj(this._min, this._max)
            LibC.free(p)
            r
        }
    }

    private func toImRect(): ImVec4 {
        return this.toVec4()
    }
}
