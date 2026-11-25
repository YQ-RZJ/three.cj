/**
 * @file imgui4cj FFI 函数声明（自动生成，基于 cimgui.h）
 * @explain 本文件包含 cimgui.h 中所有 C 函数的 foreign 声明。
 *         这些函数是包级私有的，外部调用请使用 ffi_exports.cj 中的包装。
 * @note C 字符串使用 CString；bool 用 Int32（0/1）；
 *       void* 指针用 CPointer<Unit>。
 */
protected package three._vendor.imgui4cj.imgui

import std.core.*

// =============================================================================
// igXXX 函数（cimgui.h，共 1477 个）
// =============================================================================

@FastNative
foreign func ImVec2_ImVec2_Nil(): CPointer<Unit>
@FastNative
foreign func ImVec2_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVec2_ImVec2_Float(_x: Float32, _y: Float32): CPointer<Unit>
@FastNative
foreign func ImVec4_ImVec4_Nil(): CPointer<Unit>
@FastNative
foreign func ImVec4_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVec4_ImVec4_Float(_x: Float32, _y: Float32, _z: Float32, _w: Float32): CPointer<Unit>
@FastNative
foreign func ImTextureRef_ImTextureRef_Nil(): CPointer<Unit>
@FastNative
foreign func ImTextureRef_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImTextureRef_ImTextureRef_TextureID(tex_id: UInt64): CPointer<Unit>
@FastNative
foreign func ImTextureRef_GetTexID(self: CPointer<Unit>): UInt64
@FastNative
foreign func igCreateContext(shared_font_atlas: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igDestroyContext(ctx: CPointer<Unit>): Unit
@FastNative
foreign func igGetCurrentContext(): CPointer<Unit>
@FastNative
foreign func igSetCurrentContext(ctx: CPointer<Unit>): Unit
@FastNative
foreign func igGetIO_Nil(): CPointer<Unit>
@FastNative
foreign func igGetPlatformIO_Nil(): CPointer<Unit>
@FastNative
foreign func igGetStyle(): CPointer<Unit>
@FastNative
foreign func igNewFrame(): Unit
@FastNative
foreign func igEndFrame(): Unit
@FastNative
foreign func igRender(): Unit
@FastNative
foreign func igGetDrawData(): CPointer<Unit>
@FastNative
foreign func igShowDemoWindow(p_open: CPointer<Int32>): Unit
@FastNative
foreign func igShowMetricsWindow(p_open: CPointer<Int32>): Unit
@FastNative
foreign func igShowDebugLogWindow(p_open: CPointer<Int32>): Unit
@FastNative
foreign func igShowIDStackToolWindow(p_open: CPointer<Int32>): Unit
@FastNative
foreign func igShowAboutWindow(p_open: CPointer<Int32>): Unit
@FastNative
foreign func igShowStyleEditor(ref: CPointer<Unit>): Unit
@FastNative
foreign func igShowStyleSelector(label: CString): Int32
@FastNative
foreign func igShowFontSelector(label: CString): Unit
@FastNative
foreign func igShowUserGuide(): Unit
@FastNative
foreign func igGetVersion(): CString
@FastNative
foreign func igStyleColorsDark(dst: CPointer<Unit>): Unit
@FastNative
foreign func igStyleColorsLight(dst: CPointer<Unit>): Unit
@FastNative
foreign func igStyleColorsClassic(dst: CPointer<Unit>): Unit
@FastNative
foreign func igBegin(name: CString, p_open: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igEnd(): Unit
@FastNative
foreign func igBeginChild_Str(str_id: CString, size: ImVec2, child_flags: Int32, window_flags: Int32): Int32
@FastNative
foreign func igBeginChild_ID(id: UInt32, size: ImVec2, child_flags: Int32, window_flags: Int32): Int32
@FastNative
foreign func igEndChild(): Unit
@FastNative
foreign func igIsWindowAppearing(): Int32
@FastNative
foreign func igIsWindowCollapsed(): Int32
@FastNative
foreign func igIsWindowFocused(flags: Int32): Int32
@FastNative
foreign func igIsWindowHovered(flags: Int32): Int32
@FastNative
foreign func igGetWindowDrawList(): CPointer<Unit>
@FastNative
foreign func igGetWindowPos(): ImVec2
@FastNative
foreign func igGetWindowSize(): ImVec2
@FastNative
foreign func igGetWindowWidth(): Float32
@FastNative
foreign func igGetWindowHeight(): Float32
@FastNative
foreign func igSetNextWindowPos(pos: ImVec2, cond: Int32, pivot: ImVec2): Unit
@FastNative
foreign func igSetNextWindowSize(size: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetNextWindowSizeConstraints(size_min: ImVec2, size_max: ImVec2, custom_callback: CPointer<Unit>, custom_callback_data: CPointer<Unit>): Unit
@FastNative
foreign func igSetNextWindowContentSize(size: ImVec2): Unit
@FastNative
foreign func igSetNextWindowCollapsed(collapsed: Int32, cond: Int32): Unit
@FastNative
foreign func igSetNextWindowFocus(): Unit
@FastNative
foreign func igSetNextWindowScroll(scroll: ImVec2): Unit
@FastNative
foreign func igSetNextWindowBgAlpha(alpha: Float32): Unit
@FastNative
foreign func igSetWindowPos_Vec2(pos: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowSize_Vec2(size: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowCollapsed_Bool(collapsed: Int32, cond: Int32): Unit
@FastNative
foreign func igSetWindowFocus_Nil(): Unit
@FastNative
foreign func igSetWindowPos_Str(name: CString, pos: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowSize_Str(name: CString, size: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowCollapsed_Str(name: CString, collapsed: Int32, cond: Int32): Unit
@FastNative
foreign func igSetWindowFocus_Str(name: CString): Unit
@FastNative
foreign func igGetScrollX(): Float32
@FastNative
foreign func igGetScrollY(): Float32
@FastNative
foreign func igSetScrollX_Float(scroll_x: Float32): Unit
@FastNative
foreign func igSetScrollY_Float(scroll_y: Float32): Unit
@FastNative
foreign func igGetScrollMaxX(): Float32
@FastNative
foreign func igGetScrollMaxY(): Float32
@FastNative
foreign func igSetScrollHereX(center_x_ratio: Float32): Unit
@FastNative
foreign func igSetScrollHereY(center_y_ratio: Float32): Unit
@FastNative
foreign func igSetScrollFromPosX_Float(local_x: Float32, center_x_ratio: Float32): Unit
@FastNative
foreign func igSetScrollFromPosY_Float(local_y: Float32, center_y_ratio: Float32): Unit
@FastNative
foreign func igPushFont(font: CPointer<Unit>, font_size_base_unscaled: Float32): Unit
@FastNative
foreign func igPopFont(): Unit
@FastNative
foreign func igGetFont(): CPointer<Unit>
@FastNative
foreign func igGetFontSize(): Float32
@FastNative
foreign func igGetFontBaked(): CPointer<Unit>
@FastNative
foreign func igPushStyleColor_U32(idx: Int32, col: UInt32): Unit
@FastNative
foreign func igPushStyleColor_Vec4(idx: Int32, col: ImVec4): Unit
@FastNative
foreign func igPopStyleColor(count: Int32): Unit
@FastNative
foreign func igPushStyleVar_Float(idx: Int32, val: Float32): Unit
@FastNative
foreign func igPushStyleVar_Vec2(idx: Int32, val: ImVec2): Unit
@FastNative
foreign func igPushStyleVarX(idx: Int32, val_x: Float32): Unit
@FastNative
foreign func igPushStyleVarY(idx: Int32, val_y: Float32): Unit
@FastNative
foreign func igPopStyleVar(count: Int32): Unit
@FastNative
foreign func igPushItemFlag(option: Int32, enabled: Int32): Unit
@FastNative
foreign func igPopItemFlag(): Unit
@FastNative
foreign func igPushItemWidth(item_width: Float32): Unit
@FastNative
foreign func igPopItemWidth(): Unit
@FastNative
foreign func igSetNextItemWidth(item_width: Float32): Unit
@FastNative
foreign func igCalcItemWidth(): Float32
@FastNative
foreign func igPushTextWrapPos(wrap_local_pos_x: Float32): Unit
@FastNative
foreign func igPopTextWrapPos(): Unit
@FastNative
foreign func igGetFontTexUvWhitePixel(): ImVec2
@FastNative
foreign func igGetColorU32_Col(idx: Int32, alpha_mul: Float32): UInt32
@FastNative
foreign func igGetColorU32_Vec4(col: ImVec4): UInt32
@FastNative
foreign func igGetColorU32_U32(col: UInt32, alpha_mul: Float32): UInt32
@FastNative
foreign func igGetStyleColorVec4(idx: Int32): CPointer<ImVec4>
@FastNative
foreign func igGetCursorScreenPos(): ImVec2
@FastNative
foreign func igSetCursorScreenPos(pos: ImVec2): Unit
@FastNative
foreign func igGetContentRegionAvail(): ImVec2
@FastNative
foreign func igGetCursorPos(): ImVec2
@FastNative
foreign func igGetCursorPosX(): Float32
@FastNative
foreign func igGetCursorPosY(): Float32
@FastNative
foreign func igSetCursorPos(local_pos: ImVec2): Unit
@FastNative
foreign func igSetCursorPosX(local_x: Float32): Unit
@FastNative
foreign func igSetCursorPosY(local_y: Float32): Unit
@FastNative
foreign func igGetCursorStartPos(): ImVec2
@FastNative
foreign func igSeparator(): Unit
@FastNative
foreign func igSameLine(offset_from_start_x: Float32, spacing: Float32): Unit
@FastNative
foreign func igNewLine(): Unit
@FastNative
foreign func igSpacing(): Unit
@FastNative
foreign func igDummy(size: ImVec2): Unit
@FastNative
foreign func igIndent(indent_w: Float32): Unit
@FastNative
foreign func igUnindent(indent_w: Float32): Unit
@FastNative
foreign func igBeginGroup(): Unit
@FastNative
foreign func igEndGroup(): Unit
@FastNative
foreign func igAlignTextToFramePadding(): Unit
@FastNative
foreign func igGetTextLineHeight(): Float32
@FastNative
foreign func igGetTextLineHeightWithSpacing(): Float32
@FastNative
foreign func igGetFrameHeight(): Float32
@FastNative
foreign func igGetFrameHeightWithSpacing(): Float32
@FastNative
foreign func igPushID_Str(str_id: CString): Unit
@FastNative
foreign func igPushID_StrStr(str_id_begin: CString, str_id_end: CString): Unit
@FastNative
foreign func igPushID_Ptr(ptr_id: CPointer<Unit>): Unit
@FastNative
foreign func igPushID_Int(int_id: Int32): Unit
@FastNative
foreign func igPopID(): Unit
@FastNative
foreign func igGetID_Str(str_id: CString): UInt32
@FastNative
foreign func igGetID_StrStr(str_id_begin: CString, str_id_end: CString): UInt32
@FastNative
foreign func igGetID_Ptr(ptr_id: CPointer<Unit>): UInt32
@FastNative
foreign func igGetID_Int(int_id: Int32): UInt32
@FastNative
foreign func igTextUnformatted(text: CString, text_end: CString): Unit
@FastNative
foreign func igText0(fmt: CString): Unit
@FastNative
foreign func igTextColored0(col: ImVec4, fmt: CString): Unit
@FastNative
foreign func igTextDisabled0(fmt: CString): Unit
@FastNative
foreign func igTextWrapped0(fmt: CString): Unit
@FastNative
foreign func igLabelText0(label: CString, fmt: CString): Unit
@FastNative
foreign func igBulletText0(fmt: CString): Unit
@FastNative
foreign func igSeparatorText(label: CString): Unit
@FastNative
foreign func igButton(label: CString, size: ImVec2): Int32
@FastNative
foreign func igSmallButton(label: CString): Int32
@FastNative
foreign func igInvisibleButton(str_id: CString, size: ImVec2, flags: Int32): Int32
@FastNative
foreign func igArrowButton(str_id: CString, dir: Int32): Int32
@FastNative
foreign func igCheckbox(label: CString, v: CPointer<Int32>): Int32
@FastNative
foreign func igCheckboxFlags_IntPtr(label: CString, flags: CPointer<Int32>, flags_value: Int32): Int32
@FastNative
foreign func igCheckboxFlags_UintPtr(label: CString, flags: CPointer<UInt32>, flags_value: UInt32): Int32
@FastNative
foreign func igRadioButton_Bool(label: CString, active: Int32): Int32
@FastNative
foreign func igRadioButton_IntPtr(label: CString, v: CPointer<Int32>, v_button: Int32): Int32
@FastNative
foreign func igProgressBar(fraction: Float32, size_arg: ImVec2, overlay: CString): Unit
@FastNative
foreign func igBullet(): Unit
@FastNative
foreign func igTextLink(label: CString): Int32
@FastNative
foreign func igTextLinkOpenURL(label: CString, url: CString): Int32
@FastNative
foreign func igImage(tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2): Unit
@FastNative
foreign func igImageWithBg(tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4): Unit
@FastNative
foreign func igImageButton(str_id: CString, tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4): Int32
@FastNative
foreign func igBeginCombo(label: CString, preview_value: CString, flags: Int32): Int32
@FastNative
foreign func igEndCombo(): Unit
@FastNative
foreign func igCombo_Str_arr(label: CString, current_item: CPointer<Int32>, items: CPointer<Unit>, items_count: Int32, popup_max_height_in_items: Int32): Int32
@FastNative
foreign func igCombo_Str(label: CString, current_item: CPointer<Int32>, items_separated_by_zeros: CString, popup_max_height_in_items: Int32): Int32
@FastNative
foreign func igDragFloat(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragFloat2(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragFloat3(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragFloat4(label: CString, v: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragFloatRange2(label: CString, v_current_min: CPointer<Float32>, v_current_max: CPointer<Float32>, v_speed: Float32, v_min: Float32, v_max: Float32, format: CString, format_max: CString, flags: Int32): Int32
@FastNative
foreign func igDragInt(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragInt2(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragInt3(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragInt4(label: CString, v: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragIntRange2(label: CString, v_current_min: CPointer<Int32>, v_current_max: CPointer<Int32>, v_speed: Float32, v_min: Int32, v_max: Int32, format: CString, format_max: CString, flags: Int32): Int32
@FastNative
foreign func igDragScalar(label: CString, data_type: Int32, p_data: CPointer<Unit>, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igDragScalarN(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderFloat(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderFloat2(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderFloat3(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderFloat4(label: CString, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderAngle(label: CString, v_rad: CPointer<Float32>, v_degrees_min: Float32, v_degrees_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderInt(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderInt2(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderInt3(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderInt4(label: CString, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderScalar(label: CString, data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderScalarN(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igVSliderFloat(label: CString, size: ImVec2, v: CPointer<Float32>, v_min: Float32, v_max: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igVSliderInt(label: CString, size: ImVec2, v: CPointer<Int32>, v_min: Int32, v_max: Int32, format: CString, flags: Int32): Int32
@FastNative
foreign func igVSliderScalar(label: CString, size: ImVec2, data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
foreign func igInputText(label: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32
foreign func igInputTextMultiline(label: CString, buf: CPointer<Int8>, buf_size: UIntNative, size: ImVec2, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32
foreign func igInputTextWithHint(label: CString, hint: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32
@FastNative
foreign func igInputFloat(label: CString, v: CPointer<Float32>, step: Float32, step_fast: Float32, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputFloat2(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputFloat3(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputFloat4(label: CString, v: CPointer<Float32>, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputInt(label: CString, v: CPointer<Int32>, step: Int32, step_fast: Int32, flags: Int32): Int32
@FastNative
foreign func igInputInt2(label: CString, v: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igInputInt3(label: CString, v: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igInputInt4(label: CString, v: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igInputDouble(label: CString, v: CPointer<Float64>, step: Float64, step_fast: Float64, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputScalar(label: CString, data_type: Int32, p_data: CPointer<Unit>, p_step: CPointer<Unit>, p_step_fast: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igInputScalarN(label: CString, data_type: Int32, p_data: CPointer<Unit>, components: Int32, p_step: CPointer<Unit>, p_step_fast: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igColorEdit3(label: CString, col: CPointer<Float32>, flags: Int32): Int32
@FastNative
foreign func igColorEdit4(label: CString, col: CPointer<Float32>, flags: Int32): Int32
@FastNative
foreign func igColorPicker3(label: CString, col: CPointer<Float32>, flags: Int32): Int32
@FastNative
foreign func igColorPicker4(label: CString, col: CPointer<Float32>, flags: Int32, ref_col: CPointer<Float32>): Int32
@FastNative
foreign func igColorButton(desc_id: CString, col: ImVec4, flags: Int32, size: ImVec2): Int32
@FastNative
foreign func igTreeNode_Str(label: CString): Int32
@FastNative
foreign func igTreeNode_StrStr0(str_id: CString, fmt: CString): Int32
@FastNative
foreign func igTreeNode_Ptr0(ptr_id: CPointer<Unit>, fmt: CString): Int32
@FastNative
foreign func igTreeNodeEx_Str(label: CString, flags: Int32): Int32
@FastNative
foreign func igTreeNodeEx_StrStr0(str_id: CString, flags: Int32, fmt: CString): Int32
@FastNative
foreign func igTreeNodeEx_Ptr0(ptr_id: CPointer<Unit>, flags: Int32, fmt: CString): Int32
@FastNative
foreign func igTreePush_Str(str_id: CString): Unit
@FastNative
foreign func igTreePush_Ptr(ptr_id: CPointer<Unit>): Unit
@FastNative
foreign func igTreePop(): Unit
@FastNative
foreign func igGetTreeNodeToLabelSpacing(): Float32
@FastNative
foreign func igCollapsingHeader_TreeNodeFlags(label: CString, flags: Int32): Int32
@FastNative
foreign func igCollapsingHeader_BoolPtr(label: CString, p_visible: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igSetNextItemOpen(is_open: Int32, cond: Int32): Unit
@FastNative
foreign func igSetNextItemStorageID(storage_id: UInt32): Unit
@FastNative
foreign func igTreeNodeGetOpen(storage_id: UInt32): Int32
@FastNative
foreign func igSelectable_Bool(label: CString, selected: Int32, flags: Int32, size: ImVec2): Int32
@FastNative
foreign func igSelectable_BoolPtr(label: CString, p_selected: CPointer<Int32>, flags: Int32, size: ImVec2): Int32
@FastNative
foreign func igBeginMultiSelect(flags: Int32, selection_size: Int32, items_count: Int32): CPointer<Unit>
@FastNative
foreign func igEndMultiSelect(): CPointer<Unit>
@FastNative
foreign func igSetNextItemSelectionUserData(selection_user_data: Int64): Unit
@FastNative
foreign func igIsItemToggledSelection(): Int32
@FastNative
foreign func igBeginListBox(label: CString, size: ImVec2): Int32
@FastNative
foreign func igEndListBox(): Unit
@FastNative
foreign func igListBox_Str_arr(label: CString, current_item: CPointer<Int32>, items: CPointer<Unit>, items_count: Int32, height_in_items: Int32): Int32
@FastNative
foreign func igPlotLines_FloatPtr(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit
@FastNative
foreign func igPlotHistogram_FloatPtr(label: CString, values: CPointer<Float32>, values_count: Int32, values_offset: Int32, overlay_text: CString, scale_min: Float32, scale_max: Float32, graph_size: ImVec2, stride: Int32): Unit
@FastNative
foreign func igValue_Bool(prefix: CString, b: Int32): Unit
@FastNative
foreign func igValue_Int(prefix: CString, v: Int32): Unit
@FastNative
foreign func igValue_Uint(prefix: CString, v: UInt32): Unit
@FastNative
foreign func igValue_Float(prefix: CString, v: Float32, float_format: CString): Unit
@FastNative
foreign func igBeginMenuBar(): Int32
@FastNative
foreign func igEndMenuBar(): Unit
@FastNative
foreign func igBeginMainMenuBar(): Int32
@FastNative
foreign func igEndMainMenuBar(): Unit
@FastNative
foreign func igBeginMenu(label: CString, enabled: Int32): Int32
@FastNative
foreign func igEndMenu(): Unit
@FastNative
foreign func igMenuItem_Bool(label: CString, shortcut: CString, selected: Int32, enabled: Int32): Int32
@FastNative
foreign func igMenuItem_BoolPtr(label: CString, shortcut: CString, p_selected: CPointer<Int32>, enabled: Int32): Int32
@FastNative
foreign func igBeginTooltip(): Int32
@FastNative
foreign func igEndTooltip(): Unit
@FastNative
foreign func igSetTooltip0(fmt: CString): Unit
@FastNative
foreign func igBeginItemTooltip(): Int32
@FastNative
foreign func igSetItemTooltip0(fmt: CString): Unit
@FastNative
foreign func igBeginPopup(str_id: CString, flags: Int32): Int32
@FastNative
foreign func igBeginPopupModal(name: CString, p_open: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igEndPopup(): Unit
@FastNative
foreign func igOpenPopup_Str(str_id: CString, popup_flags: Int32): Int32
@FastNative
foreign func igOpenPopup_ID(id: UInt32, popup_flags: Int32): Int32
@FastNative
foreign func igOpenPopupOnItemClick(str_id: CString, popup_flags: Int32): Int32
@FastNative
foreign func igCloseCurrentPopup(): Unit
@FastNative
foreign func igBeginPopupContextItem(str_id: CString, popup_flags: Int32): Int32
@FastNative
foreign func igBeginPopupContextWindow(str_id: CString, popup_flags: Int32): Int32
@FastNative
foreign func igBeginPopupContextVoid(str_id: CString, popup_flags: Int32): Int32
@FastNative
foreign func igIsPopupOpen_Str(str_id: CString, flags: Int32): Int32
@FastNative
foreign func igBeginTable(str_id: CString, columns: Int32, flags: Int32, outer_size: ImVec2, inner_width: Float32): Int32
@FastNative
foreign func igEndTable(): Unit
@FastNative
foreign func igTableNextRow(row_flags: Int32, min_row_height: Float32): Unit
@FastNative
foreign func igTableNextColumn(): Int32
@FastNative
foreign func igTableSetColumnIndex(column_n: Int32): Int32
@FastNative
foreign func igTableSetupColumn(label: CString, flags: Int32, init_width_or_weight: Float32, user_data: UInt32): Unit
@FastNative
foreign func igTableSetupScrollFreeze(cols: Int32, rows: Int32): Unit
@FastNative
foreign func igTableHeader(label: CString): Unit
@FastNative
foreign func igTableHeadersRow(): Unit
@FastNative
foreign func igTableAngledHeadersRow(): Unit
@FastNative
foreign func igTableGetSortSpecs(): CPointer<Unit>
@FastNative
foreign func igTableGetColumnCount(): Int32
@FastNative
foreign func igTableGetColumnIndex(): Int32
@FastNative
foreign func igTableGetRowIndex(): Int32
@FastNative
foreign func igTableGetColumnName_Int(column_n: Int32): CString
@FastNative
foreign func igTableGetColumnFlags(column_n: Int32): Int32
@FastNative
foreign func igTableSetColumnEnabled(column_n: Int32, v: Int32): Unit
@FastNative
foreign func igTableGetHoveredColumn(): Int32
@FastNative
foreign func igTableSetBgColor(target: Int32, color: UInt32, column_n: Int32): Unit
@FastNative
foreign func igColumns(count: Int32, id: CString, borders: Int32): Unit
@FastNative
foreign func igNextColumn(): Unit
@FastNative
foreign func igGetColumnIndex(): Int32
@FastNative
foreign func igGetColumnWidth(column_index: Int32): Float32
@FastNative
foreign func igSetColumnWidth(column_index: Int32, width: Float32): Unit
@FastNative
foreign func igGetColumnOffset(column_index: Int32): Float32
@FastNative
foreign func igSetColumnOffset(column_index: Int32, offset_x: Float32): Unit
@FastNative
foreign func igGetColumnsCount(): Int32
@FastNative
foreign func igBeginTabBar(str_id: CString, flags: Int32): Int32
@FastNative
foreign func igEndTabBar(): Unit
@FastNative
foreign func igBeginTabItem(label: CString, p_open: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igEndTabItem(): Unit
@FastNative
foreign func igTabItemButton(label: CString, flags: Int32): Int32
@FastNative
foreign func igSetTabItemClosed(tab_or_docked_window_label: CString): Unit
@FastNative
foreign func igLogToTTY(auto_open_depth: Int32): Unit
@FastNative
foreign func igLogToFile(auto_open_depth: Int32, filename: CString): Unit
@FastNative
foreign func igLogToClipboard(auto_open_depth: Int32): Unit
@FastNative
foreign func igLogFinish(): Unit
@FastNative
foreign func igLogButtons(): Unit
@FastNative
foreign func igLogText0(fmt: CString): Unit
@FastNative
foreign func igBeginDragDropSource(flags: Int32): Int32
@FastNative
foreign func igSetDragDropPayload(`type`: CString, data: CPointer<Unit>, sz: UIntNative, cond: Int32): Int32
@FastNative
foreign func igEndDragDropSource(): Unit
@FastNative
foreign func igBeginDragDropTarget(): Int32
@FastNative
foreign func igAcceptDragDropPayload(`type`: CString, flags: Int32): CPointer<Unit>
@FastNative
foreign func igEndDragDropTarget(): Unit
@FastNative
foreign func igGetDragDropPayload(): CPointer<Unit>
@FastNative
foreign func igBeginDisabled(disabled: Int32): Unit
@FastNative
foreign func igEndDisabled(): Unit
@FastNative
foreign func igPushClipRect(clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: Int32): Unit
@FastNative
foreign func igPopClipRect(): Unit
@FastNative
foreign func igSetItemDefaultFocus(): Unit
@FastNative
foreign func igSetKeyboardFocusHere(offset: Int32): Unit
@FastNative
foreign func igSetNavCursorVisible(visible: Int32): Unit
@FastNative
foreign func igSetNextItemAllowOverlap(): Unit
@FastNative
foreign func igIsItemHovered(flags: Int32): Int32
@FastNative
foreign func igIsItemActive(): Int32
@FastNative
foreign func igIsItemFocused(): Int32
@FastNative
foreign func igIsItemClicked(mouse_button: Int32): Int32
@FastNative
foreign func igIsItemVisible(): Int32
@FastNative
foreign func igIsItemEdited(): Int32
@FastNative
foreign func igIsItemActivated(): Int32
@FastNative
foreign func igIsItemDeactivated(): Int32
@FastNative
foreign func igIsItemDeactivatedAfterEdit(): Int32
@FastNative
foreign func igIsItemToggledOpen(): Int32
@FastNative
foreign func igIsAnyItemHovered(): Int32
@FastNative
foreign func igIsAnyItemActive(): Int32
@FastNative
foreign func igIsAnyItemFocused(): Int32
@FastNative
foreign func igGetItemID(): UInt32
@FastNative
foreign func igGetItemRectMin(): ImVec2
@FastNative
foreign func igGetItemRectMax(): ImVec2
@FastNative
foreign func igGetItemRectSize(): ImVec2
@FastNative
foreign func igGetItemFlags(): Int32
@FastNative
foreign func igGetItemClickedCountWithSingleClickDelay(mouse_button: Int32, delay: Float32): Int32
@FastNative
foreign func igGetMainViewport(): CPointer<Unit>
@FastNative
foreign func igGetBackgroundDrawList_Nil(): CPointer<Unit>
@FastNative
foreign func igGetForegroundDrawList_Nil(): CPointer<Unit>
@FastNative
foreign func igIsRectVisible_Nil(size: ImVec2): Int32
@FastNative
foreign func igIsRectVisible_Vec2(rect_min: ImVec2, rect_max: ImVec2): Int32
@FastNative
foreign func igGetTime(): Float64
@FastNative
foreign func igGetFrameCount(): Int32
@FastNative
foreign func igGetDrawListSharedData(): CPointer<Unit>
@FastNative
foreign func igGetStyleColorName(idx: Int32): CString
@FastNative
foreign func igSetStateStorage(storage: CPointer<Unit>): Unit
@FastNative
foreign func igGetStateStorage(): CPointer<Unit>
@FastNative
foreign func igCalcTextSize(text: CString, text_end: CString, hide_text_after_double_hash: Int32, wrap_width: Float32): ImVec2
@FastNative
foreign func igColorConvertU32ToFloat4(`in`: UInt32): ImVec4
@FastNative
foreign func igColorConvertFloat4ToU32(`in`: ImVec4): UInt32
@FastNative
foreign func igColorConvertRGBtoHSV(r: Float32, g: Float32, b: Float32, out_h: CPointer<Float32>, out_s: CPointer<Float32>, out_v: CPointer<Float32>): Unit
@FastNative
foreign func igColorConvertHSVtoRGB(h: Float32, s: Float32, v: Float32, out_r: CPointer<Float32>, out_g: CPointer<Float32>, out_b: CPointer<Float32>): Unit
@FastNative
foreign func igIsKeyDown_Nil(key: Int32): Int32
@FastNative
foreign func igIsKeyPressed_Bool(key: Int32, repeat: Int32): Int32
@FastNative
foreign func igIsKeyReleased_Nil(key: Int32): Int32
@FastNative
foreign func igIsKeyChordPressed_Nil(key_chord: Int32): Int32
@FastNative
foreign func igGetKeyPressedAmount(key: Int32, repeat_delay: Float32, rate: Float32): Int32
@FastNative
foreign func igGetKeyName(key: Int32): CString
@FastNative
foreign func igSetNextFrameWantCaptureKeyboard(want_capture_keyboard: Int32): Unit
@FastNative
foreign func igShortcut_Nil(key_chord: Int32, flags: Int32): Int32
@FastNative
foreign func igSetNextItemShortcut(key_chord: Int32, flags: Int32): Unit
@FastNative
foreign func igSetItemKeyOwner_Nil(key: Int32): Int32
@FastNative
foreign func igIsMouseDown_Nil(button: Int32): Int32
@FastNative
foreign func igIsMouseClicked_Bool(button: Int32, repeat: Int32): Int32
@FastNative
foreign func igIsMouseReleased_Nil(button: Int32): Int32
@FastNative
foreign func igIsMouseDoubleClicked_Nil(button: Int32): Int32
@FastNative
foreign func igIsMouseReleasedWithDelay(button: Int32, delay: Float32): Int32
@FastNative
foreign func igGetMouseClickedCount(button: Int32): Int32
@FastNative
foreign func igIsMouseHoveringRect(r_min: ImVec2, r_max: ImVec2, clip: Int32): Int32
@FastNative
foreign func igIsMousePosValid(mouse_pos: CPointer<ImVec2>): Int32
@FastNative
foreign func igIsAnyMouseDown(): Int32
@FastNative
foreign func igGetMousePos(): ImVec2
@FastNative
foreign func igGetMousePosOnOpeningCurrentPopup(): ImVec2
@FastNative
foreign func igIsMouseDragging(button: Int32, lock_threshold: Float32): Int32
@FastNative
foreign func igGetMouseDragDelta(button: Int32, lock_threshold: Float32): ImVec2
@FastNative
foreign func igResetMouseDragDelta(button: Int32): Unit
@FastNative
foreign func igGetMouseCursor(): Int32
@FastNative
foreign func igSetMouseCursor(cursor_type: Int32): Unit
@FastNative
foreign func igSetNextFrameWantCaptureMouse(want_capture_mouse: Int32): Unit
@FastNative
foreign func igGetClipboardText(): CString
@FastNative
foreign func igSetClipboardText(text: CString): Unit
foreign func igLoadIniSettingsFromDisk(ini_filename: CString): Unit
@FastNative
foreign func igLoadIniSettingsFromMemory(ini_data: CString, ini_size: UIntNative): Unit
foreign func igSaveIniSettingsToDisk(ini_filename: CString): Unit
@FastNative
foreign func igSaveIniSettingsToMemory(out_ini_size: CPointer<UIntNative>): CString
@FastNative
foreign func igDebugTextEncoding(text: CString): Unit
@FastNative
foreign func igDebugFlashStyleColor(idx: Int32): Unit
@FastNative
foreign func igDebugStartItemPicker(): Unit
@FastNative
foreign func igDebugCheckVersionAndDataLayout(version_str: CString, sz_io: UIntNative, sz_style: UIntNative, sz_vec2: UIntNative, sz_vec4: UIntNative, sz_drawvert: UIntNative, sz_drawidx: UIntNative): Int32
@FastNative
foreign func igDebugLog0(fmt: CString): Unit
@FastNative
foreign func igSetAllocatorFunctions(alloc_func: CPointer<Unit>, free_func: CPointer<Unit>, user_data: CPointer<Unit>): Unit
@FastNative
foreign func igGetAllocatorFunctions(p_alloc_func: CPointer<Unit>, p_free_func: CPointer<Unit>, p_user_data: CPointer<Unit>): Unit
@FastNative
foreign func igMemAlloc(size: UIntNative): CPointer<Unit>
@FastNative
foreign func igMemFree(ptr: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableSortSpecs_ImGuiTableSortSpecs(): CPointer<Unit>
@FastNative
foreign func ImGuiTableSortSpecs_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableColumnSortSpecs_ImGuiTableColumnSortSpecs(): CPointer<Unit>
@FastNative
foreign func ImGuiTableColumnSortSpecs_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStyle_ImGuiStyle(): CPointer<Unit>
@FastNative
foreign func ImGuiStyle_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStyle_ScaleAllSizes(self: CPointer<Unit>, scale_factor: Float32): Unit
@FastNative
foreign func ImGuiIO_AddKeyEvent(self: CPointer<Unit>, key: Int32, down: Int32): Unit
@FastNative
foreign func ImGuiIO_AddKeyAnalogEvent(self: CPointer<Unit>, key: Int32, down: Int32, v: Float32): Unit
@FastNative
foreign func ImGuiIO_AddMousePosEvent(self: CPointer<Unit>, x: Float32, y: Float32): Unit
@FastNative
foreign func ImGuiIO_AddMouseButtonEvent(self: CPointer<Unit>, button: Int32, down: Int32): Unit
@FastNative
foreign func ImGuiIO_AddMouseWheelEvent(self: CPointer<Unit>, wheel_x: Float32, wheel_y: Float32): Unit
@FastNative
foreign func ImGuiIO_AddMouseSourceEvent(self: CPointer<Unit>, source: Int32): Unit
@FastNative
foreign func ImGuiIO_AddFocusEvent(self: CPointer<Unit>, focused: Int32): Unit
@FastNative
foreign func ImGuiIO_AddInputCharacter(self: CPointer<Unit>, c: UInt32): Unit
@FastNative
foreign func ImGuiIO_AddInputCharacterUTF16(self: CPointer<Unit>, c: UInt16): Unit
@FastNative
foreign func ImGuiIO_AddInputCharactersUTF8(self: CPointer<Unit>, str: CString): Unit
@FastNative
foreign func ImGuiIO_SetKeyEventNativeData(self: CPointer<Unit>, key: Int32, native_keycode: Int32, native_scancode: Int32, native_legacy_index: Int32): Unit
@FastNative
foreign func ImGuiIO_SetAppAcceptingEvents(self: CPointer<Unit>, accepting_events: Int32): Unit
@FastNative
foreign func ImGuiIO_ClearEventsQueue(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIO_ClearInputKeys(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIO_ClearInputMouse(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIO_ImGuiIO(): CPointer<Unit>
@FastNative
foreign func ImGuiIO_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_ImGuiInputTextCallbackData(): CPointer<Unit>
@FastNative
foreign func ImGuiInputTextCallbackData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_DeleteChars(self: CPointer<Unit>, pos: Int32, bytes_count: Int32): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_InsertChars(self: CPointer<Unit>, pos: Int32, text: CString, text_end: CString): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_SelectAll(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_SetSelection(self: CPointer<Unit>, s: Int32, e: Int32): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_ClearSelection(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextCallbackData_HasSelection(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiPayload_ImGuiPayload(): CPointer<Unit>
@FastNative
foreign func ImGuiPayload_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPayload_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPayload_IsDataType(self: CPointer<Unit>, `type`: CString): Int32
@FastNative
foreign func ImGuiPayload_IsPreview(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiPayload_IsDelivery(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiOnceUponAFrame_ImGuiOnceUponAFrame(): CPointer<Unit>
@FastNative
foreign func ImGuiOnceUponAFrame_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextFilter_ImGuiTextFilter(default_filter: CString): CPointer<Unit>
@FastNative
foreign func ImGuiTextFilter_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextFilter_Draw(self: CPointer<Unit>, label: CString, width: Float32): Int32
@FastNative
foreign func ImGuiTextFilter_PassFilter(self: CPointer<Unit>, text: CString, text_end: CString): Int32
@FastNative
foreign func ImGuiTextFilter_Build(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextFilter_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextFilter_IsActive(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiTextRange_ImGuiTextRange_Nil(): CPointer<Unit>
@FastNative
foreign func ImGuiTextRange_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextRange_ImGuiTextRange_Str(_b: CString, _e: CString): CPointer<Unit>
@FastNative
foreign func ImGuiTextRange_empty(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiTextRange_split(self: CPointer<Unit>, separator: Int8, `out`: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextBuffer_ImGuiTextBuffer(): CPointer<Unit>
@FastNative
foreign func ImGuiTextBuffer_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextBuffer_begin(self: CPointer<Unit>): CString
@FastNative
foreign func ImGuiTextBuffer_end(self: CPointer<Unit>): CString
@FastNative
foreign func ImGuiTextBuffer_size(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiTextBuffer_empty(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiTextBuffer_clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextBuffer_resize(self: CPointer<Unit>, size: Int32): Unit
@FastNative
foreign func ImGuiTextBuffer_reserve(self: CPointer<Unit>, capacity: Int32): Unit
@FastNative
foreign func ImGuiTextBuffer_c_str(self: CPointer<Unit>): CString
@FastNative
foreign func ImGuiTextBuffer_append(self: CPointer<Unit>, str: CString, str_end: CString): Unit
@FastNative
foreign func ImGuiStoragePair_ImGuiStoragePair_Int(_key: UInt32, _val: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiStoragePair_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStoragePair_ImGuiStoragePair_Float(_key: UInt32, _val: Float32): CPointer<Unit>
@FastNative
foreign func ImGuiStoragePair_ImGuiStoragePair_Ptr(_key: UInt32, _val: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiStorage_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStorage_GetInt(self: CPointer<Unit>, key: UInt32, default_val: Int32): Int32
@FastNative
foreign func ImGuiStorage_SetInt(self: CPointer<Unit>, key: UInt32, val: Int32): Unit
@FastNative
foreign func ImGuiStorage_GetBool(self: CPointer<Unit>, key: UInt32, default_val: Int32): Int32
@FastNative
foreign func ImGuiStorage_SetBool(self: CPointer<Unit>, key: UInt32, val: Int32): Unit
@FastNative
foreign func ImGuiStorage_GetFloat(self: CPointer<Unit>, key: UInt32, default_val: Float32): Float32
@FastNative
foreign func ImGuiStorage_SetFloat(self: CPointer<Unit>, key: UInt32, val: Float32): Unit
@FastNative
foreign func ImGuiStorage_GetVoidPtr(self: CPointer<Unit>, key: UInt32): CPointer<Unit>
@FastNative
foreign func ImGuiStorage_SetVoidPtr(self: CPointer<Unit>, key: UInt32, val: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStorage_GetIntRef(self: CPointer<Unit>, key: UInt32, default_val: Int32): CPointer<Int32>
@FastNative
foreign func ImGuiStorage_GetBoolRef(self: CPointer<Unit>, key: UInt32, default_val: Int32): CPointer<Int32>
@FastNative
foreign func ImGuiStorage_GetFloatRef(self: CPointer<Unit>, key: UInt32, default_val: Float32): CPointer<Float32>
@FastNative
foreign func ImGuiStorage_GetVoidPtrRef(self: CPointer<Unit>, key: UInt32, default_val: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiStorage_BuildSortByKey(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStorage_SetAllInt(self: CPointer<Unit>, val: Int32): Unit
@FastNative
foreign func ImGuiListClipper_ImGuiListClipper(): CPointer<Unit>
@FastNative
foreign func ImGuiListClipper_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiListClipper_Begin(self: CPointer<Unit>, items_count: Int32, items_height: Float32): Unit
@FastNative
foreign func ImGuiListClipper_End(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiListClipper_Step(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiListClipper_IncludeItemByIndex(self: CPointer<Unit>, item_index: Int32): Unit
@FastNative
foreign func ImGuiListClipper_IncludeItemsByIndex(self: CPointer<Unit>, item_begin: Int32, item_end: Int32): Unit
@FastNative
foreign func ImGuiListClipper_SeekCursorForItem(self: CPointer<Unit>, item_index: Int32): Unit
@FastNative
foreign func ImColor_ImColor_Nil(): CPointer<Unit>
@FastNative
foreign func ImColor_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImColor_ImColor_Float(r: Float32, g: Float32, b: Float32, a: Float32): CPointer<Unit>
@FastNative
foreign func ImColor_ImColor_Vec4(col: ImVec4): CPointer<Unit>
@FastNative
foreign func ImColor_ImColor_Int(r: Int32, g: Int32, b: Int32, a: Int32): CPointer<Unit>
@FastNative
foreign func ImColor_ImColor_U32(rgba: UInt32): CPointer<Unit>
@FastNative
foreign func ImColor_SetHSV(self: CPointer<Unit>, h: Float32, s: Float32, v: Float32, a: Float32): Unit
@FastNative
foreign func ImColor_HSV(h: Float32, s: Float32, v: Float32, a: Float32): CPointer<Unit>
@FastNative
foreign func ImGuiSelectionBasicStorage_ImGuiSelectionBasicStorage(): CPointer<Unit>
@FastNative
foreign func ImGuiSelectionBasicStorage_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiSelectionBasicStorage_ApplyRequests(self: CPointer<Unit>, ms_io: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiSelectionBasicStorage_Contains(self: CPointer<Unit>, id: UInt32): Int32
@FastNative
foreign func ImGuiSelectionBasicStorage_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiSelectionBasicStorage_Swap(self: CPointer<Unit>, r: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiSelectionBasicStorage_SetItemSelected(self: CPointer<Unit>, id: UInt32, selected: Int32): Unit
@FastNative
foreign func ImGuiSelectionBasicStorage_GetNextSelectedItem(self: CPointer<Unit>, opaque_it: CPointer<Unit>, out_id: CPointer<UInt32>): Int32
@FastNative
foreign func ImGuiSelectionBasicStorage_GetStorageIdFromIndex(self: CPointer<Unit>, idx: Int32): UInt32
@FastNative
foreign func ImGuiSelectionExternalStorage_ImGuiSelectionExternalStorage(): CPointer<Unit>
@FastNative
foreign func ImGuiSelectionExternalStorage_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiSelectionExternalStorage_ApplyRequests(self: CPointer<Unit>, ms_io: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawCmd_ImDrawCmd(): CPointer<Unit>
@FastNative
foreign func ImDrawCmd_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawCmd_GetTexID(self: CPointer<Unit>): UInt64
@FastNative
foreign func ImDrawListSplitter_ImDrawListSplitter(): CPointer<Unit>
@FastNative
foreign func ImDrawListSplitter_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawListSplitter_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawListSplitter_ClearFreeMemory(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawListSplitter_Split(self: CPointer<Unit>, draw_list: CPointer<Unit>, count: Int32): Unit
@FastNative
foreign func ImDrawListSplitter_Merge(self: CPointer<Unit>, draw_list: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawListSplitter_SetCurrentChannel(self: CPointer<Unit>, draw_list: CPointer<Unit>, channel_idx: Int32): Unit
@FastNative
foreign func ImDrawList_ImDrawList(shared_data: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImDrawList_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_PushClipRect(self: CPointer<Unit>, clip_rect_min: ImVec2, clip_rect_max: ImVec2, intersect_with_current_clip_rect: Int32): Unit
@FastNative
foreign func ImDrawList_PushClipRectFullScreen(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_PopClipRect(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_PushTexture(self: CPointer<Unit>, tex_ref: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_PopTexture(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_GetClipRectMin(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImDrawList_GetClipRectMax(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImDrawList_AddLine(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, col: UInt32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddLineH(self: CPointer<Unit>, min_x: Float32, max_x: Float32, y: Float32, col: UInt32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddLineV(self: CPointer<Unit>, x: Float32, min_y: Float32, max_y: Float32, col: UInt32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddRect(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col: UInt32, rounding: Float32, thickness: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_AddRectFilled(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col: UInt32, rounding: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_AddRectFilledMultiColor(self: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, col_upr_left: UInt32, col_upr_right: UInt32, col_bot_right: UInt32, col_bot_left: UInt32): Unit
@FastNative
foreign func ImDrawList_AddQuad(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddQuadFilled(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddTriangle(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddTriangleFilled(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddCircle(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddCircleFilled(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_AddNgon(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddNgonFilled(self: CPointer<Unit>, center: ImVec2, radius: Float32, col: UInt32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_AddEllipse(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, col: UInt32, rot: Float32, num_segments: Int32, thickness: Float32): Unit
@FastNative
foreign func ImDrawList_AddEllipseFilled(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, col: UInt32, rot: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_AddText_Vec2(self: CPointer<Unit>, pos: ImVec2, col: UInt32, text_begin: CString, text_end: CString): Unit
@FastNative
foreign func ImDrawList_AddText_FontPtr(self: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, pos: ImVec2, col: UInt32, text_begin: CString, text_end: CString, wrap_width: Float32, cpu_fine_clip_rect: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_AddBezierCubic(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, col: UInt32, thickness: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_AddBezierQuadratic(self: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, col: UInt32, thickness: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_AddPolyline(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32, thickness: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_AddConvexPolyFilled(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddConcavePolyFilled(self: CPointer<Unit>, points: CPointer<ImVec2>, num_points: Int32, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddImage(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddImageQuad(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, uv1: ImVec2, uv2: ImVec2, uv3: ImVec2, uv4: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_AddImageRounded(self: CPointer<Unit>, tex_ref: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, uv_min: ImVec2, uv_max: ImVec2, col: UInt32, rounding: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_PathClear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_PathLineTo(self: CPointer<Unit>, pos: ImVec2): Unit
@FastNative
foreign func ImDrawList_PathLineToMergeDuplicate(self: CPointer<Unit>, pos: ImVec2): Unit
@FastNative
foreign func ImDrawList_PathFillConvex(self: CPointer<Unit>, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PathFillConcave(self: CPointer<Unit>, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PathStroke(self: CPointer<Unit>, col: UInt32, thickness: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_PathArcTo(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_PathArcToFast(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min_of_12: Int32, a_max_of_12: Int32): Unit
@FastNative
foreign func ImDrawList_PathEllipticalArcTo(self: CPointer<Unit>, center: ImVec2, radius: ImVec2, rot: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_PathBezierCubicCurveTo(self: CPointer<Unit>, p2: ImVec2, p3: ImVec2, p4: ImVec2, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_PathBezierQuadraticCurveTo(self: CPointer<Unit>, p2: ImVec2, p3: ImVec2, num_segments: Int32): Unit
@FastNative
foreign func ImDrawList_PathRect(self: CPointer<Unit>, rect_min: ImVec2, rect_max: ImVec2, rounding: Float32, flags: Int32): Unit
@FastNative
foreign func ImDrawList_AddCallback(self: CPointer<Unit>, callback: CPointer<Unit>, userdata: CPointer<Unit>, userdata_size: UIntNative): Unit
@FastNative
foreign func ImDrawList_AddDrawCmd(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_CloneOutput(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImDrawList_ChannelsSplit(self: CPointer<Unit>, count: Int32): Unit
@FastNative
foreign func ImDrawList_ChannelsMerge(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList_ChannelsSetCurrent(self: CPointer<Unit>, n: Int32): Unit
@FastNative
foreign func ImDrawList_PrimReserve(self: CPointer<Unit>, idx_count: Int32, vtx_count: Int32): Unit
@FastNative
foreign func ImDrawList_PrimUnreserve(self: CPointer<Unit>, idx_count: Int32, vtx_count: Int32): Unit
@FastNative
foreign func ImDrawList_PrimRect(self: CPointer<Unit>, a: ImVec2, b: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PrimRectUV(self: CPointer<Unit>, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PrimQuadUV(self: CPointer<Unit>, a: ImVec2, b: ImVec2, c: ImVec2, d: ImVec2, uv_a: ImVec2, uv_b: ImVec2, uv_c: ImVec2, uv_d: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PrimWriteVtx(self: CPointer<Unit>, pos: ImVec2, uv: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList_PrimWriteIdx(self: CPointer<Unit>, idx: UInt16): Unit
@FastNative
foreign func ImDrawList_PrimVtx(self: CPointer<Unit>, pos: ImVec2, uv: ImVec2, col: UInt32): Unit
@FastNative
foreign func ImDrawList__SetDrawListSharedData(self: CPointer<Unit>, data: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__ResetForNewFrame(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__ClearFreeMemory(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__PopUnusedDrawCmd(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__TryMergeDrawCmds(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__OnChangedClipRect(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__OnChangedTexture(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__OnChangedVtxOffset(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__SetTexture(self: CPointer<Unit>, tex_ref: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawList__CalcCircleAutoSegmentCount(self: CPointer<Unit>, radius: Float32): Int32
@FastNative
foreign func ImDrawList__PathArcToFastEx(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min_sample: Int32, a_max_sample: Int32, a_step: Int32): Unit
@FastNative
foreign func ImDrawList__PathArcToN(self: CPointer<Unit>, center: ImVec2, radius: Float32, a_min: Float32, a_max: Float32, num_segments: Int32): Unit
@FastNative
foreign func ImDrawData_ImDrawData(): CPointer<Unit>
@FastNative
foreign func ImDrawData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawData_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawData_AddDrawList(self: CPointer<Unit>, draw_list: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawData_DeIndexAllBuffers(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawData_ScaleClipRects(self: CPointer<Unit>, fb_scale: ImVec2): Unit
@FastNative
foreign func ImTextureData_ImTextureData(): CPointer<Unit>
@FastNative
foreign func ImTextureData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImTextureData_Create(self: CPointer<Unit>, format: Int32, w: Int32, h: Int32): Unit
@FastNative
foreign func ImTextureData_DestroyPixels(self: CPointer<Unit>): Unit
@FastNative
foreign func ImTextureData_GetPixels(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImTextureData_GetPixelsAt(self: CPointer<Unit>, x: Int32, y: Int32): CPointer<Unit>
@FastNative
foreign func ImTextureData_GetSizeInBytes(self: CPointer<Unit>): Int32
@FastNative
foreign func ImTextureData_GetPitch(self: CPointer<Unit>): Int32
@FastNative
foreign func ImTextureData_GetTexRef(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImTextureData_GetTexID(self: CPointer<Unit>): UInt64
@FastNative
foreign func ImTextureData_SetTexID(self: CPointer<Unit>, tex_id: UInt64): Unit
@FastNative
foreign func ImTextureData_SetStatus(self: CPointer<Unit>, status: Int32): Unit
@FastNative
foreign func ImFontConfig_ImFontConfig(): CPointer<Unit>
@FastNative
foreign func ImFontConfig_destroy(self: CPointer<Unit>): Unit

// ---- ImFontConfig 字段访问器（three.cj 补齐：cimgui 生成器未覆盖的字段级 C API）----
@FastNative
foreign func ImFontConfig_Set_MergeMode(self: CPointer<Unit>, merge_mode: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_MergeMode(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontConfig_Set_PixelSnapH(self: CPointer<Unit>, pixel_snap_h: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_PixelSnapH(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontConfig_Set_OversampleH(self: CPointer<Unit>, oversample_h: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_OversampleH(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontConfig_Set_OversampleV(self: CPointer<Unit>, oversample_v: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_OversampleV(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontConfig_Set_EllipsisChar(self: CPointer<Unit>, ellipsis_char: UInt32): Unit
@FastNative
foreign func ImFontConfig_Get_EllipsisChar(self: CPointer<Unit>): UInt32
@FastNative
foreign func ImFontConfig_Set_SizePixels(self: CPointer<Unit>, size_pixels: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_SizePixels(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_GlyphRanges(self: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): Unit
@FastNative
foreign func ImFontConfig_Get_GlyphRanges(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontConfig_Set_GlyphOffset(self: CPointer<Unit>, glyph_offset: ImVec2): Unit
@FastNative
foreign func ImFontConfig_Get_GlyphOffset(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImFontConfig_Set_GlyphMinAdvanceX(self: CPointer<Unit>, glyph_min_advance_x: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_GlyphMinAdvanceX(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_GlyphMaxAdvanceX(self: CPointer<Unit>, glyph_max_advance_x: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_GlyphMaxAdvanceX(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_GlyphExtraAdvanceX(self: CPointer<Unit>, glyph_extra_advance_x: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_GlyphExtraAdvanceX(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_FontNo(self: CPointer<Unit>, font_no: UInt32): Unit
@FastNative
foreign func ImFontConfig_Get_FontNo(self: CPointer<Unit>): UInt32
@FastNative
foreign func ImFontConfig_Set_RasterizerMultiply(self: CPointer<Unit>, rasterizer_multiply: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_RasterizerMultiply(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_RasterizerDensity(self: CPointer<Unit>, rasterizer_density: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_RasterizerDensity(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_ExtraSizeScale(self: CPointer<Unit>, extra_size_scale: Float32): Unit
@FastNative
foreign func ImFontConfig_Get_ExtraSizeScale(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontConfig_Set_FontData(self: CPointer<Unit>, font_data: CPointer<Unit>): Unit
@FastNative
foreign func ImFontConfig_Get_FontData(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImFontConfig_Set_FontDataSize(self: CPointer<Unit>, font_data_size: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_FontDataSize(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontConfig_Set_FontDataOwnedByAtlas(self: CPointer<Unit>, font_data_owned_by_atlas: Int32): Unit
@FastNative
foreign func ImFontConfig_Get_FontDataOwnedByAtlas(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontGlyph_ImFontGlyph(): CPointer<Unit>
@FastNative
foreign func ImFontGlyph_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder(): CPointer<Unit>
@FastNative
foreign func ImFontGlyphRangesBuilder_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_GetBit(self: CPointer<Unit>, n: UIntNative): Int32
@FastNative
foreign func ImFontGlyphRangesBuilder_SetBit(self: CPointer<Unit>, n: UIntNative): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_AddChar(self: CPointer<Unit>, c: UInt16): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_AddText(self: CPointer<Unit>, text: CString, text_end: CString): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_AddRanges(self: CPointer<Unit>, ranges: CPointer<UInt16>): Unit
@FastNative
foreign func ImFontGlyphRangesBuilder_BuildRanges(self: CPointer<Unit>, out_ranges: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlasRect_ImFontAtlasRect(): CPointer<Unit>
@FastNative
foreign func ImFontAtlasRect_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_ImFontAtlas(): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_AddFont(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontDefault(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontDefaultVector(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontDefaultBitmap(self: CPointer<Unit>, font_cfg: CPointer<Unit>): CPointer<Unit>
foreign func ImFontAtlas_AddFontFromFileTTF(self: CPointer<Unit>, filename: CString, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontFromMemoryTTF(self: CPointer<Unit>, font_data: CPointer<Unit>, font_data_size: Int32, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontFromMemoryCompressedTTF(self: CPointer<Unit>, compressed_font_data: CPointer<Unit>, compressed_font_data_size: Int32, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: CPointer<Unit>, compressed_font_data_base85: CString, size_pixels: Float32, font_cfg: CPointer<Unit>, glyph_ranges: CPointer<UInt16>): CPointer<Unit>
@FastNative
foreign func ImFontAtlas_RemoveFont(self: CPointer<Unit>, font: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_CompactCache(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_SetFontLoader(self: CPointer<Unit>, font_loader: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_ClearFonts(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_ClearInputData(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_ClearTexData(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontAtlas_GetGlyphRangesDefault(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_AddCustomRect(self: CPointer<Unit>, width: Int32, height: Int32, out_r: CPointer<Unit>): Int32
@FastNative
foreign func ImFontAtlas_RemoveCustomRect(self: CPointer<Unit>, id: Int32): Unit
@FastNative
foreign func ImFontAtlas_GetCustomRect(self: CPointer<Unit>, id: Int32, out_r: CPointer<Unit>): Int32
@FastNative
foreign func ImFontBaked_ImFontBaked(): CPointer<Unit>
@FastNative
foreign func ImFontBaked_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontBaked_ClearOutputData(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFontBaked_FindGlyph(self: CPointer<Unit>, c: UInt16): CPointer<Unit>
@FastNative
foreign func ImFontBaked_FindGlyphNoFallback(self: CPointer<Unit>, c: UInt16): CPointer<Unit>
@FastNative
foreign func ImFontBaked_GetCharAdvance(self: CPointer<Unit>, c: UInt16): Float32
@FastNative
foreign func ImFontBaked_IsGlyphLoaded(self: CPointer<Unit>, c: UInt16): Int32
@FastNative
foreign func ImFont_ImFont(): CPointer<Unit>
@FastNative
foreign func ImFont_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFont_IsGlyphInFont(self: CPointer<Unit>, c: UInt16): Int32
@FastNative
foreign func ImFont_IsLoaded(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFont_GetDebugName(self: CPointer<Unit>): CString
@FastNative
foreign func ImFont_GetFontBaked(self: CPointer<Unit>, font_size: Float32, density: Float32): CPointer<Unit>
@FastNative
foreign func ImFont_CalcTextSizeA(self: CPointer<Unit>, size: Float32, max_width: Float32, wrap_width: Float32, text_begin: CString, text_end: CString, out_remaining: CPointer<CString>): ImVec2
@FastNative
foreign func ImFont_CalcWordWrapPosition(self: CPointer<Unit>, size: Float32, text: CString, text_end: CString, wrap_width: Float32): CString
@FastNative
foreign func ImFont_RenderChar(self: CPointer<Unit>, draw_list: CPointer<Unit>, size: Float32, pos: ImVec2, col: UInt32, c: UInt16, cpu_fine_clip: CPointer<Unit>): Unit
@FastNative
foreign func ImFont_RenderText(self: CPointer<Unit>, draw_list: CPointer<Unit>, size: Float32, pos: ImVec2, col: UInt32, clip_rect: ImVec4, text_begin: CString, text_end: CString, wrap_width: Float32, flags: Int32): Unit
@FastNative
foreign func ImFont_ClearOutputData(self: CPointer<Unit>): Unit
@FastNative
foreign func ImFont_AddRemapChar(self: CPointer<Unit>, from_codepoint: UInt16, to_codepoint: UInt16): Unit
@FastNative
foreign func ImFont_IsGlyphRangeUnused(self: CPointer<Unit>, c_begin: UInt32, c_last: UInt32): Int32

// ---- ImGuiIO 字段访问器（three.cj 补齐）----
@FastNative
foreign func ImGuiIO_Get_Fonts(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiIO_Set_Fonts(self: CPointer<Unit>, fonts: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIO_Get_FontDefault(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiIO_Set_FontDefault(self: CPointer<Unit>, font_default: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIO_Get_DisplaySize(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImGuiIO_Set_DisplaySize(self: CPointer<Unit>, display_size: ImVec2): Unit
@FastNative
foreign func ImGuiIO_Get_DisplayFramebufferScale(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImGuiIO_Set_DisplayFramebufferScale(self: CPointer<Unit>, display_framebuffer_scale: ImVec2): Unit
@FastNative
foreign func ImGuiIO_Get_DeltaTime(self: CPointer<Unit>): Float32
@FastNative
foreign func ImGuiIO_Set_DeltaTime(self: CPointer<Unit>, delta_time: Float32): Unit
@FastNative
foreign func ImGuiIO_Get_ConfigFlags(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiIO_Set_ConfigFlags(self: CPointer<Unit>, config_flags: Int32): Unit
@FastNative
foreign func ImGuiIO_Get_BackendFlags(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiIO_Set_BackendFlags(self: CPointer<Unit>, backend_flags: Int32): Unit

// ---- ImGuiStyle 字段访问器（three.cj 补齐）----
@FastNative
foreign func ImGuiStyle_Get_FontScaleMain(self: CPointer<Unit>): Float32
@FastNative
foreign func ImGuiStyle_Set_FontScaleMain(self: CPointer<Unit>, font_scale_main: Float32): Unit
@FastNative
foreign func ImGuiStyle_Get_FontSizeBase(self: CPointer<Unit>): Float32
@FastNative
foreign func ImGuiStyle_Set_FontSizeBase(self: CPointer<Unit>, font_size_base: Float32): Unit

// ---- ImFontAtlas 额外能力（three.cj 补齐）----
foreign func ImFontAtlas_GetTexDataAsRGBA32(self: CPointer<Unit>, out_pixels: CPointer<CPointer<UInt8>>, out_width: CPointer<Int32>, out_height: CPointer<Int32>, out_bytes_per_pixel: CPointer<Int32>): Unit
@FastNative
foreign func ImFontAtlas_IsBuilt(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontAtlas_Set_TexMinWidth(self: CPointer<Unit>, tex_min_width: Int32): Unit
@FastNative
foreign func ImFontAtlas_Get_TexMinWidth(self: CPointer<Unit>): Int32

// ---- 标准字形范围（three.cj 补齐）----
@FastNative
foreign func ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesChineseFull(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesJapanese(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesKorean(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesGreek(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesCyrillic(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesThai(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImFontAtlas_GetGlyphRangesVietnamese(self: CPointer<Unit>): CPointer<UInt16>

// ---- ImVector_ImWchar 字段访问器（three.cj 补齐）----
@FastNative
foreign func ImVector_ImWchar_Get_Data(self: CPointer<Unit>): CPointer<UInt16>
@FastNative
foreign func ImVector_ImWchar_Get_Size(self: CPointer<Unit>): Int32
@FastNative
foreign func ImVector_ImWchar_Get_Capacity(self: CPointer<Unit>): Int32

// ---- ImFontGlyph 字段访问器（three.cj 补齐）----
@FastNative
foreign func ImFontGlyph_Get_Codepoint(self: CPointer<Unit>): UInt32
@FastNative
foreign func ImFontGlyph_Get_Visible(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontGlyph_Get_Colored(self: CPointer<Unit>): Int32
@FastNative
foreign func ImFontGlyph_Get_AdvanceX(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_X0(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_Y0(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_X1(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_Y1(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_U0(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_V0(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_U1(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_V1(self: CPointer<Unit>): Float32
@FastNative
foreign func ImFontGlyph_Get_PackId(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiViewport_ImGuiViewport(): CPointer<Unit>
@FastNative
foreign func ImGuiViewport_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiViewport_GetCenter(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImGuiViewport_GetWorkCenter(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImGuiPlatformIO_ImGuiPlatformIO(): CPointer<Unit>
@FastNative
foreign func ImGuiPlatformIO_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPlatformIO_ClearPlatformHandlers(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPlatformIO_ClearRendererHandlers(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPlatformImeData_ImGuiPlatformImeData(): CPointer<Unit>
@FastNative
foreign func ImGuiPlatformImeData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func igImHashData(data: CPointer<Unit>, data_size: UIntNative, seed: UInt32): UInt32
@FastNative
foreign func igImHashStr(data: CString, data_size: UIntNative, seed: UInt32): UInt32
@FastNative
foreign func igImHashSkipUncontributingPrefix(label: CString): CString
@FastNative
foreign func igImAlphaBlendColors(col_a: UInt32, col_b: UInt32): UInt32
@FastNative
foreign func igImIsPowerOfTwo_Int(v: Int32): Int32
@FastNative
foreign func igImIsPowerOfTwo_U64(v: UInt64): Int32
@FastNative
foreign func igImUpperPowerOfTwo(v: Int32): Int32
@FastNative
foreign func igImCountSetBits(v: UInt32): UInt32
@FastNative
foreign func igImStricmp(str1: CString, str2: CString): Int32
@FastNative
foreign func igImStrnicmp(str1: CString, str2: CString, count: UIntNative): Int32
@FastNative
foreign func igImStrncpy(dst: CPointer<Int8>, src: CString, count: UIntNative): Unit
@FastNative
foreign func igImStrdup(str: CString): CPointer<Int8>
@FastNative
foreign func igImMemdup(src: CPointer<Unit>, size: UIntNative): CPointer<Unit>
@FastNative
foreign func igImStrdupcpy(dst: CPointer<Int8>, p_dst_size: CPointer<UIntNative>, str: CString): CPointer<Int8>
@FastNative
foreign func igImStrchrRange(str_begin: CString, str_end: CString, c: Int8): CString
@FastNative
foreign func igImStreolRange(str: CString, str_end: CString): CString
@FastNative
foreign func igImStristr(haystack: CString, haystack_end: CString, needle: CString, needle_end: CString): CString
@FastNative
foreign func igImStrTrimBlanks(str: CPointer<Int8>): Unit
@FastNative
foreign func igImStrSkipBlank(str: CString): CString
@FastNative
foreign func igImStrlenW(str: CPointer<UInt16>): Int32
@FastNative
foreign func igImStrbol(buf_mid_line: CString, buf_begin: CString): CString
@FastNative
foreign func igImToUpper(c: Int8): Int8
@FastNative
foreign func igImCharIsBlankA(c: Int8): Int32
@FastNative
foreign func igImCharIsBlankW(c: UInt32): Int32
@FastNative
foreign func igImCharIsXdigitA(c: Int8): Int32
@FastNative
foreign func igImFormatString0(buf: CPointer<Int8>, buf_size: UIntNative, fmt: CString): Int32
@FastNative
foreign func igImFormatStringToTempBuffer0(out_buf: CPointer<CString>, out_buf_end: CPointer<CString>, fmt: CString): Unit
@FastNative
foreign func igImParseFormatFindStart(format: CString): CString
@FastNative
foreign func igImParseFormatFindEnd(format: CString): CString
@FastNative
foreign func igImParseFormatTrimDecorations(format: CString, buf: CPointer<Int8>, buf_size: UIntNative): CString
@FastNative
foreign func igImParseFormatSanitizeForPrinting(fmt_in: CString, fmt_out: CPointer<Int8>, fmt_out_size: UIntNative): Unit
@FastNative
foreign func igImParseFormatSanitizeForScanning(fmt_in: CString, fmt_out: CPointer<Int8>, fmt_out_size: UIntNative): CString
@FastNative
foreign func igImParseFormatPrecision(format: CString, default_value: Int32): Int32
@FastNative
foreign func igImTextCharToUtf8(out_buf: CPointer<Int8>, c: UInt32): Int32
@FastNative
foreign func igImTextStrToUtf8(out_buf: CPointer<Int8>, out_buf_size: Int32, in_text: CPointer<UInt16>, in_text_end: CPointer<UInt16>): Int32
@FastNative
foreign func igImTextCharFromUtf8(out_char: CPointer<UInt32>, in_text: CString, in_text_end: CString): Int32
@FastNative
foreign func igImTextStrFromUtf8(out_buf: CPointer<UInt16>, out_buf_size: Int32, in_text: CString, in_text_end: CString, in_remaining: CPointer<CString>): Int32
@FastNative
foreign func igImTextCountCharsFromUtf8(in_text: CString, in_text_end: CString): Int32
@FastNative
foreign func igImTextCountUtf8BytesFromChar(in_text: CString, in_text_end: CString): Int32
@FastNative
foreign func igImTextCountUtf8BytesFromStr(in_text: CPointer<UInt16>, in_text_end: CPointer<UInt16>): Int32
@FastNative
foreign func igImTextFindPreviousUtf8Codepoint(in_text_start: CString, in_p: CString): CString
@FastNative
foreign func igImTextFindValidUtf8CodepointEnd(in_text_start: CString, in_text_end: CString, in_p: CString): CString
@FastNative
foreign func igImTextCountLines(in_text: CString, in_text_end: CString): Int32
@FastNative
foreign func igImFontCalcTextSizeEx(font: CPointer<Unit>, size: Float32, max_width: Float32, wrap_width: Float32, text_begin: CString, text_end_display: CString, text_end: CString, out_remaining: CPointer<CString>, out_offset: CPointer<ImVec2>, flags: Int32): ImVec2
@FastNative
foreign func igImFontCalcWordWrapPositionEx(font: CPointer<Unit>, size: Float32, text: CString, text_end: CString, wrap_width: Float32, flags: Int32): CString
@FastNative
foreign func igImTextCalcWordWrapNextLineStart(text: CString, text_end: CString, flags: Int32): CString
@FastNative
foreign func igImTextInitClassifiers(): Unit
@FastNative
foreign func igImTextClassifierClear(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32): Unit
@FastNative
foreign func igImTextClassifierSetCharClass(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32, c: UInt32): Unit
@FastNative
foreign func igImTextClassifierSetCharClassFromStr(bits: CPointer<UInt32>, codepoint_min: UInt32, codepoint_end: UInt32, char_class: Int32, s: CString): Unit
@FastNative
foreign func igImFileOpen(filename: CString, mode: CString): Int32
@FastNative
foreign func igImFileClose(file: Int32): Int32
@FastNative
foreign func igImFileGetSize(file: Int32): UInt64
@FastNative
foreign func igImFileRead(data: CPointer<Unit>, size: UInt64, count: UInt64, file: Int32): UInt64
@FastNative
foreign func igImFileWrite(data: CPointer<Unit>, size: UInt64, count: UInt64, file: Int32): UInt64
@FastNative
foreign func igImFileLoadToMemory(filename: CString, mode: CString, out_file_size: CPointer<UIntNative>, padding_bytes: Int32): CPointer<Unit>
@FastNative
foreign func igImPow_Float(x: Float32, y: Float32): Float32
@FastNative
foreign func igImPow_double(x: Float64, y: Float64): Float64
@FastNative
foreign func igImLog_Float(x: Float32): Float32
@FastNative
foreign func igImLog_double(x: Float64): Float64
@FastNative
foreign func igImAbs_Int(x: Int32): Int32
@FastNative
foreign func igImAbs_Float(x: Float32): Float32
@FastNative
foreign func igImAbs_double(x: Float64): Float64
@FastNative
foreign func igImSign_Float(x: Float32): Float32
@FastNative
foreign func igImSign_double(x: Float64): Float64
@FastNative
foreign func igImRsqrt_Float(x: Float32): Float32
@FastNative
foreign func igImRsqrt_double(x: Float64): Float64
@FastNative
foreign func igImMin(lhs: ImVec2, rhs: ImVec2): ImVec2
@FastNative
foreign func igImMax(lhs: ImVec2, rhs: ImVec2): ImVec2
@FastNative
foreign func igImClamp(v: ImVec2, mn: ImVec2, mx: ImVec2): ImVec2
@FastNative
foreign func igImLerp_Vec2Float(a: ImVec2, b: ImVec2, t: Float32): ImVec2
@FastNative
foreign func igImLerp_Vec2Vec2(a: ImVec2, b: ImVec2, t: ImVec2): ImVec2
@FastNative
foreign func igImLerp_Vec4(a: ImVec4, b: ImVec4, t: Float32): ImVec4
@FastNative
foreign func igImSaturate(f: Float32): Float32
@FastNative
foreign func igImLengthSqr_Vec2(lhs: ImVec2): Float32
@FastNative
foreign func igImLengthSqr_Vec4(lhs: ImVec4): Float32
@FastNative
foreign func igImInvLength(lhs: ImVec2, fail_value: Float32): Float32
@FastNative
foreign func igImTrunc_Float(f: Float32): Float32
@FastNative
foreign func igImTrunc_Vec2(v: ImVec2): ImVec2
@FastNative
foreign func igImFloor_Float(f: Float32): Float32
@FastNative
foreign func igImFloor_Vec2(v: ImVec2): ImVec2
@FastNative
foreign func igImTrunc64(f: Float32): Float32
@FastNative
foreign func igImRound64(f: Float32): Float32
@FastNative
foreign func igImCeilFast(f: Float32): Float32
@FastNative
foreign func igImModPositive(a: Int32, b: Int32): Int32
@FastNative
foreign func igImDot(a: ImVec2, b: ImVec2): Float32
@FastNative
foreign func igImRotate(v: ImVec2, cos_a: Float32, sin_a: Float32): ImVec2
@FastNative
foreign func igImLinearSweep(current: Float32, target: Float32, speed: Float32): Float32
@FastNative
foreign func igImLinearRemapClamp(s0: Float32, s1: Float32, d0: Float32, d1: Float32, x: Float32): Float32
@FastNative
foreign func igImMul(lhs: ImVec2, rhs: ImVec2): ImVec2
@FastNative
foreign func igImIsFloatAboveGuaranteedIntegerPrecision(f: Float32): Int32
@FastNative
foreign func igImExponentialMovingAverage(avg: Float32, sample: Float32, n: Int32): Float32
@FastNative
foreign func igImBezierCubicCalc(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, t: Float32): ImVec2
@FastNative
foreign func igImBezierCubicClosestPoint(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, num_segments: Int32): ImVec2
@FastNative
foreign func igImBezierCubicClosestPointCasteljau(p1: ImVec2, p2: ImVec2, p3: ImVec2, p4: ImVec2, p: ImVec2, tess_tol: Float32): ImVec2
@FastNative
foreign func igImBezierQuadraticCalc(p1: ImVec2, p2: ImVec2, p3: ImVec2, t: Float32): ImVec2
@FastNative
foreign func igImLineClosestPoint(a: ImVec2, b: ImVec2, p: ImVec2): ImVec2
@FastNative
foreign func igImTriangleContainsPoint(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2): Int32
@FastNative
foreign func igImTriangleClosestPoint(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2): ImVec2
@FastNative
foreign func igImTriangleBarycentricCoords(a: ImVec2, b: ImVec2, c: ImVec2, p: ImVec2, out_u: CPointer<Float32>, out_v: CPointer<Float32>, out_w: CPointer<Float32>): Unit
@FastNative
foreign func igImTriangleArea(a: ImVec2, b: ImVec2, c: ImVec2): Float32
@FastNative
foreign func igImTriangleIsClockwise(a: ImVec2, b: ImVec2, c: ImVec2): Int32
@FastNative
foreign func ImVec1_ImVec1_Nil(): CPointer<Unit>
@FastNative
foreign func ImVec1_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVec1_ImVec1_Float(_x: Float32): CPointer<Unit>
@FastNative
foreign func ImVec2i_ImVec2i_Nil(): CPointer<Unit>
@FastNative
foreign func ImVec2i_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVec2i_ImVec2i_Int(_x: Int32, _y: Int32): CPointer<Unit>
@FastNative
foreign func ImVec2ih_ImVec2ih_Nil(): CPointer<Unit>
@FastNative
foreign func ImVec2ih_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVec2ih_ImVec2ih_short(_x: Int16, _y: Int16): CPointer<Unit>
@FastNative
foreign func ImVec2ih_ImVec2ih_Vec2(rhs: ImVec2): CPointer<Unit>
@FastNative
foreign func ImRect_ImRect_Nil(): CPointer<Unit>
@FastNative
foreign func ImRect_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImRect_ImRect_Vec2(min: ImVec2, max: ImVec2): CPointer<Unit>
@FastNative
foreign func ImRect_ImRect_Vec4(v: ImVec4): CPointer<Unit>
@FastNative
foreign func ImRect_ImRect_Float(x1: Float32, y1: Float32, x2: Float32, y2: Float32): CPointer<Unit>
@FastNative
foreign func ImRect_GetCenter(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_GetSize(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_GetWidth(self: CPointer<Unit>): Float32
@FastNative
foreign func ImRect_GetHeight(self: CPointer<Unit>): Float32
@FastNative
foreign func ImRect_GetArea(self: CPointer<Unit>): Float32
@FastNative
foreign func ImRect_GetTL(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_GetTR(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_GetBL(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_GetBR(self: CPointer<Unit>): ImVec2
@FastNative
foreign func ImRect_Contains_Vec2(self: CPointer<Unit>, p: ImVec2): Int32
@FastNative
foreign func ImRect_Contains_Rect(self: CPointer<Unit>, r: CPointer<Unit>): Int32
@FastNative
foreign func ImRect_ContainsWithPad(self: CPointer<Unit>, p: ImVec2, pad: ImVec2): Int32
@FastNative
foreign func ImRect_Overlaps(self: CPointer<Unit>, r: CPointer<Unit>): Int32
@FastNative
foreign func ImRect_Add_Vec2(self: CPointer<Unit>, p: ImVec2): Unit
@FastNative
foreign func ImRect_Add_Rect(self: CPointer<Unit>, r: CPointer<Unit>): Unit
@FastNative
foreign func ImRect_AddX(self: CPointer<Unit>, x: Float32): Unit
@FastNative
foreign func ImRect_AddY(self: CPointer<Unit>, y: Float32): Unit
@FastNative
foreign func ImRect_Expand_Float(self: CPointer<Unit>, amount: Float32): Unit
@FastNative
foreign func ImRect_Expand_Vec2(self: CPointer<Unit>, amount: ImVec2): Unit
@FastNative
foreign func ImRect_Translate(self: CPointer<Unit>, d: ImVec2): Unit
@FastNative
foreign func ImRect_TranslateX(self: CPointer<Unit>, dx: Float32): Unit
@FastNative
foreign func ImRect_TranslateY(self: CPointer<Unit>, dy: Float32): Unit
@FastNative
foreign func ImRect_ClipWith(self: CPointer<Unit>, r: CPointer<Unit>): Unit
@FastNative
foreign func ImRect_ClipWithFull(self: CPointer<Unit>, r: CPointer<Unit>): Unit
@FastNative
foreign func ImRect_IsInverted(self: CPointer<Unit>): Int32
@FastNative
foreign func ImRect_ToVec4(self: CPointer<Unit>): ImVec4
@FastNative
foreign func ImRect_AsVec4(self: CPointer<Unit>): CPointer<ImVec4>
@FastNative
foreign func igImBitArrayGetStorageSizeInBytes(bitcount: Int32): UIntNative
@FastNative
foreign func igImBitArrayClearAllBits(arr: CPointer<UInt32>, bitcount: Int32): Unit
@FastNative
foreign func igImBitArrayTestBit(arr: CPointer<UInt32>, n: Int32): Int32
@FastNative
foreign func igImBitArrayClearBit(arr: CPointer<UInt32>, n: Int32): Unit
@FastNative
foreign func igImBitArraySetBit(arr: CPointer<UInt32>, n: Int32): Unit
@FastNative
foreign func igImBitArraySetBitRange(arr: CPointer<UInt32>, n: Int32, n2: Int32): Unit
@FastNative
foreign func ImBitVector_Create(self: CPointer<Unit>, sz: Int32): Unit
@FastNative
foreign func ImBitVector_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImBitVector_TestBit(self: CPointer<Unit>, n: Int32): Int32
@FastNative
foreign func ImBitVector_SetBit(self: CPointer<Unit>, n: Int32): Unit
@FastNative
foreign func ImBitVector_ClearBit(self: CPointer<Unit>, n: Int32): Unit
@FastNative
foreign func ImGuiTextIndex_clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTextIndex_size(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiTextIndex_get_line_begin(self: CPointer<Unit>, base: CString, n: Int32): CString
@FastNative
foreign func ImGuiTextIndex_get_line_end(self: CPointer<Unit>, base: CString, n: Int32): CString
@FastNative
foreign func ImGuiTextIndex_append(self: CPointer<Unit>, base: CString, old_size: Int32, new_size: Int32): Unit
@FastNative
foreign func ImGuiPackedDate_ImGuiPackedDate_Nil(): CPointer<Unit>
@FastNative
foreign func ImGuiPackedDate_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPackedDate_ImGuiPackedDate_Int(yyyymmdd: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiPackedDate_IsValid(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiPackedDate_Unpack(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiPackedDate_SubtractMonths(self: CPointer<Unit>, m: Int32): Unit
@FastNative
foreign func igImLowerBound(in_begin: CPointer<Unit>, in_end: CPointer<Unit>, key: UInt32): CPointer<Unit>
@FastNative
foreign func ImDrawListSharedData_ImDrawListSharedData(): CPointer<Unit>
@FastNative
foreign func ImDrawListSharedData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImDrawListSharedData_SetCircleTessellationMaxError(self: CPointer<Unit>, max_error: Float32): Unit
@FastNative
foreign func ImDrawDataBuilder_ImDrawDataBuilder(): CPointer<Unit>
@FastNative
foreign func ImDrawDataBuilder_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStyleVarInfo_GetVarPtr(self: CPointer<Unit>, parent: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiStyleMod_ImGuiStyleMod_Int(idx: Int32, v: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiStyleMod_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStyleMod_ImGuiStyleMod_Float(idx: Int32, v: Float32): CPointer<Unit>
@FastNative
foreign func ImGuiStyleMod_ImGuiStyleMod_Vec2(idx: Int32, v: ImVec2): CPointer<Unit>
@FastNative
foreign func ImGuiComboPreviewData_ImGuiComboPreviewData(): CPointer<Unit>
@FastNative
foreign func ImGuiComboPreviewData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMenuColumns_ImGuiMenuColumns(): CPointer<Unit>
@FastNative
foreign func ImGuiMenuColumns_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMenuColumns_Update(self: CPointer<Unit>, spacing: Float32, window_reappearing: Int32): Unit
@FastNative
foreign func ImGuiMenuColumns_DeclColumns(self: CPointer<Unit>, w_icon: Float32, w_label: Float32, w_shortcut: Float32, w_mark: Float32): Float32
@FastNative
foreign func ImGuiMenuColumns_CalcNextTotalWidth(self: CPointer<Unit>, update_offsets: Int32): Unit
@FastNative
foreign func ImGuiInputTextDeactivatedState_ImGuiInputTextDeactivatedState(): CPointer<Unit>
@FastNative
foreign func ImGuiInputTextDeactivatedState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextDeactivatedState_ClearFreeMemory(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ImGuiInputTextState(): CPointer<Unit>
@FastNative
foreign func ImGuiInputTextState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ClearText(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ClearFreeMemory(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_OnKeyPressed(self: CPointer<Unit>, key: Int32): Unit
@FastNative
foreign func ImGuiInputTextState_OnCharPressed(self: CPointer<Unit>, c: UInt32): Unit
@FastNative
foreign func ImGuiInputTextState_GetPreferredOffsetX(self: CPointer<Unit>): Float32
@FastNative
foreign func ImGuiInputTextState_GetText(self: CPointer<Unit>): CString
@FastNative
foreign func ImGuiInputTextState_CursorAnimReset(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_CursorClamp(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_HasSelection(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiInputTextState_ClearSelection(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_GetCursorPos(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiInputTextState_GetSelectionStart(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiInputTextState_GetSelectionEnd(self: CPointer<Unit>): Int32
@FastNative
foreign func ImGuiInputTextState_SetSelection(self: CPointer<Unit>, start: Int32, end: Int32): Unit
@FastNative
foreign func ImGuiInputTextState_SelectAll(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ReloadUserBufAndSelectAll(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ReloadUserBufAndKeepSelection(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputTextState_ReloadUserBufAndMoveToEnd(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNextWindowData_ImGuiNextWindowData(): CPointer<Unit>
@FastNative
foreign func ImGuiNextWindowData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNextWindowData_ClearFlags(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNextItemData_ImGuiNextItemData(): CPointer<Unit>
@FastNative
foreign func ImGuiNextItemData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNextItemData_ClearFlags(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiLastItemData_ImGuiLastItemData(): CPointer<Unit>
@FastNative
foreign func ImGuiLastItemData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiErrorRecoveryState_ImGuiErrorRecoveryState(): CPointer<Unit>
@FastNative
foreign func ImGuiErrorRecoveryState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPtrOrIndex_ImGuiPtrOrIndex_Ptr(ptr: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiPtrOrIndex_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiPtrOrIndex_ImGuiPtrOrIndex_Int(index: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiPopupData_ImGuiPopupData(): CPointer<Unit>
@FastNative
foreign func ImGuiPopupData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiInputEvent_ImGuiInputEvent(): CPointer<Unit>
@FastNative
foreign func ImGuiInputEvent_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiKeyRoutingData_ImGuiKeyRoutingData(): CPointer<Unit>
@FastNative
foreign func ImGuiKeyRoutingData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiKeyRoutingTable_ImGuiKeyRoutingTable(): CPointer<Unit>
@FastNative
foreign func ImGuiKeyRoutingTable_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiKeyRoutingTable_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiKeyOwnerData_ImGuiKeyOwnerData(): CPointer<Unit>
@FastNative
foreign func ImGuiKeyOwnerData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiListClipperRange_FromIndices(min: Int32, max: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiListClipperRange_FromPositions(y1: Float32, y2: Float32, off_min: Int32, off_max: Int32): CPointer<Unit>
@FastNative
foreign func ImGuiListClipperData_ImGuiListClipperData(): CPointer<Unit>
@FastNative
foreign func ImGuiListClipperData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiListClipperData_Reset(self: CPointer<Unit>, clipper: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNavItemData_ImGuiNavItemData(): CPointer<Unit>
@FastNative
foreign func ImGuiNavItemData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiNavItemData_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTypingSelectState_ImGuiTypingSelectState(): CPointer<Unit>
@FastNative
foreign func ImGuiTypingSelectState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTypingSelectState_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiOldColumnData_ImGuiOldColumnData(): CPointer<Unit>
@FastNative
foreign func ImGuiOldColumnData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiOldColumns_ImGuiOldColumns(): CPointer<Unit>
@FastNative
foreign func ImGuiOldColumns_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiBoxSelectState_ImGuiBoxSelectState(): CPointer<Unit>
@FastNative
foreign func ImGuiBoxSelectState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMultiSelectTempData_ImGuiMultiSelectTempData(): CPointer<Unit>
@FastNative
foreign func ImGuiMultiSelectTempData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMultiSelectTempData_Clear(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMultiSelectTempData_ClearIO(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiMultiSelectState_ImGuiMultiSelectState(): CPointer<Unit>
@FastNative
foreign func ImGuiMultiSelectState_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiViewportP_ImGuiViewportP(): CPointer<Unit>
@FastNative
foreign func ImGuiViewportP_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiViewportP_CalcWorkRectPos(self: CPointer<Unit>, inset_min: ImVec2): ImVec2
@FastNative
foreign func ImGuiViewportP_CalcWorkRectSize(self: CPointer<Unit>, inset_min: ImVec2, inset_max: ImVec2): ImVec2
@FastNative
foreign func ImGuiViewportP_UpdateWorkRect(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiViewportP_GetMainRect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiViewportP_GetWorkRect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiViewportP_GetBuildWorkRect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiWindowSettings_ImGuiWindowSettings(): CPointer<Unit>
@FastNative
foreign func ImGuiWindowSettings_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiWindowSettings_GetName(self: CPointer<Unit>): CPointer<Int8>
@FastNative
foreign func ImGuiSettingsHandler_ImGuiSettingsHandler(): CPointer<Unit>
@FastNative
foreign func ImGuiSettingsHandler_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiDebugAllocInfo_ImGuiDebugAllocInfo(): CPointer<Unit>
@FastNative
foreign func ImGuiDebugAllocInfo_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiStackLevelInfo_ImGuiStackLevelInfo(): CPointer<Unit>
@FastNative
foreign func ImGuiStackLevelInfo_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiDebugItemPathQuery_ImGuiDebugItemPathQuery(): CPointer<Unit>
@FastNative
foreign func ImGuiDebugItemPathQuery_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiIDStackTool_ImGuiIDStackTool(): CPointer<Unit>
@FastNative
foreign func ImGuiIDStackTool_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiContextHook_ImGuiContextHook(): CPointer<Unit>
@FastNative
foreign func ImGuiContextHook_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiContext_ImGuiContext(shared_font_atlas: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiContext_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiWindow_ImGuiWindow(context: CPointer<Unit>, name: CString): CPointer<Unit>
@FastNative
foreign func ImGuiWindow_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiWindow_GetID_Str(self: CPointer<Unit>, str: CString, str_end: CString): UInt32
@FastNative
foreign func ImGuiWindow_GetID_Ptr(self: CPointer<Unit>, ptr: CPointer<Unit>): UInt32
@FastNative
foreign func ImGuiWindow_GetID_Int(self: CPointer<Unit>, n: Int32): UInt32
@FastNative
foreign func ImGuiWindow_GetIDFromPos(self: CPointer<Unit>, p_abs: ImVec2): UInt32
@FastNative
foreign func ImGuiWindow_GetIDFromRectangle(self: CPointer<Unit>, r_abs: CPointer<Unit>): UInt32
@FastNative
foreign func ImGuiWindow_Rect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiWindow_TitleBarRect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiWindow_MenuBarRect(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func ImGuiTabItem_ImGuiTabItem(): CPointer<Unit>
@FastNative
foreign func ImGuiTabItem_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTabBar_ImGuiTabBar(): CPointer<Unit>
@FastNative
foreign func ImGuiTabBar_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableColumn_ImGuiTableColumn(): CPointer<Unit>
@FastNative
foreign func ImGuiTableColumn_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableInstanceData_ImGuiTableInstanceData(): CPointer<Unit>
@FastNative
foreign func ImGuiTableInstanceData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTable_ImGuiTable(): CPointer<Unit>
@FastNative
foreign func ImGuiTable_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableTempData_ImGuiTableTempData(): CPointer<Unit>
@FastNative
foreign func ImGuiTableTempData_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableColumnSettings_ImGuiTableColumnSettings(): CPointer<Unit>
@FastNative
foreign func ImGuiTableColumnSettings_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableSettings_ImGuiTableSettings(): CPointer<Unit>
@FastNative
foreign func ImGuiTableSettings_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImGuiTableSettings_GetColumnSettings(self: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igTableOpenContextMenu(column_n: Int32): Unit
@FastNative
foreign func igTableSetColumnWidth(column_n: Int32, width: Float32): Unit
@FastNative
foreign func igTableSetColumnSortDirection(column_n: Int32, sort_direction: Int32, append_to_sort_specs: Int32): Unit
@FastNative
foreign func igTableGetHoveredRow(): Int32
@FastNative
foreign func igTableGetHeaderRowHeight(): Float32
@FastNative
foreign func igTableGetHeaderAngledMaxLabelWidth(): Float32
@FastNative
foreign func igTablePushBackgroundChannel(): Unit
@FastNative
foreign func igTablePopBackgroundChannel(): Unit
@FastNative
foreign func igTablePushColumnChannel(column_n: Int32): Unit
@FastNative
foreign func igTablePopColumnChannel(): Unit
@FastNative
foreign func igTableAngledHeadersRowEx(row_id: UInt32, angle: Float32, max_label_width: Float32, data: CPointer<Unit>, data_count: Int32): Unit
@FastNative
foreign func igGetCurrentTable(): CPointer<Unit>
@FastNative
foreign func igTableFindByID(id: UInt32): CPointer<Unit>
@FastNative
foreign func igBeginTableEx(name: CString, id: UInt32, columns_count: Int32, flags: Int32, outer_size: ImVec2, inner_width: Float32): Int32
@FastNative
foreign func igTableBeginInitMemory(table: CPointer<Unit>, columns_count: Int32): Unit
@FastNative
foreign func igTableApplyQueuedRequests(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableSetupDrawChannels(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableReconcileColumns(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableUpdateLayout(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableUpdateBorders(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableUpdateColumnsWeightFromWidth(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableApplyExternalUnclipRect(table: CPointer<Unit>, rect: CPointer<Unit>): Unit
@FastNative
foreign func igTableDrawBorders(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableDrawDefaultContextMenu(table: CPointer<Unit>, flags_for_section_to_display: Int32): Unit
@FastNative
foreign func igTableBeginContextMenuPopup(table: CPointer<Unit>): Int32
@FastNative
foreign func igTableMergeDrawChannels(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGetInstanceData(table: CPointer<Unit>, instance_no: Int32): CPointer<Unit>
@FastNative
foreign func igTableGetInstanceID(table: CPointer<Unit>, instance_no: Int32): UInt32
@FastNative
foreign func igTableFixDisplayOrder(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableSortSpecsSanitize(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableSortSpecsBuild(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableInitColumnDefaults(table: CPointer<Unit>, column: CPointer<Unit>, init_mask: Int32): Unit
@FastNative
foreign func igTableGetColumnNextSortDirection(column: CPointer<Unit>): Int32
@FastNative
foreign func igTableFixColumnSortDirection(table: CPointer<Unit>, column: CPointer<Unit>): Unit
@FastNative
foreign func igTableGetColumnWidthAuto(table: CPointer<Unit>, column: CPointer<Unit>): Float32
@FastNative
foreign func igTableBeginRow(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableEndRow(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableBeginCell(table: CPointer<Unit>, column_n: Int32): Unit
@FastNative
foreign func igTableEndCell(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGetCellBgRect(table: CPointer<Unit>, column_n: Int32): CPointer<Unit>
@FastNative
foreign func igTableGetColumnName_TablePtr(table: CPointer<Unit>, column_n: Int32): CString
@FastNative
foreign func igTableGetColumnResizeID(table: CPointer<Unit>, column_n: Int32, instance_no: Int32): UInt32
@FastNative
foreign func igTableCalcMaxColumnWidth(table: CPointer<Unit>, column_n: Int32): Float32
@FastNative
foreign func igTableSetColumnWidthAutoSingle(table: CPointer<Unit>, column_n: Int32): Unit
@FastNative
foreign func igTableSetColumnWidthAutoAll(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableSetColumnDisplayOrder(table: CPointer<Unit>, column_n: Int32, dst_order: Int32): Unit
@FastNative
foreign func igTableQueueSetColumnDisplayOrder(table: CPointer<Unit>, column_n: Int32, dst_order: Int32): Unit
@FastNative
foreign func igTableRemove(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGcCompactTransientBuffers_TablePtr(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGcCompactTransientBuffers_TableTempDataPtr(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGcCompactSettings(): Unit
@FastNative
foreign func igTableLoadSettings(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableLoadSettingsForColumns(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableLoadSettingsForColumn(column: CPointer<Unit>, column_settings: CPointer<Unit>, load_flags: Int32): Unit
@FastNative
foreign func igTableSaveSettings(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableResetSettings(table: CPointer<Unit>): Unit
@FastNative
foreign func igTableGetBoundSettings(table: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igTableSettingsAddSettingsHandler(): Unit
@FastNative
foreign func igTableSettingsCreate(id: UInt32, columns_count: Int32): CPointer<Unit>
@FastNative
foreign func igTableSettingsFindByID(id: UInt32): CPointer<Unit>
@FastNative
foreign func igSetWindowClipRectBeforeSetChannel(window: CPointer<Unit>, clip_rect: CPointer<Unit>): Unit
@FastNative
foreign func igBeginColumns(str_id: CString, count: Int32, flags: Int32): Unit
@FastNative
foreign func igEndColumns(): Unit
@FastNative
foreign func igPushColumnClipRect(column_index: Int32): Unit
@FastNative
foreign func igPushColumnsBackground(): Unit
@FastNative
foreign func igPopColumnsBackground(): Unit
@FastNative
foreign func igGetColumnsID(str_id: CString, count: Int32): UInt32
@FastNative
foreign func igFindOrCreateColumns(window: CPointer<Unit>, id: UInt32): CPointer<Unit>
@FastNative
foreign func igGetColumnOffsetFromNorm(columns: CPointer<Unit>, offset_norm: Float32): Float32
@FastNative
foreign func igGetColumnNormFromOffset(columns: CPointer<Unit>, offset: Float32): Float32
@FastNative
foreign func igGetIO_ContextPtr(ctx: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igGetPlatformIO_ContextPtr(ctx: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igGetScale(): Float32
@FastNative
foreign func igGetCurrentWindowRead(): CPointer<Unit>
@FastNative
foreign func igGetCurrentWindow(): CPointer<Unit>
@FastNative
foreign func igFindWindowByID(id: UInt32): CPointer<Unit>
@FastNative
foreign func igFindWindowByName(name: CString): CPointer<Unit>
@FastNative
foreign func igUpdateWindowParentAndRootLinks(window: CPointer<Unit>, flags: Int32, parent_window: CPointer<Unit>): Unit
@FastNative
foreign func igUpdateWindowSkipRefresh(window: CPointer<Unit>): Unit
@FastNative
foreign func igCalcWindowNextAutoFitSize(window: CPointer<Unit>): ImVec2
@FastNative
foreign func igIsWindowChildOf(window: CPointer<Unit>, potential_parent: CPointer<Unit>, popup_hierarchy: Int32): Int32
@FastNative
foreign func igIsWindowInBeginStack(window: CPointer<Unit>): Int32
@FastNative
foreign func igIsWindowWithinBeginStackOf(window: CPointer<Unit>, potential_parent: CPointer<Unit>): Int32
@FastNative
foreign func igIsWindowAbove(potential_above: CPointer<Unit>, potential_below: CPointer<Unit>): Int32
@FastNative
foreign func igIsWindowNavFocusable(window: CPointer<Unit>): Int32
@FastNative
foreign func igSetWindowPos_WindowPtr(window: CPointer<Unit>, pos: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowSize_WindowPtr(window: CPointer<Unit>, size: ImVec2, cond: Int32): Unit
@FastNative
foreign func igSetWindowCollapsed_WindowPtr(window: CPointer<Unit>, collapsed: Int32, cond: Int32): Unit
@FastNative
foreign func igSetWindowHitTestHole(window: CPointer<Unit>, pos: ImVec2, size: ImVec2): Unit
@FastNative
foreign func igSetWindowHiddenAndSkipItemsForCurrentFrame(window: CPointer<Unit>): Unit
@FastNative
foreign func igSetWindowParentWindowForFocusRoute(window: CPointer<Unit>, parent_window: CPointer<Unit>): Unit
@FastNative
foreign func igWindowRectAbsToRel(window: CPointer<Unit>, r: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igWindowRectRelToAbs(window: CPointer<Unit>, r: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igWindowPosAbsToRel(window: CPointer<Unit>, p: ImVec2): ImVec2
@FastNative
foreign func igWindowPosRelToAbs(window: CPointer<Unit>, p: ImVec2): ImVec2
@FastNative
foreign func igFocusWindow(window: CPointer<Unit>, flags: Int32): Unit
@FastNative
foreign func igFocusTopMostWindowUnderOne(under_this_window: CPointer<Unit>, ignore_window: CPointer<Unit>, filter_viewport: CPointer<Unit>, flags: Int32): Unit
@FastNative
foreign func igBringWindowToFocusFront(window: CPointer<Unit>): Unit
@FastNative
foreign func igBringWindowToDisplayFront(window: CPointer<Unit>): Unit
@FastNative
foreign func igBringWindowToDisplayBack(window: CPointer<Unit>): Unit
@FastNative
foreign func igBringWindowToDisplayBehind(window: CPointer<Unit>, above_window: CPointer<Unit>): Unit
@FastNative
foreign func igFindWindowDisplayIndex(window: CPointer<Unit>): Int32
@FastNative
foreign func igFindBottomMostVisibleWindowWithinBeginStack(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igSetNextWindowRefreshPolicy(flags: Int32): Unit
@FastNative
foreign func igRegisterUserTexture(tex: CPointer<Unit>): Unit
@FastNative
foreign func igUnregisterUserTexture(tex: CPointer<Unit>): Unit
@FastNative
foreign func igRegisterFontAtlas(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igUnregisterFontAtlas(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igSetCurrentFont(font: CPointer<Unit>, font_size_before_scaling: Float32, font_size_after_scaling: Float32): Unit
@FastNative
foreign func igUpdateCurrentFontSize(restore_font_size_after_scaling: Float32): Unit
@FastNative
foreign func igSetFontRasterizerDensity(rasterizer_density: Float32): Unit
@FastNative
foreign func igGetFontRasterizerDensity(): Float32
@FastNative
foreign func igGetRoundedFontSize(size: Float32): Float32
@FastNative
foreign func igGetDefaultFont(): CPointer<Unit>
@FastNative
foreign func igPushPasswordFont(): Unit
@FastNative
foreign func igPopPasswordFont(): Unit
@FastNative
foreign func igGetForegroundDrawList_WindowPtr(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igGetBackgroundDrawList_ViewportPtr(viewport: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igGetForegroundDrawList_ViewportPtr(viewport: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igAddDrawListToDrawDataEx(draw_data: CPointer<Unit>, out_list: CPointer<Unit>, draw_list: CPointer<Unit>): Unit
@FastNative
foreign func igInitialize(): Unit
@FastNative
foreign func igShutdown(): Unit
@FastNative
foreign func igSetContextName(ctx: CPointer<Unit>, name: CString): Unit
@FastNative
foreign func igAddContextHook(ctx: CPointer<Unit>, hook: CPointer<Unit>): UInt32
@FastNative
foreign func igRemoveContextHook(ctx: CPointer<Unit>, hook_to_remove: UInt32): Unit
@FastNative
foreign func igCallContextHooks(ctx: CPointer<Unit>, `type`: Int32): Unit
@FastNative
foreign func igUpdateInputEvents(trickle_fast_inputs: Int32): Unit
@FastNative
foreign func igUpdateHoveredWindowAndCaptureFlags(mouse_pos: ImVec2): Unit
@FastNative
foreign func igFindHoveredWindowEx(pos: ImVec2, find_first_and_in_any_viewport: Int32, out_hovered_window: CPointer<Unit>, out_hovered_window_under_moving_window: CPointer<Unit>): Unit
@FastNative
foreign func igStartMouseMovingWindow(window: CPointer<Unit>): Unit
@FastNative
foreign func igStopMouseMovingWindow(): Unit
@FastNative
foreign func igUpdateMouseMovingWindowNewFrame(): Unit
@FastNative
foreign func igUpdateMouseMovingWindowEndFrame(): Unit
@FastNative
foreign func igGetWindowViewport(): CPointer<Unit>
@FastNative
foreign func igScaleWindowsInViewport(viewport: CPointer<Unit>, scale: Float32): Unit
@FastNative
foreign func igSetWindowViewport(window: CPointer<Unit>, viewport: CPointer<Unit>): Unit
@FastNative
foreign func igMarkIniSettingsDirty_Nil(): Unit
@FastNative
foreign func igMarkIniSettingsDirty_WindowPtr(window: CPointer<Unit>): Unit
@FastNative
foreign func igClearIniSettings(): Unit
@FastNative
foreign func igCleanupIniSettings(args: CPointer<Unit>): Unit
@FastNative
foreign func igAddSettingsHandler(handler: CPointer<Unit>): Unit
@FastNative
foreign func igRemoveSettingsHandler(type_name: CString): Unit
@FastNative
foreign func igFindSettingsHandler(type_name: CString): CPointer<Unit>
@FastNative
foreign func igCreateNewWindowSettings(name: CString): CPointer<Unit>
@FastNative
foreign func igFindWindowSettingsByID(id: UInt32): CPointer<Unit>
@FastNative
foreign func igFindWindowSettingsByWindow(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igClearWindowSettings(name: CString): Unit
@FastNative
foreign func igLocalizeRegisterEntries(entries: CPointer<Unit>, count: Int32): Unit
@FastNative
foreign func igLocalizeGetMsg(key: Int32): CString
@FastNative
foreign func igSetScrollX_WindowPtr(window: CPointer<Unit>, scroll_x: Float32): Unit
@FastNative
foreign func igSetScrollY_WindowPtr(window: CPointer<Unit>, scroll_y: Float32): Unit
@FastNative
foreign func igSetScrollFromPosX_WindowPtr(window: CPointer<Unit>, local_x: Float32, center_x_ratio: Float32): Unit
@FastNative
foreign func igSetScrollFromPosY_WindowPtr(window: CPointer<Unit>, local_y: Float32, center_y_ratio: Float32): Unit
@FastNative
foreign func igScrollToItem(flags: Int32): Unit
@FastNative
foreign func igScrollToRect(window: CPointer<Unit>, rect: CPointer<Unit>, flags: Int32): Unit
@FastNative
foreign func igScrollToRectEx(window: CPointer<Unit>, rect: CPointer<Unit>, flags: Int32): ImVec2
@FastNative
foreign func igScrollToBringRectIntoView(window: CPointer<Unit>, rect: CPointer<Unit>): Unit
@FastNative
foreign func igGetItemStatusFlags(): Int32
@FastNative
foreign func igGetActiveID(): UInt32
@FastNative
foreign func igGetFocusID(): UInt32
@FastNative
foreign func igSetActiveID(id: UInt32, window: CPointer<Unit>): Unit
@FastNative
foreign func igSetFocusID(id: UInt32, window: CPointer<Unit>): Unit
@FastNative
foreign func igClearActiveID(): Unit
@FastNative
foreign func igGetHoveredID(): UInt32
@FastNative
foreign func igSetHoveredID(id: UInt32): Unit
@FastNative
foreign func igKeepAliveID(id: UInt32): Unit
@FastNative
foreign func igMarkItemEdited(id: UInt32): Unit
@FastNative
foreign func igPushOverrideID(id: UInt32): Unit
@FastNative
foreign func igGetIDWithSeed_Str(str_id_begin: CString, str_id_end: CString, seed: UInt32): UInt32
@FastNative
foreign func igGetIDWithSeed_Int(n: Int32, seed: UInt32): UInt32
@FastNative
foreign func igItemSize_Vec2(size: ImVec2, text_baseline_y: Float32): Unit
@FastNative
foreign func igItemSize_Rect(bb: CPointer<Unit>, text_baseline_y: Float32): Unit
@FastNative
foreign func igItemAdd(bb: CPointer<Unit>, id: UInt32, nav_bb: CPointer<Unit>, extra_flags: Int32): Int32
@FastNative
foreign func igItemHoverable(bb: CPointer<Unit>, id: UInt32, item_flags: Int32): Int32
@FastNative
foreign func igIsWindowContentHoverable(window: CPointer<Unit>, flags: Int32): Int32
@FastNative
foreign func igIsClippedEx(bb: CPointer<Unit>, id: UInt32): Int32
@FastNative
foreign func igSetLastItemData(item_id: UInt32, item_flags: Int32, status_flags: Int32, item_rect: CPointer<Unit>): Unit
@FastNative
foreign func igCalcItemSize(size: ImVec2, default_w: Float32, default_h: Float32): ImVec2
@FastNative
foreign func igCalcWrapWidthForPos(pos: ImVec2, wrap_pos_x: Float32): Float32
@FastNative
foreign func igPushMultiItemsWidths(components: Int32, width_full: Float32): Unit
@FastNative
foreign func igShrinkWidths(items: CPointer<Unit>, count: Int32, width_excess: Float32, width_min: Float32): Unit
@FastNative
foreign func igCalcClipRectVisibleItemsY(clip_rect: CPointer<Unit>, pos: ImVec2, items_height: Float32, out_visible_start: CPointer<Int32>, out_visible_end: CPointer<Int32>): Unit
@FastNative
foreign func igGetStyleVarInfo(idx: Int32): CPointer<Unit>
@FastNative
foreign func igBeginDisabledOverrideReenable(): Unit
@FastNative
foreign func igEndDisabledOverrideReenable(): Unit
@FastNative
foreign func igLogBegin(flags: Int32, auto_open_depth: Int32): Unit
@FastNative
foreign func igLogToBuffer(auto_open_depth: Int32): Unit
@FastNative
foreign func igLogRenderedText(ref_pos: CPointer<ImVec2>, text: CString, text_end: CString): Unit
@FastNative
foreign func igLogSetNextTextDecoration(prefix: CString, suffix: CString): Unit
@FastNative
foreign func igBeginChildEx(name: CString, id: UInt32, size_arg: ImVec2, child_flags: Int32, window_flags: Int32): Int32
@FastNative
foreign func igFindFrontMostVisibleChildWindow(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igBeginPopupEx(id: UInt32, extra_window_flags: Int32): Int32
@FastNative
foreign func igBeginPopupMenuEx(id: UInt32, label: CString, extra_window_flags: Int32): Int32
@FastNative
foreign func igOpenPopupEx(id: UInt32, popup_flags: Int32): Int32
@FastNative
foreign func igClosePopupToLevel(remaining: Int32, restore_focus_to_window_under_popup: Int32): Unit
@FastNative
foreign func igClosePopupsOverWindow(ref_window: CPointer<Unit>, restore_focus_to_window_under_popup: Int32): Unit
@FastNative
foreign func igClosePopupsExceptModals(): Unit
@FastNative
foreign func igIsPopupOpen_ID(id: UInt32, popup_flags: Int32): Int32
@FastNative
foreign func igGetPopupAllowedExtentRect(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igGetTopMostPopupModal(): CPointer<Unit>
@FastNative
foreign func igGetTopMostAndVisiblePopupModal(): CPointer<Unit>
@FastNative
foreign func igFindBlockingModal(window: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igFindBestWindowPosForPopup(window: CPointer<Unit>): ImVec2
@FastNative
foreign func igFindBestWindowPosForPopupEx(ref_pos: ImVec2, size: ImVec2, last_dir: CPointer<Int32>, r_outer: CPointer<Unit>, r_avoid: CPointer<Unit>, policy: Int32): ImVec2
@FastNative
foreign func igGetMouseButtonFromPopupFlags(flags: Int32): Int32
@FastNative
foreign func igIsPopupOpenRequestForItem(flags: Int32, id: UInt32): Int32
@FastNative
foreign func igIsPopupOpenRequestForWindow(flags: Int32): Int32
@FastNative
foreign func igBeginTooltipEx(tooltip_flags: Int32, extra_window_flags: Int32): Int32
@FastNative
foreign func igBeginTooltipHidden(): Int32
@FastNative
foreign func igBeginViewportSideBar(name: CString, viewport: CPointer<Unit>, dir: Int32, size: Float32, window_flags: Int32): Int32
@FastNative
foreign func igBeginMenuEx(label: CString, icon: CString, enabled: Int32): Int32
@FastNative
foreign func igMenuItemEx(label: CString, icon: CString, shortcut: CString, selected: Int32, enabled: Int32): Int32
@FastNative
foreign func igBeginComboPopup(popup_id: UInt32, bb: CPointer<Unit>, flags: Int32): Int32
@FastNative
foreign func igBeginComboPreview(): Int32
@FastNative
foreign func igEndComboPreview(): Unit
@FastNative
foreign func igNavInitWindow(window: CPointer<Unit>, force_reinit: Int32): Unit
@FastNative
foreign func igNavInitRequestApplyResult(): Unit
@FastNative
foreign func igNavMoveRequestButNoResultYet(): Int32
@FastNative
foreign func igNavMoveRequestSubmit(move_dir: Int32, clip_dir: Int32, move_flags: Int32, scroll_flags: Int32): Unit
@FastNative
foreign func igNavMoveRequestForward(move_dir: Int32, clip_dir: Int32, move_flags: Int32, scroll_flags: Int32): Unit
@FastNative
foreign func igNavMoveRequestResolveWithLastItem(result: CPointer<Unit>): Unit
@FastNative
foreign func igNavMoveRequestResolveWithPastTreeNode(result: CPointer<Unit>, tree_node_data: CPointer<Unit>): Unit
@FastNative
foreign func igNavMoveRequestCancel(): Unit
@FastNative
foreign func igNavMoveRequestApplyResult(): Unit
@FastNative
foreign func igNavMoveRequestTryWrapping(window: CPointer<Unit>, move_flags: Int32): Unit
@FastNative
foreign func igNavHighlightActivated(id: UInt32): Unit
@FastNative
foreign func igNavClearPreferredPosForAxis(axis: Int32): Unit
@FastNative
foreign func igSetNavCursorVisibleAfterMove(): Unit
@FastNative
foreign func igNavUpdateCurrentWindowIsScrollPushableX(): Unit
@FastNative
foreign func igSetNavWindow(window: CPointer<Unit>): Unit
@FastNative
foreign func igSetNavID(id: UInt32, nav_layer: Int32, focus_scope_id: UInt32, rect_rel: CPointer<Unit>): Unit
@FastNative
foreign func igSetNavFocusScope(focus_scope_id: UInt32): Unit
@FastNative
foreign func igFocusItem(): Unit
@FastNative
foreign func igActivateItemByID(id: UInt32): Unit
@FastNative
foreign func igIsNamedKey(key: Int32): Int32
@FastNative
foreign func igIsNamedKeyOrMod(key: Int32): Int32
@FastNative
foreign func igIsLegacyKey(key: Int32): Int32
@FastNative
foreign func igIsKeyboardKey(key: Int32): Int32
@FastNative
foreign func igIsGamepadKey(key: Int32): Int32
@FastNative
foreign func igIsMouseKey(key: Int32): Int32
@FastNative
foreign func igIsAliasKey(key: Int32): Int32
@FastNative
foreign func igIsLRModKey(key: Int32): Int32
@FastNative
foreign func igFixupKeyChord(key_chord: Int32): Int32
@FastNative
foreign func igConvertSingleModFlagToKey(key: Int32): Int32
@FastNative
foreign func igGetKeyData_ContextPtr(ctx: CPointer<Unit>, key: Int32): CPointer<Unit>
@FastNative
foreign func igGetKeyData_Key(key: Int32): CPointer<Unit>
@FastNative
foreign func igGetKeyChordName(key_chord: Int32): CString
@FastNative
foreign func igMouseButtonToKey(button: Int32): Int32
@FastNative
foreign func igIsMouseDragPastThreshold(button: Int32, lock_threshold: Float32): Int32
@FastNative
foreign func igGetKeyMagnitude2d(key_left: Int32, key_right: Int32, key_up: Int32, key_down: Int32): ImVec2
@FastNative
foreign func igGetNavTweakPressedAmount(axis: Int32): Float32
@FastNative
foreign func igCalcTypematicRepeatAmount(t0: Float32, t1: Float32, repeat_delay: Float32, repeat_rate: Float32): Int32
@FastNative
foreign func igGetTypematicRepeatRate(flags: Int32, repeat_delay: CPointer<Float32>, repeat_rate: CPointer<Float32>): Unit
@FastNative
foreign func igTeleportMousePos(pos: ImVec2): Unit
@FastNative
foreign func igSetActiveIdUsingAllKeyboardKeys(): Unit
@FastNative
foreign func igIsActiveIdUsingNavDir(dir: Int32): Int32
@FastNative
foreign func igGetKeyOwner(key: Int32): UInt32
@FastNative
foreign func igSetKeyOwner(key: Int32, owner_id: UInt32, flags: Int32): Unit
@FastNative
foreign func igSetKeyOwnersForKeyChord(key: Int32, owner_id: UInt32, flags: Int32): Unit
@FastNative
foreign func igSetItemKeyOwner_InputFlags(key: Int32, flags: Int32): Int32
@FastNative
foreign func igTestKeyOwner(key: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igGetKeyOwnerData(ctx: CPointer<Unit>, key: Int32): CPointer<Unit>
@FastNative
foreign func igIsKeyDown_ID(key: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsKeyPressed_InputFlags(key: Int32, flags: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsKeyReleased_ID(key: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsKeyChordPressed_InputFlags(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsMouseDown_ID(button: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsMouseClicked_InputFlags(button: Int32, flags: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsMouseReleased_ID(button: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igIsMouseDoubleClicked_ID(button: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igShortcut_ID(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igSetShortcutRouting(key_chord: Int32, flags: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igTestShortcutRouting(key_chord: Int32, owner_id: UInt32): Int32
@FastNative
foreign func igGetShortcutRoutingData(key_chord: Int32): CPointer<Unit>
@FastNative
foreign func igPushFocusScope(id: UInt32): Unit
@FastNative
foreign func igPopFocusScope(): Unit
@FastNative
foreign func igIsInNavFocusRoute(focus_scope_id: UInt32): Int32
@FastNative
foreign func igGetCurrentFocusScope(): UInt32
@FastNative
foreign func igIsDragDropActive(): Int32
@FastNative
foreign func igBeginDragDropTargetCustom(bb: CPointer<Unit>, id: UInt32): Int32
@FastNative
foreign func igBeginDragDropTargetViewport(viewport: CPointer<Unit>, p_bb: CPointer<Unit>): Int32
@FastNative
foreign func igClearDragDrop(): Unit
@FastNative
foreign func igIsDragDropPayloadBeingAccepted(): Int32
@FastNative
foreign func igRenderDragDropTargetRectForItem(bb: CPointer<Unit>): Unit
@FastNative
foreign func igRenderDragDropTargetRectEx(draw_list: CPointer<Unit>, bb: CPointer<Unit>, rounding: Float32): Unit
@FastNative
foreign func igGetTypingSelectRequest(flags: Int32): CPointer<Unit>
@FastNative
foreign func igBeginBoxSelect(scope_rect: CPointer<Unit>, window: CPointer<Unit>, box_select_id: UInt32, ms_flags: Int32): Int32
@FastNative
foreign func igEndBoxSelect(scope_rect: CPointer<Unit>, ms_flags: Int32): Unit
@FastNative
foreign func igMultiSelectItemHeader(id: UInt32, p_selected: CPointer<Int32>, p_button_flags: CPointer<Int32>): Unit
@FastNative
foreign func igMultiSelectItemFooter(id: UInt32, p_selected: CPointer<Int32>, p_pressed: CPointer<Int32>, extra_flags: Int32): Unit
@FastNative
foreign func igMultiSelectAddSetAll(ms: CPointer<Unit>, selected: Int32): Unit
@FastNative
foreign func igMultiSelectAddSetRange(ms: CPointer<Unit>, selected: Int32, range_dir: Int32, first_item: Int64, last_item: Int64): Unit
@FastNative
foreign func igGetBoxSelectState(id: UInt32): CPointer<Unit>
@FastNative
foreign func igGetMultiSelectState(id: UInt32): CPointer<Unit>
@FastNative
foreign func igGetCurrentTabBar(): CPointer<Unit>
@FastNative
foreign func igTabBarFindByID(id: UInt32): CPointer<Unit>
@FastNative
foreign func igTabBarRemove(tab_bar: CPointer<Unit>): Unit
@FastNative
foreign func igBeginTabBarEx(tab_bar: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32): Int32
@FastNative
foreign func igTabBarFindTabByID(tab_bar: CPointer<Unit>, tab_id: UInt32): CPointer<Unit>
@FastNative
foreign func igTabBarFindTabByOrder(tab_bar: CPointer<Unit>, order: Int32): CPointer<Unit>
@FastNative
foreign func igTabBarGetCurrentTab(tab_bar: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igTabBarGetTabOrder(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Int32
@FastNative
foreign func igTabBarGetTabName(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): CString
@FastNative
foreign func igTabBarRemoveTab(tab_bar: CPointer<Unit>, tab_id: UInt32): Unit
@FastNative
foreign func igTabBarCloseTab(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Unit
@FastNative
foreign func igTabBarQueueFocus_TabItemPtr(tab_bar: CPointer<Unit>, tab: CPointer<Unit>): Unit
@FastNative
foreign func igTabBarQueueFocus_Str(tab_bar: CPointer<Unit>, tab_name: CString): Unit
@FastNative
foreign func igTabBarQueueReorder(tab_bar: CPointer<Unit>, tab: CPointer<Unit>, offset: Int32): Unit
@FastNative
foreign func igTabBarQueueReorderFromMousePos(tab_bar: CPointer<Unit>, tab: CPointer<Unit>, mouse_pos: ImVec2): Unit
@FastNative
foreign func igTabBarProcessReorder(tab_bar: CPointer<Unit>): Int32
@FastNative
foreign func igTabItemEx(tab_bar: CPointer<Unit>, label: CString, p_open: CPointer<Int32>, flags: Int32, docked_window: CPointer<Unit>): Int32
@FastNative
foreign func igTabItemSpacing(str_id: CString, flags: Int32, width: Float32): Unit
@FastNative
foreign func igTabItemCalcSize_Str(label: CString, has_close_button_or_unsaved_marker: Int32): ImVec2
@FastNative
foreign func igTabItemCalcSize_WindowPtr(window: CPointer<Unit>): ImVec2
@FastNative
foreign func igTabItemBackground(draw_list: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32, col: UInt32): Unit
@FastNative
foreign func igTabItemLabelAndCloseButton(draw_list: CPointer<Unit>, bb: CPointer<Unit>, flags: Int32, frame_padding: ImVec2, label: CString, tab_id: UInt32, close_button_id: UInt32, is_contents_visible: Int32, out_just_closed: CPointer<Int32>, out_text_clipped: CPointer<Int32>): Unit
@FastNative
foreign func igRenderText(pos: ImVec2, text: CString, text_end: CString, hide_text_after_hash: Int32): Unit
@FastNative
foreign func igRenderTextWrapped(pos: ImVec2, text: CString, text_end: CString, wrap_width: Float32): Unit
@FastNative
foreign func igRenderTextClipped(pos_min: ImVec2, pos_max: ImVec2, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>, align: ImVec2, clip_rect: CPointer<Unit>): Unit
@FastNative
foreign func igRenderTextClippedEx(draw_list: CPointer<Unit>, pos_min: ImVec2, pos_max: ImVec2, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>, align: ImVec2, clip_rect: CPointer<Unit>): Unit
@FastNative
foreign func igRenderTextEllipsis(draw_list: CPointer<Unit>, pos_min: ImVec2, pos_max: ImVec2, ellipsis_max_x: Float32, text: CString, text_end: CString, text_size_if_known: CPointer<ImVec2>): Unit
@FastNative
foreign func igRenderFrame(p_min: ImVec2, p_max: ImVec2, fill_col: UInt32, borders: Int32, rounding: Float32): Unit
@FastNative
foreign func igRenderFrameBorder(p_min: ImVec2, p_max: ImVec2, rounding: Float32): Unit
@FastNative
foreign func igRenderColorComponentMarker(bb: CPointer<Unit>, col: UInt32, rounding: Float32): Unit
@FastNative
foreign func igRenderColorRectWithAlphaCheckerboard(draw_list: CPointer<Unit>, p_min: ImVec2, p_max: ImVec2, fill_col: UInt32, grid_step: Float32, grid_off: ImVec2, rounding: Float32, flags: Int32): Unit
@FastNative
foreign func igRenderNavCursor(bb: CPointer<Unit>, id: UInt32, flags: Int32, rounding: Float32): Unit
@FastNative
foreign func igFindRenderedTextEnd(text: CString, text_end: CString): CString
@FastNative
foreign func igRenderMouseCursor(pos: ImVec2, scale: Float32, mouse_cursor: Int32, col_fill: UInt32, col_border: UInt32, col_shadow: UInt32): Unit
@FastNative
foreign func igRenderArrow(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32, dir: Int32, scale: Float32): Unit
@FastNative
foreign func igRenderBullet(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32): Unit
@FastNative
foreign func igRenderCheckMark(draw_list: CPointer<Unit>, pos: ImVec2, col: UInt32, sz: Float32): Unit
@FastNative
foreign func igRenderArrowPointingAt(draw_list: CPointer<Unit>, pos: ImVec2, half_sz: ImVec2, direction: Int32, col: UInt32): Unit
@FastNative
foreign func igRenderRectFilledInRangeH(draw_list: CPointer<Unit>, rect: CPointer<Unit>, col: UInt32, fill_x0: Float32, fill_x1: Float32, rounding: Float32): Unit
@FastNative
foreign func igRenderRectFilledWithHole(draw_list: CPointer<Unit>, outer: CPointer<Unit>, inner: CPointer<Unit>, col: UInt32, rounding: Float32): Unit
@FastNative
foreign func igCalcRoundingFlagsForRectInRect(r_in: CPointer<Unit>, r_outer: CPointer<Unit>, threshold: Float32): Int32
@FastNative
foreign func igTextEx(text: CString, text_end: CString, flags: Int32): Unit
@FastNative
foreign func igTextAligned0(align_x: Float32, size_x: Float32, fmt: CString): Unit
@FastNative
foreign func igButtonEx(label: CString, size_arg: ImVec2, flags: Int32): Int32
@FastNative
foreign func igArrowButtonEx(str_id: CString, dir: Int32, size_arg: ImVec2, flags: Int32): Int32
@FastNative
foreign func igImageButtonEx(id: UInt32, tex_ref: CPointer<Unit>, image_size: ImVec2, uv0: ImVec2, uv1: ImVec2, bg_col: ImVec4, tint_col: ImVec4, flags: Int32): Int32
@FastNative
foreign func igSeparatorEx(flags: Int32, thickness: Float32): Unit
@FastNative
foreign func igSeparatorTextEx(id: UInt32, label: CString, label_end: CString, extra_width: Float32): Unit
@FastNative
foreign func igCheckboxFlags_S64Ptr(label: CString, flags: CPointer<Int64>, flags_value: Int64): Int32
@FastNative
foreign func igCheckboxFlags_U64Ptr(label: CString, flags: CPointer<UInt64>, flags_value: UInt64): Int32
@FastNative
foreign func igCloseButton(id: UInt32, pos: ImVec2): Int32
@FastNative
foreign func igCollapseButton(id: UInt32, pos: ImVec2): Int32
@FastNative
foreign func igScrollbar(axis: Int32): Unit
@FastNative
foreign func igScrollbarEx(bb: CPointer<Unit>, id: UInt32, axis: Int32, p_scroll_v: CPointer<Int64>, avail_v: Int64, contents_v: Int64, draw_rounding_flags: Int32): Int32
@FastNative
foreign func igGetWindowScrollbarRect(window: CPointer<Unit>, axis: Int32): CPointer<Unit>
@FastNative
foreign func igGetWindowScrollbarID(window: CPointer<Unit>, axis: Int32): UInt32
@FastNative
foreign func igGetWindowResizeCornerID(window: CPointer<Unit>, n: Int32): UInt32
@FastNative
foreign func igGetWindowResizeBorderID(window: CPointer<Unit>, dir: Int32): UInt32
@FastNative
foreign func igExtendHitBoxWhenNearViewportEdge(window: CPointer<Unit>, bb: CPointer<Unit>, threshold: Float32, axis: Int32): Unit
@FastNative
foreign func igButtonBehavior(bb: CPointer<Unit>, id: UInt32, out_hovered: CPointer<Int32>, out_held: CPointer<Int32>, flags: Int32): Int32
@FastNative
foreign func igDragBehavior(id: UInt32, data_type: Int32, p_v: CPointer<Unit>, v_speed: Float32, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32): Int32
@FastNative
foreign func igSliderBehavior(bb: CPointer<Unit>, id: UInt32, data_type: Int32, p_v: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>, format: CString, flags: Int32, out_grab_bb: CPointer<Unit>): Int32
@FastNative
foreign func igSplitterBehavior(bb: CPointer<Unit>, id: UInt32, axis: Int32, size1: CPointer<Float32>, size2: CPointer<Float32>, min_size1: Float32, min_size2: Float32, hover_extend: Float32, hover_visibility_delay: Float32, bg_col: UInt32): Int32
@FastNative
foreign func igTreeNodeBehavior(id: UInt32, flags: Int32, label: CString, label_end: CString): Int32
@FastNative
foreign func igTreeNodeDrawLineToChildNode(target_pos: ImVec2): Unit
@FastNative
foreign func igTreeNodeDrawLineToTreePop(data: CPointer<Unit>): Unit
@FastNative
foreign func igTreePushOverrideID(id: UInt32): Unit
@FastNative
foreign func igTreeNodeSetOpen(storage_id: UInt32, open: Int32): Unit
@FastNative
foreign func igTreeNodeUpdateNextOpen(storage_id: UInt32, flags: Int32): Int32
@FastNative
foreign func igDataTypeGetInfo(data_type: Int32): CPointer<Unit>
@FastNative
foreign func igDataTypeFormatString(buf: CPointer<Int8>, buf_size: Int32, data_type: Int32, p_data: CPointer<Unit>, format: CString): Int32
@FastNative
foreign func igDataTypeApplyOp(data_type: Int32, op: Int32, output: CPointer<Unit>, arg_1: CPointer<Unit>, arg_2: CPointer<Unit>): Unit
@FastNative
foreign func igDataTypeApplyFromText(buf: CString, data_type: Int32, p_data: CPointer<Unit>, format: CString, p_data_when_empty: CPointer<Unit>): Int32
@FastNative
foreign func igDataTypeCompare(data_type: Int32, arg_1: CPointer<Unit>, arg_2: CPointer<Unit>): Int32
@FastNative
foreign func igDataTypeClamp(data_type: Int32, p_data: CPointer<Unit>, p_min: CPointer<Unit>, p_max: CPointer<Unit>): Int32
@FastNative
foreign func igDataTypeIsZero(data_type: Int32, p_data: CPointer<Unit>): Int32
@FastNative
foreign func igInputTextEx(label: CString, hint: CString, buf: CPointer<Int8>, buf_size: Int32, size_arg: ImVec2, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32
@FastNative
foreign func igInputTextDeactivateHook(id: UInt32): Unit
@FastNative
foreign func igTempInputText(bb: CPointer<Unit>, id: UInt32, label: CString, buf: CPointer<Int8>, buf_size: UIntNative, flags: Int32, callback: CPointer<Unit>, user_data: CPointer<Unit>): Int32
@FastNative
foreign func igTempInputScalar(bb: CPointer<Unit>, id: UInt32, label: CString, data_type: Int32, p_data: CPointer<Unit>, format: CString, p_clamp_min: CPointer<Unit>, p_clamp_max: CPointer<Unit>): Int32
@FastNative
foreign func igTempInputIsActive(id: UInt32): Int32
@FastNative
foreign func igGetInputTextState(id: UInt32): CPointer<Unit>
@FastNative
foreign func igSetNextItemRefVal(data_type: Int32, p_data: CPointer<Unit>): Unit
@FastNative
foreign func igIsItemActiveAsInputText(): Int32
@FastNative
foreign func igColorTooltip(text: CString, col: CPointer<Float32>, flags: Int32): Unit
@FastNative
foreign func igColorEditOptionsPopup(col: CPointer<Float32>, flags: Int32): Unit
@FastNative
foreign func igColorPickerOptionsPopup(ref_col: CPointer<Float32>, flags: Int32): Unit
@FastNative
foreign func igSetNextItemColorMarker(col: UInt32): Unit
@FastNative
foreign func igShadeVertsLinearColorGradientKeepAlpha(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, gradient_p0: ImVec2, gradient_p1: ImVec2, col0: UInt32, col1: UInt32): Unit
@FastNative
foreign func igShadeVertsLinearUV(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, a: ImVec2, b: ImVec2, uv_a: ImVec2, uv_b: ImVec2, clamp: Int32): Unit
@FastNative
foreign func igShadeVertsTransformPos(draw_list: CPointer<Unit>, vert_start_idx: Int32, vert_end_idx: Int32, pivot_in: ImVec2, cos_a: Float32, sin_a: Float32, pivot_out: ImVec2): Unit
@FastNative
foreign func igGcCompactTransientMiscBuffers(): Unit
@FastNative
foreign func igGcCompactTransientWindowBuffers(window: CPointer<Unit>): Unit
@FastNative
foreign func igGcAwakeTransientWindowBuffers(window: CPointer<Unit>): Unit
@FastNative
foreign func igErrorLog(msg: CString): Int32
@FastNative
foreign func igErrorRecoveryStoreState(state_out: CPointer<Unit>): Unit
@FastNative
foreign func igErrorRecoveryTryToRecoverState(state_in: CPointer<Unit>): Unit
@FastNative
foreign func igErrorRecoveryTryToRecoverWindowState(state_in: CPointer<Unit>): Unit
@FastNative
foreign func igErrorCheckUsingSetCursorPosToExtendParentBoundaries(): Unit
@FastNative
foreign func igErrorCheckEndFrameFinalizeErrorTooltip(): Unit
@FastNative
foreign func igBeginErrorTooltip(): Int32
@FastNative
foreign func igEndErrorTooltip(): Unit
@FastNative
foreign func igDemoMarker(file: CString, line: Int32, section: CString): Unit
@FastNative
foreign func igDebugAllocHook(info: CPointer<Unit>, frame_count: Int32, ptr: CPointer<Unit>, size: UIntNative): Unit
@FastNative
foreign func igDebugDrawCursorPos(col: UInt32): Unit
@FastNative
foreign func igDebugDrawLineExtents(col: UInt32): Unit
@FastNative
foreign func igDebugDrawItemRect(col: UInt32): Unit
@FastNative
foreign func igDebugTextUnformattedWithLocateItem(line_begin: CString, line_end: CString): Unit
@FastNative
foreign func igDebugLocateItem(target_id: UInt32): Unit
@FastNative
foreign func igDebugLocateItemOnHover(target_id: UInt32): Unit
@FastNative
foreign func igDebugLocateItemResolveWithLastItem(): Unit
@FastNative
foreign func igDebugBreakClearData(): Unit
@FastNative
foreign func igDebugBreakButton(label: CString, description_of_location: CString): Int32
@FastNative
foreign func igDebugBreakButtonTooltip(keyboard_only: Int32, description_of_location: CString): Unit
@FastNative
foreign func igShowFontAtlas(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igDebugTextureIDToU64(tex_id: UInt64): UInt64
@FastNative
foreign func igDebugHookIdInfo(id: UInt32, data_type: Int32, data_id: CPointer<Unit>, data_id_end: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeColumns(columns: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeDrawList(window: CPointer<Unit>, viewport: CPointer<Unit>, draw_list: CPointer<Unit>, label: CString): Unit
@FastNative
foreign func igDebugNodeDrawCmdShowMeshAndBoundingBox(out_draw_list: CPointer<Unit>, draw_list: CPointer<Unit>, draw_cmd: CPointer<Unit>, show_mesh: Int32, show_aabb: Int32): Unit
@FastNative
foreign func igDebugNodeFont(font: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeFontGlyphsForSrcMask(font: CPointer<Unit>, baked: CPointer<Unit>, src_mask: Int32): Unit
@FastNative
foreign func igDebugNodeFontGlyph(font: CPointer<Unit>, glyph: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeTexture(tex: CPointer<Unit>, int_id: Int32, highlight_rect: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeStorage(storage: CPointer<Unit>, label: CString): Unit
@FastNative
foreign func igDebugNodeTabBar(tab_bar: CPointer<Unit>, label: CString): Unit
@FastNative
foreign func igDebugNodeTable(table: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeTableSettings(settings: CPointer<Unit>, table: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeInputTextState(state: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeTypingSelectState(state: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeMultiSelectState(state: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeWindow(window: CPointer<Unit>, label: CString): Unit
@FastNative
foreign func igDebugNodeWindowSettings(settings: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeWindowsList(windows: CPointer<Unit>, label: CString): Unit
@FastNative
foreign func igDebugNodeWindowsListByBeginStackParent(windows: CPointer<Unit>, windows_size: Int32, parent_in_begin_stack: CPointer<Unit>): Unit
@FastNative
foreign func igDebugNodeViewport(viewport: CPointer<Unit>): Unit
@FastNative
foreign func igDebugRenderKeyboardPreview(draw_list: CPointer<Unit>): Unit
@FastNative
foreign func igDebugRenderViewportThumbnail(draw_list: CPointer<Unit>, viewport: CPointer<Unit>, bb: CPointer<Unit>): Unit
@FastNative
foreign func ImFontLoader_ImFontLoader(): CPointer<Unit>
@FastNative
foreign func ImFontLoader_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasGetFontLoaderForStbTruetype(): CPointer<Unit>
@FastNative
foreign func igImFontAtlasRectId_GetIndex(id: Int32): Int32
@FastNative
foreign func igImFontAtlasRectId_GetGeneration(id: Int32): UInt32
@FastNative
foreign func igImFontAtlasRectId_Make(index_idx: Int32, gen_idx: Int32): Int32
@FastNative
foreign func ImFontAtlasBuilder_ImFontAtlasBuilder(): CPointer<Unit>
@FastNative
foreign func ImFontAtlasBuilder_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildInit(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildDestroy(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildMain(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildSetupFontLoader(atlas: CPointer<Unit>, font_loader: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildNotifySetFont(atlas: CPointer<Unit>, old_font: CPointer<Unit>, new_font: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildUpdatePointers(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildRenderBitmapFromString(atlas: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32, in_str: CString, in_marker_char: Int8): Unit
@FastNative
foreign func igImFontAtlasBuildClear(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasTextureAdd(atlas: CPointer<Unit>, w: Int32, h: Int32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasTextureMakeSpace(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasTextureRepack(atlas: CPointer<Unit>, w: Int32, h: Int32): Unit
@FastNative
foreign func igImFontAtlasTextureGrow(atlas: CPointer<Unit>, old_w: Int32, old_h: Int32): Unit
@FastNative
foreign func igImFontAtlasTextureCompact(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasTextureGetSizeEstimate(atlas: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igImFontAtlasBuildSetupFontSpecialGlyphs(atlas: CPointer<Unit>, font: CPointer<Unit>, src: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildLegacyPreloadAllGlyphRanges(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBuildGetOversampleFactors(src: CPointer<Unit>, baked: CPointer<Unit>, out_oversample_h: CPointer<Int32>, out_oversample_v: CPointer<Int32>): Unit
@FastNative
foreign func igImFontAtlasBuildDiscardBakes(atlas: CPointer<Unit>, unused_frames: Int32): Unit
@FastNative
foreign func igImFontAtlasFontSourceInit(atlas: CPointer<Unit>, src: CPointer<Unit>): Int32
@FastNative
foreign func igImFontAtlasFontSourceAddToFont(atlas: CPointer<Unit>, font: CPointer<Unit>, src: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasFontDestroySourceData(atlas: CPointer<Unit>, src: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasFontInitOutput(atlas: CPointer<Unit>, font: CPointer<Unit>): Int32
@FastNative
foreign func igImFontAtlasFontDestroyOutput(atlas: CPointer<Unit>, font: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasFontRebuildOutput(atlas: CPointer<Unit>, font: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasFontDiscardBakes(atlas: CPointer<Unit>, font: CPointer<Unit>, unused_frames: Int32): Unit
@FastNative
foreign func igImFontAtlasBakedGetId(font_id: UInt32, baked_size: Float32, rasterizer_density: Float32): UInt32
@FastNative
foreign func igImFontAtlasBakedGetOrAdd(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasBakedGetClosestMatch(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasBakedAdd(atlas: CPointer<Unit>, font: CPointer<Unit>, font_size: Float32, font_rasterizer_density: Float32, baked_id: UInt32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasBakedDiscard(atlas: CPointer<Unit>, font: CPointer<Unit>, baked: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBakedAddFontGlyph(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, in_glyph: CPointer<Unit>): CPointer<Unit>
@FastNative
foreign func igImFontAtlasBakedAddFontGlyphAdvancedX(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, codepoint: UInt16, advance_x: Float32): Unit
@FastNative
foreign func igImFontAtlasBakedDiscardFontGlyph(atlas: CPointer<Unit>, font: CPointer<Unit>, baked: CPointer<Unit>, glyph: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasBakedSetFontGlyphBitmap(atlas: CPointer<Unit>, baked: CPointer<Unit>, src: CPointer<Unit>, glyph: CPointer<Unit>, r: CPointer<Unit>, src_pixels: CPointer<Unit>, src_fmt: Int32, src_pitch: Int32): Unit
@FastNative
foreign func igImFontAtlasPackInit(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasPackAddRect(atlas: CPointer<Unit>, w: Int32, h: Int32, overwrite_entry: CPointer<Unit>): Int32
@FastNative
foreign func igImFontAtlasPackGetRect(atlas: CPointer<Unit>, id: Int32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasPackGetRectSafe(atlas: CPointer<Unit>, id: Int32): CPointer<Unit>
@FastNative
foreign func igImFontAtlasPackDiscardRect(atlas: CPointer<Unit>, id: Int32): Unit
@FastNative
foreign func igImFontAtlasUpdateNewFrame(atlas: CPointer<Unit>, frame_count: Int32, renderer_has_textures: Int32): Unit
@FastNative
foreign func igImFontAtlasAddDrawListSharedData(atlas: CPointer<Unit>, data: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasRemoveDrawListSharedData(atlas: CPointer<Unit>, data: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasUpdateDrawListsTextures(atlas: CPointer<Unit>, old_tex: CPointer<Unit>, new_tex: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasUpdateDrawListsSharedData(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasTextureBlockConvert(src_pixels: CPointer<Unit>, src_fmt: Int32, src_pitch: Int32, dst_pixels: CPointer<Unit>, dst_fmt: Int32, dst_pitch: Int32, w: Int32, h: Int32): Unit
@FastNative
foreign func igImFontAtlasTextureBlockPostProcess(data: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasTextureBlockPostProcessMultiply(data: CPointer<Unit>, multiply_factor: Float32): Unit
@FastNative
foreign func igImFontAtlasTextureBlockFill(dst_tex: CPointer<Unit>, dst_x: Int32, dst_y: Int32, w: Int32, h: Int32, col: UInt32): Unit
@FastNative
foreign func igImFontAtlasTextureBlockCopy(src_tex: CPointer<Unit>, src_x: Int32, src_y: Int32, dst_tex: CPointer<Unit>, dst_x: Int32, dst_y: Int32, w: Int32, h: Int32): Unit
@FastNative
foreign func igImFontAtlasTextureBlockQueueUpload(atlas: CPointer<Unit>, tex: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32): Unit
@FastNative
foreign func igImTextureDataUpdateNewFrame(tex: CPointer<Unit>): Int32
@FastNative
foreign func igImTextureDataQueueUpload(tex: CPointer<Unit>, x: Int32, y: Int32, w: Int32, h: Int32): Unit
@FastNative
foreign func igImTextureDataGetFormatBytesPerPixel(format: Int32): Int32
@FastNative
foreign func igImTextureDataGetStatusName(status: Int32): CString
@FastNative
foreign func igImTextureDataGetFormatName(format: Int32): CString
@FastNative
foreign func igImFontAtlasDebugLogTextureRequests(atlas: CPointer<Unit>): Unit
@FastNative
foreign func igImFontAtlasGetMouseCursorTexData(atlas: CPointer<Unit>, cursor_type: Int32, out_offset: CPointer<ImVec2>, out_size: CPointer<ImVec2>, out_uv_border: CPointer<Unit>, out_uv_fill: CPointer<Unit>): Int32
@FastNative
foreign func igGET_FLT_MAX(): Float32
@FastNative
foreign func igGET_FLT_MIN(): Float32
@FastNative
foreign func ImVector_ImWchar_create(): CPointer<Unit>
@FastNative
foreign func ImVector_ImWchar_destroy(self: CPointer<Unit>): Unit
@FastNative
foreign func ImVector_ImWchar_Init(p: CPointer<Unit>): Unit
@FastNative
foreign func ImVector_ImWchar_UnInit(p: CPointer<Unit>): Unit

// =============================================================================
// ImGui_ImplSDL3_* 函数（cimgui_impl.h，共 12 个）
// =============================================================================

@FastNative
foreign func ImGui_ImplSDL3_InitForD3D(window: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForMetal(window: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForOpenGL(window: CPointer<Unit>, sdl_gl_context: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForOther(window: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForSDLGPU(window: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForSDLRenderer(window: CPointer<Unit>, renderer: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_InitForVulkan(window: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_NewFrame(): Unit
@FastNative
foreign func ImGui_ImplSDL3_ProcessEvent(event: CPointer<Unit>): Int32
@FastNative
foreign func ImGui_ImplSDL3_SetGamepadMode(mode: Int32, manual_gamepads_array: CPointer<Unit>, manual_gamepads_count: Int32): Unit
@FastNative
foreign func ImGui_ImplSDL3_SetMouseCaptureMode(mode: Int32): Unit
@FastNative
foreign func ImGui_ImplSDL3_Shutdown(): Unit

// =============================================================================
// imgui_impl_bgfx C API（cxx/imgui_impl_bgfx/imgui_impl_bgfx_capi.cpp）
// =============================================================================

@FastNative
foreign func imgui_cj_impl_bgfx_init(auto_shader: Int32, starting_view_id: Int32, max_views: Int32): Int32
@FastNative
foreign func imgui_cj_impl_bgfx_shutdown(): Unit
@FastNative
foreign func imgui_cj_impl_bgfx_render_draw_data(): Unit
