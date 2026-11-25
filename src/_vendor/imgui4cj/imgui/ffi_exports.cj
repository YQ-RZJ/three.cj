/**
 * @file imgui4cj 公共函数包装（自动生成，基于 cimgui）
 * @brief 为每个 foreign 函数提供安全的 Cangjie 包装。
 * @note 字符串参数（CString）由调用方用 `LibC.mallocCString()` 创建、用完 `LibC.free()` 释放（与 sdl4cj 约定一致）。
 *       bool 返回值统一用 Int32（0/1）传递，包装层转为 Bool。
 */
protected package three._vendor.imgui4cj.imgui

import std.core.*

// =============================================================================
// 生命周期
// =============================================================================

/**
 * @brief 创建 ImGui 上下文
 * @param sharedFontAtlas 共享字体图集（null 使用默认）
 * @return 上下文指针
 */
public func ImGui_CreateContext_cj(sharedFontAtlas: CPointer<Unit>): CPointer<Unit> {
    return unsafe { igCreateContext(sharedFontAtlas) }
}

public func ImGui_DestroyContext_cj(ctx: CPointer<Unit>): Unit {
    unsafe { igDestroyContext(ctx) }
}

public func ImGui_GetCurrentContext_cj(): CPointer<Unit> {
    return unsafe { igGetCurrentContext() }
}

public func ImGui_SetCurrentContext_cj(ctx: CPointer<Unit>): Unit {
    unsafe { igSetCurrentContext(ctx) }
}

// =============================================================================
// 帧控制
// =============================================================================

public func ImGui_NewFrame_cj(): Unit { unsafe { igNewFrame() } }
public func igNewFrame_cj(): Unit { unsafe { igNewFrame() } }
public func ImGui_EndFrame_cj(): Unit { unsafe { igEndFrame() } }
public func ImGui_Render_cj(): Unit { unsafe { igRender() } }
public func ImGui_GetDrawData_cj(): CPointer<Unit> { return unsafe { igGetDrawData() } }

// =============================================================================
// IO
// =============================================================================

public func ImGui_GetIO_cj(): CPointer<Unit> { return unsafe { igGetIO_Nil() } }
public func ImGui_GetStyle_cj(): CPointer<Unit> { return unsafe { igGetStyle() } }
public func ImGui_GetVersion_cj(): String {
    return unsafe {
        let p = igGetVersion()
        if (p.isNull()) { "" } else { p.toString() }
    }
}

// =============================================================================
// 窗口
// =============================================================================

public func ImGui_Begin_cj(name: CString, pOpen: CPointer<Int32>, flags: Int32): Bool {
    return unsafe {
        let r = if (igBegin(name, pOpen, flags) != 0) { 1 } else { 0 }
        r != 0
    }
}

public func ImGui_End_cj(): Unit { unsafe { igEnd() } }

// =============================================================================
// 按钮
// =============================================================================

public func ImGui_Button_cj(label: CString, sizeX: Float32, sizeY: Float32): Bool {
    return unsafe {
        let r = if (igButton(label, ImVec2(sizeX, sizeY)) != 0) { 1 } else { 0 }
        r != 0
    }
}

public func ImGui_SmallButton_cj(label: CString): Bool {
    return unsafe {
        let r = if (igSmallButton(label) != 0) { 1 } else { 0 }
        r != 0
    }
}

// =============================================================================
// 文本
// =============================================================================

public func ImGui_TextUnformatted_cj(text: CString): Unit {
    unsafe {
        igTextUnformatted(text, CString(CPointer<UInt8>()))
    }
}

/**
 * @brief 显示文本（支持 Cangjie 字符串插值）
 * @note 变参格式化在 Cangjie 侧通过字符串插值完成，传入 ImGui::Text("%s", text)
 */
public func ImGui_Text_cj(text: CString): Unit {
    unsafe {
        igTextUnformatted(text, CString(CPointer<UInt8>()))
    }
}

// =============================================================================
// 文本输入
// =============================================================================

public func ImGui_ProcessTextInput_cj(text: CString): Bool {
    return unsafe {
        let io = igGetIO_Nil()
        if (!io.isNull()) {
            // cimgui 没有直接的 AddInputCharactersUTF8，
            // 通过 io.AddInputCharactersUTF8 的偏移调用
            // 实际需要 cimgui 提供 igIO_AddInputCharactersUTF8
            // 暂用 ImGui::GetIO().AddInputCharactersUTF8 通过外层包装
        }
        true
    }
}

// =============================================================================
// 复选框
// =============================================================================

public func ImGui_Checkbox_cj(label: CString, v: CPointer<Int32>): Bool {
    return unsafe {
        let r = if (igCheckbox(label, v) != 0) { 1 } else { 0 }
        r != 0
    }
}

// =============================================================================
// SDL3 后端
// =============================================================================

public func ImGui_ImplSDL3_InitForOpenGL_cj(window: CPointer<Unit>, glContext: CPointer<Unit>): Bool {
    return unsafe { if (ImGui_ImplSDL3_InitForOpenGL(window, glContext) != 0) { true } else { false } }
}

public func ImGui_ImplSDL3_InitForOther_cj(window: CPointer<Unit>): Bool {
    return unsafe { if (ImGui_ImplSDL3_InitForOther(window) != 0) { true } else { false } }
}

public func ImGui_ImplSDL3_NewFrame_cj(): Unit { unsafe { ImGui_ImplSDL3_NewFrame() } }

public func ImGui_ImplSDL3_ProcessEvent_cj(event: CPointer<Unit>): Bool {
    return unsafe { if (ImGui_ImplSDL3_ProcessEvent(event) != 0) { true } else { false } }
}

public func ImGui_ImplSDL3_Shutdown_cj(): Unit { unsafe { ImGui_ImplSDL3_Shutdown() } }

// =============================================================================
// bgfx 渲染后端 C API 包装
// =============================================================================

public func ImGui_Implbgfx_Init_cj(autoShader: Bool, startingViewId: Int32): Bool {
    return unsafe {
        let a: Int32 = if (autoShader) { 1 } else { 0 }
        if (imgui_cj_impl_bgfx_init(a, startingViewId, 16) != 0) { true } else { false }
    }
}

public func ImGui_Implbgfx_Shutdown_cj(): Unit {
 unsafe { imgui_cj_impl_bgfx_shutdown() } }

public func ImGui_Implbgfx_RenderDrawData_cj(): Unit { unsafe { imgui_cj_impl_bgfx_render_draw_data() } }

// =============================================================================
// 自动生成的 igXXX 包装（按 cimgui 函数名直接暴露）
// =============================================================================

public func ImVec2_ImVec2_Nil_cj(): CPointer<Unit> { return unsafe { ImVec2_ImVec2_Nil() } }

public func ImVec2_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVec2_destroy(self) } }

public func ImVec2_ImVec2_Float_cj(_x: Float32, _y: Float32): CPointer<Unit> { return unsafe { ImVec2_ImVec2_Float(_x, _y) } }

public func ImVec4_ImVec4_Nil_cj(): CPointer<Unit> { return unsafe { ImVec4_ImVec4_Nil() } }

public func ImVec4_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVec4_destroy(self) } }

public func ImVec4_ImVec4_Float_cj(_x: Float32, _y: Float32, _z: Float32, _w: Float32): CPointer<Unit> { return unsafe { ImVec4_ImVec4_Float(_x, _y, _z, _w) } }

public func ImTextureRef_ImTextureRef_Nil_cj(): CPointer<Unit> { return unsafe { ImTextureRef_ImTextureRef_Nil() } }

public func ImTextureRef_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImTextureRef_destroy(self) } }

public func ImTextureRef_ImTextureRef_TextureID_cj(tex_id: UInt64): CPointer<Unit> { return unsafe { ImTextureRef_ImTextureRef_TextureID(tex_id) } }

public func ImTextureRef_GetTexID_cj(self: CPointer<Unit>): UInt64 { return unsafe { ImTextureRef_GetTexID(self) } }

public func igShowDemoWindow_cj(p_open: CPointer<Int32>): Unit { unsafe { igShowDemoWindow(p_open) } }

public func igShowMetricsWindow_cj(p_open: CPointer<Int32>): Unit { unsafe { igShowMetricsWindow(p_open) } }

public func igShowDebugLogWindow_cj(p_open: CPointer<Int32>): Unit { unsafe { igShowDebugLogWindow(p_open) } }

public func igShowIDStackToolWindow_cj(p_open: CPointer<Int32>): Unit { unsafe { igShowIDStackToolWindow(p_open) } }

public func igShowAboutWindow_cj(p_open: CPointer<Int32>): Unit { unsafe { igShowAboutWindow(p_open) } }

public func igShowStyleEditor_cj(ref: CPointer<Unit>): Unit { unsafe { igShowStyleEditor(ref) } }

public func igShowStyleSelector_cj(label: CString): Int32 { return unsafe { igShowStyleSelector(label) } }

public func igShowFontSelector_cj(label: CString): Unit { unsafe { igShowFontSelector(label) } }

public func igShowUserGuide_cj(): Unit { unsafe { igShowUserGuide() } }

public func igStyleColorsDark_cj(dst: CPointer<Unit>): Unit { unsafe { igStyleColorsDark(dst) } }

public func igStyleColorsLight_cj(dst: CPointer<Unit>): Unit { unsafe { igStyleColorsLight(dst) } }

public func igStyleColorsClassic_cj(dst: CPointer<Unit>): Unit { unsafe { igStyleColorsClassic(dst) } }

public func igBeginChild_Str_cj(str_id: CString, size: ImVec2, child_flags: Int32, window_flags: Int32): Int32 { return unsafe { igBeginChild_Str(str_id, size, child_flags, window_flags) } }

public func igBeginChild_ID_cj(id: UInt32, size: ImVec2, child_flags: Int32, window_flags: Int32): Int32 { return unsafe { igBeginChild_ID(id, size, child_flags, window_flags) } }

public func igEndChild_cj(): Unit { unsafe { igEndChild() } }

public func igIsWindowAppearing_cj(): Int32 { return unsafe { igIsWindowAppearing() } }

public func igIsWindowCollapsed_cj(): Int32 { return unsafe { igIsWindowCollapsed() } }

public func igIsWindowFocused_cj(flags: Int32): Int32 { return unsafe { igIsWindowFocused(flags) } }

public func igIsWindowHovered_cj(flags: Int32): Int32 { return unsafe { igIsWindowHovered(flags) } }

public func igGetWindowDrawList_cj(): CPointer<Unit> { return unsafe { igGetWindowDrawList() } }

public func igGetWindowPos_cj(): ImVec2 { return unsafe { igGetWindowPos() } }

public func igGetWindowSize_cj(): ImVec2 { return unsafe { igGetWindowSize() } }

public func igGetWindowWidth_cj(): Float32 { return unsafe { igGetWindowWidth() } }

public func igGetWindowHeight_cj(): Float32 { return unsafe { igGetWindowHeight() } }

public func igSetNextWindowPos_cj(pos: ImVec2, cond: Int32, pivot: ImVec2): Unit { unsafe { igSetNextWindowPos(pos, cond, pivot) } }

public func igSetNextWindowSize_cj(size: ImVec2, cond: Int32): Unit { unsafe { igSetNextWindowSize(size, cond) } }

public func igSetNextWindowSizeConstraints_cj(size_min: ImVec2, size_max: ImVec2, custom_callback: CPointer<Unit>, custom_callback_data: CPointer<Unit>): Unit { unsafe { igSetNextWindowSizeConstraints(size_min, size_max, custom_callback, custom_callback_data) } }

public func igSetNextWindowContentSize_cj(size: ImVec2): Unit { unsafe { igSetNextWindowContentSize(size) } }

public func igSetNextWindowCollapsed_cj(collapsed: Int32, cond: Int32): Unit { unsafe { igSetNextWindowCollapsed(collapsed, cond) } }

public func igSetNextWindowFocus_cj(): Unit { unsafe { igSetNextWindowFocus() } }

public func igSetNextWindowScroll_cj(scroll: ImVec2): Unit { unsafe { igSetNextWindowScroll(scroll) } }

public func igSetNextWindowBgAlpha_cj(alpha: Float32): Unit { unsafe { igSetNextWindowBgAlpha(alpha) } }

public func igSetWindowPos_Vec2_cj(pos: ImVec2, cond: Int32): Unit { unsafe { igSetWindowPos_Vec2(pos, cond) } }

public func igSetWindowSize_Vec2_cj(size: ImVec2, cond: Int32): Unit { unsafe { igSetWindowSize_Vec2(size, cond) } }

public func igSetWindowCollapsed_Bool_cj(collapsed: Int32, cond: Int32): Unit { unsafe { igSetWindowCollapsed_Bool(collapsed, cond) } }

public func igSetWindowFocus_Nil_cj(): Unit { unsafe { igSetWindowFocus_Nil() } }

public func igCreateContext_cj(shared_font_atlas: CPointer<Unit>): CPointer<Unit> { return unsafe { igCreateContext(shared_font_atlas) } }

public func igDestroyContext_cj(ctx: CPointer<Unit>): Unit { unsafe { igDestroyContext(ctx) } }

public func igGetCurrentContext_cj(): CPointer<Unit> { return unsafe { igGetCurrentContext() } }

public func igGetDrawData_cj(): CPointer<Unit> { return unsafe { igGetDrawData() } }

public func igSetWindowPos_Str_cj(name: CString, pos: ImVec2, cond: Int32): Unit { unsafe { igSetWindowPos_Str(name, pos, cond) } }

public func igSetWindowSize_Str_cj(name: CString, size: ImVec2, cond: Int32): Unit { unsafe { igSetWindowSize_Str(name, size, cond) } }

public func igSetWindowCollapsed_Str_cj(name: CString, collapsed: Int32, cond: Int32): Unit { unsafe { igSetWindowCollapsed_Str(name, collapsed, cond) } }

public func igSetWindowFocus_Str_cj(name: CString): Unit { unsafe { igSetWindowFocus_Str(name) } }

public func igGetScrollX_cj(): Float32 { return unsafe { igGetScrollX() } }

public func igGetScrollY_cj(): Float32 { return unsafe { igGetScrollY() } }

public func igSetScrollX_Float_cj(scroll_x: Float32): Unit { unsafe { igSetScrollX_Float(scroll_x) } }

public func igSetScrollY_Float_cj(scroll_y: Float32): Unit { unsafe { igSetScrollY_Float(scroll_y) } }

public func igGetScrollMaxX_cj(): Float32 { return unsafe { igGetScrollMaxX() } }

public func igGetScrollMaxY_cj(): Float32 { return unsafe { igGetScrollMaxY() } }

public func igSetScrollHereX_cj(center_x_ratio: Float32): Unit { unsafe { igSetScrollHereX(center_x_ratio) } }

public func igSetScrollHereY_cj(center_y_ratio: Float32): Unit { unsafe { igSetScrollHereY(center_y_ratio) } }

public func igSetScrollFromPosX_Float_cj(local_x: Float32, center_x_ratio: Float32): Unit { unsafe { igSetScrollFromPosX_Float(local_x, center_x_ratio) } }

public func igSetScrollFromPosY_Float_cj(local_y: Float32, center_y_ratio: Float32): Unit { unsafe { igSetScrollFromPosY_Float(local_y, center_y_ratio) } }

public func igPushFont_cj(font: CPointer<Unit>, font_size_base_unscaled: Float32): Unit { unsafe { igPushFont(font, font_size_base_unscaled) } }

public func igPopFont_cj(): Unit { unsafe { igPopFont() } }

public func igGetFont_cj(): CPointer<Unit> { return unsafe { igGetFont() } }

public func igGetFontSize_cj(): Float32 { return unsafe { igGetFontSize() } }

public func igGetFontBaked_cj(): CPointer<Unit> { return unsafe { igGetFontBaked() } }

public func igPushStyleColor_U32_cj(idx: Int32, col: UInt32): Unit { unsafe { igPushStyleColor_U32(idx, col) } }

public func igPushStyleColor_Vec4_cj(idx: Int32, col: ImVec4): Unit { unsafe { igPushStyleColor_Vec4(idx, col) } }

public func igPopStyleColor_cj(count: Int32): Unit { unsafe { igPopStyleColor(count) } }

public func igPushStyleVar_Float_cj(idx: Int32, val: Float32): Unit { unsafe { igPushStyleVar_Float(idx, val) } }

public func igPushStyleVar_Vec2_cj(idx: Int32, val: ImVec2): Unit { unsafe { igPushStyleVar_Vec2(idx, val) } }

public func igPushStyleVarX_cj(idx: Int32, val_x: Float32): Unit { unsafe { igPushStyleVarX(idx, val_x) } }

public func igPushStyleVarY_cj(idx: Int32, val_y: Float32): Unit { unsafe { igPushStyleVarY(idx, val_y) } }

public func igPopStyleVar_cj(count: Int32): Unit { unsafe { igPopStyleVar(count) } }

public func igPushItemFlag_cj(option: Int32, enabled: Int32): Unit { unsafe { igPushItemFlag(option, enabled) } }

public func igPopItemFlag_cj(): Unit { unsafe { igPopItemFlag() } }

public func igPushItemWidth_cj(item_width: Float32): Unit { unsafe { igPushItemWidth(item_width) } }

public func igPopItemWidth_cj(): Unit { unsafe { igPopItemWidth() } }

public func igSetNextItemWidth_cj(item_width: Float32): Unit { unsafe { igSetNextItemWidth(item_width) } }

public func igCalcItemWidth_cj(): Float32 { return unsafe { igCalcItemWidth() } }

public func igPushTextWrapPos_cj(wrap_local_pos_x: Float32): Unit { unsafe { igPushTextWrapPos(wrap_local_pos_x) } }

public func igPopTextWrapPos_cj(): Unit { unsafe { igPopTextWrapPos() } }

public func igGetFontTexUvWhitePixel_cj(): ImVec2 { return unsafe { igGetFontTexUvWhitePixel() } }

public func igGetColorU32_Col_cj(idx: Int32, alpha_mul: Float32): UInt32 { return unsafe { igGetColorU32_Col(idx, alpha_mul) } }

public func igGetColorU32_Vec4_cj(col: ImVec4): UInt32 { return unsafe { igGetColorU32_Vec4(col) } }

public func igGetColorU32_U32_cj(col: UInt32, alpha_mul: Float32): UInt32 { return unsafe { igGetColorU32_U32(col, alpha_mul) } }

public func igGetStyleColorVec4_cj(idx: Int32): CPointer<ImVec4> { return unsafe { igGetStyleColorVec4(idx) } }

public func igGetIO_Nil_cj(): CPointer<Unit> { return unsafe { igGetIO_Nil() } }

public func igGetStyle_cj(): CPointer<Unit> { return unsafe { igGetStyle() } }

public func igGetCursorScreenPos_cj(): ImVec2 { return unsafe { igGetCursorScreenPos() } }

public func igSetCursorScreenPos_cj(pos: ImVec2): Unit { unsafe { igSetCursorScreenPos(pos) } }

public func igGetContentRegionAvail_cj(): ImVec2 { return unsafe { igGetContentRegionAvail() } }

public func igGetCursorPos_cj(): ImVec2 { return unsafe { igGetCursorPos() } }

public func igGetCursorPosX_cj(): Float32 { return unsafe { igGetCursorPosX() } }

public func igGetCursorPosY_cj(): Float32 { return unsafe { igGetCursorPosY() } }

public func igSetCursorPos_cj(local_pos: ImVec2): Unit { unsafe { igSetCursorPos(local_pos) } }

public func igSetCursorPosX_cj(local_x: Float32): Unit { unsafe { igSetCursorPosX(local_x) } }

public func igSetCursorPosY_cj(local_y: Float32): Unit { unsafe { igSetCursorPosY(local_y) } }

public func igGetCursorStartPos_cj(): ImVec2 { return unsafe { igGetCursorStartPos() } }

public func igSeparator_cj(): Unit { unsafe { igSeparator() } }

public func igSameLine_cj(offset_from_start_x: Float32, spacing: Float32): Unit { unsafe { igSameLine(offset_from_start_x, spacing) } }

public func igNewLine_cj(): Unit { unsafe { igNewLine() } }

public func igSpacing_cj(): Unit { unsafe { igSpacing() } }

public func igDummy_cj(size: ImVec2): Unit { unsafe { igDummy(size) } }

public func igIndent_cj(indent_w: Float32): Unit { unsafe { igIndent(indent_w) } }

public func igUnindent_cj(indent_w: Float32): Unit { unsafe { igUnindent(indent_w) } }

public func igBeginGroup_cj(): Unit { unsafe { igBeginGroup() } }

public func igEndGroup_cj(): Unit { unsafe { igEndGroup() } }

public func igAlignTextToFramePadding_cj(): Unit { unsafe { igAlignTextToFramePadding() } }

public func igGetTextLineHeight_cj(): Float32 { return unsafe { igGetTextLineHeight() } }

public func igGetTextLineHeightWithSpacing_cj(): Float32 { return unsafe { igGetTextLineHeightWithSpacing() } }

public func igGetFrameHeight_cj(): Float32 { return unsafe { igGetFrameHeight() } }

public func igGetFrameHeightWithSpacing_cj(): Float32 { return unsafe { igGetFrameHeightWithSpacing() } }

public func igPushID_Str_cj(str_id: CString): Unit { unsafe { igPushID_Str(str_id) } }

public func igPushID_StrStr_cj(str_id_begin: CString, str_id_end: CString): Unit { unsafe { igPushID_StrStr(str_id_begin, str_id_end) } }

public func igPushID_Ptr_cj(ptr_id: CPointer<Unit>): Unit { unsafe { igPushID_Ptr(ptr_id) } }

public func igPushID_Int_cj(int_id: Int32): Unit { unsafe { igPushID_Int(int_id) } }

public func igPopID_cj(): Unit { unsafe { igPopID() } }

public func igGetID_Str_cj(str_id: CString): UInt32 { return unsafe { igGetID_Str(str_id) } }

public func igGetID_StrStr_cj(str_id_begin: CString, str_id_end: CString): UInt32 { return unsafe { igGetID_StrStr(str_id_begin, str_id_end) } }

public func igGetID_Ptr_cj(ptr_id: CPointer<Unit>): UInt32 { return unsafe { igGetID_Ptr(ptr_id) } }

public func igGetID_Int_cj(int_id: Int32): UInt32 { return unsafe { igGetID_Int(int_id) } }

public func igText0_cj(fmt: CString): Unit { unsafe { igText0(fmt) } }

public func igTextColored0_cj(col: ImVec4, fmt: CString): Unit { unsafe { igTextColored0(col, fmt) } }

public func igTextDisabled0_cj(fmt: CString): Unit { unsafe { igTextDisabled0(fmt) } }

public func igTextWrapped0_cj(fmt: CString): Unit { unsafe { igTextWrapped0(fmt) } }

public func igLabelText0_cj(label: CString, fmt: CString): Unit { unsafe { igLabelText0(label, fmt) } }

public func igBulletText0_cj(fmt: CString): Unit { unsafe { igBulletText0(fmt) } }

public func igSeparatorText_cj(label: CString): Unit { unsafe { igSeparatorText(label) } }

public func igInvisibleButton_cj(str_id: CString, size: ImVec2, flags: Int32): Int32 { return unsafe { igInvisibleButton(str_id, size, flags) } }

public func igArrowButton_cj(str_id: CString, dir: Int32): Int32 { return unsafe { igArrowButton(str_id, dir) } }

public func igCheckboxFlags_IntPtr_cj(label: CString, flags: CPointer<Int32>, flags_value: Int32): Int32 { return unsafe { igCheckboxFlags_IntPtr(label, flags, flags_value) } }

public func igCheckboxFlags_UintPtr_cj(label: CString, flags: CPointer<UInt32>, flags_value: UInt32): Int32 { return unsafe { igCheckboxFlags_UintPtr(label, flags, flags_value) } }

public func igRadioButton_Bool_cj(label: CString, active: Int32): Int32 { return unsafe { igRadioButton_Bool(label, active) } }

public func igRadioButton_IntPtr_cj(label: CString, v: CPointer<Int32>, v_button: Int32): Int32 { return unsafe { igRadioButton_IntPtr(label, v, v_button) } }

public func igProgressBar_cj(fraction: Float32, size_arg: ImVec2, overlay: CString): Unit { unsafe { igProgressBar(fraction, size_arg, overlay) } }

public func igBullet_cj(): Unit { unsafe { igBullet() } }

// =============================================================================
// ImGui_* 高级包装（String 参数，自动 CString 转换）
// =============================================================================

public func ImGui_Separator_cj(): Unit { unsafe { igSeparator() } }

public func ImGui_SameLine_cj(offset: Float32, spacing: Float32): Unit { unsafe { igSameLine(offset, spacing) } }

public func ImGui_Spacing_cj(): Unit { unsafe { igSpacing() } }

public func ImGui_Columns_cj(count: Int32, id: CString, borders: Int32): Unit {
    unsafe {
        igColumns(count, id, borders)
    }
}

public func ImGui_SliderInt_cj(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igSliderInt(label, v, v_min, v_max, format, flags)
        r
    }
}

public func ImGui_InputText_cj(label: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 {
    unsafe {
        let r = igInputText(label, buf, buf_size, flags, callback, user_data)
        r
    }
}

public func ImGui_InputTextWithHint_cj(label: CString, hint: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 {
    unsafe {
        let r = igInputTextWithHint(label, hint, buf, buf_size, flags, callback, user_data)
        r
    }
}

public func ImGui_InputFloat_cj(label: CString, v: CPointer<Float32>, step: Float32, step_fast: Float32, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igInputFloat(label, v, step, step_fast, format, flags)
        r
    }
}

public func ImGui_Combo_Str_cj(label: CString, current_item: CPointer<Int32>, items_separated_by_zeros: CString, popup_max_height_in_items: Int32): Int32 {
    unsafe {
        let r = igCombo_Str(label, current_item, items_separated_by_zeros, popup_max_height_in_items)
        r
    }
}

public func ImGui_Selectable_Bool_cj(label: CString, selected: Int32, flags: Int32, size: ImVec2): Int32 {
    unsafe {
        let r = igSelectable_Bool(label, selected, flags, size)
        r
    }
}

public func ImGui_BeginDisabled_cj(disabled: Int32): Unit {
 unsafe { igBeginDisabled(disabled) } }

public func ImGui_EndDisabled_cj(): Unit { unsafe { igEndDisabled() } }

public func ImGui_PushClipRect_cj(clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: Int32): Unit { unsafe { igPushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect) } }

public func ImGui_PopClipRect_cj(): Unit { unsafe { igPopClipRect() } }

public func ImGui_SetNextItemWidth_cj(item_width: Float32): Unit { unsafe { igSetNextItemWidth(item_width) } }

public func ImGui_SetNextItemOpen_cj(is_open: Int32, cond: Int32): Unit { unsafe { igSetNextItemOpen(is_open, cond) } }

public func ImGui_SeparatorText_cj(label: CString): Unit {
    unsafe {
        igSeparatorText(label)
    }
}

public func ImGui_BeginItemTooltip_cj(): Int32 {
 return unsafe { igBeginItemTooltip() } }

public func ImGui_EndTooltip_cj(): Unit { unsafe { igEndTooltip() } }

public func ImGui_SetTooltip0_cj(fmt: CString): Unit {
    unsafe {
        igSetTooltip0(fmt)
    }
}

public func ImGui_TreePop_cj(): Unit {
 unsafe { igTreePop() } }

public func ImGui_TreeNode_Str_cj(label: CString): Int32 {
    unsafe {
        let r = igTreeNode_Str(label)
        r
    }
}

public func ImGui_TreeNodeEx_Str_cj(label: CString, flags: Int32): Int32 {
    unsafe {
        let r = igTreeNodeEx_Str(label, flags)
        r
    }
}

public func ImGui_CollapsingHeader_TreeNodeFlags_cj(label: CString, flags: Int32): Int32 {
    unsafe {
        let r = igCollapsingHeader_TreeNodeFlags(label, flags)
        r
    }
}

public func ImGui_IsItemHovered_cj(flags: Int32): Int32 {
 return unsafe { igIsItemHovered(flags) } }

public func ImGui_IsItemActive_cj(): Int32 { return unsafe { igIsItemActive() } }

public func ImGui_IsItemFocused_cj(): Int32 { return unsafe { igIsItemFocused() } }

public func ImGui_IsItemClicked_cj(mouse_button: Int32): Int32 { return unsafe { igIsItemClicked(mouse_button) } }

public func ImGui_IsItemVisible_cj(): Int32 { return unsafe { igIsItemVisible() } }

public func ImGui_IsItemEdited_cj(): Int32 { return unsafe { igIsItemEdited() } }

public func ImGui_IsItemActivated_cj(): Int32 { return unsafe { igIsItemActivated() } }

public func ImGui_IsItemDeactivated_cj(): Int32 { return unsafe { igIsItemDeactivated() } }

public func ImGui_IsItemDeactivatedAfterEdit_cj(): Int32 { return unsafe { igIsItemDeactivatedAfterEdit() } }

public func ImGui_IsItemToggledOpen_cj(): Int32 { return unsafe { igIsItemToggledOpen() } }

public func ImGui_IsAnyItemHovered_cj(): Int32 { return unsafe { igIsAnyItemHovered() } }

public func ImGui_IsAnyItemActive_cj(): Int32 { return unsafe { igIsAnyItemActive() } }

public func ImGui_IsAnyItemFocused_cj(): Int32 { return unsafe { igIsAnyItemFocused() } }

public func ImGui_GetItemID_cj(): UInt32 { return unsafe { igGetItemID() } }

public func ImGui_GetItemRectMin_cj(): ImVec2 { return unsafe { igGetItemRectMin() } }

public func ImGui_GetItemRectMax_cj(): ImVec2 { return unsafe { igGetItemRectMax() } }

public func ImGui_GetItemRectSize_cj(): ImVec2 { return unsafe { igGetItemRectSize() } }

public func ImGui_SetItemDefaultFocus_cj(): Unit { unsafe { igSetItemDefaultFocus() } }

public func ImGui_SetNextItemAllowOverlap_cj(): Unit { unsafe { igSetNextItemAllowOverlap() } }

public func ImGui_ProgressBar_cj(fraction: Float32, size_arg: ImVec2, overlay: CString): Unit {
    unsafe {
        igProgressBar(fraction, size_arg, overlay)
    }
}

public func ImGui_PlotLines_FloatPtr_cj(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit {
    unsafe {
        igPlotLines_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    }
}

public func ImGui_PlotHistogram_FloatPtr_cj(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit {
    unsafe {
        igPlotHistogram_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride)
    }
}

public func ImGui_Value_Float_cj(prefix: CString, v: Float32, float_format: CString): Unit {
    unsafe {
        igValue_Float(prefix, v, float_format)
    }
}

public func ImGui_DragFloat_cj(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igDragFloat(label, v, v_speed, v_min, v_max, format, flags)
        r
    }
}

public func ImGui_DragInt_cj(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igDragInt(label, v, v_speed, v_min, v_max, format, flags)
        r
    }
}

public func ImGui_InputInt_cj(label: CString, v: CPointer<Int32>, step: Int32, step_fast: Int32, flags: Int32): Int32 {
    unsafe {
        let r = igInputInt(label, v, step, step_fast, flags)
        r
    }
}

public func ImGui_InputDouble_cj(label: CString, v: CPointer<Float64>, step: Float64, step_fast: Float64, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igInputDouble(label, v, step, step_fast, format, flags)
        r
    }
}

public func ImGui_VSliderFloat_cj(label: CString, size: ImVec2, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 {
    unsafe {
        let r = igVSliderFloat(label, size, v, v_min, v_max, format, flags)
        r
    }
}

public func ImGui_ColorEdit4_cj(label: CString, col: CPointer<Float32>, flags: Int32): Int32 {
    unsafe {
        let r = igColorEdit4(label, col, flags)
        r
    }
}

public func ImGui_ColorPicker4_cj(label: CString, col: CPointer<Float32>, flags: Int32, ref_col: CPointer<Float32>): Int32 {
    unsafe {
        let r = igColorPicker4(label, col, flags, ref_col)
        r
    }
}

public func ImGui_ListBox_Str_arr_cj(label: CString, current_item: CPointer<Int32>, items: CPointer<Unit>, items_count: Int32, height_in_items: Int32): Int32 {
    unsafe {
        let r = igListBox_Str_arr(label, current_item, items, items_count, height_in_items)
        r
    }
}

public func ImGui_GetWindowDrawList_cj(): CPointer<Unit> { return unsafe { igGetWindowDrawList() } }

public func ImGui_BeginTooltip_cj(): Int32 { return unsafe { igBeginTooltip() } }

public func ImGui_TextLink_cj(label: CString): Int32 { return unsafe { igTextLink(label) } }

public func igTextLinkOpenURL_cj(label: CString, url: CString): Int32 { return unsafe { igTextLinkOpenURL(label, url) } }

public func igImage_cj(tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2): Unit { unsafe { igImage(tex_ref, image_size, uv0, uv1) } }

public func igImageWithBg_cj(tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4): Unit { unsafe { igImageWithBg(tex_ref, image_size, uv0, uv1, bg_col, tint_col) } }

public func igImageButton_cj(str_id: CString, tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4): Int32 { return unsafe { igImageButton(str_id, tex_ref, image_size, uv0, uv1, bg_col, tint_col) } }

public func igBeginCombo_cj(label: CString, preview_value: CString, flags: Int32): Int32 { return unsafe { igBeginCombo(label, preview_value, flags) } }

public func igEndCombo_cj(): Unit { unsafe { igEndCombo() } }

public func igCombo_Str_arr_cj(label: CString, current_item: CPointer<Int32>, items: CPointer<Unit>, items_count: Int32, popup_max_height_in_items: Int32): Int32 { return unsafe { igCombo_Str_arr(label, current_item, items, items_count, popup_max_height_in_items) } }

public func igCombo_Str_cj(label: CString, current_item: CPointer<Int32>, items_separated_by_zeros: CString, popup_max_height_in_items: Int32): Int32 { return unsafe { igCombo_Str(label, current_item, items_separated_by_zeros, popup_max_height_in_items) } }

public func igDragFloat_cj(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igDragFloat(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragFloat2_cj(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igDragFloat2(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragFloat3_cj(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igDragFloat3(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragFloat4_cj(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igDragFloat4(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragFloatRange2_cj(label: CString, v_current_min: CPointer<Float32>, v_current_max: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, format_max: CString, flags: Int32): Int32 { return unsafe { igDragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags) } }

public func igDragInt_cj(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igDragInt(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragInt2_cj(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igDragInt2(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragInt3_cj(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igDragInt3(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragInt4_cj(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igDragInt4(label, v, v_speed, v_min, v_max, format, flags) } }

public func igDragIntRange2_cj(label: CString, v_current_min: CPointer<Int32>, v_current_max: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, format_max: CString, flags: Int32): Int32 { return unsafe { igDragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags) } }

public func igDragScalar_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igDragScalar(label, data_type, p_data, v_speed, p_min, p_max, format, flags) } }

public func igDragScalarN_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igDragScalarN(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags) } }

public func igSliderFloat_cj(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igSliderFloat(label, v, v_min, v_max, format, flags) } }

public func igSliderFloat2_cj(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igSliderFloat2(label, v, v_min, v_max, format, flags) } }

public func igSliderFloat3_cj(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igSliderFloat3(label, v, v_min, v_max, format, flags) } }

public func igSliderFloat4_cj(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igSliderFloat4(label, v, v_min, v_max, format, flags) } }

public func igSliderAngle_cj(label: CString, v_rad: CPointer<Float32>, v_degrees_min: Float32, v_degrees_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igSliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format, flags) } }

public func igSliderInt_cj(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igSliderInt(label, v, v_min, v_max, format, flags) } }

public func igSliderInt2_cj(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igSliderInt2(label, v, v_min, v_max, format, flags) } }

public func igSliderInt3_cj(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igSliderInt3(label, v, v_min, v_max, format, flags) } }

public func igSliderInt4_cj(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igSliderInt4(label, v, v_min, v_max, format, flags) } }

public func igSliderScalar_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igSliderScalar(label, data_type, p_data, p_min, p_max, format, flags) } }

public func igSliderScalarN_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igSliderScalarN(label, data_type, p_data, components, p_min, p_max, format, flags) } }

public func igVSliderFloat_cj(label: CString, size: ImVec2, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32 { return unsafe { igVSliderFloat(label, size, v, v_min, v_max, format, flags) } }

public func igVSliderInt_cj(label: CString, size: ImVec2, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32 { return unsafe { igVSliderInt(label, size, v, v_min, v_max, format, flags) } }

public func igVSliderScalar_cj(label: CString, size: ImVec2, data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igVSliderScalar(label, size, data_type, p_data, p_min, p_max, format, flags) } }

public func igInputText_cj(label: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 { return unsafe { igInputText(label, buf, buf_size, flags, callback, user_data) } }

public func igInputTextMultiline_cj(label: CString, buf: CPointer<Int8>, buf_size: UIntNative, size: ImVec2, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 { return unsafe { igInputTextMultiline(label, buf, buf_size, size, flags, callback, user_data) } }

public func igInputTextWithHint_cj(label: CString, hint: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 { return unsafe { igInputTextWithHint(label, hint, buf, buf_size, flags, callback, user_data) } }

public func igInputFloat_cj(label: CString, v: CPointer<Float32>, step: Float32, step_fast: Float32, format: CString, flags: Int32): Int32 { return unsafe { igInputFloat(label, v, step, step_fast, format, flags) } }

public func igInputFloat2_cj(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32 { return unsafe { igInputFloat2(label, v, format, flags) } }

public func igInputFloat3_cj(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32 { return unsafe { igInputFloat3(label, v, format, flags) } }

public func igInputFloat4_cj(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32 { return unsafe { igInputFloat4(label, v, format, flags) } }

public func igInputInt_cj(label: CString, v: CPointer<Int32>, step: Int32, step_fast: Int32, flags: Int32): Int32 { return unsafe { igInputInt(label, v, step, step_fast, flags) } }

public func igInputInt2_cj(label: CString, v: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igInputInt2(label, v, flags) } }

public func igInputInt3_cj(label: CString, v: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igInputInt3(label, v, flags) } }

public func igInputInt4_cj(label: CString, v: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igInputInt4(label, v, flags) } }

public func igInputDouble_cj(label: CString, v: CPointer<Float64>, step: Float64, step_fast: Float64, format: CString, flags: Int32): Int32 { return unsafe { igInputDouble(label, v, step, step_fast, format, flags) } }

public func igInputScalar_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, p_step: CPointer<Unit>, p_step_fast: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igInputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags) } }

public func igInputScalarN_cj(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, p_step: CPointer<Unit>, p_step_fast: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igInputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags) } }

public func igColorEdit3_cj(label: CString, col: CPointer<Float32>, flags: Int32): Int32 { return unsafe { igColorEdit3(label, col, flags) } }

public func igColorEdit4_cj(label: CString, col: CPointer<Float32>, flags: Int32): Int32 { return unsafe { igColorEdit4(label, col, flags) } }

public func igColorPicker3_cj(label: CString, col: CPointer<Float32>, flags: Int32): Int32 { return unsafe { igColorPicker3(label, col, flags) } }

public func igColorPicker4_cj(label: CString, col: CPointer<Float32>, flags: Int32, ref_col: CPointer<Float32>): Int32 { return unsafe { igColorPicker4(label, col, flags, ref_col) } }

public func igColorButton_cj(desc_id: CString, col: ImVec4, flags: Int32, size: ImVec2): Int32 { return unsafe { igColorButton(desc_id, col, flags, size) } }

public func igTreeNode_Str_cj(label: CString): Int32 { return unsafe { igTreeNode_Str(label) } }

public func igTreeNode_StrStr0_cj(str_id: CString, fmt: CString): Int32 { return unsafe { igTreeNode_StrStr0(str_id, fmt) } }

public func igTreeNode_Ptr0_cj(ptr_id: CPointer<Unit>, fmt: CString): Int32 { return unsafe { igTreeNode_Ptr0(ptr_id, fmt) } }

public func igTreeNodeEx_Str_cj(label: CString, flags: Int32): Int32 { return unsafe { igTreeNodeEx_Str(label, flags) } }

public func igTreeNodeEx_StrStr0_cj(str_id: CString, flags: Int32, fmt: CString): Int32 { return unsafe { igTreeNodeEx_StrStr0(str_id, flags, fmt) } }

public func igTreeNodeEx_Ptr0_cj(ptr_id: CPointer<Unit>, flags: Int32, fmt: CString): Int32 { return unsafe { igTreeNodeEx_Ptr0(ptr_id, flags, fmt) } }

public func igTreePush_Str_cj(str_id: CString): Unit { unsafe { igTreePush_Str(str_id) } }

public func igTreePush_Ptr_cj(ptr_id: CPointer<Unit>): Unit { unsafe { igTreePush_Ptr(ptr_id) } }

public func igTreePop_cj(): Unit { unsafe { igTreePop() } }

public func igGetTreeNodeToLabelSpacing_cj(): Float32 { return unsafe { igGetTreeNodeToLabelSpacing() } }

public func igCollapsingHeader_TreeNodeFlags_cj(label: CString, flags: Int32): Int32 { return unsafe { igCollapsingHeader_TreeNodeFlags(label, flags) } }

public func igCollapsingHeader_BoolPtr_cj(label: CString, p_visible: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igCollapsingHeader_BoolPtr(label, p_visible, flags) } }

public func igSetNextItemOpen_cj(is_open: Int32, cond: Int32): Unit { unsafe { igSetNextItemOpen(is_open, cond) } }

public func igSetNextItemStorageID_cj(storage_id: UInt32): Unit { unsafe { igSetNextItemStorageID(storage_id) } }

public func igTreeNodeGetOpen_cj(storage_id: UInt32): Int32 { return unsafe { igTreeNodeGetOpen(storage_id) } }

public func igSelectable_Bool_cj(label: CString, selected: Int32, flags: Int32, size: ImVec2): Int32 { return unsafe { igSelectable_Bool(label, selected, flags, size) } }

public func igSelectable_BoolPtr_cj(label: CString, p_selected: CPointer<Int32>, flags: Int32, size: ImVec2): Int32 { return unsafe { igSelectable_BoolPtr(label, p_selected, flags, size) } }

public func igBeginMultiSelect_cj(flags: Int32, selection_size: Int32, items_count: Int32): CPointer<Unit> { return unsafe { igBeginMultiSelect(flags, selection_size, items_count) } }

public func igEndMultiSelect_cj(): CPointer<Unit> { return unsafe { igEndMultiSelect() } }

public func igSetNextItemSelectionUserData_cj(selection_user_data: Int64): Unit { unsafe { igSetNextItemSelectionUserData(selection_user_data) } }

public func igIsItemToggledSelection_cj(): Int32 { return unsafe { igIsItemToggledSelection() } }

public func igBeginListBox_cj(label: CString, size: ImVec2): Int32 { return unsafe { igBeginListBox(label, size) } }

public func igEndListBox_cj(): Unit { unsafe { igEndListBox() } }

public func igListBox_Str_arr_cj(label: CString, current_item: CPointer<Int32>, items: CPointer<Unit>, items_count: Int32, height_in_items: Int32): Int32 { return unsafe { igListBox_Str_arr(label, current_item, items, items_count, height_in_items) } }

public func igPlotLines_FloatPtr_cj(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit { unsafe { igPlotLines_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride) } }

public func igPlotHistogram_FloatPtr_cj(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit { unsafe { igPlotHistogram_FloatPtr(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride) } }

public func igValue_Bool_cj(prefix: CString, b: Int32): Unit { unsafe { igValue_Bool(prefix, b) } }

public func igValue_Int_cj(prefix: CString, v: Int32): Unit { unsafe { igValue_Int(prefix, v) } }

public func igValue_Uint_cj(prefix: CString, v: UInt32): Unit { unsafe { igValue_Uint(prefix, v) } }

public func igValue_Float_cj(prefix: CString, v: Float32, float_format: CString): Unit { unsafe { igValue_Float(prefix, v, float_format) } }

public func igBeginMenuBar_cj(): Int32 { return unsafe { igBeginMenuBar() } }

public func igEndMenuBar_cj(): Unit { unsafe { igEndMenuBar() } }

public func igBeginMainMenuBar_cj(): Int32 { return unsafe { igBeginMainMenuBar() } }

public func igEndMainMenuBar_cj(): Unit { unsafe { igEndMainMenuBar() } }

public func igBeginMenu_cj(label: CString, enabled: Int32): Int32 { return unsafe { igBeginMenu(label, enabled) } }

public func igEndMenu_cj(): Unit { unsafe { igEndMenu() } }

public func igMenuItem_Bool_cj(label: CString, shortcut: CString, selected: Int32, enabled: Int32): Int32 { return unsafe { igMenuItem_Bool(label, shortcut, selected, enabled) } }

public func igMenuItem_BoolPtr_cj(label: CString, shortcut: CString, p_selected: CPointer<Int32>, enabled: Int32): Int32 { return unsafe { igMenuItem_BoolPtr(label, shortcut, p_selected, enabled) } }

public func igBeginTooltip_cj(): Int32 { return unsafe { igBeginTooltip() } }

public func igEndTooltip_cj(): Unit { unsafe { igEndTooltip() } }

public func igSetTooltip0_cj(fmt: CString): Unit { unsafe { igSetTooltip0(fmt) } }

public func igBeginItemTooltip_cj(): Int32 { return unsafe { igBeginItemTooltip() } }

public func igSetItemTooltip0_cj(fmt: CString): Unit { unsafe { igSetItemTooltip0(fmt) } }

public func igBeginPopup_cj(str_id: CString, flags: Int32): Int32 { return unsafe { igBeginPopup(str_id, flags) } }

public func igBeginPopupModal_cj(name: CString, p_open: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igBeginPopupModal(name, p_open, flags) } }

public func igEndPopup_cj(): Unit { unsafe { igEndPopup() } }

public func igOpenPopup_Str_cj(str_id: CString, popup_flags: Int32): Int32 { return unsafe { igOpenPopup_Str(str_id, popup_flags) } }

public func igOpenPopup_ID_cj(id: UInt32, popup_flags: Int32): Int32 { return unsafe { igOpenPopup_ID(id, popup_flags) } }

public func igOpenPopupOnItemClick_cj(str_id: CString, popup_flags: Int32): Int32 { return unsafe { igOpenPopupOnItemClick(str_id, popup_flags) } }

public func igCloseCurrentPopup_cj(): Unit { unsafe { igCloseCurrentPopup() } }

public func igBeginPopupContextItem_cj(str_id: CString, popup_flags: Int32): Int32 { return unsafe { igBeginPopupContextItem(str_id, popup_flags) } }

public func igBeginPopupContextWindow_cj(str_id: CString, popup_flags: Int32): Int32 { return unsafe { igBeginPopupContextWindow(str_id, popup_flags) } }

public func igBeginPopupContextVoid_cj(str_id: CString, popup_flags: Int32): Int32 { return unsafe { igBeginPopupContextVoid(str_id, popup_flags) } }

public func igIsPopupOpen_Str_cj(str_id: CString, flags: Int32): Int32 { return unsafe { igIsPopupOpen_Str(str_id, flags) } }

public func igBeginTable_cj(str_id: CString, columns: Int32, flags: Int32, outer_size: ImVec2, inner_width: Float32): Int32 { return unsafe { igBeginTable(str_id, columns, flags, outer_size, inner_width) } }

public func igEndTable_cj(): Unit { unsafe { igEndTable() } }

public func igTableNextRow_cj(row_flags: Int32, min_row_height: Float32): Unit { unsafe { igTableNextRow(row_flags, min_row_height) } }

public func igTableNextColumn_cj(): Int32 { return unsafe { igTableNextColumn() } }

public func igTableSetColumnIndex_cj(column_n: Int32): Int32 { return unsafe { igTableSetColumnIndex(column_n) } }

public func igTableSetupColumn_cj(label: CString, flags: Int32, init_width_or_weight: Float32, user_data: UInt32): Unit { unsafe { igTableSetupColumn(label, flags, init_width_or_weight, user_data) } }

public func igTableSetupScrollFreeze_cj(cols: Int32, rows: Int32): Unit { unsafe { igTableSetupScrollFreeze(cols, rows) } }

public func igTableHeader_cj(label: CString): Unit { unsafe { igTableHeader(label) } }

public func igTableHeadersRow_cj(): Unit { unsafe { igTableHeadersRow() } }

public func igTableAngledHeadersRow_cj(): Unit { unsafe { igTableAngledHeadersRow() } }

public func igTableGetSortSpecs_cj(): CPointer<Unit> { return unsafe { igTableGetSortSpecs() } }

public func igTableGetColumnCount_cj(): Int32 { return unsafe { igTableGetColumnCount() } }

public func igTableGetColumnIndex_cj(): Int32 { return unsafe { igTableGetColumnIndex() } }

public func igTableGetRowIndex_cj(): Int32 { return unsafe { igTableGetRowIndex() } }

public func igTableGetColumnName_Int_cj(column_n: Int32): String {
    return unsafe {
        let p = igTableGetColumnName_Int(column_n)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igTableGetColumnFlags_cj(column_n: Int32): Int32 { return unsafe { igTableGetColumnFlags(column_n) } }

public func igTableSetColumnEnabled_cj(column_n: Int32, v: Int32): Unit { unsafe { igTableSetColumnEnabled(column_n, v) } }

public func igTableGetHoveredColumn_cj(): Int32 { return unsafe { igTableGetHoveredColumn() } }

public func igTableSetBgColor_cj(target: Int32, color: UInt32, column_n: Int32): Unit { unsafe { igTableSetBgColor(target, color, column_n) } }

public func igColumns_cj(count: Int32, id: CString, borders: Int32): Unit { unsafe { igColumns(count, id, borders) } }

public func igNextColumn_cj(): Unit { unsafe { igNextColumn() } }

public func igGetColumnIndex_cj(): Int32 { return unsafe { igGetColumnIndex() } }

public func igGetColumnWidth_cj(column_index: Int32): Float32 { return unsafe { igGetColumnWidth(column_index) } }

public func igSetColumnWidth_cj(column_index: Int32, width: Float32): Unit { unsafe { igSetColumnWidth(column_index, width) } }

public func igGetColumnOffset_cj(column_index: Int32): Float32 { return unsafe { igGetColumnOffset(column_index) } }

public func igSetColumnOffset_cj(column_index: Int32, offset_x: Float32): Unit { unsafe { igSetColumnOffset(column_index, offset_x) } }

public func igGetColumnsCount_cj(): Int32 { return unsafe { igGetColumnsCount() } }

public func igBeginTabBar_cj(str_id: CString, flags: Int32): Int32 { return unsafe { igBeginTabBar(str_id, flags) } }

public func igEndTabBar_cj(): Unit { unsafe { igEndTabBar() } }

public func igBeginTabItem_cj(label: CString, p_open: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igBeginTabItem(label, p_open, flags) } }

public func igEndTabItem_cj(): Unit { unsafe { igEndTabItem() } }

public func igTabItemButton_cj(label: CString, flags: Int32): Int32 { return unsafe { igTabItemButton(label, flags) } }

public func igSetTabItemClosed_cj(tab_or_docked_window_label: CString): Unit { unsafe { igSetTabItemClosed(tab_or_docked_window_label) } }

public func igLogToTTY_cj(auto_open_depth: Int32): Unit { unsafe { igLogToTTY(auto_open_depth) } }

public func igLogToFile_cj(auto_open_depth: Int32, filename: CString): Unit { unsafe { igLogToFile(auto_open_depth, filename) } }

public func igLogToClipboard_cj(auto_open_depth: Int32): Unit { unsafe { igLogToClipboard(auto_open_depth) } }

public func igLogFinish_cj(): Unit { unsafe { igLogFinish() } }

public func igLogButtons_cj(): Unit { unsafe { igLogButtons() } }

public func igLogText0_cj(fmt: CString): Unit { unsafe { igLogText0(fmt) } }

public func igBeginDragDropSource_cj(flags: Int32): Int32 { return unsafe { igBeginDragDropSource(flags) } }

public func igSetDragDropPayload_cj(`type`: CString, data: CPointer<Unit>, sz: UIntNative, cond: Int32): Int32 { return unsafe { igSetDragDropPayload(`type`, data, sz, cond) } }

public func igEndDragDropSource_cj(): Unit { unsafe { igEndDragDropSource() } }

public func igBeginDragDropTarget_cj(): Int32 { return unsafe { igBeginDragDropTarget() } }

public func igAcceptDragDropPayload_cj(`type`: CString, flags: Int32): CPointer<Unit> { return unsafe { igAcceptDragDropPayload(`type`, flags) } }

public func igEndDragDropTarget_cj(): Unit { unsafe { igEndDragDropTarget() } }

public func igGetDragDropPayload_cj(): CPointer<Unit> { return unsafe { igGetDragDropPayload() } }

public func igBeginDisabled_cj(disabled: Int32): Unit { unsafe { igBeginDisabled(disabled) } }

public func igEndDisabled_cj(): Unit { unsafe { igEndDisabled() } }

public func igPushClipRect_cj(clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: Int32): Unit { unsafe { igPushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect) } }

public func igPopClipRect_cj(): Unit { unsafe { igPopClipRect() } }

public func igSetItemDefaultFocus_cj(): Unit { unsafe { igSetItemDefaultFocus() } }

public func igSetKeyboardFocusHere_cj(offset: Int32): Unit { unsafe { igSetKeyboardFocusHere(offset) } }

public func igSetNavCursorVisible_cj(visible: Int32): Unit { unsafe { igSetNavCursorVisible(visible) } }

public func igSetNextItemAllowOverlap_cj(): Unit { unsafe { igSetNextItemAllowOverlap() } }

public func igIsItemHovered_cj(flags: Int32): Int32 { return unsafe { igIsItemHovered(flags) } }

public func igIsItemActive_cj(): Int32 { return unsafe { igIsItemActive() } }

public func igIsItemFocused_cj(): Int32 { return unsafe { igIsItemFocused() } }

public func igIsItemClicked_cj(mouse_button: Int32): Int32 { return unsafe { igIsItemClicked(mouse_button) } }

public func igIsItemVisible_cj(): Int32 { return unsafe { igIsItemVisible() } }

public func igIsItemEdited_cj(): Int32 { return unsafe { igIsItemEdited() } }

public func igIsItemActivated_cj(): Int32 { return unsafe { igIsItemActivated() } }

public func igIsItemDeactivated_cj(): Int32 { return unsafe { igIsItemDeactivated() } }

public func igIsItemDeactivatedAfterEdit_cj(): Int32 { return unsafe { igIsItemDeactivatedAfterEdit() } }

public func igIsItemToggledOpen_cj(): Int32 { return unsafe { igIsItemToggledOpen() } }

public func igIsAnyItemHovered_cj(): Int32 { return unsafe { igIsAnyItemHovered() } }

public func igIsAnyItemActive_cj(): Int32 { return unsafe { igIsAnyItemActive() } }

public func igIsAnyItemFocused_cj(): Int32 { return unsafe { igIsAnyItemFocused() } }

public func igGetItemID_cj(): UInt32 { return unsafe { igGetItemID() } }

public func igGetItemRectMin_cj(): ImVec2 { return unsafe { igGetItemRectMin() } }

public func igGetItemRectMax_cj(): ImVec2 { return unsafe { igGetItemRectMax() } }

public func igGetItemRectSize_cj(): ImVec2 { return unsafe { igGetItemRectSize() } }

public func igGetItemFlags_cj(): Int32 { return unsafe { igGetItemFlags() } }

public func igGetItemClickedCountWithSingleClickDelay_cj(mouse_button: Int32, delay: Float32): Int32 { return unsafe { igGetItemClickedCountWithSingleClickDelay(mouse_button, delay) } }

public func igGetMainViewport_cj(): CPointer<Unit> { return unsafe { igGetMainViewport() } }

public func igGetBackgroundDrawList_Nil_cj(): CPointer<Unit> { return unsafe { igGetBackgroundDrawList_Nil() } }

public func igGetForegroundDrawList_Nil_cj(): CPointer<Unit> { return unsafe { igGetForegroundDrawList_Nil() } }

public func igIsRectVisible_Nil_cj(size: ImVec2): Int32 { return unsafe { igIsRectVisible_Nil(size) } }

public func igIsRectVisible_Vec2_cj(rect_min: ImVec2, rect_max: ImVec2): Int32 { return unsafe { igIsRectVisible_Vec2(rect_min, rect_max) } }

public func igGetTime_cj(): Float64 { return unsafe { igGetTime() } }

public func igGetFrameCount_cj(): Int32 { return unsafe { igGetFrameCount() } }

public func igGetDrawListSharedData_cj(): CPointer<Unit> { return unsafe { igGetDrawListSharedData() } }

public func igGetStyleColorName_cj(idx: Int32): String {
    return unsafe {
        let p = igGetStyleColorName(idx)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igSetStateStorage_cj(storage: CPointer<Unit>): Unit { unsafe { igSetStateStorage(storage) } }

public func igGetStateStorage_cj(): CPointer<Unit> { return unsafe { igGetStateStorage() } }

public func igCalcTextSize_cj(text: CString, text_end: CString, hide_text_after_double_hash: Int32, wrap_width: Float32): ImVec2 { return unsafe { igCalcTextSize(text, text_end, hide_text_after_double_hash, wrap_width) } }

public func igColorConvertU32ToFloat4_cj(`in`: UInt32): ImVec4 { return unsafe { igColorConvertU32ToFloat4(`in`) } }

public func igColorConvertFloat4ToU32_cj(`in`: ImVec4): UInt32 { return unsafe { igColorConvertFloat4ToU32(`in`) } }

public func igColorConvertRGBtoHSV_cj(r: Float32, g: Float32, b: Float32, out_h: CPointer<Float32>, out_s: CPointer<Float32>, out_v: CPointer<Float32>): Unit { unsafe { igColorConvertRGBtoHSV(r, g, b, out_h, out_s, out_v) } }

public func igColorConvertHSVtoRGB_cj(h: Float32, s: Float32, v: Float32, out_r: CPointer<Float32>, out_g: CPointer<Float32>, out_b: CPointer<Float32>): Unit { unsafe { igColorConvertHSVtoRGB(h, s, v, out_r, out_g, out_b) } }

public func igIsKeyDown_Nil_cj(key: Int32): Int32 { return unsafe { igIsKeyDown_Nil(key) } }

public func igIsKeyPressed_Bool_cj(key: Int32, repeat: Int32): Int32 { return unsafe { igIsKeyPressed_Bool(key, repeat) } }

public func igIsKeyReleased_Nil_cj(key: Int32): Int32 { return unsafe { igIsKeyReleased_Nil(key) } }

public func igIsKeyChordPressed_Nil_cj(key_chord: Int32): Int32 { return unsafe { igIsKeyChordPressed_Nil(key_chord) } }

public func igGetKeyPressedAmount_cj(key: Int32, repeat_delay: Float32, rate: Float32): Int32 { return unsafe { igGetKeyPressedAmount(key, repeat_delay, rate) } }

public func igGetKeyName_cj(key: Int32): String {
    return unsafe {
        let p = igGetKeyName(key)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igSetNextFrameWantCaptureKeyboard_cj(want_capture_keyboard: Int32): Unit { unsafe { igSetNextFrameWantCaptureKeyboard(want_capture_keyboard) } }

public func igShortcut_Nil_cj(key_chord: Int32, flags: Int32): Int32 { return unsafe { igShortcut_Nil(key_chord, flags) } }

public func igSetNextItemShortcut_cj(key_chord: Int32, flags: Int32): Unit { unsafe { igSetNextItemShortcut(key_chord, flags) } }

public func igSetItemKeyOwner_Nil_cj(key: Int32): Int32 { return unsafe { igSetItemKeyOwner_Nil(key) } }

public func igIsMouseDown_Nil_cj(button: Int32): Int32 { return unsafe { igIsMouseDown_Nil(button) } }

public func igIsMouseClicked_Bool_cj(button: Int32, repeat: Int32): Int32 { return unsafe { igIsMouseClicked_Bool(button, repeat) } }

public func igIsMouseReleased_Nil_cj(button: Int32): Int32 { return unsafe { igIsMouseReleased_Nil(button) } }

public func igIsMouseDoubleClicked_Nil_cj(button: Int32): Int32 { return unsafe { igIsMouseDoubleClicked_Nil(button) } }

public func igIsMouseReleasedWithDelay_cj(button: Int32, delay: Float32): Int32 { return unsafe { igIsMouseReleasedWithDelay(button, delay) } }

public func igGetMouseClickedCount_cj(button: Int32): Int32 { return unsafe { igGetMouseClickedCount(button) } }

public func igIsMouseHoveringRect_cj(r_min: ImVec2, r_max: ImVec2, clip: Int32): Int32 { return unsafe { igIsMouseHoveringRect(r_min, r_max, clip) } }

public func igIsMousePosValid_cj(mouse_pos: CPointer<ImVec2>): Int32 { return unsafe { igIsMousePosValid(mouse_pos) } }

public func igIsAnyMouseDown_cj(): Int32 { return unsafe { igIsAnyMouseDown() } }

public func igGetMousePos_cj(): ImVec2 { return unsafe { igGetMousePos() } }

public func igGetMousePosOnOpeningCurrentPopup_cj(): ImVec2 { return unsafe { igGetMousePosOnOpeningCurrentPopup() } }

public func igIsMouseDragging_cj(button: Int32, lock_threshold: Float32): Int32 { return unsafe { igIsMouseDragging(button, lock_threshold) } }

public func igIsMouseDown_cj(button: Int32): Int32 { return unsafe { igIsMouseDown_Nil(button) } }

public func igIsMouseClicked_cj(button: Int32, repeat: Bool): Int32 { return unsafe { if (igIsMouseClicked_Bool(button, if (repeat) { 1 } else { 0 }) != 0) { 1 } else { 0 } } }

public func igIsMouseDoubleClicked_cj(button: Int32): Int32 { return unsafe { igIsMouseDoubleClicked_Nil(button) } }

public func igGetMouseDragDelta_cj(button: Int32, lock_threshold: Float32): ImVec2 { return unsafe { igGetMouseDragDelta(button, lock_threshold) } }

public func igIsKeyDown_cj(key: Int32): Int32 { return unsafe { igIsKeyDown_Nil(key) } }

public func igIsKeyPressed_cj(key: Int32, repeat: Bool): Int32 { return unsafe { if (igIsKeyPressed_Bool(key, if (repeat) { 1 } else { 0 }) != 0) { 1 } else { 0 } } }

public func igResetMouseDragDelta_cj(button: Int32): Unit { unsafe { igResetMouseDragDelta(button) } }

public func igGetMouseCursor_cj(): Int32 { return unsafe { igGetMouseCursor() } }

public func igSetMouseCursor_cj(cursor_type: Int32): Unit { unsafe { igSetMouseCursor(cursor_type) } }

public func igSetNextFrameWantCaptureMouse_cj(want_capture_mouse: Int32): Unit { unsafe { igSetNextFrameWantCaptureMouse(want_capture_mouse) } }

public func igGetClipboardText_cj(): String {
    return unsafe {
        let p = igGetClipboardText()
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igSetClipboardText_cj(text: CString): Unit { unsafe { igSetClipboardText(text) } }

public func igLoadIniSettingsFromDisk_cj(ini_filename: CString): Unit { unsafe { igLoadIniSettingsFromDisk(ini_filename) } }

public func igLoadIniSettingsFromMemory_cj(ini_data: CString, ini_size: UIntNative): Unit { unsafe { igLoadIniSettingsFromMemory(ini_data, ini_size) } }

public func igSaveIniSettingsToDisk_cj(ini_filename: CString): Unit { unsafe { igSaveIniSettingsToDisk(ini_filename) } }

public func igSaveIniSettingsToMemory_cj(out_ini_size: CPointer<UIntNative>): String {
    return unsafe {
        let p = igSaveIniSettingsToMemory(out_ini_size)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igDebugTextEncoding_cj(text: CString): Unit { unsafe { igDebugTextEncoding(text) } }

public func igDebugFlashStyleColor_cj(idx: Int32): Unit { unsafe { igDebugFlashStyleColor(idx) } }

public func igDebugStartItemPicker_cj(): Unit { unsafe { igDebugStartItemPicker() } }

public func igDebugCheckVersionAndDataLayout_cj(version_str: CString, sz_io: UIntNative, sz_style: UIntNative, sz_vec2: UIntNative, sz_vec4: UIntNative, sz_drawvert: UIntNative, sz_drawidx: UIntNative): Int32 { return unsafe { igDebugCheckVersionAndDataLayout(version_str, sz_io, sz_style, sz_vec2, sz_vec4, sz_drawvert, sz_drawidx) } }

public func igDebugLog0_cj(fmt: CString): Unit { unsafe { igDebugLog0(fmt) } }

public func igSetAllocatorFunctions_cj(alloc_func: CPointer<Unit>, free_func: CPointer<Unit>, user_data: CPointer<Unit>): Unit { unsafe { igSetAllocatorFunctions(alloc_func, free_func, user_data) } }

public func igGetAllocatorFunctions_cj(p_alloc_func: CPointer<Unit>, p_free_func: CPointer<Unit>, p_user_data: CPointer<Unit>): Unit { unsafe { igGetAllocatorFunctions(p_alloc_func, p_free_func, p_user_data) } }

public func igMemAlloc_cj(size: UIntNative): CPointer<Unit> { return unsafe { igMemAlloc(size) } }

public func igMemFree_cj(ptr: CPointer<Unit>): Unit { unsafe { igMemFree(ptr) } }

public func ImGuiTableSortSpecs_ImGuiTableSortSpecs_cj(): CPointer<Unit> { return unsafe { ImGuiTableSortSpecs_ImGuiTableSortSpecs() } }

public func ImGuiTableSortSpecs_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableSortSpecs_destroy(self) } }

public func ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs_cj(): CPointer<Unit> { return unsafe { ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs() } }

public func ImGuiTableColumnSortSpecs_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableColumnSortSpecs_destroy(self) } }

public func ImGuiStyle_ImGuiStyle_cj(): CPointer<Unit> { return unsafe { ImGuiStyle_ImGuiStyle() } }

public func ImGuiStyle_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStyle_destroy(self) } }

public func ImGuiStyle_ScaleAllSizes_cj(self: CPointer<Unit>, scale_factor: Float32): Unit { unsafe { ImGuiStyle_ScaleAllSizes(self, scale_factor) } }

public func ImGuiIO_AddKeyEvent_cj(self: CPointer<Unit>, key: Int32, down: Int32): Unit { unsafe { ImGuiIO_AddKeyEvent(self, key, down) } }

public func ImGuiIO_AddKeyAnalogEvent_cj(self: CPointer<Unit>, key: Int32, down: Int32, v: Float32): Unit { unsafe { ImGuiIO_AddKeyAnalogEvent(self, key, down, v) } }

public func ImGuiIO_AddMousePosEvent_cj(self: CPointer<Unit>, x: Float32, y: Float32): Unit { unsafe { ImGuiIO_AddMousePosEvent(self, x, y) } }

public func ImGuiIO_AddMouseButtonEvent_cj(self: CPointer<Unit>, button: Int32, down: Int32): Unit { unsafe { ImGuiIO_AddMouseButtonEvent(self, button, down) } }

public func ImGuiIO_AddMouseWheelEvent_cj(self: CPointer<Unit>, wheel_x: Float32, wheel_y: Float32): Unit { unsafe { ImGuiIO_AddMouseWheelEvent(self, wheel_x, wheel_y) } }

public func ImGuiIO_AddMouseSourceEvent_cj(self: CPointer<Unit>, source: Int32): Unit { unsafe { ImGuiIO_AddMouseSourceEvent(self, source) } }

public func ImGuiIO_AddFocusEvent_cj(self: CPointer<Unit>, focused: Int32): Unit { unsafe { ImGuiIO_AddFocusEvent(self, focused) } }

public func ImGuiIO_AddInputCharacter_cj(self: CPointer<Unit>, c: UInt32): Unit { unsafe { ImGuiIO_AddInputCharacter(self, c) } }

public func ImGuiIO_AddInputCharacterUTF16_cj(self: CPointer<Unit>, c: UInt16): Unit { unsafe { ImGuiIO_AddInputCharacterUTF16(self, c) } }

public func ImGuiIO_AddInputCharactersUTF8_cj(self: CPointer<Unit>, str: CString): Unit { unsafe { ImGuiIO_AddInputCharactersUTF8(self, str) } }

public func ImGuiIO_SetKeyEventNativeData_cj(self: CPointer<Unit>, key: Int32, native_keycode: Int32, native_scancode: Int32, native_legacy_index: Int32): Unit { unsafe { ImGuiIO_SetKeyEventNativeData(self, key, native_keycode, native_scancode, native_legacy_index) } }

public func ImGuiIO_SetAppAcceptingEvents_cj(self: CPointer<Unit>, accepting_events: Int32): Unit { unsafe { ImGuiIO_SetAppAcceptingEvents(self, accepting_events) } }

public func ImGuiIO_ClearEventsQueue_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiIO_ClearEventsQueue(self) } }

public func ImGuiIO_ClearInputKeys_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiIO_ClearInputKeys(self) } }

public func ImGuiIO_ClearInputMouse_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiIO_ClearInputMouse(self) } }

public func ImGuiIO_ImGuiIO_cj(): CPointer<Unit> { return unsafe { ImGuiIO_ImGuiIO() } }

public func ImGuiIO_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiIO_destroy(self) } }

public func ImGuiInputTextCallbackData_ImGuiInputTextCallbackData_cj(): CPointer<Unit> { return unsafe { ImGuiInputTextCallbackData_ImGuiInputTextCallbackData() } }

public func ImGuiInputTextCallbackData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextCallbackData_destroy(self) } }

public func ImGuiInputTextCallbackData_DeleteChars_cj(self: CPointer<Unit>, pos: Int32, bytes_count: Int32): Unit { unsafe { ImGuiInputTextCallbackData_DeleteChars(self, pos, bytes_count) } }

public func ImGuiInputTextCallbackData_InsertChars_cj(self: CPointer<Unit>, pos: Int32, text: CString, text_end: CString): Unit { unsafe { ImGuiInputTextCallbackData_InsertChars(self, pos, text, text_end) } }

public func ImGuiInputTextCallbackData_SelectAll_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextCallbackData_SelectAll(self) } }

public func ImGuiInputTextCallbackData_SetSelection_cj(self: CPointer<Unit>, s: Int32, e: Int32): Unit { unsafe { ImGuiInputTextCallbackData_SetSelection(self, s, e) } }

public func ImGuiInputTextCallbackData_ClearSelection_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextCallbackData_ClearSelection(self) } }

public func ImGuiInputTextCallbackData_HasSelection_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiInputTextCallbackData_HasSelection(self) } }

public func ImGuiPayload_ImGuiPayload_cj(): CPointer<Unit> { return unsafe { ImGuiPayload_ImGuiPayload() } }

public func ImGuiPayload_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPayload_destroy(self) } }

public func ImGuiPayload_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPayload_Clear(self) } }

public func ImGuiPayload_IsDataType_cj(self: CPointer<Unit>, `type`: CString): Int32 { return unsafe { ImGuiPayload_IsDataType(self, `type`) } }

public func ImGuiPayload_IsPreview_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiPayload_IsPreview(self) } }

public func ImGuiPayload_IsDelivery_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiPayload_IsDelivery(self) } }

public func ImGuiOnceUponAFrame_ImGuiOnceUponAFrame_cj(): CPointer<Unit> { return unsafe { ImGuiOnceUponAFrame_ImGuiOnceUponAFrame() } }

public func ImGuiOnceUponAFrame_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiOnceUponAFrame_destroy(self) } }

public func ImGuiTextFilter_ImGuiTextFilter_cj(default_filter: CString): CPointer<Unit> { return unsafe { ImGuiTextFilter_ImGuiTextFilter(default_filter) } }

public func ImGuiTextFilter_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextFilter_destroy(self) } }

public func ImGuiTextFilter_Draw_cj(self: CPointer<Unit>, label: CString, width: Float32): Int32 { return unsafe { ImGuiTextFilter_Draw(self, label, width) } }

public func ImGuiTextFilter_PassFilter_cj(self: CPointer<Unit>, text: CString, text_end: CString): Int32 { return unsafe { ImGuiTextFilter_PassFilter(self, text, text_end) } }

public func ImGuiTextFilter_Build_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextFilter_Build(self) } }

public func ImGuiTextFilter_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextFilter_Clear(self) } }

public func ImGuiTextFilter_IsActive_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiTextFilter_IsActive(self) } }

public func ImGuiTextRange_ImGuiTextRange_Nil_cj(): CPointer<Unit> { return unsafe { ImGuiTextRange_ImGuiTextRange_Nil() } }

public func ImGuiTextRange_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextRange_destroy(self) } }

public func ImGuiTextRange_ImGuiTextRange_Str_cj(_b: CString, _e: CString): CPointer<Unit> { return unsafe { ImGuiTextRange_ImGuiTextRange_Str(_b, _e) } }

public func ImGuiTextRange_empty_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiTextRange_empty(self) } }

public func ImGuiTextRange_split_cj(self: CPointer<Unit>, separator: Int8, `out`: CPointer<Unit>): Unit { unsafe { ImGuiTextRange_split(self, separator, `out`) } }

public func ImGuiTextBuffer_ImGuiTextBuffer_cj(): CPointer<Unit> { return unsafe { ImGuiTextBuffer_ImGuiTextBuffer() } }

public func ImGuiTextBuffer_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextBuffer_destroy(self) } }

public func ImGuiTextBuffer_begin_cj(self: CPointer<Unit>): String {
    return unsafe {
        let p = ImGuiTextBuffer_begin(self)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiTextBuffer_end_cj(self: CPointer<Unit>): String {
    return unsafe {
        let p = ImGuiTextBuffer_end(self)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiTextBuffer_size_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiTextBuffer_size(self) } }

public func ImGuiTextBuffer_empty_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiTextBuffer_empty(self) } }

public func ImGuiTextBuffer_clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextBuffer_clear(self) } }

public func ImGuiTextBuffer_resize_cj(self: CPointer<Unit>, size: Int32): Unit { unsafe { ImGuiTextBuffer_resize(self, size) } }

public func ImGuiTextBuffer_reserve_cj(self: CPointer<Unit>, capacity: Int32): Unit { unsafe { ImGuiTextBuffer_reserve(self, capacity) } }

public func ImGuiTextBuffer_c_str_cj(self: CPointer<Unit>): String {
    return unsafe {
        let p = ImGuiTextBuffer_c_str(self)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiTextBuffer_append_cj(self: CPointer<Unit>, str: CString, str_end: CString): Unit { unsafe { ImGuiTextBuffer_append(self, str, str_end) } }

public func ImGuiStoragePair_ImGuiStoragePair_Int_cj(_key: UInt32, _val: Int32): CPointer<Unit> { return unsafe { ImGuiStoragePair_ImGuiStoragePair_Int(_key, _val) } }

public func ImGuiStoragePair_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStoragePair_destroy(self) } }

public func ImGuiStoragePair_ImGuiStoragePair_Float_cj(_key: UInt32, _val: Float32): CPointer<Unit> { return unsafe { ImGuiStoragePair_ImGuiStoragePair_Float(_key, _val) } }

public func ImGuiStoragePair_ImGuiStoragePair_Ptr_cj(_key: UInt32, _val: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiStoragePair_ImGuiStoragePair_Ptr(_key, _val) } }

public func ImGuiStorage_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStorage_Clear(self) } }

public func ImGuiStorage_GetInt_cj(self: CPointer<Unit>, key: UInt32, default_val: Int32): Int32 { return unsafe { ImGuiStorage_GetInt(self, key, default_val) } }

public func ImGuiStorage_SetInt_cj(self: CPointer<Unit>, key: UInt32, val: Int32): Unit { unsafe { ImGuiStorage_SetInt(self, key, val) } }

public func ImGuiStorage_GetBool_cj(self: CPointer<Unit>, key: UInt32, default_val: Int32): Int32 { return unsafe { ImGuiStorage_GetBool(self, key, default_val) } }

public func ImGuiStorage_SetBool_cj(self: CPointer<Unit>, key: UInt32, val: Int32): Unit { unsafe { ImGuiStorage_SetBool(self, key, val) } }

public func ImGuiStorage_GetFloat_cj(self: CPointer<Unit>, key: UInt32, default_val: Float32): Float32 { return unsafe { ImGuiStorage_GetFloat(self, key, default_val) } }

public func ImGuiStorage_SetFloat_cj(self: CPointer<Unit>, key: UInt32, val: Float32): Unit { unsafe { ImGuiStorage_SetFloat(self, key, val) } }

public func ImGuiStorage_GetVoidPtr_cj(self: CPointer<Unit>, key: UInt32): CPointer<Unit> { return unsafe { ImGuiStorage_GetVoidPtr(self, key) } }

public func ImGuiStorage_SetVoidPtr_cj(self: CPointer<Unit>, key: UInt32, val: CPointer<Unit>): Unit { unsafe { ImGuiStorage_SetVoidPtr(self, key, val) } }

public func ImGuiStorage_GetIntRef_cj(self: CPointer<Unit>, key: UInt32, default_val: Int32): CPointer<Int32> { return unsafe { ImGuiStorage_GetIntRef(self, key, default_val) } }

public func ImGuiStorage_GetBoolRef_cj(self: CPointer<Unit>, key: UInt32, default_val: Int32): CPointer<Int32> { return unsafe { ImGuiStorage_GetBoolRef(self, key, default_val) } }

public func ImGuiStorage_GetFloatRef_cj(self: CPointer<Unit>, key: UInt32, default_val: Float32): CPointer<Float32> { return unsafe { ImGuiStorage_GetFloatRef(self, key, default_val) } }

public func ImGuiStorage_GetVoidPtrRef_cj(self: CPointer<Unit>, key: UInt32, default_val: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiStorage_GetVoidPtrRef(self, key, default_val) } }

public func ImGuiStorage_BuildSortByKey_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStorage_BuildSortByKey(self) } }

public func ImGuiStorage_SetAllInt_cj(self: CPointer<Unit>, val: Int32): Unit { unsafe { ImGuiStorage_SetAllInt(self, val) } }

public func ImGuiListClipper_ImGuiListClipper_cj(): CPointer<Unit> { return unsafe { ImGuiListClipper_ImGuiListClipper() } }

public func ImGuiListClipper_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiListClipper_destroy(self) } }

public func ImGuiListClipper_Begin_cj(self: CPointer<Unit>, items_count: Int32, items_height: Float32): Unit { unsafe { ImGuiListClipper_Begin(self, items_count, items_height) } }

public func ImGuiListClipper_End_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiListClipper_End(self) } }

public func ImGuiListClipper_Step_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiListClipper_Step(self) } }

public func ImGuiListClipper_IncludeItemByIndex_cj(self: CPointer<Unit>, item_index: Int32): Unit { unsafe { ImGuiListClipper_IncludeItemByIndex(self, item_index) } }

public func ImGuiListClipper_IncludeItemsByIndex_cj(self: CPointer<Unit>, item_begin: Int32, item_end: Int32): Unit { unsafe { ImGuiListClipper_IncludeItemsByIndex(self, item_begin, item_end) } }

public func ImGuiListClipper_SeekCursorForItem_cj(self: CPointer<Unit>, item_index: Int32): Unit { unsafe { ImGuiListClipper_SeekCursorForItem(self, item_index) } }

public func ImColor_ImColor_Nil_cj(): CPointer<Unit> { return unsafe { ImColor_ImColor_Nil() } }

public func ImColor_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImColor_destroy(self) } }

public func ImColor_ImColor_Float_cj(r: Float32, g: Float32, b: Float32, a: Float32): CPointer<Unit> { return unsafe { ImColor_ImColor_Float(r, g, b, a) } }

public func ImColor_ImColor_Vec4_cj(col: ImVec4): CPointer<Unit> { return unsafe { ImColor_ImColor_Vec4(col) } }

public func ImColor_ImColor_Int_cj(r: Int32, g: Int32, b: Int32, a: Int32): CPointer<Unit> { return unsafe { ImColor_ImColor_Int(r, g, b, a) } }

public func ImColor_ImColor_U32_cj(rgba: UInt32): CPointer<Unit> { return unsafe { ImColor_ImColor_U32(rgba) } }

public func ImColor_SetHSV_cj(self: CPointer<Unit>, h: Float32, s: Float32, v: Float32, a: Float32): Unit { unsafe { ImColor_SetHSV(self, h, s, v, a) } }

public func ImColor_HSV_cj(h: Float32, s: Float32, v: Float32, a: Float32): CPointer<Unit> { return unsafe { ImColor_HSV(h, s, v, a) } }

public func ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage_cj(): CPointer<Unit> { return unsafe { ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage() } }

public func ImGuiSelectionBasicStorage_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiSelectionBasicStorage_destroy(self) } }

public func ImGuiSelectionBasicStorage_ApplyRequests_cj(self: CPointer<Unit>, ms_io: CPointer<Unit>): Unit { unsafe { ImGuiSelectionBasicStorage_ApplyRequests(self, ms_io) } }

public func ImGuiSelectionBasicStorage_Contains_cj(self: CPointer<Unit>, id: UInt32): Int32 { return unsafe { ImGuiSelectionBasicStorage_Contains(self, id) } }

public func ImGuiSelectionBasicStorage_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiSelectionBasicStorage_Clear(self) } }

public func ImGuiSelectionBasicStorage_Swap_cj(self: CPointer<Unit>, r: CPointer<Unit>): Unit { unsafe { ImGuiSelectionBasicStorage_Swap(self, r) } }

public func ImGuiSelectionBasicStorage_SetItemSelected_cj(self: CPointer<Unit>, id: UInt32, selected: Int32): Unit { unsafe { ImGuiSelectionBasicStorage_SetItemSelected(self, id, selected) } }

public func ImGuiSelectionBasicStorage_GetNextSelectedItem_cj(self: CPointer<Unit>, opaque_it: CPointer<Unit>, out_id: CPointer<UInt32>): Int32 { return unsafe { ImGuiSelectionBasicStorage_GetNextSelectedItem(self, opaque_it, out_id) } }

public func ImGuiSelectionBasicStorage_GetStorageIdFromIndex_cj(self: CPointer<Unit>, idx: Int32): UInt32 { return unsafe { ImGuiSelectionBasicStorage_GetStorageIdFromIndex(self, idx) } }

public func ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage_cj(): CPointer<Unit> { return unsafe { ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage() } }

public func ImGuiSelectionExternalStorage_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiSelectionExternalStorage_destroy(self) } }

public func ImGuiSelectionExternalStorage_ApplyRequests_cj(self: CPointer<Unit>, ms_io: CPointer<Unit>): Unit { unsafe { ImGuiSelectionExternalStorage_ApplyRequests(self, ms_io) } }

public func ImDrawCmd_ImDrawCmd_cj(): CPointer<Unit> { return unsafe { ImDrawCmd_ImDrawCmd() } }

public func ImDrawCmd_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawCmd_destroy(self) } }

public func ImDrawCmd_GetTexID_cj(self: CPointer<Unit>): UInt64 { return unsafe { ImDrawCmd_GetTexID(self) } }

public func ImDrawListSplitter_ImDrawListSplitter_cj(): CPointer<Unit> { return unsafe { ImDrawListSplitter_ImDrawListSplitter() } }

public func ImDrawListSplitter_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawListSplitter_destroy(self) } }

public func ImDrawListSplitter_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawListSplitter_Clear(self) } }

public func ImDrawListSplitter_ClearFreeMemory_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawListSplitter_ClearFreeMemory(self) } }

public func ImDrawListSplitter_Split_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>, count: Int32): Unit { unsafe { ImDrawListSplitter_Split(self, draw_list, count) } }

public func ImDrawListSplitter_Merge_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>): Unit { unsafe { ImDrawListSplitter_Merge(self, draw_list) } }

public func ImDrawListSplitter_SetCurrentChannel_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>, channel_idx: Int32): Unit { unsafe { ImDrawListSplitter_SetCurrentChannel(self, draw_list, channel_idx) } }

public func ImDrawList_ImDrawList_cj(shared_data: CPointer<Unit>): CPointer<Unit> { return unsafe { ImDrawList_ImDrawList(shared_data) } }

public func ImDrawList_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_destroy(self) } }

public func ImDrawList_PushClipRect_cj(self: CPointer<Unit>, clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: Int32): Unit { unsafe { ImDrawList_PushClipRect(self, clip_rect_min, clip_rect_max, intersect_with_current_clip_rect) } }

public func ImDrawList_PushClipRectFullScreen_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_PushClipRectFullScreen(self) } }

public func ImDrawList_PopClipRect_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_PopClipRect(self) } }

public func ImDrawList_PushTexture_cj(self: CPointer<Unit>, tex_ref: CPointer<Unit>): Unit { unsafe { ImDrawList_PushTexture(self, tex_ref) } }

public func ImDrawList_PopTexture_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_PopTexture(self) } }

public func ImDrawList_GetClipRectMin_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImDrawList_GetClipRectMin(self) } }

public func ImDrawList_GetClipRectMax_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImDrawList_GetClipRectMax(self) } }

public func ImDrawList_AddLine_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, col: UInt32, thickness: Float32): Unit { unsafe { ImDrawList_AddLine(self, p1, p2, col, thickness) } }

public func ImDrawList_AddLineH_cj(self: CPointer<Unit>, min_x: Float32, max_x: Float32, y: Float32, col: UInt32, thickness: Float32): Unit { unsafe { ImDrawList_AddLineH(self, min_x, max_x, y, col, thickness) } }

public func ImDrawList_AddLineV_cj(self: CPointer<Unit>, x: Float32, min_y: Float32, max_y: Float32, col: UInt32, thickness: Float32): Unit { unsafe { ImDrawList_AddLineV(self, x, min_y, max_y, col, thickness) } }

public func ImDrawList_AddRect_cj(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col: UInt32, rounding: Float32, thickness: Float32, flags: Int32): Unit { unsafe { ImDrawList_AddRect(self, p_min, p_max, col, rounding, thickness, flags) } }

public func ImDrawList_AddRectFilled_cj(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col: UInt32, rounding: Float32, flags: Int32): Unit { unsafe { ImDrawList_AddRectFilled(self, p_min, p_max, col, rounding, flags) } }

public func ImDrawList_AddRectFilledMultiColor_cj(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col_upr_left: UInt32, col_upr_right: UInt32, col_bot_right: UInt32, col_bot_left: UInt32): Unit { unsafe { ImDrawList_AddRectFilledMultiColor(self, p_min, p_max, col_upr_left, col_upr_right, col_bot_right, col_bot_left) } }

public func ImDrawList_AddQuad_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32, thickness: Float32): Unit { unsafe { ImDrawList_AddQuad(self, p1, p2, p3, p4, col, thickness) } }

public func ImDrawList_AddQuadFilled_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_AddQuadFilled(self, p1, p2, p3, p4, col) } }

public func ImDrawList_AddTriangle_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32, thickness: Float32): Unit { unsafe { ImDrawList_AddTriangle(self, p1, p2, p3, col, thickness) } }

public func ImDrawList_AddTriangleFilled_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_AddTriangleFilled(self, p1, p2, p3, col) } }

public func ImDrawList_AddCircle_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32, thickness: Float32): Unit { unsafe { ImDrawList_AddCircle(self, center, radius, col, num_segments, thickness) } }

public func ImDrawList_AddCircleFilled_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32): Unit { unsafe { ImDrawList_AddCircleFilled(self, center, radius, col, num_segments) } }

public func ImDrawList_AddNgon_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32, thickness: Float32): Unit { unsafe { ImDrawList_AddNgon(self, center, radius, col, num_segments, thickness) } }

public func ImDrawList_AddNgonFilled_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32): Unit { unsafe { ImDrawList_AddNgonFilled(self, center, radius, col, num_segments) } }

public func ImDrawList_AddEllipse_cj(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, col: UInt32, rot: Float32, num_segments: Int32, thickness: Float32): Unit { unsafe { ImDrawList_AddEllipse(self, center, radius, col, rot, num_segments, thickness) } }

public func ImDrawList_AddEllipseFilled_cj(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, col: UInt32, rot: Float32, num_segments: Int32): Unit { unsafe { ImDrawList_AddEllipseFilled(self, center, radius, col, rot, num_segments) } }

public func ImDrawList_AddText_Vec2_cj(self: CPointer<Unit>, pos: ImVec2, col: UInt32, text_begin: CString, text_end: CString): Unit { unsafe { ImDrawList_AddText_Vec2(self, pos, col, text_begin, text_end) } }

public func ImDrawList_AddText_FontPtr_cj(self: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, pos: ImVec2, col: UInt32, text_begin: CString, text_end: CString, wrap_width: Float32, cpu_fine_clip_rect: CPointer<Unit>): Unit { unsafe { ImDrawList_AddText_FontPtr(self, font, font_size, pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect) } }

public func ImDrawList_AddBezierCubic_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32, thickness: Float32, num_segments: Int32): Unit { unsafe { ImDrawList_AddBezierCubic(self, p1, p2, p3, p4, col, thickness, num_segments) } }

public func ImDrawList_AddBezierQuadratic_cj(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32, thickness: Float32, num_segments: Int32): Unit { unsafe { ImDrawList_AddBezierQuadratic(self, p1, p2, p3, col, thickness, num_segments) } }

public func ImDrawList_AddPolyline_cj(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32, thickness: Float32, flags: Int32): Unit { unsafe { ImDrawList_AddPolyline(self, points, num_points, col, thickness, flags) } }

public func ImDrawList_AddConvexPolyFilled_cj(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32): Unit { unsafe { ImDrawList_AddConvexPolyFilled(self, points, num_points, col) } }

public func ImDrawList_AddConcavePolyFilled_cj(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32): Unit { unsafe { ImDrawList_AddConcavePolyFilled(self, points, num_points, col) } }

public func ImDrawList_AddImage_cj(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_AddImage(self, tex_ref, p_min, p_max, uv_min, uv_max, col) } }

public func ImDrawList_AddImageQuad_cj(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, uv1: ImVec2, uv2: ImVec2, uv3: ImVec2, uv4: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_AddImageQuad(self, tex_ref, p1, p2, p3, p4, uv1, uv2, uv3, uv4, col) } }

public func ImDrawList_AddImageRounded_cj(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: UInt32, rounding: Float32, flags: Int32): Unit { unsafe { ImDrawList_AddImageRounded(self, tex_ref, p_min, p_max, uv_min, uv_max, col, rounding, flags) } }

public func ImDrawList_PathClear_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_PathClear(self) } }

public func ImDrawList_PathLineTo_cj(self: CPointer<Unit>, pos: ImVec2): Unit { unsafe { ImDrawList_PathLineTo(self, pos) } }

public func ImDrawList_PathLineToMergeDuplicate_cj(self: CPointer<Unit>, pos: ImVec2): Unit { unsafe { ImDrawList_PathLineToMergeDuplicate(self, pos) } }

public func ImDrawList_PathFillConvex_cj(self: CPointer<Unit>, col: UInt32): Unit { unsafe { ImDrawList_PathFillConvex(self, col) } }

public func ImDrawList_PathFillConcave_cj(self: CPointer<Unit>, col: UInt32): Unit { unsafe { ImDrawList_PathFillConcave(self, col) } }

public func ImDrawList_PathStroke_cj(self: CPointer<Unit>, col: UInt32, thickness: Float32, flags: Int32): Unit { unsafe { ImDrawList_PathStroke(self, col, thickness, flags) } }

public func ImDrawList_PathArcTo_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit { unsafe { ImDrawList_PathArcTo(self, center, radius, a_min, a_max, num_segments) } }

public func ImDrawList_PathArcToFast_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min_of_12: Int32, a_max_of_12: Int32): Unit { unsafe { ImDrawList_PathArcToFast(self, center, radius, a_min_of_12, a_max_of_12) } }

public func ImDrawList_PathEllipticalArcTo_cj(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, rot: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit { unsafe { ImDrawList_PathEllipticalArcTo(self, center, radius, rot, a_min, a_max, num_segments) } }

public func ImDrawList_PathBezierCubicCurveTo_cj(self: CPointer<Unit>, p2: ImVec2, p3: ImVec2, p4: ImVec2, num_segments: Int32): Unit { unsafe { ImDrawList_PathBezierCubicCurveTo(self, p2, p3, p4, num_segments) } }

public func ImDrawList_PathBezierQuadraticCurveTo_cj(self: CPointer<Unit>, p2: ImVec2, p3: ImVec2, num_segments: Int32): Unit { unsafe { ImDrawList_PathBezierQuadraticCurveTo(self, p2, p3, num_segments) } }

public func ImDrawList_PathRect_cj(self: CPointer<Unit>, rect_min: ImVec2, rect_max: ImVec2, rounding: Float32, flags: Int32): Unit { unsafe { ImDrawList_PathRect(self, rect_min, rect_max, rounding, flags) } }

public func ImDrawList_AddCallback_cj(self: CPointer<Unit>, callback: CPointer<Unit>, userdata: CPointer<Unit>, userdata_size: UIntNative): Unit { unsafe { ImDrawList_AddCallback(self, callback, userdata, userdata_size) } }

public func ImDrawList_AddDrawCmd_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_AddDrawCmd(self) } }

public func ImDrawList_CloneOutput_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImDrawList_CloneOutput(self) } }

public func ImDrawList_ChannelsSplit_cj(self: CPointer<Unit>, count: Int32): Unit { unsafe { ImDrawList_ChannelsSplit(self, count) } }

public func ImDrawList_ChannelsMerge_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList_ChannelsMerge(self) } }

public func ImDrawList_ChannelsSetCurrent_cj(self: CPointer<Unit>, n: Int32): Unit { unsafe { ImDrawList_ChannelsSetCurrent(self, n) } }

public func ImDrawList_PrimReserve_cj(self: CPointer<Unit>, idx_count: Int32, vtx_count: Int32): Unit { unsafe { ImDrawList_PrimReserve(self, idx_count, vtx_count) } }

public func ImDrawList_PrimUnreserve_cj(self: CPointer<Unit>, idx_count: Int32, vtx_count: Int32): Unit { unsafe { ImDrawList_PrimUnreserve(self, idx_count, vtx_count) } }

public func ImDrawList_PrimRect_cj(self: CPointer<Unit>, a: ImVec2, b: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_PrimRect(self, a, b, col) } }

public func ImDrawList_PrimRectUV_cj(self: CPointer<Unit>, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_PrimRectUV(self, a, b, uv_a, uv_b, col) } }

public func ImDrawList_PrimQuadUV_cj(self: CPointer<Unit>, a: ImVec2, b: ImVec2, c: ImVec2, d: ImVec2, uv_a: ImVec2, uv_b: ImVec2, uv_c: ImVec2, uv_d: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_PrimQuadUV(self, a, b, c, d, uv_a, uv_b, uv_c, uv_d, col) } }

public func ImDrawList_PrimWriteVtx_cj(self: CPointer<Unit>, pos: ImVec2, uv: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_PrimWriteVtx(self, pos, uv, col) } }

public func ImDrawList_PrimWriteIdx_cj(self: CPointer<Unit>, idx: UInt16): Unit { unsafe { ImDrawList_PrimWriteIdx(self, idx) } }

public func ImDrawList_PrimVtx_cj(self: CPointer<Unit>, pos: ImVec2, uv: ImVec2, col: UInt32): Unit { unsafe { ImDrawList_PrimVtx(self, pos, uv, col) } }

public func ImDrawList__SetDrawListSharedData_cj(self: CPointer<Unit>, data: CPointer<Unit>): Unit { unsafe { ImDrawList__SetDrawListSharedData(self, data) } }

public func ImDrawList__ResetForNewFrame_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__ResetForNewFrame(self) } }

public func ImDrawList__ClearFreeMemory_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__ClearFreeMemory(self) } }

public func ImDrawList__PopUnusedDrawCmd_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__PopUnusedDrawCmd(self) } }

public func ImDrawList__TryMergeDrawCmds_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__TryMergeDrawCmds(self) } }

public func ImDrawList__OnChangedClipRect_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__OnChangedClipRect(self) } }

public func ImDrawList__OnChangedTexture_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__OnChangedTexture(self) } }

public func ImDrawList__OnChangedVtxOffset_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawList__OnChangedVtxOffset(self) } }

public func ImDrawList__SetTexture_cj(self: CPointer<Unit>, tex_ref: CPointer<Unit>): Unit { unsafe { ImDrawList__SetTexture(self, tex_ref) } }

public func ImDrawList__CalcCircleAutoSegmentCount_cj(self: CPointer<Unit>, radius: Float32): Int32 { return unsafe { ImDrawList__CalcCircleAutoSegmentCount(self, radius) } }

public func ImDrawList__PathArcToFastEx_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min_sample: Int32, a_max_sample: Int32, a_step: Int32): Unit { unsafe { ImDrawList__PathArcToFastEx(self, center, radius, a_min_sample, a_max_sample, a_step) } }

public func ImDrawList__PathArcToN_cj(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit { unsafe { ImDrawList__PathArcToN(self, center, radius, a_min, a_max, num_segments) } }

public func ImDrawData_ImDrawData_cj(): CPointer<Unit> { return unsafe { ImDrawData_ImDrawData() } }

public func ImDrawData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawData_destroy(self) } }

public func ImDrawData_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawData_Clear(self) } }

public func ImDrawData_AddDrawList_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>): Unit { unsafe { ImDrawData_AddDrawList(self, draw_list) } }

public func ImDrawData_DeIndexAllBuffers_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawData_DeIndexAllBuffers(self) } }

public func ImDrawData_ScaleClipRects_cj(self: CPointer<Unit>, fb_scale: ImVec2): Unit { unsafe { ImDrawData_ScaleClipRects(self, fb_scale) } }

public func ImTextureData_ImTextureData_cj(): CPointer<Unit> { return unsafe { ImTextureData_ImTextureData() } }

public func ImTextureData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImTextureData_destroy(self) } }

public func ImTextureData_Create_cj(self: CPointer<Unit>, format: Int32, w: Int32, h: Int32): Unit { unsafe { ImTextureData_Create(self, format, w, h) } }

public func ImTextureData_DestroyPixels_cj(self: CPointer<Unit>): Unit { unsafe { ImTextureData_DestroyPixels(self) } }

public func ImTextureData_GetPixels_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImTextureData_GetPixels(self) } }

public func ImTextureData_GetPixelsAt_cj(self: CPointer<Unit>, x: Int32, y: Int32): CPointer<Unit> { return unsafe { ImTextureData_GetPixelsAt(self, x, y) } }

public func ImTextureData_GetSizeInBytes_cj(self: CPointer<Unit>): Int32 { return unsafe { ImTextureData_GetSizeInBytes(self) } }

public func ImTextureData_GetPitch_cj(self: CPointer<Unit>): Int32 { return unsafe { ImTextureData_GetPitch(self) } }

public func ImTextureData_GetTexRef_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImTextureData_GetTexRef(self) } }

public func ImTextureData_GetTexID_cj(self: CPointer<Unit>): UInt64 { return unsafe { ImTextureData_GetTexID(self) } }

public func ImTextureData_SetTexID_cj(self: CPointer<Unit>, tex_id: UInt64): Unit { unsafe { ImTextureData_SetTexID(self, tex_id) } }

public func ImTextureData_SetStatus_cj(self: CPointer<Unit>, status: Int32): Unit { unsafe { ImTextureData_SetStatus(self, status) } }

public func ImFontConfig_ImFontConfig_cj(): CPointer<Unit> { return unsafe { ImFontConfig_ImFontConfig() } }

public func ImFontConfig_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontConfig_destroy(self) } }

public func ImFontConfig_Set_MergeMode_cj(self: CPointer<Unit>, merge_mode: Int32): Unit { unsafe { ImFontConfig_Set_MergeMode(self, merge_mode) } }

public func ImFontConfig_Get_MergeMode_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_MergeMode(self) } }

public func ImFontConfig_Set_PixelSnapH_cj(self: CPointer<Unit>, pixel_snap_h: Int32): Unit { unsafe { ImFontConfig_Set_PixelSnapH(self, pixel_snap_h) } }

public func ImFontConfig_Get_PixelSnapH_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_PixelSnapH(self) } }

public func ImFontConfig_Set_OversampleH_cj(self: CPointer<Unit>, oversample_h: Int32): Unit { unsafe { ImFontConfig_Set_OversampleH(self, oversample_h) } }

public func ImFontConfig_Get_OversampleH_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_OversampleH(self) } }

public func ImFontConfig_Set_OversampleV_cj(self: CPointer<Unit>, oversample_v: Int32): Unit { unsafe { ImFontConfig_Set_OversampleV(self, oversample_v) } }

public func ImFontConfig_Get_OversampleV_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_OversampleV(self) } }

public func ImFontConfig_Set_EllipsisChar_cj(self: CPointer<Unit>, ellipsis_char: UInt32): Unit { unsafe { ImFontConfig_Set_EllipsisChar(self, ellipsis_char) } }

public func ImFontConfig_Get_EllipsisChar_cj(self: CPointer<Unit>): UInt32 { return unsafe { ImFontConfig_Get_EllipsisChar(self) } }

public func ImFontConfig_Set_SizePixels_cj(self: CPointer<Unit>, size_pixels: Float32): Unit { unsafe { ImFontConfig_Set_SizePixels(self, size_pixels) } }

public func ImFontConfig_Get_SizePixels_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_SizePixels(self) } }

public func ImFontConfig_Set_GlyphRanges_cj(self: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): Unit { unsafe { ImFontConfig_Set_GlyphRanges(self, glyph_ranges) } }

public func ImFontConfig_Get_GlyphRanges_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontConfig_Get_GlyphRanges(self) } }

public func ImFontConfig_Set_GlyphOffset_cj(self: CPointer<Unit>, glyph_offset: ImVec2): Unit { unsafe { ImFontConfig_Set_GlyphOffset(self, glyph_offset) } }

public func ImFontConfig_Get_GlyphOffset_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImFontConfig_Get_GlyphOffset(self) } }

public func ImFontConfig_Set_GlyphMinAdvanceX_cj(self: CPointer<Unit>, glyph_min_advance_x: Float32): Unit { unsafe { ImFontConfig_Set_GlyphMinAdvanceX(self, glyph_min_advance_x) } }

public func ImFontConfig_Get_GlyphMinAdvanceX_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_GlyphMinAdvanceX(self) } }

public func ImFontConfig_Set_GlyphMaxAdvanceX_cj(self: CPointer<Unit>, glyph_max_advance_x: Float32): Unit { unsafe { ImFontConfig_Set_GlyphMaxAdvanceX(self, glyph_max_advance_x) } }

public func ImFontConfig_Get_GlyphMaxAdvanceX_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_GlyphMaxAdvanceX(self) } }

public func ImFontConfig_Set_GlyphExtraAdvanceX_cj(self: CPointer<Unit>, glyph_extra_advance_x: Float32): Unit { unsafe { ImFontConfig_Set_GlyphExtraAdvanceX(self, glyph_extra_advance_x) } }

public func ImFontConfig_Get_GlyphExtraAdvanceX_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_GlyphExtraAdvanceX(self) } }

public func ImFontConfig_Set_FontNo_cj(self: CPointer<Unit>, font_no: UInt32): Unit { unsafe { ImFontConfig_Set_FontNo(self, font_no) } }

public func ImFontConfig_Get_FontNo_cj(self: CPointer<Unit>): UInt32 { return unsafe { ImFontConfig_Get_FontNo(self) } }

public func ImFontConfig_Set_RasterizerMultiply_cj(self: CPointer<Unit>, rasterizer_multiply: Float32): Unit { unsafe { ImFontConfig_Set_RasterizerMultiply(self, rasterizer_multiply) } }

public func ImFontConfig_Get_RasterizerMultiply_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_RasterizerMultiply(self) } }

public func ImFontConfig_Set_RasterizerDensity_cj(self: CPointer<Unit>, rasterizer_density: Float32): Unit { unsafe { ImFontConfig_Set_RasterizerDensity(self, rasterizer_density) } }

public func ImFontConfig_Get_RasterizerDensity_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_RasterizerDensity(self) } }

public func ImFontConfig_Set_ExtraSizeScale_cj(self: CPointer<Unit>, extra_size_scale: Float32): Unit { unsafe { ImFontConfig_Set_ExtraSizeScale(self, extra_size_scale) } }

public func ImFontConfig_Get_ExtraSizeScale_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontConfig_Get_ExtraSizeScale(self) } }

public func ImFontConfig_Set_FontData_cj(self: CPointer<Unit>, font_data: CPointer<Unit>): Unit { unsafe { ImFontConfig_Set_FontData(self, font_data) } }

public func ImFontConfig_Get_FontData_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImFontConfig_Get_FontData(self) } }

public func ImFontConfig_Set_FontDataSize_cj(self: CPointer<Unit>, font_data_size: Int32): Unit { unsafe { ImFontConfig_Set_FontDataSize(self, font_data_size) } }

public func ImFontConfig_Get_FontDataSize_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_FontDataSize(self) } }

public func ImFontConfig_Set_FontDataOwnedByAtlas_cj(self: CPointer<Unit>, font_data_owned_by_atlas: Int32): Unit { unsafe { ImFontConfig_Set_FontDataOwnedByAtlas(self, font_data_owned_by_atlas) } }

public func ImFontConfig_Get_FontDataOwnedByAtlas_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontConfig_Get_FontDataOwnedByAtlas(self) } }

public func ImFontGlyph_ImFontGlyph_cj(): CPointer<Unit> { return unsafe { ImFontGlyph_ImFontGlyph() } }

public func ImFontGlyph_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontGlyph_destroy(self) } }

public func ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder_cj(): CPointer<Unit> { return unsafe { ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder() } }

public func ImFontGlyphRangesBuilder_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontGlyphRangesBuilder_destroy(self) } }

public func ImFontGlyphRangesBuilder_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImFontGlyphRangesBuilder_Clear(self) } }

public func ImFontGlyphRangesBuilder_GetBit_cj(self: CPointer<Unit>, n: UIntNative): Int32 { return unsafe { ImFontGlyphRangesBuilder_GetBit(self, n) } }

public func ImFontGlyphRangesBuilder_SetBit_cj(self: CPointer<Unit>, n: UIntNative): Unit { unsafe { ImFontGlyphRangesBuilder_SetBit(self, n) } }

public func ImFontGlyphRangesBuilder_AddChar_cj(self: CPointer<Unit>, c: UInt16): Unit { unsafe { ImFontGlyphRangesBuilder_AddChar(self, c) } }

public func ImFontGlyphRangesBuilder_AddText_cj(self: CPointer<Unit>, text: CString, text_end: CString): Unit { unsafe { ImFontGlyphRangesBuilder_AddText(self, text, text_end) } }

public func ImFontGlyphRangesBuilder_AddRanges_cj(self: CPointer<Unit>, ranges: CPointer<UInt16>): Unit { unsafe { ImFontGlyphRangesBuilder_AddRanges(self, ranges) } }

public func ImFontGlyphRangesBuilder_BuildRanges_cj(self: CPointer<Unit>, out_ranges: CPointer<Unit>): Unit { unsafe { ImFontGlyphRangesBuilder_BuildRanges(self, out_ranges) } }

public func ImFontAtlasRect_ImFontAtlasRect_cj(): CPointer<Unit> { return unsafe { ImFontAtlasRect_ImFontAtlasRect() } }

public func ImFontAtlasRect_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlasRect_destroy(self) } }

public func ImFontAtlas_ImFontAtlas_cj(): CPointer<Unit> { return unsafe { ImFontAtlas_ImFontAtlas() } }

public func ImFontAtlas_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_destroy(self) } }

public func ImFontAtlas_AddFont_cj(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFont(self, font_cfg) } }

public func ImFontAtlas_AddFontDefault_cj(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontDefault(self, font_cfg) } }

public func ImFontAtlas_AddFontDefaultVector_cj(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontDefaultVector(self, font_cfg) } }

public func ImFontAtlas_AddFontDefaultBitmap_cj(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontDefaultBitmap(self, font_cfg) } }

public func ImFontAtlas_AddFontFromFileTTF_cj(self: CPointer<Unit>, filename: CString, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontFromFileTTF(self, filename, size_pixels, font_cfg, glyph_ranges) } }

public func ImFontAtlas_AddFontFromMemoryTTF_cj(self: CPointer<Unit>, font_data: CPointer<Unit>, font_data_size: Int32, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontFromMemoryTTF(self, font_data, font_data_size, size_pixels, font_cfg, glyph_ranges) } }

public func ImFontAtlas_AddFontFromMemoryCompressedTTF_cj(self: CPointer<Unit>, compressed_font_data: CPointer<Unit>, compressed_font_data_size: Int32, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontFromMemoryCompressedTTF(self, compressed_font_data, compressed_font_data_size, size_pixels, font_cfg, glyph_ranges) } }

public func ImFontAtlas_AddFontFromMemoryCompressedBase85TTF_cj(self: CPointer<Unit>, compressed_font_data_base85: CString, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit> { return unsafe { ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self, compressed_font_data_base85, size_pixels, font_cfg, glyph_ranges) } }

public func ImFontAtlas_RemoveFont_cj(self: CPointer<Unit>, font: CPointer<Unit>): Unit { unsafe { ImFontAtlas_RemoveFont(self, font) } }

public func ImFontAtlas_CompactCache_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_CompactCache(self) } }

public func ImFontAtlas_SetFontLoader_cj(self: CPointer<Unit>, font_loader: CPointer<Unit>): Unit { unsafe { ImFontAtlas_SetFontLoader(self, font_loader) } }

public func ImFontAtlas_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_Clear(self) } }

public func ImFontAtlas_ClearFonts_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_ClearFonts(self) } }

public func ImFontAtlas_ClearInputData_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_ClearInputData(self) } }

public func ImFontAtlas_ClearTexData_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlas_ClearTexData(self) } }

public func ImFontAtlas_GetGlyphRangesDefault_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesDefault(self) } }

public func ImFontAtlas_AddCustomRect_cj(self: CPointer<Unit>, width: Int32, height: Int32, out_r: CPointer<Unit>): Int32 { return unsafe { ImFontAtlas_AddCustomRect(self, width, height, out_r) } }

public func ImFontAtlas_RemoveCustomRect_cj(self: CPointer<Unit>, id: Int32): Unit { unsafe { ImFontAtlas_RemoveCustomRect(self, id) } }

public func ImFontAtlas_GetCustomRect_cj(self: CPointer<Unit>, id: Int32, out_r: CPointer<Unit>): Int32 { return unsafe { ImFontAtlas_GetCustomRect(self, id, out_r) } }

public func ImFontBaked_ImFontBaked_cj(): CPointer<Unit> { return unsafe { ImFontBaked_ImFontBaked() } }

public func ImFontBaked_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontBaked_destroy(self) } }

public func ImFontBaked_ClearOutputData_cj(self: CPointer<Unit>): Unit { unsafe { ImFontBaked_ClearOutputData(self) } }

public func ImFontBaked_FindGlyph_cj(self: CPointer<Unit>, c: UInt16): CPointer<Unit> { return unsafe { ImFontBaked_FindGlyph(self, c) } }

public func ImFontBaked_FindGlyphNoFallback_cj(self: CPointer<Unit>, c: UInt16): CPointer<Unit> { return unsafe { ImFontBaked_FindGlyphNoFallback(self, c) } }

public func ImFontBaked_GetCharAdvance_cj(self: CPointer<Unit>, c: UInt16): Float32 { return unsafe { ImFontBaked_GetCharAdvance(self, c) } }

public func ImFontBaked_IsGlyphLoaded_cj(self: CPointer<Unit>, c: UInt16): Int32 { return unsafe { ImFontBaked_IsGlyphLoaded(self, c) } }

public func ImFont_ImFont_cj(): CPointer<Unit> { return unsafe { ImFont_ImFont() } }

public func ImFont_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFont_destroy(self) } }

public func ImFont_IsGlyphInFont_cj(self: CPointer<Unit>, c: UInt16): Int32 { return unsafe { ImFont_IsGlyphInFont(self, c) } }

public func ImFont_IsLoaded_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFont_IsLoaded(self) } }

public func ImFont_GetDebugName_cj(self: CPointer<Unit>): String {
    return unsafe {
        let p = ImFont_GetDebugName(self)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImFont_GetFontBaked_cj(self: CPointer<Unit>, font_size: Float32, density: Float32): CPointer<Unit> { return unsafe { ImFont_GetFontBaked(self, font_size, density) } }

public func ImFont_CalcTextSizeA_cj(self: CPointer<Unit>, size: Float32, max_width: Float32, wrap_width: Float32, text_begin: CString, text_end: CString, out_remaining: CPointer<CString>): ImVec2 { return unsafe { ImFont_CalcTextSizeA(self, size, max_width, wrap_width, text_begin, text_end, out_remaining) } }

public func ImFont_CalcWordWrapPosition_cj(self: CPointer<Unit>, size: Float32, text: CString, text_end: CString, wrap_width: Float32): String {
    return unsafe {
        let p = ImFont_CalcWordWrapPosition(self, size, text, text_end, wrap_width)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImFont_RenderChar_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>, size: Float32, pos: ImVec2, col: UInt32, c: UInt16, cpu_fine_clip: CPointer<Unit>): Unit { unsafe { ImFont_RenderChar(self, draw_list, size, pos, col, c, cpu_fine_clip) } }

public func ImFont_RenderText_cj(self: CPointer<Unit>, draw_list: CPointer<Unit>, size: Float32, pos: ImVec2, col: UInt32, clip_rect: ImVec4, text_begin: CString, text_end: CString, wrap_width: Float32, flags: Int32): Unit { unsafe { ImFont_RenderText(self, draw_list, size, pos, col, clip_rect, text_begin, text_end, wrap_width, flags) } }

public func ImFont_ClearOutputData_cj(self: CPointer<Unit>): Unit { unsafe { ImFont_ClearOutputData(self) } }

public func ImFont_AddRemapChar_cj(self: CPointer<Unit>, from_codepoint: UInt16, to_codepoint: UInt16): Unit { unsafe { ImFont_AddRemapChar(self, from_codepoint, to_codepoint) } }

public func ImFont_IsGlyphRangeUnused_cj(self: CPointer<Unit>, c_begin: UInt32, c_last: UInt32): Int32 { return unsafe { ImFont_IsGlyphRangeUnused(self, c_begin, c_last) } }

public func ImGuiIO_Get_Fonts_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiIO_Get_Fonts(self) } }

public func ImGuiIO_Set_Fonts_cj(self: CPointer<Unit>, fonts: CPointer<Unit>): Unit { unsafe { ImGuiIO_Set_Fonts(self, fonts) } }

public func ImGuiIO_Get_FontDefault_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiIO_Get_FontDefault(self) } }

public func ImGuiIO_Set_FontDefault_cj(self: CPointer<Unit>, font_default: CPointer<Unit>): Unit { unsafe { ImGuiIO_Set_FontDefault(self, font_default) } }

public func ImGuiIO_Get_DisplaySize_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImGuiIO_Get_DisplaySize(self) } }

public func ImGuiIO_Set_DisplaySize_cj(self: CPointer<Unit>, display_size: ImVec2): Unit { unsafe { ImGuiIO_Set_DisplaySize(self, display_size) } }

public func ImGuiIO_Get_DisplayFramebufferScale_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImGuiIO_Get_DisplayFramebufferScale(self) } }

public func ImGuiIO_Set_DisplayFramebufferScale_cj(self: CPointer<Unit>, display_framebuffer_scale: ImVec2): Unit { unsafe { ImGuiIO_Set_DisplayFramebufferScale(self, display_framebuffer_scale) } }

public func ImGuiIO_Get_DeltaTime_cj(self: CPointer<Unit>): Float32 { return unsafe { ImGuiIO_Get_DeltaTime(self) } }

public func ImGuiIO_Set_DeltaTime_cj(self: CPointer<Unit>, delta_time: Float32): Unit { unsafe { ImGuiIO_Set_DeltaTime(self, delta_time) } }

public func ImGuiIO_Get_ConfigFlags_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiIO_Get_ConfigFlags(self) } }

public func ImGuiIO_Set_ConfigFlags_cj(self: CPointer<Unit>, config_flags: Int32): Unit { unsafe { ImGuiIO_Set_ConfigFlags(self, config_flags) } }

public func ImGuiIO_Get_BackendFlags_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiIO_Get_BackendFlags(self) } }

public func ImGuiIO_Set_BackendFlags_cj(self: CPointer<Unit>, backend_flags: Int32): Unit { unsafe { ImGuiIO_Set_BackendFlags(self, backend_flags) } }

public func ImGuiStyle_Get_FontScaleMain_cj(self: CPointer<Unit>): Float32 { return unsafe { ImGuiStyle_Get_FontScaleMain(self) } }

public func ImGuiStyle_Set_FontScaleMain_cj(self: CPointer<Unit>, font_scale_main: Float32): Unit { unsafe { ImGuiStyle_Set_FontScaleMain(self, font_scale_main) } }

public func ImGuiStyle_Get_FontSizeBase_cj(self: CPointer<Unit>): Float32 { return unsafe { ImGuiStyle_Get_FontSizeBase(self) } }

public func ImGuiStyle_Set_FontSizeBase_cj(self: CPointer<Unit>, font_size_base: Float32): Unit { unsafe { ImGuiStyle_Set_FontSizeBase(self, font_size_base) } }

public func ImFontAtlas_GetTexDataAsRGBA32_cj(self: CPointer<Unit>, out_pixels: CPointer<CPointer<UInt8>>, out_width: CPointer<Int32>, out_height: CPointer<Int32>, out_bytes_per_pixel: CPointer<Int32>): Unit { unsafe { ImFontAtlas_GetTexDataAsRGBA32(self, out_pixels, out_width, out_height, out_bytes_per_pixel) } }

public func ImFontAtlas_IsBuilt_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontAtlas_IsBuilt(self) } }

public func ImFontAtlas_Set_TexMinWidth_cj(self: CPointer<Unit>, tex_min_width: Int32): Unit { unsafe { ImFontAtlas_Set_TexMinWidth(self, tex_min_width) } }

public func ImFontAtlas_Get_TexMinWidth_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontAtlas_Get_TexMinWidth(self) } }
public func ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self) } }
public func ImFontAtlas_GetGlyphRangesChineseFull_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesChineseFull(self) } }
public func ImFontAtlas_GetGlyphRangesJapanese_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesJapanese(self) } }
public func ImFontAtlas_GetGlyphRangesKorean_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesKorean(self) } }
public func ImFontAtlas_GetGlyphRangesGreek_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesGreek(self) } }
public func ImFontAtlas_GetGlyphRangesCyrillic_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesCyrillic(self) } }
public func ImFontAtlas_GetGlyphRangesThai_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesThai(self) } }
public func ImFontAtlas_GetGlyphRangesVietnamese_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImFontAtlas_GetGlyphRangesVietnamese(self) } }

public func ImVector_ImWchar_Get_Data_cj(self: CPointer<Unit>): CPointer<UInt16> { return unsafe { ImVector_ImWchar_Get_Data(self) } }

public func ImVector_ImWchar_Get_Size_cj(self: CPointer<Unit>): Int32 { return unsafe { ImVector_ImWchar_Get_Size(self) } }

public func ImVector_ImWchar_Get_Capacity_cj(self: CPointer<Unit>): Int32 { return unsafe { ImVector_ImWchar_Get_Capacity(self) } }

public func ImFontGlyph_Get_Codepoint_cj(self: CPointer<Unit>): UInt32 { return unsafe { ImFontGlyph_Get_Codepoint(self) } }

public func ImFontGlyph_Get_Visible_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontGlyph_Get_Visible(self) } }

public func ImFontGlyph_Get_Colored_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontGlyph_Get_Colored(self) } }

public func ImFontGlyph_Get_AdvanceX_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_AdvanceX(self) } }

public func ImFontGlyph_Get_X0_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_X0(self) } }

public func ImFontGlyph_Get_Y0_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_Y0(self) } }

public func ImFontGlyph_Get_X1_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_X1(self) } }

public func ImFontGlyph_Get_Y1_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_Y1(self) } }

public func ImFontGlyph_Get_U0_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_U0(self) } }

public func ImFontGlyph_Get_V0_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_V0(self) } }

public func ImFontGlyph_Get_U1_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_U1(self) } }

public func ImFontGlyph_Get_V1_cj(self: CPointer<Unit>): Float32 { return unsafe { ImFontGlyph_Get_V1(self) } }

public func ImFontGlyph_Get_PackId_cj(self: CPointer<Unit>): Int32 { return unsafe { ImFontGlyph_Get_PackId(self) } }

public func ImGuiViewport_ImGuiViewport_cj(): CPointer<Unit> { return unsafe { ImGuiViewport_ImGuiViewport() } }

public func ImGuiViewport_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiViewport_destroy(self) } }

public func ImGuiViewport_GetCenter_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImGuiViewport_GetCenter(self) } }

public func ImGuiViewport_GetWorkCenter_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImGuiViewport_GetWorkCenter(self) } }

public func ImGuiPlatformIO_ImGuiPlatformIO_cj(): CPointer<Unit> { return unsafe { ImGuiPlatformIO_ImGuiPlatformIO() } }

public func ImGuiPlatformIO_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPlatformIO_destroy(self) } }

public func ImGuiPlatformIO_ClearPlatformHandlers_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPlatformIO_ClearPlatformHandlers(self) } }

public func ImGuiPlatformIO_ClearRendererHandlers_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPlatformIO_ClearRendererHandlers(self) } }

public func ImGuiPlatformImeData_ImGuiPlatformImeData_cj(): CPointer<Unit> { return unsafe { ImGuiPlatformImeData_ImGuiPlatformImeData() } }

public func ImGuiPlatformImeData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPlatformImeData_destroy(self) } }

public func igImHashData_cj(data: CPointer<Unit>, data_size: UIntNative, seed: UInt32): UInt32 { return unsafe { igImHashData(data, data_size, seed) } }

public func igImHashStr_cj(data: CString, data_size: UIntNative, seed: UInt32): UInt32 { return unsafe { igImHashStr(data, data_size, seed) } }

public func igImHashSkipUncontributingPrefix_cj(label: CString): String {
    return unsafe {
        let p = igImHashSkipUncontributingPrefix(label)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImAlphaBlendColors_cj(col_a: UInt32, col_b: UInt32): UInt32 { return unsafe { igImAlphaBlendColors(col_a, col_b) } }

public func igImIsPowerOfTwo_Int_cj(v: Int32): Int32 { return unsafe { igImIsPowerOfTwo_Int(v) } }

public func igImIsPowerOfTwo_U64_cj(v: UInt64): Int32 { return unsafe { igImIsPowerOfTwo_U64(v) } }

public func igImUpperPowerOfTwo_cj(v: Int32): Int32 { return unsafe { igImUpperPowerOfTwo(v) } }

public func igImCountSetBits_cj(v: UInt32): UInt32 { return unsafe { igImCountSetBits(v) } }

public func igImStricmp_cj(str1: CString, str2: CString): Int32 { return unsafe { igImStricmp(str1, str2) } }

public func igImStrnicmp_cj(str1: CString, str2: CString, count: UIntNative): Int32 { return unsafe { igImStrnicmp(str1, str2, count) } }

public func igImStrncpy_cj(dst: CPointer<Int8>, src: CString, count: UIntNative): Unit { unsafe { igImStrncpy(dst, src, count) } }

public func igImStrdup_cj(str: CString): CPointer<Int8> { return unsafe { igImStrdup(str) } }

public func igImMemdup_cj(src: CPointer<Unit>, size: UIntNative): CPointer<Unit> { return unsafe { igImMemdup(src, size) } }

public func igImStrdupcpy_cj(dst: CPointer<Int8>, p_dst_size: CPointer<UIntNative>, str: CString): CPointer<Int8> { return unsafe { igImStrdupcpy(dst, p_dst_size, str) } }

public func igImStrchrRange_cj(str_begin: CString, str_end: CString, c: Int8): String {
    return unsafe {
        let p = igImStrchrRange(str_begin, str_end, c)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImStreolRange_cj(str: CString, str_end: CString): String {
    return unsafe {
        let p = igImStreolRange(str, str_end)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImStristr_cj(haystack: CString, haystack_end: CString, needle: CString, needle_end: CString): String {
    return unsafe {
        let p = igImStristr(haystack, haystack_end, needle, needle_end)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImStrTrimBlanks_cj(str: CPointer<Int8>): Unit { unsafe { igImStrTrimBlanks(str) } }

public func igImStrSkipBlank_cj(str: CString): String {
    return unsafe {
        let p = igImStrSkipBlank(str)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImStrlenW_cj(str: CPointer<UInt16>): Int32 { return unsafe { igImStrlenW(str) } }

public func igImStrbol_cj(buf_mid_line: CString, buf_begin: CString): String {
    return unsafe {
        let p = igImStrbol(buf_mid_line, buf_begin)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImToUpper_cj(c: Int8): Int8 { return unsafe { igImToUpper(c) } }

public func igImCharIsBlankA_cj(c: Int8): Int32 { return unsafe { igImCharIsBlankA(c) } }

public func igImCharIsBlankW_cj(c: UInt32): Int32 { return unsafe { igImCharIsBlankW(c) } }

public func igImCharIsXdigitA_cj(c: Int8): Int32 { return unsafe { igImCharIsXdigitA(c) } }

public func igImFormatString0_cj(buf: CPointer<Int8>, buf_size: UIntNative, fmt: CString): Int32 { return unsafe { igImFormatString0(buf, buf_size, fmt) } }

public func igImFormatStringToTempBuffer0_cj(out_buf: CPointer<CString>, out_buf_end: CPointer<CString>, fmt: CString): Unit { unsafe { igImFormatStringToTempBuffer0(out_buf, out_buf_end, fmt) } }

public func igImParseFormatFindStart_cj(format: CString): String {
    return unsafe {
        let p = igImParseFormatFindStart(format)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImParseFormatFindEnd_cj(format: CString): String {
    return unsafe {
        let p = igImParseFormatFindEnd(format)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImParseFormatTrimDecorations_cj(format: CString, buf: CPointer<Int8>, buf_size: UIntNative): String {
    return unsafe {
        let p = igImParseFormatTrimDecorations(format, buf, buf_size)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImParseFormatSanitizeForPrinting_cj(fmt_in: CString, fmt_out: CPointer<Int8>, fmt_out_size: UIntNative): Unit { unsafe { igImParseFormatSanitizeForPrinting(fmt_in, fmt_out, fmt_out_size) } }

public func igImParseFormatSanitizeForScanning_cj(fmt_in: CString, fmt_out: CPointer<Int8>, fmt_out_size: UIntNative): String {
    return unsafe {
        let p = igImParseFormatSanitizeForScanning(fmt_in, fmt_out, fmt_out_size)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImParseFormatPrecision_cj(format: CString, default_value: Int32): Int32 { return unsafe { igImParseFormatPrecision(format, default_value) } }

public func igImTextCharToUtf8_cj(out_buf: CPointer<Int8>, c: UInt32): Int32 { return unsafe { igImTextCharToUtf8(out_buf, c) } }

public func igImTextStrToUtf8_cj(out_buf: CPointer<Int8>, out_buf_size: Int32, in_text: CPointer<UInt16>, in_text_end: CPointer<UInt16>): Int32 { return unsafe { igImTextStrToUtf8(out_buf, out_buf_size, in_text, in_text_end) } }

public func igImTextCharFromUtf8_cj(out_char: CPointer<UInt32>, in_text: CString, in_text_end: CString): Int32 { return unsafe { igImTextCharFromUtf8(out_char, in_text, in_text_end) } }

public func igImTextStrFromUtf8_cj(out_buf: CPointer<UInt16>, out_buf_size: Int32, in_text: CString, in_text_end: CString, in_remaining: CPointer<CString>): Int32 { return unsafe { igImTextStrFromUtf8(out_buf, out_buf_size, in_text, in_text_end, in_remaining) } }

public func igImTextCountCharsFromUtf8_cj(in_text: CString, in_text_end: CString): Int32 { return unsafe { igImTextCountCharsFromUtf8(in_text, in_text_end) } }

public func igImTextCountUtf8BytesFromChar_cj(in_text: CString, in_text_end: CString): Int32 { return unsafe { igImTextCountUtf8BytesFromChar(in_text, in_text_end) } }

public func igImTextCountUtf8BytesFromStr_cj(in_text: CPointer<UInt16>, in_text_end: CPointer<UInt16>): Int32 { return unsafe { igImTextCountUtf8BytesFromStr(in_text, in_text_end) } }

public func igImTextFindPreviousUtf8Codepoint_cj(in_text_start: CString, in_p: CString): String {
    return unsafe {
        let p = igImTextFindPreviousUtf8Codepoint(in_text_start, in_p)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImTextFindValidUtf8CodepointEnd_cj(in_text_start: CString, in_text_end: CString, in_p: CString): String {
    return unsafe {
        let p = igImTextFindValidUtf8CodepointEnd(in_text_start, in_text_end, in_p)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImTextCountLines_cj(in_text: CString, in_text_end: CString): Int32 { return unsafe { igImTextCountLines(in_text, in_text_end) } }

public func igImFontCalcTextSizeEx_cj(font: CPointer<Unit>, size: Float32, max_width: Float32, wrap_width: Float32, text_begin: CString, text_end_display: CString, text_end: CString, out_remaining: CPointer<CString>, out_offset: CPointer<ImVec2>, flags: Int32): ImVec2 { return unsafe { igImFontCalcTextSizeEx(font, size, max_width, wrap_width, text_begin, text_end_display, text_end, out_remaining, out_offset, flags) } }

public func igImFontCalcWordWrapPositionEx_cj(font: CPointer<Unit>, size: Float32, text: CString, text_end: CString, wrap_width: Float32, flags: Int32): String {
    return unsafe {
        let p = igImFontCalcWordWrapPositionEx(font, size, text, text_end, wrap_width, flags)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImTextCalcWordWrapNextLineStart_cj(text: CString, text_end: CString, flags: Int32): String {
    return unsafe {
        let p = igImTextCalcWordWrapNextLineStart(text, text_end, flags)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImTextInitClassifiers_cj(): Unit { unsafe { igImTextInitClassifiers() } }

public func igImTextClassifierClear_cj(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32): Unit { unsafe { igImTextClassifierClear(bits, codepoint_min, codepoint_end, char_class) } }

public func igImTextClassifierSetCharClass_cj(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32, c: UInt32): Unit { unsafe { igImTextClassifierSetCharClass(bits, codepoint_min, codepoint_end, char_class, c) } }

public func igImTextClassifierSetCharClassFromStr_cj(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32, s: CString): Unit { unsafe { igImTextClassifierSetCharClassFromStr(bits, codepoint_min, codepoint_end, char_class, s) } }

public func igImFileOpen_cj(filename: CString, mode: CString): Int32 { return unsafe { igImFileOpen(filename, mode) } }

public func igImFileClose_cj(file: Int32): Int32 { return unsafe { igImFileClose(file) } }

public func igImFileGetSize_cj(file: Int32): UInt64 { return unsafe { igImFileGetSize(file) } }

public func igImFileRead_cj(data: CPointer<Unit>, size: UInt64, count: UInt64, file: Int32): UInt64 { return unsafe { igImFileRead(data, size, count, file) } }

public func igImFileWrite_cj(data: CPointer<Unit>, size: UInt64, count: UInt64, file: Int32): UInt64 { return unsafe { igImFileWrite(data, size, count, file) } }

public func igImFileLoadToMemory_cj(filename: CString, mode: CString, out_file_size: CPointer<UIntNative>, padding_bytes: Int32): CPointer<Unit> { return unsafe { igImFileLoadToMemory(filename, mode, out_file_size, padding_bytes) } }

public func igImPow_Float_cj(x: Float32, y: Float32): Float32 { return unsafe { igImPow_Float(x, y) } }

public func igImPow_double_cj(x: Float64, y: Float64): Float64 { return unsafe { igImPow_double(x, y) } }

public func igImLog_Float_cj(x: Float32): Float32 { return unsafe { igImLog_Float(x) } }

public func igImLog_double_cj(x: Float64): Float64 { return unsafe { igImLog_double(x) } }

public func igImAbs_Int_cj(x: Int32): Int32 { return unsafe { igImAbs_Int(x) } }

public func igImAbs_Float_cj(x: Float32): Float32 { return unsafe { igImAbs_Float(x) } }

public func igImAbs_double_cj(x: Float64): Float64 { return unsafe { igImAbs_double(x) } }

public func igImSign_Float_cj(x: Float32): Float32 { return unsafe { igImSign_Float(x) } }

public func igImSign_double_cj(x: Float64): Float64 { return unsafe { igImSign_double(x) } }

public func igImRsqrt_Float_cj(x: Float32): Float32 { return unsafe { igImRsqrt_Float(x) } }

public func igImRsqrt_double_cj(x: Float64): Float64 { return unsafe { igImRsqrt_double(x) } }

public func igImMin_cj(lhs: ImVec2, rhs: ImVec2): ImVec2 { return unsafe { igImMin(lhs, rhs) } }

public func igImMax_cj(lhs: ImVec2, rhs: ImVec2): ImVec2 { return unsafe { igImMax(lhs, rhs) } }

public func igImClamp_cj(v: ImVec2, mn: ImVec2, mx: ImVec2): ImVec2 { return unsafe { igImClamp(v, mn, mx) } }

public func igImLerp_Vec2Float_cj(a: ImVec2, b: ImVec2, t: Float32): ImVec2 { return unsafe { igImLerp_Vec2Float(a, b, t) } }

public func igImLerp_Vec2Vec2_cj(a: ImVec2, b: ImVec2, t: ImVec2): ImVec2 { return unsafe { igImLerp_Vec2Vec2(a, b, t) } }

public func igImLerp_Vec4_cj(a: ImVec4, b: ImVec4, t: Float32): ImVec4 { return unsafe { igImLerp_Vec4(a, b, t) } }

public func igImSaturate_cj(f: Float32): Float32 { return unsafe { igImSaturate(f) } }

public func igImLengthSqr_Vec2_cj(lhs: ImVec2): Float32 { return unsafe { igImLengthSqr_Vec2(lhs) } }

public func igImLengthSqr_Vec4_cj(lhs: ImVec4): Float32 { return unsafe { igImLengthSqr_Vec4(lhs) } }

public func igImInvLength_cj(lhs: ImVec2, fail_value: Float32): Float32 { return unsafe { igImInvLength(lhs, fail_value) } }

public func igImTrunc_Float_cj(f: Float32): Float32 { return unsafe { igImTrunc_Float(f) } }

public func igImTrunc_Vec2_cj(v: ImVec2): ImVec2 { return unsafe { igImTrunc_Vec2(v) } }

public func igImFloor_Float_cj(f: Float32): Float32 { return unsafe { igImFloor_Float(f) } }

public func igImFloor_Vec2_cj(v: ImVec2): ImVec2 { return unsafe { igImFloor_Vec2(v) } }

public func igImTrunc64_cj(f: Float32): Float32 { return unsafe { igImTrunc64(f) } }

public func igImRound64_cj(f: Float32): Float32 { return unsafe { igImRound64(f) } }

public func igImCeilFast_cj(f: Float32): Float32 { return unsafe { igImCeilFast(f) } }

public func igImModPositive_cj(a: Int32, b: Int32): Int32 { return unsafe { igImModPositive(a, b) } }

public func igImDot_cj(a: ImVec2, b: ImVec2): Float32 { return unsafe { igImDot(a, b) } }

public func igImRotate_cj(v: ImVec2, cos_a: Float32, sin_a: Float32): ImVec2 { return unsafe { igImRotate(v, cos_a, sin_a) } }

public func igImLinearSweep_cj(current: Float32, target: Float32, speed: Float32): Float32 { return unsafe { igImLinearSweep(current, target, speed) } }

public func igImLinearRemapClamp_cj(s0: Float32, s1: Float32, d0: Float32, d1: Float32, x: Float32): Float32 { return unsafe { igImLinearRemapClamp(s0, s1, d0, d1, x) } }

public func igImMul_cj(lhs: ImVec2, rhs: ImVec2): ImVec2 { return unsafe { igImMul(lhs, rhs) } }

public func igImIsFloatAboveGuaranteedIntegerPrecision_cj(f: Float32): Int32 { return unsafe { igImIsFloatAboveGuaranteedIntegerPrecision(f) } }

public func igImExponentialMovingAverage_cj(avg: Float32, sample: Float32, n: Int32): Float32 { return unsafe { igImExponentialMovingAverage(avg, sample, n) } }

public func igImBezierCubicCalc_cj(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, t: Float32): ImVec2 { return unsafe { igImBezierCubicCalc(p1, p2, p3, p4, t) } }

public func igImBezierCubicClosestPoint_cj(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, num_segments: Int32): ImVec2 { return unsafe { igImBezierCubicClosestPoint(p1, p2, p3, p4, p, num_segments) } }

public func igImBezierCubicClosestPointCasteljau_cj(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, tess_tol: Float32): ImVec2 { return unsafe { igImBezierCubicClosestPointCasteljau(p1, p2, p3, p4, p, tess_tol) } }

public func igImBezierQuadraticCalc_cj(p1: ImVec2, p2: ImVec2, p3: ImVec2, t: Float32): ImVec2 { return unsafe { igImBezierQuadraticCalc(p1, p2, p3, t) } }

public func igImLineClosestPoint_cj(a: ImVec2, b: ImVec2, p: ImVec2): ImVec2 { return unsafe { igImLineClosestPoint(a, b, p) } }

public func igImTriangleContainsPoint_cj(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2): Int32 { return unsafe { igImTriangleContainsPoint(a, b, c, p) } }

public func igImTriangleClosestPoint_cj(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2): ImVec2 { return unsafe { igImTriangleClosestPoint(a, b, c, p) } }

public func igImTriangleBarycentricCoords_cj(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2, out_u: CPointer<Float32>, out_v: CPointer<Float32>, out_w: CPointer<Float32>): Unit { unsafe { igImTriangleBarycentricCoords(a, b, c, p, out_u, out_v, out_w) } }

public func igImTriangleArea_cj(a: ImVec2, b: ImVec2, c: ImVec2): Float32 { return unsafe { igImTriangleArea(a, b, c) } }

public func igImTriangleIsClockwise_cj(a: ImVec2, b: ImVec2, c: ImVec2): Int32 { return unsafe { igImTriangleIsClockwise(a, b, c) } }

public func ImVec1_ImVec1_Nil_cj(): CPointer<Unit> { return unsafe { ImVec1_ImVec1_Nil() } }

public func ImVec1_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVec1_destroy(self) } }

public func ImVec1_ImVec1_Float_cj(_x: Float32): CPointer<Unit> { return unsafe { ImVec1_ImVec1_Float(_x) } }

public func ImVec2i_ImVec2i_Nil_cj(): CPointer<Unit> { return unsafe { ImVec2i_ImVec2i_Nil() } }

public func ImVec2i_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVec2i_destroy(self) } }

public func ImVec2i_ImVec2i_Int_cj(_x: Int32, _y: Int32): CPointer<Unit> { return unsafe { ImVec2i_ImVec2i_Int(_x, _y) } }

public func ImVec2ih_ImVec2ih_Nil_cj(): CPointer<Unit> { return unsafe { ImVec2ih_ImVec2ih_Nil() } }

public func ImVec2ih_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVec2ih_destroy(self) } }

public func ImVec2ih_ImVec2ih_short_cj(_x: Int16, _y: Int16): CPointer<Unit> { return unsafe { ImVec2ih_ImVec2ih_short(_x, _y) } }

public func ImVec2ih_ImVec2ih_Vec2_cj(rhs: ImVec2): CPointer<Unit> { return unsafe { ImVec2ih_ImVec2ih_Vec2(rhs) } }

public func ImRect_ImRect_Nil_cj(): CPointer<Unit> { return unsafe { ImRect_ImRect_Nil() } }

public func ImRect_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImRect_destroy(self) } }

public func ImRect_ImRect_Vec2_cj(min: ImVec2, max: ImVec2): CPointer<Unit> { return unsafe { ImRect_ImRect_Vec2(min, max) } }

public func ImRect_ImRect_Vec4_cj(v: ImVec4): CPointer<Unit> { return unsafe { ImRect_ImRect_Vec4(v) } }

public func ImRect_ImRect_Float_cj(x1: Float32, y1: Float32, x2: Float32, y2: Float32): CPointer<Unit> { return unsafe { ImRect_ImRect_Float(x1, y1, x2, y2) } }

public func ImRect_GetCenter_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetCenter(self) } }

public func ImRect_GetSize_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetSize(self) } }

public func ImRect_GetWidth_cj(self: CPointer<Unit>): Float32 { return unsafe { ImRect_GetWidth(self) } }

public func ImRect_GetHeight_cj(self: CPointer<Unit>): Float32 { return unsafe { ImRect_GetHeight(self) } }

public func ImRect_GetArea_cj(self: CPointer<Unit>): Float32 { return unsafe { ImRect_GetArea(self) } }

public func ImRect_GetTL_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetTL(self) } }

public func ImRect_GetTR_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetTR(self) } }

public func ImRect_GetBL_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetBL(self) } }

public func ImRect_GetBR_cj(self: CPointer<Unit>): ImVec2 { return unsafe { ImRect_GetBR(self) } }

public func ImRect_Contains_Vec2_cj(self: CPointer<Unit>, p: ImVec2): Int32 { return unsafe { ImRect_Contains_Vec2(self, p) } }

public func ImRect_Contains_Rect_cj(self: CPointer<Unit>, r: CPointer<Unit>): Int32 { return unsafe { ImRect_Contains_Rect(self, r) } }

public func ImRect_ContainsWithPad_cj(self: CPointer<Unit>, p: ImVec2, pad: ImVec2): Int32 { return unsafe { ImRect_ContainsWithPad(self, p, pad) } }

public func ImRect_Overlaps_cj(self: CPointer<Unit>, r: CPointer<Unit>): Int32 { return unsafe { ImRect_Overlaps(self, r) } }

public func ImRect_Add_Vec2_cj(self: CPointer<Unit>, p: ImVec2): Unit { unsafe { ImRect_Add_Vec2(self, p) } }

public func ImRect_Add_Rect_cj(self: CPointer<Unit>, r: CPointer<Unit>): Unit { unsafe { ImRect_Add_Rect(self, r) } }

public func ImRect_AddX_cj(self: CPointer<Unit>, x: Float32): Unit { unsafe { ImRect_AddX(self, x) } }

public func ImRect_AddY_cj(self: CPointer<Unit>, y: Float32): Unit { unsafe { ImRect_AddY(self, y) } }

public func ImRect_Expand_Float_cj(self: CPointer<Unit>, amount: Float32): Unit { unsafe { ImRect_Expand_Float(self, amount) } }

public func ImRect_Expand_Vec2_cj(self: CPointer<Unit>, amount: ImVec2): Unit { unsafe { ImRect_Expand_Vec2(self, amount) } }

public func ImRect_Translate_cj(self: CPointer<Unit>, d: ImVec2): Unit { unsafe { ImRect_Translate(self, d) } }

public func ImRect_TranslateX_cj(self: CPointer<Unit>, dx: Float32): Unit { unsafe { ImRect_TranslateX(self, dx) } }

public func ImRect_TranslateY_cj(self: CPointer<Unit>, dy: Float32): Unit { unsafe { ImRect_TranslateY(self, dy) } }

public func ImRect_ClipWith_cj(self: CPointer<Unit>, r: CPointer<Unit>): Unit { unsafe { ImRect_ClipWith(self, r) } }

public func ImRect_ClipWithFull_cj(self: CPointer<Unit>, r: CPointer<Unit>): Unit { unsafe { ImRect_ClipWithFull(self, r) } }

public func ImRect_IsInverted_cj(self: CPointer<Unit>): Int32 { return unsafe { ImRect_IsInverted(self) } }

public func ImRect_ToVec4_cj(self: CPointer<Unit>): ImVec4 { return unsafe { ImRect_ToVec4(self) } }

public func ImRect_AsVec4_cj(self: CPointer<Unit>): CPointer<ImVec4> { return unsafe { ImRect_AsVec4(self) } }

public func igImBitArrayGetStorageSizeInBytes_cj(bitcount: Int32): UIntNative { return unsafe { igImBitArrayGetStorageSizeInBytes(bitcount) } }

public func igImBitArrayClearAllBits_cj(arr: CPointer<UInt32>, bitcount: Int32): Unit { unsafe { igImBitArrayClearAllBits(arr, bitcount) } }

public func igImBitArrayTestBit_cj(arr: CPointer<UInt32>, n: Int32): Int32 { return unsafe { igImBitArrayTestBit(arr, n) } }

public func igImBitArrayClearBit_cj(arr: CPointer<UInt32>, n: Int32): Unit { unsafe { igImBitArrayClearBit(arr, n) } }

public func igImBitArraySetBit_cj(arr: CPointer<UInt32>, n: Int32): Unit { unsafe { igImBitArraySetBit(arr, n) } }

public func igImBitArraySetBitRange_cj(arr: CPointer<UInt32>, n: Int32, n2: Int32): Unit { unsafe { igImBitArraySetBitRange(arr, n, n2) } }

public func ImBitVector_Create_cj(self: CPointer<Unit>, sz: Int32): Unit { unsafe { ImBitVector_Create(self, sz) } }

public func ImBitVector_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImBitVector_Clear(self) } }

public func ImBitVector_TestBit_cj(self: CPointer<Unit>, n: Int32): Int32 { return unsafe { ImBitVector_TestBit(self, n) } }

public func ImBitVector_SetBit_cj(self: CPointer<Unit>, n: Int32): Unit { unsafe { ImBitVector_SetBit(self, n) } }

public func ImBitVector_ClearBit_cj(self: CPointer<Unit>, n: Int32): Unit { unsafe { ImBitVector_ClearBit(self, n) } }

public func ImGuiTextIndex_clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTextIndex_clear(self) } }

public func ImGuiTextIndex_size_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiTextIndex_size(self) } }

public func ImGuiTextIndex_get_line_begin_cj(self: CPointer<Unit>, base: CString, n: Int32): String {
    return unsafe {
        let p = ImGuiTextIndex_get_line_begin(self, base, n)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiTextIndex_get_line_end_cj(self: CPointer<Unit>, base: CString, n: Int32): String {
    return unsafe {
        let p = ImGuiTextIndex_get_line_end(self, base, n)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiTextIndex_append_cj(self: CPointer<Unit>, base: CString, old_size: Int32, new_size: Int32): Unit { unsafe { ImGuiTextIndex_append(self, base, old_size, new_size) } }

public func ImGuiPackedDate_ImGuiPackedDate_Nil_cj(): CPointer<Unit> { return unsafe { ImGuiPackedDate_ImGuiPackedDate_Nil() } }

public func ImGuiPackedDate_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPackedDate_destroy(self) } }

public func ImGuiPackedDate_ImGuiPackedDate_Int_cj(yyyymmdd: Int32): CPointer<Unit> { return unsafe { ImGuiPackedDate_ImGuiPackedDate_Int(yyyymmdd) } }

public func ImGuiPackedDate_IsValid_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiPackedDate_IsValid(self) } }

public func ImGuiPackedDate_Unpack_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiPackedDate_Unpack(self) } }

public func ImGuiPackedDate_SubtractMonths_cj(self: CPointer<Unit>, m: Int32): Unit { unsafe { ImGuiPackedDate_SubtractMonths(self, m) } }

public func igImLowerBound_cj(in_begin: CPointer<Unit>, in_end: CPointer<Unit>, key: UInt32): CPointer<Unit> { return unsafe { igImLowerBound(in_begin, in_end, key) } }

public func ImDrawListSharedData_ImDrawListSharedData_cj(): CPointer<Unit> { return unsafe { ImDrawListSharedData_ImDrawListSharedData() } }

public func ImDrawListSharedData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawListSharedData_destroy(self) } }

public func ImDrawListSharedData_SetCircleTessellationMaxError_cj(self: CPointer<Unit>, max_error: Float32): Unit { unsafe { ImDrawListSharedData_SetCircleTessellationMaxError(self, max_error) } }

public func ImDrawDataBuilder_ImDrawDataBuilder_cj(): CPointer<Unit> { return unsafe { ImDrawDataBuilder_ImDrawDataBuilder() } }

public func ImDrawDataBuilder_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImDrawDataBuilder_destroy(self) } }

public func ImGuiStyleVarInfo_GetVarPtr_cj(self: CPointer<Unit>, parent: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiStyleVarInfo_GetVarPtr(self, parent) } }

public func ImGuiStyleMod_ImGuiStyleMod_Int_cj(idx: Int32, v: Int32): CPointer<Unit> { return unsafe { ImGuiStyleMod_ImGuiStyleMod_Int(idx, v) } }

public func ImGuiStyleMod_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStyleMod_destroy(self) } }

public func ImGuiStyleMod_ImGuiStyleMod_Float_cj(idx: Int32, v: Float32): CPointer<Unit> { return unsafe { ImGuiStyleMod_ImGuiStyleMod_Float(idx, v) } }

public func ImGuiStyleMod_ImGuiStyleMod_Vec2_cj(idx: Int32, v: ImVec2): CPointer<Unit> { return unsafe { ImGuiStyleMod_ImGuiStyleMod_Vec2(idx, v) } }

public func ImGuiComboPreviewData_ImGuiComboPreviewData_cj(): CPointer<Unit> { return unsafe { ImGuiComboPreviewData_ImGuiComboPreviewData() } }

public func ImGuiComboPreviewData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiComboPreviewData_destroy(self) } }

public func ImGuiMenuColumns_ImGuiMenuColumns_cj(): CPointer<Unit> { return unsafe { ImGuiMenuColumns_ImGuiMenuColumns() } }

public func ImGuiMenuColumns_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiMenuColumns_destroy(self) } }

public func ImGuiMenuColumns_Update_cj(self: CPointer<Unit>, spacing: Float32, window_reappearing: Int32): Unit { unsafe { ImGuiMenuColumns_Update(self, spacing, window_reappearing) } }

public func ImGuiMenuColumns_DeclColumns_cj(self: CPointer<Unit>, w_icon: Float32, w_label: Float32, w_shortcut: Float32, w_mark: Float32): Float32 { return unsafe { ImGuiMenuColumns_DeclColumns(self, w_icon, w_label, w_shortcut, w_mark) } }

public func ImGuiMenuColumns_CalcNextTotalWidth_cj(self: CPointer<Unit>, update_offsets: Int32): Unit { unsafe { ImGuiMenuColumns_CalcNextTotalWidth(self, update_offsets) } }

public func ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState_cj(): CPointer<Unit> { return unsafe { ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState() } }

public func ImGuiInputTextDeactivatedState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextDeactivatedState_destroy(self) } }

public func ImGuiInputTextDeactivatedState_ClearFreeMemory_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextDeactivatedState_ClearFreeMemory(self) } }

public func ImGuiInputTextState_ImGuiInputTextState_cj(): CPointer<Unit> { return unsafe { ImGuiInputTextState_ImGuiInputTextState() } }

public func ImGuiInputTextState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_destroy(self) } }

public func ImGuiInputTextState_ClearText_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ClearText(self) } }

public func ImGuiInputTextState_ClearFreeMemory_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ClearFreeMemory(self) } }

public func ImGuiInputTextState_OnKeyPressed_cj(self: CPointer<Unit>, key: Int32): Unit { unsafe { ImGuiInputTextState_OnKeyPressed(self, key) } }

public func ImGuiInputTextState_OnCharPressed_cj(self: CPointer<Unit>, c: UInt32): Unit { unsafe { ImGuiInputTextState_OnCharPressed(self, c) } }

public func ImGuiInputTextState_GetPreferredOffsetX_cj(self: CPointer<Unit>): Float32 { return unsafe { ImGuiInputTextState_GetPreferredOffsetX(self) } }

public func ImGuiInputTextState_GetText_cj(self: CPointer<Unit>): String {
    return unsafe {
        let p = ImGuiInputTextState_GetText(self)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func ImGuiInputTextState_CursorAnimReset_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_CursorAnimReset(self) } }

public func ImGuiInputTextState_CursorClamp_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_CursorClamp(self) } }

public func ImGuiInputTextState_HasSelection_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiInputTextState_HasSelection(self) } }

public func ImGuiInputTextState_ClearSelection_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ClearSelection(self) } }

public func ImGuiInputTextState_GetCursorPos_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiInputTextState_GetCursorPos(self) } }

public func ImGuiInputTextState_GetSelectionStart_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiInputTextState_GetSelectionStart(self) } }

public func ImGuiInputTextState_GetSelectionEnd_cj(self: CPointer<Unit>): Int32 { return unsafe { ImGuiInputTextState_GetSelectionEnd(self) } }

public func ImGuiInputTextState_SetSelection_cj(self: CPointer<Unit>, start: Int32, end: Int32): Unit { unsafe { ImGuiInputTextState_SetSelection(self, start, end) } }

public func ImGuiInputTextState_SelectAll_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_SelectAll(self) } }

public func ImGuiInputTextState_ReloadUserBufAndSelectAll_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ReloadUserBufAndSelectAll(self) } }

public func ImGuiInputTextState_ReloadUserBufAndKeepSelection_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ReloadUserBufAndKeepSelection(self) } }

public func ImGuiInputTextState_ReloadUserBufAndMoveToEnd_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputTextState_ReloadUserBufAndMoveToEnd(self) } }

public func ImGuiNextWindowData_ImGuiNextWindowData_cj(): CPointer<Unit> { return unsafe { ImGuiNextWindowData_ImGuiNextWindowData() } }

public func ImGuiNextWindowData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNextWindowData_destroy(self) } }

public func ImGuiNextWindowData_ClearFlags_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNextWindowData_ClearFlags(self) } }

public func ImGuiNextItemData_ImGuiNextItemData_cj(): CPointer<Unit> { return unsafe { ImGuiNextItemData_ImGuiNextItemData() } }

public func ImGuiNextItemData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNextItemData_destroy(self) } }

public func ImGuiNextItemData_ClearFlags_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNextItemData_ClearFlags(self) } }

public func ImGuiLastItemData_ImGuiLastItemData_cj(): CPointer<Unit> { return unsafe { ImGuiLastItemData_ImGuiLastItemData() } }

public func ImGuiLastItemData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiLastItemData_destroy(self) } }

public func ImGuiErrorRecoveryState_ImGuiErrorRecoveryState_cj(): CPointer<Unit> { return unsafe { ImGuiErrorRecoveryState_ImGuiErrorRecoveryState() } }

public func ImGuiErrorRecoveryState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiErrorRecoveryState_destroy(self) } }

public func ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr_cj(ptr: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr(ptr) } }

public func ImGuiPtrOrIndex_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPtrOrIndex_destroy(self) } }

public func ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int_cj(index: Int32): CPointer<Unit> { return unsafe { ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int(index) } }

public func ImGuiPopupData_ImGuiPopupData_cj(): CPointer<Unit> { return unsafe { ImGuiPopupData_ImGuiPopupData() } }

public func ImGuiPopupData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiPopupData_destroy(self) } }

public func ImGuiInputEvent_ImGuiInputEvent_cj(): CPointer<Unit> { return unsafe { ImGuiInputEvent_ImGuiInputEvent() } }

public func ImGuiInputEvent_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiInputEvent_destroy(self) } }

public func ImGuiKeyRoutingData_ImGuiKeyRoutingData_cj(): CPointer<Unit> { return unsafe { ImGuiKeyRoutingData_ImGuiKeyRoutingData() } }

public func ImGuiKeyRoutingData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiKeyRoutingData_destroy(self) } }

public func ImGuiKeyRoutingTable_ImGuiKeyRoutingTable_cj(): CPointer<Unit> { return unsafe { ImGuiKeyRoutingTable_ImGuiKeyRoutingTable() } }

public func ImGuiKeyRoutingTable_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiKeyRoutingTable_destroy(self) } }

public func ImGuiKeyRoutingTable_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiKeyRoutingTable_Clear(self) } }

public func ImGuiKeyOwnerData_ImGuiKeyOwnerData_cj(): CPointer<Unit> { return unsafe { ImGuiKeyOwnerData_ImGuiKeyOwnerData() } }

public func ImGuiKeyOwnerData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiKeyOwnerData_destroy(self) } }

public func ImGuiListClipperRange_FromIndices_cj(min: Int32, max: Int32): CPointer<Unit> { return unsafe { ImGuiListClipperRange_FromIndices(min, max) } }

public func ImGuiListClipperRange_FromPositions_cj(y1: Float32, y2: Float32, off_min: Int32, off_max: Int32): CPointer<Unit> { return unsafe { ImGuiListClipperRange_FromPositions(y1, y2, off_min, off_max) } }

public func ImGuiListClipperData_ImGuiListClipperData_cj(): CPointer<Unit> { return unsafe { ImGuiListClipperData_ImGuiListClipperData() } }

public func ImGuiListClipperData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiListClipperData_destroy(self) } }

public func ImGuiListClipperData_Reset_cj(self: CPointer<Unit>, clipper: CPointer<Unit>): Unit { unsafe { ImGuiListClipperData_Reset(self, clipper) } }

public func ImGuiNavItemData_ImGuiNavItemData_cj(): CPointer<Unit> { return unsafe { ImGuiNavItemData_ImGuiNavItemData() } }

public func ImGuiNavItemData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNavItemData_destroy(self) } }

public func ImGuiNavItemData_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiNavItemData_Clear(self) } }

public func ImGuiTypingSelectState_ImGuiTypingSelectState_cj(): CPointer<Unit> { return unsafe { ImGuiTypingSelectState_ImGuiTypingSelectState() } }

public func ImGuiTypingSelectState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTypingSelectState_destroy(self) } }

public func ImGuiTypingSelectState_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTypingSelectState_Clear(self) } }

public func ImGuiOldColumnData_ImGuiOldColumnData_cj(): CPointer<Unit> { return unsafe { ImGuiOldColumnData_ImGuiOldColumnData() } }

public func ImGuiOldColumnData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiOldColumnData_destroy(self) } }

public func ImGuiOldColumns_ImGuiOldColumns_cj(): CPointer<Unit> { return unsafe { ImGuiOldColumns_ImGuiOldColumns() } }

public func ImGuiOldColumns_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiOldColumns_destroy(self) } }

public func ImGuiBoxSelectState_ImGuiBoxSelectState_cj(): CPointer<Unit> { return unsafe { ImGuiBoxSelectState_ImGuiBoxSelectState() } }

public func ImGuiBoxSelectState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiBoxSelectState_destroy(self) } }

public func ImGuiMultiSelectTempData_ImGuiMultiSelectTempData_cj(): CPointer<Unit> { return unsafe { ImGuiMultiSelectTempData_ImGuiMultiSelectTempData() } }

public func ImGuiMultiSelectTempData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiMultiSelectTempData_destroy(self) } }

public func ImGuiMultiSelectTempData_Clear_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiMultiSelectTempData_Clear(self) } }

public func ImGuiMultiSelectTempData_ClearIO_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiMultiSelectTempData_ClearIO(self) } }

public func ImGuiMultiSelectState_ImGuiMultiSelectState_cj(): CPointer<Unit> { return unsafe { ImGuiMultiSelectState_ImGuiMultiSelectState() } }

public func ImGuiMultiSelectState_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiMultiSelectState_destroy(self) } }

public func ImGuiViewportP_ImGuiViewportP_cj(): CPointer<Unit> { return unsafe { ImGuiViewportP_ImGuiViewportP() } }

public func ImGuiViewportP_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiViewportP_destroy(self) } }

public func ImGuiViewportP_CalcWorkRectPos_cj(self: CPointer<Unit>, inset_min: ImVec2): ImVec2 { return unsafe { ImGuiViewportP_CalcWorkRectPos(self, inset_min) } }

public func ImGuiViewportP_CalcWorkRectSize_cj(self: CPointer<Unit>, inset_min: ImVec2, inset_max: ImVec2): ImVec2 { return unsafe { ImGuiViewportP_CalcWorkRectSize(self, inset_min, inset_max) } }

public func ImGuiViewportP_UpdateWorkRect_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiViewportP_UpdateWorkRect(self) } }

public func ImGuiViewportP_GetMainRect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiViewportP_GetMainRect(self) } }

public func ImGuiViewportP_GetWorkRect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiViewportP_GetWorkRect(self) } }

public func ImGuiViewportP_GetBuildWorkRect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiViewportP_GetBuildWorkRect(self) } }

public func ImGuiWindowSettings_ImGuiWindowSettings_cj(): CPointer<Unit> { return unsafe { ImGuiWindowSettings_ImGuiWindowSettings() } }

public func ImGuiWindowSettings_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiWindowSettings_destroy(self) } }

public func ImGuiWindowSettings_GetName_cj(self: CPointer<Unit>): CPointer<Int8> { return unsafe { ImGuiWindowSettings_GetName(self) } }

public func ImGuiSettingsHandler_ImGuiSettingsHandler_cj(): CPointer<Unit> { return unsafe { ImGuiSettingsHandler_ImGuiSettingsHandler() } }

public func ImGuiSettingsHandler_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiSettingsHandler_destroy(self) } }

public func ImGuiDebugAllocInfo_ImGuiDebugAllocInfo_cj(): CPointer<Unit> { return unsafe { ImGuiDebugAllocInfo_ImGuiDebugAllocInfo() } }

public func ImGuiDebugAllocInfo_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiDebugAllocInfo_destroy(self) } }

public func ImGuiStackLevelInfo_ImGuiStackLevelInfo_cj(): CPointer<Unit> { return unsafe { ImGuiStackLevelInfo_ImGuiStackLevelInfo() } }

public func ImGuiStackLevelInfo_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiStackLevelInfo_destroy(self) } }

public func ImGuiDebugItemPathQuery_ImGuiDebugItemPathQuery_cj(): CPointer<Unit> { return unsafe { ImGuiDebugItemPathQuery_ImGuiDebugItemPathQuery() } }

public func ImGuiDebugItemPathQuery_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiDebugItemPathQuery_destroy(self) } }

public func ImGuiIDStackTool_ImGuiIDStackTool_cj(): CPointer<Unit> { return unsafe { ImGuiIDStackTool_ImGuiIDStackTool() } }

public func ImGuiIDStackTool_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiIDStackTool_destroy(self) } }

public func ImGuiContextHook_ImGuiContextHook_cj(): CPointer<Unit> { return unsafe { ImGuiContextHook_ImGuiContextHook() } }

public func ImGuiContextHook_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiContextHook_destroy(self) } }

public func ImGuiContext_ImGuiContext_cj(shared_font_atlas: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiContext_ImGuiContext(shared_font_atlas) } }

public func ImGuiContext_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiContext_destroy(self) } }

public func ImGuiWindow_ImGuiWindow_cj(context: CPointer<Unit>, name: CString): CPointer<Unit> { return unsafe { ImGuiWindow_ImGuiWindow(context, name) } }

public func ImGuiWindow_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiWindow_destroy(self) } }

public func ImGuiWindow_GetID_Str_cj(self: CPointer<Unit>, str: CString, str_end: CString): UInt32 { return unsafe { ImGuiWindow_GetID_Str(self, str, str_end) } }

public func ImGuiWindow_GetID_Ptr_cj(self: CPointer<Unit>, ptr: CPointer<Unit>): UInt32 { return unsafe { ImGuiWindow_GetID_Ptr(self, ptr) } }

public func ImGuiWindow_GetID_Int_cj(self: CPointer<Unit>, n: Int32): UInt32 { return unsafe { ImGuiWindow_GetID_Int(self, n) } }

public func ImGuiWindow_GetIDFromPos_cj(self: CPointer<Unit>, p_abs: ImVec2): UInt32 { return unsafe { ImGuiWindow_GetIDFromPos(self, p_abs) } }

public func ImGuiWindow_GetIDFromRectangle_cj(self: CPointer<Unit>, r_abs: CPointer<Unit>): UInt32 { return unsafe { ImGuiWindow_GetIDFromRectangle(self, r_abs) } }

public func ImGuiWindow_Rect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiWindow_Rect(self) } }

public func ImGuiWindow_TitleBarRect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiWindow_TitleBarRect(self) } }

public func ImGuiWindow_MenuBarRect_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiWindow_MenuBarRect(self) } }

public func ImGuiTabItem_ImGuiTabItem_cj(): CPointer<Unit> { return unsafe { ImGuiTabItem_ImGuiTabItem() } }

public func ImGuiTabItem_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTabItem_destroy(self) } }

public func ImGuiTabBar_ImGuiTabBar_cj(): CPointer<Unit> { return unsafe { ImGuiTabBar_ImGuiTabBar() } }

public func ImGuiTabBar_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTabBar_destroy(self) } }

public func ImGuiTableColumn_ImGuiTableColumn_cj(): CPointer<Unit> { return unsafe { ImGuiTableColumn_ImGuiTableColumn() } }

public func ImGuiTableColumn_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableColumn_destroy(self) } }

public func ImGuiTableInstanceData_ImGuiTableInstanceData_cj(): CPointer<Unit> { return unsafe { ImGuiTableInstanceData_ImGuiTableInstanceData() } }

public func ImGuiTableInstanceData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableInstanceData_destroy(self) } }

public func ImGuiTable_ImGuiTable_cj(): CPointer<Unit> { return unsafe { ImGuiTable_ImGuiTable() } }

public func ImGuiTable_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTable_destroy(self) } }

public func ImGuiTableTempData_ImGuiTableTempData_cj(): CPointer<Unit> { return unsafe { ImGuiTableTempData_ImGuiTableTempData() } }

public func ImGuiTableTempData_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableTempData_destroy(self) } }

public func ImGuiTableColumnSettings_ImGuiTableColumnSettings_cj(): CPointer<Unit> { return unsafe { ImGuiTableColumnSettings_ImGuiTableColumnSettings() } }

public func ImGuiTableColumnSettings_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableColumnSettings_destroy(self) } }

public func ImGuiTableSettings_ImGuiTableSettings_cj(): CPointer<Unit> { return unsafe { ImGuiTableSettings_ImGuiTableSettings() } }

public func ImGuiTableSettings_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImGuiTableSettings_destroy(self) } }

public func ImGuiTableSettings_GetColumnSettings_cj(self: CPointer<Unit>): CPointer<Unit> { return unsafe { ImGuiTableSettings_GetColumnSettings(self) } }

public func igTableOpenContextMenu_cj(column_n: Int32): Unit { unsafe { igTableOpenContextMenu(column_n) } }

public func igTableSetColumnWidth_cj(column_n: Int32, width: Float32): Unit { unsafe { igTableSetColumnWidth(column_n, width) } }

public func igTableSetColumnSortDirection_cj(column_n: Int32, sort_direction: Int32, append_to_sort_specs: Int32): Unit { unsafe { igTableSetColumnSortDirection(column_n, sort_direction, append_to_sort_specs) } }

public func igTableGetHoveredRow_cj(): Int32 { return unsafe { igTableGetHoveredRow() } }

public func igTableGetHeaderRowHeight_cj(): Float32 { return unsafe { igTableGetHeaderRowHeight() } }

public func igTableGetHeaderAngledMaxLabelWidth_cj(): Float32 { return unsafe { igTableGetHeaderAngledMaxLabelWidth() } }

public func igTablePushBackgroundChannel_cj(): Unit { unsafe { igTablePushBackgroundChannel() } }

public func igTablePopBackgroundChannel_cj(): Unit { unsafe { igTablePopBackgroundChannel() } }

public func igTablePushColumnChannel_cj(column_n: Int32): Unit { unsafe { igTablePushColumnChannel(column_n) } }

public func igTablePopColumnChannel_cj(): Unit { unsafe { igTablePopColumnChannel() } }

public func igTableAngledHeadersRowEx_cj(row_id: UInt32, angle: Float32, max_label_width: Float32, data: CPointer<Unit>, data_count: Int32): Unit { unsafe { igTableAngledHeadersRowEx(row_id, angle, max_label_width, data, data_count) } }

public func igGetCurrentTable_cj(): CPointer<Unit> { return unsafe { igGetCurrentTable() } }

public func igTableFindByID_cj(id: UInt32): CPointer<Unit> { return unsafe { igTableFindByID(id) } }

public func igBeginTableEx_cj(name: CString, id: UInt32, columns_count: Int32, flags: Int32, outer_size: ImVec2, inner_width: Float32): Int32 { return unsafe { igBeginTableEx(name, id, columns_count, flags, outer_size, inner_width) } }

public func igTableBeginInitMemory_cj(table: CPointer<Unit>, columns_count: Int32): Unit { unsafe { igTableBeginInitMemory(table, columns_count) } }

public func igTableApplyQueuedRequests_cj(table: CPointer<Unit>): Unit { unsafe { igTableApplyQueuedRequests(table) } }

public func igTableSetupDrawChannels_cj(table: CPointer<Unit>): Unit { unsafe { igTableSetupDrawChannels(table) } }

public func igTableReconcileColumns_cj(table: CPointer<Unit>): Unit { unsafe { igTableReconcileColumns(table) } }

public func igTableUpdateLayout_cj(table: CPointer<Unit>): Unit { unsafe { igTableUpdateLayout(table) } }

public func igTableUpdateBorders_cj(table: CPointer<Unit>): Unit { unsafe { igTableUpdateBorders(table) } }

public func igTableUpdateColumnsWeightFromWidth_cj(table: CPointer<Unit>): Unit { unsafe { igTableUpdateColumnsWeightFromWidth(table) } }

public func igTableApplyExternalUnclipRect_cj(table: CPointer<Unit>, rect: CPointer<Unit>): Unit { unsafe { igTableApplyExternalUnclipRect(table, rect) } }

public func igTableDrawBorders_cj(table: CPointer<Unit>): Unit { unsafe { igTableDrawBorders(table) } }

public func igTableDrawDefaultContextMenu_cj(table: CPointer<Unit>, flags_for_section_to_display: Int32): Unit { unsafe { igTableDrawDefaultContextMenu(table, flags_for_section_to_display) } }

public func igTableBeginContextMenuPopup_cj(table: CPointer<Unit>): Int32 { return unsafe { igTableBeginContextMenuPopup(table) } }

public func igTableMergeDrawChannels_cj(table: CPointer<Unit>): Unit { unsafe { igTableMergeDrawChannels(table) } }

public func igTableGetInstanceData_cj(table: CPointer<Unit>, instance_no: Int32): CPointer<Unit> { return unsafe { igTableGetInstanceData(table, instance_no) } }

public func igTableGetInstanceID_cj(table: CPointer<Unit>, instance_no: Int32): UInt32 { return unsafe { igTableGetInstanceID(table, instance_no) } }

public func igTableFixDisplayOrder_cj(table: CPointer<Unit>): Unit { unsafe { igTableFixDisplayOrder(table) } }

public func igTableSortSpecsSanitize_cj(table: CPointer<Unit>): Unit { unsafe { igTableSortSpecsSanitize(table) } }

public func igTableSortSpecsBuild_cj(table: CPointer<Unit>): Unit { unsafe { igTableSortSpecsBuild(table) } }

public func igTableInitColumnDefaults_cj(table: CPointer<Unit>, column: CPointer<Unit>, init_mask: Int32): Unit { unsafe { igTableInitColumnDefaults(table, column, init_mask) } }

public func igTableGetColumnNextSortDirection_cj(column: CPointer<Unit>): Int32 { return unsafe { igTableGetColumnNextSortDirection(column) } }

public func igTableFixColumnSortDirection_cj(table: CPointer<Unit>, column: CPointer<Unit>): Unit { unsafe { igTableFixColumnSortDirection(table, column) } }

public func igTableGetColumnWidthAuto_cj(table: CPointer<Unit>, column: CPointer<Unit>): Float32 { return unsafe { igTableGetColumnWidthAuto(table, column) } }

public func igTableBeginRow_cj(table: CPointer<Unit>): Unit { unsafe { igTableBeginRow(table) } }

public func igTableEndRow_cj(table: CPointer<Unit>): Unit { unsafe { igTableEndRow(table) } }

public func igTableBeginCell_cj(table: CPointer<Unit>, column_n: Int32): Unit { unsafe { igTableBeginCell(table, column_n) } }

public func igTableEndCell_cj(table: CPointer<Unit>): Unit { unsafe { igTableEndCell(table) } }

public func igTableGetCellBgRect_cj(table: CPointer<Unit>, column_n: Int32): CPointer<Unit> { return unsafe { igTableGetCellBgRect(table, column_n) } }

public func igTableGetColumnName_TablePtr_cj(table: CPointer<Unit>, column_n: Int32): String {
    return unsafe {
        let p = igTableGetColumnName_TablePtr(table, column_n)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igTableGetColumnResizeID_cj(table: CPointer<Unit>, column_n: Int32, instance_no: Int32): UInt32 { return unsafe { igTableGetColumnResizeID(table, column_n, instance_no) } }

public func igTableCalcMaxColumnWidth_cj(table: CPointer<Unit>, column_n: Int32): Float32 { return unsafe { igTableCalcMaxColumnWidth(table, column_n) } }

public func igTableSetColumnWidthAutoSingle_cj(table: CPointer<Unit>, column_n: Int32): Unit { unsafe { igTableSetColumnWidthAutoSingle(table, column_n) } }

public func igTableSetColumnWidthAutoAll_cj(table: CPointer<Unit>): Unit { unsafe { igTableSetColumnWidthAutoAll(table) } }

public func igTableSetColumnDisplayOrder_cj(table: CPointer<Unit>, column_n: Int32, dst_order: Int32): Unit { unsafe { igTableSetColumnDisplayOrder(table, column_n, dst_order) } }

public func igTableQueueSetColumnDisplayOrder_cj(table: CPointer<Unit>, column_n: Int32, dst_order: Int32): Unit { unsafe { igTableQueueSetColumnDisplayOrder(table, column_n, dst_order) } }

public func igTableRemove_cj(table: CPointer<Unit>): Unit { unsafe { igTableRemove(table) } }

public func igTableGcCompactTransientBuffers_TablePtr_cj(table: CPointer<Unit>): Unit { unsafe { igTableGcCompactTransientBuffers_TablePtr(table) } }

public func igTableGcCompactTransientBuffers_TableTempDataPtr_cj(table: CPointer<Unit>): Unit { unsafe { igTableGcCompactTransientBuffers_TableTempDataPtr(table) } }

public func igTableGcCompactSettings_cj(): Unit { unsafe { igTableGcCompactSettings() } }

public func igTableLoadSettings_cj(table: CPointer<Unit>): Unit { unsafe { igTableLoadSettings(table) } }

public func igTableLoadSettingsForColumns_cj(table: CPointer<Unit>): Unit { unsafe { igTableLoadSettingsForColumns(table) } }

public func igTableLoadSettingsForColumn_cj(column: CPointer<Unit>, column_settings: CPointer<Unit>, load_flags: Int32): Unit { unsafe { igTableLoadSettingsForColumn(column, column_settings, load_flags) } }

public func igTableSaveSettings_cj(table: CPointer<Unit>): Unit { unsafe { igTableSaveSettings(table) } }

public func igTableResetSettings_cj(table: CPointer<Unit>): Unit { unsafe { igTableResetSettings(table) } }

public func igTableGetBoundSettings_cj(table: CPointer<Unit>): CPointer<Unit> { return unsafe { igTableGetBoundSettings(table) } }

public func igTableSettingsAddSettingsHandler_cj(): Unit { unsafe { igTableSettingsAddSettingsHandler() } }

public func igTableSettingsCreate_cj(id: UInt32, columns_count: Int32): CPointer<Unit> { return unsafe { igTableSettingsCreate(id, columns_count) } }

public func igTableSettingsFindByID_cj(id: UInt32): CPointer<Unit> { return unsafe { igTableSettingsFindByID(id) } }

public func igSetWindowClipRectBeforeSetChannel_cj(window: CPointer<Unit>, clip_rect: CPointer<Unit>): Unit { unsafe { igSetWindowClipRectBeforeSetChannel(window, clip_rect) } }

public func igBeginColumns_cj(str_id: CString, count: Int32, flags: Int32): Unit { unsafe { igBeginColumns(str_id, count, flags) } }

public func igEndColumns_cj(): Unit { unsafe { igEndColumns() } }

public func igPushColumnClipRect_cj(column_index: Int32): Unit { unsafe { igPushColumnClipRect(column_index) } }

public func igPushColumnsBackground_cj(): Unit { unsafe { igPushColumnsBackground() } }

public func igPopColumnsBackground_cj(): Unit { unsafe { igPopColumnsBackground() } }

public func igGetColumnsID_cj(str_id: CString, count: Int32): UInt32 { return unsafe { igGetColumnsID(str_id, count) } }

public func igFindOrCreateColumns_cj(window: CPointer<Unit>, id: UInt32): CPointer<Unit> { return unsafe { igFindOrCreateColumns(window, id) } }

public func igGetColumnOffsetFromNorm_cj(columns: CPointer<Unit>, offset_norm: Float32): Float32 { return unsafe { igGetColumnOffsetFromNorm(columns, offset_norm) } }

public func igGetColumnNormFromOffset_cj(columns: CPointer<Unit>, offset: Float32): Float32 { return unsafe { igGetColumnNormFromOffset(columns, offset) } }

public func igGetIO_ContextPtr_cj(ctx: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetIO_ContextPtr(ctx) } }

public func igGetPlatformIO_ContextPtr_cj(ctx: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetPlatformIO_ContextPtr(ctx) } }

public func igGetScale_cj(): Float32 { return unsafe { igGetScale() } }

public func igGetCurrentWindowRead_cj(): CPointer<Unit> { return unsafe { igGetCurrentWindowRead() } }

public func igGetCurrentWindow_cj(): CPointer<Unit> { return unsafe { igGetCurrentWindow() } }

public func igFindWindowByID_cj(id: UInt32): CPointer<Unit> { return unsafe { igFindWindowByID(id) } }

public func igFindWindowByName_cj(name: CString): CPointer<Unit> { return unsafe { igFindWindowByName(name) } }

public func igUpdateWindowParentAndRootLinks_cj(window: CPointer<Unit>, flags: Int32, parent_window: CPointer<Unit>): Unit { unsafe { igUpdateWindowParentAndRootLinks(window, flags, parent_window) } }

public func igUpdateWindowSkipRefresh_cj(window: CPointer<Unit>): Unit { unsafe { igUpdateWindowSkipRefresh(window) } }

public func igCalcWindowNextAutoFitSize_cj(window: CPointer<Unit>): ImVec2 { return unsafe { igCalcWindowNextAutoFitSize(window) } }

public func igIsWindowChildOf_cj(window: CPointer<Unit>, potential_parent: CPointer<Unit>, popup_hierarchy: Int32): Int32 { return unsafe { igIsWindowChildOf(window, potential_parent, popup_hierarchy) } }

public func igIsWindowInBeginStack_cj(window: CPointer<Unit>): Int32 { return unsafe { igIsWindowInBeginStack(window) } }

public func igIsWindowWithinBeginStackOf_cj(window: CPointer<Unit>, potential_parent: CPointer<Unit>): Int32 { return unsafe { igIsWindowWithinBeginStackOf(window, potential_parent) } }

public func igIsWindowAbove_cj(potential_above: CPointer<Unit>, potential_below: CPointer<Unit>): Int32 { return unsafe { igIsWindowAbove(potential_above, potential_below) } }

public func igIsWindowNavFocusable_cj(window: CPointer<Unit>): Int32 { return unsafe { igIsWindowNavFocusable(window) } }

public func igSetWindowPos_WindowPtr_cj(window: CPointer<Unit>, pos: ImVec2, cond: Int32): Unit { unsafe { igSetWindowPos_WindowPtr(window, pos, cond) } }

public func igSetWindowSize_WindowPtr_cj(window: CPointer<Unit>, size: ImVec2, cond: Int32): Unit { unsafe { igSetWindowSize_WindowPtr(window, size, cond) } }

public func igSetWindowCollapsed_WindowPtr_cj(window: CPointer<Unit>, collapsed: Int32, cond: Int32): Unit { unsafe { igSetWindowCollapsed_WindowPtr(window, collapsed, cond) } }

public func igSetWindowHitTestHole_cj(window: CPointer<Unit>, pos: ImVec2, size: ImVec2): Unit { unsafe { igSetWindowHitTestHole(window, pos, size) } }

public func igSetWindowHiddenAndSkipItemsForCurrentFrame_cj(window: CPointer<Unit>): Unit { unsafe { igSetWindowHiddenAndSkipItemsForCurrentFrame(window) } }

public func igSetWindowParentWindowForFocusRoute_cj(window: CPointer<Unit>, parent_window: CPointer<Unit>): Unit { unsafe { igSetWindowParentWindowForFocusRoute(window, parent_window) } }

public func igWindowRectAbsToRel_cj(window: CPointer<Unit>, r: CPointer<Unit>): CPointer<Unit> { return unsafe { igWindowRectAbsToRel(window, r) } }

public func igWindowRectRelToAbs_cj(window: CPointer<Unit>, r: CPointer<Unit>): CPointer<Unit> { return unsafe { igWindowRectRelToAbs(window, r) } }

public func igWindowPosAbsToRel_cj(window: CPointer<Unit>, p: ImVec2): ImVec2 { return unsafe { igWindowPosAbsToRel(window, p) } }

public func igWindowPosRelToAbs_cj(window: CPointer<Unit>, p: ImVec2): ImVec2 { return unsafe { igWindowPosRelToAbs(window, p) } }

public func igFocusWindow_cj(window: CPointer<Unit>, flags: Int32): Unit { unsafe { igFocusWindow(window, flags) } }

public func igFocusTopMostWindowUnderOne_cj(under_this_window: CPointer<Unit>, ignore_window: CPointer<Unit>, filter_viewport: CPointer<Unit>, flags: Int32): Unit { unsafe { igFocusTopMostWindowUnderOne(under_this_window, ignore_window, filter_viewport, flags) } }

public func igBringWindowToFocusFront_cj(window: CPointer<Unit>): Unit { unsafe { igBringWindowToFocusFront(window) } }

public func igBringWindowToDisplayFront_cj(window: CPointer<Unit>): Unit { unsafe { igBringWindowToDisplayFront(window) } }

public func igBringWindowToDisplayBack_cj(window: CPointer<Unit>): Unit { unsafe { igBringWindowToDisplayBack(window) } }

public func igBringWindowToDisplayBehind_cj(window: CPointer<Unit>, above_window: CPointer<Unit>): Unit { unsafe { igBringWindowToDisplayBehind(window, above_window) } }

public func igFindWindowDisplayIndex_cj(window: CPointer<Unit>): Int32 { return unsafe { igFindWindowDisplayIndex(window) } }

public func igFindBottomMostVisibleWindowWithinBeginStack_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igFindBottomMostVisibleWindowWithinBeginStack(window) } }

public func igSetNextWindowRefreshPolicy_cj(flags: Int32): Unit { unsafe { igSetNextWindowRefreshPolicy(flags) } }

public func igRegisterUserTexture_cj(tex: CPointer<Unit>): Unit { unsafe { igRegisterUserTexture(tex) } }

public func igUnregisterUserTexture_cj(tex: CPointer<Unit>): Unit { unsafe { igUnregisterUserTexture(tex) } }

public func igRegisterFontAtlas_cj(atlas: CPointer<Unit>): Unit { unsafe { igRegisterFontAtlas(atlas) } }

public func igUnregisterFontAtlas_cj(atlas: CPointer<Unit>): Unit { unsafe { igUnregisterFontAtlas(atlas) } }

public func igSetCurrentFont_cj(font: CPointer<Unit>, font_size_before_scaling: Float32, font_size_after_scaling: Float32): Unit { unsafe { igSetCurrentFont(font, font_size_before_scaling, font_size_after_scaling) } }

public func igUpdateCurrentFontSize_cj(restore_font_size_after_scaling: Float32): Unit { unsafe { igUpdateCurrentFontSize(restore_font_size_after_scaling) } }

public func igSetFontRasterizerDensity_cj(rasterizer_density: Float32): Unit { unsafe { igSetFontRasterizerDensity(rasterizer_density) } }

public func igGetFontRasterizerDensity_cj(): Float32 { return unsafe { igGetFontRasterizerDensity() } }

public func igGetRoundedFontSize_cj(size: Float32): Float32 { return unsafe { igGetRoundedFontSize(size) } }

public func igGetDefaultFont_cj(): CPointer<Unit> { return unsafe { igGetDefaultFont() } }

public func igPushPasswordFont_cj(): Unit { unsafe { igPushPasswordFont() } }

public func igPopPasswordFont_cj(): Unit { unsafe { igPopPasswordFont() } }

public func igGetForegroundDrawList_WindowPtr_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetForegroundDrawList_WindowPtr(window) } }

public func igGetBackgroundDrawList_ViewportPtr_cj(viewport: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetBackgroundDrawList_ViewportPtr(viewport) } }

public func igGetForegroundDrawList_ViewportPtr_cj(viewport: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetForegroundDrawList_ViewportPtr(viewport) } }

public func igAddDrawListToDrawDataEx_cj(draw_data: CPointer<Unit>, out_list: CPointer<Unit>, draw_list: CPointer<Unit>): Unit { unsafe { igAddDrawListToDrawDataEx(draw_data, out_list, draw_list) } }

public func igInitialize_cj(): Unit { unsafe { igInitialize() } }

public func igShutdown_cj(): Unit { unsafe { igShutdown() } }

public func igSetContextName_cj(ctx: CPointer<Unit>, name: CString): Unit { unsafe { igSetContextName(ctx, name) } }

public func igAddContextHook_cj(ctx: CPointer<Unit>, hook: CPointer<Unit>): UInt32 { return unsafe { igAddContextHook(ctx, hook) } }

public func igRemoveContextHook_cj(ctx: CPointer<Unit>, hook_to_remove: UInt32): Unit { unsafe { igRemoveContextHook(ctx, hook_to_remove) } }

public func igCallContextHooks_cj(ctx: CPointer<Unit>, `type`: Int32): Unit { unsafe { igCallContextHooks(ctx, `type`) } }

public func igUpdateInputEvents_cj(trickle_fast_inputs: Int32): Unit { unsafe { igUpdateInputEvents(trickle_fast_inputs) } }

public func igUpdateHoveredWindowAndCaptureFlags_cj(mouse_pos: ImVec2): Unit { unsafe { igUpdateHoveredWindowAndCaptureFlags(mouse_pos) } }

public func igFindHoveredWindowEx_cj(pos: ImVec2, find_first_and_in_any_viewport: Int32, out_hovered_window: CPointer<Unit>, out_hovered_window_under_moving_window: CPointer<Unit>): Unit { unsafe { igFindHoveredWindowEx(pos, find_first_and_in_any_viewport, out_hovered_window, out_hovered_window_under_moving_window) } }

public func igStartMouseMovingWindow_cj(window: CPointer<Unit>): Unit { unsafe { igStartMouseMovingWindow(window) } }

public func igStopMouseMovingWindow_cj(): Unit { unsafe { igStopMouseMovingWindow() } }

public func igUpdateMouseMovingWindowNewFrame_cj(): Unit { unsafe { igUpdateMouseMovingWindowNewFrame() } }

public func igUpdateMouseMovingWindowEndFrame_cj(): Unit { unsafe { igUpdateMouseMovingWindowEndFrame() } }

public func igGetWindowViewport_cj(): CPointer<Unit> { return unsafe { igGetWindowViewport() } }

public func igScaleWindowsInViewport_cj(viewport: CPointer<Unit>, scale: Float32): Unit { unsafe { igScaleWindowsInViewport(viewport, scale) } }

public func igSetWindowViewport_cj(window: CPointer<Unit>, viewport: CPointer<Unit>): Unit { unsafe { igSetWindowViewport(window, viewport) } }

public func igMarkIniSettingsDirty_Nil_cj(): Unit { unsafe { igMarkIniSettingsDirty_Nil() } }

public func igMarkIniSettingsDirty_WindowPtr_cj(window: CPointer<Unit>): Unit { unsafe { igMarkIniSettingsDirty_WindowPtr(window) } }

public func igClearIniSettings_cj(): Unit { unsafe { igClearIniSettings() } }

public func igCleanupIniSettings_cj(args: CPointer<Unit>): Unit { unsafe { igCleanupIniSettings(args) } }

public func igAddSettingsHandler_cj(handler: CPointer<Unit>): Unit { unsafe { igAddSettingsHandler(handler) } }

public func igRemoveSettingsHandler_cj(type_name: CString): Unit { unsafe { igRemoveSettingsHandler(type_name) } }

public func igFindSettingsHandler_cj(type_name: CString): CPointer<Unit> { return unsafe { igFindSettingsHandler(type_name) } }

public func igCreateNewWindowSettings_cj(name: CString): CPointer<Unit> { return unsafe { igCreateNewWindowSettings(name) } }

public func igFindWindowSettingsByID_cj(id: UInt32): CPointer<Unit> { return unsafe { igFindWindowSettingsByID(id) } }

public func igFindWindowSettingsByWindow_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igFindWindowSettingsByWindow(window) } }

public func igClearWindowSettings_cj(name: CString): Unit { unsafe { igClearWindowSettings(name) } }

public func igLocalizeRegisterEntries_cj(entries: CPointer<Unit>, count: Int32): Unit { unsafe { igLocalizeRegisterEntries(entries, count) } }

public func igLocalizeGetMsg_cj(key: Int32): String {
    return unsafe {
        let p = igLocalizeGetMsg(key)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igSetScrollX_WindowPtr_cj(window: CPointer<Unit>, scroll_x: Float32): Unit { unsafe { igSetScrollX_WindowPtr(window, scroll_x) } }

public func igSetScrollY_WindowPtr_cj(window: CPointer<Unit>, scroll_y: Float32): Unit { unsafe { igSetScrollY_WindowPtr(window, scroll_y) } }

public func igSetScrollFromPosX_WindowPtr_cj(window: CPointer<Unit>, local_x: Float32, center_x_ratio: Float32): Unit { unsafe { igSetScrollFromPosX_WindowPtr(window, local_x, center_x_ratio) } }

public func igSetScrollFromPosY_WindowPtr_cj(window: CPointer<Unit>, local_y: Float32, center_y_ratio: Float32): Unit { unsafe { igSetScrollFromPosY_WindowPtr(window, local_y, center_y_ratio) } }

public func igScrollToItem_cj(flags: Int32): Unit { unsafe { igScrollToItem(flags) } }

public func igScrollToRect_cj(window: CPointer<Unit>, rect: CPointer<Unit>, flags: Int32): Unit { unsafe { igScrollToRect(window, rect, flags) } }

public func igScrollToRectEx_cj(window: CPointer<Unit>, rect: CPointer<Unit>, flags: Int32): ImVec2 { return unsafe { igScrollToRectEx(window, rect, flags) } }

public func igScrollToBringRectIntoView_cj(window: CPointer<Unit>, rect: CPointer<Unit>): Unit { unsafe { igScrollToBringRectIntoView(window, rect) } }

public func igGetItemStatusFlags_cj(): Int32 { return unsafe { igGetItemStatusFlags() } }

public func igGetActiveID_cj(): UInt32 { return unsafe { igGetActiveID() } }

public func igGetFocusID_cj(): UInt32 { return unsafe { igGetFocusID() } }

public func igSetActiveID_cj(id: UInt32, window: CPointer<Unit>): Unit { unsafe { igSetActiveID(id, window) } }

public func igSetFocusID_cj(id: UInt32, window: CPointer<Unit>): Unit { unsafe { igSetFocusID(id, window) } }

public func igClearActiveID_cj(): Unit { unsafe { igClearActiveID() } }

public func igGetHoveredID_cj(): UInt32 { return unsafe { igGetHoveredID() } }

public func igSetHoveredID_cj(id: UInt32): Unit { unsafe { igSetHoveredID(id) } }

public func igKeepAliveID_cj(id: UInt32): Unit { unsafe { igKeepAliveID(id) } }

public func igMarkItemEdited_cj(id: UInt32): Unit { unsafe { igMarkItemEdited(id) } }

public func igPushOverrideID_cj(id: UInt32): Unit { unsafe { igPushOverrideID(id) } }

public func igGetIDWithSeed_Str_cj(str_id_begin: CString, str_id_end: CString, seed: UInt32): UInt32 { return unsafe { igGetIDWithSeed_Str(str_id_begin, str_id_end, seed) } }

public func igGetIDWithSeed_Int_cj(n: Int32, seed: UInt32): UInt32 { return unsafe { igGetIDWithSeed_Int(n, seed) } }

public func igItemSize_Vec2_cj(size: ImVec2, text_baseline_y: Float32): Unit { unsafe { igItemSize_Vec2(size, text_baseline_y) } }

public func igItemSize_Rect_cj(bb: CPointer<Unit>, text_baseline_y: Float32): Unit { unsafe { igItemSize_Rect(bb, text_baseline_y) } }

public func igItemAdd_cj(bb: CPointer<Unit>, id: UInt32, nav_bb: CPointer<Unit>, extra_flags: Int32): Int32 { return unsafe { igItemAdd(bb, id, nav_bb, extra_flags) } }

public func igItemHoverable_cj(bb: CPointer<Unit>, id: UInt32, item_flags: Int32): Int32 { return unsafe { igItemHoverable(bb, id, item_flags) } }

public func igIsWindowContentHoverable_cj(window: CPointer<Unit>, flags: Int32): Int32 { return unsafe { igIsWindowContentHoverable(window, flags) } }

public func igIsClippedEx_cj(bb: CPointer<Unit>, id: UInt32): Int32 { return unsafe { igIsClippedEx(bb, id) } }

public func igSetLastItemData_cj(item_id: UInt32, item_flags: Int32, status_flags: Int32, item_rect: CPointer<Unit>): Unit { unsafe { igSetLastItemData(item_id, item_flags, status_flags, item_rect) } }

public func igCalcItemSize_cj(size: ImVec2, default_w: Float32, default_h: Float32): ImVec2 { return unsafe { igCalcItemSize(size, default_w, default_h) } }

public func igCalcWrapWidthForPos_cj(pos: ImVec2, wrap_pos_x: Float32): Float32 { return unsafe { igCalcWrapWidthForPos(pos, wrap_pos_x) } }

public func igPushMultiItemsWidths_cj(components: Int32, width_full: Float32): Unit { unsafe { igPushMultiItemsWidths(components, width_full) } }

public func igShrinkWidths_cj(items: CPointer<Unit>, count: Int32, width_excess: Float32, width_min: Float32): Unit { unsafe { igShrinkWidths(items, count, width_excess, width_min) } }

public func igCalcClipRectVisibleItemsY_cj(clip_rect: CPointer<Unit>, pos: ImVec2, items_height: Float32, out_visible_start: CPointer<Int32>, out_visible_end: CPointer<Int32>): Unit { unsafe { igCalcClipRectVisibleItemsY(clip_rect, pos, items_height, out_visible_start, out_visible_end) } }

public func igGetStyleVarInfo_cj(idx: Int32): CPointer<Unit> { return unsafe { igGetStyleVarInfo(idx) } }

public func igBeginDisabledOverrideReenable_cj(): Unit { unsafe { igBeginDisabledOverrideReenable() } }

public func igEndDisabledOverrideReenable_cj(): Unit { unsafe { igEndDisabledOverrideReenable() } }

public func igLogBegin_cj(flags: Int32, auto_open_depth: Int32): Unit { unsafe { igLogBegin(flags, auto_open_depth) } }

public func igLogToBuffer_cj(auto_open_depth: Int32): Unit { unsafe { igLogToBuffer(auto_open_depth) } }

public func igLogRenderedText_cj(ref_pos: CPointer<ImVec2>, text: CString, text_end: CString): Unit { unsafe { igLogRenderedText(ref_pos, text, text_end) } }

public func igLogSetNextTextDecoration_cj(prefix: CString, suffix: CString): Unit { unsafe { igLogSetNextTextDecoration(prefix, suffix) } }

public func igBeginChildEx_cj(name: CString, id: UInt32, size_arg: ImVec2, child_flags: Int32, window_flags: Int32): Int32 { return unsafe { igBeginChildEx(name, id, size_arg, child_flags, window_flags) } }

public func igFindFrontMostVisibleChildWindow_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igFindFrontMostVisibleChildWindow(window) } }

public func igBeginPopupEx_cj(id: UInt32, extra_window_flags: Int32): Int32 { return unsafe { igBeginPopupEx(id, extra_window_flags) } }

public func igBeginPopupMenuEx_cj(id: UInt32, label: CString, extra_window_flags: Int32): Int32 { return unsafe { igBeginPopupMenuEx(id, label, extra_window_flags) } }

public func igOpenPopupEx_cj(id: UInt32, popup_flags: Int32): Int32 { return unsafe { igOpenPopupEx(id, popup_flags) } }

public func igClosePopupToLevel_cj(remaining: Int32, restore_focus_to_window_under_popup: Int32): Unit { unsafe { igClosePopupToLevel(remaining, restore_focus_to_window_under_popup) } }

public func igClosePopupsOverWindow_cj(ref_window: CPointer<Unit>, restore_focus_to_window_under_popup: Int32): Unit { unsafe { igClosePopupsOverWindow(ref_window, restore_focus_to_window_under_popup) } }

public func igClosePopupsExceptModals_cj(): Unit { unsafe { igClosePopupsExceptModals() } }

public func igIsPopupOpen_ID_cj(id: UInt32, popup_flags: Int32): Int32 { return unsafe { igIsPopupOpen_ID(id, popup_flags) } }

public func igGetPopupAllowedExtentRect_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igGetPopupAllowedExtentRect(window) } }

public func igGetTopMostPopupModal_cj(): CPointer<Unit> { return unsafe { igGetTopMostPopupModal() } }

public func igGetTopMostAndVisiblePopupModal_cj(): CPointer<Unit> { return unsafe { igGetTopMostAndVisiblePopupModal() } }

public func igFindBlockingModal_cj(window: CPointer<Unit>): CPointer<Unit> { return unsafe { igFindBlockingModal(window) } }

public func igFindBestWindowPosForPopup_cj(window: CPointer<Unit>): ImVec2 { return unsafe { igFindBestWindowPosForPopup(window) } }

public func igFindBestWindowPosForPopupEx_cj(ref_pos: ImVec2, size: ImVec2, last_dir: CPointer<Int32>, r_outer: CPointer<Unit>, r_avoid: CPointer<Unit>, policy: Int32): ImVec2 { return unsafe { igFindBestWindowPosForPopupEx(ref_pos, size, last_dir, r_outer, r_avoid, policy) } }

public func igGetMouseButtonFromPopupFlags_cj(flags: Int32): Int32 { return unsafe { igGetMouseButtonFromPopupFlags(flags) } }

public func igIsPopupOpenRequestForItem_cj(flags: Int32, id: UInt32): Int32 { return unsafe { igIsPopupOpenRequestForItem(flags, id) } }

public func igIsPopupOpenRequestForWindow_cj(flags: Int32): Int32 { return unsafe { igIsPopupOpenRequestForWindow(flags) } }

public func igBeginTooltipEx_cj(tooltip_flags: Int32, extra_window_flags: Int32): Int32 { return unsafe { igBeginTooltipEx(tooltip_flags, extra_window_flags) } }

public func igBeginTooltipHidden_cj(): Int32 { return unsafe { igBeginTooltipHidden() } }

public func igBeginViewportSideBar_cj(name: CString, viewport: CPointer<Unit>, dir: Int32, size: Float32, window_flags: Int32): Int32 { return unsafe { igBeginViewportSideBar(name, viewport, dir, size, window_flags) } }

public func igBeginMenuEx_cj(label: CString, icon: CString, enabled: Int32): Int32 { return unsafe { igBeginMenuEx(label, icon, enabled) } }

public func igMenuItemEx_cj(label: CString, icon: CString, shortcut: CString, selected: Int32, enabled: Int32): Int32 { return unsafe { igMenuItemEx(label, icon, shortcut, selected, enabled) } }

public func igBeginComboPopup_cj(popup_id: UInt32, bb: CPointer<Unit>, flags: Int32): Int32 { return unsafe { igBeginComboPopup(popup_id, bb, flags) } }

public func igBeginComboPreview_cj(): Int32 { return unsafe { igBeginComboPreview() } }

public func igEndComboPreview_cj(): Unit { unsafe { igEndComboPreview() } }

public func igNavInitWindow_cj(window: CPointer<Unit>, force_reinit: Int32): Unit { unsafe { igNavInitWindow(window, force_reinit) } }

public func igNavInitRequestApplyResult_cj(): Unit { unsafe { igNavInitRequestApplyResult() } }

public func igNavMoveRequestButNoResultYet_cj(): Int32 { return unsafe { igNavMoveRequestButNoResultYet() } }

public func igNavMoveRequestSubmit_cj(move_dir: Int32, clip_dir: Int32, move_flags: Int32, scroll_flags: Int32): Unit { unsafe { igNavMoveRequestSubmit(move_dir, clip_dir, move_flags, scroll_flags) } }

public func igNavMoveRequestForward_cj(move_dir: Int32, clip_dir: Int32, move_flags: Int32, scroll_flags: Int32): Unit { unsafe { igNavMoveRequestForward(move_dir, clip_dir, move_flags, scroll_flags) } }

public func igNavMoveRequestResolveWithLastItem_cj(result: CPointer<Unit>): Unit { unsafe { igNavMoveRequestResolveWithLastItem(result) } }

public func igNavMoveRequestResolveWithPastTreeNode_cj(result: CPointer<Unit>, tree_node_data: CPointer<Unit>): Unit { unsafe { igNavMoveRequestResolveWithPastTreeNode(result, tree_node_data) } }

public func igNavMoveRequestCancel_cj(): Unit { unsafe { igNavMoveRequestCancel() } }

public func igNavMoveRequestApplyResult_cj(): Unit { unsafe { igNavMoveRequestApplyResult() } }

public func igNavMoveRequestTryWrapping_cj(window: CPointer<Unit>, move_flags: Int32): Unit { unsafe { igNavMoveRequestTryWrapping(window, move_flags) } }

public func igNavHighlightActivated_cj(id: UInt32): Unit { unsafe { igNavHighlightActivated(id) } }

public func igNavClearPreferredPosForAxis_cj(axis: Int32): Unit { unsafe { igNavClearPreferredPosForAxis(axis) } }

public func igSetNavCursorVisibleAfterMove_cj(): Unit { unsafe { igSetNavCursorVisibleAfterMove() } }

public func igNavUpdateCurrentWindowIsScrollPushableX_cj(): Unit { unsafe { igNavUpdateCurrentWindowIsScrollPushableX() } }

public func igSetNavWindow_cj(window: CPointer<Unit>): Unit { unsafe { igSetNavWindow(window) } }

public func igSetNavID_cj(id: UInt32, nav_layer: Int32, focus_scope_id: UInt32, rect_rel: CPointer<Unit>): Unit { unsafe { igSetNavID(id, nav_layer, focus_scope_id, rect_rel) } }

public func igSetNavFocusScope_cj(focus_scope_id: UInt32): Unit { unsafe { igSetNavFocusScope(focus_scope_id) } }

public func igFocusItem_cj(): Unit { unsafe { igFocusItem() } }

public func igActivateItemByID_cj(id: UInt32): Unit { unsafe { igActivateItemByID(id) } }

public func igIsNamedKey_cj(key: Int32): Int32 { return unsafe { igIsNamedKey(key) } }

public func igIsNamedKeyOrMod_cj(key: Int32): Int32 { return unsafe { igIsNamedKeyOrMod(key) } }

public func igIsLegacyKey_cj(key: Int32): Int32 { return unsafe { igIsLegacyKey(key) } }

public func igIsKeyboardKey_cj(key: Int32): Int32 { return unsafe { igIsKeyboardKey(key) } }

public func igIsGamepadKey_cj(key: Int32): Int32 { return unsafe { igIsGamepadKey(key) } }

public func igIsMouseKey_cj(key: Int32): Int32 { return unsafe { igIsMouseKey(key) } }

public func igIsAliasKey_cj(key: Int32): Int32 { return unsafe { igIsAliasKey(key) } }

public func igIsLRModKey_cj(key: Int32): Int32 { return unsafe { igIsLRModKey(key) } }

public func igFixupKeyChord_cj(key_chord: Int32): Int32 { return unsafe { igFixupKeyChord(key_chord) } }

public func igConvertSingleModFlagToKey_cj(key: Int32): Int32 { return unsafe { igConvertSingleModFlagToKey(key) } }

public func igGetKeyData_ContextPtr_cj(ctx: CPointer<Unit>, key: Int32): CPointer<Unit> { return unsafe { igGetKeyData_ContextPtr(ctx, key) } }

public func igGetKeyData_Key_cj(key: Int32): CPointer<Unit> { return unsafe { igGetKeyData_Key(key) } }

public func igGetKeyChordName_cj(key_chord: Int32): String {
    return unsafe {
        let p = igGetKeyChordName(key_chord)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igMouseButtonToKey_cj(button: Int32): Int32 { return unsafe { igMouseButtonToKey(button) } }

public func igIsMouseDragPastThreshold_cj(button: Int32, lock_threshold: Float32): Int32 { return unsafe { igIsMouseDragPastThreshold(button, lock_threshold) } }

public func igGetKeyMagnitude2d_cj(key_left: Int32, key_right: Int32, key_up: Int32, key_down: Int32): ImVec2 { return unsafe { igGetKeyMagnitude2d(key_left, key_right, key_up, key_down) } }

public func igGetNavTweakPressedAmount_cj(axis: Int32): Float32 { return unsafe { igGetNavTweakPressedAmount(axis) } }

public func igCalcTypematicRepeatAmount_cj(t0: Float32, t1: Float32, repeat_delay: Float32, repeat_rate: Float32): Int32 { return unsafe { igCalcTypematicRepeatAmount(t0, t1, repeat_delay, repeat_rate) } }

public func igGetTypematicRepeatRate_cj(flags: Int32, repeat_delay: CPointer<Float32>, repeat_rate: CPointer<Float32>): Unit { unsafe { igGetTypematicRepeatRate(flags, repeat_delay, repeat_rate) } }

public func igTeleportMousePos_cj(pos: ImVec2): Unit { unsafe { igTeleportMousePos(pos) } }

public func igSetActiveIdUsingAllKeyboardKeys_cj(): Unit { unsafe { igSetActiveIdUsingAllKeyboardKeys() } }

public func igIsActiveIdUsingNavDir_cj(dir: Int32): Int32 { return unsafe { igIsActiveIdUsingNavDir(dir) } }

public func igGetKeyOwner_cj(key: Int32): UInt32 { return unsafe { igGetKeyOwner(key) } }

public func igSetKeyOwner_cj(key: Int32, owner_id: UInt32, flags: Int32): Unit { unsafe { igSetKeyOwner(key, owner_id, flags) } }

public func igSetKeyOwnersForKeyChord_cj(key: Int32, owner_id: UInt32, flags: Int32): Unit { unsafe { igSetKeyOwnersForKeyChord(key, owner_id, flags) } }

public func igSetItemKeyOwner_InputFlags_cj(key: Int32, flags: Int32): Int32 { return unsafe { igSetItemKeyOwner_InputFlags(key, flags) } }

public func igTestKeyOwner_cj(key: Int32, owner_id: UInt32): Int32 { return unsafe { igTestKeyOwner(key, owner_id) } }

public func igGetKeyOwnerData_cj(ctx: CPointer<Unit>, key: Int32): CPointer<Unit> { return unsafe { igGetKeyOwnerData(ctx, key) } }

public func igIsKeyDown_ID_cj(key: Int32, owner_id: UInt32): Int32 { return unsafe { igIsKeyDown_ID(key, owner_id) } }

public func igIsKeyPressed_InputFlags_cj(key: Int32, flags: Int32, owner_id: UInt32): Int32 { return unsafe { igIsKeyPressed_InputFlags(key, flags, owner_id) } }

public func igIsKeyReleased_ID_cj(key: Int32, owner_id: UInt32): Int32 { return unsafe { igIsKeyReleased_ID(key, owner_id) } }

public func igIsKeyChordPressed_InputFlags_cj(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32 { return unsafe { igIsKeyChordPressed_InputFlags(key_chord, flags, owner_id) } }

public func igIsMouseDown_ID_cj(button: Int32, owner_id: UInt32): Int32 { return unsafe { igIsMouseDown_ID(button, owner_id) } }

public func igIsMouseClicked_InputFlags_cj(button: Int32, flags: Int32, owner_id: UInt32): Int32 { return unsafe { igIsMouseClicked_InputFlags(button, flags, owner_id) } }

public func igIsMouseReleased_ID_cj(button: Int32, owner_id: UInt32): Int32 { return unsafe { igIsMouseReleased_ID(button, owner_id) } }

public func igIsMouseDoubleClicked_ID_cj(button: Int32, owner_id: UInt32): Int32 { return unsafe { igIsMouseDoubleClicked_ID(button, owner_id) } }

public func igShortcut_ID_cj(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32 { return unsafe { igShortcut_ID(key_chord, flags, owner_id) } }

public func igSetShortcutRouting_cj(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32 { return unsafe { igSetShortcutRouting(key_chord, flags, owner_id) } }

public func igTestShortcutRouting_cj(key_chord: Int32, owner_id: UInt32): Int32 { return unsafe { igTestShortcutRouting(key_chord, owner_id) } }

public func igGetShortcutRoutingData_cj(key_chord: Int32): CPointer<Unit> { return unsafe { igGetShortcutRoutingData(key_chord) } }

public func igPushFocusScope_cj(id: UInt32): Unit { unsafe { igPushFocusScope(id) } }

public func igPopFocusScope_cj(): Unit { unsafe { igPopFocusScope() } }

public func igIsInNavFocusRoute_cj(focus_scope_id: UInt32): Int32 { return unsafe { igIsInNavFocusRoute(focus_scope_id) } }

public func igGetCurrentFocusScope_cj(): UInt32 { return unsafe { igGetCurrentFocusScope() } }

public func igIsDragDropActive_cj(): Int32 { return unsafe { igIsDragDropActive() } }

public func igBeginDragDropTargetCustom_cj(bb: CPointer<Unit>, id: UInt32): Int32 { return unsafe { igBeginDragDropTargetCustom(bb, id) } }

public func igBeginDragDropTargetViewport_cj(viewport: CPointer<Unit>, p_bb: CPointer<Unit>): Int32 { return unsafe { igBeginDragDropTargetViewport(viewport, p_bb) } }

public func igClearDragDrop_cj(): Unit { unsafe { igClearDragDrop() } }

public func igIsDragDropPayloadBeingAccepted_cj(): Int32 { return unsafe { igIsDragDropPayloadBeingAccepted() } }

public func igRenderDragDropTargetRectForItem_cj(bb: CPointer<Unit>): Unit { unsafe { igRenderDragDropTargetRectForItem(bb) } }

public func igRenderDragDropTargetRectEx_cj(draw_list: CPointer<Unit>, bb: CPointer<Unit>, rounding: Float32): Unit { unsafe { igRenderDragDropTargetRectEx(draw_list, bb, rounding) } }

public func igGetTypingSelectRequest_cj(flags: Int32): CPointer<Unit> { return unsafe { igGetTypingSelectRequest(flags) } }

public func igBeginBoxSelect_cj(scope_rect: CPointer<Unit>, window: CPointer<Unit>, box_select_id: UInt32, ms_flags: Int32): Int32 { return unsafe { igBeginBoxSelect(scope_rect, window, box_select_id, ms_flags) } }

public func igEndBoxSelect_cj(scope_rect: CPointer<Unit>, ms_flags: Int32): Unit { unsafe { igEndBoxSelect(scope_rect, ms_flags) } }

public func igMultiSelectItemHeader_cj(id: UInt32, p_selected: CPointer<Int32>, p_button_flags: CPointer<Int32>): Unit { unsafe { igMultiSelectItemHeader(id, p_selected, p_button_flags) } }

public func igMultiSelectItemFooter_cj(id: UInt32, p_selected: CPointer<Int32>, p_pressed: CPointer<Int32>, extra_flags: Int32): Unit { unsafe { igMultiSelectItemFooter(id, p_selected, p_pressed, extra_flags) } }

public func igMultiSelectAddSetAll_cj(ms: CPointer<Unit>, selected: Int32): Unit { unsafe { igMultiSelectAddSetAll(ms, selected) } }

public func igMultiSelectAddSetRange_cj(ms: CPointer<Unit>, selected: Int32, range_dir: Int32, first_item: Int64, last_item: Int64): Unit { unsafe { igMultiSelectAddSetRange(ms, selected, range_dir, first_item, last_item) } }

public func igGetBoxSelectState_cj(id: UInt32): CPointer<Unit> { return unsafe { igGetBoxSelectState(id) } }

public func igGetMultiSelectState_cj(id: UInt32): CPointer<Unit> { return unsafe { igGetMultiSelectState(id) } }

public func igGetCurrentTabBar_cj(): CPointer<Unit> { return unsafe { igGetCurrentTabBar() } }

public func igTabBarFindByID_cj(id: UInt32): CPointer<Unit> { return unsafe { igTabBarFindByID(id) } }

public func igTabBarRemove_cj(tab_bar: CPointer<Unit>): Unit { unsafe { igTabBarRemove(tab_bar) } }

public func igBeginTabBarEx_cj(tab_bar: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32): Int32 { return unsafe { igBeginTabBarEx(tab_bar, bb, flags) } }

public func igTabBarFindTabByID_cj(tab_bar: CPointer<Unit>, tab_id: UInt32): CPointer<Unit> { return unsafe { igTabBarFindTabByID(tab_bar, tab_id) } }

public func igTabBarFindTabByOrder_cj(tab_bar: CPointer<Unit>, order: Int32): CPointer<Unit> { return unsafe { igTabBarFindTabByOrder(tab_bar, order) } }

public func igTabBarGetCurrentTab_cj(tab_bar: CPointer<Unit>): CPointer<Unit> { return unsafe { igTabBarGetCurrentTab(tab_bar) } }

public func igTabBarGetTabOrder_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Int32 { return unsafe { igTabBarGetTabOrder(tab_bar, tab) } }

public func igTabBarGetTabName_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): String {
    return unsafe {
        let p = igTabBarGetTabName(tab_bar, tab)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igTabBarRemoveTab_cj(tab_bar: CPointer<Unit>, tab_id: UInt32): Unit { unsafe { igTabBarRemoveTab(tab_bar, tab_id) } }

public func igTabBarCloseTab_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Unit { unsafe { igTabBarCloseTab(tab_bar, tab) } }

public func igTabBarQueueFocus_TabItemPtr_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Unit { unsafe { igTabBarQueueFocus_TabItemPtr(tab_bar, tab) } }

public func igTabBarQueueFocus_Str_cj(tab_bar: CPointer<Unit>, tab_name: CString): Unit { unsafe { igTabBarQueueFocus_Str(tab_bar, tab_name) } }

public func igTabBarQueueReorder_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>, offset: Int32): Unit { unsafe { igTabBarQueueReorder(tab_bar, tab, offset) } }

public func igTabBarQueueReorderFromMousePos_cj(tab_bar: CPointer<Unit>, tab: CPointer<Unit>, mouse_pos: ImVec2): Unit { unsafe { igTabBarQueueReorderFromMousePos(tab_bar, tab, mouse_pos) } }

public func igTabBarProcessReorder_cj(tab_bar: CPointer<Unit>): Int32 { return unsafe { igTabBarProcessReorder(tab_bar) } }

public func igTabItemEx_cj(tab_bar: CPointer<Unit>, label: CString, p_open: CPointer<Int32>, flags: Int32, docked_window: CPointer<Unit>): Int32 { return unsafe { igTabItemEx(tab_bar, label, p_open, flags, docked_window) } }

public func igTabItemSpacing_cj(str_id: CString, flags: Int32, width: Float32): Unit { unsafe { igTabItemSpacing(str_id, flags, width) } }

public func igTabItemCalcSize_Str_cj(label: CString, has_close_button_or_unsaved_marker: Int32): ImVec2 { return unsafe { igTabItemCalcSize_Str(label, has_close_button_or_unsaved_marker) } }

public func igTabItemCalcSize_WindowPtr_cj(window: CPointer<Unit>): ImVec2 { return unsafe { igTabItemCalcSize_WindowPtr(window) } }

public func igTabItemBackground_cj(draw_list: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32, col: UInt32): Unit { unsafe { igTabItemBackground(draw_list, bb, flags, col) } }

public func igTabItemLabelAndCloseButton_cj(draw_list: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32, frame_padding: ImVec2, label: CString, tab_id: UInt32, close_button_id: UInt32, is_contents_visible: Int32, out_just_closed: CPointer<Int32>, out_text_clipped: CPointer<Int32>): Unit { unsafe { igTabItemLabelAndCloseButton(draw_list, bb, flags, frame_padding, label, tab_id, close_button_id, is_contents_visible, out_just_closed, out_text_clipped) } }

public func igRenderText_cj(pos: ImVec2, text: CString, text_end: CString, hide_text_after_hash: Int32): Unit { unsafe { igRenderText(pos, text, text_end, hide_text_after_hash) } }

public func igRenderTextWrapped_cj(pos: ImVec2, text: CString, text_end: CString, wrap_width: Float32): Unit { unsafe { igRenderTextWrapped(pos, text, text_end, wrap_width) } }

public func igRenderTextClipped_cj(pos_min: ImVec2, pos_max: ImVec2, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>, align: ImVec2, clip_rect: CPointer<Unit>): Unit { unsafe { igRenderTextClipped(pos_min, pos_max, text, text_end, text_size_if_known, align, clip_rect) } }

public func igRenderTextClippedEx_cj(draw_list: CPointer<Unit>, pos_min: ImVec2, pos_max: ImVec2, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>, align: ImVec2, clip_rect: CPointer<Unit>): Unit { unsafe { igRenderTextClippedEx(draw_list, pos_min, pos_max, text, text_end, text_size_if_known, align, clip_rect) } }

public func igRenderTextEllipsis_cj(draw_list: CPointer<Unit>, pos_min: ImVec2, pos_max: ImVec2, ellipsis_max_x: Float32, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>): Unit { unsafe { igRenderTextEllipsis(draw_list, pos_min, pos_max, ellipsis_max_x, text, text_end, text_size_if_known) } }

public func igRenderFrame_cj(p_min: ImVec2, p_max: ImVec2, fill_col: UInt32, borders: Int32, rounding: Float32): Unit { unsafe { igRenderFrame(p_min, p_max, fill_col, borders, rounding) } }

public func igRenderFrameBorder_cj(p_min: ImVec2, p_max: ImVec2, rounding: Float32): Unit { unsafe { igRenderFrameBorder(p_min, p_max, rounding) } }

public func igRenderColorComponentMarker_cj(bb: CPointer<Unit>, col: UInt32, rounding: Float32): Unit { unsafe { igRenderColorComponentMarker(bb, col, rounding) } }

public func igRenderColorRectWithAlphaCheckerboard_cj(draw_list: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, fill_col: UInt32, grid_step: Float32, grid_off: ImVec2, rounding: Float32, flags: Int32): Unit { unsafe { igRenderColorRectWithAlphaCheckerboard(draw_list, p_min, p_max, fill_col, grid_step, grid_off, rounding, flags) } }

public func igRenderNavCursor_cj(bb: CPointer<Unit>, id: UInt32, flags: Int32, rounding: Float32): Unit { unsafe { igRenderNavCursor(bb, id, flags, rounding) } }

public func igFindRenderedTextEnd_cj(text: CString, text_end: CString): String {
    return unsafe {
        let p = igFindRenderedTextEnd(text, text_end)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igRenderMouseCursor_cj(pos: ImVec2, scale: Float32, mouse_cursor: Int32, col_fill: UInt32, col_border: UInt32, col_shadow: UInt32): Unit { unsafe { igRenderMouseCursor(pos, scale, mouse_cursor, col_fill, col_border, col_shadow) } }

public func igRenderArrow_cj(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32, dir: Int32, scale: Float32): Unit { unsafe { igRenderArrow(draw_list, pos, col, dir, scale) } }

public func igRenderBullet_cj(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32): Unit { unsafe { igRenderBullet(draw_list, pos, col) } }

public func igRenderCheckMark_cj(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32, sz: Float32): Unit { unsafe { igRenderCheckMark(draw_list, pos, col, sz) } }

public func igRenderArrowPointingAt_cj(draw_list: CPointer<Unit>, pos: ImVec2, half_sz: ImVec2, direction: Int32, col: UInt32): Unit { unsafe { igRenderArrowPointingAt(draw_list, pos, half_sz, direction, col) } }

public func igRenderRectFilledInRangeH_cj(draw_list: CPointer<Unit>, rect: CPointer<Unit>, col: UInt32, fill_x0: Float32, fill_x1: Float32, rounding: Float32): Unit { unsafe { igRenderRectFilledInRangeH(draw_list, rect, col, fill_x0, fill_x1, rounding) } }

public func igRenderRectFilledWithHole_cj(draw_list: CPointer<Unit>, outer: CPointer<Unit>, inner: CPointer<Unit>, col: UInt32, rounding: Float32): Unit { unsafe { igRenderRectFilledWithHole(draw_list, outer, inner, col, rounding) } }

public func igCalcRoundingFlagsForRectInRect_cj(r_in: CPointer<Unit>, r_outer: CPointer<Unit>, threshold: Float32): Int32 { return unsafe { igCalcRoundingFlagsForRectInRect(r_in, r_outer, threshold) } }

public func igTextEx_cj(text: CString, text_end: CString, flags: Int32): Unit { unsafe { igTextEx(text, text_end, flags) } }

public func igTextAligned0_cj(align_x: Float32, size_x: Float32, fmt: CString): Unit { unsafe { igTextAligned0(align_x, size_x, fmt) } }

public func igButtonEx_cj(label: CString, size_arg: ImVec2, flags: Int32): Int32 { return unsafe { igButtonEx(label, size_arg, flags) } }

public func igArrowButtonEx_cj(str_id: CString, dir: Int32, size_arg: ImVec2, flags: Int32): Int32 { return unsafe { igArrowButtonEx(str_id, dir, size_arg, flags) } }

public func igImageButtonEx_cj(id: UInt32, tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4, flags: Int32): Int32 { return unsafe { igImageButtonEx(id, tex_ref, image_size, uv0, uv1, bg_col, tint_col, flags) } }

public func igSeparatorEx_cj(flags: Int32, thickness: Float32): Unit { unsafe { igSeparatorEx(flags, thickness) } }

public func igSeparatorTextEx_cj(id: UInt32, label: CString, label_end: CString, extra_width: Float32): Unit { unsafe { igSeparatorTextEx(id, label, label_end, extra_width) } }

public func igCheckboxFlags_S64Ptr_cj(label: CString, flags: CPointer<Int64>, flags_value: Int64): Int32 { return unsafe { igCheckboxFlags_S64Ptr(label, flags, flags_value) } }

public func igCheckboxFlags_U64Ptr_cj(label: CString, flags: CPointer<UInt64>, flags_value: UInt64): Int32 { return unsafe { igCheckboxFlags_U64Ptr(label, flags, flags_value) } }

public func igCloseButton_cj(id: UInt32, pos: ImVec2): Int32 { return unsafe { igCloseButton(id, pos) } }

public func igCollapseButton_cj(id: UInt32, pos: ImVec2): Int32 { return unsafe { igCollapseButton(id, pos) } }

public func igScrollbar_cj(axis: Int32): Unit { unsafe { igScrollbar(axis) } }

public func igScrollbarEx_cj(bb: CPointer<Unit>, id: UInt32, axis: Int32, p_scroll_v: CPointer<Int64>, avail_v: Int64, contents_v: Int64, draw_rounding_flags: Int32): Int32 { return unsafe { igScrollbarEx(bb, id, axis, p_scroll_v, avail_v, contents_v, draw_rounding_flags) } }

public func igGetWindowScrollbarRect_cj(window: CPointer<Unit>, axis: Int32): CPointer<Unit> { return unsafe { igGetWindowScrollbarRect(window, axis) } }

public func igGetWindowScrollbarID_cj(window: CPointer<Unit>, axis: Int32): UInt32 { return unsafe { igGetWindowScrollbarID(window, axis) } }

public func igGetWindowResizeCornerID_cj(window: CPointer<Unit>, n: Int32): UInt32 { return unsafe { igGetWindowResizeCornerID(window, n) } }

public func igGetWindowResizeBorderID_cj(window: CPointer<Unit>, dir: Int32): UInt32 { return unsafe { igGetWindowResizeBorderID(window, dir) } }

public func igExtendHitBoxWhenNearViewportEdge_cj(window: CPointer<Unit>, bb: CPointer<Unit>, threshold: Float32, axis: Int32): Unit { unsafe { igExtendHitBoxWhenNearViewportEdge(window, bb, threshold, axis) } }

public func igButtonBehavior_cj(bb: CPointer<Unit>, id: UInt32, out_hovered: CPointer<Int32>, out_held: CPointer<Int32>, flags: Int32): Int32 { return unsafe { igButtonBehavior(bb, id, out_hovered, out_held, flags) } }

public func igDragBehavior_cj(id: UInt32, data_type: Int32, p_v: CPointer<Unit>, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32 { return unsafe { igDragBehavior(id, data_type, p_v, v_speed, p_min, p_max, format, flags) } }

public func igSliderBehavior_cj(bb: CPointer<Unit>, id: UInt32, data_type: Int32, p_v: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32, out_grab_bb: CPointer<Unit>): Int32 { return unsafe { igSliderBehavior(bb, id, data_type, p_v, p_min, p_max, format, flags, out_grab_bb) } }

public func igSplitterBehavior_cj(bb: CPointer<Unit>, id: UInt32, axis: Int32, size1: CPointer<Float32>, size2: CPointer<Float32>, min_size1: Float32, min_size2: Float32, hover_extend: Float32, hover_visibility_delay: Float32, bg_col: UInt32): Int32 { return unsafe { igSplitterBehavior(bb, id, axis, size1, size2, min_size1, min_size2, hover_extend, hover_visibility_delay, bg_col) } }

public func igTreeNodeBehavior_cj(id: UInt32, flags: Int32, label: CString, label_end: CString): Int32 { return unsafe { igTreeNodeBehavior(id, flags, label, label_end) } }

public func igTreeNodeDrawLineToChildNode_cj(target_pos: ImVec2): Unit { unsafe { igTreeNodeDrawLineToChildNode(target_pos) } }

public func igTreeNodeDrawLineToTreePop_cj(data: CPointer<Unit>): Unit { unsafe { igTreeNodeDrawLineToTreePop(data) } }

public func igTreePushOverrideID_cj(id: UInt32): Unit { unsafe { igTreePushOverrideID(id) } }

public func igTreeNodeSetOpen_cj(storage_id: UInt32, open: Int32): Unit { unsafe { igTreeNodeSetOpen(storage_id, open) } }

public func igTreeNodeUpdateNextOpen_cj(storage_id: UInt32, flags: Int32): Int32 { return unsafe { igTreeNodeUpdateNextOpen(storage_id, flags) } }

public func igDataTypeGetInfo_cj(data_type: Int32): CPointer<Unit> { return unsafe { igDataTypeGetInfo(data_type) } }

public func igDataTypeFormatString_cj(buf: CPointer<Int8>, buf_size: Int32, data_type: Int32, p_data: CPointer<Unit>, format: CString): Int32 { return unsafe { igDataTypeFormatString(buf, buf_size, data_type, p_data, format) } }

public func igDataTypeApplyOp_cj(data_type: Int32, op: Int32, output: CPointer<Unit>, arg_1: CPointer<Unit>, arg_2: CPointer<Unit>): Unit { unsafe { igDataTypeApplyOp(data_type, op, output, arg_1, arg_2) } }

public func igDataTypeApplyFromText_cj(buf: CString, data_type: Int32, p_data: CPointer<Unit>, format: CString, p_data_when_empty: CPointer<Unit>): Int32 { return unsafe { igDataTypeApplyFromText(buf, data_type, p_data, format, p_data_when_empty) } }

public func igDataTypeCompare_cj(data_type: Int32, arg_1: CPointer<Unit>, arg_2: CPointer<Unit>): Int32 { return unsafe { igDataTypeCompare(data_type, arg_1, arg_2) } }

public func igDataTypeClamp_cj(data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>): Int32 { return unsafe { igDataTypeClamp(data_type, p_data, p_min, p_max) } }

public func igDataTypeIsZero_cj(data_type: Int32, p_data: CPointer<Unit>): Int32 { return unsafe { igDataTypeIsZero(data_type, p_data) } }

public func igInputTextEx_cj(label: CString, hint: CString, buf: CPointer<Int8>, buf_size: Int32, size_arg: ImVec2, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 { return unsafe { igInputTextEx(label, hint, buf, buf_size, size_arg, flags, callback, user_data) } }

public func igInputTextDeactivateHook_cj(id: UInt32): Unit { unsafe { igInputTextDeactivateHook(id) } }

public func igTempInputText_cj(bb: CPointer<Unit>, id: UInt32, label: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32 { return unsafe { igTempInputText(bb, id, label, buf, buf_size, flags, callback, user_data) } }

public func igTempInputScalar_cj(bb: CPointer<Unit>, id: UInt32, label: CString, data_type: Int32, p_data: CPointer<Unit>, format: CString, p_clamp_min: CPointer<Unit>, p_clamp_max: CPointer<Unit>): Int32 { return unsafe { igTempInputScalar(bb, id, label, data_type, p_data, format, p_clamp_min, p_clamp_max) } }

public func igTempInputIsActive_cj(id: UInt32): Int32 { return unsafe { igTempInputIsActive(id) } }

public func igGetInputTextState_cj(id: UInt32): CPointer<Unit> { return unsafe { igGetInputTextState(id) } }

public func igSetNextItemRefVal_cj(data_type: Int32, p_data: CPointer<Unit>): Unit { unsafe { igSetNextItemRefVal(data_type, p_data) } }

public func igIsItemActiveAsInputText_cj(): Int32 { return unsafe { igIsItemActiveAsInputText() } }

public func igColorTooltip_cj(text: CString, col: CPointer<Float32>, flags: Int32): Unit { unsafe { igColorTooltip(text, col, flags) } }

public func igColorEditOptionsPopup_cj(col: CPointer<Float32>, flags: Int32): Unit { unsafe { igColorEditOptionsPopup(col, flags) } }

public func igColorPickerOptionsPopup_cj(ref_col: CPointer<Float32>, flags: Int32): Unit { unsafe { igColorPickerOptionsPopup(ref_col, flags) } }

public func igSetNextItemColorMarker_cj(col: UInt32): Unit { unsafe { igSetNextItemColorMarker(col) } }

public func igShadeVertsLinearColorGradientKeepAlpha_cj(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, gradient_p0: ImVec2, gradient_p1: ImVec2, col0: UInt32, col1: UInt32): Unit { unsafe { igShadeVertsLinearColorGradientKeepAlpha(draw_list, vert_start_idx, vert_end_idx, gradient_p0, gradient_p1, col0, col1) } }

public func igShadeVertsLinearUV_cj(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, clamp: Int32): Unit { unsafe { igShadeVertsLinearUV(draw_list, vert_start_idx, vert_end_idx, a, b, uv_a, uv_b, clamp) } }

public func igShadeVertsTransformPos_cj(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, pivot_in: ImVec2, cos_a: Float32, sin_a: Float32, pivot_out: ImVec2): Unit { unsafe { igShadeVertsTransformPos(draw_list, vert_start_idx, vert_end_idx, pivot_in, cos_a, sin_a, pivot_out) } }

public func igGcCompactTransientMiscBuffers_cj(): Unit { unsafe { igGcCompactTransientMiscBuffers() } }

public func igGcCompactTransientWindowBuffers_cj(window: CPointer<Unit>): Unit { unsafe { igGcCompactTransientWindowBuffers(window) } }

public func igGcAwakeTransientWindowBuffers_cj(window: CPointer<Unit>): Unit { unsafe { igGcAwakeTransientWindowBuffers(window) } }

public func igErrorLog_cj(msg: CString): Int32 { return unsafe { igErrorLog(msg) } }

public func igErrorRecoveryStoreState_cj(state_out: CPointer<Unit>): Unit { unsafe { igErrorRecoveryStoreState(state_out) } }

public func igErrorRecoveryTryToRecoverState_cj(state_in: CPointer<Unit>): Unit { unsafe { igErrorRecoveryTryToRecoverState(state_in) } }

public func igErrorRecoveryTryToRecoverWindowState_cj(state_in: CPointer<Unit>): Unit { unsafe { igErrorRecoveryTryToRecoverWindowState(state_in) } }

public func igErrorCheckUsingSetCursorPosToExtendParentBoundaries_cj(): Unit { unsafe { igErrorCheckUsingSetCursorPosToExtendParentBoundaries() } }

public func igErrorCheckEndFrameFinalizeErrorTooltip_cj(): Unit { unsafe { igErrorCheckEndFrameFinalizeErrorTooltip() } }

public func igBeginErrorTooltip_cj(): Int32 { return unsafe { igBeginErrorTooltip() } }

public func igEndErrorTooltip_cj(): Unit { unsafe { igEndErrorTooltip() } }

public func igDemoMarker_cj(file: CString, line: Int32, section: CString): Unit { unsafe { igDemoMarker(file, line, section) } }

public func igDebugAllocHook_cj(info: CPointer<Unit>, frame_count: Int32, ptr: CPointer<Unit>, size: UIntNative): Unit { unsafe { igDebugAllocHook(info, frame_count, ptr, size) } }

public func igDebugDrawCursorPos_cj(col: UInt32): Unit { unsafe { igDebugDrawCursorPos(col) } }

public func igDebugDrawLineExtents_cj(col: UInt32): Unit { unsafe { igDebugDrawLineExtents(col) } }

public func igDebugDrawItemRect_cj(col: UInt32): Unit { unsafe { igDebugDrawItemRect(col) } }

public func igDebugTextUnformattedWithLocateItem_cj(line_begin: CString, line_end: CString): Unit { unsafe { igDebugTextUnformattedWithLocateItem(line_begin, line_end) } }

public func igDebugLocateItem_cj(target_id: UInt32): Unit { unsafe { igDebugLocateItem(target_id) } }

public func igDebugLocateItemOnHover_cj(target_id: UInt32): Unit { unsafe { igDebugLocateItemOnHover(target_id) } }

public func igDebugLocateItemResolveWithLastItem_cj(): Unit { unsafe { igDebugLocateItemResolveWithLastItem() } }

public func igDebugBreakClearData_cj(): Unit { unsafe { igDebugBreakClearData() } }

public func igDebugBreakButton_cj(label: CString, description_of_location: CString): Int32 { return unsafe { igDebugBreakButton(label, description_of_location) } }

public func igDebugBreakButtonTooltip_cj(keyboard_only: Int32, description_of_location: CString): Unit { unsafe { igDebugBreakButtonTooltip(keyboard_only, description_of_location) } }

public func igShowFontAtlas_cj(atlas: CPointer<Unit>): Unit { unsafe { igShowFontAtlas(atlas) } }

public func igDebugTextureIDToU64_cj(tex_id: UInt64): UInt64 { return unsafe { igDebugTextureIDToU64(tex_id) } }

public func igDebugHookIdInfo_cj(id: UInt32, data_type: Int32, data_id: CPointer<Unit>, data_id_end: CPointer<Unit>): Unit { unsafe { igDebugHookIdInfo(id, data_type, data_id, data_id_end) } }

public func igDebugNodeColumns_cj(columns: CPointer<Unit>): Unit { unsafe { igDebugNodeColumns(columns) } }

public func igDebugNodeDrawList_cj(window: CPointer<Unit>, viewport: CPointer<Unit>, draw_list: CPointer<Unit>, label: CString): Unit { unsafe { igDebugNodeDrawList(window, viewport, draw_list, label) } }

public func igDebugNodeDrawCmdShowMeshAndBoundingBox_cj(out_draw_list: CPointer<Unit>, draw_list: CPointer<Unit>, draw_cmd: CPointer<Unit>, show_mesh: Int32, show_aabb: Int32): Unit { unsafe { igDebugNodeDrawCmdShowMeshAndBoundingBox(out_draw_list, draw_list, draw_cmd, show_mesh, show_aabb) } }

public func igDebugNodeFont_cj(font: CPointer<Unit>): Unit { unsafe { igDebugNodeFont(font) } }

public func igDebugNodeFontGlyphsForSrcMask_cj(font: CPointer<Unit>, baked: CPointer<Unit>, src_mask: Int32): Unit { unsafe { igDebugNodeFontGlyphsForSrcMask(font, baked, src_mask) } }

public func igDebugNodeFontGlyph_cj(font: CPointer<Unit>, glyph: CPointer<Unit>): Unit { unsafe { igDebugNodeFontGlyph(font, glyph) } }

public func igDebugNodeTexture_cj(tex: CPointer<Unit>, int_id: Int32, highlight_rect: CPointer<Unit>): Unit { unsafe { igDebugNodeTexture(tex, int_id, highlight_rect) } }

public func igDebugNodeStorage_cj(storage: CPointer<Unit>, label: CString): Unit { unsafe { igDebugNodeStorage(storage, label) } }

public func igDebugNodeTabBar_cj(tab_bar: CPointer<Unit>, label: CString): Unit { unsafe { igDebugNodeTabBar(tab_bar, label) } }

public func igDebugNodeTable_cj(table: CPointer<Unit>): Unit { unsafe { igDebugNodeTable(table) } }

public func igDebugNodeTableSettings_cj(settings: CPointer<Unit>, table: CPointer<Unit>): Unit { unsafe { igDebugNodeTableSettings(settings, table) } }

public func igDebugNodeInputTextState_cj(state: CPointer<Unit>): Unit { unsafe { igDebugNodeInputTextState(state) } }

public func igDebugNodeTypingSelectState_cj(state: CPointer<Unit>): Unit { unsafe { igDebugNodeTypingSelectState(state) } }

public func igDebugNodeMultiSelectState_cj(state: CPointer<Unit>): Unit { unsafe { igDebugNodeMultiSelectState(state) } }

public func igDebugNodeWindow_cj(window: CPointer<Unit>, label: CString): Unit { unsafe { igDebugNodeWindow(window, label) } }

public func igDebugNodeWindowSettings_cj(settings: CPointer<Unit>): Unit { unsafe { igDebugNodeWindowSettings(settings) } }

public func igDebugNodeWindowsList_cj(windows: CPointer<Unit>, label: CString): Unit { unsafe { igDebugNodeWindowsList(windows, label) } }

public func igDebugNodeWindowsListByBeginStackParent_cj(windows: CPointer<Unit>, windows_size: Int32, parent_in_begin_stack: CPointer<Unit>): Unit { unsafe { igDebugNodeWindowsListByBeginStackParent(windows, windows_size, parent_in_begin_stack) } }

public func igDebugNodeViewport_cj(viewport: CPointer<Unit>): Unit { unsafe { igDebugNodeViewport(viewport) } }

public func igDebugRenderKeyboardPreview_cj(draw_list: CPointer<Unit>): Unit { unsafe { igDebugRenderKeyboardPreview(draw_list) } }

public func igDebugRenderViewportThumbnail_cj(draw_list: CPointer<Unit>, viewport: CPointer<Unit>, bb: CPointer<Unit>): Unit { unsafe { igDebugRenderViewportThumbnail(draw_list, viewport, bb) } }

public func ImFontLoader_ImFontLoader_cj(): CPointer<Unit> { return unsafe { ImFontLoader_ImFontLoader() } }

public func ImFontLoader_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontLoader_destroy(self) } }

public func igImFontAtlasGetFontLoaderForStbTruetype_cj(): CPointer<Unit> { return unsafe { igImFontAtlasGetFontLoaderForStbTruetype() } }

public func igImFontAtlasRectId_GetIndex_cj(id: Int32): Int32 { return unsafe { igImFontAtlasRectId_GetIndex(id) } }

public func igImFontAtlasRectId_GetGeneration_cj(id: Int32): UInt32 { return unsafe { igImFontAtlasRectId_GetGeneration(id) } }

public func igImFontAtlasRectId_Make_cj(index_idx: Int32, gen_idx: Int32): Int32 { return unsafe { igImFontAtlasRectId_Make(index_idx, gen_idx) } }

public func ImFontAtlasBuilder_ImFontAtlasBuilder_cj(): CPointer<Unit> { return unsafe { ImFontAtlasBuilder_ImFontAtlasBuilder() } }

public func ImFontAtlasBuilder_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImFontAtlasBuilder_destroy(self) } }

public func igImFontAtlasBuildInit_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildInit(atlas) } }

public func igImFontAtlasBuildDestroy_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildDestroy(atlas) } }

public func igImFontAtlasBuildMain_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildMain(atlas) } }

public func igImFontAtlasBuildSetupFontLoader_cj(atlas: CPointer<Unit>, font_loader: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildSetupFontLoader(atlas, font_loader) } }

public func igImFontAtlasBuildNotifySetFont_cj(atlas: CPointer<Unit>, old_font: CPointer<Unit>, new_font: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildNotifySetFont(atlas, old_font, new_font) } }

public func igImFontAtlasBuildUpdatePointers_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildUpdatePointers(atlas) } }

public func igImFontAtlasBuildRenderBitmapFromString_cj(atlas: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32, in_str: CString, in_marker_char: Int8): Unit { unsafe { igImFontAtlasBuildRenderBitmapFromString(atlas, x, y, w, h, in_str, in_marker_char) } }

public func igImFontAtlasBuildClear_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildClear(atlas) } }

public func igImFontAtlasTextureAdd_cj(atlas: CPointer<Unit>, w: Int32, h: Int32): CPointer<Unit> { return unsafe { igImFontAtlasTextureAdd(atlas, w, h) } }

public func igImFontAtlasTextureMakeSpace_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasTextureMakeSpace(atlas) } }

public func igImFontAtlasTextureRepack_cj(atlas: CPointer<Unit>, w: Int32, h: Int32): Unit { unsafe { igImFontAtlasTextureRepack(atlas, w, h) } }

public func igImFontAtlasTextureGrow_cj(atlas: CPointer<Unit>, old_w: Int32, old_h: Int32): Unit { unsafe { igImFontAtlasTextureGrow(atlas, old_w, old_h) } }

public func igImFontAtlasTextureCompact_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasTextureCompact(atlas) } }

public func igImFontAtlasTextureGetSizeEstimate_cj(atlas: CPointer<Unit>): CPointer<Unit> { return unsafe { igImFontAtlasTextureGetSizeEstimate(atlas) } }

public func igImFontAtlasBuildSetupFontSpecialGlyphs_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, src: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildSetupFontSpecialGlyphs(atlas, font, src) } }

public func igImFontAtlasBuildLegacyPreloadAllGlyphRanges_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasBuildLegacyPreloadAllGlyphRanges(atlas) } }

public func igImFontAtlasBuildGetOversampleFactors_cj(src: CPointer<Unit>, baked: CPointer<Unit>, out_oversample_h: CPointer<Int32>, out_oversample_v: CPointer<Int32>): Unit { unsafe { igImFontAtlasBuildGetOversampleFactors(src, baked, out_oversample_h, out_oversample_v) } }

public func igImFontAtlasBuildDiscardBakes_cj(atlas: CPointer<Unit>, unused_frames: Int32): Unit { unsafe { igImFontAtlasBuildDiscardBakes(atlas, unused_frames) } }

public func igImFontAtlasFontSourceInit_cj(atlas: CPointer<Unit>, src: CPointer<Unit>): Int32 { return unsafe { igImFontAtlasFontSourceInit(atlas, src) } }

public func igImFontAtlasFontSourceAddToFont_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, src: CPointer<Unit>): Unit { unsafe { igImFontAtlasFontSourceAddToFont(atlas, font, src) } }

public func igImFontAtlasFontDestroySourceData_cj(atlas: CPointer<Unit>, src: CPointer<Unit>): Unit { unsafe { igImFontAtlasFontDestroySourceData(atlas, src) } }

public func igImFontAtlasFontInitOutput_cj(atlas: CPointer<Unit>, font: CPointer<Unit>): Int32 { return unsafe { igImFontAtlasFontInitOutput(atlas, font) } }

public func igImFontAtlasFontDestroyOutput_cj(atlas: CPointer<Unit>, font: CPointer<Unit>): Unit { unsafe { igImFontAtlasFontDestroyOutput(atlas, font) } }

public func igImFontAtlasFontRebuildOutput_cj(atlas: CPointer<Unit>, font: CPointer<Unit>): Unit { unsafe { igImFontAtlasFontRebuildOutput(atlas, font) } }

public func igImFontAtlasFontDiscardBakes_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, unused_frames: Int32): Unit { unsafe { igImFontAtlasFontDiscardBakes(atlas, font, unused_frames) } }

public func igImFontAtlasBakedGetId_cj(font_id: UInt32, baked_size: Float32, rasterizer_density: Float32): UInt32 { return unsafe { igImFontAtlasBakedGetId(font_id, baked_size, rasterizer_density) } }

public func igImFontAtlasBakedGetOrAdd_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32): CPointer<Unit> { return unsafe { igImFontAtlasBakedGetOrAdd(atlas, font, font_size, font_rasterizer_density) } }

public func igImFontAtlasBakedGetClosestMatch_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32): CPointer<Unit> { return unsafe { igImFontAtlasBakedGetClosestMatch(atlas, font, font_size, font_rasterizer_density) } }

public func igImFontAtlasBakedAdd_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32, baked_id: UInt32): CPointer<Unit> { return unsafe { igImFontAtlasBakedAdd(atlas, font, font_size, font_rasterizer_density, baked_id) } }

public func igImFontAtlasBakedDiscard_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, baked: CPointer<Unit>): Unit { unsafe { igImFontAtlasBakedDiscard(atlas, font, baked) } }

public func igImFontAtlasBakedAddFontGlyph_cj(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, in_glyph: CPointer<Unit>): CPointer<Unit> { return unsafe { igImFontAtlasBakedAddFontGlyph(atlas, baked, src, in_glyph) } }

public func igImFontAtlasBakedAddFontGlyphAdvancedX_cj(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, codepoint: UInt16, advance_x: Float32): Unit { unsafe { igImFontAtlasBakedAddFontGlyphAdvancedX(atlas, baked, src, codepoint, advance_x) } }

public func igImFontAtlasBakedDiscardFontGlyph_cj(atlas: CPointer<Unit>, font: CPointer<Unit>, baked: CPointer<Unit>, glyph: CPointer<Unit>): Unit { unsafe { igImFontAtlasBakedDiscardFontGlyph(atlas, font, baked, glyph) } }

public func igImFontAtlasBakedSetFontGlyphBitmap_cj(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, glyph: CPointer<Unit>, r: CPointer<Unit>, src_pixels: CPointer<Unit>, src_fmt: Int32, src_pitch: Int32): Unit { unsafe { igImFontAtlasBakedSetFontGlyphBitmap(atlas, baked, src, glyph, r, src_pixels, src_fmt, src_pitch) } }

public func igImFontAtlasPackInit_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasPackInit(atlas) } }

public func igImFontAtlasPackAddRect_cj(atlas: CPointer<Unit>, w: Int32, h: Int32, overwrite_entry: CPointer<Unit>): Int32 { return unsafe { igImFontAtlasPackAddRect(atlas, w, h, overwrite_entry) } }

public func igImFontAtlasPackGetRect_cj(atlas: CPointer<Unit>, id: Int32): CPointer<Unit> { return unsafe { igImFontAtlasPackGetRect(atlas, id) } }

public func igImFontAtlasPackGetRectSafe_cj(atlas: CPointer<Unit>, id: Int32): CPointer<Unit> { return unsafe { igImFontAtlasPackGetRectSafe(atlas, id) } }

public func igImFontAtlasPackDiscardRect_cj(atlas: CPointer<Unit>, id: Int32): Unit { unsafe { igImFontAtlasPackDiscardRect(atlas, id) } }

public func igImFontAtlasUpdateNewFrame_cj(atlas: CPointer<Unit>, frame_count: Int32, renderer_has_textures: Int32): Unit { unsafe { igImFontAtlasUpdateNewFrame(atlas, frame_count, renderer_has_textures) } }

public func igImFontAtlasAddDrawListSharedData_cj(atlas: CPointer<Unit>, data: CPointer<Unit>): Unit { unsafe { igImFontAtlasAddDrawListSharedData(atlas, data) } }

public func igImFontAtlasRemoveDrawListSharedData_cj(atlas: CPointer<Unit>, data: CPointer<Unit>): Unit { unsafe { igImFontAtlasRemoveDrawListSharedData(atlas, data) } }

public func igImFontAtlasUpdateDrawListsTextures_cj(atlas: CPointer<Unit>, old_tex: CPointer<Unit>, new_tex: CPointer<Unit>): Unit { unsafe { igImFontAtlasUpdateDrawListsTextures(atlas, old_tex, new_tex) } }

public func igImFontAtlasUpdateDrawListsSharedData_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasUpdateDrawListsSharedData(atlas) } }

public func igImFontAtlasTextureBlockConvert_cj(src_pixels: CPointer<Unit>, src_fmt: Int32, src_pitch: Int32, dst_pixels: CPointer<Unit>, dst_fmt: Int32, dst_pitch: Int32, w: Int32, h: Int32): Unit { unsafe { igImFontAtlasTextureBlockConvert(src_pixels, src_fmt, src_pitch, dst_pixels, dst_fmt, dst_pitch, w, h) } }

public func igImFontAtlasTextureBlockPostProcess_cj(data: CPointer<Unit>): Unit { unsafe { igImFontAtlasTextureBlockPostProcess(data) } }

public func igImFontAtlasTextureBlockPostProcessMultiply_cj(data: CPointer<Unit>, multiply_factor: Float32): Unit { unsafe { igImFontAtlasTextureBlockPostProcessMultiply(data, multiply_factor) } }

public func igImFontAtlasTextureBlockFill_cj(dst_tex: CPointer<Unit>, dst_x: Int32, dst_y: Int32, w: Int32, h: Int32, col: UInt32): Unit { unsafe { igImFontAtlasTextureBlockFill(dst_tex, dst_x, dst_y, w, h, col) } }

public func igImFontAtlasTextureBlockCopy_cj(src_tex: CPointer<Unit>, src_x: Int32, src_y: Int32, dst_tex: CPointer<Unit>, dst_x: Int32, dst_y: Int32, w: Int32, h: Int32): Unit { unsafe { igImFontAtlasTextureBlockCopy(src_tex, src_x, src_y, dst_tex, dst_x, dst_y, w, h) } }

public func igImFontAtlasTextureBlockQueueUpload_cj(atlas: CPointer<Unit>, tex: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32): Unit { unsafe { igImFontAtlasTextureBlockQueueUpload(atlas, tex, x, y, w, h) } }

public func igImTextureDataUpdateNewFrame_cj(tex: CPointer<Unit>): Int32 { return unsafe { igImTextureDataUpdateNewFrame(tex) } }

public func igImTextureDataQueueUpload_cj(tex: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32): Unit { unsafe { igImTextureDataQueueUpload(tex, x, y, w, h) } }

public func igImTextureDataGetFormatBytesPerPixel_cj(format: Int32): Int32 { return unsafe { igImTextureDataGetFormatBytesPerPixel(format) } }

public func igImTextureDataGetStatusName_cj(status: Int32): String {
    return unsafe {
        let p = igImTextureDataGetStatusName(status)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImTextureDataGetFormatName_cj(format: Int32): String {
    return unsafe {
        let p = igImTextureDataGetFormatName(format)
        if (p.isNull()) { "" } else { p.toString() }
    }
}

public func igImFontAtlasDebugLogTextureRequests_cj(atlas: CPointer<Unit>): Unit { unsafe { igImFontAtlasDebugLogTextureRequests(atlas) } }

public func igImFontAtlasGetMouseCursorTexData_cj(atlas: CPointer<Unit>, cursor_type: Int32, out_offset: CPointer<ImVec2>, out_size: CPointer<ImVec2>, out_uv_border: CPointer<Unit>, out_uv_fill: CPointer<Unit>): Int32 { return unsafe { igImFontAtlasGetMouseCursorTexData(atlas, cursor_type, out_offset, out_size, out_uv_border, out_uv_fill) } }

public func igGET_FLT_MAX_cj(): Float32 { return unsafe { igGET_FLT_MAX() } }

public func igGET_FLT_MIN_cj(): Float32 { return unsafe { igGET_FLT_MIN() } }

public func ImVector_ImWchar_create_cj(): CPointer<Unit> { return unsafe { ImVector_ImWchar_create() } }

public func ImVector_ImWchar_destroy_cj(self: CPointer<Unit>): Unit { unsafe { ImVector_ImWchar_destroy(self) } }

public func ImVector_ImWchar_Init_cj(p: CPointer<Unit>): Unit { unsafe { ImVector_ImWchar_Init(p) } }

public func ImVector_ImWchar_UnInit_cj(p: CPointer<Unit>): Unit { unsafe { ImVector_ImWchar_UnInit(p) } }

public func ImGui_ImplSDL3_InitForD3D_cj(window: CPointer<Unit>): Int32 { return unsafe { ImGui_ImplSDL3_InitForD3D(window) } }

public func ImGui_ImplSDL3_InitForMetal_cj(window: CPointer<Unit>): Int32 { return unsafe { ImGui_ImplSDL3_InitForMetal(window) } }

public func ImGui_ImplSDL3_InitForSDLGPU_cj(window: CPointer<Unit>): Int32 { return unsafe { ImGui_ImplSDL3_InitForSDLGPU(window) } }

public func ImGui_ImplSDL3_InitForSDLRenderer_cj(window: CPointer<Unit>, renderer: CPointer<Unit>): Int32 { return unsafe { ImGui_ImplSDL3_InitForSDLRenderer(window, renderer) } }

public func ImGui_ImplSDL3_InitForVulkan_cj(window: CPointer<Unit>): Int32 { return unsafe { ImGui_ImplSDL3_InitForVulkan(window) } }

public func ImGui_ImplSDL3_SetGamepadMode_cj(mode: Int32, manual_gamepads_array: CPointer<Unit>, manual_gamepads_count: Int32): Unit { unsafe { ImGui_ImplSDL3_SetGamepadMode(mode, manual_gamepads_array, manual_gamepads_count) } }

public func ImGui_ImplSDL3_SetMouseCaptureMode_cj(mode: Int32): Unit { unsafe { ImGui_ImplSDL3_SetMouseCaptureMode(mode) } }

// =============================================================================
// ImGuiIO 字段访问（@C struct 指针重解释，布局见 types.cj / imgui.h v1.92.9）
// =============================================================================

/// 读取 ImGuiIO 快照（当前帧输入/输出状态）
public func ImGui_IO_Read_cj(): ImGuiIO {
    unsafe {
        let p = CPointer<ImGuiIO>(igGetIO_Nil())
        if (p.isNull()) { return ImGuiIO() }
        return p.read()
    }
}

/// 写回 ImGuiIO（请先 Read 修改后写回；仅覆盖 types.cj 中已定义的前缀字段）
public func ImGui_IO_Write_cj(io: ImGuiIO): Unit {
    unsafe {
        let p = CPointer<ImGuiIO>(igGetIO_Nil())
        if (!p.isNull()) { p.write(io) }
    }
}

/// 鼠标是否被 ImGui 捕获（为 true 时游戏不应响应鼠标）
public func ImGui_IO_WantCaptureMouse_cj(): Bool { return ImGui_IO_Read_cj().wantCaptureMouse }

/// 键盘是否被 ImGui 捕获（为 true 时游戏不应响应键盘）
public func ImGui_IO_WantCaptureKeyboard_cj(): Bool { return ImGui_IO_Read_cj().wantCaptureKeyboard }

/// ImGui 是否需要文本输入（如 InputText 激活，移动端可据此弹软键盘）
public func ImGui_IO_WantTextInput_cj(): Bool { return ImGui_IO_Read_cj().wantTextInput }

/// 导航是否激活（窗口获得焦点且未禁用导航输入）
public func ImGui_IO_NavActive_cj(): Bool { return ImGui_IO_Read_cj().navActive }

/// 导航高亮是否可见
public func ImGui_IO_NavVisible_cj(): Bool { return ImGui_IO_Read_cj().navVisible }

/// 帧率估计（基于 io.DeltaTime 的 60 帧滚动平均）
public func ImGui_IO_Framerate_cj(): Float32 { return ImGui_IO_Read_cj().framerate }

/// 当前帧鼠标位置（无效时为 (-FLT_MAX, -FLT_MAX)）
public func ImGui_IO_MousePos_cj(): ImVec2 { return ImGui_IO_Read_cj().mousePos }

/// 当前帧鼠标位移（任一位置无效时为零向量）
public func ImGui_IO_MouseDelta_cj(): ImVec2 { return ImGui_IO_Read_cj().mouseDelta }

/// 鼠标键按下状态（button: 0=左, 1=右, 2=中）
public func ImGui_IO_MouseDown_cj(button: Int32): Bool {
    if (button < 0 || button >= 5) { return false }
    unsafe {
        let p = CPointer<ImGuiIO>(igGetIO_Nil())
        if (p.isNull()) { return false }
        return p.read().mouseDown[Int64(button)]
    }
}

/// 垂直滚轮增量（>0 上滚，<0 下滚）
public func ImGui_IO_MouseWheel_cj(): Float32 { return ImGui_IO_Read_cj().mouseWheel }

/// 水平滚轮增量（>0 左滚，<0 右滚）
public func ImGui_IO_MouseWheelH_cj(): Float32 { return ImGui_IO_Read_cj().mouseWheelH }

/// Ctrl（macOS 上为 Cmd）是否按下
public func ImGui_IO_KeyCtrl_cj(): Bool { return ImGui_IO_Read_cj().keyCtrl }

/// Shift 是否按下
public func ImGui_IO_KeyShift_cj(): Bool { return ImGui_IO_Read_cj().keyShift }

/// Alt 是否按下
public func ImGui_IO_KeyAlt_cj(): Bool { return ImGui_IO_Read_cj().keyAlt }

/// Super（非 macOS 为 Win，macOS 为 Ctrl）是否按下
public func ImGui_IO_KeySuper_cj(): Bool { return ImGui_IO_Read_cj().keySuper }

/// 修饰键合并位掩码（ImGuiMod_Ctrl/Shift/Alt/Super 按位或）
public func ImGui_IO_KeyMods_cj(): Int32 { return ImGui_IO_Read_cj().keyMods }

/// 全局透明度（ImGuiStyle.Alpha）
public func ImGui_Style_GetAlpha_cj(): Float32 { return unsafe { CPointer<ImGuiStyle>(igGetStyle()).read().alpha } }

/// 设置全局透明度
public func ImGui_Style_SetAlpha_cj(alpha: Float32): Unit {
    unsafe {
        let p = CPointer<ImGuiStyle>(igGetStyle())
        if (p.isNull()) { return }
        var s = p.read()
        s.alpha = alpha
        p.write(s)
    }
}

// =============================================================================
// ImGuiStyle 字段访问（@C struct 指针重解释）
// =============================================================================

/// 读取 ImGuiStyle 快照
public func ImGui_Style_Read_cj(): ImGuiStyle {
    unsafe {
        let p = CPointer<ImGuiStyle>(igGetStyle())
        if (p.isNull()) { return ImGuiStyle() }
        return p.read()
    }
}

/// 写回 ImGuiStyle（请先 Read 修改后写回；仅覆盖 types.cj 中已定义的前缀字段）
public func ImGui_Style_Write_cj(style: ImGuiStyle): Unit {
    unsafe {
        let p = CPointer<ImGuiStyle>(igGetStyle())
        if (!p.isNull()) { p.write(style) }
    }
}

/// 读取单个样式色（ImGuiCol 索引，RGBA 0.0..1.0）
public func ImGui_Style_GetColorVec4_cj(idx: Int32): ImVec4 {
    unsafe {
        let p = CPointer<ImGuiStyle>(igGetStyle())
        if (p.isNull() || idx < 0 || idx >= 66) { return ImVec4() }
        return p.read().colors[Int64(idx)]
    }
}

/// 修改单个样式色（ImGuiCol 索引，RGBA 0.0..1.0）
public func ImGui_Style_SetColorVec4_cj(idx: Int32, col: ImVec4): Unit {
    unsafe {
        let p = CPointer<ImGuiStyle>(igGetStyle())
        if (p.isNull() || idx < 0 || idx >= 66) { return }
        var s = p.read()
        s.colors[Int64(idx)] = col
        p.write(s)
    }
}

// =============================================================================
// ImGuiInputTextCallbackData 字段访问（@C struct 指针重解释，回调内使用）
// =============================================================================

/// 读取回调数据快照
public func ImGui_InputTextData_Read_cj(data: CPointer<Unit>): ImGuiInputTextCallbackData {
    unsafe {
        let p = CPointer<ImGuiInputTextCallbackData>(data)
        if (p.isNull()) { return ImGuiInputTextCallbackData() }
        return p.read()
    }
}

/// 写回回调数据（修改字段后调用）
public func ImGui_InputTextData_Write_cj(data: CPointer<Unit>, d: ImGuiInputTextCallbackData): Unit {
    unsafe {
        let p = CPointer<ImGuiInputTextCallbackData>(data)
        if (!p.isNull()) { p.write(d) }
    }
}

/// 回调事件类型（ImGuiInputTextFlags_Callback*，只读）
public func ImGui_InputTextData_GetEventFlag_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).eventFlag }

/// 事件键（ImGuiKey，只读）
public func ImGui_InputTextData_GetEventKey_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).eventKey }

/// 输入字符（[CharFilter] 可读写：替换为其它字符，或置 0 丢弃）
public func ImGui_InputTextData_GetEventChar_cj(data: CPointer<Unit>): UInt16 { return ImGui_InputTextData_Read_cj(data).eventChar }

/// 设置输入字符（置 0 表示丢弃该字符）
public func ImGui_InputTextData_SetEventChar_cj(data: CPointer<Unit>, c: UInt16): Unit {
    unsafe {
        let p = CPointer<ImGuiInputTextCallbackData>(data)
        if (p.isNull()) { return }
        var d = p.read()
        d.eventChar = c
        p.write(d)
    }
}

/// 文本缓冲指针（可读写内容，勿替换指针）
public func ImGui_InputTextData_GetBuf_cj(data: CPointer<Unit>): CPointer<UInt8> { return ImGui_InputTextData_Read_cj(data).buf }

/// 文本长度（不含 '\0'）
public func ImGui_InputTextData_GetBufTextLen_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).bufTextLen }

/// 缓冲容量（含 '\0' 存储位，只读）
public func ImGui_InputTextData_GetBufSize_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).bufSize }

/// 光标位置（可读写）
public func ImGui_InputTextData_GetCursorPos_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).cursorPos }

/// 设置光标位置
public func ImGui_InputTextData_SetCursorPos_cj(data: CPointer<Unit>, pos: Int32): Unit {
    unsafe {
        let p = CPointer<ImGuiInputTextCallbackData>(data)
        if (p.isNull()) { return }
        var d = p.read()
        d.cursorPos = pos
        p.write(d)
    }
}

/// 选区起点（== selectionEnd 时无选区）
public func ImGui_InputTextData_GetSelectionStart_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).selectionStart }

/// 选区终点
public func ImGui_InputTextData_GetSelectionEnd_cj(data: CPointer<Unit>): Int32 { return ImGui_InputTextData_Read_cj(data).selectionEnd }

/// 设置选区（同时移动光标到 end）
public func ImGui_InputTextData_SetSelection_cj(data: CPointer<Unit>, start: Int32, end_: Int32): Unit {
    unsafe {
        let p = CPointer<ImGuiInputTextCallbackData>(data)
        if (p.isNull()) { return }
        var d = p.read()
        d.selectionStart = start
        d.selectionEnd = end_
        d.cursorPos = end_
        p.write(d)
    }
}
