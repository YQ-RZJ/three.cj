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
 * @file[zh-cn] renderers_postprocessing_clearpass 清屏 pass ClearPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.ClearPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([clearColor[, clearAlpha]])（两个均为命名可选参数，缺省为透明黑 /
 * 0.0），绑定 clearColor（UInt32，0xAABBGGRR）/ clearAlpha 属性，并复用
 * _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：clear 操作发生在 render 内，由 EffectComposer.render 在渲染线程执行，且需引擎已完成
 * bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(renderer, writeBuffer, readBuffer, deltaTime)：参数含 FrameBufferHandle，无 Lua 通道；
 * - 私有常量 CLEAR_VIEW_ID 与内部 view 分配策略不对脚本暴露（composer 链内部使用）。
 *
 * @file[en] renderers_postprocessing_clearpass  Lua binding of the clear pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.ClearPass as a Lua type
 * @explain[en] Constructor new([clearColor[, clearAlpha]]) (both named optionals, defaulting to
 * transparent black / 0.0); binds the clearColor (UInt32, 0xAABBGGRR) / clearAlpha properties and
 * reuses _prebindPpPassMembers for the Pass base members.
 * Precondition: the clear happens inside render, driven by EffectComposer.render on the render
 * thread, and requires completed bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(renderer, writeBuffer, readBuffer, deltaTime): FrameBufferHandle parameters have no Lua
 *   channel;
 * - the private CLEAR_VIEW_ID constant and the view allocation strategy are composer internals and
 *   not exposed.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ClearPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.ClearPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ClearPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.ClearPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installClearPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.ClearPass")
    b.constructor {
        args => ClearPass(clearColor: UInt32(prebindInt(args, 0, default: 0) & 0xFFFFFFFF),
            clearAlpha: prebindNum(args, 1, default: 0.0))
    }
    _prebindPpPassMembers(b, vm)
    b.property("clearColor", getter: Some({ref => LuaValue.of(Int64(ref.cast<ClearPass>().clearColor))}),
        setter: Some({
            ref, v => ref.cast<ClearPass>().clearColor = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("clearAlpha", getter: Some({ref => LuaValue.of(ref.cast<ClearPass>().clearAlpha)}),
        setter: Some({ref, v => ref.cast<ClearPass>().clearAlpha = v.numberValue()}))
    b.install(vm)
}
