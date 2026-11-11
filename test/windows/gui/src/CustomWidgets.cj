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
 * @file 自绘交互控件示例 v2（事件完全隔离版）
 * @brief UiDummy 布局占位 + UiMouse 矩形命中 + 按键查询——不依赖 ImGui item 状态
 * @explain v1 用 UiInvisibleButton 占位并依赖 ImGui 的"最后 item"状态
 *   （UiItemQuery.isItemHovered/isItemActive/getItemRectMin）做交互。
 *   该状态是窗口级全局的：若按钮被裁剪跳过或 ID 冲突，控件会读到别的控件的状态，
 *   造成"点一个、全部激活"的事件串扰。
 *   v2 改为完全自管命中：先用 UiCursor.getCursorScreenPos() 计算矩形，再用
 *   UiMouse.isMouseHoveringRect/isMouseClicked/isMouseDown 逐控件独立判定——
 *   不读任何 ImGui item 状态，事件彻底隔离，且不依赖 ID 唯一性。
 *   颜色均为 IM_COL32（0xAABBGGRR，最高字节 alpha）。
 */

package test_gui

import std.core.*
import std.math.*
import three.core.math.*
import three.window.ui.*

// =============================================================================
// 命中测试辅助（无状态、逐控件独立）
// =============================================================================

/**
 * @brief 鼠标是否悬停在矩形上（屏幕坐标，逻辑像素）
 */
func isMouseOver(pMin: Vector2, pMax: Vector2): Bool {
    return UiMouse.isMouseHoveringRect(Float32(pMin.x), Float32(pMin.y),
                                       Float32(pMax.x), Float32(pMax.y))
}

/// 帧内递增的占位 ID 序号（同帧内控件绘制顺序确定 → ID 稳定）
var gHitCounter: Int64 = 0

/**
 * @brief 帧首重置占位 ID 计数器（在 ui 体绘制控件之前调用一次）
 */
func resetHitCounter(): Unit {
    gHitCounter = 0
}

/**
 * @brief 控件矩形辅助：从当前光标取矩形并以"可交互 item"占位
 * @explain 必须在占位之前取 getCursorScreenPos（占位后光标已前移）。
 *         占位用 UiInvisibleButton 而非 UiDummy：ImGui 中非交互区域按住拖动
 *         会移动窗口（v2 出现的"拖控件变拖窗口"根因），交互 item 会消费输入，
 *         拦截窗口拖动；本方案的命中/点击/拖拽逻辑全部由 UiMouse 独立判定，
 *         不读取任何 ImGui item 状态，事件隔离不受 ID 冲突影响。
 *         ID 按"帧内序号"生成：只要每帧绘制顺序稳定，ID 即稳定。
 */
func takeRect(w: Float32, h: Float32): (Vector2, Vector2) {
    let pMin = UiCursor.getCursorScreenPos()
    let pMax = Vector2(pMin.x + Float64(w), pMin.y + Float64(h))
    gHitCounter++
    UiInvisibleButton(id: "##cw${gHitCounter}", w: w, h: h).draw()
    return (pMin, pMax)
}

// =============================================================================
// UiRoundedButton — 圆角半透明按钮
// =============================================================================

/**
 * @brief 圆角半透明按钮——hover/按下三态变色，事件独立判定
 */
public class UiRoundedButton <: UiWidget {
    private let _label: String
    private let _w: Float32
    private let _h: Float32
    private let _rounding: Float32
    private var _onClick: Option<() -> Unit> = None

    /// IM_COL32（0xAABBGGRR）：常态 45% 半透明蓝 / hover 65% / 按下 85%
    private static let COL_NORMAL: UInt32 = 0x73B46628
    private static let COL_HOVER: UInt32 = 0xA6B46628
    private static let COL_ACTIVE: UInt32 = 0xD9B46628

    public init(label!: String, w!: Float32, h!: Float32, rounding!: Float32 = 8.0) {
        super()
        this._label = label
        this._w = w
        this._h = h
        this._rounding = rounding
    }

    public func onClick(callback: () -> Unit): UiRoundedButton {
        this._onClick = Some(callback)
        return this
    }

    public override func draw(): Bool {
        // ① 取矩形并占位推进光标（先取坐标再占位，顺序不可反）
        let (pMin, pMax) = takeRect(this._w, this._h)
        // ② 事件独立判定：矩形命中 + 按键查询，不读 ImGui item 状态
        let hovered = isMouseOver(pMin, pMax)
        let pressed = hovered && UiMouse.isMouseDown(0)
        let clicked = hovered && UiMouse.isMouseClicked(0)
        // ③ DrawList 自绘外观
        let fill: UInt32 = if (pressed) { UiRoundedButton.COL_ACTIVE }
                           else if (hovered) { UiRoundedButton.COL_HOVER }
                           else { UiRoundedButton.COL_NORMAL }
        let dl = UiDrawList.window()
        dl.addRectFilled(pMin, pMax, fill, rounding: this._rounding)
        dl.addRect(pMin, pMax, 0xFFFFFFFF, rounding: this._rounding, thickness: 1.0)
        let (tw, th) = UiStyle.calcTextSize(this._label)
        dl.addText(Vector2((pMin.x + pMax.x - Float64(tw)) * 0.5, (pMin.y + pMax.y - Float64(th)) * 0.5),
                   0xFFFFFFFF, this._label)
        if (clicked) {
            if (let Some(f) <- this._onClick) { f() }
        }
        return clicked
    }
}

// =============================================================================
// UiToggleSwitch — 拟物开关
// =============================================================================

/**
 * @brief 拟物开关——胶囊轨道 + 圆形滑钮，点击切换 Bool 状态
 */
public class UiToggleSwitch <: UiWidget {
    private let _w: Float32
    private let _h: Float32
    private var _on: Bool
    private var _onChange: Option<(Bool) -> Unit> = None

    /// 轨道：关=40% 灰 / 开=85% 绿；滑钮：白色
    private static let COL_TRACK_OFF: UInt32 = 0x66666666
    private static let COL_TRACK_ON: UInt32 = 0xD966D94A
    private static let COL_KNOB: UInt32 = 0xFFF0F0F0

    public init(on!: Bool = false, w!: Float32 = 54.0, h!: Float32 = 28.0) {
        super()
        this._w = w
        this._h = h
        this._on = on
    }

    public func isOn(): Bool { return this._on }
    public func setOn(on: Bool): Unit { this._on = on }

    public func onChange(callback: (Bool) -> Unit): UiToggleSwitch {
        this._onChange = Some(callback)
        return this
    }

    public override func draw(): Bool {
        let (pMin, pMax) = takeRect(this._w, this._h)
        let hovered = isMouseOver(pMin, pMax)
        let clicked = hovered && UiMouse.isMouseClicked(0)
        if (clicked) {
            this._on = !this._on
            if (let Some(f) <- this._onChange) { f(this._on) }
        }
        let dl = UiDrawList.window()
        // 胶囊轨道（圆角=高度一半），hover 提亮一档 alpha
        var track = if (this._on) { UiToggleSwitch.COL_TRACK_ON } else { UiToggleSwitch.COL_TRACK_OFF }
        if (hovered) { track = (track >> 24) + 0x19000000 + (track & 0x00FFFFFF) }
        dl.addRectFilled(pMin, pMax, track, rounding: this._h * 0.5)
        // 滑钮：开→右侧，关→左侧
        let r = Float64(this._h) * 0.5 - 3.0
        let knobX = if (this._on) { pMax.x - r - 3.0 } else { pMin.x + r + 3.0 }
        let cy = (pMin.y + pMax.y) * 0.5
        dl.addCircleFilled(Vector2(knobX, cy), Float32(r), UiToggleSwitch.COL_KNOB)
        return clicked
    }
}

// =============================================================================
// UiRingProgress — 环形进度
// =============================================================================

/**
 * @brief 环形进度——圆弧描边 + 居中百分比文本（无交互，每帧重绘）
 */
public class UiRingProgress <: UiWidget {
    private let _radius: Float32
    private var _fraction: Float32
    private let _col: UInt32

    public init(fraction!: Float32 = 0.0, radius!: Float32 = 32.0,
                col!: UInt32 = 0xE6B46628) {
        super()
        this._fraction = fraction
        this._radius = radius
        this._col = col
    }

    public func setFraction(f: Float32): Unit {
        this._fraction = if (f < 0.0) { 0.0 } else if (f > 1.0) { 1.0 } else { f }
    }
    public func getFraction(): Float32 { return this._fraction }

    public override func draw(): Bool {
        let d = this._radius * 2.0
        let (pMin, _) = takeRect(d, d)
        let dl = UiDrawList.window()
        let c = Vector2(pMin.x + Float64(this._radius), pMin.y + Float64(this._radius))
        // 背景整环（淡）
        dl.addCircle(c, this._radius, 0x40FFFFFF, thickness: 4.0)
        // 进度弧：从正上方顺时针
        if (this._fraction > 0.0) {
            let a0: Float32 = -1.5707964        // -PI/2
            let a1: Float32 = a0 + 6.2831855 * this._fraction
            dl.pathClear()
            dl.pathArcTo(c, this._radius, a0, a1)
            dl.pathStroke(this._col, thickness: 4.0)
        }
        // 居中百分比
        let text = "${Int32(this._fraction * 100.0)}%"
        let (tw, th) = UiStyle.calcTextSize(text)
        dl.addText(Vector2(c.x - Float64(tw) * 0.5, c.y - Float64(th) * 0.5), 0xFFFFFFFF, text)
        return false
    }
}

// =============================================================================
// UiFancySlider — 自绘滑条
// =============================================================================

/**
 * @brief 自绘滑条——圆角轨道 + 填充条 + 滑钮，支持拖动取值
 * @explain 拖动逻辑：矩形命中期间按住左键即视为拖拽中，把鼠标屏幕 X 映射到值域并夹取；
 *         无需跨帧拖拽状态（实例每帧重建也能工作）。
 */
public class UiFancySlider <: UiWidget {
    private let _w: Float32
    private let _h: Float32
    private let _min: Float32
    private let _max: Float32
    private var _value: Float32
    private var _onChange: Option<(Float32) -> Unit> = None

    /// 轨道 45% 灰 / 填充 90% 蓝 / 滑钮白色
    private static let COL_TRACK: UInt32 = 0x735A5A5A
    private static let COL_FILL: UInt32 = 0xE6B46628
    private static let COL_KNOB: UInt32 = 0xFFF0F0F0

    public init(value!: Float32, w!: Float32 = 200.0, h!: Float32 = 22.0,
                min!: Float32 = 0.0, max!: Float32 = 1.0) {
        super()
        this._w = w
        this._h = h
        this._min = min
        this._max = max
        this._value = if (value < min) { min } else if (value > max) { value } else { value }
    }

    public func getValue(): Float32 { return this._value }
    public func setValue(v: Float32): Unit {
        this._value = if (v < this._min) { this._min } else if (v > this._max) { this._max } else { v }
    }

    public func onChange(callback: (Float32) -> Unit): UiFancySlider {
        this._onChange = Some(callback)
        return this
    }

    public override func draw(): Bool {
        let (pMin, pMax) = takeRect(this._w, this._h)
        let hovered = isMouseOver(pMin, pMax)
        // 拖拽中 = 命中 + 左键按住（无状态判定）
        let dragging = hovered && UiMouse.isMouseDown(0)
        if (dragging) {
            let mouse = UiMouse.getMousePos()
            let t = (mouse.x - pMin.x) / Float64(this._w)
            let tt = if (t < 0.0) { 0.0 } else if (t > 1.0) { 1.0 } else { t }
            let nv = this._min + (this._max - this._min) * Float32(tt)
            if (nv != this._value) {
                this._value = nv
                if (let Some(f) <- this._onChange) { f(nv) }
            }
        }
        let dl = UiDrawList.window()
        // 轨道
        dl.addRectFilled(pMin, pMax, UiFancySlider.COL_TRACK, rounding: this._h * 0.5)
        // 填充条（宽度按值比例）
        let t = (this._value - this._min) / (this._max - this._min)
        if (t > 0.0) {
            let fillMax = Vector2(pMin.x + Float64(this._w * t), pMax.y)
            dl.addRectFilled(pMin, fillMax, UiFancySlider.COL_FILL, rounding: this._h * 0.5)
        }
        // 滑钮（拖拽时放大一档）
        let knobR = if (dragging) { this._h * 0.62 } else { this._h * 0.5 }
        let knobX = pMin.x + Float64(this._w * t)
        let cy = (pMin.y + pMax.y) * 0.5
        dl.addCircleFilled(Vector2(knobX, cy), knobR, UiFancySlider.COL_KNOB)
        return dragging
    }
}
