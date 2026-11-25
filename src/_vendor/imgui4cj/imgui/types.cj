/**
 * @file ImGui 类型定义
 * @brief ImGui 枚举、标志位、结构体与常量定义
 * @explain 仓颉枚举是引用类型，不满足 CType 约束。foreign 函数使用 Int32
 *         作为 C 枚举的底层表示。调用方通过 `EnumType.value()` 和
 *         `EnumType.fromValue(v)` 进行转换。
 *         全部取值与 cxx/imgui/imgui.h（Dear ImGui v1.92.9）严格对齐；
 *         imgui.h 中已删除/改名的成员（如 FittingPolicyResizeDown、
 *         ImGuiTabItemFlags_NoOverlay、ImGuiColorEditFlags_AlphaPreview、
 *         DockingPreview/DockingEmptyBg 等）不再保留。
 * @note 位掩码标志使用 Int32 直接传递（对应 C 的 ImGuiWindowFlags 等 int 类型）。
 */
protected package three._vendor.imgui4cj.imgui

import std.collection.*

// =============================================================================
// 通用常量与工具
// =============================================================================

/// IM_COL32(r, g, b, a) 等价工具：将 RGBA 分量打包为 ImU32 颜色
public func imCol32(r: UInt32, g: UInt32, b: UInt32, a: UInt32): UInt32 {
    return (a << 24) | (b << 16) | (g << 8) | r
}

/// 白色（不透明）
public const IM_COL32_WHITE: UInt32 = 0xFFFFFFFF
/// 黑色（不透明）
public const IM_COL32_BLACK: UInt32 = 0xFF000000
/// 透明黑
public const IM_COL32_BLACK_TRANS: UInt32 = 0x00000000

/// ImGuiKeyChord：ImGuiKey 值可与 ImGuiMod_Ctrl 等按位或组合（如 Ctrl|S）
public type ImGuiKeyChord = Int32

// =============================================================================
// 结构体（C 布局，与 imgui.h ImVec2 / ImVec4 一致）
// =============================================================================

/// 2D 向量（位置、尺寸等）
@C
public struct ImVec2 {
    public var x: Float32
    public var y: Float32

    public init() {
        this.x = 0.0
        this.y = 0.0
    }

    public init(x: Float32, y: Float32) {
        this.x = x
        this.y = y
    }
}

/// 4D 向量/RGBA 颜色（0.0..1.0）
@C
public struct ImVec4 {
    public var x: Float32
    public var y: Float32
    public var z: Float32
    public var w: Float32

    public init() {
        this.x = 0.0
        this.y = 0.0
        this.z = 0.0
        this.w = 0.0
    }

    public init(x: Float32, y: Float32, z: Float32, w: Float32) {
        this.x = x
        this.y = y
        this.z = z
        this.w = w
    }
}


// =============================================================================
// ImGuiWindowFlags（对应 imgui.h ImGuiWindowFlags_）
// =============================================================================

/// 窗口标志（Begin / BeginChild）
public enum ImGuiWindowFlags {
    None | NoTitleBar | NoResize | NoMove |
    NoScrollbar| NoScrollWithMouse| NoCollapse| AlwaysAutoResize |
    NoBackground| NoSavedSettings| NoMouseInputs| MenuBar |
    HorizontalScrollbar| NoFocusOnAppearing| NoBringToFrontOnFocus| AlwaysVerticalScrollbar |
    AlwaysHorizontalScrollbar| NoNavInputs| NoNavFocus| UnsavedDocument |
    NoNav| NoDecoration| NoInputs| ChildWindow |
    Tooltip| Popup| Modal| ChildMenu

    public func value(): Int32 {
        match (this) {
            case None => 0
            case NoTitleBar => 1 << 0
            case NoResize => 1 << 1
            case NoMove => 1 << 2
            case NoScrollbar => 1 << 3
            case NoScrollWithMouse => 1 << 4
            case NoCollapse => 1 << 5
            case AlwaysAutoResize => 1 << 6
            case NoBackground => 1 << 7
            case NoSavedSettings => 1 << 8
            case NoMouseInputs => 1 << 9
            case MenuBar => 1 << 10
            case HorizontalScrollbar => 1 << 11
            case NoFocusOnAppearing => 1 << 12
            case NoBringToFrontOnFocus => 1 << 13
            case AlwaysVerticalScrollbar => 1 << 14
            case AlwaysHorizontalScrollbar => 1 << 15
            case NoNavInputs => 1 << 16
            case NoNavFocus => 1 << 17
            case UnsavedDocument => 1 << 18
            case NoNav => NoNavInputs.value() | NoNavFocus.value()
            case NoDecoration => NoTitleBar.value() | NoResize.value() | NoScrollbar.value() | NoCollapse.value()
            case NoInputs => NoMouseInputs.value() | NoNavInputs.value() | NoNavFocus.value()
            case ChildWindow => 1 << 24
            case Tooltip => 1 << 25
            case Popup => 1 << 26
            case Modal => 1 << 27
            case ChildMenu => 1 << 28
        }
    }

    public static func fromValue(v: Int32): ImGuiWindowFlags {
        if ((v & (1 << 0)) != 0) { return NoTitleBar }
        if ((v & (1 << 1)) != 0) { return NoResize }
        if ((v & (1 << 2)) != 0) { return NoMove }
        if ((v & (1 << 3)) != 0) { return NoScrollbar }
        if ((v & (1 << 4)) != 0) { return NoScrollWithMouse }
        if ((v & (1 << 5)) != 0) { return NoCollapse }
        if ((v & (1 << 6)) != 0) { return AlwaysAutoResize }
        if ((v & (1 << 7)) != 0) { return NoBackground }
        if ((v & (1 << 8)) != 0) { return NoSavedSettings }
        if ((v & (1 << 9)) != 0) { return NoMouseInputs }
        if ((v & (1 << 10)) != 0) { return MenuBar }
        if ((v & (1 << 11)) != 0) { return HorizontalScrollbar }
        if ((v & (1 << 12)) != 0) { return NoFocusOnAppearing }
        if ((v & (1 << 13)) != 0) { return NoBringToFrontOnFocus }
        if ((v & (1 << 14)) != 0) { return AlwaysVerticalScrollbar }
        if ((v & (1 << 15)) != 0) { return AlwaysHorizontalScrollbar }
        if ((v & (1 << 16)) != 0) { return NoNavInputs }
        if ((v & (1 << 17)) != 0) { return NoNavFocus }
        if ((v & (1 << 18)) != 0) { return UnsavedDocument }
        if ((v & (1 << 24)) != 0) { return ChildWindow }
        if ((v & (1 << 25)) != 0) { return Tooltip }
        if ((v & (1 << 26)) != 0) { return Popup }
        if ((v & (1 << 27)) != 0) { return Modal }
        if ((v & (1 << 28)) != 0) { return ChildMenu }
        return None
    }
}

// =============================================================================
// ImGuiCond（对应 imgui.h ImGuiCond_）
// =============================================================================

/// 条件标志（SetNextWindowPos / SetNextWindowSize 等）
public enum ImGuiCond {
    None | Always | Once | FirstUseEver |
    Appearing

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Always => 1 << 0
            case Once => 1 << 1
            case FirstUseEver => 1 << 2
            case Appearing => 1 << 3
        }
    }

    public static func fromValue(v: Int32): ImGuiCond {
        if ((v & (1 << 0)) != 0) { return Always }
        if ((v & (1 << 1)) != 0) { return Once }
        if ((v & (1 << 2)) != 0) { return FirstUseEver }
        if ((v & (1 << 3)) != 0) { return Appearing }
        return None
    }
}

// =============================================================================
// ImGuiColorEditFlags（对应 imgui.h ImGuiColorEditFlags_）
// =============================================================================

/// 颜色编辑/选择器标志（ColorEdit / ColorPicker / ColorButton）
public enum ImGuiColorEditFlags {
    None | NoAlpha | NoPicker | NoOptions |
    NoSmallPreview| NoInputs| NoTooltip| NoLabel |
    NoSidePreview| NoDragDrop| NoBorder| NoColorMarkers |
    AlphaOpaque| AlphaNoBg| AlphaPreviewHalf| AlphaBar |
    HDR| DisplayRGB| DisplayHSV| DisplayHex |
    Uint8| Float| PickerHueBar| PickerHueWheel |
    PickerNoRotate| InputRGB| InputHSV

    public func value(): Int32 {
        match (this) {
            case None => 0
            case NoAlpha => 1 << 1
            case NoPicker => 1 << 2
            case NoOptions => 1 << 3
            case NoSmallPreview => 1 << 4
            case NoInputs => 1 << 5
            case NoTooltip => 1 << 6
            case NoLabel => 1 << 7
            case NoSidePreview => 1 << 8
            case NoDragDrop => 1 << 9
            case NoBorder => 1 << 10
            case NoColorMarkers => 1 << 11
            case AlphaOpaque => 1 << 12
            case AlphaNoBg => 1 << 13
            case AlphaPreviewHalf => 1 << 14
            case AlphaBar => 1 << 18
            case HDR => 1 << 19
            case DisplayRGB => 1 << 20
            case DisplayHSV => 1 << 21
            case DisplayHex => 1 << 22
            case Uint8 => 1 << 23
            case Float => 1 << 24
            case PickerHueBar => 1 << 25
            case PickerHueWheel => 1 << 26
            case PickerNoRotate => 1 << 27
            case InputRGB => 1 << 28
            case InputHSV => 1 << 29
        }
    }

    public static func fromValue(v: Int32): ImGuiColorEditFlags {
        if ((v & (1 << 1)) != 0) { return NoAlpha }
        if ((v & (1 << 2)) != 0) { return NoPicker }
        if ((v & (1 << 3)) != 0) { return NoOptions }
        if ((v & (1 << 4)) != 0) { return NoSmallPreview }
        if ((v & (1 << 5)) != 0) { return NoInputs }
        if ((v & (1 << 6)) != 0) { return NoTooltip }
        if ((v & (1 << 7)) != 0) { return NoLabel }
        if ((v & (1 << 8)) != 0) { return NoSidePreview }
        if ((v & (1 << 9)) != 0) { return NoDragDrop }
        if ((v & (1 << 10)) != 0) { return NoBorder }
        if ((v & (1 << 11)) != 0) { return NoColorMarkers }
        if ((v & (1 << 12)) != 0) { return AlphaOpaque }
        if ((v & (1 << 13)) != 0) { return AlphaNoBg }
        if ((v & (1 << 14)) != 0) { return AlphaPreviewHalf }
        if ((v & (1 << 18)) != 0) { return AlphaBar }
        if ((v & (1 << 19)) != 0) { return HDR }
        if ((v & (1 << 20)) != 0) { return DisplayRGB }
        if ((v & (1 << 21)) != 0) { return DisplayHSV }
        if ((v & (1 << 22)) != 0) { return DisplayHex }
        if ((v & (1 << 23)) != 0) { return Uint8 }
        if ((v & (1 << 24)) != 0) { return Float }
        if ((v & (1 << 25)) != 0) { return PickerHueBar }
        if ((v & (1 << 26)) != 0) { return PickerHueWheel }
        if ((v & (1 << 27)) != 0) { return PickerNoRotate }
        if ((v & (1 << 28)) != 0) { return InputRGB }
        if ((v & (1 << 29)) != 0) { return InputHSV }
        return None
    }
}

// =============================================================================
// ImGuiSliderFlags（对应 imgui.h ImGuiSliderFlags_）
// =============================================================================

/// 滑块/拖拽标志（SliderFloat / DragFloat / SliderInt 等）
public enum ImGuiSliderFlags {
    None | Logarithmic | NoRoundToFormat | NoInput |
    WrapAround| ClampOnInput| ClampZeroRange| NoSpeedTweaks |
    ColorMarkers| AlwaysClamp

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Logarithmic => 1 << 5
            case NoRoundToFormat => 1 << 6
            case NoInput => 1 << 7
            case WrapAround => 1 << 8
            case ClampOnInput => 1 << 9
            case ClampZeroRange => 1 << 10
            case NoSpeedTweaks => 1 << 11
            case ColorMarkers => 1 << 12
            case AlwaysClamp => ClampOnInput.value() | ClampZeroRange.value()
        }
    }

    public static func fromValue(v: Int32): ImGuiSliderFlags {
        if ((v & (1 << 5)) != 0) { return Logarithmic }
        if ((v & (1 << 6)) != 0) { return NoRoundToFormat }
        if ((v & (1 << 7)) != 0) { return NoInput }
        if ((v & (1 << 8)) != 0) { return WrapAround }
        if ((v & (1 << 9)) != 0) { return ClampOnInput }
        if ((v & (1 << 10)) != 0) { return ClampZeroRange }
        if ((v & (1 << 11)) != 0) { return NoSpeedTweaks }
        if ((v & (1 << 12)) != 0) { return ColorMarkers }
        return None
    }
}

// =============================================================================
// ImGuiSelectableFlags（对应 imgui.h ImGuiSelectableFlags_）
// =============================================================================

/// 可选择项标志（Selectable）
public enum ImGuiSelectableFlags {
    None | NoAutoClosePopups | SpanAllColumns | AllowDoubleClick |
    Disabled| AllowOverlap| Highlight| SelectOnNav

    public func value(): Int32 {
        match (this) {
            case None => 0
            case NoAutoClosePopups => 1 << 0
            case SpanAllColumns => 1 << 1
            case AllowDoubleClick => 1 << 2
            case Disabled => 1 << 3
            case AllowOverlap => 1 << 4
            case Highlight => 1 << 5
            case SelectOnNav => 1 << 6
        }
    }

    public static func fromValue(v: Int32): ImGuiSelectableFlags {
        if ((v & (1 << 0)) != 0) { return NoAutoClosePopups }
        if ((v & (1 << 1)) != 0) { return SpanAllColumns }
        if ((v & (1 << 2)) != 0) { return AllowDoubleClick }
        if ((v & (1 << 3)) != 0) { return Disabled }
        if ((v & (1 << 4)) != 0) { return AllowOverlap }
        if ((v & (1 << 5)) != 0) { return Highlight }
        if ((v & (1 << 6)) != 0) { return SelectOnNav }
        return None
    }
}

// =============================================================================
// ImGuiTreeNodeFlags（对应 imgui.h ImGuiTreeNodeFlags_）
// =============================================================================

/// 树节点标志（TreeNode / TreeNodeEx / CollapsingHeader）
public enum ImGuiTreeNodeFlags {
    None | Selected | Framed | AllowOverlap |
    NoTreePushOnOpen| NoAutoOpenOnLog| DefaultOpen| OpenOnDoubleClick |
    OpenOnArrow| Leaf| Bullet| FramePadding |
    SpanAvailWidth| SpanFullWidth| SpanLabelWidth| SpanAllColumns |
    LabelSpanAllColumns| NavLeftJumpsToParent| CollapsingHeader| DrawLinesNone |
    DrawLinesFull| DrawLinesToNodes

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Selected => 1 << 0
            case Framed => 1 << 1
            case AllowOverlap => 1 << 2
            case NoTreePushOnOpen => 1 << 3
            case NoAutoOpenOnLog => 1 << 4
            case DefaultOpen => 1 << 5
            case OpenOnDoubleClick => 1 << 6
            case OpenOnArrow => 1 << 7
            case Leaf => 1 << 8
            case Bullet => 1 << 9
            case FramePadding => 1 << 10
            case SpanAvailWidth => 1 << 11
            case SpanFullWidth => 1 << 12
            case SpanLabelWidth => 1 << 13
            case SpanAllColumns => 1 << 14
            case LabelSpanAllColumns => 1 << 15
            case NavLeftJumpsToParent => 1 << 17
            case CollapsingHeader => Framed.value() | NoTreePushOnOpen.value() | NoAutoOpenOnLog.value()
            case DrawLinesNone => 1 << 18
            case DrawLinesFull => 1 << 19
            case DrawLinesToNodes => 1 << 20
        }
    }

    public static func fromValue(v: Int32): ImGuiTreeNodeFlags {
        if ((v & (1 << 0)) != 0) { return Selected }
        if ((v & (1 << 1)) != 0) { return Framed }
        if ((v & (1 << 2)) != 0) { return AllowOverlap }
        if ((v & (1 << 3)) != 0) { return NoTreePushOnOpen }
        if ((v & (1 << 4)) != 0) { return NoAutoOpenOnLog }
        if ((v & (1 << 5)) != 0) { return DefaultOpen }
        if ((v & (1 << 6)) != 0) { return OpenOnDoubleClick }
        if ((v & (1 << 7)) != 0) { return OpenOnArrow }
        if ((v & (1 << 8)) != 0) { return Leaf }
        if ((v & (1 << 9)) != 0) { return Bullet }
        if ((v & (1 << 10)) != 0) { return FramePadding }
        if ((v & (1 << 11)) != 0) { return SpanAvailWidth }
        if ((v & (1 << 12)) != 0) { return SpanFullWidth }
        if ((v & (1 << 13)) != 0) { return SpanLabelWidth }
        if ((v & (1 << 14)) != 0) { return SpanAllColumns }
        if ((v & (1 << 15)) != 0) { return LabelSpanAllColumns }
        if ((v & (1 << 17)) != 0) { return NavLeftJumpsToParent }
        if ((v & (1 << 18)) != 0) { return DrawLinesNone }
        if ((v & (1 << 19)) != 0) { return DrawLinesFull }
        if ((v & (1 << 20)) != 0) { return DrawLinesToNodes }
        return None
    }
}

// =============================================================================
// ImGuiInputTextFlags（对应 imgui.h ImGuiInputTextFlags_）
// =============================================================================

/// 文本输入标志（InputText / InputTextMultiline）
public enum ImGuiInputTextFlags {
    None | CharsDecimal | CharsHexadecimal | CharsScientific |
    CharsUppercase| CharsNoBlank| AllowTabInput| EnterReturnsTrue |
    EscapeClearsAll| CtrlEnterForNewLine| ReadOnly| Password |
    AlwaysOverwrite| AutoSelectAll| ParseEmptyRefVal| DisplayEmptyRefVal |
    NoHorizontalScroll| NoUndoRedo| ElideLeft| CallbackCompletion |
    CallbackHistory| CallbackAlways| CallbackCharFilter| CallbackResize |
    CallbackEdit| WordWrap

    public func value(): Int32 {
        match (this) {
            case None => 0
            case CharsDecimal => 1 << 0
            case CharsHexadecimal => 1 << 1
            case CharsScientific => 1 << 2
            case CharsUppercase => 1 << 3
            case CharsNoBlank => 1 << 4
            case AllowTabInput => 1 << 5
            case EnterReturnsTrue => 1 << 6
            case EscapeClearsAll => 1 << 7
            case CtrlEnterForNewLine => 1 << 8
            case ReadOnly => 1 << 9
            case Password => 1 << 10
            case AlwaysOverwrite => 1 << 11
            case AutoSelectAll => 1 << 12
            case ParseEmptyRefVal => 1 << 13
            case DisplayEmptyRefVal => 1 << 14
            case NoHorizontalScroll => 1 << 15
            case NoUndoRedo => 1 << 16
            case ElideLeft => 1 << 17
            case CallbackCompletion => 1 << 18
            case CallbackHistory => 1 << 19
            case CallbackAlways => 1 << 20
            case CallbackCharFilter => 1 << 21
            case CallbackResize => 1 << 22
            case CallbackEdit => 1 << 23
            case WordWrap => 1 << 24
        }
    }

    public static func fromValue(v: Int32): ImGuiInputTextFlags {
        if ((v & (1 << 0)) != 0) { return CharsDecimal }
        if ((v & (1 << 1)) != 0) { return CharsHexadecimal }
        if ((v & (1 << 2)) != 0) { return CharsScientific }
        if ((v & (1 << 3)) != 0) { return CharsUppercase }
        if ((v & (1 << 4)) != 0) { return CharsNoBlank }
        if ((v & (1 << 5)) != 0) { return AllowTabInput }
        if ((v & (1 << 6)) != 0) { return EnterReturnsTrue }
        if ((v & (1 << 7)) != 0) { return EscapeClearsAll }
        if ((v & (1 << 8)) != 0) { return CtrlEnterForNewLine }
        if ((v & (1 << 9)) != 0) { return ReadOnly }
        if ((v & (1 << 10)) != 0) { return Password }
        if ((v & (1 << 11)) != 0) { return AlwaysOverwrite }
        if ((v & (1 << 12)) != 0) { return AutoSelectAll }
        if ((v & (1 << 13)) != 0) { return ParseEmptyRefVal }
        if ((v & (1 << 14)) != 0) { return DisplayEmptyRefVal }
        if ((v & (1 << 15)) != 0) { return NoHorizontalScroll }
        if ((v & (1 << 16)) != 0) { return NoUndoRedo }
        if ((v & (1 << 17)) != 0) { return ElideLeft }
        if ((v & (1 << 18)) != 0) { return CallbackCompletion }
        if ((v & (1 << 19)) != 0) { return CallbackHistory }
        if ((v & (1 << 20)) != 0) { return CallbackAlways }
        if ((v & (1 << 21)) != 0) { return CallbackCharFilter }
        if ((v & (1 << 22)) != 0) { return CallbackResize }
        if ((v & (1 << 23)) != 0) { return CallbackEdit }
        if ((v & (1 << 24)) != 0) { return WordWrap }
        return None
    }
}

// =============================================================================
// ImGuiFocusedFlags（对应 imgui.h ImGuiFocusedFlags_）
// =============================================================================

/// 焦点查询标志（IsWindowFocused）
public enum ImGuiFocusedFlags {
    None | ChildWindows | RootWindow | AnyWindow |
    NoPopupHierarchy| RootAndChildWindows

    public func value(): Int32 {
        match (this) {
            case None => 0
            case ChildWindows => 1 << 0
            case RootWindow => 1 << 1
            case AnyWindow => 1 << 2
            case NoPopupHierarchy => 1 << 3
            case RootAndChildWindows => RootWindow.value() | ChildWindows.value()
        }
    }

    public static func fromValue(v: Int32): ImGuiFocusedFlags {
        if ((v & (1 << 0)) != 0) { return ChildWindows }
        if ((v & (1 << 1)) != 0) { return RootWindow }
        if ((v & (1 << 2)) != 0) { return AnyWindow }
        if ((v & (1 << 3)) != 0) { return NoPopupHierarchy }
        return None
    }
}

// =============================================================================
// ImGuiHoveredFlags（对应 imgui.h ImGuiHoveredFlags_）
// =============================================================================

/// 悬停查询标志（IsItemHovered / IsWindowHovered）
public enum ImGuiHoveredFlags {
    None | ChildWindows | RootWindow | AnyWindow |
    NoPopupHierarchy| AllowWhenBlockedByPopup| AllowWhenBlockedByActiveItem| AllowWhenOverlappedByItem |
    AllowWhenOverlappedByWindow| AllowWhenDisabled| NoNavOverride| AllowWhenOverlapped |
    RectOnly| RootAndChildWindows| ForTooltip| Stationary |
    DelayNone| DelayShort| DelayNormal| NoSharedDelay

    public func value(): Int32 {
        match (this) {
            case None => 0
            case ChildWindows => 1 << 0
            case RootWindow => 1 << 1
            case AnyWindow => 1 << 2
            case NoPopupHierarchy => 1 << 3
            case AllowWhenBlockedByPopup => 1 << 5
            case AllowWhenBlockedByActiveItem => 1 << 7
            case AllowWhenOverlappedByItem => 1 << 8
            case AllowWhenOverlappedByWindow => 1 << 9
            case AllowWhenDisabled => 1 << 10
            case NoNavOverride => 1 << 11
            case AllowWhenOverlapped => AllowWhenOverlappedByItem.value() | AllowWhenOverlappedByWindow.value()
            case RectOnly => AllowWhenBlockedByPopup.value() | AllowWhenBlockedByActiveItem.value() | AllowWhenOverlapped.value()
            case RootAndChildWindows => RootWindow.value() | ChildWindows.value()
            case ForTooltip => 1 << 12
            case Stationary => 1 << 13
            case DelayNone => 1 << 14
            case DelayShort => 1 << 15
            case DelayNormal => 1 << 16
            case NoSharedDelay => 1 << 17
        }
    }

    public static func fromValue(v: Int32): ImGuiHoveredFlags {
        if ((v & (1 << 0)) != 0) { return ChildWindows }
        if ((v & (1 << 1)) != 0) { return RootWindow }
        if ((v & (1 << 2)) != 0) { return AnyWindow }
        if ((v & (1 << 3)) != 0) { return NoPopupHierarchy }
        if ((v & (1 << 5)) != 0) { return AllowWhenBlockedByPopup }
        if ((v & (1 << 7)) != 0) { return AllowWhenBlockedByActiveItem }
        if ((v & (1 << 8)) != 0) { return AllowWhenOverlappedByItem }
        if ((v & (1 << 9)) != 0) { return AllowWhenOverlappedByWindow }
        if ((v & (1 << 10)) != 0) { return AllowWhenDisabled }
        if ((v & (1 << 11)) != 0) { return NoNavOverride }
        if ((v & (1 << 12)) != 0) { return ForTooltip }
        if ((v & (1 << 13)) != 0) { return Stationary }
        if ((v & (1 << 14)) != 0) { return DelayNone }
        if ((v & (1 << 15)) != 0) { return DelayShort }
        if ((v & (1 << 16)) != 0) { return DelayNormal }
        if ((v & (1 << 17)) != 0) { return NoSharedDelay }
        return None
    }
}

// =============================================================================
// ImGuiChildFlags（对应 imgui.h ImGuiChildFlags_）
// =============================================================================

/// 子窗口标志（BeginChild）
public enum ImGuiChildFlags {
    None | Borders | AlwaysUseWindowPadding | ResizeX |
    ResizeY| AutoResizeX| AutoResizeY| AlwaysAutoResize |
    FrameStyle| NavFlattened

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Borders => 1 << 0
            case AlwaysUseWindowPadding => 1 << 1
            case ResizeX => 1 << 2
            case ResizeY => 1 << 3
            case AutoResizeX => 1 << 4
            case AutoResizeY => 1 << 5
            case AlwaysAutoResize => 1 << 6
            case FrameStyle => 1 << 7
            case NavFlattened => 1 << 8
        }
    }

    public static func fromValue(v: Int32): ImGuiChildFlags {
        if ((v & (1 << 0)) != 0) { return Borders }
        if ((v & (1 << 1)) != 0) { return AlwaysUseWindowPadding }
        if ((v & (1 << 2)) != 0) { return ResizeX }
        if ((v & (1 << 3)) != 0) { return ResizeY }
        if ((v & (1 << 4)) != 0) { return AutoResizeX }
        if ((v & (1 << 5)) != 0) { return AutoResizeY }
        if ((v & (1 << 6)) != 0) { return AlwaysAutoResize }
        if ((v & (1 << 7)) != 0) { return FrameStyle }
        if ((v & (1 << 8)) != 0) { return NavFlattened }
        return None
    }
}

// =============================================================================
// ImGuiPopupFlags（对应 imgui.h ImGuiPopupFlags_）
// =============================================================================

/// 弹出窗口标志（OpenPopup* / BeginPopupContext* / IsPopupOpen）
public enum ImGuiPopupFlags {
    None | MouseButtonLeft | MouseButtonRight | MouseButtonMiddle |
    NoReopen| NoOpenOverExistingPopup| NoOpenOverItems| AnyPopupId |
    AnyPopupLevel| AnyPopup

    public func value(): Int32 {
        match (this) {
            case None => 0
            case MouseButtonLeft => 1 << 2
            case MouseButtonRight => 2 << 2
            case MouseButtonMiddle => 3 << 2
            case NoReopen => 1 << 5
            case NoOpenOverExistingPopup => 1 << 7
            case NoOpenOverItems => 1 << 8
            case AnyPopupId => 1 << 10
            case AnyPopupLevel => 1 << 11
            case AnyPopup => AnyPopupId.value() | AnyPopupLevel.value()
        }
    }

    public static func fromValue(v: Int32): ImGuiPopupFlags {
        if (v == MouseButtonLeft.value()) { return MouseButtonLeft }
        if (v == MouseButtonRight.value()) { return MouseButtonRight }
        if (v == MouseButtonMiddle.value()) { return MouseButtonMiddle }
        if (v == NoReopen.value()) { return NoReopen }
        if (v == NoOpenOverExistingPopup.value()) { return NoOpenOverExistingPopup }
        if (v == NoOpenOverItems.value()) { return NoOpenOverItems }
        if (v == AnyPopupId.value()) { return AnyPopupId }
        if (v == AnyPopupLevel.value()) { return AnyPopupLevel }
        if (v == AnyPopup.value()) { return AnyPopup }
        return None
    }
}

// =============================================================================
// ImGuiTabBarFlags（对应 imgui.h ImGuiTabBarFlags_）
// =============================================================================

/// 标签栏标志（BeginTabBar）
public enum ImGuiTabBarFlags {
    None | Reorderable | AutoSelectNewTabs | TabListPopupButton |
    NoCloseWithMiddleMouseButton| NoTabListScrollingButtons| NoTooltip| DrawSelectedOverline |
    FittingPolicyMixed| FittingPolicyShrink| FittingPolicyScroll

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Reorderable => 1 << 0
            case AutoSelectNewTabs => 1 << 1
            case TabListPopupButton => 1 << 2
            case NoCloseWithMiddleMouseButton => 1 << 3
            case NoTabListScrollingButtons => 1 << 4
            case NoTooltip => 1 << 5
            case DrawSelectedOverline => 1 << 6
            case FittingPolicyMixed => 1 << 7
            case FittingPolicyShrink => 1 << 8
            case FittingPolicyScroll => 1 << 9
        }
    }

    public static func fromValue(v: Int32): ImGuiTabBarFlags {
        if ((v & (1 << 0)) != 0) { return Reorderable }
        if ((v & (1 << 1)) != 0) { return AutoSelectNewTabs }
        if ((v & (1 << 2)) != 0) { return TabListPopupButton }
        if ((v & (1 << 3)) != 0) { return NoCloseWithMiddleMouseButton }
        if ((v & (1 << 4)) != 0) { return NoTabListScrollingButtons }
        if ((v & (1 << 5)) != 0) { return NoTooltip }
        if ((v & (1 << 6)) != 0) { return DrawSelectedOverline }
        if ((v & (1 << 7)) != 0) { return FittingPolicyMixed }
        if ((v & (1 << 8)) != 0) { return FittingPolicyShrink }
        if ((v & (1 << 9)) != 0) { return FittingPolicyScroll }
        return None
    }
}

// =============================================================================
// ImGuiTabItemFlags（对应 imgui.h ImGuiTabItemFlags_）
// =============================================================================

/// 标签项标志（BeginTabItem / TabItemButton）
public enum ImGuiTabItemFlags {
    None | UnsavedDocument | SetSelected | NoCloseWithMiddleMouseButton |
    NoPushId| NoTooltip| NoReorder| Leading |
    Trailing| NoAssumedClosure

    public func value(): Int32 {
        match (this) {
            case None => 0
            case UnsavedDocument => 1 << 0
            case SetSelected => 1 << 1
            case NoCloseWithMiddleMouseButton => 1 << 2
            case NoPushId => 1 << 3
            case NoTooltip => 1 << 4
            case NoReorder => 1 << 5
            case Leading => 1 << 6
            case Trailing => 1 << 7
            case NoAssumedClosure => 1 << 8
        }
    }

    public static func fromValue(v: Int32): ImGuiTabItemFlags {
        if ((v & (1 << 0)) != 0) { return UnsavedDocument }
        if ((v & (1 << 1)) != 0) { return SetSelected }
        if ((v & (1 << 2)) != 0) { return NoCloseWithMiddleMouseButton }
        if ((v & (1 << 3)) != 0) { return NoPushId }
        if ((v & (1 << 4)) != 0) { return NoTooltip }
        if ((v & (1 << 5)) != 0) { return NoReorder }
        if ((v & (1 << 6)) != 0) { return Leading }
        if ((v & (1 << 7)) != 0) { return Trailing }
        if ((v & (1 << 8)) != 0) { return NoAssumedClosure }
        return None
    }
}

// =============================================================================
// ImGuiTableFlags（对应 imgui.h ImGuiTableFlags_）
// =============================================================================

/// 表格标志（BeginTable）
public enum ImGuiTableFlags {
    None | Resizable | Reorderable | Hideable |
    Sortable| NoSavedSettings| ContextMenuInBody| RowBg |
    BordersInnerH| BordersOuterH| BordersInnerV| BordersOuterV |
    BordersH| BordersV| BordersInner| BordersOuter |
    Borders| NoBordersInBody| NoBordersInBodyUntilResize| SizingFixedFit |
    SizingFixedSame| SizingStretchProp| SizingStretchSame| NoHostExtendX |
    NoHostExtendY| NoKeepColumnsVisible| PreciseWidths| NoClip |
    PadOuterX| NoPadOuterX| NoPadInnerX| ScrollX |
    ScrollY| SortMulti| SortTristate| HighlightHoveredColumn

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Resizable => 1 << 0
            case Reorderable => 1 << 1
            case Hideable => 1 << 2
            case Sortable => 1 << 3
            case NoSavedSettings => 1 << 4
            case ContextMenuInBody => 1 << 5
            case RowBg => 1 << 6
            case BordersInnerH => 1 << 7
            case BordersOuterH => 1 << 8
            case BordersInnerV => 1 << 9
            case BordersOuterV => 1 << 10
            case BordersH => BordersInnerH.value() | BordersOuterH.value()
            case BordersV => BordersInnerV.value() | BordersOuterV.value()
            case BordersInner => BordersInnerH.value() | BordersInnerV.value()
            case BordersOuter => BordersOuterH.value() | BordersOuterV.value()
            case Borders => BordersH.value() | BordersV.value()
            case NoBordersInBody => 1 << 11
            case NoBordersInBodyUntilResize => 1 << 12
            case SizingFixedFit => 1 << 13
            case SizingFixedSame => 2 << 13
            case SizingStretchProp => 3 << 13
            case SizingStretchSame => 4 << 13
            case NoHostExtendX => 1 << 16
            case NoHostExtendY => 1 << 17
            case NoKeepColumnsVisible => 1 << 18
            case PreciseWidths => 1 << 19
            case NoClip => 1 << 20
            case PadOuterX => 1 << 21
            case NoPadOuterX => 1 << 22
            case NoPadInnerX => 1 << 23
            case ScrollX => 1 << 24
            case ScrollY => 1 << 25
            case SortMulti => 1 << 26
            case SortTristate => 1 << 27
            case HighlightHoveredColumn => 1 << 28
        }
    }

    public static func fromValue(v: Int32): ImGuiTableFlags {
        if (v == Resizable.value()) { return Resizable }
        if (v == Reorderable.value()) { return Reorderable }
        if (v == Hideable.value()) { return Hideable }
        if (v == Sortable.value()) { return Sortable }
        if (v == NoSavedSettings.value()) { return NoSavedSettings }
        if (v == ContextMenuInBody.value()) { return ContextMenuInBody }
        if (v == RowBg.value()) { return RowBg }
        if (v == BordersInnerH.value()) { return BordersInnerH }
        if (v == BordersOuterH.value()) { return BordersOuterH }
        if (v == BordersInnerV.value()) { return BordersInnerV }
        if (v == BordersOuterV.value()) { return BordersOuterV }
        if (v == BordersH.value()) { return BordersH }
        if (v == BordersV.value()) { return BordersV }
        if (v == BordersInner.value()) { return BordersInner }
        if (v == BordersOuter.value()) { return BordersOuter }
        if (v == Borders.value()) { return Borders }
        if (v == NoBordersInBody.value()) { return NoBordersInBody }
        if (v == NoBordersInBodyUntilResize.value()) { return NoBordersInBodyUntilResize }
        if (v == SizingFixedFit.value()) { return SizingFixedFit }
        if (v == SizingFixedSame.value()) { return SizingFixedSame }
        if (v == SizingStretchProp.value()) { return SizingStretchProp }
        if (v == SizingStretchSame.value()) { return SizingStretchSame }
        if (v == NoHostExtendX.value()) { return NoHostExtendX }
        if (v == NoHostExtendY.value()) { return NoHostExtendY }
        if (v == NoKeepColumnsVisible.value()) { return NoKeepColumnsVisible }
        if (v == PreciseWidths.value()) { return PreciseWidths }
        if (v == NoClip.value()) { return NoClip }
        if (v == PadOuterX.value()) { return PadOuterX }
        if (v == NoPadOuterX.value()) { return NoPadOuterX }
        if (v == NoPadInnerX.value()) { return NoPadInnerX }
        if (v == ScrollX.value()) { return ScrollX }
        if (v == ScrollY.value()) { return ScrollY }
        if (v == SortMulti.value()) { return SortMulti }
        if (v == SortTristate.value()) { return SortTristate }
        if (v == HighlightHoveredColumn.value()) { return HighlightHoveredColumn }
        return None
    }
}

// =============================================================================
// ImGuiTableColumnFlags（对应 imgui.h ImGuiTableColumnFlags_）
// =============================================================================

/// 表格列标志（TableSetupColumn / TableGetColumnFlags）
public enum ImGuiTableColumnFlags {
    None | Disabled | DefaultHide | DefaultSort |
    WidthStretch| WidthFixed| NoResize| NoReorder |
    NoHide| NoClip| NoSort| NoSortAscending |
    NoSortDescending| NoHeaderLabel| NoHeaderWidth| PreferSortAscending |
    PreferSortDescending| IndentEnable| IndentDisable| AngledHeader |
    IsEnabled| IsVisible| IsSorted| IsHovered

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Disabled => 1 << 0
            case DefaultHide => 1 << 1
            case DefaultSort => 1 << 2
            case WidthStretch => 1 << 3
            case WidthFixed => 1 << 4
            case NoResize => 1 << 5
            case NoReorder => 1 << 6
            case NoHide => 1 << 7
            case NoClip => 1 << 8
            case NoSort => 1 << 9
            case NoSortAscending => 1 << 10
            case NoSortDescending => 1 << 11
            case NoHeaderLabel => 1 << 12
            case NoHeaderWidth => 1 << 13
            case PreferSortAscending => 1 << 14
            case PreferSortDescending => 1 << 15
            case IndentEnable => 1 << 16
            case IndentDisable => 1 << 17
            case AngledHeader => 1 << 18
            case IsEnabled => 1 << 24
            case IsVisible => 1 << 25
            case IsSorted => 1 << 26
            case IsHovered => 1 << 27
        }
    }

    public static func fromValue(v: Int32): ImGuiTableColumnFlags {
        if ((v & (1 << 0)) != 0) { return Disabled }
        if ((v & (1 << 1)) != 0) { return DefaultHide }
        if ((v & (1 << 2)) != 0) { return DefaultSort }
        if ((v & (1 << 3)) != 0) { return WidthStretch }
        if ((v & (1 << 4)) != 0) { return WidthFixed }
        if ((v & (1 << 5)) != 0) { return NoResize }
        if ((v & (1 << 6)) != 0) { return NoReorder }
        if ((v & (1 << 7)) != 0) { return NoHide }
        if ((v & (1 << 8)) != 0) { return NoClip }
        if ((v & (1 << 9)) != 0) { return NoSort }
        if ((v & (1 << 10)) != 0) { return NoSortAscending }
        if ((v & (1 << 11)) != 0) { return NoSortDescending }
        if ((v & (1 << 12)) != 0) { return NoHeaderLabel }
        if ((v & (1 << 13)) != 0) { return NoHeaderWidth }
        if ((v & (1 << 14)) != 0) { return PreferSortAscending }
        if ((v & (1 << 15)) != 0) { return PreferSortDescending }
        if ((v & (1 << 16)) != 0) { return IndentEnable }
        if ((v & (1 << 17)) != 0) { return IndentDisable }
        if ((v & (1 << 18)) != 0) { return AngledHeader }
        if ((v & (1 << 24)) != 0) { return IsEnabled }
        if ((v & (1 << 25)) != 0) { return IsVisible }
        if ((v & (1 << 26)) != 0) { return IsSorted }
        if ((v & (1 << 27)) != 0) { return IsHovered }
        return None
    }
}

// =============================================================================
// ImGuiTableRowFlags（对应 imgui.h ImGuiTableRowFlags_）
// =============================================================================

/// 表格行标志（TableNextRow）
public enum ImGuiTableRowFlags {
    None | Headers

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Headers => 1 << 0
        }
    }

    public static func fromValue(v: Int32): ImGuiTableRowFlags {
        if ((v & (1 << 0)) != 0) { return Headers }
        return None
    }
}

// =============================================================================
// ImGuiTableBgTarget（对应 imgui.h ImGuiTableBgTarget_）
// =============================================================================

/// 表格背景目标（TableSetBgColor）
public enum ImGuiTableBgTarget {
    None | RowBg0 | RowBg1 | CellBg

    public func value(): Int32 {
        match (this) {
            case None => 0
            case RowBg0 => 1
            case RowBg1 => 2
            case CellBg => 3
        }
    }

    public static func fromValue(v: Int32): ImGuiTableBgTarget {
        if (v == RowBg0.value()) { return RowBg0 }
        if (v == RowBg1.value()) { return RowBg1 }
        if (v == CellBg.value()) { return CellBg }
        return None
    }
}

// =============================================================================
// ImGuiButtonFlags（对应 imgui.h ImGuiButtonFlags_）
// =============================================================================

/// 按钮标志（InvisibleButton）
public enum ImGuiButtonFlags {
    None | MouseButtonLeft | MouseButtonRight | MouseButtonMiddle |
    EnableNav| AllowOverlap

    public func value(): Int32 {
        match (this) {
            case None => 0
            case MouseButtonLeft => 1 << 0
            case MouseButtonRight => 1 << 1
            case MouseButtonMiddle => 1 << 2
            case EnableNav => 1 << 3
            case AllowOverlap => 1 << 12
        }
    }

    public static func fromValue(v: Int32): ImGuiButtonFlags {
        if ((v & (1 << 0)) != 0) { return MouseButtonLeft }
        if ((v & (1 << 1)) != 0) { return MouseButtonRight }
        if ((v & (1 << 2)) != 0) { return MouseButtonMiddle }
        if ((v & (1 << 3)) != 0) { return EnableNav }
        if ((v & (1 << 12)) != 0) { return AllowOverlap }
        return None
    }
}

// =============================================================================
// ImGuiComboFlags（对应 imgui.h ImGuiComboFlags_）
// =============================================================================

/// 下拉框标志（BeginCombo）
public enum ImGuiComboFlags {
    None | PopupAlignLeft | HeightSmall | HeightRegular |
    HeightLarge| HeightLargest| NoArrowButton| NoPreview |
    WidthFitPreview

    public func value(): Int32 {
        match (this) {
            case None => 0
            case PopupAlignLeft => 1 << 0
            case HeightSmall => 1 << 1
            case HeightRegular => 1 << 2
            case HeightLarge => 1 << 3
            case HeightLargest => 1 << 4
            case NoArrowButton => 1 << 5
            case NoPreview => 1 << 6
            case WidthFitPreview => 1 << 7
        }
    }

    public static func fromValue(v: Int32): ImGuiComboFlags {
        if ((v & (1 << 0)) != 0) { return PopupAlignLeft }
        if ((v & (1 << 1)) != 0) { return HeightSmall }
        if ((v & (1 << 2)) != 0) { return HeightRegular }
        if ((v & (1 << 3)) != 0) { return HeightLarge }
        if ((v & (1 << 4)) != 0) { return HeightLargest }
        if ((v & (1 << 5)) != 0) { return NoArrowButton }
        if ((v & (1 << 6)) != 0) { return NoPreview }
        if ((v & (1 << 7)) != 0) { return WidthFitPreview }
        return None
    }
}

// =============================================================================
// ImGuiDragDropFlags（对应 imgui.h ImGuiDragDropFlags_）
// =============================================================================

/// 拖放标志（BeginDragDropSource / AcceptDragDropPayload）
public enum ImGuiDragDropFlags {
    None | SourceNoPreviewTooltip | SourceNoDisableHover | SourceNoHoldToOpenOthers |
    SourceAllowNullID| SourceExtern| PayloadAutoExpire| PayloadNoCrossContext |
    PayloadNoCrossProcess| AcceptBeforeDelivery| AcceptNoDrawDefaultRect| AcceptNoPreviewTooltip |
    AcceptDrawAsHovered| AcceptPeekOnly

    public func value(): Int32 {
        match (this) {
            case None => 0
            case SourceNoPreviewTooltip => 1 << 0
            case SourceNoDisableHover => 1 << 1
            case SourceNoHoldToOpenOthers => 1 << 2
            case SourceAllowNullID => 1 << 3
            case SourceExtern => 1 << 4
            case PayloadAutoExpire => 1 << 5
            case PayloadNoCrossContext => 1 << 6
            case PayloadNoCrossProcess => 1 << 7
            case AcceptBeforeDelivery => 1 << 10
            case AcceptNoDrawDefaultRect => 1 << 11
            case AcceptNoPreviewTooltip => 1 << 12
            case AcceptDrawAsHovered => 1 << 13
            case AcceptPeekOnly => AcceptBeforeDelivery.value() | AcceptNoDrawDefaultRect.value()
        }
    }

    public static func fromValue(v: Int32): ImGuiDragDropFlags {
        if ((v & (1 << 0)) != 0) { return SourceNoPreviewTooltip }
        if ((v & (1 << 1)) != 0) { return SourceNoDisableHover }
        if ((v & (1 << 2)) != 0) { return SourceNoHoldToOpenOthers }
        if ((v & (1 << 3)) != 0) { return SourceAllowNullID }
        if ((v & (1 << 4)) != 0) { return SourceExtern }
        if ((v & (1 << 5)) != 0) { return PayloadAutoExpire }
        if ((v & (1 << 6)) != 0) { return PayloadNoCrossContext }
        if ((v & (1 << 7)) != 0) { return PayloadNoCrossProcess }
        if ((v & (1 << 10)) != 0) { return AcceptBeforeDelivery }
        if ((v & (1 << 11)) != 0) { return AcceptNoDrawDefaultRect }
        if ((v & (1 << 12)) != 0) { return AcceptNoPreviewTooltip }
        if ((v & (1 << 13)) != 0) { return AcceptDrawAsHovered }
        return None
    }
}

// =============================================================================
// ImGuiMultiSelectFlags（对应 imgui.h ImGuiMultiSelectFlags_）
// =============================================================================

/// 多选标志（BeginMultiSelect）
public enum ImGuiMultiSelectFlags {
    None | SingleSelect | NoSelectAll | NoRangeSelect |
    NoAutoSelect| NoAutoClear| NoAutoClearOnReselect| BoxSelect1d |
    BoxSelect2d| BoxSelectNoScroll| ClearOnEscape| ClearOnClickVoid |
    ScopeWindow| ScopeRect| SelectOnAuto| SelectOnClickAlways |
    SelectOnClickRelease| NavWrapX| NoSelectOnRightClick

    public func value(): Int32 {
        match (this) {
            case None => 0
            case SingleSelect => 1 << 0
            case NoSelectAll => 1 << 1
            case NoRangeSelect => 1 << 2
            case NoAutoSelect => 1 << 3
            case NoAutoClear => 1 << 4
            case NoAutoClearOnReselect => 1 << 5
            case BoxSelect1d => 1 << 6
            case BoxSelect2d => 1 << 7
            case BoxSelectNoScroll => 1 << 8
            case ClearOnEscape => 1 << 9
            case ClearOnClickVoid => 1 << 10
            case ScopeWindow => 1 << 11
            case ScopeRect => 1 << 12
            case SelectOnAuto => 1 << 13
            case SelectOnClickAlways => 1 << 14
            case SelectOnClickRelease => 1 << 15
            case NavWrapX => 1 << 16
            case NoSelectOnRightClick => 1 << 17
        }
    }

    public static func fromValue(v: Int32): ImGuiMultiSelectFlags {
        if ((v & (1 << 0)) != 0) { return SingleSelect }
        if ((v & (1 << 1)) != 0) { return NoSelectAll }
        if ((v & (1 << 2)) != 0) { return NoRangeSelect }
        if ((v & (1 << 3)) != 0) { return NoAutoSelect }
        if ((v & (1 << 4)) != 0) { return NoAutoClear }
        if ((v & (1 << 5)) != 0) { return NoAutoClearOnReselect }
        if ((v & (1 << 6)) != 0) { return BoxSelect1d }
        if ((v & (1 << 7)) != 0) { return BoxSelect2d }
        if ((v & (1 << 8)) != 0) { return BoxSelectNoScroll }
        if ((v & (1 << 9)) != 0) { return ClearOnEscape }
        if ((v & (1 << 10)) != 0) { return ClearOnClickVoid }
        if ((v & (1 << 11)) != 0) { return ScopeWindow }
        if ((v & (1 << 12)) != 0) { return ScopeRect }
        if ((v & (1 << 13)) != 0) { return SelectOnAuto }
        if ((v & (1 << 14)) != 0) { return SelectOnClickAlways }
        if ((v & (1 << 15)) != 0) { return SelectOnClickRelease }
        if ((v & (1 << 16)) != 0) { return NavWrapX }
        if ((v & (1 << 17)) != 0) { return NoSelectOnRightClick }
        return None
    }
}

// =============================================================================
// ImGuiItemFlags（对应 imgui.h ImGuiItemFlags_）
// =============================================================================

/// 条目通用标志（PushItemFlag）
public enum ImGuiItemFlags {
    None | NoTabStop | NoNav | NoNavDefaultFocus |
    ButtonRepeat| AutoClosePopups| AllowDuplicateId| Disabled |
    LiveEditOnInputText| LiveEditOnInputScalar| LiveEditOnInput

    public func value(): Int32 {
        match (this) {
            case None => 0
            case NoTabStop => 1 << 0
            case NoNav => 1 << 1
            case NoNavDefaultFocus => 1 << 2
            case ButtonRepeat => 1 << 3
            case AutoClosePopups => 1 << 4
            case AllowDuplicateId => 1 << 5
            case Disabled => 1 << 6
            case LiveEditOnInputText => 1 << 7
            case LiveEditOnInputScalar => 1 << 8
            case LiveEditOnInput => LiveEditOnInputText.value() | LiveEditOnInputScalar.value()
        }
    }

    public static func fromValue(v: Int32): ImGuiItemFlags {
        if ((v & (1 << 0)) != 0) { return NoTabStop }
        if ((v & (1 << 1)) != 0) { return NoNav }
        if ((v & (1 << 2)) != 0) { return NoNavDefaultFocus }
        if ((v & (1 << 3)) != 0) { return ButtonRepeat }
        if ((v & (1 << 4)) != 0) { return AutoClosePopups }
        if ((v & (1 << 5)) != 0) { return AllowDuplicateId }
        if ((v & (1 << 6)) != 0) { return Disabled }
        if ((v & (1 << 7)) != 0) { return LiveEditOnInputText }
        if ((v & (1 << 8)) != 0) { return LiveEditOnInputScalar }
        return None
    }
}

// =============================================================================
// ImDrawFlags（对应 imgui.h ImDrawFlags_）
// =============================================================================

/// 绘制标志（DrawList AddRect / PathRect / PathStroke 等）
public enum ImDrawFlags {
    None | RoundCornersTopLeft | RoundCornersTopRight | RoundCornersBottomLeft |
    RoundCornersBottomRight| RoundCornersNone| RoundCornersAll| RoundCornersTop |
    RoundCornersBottom| RoundCornersLeft| RoundCornersRight| Closed

    public func value(): Int32 {
        match (this) {
            case None => 0
            case RoundCornersTopLeft => 1 << 4
            case RoundCornersTopRight => 1 << 5
            case RoundCornersBottomLeft => 1 << 6
            case RoundCornersBottomRight => 1 << 7
            case RoundCornersNone => 1 << 8
            case RoundCornersAll => RoundCornersTopLeft.value() | RoundCornersTopRight.value() | RoundCornersBottomLeft.value() | RoundCornersBottomRight.value()
            case RoundCornersTop => RoundCornersTopLeft.value() | RoundCornersTopRight.value()
            case RoundCornersBottom => RoundCornersBottomLeft.value() | RoundCornersBottomRight.value()
            case RoundCornersLeft => RoundCornersBottomLeft.value() | RoundCornersTopLeft.value()
            case RoundCornersRight => RoundCornersBottomRight.value() | RoundCornersTopRight.value()
            case Closed => 1 << 9
        }
    }

    public static func fromValue(v: Int32): ImDrawFlags {
        if ((v & (1 << 4)) != 0) { return RoundCornersTopLeft }
        if ((v & (1 << 5)) != 0) { return RoundCornersTopRight }
        if ((v & (1 << 6)) != 0) { return RoundCornersBottomLeft }
        if ((v & (1 << 7)) != 0) { return RoundCornersBottomRight }
        if ((v & (1 << 8)) != 0) { return RoundCornersNone }
        if ((v & (1 << 9)) != 0) { return Closed }
        return None
    }
}

// =============================================================================
// ImGuiInputFlags（对应 imgui.h ImGuiInputFlags_）
// =============================================================================

/// 输入路由标志（Shortcut / SetNextItemShortcut）
public enum ImGuiInputFlags {
    None | Repeat | RouteActive | RouteFocused |
    RouteGlobal| RouteAlways| RouteOverFocused| RouteOverActive |
    RouteUnlessBgFocused| RouteFromRootWindow| Tooltip

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Repeat => 1 << 0
            case RouteActive => 1 << 10
            case RouteFocused => 1 << 11
            case RouteGlobal => 1 << 12
            case RouteAlways => 1 << 13
            case RouteOverFocused => 1 << 14
            case RouteOverActive => 1 << 15
            case RouteUnlessBgFocused => 1 << 16
            case RouteFromRootWindow => 1 << 17
            case Tooltip => 1 << 18
        }
    }

    public static func fromValue(v: Int32): ImGuiInputFlags {
        if ((v & (1 << 0)) != 0) { return Repeat }
        if ((v & (1 << 10)) != 0) { return RouteActive }
        if ((v & (1 << 11)) != 0) { return RouteFocused }
        if ((v & (1 << 12)) != 0) { return RouteGlobal }
        if ((v & (1 << 13)) != 0) { return RouteAlways }
        if ((v & (1 << 14)) != 0) { return RouteOverFocused }
        if ((v & (1 << 15)) != 0) { return RouteOverActive }
        if ((v & (1 << 16)) != 0) { return RouteUnlessBgFocused }
        if ((v & (1 << 17)) != 0) { return RouteFromRootWindow }
        if ((v & (1 << 18)) != 0) { return Tooltip }
        return None
    }
}

// =============================================================================
// ImGuiConfigFlags（对应 imgui.h ImGuiConfigFlags_）
// =============================================================================

/// 配置标志（io.ConfigFlags）
public enum ImGuiConfigFlags {
    None | NavEnableKeyboard | NavEnableGamepad | NoMouse |
    NoMouseCursorChange| NoKeyboard| IsSRGB| IsTouchScreen

    public func value(): Int32 {
        match (this) {
            case None => 0
            case NavEnableKeyboard => 1 << 0
            case NavEnableGamepad => 1 << 1
            case NoMouse => 1 << 4
            case NoMouseCursorChange => 1 << 5
            case NoKeyboard => 1 << 6
            case IsSRGB => 1 << 20
            case IsTouchScreen => 1 << 21
        }
    }

    public static func fromValue(v: Int32): ImGuiConfigFlags {
        if ((v & (1 << 0)) != 0) { return NavEnableKeyboard }
        if ((v & (1 << 1)) != 0) { return NavEnableGamepad }
        if ((v & (1 << 4)) != 0) { return NoMouse }
        if ((v & (1 << 5)) != 0) { return NoMouseCursorChange }
        if ((v & (1 << 6)) != 0) { return NoKeyboard }
        if ((v & (1 << 20)) != 0) { return IsSRGB }
        if ((v & (1 << 21)) != 0) { return IsTouchScreen }
        return None
    }
}

// =============================================================================
// ImGuiBackendFlags（对应 imgui.h ImGuiBackendFlags_）
// =============================================================================

/// 后端能力标志（io.BackendFlags）
public enum ImGuiBackendFlags {
    None | HasGamepad | HasMouseCursors | HasSetMousePos |
    RendererHasVtxOffset| RendererHasTextures

    public func value(): Int32 {
        match (this) {
            case None => 0
            case HasGamepad => 1 << 0
            case HasMouseCursors => 1 << 1
            case HasSetMousePos => 1 << 2
            case RendererHasVtxOffset => 1 << 3
            case RendererHasTextures => 1 << 4
        }
    }

    public static func fromValue(v: Int32): ImGuiBackendFlags {
        if ((v & (1 << 0)) != 0) { return HasGamepad }
        if ((v & (1 << 1)) != 0) { return HasMouseCursors }
        if ((v & (1 << 2)) != 0) { return HasSetMousePos }
        if ((v & (1 << 3)) != 0) { return RendererHasVtxOffset }
        if ((v & (1 << 4)) != 0) { return RendererHasTextures }
        return None
    }
}

// =============================================================================
// ImGuiMod（对应 imgui.h ImGuiMod_）
// =============================================================================

/// 键盘修饰键（可与 ImGuiKey 组成 ImGuiKeyChord，如 ModCtrl | KeyS）
public enum ImGuiMod {
    None | Ctrl | Shift | Alt |
    Super

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Ctrl => 1 << 12
            case Shift => 1 << 13
            case Alt => 1 << 14
            case Super => 1 << 15
        }
    }

    public static func fromValue(v: Int32): ImGuiMod {
        if ((v & (1 << 12)) != 0) { return Ctrl }
        if ((v & (1 << 13)) != 0) { return Shift }
        if ((v & (1 << 14)) != 0) { return Alt }
        if ((v & (1 << 15)) != 0) { return Super }
        return None
    }
}

// =============================================================================
// ImGuiCol（对应 imgui.h ImGuiCol_）
// =============================================================================

/// 颜色标识（PushStyleColor / GetColorU32 / GetStyleColorName）
public enum ImGuiCol {
    Text | TextDisabled | WindowBg | ChildBg |
    PopupBg| Border| BorderShadow| FrameBg |
    FrameBgHovered| FrameBgActive| TitleBg| TitleBgActive |
    TitleBgCollapsed| MenuBarBg| ScrollbarBg| ScrollbarGrab |
    ScrollbarGrabHovered| ScrollbarGrabActive| CheckMark| CheckboxSelectedBg |
    SliderGrab| SliderGrabActive| Button| ButtonHovered |
    ButtonActive| Header| HeaderHovered| HeaderActive |
    Separator| SeparatorHovered| SeparatorActive| ResizeGrip |
    ResizeGripHovered| ResizeGripActive| InputTextCursor| TabHovered |
    Tab| TabSelected| TabSelectedOverline| TabDimmed |
    TabDimmedSelected| TabDimmedSelectedOverline| PlotLines| PlotLinesHovered |
    PlotHistogram| PlotHistogramHovered| TableHeaderBg| TableBorderStrong |
    TableBorderLight| TableRowBg| TableRowBgAlt| TextLink |
    TextSelectedBg| TreeLines| DragDropTarget| DragDropTargetBg |
    UnsavedMarker| NavCursor| NavWindowingHighlight| NavWindowingDimBg |
    ModalWindowDimBg

    public func value(): Int32 {
        match (this) {
            case Text => 0
            case TextDisabled => 1
            case WindowBg => 2
            case ChildBg => 3
            case PopupBg => 4
            case Border => 5
            case BorderShadow => 6
            case FrameBg => 7
            case FrameBgHovered => 8
            case FrameBgActive => 9
            case TitleBg => 10
            case TitleBgActive => 11
            case TitleBgCollapsed => 12
            case MenuBarBg => 13
            case ScrollbarBg => 14
            case ScrollbarGrab => 15
            case ScrollbarGrabHovered => 16
            case ScrollbarGrabActive => 17
            case CheckMark => 18
            case CheckboxSelectedBg => 19
            case SliderGrab => 20
            case SliderGrabActive => 21
            case Button => 22
            case ButtonHovered => 23
            case ButtonActive => 24
            case Header => 25
            case HeaderHovered => 26
            case HeaderActive => 27
            case Separator => 28
            case SeparatorHovered => 29
            case SeparatorActive => 30
            case ResizeGrip => 31
            case ResizeGripHovered => 32
            case ResizeGripActive => 33
            case InputTextCursor => 34
            case TabHovered => 35
            case Tab => 36
            case TabSelected => 37
            case TabSelectedOverline => 38
            case TabDimmed => 39
            case TabDimmedSelected => 40
            case TabDimmedSelectedOverline => 41
            case PlotLines => 42
            case PlotLinesHovered => 43
            case PlotHistogram => 44
            case PlotHistogramHovered => 45
            case TableHeaderBg => 46
            case TableBorderStrong => 47
            case TableBorderLight => 48
            case TableRowBg => 49
            case TableRowBgAlt => 50
            case TextLink => 51
            case TextSelectedBg => 52
            case TreeLines => 53
            case DragDropTarget => 54
            case DragDropTargetBg => 55
            case UnsavedMarker => 56
            case NavCursor => 57
            case NavWindowingHighlight => 58
            case NavWindowingDimBg => 59
            case ModalWindowDimBg => 60
        }
    }
}

// =============================================================================
// ImGuiStyleVar（对应 imgui.h ImGuiStyleVar_）
// =============================================================================

/// 样式变量标识（PushStyleVar / GetStyleVar）
public enum ImGuiStyleVar {
    Alpha | DisabledAlpha | WindowPadding | WindowRounding |
    WindowBorderSize| WindowMinSize| WindowTitleAlign| ChildRounding |
    ChildBorderSize| PopupRounding| PopupBorderSize| FramePadding |
    FrameRounding| FrameBorderSize| ItemSpacing| ItemInnerSpacing |
    IndentSpacing| CellPadding| ScrollbarSize| ScrollbarRounding |
    ScrollbarPadding| GrabMinSize| GrabRounding| ImageRounding |
    ImageBorderSize| TabRounding| TabBorderSize| TabMinWidthBase |
    TabMinWidthShrink| TabBarBorderSize| TabBarOverlineSize| TableAngledHeadersAngle |
    TableAngledHeadersTextAlign| TreeLinesSize| TreeLinesRounding| MenuItemRounding |
    SelectableRounding| DragDropTargetRounding| ButtonTextAlign| SelectableTextAlign |
    SeparatorSize| SeparatorTextBorderSize| SeparatorTextAlign| SeparatorTextPadding

    public func value(): Int32 {
        match (this) {
            case Alpha => 0
            case DisabledAlpha => 1
            case WindowPadding => 2
            case WindowRounding => 3
            case WindowBorderSize => 4
            case WindowMinSize => 5
            case WindowTitleAlign => 6
            case ChildRounding => 7
            case ChildBorderSize => 8
            case PopupRounding => 9
            case PopupBorderSize => 10
            case FramePadding => 11
            case FrameRounding => 12
            case FrameBorderSize => 13
            case ItemSpacing => 14
            case ItemInnerSpacing => 15
            case IndentSpacing => 16
            case CellPadding => 17
            case ScrollbarSize => 18
            case ScrollbarRounding => 19
            case ScrollbarPadding => 20
            case GrabMinSize => 21
            case GrabRounding => 22
            case ImageRounding => 23
            case ImageBorderSize => 24
            case TabRounding => 25
            case TabBorderSize => 26
            case TabMinWidthBase => 27
            case TabMinWidthShrink => 28
            case TabBarBorderSize => 29
            case TabBarOverlineSize => 30
            case TableAngledHeadersAngle => 31
            case TableAngledHeadersTextAlign => 32
            case TreeLinesSize => 33
            case TreeLinesRounding => 34
            case MenuItemRounding => 35
            case SelectableRounding => 36
            case DragDropTargetRounding => 37
            case ButtonTextAlign => 38
            case SelectableTextAlign => 39
            case SeparatorSize => 40
            case SeparatorTextBorderSize => 41
            case SeparatorTextAlign => 42
            case SeparatorTextPadding => 43
        }
    }
}

// =============================================================================
// ImGuiDir（对应 imgui.h ImGuiDir_）
// =============================================================================

/// 方向标识（ArrowButton / DockBuilderSplitNode）
public enum ImGuiDir {
    None | Left | Right | Up |
    Down

    public func value(): Int32 {
        match (this) {
            case None => -1
            case Left => 0
            case Right => 1
            case Up => 2
            case Down => 3
        }
    }
}

// =============================================================================
// ImGuiDataType（对应 imgui.h ImGuiDataType_）
// =============================================================================

/// 基础数据类型标识（SliderScalar / DragScalar / InputScalar）
public enum ImGuiDataType {
    S8 | U8 | S16 | U16 |
    S32| U32| S64| U64 |
    Float| Double| `Bool`| String

    public func value(): Int32 {
        match (this) {
            case S8 => 0
            case U8 => 1
            case S16 => 2
            case U16 => 3
            case S32 => 4
            case U32 => 5
            case S64 => 6
            case U64 => 7
            case Float => 8
            case Double => 9
            case `Bool` => 10
            case String => 11
        }
    }
}

// =============================================================================
// ImGuiMouseButton（对应 imgui.h ImGuiMouseButton_）
// =============================================================================

/// 鼠标按键标识（0=左，1=右，2=中）
public enum ImGuiMouseButton {
    Left | Right | Middle

    public func value(): Int32 {
        match (this) {
            case Left => 0
            case Right => 1
            case Middle => 2
        }
    }
}

// =============================================================================
// ImGuiMouseCursor（对应 imgui.h ImGuiMouseCursor_）
// =============================================================================

/// 鼠标光标形状（GetMouseCursor / SetMouseCursor）
public enum ImGuiMouseCursor {
    None | Arrow | TextInput | ResizeAll |
    ResizeNS| ResizeEW| ResizeNESW| ResizeNWSE |
    Hand| Wait| Progress| NotAllowed

    public func value(): Int32 {
        match (this) {
            case None => -1
            case Arrow => 0
            case TextInput => 1
            case ResizeAll => 2
            case ResizeNS => 3
            case ResizeEW => 4
            case ResizeNESW => 5
            case ResizeNWSE => 6
            case Hand => 7
            case Wait => 8
            case Progress => 9
            case NotAllowed => 10
        }
    }
}

// =============================================================================
// ImGuiSortDirection（对应 imgui.h ImGuiSortDirection_）
// =============================================================================

/// 排序方向（表格排序规格）
public enum ImGuiSortDirection {
    None | Ascending | Descending

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Ascending => 1
            case Descending => 2
        }
    }
}

// =============================================================================
// ImGuiKey（对应 imgui.h ImGuiKey_）
// =============================================================================

/// 按键标识（命名键从 512 开始；可与 ImGuiMod 组成 ImGuiKeyChord）
public enum ImGuiKey {
    None | Tab | LeftArrow | RightArrow |
    UpArrow| DownArrow| PageUp| PageDown |
    Home| End| Insert| Delete |
    Backspace| Space| Enter| Escape |
    LeftCtrl| LeftShift| LeftAlt| LeftSuper |
    RightCtrl| RightShift| RightAlt| RightSuper |
    Menu| Digit0| Digit1| Digit2 |
    Digit3| Digit4| Digit5| Digit6 |
    Digit7| Digit8| Digit9| A |
    B| C| D| E |
    F| G| H| I |
    J| K| L| M |
    N| O| P| Q |
    R| S| T| U |
    V| W| X| Y |
    Z| F1| F2| F3 |
    F4| F5| F6| F7 |
    F8| F9| F10| F11 |
    F12| F13| F14| F15 |
    F16| F17| F18| F19 |
    F20| F21| F22| F23 |
    F24| Apostrophe| Comma| Minus |
    Period| Slash| Semicolon| Equal |
    LeftBracket| Backslash| RightBracket| GraveAccent |
    CapsLock| ScrollLock| NumLock| PrintScreen |
    Pause| Keypad0| Keypad1| Keypad2 |
    Keypad3| Keypad4| Keypad5| Keypad6 |
    Keypad7| Keypad8| Keypad9| KeypadDecimal |
    KeypadDivide| KeypadMultiply| KeypadSubtract| KeypadAdd |
    KeypadEnter| KeypadEqual| AppBack| AppForward |
    Oem102| GamepadStart| GamepadBack| GamepadFaceLeft |
    GamepadFaceRight| GamepadFaceUp| GamepadFaceDown| GamepadDpadLeft |
    GamepadDpadRight| GamepadDpadUp| GamepadDpadDown| GamepadL1 |
    GamepadR1| GamepadL2| GamepadR2| GamepadL3 |
    GamepadR3| GamepadLStickLeft| GamepadLStickRight| GamepadLStickUp |
    GamepadLStickDown| GamepadRStickLeft| GamepadRStickRight| GamepadRStickUp |
    GamepadRStickDown| MouseLeft| MouseRight| MouseMiddle |
    MouseX1| MouseX2| MouseWheelX| MouseWheelY |
    ReservedForModCtrl| ReservedForModShift| ReservedForModAlt| ReservedForModSuper

    public func value(): Int32 {
        match (this) {
            case None => 0
            case Tab => 512
            case LeftArrow => 513
            case RightArrow => 514
            case UpArrow => 515
            case DownArrow => 516
            case PageUp => 517
            case PageDown => 518
            case Home => 519
            case End => 520
            case Insert => 521
            case Delete => 522
            case Backspace => 523
            case Space => 524
            case Enter => 525
            case Escape => 526
            case LeftCtrl => 527
            case LeftShift => 528
            case LeftAlt => 529
            case LeftSuper => 530
            case RightCtrl => 531
            case RightShift => 532
            case RightAlt => 533
            case RightSuper => 534
            case Menu => 535
            case Digit0 => 536
            case Digit1 => 537
            case Digit2 => 538
            case Digit3 => 539
            case Digit4 => 540
            case Digit5 => 541
            case Digit6 => 542
            case Digit7 => 543
            case Digit8 => 544
            case Digit9 => 545
            case A => 546
            case B => 547
            case C => 548
            case D => 549
            case E => 550
            case F => 551
            case G => 552
            case H => 553
            case I => 554
            case J => 555
            case K => 556
            case L => 557
            case M => 558
            case N => 559
            case O => 560
            case P => 561
            case Q => 562
            case R => 563
            case S => 564
            case T => 565
            case U => 566
            case V => 567
            case W => 568
            case X => 569
            case Y => 570
            case Z => 571
            case F1 => 572
            case F2 => 573
            case F3 => 574
            case F4 => 575
            case F5 => 576
            case F6 => 577
            case F7 => 578
            case F8 => 579
            case F9 => 580
            case F10 => 581
            case F11 => 582
            case F12 => 583
            case F13 => 584
            case F14 => 585
            case F15 => 586
            case F16 => 587
            case F17 => 588
            case F18 => 589
            case F19 => 590
            case F20 => 591
            case F21 => 592
            case F22 => 593
            case F23 => 594
            case F24 => 595
            case Apostrophe => 596
            case Comma => 597
            case Minus => 598
            case Period => 599
            case Slash => 600
            case Semicolon => 601
            case Equal => 602
            case LeftBracket => 603
            case Backslash => 604
            case RightBracket => 605
            case GraveAccent => 606
            case CapsLock => 607
            case ScrollLock => 608
            case NumLock => 609
            case PrintScreen => 610
            case Pause => 611
            case Keypad0 => 612
            case Keypad1 => 613
            case Keypad2 => 614
            case Keypad3 => 615
            case Keypad4 => 616
            case Keypad5 => 617
            case Keypad6 => 618
            case Keypad7 => 619
            case Keypad8 => 620
            case Keypad9 => 621
            case KeypadDecimal => 622
            case KeypadDivide => 623
            case KeypadMultiply => 624
            case KeypadSubtract => 625
            case KeypadAdd => 626
            case KeypadEnter => 627
            case KeypadEqual => 628
            case AppBack => 629
            case AppForward => 630
            case Oem102 => 631
            case GamepadStart => 632
            case GamepadBack => 633
            case GamepadFaceLeft => 634
            case GamepadFaceRight => 635
            case GamepadFaceUp => 636
            case GamepadFaceDown => 637
            case GamepadDpadLeft => 638
            case GamepadDpadRight => 639
            case GamepadDpadUp => 640
            case GamepadDpadDown => 641
            case GamepadL1 => 642
            case GamepadR1 => 643
            case GamepadL2 => 644
            case GamepadR2 => 645
            case GamepadL3 => 646
            case GamepadR3 => 647
            case GamepadLStickLeft => 648
            case GamepadLStickRight => 649
            case GamepadLStickUp => 650
            case GamepadLStickDown => 651
            case GamepadRStickLeft => 652
            case GamepadRStickRight => 653
            case GamepadRStickUp => 654
            case GamepadRStickDown => 655
            case MouseLeft => 656
            case MouseRight => 657
            case MouseMiddle => 658
            case MouseX1 => 659
            case MouseX2 => 660
            case MouseWheelX => 661
            case MouseWheelY => 662
            case ReservedForModCtrl => 663
            case ReservedForModShift => 664
            case ReservedForModAlt => 665
            case ReservedForModSuper => 666
        }
    }
}

/// 组合多个窗口标志
public func combineWindowFlags(flags: ArrayList<ImGuiWindowFlags>): Int32 {
    var r: Int32 = 0
    for (f in flags) {
        r = r | f.value()
    }
    return r
}

// =============================================================================
// ImGuiKey 相关常量
// =============================================================================

/// 首个命名键值（除 0 外的第一个有效键值）
public const ImGuiKeyNamedKeyBegin: Int32 = 512
/// 命名键结束值（不含）
public const ImGuiKeyNamedKeyEnd: Int32 = 667
/// 命名键数量
public const ImGuiKeyNamedKeyCount: Int32 = 155
/// ImGuiMod 组合位掩码
public const ImGuiModMask: Int32 = 0xF000

// =============================================================================
// 结构体字段访问（C 布局，与 imgui.h Dear ImGui v1.92.9 严格对齐）
// @explain ImGuiIO / ImGuiStyle / ImGuiInputTextCallbackData 在 ffi.cj 中以
//         CPointer<Unit> 透传，此处定义同布局的 @C struct，通过指针重解释
//         直接读写字段（与 sdl4cj 的 SDL_Event 处理方式一致）。
// @note ImGuiIO 定义截断至 keyMods（KeysData[] 之前）——所有常用运行时状态
//         字段均在此范围内；截断不影响前缀字段的偏移，写回时仅覆盖已定义字节。
// @note ImGuiIO 尾部（KeysData[]、MouseClickedPos[5] 等）未定义，如需访问再补。
// =============================================================================

/// ImGuiIO（imgui.h struct ImGuiIO，截断至 keyMods；对应字节偏移 0..268）
@C
public struct ImGuiIO {
    public var configFlags: Int32                  // @0
    public var backendFlags: Int32                 // @4
    public var displaySize: ImVec2                 // @8
    public var displayFramebufferScale: ImVec2     // @16
    public var deltaTime: Float32                  // @24
    public var iniSavingRate: Float32              // @28
    public var iniFilename: CPointer<UInt8>        // @32
    public var logFilename: CPointer<UInt8>        // @40
    public var userData: CPointer<Unit>            // @48
    public var fonts: CPointer<Unit>               // @56
    public var fontDefault: CPointer<Unit>         // @64
    // @72..83：12 个连续 bool 配置位
    public var fontAllowUserScaling: Bool
    public var configNavSwapGamepadButtons: Bool
    public var configNavMoveSetMousePos: Bool
    public var configNavCaptureKeyboard: Bool
    public var configNavEscapeClearFocusItem: Bool
    public var configNavEscapeClearFocusWindow: Bool
    public var configNavCursorVisibleAuto: Bool
    public var configNavCursorVisibleAlways: Bool
    public var configMacOSXBehaviors: Bool
    public var configInputTrickleEventQueue: Bool
    public var configInputTextCursorBlink: Bool
    public var configInputTextEnterKeepActive: Bool
    public var configColorEditFlags: Int32         // @84
    // @88..93：6 个连续 bool 配置位
    public var configDragClickToInputText: Bool
    public var configWindowsResizeFromEdges: Bool
    public var configWindowsMoveFromTitleBarOnly: Bool
    public var configWindowsCopyContentsWithCtrlC: Bool
    public var configScrollbarScrollByPage: Bool
    public var configIniSettingsSaveLastUsedDate: Bool
    public var configIniSettingsAutoDiscardMonths: Int32 // @96
    // @100..101
    public var configDebugIniSettings: Bool
    public var mouseDrawCursor: Bool
    public var configMemoryCompactTimer: Float32   // @104
    public var mouseDoubleClickTime: Float32       // @108
    public var mouseDoubleClickMaxDist: Float32    // @112
    public var mouseSingleClickDelay: Float32      // @116
    public var mouseDragThreshold: Float32         // @120
    public var keyRepeatDelay: Float32             // @124
    public var keyRepeatRate: Float32              // @128
    // @132..135：错误恢复配置
    public var configErrorRecovery: Bool
    public var configErrorRecoveryEnableAssert: Bool
    public var configErrorRecoveryEnableDebugLog: Bool
    public var configErrorRecoveryEnableTooltip: Bool
    // @136..141：调试配置
    public var configDebugIsDebuggerPresent: Bool
    public var configDebugHighlightIdConflicts: Bool
    public var configDebugHighlightIdConflictsShowItemPicker: Bool
    public var configDebugBeginReturnValueOnce: Bool
    public var configDebugBeginReturnValueLoop: Bool
    public var configDebugIgnoreFocusLoss: Bool
    public var backendPlatformName: CPointer<UInt8>   // @144
    public var backendRendererName: CPointer<UInt8>   // @152
    public var backendPlatformUserData: CPointer<Unit> // @160
    public var backendRendererUserData: CPointer<Unit> // @168
    public var backendLanguageUserData: CPointer<Unit> // @176
    // ===== 运行时状态（每帧由 NewFrame 更新）=====
    public var wantCaptureMouse: Bool              // @184
    public var wantCaptureKeyboard: Bool           // @185
    public var wantTextInput: Bool                 // @186
    public var wantSetMousePos: Bool               // @187
    public var wantSaveIniSettings: Bool           // @188
    public var navActive: Bool                     // @189
    public var navVisible: Bool                    // @190
    public var framerate: Float32                  // @192
    public var metricsRenderVertices: Int32        // @196
    public var metricsRenderIndices: Int32         // @200
    public var metricsRenderWindows: Int32         // @204
    public var metricsActiveWindows: Int32         // @208
    public var mouseDelta: ImVec2                  // @212
    public var ctx: CPointer<Unit>                 // @224
    public var mousePos: ImVec2                    // @232
    public var mouseDown: VArray<Bool, $5>         // @240（5 字节）
    public var mouseWheel: Float32                 // @248
    public var mouseWheelH: Float32                // @252
    public var mouseSource: Int32                  // @256（ImGuiMouseSource）
    public var keyCtrl: Bool                       // @260
    public var keyShift: Bool                      // @261
    public var keyAlt: Bool                        // @262
    public var keySuper: Bool                      // @263
    public var keyMods: Int32                      // @264（ImGuiMod 按位或）

    public init() {
        this.configFlags = 0
        this.backendFlags = 0
        this.displaySize = ImVec2()
        this.displayFramebufferScale = ImVec2()
        this.deltaTime = 0.0
        this.iniSavingRate = 0.0
        this.iniFilename = CPointer<UInt8>()
        this.logFilename = CPointer<UInt8>()
        this.userData = CPointer<Unit>()
        this.fonts = CPointer<Unit>()
        this.fontDefault = CPointer<Unit>()
        this.fontAllowUserScaling = false
        this.configNavSwapGamepadButtons = false
        this.configNavMoveSetMousePos = false
        this.configNavCaptureKeyboard = false
        this.configNavEscapeClearFocusItem = false
        this.configNavEscapeClearFocusWindow = false
        this.configNavCursorVisibleAuto = false
        this.configNavCursorVisibleAlways = false
        this.configMacOSXBehaviors = false
        this.configInputTrickleEventQueue = false
        this.configInputTextCursorBlink = false
        this.configInputTextEnterKeepActive = false
        this.configColorEditFlags = 0
        this.configDragClickToInputText = false
        this.configWindowsResizeFromEdges = false
        this.configWindowsMoveFromTitleBarOnly = false
        this.configWindowsCopyContentsWithCtrlC = false
        this.configScrollbarScrollByPage = false
        this.configIniSettingsSaveLastUsedDate = false
        this.configIniSettingsAutoDiscardMonths = 0
        this.configDebugIniSettings = false
        this.mouseDrawCursor = false
        this.configMemoryCompactTimer = 0.0
        this.mouseDoubleClickTime = 0.0
        this.mouseDoubleClickMaxDist = 0.0
        this.mouseSingleClickDelay = 0.0
        this.mouseDragThreshold = 0.0
        this.keyRepeatDelay = 0.0
        this.keyRepeatRate = 0.0
        this.configErrorRecovery = false
        this.configErrorRecoveryEnableAssert = false
        this.configErrorRecoveryEnableDebugLog = false
        this.configErrorRecoveryEnableTooltip = false
        this.configDebugIsDebuggerPresent = false
        this.configDebugHighlightIdConflicts = false
        this.configDebugHighlightIdConflictsShowItemPicker = false
        this.configDebugBeginReturnValueOnce = false
        this.configDebugBeginReturnValueLoop = false
        this.configDebugIgnoreFocusLoss = false
        this.backendPlatformName = CPointer<UInt8>()
        this.backendRendererName = CPointer<UInt8>()
        this.backendPlatformUserData = CPointer<Unit>()
        this.backendRendererUserData = CPointer<Unit>()
        this.backendLanguageUserData = CPointer<Unit>()
        this.wantCaptureMouse = false
        this.wantCaptureKeyboard = false
        this.wantTextInput = false
        this.wantSetMousePos = false
        this.wantSaveIniSettings = false
        this.navActive = false
        this.navVisible = false
        this.framerate = 0.0
        this.metricsRenderVertices = 0
        this.metricsRenderIndices = 0
        this.metricsRenderWindows = 0
        this.metricsActiveWindows = 0
        this.mouseDelta = ImVec2()
        this.ctx = CPointer<Unit>()
        this.mousePos = ImVec2()
        this.mouseDown = VArray<Bool, $5>(repeat: false)
        this.mouseWheel = 0.0
        this.mouseWheelH = 0.0
        this.mouseSource = 0
        this.keyCtrl = false
        this.keyShift = false
        this.keyAlt = false
        this.keySuper = false
        this.keyMods = 0
    }
}

/// ImGuiStyle（imgui.h struct ImGuiStyle，截断至 colors；对应字节偏移 0..1080）
@C
public struct ImGuiStyle {
    public var fontSizeBase: Float32               // @0
    public var fontScaleMain: Float32              // @4
    public var fontScaleDpi: Float32               // @8
    public var alpha: Float32                      // @12
    public var disabledAlpha: Float32              // @16
    public var windowPadding: ImVec2               // @20
    public var windowRounding: Float32             // @28
    public var windowBorderSize: Float32           // @32
    public var windowBorderHoverPadding: Float32   // @36
    public var windowMinSize: ImVec2               // @40
    public var windowTitleAlign: ImVec2            // @48
    public var windowMenuButtonPosition: Int32     // @56（ImGuiDir）
    public var childRounding: Float32              // @60
    public var childBorderSize: Float32            // @64
    public var popupRounding: Float32              // @68
    public var popupBorderSize: Float32            // @72
    public var framePadding: ImVec2                // @76
    public var frameRounding: Float32              // @84
    public var frameBorderSize: Float32            // @88
    public var itemSpacing: ImVec2                 // @92
    public var itemInnerSpacing: ImVec2            // @100
    public var cellPadding: ImVec2                 // @108
    public var touchExtraPadding: ImVec2           // @116
    public var indentSpacing: Float32              // @124
    public var columnsMinSpacing: Float32          // @128
    public var scrollbarSize: Float32              // @132
    public var scrollbarRounding: Float32          // @136
    public var scrollbarPadding: Float32           // @140
    public var grabMinSize: Float32                // @144
    public var grabRounding: Float32               // @148
    public var logSliderDeadzone: Float32          // @152
    public var imageRounding: Float32              // @156
    public var imageBorderSize: Float32            // @160
    public var tabRounding: Float32                // @164
    public var tabBorderSize: Float32              // @168
    public var tabMinWidthBase: Float32            // @172
    public var tabMinWidthShrink: Float32          // @176
    public var tabCloseButtonMinWidthSelected: Float32    // @180
    public var tabCloseButtonMinWidthUnselected: Float32  // @184
    public var tabBarBorderSize: Float32           // @188
    public var tabBarOverlineSize: Float32         // @192
    public var tableAngledHeadersAngle: Float32    // @196
    public var tableAngledHeadersTextAlign: ImVec2 // @200
    public var treeLinesFlags: Int32               // @208（ImGuiTreeNodeFlags）
    public var treeLinesSize: Float32              // @212
    public var treeLinesRounding: Float32          // @216
    public var menuItemRounding: Float32           // @220
    public var selectableRounding: Float32         // @224
    public var dragDropTargetRounding: Float32     // @228
    public var dragDropTargetBorderSize: Float32   // @232
    public var dragDropTargetPadding: Float32      // @236
    public var colorMarkerSize: Float32            // @240
    public var colorButtonPosition: Int32          // @244（ImGuiDir）
    public var buttonTextAlign: ImVec2             // @248
    public var selectableTextAlign: ImVec2         // @256
    public var inputTextCursorSize: Float32        // @264
    public var separatorSize: Float32              // @268
    public var separatorTextBorderSize: Float32    // @272
    public var separatorTextAlign: ImVec2          // @276
    public var separatorTextPadding: ImVec2        // @284
    public var displayWindowPadding: ImVec2        // @292
    public var displaySafeAreaPadding: ImVec2      // @300
    public var mouseCursorScale: Float32           // @308
    public var antiAliasedLines: Bool              // @312
    public var antiAliasedLinesUseTex: Bool        // @313
    public var antiAliasedFill: Bool               // @314
    public var curveTessellationTol: Float32       // @316
    public var circleTessellationMaxError: Float32 // @320
    public var colors: VArray<ImVec4, $66>         // @324（ImGuiCol_COUNT == 66）

    public init() {
        this.fontSizeBase = 0.0
        this.fontScaleMain = 0.0
        this.fontScaleDpi = 0.0
        this.alpha = 0.0
        this.disabledAlpha = 0.0
        this.windowPadding = ImVec2()
        this.windowRounding = 0.0
        this.windowBorderSize = 0.0
        this.windowBorderHoverPadding = 0.0
        this.windowMinSize = ImVec2()
        this.windowTitleAlign = ImVec2()
        this.windowMenuButtonPosition = 0
        this.childRounding = 0.0
        this.childBorderSize = 0.0
        this.popupRounding = 0.0
        this.popupBorderSize = 0.0
        this.framePadding = ImVec2()
        this.frameRounding = 0.0
        this.frameBorderSize = 0.0
        this.itemSpacing = ImVec2()
        this.itemInnerSpacing = ImVec2()
        this.cellPadding = ImVec2()
        this.touchExtraPadding = ImVec2()
        this.indentSpacing = 0.0
        this.columnsMinSpacing = 0.0
        this.scrollbarSize = 0.0
        this.scrollbarRounding = 0.0
        this.scrollbarPadding = 0.0
        this.grabMinSize = 0.0
        this.grabRounding = 0.0
        this.logSliderDeadzone = 0.0
        this.imageRounding = 0.0
        this.imageBorderSize = 0.0
        this.tabRounding = 0.0
        this.tabBorderSize = 0.0
        this.tabMinWidthBase = 0.0
        this.tabMinWidthShrink = 0.0
        this.tabCloseButtonMinWidthSelected = 0.0
        this.tabCloseButtonMinWidthUnselected = 0.0
        this.tabBarBorderSize = 0.0
        this.tabBarOverlineSize = 0.0
        this.tableAngledHeadersAngle = 0.0
        this.tableAngledHeadersTextAlign = ImVec2()
        this.treeLinesFlags = 0
        this.treeLinesSize = 0.0
        this.treeLinesRounding = 0.0
        this.menuItemRounding = 0.0
        this.selectableRounding = 0.0
        this.dragDropTargetRounding = 0.0
        this.dragDropTargetBorderSize = 0.0
        this.dragDropTargetPadding = 0.0
        this.colorMarkerSize = 0.0
        this.colorButtonPosition = 0
        this.buttonTextAlign = ImVec2()
        this.selectableTextAlign = ImVec2()
        this.inputTextCursorSize = 0.0
        this.separatorSize = 0.0
        this.separatorTextBorderSize = 0.0
        this.separatorTextAlign = ImVec2()
        this.separatorTextPadding = ImVec2()
        this.displayWindowPadding = ImVec2()
        this.displaySafeAreaPadding = ImVec2()
        this.mouseCursorScale = 0.0
        this.antiAliasedLines = false
        this.antiAliasedLinesUseTex = false
        this.antiAliasedFill = false
        this.curveTessellationTol = 0.0
        this.circleTessellationMaxError = 0.0
        this.colors = VArray<ImVec4, $66>(repeat: ImVec4())
    }
}

/// ImGuiInputTextCallbackData（imgui.h 同名结构体，完整定义）
@C
public struct ImGuiInputTextCallbackData {
    public var ctx: CPointer<Unit>            // @0（ImGuiContext*）
    public var eventFlag: Int32               // @8（ImGuiInputTextFlags_Callback*，只读）
    public var flags: Int32                   // @12（用户传入的 flags，只读）
    public var userData: CPointer<Unit>       // @16（只读）
    public var id: UInt32                     // @24（ImGuiID，只读）
    public var eventKey: Int32                // @28（ImGuiKey，只读）
    public var eventChar: UInt16              // @32（ImWchar；可读写，置 0 丢弃字符）
    public var eventActivated: Bool           // @34（只读）
    public var bufDirty: Bool                 // @35（修改 buf/bufTextLen 后必须置 true）
    public var buf: CPointer<UInt8>           // @40（文本缓冲，可读写内容、勿替换指针）
    public var bufTextLen: Int32              // @48（文本长度，不含 '\0'）
    public var bufSize: Int32                 // @52（缓冲容量，只读）
    public var cursorPos: Int32               // @56
    public var selectionStart: Int32          // @60
    public var selectionEnd: Int32            // @64

    public init() {
        this.ctx = CPointer<Unit>()
        this.eventFlag = 0
        this.flags = 0
        this.userData = CPointer<Unit>()
        this.id = 0
        this.eventKey = 0
        this.eventChar = 0
        this.eventActivated = false
        this.bufDirty = false
        this.buf = CPointer<UInt8>()
        this.bufTextLen = 0
        this.bufSize = 0
        this.cursorPos = 0
        this.selectionStart = 0
        this.selectionEnd = 0
    }
}

