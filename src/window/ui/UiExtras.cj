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
 * @file[zh-cn] UiExtras.cj — 补充控件与系统能力封装
 * @brief[zh-cn] 封装 ffi_exports.cj 中已有但此前未公开的能力：子窗口类、多行文本输入、单选按钮、透明命中区、位标志复选框、内置主题、鼠标拖拽/剪贴板/输入捕获、样式色查询、Combo 预览、项级开关
 * @explain[zh-cn] 全部基于 imgui4cj 已导出的 ig*_cj 函数，不依赖裸 FFI。用法示例：
 *   UiWindow("Demo").draw({ =>
 *       UiInputTextMultiline(label: "Code", bufSize: 4096).draw()
 *       UiRadioButton(label: "Option A", active: this.mode == 0).draw()
 *       let group = PtrArray<Int32>(1); group.set(0, this.mode)
 *       if (UiRadioButtonGroup(label: "Option B", value: group, buttonValue: 1).draw()) { this.mode = group.get(0) }
 *       UiTheme.applyDark()
 *   })
 *
 * @file[en] UiExtras.cj — Supplementary Widgets and System Capabilities
 * @brief[en] Public wrappers for FFI capabilities not yet exposed: child window class, multiline text input, radio buttons, invisible hit area, checkbox flags, built-in themes, mouse drag/clipboard/input capture, style color query, combo preview, item flags
 * @explain[en] All built on the exported ig*_cj functions, no raw FFI required.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*
import three.core.math.*
import three.utils.memory.PtrArray

// =============================================================================
// UiChildWindow — 子窗口（类形式，滚动面板基础）
// =============================================================================

/**
 * @brief[zh-cn] 子窗口控件（BeginChild/EndChild 的类形式）
 * @explain[zh-cn] 在父窗口内创建带独立滚动区域的子区域，是滚动面板/分栏布局的基础。
 *   静态形式见 UiWindow.beginChild/endChild；本类提供与 UiWindow 一致的 draw() 闭包生命周期管理。
 *
 * @brief[en] Child window widget (class form of BeginChild/EndChild)
 * @explain[en] Creates a child region with independent scrolling inside a parent window — the basis of scroll panels and split layouts.
 */
public class UiChildWindow {
    private var _id: String
    private var _w: Float32
    private var _h: Float32
    private var _childFlags: Int32
    private var _windowFlags: Int32

    /**
     * @brief[zh-cn] 构造子窗口
     * @param[zh-cn] id 子窗口 ID（同一父窗口内需唯一）
     * @param[zh-cn] w 宽度（0=使用剩余宽度）
     * @param[zh-cn] h 高度（0=使用剩余高度）
     * @param[zh-cn] childFlags ImGuiChildFlags
     * @param[zh-cn] windowFlags ImGuiWindowFlags
     *
     * @brief[en] Constructs a child window
     * @param[en] id Child window ID (unique within the parent window)
     * @param[en] w Width (0=remaining width)
     * @param[en] h Height (0=remaining height)
     * @param[en] childFlags ImGuiChildFlags
     * @param[en] windowFlags ImGuiWindowFlags
     */
    public init(id!: String, w!: Float32 = 0.0, h!: Float32 = 0.0,
                childFlags!: Int32 = 0, windowFlags!: Int32 = 0) {
        this._id = id
        this._w = w
        this._h = h
        this._childFlags = childFlags
        this._windowFlags = windowFlags
    }

    /**
     * @brief[zh-cn] 开始子窗口（ImGui BeginChild）
     * @return[zh-cn] 子窗口是否可见
     *
     * @brief[en] Begins the child window (ImGui BeginChild)
     * @return[en] Whether the child window is visible
     */
    public func begin(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._id) }
        let r = igBeginChild_Str_cj(cs, ImVec2(this._w, this._h), this._childFlags, this._windowFlags)
        unsafe { LibC.free(cs) }
        return r != 0
    }

    /**
     * @brief[zh-cn] 结束子窗口（ImGui EndChild）
     *
     * @brief[en] Ends the child window (ImGui EndChild)
     */
    public func end(): Unit {
        igEndChild_cj()
    }

    /**
     * @brief[zh-cn] 使用闭包自动管理 begin/end
     * @param[zh-cn] content 子窗口内控件渲染回调
     * @return[zh-cn] 子窗口是否可见
     *
     * @brief[en] Automatically manages begin/end with a closure
     * @param[en] content Render callback for widgets inside the child window
     * @return[en] Whether the child window is visible
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
     * @brief[zh-cn] 创建子窗口
     * @param[zh-cn] id 子窗口 ID
     * @param[zh-cn] w 宽度
     * @param[zh-cn] h 高度
     * @return[zh-cn] 子窗口实例
     *
     * @brief[en] Creates a child window
     * @param[en] id Child window ID
     * @param[en] w Width
     * @param[en] h Height
     * @return[en] Child window instance
     */
    public static func create(id: String, w!: Float32 = 0.0, h!: Float32 = 0.0): UiChildWindow {
        return UiChildWindow(id: id, w: w, h: h)
    }
}

// =============================================================================
// UiInputTextMultiline — 多行文本输入框
// =============================================================================

/**
 * @brief[zh-cn] 多行文本输入框控件
 * @explain[zh-cn] 缓冲区管理与 UiInputText 一致（malloc 缓冲 + getText/setText 读写）。
 *
 * @brief[en] Multiline text input widget
 * @explain[en] Buffer management matches UiInputText (malloc'ed buffer with getText/setText).
 */
public class UiInputTextMultiline <: UiWidget {
    private var _label: String
    private var _buf: CPointer<Int8>
    private var _bufSize: UIntNative
    private var _w: Float32
    private var _h: Float32
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造多行文本输入框
     * @param[zh-cn] label 标签
     * @param[zh-cn] bufSize 缓冲区大小（字节），默认 1024
     * @param[zh-cn] w 宽度（0=自动）
     * @param[zh-cn] h 高度（0=约 6 行文本高度）
     * @param[zh-cn] flags 输入标志
     *
     * @brief[en] Constructs a multiline text input widget
     * @param[en] label Label text
     * @param[en] bufSize Buffer size in bytes, defaults to 1024
     * @param[en] w Width (0=auto)
     * @param[en] h Height (0=about 6 text lines)
     * @param[en] flags Input flags
     */
    public init(label!: String, bufSize!: UIntNative = UIntNative(1024),
                w!: Float32 = 0.0, h!: Float32 = 0.0, flags!: Int32 = 0) {
        super()
        this._label = label
        this._bufSize = bufSize
        this._w = w
        this._h = h
        this._flags = flags
        this._buf = unsafe { LibC.malloc<Int8>(count: Int64(bufSize)) }
        unsafe { let p = this._buf; p.write(0i8) }
    }

    /**
     * @brief[zh-cn] 渲染多行文本输入框
     * @return[zh-cn] 本次输入内容是否发生变化
     *
     * @brief[en] Renders the multiline text input
     * @return[en] Whether the input text changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igInputTextMultiline_cj(cs, this._buf, this._bufSize, ImVec2(this._w, this._h),
                                        this._flags, CPointer<Unit>(), CPointer<Unit>()) != 0
        unsafe { LibC.free(cs) }
        return r
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
}

// =============================================================================
// UiRadioButton — 单选按钮
// =============================================================================

/**
 * @brief[zh-cn] 单选按钮控件（布尔激活态形式）
 * @explain[zh-cn] active 为 true 时显示选中圆点，点击返回 true。互斥逻辑由调用方维护。
 *
 * @brief[en] Radio button widget (boolean active form)
 * @explain[en] Shows the selected dot when active is true; returns true on click. Mutual exclusion is managed by the caller.
 */
public class UiRadioButton <: UiWidget {
    private var _label: String
    private var _active: Bool

    /**
     * @brief[zh-cn] 构造单选按钮
     * @param[zh-cn] label 按钮标签
     * @param[zh-cn] active 是否处于选中态
     *
     * @brief[en] Constructs a radio button
     * @param[en] label Button label
     * @param[en] active Whether currently selected
     */
    public init(label!: String, active!: Bool) {
        super()
        this._label = label
        this._active = active
    }

    /**
     * @brief[zh-cn] 渲染单选按钮
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the radio button
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igRadioButton_Bool_cj(cs, if (this._active) { 1 } else { 0 }) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

/**
 * @brief[zh-cn] 单选按钮组控件（Int 共享值形式）
 * @explain[zh-cn] value 为共享的单元素 PtrArray<Int32>，buttonValue 为本按钮代表的值；
 *   点击时 value 被写为 buttonValue，draw() 返回 true。
 *
 * @brief[en] Radio button group widget (shared Int value form)
 * @explain[en] value is a shared single-element PtrArray<Int32> and buttonValue is this button's value;
 *   on click, value is written to buttonValue and draw() returns true.
 */
public class UiRadioButtonGroup <: UiWidget {
    private var _label: String
    private var _value: PtrArray<Int32>
    private var _buttonValue: Int32

    /**
     * @brief[zh-cn] 构造单选按钮组项
     * @param[zh-cn] label 按钮标签
     * @param[zh-cn] value 共享选中值（PtrArray<Int32> 单元素）
     * @param[zh-cn] buttonValue 本按钮代表的值
     *
     * @brief[en] Constructs a radio group button
     * @param[en] label Button label
     * @param[en] value Shared selected value (single-element PtrArray<Int32>)
     * @param[en] buttonValue The value this button represents
     */
    public init(label!: String, value!: PtrArray<Int32>, buttonValue!: Int32) {
        super()
        this._label = label
        this._value = value
        this._buttonValue = buttonValue
    }

    /**
     * @brief[zh-cn] 渲染单选按钮组项并同步选中值
     * @return[zh-cn] 本次选中值是否变化（即本按钮被点击）
     *
     * @brief[en] Renders the radio group button and syncs the selected value
     * @return[en] Whether the selected value changed this frame (i.e. this button was clicked)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igRadioButton_IntPtr_cj(cs, this._value.data(), this._buttonValue) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

// =============================================================================
// UiInvisibleButton — 透明命中区（自绘控件基石）
// =============================================================================

/**
 * @brief[zh-cn] 透明命中区控件（InvisibleButton）
 * @explain[zh-cn] 不绘制任何内容但占位并可交互，是自定义绘制控件（配合 UiDrawList）的命中判定基石。
 *
 * @brief[en] Invisible button (InvisibleButton)
 * @explain[en] Occupies space and handles interaction without drawing anything — the hit-test foundation for custom-drawn widgets (paired with UiDrawList).
 */
public class UiInvisibleButton <: UiWidget {
    private var _id: String
    private var _w: Float32
    private var _h: Float32
    private var _flags: Int32

    /**
     * @brief[zh-cn] 构造透明命中区
     * @param[zh-cn] id 命中区 ID
     * @param[zh-cn] w 宽度
     * @param[zh-cn] h 高度
     * @param[zh-cn] flags ImGuiButtonFlags
     *
     * @brief[en] Constructs an invisible button
     * @param[en] id Button ID
     * @param[en] w Width
     * @param[en] h Height
     * @param[en] flags ImGuiButtonFlags
     */
    public init(id!: String, w!: Float32, h!: Float32, flags!: Int32 = 0) {
        super()
        this._id = id
        this._w = w
        this._h = h
        this._flags = flags
    }

    /**
     * @brief[zh-cn] 渲染透明命中区
     * @return[zh-cn] 本次是否被点击
     *
     * @brief[en] Renders the invisible hit area
     * @return[en] Whether it was clicked this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._id) }
        let r = igInvisibleButton_cj(cs, ImVec2(this._w, this._h), this._flags) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

// =============================================================================
// UiCheckboxFlags — 位标志复选框
// =============================================================================

/**
 * @brief[zh-cn] 位标志复选框控件
 * @explain[zh-cn] flags 为共享的单元素 PtrArray<Int32>，点击时对 flagsValue 位进行置位/清零。
 *
 * @brief[en] Checkbox flags widget
 * @explain[en] flags is a shared single-element PtrArray<Int32>; clicking toggles the flagsValue bit(s).
 */
public class UiCheckboxFlags <: UiWidget {
    private var _label: String
    private var _flags: PtrArray<Int32>
    private var _flagsValue: Int32

    /**
     * @brief[zh-cn] 构造位标志复选框
     * @param[zh-cn] label 标签
     * @param[zh-cn] flags 共享标志值（PtrArray<Int32> 单元素）
     * @param[zh-cn] flagsValue 本复选框控制的位
     *
     * @brief[en] Constructs a checkbox flags widget
     * @param[en] label Label text
     * @param[en] flags Shared flags value (single-element PtrArray<Int32>)
     * @param[en] flagsValue The bit(s) this checkbox controls
     */
    public init(label!: String, flags!: PtrArray<Int32>, flagsValue!: Int32) {
        super()
        this._label = label
        this._flags = flags
        this._flagsValue = flagsValue
    }

    /**
     * @brief[zh-cn] 渲染位标志复选框
     * @return[zh-cn] 本次标志位是否变化
     *
     * @brief[en] Renders the checkbox flags widget
     * @return[en] Whether the flags changed this frame
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        let cs = unsafe { LibC.mallocCString(this._label) }
        let r = igCheckboxFlags_IntPtr_cj(cs, this._flags.data(), this._flagsValue) != 0
        unsafe { LibC.free(cs) }
        return r
    }
}

// =============================================================================
// UiTheme — 内置主题
// =============================================================================

/**
 * @brief[zh-cn] 内置主题应用工具
 * @explain[zh-cn] 将 ImGui 内置配色方案应用到当前样式（在 ui 体或 onInit 中调用一次即可）。
 *
 * @brief[en] Built-in theme applier
 * @explain[en] Applies an ImGui built-in color scheme to the current style (call once in the ui body or onInit).
 */
public class UiTheme {
    private let _dummy: Int32 = 0

    /**
     * @brief[zh-cn] 构造主题工具（不可实例化使用，仅静态方法）
     *
     * @brief[en] Constructs the theme utility (static-only)
     */
    public init() {}

    /**
     * @brief[zh-cn] 应用深色主题（ImGui 默认）
     *
     * @brief[en] Applies the dark theme (ImGui default)
     */
    public static func applyDark(): Unit {
        igStyleColorsDark_cj(CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 应用浅色主题
     *
     * @brief[en] Applies the light theme
     */
    public static func applyLight(): Unit {
        igStyleColorsLight_cj(CPointer<Unit>())
    }

    /**
     * @brief[zh-cn] 应用经典主题
     *
     * @brief[en] Applies the classic theme
     */
    public static func applyClassic(): Unit {
        igStyleColorsClassic_cj(CPointer<Unit>())
    }
}

// =============================================================================
// UiStyleColor — 样式色查询
// =============================================================================

/**
 * @brief[zh-cn] 样式色查询工具
 * @explain[zh-cn] 读取 ImGui 当前样式色（含当前 alpha 修饰），返回 IM_COL32 格式 U32，可直接传给 UiDrawList。
 *
 * @brief[en] Style color query utility
 * @explain[en] Reads the current ImGui style color (with alpha modulation) as an IM_COL32 U32, directly usable by UiDrawList.
 */
public class UiStyleColor {
    private let _dummy: Int32 = 0

    /**
     * @brief[zh-cn] 构造样式色查询工具（仅静态方法）
     *
     * @brief[en] Constructs the style color query utility (static-only)
     */
    public init() {}

    /**
     * @brief[zh-cn] 按样式色索引取色
     * @param[zh-cn] col ImGuiCol 索引
     * @param[zh-cn] alphaMul 透明度乘数（1.0=不修改）
     * @return[zh-cn] IM_COL32 格式颜色
     *
     * @brief[en] Gets a style color by index
     * @param[en] col ImGuiCol index
     * @param[en] alphaMul Alpha multiplier (1.0=unchanged)
     * @return[en] Color in IM_COL32 format
     */
    public static func getU32(col: Int32, alphaMul!: Float32 = 1.0): UInt32 {
        return igGetColorU32_Col_cj(col, alphaMul)
    }

    /**
     * @brief[zh-cn] 按自定义颜色取色（经样式透明度修饰）
     * @param[zh-cn] col RGBA 颜色
     * @return[zh-cn] IM_COL32 格式颜色
     *
     * @brief[en] Gets a color from a custom RGBA (modulated by style alpha)
     * @param[en] col RGBA color
     * @return[en] Color in IM_COL32 format
     */
    public static func fromVec4(col: Color4): UInt32 {
        return igGetColorU32_Vec4_cj(ImVec4(Float32(col.r), Float32(col.g), Float32(col.b), Float32(col.a)))
    }

    /**
     * @brief[zh-cn] 按打包 U32 颜色取色（经样式透明度修饰）
     * @param[zh-cn] col IM_COL32 打包颜色
     * @param[zh-cn] alphaMul 透明度乘数
     * @return[zh-cn] IM_COL32 格式颜色
     *
     * @brief[en] Gets a color from a packed U32 (modulated by style alpha)
     * @param[en] col Packed IM_COL32 color
     * @param[en] alphaMul Alpha multiplier
     * @return[en] Color in IM_COL32 format
     */
    public static func fromU32(col: UInt32, alphaMul!: Float32 = 1.0): UInt32 {
        return igGetColorU32_U32_cj(col, alphaMul)
    }
}

// =============================================================================
// UiComboPreview — Combo 预览区
// =============================================================================

/**
 * @brief[zh-cn] Combo 下拉预览区控件
 * @explain[zh-cn] 在 BeginCombo/EndCombo 内部渲染自定义预览内容（如色块、图标），
 *   需配合 UiWindow 静态的 beginCombo/endCombo 或 UiCombo 使用。
 *
 * @brief[en] Combo dropdown preview widget
 * @explain[en] Renders custom preview content (color swatch, icon) inside BeginCombo/EndCombo;
 *   pair with the combo begin/end of UiWindow or UiCombo.
 */
public class UiComboPreview <: UiWidget {
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造 Combo 预览区
     * @param[zh-cn] content 预览内容渲染回调
     *
     * @brief[en] Constructs a combo preview
     * @param[en] content Preview content render callback
     */
    public init(content!: () -> Unit) {
        super()
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染 Combo 预览区（BeginComboPreview/EndComboPreview 包裹内容）
     * @return[zh-cn] 预览区是否可用（仅当处于 Combo 内部时为 true）
     *
     * @brief[en] Renders the combo preview (content wrapped in BeginComboPreview/EndComboPreview)
     * @return[en] Whether the preview area is available (true only inside a combo)
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        if (igBeginComboPreview_cj() == 0) {
            return false
        }
        this._content()
        igEndComboPreview_cj()
        return true
    }
}

// =============================================================================
// UiItemFlags — 项级开关（PushItemFlag/PopItemFlag）
// =============================================================================

/**
 * @brief[zh-cn] 项级开关容器（PushItemFlag/PopItemFlag 包裹内容）
 * @explain[zh-cn] 对容器内所有控件应用项级选项（如禁用 Tab 选中导航）。
 *
 * @brief[en] Item flag container (content wrapped in PushItemFlag/PopItemFlag)
 * @explain[en] Applies an item-level option (e.g. disabling tab navigation) to all widgets inside.
 */
public class UiItemFlags <: UiWidget {
    private var _option: Int32
    private var _enabled: Bool
    private var _content: () -> Unit

    /**
     * @brief[zh-cn] 构造项级开关容器
     * @param[zh-cn] option ImGuiItemFlags 选项
     * @param[zh-cn] enabled 是否启用
     * @param[zh-cn] content 容器内控件渲染回调
     *
     * @brief[en] Constructs an item flag container
     * @param[en] option ImGuiItemFlags option
     * @param[en] enabled Whether enabled
     * @param[en] content Render callback for widgets inside
     */
    public init(option!: Int32, enabled!: Bool, content!: () -> Unit) {
        super()
        this._option = option
        this._enabled = enabled
        this._content = content
    }

    /**
     * @brief[zh-cn] 渲染项级开关容器
     * @return[zh-cn] 控件交互结果，本控件恒为 false
     *
     * @brief[en] Renders the item flag container
     * @return[en] Widget interaction result; always false
     */
    public override func draw(): Bool {
        ensureCurrentContext()
        igPushItemFlag_cj(this._option, if (this._enabled) { 1 } else { 0 })
        this._content()
        igPopItemFlag_cj()
        return false
    }
}

// =============================================================================
// UiSystem — 剪贴板 / 鼠标拖拽 / 输入捕获
// =============================================================================

/**
 * @brief[zh-cn] 系统能力工具：剪贴板、鼠标拖拽判定、输入捕获
 *
 * @brief[en] System utilities: clipboard, mouse drag detection, input capture
 */
public class UiSystem {
    private let _dummy: Int32 = 0

    /**
     * @brief[zh-cn] 构造系统工具（仅静态方法）
     *
     * @brief[en] Constructs the system utility (static-only)
     */
    public init() {}

    // ===== 剪贴板 =====

    /**
     * @brief[zh-cn] 读取系统剪贴板文本
     * @return[zh-cn] 剪贴板内容（不可用时为空字符串）
     *
     * @brief[en] Reads the system clipboard text
     * @return[en] Clipboard content (empty string when unavailable)
     */
    public static func getClipboardText(): String {
        return igGetClipboardText_cj()
    }

    /**
     * @brief[zh-cn] 写入系统剪贴板文本
     * @param[zh-cn] text 要写入的文本
     *
     * @brief[en] Writes text to the system clipboard
     * @param[en] text Text to write
     */
    public static func setClipboardText(text: String): Unit {
        unsafe {
            let cs = LibC.mallocCString(text)
            igSetClipboardText_cj(cs)
            LibC.free(cs)
        }
    }

    // ===== 鼠标拖拽 =====

    /**
     * @brief[zh-cn] 判断指定鼠标键是否正在拖拽
     * @param[zh-cn] button 鼠标键（0=左, 1=右, 2=中）
     * @param[zh-cn] lockThreshold 启动拖拽的位移阈值（-1=使用默认）
     * @return[zh-cn] 是否正在拖拽
     *
     * @brief[en] Whether the given mouse button is dragging
     * @param[en] button Mouse button (0=left, 1=right, 2=middle)
     * @param[en] lockThreshold Drag lock threshold (-1=default)
     * @return[en] Whether dragging
     */
    public static func isMouseDragging(button!: Int32 = 0, lockThreshold!: Float32 = -1.0): Bool {
        return igIsMouseDragging_cj(button, lockThreshold) != 0
    }

    /**
     * @brief[zh-cn] 重置鼠标拖拽位移基准
     * @param[zh-cn] button 鼠标键
     *
     * @brief[en] Resets the mouse drag delta reference
     * @param[en] button Mouse button
     */
    public static func resetMouseDragDelta(button!: Int32 = 0): Unit {
        igResetMouseDragDelta_cj(button)
    }

    // ===== 输入捕获 =====

    /**
     * @brief[zh-cn] 请求下一帧捕获鼠标（游戏输入让位于 UI）
     * @param[zh-cn] want 是否捕获
     *
     * @brief[en] Requests mouse capture for the next frame (game input yields to UI)
     * @param[en] want Whether to capture
     */
    public static func wantCaptureMouseNextFrame(want: Bool): Unit {
        igSetNextFrameWantCaptureMouse_cj(if (want) { 1 } else { 0 })
    }

    /**
     * @brief[zh-cn] 请求下一帧捕获键盘（游戏快捷键让位于 UI 输入）
     * @param[zh-cn] want 是否捕获
     *
     * @brief[en] Requests keyboard capture for the next frame (game shortcuts yield to UI input)
     * @param[en] want Whether to capture
     */
    public static func wantCaptureKeyboardNextFrame(want: Bool): Unit {
        igSetNextFrameWantCaptureKeyboard_cj(if (want) { 1 } else { 0 })
    }

    // ===== IO 运行时状态查询（每帧由 NewFrame 更新） =====

    /**
     * @brief[zh-cn] 鼠标是否被 ImGui 捕获（为 true 时游戏/场景不应响应鼠标）
     *
     * @brief[en] Whether ImGui captures the mouse (do not dispatch to game/scene when true)
     */
    public static func isMouseCaptured(): Bool { return ImGui_IO_WantCaptureMouse_cj() }

    /**
     * @brief[zh-cn] 键盘是否被 ImGui 捕获（为 true 时游戏/场景不应响应键盘）
     *
     * @brief[en] Whether ImGui captures the keyboard (do not dispatch to game/scene when true)
     */
    public static func isKeyboardCaptured(): Bool { return ImGui_IO_WantCaptureKeyboard_cj() }

    /**
     * @brief[zh-cn] ImGui 是否需要文本输入（如 InputText 激活）
     *
     * @brief[en] Whether ImGui wants text input (e.g. InputText active)
     */
    public static func wantsTextInput(): Bool { return ImGui_IO_WantTextInput_cj() }

    /**
     * @brief[zh-cn] 帧率估计（60 帧滚动平均）
     *
     * @brief[en] Framerate estimate (60-frame rolling average)
     */
    public static func framerate(): Float32 { return ImGui_IO_Framerate_cj() }

    /**
     * @brief[zh-cn] 当前帧鼠标位置（无效时为 -FLT_MAX）
     *
     * @brief[en] Current-frame mouse position (-FLT_MAX when invalid)
     */
    public static func ioMousePos(): Vector2 {
        let v = ImGui_IO_MousePos_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 当前帧鼠标位移（任一位置无效时为零向量）
     *
     * @brief[en] Current-frame mouse delta (zero when either position is invalid)
     */
    public static func ioMouseDelta(): Vector2 {
        let v = ImGui_IO_MouseDelta_cj()
        return Vector2(Float64(v.x), Float64(v.y))
    }

    /**
     * @brief[zh-cn] 鼠标键按下状态
     * @param[zh-cn] button 鼠标键（0=左, 1=右, 2=中）
     *
     * @brief[en] Mouse button down state
     * @param[en] button Mouse button (0=left, 1=right, 2=middle)
     */
    public static func isIoMouseDown(button: Int32): Bool { return ImGui_IO_MouseDown_cj(button) }

    /**
     * @brief[zh-cn] 垂直滚轮增量（>0 上滚，<0 下滚）
     *
     * @brief[en] Vertical wheel delta (>0 up, <0 down)
     */
    public static func ioMouseWheel(): Float32 { return ImGui_IO_MouseWheel_cj() }

    /**
     * @brief[zh-cn] 水平滚轮增量（>0 左滚，<0 右滚）
     *
     * @brief[en] Horizontal wheel delta (>0 left, <0 right)
     */
    public static func ioMouseWheelH(): Float32 { return ImGui_IO_MouseWheelH_cj() }

    /**
     * @brief[zh-cn] Ctrl（macOS 上为 Cmd）是否按下
     *
     * @brief[en] Whether Ctrl (Cmd on macOS) is down
     */
    public static func isKeyCtrl(): Bool { return ImGui_IO_KeyCtrl_cj() }

    /**
     * @brief[zh-cn] Shift 是否按下
     *
     * @brief[en] Whether Shift is down
     */
    public static func isKeyShift(): Bool { return ImGui_IO_KeyShift_cj() }

    /**
     * @brief[zh-cn] Alt 是否按下
     *
     * @brief[en] Whether Alt is down
     */
    public static func isKeyAlt(): Bool { return ImGui_IO_KeyAlt_cj() }

    /**
     * @brief[zh-cn] Super（非 macOS 为 Win，macOS 为 Ctrl）是否按下
     *
     * @brief[en] Whether Super (Win key, Ctrl on macOS) is down
     */
    public static func isKeySuper(): Bool { return ImGui_IO_KeySuper_cj() }

    /**
     * @brief[zh-cn] 修饰键合并位掩码（ImGuiMod_Ctrl/Shift/Alt/Super 按位或）
     *
     * @brief[en] Merged modifier mask (bitwise-or of ImGuiMod_Ctrl/Shift/Alt/Super)
     */
    public static func keyMods(): Int32 { return ImGui_IO_KeyMods_cj() }
}
