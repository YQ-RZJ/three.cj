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
 * @file[zh-cn] window_ui_uipayload UiPayload.cj 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 把 three.window.ui.UiPayload 绑定为 Lua 类型 three.window.ui.UiPayload
 * @explain[zh-cn] 覆盖：静态工厂 getCurrentPayload()，实例方法 isValid()/isDataType(dataType)/
 * isPreview()/isDelivery()/clear()。适配约定：
 * - 源码构造参数为 VoidPtr，脚本侧不提供 constructor，实例只能经 getCurrentPayload() 获取
 *   （在 BeginDragDropTarget/EndDragDropTarget 内调用）；
 * - isDataType 接收 Lua 字符串，Bool 结果以 Lua 布尔返回；
 * - 载荷的二进制内容与底层字段在 Cangjie 公共面没有读取接口（ImGuiPayload 的 Data/DataSize 等
 *   字段未封装为 public 方法），因此 Lua 侧无法读取载荷内容，只做类型/状态查询与清空。
 * 跳过成员及原因：
 * - 无 public 成员因类型不可映射而被跳过；
 * - 载荷二进制数据无 public 访问器，无法绑定（文件头已说明）；
 * - private 字段 _payload 不暴露。
 *
 * @file[en] window_ui_uipayload  Lua binding of UiPayload.cj (three.script.prebind)
 * @brief[en] Binds three.window.ui.UiPayload as the Lua type three.window.ui.UiPayload
 * @explain[en] Coverage: static factory getCurrentPayload() and instance methods isValid()/
 * isDataType(dataType)/isPreview()/isDelivery()/clear(). Conventions:
 * - The source constructor takes a VoidPtr, so no constructor is exposed; instances come from
 *   getCurrentPayload() only (call it inside BeginDragDropTarget/EndDragDropTarget);
 * - isDataType takes a Lua string and returns a Lua boolean;
 * - The payload's binary content and underlying fields have no read accessor in the Cangjie public
 *   API (ImGuiPayload's Data/DataSize etc. are not wrapped as public methods), so Lua can only query
 *   type/state and clear the payload, not read its contents.
 * Skipped members and reasons:
 * - No public member is skipped for unmappable types;
 * - The payload binary data has no public accessor and cannot be bound (noted in the file header);
 * - The private field _payload is not exposed.
 */
package three.script.prebind

import three.window.ui.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 UiPayload 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.window.ui.UiPayload）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UiPayload
 * @param[en] vm The target virtual machine (class table installed at three.window.ui.UiPayload)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUiPayload(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.window.ui.UiPayload")
    b.staticMethod("getCurrentPayload") {
        _ => [prebindRegister(UiPayload.getCurrentPayload(), "three.window.ui.UiPayload")]
    }
    b.method("isValid") {ref, _ => [LuaValue.of(ref.cast<UiPayload>().isValid())]}
    b.method("isDataType") {
        ref, args => [LuaValue.of(ref.cast<UiPayload>().isDataType(prebindStr(args, 0)))]
    }
    b.method("isPreview") {ref, _ => [LuaValue.of(ref.cast<UiPayload>().isPreview())]}
    b.method("isDelivery") {ref, _ => [LuaValue.of(ref.cast<UiPayload>().isDelivery())]}
    b.method("clear") {
        ref, _ =>
            ref.cast<UiPayload>().clear()
            []
    }
    b.install(vm)
}
