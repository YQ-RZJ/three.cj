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
 * @file[zh-cn] renderers_postprocessing_halftonepass 半色调网点 pass HalftonePass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.HalftonePass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([shape[, radius[, rotateR[, rotateG[, rotateB[, scatter[, blending[,
 * blendingMode[, greyscale[, disable]]]]]]]]]])，默认值 1 / 4.0 / PI/12 / PI/12*2 / PI/12*3 /
 * 0.0 / 1.0 / 1 / false / false；绑定全部参数属性与常量 HALFTONE_VIEW_ID_BASE（按函数取值），
 * 并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成 bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 program 缓存与 _compile 等为内部实现。
 *
 * @file[en] renderers_postprocessing_halftonepass  Lua binding of the halftone pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.HalftonePass as a Lua type
 * @explain[en] Constructor new([shape[, radius[, rotateR[, rotateG[, rotateB[, scatter[, blending[,
 * blendingMode[, greyscale[, disable]]]]]]]]]]), defaults 1 / 4.0 / PI/12 / PI/12*2 / PI/12*3 /
 * 0.0 / 1.0 / 1 / false / false; binds every parameter property and the HALFTONE_VIEW_ID_BASE
 * constant (read as a function), and reuses _prebindPpPassMembers for the Pass base members.
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private program cache and _compile are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 HalftonePass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.HalftonePass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of HalftonePass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.HalftonePass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installHalftonePass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.HalftonePass")
    b.constructor {
        args => HalftonePass(shape: prebindInt(args, 0, default: 1), radius: prebindNum(args, 1, default: 4.0),
            rotateR: prebindNum(args, 2, default: 3.141592653589793 / 12.0),
            rotateG: prebindNum(args, 3, default: 3.141592653589793 / 12.0 * 2.0),
            rotateB: prebindNum(args, 4, default: 3.141592653589793 / 12.0 * 3.0),
            scatter: prebindNum(args, 5, default: 0.0), blending: prebindNum(args, 6, default: 1.0),
            blendingMode: prebindInt(args, 7, default: 1), greyscale: prebindBool(args, 8, default: false),
            disable: prebindBool(args, 9, default: false))
    }
    _prebindPpPassMembers(b, vm)
    b.property("shape", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().shape)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().shape = v.intValue()}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().radius)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().radius = v.numberValue()}))
    b.property("rotateR", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().rotateR)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().rotateR = v.numberValue()}))
    b.property("rotateG", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().rotateG)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().rotateG = v.numberValue()}))
    b.property("rotateB", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().rotateB)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().rotateB = v.numberValue()}))
    b.property("scatter", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().scatter)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().scatter = v.numberValue()}))
    b.property("blending", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().blending)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().blending = v.numberValue()}))
    b.property("blendingMode", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().blendingMode)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().blendingMode = v.intValue()}))
    b.property("greyscale", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().greyscale)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().greyscale = v.boolValue()}))
    b.property("disable", getter: Some({ref => LuaValue.of(ref.cast<HalftonePass>().disable)}),
        setter: Some({ref, v => ref.cast<HalftonePass>().disable = v.boolValue()}))
    b.staticMethod("HALFTONE_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(HalftonePass.HALFTONE_VIEW_ID_BASE))]
    }
    b.install(vm)
}
