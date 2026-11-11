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
 * @file[zh-cn] UiCursor.cj — 光标定位 / 内容区 / ID 栈 / 行高度量
 * @brief[zh-cn] 自绘控件的精确定位与多实例消歧能力
 * @explain[zh-cn] 补齐任意自绘控件所需的布局与命名空间原语（与 UiDrawList、
 *         UiInvisibleButton、UiItemQuery 组合成完整闭环）。用法示例：
 *   // 自绘控件：光标定位 + DrawList 绘制
 *   let p = UiCursor.getCursorScreenPos()
 *   UiCursor.setCursorScreenPos(Vector2(p.x + 10.0, p.y))
 *   let avail = UiCursor.getContentRegionAvail()   // 自适应尺寸
 *   // 多个同类自绘控件消歧（ID 栈）
 *   UiCursor.pushId("row0"); UiInvisibleButton("btn", ...).draw(); UiCursor.popId()
 *   // 或作用域形式（自动 Pop）
 *   UiIdScope("row1", { => UiInvisibleButton("btn", ...).draw() })
 *   // 与默认控件对齐的自绘高度
 *   let h = UiCursor.getFrameHeight()              // 帧高度（按钮/输入框标准高度）
 *
 * @file[en] UiCursor.cj — Cursor Positioning / Content Region / ID Stack / Metrics
 * @brief[en] Precise layout and namespace primitives for fully custom widgets
 * @explain[en] Completes the layout/naming primitives needed for arbitrary custom widgets
 *         (combined with UiDrawList, UiInvisibleButton and UiItemQuery for a full
 *         toolkit). See the zh-cn block for usage examples.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*

// =============================================================================
// UiCursor — 光标定位 / 内容区 / ID 栈 / 行高度量
// Cursor Positioning / Content Region / ID Stack / Line Metrics
// =============================================================================

/**
 * @brief[zh-cn] 光标定位、内容区查询、ID 栈与行高度量（全静态）
 * @explain[zh-cn] ImGui 布局是"光标推进"模型：控件按光标位置放置并推进光标。
 *         自绘控件通过读写光标实现精确定位；通过 ID 栈避免多实例 ID 冲突；
 *         通过行高/帧高度量与默认控件对齐。所有 API 须在 Begin/End（UiWindow.draw）
 *         之间调用。
 *
 * @brief[en] Cursor positioning, content region queries, ID stack and line metrics (all static)
 * @explain[en] ImGui layout uses a "cursor advancement" model: widgets are placed at the
 *         cursor and advance it. Custom widgets position precisely by reading/writing the
 *         cursor, disambiguate multiple instances via the ID stack, and align with default
 *         widgets via line/frame metrics. All APIs must be called between Begin/End
 *         (UiWindow.draw).
 */
public class UiCursor {
    // ===== 屏幕坐标光标 =====
    // ===== Screen-Space Cursor =====

    /**
     * @brief[zh-cn] 获取下个控件将放置的屏幕坐标（窗口内容区左上 + 光标偏移）
     * @return[zh-cn] 屏幕坐标（逻辑像素）
     *
     * @brief[en] Gets the screen position where the next widget will be placed
     *            (window content origin + cursor offset)
     * @return[en] Screen position (logical pixels)
     */
    public static func getCursorScreenPos(): Vector2 {
        let v = igGetCursorScreenPos_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 设置下个控件的屏幕坐标（自由布局/overlay 绘制的落点）
     * @param[zh-cn] pos 屏幕坐标（逻辑像素）
     *
     * @brief[en] Sets the screen position of the next widget (landing point for
     *            free layout / overlay drawing)
     * @param[en] pos Screen position (logical pixels)
     */
    public static func setCursorScreenPos(pos: Vector2): Unit {
        igSetCursorScreenPos_cj(ImVec2(Float32(pos.x), Float32(pos.y)))
    }

    // ===== 窗口相对光标 =====
    // ===== Window-Relative Cursor =====

    /**
     * @brief[zh-cn] 获取窗口内容区内的光标位置（窗口相对坐标）
     * @return[zh-cn] 窗口相对坐标（逻辑像素）
     *
     * @brief[en] Gets the cursor position within the window content region (window-relative)
     * @return[en] Window-relative position (logical pixels)
     */
    public static func getCursorPos(): Vector2 {
        let v = igGetCursorPos_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 设置窗口内容区内的光标位置（窗口相对坐标）
     * @param[zh-cn] pos 窗口相对坐标（逻辑像素）
     *
     * @brief[en] Sets the cursor position within the window content region (window-relative)
     * @param[en] pos Window-relative position (logical pixels)
     */
    public static func setCursorPos(pos: Vector2): Unit {
        igSetCursorPos_cj(ImVec2(Float32(pos.x), Float32(pos.y)))
    }

    // ===== 内容区 =====
    // ===== Content Region =====

    /**
     * @brief[zh-cn] 获取当前内容区剩余可用空间（从光标处到内容区右下角）
     * @return[zh-cn] 可用尺寸（逻辑像素；自适应尺寸控件的依据）
     *
     * @brief[en] Gets the remaining available space in the content region
     *            (from the cursor to the region's bottom-right)
     * @return[en] Available size (logical pixels; the basis for auto-fit custom widgets)
     */
    public static func getContentRegionAvail(): Vector2 {
        let v = igGetContentRegionAvail_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    // ===== ID 栈 =====
    // ===== ID Stack =====

    /**
     * @brief[zh-cn] 压入字符串 ID 命名空间（与 popId 配对）
     * @explain[zh-cn] 多个同类自绘控件（label 相同或为空）在同一层出现时，
     *             ImGui 会因 ID 冲突产生点击串扰；压入不同的父 ID 可消歧。
     *
     * @brief[en] Pushes a string ID namespace (paired with popId)
     * @explain[en] When multiple same-type custom widgets (same or empty labels) appear at
     *             the same level, ImGui ID collisions cause click cross-talk; pushing
     *             distinct parent IDs disambiguates them.
     * @param[zh-cn] id 命名空间标识
     *
     * @brief[en] id Namespace identifier
     */
    public static func pushId(id: String): Unit {
        let cs = unsafe { LibC.mallocCString(id) }
        igPushID_Str_cj(cs)
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 压入整数 ID 命名空间（与 popId 配对；循环内多用索引）
     * @param[zh-cn] id 整数标识（如循环索引）
     *
     * @brief[en] Pushes an integer ID namespace (paired with popId; loop indices are common)
     * @param[en] id Integer identifier (e.g. loop index)
     */
    public static func pushIdInt(id: Int32): Unit {
        igPushID_Int_cj(id)
    }

    /**
     * @brief[zh-cn] 弹出 ID 命名空间（与 pushId/pushIdInt 配对）
     *
     * @brief[en] Pops the ID namespace (paired with pushId/pushIdInt)
     */
    public static func popId(): Unit {
        igPopID_cj()
    }

    // ===== 行高 / 帧高度量 =====
    // ===== Line / Frame Metrics =====

    /**
     * @brief[zh-cn] 文本行高（FontSize + 少量余量）
     * @return[zh-cn] 行高（逻辑像素）
     *
     * @brief[en] Text line height (FontSize + small padding)
     * @return[en] Line height (logical pixels)
     */
    public static func getTextLineHeight(): Float32 {
        return igGetTextLineHeight_cj()
    }

    /**
     * @brief[zh-cn] 文本行高 + 垂直间距（ItemSpacing.y）
     * @return[zh-cn] 含间距的行高（逻辑像素）
     *
     * @brief[en] Text line height + vertical spacing (ItemSpacing.y)
     * @return[en] Line height including spacing (logical pixels)
     */
    public static func getTextLineHeightWithSpacing(): Float32 {
        return igGetTextLineHeightWithSpacing_cj()
    }

    /**
     * @brief[zh-cn] 标准控件帧高度（按钮/输入框等的默认高度）
     * @return[zh-cn] 帧高度（逻辑像素；自绘控件与之对齐可保持视觉一致）
     *
     * @brief[en] Standard widget frame height (default height of buttons/inputs etc.)
     * @return[en] Frame height (logical pixels; aligning custom widgets keeps visual consistency)
     */
    public static func getFrameHeight(): Float32 {
        return igGetFrameHeight_cj()
    }

    /**
     * @brief[zh-cn] 标准控件帧高度 + 垂直间距
     * @return[zh-cn] 含间距的帧高度（逻辑像素）
     *
     * @brief[en] Standard frame height + vertical spacing
     * @return[en] Frame height including spacing (logical pixels)
     */
    public static func getFrameHeightWithSpacing(): Float32 {
        return igGetFrameHeightWithSpacing_cj()
    }
}

// =============================================================================
// UiIdScope — ID 命名空间作用域
// ID Namespace Scope
// =============================================================================

/**
 * @brief[zh-cn] ID 命名空间作用域控件
 * @explain[zh-cn] pushId/popId 的作用域封装：闭包内所有控件共享父 ID，异常安全
 *         （闭包返回后必定 popId）。适合包裹"一行/一格"内的若干自绘控件。
 *
 * @brief[en] ID namespace scope widget
 * @explain[en] Scoped wrapper over pushId/popId: all widgets inside the closure share the
 *         parent ID, with exception safety (popId always runs after the closure returns).
 *         Ideal for wrapping several custom widgets within a "row/cell".
 */
public class UiIdScope <: UiWidget {
    private var _id: String
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造 ID 作用域
     * @param[zh-cn] id 命名空间标识
     * @param[zh-cn] content 作用域内控件渲染回调
     *
     * @brief[en] Constructs an ID scope
     * @param[en] id Namespace identifier
     * @param[en] content Render callback for widgets inside the scope
     */
    public init(id!: String, content!: () -> Unit) {
        super()
        this._id = id
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染 ID 作用域内的控件（PushID/PopID 包裹内容）
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders widgets inside the ID scope (content wrapped in PushID/PopID)
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        UiCursor.pushId(this._id)
        this._content()
        UiCursor.popId()
        return false
    }
}
