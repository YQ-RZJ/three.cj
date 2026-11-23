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
 * @file[zh-cn] renderers_postprocessing_dotscreenpass 点阵屏 pass DotScreenPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.DotScreenPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([center[, angle[, scale]]])（默认 Vector2(0.5, 0.5) / 1.57 / 1.0），
 * 绑定 center（Vector2，经 prebindRegister / prebindAsValue 往返）/ angle / scale 属性与常量
 * DOTSCREEN_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成 bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 program/uniform 缓存与 _compileDotScreen 为内部实现。
 *
 * @file[en] renderers_postprocessing_dotscreenpass  Lua binding of the dot screen pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.DotScreenPass as a Lua type
 * @explain[en] Constructor new([center[, angle[, scale]]]) (defaults Vector2(0.5, 0.5) / 1.57 /
 * 1.0); binds the center (Vector2, round-tripped via prebindRegister / prebindAsValue) / angle /
 * scale properties and the DOTSCREEN_VIEW_ID_BASE constant (read as a function), and reuses
 * _prebindPpPassMembers for the Pass base members.
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private program/uniform caches and _compileDotScreen are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.core.math.Vector2
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 DotScreenPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.DotScreenPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DotScreenPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.DotScreenPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDotScreenPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.DotScreenPass")
    b.constructor {
        args => DotScreenPass(center: _prebindPpVec2(args, 0, default: Vector2(0.5, 0.5)),
            angle: prebindNum(args, 1, default: 1.57), scale: prebindNum(args, 2, default: 1.0))
    }
    _prebindPpPassMembers(b, vm)
    b.property("center", getter: Some({
        ref => prebindRegister(ref.cast<DotScreenPass>().center, "three.core.math.Vector2")
    }), setter: Some({
        ref, v => ref.cast<DotScreenPass>().center = prebindAsValue<Vector2>(v)
    }))
    b.property("angle", getter: Some({ref => LuaValue.of(ref.cast<DotScreenPass>().angle)}),
        setter: Some({ref, v => ref.cast<DotScreenPass>().angle = v.numberValue()}))
    b.property("scale", getter: Some({ref => LuaValue.of(ref.cast<DotScreenPass>().scale)}),
        setter: Some({ref, v => ref.cast<DotScreenPass>().scale = v.numberValue()}))
    b.staticMethod("DOTSCREEN_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(DotScreenPass.DOTSCREEN_VIEW_ID_BASE))]
    }
    b.install(vm)
}
