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
 * @file[zh-cn] ImGuiWrappers.cj — 本地 ImGui 高级包装函数
 * @brief[zh-cn] 封装 ig*_cj 公共包装函数，提供 String 参数自动 CString 转换的便捷接口
 * @explain[zh-cn] 当 imgui4cj 远程版本尚未包含这些包装时，在此本地定义。所有函数接受 Cangjie String 参数并自动完成 CString 转换与内存释放。
 *
 * @file[en] ImGuiWrappers.cj — Local ImGui High-Level Wrappers
 * @brief[en] Wraps ig*_cj public functions with automatic String-to-CString conversion
 * @explain[en] Defined locally when the remote imgui4cj version lacks these wrappers. All functions accept Cangjie String and handle CString allocation/release internally.
 */
package three.window.ui

import std.core.*
import imgui4cj.imgui.*

// ===== Separator / Spacing / SameLine =====

internal func ImGui_Separator_cj(): Unit { unsafe { igSeparator_cj() } }

internal func ImGui_SameLine_cj(offset: Float32, spacing: Float32): Unit {
    unsafe { igSameLine_cj(offset, spacing) }
}

internal func ImGui_Spacing_cj(): Unit { unsafe { igSpacing_cj() } }

// ===== Columns =====

internal func ImGui_Columns_cj(count: Int32, id: String, borders: Int32): Unit {
    unsafe {
        let cs = LibC.mallocCString(id)
        igColumns_cj(count, cs, borders)
        LibC.free(cs)
    }
}

// ===== SliderInt =====

internal func ImGui_SliderInt_cj(label: String, v: CPointer<Int32>,
                              v_min: Int32, v_max: Int32,
                              format: String, flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igSliderInt_cj(csLabel, v, v_min, v_max, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

// ===== InputText =====

internal func ImGui_InputText_cj(label: String, buf: CPointer<Int8>,
                              buf_size: UIntNative, flags: Int32,
                              callback: CPointer<Unit>,
                              user_data: CPointer<Unit>): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igInputText_cj(cs, buf, buf_size, flags, callback, user_data)
        LibC.free(cs)
        r
    }
}

// ===== InputTextWithHint =====

internal func ImGui_InputTextWithHint_cj(label: String, hint: String,
                                      buf: CPointer<Int8>,
                                      buf_size: UIntNative, flags: Int32,
                                      callback: CPointer<Unit>,
                                      user_data: CPointer<Unit>): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csHint = LibC.mallocCString(hint)
        let r = igInputTextWithHint_cj(csLabel, csHint, buf, buf_size, flags, callback, user_data)
        LibC.free(csLabel)
        LibC.free(csHint)
        r
    }
}

// ===== InputFloat =====

internal func ImGui_InputFloat_cj(label: String, v: CPointer<Float32>,
                               step: Float32, step_fast: Float32,
                               format: String, flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igInputFloat_cj(csLabel, v, step, step_fast, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

// ===== Combo_Str =====

internal func ImGui_Combo_Str_cj(label: String, current_item: CPointer<Int32>,
                               items_separated_by_zeros: String,
                               popup_max_height_in_items: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csItems = LibC.mallocCString(items_separated_by_zeros)
        let r = igCombo_Str_cj(csLabel, current_item, csItems, popup_max_height_in_items)
        LibC.free(csLabel)
        LibC.free(csItems)
        r
    }
}

// ===== Selectable_Bool =====

internal func ImGui_Selectable_Bool_cj(label: String, selected: Int32,
                                     flags: Int32, size: ImVec2): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igSelectable_Bool_cj(cs, selected, flags, size)
        LibC.free(cs)
        r
    }
}

// ===== BeginDisabled / EndDisabled =====

internal func ImGui_BeginDisabled_cj(disabled: Int32): Unit {
    unsafe { igBeginDisabled_cj(disabled) }
}

internal func ImGui_EndDisabled_cj(): Unit {
    unsafe { igEndDisabled_cj() }
}

// ===== ClipRect =====

internal func ImGui_PushClipRect_cj(clip_rect_min: ImVec2,
                                  clip_rect_max: ImVec2,
                                  intersect_with_current_clip_rect: Int32): Unit {
    unsafe { igPushClipRect_cj(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect) }
}

internal func ImGui_PopClipRect_cj(): Unit { unsafe { igPopClipRect_cj() } }

// ===== SetNextItemWidth / SetNextItemOpen =====

internal func ImGui_SetNextItemWidth_cj(item_width: Float32): Unit {
    unsafe { igSetNextItemWidth_cj(item_width) }
}

internal func ImGui_SetNextItemOpen_cj(is_open: Int32, cond: Int32): Unit {
    unsafe { igSetNextItemOpen_cj(is_open, cond) }
}

// ===== SeparatorText =====

internal func ImGui_SeparatorText_cj(label: String): Unit {
    unsafe {
        let cs = LibC.mallocCString(label)
        igSeparatorText_cj(cs)
        LibC.free(cs)
    }
}

// ===== Tooltip =====

internal func ImGui_BeginItemTooltip_cj(): Int32 {
    return unsafe { igBeginItemTooltip_cj() }
}

internal func ImGui_EndTooltip_cj(): Unit { unsafe { igEndTooltip_cj() } }

internal func ImGui_SetTooltip0_cj(fmt: String): Unit {
    unsafe {
        let cs = LibC.mallocCString(fmt)
        igSetTooltip0_cj(cs)
        LibC.free(cs)
    }
}

// ===== Tree =====

internal func ImGui_TreeNode_Str_cj(label: String): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igTreeNode_Str_cj(cs)
        LibC.free(cs)
        r
    }
}

internal func ImGui_TreeNodeEx_Str_cj(label: String, flags: Int32): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igTreeNodeEx_Str_cj(cs, flags)
        LibC.free(cs)
        r
    }
}

internal func ImGui_TreePop_cj(): Unit { unsafe { igTreePop_cj() } }

internal func ImGui_CollapsingHeader_TreeNodeFlags_cj(label: String, flags: Int32): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igCollapsingHeader_TreeNodeFlags_cj(cs, flags)
        LibC.free(cs)
        r
    }
}

// ===== ProgressBar =====

internal func ImGui_ProgressBar_cj(fraction: Float32, size_arg: ImVec2,
                                 overlay: String): Unit {
    unsafe {
        let cs = LibC.mallocCString(overlay)
        igProgressBar_cj(fraction, size_arg, cs)
        LibC.free(cs)
    }
}

// ===== PlotLines / PlotHistogram =====

internal func ImGui_PlotLines_FloatPtr_cj(label: String,
                                       values: CPointer<Float32>,
                                       values_count: Int32,
                                       values_offset: Int32,
                                       overlay_text: String,
                                       scale_min: Float32,
                                       scale_max: Float32,
                                       graph_size: ImVec2,
                                       stride: Int32): Unit {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csOverlay = LibC.mallocCString(overlay_text)
        igPlotLines_FloatPtr_cj(csLabel, values, values_count, values_offset,
                             csOverlay, scale_min, scale_max, graph_size, stride)
        LibC.free(csLabel)
        LibC.free(csOverlay)
    }
}

internal func ImGui_PlotHistogram_FloatPtr_cj(label: String,
                                           values: CPointer<Float32>,
                                           values_count: Int32,
                                           values_offset: Int32,
                                           overlay_text: String,
                                           scale_min: Float32,
                                           scale_max: Float32,
                                           graph_size: ImVec2,
                                           stride: Int32): Unit {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csOverlay = LibC.mallocCString(overlay_text)
        igPlotHistogram_FloatPtr_cj(csLabel, values, values_count, values_offset,
                                 csOverlay, scale_min, scale_max, graph_size, stride)
        LibC.free(csLabel)
        LibC.free(csOverlay)
    }
}

// ===== Value_Float =====

internal func ImGui_Value_Float_cj(prefix: String, v: Float32,
                                 float_format: String): Unit {
    unsafe {
        let csPrefix = LibC.mallocCString(prefix)
        let csFmt = LibC.mallocCString(float_format)
        igValue_Float_cj(csPrefix, v, csFmt)
        LibC.free(csPrefix)
        LibC.free(csFmt)
    }
}

// ===== DragFloat / DragInt =====

internal func ImGui_DragFloat_cj(label: String, v: CPointer<Float32>,
                               v_speed: Float32, v_min: Float32,
                               v_max: Float32, format: String,
                               flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igDragFloat_cj(csLabel, v, v_speed, v_min, v_max, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

internal func ImGui_DragInt_cj(label: String, v: CPointer<Int32>,
                             v_speed: Float32, v_min: Int32,
                             v_max: Int32, format: String,
                             flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igDragInt_cj(csLabel, v, v_speed, v_min, v_max, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

// ===== InputInt / InputDouble =====

internal func ImGui_InputInt_cj(label: String, v: CPointer<Int32>,
                              step: Int32, step_fast: Int32,
                              flags: Int32): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igInputInt_cj(cs, v, step, step_fast, flags)
        LibC.free(cs)
        r
    }
}

internal func ImGui_InputDouble_cj(label: String, v: CPointer<Float64>,
                                 step: Float64, step_fast: Float64,
                                 format: String, flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igInputDouble_cj(csLabel, v, step, step_fast, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

// ===== VSliderFloat =====

internal func ImGui_VSliderFloat_cj(label: String, size: ImVec2,
                                  v: CPointer<Float32>,
                                  v_min: Float32, v_max: Float32,
                                  format: String, flags: Int32): Int32 {
    unsafe {
        let csLabel = LibC.mallocCString(label)
        let csFmt = LibC.mallocCString(format)
        let r = igVSliderFloat_cj(csLabel, size, v, v_min, v_max, csFmt, flags)
        LibC.free(csLabel)
        LibC.free(csFmt)
        r
    }
}

// ===== ColorEdit4 / ColorPicker4 =====

internal func ImGui_ColorEdit4_cj(label: String, col: CPointer<Float32>,
                                flags: Int32): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igColorEdit4_cj(cs, col, flags)
        LibC.free(cs)
        r
    }
}

internal func ImGui_ColorPicker4_cj(label: String, col: CPointer<Float32>,
                                  flags: Int32,
                                  ref_col: CPointer<Float32>): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igColorPicker4_cj(cs, col, flags, ref_col)
        LibC.free(cs)
        r
    }
}

// ===== ListBox_Str_arr =====

internal func ImGui_ListBox_Str_arr_cj(label: String,
                                     current_item: CPointer<Int32>,
                                     items: CPointer<Unit>,
                                     items_count: Int32,
                                     height_in_items: Int32): Int32 {
    unsafe {
        let cs = LibC.mallocCString(label)
        let r = igListBox_Str_arr_cj(cs, current_item, items, items_count, height_in_items)
        LibC.free(cs)
        r
    }
}

// ===== ItemQuery =====

internal func ImGui_IsItemHovered_cj(flags: Int32): Int32 {
    return unsafe { igIsItemHovered_cj(flags) }
}

internal func ImGui_IsItemActive_cj(): Int32 { return unsafe { igIsItemActive_cj() } }

internal func ImGui_IsItemFocused_cj(): Int32 { return unsafe { igIsItemFocused_cj() } }

internal func ImGui_IsItemClicked_cj(mouse_button: Int32): Int32 {
    return unsafe { igIsItemClicked_cj(mouse_button) }
}

internal func ImGui_IsItemVisible_cj(): Int32 { return unsafe { igIsItemVisible_cj() } }

internal func ImGui_IsItemEdited_cj(): Int32 { return unsafe { igIsItemEdited_cj() } }

internal func ImGui_IsItemActivated_cj(): Int32 { return unsafe { igIsItemActivated_cj() } }

internal func ImGui_IsItemDeactivated_cj(): Int32 { return unsafe { igIsItemDeactivated_cj() } }

internal func ImGui_IsItemDeactivatedAfterEdit_cj(): Int32 {
    return unsafe { igIsItemDeactivatedAfterEdit_cj() }
}

internal func ImGui_IsItemToggledOpen_cj(): Int32 { return unsafe { igIsItemToggledOpen_cj() } }

internal func ImGui_IsAnyItemHovered_cj(): Int32 { return unsafe { igIsAnyItemHovered_cj() } }

internal func ImGui_IsAnyItemActive_cj(): Int32 { return unsafe { igIsAnyItemActive_cj() } }

internal func ImGui_IsAnyItemFocused_cj(): Int32 { return unsafe { igIsAnyItemFocused_cj() } }

internal func ImGui_GetItemID_cj(): UInt32 { return unsafe { igGetItemID_cj() } }

internal func ImGui_GetItemRectMin_cj(): ImVec2 { return unsafe { igGetItemRectMin_cj() } }

internal func ImGui_GetItemRectMax_cj(): ImVec2 { return unsafe { igGetItemRectMax_cj() } }

internal func ImGui_GetItemRectSize_cj(): ImVec2 { return unsafe { igGetItemRectSize_cj() } }

internal func ImGui_SetItemDefaultFocus_cj(): Unit { unsafe { igSetItemDefaultFocus_cj() } }

internal func ImGui_SetNextItemAllowOverlap_cj(): Unit {
    unsafe { igSetNextItemAllowOverlap_cj() }
}

// ===== Window (ImGui_Begin_cj / ImGui_End_cj 已在 ffi_exports.cj 中定义，无需重复) =====
