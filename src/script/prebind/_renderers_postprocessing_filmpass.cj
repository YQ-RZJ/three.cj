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
 * @file[zh-cn] renderers_postprocessing_filmpass 胶片颗粒 pass FilmPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.FilmPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([intensity[, grayscale]])（默认 0.5 / false），绑定 intensity /
 * grayscale / time 属性与常量 FILM_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers
 * 安装 Pass 基类成员。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成 bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 program/uniform 缓存为内部实现。
 *
 * @file[en] renderers_postprocessing_filmpass  Lua binding of the film grain pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.FilmPass as a Lua type
 * @explain[en] Constructor new([intensity[, grayscale]]) (defaults 0.5 / false); binds the
 * intensity / grayscale / time properties and the FILM_VIEW_ID_BASE constant (read as a function),
 * and reuses _prebindPpPassMembers for the Pass base members.
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private program/uniform caches are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FilmPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.FilmPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FilmPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.FilmPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFilmPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.FilmPass")
    b.constructor {
        args => FilmPass(intensity: prebindNum(args, 0, default: 0.5), grayscale: prebindBool(args, 1, default: false))
    }
    _prebindPpPassMembers(b, vm)
    b.property("intensity", getter: Some({ref => LuaValue.of(ref.cast<FilmPass>().intensity)}),
        setter: Some({ref, v => ref.cast<FilmPass>().intensity = v.numberValue()}))
    b.property("grayscale", getter: Some({ref => LuaValue.of(ref.cast<FilmPass>().grayscale)}),
        setter: Some({ref, v => ref.cast<FilmPass>().grayscale = v.boolValue()}))
    b.property("time", getter: Some({ref => LuaValue.of(ref.cast<FilmPass>().time)}),
        setter: Some({ref, v => ref.cast<FilmPass>().time = v.numberValue()}))
    b.staticMethod("FILM_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(FilmPass.FILM_VIEW_ID_BASE))]
    }
    b.install(vm)
}
