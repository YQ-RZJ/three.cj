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
 * @file[zh-cn] renderers_postprocessing_lutpass 调色 LUT pass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.LUTPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造对应源码 init(lut!: EngineDataTexture = EngineDataTexture.invalid(), lutSize!: Int64 = 0,
 * intensity!: Float64 = 1.0)：位置 0 传 three.renderers.textures.EngineDataTexture（3D LUT 数据纹理；传 nil
 * 则按无效实例构造，render 会跳过），位置 1 / 2 读取 lutSize / intensity。绑定
 * lutSize / intensity 属性，复用 _prebindPpShaderPassMembers 安装 ShaderPass 基类成员
 * （其内部先安装 Pass 基类成员）。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成渲染后端初始化。构造与属性读写可安全调用（构造不会触达 GPU）。
 * 跳过成员及原因：
 * - render(...)：参数含 GfxFrameBufferHandle，由 composer 链驱动；
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry)：IUniformRegistry 无 Lua 类型可往返。
 *
 * @file[en] renderers_postprocessing_lutpass  Lua binding of the LUT color-grading pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.LUTPass as a Lua type
 * @explain[en] The constructor binds the source-class init(lut!: EngineDataTexture = EngineDataTexture.invalid(),
 * lutSize!: Int64 = 0, intensity!: Float64 = 1.0): position 0 takes a three.renderers.textures.EngineDataTexture
 * (3D LUT data texture; pass nil to build an invalid instance, which makes render skip), while
 * positions 1 / 2 read lutSize / intensity. Binds the lutSize / intensity properties and reuses
 * _prebindPpShaderPassMembers for the ShaderPass base members (it installs the Pass base members
 * first).
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed render-backend initialization.
 * Construction and property access are safe (construction does not reach the GPU).
 * Skipped members and reasons:
 * - render(...): GfxFrameBufferHandle parameters, driven by the composer chain;
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry): IUniformRegistry has no Lua type to round-trip.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LUTPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.LUTPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LUTPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.LUTPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLUTPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.LUTPass")
    b.constructor {
        args => LUTPass(_prebindPpDataTexture(args, 0), lutSize: prebindInt(args, 1, default: 0),
            intensity: prebindNum(args, 2, default: 1.0))
    }
    _prebindPpShaderPassMembers(b, vm)
    b.property("lutSize", getter: Some({ref => LuaValue.of(ref.cast<LUTPass>().lutSize)}),
        setter: Some({ref, v => ref.cast<LUTPass>().lutSize = v.intValue()}))
    b.property("intensity", getter: Some({ref => LuaValue.of(ref.cast<LUTPass>().intensity)}),
        setter: Some({ref, v => ref.cast<LUTPass>().intensity = v.numberValue()}))
    b.install(vm)
}
