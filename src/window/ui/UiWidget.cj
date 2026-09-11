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

    public init() {}
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

    public init(text!: String) { super(); this._text = text }

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

    public init(label!: String) { super(); this._label = label }

    public func onClick(callback: () -> Unit): UiSmallButton {
        this._onClick = Some(callback)
        return this
    }

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
 * @explain[zh-cn] 使用 CPointer<Int32> 存储状态（0/1），与 ImGui 约定一致。
 *
 * @brief[en] Checkbox widget
 * @explain[en] Uses CPointer<Int32> for state (0/1), matching ImGui conventions.
 */
public class UiCheckbox <: UiWidget {
    private var _label: String
    private var _value: CPointer<Int32>

    public init(label!: String, value!: CPointer<Int32>) {
        super()
        this._label = label
        this._value = value
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Checkbox_cj(this._label, this._value)
    }

    /// 获取当前值（0=未选中，1=选中）
    public func getValue(): Int32 {
        return unsafe { this._value.read() }
    }

    /// 设置值
    public func setValue(v: Int32): Unit {
        unsafe { this._value.write(v) }
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
    private var _value: CPointer<Float32>
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    public init(label!: String, value!: CPointer<Float32>,
                min!: Float32 = 0.0, max!: Float32 = 1.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._min = min
        this._max = max
        this._format = format
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let fmtCs = unsafe { LibC.mallocCString(this._format) }
        let r = igSliderFloat_cj(cs, this._value, this._min, this._max, fmtCs, 0)
        unsafe { LibC.free(cs); LibC.free(fmtCs) }
        return r != 0
    }

    public func getValue(): Float32 {
        return unsafe { this._value.read() }
    }

    public func setValue(v: Float32): Unit {
        unsafe { this._value.write(v) }
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
    private var _value: CPointer<Int32>
    private var _min: Int32
    private var _max: Int32
    private var _format: String

    public init(label!: String, value!: CPointer<Int32>,
                min!: Int32 = 0, max!: Int32 = 100,
                format!: String = "%d") {
        super()
        this._label = label
        this._value = value
        this._min = min
        this._max = max
        this._format = format
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let fmtCs = unsafe { LibC.mallocCString(this._format) }
        let r = igSliderInt_cj(cs, this._value, this._min, this._max, fmtCs, 0)
        unsafe { LibC.free(cs); LibC.free(fmtCs) }
        return r != 0
    }

    public func getValue(): Int32 {
        return unsafe { this._value.read() }
    }

    public func setValue(v: Int32): Unit {
        unsafe { this._value.write(v) }
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

    /// 获取缓冲区指针（高级用法）
    public func getBufPtr(): CPointer<Int8> { return this._buf }
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
    private var _value: CPointer<Float32>
    private var _step: Float32
    private var _stepFast: Float32
    private var _format: String

    public init(label!: String, value!: CPointer<Float32>,
                step!: Float32 = 0.1, stepFast!: Float32 = 1.0,
                format!: String = "%.3f") {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
        this._format = format
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputFloat_cj(this._label, this._value, this._step, this._stepFast, this._format, 0) != 0
    }

    public func getValue(): Float32 { return unsafe { this._value.read() } }
    public func setValue(v: Float32): Unit { unsafe { this._value.write(v) } }
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
    private var _currentItem: CPointer<Int32>
    private var _items: String

    /**
     * @param label 标签
     * @param currentItem 当前选中索引指针
     * @param items 以 '\0' 分隔的选项列表（如 "Option1\0Option2\0Option3\0"）
     */
    public init(label!: String, currentItem!: CPointer<Int32>, items!: String) {
        super()
        this._label = label
        this._currentItem = currentItem
        this._items = items
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Combo_Str_cj(this._label, this._currentItem, this._items, -1) != 0
    }

    public func getCurrentIndex(): Int32 { return unsafe { this._currentItem.read() } }
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

    public init(label!: String, selected!: Bool = false, flags!: Int32 = 0) {
        super()
        this._label = label
        this._selected = selected
        this._flags = flags
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_Selectable_Bool_cj(this._label, if (this._selected) { 1 } else { 0 }, this._flags, ImVec2(0.0, 0.0)) != 0
    }

    public func isSelected(): Bool { return this._selected }
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
    public init() { super() }
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

    public init(offset!: Float32 = 0.0, spacing!: Float32 = -1.0) {
        super()
        this._offset = offset
        this._spacing = spacing
    }

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
    public init() { super() }
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

    public init(label!: String) { super(); this._label = label }

    /**
     * @brief[zh-cn] 设置子内容闭包
     * @return[zh-cn] this（链式调用）
     *
     * @brief[en] Sets the child content closure
     * @return[en] this (for chaining)
     */
    public func withContent(content: () -> Unit): UiTreeNode {
        this._content = Some(content)
        return this
    }

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

    public init(label!: String, flags!: Int32 = 0) { super(); this._label = label; this._flags = flags }

    public func withContent(content: () -> Unit): UiTreeNodeEx {
        this._content = Some(content)
        return this
    }

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

    public init(label!: String, flags!: Int32 = 0) { super(); this._label = label; this._flags = flags }

    public func withContent(content: () -> Unit): UiCollapsingHeader {
        this._content = Some(content)
        return this
    }

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

    public init(content!: () -> Unit) { super(); this._content = content }

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

    public init(text!: String) { super(); this._text = text }

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

    public init(fraction!: Float32 = 0.0,
                size!: Vector2 = Vector2(-1.0, 0.0),
                overlay!: String = "") {
        super()
        this._fraction = fraction
        this._size = size
        this._overlay = overlay
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_ProgressBar_cj(this._fraction, ImVec2(Float32(this._size.x), Float32(this._size.y)), this._overlay)
        return false
    }

    public func setFraction(f: Float32): Unit { this._fraction = f }
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
    private var _currentItem: CPointer<Int32>
    private var _items: String
    private var _heightInItems: Int32

    public init(label!: String, currentItem!: CPointer<Int32>,
                items!: String, heightInItems!: Int32 = -1) {
        super()
        this._label = label
        this._currentItem = currentItem
        this._items = items
        this._heightInItems = heightInItems
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return unsafe {
            let csItems = LibC.mallocCString(this._items)
            let r = ImGui_ListBox_Str_arr_cj(this._label, this._currentItem,
                                              CPointer<Unit>(csItems.getChars()),
                                              -1, this._heightInItems)
            LibC.free(csItems)
            r != 0
        }
    }

    public func getCurrentIndex(): Int32 { return unsafe { this._currentItem.read() } }
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

    public init(texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0)) {
        super()
        this._texId = texId
        this._size = size
    }

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

    public init(strId!: String, texId!: UInt64,
                size!: Vector2 = Vector2(64.0, 64.0)) {
        super()
        this._strId = strId
        this._texId = texId
        this._size = size
    }

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
    private var _col: CPointer<Float32>
    private var _flags: Int32

    public init(label!: String, col!: CPointer<Float32>, flags!: Int32 = 0) {
        super()
        this._label = label
        this._col = col
        this._flags = flags
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_ColorEdit4_cj(this._label, this._col, this._flags) != 0
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
    private var _col: CPointer<Float32>
    private var _flags: Int32

    public init(label!: String, col!: CPointer<Float32>, flags!: Int32 = 0) {
        super()
        this._label = label
        this._col = col
        this._flags = flags
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_ColorPicker4_cj(this._label, this._col, this._flags, CPointer<Float32>()) != 0
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
    private var _value: CPointer<Float32>
    private var _speed: Float32
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    public init(label!: String, value!: CPointer<Float32>,
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

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_DragFloat_cj(this._label, this._value, this._speed,
                                   this._min, this._max, this._format, 0) != 0
    }

    public func getValue(): Float32 { return unsafe { this._value.read() } }
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
    private var _value: CPointer<Int32>
    private var _speed: Float32
    private var _min: Int32
    private var _max: Int32
    private var _format: String

    public init(label!: String, value!: CPointer<Int32>,
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

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_DragInt_cj(this._label, this._value, this._speed,
                                 this._min, this._max, this._format, 0) != 0
    }

    public func getValue(): Int32 { return unsafe { this._value.read() } }
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
    private var _value: CPointer<Int32>
    private var _step: Int32
    private var _stepFast: Int32

    public init(label!: String, value!: CPointer<Int32>,
                step!: Int32 = 1, stepFast!: Int32 = 100) {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputInt_cj(this._label, this._value, this._step, this._stepFast, 0) != 0
    }

    public func getValue(): Int32 { return unsafe { this._value.read() } }
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
    private var _value: CPointer<Float64>
    private var _step: Float64
    private var _stepFast: Float64
    private var _format: String

    public init(label!: String, value!: CPointer<Float64>,
                step!: Float64 = 0.1, stepFast!: Float64 = 1.0,
                format!: String = "%.6f") {
        super()
        this._label = label
        this._value = value
        this._step = step
        this._stepFast = stepFast
        this._format = format
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_InputDouble_cj(this._label, this._value, this._step, this._stepFast, this._format, 0) != 0
    }

    public func getValue(): Float64 { return unsafe { this._value.read() } }
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
    private var _value: CPointer<Float32>
    private var _size: Vector2
    private var _min: Float32
    private var _max: Float32
    private var _format: String

    public init(label!: String, value!: CPointer<Float32>,
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

    public override func draw(): Bool {
        ensureCurrentContext()
        return ImGui_VSliderFloat_cj(this._label, ImVec2(Float32(this._size.x), Float32(this._size.y)),
                                      this._value, this._min, this._max, this._format, 0) != 0
    }

    public func getValue(): Float32 { return unsafe { this._value.read() } }
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

    public init(disabled!: Bool = true, content!: () -> Unit) {
        super()
        this._disabled = disabled
        this._content = content
    }

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

    public init(min!: Vector2, max!: Vector2,
                content!: () -> Unit) {
        super()
        this._min = min
        this._max = max
        this._content = content
    }

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

    public init(width!: Float32) { super(); this._width = width }

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

    public init(isOpen!: Bool = true, cond!: Int32 = 0) {
        super()
        this._isOpen = isOpen
        this._cond = cond
    }

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

    public init(label!: String) { super(); this._label = label }

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
    private var _values: CPointer<Float32>
    private var _count: Int32
    private var _offset: Int32
    private var _overlay: String
    private var _scaleMin: Float32
    private var _scaleMax: Float32
    private var _size: Vector2

    public init(label!: String, values!: CPointer<Float32>,
                count!: Int32, offset!: Int32 = 0,
                overlay!: String = "", scaleMin!: Float32 = 3.4028235e38,
                scaleMax!: Float32 = 3.4028235e38,
                size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._label = label
        this._values = values
        this._count = count
        this._offset = offset
        this._overlay = overlay
        this._scaleMin = scaleMin
        this._scaleMax = scaleMax
        this._size = size
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_PlotLines_FloatPtr_cj(this._label, this._values, this._count,
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
    private var _values: CPointer<Float32>
    private var _count: Int32
    private var _offset: Int32
    private var _overlay: String
    private var _scaleMin: Float32
    private var _scaleMax: Float32
    private var _size: Vector2

    public init(label!: String, values!: CPointer<Float32>,
                count!: Int32, offset!: Int32 = 0,
                overlay!: String = "", scaleMin!: Float32 = 3.4028235e38,
                scaleMax!: Float32 = 3.4028235e38,
                size!: Vector2 = Vector2(0.0, 0.0)) {
        super()
        this._label = label
        this._values = values
        this._count = count
        this._offset = offset
        this._overlay = overlay
        this._scaleMin = scaleMin
        this._scaleMax = scaleMax
        this._size = size
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_PlotHistogram_FloatPtr_cj(this._label, this._values, this._count,
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

    public init(prefix!: String, value!: Float32, format!: String = "") {
        super()
        this._prefix = prefix
        this._value = value
        this._format = format
    }

    public override func draw(): Bool {
        ensureCurrentContext()
        ImGui_Value_Float_cj(this._prefix, this._value, this._format)
        return false
    }

    public func setValue(v: Float32): Unit { this._value = v }
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
     * @return[zh-cn] 是否悬停
     *
     * @brief[en] Whether the last widget is hovered
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
     * @return[zh-cn] 是否被点击
     *
     * @brief[en] Whether the last widget was clicked
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
     *
     * @brief[en] Pushes a string ID
     */
    public static func pushID(strID: String): Unit {
        unsafe { let cs = LibC.mallocCString(strID); igPushID_Str_cj(cs); LibC.free(cs) }
    }
    /**
     * @brief[zh-cn] 压入整数 ID
     *
     * @brief[en] Pushes an integer ID
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

public class UiArrowButton <: UiWidget {
    private var _id: String
    private var _dir: Int32
    public init(id: String, dir: Int32) { super(); this._id = id; this._dir = dir }
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

public class UiBeginCombo <: UiWidget {
    private var _label: String
    private var _preview: String
    private var _flags: Int32
    public init(label: String, previewValue: String, flags!: Int32 = 0) { super(); this._label = label; this._preview = previewValue; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }
        let csP = unsafe { LibC.mallocCString(this._preview) }
        let r = igBeginCombo_cj(csL, csP, this._flags)
        unsafe { LibC.free(csL); LibC.free(csP) }
        return r != 0
    }
}

public class UiEndCombo <: UiWidget {
    public init() { super() }
    public override func draw(): Bool { ensureCurrentContext(); igEndCombo_cj(); return true }
}

// =============================================================================
// UiBeginListBox / UiEndListBox — 自定义列表框
// Custom List Box
// =============================================================================

public class UiBeginListBox <: UiWidget {
    private var _label: String
    private var _w: Float32
    private var _h: Float32
    public init(label: String, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32) { super(); this._label = label; this._w = w; this._h = h }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igBeginListBox_cj(cs, ImVec2(this._w, this._h))
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

public class UiEndListBox <: UiWidget {
    public init() { super() }
    public override func draw(): Bool { ensureCurrentContext(); igEndListBox_cj(); return true }
}

// =============================================================================
// UiColorButton — 颜色按钮
// Color Button
// =============================================================================

public class UiColorButton <: UiWidget {
    private var _desc: String
    private var _col: ImVec4
    private var _flags: Int32
    private var _w: Float32
    private var _h: Float32
    public init(desc: String, r: Float32, g: Float32, b: Float32, a!: Float32 = 1.0f32, flags!: Int32 = 0, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32) {
        super(); this._desc = desc; this._col = ImVec4(r, g, b, a); this._flags = flags; this._w = w; this._h = h
    }
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

public class UiColorEdit3 <: UiWidget {
    private var _label: String
    private var _col: CPointer<Float32>
    private var _flags: Int32
    public init(label: String, col: CPointer<Float32>, flags!: Int32 = 0) { super(); this._label = label; this._col = col; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igColorEdit3_cj(cs, this._col, this._flags)
        unsafe { LibC.free(cs) }
        return r != 0
    }
}

// =============================================================================
// UiDragFloat2 / UiDragFloat3 / UiDragFloat4
// Multi-Channel Float Drag
// =============================================================================

public class UiDragFloat2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat2_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiDragFloat3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat3_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiDragFloat4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _speed: Float32; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragFloat4_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiDragInt2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt2_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiDragInt3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt3_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiDragInt4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _speed: Float32; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0) {
        this._label = label; this._v = v; this._speed = speed; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igDragInt4_cj(csL, this._v, this._speed, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

// =============================================================================
// UiSliderFloat2 / UiSliderFloat3 / UiSliderFloat4 / UiSliderAngle
// Multi-Channel Float Slider / Angle Slider
// =============================================================================

public class UiSliderFloat2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat2_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderFloat3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat3_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderFloat4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _min: Float32; private var _max: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderFloat4_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderAngle <: UiWidget {
    private var _label: String; private var _vRad: CPointer<Float32>; private var _minDeg: Float32; private var _maxDeg: Float32; private var _fmt: String; private var _flags: Int32
    public init(label: String, vRad: CPointer<Float32>, minDeg!: Float32 = -360.0f32, maxDeg!: Float32 = 360.0f32, format!: String = "%.0f deg", flags!: Int32 = 0) {
        super(); this._label = label; this._vRad = vRad; this._minDeg = minDeg; this._maxDeg = maxDeg; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderAngle_cj(csL, this._vRad, this._minDeg, this._maxDeg, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderInt2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt2_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderInt3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt3_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiSliderInt4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _min: Int32; private var _max: Int32; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0) {
        super(); this._label = label; this._v = v; this._min = min; this._max = max; this._fmt = format; this._flags = flags
    }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igSliderInt4_cj(csL, this._v, this._min, this._max, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

// =============================================================================
// UiInputFloat2 / UiInputFloat3 / UiInputFloat4
// Multi-Channel Float Input
// =============================================================================

public class UiInputFloat2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat2_cj(csL, this._v, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiInputFloat3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat3_cj(csL, this._v, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiInputFloat4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Float32>; private var _fmt: String; private var _flags: Int32
    public init(label: String, v: CPointer<Float32>, format!: String = "%.3f", flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._fmt = format; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }; let csF = unsafe { LibC.mallocCString(this._fmt) }
        let r = igInputFloat4_cj(csL, this._v, csF, this._flags)
        unsafe { LibC.free(csL); LibC.free(csF) }; return r != 0
    }
}

public class UiInputInt2 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt2_cj(cs, this._v, this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

public class UiInputInt3 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt3_cj(cs, this._v, this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

public class UiInputInt4 <: UiWidget {
    private var _label: String; private var _v: CPointer<Int32>; private var _flags: Int32
    public init(label: String, v: CPointer<Int32>, flags!: Int32 = 0) { super(); this._label = label; this._v = v; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputInt4_cj(cs, this._v, this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

// =============================================================================
// UiColorPicker3 — 三通道颜色选择器
// 3-Channel Color Picker
// =============================================================================

public class UiColorPicker3 <: UiWidget {
    private var _label: String; private var _col: CPointer<Float32>; private var _flags: Int32
    public init(label!: String, col!: CPointer<Float32>, flags!: Int32 = 0) { super(); this._label = label; this._col = col; this._flags = flags }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igColorPicker3_cj(cs, this._col, this._flags)
        unsafe { LibC.free(cs) }; return r != 0
    }
}

// =============================================================================
// UiTextLink — 可点击链接文本
// Clickable Link Text
// =============================================================================

public class UiTextLink <: UiWidget {
    private var _label: String
    public init(label!: String) { super(); this._label = label }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = ImGui_TextLink_cj(cs)
        unsafe { LibC.free(cs) }; return r != 0
    }
    public func openURL(): Unit {
        let cs = unsafe { LibC.mallocCString(this._label) }
        igTextLinkOpenURL_cj(cs, cs)
        unsafe { LibC.free(cs) }
    }
}

// =============================================================================
// UiTextBullet — 圆点文本（BulletText）
// Bullet Text
// =============================================================================

public class UiTextBullet <: UiWidget {
    private var _text: String
    public init(text!: String) { super(); this._text = text }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._text) }
        igBulletText0_cj(cs)
        unsafe { LibC.free(cs) }; return false
    }
}

// =============================================================================
// UiLabelText — 标签+值文本
// Label + Value Text
// =============================================================================

public class UiLabelText <: UiWidget {
    private var _label: String; private var _text: String
    public init(label!: String, text!: String) { super(); this._label = label; this._text = text }
    public override func draw(): Bool {
        ensureCurrentContext()
        let csL = unsafe { LibC.mallocCString(this._label) }
        let csT = unsafe { LibC.mallocCString(this._text) }
        igLabelText0_cj(csL, csT)
        unsafe { LibC.free(csL); LibC.free(csT) }; return false
    }
}

// =============================================================================
// UiValueBool / UiValueInt / UiValueUint — 值显示变体
// Value Display Variants
// =============================================================================

public class UiValueBool <: UiWidget {
    private var _prefix: String; private var _v: Bool
    public init(prefix!: String, v!: Bool) { super(); this._prefix = prefix; this._v = v }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._prefix) }
        igValue_Bool_cj(cs, if (this._v) { 1 } else { 0 })
        unsafe { LibC.free(cs) }; return false
    }
}

public class UiValueInt <: UiWidget {
    private var _prefix: String; private var _v: Int32
    public init(prefix!: String, v!: Int32) { super(); this._prefix = prefix; this._v = v }
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._prefix) }
        igValue_Int_cj(cs, this._v)
        unsafe { LibC.free(cs) }; return false
    }
}

public class UiValueUint <: UiWidget {
    private var _prefix: String; private var _v: UInt32
    public init(prefix!: String, v!: UInt32) { super(); this._prefix = prefix; this._v = v }
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

public class UiListClipper {
    private var _clipper: CPointer<Unit> = CPointer<Unit>()

    public init() {
        this._clipper = ImGuiListClipper_ImGuiListClipper_cj()
    }

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
     *
     * @brief[en] Gets the current batch start index
     */
    public func getDisplayStart(): Int32 {
        if (this._clipper.isNull()) { return 0 }
        return unsafe { CPointer<Int32>(CPointer<UInt8>(this._clipper) + 24).read() }
    }

    /**
     * @brief[zh-cn] 获取当前批次结束索引
     *
     * @brief[en] Gets the current batch end index
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

public class UiTextFilter {
    private var _filter: CPointer<Unit> = CPointer<Unit>()

    public init(defaultFilter!: String = "") {
        let cs = unsafe { LibC.mallocCString(defaultFilter) }
        this._filter = ImGuiTextFilter_ImGuiTextFilter_cj(cs)
        unsafe { LibC.free(cs) }
    }

    public func destroy(): Unit {
        if (!this._filter.isNull()) {
            ImGuiTextFilter_destroy_cj(this._filter)
            this._filter = CPointer<Unit>()
        }
    }

    /**
     * @brief[zh-cn] 绘制过滤器输入框
     *
     * @brief[en] Draws the filter input box
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
     *
     * @brief[en] Tests whether text passes the filter
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
     *
     * @brief[en] Whether active (has a filter condition)
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

public class UiKeyboard {
    /**
     * @brief[zh-cn] 指定键是否按下
     *
     * @brief[en] Whether the given key is down
     */
    public static func isKeyDown(key: Int32): Bool { return igIsKeyDown_Nil_cj(key) != 0 }
    /**
     * @brief[zh-cn] 指定键是否刚按下（含重复）
     *
     * @brief[en] Whether the given key was just pressed (including repeats)
     */
    public static func isKeyPressed(key: Int32, repeat_!: Bool = true): Bool { return igIsKeyPressed_Bool_cj(key, if (repeat_) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 指定键是否刚释放
     *
     * @brief[en] Whether the given key was just released
     */
    public static func isKeyReleased(key: Int32): Bool { return igIsKeyReleased_Nil_cj(key) != 0 }
    /**
     * @brief[zh-cn] 获取键名
     *
     * @brief[en] Gets the key name
     */
    public static func getKeyName(key: Int32): String { return igGetKeyName_cj(key) }
    /**
     * @brief[zh-cn] 指定键按下次数
     *
     * @brief[en] Gets the press count of the given key
     */
    public static func getKeyPressedAmount(key: Int32, repeatDelay: Float32, rate: Float32): Int32 { return igGetKeyPressedAmount_cj(key, repeatDelay, rate) }
}

public class UiMouse {
    /**
     * @brief[zh-cn] 指定鼠标按钮是否按下
     *
     * @brief[en] Whether the given mouse button is down
     */
    public static func isMouseDown(button: Int32): Bool { return igIsMouseDown_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否刚点击
     *
     * @brief[en] Whether the given mouse button was just clicked
     */
    public static func isMouseClicked(button: Int32, repeat_!: Bool = false): Bool { return igIsMouseClicked_Bool_cj(button, if (repeat_) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否刚释放
     *
     * @brief[en] Whether the given mouse button was just released
     */
    public static func isMouseReleased(button: Int32): Bool { return igIsMouseReleased_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 指定鼠标按钮是否双击
     *
     * @brief[en] Whether the given mouse button was double-clicked
     */
    public static func isMouseDoubleClicked(button: Int32): Bool { return igIsMouseDoubleClicked_Nil_cj(button) != 0 }
    /**
     * @brief[zh-cn] 鼠标是否在指定矩形区域内悬停
     *
     * @brief[en] Whether the mouse is hovering within the given rectangle
     */
    public static func isMouseHoveringRect(minX: Float32, minY: Float32, maxX: Float32, maxY: Float32, clip!: Bool = true): Bool { return igIsMouseHoveringRect_cj(ImVec2(minX, minY), ImVec2(maxX, maxY), if (clip) { 1 } else { 0 }) != 0 }
    /**
     * @brief[zh-cn] 是否有任意鼠标按钮按下
     *
     * @brief[en] Whether any mouse button is down
     */
    public static func isAnyMouseDown(): Bool { return igIsAnyMouseDown_cj() != 0 }
    /**
     * @brief[zh-cn] 获取鼠标位置
     *
     * @brief[en] Gets the mouse position
     */
    public static func getMousePos(): ImVec2 { return igGetMousePos_cj() }
    /**
     * @brief[zh-cn] 获取鼠标拖拽增量
     *
     * @brief[en] Gets the mouse drag delta
     */
    public static func getMouseDragDelta(button!: Int32 = 0, lockThreshold!: Float32 = -1.0f32): ImVec2 { return igGetMouseDragDelta_cj(button, lockThreshold) }
    /**
     * @brief[zh-cn] 重置鼠标拖拽增量
     *
     * @brief[en] Resets the mouse drag delta
     */
    public static func resetMouseDragDelta(button!: Int32 = 0): Unit { igResetMouseDragDelta_cj(button) }
    /**
     * @brief[zh-cn] 获取当前鼠标光标类型
     *
     * @brief[en] Gets the current mouse cursor type
     */
    public static func getMouseCursor(): Int32 { return igGetMouseCursor_cj() }
    /**
     * @brief[zh-cn] 设置鼠标光标类型
     *
     * @brief[en] Sets the mouse cursor type
     */
    public static func setMouseCursor(cursorType: Int32): Unit { igSetMouseCursor_cj(cursorType) }
}

// =============================================================================
// UiSpacing — 间距（已在 UiWidget 中定义，此处保留）
// =============================================================================
