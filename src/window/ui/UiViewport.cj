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
 * @file[zh-cn] UiViewport.cj — ImGui 视口查询
 * @brief[zh-cn] 封装 ImGuiViewport，提供视口位置/尺寸/工作区查询
 * @explain[zh-cn] 用法示例：
 *   let vp = UiViewport.getMain()
 *   let (cx, cy) = vp.getCenter()
 *   let (w, h) = vp.getSize()
 *
 * @file[en] UiViewport.cj — ImGui Viewport Query
 * @brief[en] Wraps ImGuiViewport for viewport position/size/work-area queries
 * @explain[en] Usage example:
 *   let vp = UiViewport.getMain()
 *   let (cx, cy) = vp.getCenter()
 *   let (w, h) = vp.getSize()
 * @explain[en] Usage example:
 *   let vp = UiViewport.getMain()
 *   let (cx, cy) = vp.getCenter()
 *   let (w, h) = vp.getSize()
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// =============================================================================
// UiViewport — 视口查询
// Viewport Query
// =============================================================================

/**
 * @brief[zh-cn] ImGui 视口查询
 * @explain[zh-cn] 封装 ImGuiViewport 的只读查询方法。
 *         视口 = 显示区域（单窗口应用只有一个主视口）。
 *
 * @brief[en] ImGui viewport query
 * @explain[en] Wraps ImGuiViewport read-only query methods.
 *         Viewport = display area (single-window apps have only one main viewport).
 */
public class UiViewport {
    private var _vp: CPointer<Unit>

    public init(vpPtr: CPointer<Unit>) { this._vp = vpPtr }

    /**
     * @brief[zh-cn] 获取主视口（通常是整个窗口）
     *
     * @brief[en] Gets the main viewport (usually the entire window)
     */
    public static func getMain(): UiViewport {
        return UiViewport(igGetMainViewport_cj())
    }

    /**
     * @brief[zh-cn] 获取当前窗口所在的视口
     *
     * @brief[en] Gets the viewport containing the current window
     */
    public static func getWindowViewport(): UiViewport {
        return UiViewport(igGetWindowViewport_cj())
    }

    /**
     * @brief[zh-cn] 获取底层 ImGuiViewport 指针
     *
     * @brief[en] Gets the underlying ImGuiViewport pointer
     */
    public func getHandle(): CPointer<Unit> { return this._vp }

    // ImGuiViewport 字段偏移（x64）:
    // ImGuiViewport field offsets (x64):
    // ID(4) + Flags(4) + Pos(8) + Size(8) + WorkPos(8) + WorkSize(8) + DpiScale(4) + ...

    /**
     * @brief[zh-cn] 视口位置（屏幕坐标）
     *
     * @brief[en] Viewport position (screen coordinates)
     */
    public func getPos(): (Float32, Float32) {
        if (this._vp.isNull()) { return (0.0f32, 0.0f32) }
        let x = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 8).read() }
        let y = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 12).read() }
        return (x, y)
    }

    /**
     * @brief[zh-cn] 视口尺寸
     *
     * @brief[en] Viewport size
     */
    public func getSize(): (Float32, Float32) {
        if (this._vp.isNull()) { return (0.0f32, 0.0f32) }
        let w = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 16).read() }
        let h = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 20).read() }
        return (w, h)
    }

    /**
     * @brief[zh-cn] 工作区位置（排除系统栏等）
     *
     * @brief[en] Work area position (excludes system bars etc.)
     */
    public func getWorkPos(): (Float32, Float32) {
        if (this._vp.isNull()) { return (0.0f32, 0.0f32) }
        let x = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 24).read() }
        let y = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 28).read() }
        return (x, y)
    }

    /**
     * @brief[zh-cn] 工作区尺寸
     *
     * @brief[en] Work area size
     */
    public func getWorkSize(): (Float32, Float32) {
        if (this._vp.isNull()) { return (0.0f32, 0.0f32) }
        let w = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 32).read() }
        let h = unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 36).read() }
        return (w, h)
    }

    /**
     * @brief[zh-cn] DPI 缩放因子
     *
     * @brief[en] DPI scale factor
     */
    public func getDpiScale(): Float32 {
        if (this._vp.isNull()) { return 1.0f32 }
        return unsafe { CPointer<Float32>(CPointer<UInt8>(this._vp) + 40).read() }
    }

    /**
     * @brief[zh-cn] 视口中心点
     *
     * @brief[en] Viewport center point
     */
    public func getCenter(): ImVec2 {
        if (this._vp.isNull()) { return ImVec2(0.0, 0.0) }
        return ImGuiViewport_GetCenter_cj(this._vp)
    }

    /**
     * @brief[zh-cn] 工作区中心点
     *
     * @brief[en] Work area center point
     */
    public func getWorkCenter(): ImVec2 {
        if (this._vp.isNull()) { return ImVec2(0.0, 0.0) }
        return ImGuiViewport_GetWorkCenter_cj(this._vp)
    }
}
