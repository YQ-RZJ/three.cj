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
 * @file[zh-cn] UiLayout.cj — ImGui 布局辅助控件
 * @brief[zh-cn] 提供间距、同行、分组、缩进、换行等布局控制
 * @explain[zh-cn] 包含 UiGroup、UiIndent、UiUnindent、UiNewLine、UiDummy、UiTextWrapped、UiTextColored、UiTextDisabled、UiBullet、UiDisabledBlock、UiColumns 十一个布局与辅助控件。用法示例：
 *   UiWindow("Layout Demo").draw({ =>
 *       UiText("Left"); UiSameLine(); UiText("Right")
 *       UiIndent().draw()
 *       UiText("Indented content")
 *       UiUnindent().draw()
 *       UiGroup({ => UiText("Group item 1"); UiText("Group item 2") })
 *   })
 *
 * @file[en] UiLayout.cj — ImGui Layout Helper Widgets
 * @brief[en] Layout controls: spacing, same-line, grouping, indentation, line-break etc.
 * @explain[en] Provides UiGroup, UiIndent, UiUnindent, UiNewLine, UiDummy, UiTextWrapped, UiTextColored, UiTextDisabled, UiBullet, UiDisabledBlock, UiColumns — eleven layout and helper widgets.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*

// =============================================================================
// UiGroup — 分组容器
// =============================================================================

/**
 * @brief[zh-cn] 分组容器控件
 * @explain[zh-cn] 将一组控件包装为一个整体，可一起移动/隐藏。
 *
 * @brief[en] Group container widget
 * @explain[en] Wraps a group of widgets as a single unit for collective movement/hiding.
 */
public class UiGroup <: UiWidget {
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造分组容器
     * @param[zh-cn] content 组内控件渲染回调
     *
     * @brief[en] Constructs a group container
     * @param[en] content Render callback for widgets inside the group
     */
    public init(content!: () -> Unit) {
        super()
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染分组容器（BeginGroup/EndGroup 包裹内容）
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the group (content wrapped in BeginGroup/EndGroup)
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igBeginGroup_cj()
        this._content()
        igEndGroup_cj()
        return false
    }
}

// =============================================================================
// UiIndent — 缩进
// =============================================================================

/**
 * @brief[zh-cn] 缩进控件
 *
 * @brief[en] Indent widget
 */
public class UiIndent <: UiWidget {
    private var _w: Float32

    /**
     * @brief[zh-cn] 构造缩进控件
     * @param[zh-cn] w 缩进宽度，默认 0.0（使用 ImGui 默认缩进宽度）
     *
     * @brief[en] Constructs an indent widget
     * @param[en] w Indent width, defaults to 0.0 (ImGui default indent width)
     */
    public init(w!: Float32 = 0.0) { super(); this._w = w }

    /**
     * @brief[zh-cn] 渲染缩进
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the indent
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igIndent_cj(this._w)
        return false
    }
}

// =============================================================================
// UiUnindent — 取消缩进
// =============================================================================

/**
 * @brief[zh-cn] 取消缩进控件
 *
 * @brief[en] Unindent widget
 */
public class UiUnindent <: UiWidget {
    private var _w: Float32

    /**
     * @brief[zh-cn] 构造取消缩进控件
     * @param[zh-cn] w 取消缩进宽度，默认 0.0（使用 ImGui 默认缩进宽度）
     *
     * @brief[en] Constructs an unindent widget
     * @param[en] w Unindent width, defaults to 0.0 (ImGui default indent width)
     */
    public init(w!: Float32 = 0.0) { super(); this._w = w }

    /**
     * @brief[zh-cn] 渲染取消缩进
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the unindent
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igUnindent_cj(this._w)
        return false
    }
}

// =============================================================================
// UiNewLine — 换行
// =============================================================================

/**
 * @brief[zh-cn] 换行控件
 *
 * @brief[en] New line widget
 */
public class UiNewLine <: UiWidget {
    /**
     * @brief[zh-cn] 构造换行控件
     *
     * @brief[en] Constructs a new-line widget
     */
    public init() { super() }

    /**
     * @brief[zh-cn] 渲染换行
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the line break
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igNewLine_cj()
        return false
    }
}

// =============================================================================
// UiDummy — 占位符
// =============================================================================

/**
 * @brief[zh-cn] 占位符控件（指定大小的空白）
 *
 * @brief[en] Placeholder widget (blank space of specified size)
 */
public class UiDummy <: UiWidget {
    private var _size: Vector2

    /**
     * @brief[zh-cn] 构造占位符控件
     * @param[zh-cn] size 占位尺寸，默认 (0, 0)
     *
     * @brief[en] Constructs a dummy (blank space) widget
     * @param[en] size Size of the blank space, defaults to (0, 0)
     */
    public init(size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._size = size
    }

    /**
     * @brief[zh-cn] 渲染指定尺寸的空白占位
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders a blank space of the given size
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igDummy_cj(ImVec2(Float32(this._size.x), Float32(this._size.y)))
        return false
    }
}

// =============================================================================
// UiTextWrapped — 自动换行文本
// =============================================================================

/**
 * @brief[zh-cn] 自动换行文本控件
 *
 * @brief[en] Word-wrapped text widget
 */
public class UiTextWrapped <: UiWidget {
    private var _text: String

    /**
     * @brief[zh-cn] 构造自动换行文本控件
     * @param[zh-cn] text 要显示的文本
     *
     * @brief[en] Constructs a word-wrapped text widget
     * @param[en] text Text to display
     */
    public init(text!: String) { super(); this._text = text }

    /**
     * @brief[zh-cn] 渲染自动换行文本
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the word-wrapped text
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._text) }
        igTextWrapped0_cj(cs)
        unsafe { LibC.free(cs) }
        return false
    }
}

// =============================================================================
// UiTextColored — 彩色文本
// =============================================================================

/**
 * @brief[zh-cn] 彩色文本控件
 * @explain[zh-cn] 以指定颜色渲染文本，透明度固定为 1.0。
 *
 * @brief[en] Colored text widget
 * @explain[en] Renders text with the given color; alpha is fixed at 1.0.
 */
public class UiTextColored <: UiWidget {
    private var _text: String
    private var _color: Color

    /**
     * @brief[zh-cn] 构造彩色文本控件
     * @param[zh-cn] text 要显示的文本
     * @param[zh-cn] color 文本颜色（RGB 分量范围 [0, 1]），默认白色
     *
     * @brief[en] Constructs a colored text widget
     * @param[en] text Text to display
     * @param[en] color Text color (RGB components in [0, 1]), defaults to white
     */
    public init(text!: String, color!: Color = Color(1.0, 1.0, 1.0)) {
        super()
        this._text = text
        this._color = color
    }

    /**
     * @brief[zh-cn] 渲染彩色文本
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the colored text
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._text) }
        igTextColored0_cj(ImVec4(Float32(this._color.r), Float32(this._color.g), Float32(this._color.b), 1.0), cs)
        unsafe { LibC.free(cs) }
        return false
    }
}

// =============================================================================
// UiTextDisabled — 禁用样式文本
// =============================================================================

/**
 * @brief[zh-cn] 禁用样式文本控件（灰色）
 *
 * @brief[en] Disabled style text widget (grayed out)
 */
public class UiTextDisabled <: UiWidget {
    private var _text: String

    /**
     * @brief[zh-cn] 构造禁用样式文本控件
     * @param[zh-cn] text 要显示的文本
     *
     * @brief[en] Constructs a disabled-style text widget
     * @param[en] text Text to display
     */
    public init(text!: String) { super(); this._text = text }

    /**
     * @brief[zh-cn] 渲染灰色禁用文本
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the grayed-out disabled text
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        let cs = unsafe { LibC.mallocCString(this._text) }
        igTextDisabled0_cj(cs)
        unsafe { LibC.free(cs) }
        return false
    }
}

// =============================================================================
// UiBullet — 项目符号
// =============================================================================

/**
 * @brief[zh-cn] 项目符号控件（圆点 + 同行内容）
 *
 * @brief[en] Bullet widget (dot + same-line content)
 */
public class UiBullet <: UiWidget {
    private var _content: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造项目符号控件
     *
     * @brief[en] Constructs a bullet widget
     */
    public init() { super() }

    /**
     * @brief[zh-cn] 设置项目符号后随行的内容回调
     * @param[zh-cn] content 内容渲染回调
     * @return[zh-cn] 返回自身（支持链式调用）
     *
     * @brief[en] Sets the content callback rendered after the bullet
     * @param[en] content Content render callback
     * @return[en] Returns itself (for chaining)
     */
    public func withContent(content: () -> Unit): UiBullet {
        this._content = Some(content)
        return this
    }

    /**
     * @brief[zh-cn] 渲染项目符号及其后随内容
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the bullet and its following content
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igBullet_cj()
        match (this._content) {
            case Some(f) => f()
            case None => ()
        }
        return false
    }
}

// =============================================================================
// UiBeginDisabled / UiEndDisabled — 禁用状态
// =============================================================================

/**
 * @brief[zh-cn] 禁用状态容器
 * @explain[zh-cn] 将子控件设为禁用（灰色不可交互）
 *
 * @brief[en] Disabled state container
 * @explain[en] Sets child widgets to disabled state (grayed out, non-interactive)
 */
public class UiDisabledBlock <: UiWidget {
    private var _disabled: Bool
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造禁用状态容器
     * @param[zh-cn] disabled 是否启用禁用状态，默认 true
     * @param[zh-cn] content 容器内控件渲染回调
     *
     * @brief[en] Constructs a disabled-state container
     * @param[en] disabled Whether the disabled state is enabled, defaults to true
     * @param[en] content Render callback for widgets inside the container
     */
    public init(disabled!: Bool = true, content!: () -> Unit) {
        super()
        this._disabled = disabled
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染禁用容器（BeginDisabled/EndDisabled 包裹内容）
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the disabled container (content wrapped in BeginDisabled/EndDisabled)
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        igBeginDisabled_cj(if (this._disabled) { 1 } else { 0 })
        this._content()
        igEndDisabled_cj()
        return false
    }
}

// =============================================================================
// UiColumns / UiNextColumn — 列布局
// =============================================================================

/**
 * @brief[zh-cn] 列布局容器
 *
 * @brief[en] Column layout container
 */
public class UiColumns <: UiWidget {
    private var _count: Int32
    private var _id: String
    private var _border: Bool
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造列布局容器
     * @param[zh-cn] count 列数，默认 2
     * @param[zh-cn] id 列组标识（用于区分多个列组），默认空字符串
     * @param[zh-cn] border 是否绘制列分隔边框，默认 false
     * @param[zh-cn] content 列内控件渲染回调
     *
     * @brief[en] Constructs a column layout container
     * @param[en] count Number of columns, defaults to 2
     * @param[en] id Column group identifier (to distinguish multiple groups), defaults to empty string
     * @param[en] border Whether to draw column separator borders, defaults to false
     * @param[en] content Render callback for widgets inside the columns
     */
    public init(count!: Int32 = 2, id!: String = "", border!: Bool = false,
                content!: () -> Unit) {
        super()
        this._count = count
        this._id = id
        this._border = border
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染列布局（开始列组、渲染内容、结束列组）
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the column layout (begin column group, render content, end group)
     * @return[en] Widget interaction result; always false for this widget
     */
    public override func draw(): Bool {
        let countCs = unsafe { LibC.malloc<Int32>() }
        unsafe { countCs.write(this._count) }
        let borderVal: Int32 = if (this._border) { 1 } else { 0 }
        let idCs = unsafe { LibC.mallocCString(this._id) }
        igColumns_cj(this._count, idCs, borderVal)
        this._content()
        igColumns_cj(1, unsafe { LibC.mallocCString("") }, 0)
        unsafe { LibC.free(idCs) }
        return false
    }
}
