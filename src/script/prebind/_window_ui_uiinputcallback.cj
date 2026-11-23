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
 * @file[zh-cn] window_ui_uiinputcallback UiInputCallback.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiInputTextCallback 绑定为 Lua 类型
 *   three.window.ui.UiInputTextCallback
 * @explain[zh-cn] 覆盖：全部 public 实例方法——isValid、selectAll/clearSelection/hasSelection、
 * setSelection、deleteChars、insertChars、getEventFlag/getEventKey/getEventChar/setEventChar、
 * getBufTextLen/getBufSize/getBufText、getCursorPos/setCursorPos、getSelectionStart/getSelectionEnd、
 * setSelectionRange。适配约定：
 * - 源码构造参数为 VoidPtr，脚本侧不提供 constructor，实例应在 igInputText 回调内由回调参数获取；
 * - Int32 以 Int64(...) 返回、Int32(...) 回写；UInt16 事件字符以 Int64(...) 返回、
 *   UInt16(数字 & 0xFFFF) 回写；getBufText() 返回 String 可直接绑定；
 * - 方法内异常不逃逸到 Lua（简单 FFI 调用沿用同目录绑定写法）。
 * 跳过成员及原因：
 * - internal getBuf() 返回裸 CPointer<UInt8>，缓冲区所有权归 ImGui，不属于脚本接口（读文本请用
 *   getBufText()），故不绑定；
 * - private 字段 _data 不暴露。
 *
 * @file[en] window_ui_uiinputcallback  Lua binding of UiInputCallback.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiInputTextCallback as the Lua type
 *   three.window.ui.UiInputTextCallback
 * @explain[en] Coverage: every public instance method — isValid, selectAll/clearSelection/
 * hasSelection, setSelection, deleteChars, insertChars, getEventFlag/getEventKey/getEventChar/
 * setEventChar, getBufTextLen/getBufSize/getBufText, getCursorPos/setCursorPos,
 * getSelectionStart/getSelectionEnd and setSelectionRange. Conventions:
 * - The source constructor takes a VoidPtr, so no constructor is exposed; instances are obtained
 *   from the callback parameter inside an igInputText callback;
 * - Int32 is returned as Int64(...) and written back with Int32(...); the UInt16 event character is
 *   returned as Int64(...) and written back with UInt16(number & 0xFFFF); getBufText() returns a
 *   String and is bound directly;
 * - Exceptions do not escape to Lua (simple FFI calls follow the sibling binding style).
 * Skipped members and reasons:
 * - The internal getBuf() returns a raw CPointer<UInt8> owned by ImGui and is not a script API
 *   (use getBufText() for reading text) — not bound;
 * - The private field _data is not exposed.
 */
package three.script.prebind

import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UiInputTextCallback 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiInputTextCallback）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiInputTextCallback
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiInputTextCallback)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiInputTextCallback(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiInputTextCallback")
    b.method("isValid") {ref, _ => [LuaValue.of(ref.cast<UiInputTextCallback>().isValid())]}

    // ===== 选区 / Selection =====
    b.method("selectAll") {
        ref, _ =>
            ref.cast<UiInputTextCallback>().selectAll()
            []
    }
    b.method("clearSelection") {
        ref, _ =>
            ref.cast<UiInputTextCallback>().clearSelection()
            []
    }
    b.method("hasSelection") {
        ref, _ => [LuaValue.of(ref.cast<UiInputTextCallback>().hasSelection())]
    }
    b.method("setSelection") {
        ref, args =>
            ref.cast<UiInputTextCallback>().setSelection(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            []
    }

    // ===== 文本编辑 / Text editing =====
    b.method("deleteChars") {
        ref, args =>
            ref.cast<UiInputTextCallback>().deleteChars(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            []
    }
    b.method("insertChars") {
        ref, args =>
            ref.cast<UiInputTextCallback>().insertChars(Int32(prebindInt(args, 0)), prebindStr(args, 1))
            []
    }

    // ===== 事件字段 / Event fields =====
    b.method("getEventFlag") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getEventFlag()))]
    }
    b.method("getEventKey") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getEventKey()))]
    }
    b.method("getEventChar") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getEventChar()))]
    }
    b.method("setEventChar") {
        ref, args =>
            ref.cast<UiInputTextCallback>().setEventChar(UInt16(prebindInt(args, 0) & 0xFFFF))
            []
    }

    // ===== 文本缓冲 / Text buffer =====
    b.method("getBufTextLen") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getBufTextLen()))]
    }
    b.method("getBufSize") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getBufSize()))]
    }
    b.method("getBufText") {ref, _ => [LuaValue.of(ref.cast<UiInputTextCallback>().getBufText())]}

    // ===== 光标与选区位置 / Cursor and selection positions =====
    b.method("getCursorPos") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getCursorPos()))]
    }
    b.method("setCursorPos") {
        ref, args =>
            ref.cast<UiInputTextCallback>().setCursorPos(Int32(prebindInt(args, 0)))
            []
    }
    b.method("getSelectionStart") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getSelectionStart()))]
    }
    b.method("getSelectionEnd") {
        ref, _ => [LuaValue.of(Int64(ref.cast<UiInputTextCallback>().getSelectionEnd()))]
    }
    b.method("setSelectionRange") {
        ref, args =>
            ref.cast<UiInputTextCallback>().setSelectionRange(Int32(prebindInt(args, 0)), Int32(prebindInt(args, 1)))
            []
    }
    b.install(vm)
}
