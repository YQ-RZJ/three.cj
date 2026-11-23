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
 * @file[zh-cn] animation_skeletal_eventsystem 动画事件系统 AnimationEventSystem 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.animation.skeletal.AnimationEventSystem 绑定为 Lua 类型
 * @explain[zh-cn] addEvent / onComplete 的 (String) -> Unit 回调经 LuaCallback.fromValue
 * 包装为可调用 Lua 闭包；checkEvents / clearEvents / clearAll / resetTriggered 为纯参数
 * 方法直接透传。
 * 跳过：AnimationEvent / AnimationCompleteCallback —— 二者的构造必须传入仓颉闭包，
 * 且仅作为事件系统内部条目存在，Lua 侧无需直接构造。
 *
 * @file[en] animation_skeletal_eventsystem  Lua binding of the animation event system
 * AnimationEventSystem (three.script.prebind)
 * @brief[en] Binds three.animation.skeletal.AnimationEventSystem as a Lua type
 * @explain[en] The (String) -> Unit callbacks of addEvent / onComplete are wrapped into
 * callable Lua closures through LuaCallback.fromValue; checkEvents / clearEvents / clearAll /
 * resetTriggered are plain parameter methods passed straight through.
 * Skipped: AnimationEvent / AnimationCompleteCallback — both require a Cangjie closure when
 * constructed and only exist as internal entries of the event system, so Lua never needs to
 * build them directly.
 */
package three.script.prebind

import three.animation.skeletal.AnimationEventSystem
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AnimationEventSystem 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.skeletal.AnimationEventSystem）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationEventSystem
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.skeletal.AnimationEventSystem)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationEventSystem(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.skeletal.AnimationEventSystem")
    b.constructor {_ => AnimationEventSystem()}
    // ===== 帧事件注册（Lua 函数经 LuaCallback 包装） =====
    b.method("addEvent") {
        ref, args =>
            let listener = args[3]
            ref.cast<AnimationEventSystem>().addEvent(
                prebindStr(args, 0),
                prebindStr(args, 1),
                Float32(prebindNum(args, 2)),
                {
                    name: String =>
                        let cb = LuaCallback.fromValue(vm, listener)
                        if (let Some(c) <- cb) {
                            try {
                                c.call(args: [LuaValue.Str(name)])
                            } catch (_: Exception) {
                                // 回调异常不影响事件系统继续运行
                            }
                        }
                }
            )
            Array<LuaValue>()
    }
    // ===== 完成回调注册 =====
    b.method("onComplete") {
        ref, args =>
            let listener = args[1]
            ref.cast<AnimationEventSystem>().onComplete(
                prebindStr(args, 0),
                {
                    name: String =>
                        let cb = LuaCallback.fromValue(vm, listener)
                        if (let Some(c) <- cb) {
                            try {
                                c.call(args: [LuaValue.Str(name)])
                            } catch (_: Exception) {
                                // 回调异常不影响事件系统继续运行
                            }
                        }
                }
            )
            Array<LuaValue>()
    }
    // ===== 每帧检测 =====
    b.method("checkEvents") {
        ref, args =>
            ref
                .cast<AnimationEventSystem>()
                .checkEvents(prebindStr(args, 0), Float32(prebindNum(args, 1)), Float32(prebindNum(args, 2)),
                    prebindBool(args, 3))
            Array<LuaValue>()
    }
    // ===== 清理 =====
    b.method("clearEvents") {
        ref, args =>
            ref.cast<AnimationEventSystem>().clearEvents(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.method("clearAll") {
        ref, _ =>
            ref.cast<AnimationEventSystem>().clearAll()
            Array<LuaValue>()
    }
    b.method("resetTriggered") {
        ref, args =>
            ref.cast<AnimationEventSystem>().resetTriggered(prebindStr(args, 0))
            Array<LuaValue>()
    }
    b.install(vm)
}
