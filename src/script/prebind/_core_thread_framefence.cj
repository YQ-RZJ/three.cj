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
 * @file[zh-cn] core_thread_framefence 帧栅栏 FrameFence 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.thread.FrameFence 绑定为 Lua 类型 three.core.thread.FrameFence
 * @explain[zh-cn] 覆盖构造（new）与方法（submit/advance/advanceBy/waitUntil/done/submitted/
 * broadcastAll），含序号（Int64）查询与推进。无公开属性、无回调/容器依赖。
 *
 * @file[en] core_thread_framefence  Lua binding of the frame fence FrameFence
 * (three.script.prebind)
 * @brief[en] Binds three.core.thread.FrameFence as the Lua type three.core.thread.FrameFence
 * @explain[en] Covers construction (new) and methods (submit/advance/advanceBy/waitUntil/
 * done/submitted/broadcastAll) with sequence (Int64) query and advancement. No public
 * properties and no callback/container dependencies.
 */
package three.script.prebind

import three.core.thread.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FrameFence 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.thread.FrameFence）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FrameFence
 * @param[en] vm The target virtual machine (class table installed at three.core.thread.FrameFence)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFrameFence(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.thread.FrameFence")
    // ===== 构造 =====
    b.constructor {_ => FrameFence()}
    // ===== 提交/推进 =====
    b.method("submit") {
        ref, _ => [LuaValue.of(ref.cast<FrameFence>().submit())]
    }
    b.method("advance") {
        ref, _ =>
            ref.cast<FrameFence>().advance()
            []
    }
    b.method("advanceBy") {
        ref, args =>
            ref.cast<FrameFence>().advanceBy(args[0].intValue())
            []
    }
    // ===== 等待 =====
    b.method("waitUntil") {
        ref, args =>
            ref.cast<FrameFence>().waitUntil(args[0].intValue())
            []
    }
    b.method("broadcastAll") {
        ref, _ =>
            ref.cast<FrameFence>().broadcastAll()
            []
    }
    // ===== 序号查询 =====
    b.method("done") {
        ref, _ => [LuaValue.of(ref.cast<FrameFence>().done())]
    }
    b.method("submitted") {
        ref, _ => [LuaValue.of(ref.cast<FrameFence>().submitted())]
    }
    b.install(vm)
}
