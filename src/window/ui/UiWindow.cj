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
 * @file[zh-cn] UiWindow.cj — ImGui 窗口组件
 * @brief[zh-cn] 封装 ImGui Begin/End 语义的窗口控件
 * @explain[zh-cn] 支持标题、打开状态、标志位，可手动调用 begin()/end()，也可通过 draw() 闭包自动管理生命周期。用法示例：
 *   let w = UiWindow("My Window")
 *   w.begin()
 *   // ... 添加子控件 ...
 *   w.end()
 *
 *   // 或通过 draw() 闭包自动管理：
 *   UiWindow("Demo").draw({ =>
 *       UiText("Hello")
 *       UiButton("Click").onClick({ => @LogInfo(["UiWindow", "clicked"]) })
 *   })
 *
 * @file[en] UiWindow.cj — ImGui Window Component
 * @brief[en] Window widget wrapping ImGui Begin/End semantics
 * @explain[en] Supports title, open state, and flags; can call begin()/end() manually or use draw() closure for automatic lifecycle management.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.utils.memory.PtrArray

/**
 * @brief[zh-cn] ImGui 窗口组件
 * @explain[zh-cn] 封装 ImGui Begin/End，支持标题、打开状态、标志位。可作为容器添加子控件，也可用 draw() 闭包自动管理生命周期。
 *
 * @brief[en] ImGui window widget
 * @explain[en] Wraps ImGui Begin/End and supports title, open state, and flags. Can be used as a container for child widgets or via draw() closure.
 */
public class UiWindow {
    /// 窗口标题
    private var _title: String
    /// 窗口标志（ImGuiWindowFlags）
    private var _flags: Int32
    /// 是否打开（用于带关闭按钮的窗口）
    private var _open: Option<PtrArray<Int32>> = None
    /// 打开状态值（栈上分配）
    private var _openValue: Int32 = 1

    /**
     * @brief[zh-cn] 构造普通窗口
     * @param[zh-cn] title 窗口标题
     * @param[zh-cn] flags 窗口标志（默认 0）
     *
     * @brief[en] Constructs a normal window
     * @param[en] title Window title
     * @param[en] flags Window flags (default 0)
     */
    public init(title!: String, flags!: Int32 = 0) {
        this._title = title
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 构造带关闭按钮的窗口
     * @param[zh-cn] title 窗口标题
     * @param[zh-cn] open 打开状态指针
     * @param[zh-cn] flags 窗口标志
     *
     * @brief[en] Constructs a window with a close button
     * @param[en] title Window title
     * @param[en] open Pointer to open state
     * @param[en] flags Window flags
     */
    public init(title!: String, open!: PtrArray<Int32>, flags!: Int32 = 0) {
        this._title = title
        this._flags = flags
        this._open = Some(open)
    }

    /**
     * @brief[zh-cn] 开始窗口（调用 ImGui Begin）
     * @return[zh-cn] 窗口是否可见
     *
     * @brief[en] Begins the window (calls ImGui Begin)
     * @return[en] Whether the window is visible
     */
    public func begin(): Bool {
        ensureCurrentContext()
        match (this._open) {
            case Some(p) => return ImGui_Begin_cj(this._title, p.data(), this._flags)
            case None => return ImGui_Begin_cj(this._title, CPointer<Int32>(), this._flags)
        }
    }

    /**
     * @brief[zh-cn] 结束窗口（调用 ImGui End）
     *
     * @brief[en] Ends the window (calls ImGui End)
     */
    public func end(): Unit {
        ImGui_End_cj()
    }

    /**
     * @brief[zh-cn] 使用闭包自动管理 begin/end
     * @param[zh-cn] content 绘制闭包
     * @return[zh-cn] 窗口是否可见
     *
     * @brief[en] Automatically manages begin/end with a closure
     * @param[en] content Drawing closure
     * @return[en] Whether the window is visible
     */
    public func draw(content: () -> Unit): Bool {
        let visible = this.begin()
        if (visible) {
            content()
        }
        this.end()
        return visible
    }

    /**
     * @brief[zh-cn] 创建普通窗口
     * @param[zh-cn] title 窗口标题
     * @param[zh-cn] flags 窗口标志（默认 0）
     * @return[zh-cn] 窗口实例
     *
     * @brief[en] Creates a normal window
     * @param[en] title Window title
     * @param[en] flags Window flags (default 0)
     * @return[en] Window instance
     */
    public static func create(title: String, flags!: Int32 = 0): UiWindow {
        return UiWindow(title: title, flags: flags)
    }

    /**
     * @brief[zh-cn] 创建带关闭按钮的窗口
     * @param[zh-cn] title 窗口标题
     * @param[zh-cn] flags 窗口标志（默认 0）
     * @return[zh-cn] 窗口实例
     *
     * @brief[en] Creates a window with a close button
     * @param[en] title Window title
     * @param[en] flags Window flags (default 0)
     * @return[en] Window instance
     */
    public static func createWithClose(title: String, flags!: Int32 = 0): UiWindow {
        let openArr = PtrArray<Int32>(1)
        openArr.set(0, 1)
        return UiWindow(title: title, open: openArr, flags: flags)
    }

    // ===== 窗口定位（Begin 前调用） =====
    // ===== Window Positioning (call before Begin) =====

    /**
     * @brief[zh-cn] 设置下一个窗口的位置（在 begin()/draw() 前调用）
     * @param[zh-cn] x X 坐标（像素）
     * @param[zh-cn] y Y 坐标（像素）
     * @param[zh-cn] cond 条件标志（ImGuiCond，0=总是）
     * @param[zh-cn] pivotX 枢轴 X（0=左, 0.5=中, 1=右）
     * @param[zh-cn] pivotY 枢轴 Y（0=上, 0.5=中, 1=下）
     *
     * @brief[en] Sets the position of the next window (call before begin()/draw())
     * @param[en] x X coordinate in pixels
     * @param[en] y Y coordinate in pixels
     * @param[en] cond Condition flags (ImGuiCond, 0=always)
     * @param[en] pivotX Pivot X (0=left, 0.5=center, 1=right)
     * @param[en] pivotY Pivot Y (0=top, 0.5=center, 1=bottom)
     */
    public static func setNextWindowPos(x: Float32, y: Float32, cond!: Int32 = 0,
                                        pivotX!: Float32 = 0.0f32, pivotY!: Float32 = 0.0f32): Unit {
        igSetNextWindowPos_cj(ImVec2(x, y), cond, ImVec2(pivotX, pivotY))
    }

    /**
     * @brief[zh-cn] 设置下一个窗口的位置（向量形式）
     * @param[zh-cn] pos 位置（像素）
     * @param[zh-cn] cond 条件标志
     * @param[zh-cn] pivot 枢轴
     *
     * @brief[en] Sets the position of the next window (vector form)
     * @param[en] pos Position in pixels
     * @param[en] cond Condition flags
     * @param[en] pivot Pivot point
     */
    public static func setNextWindowPosVec(pos: ImVec2, cond!: Int32 = 0, pivot!: ImVec2 = ImVec2(0.0, 0.0)): Unit {
        igSetNextWindowPos_cj(pos, cond, pivot)
    }

    /**
     * @brief[zh-cn] 设置下一个窗口的尺寸（在 begin()/draw() 前调用）
     * @param[zh-cn] w 宽度（像素，0=自动适配）
     * @param[zh-cn] h 高度（像素，0=自动适配）
     * @param[zh-cn] cond 条件标志
     *
     * @brief[en] Sets the size of the next window (call before begin()/draw())
     * @param[en] w Width in pixels (0=auto-fit)
     * @param[en] h Height in pixels (0=auto-fit)
     * @param[en] cond Condition flags
     */
    public static func setNextWindowSize(w: Float32, h: Float32, cond!: Int32 = 0): Unit {
        igSetNextWindowSize_cj(ImVec2(w, h), cond)
    }

    /**
     * @brief[zh-cn] 设置下一个窗口的折叠状态
     * @param[zh-cn] collapsed 是否折叠
     * @param[zh-cn] cond 条件标志
     *
     * @brief[en] Sets the collapsed state of the next window
     * @param[en] collapsed Whether collapsed
     * @param[en] cond Condition flags
     */
    public static func setNextWindowCollapsed(collapsed: Bool, cond!: Int32 = 0): Unit {
        igSetNextWindowCollapsed_cj(if (collapsed) { 1 } else { 0 }, cond)
    }

    /**
     * @brief[zh-cn] 设置下一个窗口获得焦点
     *
     * @brief[en] Sets the next window to gain focus
     */
    public static func setNextWindowFocus(): Unit {
        igSetNextWindowFocus_cj()
    }

    /**
     * @brief[zh-cn] 设置下一个窗口的背景透明度
     * @param[zh-cn] alpha 透明度（0.0~1.0）
     *
     * @brief[en] Sets the background alpha of the next window
     * @param[en] alpha Transparency (0.0~1.0)
     */
    public static func setNextWindowBgAlpha(alpha: Float32): Unit {
        igSetNextWindowBgAlpha_cj(alpha)
    }

    /**
     * @brief[zh-cn] 设置下一个窗口的尺寸约束
     * @param[zh-cn] minW 最小宽度
     * @param[zh-cn] minH 最小高度
     * @param[zh-cn] maxW 最大宽度（FLT_MAX=不限）
     * @param[zh-cn] maxH 最大高度（FLT_MAX=不限）
     *
     * @brief[en] Sets the size constraints of the next window
     * @param[en] minW Minimum width
     * @param[en] minH Minimum height
     * @param[en] maxW Maximum width (FLT_MAX=unlimited)
     * @param[en] maxH Maximum height (FLT_MAX=unlimited)
     */
    public static func setNextWindowSizeConstraints(minW: Float32, minH: Float32, maxW: Float32, maxH: Float32): Unit {
        igSetNextWindowSizeConstraints_cj(ImVec2(minW, minH), ImVec2(maxW, maxH), CPointer<Unit>(), CPointer<Unit>())
    }

    // ===== 窗口状态查询 =====
    // ===== Window State Queries =====

    /**
     * @brief[zh-cn] 当前窗口是否正在出现（动画过渡）
     *
     * @brief[en] Whether the current window is appearing (animation transition)
     */
    public static func isWindowAppearing(): Bool { return igIsWindowAppearing_cj() != 0 }
    /**
     * @brief[zh-cn] 当前窗口是否折叠
     *
     * @brief[en] Whether the current window is collapsed
     */
    public static func isWindowCollapsed(): Bool { return igIsWindowCollapsed_cj() != 0 }
    /**
     * @brief[zh-cn] 当前窗口是否获得焦点
     * @param[zh-cn] flags ImGuiFocusedFlags（默认 0）
     *
     * @brief[en] Whether the current window is focused
     * @param[en] flags ImGuiFocusedFlags (default 0)
     */
    public static func isWindowFocused(flags!: Int32 = 0): Bool { return igIsWindowFocused_cj(flags) != 0 }
    /**
     * @brief[zh-cn] 当前窗口是否被悬停
     * @param[zh-cn] flags ImGuiHoveredFlags（默认 0）
     *
     * @brief[en] Whether the current window is hovered
     * @param[en] flags ImGuiHoveredFlags (default 0)
     */
    public static func isWindowHovered(flags!: Int32 = 0): Bool { return igIsWindowHovered_cj(flags) != 0 }

    /**
     * @brief[zh-cn] 获取当前窗口位置
     *
     * @brief[en] Gets the current window position
     */
    public static func getWindowPos(): ImVec2 { return igGetWindowPos_cj() }
    /**
     * @brief[zh-cn] 获取当前窗口尺寸
     *
     * @brief[en] Gets the current window size
     */
    public static func getWindowSize(): ImVec2 { return igGetWindowSize_cj() }
    /**
     * @brief[zh-cn] 获取当前窗口宽度
     *
     * @brief[en] Gets the current window width
     */
    public static func getWindowWidth(): Float32 { return igGetWindowWidth_cj() }
    /**
     * @brief[zh-cn] 获取当前窗口高度
     *
     * @brief[en] Gets the current window height
     */
    public static func getWindowHeight(): Float32 { return igGetWindowHeight_cj() }

    // ===== 子窗口 =====
    // ===== Child Windows =====

    /**
     * @brief[zh-cn] 创建子窗口（在 begin/end 内使用）
     * @param[zh-cn] id 子窗口 ID
     * @param[zh-cn] w 宽度（0=自动）
     * @param[zh-cn] h 高度（0=自动）
     * @param[zh-cn] childFlags 子窗口标志
     * @param[zh-cn] windowFlags 窗口标志
     * @return[zh-cn] 是否可见
     *
     * @brief[en] Creates a child window (use inside begin/end)
     * @param[en] id Child window ID
     * @param[en] w Width (0=auto)
     * @param[en] h Height (0=auto)
     * @param[en] childFlags Child window flags
     * @param[en] windowFlags Window flags
     * @return[en] Whether visible
     */
    public static func beginChild(id: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32,
                                  childFlags!: Int32 = 0, windowFlags!: Int32 = 0): Bool {
        let cs = unsafe { LibC.mallocCString(id) }
        let r = igBeginChild_Str_cj(cs, ImVec2(w, h), childFlags, windowFlags)
        unsafe { LibC.free(cs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 结束子窗口
     *
     * @brief[en] Ends the child window
     */
    public static func endChild(): Unit { igEndChild_cj() }

    // ===== 滚动 =====
    // ===== Scrolling =====

    /**
     * @brief[zh-cn] 获取当前滚动 X
     *
     * @brief[en] Gets the current scroll X
     */
    public static func getScrollX(): Float32 { return igGetScrollX_cj() }
    /**
     * @brief[zh-cn] 获取当前滚动 Y
     *
     * @brief[en] Gets the current scroll Y
     */
    public static func getScrollY(): Float32 { return igGetScrollY_cj() }
    /**
     * @brief[zh-cn] 获取滚动 X 最大值
     *
     * @brief[en] Gets the maximum scroll X
     */
    public static func getScrollMaxX(): Float32 { return igGetScrollMaxX_cj() }
    /**
     * @brief[zh-cn] 获取滚动 Y 最大值
     *
     * @brief[en] Gets the maximum scroll Y
     */
    public static func getScrollMaxY(): Float32 { return igGetScrollMaxY_cj() }
    /**
     * @brief[zh-cn] 设置滚动 X
     * @param[zh-cn] scrollX 滚动 X 偏移
     *
     * @brief[en] Sets the scroll X
     * @param[en] scrollX Scroll X offset
     */
    public static func setScrollX(scrollX: Float32): Unit { igSetScrollX_Float_cj(scrollX) }
    /**
     * @brief[zh-cn] 设置滚动 Y
     * @param[zh-cn] scrollY 滚动 Y 偏移
     *
     * @brief[en] Sets the scroll Y
     * @param[en] scrollY Scroll Y offset
     */
    public static func setScrollY(scrollY: Float32): Unit { igSetScrollY_Float_cj(scrollY) }
    /**
     * @brief[zh-cn] 将当前滚动位置居中到当前光标 Y
     * @param[zh-cn] centerYRatio 光标在视口内的垂直比例（默认 0.5）
     *
     * @brief[en] Centers the scroll position at the current cursor Y
     * @param[en] centerYRatio Vertical ratio of the cursor within the viewport (default 0.5)
     */
    public static func setScrollHereY(centerYRatio!: Float32 = 0.5f32): Unit { igSetScrollHereY_cj(centerYRatio) }
    /**
     * @brief[zh-cn] 将当前滚动位置居中到当前光标 X
     * @param[zh-cn] centerXRatio 光标在视口内的水平比例（默认 0.5）
     *
     * @brief[en] Centers the scroll position at the current cursor X
     * @param[en] centerXRatio Horizontal ratio of the cursor within the viewport (default 0.5)
     */
    public static func setScrollHereX(centerXRatio!: Float32 = 0.5f32): Unit { igSetScrollHereX_cj(centerXRatio) }
}
