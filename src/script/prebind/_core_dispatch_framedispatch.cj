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
 * @file[zh-cn] core_dispatch_framedispatch 帧调度器 FrameDispatch 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dispatch.FrameDispatch 绑定为 Lua 类型
 * three.core.dispatch.FrameDispatch
 * @explain[zh-cn] 覆盖构造（new/可选时间预算 maximum）、属性（maximum 可读写，
 * frameElapsed/activeTaskCount/pausedTaskCount 只读）与方法（unregister/pause/resume/
 * clear/frameEvent）。register/registerTask 跳过：其参数为回调函数与 ICircularQueue
 * 参数队列（容器，无 Lua 通道）。枚举 FrameTaskMode 与类 FrameTask/FrameTaskContext
 * 不绑定：构造依赖回调/容器，Lua 侧无入口。
 *
 * @file[en] core_dispatch_framedispatch  Lua binding of the frame dispatcher FrameDispatch
 * (three.script.prebind)
 * @brief[en] Binds three.core.dispatch.FrameDispatch as the Lua type
 * three.core.dispatch.FrameDispatch
 * @explain[en] Covers construction (new / optional time budget maximum), properties
 * (maximum read-write; frameElapsed/activeTaskCount/pausedTaskCount read-only) and methods
 * (unregister/pause/resume/clear/frameEvent). register/registerTask are omitted: their
 * parameters are callbacks and an ICircularQueue parameter queue (containers, no Lua
 * channel). Enum FrameTaskMode and classes FrameTask/FrameTaskContext are not bound:
 * construction depends on callbacks/containers with no Lua entry point.
 */
package three.script.prebind

import three.core.dispatch.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FrameDispatch 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dispatch.FrameDispatch）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FrameDispatch
 * @param[en] vm The target virtual machine (class table installed at three.core.dispatch.FrameDispatch)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFrameDispatch(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dispatch.FrameDispatch")
    // ===== 构造 =====
    b.constructor {args => FrameDispatch(maximum: prebindNum(args, 0, default: 5.0))}
    // ===== 属性 =====
    b.property("maximum", getter: Some({ref => LuaValue.of(ref.cast<FrameDispatch>().maximum)}),
        setter: Some({ref, v => ref.cast<FrameDispatch>().maximum = v.numberValue()}))
    b.property("frameElapsed", getter: Some({ref => LuaValue.of(ref.cast<FrameDispatch>().frameElapsed)}))
    b.property("activeTaskCount", getter: Some({ref => LuaValue.of(ref.cast<FrameDispatch>().activeTaskCount)}))
    b.property("pausedTaskCount", getter: Some({ref => LuaValue.of(ref.cast<FrameDispatch>().pausedTaskCount)}))
    // ===== 任务管理 =====
    b.method("unregister") {
        ref, args =>
            ref.cast<FrameDispatch>().unregister(args[0].intValue())
            []
    }
    b.method("pause") {
        ref, args =>
            ref.cast<FrameDispatch>().pause(args[0].intValue())
            []
    }
    b.method("resume") {
        ref, args =>
            ref.cast<FrameDispatch>().resume(args[0].intValue())
            []
    }
    b.method("clear") {
        ref, _ =>
            ref.cast<FrameDispatch>().clear()
            []
    }
    // ===== 帧调度 =====
    b.method("frameEvent") {
        ref, args =>
            ref.cast<FrameDispatch>().frameEvent(deltaTime: prebindNum(args, 0, default: 0.0))
            []
    }
    b.install(vm)
}
