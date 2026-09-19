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
 * @file[zh-cn] UiWidget.cj — ImGui 控件基类与具体控件实现
 * @brief[zh-cn] 所有 UI 控件的基类 UiWidget 与三十个具体控件实现
 * @explain[zh-cn] UiWidget 提供统一的 draw() 接口，子类重写 draw() 实现各自的 ImGui 调用。包含：UiText、UiButton、UiSmallButton、UiCheckbox、UiSliderFloat、UiSliderInt、UiInputText、UiInputFloat、UiInputInt、UiInputDouble、UiDragFloat、UiDragInt、UiCombo、UiSelectable、UiSeparator、UiSameLine、UiSpacing、UiTreeNode、UiTreeNodeEx、UiCollapsingHeader、UiTooltip、UiSetTooltip、UiProgressBar、UiListBox、UiImage、UiImageButton、UiColorEdit4、UiColorPicker4、UiVSliderFloat、UiDisabled、UiClipRect、UiSetNextItemWidth、UiSetNextItemOpen、UiSeparatorText、UiPlotLines、UiPlotHistogram、UiValue、UiItemQuery。用法示例：
 *   UiText("Hello").draw()
 *   if (UiButton("Click Me").draw()) { ... }
 *   UiWindow("Demo").draw({ =>
 *       UiText("Frame: " + frame.toString())
 *       UiSliderFloat("Value", valuePtr, 0.0, 1.0).draw()
 *   })
 *
 * @file[en] UiWidget.cj — ImGui Widget Base Class & Concrete Implementations
 * @brief[en] Base class UiWidget with unified draw() interface and thirty concrete widget implementations
 * @explain[en] UiWidget provides a unified draw() interface; subclasses override draw() for their ImGui calls. Includes text, buttons, checkboxes, sliders, inputs, drags, combos, selectables, tree nodes, tooltips, progress bars, images, color editors, plots, and query utilities.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*
import three.utils.memory.PtrArray
import three.window.UiContext

/// 确保当前系统线程的 ImGui TLS 上下文已设置（窗口泵为 spawn，可能在 execBgfx 等阻塞后迁移）
internal func ensureCurrentContext(): Unit {
    let ctx = UiContext.getCurrentContext()
    if (!ctx.isNull()) {
        ImGui_SetCurrentContext_cj(ctx)
    }
}

// =============================================================================
// 基类：UiWidget
// =============================================================================

/**
 * @brief[zh-cn] ImGui 控件基类
 * @explain[zh-cn] 所有具体控件继承此类。子类重写 draw() 实现渲染逻辑。
 *
 * @brief[en] Base class for all ImGui widgets
 * @explain[en] All concrete widgets inherit from this class. Subclasses override draw() to implement rendering logic.
 */
public open class UiWidget {
    /// 控件 ID（用于 ImGui PushID/PopID）
    private var _id: String = ""

    /**
     * @brief[zh-cn] 构造不带 ID 的控件
     *
     * @brief[en] Constructs a widget without an ID
     */
    public init() {}
    /**
     * @brief[zh-cn] 构造带 ID 的控件
     * @param[zh-cn] id 控件 ID（用于 ImGui PushID/PopID 命名空间隔离）
     *
     * @brief[en] Constructs a widget with an ID
     * @param[en] id Widget ID (used for ImGui PushID/PopID namespace isolation)
     */
    public init(id!: String) { this._id = id }

    /**
     * @brief[zh-cn] 渲染控件（子类重写）
     * @return[zh-cn] 控件交互结果（点击/值变化等），具体含义由子类定义
     *
     * @brief[en] Render the widget (override in subclasses)
     * @return[en] Widget interaction result (click/value change etc.), meaning defined by subclass
     */
    public open func draw(): Bool { return false }

    /**
     * @brief[zh-cn] 获取控件 ID
     *
     * @brief[en] Returns the widget ID
     */
    public func getId(): String { return this._id }
}

// =============================================================================
// UiText — 文本显示
// =============================================================================

/**
 * @brief[zh-cn] 文本显示控件
 *
 * @brief[en] Text display widget
 */
public class UiText <: UiWidget {
    private var _text: String

    /**
     * @brief[zh-cn] 构造文本显示控件
     * @param[zh-cn] text 要显示的文本
     *
     * @brief[en] Constructs a text display widget
     * @param[en] text The text to display
     */
    public init(text!: String) { super(); this._text = text }

    /**
     * @brief[zh-cn] 渲染文本
     * @return[zh-cn] 恒为 false（文本无交互）
     *
     * @brief[en] Renders the text
     * @return[en] Always false (text has no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_Text_cj(this._text)
        return false
    }

    /**
     * @brief[zh-cn] 获取显示文本
     *
     * @brief[en] Returns the display text
     */
    public func getText(): String { return this._text }
    /**
     * @brief[zh-cn] 设置显示文本
     *
     * @brief[en] Sets the display text
     */
    public func setText(text: String): Unit { this._text = text }
}

// =============================================================================
// UiButton — 按钮
// =============================================================================

/**
 * @brief[zh-cn] 按钮控件
 *
 * @brief[en] Button widget
 */
public class UiButton <: UiWidget {
    private var _label: String
    private var _size: Vector2
    private var _onClick: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造按钮控件
     * @param[zh-cn] label 按钮标签文本
     * @param[zh-cn] size 按钮尺寸（默认 (0,0) 表示自动计算）
     *
     * @brief[en] Constructs a button widget
     * @param[en] label Button label text
     * @param[en] size Button size (default (0,0) means auto-calculated)
     */
    public init(label!: String, size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._label = label
        this._size = size
    }

    /**
     * @brief[zh-cn] 设置点击回调
     * @param[zh-cn] callback 点击时执行的闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the click callback
     * @param[en] callback Closure executed on click
     * @return[en] this (for chaining)
     */
    public func onClick(callback: () -> Unit): UiButton {
        this._onClick = Some(callback)
        return this
    }

    /**
     * @brief[zh-cn] 渲染按钮，点击时触发回调
     * @return[zh-cn] 本次点击是否发生
     *
     * @brief[en] Renders the button and triggers the callback on click
     * @return[en] Whether the button was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let clicked = ImGui_Button_cj(this._label, Float32(this._size.x), Float32(this._size.y))
        if (clicked) {
            match (this._onClick) {
                case Some(f) => f()
                case None => ()
            }
        }
        return clicked
    }
}

// =============================================================================
// UiSmallButton — 小按钮
// =============================================================================

/**
 * @brief[zh-cn] 小按钮控件（无边框，适合工具栏）
 *
 * @brief[en] Small button widget (borderless, suitable for toolbars)
 */
public class UiSmallButton <: UiWidget {
    private var _label: String
    private var _onClick: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造小按钮控件
     * @param[zh-cn] label 按钮标签文本
     *
     * @brief[en] Constructs a small button widget
     * @param[en] label Button label text
     */
    public init(label!: String) { super(); this._label = label }

    /**
     * @brief[zh-cn] 设置点击回调
     * @param[zh-cn] callback 点击时执行的闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the click callback
     * @param[en] callback Closure executed on click
     * @return[en] this (for chaining)
     */
    public func onClick(callback: () -> Unit): UiSmallButton {
        this._onClick = Some(callback)
        return this
    }

    /**
     * @brief[zh-cn] 渲染小按钮，点击时触发回调
     * @return[zh-cn] 本次点击是否发生
     *
     * @brief[en] Renders the small button and triggers the callback on click
     * @return[en] Whether the button was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let clicked = ImGui_SmallButton_cj(this._label)
        if (clicked) {
            match (this._onClick) {
                case Some(f) => f()
                case None => ()
            }
        }
        return clicked
    }
}

// =============================================================================
// UiCheckbox — 复选框
// =============================================================================

/**
 * @brief[zh-cn] 复选框控件
 * @explain[zh-cn] 使用 PtrArray<Int32> 存储状态（0/1），与 ImGui 约定一致。
 *
 * @brief[en] Checkbox widget
 * @explain[en] Uses PtrArray<Int32> for state (0/1), matching ImGui conventions.
 */
public class UiCheckbox <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Int32>

    /**
     * @brief[zh-cn] 构造复选框控件
     * @param[zh-cn] label 复选框标签文本
     * @param[zh-cn] value 状态缓冲（PtrArray<Int32> 单元素，0=未选中 1=选中）
     *
     * @brief[en] Constructs a checkbox widget
     * @param[en] label Checkbox label text
     * @param[en] value State buffer (single-element PtrArray<Int32>, 0=unchecked 1=checked)
     */
    public init(label!: String, value!: PtrArray<Int32>) {
        super()
        this._label = label
        this._value = value
    }

    /**
     * @brief[zh-cn] 渲染复选框并同步勾选状态
     * @return[zh-cn] 本次是否发生勾选状态变化
     *
     * @brief[en] Renders the checkbox and syncs the check state
     * @return[en] Whether the check state changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Checkbox_cj(this._label, this._value.data())
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 0=未选中，1=选中
     *
     * @brief[en] Gets the current value
     * @return[en] 0=unchecked, 1=checked
     */
    public func getValue(): Int32 {
        return this._value.get(0)
    }

    /**
     * @brief[zh-cn] 设置值
     * @param[zh-cn] v 0=未选中，1=选中
     *
     * @brief[en] Sets the value
     * @param[en] v 0=unchecked, 1=checked
     */
    public func setValue(v: Int32): Unit {
        this._value.set(0, v)
    }
}

// =============================================================================
// UiSliderFloat — 浮点滑块
// =============================================================================

/**
 * @brief[zh-cn] 浮点滑块控件
 *
 * @brief[en] Float slider widget
 */
public class UiSliderFloat <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Float32>
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    /**
     * @brief[zh-cn] 构造浮点滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Float32> 单元素，随拖动更新）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 1.0）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     *
     * @brief[en] Constructs a float slider widget
     * @param[en] label Slider label text
     * @param[en] value Value buffer (single-element PtrArray<Float32>, updated on drag)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 1.0)
     * @param[en] format Number display format (default "%.3f")
     */
    public init(label!: String, value!: PtrArray<Float32>,
                min!: Float32 = 0.0, max!: Float32 = 1.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._min = min
        this._max = max
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染滑块并同步值
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the slider and syncs the value
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let fmtCs = unsafe { LibC.mallocCString(this._format) }
        let r = igSliderFloat_cj(cs, this._value.data(), this._min, this._max, fmtCs, 0)
        unsafe { LibC.free(cs); LibC.free(fmtCs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 滑块当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current slider value
     */
    public func getValue(): Float32 {
        return this._value.get(0)
    }

    /**
     * @brief[zh-cn] 设置当前值
     * @param[zh-cn] v 要设置的值
     *
     * @brief[en] Sets the current value
     * @param[en] v The value to set
     */
    public func setValue(v: Float32): Unit {
        this._value.set(0, v)
    }
}

// =============================================================================
// UiSliderInt — 整数滑块
// =============================================================================

/**
 * @brief[zh-cn] 整数滑块控件
 *
 * @brief[en] Integer slider widget
 */
public class UiSliderInt <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Int32>
    private var _min: Int32
    private var _max: Int32
    private var _format: String

    /**
     * @brief[zh-cn] 构造整数滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Int32> 单元素，随拖动更新）
     * @param[zh-cn] min 最小值（默认 0）
     * @param[zh-cn] max 最大值（默认 100）
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     *
     * @brief[en] Constructs an integer slider widget
     * @param[en] label Slider label text
     * @param[en] value Value buffer (single-element PtrArray<Int32>, updated on drag)
     * @param[en] min Minimum value (default 0)
     * @param[en] max Maximum value (default 100)
     * @param[en] format Number display format (default "%d")
     */
    public init(label!: String, value!: PtrArray<Int32>,
                min!: Int32 = 0, max!: Int32 = 100,
                format!: String = "%d") {
        super()
        this._label = label
        this._value = value
        this._min = min
        this._max = max
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染滑块并同步值
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the slider and syncs the value
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let fmtCs = unsafe { LibC.mallocCString(this._format) }
        let r = igSliderInt_cj(cs, this._value.data(), this._min, this._max, fmtCs, 0)
        unsafe { LibC.free(cs); LibC.free(fmtCs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 滑块当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current slider value
     */
    public func getValue(): Int32 {
        return this._value.get(0)
    }

    /**
     * @brief[zh-cn] 设置当前值
     * @param[zh-cn] v 要设置的值
     *
     * @brief[en] Sets the current value
     * @param[en] v The value to set
     */
    public func setValue(v: Int32): Unit {
        this._value.set(0, v)
    }
}

// =============================================================================
// UiInputText — 文本输入框
// =============================================================================

/**
 * @brief[zh-cn] 文本输入框控件
 * @explain[zh-cn] 使用栈缓冲区存储输入文本。
 *
 * @brief[en] Text input widget
 * @explain[en] Uses a stack buffer to store input text.
 */
public class UiInputText <: UiWidget {
    private var _label: String
    private var _buf: CPointer<Int8>
    private var _bufSize: UIntNative
    private var _hint: String
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造文本输入框
     * @param[zh-cn] label 标签
     * @param[zh-cn] bufSize 缓冲区大小（字节），默认 256
     * @param[zh-cn] hint 占位提示文本
     * @param[zh-cn] flags 输入标志
     *
     * @brief[en] Constructs a text input widget
     * @param[en] label Label text
     * @param[en] bufSize Buffer size in bytes, defaults to 256
     * @param[en] hint Placeholder hint text
     * @param[en] flags Input flags
     */
    public init(label!: String, bufSize!: UIntNative = UIntNative(256),
                hint!: String = "", flags!: Int32 = 0) {
        super()
        this._label = label
        this._bufSize = bufSize
        this._hint = hint
        this._flags = flags
        this._buf = unsafe { LibC.malloc<Int8>(count: Int64(bufSize)) }
        unsafe {
            let p = this._buf
            p.write(0i8)
        }
    }

    /**
     * @brief[zh-cn] 渲染文本输入框
     * @return[zh-cn] 本次输入内容是否发生变化
     *
     * @brief[en] Renders the text input box
     * @return[en] Whether the input text changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        if (this._hint.isEmpty()) {
            let cs = unsafe { LibC.mallocCString(this._label) }
            let r = igInputText_cj(cs, this._buf, this._bufSize, this._flags, CPointer<Unit>(), CPointer<Unit>()) != 0
            unsafe { LibC.free(cs) }
            return r
        } else {
            let cs = unsafe { LibC.mallocCString(this._label) }
            let hintCs = unsafe { LibC.mallocCString(this._hint) }
            let r = igInputTextWithHint_cj(cs, hintCs, this._buf, this._bufSize, this._flags, CPointer<Unit>(), CPointer<Unit>()) != 0
            unsafe { LibC.free(cs); LibC.free(hintCs) }
            return r
        }
    }

    /**
     * @brief[zh-cn] 获取输入文本
     *
     * @brief[en] Returns the input text
     */
    public func getText(): String {
        return unsafe {
            let cp = CPointer<UInt8>(CPointer<Unit>(this._buf))
            if (cp.isNull()) { "" } else { CString(cp).toString() }
        }
    }

    /**
     * @brief[zh-cn] 设置输入文本
     *
     * @brief[en] Sets the input text
     */
    public func setText(text: String): Unit {
        unsafe {
            let cs = LibC.mallocCString(text)
            let src = cs.getChars()
            let dst = this._buf
            var i: Int64 = 0
            while (i < Int64(this._bufSize) - 1) {
                let ch = (src + i).read()
                if (ch == 0u8) { break }
                (dst + i).write(Int8(ch))
                i++
            }
            (dst + i).write(0i8)
            LibC.free(cs)
        }
    }

    /// 获取缓冲区指针（内部使用，外部请使用 getText/setText）
    internal func getBufPtr(): CPointer<Int8> { return this._buf }
}

// =============================================================================
// UiInputFloat — 浮点输入框
// =============================================================================

/**
 * @brief[zh-cn] 浮点输入框控件
 *
 * @brief[en] Float input widget
 */
public class UiInputFloat <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Float32>
    private var _step: Float32
    private var _stepFast: Float32
    private var _format: String

    /**
     * @brief[zh-cn] 构造浮点输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Float32> 单元素，随输入更新）
     * @param[zh-cn] step 步进值（默认 0.1）
     * @param[zh-cn] stepFast 按住 Shift 时的快进步进（默认 1.0）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     *
     * @brief[en] Constructs a float input widget
     * @param[en] label Input label text
     * @param[en] value Value buffer (single-element PtrArray<Float32>, updated on input)
     * @param[en] step Step value (default 0.1)
     * @param[en] stepFast Fast step while holding Shift (default 1.0)
     * @param[en] format Number display format (default "%.3f")
     */
    public init(label!: String, value!: PtrArray<Float32>,
                step!: Float32 = 0.1, stepFast!: Float32 = 1.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染浮点输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the float input box
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputFloat_cj(this._label, this._value.data(), this._step, this._stepFast, this._format, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 输入框当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current input value
     */
    public func getValue(): Float32 { return this._value.get(0) }
    /**
     * @brief[zh-cn] 设置当前值
     * @param[zh-cn] v 要设置的值
     *
     * @brief[en] Sets the current value
     * @param[en] v The value to set
     */
    public func setValue(v: Float32): Unit { this._value.set(0, v) }
}

// =============================================================================
// UiCombo — 下拉框
// =============================================================================

/**
 * @brief[zh-cn] 下拉框控件
 *
 * @brief[en] Combo box widget
 */
public class UiCombo <: UiWidget {
    private var _label: String
    private var _currentItem: PtrArray<Int32>
    private var _items: String

    /**
     * @brief[zh-cn] 构造下拉框控件
     * @param[zh-cn] label 下拉框标签文本
     * @param[zh-cn] currentItem 当前选中索引（PtrArray<Int32> 单元素绑定）
     * @param[zh-cn] items 以 '\0' 分隔的选项列表（如 "Option1\0Option2\0Option3\0"）
     *
     * @brief[en] Constructs a combo box widget
     * @param[en] label Combo label text
     * @param[en] currentItem Current selected index (single-element PtrArray<Int32> binding)
     * @param[en] items Option list separated by '\0' (e.g. "Option1\0Option2\0Option3\0")
     */
    public init(label!: String, currentItem!: PtrArray<Int32>, items!: String) {
        super()
        this._label = label
        this._currentItem = currentItem
        this._items = items
    }

    /**
     * @brief[zh-cn] 渲染下拉框并同步选中索引
     * @return[zh-cn] 本次选中项是否发生变化
     *
     * @brief[en] Renders the combo box and syncs the selected index
     * @return[en] Whether the selection changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Combo_Str_cj(this._label, this._currentItem.data(), this._items, -1) != 0
    }

    /**
     * @brief[zh-cn] 获取当前选中项索引
     * @return[zh-cn] 当前选中项索引
     *
     * @brief[en] Gets the current selected item index
     * @return[en] The current selected index
     */
    public func getCurrentIndex(): Int32 { return this._currentItem.get(0) }
}

// =============================================================================
// UiSelectable — 可选项
// =============================================================================

/**
 * @brief[zh-cn] 可选项控件
 *
 * @brief[en] Selectable widget
 */
public class UiSelectable <: UiWidget {
    private var _label: String
    private var _selected: Bool
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造可选项控件
     * @param[zh-cn] label 选项标签文本
     * @param[zh-cn] selected 初始选中状态（默认 false）
     * @param[zh-cn] flags ImGui 选择项标志（默认 0）
     *
     * @brief[en] Constructs a selectable widget
     * @param[en] label Selectable label text
     * @param[en] selected Initial selection state (default false)
     * @param[en] flags ImGui selectable flags (default 0)
     */
    public init(label!: String, selected!: Bool = false, flags!: Int32 = 0) {
        super()
        this._label = label
        this._selected = selected
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 渲染可选项
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the selectable
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Selectable_Bool_cj(this._label, if (this._selected) { 1 } else { 0 }, this._flags, ImVec2(0.0, 0.0)) != 0
    }

    /**
     * @brief[zh-cn] 获取选中状态
     * @return[zh-cn] 是否选中
     *
     * @brief[en] Gets the selection state
     * @return[en] Whether selected
     */
    public func isSelected(): Bool { return this._selected }
    /**
     * @brief[zh-cn] 设置选中状态
     * @param[zh-cn] v 是否选中
     *
     * @brief[en] Sets the selection state
     * @param[en] v Whether selected
     */
    public func setSelected(v: Bool): Unit { this._selected = v }
}

// =============================================================================
// UiSeparator — 分隔线
// =============================================================================

/**
 * @brief[zh-cn] 分隔线控件
 *
 * @brief[en] Separator widget
 */
public class UiSeparator <: UiWidget {
    /**
     * @brief[zh-cn] 构造分隔线控件
     *
     * @brief[en] Constructs a separator widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 渲染分隔线
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the separator
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_Separator_cj()
        return false
    }
}

// =============================================================================
// UiSameLine — 同行布局
// =============================================================================

/**
 * @brief[zh-cn] 同行布局控件（将下一个控件放到同一行）
 *
 * @brief[en] Same-line layout widget (places the next widget on the same line)
 */
public class UiSameLine <: UiWidget {
    private var _offset: Float32
    private var _spacing: Float32

    /**
     * @brief[zh-cn] 构造同行布局控件
     * @param[zh-cn] offset 相对上一项的水平偏移（默认 0.0）
     * @param[zh-cn] spacing 与上一项的间距（默认 -1.0 表示使用默认间距）
     *
     * @brief[en] Constructs a same-line layout widget
     * @param[en] offset Horizontal offset from the previous item (default 0.0)
     * @param[en] spacing Spacing from the previous item (default -1.0 means use default spacing)
     */
    public init(offset!: Float32 = 0.0, spacing!: Float32 = -1.0) {
        super()
        this._offset = offset
        this._spacing = spacing
    }

    /**
     * @brief[zh-cn] 将下一个控件放到同一行
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Places the next widget on the same line
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_SameLine_cj(this._offset, this._spacing)
        return false
    }
}

// =============================================================================
// UiSpacing — 间距
// =============================================================================

/**
 * @brief[zh-cn] 间距控件
 *
 * @brief[en] Spacing widget
 */
public class UiSpacing <: UiWidget {
    /**
     * @brief[zh-cn] 构造间距控件
     *
     * @brief[en] Constructs a spacing widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 插入一行垂直间距
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Inserts a vertical spacing line
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_Spacing_cj()
        return false
    }
}

// =============================================================================
// UiTreeNode — 树节点
// =============================================================================

/**
 * @brief[zh-cn] 树节点控件
 * @explain[zh-cn] 用法：UiTreeNode("Node Label").draw({ => UiText("Child content") })
 *
 * @brief[en] Tree node widget
 * @explain[en] Usage: UiTreeNode("Node Label").draw({ => UiText("Child content") })
 */
public class UiTreeNode <: UiWidget {
    private var _label: String
    private var _content: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造树节点控件
     * @param[zh-cn] label 节点标签文本
     *
     * @brief[en] Constructs a tree node widget
     * @param[en] label Node label text
     */
    public init(label!: String) { super(); this._label = label }

    /**
     * @brief[zh-cn] 设置子内容闭包
     * @param[zh-cn] content 展开时执行的子内容闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the child content closure
     * @param[en] content Child content closure executed when expanded
     * @return[en] this (for chaining)
     */
    public func withContent(content: () -> Unit): UiTreeNode {
        this._content = Some(content)
        return this
    }

    /**
     * @brief[zh-cn] 渲染树节点；展开时执行子内容
     * @return[zh-cn] 本帧是否处于展开状态
     *
     * @brief[en] Renders the tree node; executes child content when expanded
     * @return[en] Whether the node is expanded this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let opened = ImGui_TreeNode_Str_cj(this._label) != 0
        if (opened) {
            match (this._content) {
                case Some(f) => f()
                case None => ()
            }
            ImGui_TreePop_cj()
        }
        return opened
    }
}

// =============================================================================
// UiTreeNodeEx — 扩展树节点（支持标志位）
// =============================================================================

/**
 * @brief[zh-cn] 扩展树节点控件（支持标志位）
 *
 * @brief[en] Extended tree node widget (with flags support)
 */
public class UiTreeNodeEx <: UiWidget {
    private var _label: String
    private var _flags: Int32
    private var _content: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造扩展树节点控件
     * @param[zh-cn] label 节点标签文本
     * @param[zh-cn] flags ImGui 树节点标志（如默认展开，默认 0）
     *
     * @brief[en] Constructs an extended tree node widget
     * @param[en] label Node label text
     * @param[en] flags ImGui tree node flags (e.g. default-open, default 0)
     */
    public init(label!: String, flags!: Int32 = 0) { super(); this._label = label; this._flags = flags }

    /**
     * @brief[zh-cn] 设置子内容闭包
     * @param[zh-cn] content 展开时执行的子内容闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the child content closure
     * @param[en] content Child content closure executed when expanded
     * @return[en] this (for chaining)
     */
    public func withContent(content: () -> Unit): UiTreeNodeEx {
        this._content = Some(content)
        return this
    }

    /**
     * @brief[zh-cn] 渲染扩展树节点；展开时执行子内容
     * @return[zh-cn] 本帧是否处于展开状态
     *
     * @brief[en] Renders the extended tree node; executes child content when expanded
     * @return[en] Whether the node is expanded this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let opened = ImGui_TreeNodeEx_Str_cj(this._label, this._flags) != 0
        if (opened) {
            match (this._content) {
                case Some(f) => f()
                case None => ()
            }
            ImGui_TreePop_cj()
        }
        return opened
    }
}

// =============================================================================
// UiCollapsingHeader — 折叠标题
// =============================================================================

/**
 * @brief[zh-cn] 折叠标题控件
 *
 * @brief[en] Collapsing header widget
 */
public class UiCollapsingHeader <: UiWidget {
    private var _label: String
    private var _flags: Int32
    private var _content: Option<() -> Unit> = None

    /**
     * @brief[zh-cn] 构造折叠标题控件
     * @param[zh-cn] label 标题文本
     * @param[zh-cn] flags ImGui 标题标志（默认 0）
     *
     * @brief[en] Constructs a collapsing header widget
     * @param[en] label Header text
     * @param[en] flags ImGui header flags (default 0)
     */
    public init(label!: String, flags!: Int32 = 0) { super(); this._label = label; this._flags = flags }

    /**
     * @brief[zh-cn] 设置折叠区域内容闭包
     * @param[zh-cn] content 展开时执行的内容闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the collapsible content closure
     * @param[en] content Content closure executed when expanded
     * @return[en] this (for chaining)
     */
    public func withContent(content: () -> Unit): UiCollapsingHeader {
        this._content = Some(content)
        return this
    }

    /**
     * @brief[zh-cn] 渲染折叠标题；展开时执行内容
     * @return[zh-cn] 本帧是否处于展开状态
     *
     * @brief[en] Renders the collapsing header; executes content when expanded
     * @return[en] Whether the header is expanded this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let opened = ImGui_CollapsingHeader_TreeNodeFlags_cj(this._label, this._flags) != 0
        if (opened) {
            match (this._content) {
                case Some(f) => f()
                case None => ()
            }
        }
        return opened
    }
}

// =============================================================================
// UiTooltip — 工具提示
// =============================================================================

/**
 * @brief[zh-cn] 工具提示控件（悬停时显示）
 *
 * @brief[en] Tooltip widget (shown on hover)
 */
public class UiTooltip <: UiWidget {
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造工具提示控件
     * @param[zh-cn] content 悬停时显示的内容闭包
     *
     * @brief[en] Constructs a tooltip widget
     * @param[en] content Content closure shown on hover
     */
    public init(content!: () -> Unit) { super(); this._content = content }

    /**
     * @brief[zh-cn] 悬停时显示工具提示内容
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Shows the tooltip content on hover
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        if (ImGui_BeginItemTooltip_cj() != 0) {
            this._content()
            ImGui_EndTooltip_cj()
        }
        return false
    }
}

// =============================================================================
// UiSetTooltip — 设置工具提示（文本）
// =============================================================================

/**
 * @brief[zh-cn] 文本工具提示控件
 *
 * @brief[en] Text tooltip widget
 */
public class UiSetTooltip <: UiWidget {
    private var _text: String

    /**
     * @brief[zh-cn] 构造文本工具提示控件
     * @param[zh-cn] text 提示文本
     *
     * @brief[en] Constructs a text tooltip widget
     * @param[en] text Tooltip text
     */
    public init(text!: String) { super(); this._text = text }

    /**
     * @brief[zh-cn] 立即设置并显示文本工具提示
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Sets and shows the text tooltip immediately
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_SetTooltip0_cj(this._text)
        return false
    }
}

// =============================================================================
// UiProgressBar — 进度条
// =============================================================================

/**
 * @brief[zh-cn] 进度条控件
 *
 * @brief[en] Progress bar widget
 */
public class UiProgressBar <: UiWidget {
    private var _fraction: Float32
    private var _size: Vector2
    private var _overlay: String

    /**
     * @brief[zh-cn] 构造进度条控件
     * @param[zh-cn] fraction 进度比例（0.0~1.0，默认 0.0）
     * @param[zh-cn] size 进度条尺寸（默认 (-1.0, 0.0) 表示填充当前行宽）
     * @param[zh-cn] overlay 叠加显示的文本（默认空字符串表示不显示）
     *
     * @brief[en] Constructs a progress bar widget
     * @param[en] fraction Progress fraction (0.0~1.0, default 0.0)
     * @param[en] size Progress bar size (default (-1.0, 0.0) fills the current line width)
     * @param[en] overlay Overlay text (default empty means no overlay)
     */
    public init(fraction!: Float32 = 0.0,
                size!: Vector2 = Vector2(-1.0, 0.0),
                overlay!: String = "") {
        super()
        this._fraction = fraction
        this._size = size
        this._overlay = overlay
    }

    /**
     * @brief[zh-cn] 渲染进度条
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the progress bar
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_ProgressBar_cj(this._fraction, ImVec2(Float32(this._size.x), Float32(this._size.y)), this._overlay)
        return false
    }

    /**
     * @brief[zh-cn] 设置进度比例
     * @param[zh-cn] f 进度比例（0.0~1.0）
     *
     * @brief[en] Sets the progress fraction
     * @param[en] f Progress fraction (0.0~1.0)
     */
    public func setFraction(f: Float32): Unit { this._fraction = f }
    /**
     * @brief[zh-cn] 获取进度比例
     * @return[zh-cn] 当前进度比例
     *
     * @brief[en] Gets the progress fraction
     * @return[en] The current progress fraction
     */
    public func getFraction(): Float32 { return this._fraction }
}

// =============================================================================
// UiListBox — 列表框
// =============================================================================

/**
 * @brief[zh-cn] 列表框控件
 *
 * @brief[en] List box widget
 */
public class UiListBox <: UiWidget {
    private var _label: String
    private var _currentItem: PtrArray<Int32>
    private var _items: String
    private var _heightInItems: Int32

    /**
     * @brief[zh-cn] 构造列表框控件
     * @param[zh-cn] label 列表框标签文本
     * @param[zh-cn] currentItem 当前选中索引（PtrArray<Int32> 单元素绑定）
     * @param[zh-cn] items 以 '\0' 分隔的选项列表
     * @param[zh-cn] heightInItems 以行数表示的高度（默认 -1 表示自动）
     *
     * @brief[en] Constructs a list box widget
     * @param[en] label List box label text
     * @param[en] currentItem Current selected index (single-element PtrArray<Int32> binding)
     * @param[en] items Option list separated by '\0'
     * @param[en] heightInItems Height in item rows (default -1 means auto)
     */
    public init(label!: String, currentItem!: PtrArray<Int32>,
                items!: String, heightInItems!: Int32 = -1) {
        super()
        this._label = label
        this._currentItem = currentItem
        this._items = items
        this._heightInItems = heightInItems
    }

    /**
     * @brief[zh-cn] 渲染列表框并同步选中索引
     * @return[zh-cn] 本次选中项是否发生变化
     *
     * @brief[en] Renders the list box and syncs the selected index
     * @return[en] Whether the selection changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return unsafe {
            let csItems = LibC.mallocCString(this._items)
            let r = ImGui_ListBox_Str_arr_cj(this._label, this._currentItem.data(),
                                              CPointer<Unit>(csItems.getChars()),
                                              -1, this._heightInItems)
            LibC.free(csItems)
            r != 0
        }
    }

    /**
     * @brief[zh-cn] 获取当前选中项索引
     * @return[zh-cn] 当前选中项索引
     *
     * @brief[en] Gets the current selected item index
     * @return[en] The current selected index
     */
    public func getCurrentIndex(): Int32 { return this._currentItem.get(0) }
}

// =============================================================================
// UiImage — 图片显示
// =============================================================================

/**
 * @brief[zh-cn] 图片显示控件
 *
 * @brief[en] Image display widget
 */
public class UiImage <: UiWidget {
    private var _texId: UInt64
    private var _size: Vector2

    /**
     * @brief[zh-cn] 构造图片显示控件
     * @param[zh-cn] texId 纹理 ID（bgfx 纹理句柄值）
     * @param[zh-cn] size 图片显示尺寸（默认 64x64）
     *
     * @brief[en] Constructs an image display widget
     * @param[en] texId Texture ID (bgfx texture handle value)
     * @param[en] size Display size (default 64x64)
     */
    public init(texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0)) {
        super()
        this._texId = texId
        this._size = size
    }

    /**
     * @brief[zh-cn] 渲染图片
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the image
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let texRef = ImTextureRef_ImTextureRef_TextureID_cj(this._texId)
        igImage_cj(texRef, ImVec2(Float32(this._size.x), Float32(this._size.y)), ImVec2(0.0, 0.0), ImVec2(1.0, 1.0))
        return false
    }
}

// =============================================================================
// UiImageButton — 图片按钮
// =============================================================================

/**
 * @brief[zh-cn] 图片按钮控件
 *
 * @brief[en] Image button widget
 */
public class UiImageButton <: UiWidget {
    private var _strId: String
    private var _texId: UInt64
    private var _size: Vector2

    /**
     * @brief[zh-cn] 构造图片按钮控件
     * @param[zh-cn] strId 按钮字符串 ID（ImGui ID 命名用）
     * @param[zh-cn] texId 纹理 ID（bgfx 纹理句柄值）
     * @param[zh-cn] size 按钮显示尺寸（默认 64x64）
     *
     * @brief[en] Constructs an image button widget
     * @param[en] strId Button string ID (used for ImGui ID naming)
     * @param[en] texId Texture ID (bgfx texture handle value)
     * @param[en] size Button display size (default 64x64)
     */
    public init(strId!: String, texId!: UInt64,
                size!: Vector2 = Vector2(64.0, 64.0)) {
        super()
        this._strId = strId
        this._texId = texId
        this._size = size
    }

    /**
     * @brief[zh-cn] 渲染图片按钮
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the image button
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let texRef = ImTextureRef_ImTextureRef_TextureID_cj(this._texId)
        return igImageButton_cj(unsafe { LibC.mallocCString(this._strId) }, texRef, ImVec2(Float32(this._size.x), Float32(this._size.y)),
                                 ImVec2(0.0, 0.0), ImVec2(1.0, 1.0),
                                 ImVec4(1.0, 1.0, 1.0, 1.0), ImVec4(1.0, 1.0, 1.0, 1.0)) != 0
    }
}

// =============================================================================
// UiColorEdit4 — 颜色编辑器
// =============================================================================

/**
 * @brief[zh-cn] 颜色编辑器控件（RGBA）
 *
 * @brief[en] Color editor widget (RGBA)
 */
public class UiColorEdit4 <: UiWidget {
    private var _label: String
    private var _col: PtrArray<Float32>
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造颜色编辑器控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] col 颜色缓冲（PtrArray<Float32>，4 个分量 RGBA，0.0~1.0）
     * @param[zh-cn] flags ImGui 颜色编辑标志（默认 0）
     *
     * @brief[en] Constructs a color editor widget
     * @param[en] label Label text
     * @param[en] col Color buffer (PtrArray<Float32> of 4 RGBA components, 0.0~1.0)
     * @param[en] flags ImGui color edit flags (default 0)
     */
    public init(label!: String, col!: PtrArray<Float32>, flags!: Int32 = 0) {
        super()
        this._label = label
        this._col = col
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 渲染颜色编辑器
     * @return[zh-cn] 本次颜色是否发生变化
     *
     * @brief[en] Renders the color editor
     * @return[en] Whether the color changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_ColorEdit4_cj(this._label, this._col.data(), this._flags) != 0
    }
}

// =============================================================================
// UiColorPicker4 — 颜色选择器
// =============================================================================

/**
 * @brief[zh-cn] 颜色选择器控件（RGBA）
 *
 * @brief[en] Color picker widget (RGBA)
 */
public class UiColorPicker4 <: UiWidget {
    private var _label: String
    private var _col: PtrArray<Float32>
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造颜色选择器控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] col 颜色缓冲（PtrArray<Float32>，4 个分量 RGBA，0.0~1.0）
     * @param[zh-cn] flags ImGui 颜色选择标志（默认 0）
     *
     * @brief[en] Constructs a color picker widget
     * @param[en] label Label text
     * @param[en] col Color buffer (PtrArray<Float32> of 4 RGBA components, 0.0~1.0)
     * @param[en] flags ImGui color picker flags (default 0)
     */
    public init(label!: String, col!: PtrArray<Float32>, flags!: Int32 = 0) {
        super()
        this._label = label
        this._col = col
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 渲染颜色选择器
     * @return[zh-cn] 本次颜色是否发生变化
     *
     * @brief[en] Renders the color picker
     * @return[en] Whether the color changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_ColorPicker4_cj(this._label, this._col.data(), this._flags, CPointer<Float32>()) != 0
    }
}

// =============================================================================
// UiDragFloat — 浮点拖拽
// =============================================================================

/**
 * @brief[zh-cn] 浮点拖拽控件
 *
 * @brief[en] Float drag widget
 */
public class UiDragFloat <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Float32>
    private var _speed: Float32
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    /**
     * @brief[zh-cn] 构造浮点拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Float32> 单元素，随拖拽更新）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 0.0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     *
     * @brief[en] Constructs a float drag widget
     * @param[en] label Label text
     * @param[en] value Value buffer (single-element PtrArray<Float32>, updated on drag)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 0.0 means unbounded)
     * @param[en] format Number display format (default "%.3f")
     */
    public init(label!: String, value!: PtrArray<Float32>,
                speed!: Float32 = 1.0, min!: Float32 = 0.0, max!: Float32 = 0.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._speed = speed
        this._min = min
        this._max = max
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染浮点拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the float drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_DragFloat_cj(this._label, this._value.data(), this._speed,
                                   this._min, this._max, this._format, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 拖拽当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current drag value
     */
    public func getValue(): Float32 { return this._value.get(0) }
}

// =============================================================================
// UiDragInt — 整数拖拽
// =============================================================================

/**
 * @brief[zh-cn] 整数拖拽控件
 *
 * @brief[en] Integer drag widget
 */
public class UiDragInt <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Int32>
    private var _speed: Float32
    private var _min: Int32
    private var _max: Int32
    private var _format: String

    /**
     * @brief[zh-cn] 构造整数拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Int32> 单元素，随拖拽更新）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0）
     * @param[zh-cn] max 最大值（默认 0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     *
     * @brief[en] Constructs an integer drag widget
     * @param[en] label Label text
     * @param[en] value Value buffer (single-element PtrArray<Int32>, updated on drag)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0)
     * @param[en] max Maximum value (default 0 means unbounded)
     * @param[en] format Number display format (default "%d")
     */
    public init(label!: String, value!: PtrArray<Int32>,
                speed!: Float32 = 1.0, min!: Int32 = 0, max!: Int32 = 0,
                format!: String = "%d") {
        super()
        this._label = label
        this._value = value
        this._speed = speed
        this._min = min
        this._max = max
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染整数拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the integer drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_DragInt_cj(this._label, this._value.data(), this._speed,
                                 this._min, this._max, this._format, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 拖拽当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current drag value
     */
    public func getValue(): Int32 { return this._value.get(0) }
}

// =============================================================================
// UiInputInt — 整数输入框
// =============================================================================

/**
 * @brief[zh-cn] 整数输入框控件
 *
 * @brief[en] Integer input widget
 */
public class UiInputInt <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Int32>
    private var _step: Int32
    private var _stepFast: Int32

    /**
     * @brief[zh-cn] 构造整数输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Int32> 单元素，随输入更新）
     * @param[zh-cn] step 步进值（默认 1）
     * @param[zh-cn] stepFast 按住 Shift 时的快进步进（默认 100）
     *
     * @brief[en] Constructs an integer input widget
     * @param[en] label Input label text
     * @param[en] value Value buffer (single-element PtrArray<Int32>, updated on input)
     * @param[en] step Step value (default 1)
     * @param[en] stepFast Fast step while holding Shift (default 100)
     */
    public init(label!: String, value!: PtrArray<Int32>,
                step!: Int32 = 1, stepFast!: Int32 = 100) {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
    }

    /**
     * @brief[zh-cn] 渲染整数输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the integer input box
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputInt_cj(this._label, this._value.data(), this._step, this._stepFast, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 输入框当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current input value
     */
    public func getValue(): Int32 { return this._value.get(0) }
}

// =============================================================================
// UiInputDouble — 双精度输入框
// =============================================================================

/**
 * @brief[zh-cn] 双精度输入框控件
 *
 * @brief[en] Double precision input widget
 */
public class UiInputDouble <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Float64>
    private var _step: Float64
    private var _stepFast: Float64
    private var _format: String

    /**
     * @brief[zh-cn] 构造双精度输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Float64> 单元素，随输入更新）
     * @param[zh-cn] step 步进值（默认 0.1）
     * @param[zh-cn] stepFast 按住 Shift 时的快进步进（默认 1.0）
     * @param[zh-cn] format 数值显示格式（默认 "%.6f"）
     *
     * @brief[en] Constructs a double-precision input widget
     * @param[en] label Input label text
     * @param[en] value Value buffer (single-element PtrArray<Float64>, updated on input)
     * @param[en] step Step value (default 0.1)
     * @param[en] stepFast Fast step while holding Shift (default 1.0)
     * @param[en] format Number display format (default "%.6f")
     */
    public init(label!: String, value!: PtrArray<Float64>,
                step!: Float64 = 0.1, stepFast!: Float64 = 1.0,
                format!: String = "%.6f") {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染双精度输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the double-precision input box
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputDouble_cj(this._label, this._value.data(), this._step, this._stepFast, this._format, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 输入框当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current input value
     */
    public func getValue(): Float64 { return this._value.get(0) }
}

// =============================================================================
// UiVSliderFloat — 垂直浮点滑块
// =============================================================================

/**
 * @brief[zh-cn] 垂直浮点滑块控件
 *
 * @brief[en] Vertical float slider widget
 */
public class UiVSliderFloat <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Float32>
    private var _size: Vector2
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    /**
     * @brief[zh-cn] 构造垂直浮点滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] value 值缓冲（PtrArray<Float32> 单元素，随拖动更新）
     * @param[zh-cn] size 滑块尺寸（默认 (0,0) 表示自动计算）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 1.0）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     *
     * @brief[en] Constructs a vertical float slider widget
     * @param[en] label Slider label text
     * @param[en] value Value buffer (single-element PtrArray<Float32>, updated on drag)
     * @param[en] size Slider size (default (0,0) means auto-calculated)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 1.0)
     * @param[en] format Number display format (default "%.3f")
     */
    public init(label!: String, value!: PtrArray<Float32>,
                size!: Vector2 = Vector2(0.0, 0.0),
                min!: Float32 = 0.0, max!: Float32 = 1.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._size = size
        this._min = min
        this._max = max
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染垂直滑块并同步值
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the vertical slider and syncs the value
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_VSliderFloat_cj(this._label, ImVec2(Float32(this._size.x), Float32(this._size.y)),
                                      this._value.data(), this._min, this._max, this._format, 0) != 0
    }

    /**
     * @brief[zh-cn] 获取当前值
     * @return[zh-cn] 滑块当前值
     *
     * @brief[en] Gets the current value
     * @return[en] The current slider value
     */
    public func getValue(): Float32 { return this._value.get(0) }
}

// =============================================================================
// UiBeginDisabled / UiEndDisabled — 禁用状态容器
// =============================================================================

/**
 * @brief[zh-cn] 禁用状态容器
 *
 * @brief[en] Disabled state container
 */
public class UiDisabled <: UiWidget {
    private var _disabled: Bool
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造禁用状态容器
     * @param[zh-cn] disabled 是否禁用内部控件（默认 true）
     * @param[zh-cn] content 容器内容闭包
     *
     * @brief[en] Constructs a disabled state container
     * @param[en] disabled Whether to disable the inner widgets (default true)
     * @param[en] content Container content closure
     */
    public init(disabled!: Bool = true, content!: () -> Unit) {
        super()
        this._disabled = disabled
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染容器：内部控件按禁用状态执行
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the container: inner widgets run with the disabled state applied
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_BeginDisabled_cj(if (this._disabled) { 1 } else { 0 })
        this._content()
        ImGui_EndDisabled_cj()
        return false
    }
}

// =============================================================================
// UiClipRect — 剪裁矩形
// =============================================================================

/**
 * @brief[zh-cn] 剪裁矩形容器
 *
 * @brief[en] Clip rectangle container
 */
public class UiClipRect <: UiWidget {
    private var _min: Vector2
    private var _max: Vector2
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造剪裁矩形容器
     * @param[zh-cn] min 剪裁矩形左上角（最小点）
     * @param[zh-cn] max 剪裁矩形右下角（最大点）
     * @param[zh-cn] content 容器内容闭包
     *
     * @brief[en] Constructs a clip rectangle container
     * @param[en] min Clip rectangle top-left (minimum) corner
     * @param[en] max Clip rectangle bottom-right (maximum) corner
     * @param[en] content Container content closure
     */
    public init(min!: Vector2, max!: Vector2,
                content!: () -> Unit) {
        super()
        this._min = min
        this._max = max
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染容器：在剪裁矩形内执行内容
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the container: executes content clipped to the rectangle
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_PushClipRect_cj(ImVec2(Float32(this._min.x), Float32(this._min.y)), ImVec2(Float32(this._max.x), Float32(this._max.y)), 0)
        this._content()
        ImGui_PopClipRect_cj()
        return false
    }
}

// =============================================================================
// UiSetNextItemWidth — 设置下一个控件宽度
// =============================================================================

/**
 * @brief[zh-cn] 设置下一个控件宽度
 *
 * @brief[en] Set next widget width
 */
public class UiSetNextItemWidth <: UiWidget {
    private var _width: Float32

    /**
     * @brief[zh-cn] 构造宽度设置控件
     * @param[zh-cn] width 下一个控件的宽度（负值如 -1 表示自动宽度）
     *
     * @brief[en] Constructs a next-item-width widget
     * @param[en] width Width of the next widget (negative values such as -1 mean auto width)
     */
    public init(width!: Float32) { super(); this._width = width }

    /**
     * @brief[zh-cn] 为下一个控件设置宽度
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Sets the width of the next widget
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_SetNextItemWidth_cj(this._width)
        return false
    }
}

// =============================================================================
// UiSetNextItemOpen — 设置下一个树节点打开状态
// =============================================================================

/**
 * @brief[zh-cn] 设置下一个树节点打开状态
 *
 * @brief[en] Set next tree node open state
 */
public class UiSetNextItemOpen <: UiWidget {
    private var _isOpen: Bool
    private var _cond: Int32

    /**
     * @brief[zh-cn] 构造树节点状态设置控件
     * @param[zh-cn] isOpen 下一个树节点是否打开（默认 true）
     * @param[zh-cn] cond 生效条件（ImGui 条件枚举值，默认 0 表示总是生效）
     *
     * @brief[en] Constructs a next-tree-node-state widget
     * @param[en] isOpen Whether the next tree node is open (default true)
     * @param[en] cond Activation condition (ImGui condition enum value, default 0 means always)
     */
    public init(isOpen!: Bool = true, cond!: Int32 = 0) {
        super()
        this._isOpen = isOpen
        this._cond = cond
    }

    /**
     * @brief[zh-cn] 设置下一个树节点的打开状态
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Sets the open state of the next tree node
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_SetNextItemOpen_cj(if (this._isOpen) { 1 } else { 0 }, this._cond)
        return false
    }
}

// =============================================================================
// UiSeparatorText — 带文本的分隔线
// =============================================================================

/**
 * @brief[zh-cn] 带文本的分隔线控件
 *
 * @brief[en] Separator with text widget
 */
public class UiSeparatorText <: UiWidget {
    private var _label: String

    /**
     * @brief[zh-cn] 构造带文本分隔线控件
     * @param[zh-cn] label 分隔线上显示的文本
     *
     * @brief[en] Constructs a separator-with-text widget
     * @param[en] label Text shown on the separator
     */
    public init(label!: String) { super(); this._label = label }

    /**
     * @brief[zh-cn] 渲染带文本的分隔线
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the separator with text
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_SeparatorText_cj(this._label)
        return false
    }
}

// =============================================================================
// UiPlotLines — 折线图
// =============================================================================

/**
 * @brief[zh-cn] 折线图控件
 *
 * @brief[en] Line plot widget
 */
public class UiPlotLines <: UiWidget {
    private var _label: String
    private var _values: PtrArray<Float32>
    private var _offset: Int32
    private var _overlay: String
    private var _scaleMin: Float32
    private var _scaleMax: Float32
    private var _size: Vector2

    /**
     * @brief[zh-cn] 构造折线图控件
     * @param[zh-cn] label 图表标签文本
     * @param[zh-cn] values 数据点数组（PtrArray<Float32>）
     * @param[zh-cn] offset 绘制数据的起始偏移（默认 0）
     * @param[zh-cn] overlay 叠加显示的文本（默认空字符串表示不显示）
     * @param[zh-cn] scaleMin Y 轴最小值（默认 FLT_MAX 表示自动）
     * @param[zh-cn] scaleMax Y 轴最大值（默认 FLT_MAX 表示自动）
     * @param[zh-cn] size 图表尺寸（默认 (0,0) 表示自动计算）
     *
     * @brief[en] Constructs a line plot widget
     * @param[en] label Chart label text
     * @param[en] values Data points (PtrArray<Float32>)
     * @param[en] offset Start offset into the data (default 0)
     * @param[en] overlay Overlay text (default empty means no overlay)
     * @param[en] scaleMin Y-axis minimum (default FLT_MAX means auto)
     * @param[en] scaleMax Y-axis maximum (default FLT_MAX means auto)
     * @param[en] size Chart size (default (0,0) means auto-calculated)
     */
    public init(label!: String, values!: PtrArray<Float32>,
                offset!: Int32 = 0,
                overlay!: String = "", scaleMin!: Float32 = 3.4028235e38,
                scaleMax!: Float32 = 3.4028235e38,
                size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._label = label
        this._values = values
        this._offset = offset
        this._overlay = overlay
        this._scaleMin = scaleMin
        this._scaleMax = scaleMax
        this._size = size
    }

    /**
     * @brief[zh-cn] 渲染折线图
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the line plot
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_PlotLines_FloatPtr_cj(this._label, this._values.data(), Int32(this._values.size()),
                                     this._offset, this._overlay,
                                     this._scaleMin, this._scaleMax,
                                     ImVec2(Float32(this._size.x), Float32(this._size.y)), 4)
        return false
    }
}

// =============================================================================
// UiPlotHistogram — 柱状图
// =============================================================================

/**
 * @brief[zh-cn] 柱状图控件
 *
 * @brief[en] Histogram plot widget
 */
public class UiPlotHistogram <: UiWidget {
    private var _label: String
    private var _values: PtrArray<Float32>
    private var _offset: Int32
    private var _overlay: String
    private var _scaleMin: Float32
    private var _scaleMax: Float32
    private var _size: Vector2

    /**
     * @brief[zh-cn] 构造柱状图控件
     * @param[zh-cn] label 图表标签文本
     * @param[zh-cn] values 数据点数组（PtrArray<Float32>）
     * @param[zh-cn] offset 绘制数据的起始偏移（默认 0）
     * @param[zh-cn] overlay 叠加显示的文本（默认空字符串表示不显示）
     * @param[zh-cn] scaleMin Y 轴最小值（默认 FLT_MAX 表示自动）
     * @param[zh-cn] scaleMax Y 轴最大值（默认 FLT_MAX 表示自动）
     * @param[zh-cn] size 图表尺寸（默认 (0,0) 表示自动计算）
     *
     * @brief[en] Constructs a histogram plot widget
     * @param[en] label Chart label text
     * @param[en] values Data points (PtrArray<Float32>)
     * @param[en] offset Start offset into the data (default 0)
     * @param[en] overlay Overlay text (default empty means no overlay)
     * @param[en] scaleMin Y-axis minimum (default FLT_MAX means auto)
     * @param[en] scaleMax Y-axis maximum (default FLT_MAX means auto)
     * @param[en] size Chart size (default (0,0) means auto-calculated)
     */
    public init(label!: String, values!: PtrArray<Float32>,
                offset!: Int32 = 0,
                overlay!: String = "", scaleMin!: Float32 = 3.4028235e38,
                scaleMax!: Float32 = 3.4028235e38,
                size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._label = label
        this._values = values
        this._offset = offset
        this._overlay = overlay
        this._scaleMin = scaleMin
        this._scaleMax = scaleMax
        this._size = size
    }

    /**
     * @brief[zh-cn] 渲染柱状图
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the histogram plot
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_PlotHistogram_FloatPtr_cj(this._label, this._values.data(), Int32(this._values.size()),
                                         this._offset, this._overlay,
                                         this._scaleMin, this._scaleMax,
                                         ImVec2(Float32(this._size.x), Float32(this._size.y)), 4)
        return false
    }
}

// =============================================================================
// UiValue — 值显示
// =============================================================================

/**
 * @brief[zh-cn] 值显示控件
 *
 * @brief[en] Value display widget
 */
public class UiValue <: UiWidget {
    private var _prefix: String
    private var _value: Float32
    private var _format: String

    /**
     * @brief[zh-cn] 构造值显示控件
     * @param[zh-cn] prefix 值前缀标签
     * @param[zh-cn] value 要显示的数值
     * @param[zh-cn] format 数值显示格式（默认空字符串表示使用 ImGui 默认格式）
     *
     * @brief[en] Constructs a value display widget
     * @param[en] prefix Value prefix label
     * @param[en] value The number to display
     * @param[en] format Number display format (default empty means ImGui default format)
     */
    public init(prefix!: String, value!: Float32, format!: String = "") {
        super()
        this._prefix = prefix
        this._value = value
        this._format = format
    }

    /**
     * @brief[zh-cn] 渲染值显示
     * @return[zh-cn] 恒为 false（无交互）
     *
     * @brief[en] Renders the value display
     * @return[en] Always false (no interaction)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_Value_Float_cj(this._prefix, this._value, this._format)
        return false
    }

    /**
     * @brief[zh-cn] 设置要显示的值
     * @param[zh-cn] v 要显示的值
     *
     * @brief[en] Sets the value to display
     * @param[en] v The value to display
     */
    public func setValue(v: Float32): Unit { this._value = v }
    /**
     * @brief[zh-cn] 获取当前显示的值
     * @return[zh-cn] 当前显示的值
     *
     * @brief[en] Gets the currently displayed value
     * @return[en] The currently displayed value
     */
    public func getValue(): Float32 { return this._value }
}

// =============================================================================
// UiItemQuery — 控件状态查询
// =============================================================================

/**
 * @brief[zh-cn] 控件状态查询——在 draw() 之后调用，获取交互状态
 *
 * @brief[en] Widget state query — call after draw() to retrieve interaction state
 */
public class UiItemQuery {
    /**
     * @brief[zh-cn] 上一个控件是否悬停
     * @param[zh-cn] flags ImGui 悬停标志（默认 0）
     * @return[zh-cn] 是否悬停
     *
     * @brief[en] Whether the last widget is hovered
     * @param[en] flags ImGui hovered flags (default 0)
     * @return[en] Whether hovered
     */
    public static func isItemHovered(flags!: Int32 = 0): Bool {
        return ImGui_IsItemHovered_cj(flags) != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否激活（被点击/拖动）
     * @return[zh-cn] 是否激活
     *
     * @brief[en] Whether the last widget is active (clicked/dragged)
     * @return[en] Whether active
     */
    public static func isItemActive(): Bool {
        return ImGui_IsItemActive_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否获得焦点
     * @return[zh-cn] 是否获得焦点
     *
     * @brief[en] Whether the last widget is focused
     * @return[en] Whether focused
     */
    public static func isItemFocused(): Bool {
        return ImGui_IsItemFocused_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否被点击
     * @param[zh-cn] mouseButton 鼠标按钮（0=左 1=右 2=中，默认 0）
     * @return[zh-cn] 是否被点击
     *
     * @brief[en] Whether the last widget was clicked
     * @param[en] mouseButton Mouse button (0=left, 1=right, 2=middle, default 0)
     * @return[en] Whether clicked
     */
    public static func isItemClicked(mouseButton!: Int32 = 0): Bool {
        return ImGui_IsItemClicked_cj(mouseButton) != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否可见
     * @return[zh-cn] 是否可见
     *
     * @brief[en] Whether the last widget is visible
     * @return[en] Whether visible
     */
    public static func isItemVisible(): Bool {
        return ImGui_IsItemVisible_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否被编辑
     * @return[zh-cn] 是否被编辑
     *
     * @brief[en] Whether the last widget was edited
     * @return[en] Whether edited
     */
    public static func isItemEdited(): Bool {
        return ImGui_IsItemEdited_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否被激活
     * @return[zh-cn] 是否被激活
     *
     * @brief[en] Whether the last widget was activated
     * @return[en] Whether activated
     */
    public static func isItemActivated(): Bool {
        return ImGui_IsItemActivated_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否被停用
     * @return[zh-cn] 是否被停用
     *
     * @brief[en] Whether the last widget was deactivated
     * @return[en] Whether deactivated
     */
    public static func isItemDeactivated(): Bool {
        return ImGui_IsItemDeactivated_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否在编辑后被停用
     * @return[zh-cn] 是否在编辑后被停用
     *
     * @brief[en] Whether the last widget was deactivated after edit
     * @return[en] Whether deactivated after edit
     */
    public static func isItemDeactivatedAfterEdit(): Bool {
        return ImGui_IsItemDeactivatedAfterEdit_cj() != 0
    }

    /**
     * @brief[zh-cn] 上一个控件是否被切换展开/折叠
     * @return[zh-cn] 是否被切换展开/折叠
     *
     * @brief[en] Whether the last widget was toggled open/closed
     * @return[en] Whether toggled open
     */
    public static func isItemToggledOpen(): Bool {
        return ImGui_IsItemToggledOpen_cj() != 0
    }

    /**
     * @brief[zh-cn] 任一控件是否悬停
     * @return[zh-cn] 是否有任一控件悬停
     *
     * @brief[en] Whether any widget is hovered
     * @return[en] Whether any widget is hovered
     */
    public static func isAnyItemHovered(): Bool {
        return ImGui_IsAnyItemHovered_cj() != 0
    }

    /**
     * @brief[zh-cn] 任一控件是否激活
     * @return[zh-cn] 是否有任一控件激活
     *
     * @brief[en] Whether any widget is active
     * @return[en] Whether any widget is active
     */
    public static func isAnyItemActive(): Bool {
        return ImGui_IsAnyItemActive_cj() != 0
    }

    /**
     * @brief[zh-cn] 任一控件是否获得焦点
     * @return[zh-cn] 是否有任一控件获得焦点
     *
     * @brief[en] Whether any widget is focused
     * @return[en] Whether any widget is focused
     */
    public static func isAnyItemFocused(): Bool {
        return ImGui_IsAnyItemFocused_cj() != 0
    }

    /**
     * @brief[zh-cn] 获取上一个控件的 ID
     * @return[zh-cn] 控件 ID
     *
     * @brief[en] Returns the ID of the last widget
     * @return[en] Widget ID
     */
    public static func getItemID(): UInt32 {
        return ImGui_GetItemID_cj()
    }

    /**
     * @brief[zh-cn] 获取上一个控件的矩形最小点
     * @return[zh-cn] 矩形最小点
     *
     * @brief[en] Returns the rect minimum of the last widget
     * @return[en] Rect minimum
     */
    public static func getItemRectMin(): Vector2 {
        let v = ImGui_GetItemRectMin_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 获取上一个控件的矩形最大点
     * @return[zh-cn] 矩形最大点
     *
     * @brief[en] Returns the rect maximum of the last widget
     * @return[en] Rect maximum
     */
    public static func getItemRectMax(): Vector2 {
        let v = ImGui_GetItemRectMax_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 获取上一个控件的尺寸
     * @return[zh-cn] 控件尺寸
     *
     * @brief[en] Returns the size of the last widget
     * @return[en] Widget size
     */
    public static func getItemRectSize(): Vector2 {
        let v = ImGui_GetItemRectSize_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 设置默认焦点到上一个控件
     *
     * @brief[en] Sets default focus to the last widget
     */
    public static func setItemDefaultFocus(): Unit {
        ImGui_SetItemDefaultFocus_cj()
    }

    /**
     * @brief[zh-cn] 设置下一个控件允许重叠
     *
     * @brief[en] Sets the next widget to allow overlap
     */
    public static func setNextItemAllowOverlap(): Unit {
        ImGui_SetNextItemAllowOverlap_cj()
    }

    // ===== ID 栈 =====

    /**
     * @brief[zh-cn] 压入字符串 ID
     * @param[zh-cn] strID 要压入的字符串 ID
     *
     * @brief[en] Pushes a string ID
     * @param[en] strID The string ID to push
     */
    public static func pushID(strID: String): Unit {
        unsafe { let cs = LibC.mallocCString(strID); igPushID_Str_cj(cs); LibC.free(cs) }
    }
    /**
     * @brief[zh-cn] 压入整数 ID
     * @param[zh-cn] intID 要压入的整数 ID
     *
     * @brief[en] Pushes an integer ID
     * @param[en] intID The integer ID to push
     */
    public static func pushIDInt(intID: Int32): Unit { igPushID_Int_cj(intID) }
    /**
     * @brief[zh-cn] 弹出 ID
     *
     * @brief[en] Pops the ID
     */
    public static func popID(): Unit { igPopID_cj() }

    // ===== 焦点 =====

    /**
     * @brief[zh-cn] 将键盘焦点设置到下一个控件
     * @param[zh-cn] offset 偏移量（0=下一个，-1=上一个）
     *
     * @brief[en] Sets keyboard focus to the next widget
     * @param[en] offset Offset (0=next, -1=previous)
     */
    public static func setKeyboardFocusHere(offset!: Int32 = 0): Unit { igSetKeyboardFocusHere_cj(offset) }
}

// =============================================================================
// UiArrowButton — 箭头按钮
// Arrow Button
// =============================================================================

/**
 * @brief[zh-cn] 箭头按钮控件（▲▼◀▶）
 *
 * @brief[en] Arrow button widget (▲▼◀▶)
 */
public class UiArrowButton <: UiWidget {
    private var _id: String
    private var _dir: Int32
    /**
     * @brief[zh-cn] 构造箭头按钮控件
     * @param[zh-cn] id 按钮 ID（ImGui ID 命名用）
     * @param[zh-cn] dir 箭头方向（ImGuiDir 枚举值：0=左 1=右 2=上 3=下）
     *
     * @brief[en] Constructs an arrow button widget
     * @param[en] id Button ID (used for ImGui ID naming)
     * @param[en] dir Arrow direction (ImGuiDir enum: 0=left, 1=right, 2=up, 3=down)
     */
    public init(id: String, dir: Int32) { super(); this._id = id; this._dir = dir }
    /**
     * @brief[zh-cn] 渲染箭头按钮
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the arrow button
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._id) }
        let r = igArrowButton_cj(cs, this._dir)
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

// =============================================================================
// UiBeginCombo / UiEndCombo — 自定义组合框
// Custom Combo Box
// =============================================================================

/**
 * @brief[zh-cn] 自定义组合框开始控件（配合 UiEndCombo 使用）
 *
 * @brief[en] Custom combo box begin widget (used with UiEndCombo)
 */
public class UiBeginCombo <: UiWidget {
    private var _label: String
    private var _preview: String
    private var _flags: Int32
    /**
     * @brief[zh-cn] 构造组合框开始控件
     * @param[zh-cn] label 组合框标签文本
     * @param[zh-cn] previewValue 收起时显示的预览文本
     * @param[zh-cn] flags ImGui 组合框标志（默认 0）
     *
     * @brief[en] Constructs a combo begin widget
     * @param[en] label Combo label text
     * @param[en] previewValue Preview text shown when collapsed
     * @param[en] flags ImGui combo flags (default 0)
     */
    public init(label: String, previewValue: String, flags!: Int32 = 0) { super(); this._label = label; this._preview = previewValue; this._flags = flags }
    /**
     * @brief[zh-cn] 开始组合框弹出层
     * @return[zh-cn] 弹出层本帧是否打开（打开时需在其中绘制选项并调用 UiEndCombo）
     *
     * @brief[en] Begins the combo popup
     * @return[en] Whether the popup is open this frame (if open, draw options inside and call UiEndCombo)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }
        let csP = unsafe { LibC.mallocCString(this._preview) }
        let r = igBeginCombo_cj(csL, csP, this._flags)
        unsafe { LibC.free(csL); LibC.free(csP) }
        return r != 0
    }
}

/**
 * @brief[zh-cn] 自定义组合框结束控件（配合 UiBeginCombo 使用）
 *
 * @brief[en] Custom combo box end widget (used with UiBeginCombo)
 */
public class UiEndCombo <: UiWidget {
    /**
     * @brief[zh-cn] 构造组合框结束控件
     *
     * @brief[en] Constructs a combo end widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 结束组合框弹出层
     * @return[zh-cn] 恒为 true（始终表示本帧有操作）
     *
     * @brief[en] Ends the combo popup
     * @return[en] Always true (always reports an action this frame)
     */
    public override func draw(): Bool { ensureCurrentContext(); igEndCombo_cj(); return true }
}

// =============================================================================
// UiBeginListBox / UiEndListBox — 自定义列表框
// Custom List Box
// =============================================================================

/**
 * @brief[zh-cn] 自定义列表框开始控件（配合 UiEndListBox 使用）
 *
 * @brief[en] Custom list box begin widget (used with UiEndListBox)
 */
public class UiBeginListBox <: UiWidget {
    private var _label: String
    private var _w: Float32
    private var _h: Float32
    /**
     * @brief[zh-cn] 构造列表框开始控件
     * @param[zh-cn] label 列表框标签文本
     * @param[zh-cn] w 列表框宽度（默认 0.0 表示自动）
     * @param[zh-cn] h 列表框高度（默认 0.0 表示自动）
     *
     * @brief[en] Constructs a list box begin widget
     * @param[en] label List box label text
     * @param[en] w List box width (default 0.0 means auto)
     * @param[en] h List box height (default 0.0 means auto)
     */
    public init(label: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32) { super(); this._label = label; this._w = w; this._h = h }
    /**
     * @brief[zh-cn] 开始列表框
     * @return[zh-cn] 本帧是否可绘制（需在其中绘制选项并调用 UiEndListBox）
     *
     * @brief[en] Begins the list box
     * @return[en] Whether drawing is allowed this frame (draw options inside and call UiEndListBox)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igBeginListBox_cj(cs, ImVec2(this._w, this._h))
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

/**
 * @brief[zh-cn] 自定义列表框结束控件（配合 UiBeginListBox 使用）
 *
 * @brief[en] Custom list box end widget (used with UiBeginListBox)
 */
public class UiEndListBox <: UiWidget {
    /**
     * @brief[zh-cn] 构造列表框结束控件
     *
     * @brief[en] Constructs a list box end widget
     */
    public init() { super() }
    /**
     * @brief[zh-cn] 结束列表框
     * @return[zh-cn] 恒为 true（始终表示本帧有操作）
     *
     * @brief[en] Ends the list box
     * @return[en] Always true (always reports an action this frame)
     */
    public override func draw(): Bool { ensureCurrentContext(); igEndListBox_cj(); return true }
}

// =============================================================================
// UiColorButton — 颜色按钮
// Color Button
// =============================================================================

/**
 * @brief[zh-cn] 颜色按钮控件（显示色块，可点击）
 *
 * @brief[en] Color button widget (shows a color swatch, clickable)
 */
public class UiColorButton <: UiWidget {
    private var _desc: String
    private var _col: ImVec4
    private var _flags: Int32
    private var _w: Float32
    private var _h: Float32
    /**
     * @brief[zh-cn] 构造颜色按钮控件
     * @param[zh-cn] desc 按钮描述文本（ID 命名用）
     * @param[zh-cn] r 红色分量（0.0~1.0）
     * @param[zh-cn] g 绿色分量（0.0~1.0）
     * @param[zh-cn] b 蓝色分量（0.0~1.0）
     * @param[zh-cn] a 透明度分量（默认 1.0）
     * @param[zh-cn] flags ImGui 颜色按钮标志（默认 0）
     * @param[zh-cn] w 按钮宽度（默认 0.0 表示自动）
     * @param[zh-cn] h 按钮高度（默认 0.0 表示自动）
     *
     * @brief[en] Constructs a color button widget
     * @param[en] desc Button description text (used for ID naming)
     * @param[en] r Red component (0.0~1.0)
     * @param[en] g Green component (0.0~1.0)
     * @param[en] b Blue component (0.0~1.0)
     * @param[en] a Alpha component (default 1.0)
     * @param[en] flags ImGui color button flags (default 0)
     * @param[en] w Button width (default 0.0 means auto)
     * @param[en] h Button height (default 0.0 means auto)
     */
    public init(desc: String, r: Float32, g: Float32, b: Float32, a!: Float32 = 1.0f32, flags!: Int32 = 0, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32) {
        super(); this._desc = desc; this._col = ImVec4(r, g, b, a); this._flags = flags; this._w = w; this._h = h
    }
    /**
     * @brief[zh-cn] 渲染颜色按钮
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the color button
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._desc) }
        let r = igColorButton_cj(cs, this._col, this._flags, ImVec2(this._w, this._h))
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

// =============================================================================
// UiColorEdit3 — 三通道颜色编辑
// 3-Channel Color Editor
// =============================================================================

/**
 * @brief[zh-cn] 三通道颜色编辑器控件（RGB）
 *
 * @brief[en] 3-channel color editor widget (RGB)
 */
public class UiColorEdit3 <: UiWidget {
    private var _label: String
    private var _col: PtrArray<Float32>
    private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道颜色编辑器控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] col 颜色缓冲（PtrArray<Float32>，3 个分量 RGB，0.0~1.0）
     * @param[zh-cn] flags ImGui 颜色编辑标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel color editor widget
     * @param[en] label Label text
     * @param[en] col Color buffer (PtrArray<Float32> of 3 RGB components, 0.0~1.0)
     * @param[en] flags ImGui color edit flags (default 0)
     */
    public init(label: String, col: PtrArray<Float32>, flags!: Int32 = 0) { super(); this._label = label; this._col = col; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染三通道颜色编辑器
     * @return[zh-cn] 本次颜色是否发生变化
     *
     * @brief[en] Renders the 3-channel color editor
     * @return[en] Whether the color changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igColorEdit3_cj(cs, this._col.data(), this._flags)
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

// =============================================================================
// UiDragFloat2 / UiDragFloat3 / UiDragFloat4
// Multi-Channel Float Drag
// =============================================================================

/**
 * @brief[zh-cn] 双通道浮点拖拽控件
 *
 * @brief[en] 2-channel float drag widget
 */
public class UiDragFloat2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道浮点拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，2 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 0.0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel float drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Float32> of 2 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 0.0 means unbounded)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染双通道浮点拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel float drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat2_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道浮点拖拽控件
 *
 * @brief[en] 3-channel float drag widget
 */
public class UiDragFloat3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道浮点拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，3 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 0.0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel float drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Float32> of 3 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 0.0 means unbounded)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染三通道浮点拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel float drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat3_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道浮点拖拽控件
 *
 * @brief[en] 4-channel float drag widget
 */
public class UiDragFloat4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道浮点拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，4 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0.0）
     * @param[zh-cn] max 最大值（默认 0.0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel float drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Float32> of 4 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0.0)
     * @param[en] max Maximum value (default 0.0 means unbounded)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染四通道浮点拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel float drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat4_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 双通道整数拖拽控件
 *
 * @brief[en] 2-channel integer drag widget
 */
public class UiDragInt2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道整数拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，2 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0）
     * @param[zh-cn] max 最大值（默认 0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel integer drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Int32> of 2 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0)
     * @param[en] max Maximum value (default 0 means unbounded)
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染双通道整数拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel integer drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt2_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道整数拖拽控件
 *
 * @brief[en] 3-channel integer drag widget
 */
public class UiDragInt3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道整数拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，3 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0）
     * @param[zh-cn] max 最大值（默认 0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel integer drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Int32> of 3 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0)
     * @param[en] max Maximum value (default 0 means unbounded)
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染三通道整数拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel integer drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt3_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道整数拖拽控件
 *
 * @brief[en] 4-channel integer drag widget
 */
public class UiDragInt4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道整数拖拽控件
     * @param[zh-cn] label 标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，4 个分量）
     * @param[zh-cn] speed 拖拽速度（默认 1.0）
     * @param[zh-cn] min 最小值（默认 0）
     * @param[zh-cn] max 最大值（默认 0 表示不限制）
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 拖拽标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel integer drag widget
     * @param[en] label Label text
     * @param[en] v Value buffer (PtrArray<Int32> of 4 components)
     * @param[en] speed Drag speed (default 1.0)
     * @param[en] min Minimum value (default 0)
     * @param[en] max Maximum value (default 0 means unbounded)
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui drag flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染四通道整数拖拽控件
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel integer drag widget
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt4_cj(csL, this._v.data(), this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

// =============================================================================
// UiSliderFloat2 / UiSliderFloat3 / UiSliderFloat4 / UiSliderAngle
// Multi-Channel Float Slider / Angle Slider
// =============================================================================

/**
 * @brief[zh-cn] 双通道浮点滑块控件
 *
 * @brief[en] 2-channel float slider widget
 */
public class UiSliderFloat2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道浮点滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，2 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel float slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Float32> of 2 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染双通道浮点滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel float slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat2_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道浮点滑块控件
 *
 * @brief[en] 3-channel float slider widget
 */
public class UiSliderFloat3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道浮点滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，3 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel float slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Float32> of 3 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染三通道浮点滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel float slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat3_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道浮点滑块控件
 *
 * @brief[en] 4-channel float slider widget
 */
public class UiSliderFloat4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道浮点滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，4 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel float slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Float32> of 4 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染四通道浮点滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel float slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat4_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 角度滑块控件（以弧度值显示，范围以度为单位）
 *
 * @brief[en] Angle slider widget (stores radians, range specified in degrees)
 */
public class UiSliderAngle <: UiWidget {
    private var _label: String; private var _vRad: PtrArray<Float32>; private var _minDeg: Float32; private var _maxDeg: Float32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造角度滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] vRad 角度值缓冲（弧度，PtrArray<Float32> 单元素）
     * @param[zh-cn] minDeg 最小角度（度，默认 -360.0）
     * @param[zh-cn] maxDeg 最大角度（度，默认 360.0）
     * @param[zh-cn] format 角度显示格式（默认 "%.0f deg"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs an angle slider widget
     * @param[en] label Slider label text
     * @param[en] vRad Angle value buffer in radians (single-element PtrArray<Float32>)
     * @param[en] minDeg Minimum angle in degrees (default -360.0)
     * @param[en] maxDeg Maximum angle in degrees (default 360.0)
     * @param[en] format Angle display format (default "%.0f deg")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, vRad: PtrArray<Float32>, minDeg!: Float32 = -360.0f32, maxDeg!: Float32 = 360.0f32, format!: String = "%.0f deg", flags!: Int32 = 0) {
        super(); this._label = label; this._vRad = vRad; this._minDeg = minDeg; this._maxDeg = maxDeg; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染角度滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the angle slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderAngle_cj(csL, this._vRad.data(), this._minDeg, this._maxDeg, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 双通道整数滑块控件
 *
 * @brief[en] 2-channel integer slider widget
 */
public class UiSliderInt2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道整数滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，2 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel integer slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Int32> of 2 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染双通道整数滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel integer slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt2_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道整数滑块控件
 *
 * @brief[en] 3-channel integer slider widget
 */
public class UiSliderInt3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道整数滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，3 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel integer slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Int32> of 3 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染三通道整数滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel integer slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt3_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道整数滑块控件
 *
 * @brief[en] 4-channel integer slider widget
 */
public class UiSliderInt4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道整数滑块控件
     * @param[zh-cn] label 滑块标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，4 个分量）
     * @param[zh-cn] min 最小值
     * @param[zh-cn] max 最大值
     * @param[zh-cn] format 数值显示格式（默认 "%d"）
     * @param[zh-cn] flags ImGui 滑块标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel integer slider widget
     * @param[en] label Slider label text
     * @param[en] v Value buffer (PtrArray<Int32> of 4 components)
     * @param[en] min Minimum value
     * @param[en] max Maximum value
     * @param[en] format Number display format (default "%d")
     * @param[en] flags ImGui slider flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    /**
     * @brief[zh-cn] 渲染四通道整数滑块
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel integer slider
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt4_cj(csL, this._v.data(), this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

// =============================================================================
// UiInputFloat2 / UiInputFloat3 / UiInputFloat4
// Multi-Channel Float Input
// =============================================================================

/**
 * @brief[zh-cn] 双通道浮点输入框控件
 *
 * @brief[en] 2-channel float input widget
 */
public class UiInputFloat2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道浮点输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，2 个分量）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel float input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Float32> of 2 components)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染双通道浮点输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel float input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat2_cj(csL, this._v.data(), csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道浮点输入框控件
 *
 * @brief[en] 3-channel float input widget
 */
public class UiInputFloat3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道浮点输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，3 个分量）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel float input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Float32> of 3 components)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染三通道浮点输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel float input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat3_cj(csL, this._v.data(), csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道浮点输入框控件
 *
 * @brief[en] 4-channel float input widget
 */
public class UiInputFloat4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Float32>; private var _fmt: String; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道浮点输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Float32>，4 个分量）
     * @param[zh-cn] format 数值显示格式（默认 "%.3f"）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel float input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Float32> of 4 components)
     * @param[en] format Number display format (default "%.3f")
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染四通道浮点输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel float input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat4_cj(csL, this._v.data(), csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 双通道整数输入框控件
 *
 * @brief[en] 2-channel integer input widget
 */
public class UiInputInt2 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造双通道整数输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，2 个分量）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 2-channel integer input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Int32> of 2 components)
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染双通道整数输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 2-channel integer input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt2_cj(cs, this._v.data(), this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道整数输入框控件
 *
 * @brief[en] 3-channel integer input widget
 */
public class UiInputInt3 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道整数输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，3 个分量）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel integer input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Int32> of 3 components)
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染三通道整数输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 3-channel integer input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt3_cj(cs, this._v.data(), this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 四通道整数输入框控件
 *
 * @brief[en] 4-channel integer input widget
 */
public class UiInputInt4 <: UiWidget {
    private var _label: String; private var _v: PtrArray<Int32>; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造四通道整数输入框控件
     * @param[zh-cn] label 输入框标签文本
     * @param[zh-cn] v 值缓冲（PtrArray<Int32>，4 个分量）
     * @param[zh-cn] flags ImGui 输入框标志（默认 0）
     *
     * @brief[en] Constructs a 4-channel integer input widget
     * @param[en] label Input label text
     * @param[en] v Value buffer (PtrArray<Int32> of 4 components)
     * @param[en] flags ImGui input flags (default 0)
     */
    public init(label: String, v: PtrArray<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染四通道整数输入框
     * @return[zh-cn] 本次值是否发生变化
     *
     * @brief[en] Renders the 4-channel integer input
     * @return[en] Whether the value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt4_cj(cs, this._v.data(), this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

/**
 * @brief[zh-cn] 三通道颜色选择器控件
 *
 * @brief[en] 3-channel color picker widget
 */
public class UiColorPicker3 <: UiWidget {
    private var _label: String; private var _col: PtrArray<Float32>; private var _flags: Int32
    /**
     * @brief[zh-cn] 构造三通道颜色选择器控件
     * @param[zh-cn] label 选择器标签文本
     * @param[zh-cn] col 颜色值缓冲（PtrArray<Float32>，RGB 3 个分量，取值范围 0.0~1.0）
     * @param[zh-cn] flags ImGui 颜色选择器标志（默认 0）
     *
     * @brief[en] Constructs a 3-channel color picker widget
     * @param[en] label Picker label text
     * @param[en] col Color value buffer (PtrArray<Float32> of RGB 3 components, range 0.0~1.0)
     * @param[en] flags ImGui color picker flags (default 0)
     */
    public init(label!: String, col!: PtrArray<Float32>, flags!: Int32 = 0) { super(); this._label = label; this._col = col; this._flags = flags }
    /**
     * @brief[zh-cn] 渲染三通道颜色选择器
     * @return[zh-cn] 本次颜色值是否发生变化
     *
     * @brief[en] Renders the 3-channel color picker
     * @return[en] Whether the color value changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igColorPicker3_cj(cs, this._col.data(), this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

// =============================================================================
// UiTextLink — 可点击链接文本
// Clickable Link Text
// =============================================================================

/**
 * @brief[zh-cn] 可点击链接文本控件
 *
 * @brief[en] Clickable link text widget
 */
public class UiTextLink <: UiWidget {
    private var _label: String
    /**
     * @brief[zh-cn] 构造可点击链接文本控件
     * @param[zh-cn] label 链接文本
     *
     * @brief[en] Constructs a clickable link text widget
     * @param[en] label Link text
     */
    public init(label!: String) { super(); this._label = label }
    /**
     * @brief[zh-cn] 渲染链接文本
     * @return[zh-cn] 链接本次是否被点击
     *
     * @brief[en] Renders the link text
     * @return[en] Whether the link was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = ImGui_TextLink_cj(cs)
        unsafe { LibC.free(cs) }; return r != 0
    }
    /**
     * @brief[zh-cn] 打开链接对应的 URL（调用系统默认浏览器）
     *
     * @brief[en] Opens the URL associated with the link (via the system default browser)
     */
    public func openURL(): Unit {
        let cs = unsafe { LibC.mallocCString(this._label) }
        igTextLinkOpenURL_cj(cs, cs)
        unsafe { LibC.free(cs) }
    }
}

/**
 * @brief[zh-cn] 圆点文本控件（BulletText）
 *
 * @brief[en] Bullet text widget (BulletText)
 */
public class UiTextBullet <: UiWidget {
    private var _text: String
    /**
     * @brief[zh-cn] 构造圆点文本控件
     * @param[zh-cn] text 文本内容
     *
     * @brief[en] Constructs a bullet text widget
     * @param[en] text Text content
     */
    public init(text!: String) { super(); this._text = text }
    /**
     * @brief[zh-cn] 渲染圆点文本
     * @return[zh-cn] 恒为 false（该控件不返回交互状态）
     *
     * @brief[en] Renders the bullet text
     * @return[en] Always false (this widget has no interaction state)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._text) }
        igBulletText0_cj(cs)
        unsafe { LibC.free(cs) }; return false
    }
}

/**
 * @brief[zh-cn] 标签+值文本控件（LabelText）
 *
 * @brief[en] Label plus value text widget (LabelText)
 */
public class UiLabelText <: UiWidget {
    private var _label: String; private var _text: String
    /**
     * @brief[zh-cn] 构造标签+值文本控件
     * @param[zh-cn] label 左侧标签文本
     * @param[zh-cn] text 右侧值文本
     *
     * @brief[en] Constructs a label plus value text widget
     * @param[en] label Label text on the left
     * @param[en] text Value text on the right
     */
    public init(label!: String, text!: String) { super(); this._label = label; this._text = text }
    /**
     * @brief[zh-cn] 渲染标签与值文本
     * @return[zh-cn] 恒为 false（该控件不返回交互状态）
     *
     * @brief[en] Renders the label and value text
     * @return[en] Always false (this widget has no interaction state)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }
        let csT = unsafe { LibC.mallocCString(this._text) }
        igLabelText0_cj(csL, csT)
        unsafe { LibC.free(csL); LibC.free(csT) }; return false
    }
}

/**
 * @brief[zh-cn] 布尔值显示控件（Value）
 *
 * @brief[en] Boolean value display widget (Value)
 */
public class UiValueBool <: UiWidget {
    private var _prefix: String; private var _v: Bool
    /**
     * @brief[zh-cn] 构造布尔值显示控件
     * @param[zh-cn] prefix 显示前缀文本
     * @param[zh-cn] v 布尔值
     *
     * @brief[en] Constructs a boolean value display widget
     * @param[en] prefix Display prefix text
     * @param[en] v Boolean value
     */
    public init(prefix!: String, v!: Bool) { super(); this._prefix = prefix; this._v = v }
    /**
     * @brief[zh-cn] 渲染布尔值显示
     * @return[zh-cn] 恒为 false（该控件不返回交互状态）
     *
     * @brief[en] Renders the boolean value display
     * @return[en] Always false (this widget has no interaction state)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._prefix) }
        igValue_Bool_cj(cs, if (this._v) { 1 } else { 0 })
        unsafe { LibC.free(cs) }; return false
    }
}

/**
 * @brief[zh-cn] 整数值显示控件（Value）
 *
 * @brief[en] Integer value display widget (Value)
 */
public class UiValueInt <: UiWidget {
    private var _prefix: String; private var _v: Int32
    /**
     * @brief[zh-cn] 构造整数值显示控件
     * @param[zh-cn] prefix 显示前缀文本
     * @param[zh-cn] v 整数值
     *
     * @brief[en] Constructs an integer value display widget
     * @param[en] prefix Display prefix text
     * @param[en] v Integer value
     */
    public init(prefix!: String, v!: Int32) { super(); this._prefix = prefix; this._v = v }
    /**
     * @brief[zh-cn] 渲染整数值显示
     * @return[zh-cn] 恒为 false（该控件不返回交互状态）
     *
     * @brief[en] Renders the integer value display
     * @return[en] Always false (this widget has no interaction state)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._prefix) }
        igValue_Int_cj(cs, this._v)
        unsafe { LibC.free(cs) }; return false
    }
}

/**
 * @brief[zh-cn] 无符号整数值显示控件（Value）
 *
 * @brief[en] Unsigned integer value display widget (Value)
 */
public class UiValueUint <: UiWidget {
    private var _prefix: String; private var _v: UInt32
    /**
     * @brief[zh-cn] 构造无符号整数值显示控件
     * @param[zh-cn] prefix 显示前缀文本
     * @param[zh-cn] v 无符号整数值
     *
     * @brief[en] Constructs an unsigned integer value display widget
     * @param[en] prefix Display prefix text
     * @param[en] v Unsigned integer value
     */
    public init(prefix!: String, v!: UInt32) { super(); this._prefix = prefix; this._v = v }
    /**
     * @brief[zh-cn] 渲染无符号整数值显示
     * @return[zh-cn] 恒为 false（该控件不返回交互状态）
     *
     * @brief[en] Renders the unsigned integer value display
     * @return[en] Always false (this widget has no interaction state)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._prefix) }
        igValue_Uint_cj(cs, this._v)
        unsafe { LibC.free(cs) }; return false
    }
}

// =============================================================================
// UiListClipper — 虚拟列表裁剪器（高性能大列表）
// Virtual List Clipper (high-performance large lists)
// =============================================================================

/**
 * @brief[zh-cn] 虚拟列表裁剪器，用于高性能渲染大型列表（仅绘制可见项）
 *
 * @brief[en] Virtual list clipper for high-performance large lists (draws only visible items)
 */
public class UiListClipper {
    private var _clipper: CPointer<Unit> = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造虚拟列表裁剪器
     *
     * @brief[en] Constructs a virtual list clipper
     */
    public init() {
        this._clipper = ImGuiListClipper_ImGuiListClipper_cj()
    }

    /**
     * @brief[zh-cn] 销毁裁剪器并释放底层资源
     *
     * @brief[en] Destroys the clipper and releases underlying resources
     */
    public func destroy(): Unit {
        if (!this._clipper.isNull()) {
            ImGuiListClipper_destroy_cj(this._clipper)
            this._clipper = CPointer<Unit>()
        }
    }

    /**
     * @brief[zh-cn] 开始裁剪
     * @param[zh-cn] itemsCount 总项目数
     * @param[zh-cn] itemsHeight 每项高度（-1.0=自动）
     *
     * @brief[en] Begins clipping
     * @param[en] itemsCount Total item count
     * @param[en] itemsHeight Height per item (-1.0 = auto)
     */
    public func begin(itemsCount: Int32, itemsHeight!: Float32 = -1.0f32): Unit {
        if (!this._clipper.isNull()) {
            ImGuiListClipper_Begin_cj(this._clipper, itemsCount, itemsHeight)
        }
    }

    /**
     * @brief[zh-cn] 步进到下一批可见项
     * @return[zh-cn] 是否还有可见项
     *
     * @brief[en] Steps to the next batch of visible items
     * @return[en] Whether there are more visible items
     */
    public func step(): Bool {
        if (this._clipper.isNull()) { return false }
        return ImGuiListClipper_Step_cj(this._clipper) != 0
    }

    /**
     * @brief[zh-cn] 结束裁剪
     *
     * @brief[en] Ends clipping
     */
    public func end(): Unit {
        if (!this._clipper.isNull()) { ImGuiListClipper_End_cj(this._clipper) }
    }

    /**
     * @brief[zh-cn] 获取当前批次起始索引
     * @return[zh-cn] 当前批次起始索引
     *
     * @brief[en] Gets the current batch start index
     * @return[en] The current batch start index
     */
    public func getDisplayStart(): Int32 {
        if (this._clipper.isNull()) { return 0 }
        return unsafe { CPointer<Int32>(CPointer<UInt8>(this._clipper) + 24).read() }
    }

    /**
     * @brief[zh-cn] 获取当前批次结束索引
     * @return[zh-cn] 当前批次结束索引
     *
     * @brief[en] Gets the current batch end index
     * @return[en] The current batch end index
     */
    public func getDisplayEnd(): Int32 {
        if (this._clipper.isNull()) { return 0 }
        return unsafe { CPointer<Int32>(CPointer<UInt8>(this._clipper) + 28).read() }
    }
}

// =============================================================================
// UiTextFilter — 文本过滤器
// Text Filter
// =============================================================================

/**
 * @brief[zh-cn] 文本过滤器，支持按过滤条件筛选文本列表
 *
 * @brief[en] Text filter supporting filtering of text lists by conditions
 */
public class UiTextFilter {
    private var _filter: CPointer<Unit> = CPointer<Unit>()

    /**
     * @brief[zh-cn] 构造文本过滤器
     * @param[zh-cn] defaultFilter 默认过滤条件文本（默认空字符串）
     *
     * @brief[en] Constructs a text filter
     * @param[en] defaultFilter Default filter condition text (default empty string)
     */
    public init(defaultFilter!: String = "") {
        let cs = unsafe { LibC.mallocCString(defaultFilter) }
        this._filter = ImGuiTextFilter_ImGuiTextFilter_cj(cs)
        unsafe { LibC.free(cs) }
    }

    /**
     * @brief[zh-cn] 销毁过滤器并释放底层资源
     *
     * @brief[en] Destroys the filter and releases underlying resources
     */
    public func destroy(): Unit {
        if (!this._filter.isNull()) {
            ImGuiTextFilter_destroy_cj(this._filter)
            this._filter = CPointer<Unit>()
        }
    }

    /**
     * @brief[zh-cn] 绘制过滤器输入框
     * @param[zh-cn] label 输入框标签文本（默认 "Filter"）
     * @return[zh-cn] 过滤条件本次是否发生变化
     *
     * @brief[en] Draws the filter input box
     * @param[en] label Input label text (default "Filter")
     * @return[en] Whether the filter condition changed this frame
     */
    public func draw(label!: String = "Filter"): Bool {
        if (this._filter.isNull()) { return false }
        let cs = unsafe { LibC.mallocCString(label) }
        let r = ImGuiTextFilter_Draw_cj(this._filter, cs, -1.0f32)
        unsafe { LibC.free(cs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 测试文本是否通过过滤
     * @param[zh-cn] text 待测试的文本
     * @return[zh-cn] 文本是否通过过滤条件
     *
     * @brief[en] Tests whether text passes the filter
     * @param[en] text Text to test
     * @return[en] Whether the text passes the filter condition
     */
    public func passFilter(text: String): Bool {
        if (this._filter.isNull()) { return true }
        let cs = unsafe { LibC.mallocCString(text) }
        let r = ImGuiTextFilter_PassFilter_cj(this._filter, cs, CString(CPointer<UInt8>()))
        unsafe { LibC.free(cs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 是否激活（有过滤条件）
     * @return[zh-cn] 当前是否存在有效过滤条件
     *
     * @brief[en] Whether active (has a filter condition)
     * @return[en] Whether there is currently an active filter condition
     */
    public func isActive(): Bool {
        if (this._filter.isNull()) { return false }
        return ImGuiTextFilter_IsActive_cj(this._filter) != 0
    }

    /**
     * @brief[zh-cn] 清除过滤条件
     *
     * @brief[en] Clears the filter condition
     */
    public func clear(): Unit {
        if (!this._filter.isNull()) { ImGuiTextFilter_Clear_cj(this._filter) }
    }
}

// =============================================================================
// UiKeyboard / UiMouse — 键盘鼠标查询（静态工具类）
// Keyboard / Mouse Queries (static utility classes)
// =============================================================================

/**
 * @brief[zh-cn] 键盘状态查询工具类（静态方法，封装 ImGui 键盘查询 API）
 *
 * @brief[en] Keyboard state query utility class (static methods wrapping ImGui keyboard query APIs)
 */
public class UiKeyboard {
    /**
     * @brief[zh-cn] 指定键是否按下
     * @param[zh-cn] key 键码（ImGuiKey）
     * @return[zh-cn] 键当前是否处于按下状态
     *
     * @brief[en] Whether the given key is down
     * @param[en] key Key code (ImGuiKey)
     * @return[en] Whether the key is currently down
     */
    public static func isKeyDown(key: Int32): Bool { return igIsKeyDown_Nil_cj(key) != 0 }
    /**
     * @brief[zh-cn] 指定键是否刚按下（含重复）
     * @param[zh-cn] key 键码（ImGuiKey）
     * @param[zh-cn] repeat_ 是否包含重复触发（默认 true）
     * @return[zh-cn] 键本次是否刚按下
     *
     * @brief[en] Whether the given key was just pressed (including repeats)
     * @param[en] key Key code (ImGuiKey)
     * @param[en] repeat_ Whether to include repeat triggers (default true)
     * @return[en] Whether the key was just pressed this frame
     */
    public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool { return igIsKeyPressed_Bool_cj(key, if (repeat_) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 指定键是否刚释放
     * @param[zh-cn] key 键码（ImGuiKey）
     * @return[zh-cn] 键本次是否刚释放
     *
     * @brief[en] Whether the given key was just released
     * @param[en] key Key code (ImGuiKey)
     * @return[en] Whether the key was just released this frame
     */
    public static func isKeyReleased(key: Int32): Bool { return igIsKeyReleased_Nil_cj(key) != 0 }
    /**
     * @brief[zh-cn] 获取键名
     * @param[zh-cn] key 键码（ImGuiKey）
     * @return[zh-cn] 键对应的名称字符串
     *
     * @brief[en] Gets the key name
     * @param[en] key Key code (ImGuiKey)
     * @return[en] The name string of the key
     */
    public static func getKeyName(key: Int32): String { return igGetKeyName_cj(key) }
    /**
     * @brief[zh-cn] 获取指定键的连续按下次数（受按住重复触发影响）
     * @param[zh-cn] key 键码（ImGuiKey）
     * @param[zh-cn] repeatDelay 重复触发前延迟
     * @param[zh-cn] rate 重复触发速率
     * @return[zh-cn] 键的按下次数
     *
     * @brief[en] Gets the press count of the given key (affected by hold-repeat)
     * @param[en] key Key code (ImGuiKey)
     * @param[en] repeatDelay Delay before repeat triggers
     * @param[en] rate Repeat trigger rate
     * @return[en] Press count of the key
     */
    public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32 { return igGetKeyPressedAmount_cj(key, repeatDelay, rate) }
}

/**
 * @brief[zh-cn] 鼠标状态查询工具类（静态方法，封装 ImGui 鼠标查询/设置 API）
 *
 * @brief[en] Mouse state query utility class (static methods wrapping ImGui mouse query/set APIs)
 */
public class UiMouse {
    /**
     * @brief[zh-cn] 指定鼠标按钮是否按下
     * @param[zh-cn] button 鼠标按钮索引（0=左键，1=右键，2=中键）
     * @return[zh-cn] 按钮当前是否处于按下状态
     *
     * @brief[en] Whether the given mouse button is down
     * @param[en] button Mouse button index (0=left, 1=right, 2=middle)
     * @return[en] Whether the button is currently down
     */
    public static func isMouseDown(button: Int32): Bool { return igIsMouseDown_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否刚点击
     * @param[zh-cn] button 鼠标按钮索引（0=左键，1=右键，2=中键）
     * @param[zh-cn] repeat_ 是否包含重复触发（默认 false）
     * @return[zh-cn] 按钮本次是否刚被点击
     *
     * @brief[en] Whether the given mouse button was just clicked
     * @param[en] button Mouse button index (0=left, 1=right, 2=middle)
     * @param[en] repeat_ Whether to include repeat triggers (default false)
     * @return[en] Whether the button was just clicked this frame
     */
    public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool { return igIsMouseClicked_Bool_cj(button, if (repeat_) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否刚释放
     * @param[zh-cn] button 鼠标按钮索引（0=左键，1=右键，2=中键）
     * @return[zh-cn] 按钮本次是否刚释放
     *
     * @brief[en] Whether the given mouse button was just released
     * @param[en] button Mouse button index (0=left, 1=right, 2=middle)
     * @return[en] Whether the button was just released this frame
     */
    public static func isMouseReleased(button: Int32): Bool { return igIsMouseReleased_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否双击
     * @param[zh-cn] button 鼠标按钮索引（0=左键，1=右键，2=中键）
     * @return[zh-cn] 按钮本次是否被双击
     *
     * @brief[en] Whether the given mouse button was double-clicked
     * @param[en] button Mouse button index (0=left, 1=right, 2=middle)
     * @return[en] Whether the button was double-clicked this frame
     */
    public static func isMouseDoubleClicked(button: Int32): Bool { return igIsMouseDoubleClicked_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 鼠标是否在指定矩形区域内悬停
     * @param[zh-cn] minX 矩形区域左上角 X 坐标
     * @param[zh-cn] minY 矩形区域左上角 Y 坐标
     * @param[zh-cn] maxX 矩形区域右下角 X 坐标
     * @param[zh-cn] maxY 矩形区域右下角 Y 坐标
     * @param[zh-cn] clip 是否限制在当前裁剪区域（默认 true）
     * @return[zh-cn] 鼠标是否悬停在矩形区域内
     *
     * @brief[en] Whether the mouse is hovering within the given rectangle
     * @param[en] minX Top-left X coordinate of the rectangle
     * @param[en] minY Top-left Y coordinate of the rectangle
     * @param[en] maxX Bottom-right X coordinate of the rectangle
     * @param[en] maxY Bottom-right Y coordinate of the rectangle
     * @param[en] clip Whether to clamp to the current clip rect (default true)
     * @return[en] Whether the mouse is hovering inside the rectangle
     */
    public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool { return igIsMouseHoveringRect_cj(ImVec2(minX, minY), ImVec2(maxX, maxY), if (clip) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 是否有任意鼠标按钮按下
     * @return[zh-cn] 任一鼠标按钮是否处于按下状态
     *
     * @brief[en] Whether any mouse button is down
     * @return[en] Whether any mouse button is currently down
     */
    public static func isAnyMouseDown(): Bool { return igIsAnyMouseDown_cj() != 0 }
    /**
     * @brief[zh-cn] 获取鼠标位置
     * @return[zh-cn] 当前鼠标坐标
     *
     * @brief[en] Gets the mouse position
     * @return[en] Current mouse coordinates
     */
    public static func getMousePos(): ImVec2 { return igGetMousePos_cj() }
    /**
     * @brief[zh-cn] 获取鼠标拖拽增量
     * @param[zh-cn] button 拖拽按钮索引（默认 0=左键）
     * @param[zh-cn] lockThreshold 锁定阈值（默认 -1.0，使用 ImGui 默认值）
     * @return[zh-cn] 拖拽起始位置到当前位置的位移
     *
     * @brief[en] Gets the mouse drag delta
     * @param[en] button Drag button index (default 0=left)
     * @param[en] lockThreshold Lock threshold (default -1.0, uses ImGui default)
     * @return[en] Displacement from drag start to current position
     */
    public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = -1.0f32): ImVec2 { return igGetMouseDragDelta_cj(button, lockThreshold) }
    /**
     * @brief[zh-cn] 重置鼠标拖拽增量
     * @param[zh-cn] button 拖拽按钮索引（默认 0=左键）
     *
     * @brief[en] Resets the mouse drag delta
     * @param[en] button Drag button index (default 0=left)
     */
    public static func resetMouseDragDelta(button!: Int32 = 0): Unit { igResetMouseDragDelta_cj(button) }
    /**
     * @brief[zh-cn] 获取当前鼠标光标类型
     * @return[zh-cn] 当前光标类型（ImGuiMouseCursor 枚举值）
     *
     * @brief[en] Gets the current mouse cursor type
     * @return[en] Current cursor type (ImGuiMouseCursor enum value)
     */
    public static func getMouseCursor(): Int32 { return igGetMouseCursor_cj() }
    /**
     * @brief[zh-cn] 设置鼠标光标类型
     * @param[zh-cn] cursorType 光标类型（ImGuiMouseCursor 枚举值）
     *
     * @brief[en] Sets the mouse cursor type
     * @param[en] cursorType Cursor type (ImGuiMouseCursor enum value)
     */
    public static func setMouseCursor(cursorType: Int32): Unit { igSetMouseCursor_cj(cursorType) }
}

// =============================================================================
// UiSpacing — 间距（已在 UiWidget 中定义，此处保留）
// =============================================================================
