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
 * @file[zh-cn] renderers_postprocessing_outputpass 输出 pass OutputPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.OutputPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([toneMapping[, exposure[, sRGB]]])（默认 ACESFilmicToneMapping / 1.0 /
 * true），绑定 toneMapping / exposure / sRGB 属性，并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：shader 编译与上屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成 bgfx 初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 program 缓存与 _compile / _lastToneMapping / _lastSRGB 为内部实现。
 *
 * @file[en] renderers_postprocessing_outputpass  Lua binding of the output pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.OutputPass as a Lua type
 * @explain[en] Constructor new([toneMapping[, exposure[, sRGB]]]) (defaults ACESFilmicToneMapping /
 * 1.0 / true); binds the toneMapping / exposure / sRGB properties and reuses
 * _prebindPpPassMembers for the Pass base members.
 * Precondition: shader compilation and final submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private program cache and _compile / _lastToneMapping / _lastSRGB are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.utils.constants.ACESFilmicToneMapping
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 OutputPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.OutputPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of OutputPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.OutputPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installOutputPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.OutputPass")
    b.constructor {
        args => OutputPass(toneMapping: prebindInt(args, 0, default: ACESFilmicToneMapping),
            exposure: prebindNum(args, 1, default: 1.0), sRGB: prebindBool(args, 2, default: true))
    }
    _prebindPpPassMembers(b, vm)
    b.property("toneMapping", getter: Some({ref => LuaValue.of(ref.cast<OutputPass>().toneMapping)}),
        setter: Some({ref, v => ref.cast<OutputPass>().toneMapping = v.intValue()}))
    b.property("exposure", getter: Some({ref => LuaValue.of(ref.cast<OutputPass>().exposure)}),
        setter: Some({ref, v => ref.cast<OutputPass>().exposure = v.numberValue()}))
    b.property("sRGB", getter: Some({ref => LuaValue.of(ref.cast<OutputPass>().sRGB)}),
        setter: Some({ref, v => ref.cast<OutputPass>().sRGB = v.boolValue()}))
    b.install(vm)
}
