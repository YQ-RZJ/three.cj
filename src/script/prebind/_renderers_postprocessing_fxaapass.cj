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
 * @file[zh-cn] renderers_postprocessing_fxaapass FXAA pass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.FXAAPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new()（内部固定 shaderName = "fxaa"、textureID = "tDiffuse"），复用
 * _prebindPpShaderPassMembers 安装 ShaderPass 基类成员（其内部先安装 Pass 基类成员），
 * FXAAPass 自身没有额外 public 字段。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行，
 * 需引擎已完成渲染后端初始化。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry)：u_resolution 绑定属于渲染内部钩子，
 *   IUniformRegistry 无 Lua 类型可往返；
 * - render(...)：参数含 GfxFrameBufferHandle，由 composer 链驱动。
 *
 * @file[en] renderers_postprocessing_fxaapass  Lua binding of the FXAA pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.FXAAPass as a Lua type
 * @explain[en] Constructor new() (shaderName is fixed to "fxaa" and textureID to "tDiffuse");
 * reuses _prebindPpShaderPassMembers for the ShaderPass base members (it installs the Pass base
 * members first). FXAAPass has no additional public fields.
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, requiring completed bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry): binding u_resolution is an internal render
 *   hook and IUniformRegistry has no Lua type to round-trip;
 * - render(...): GfxFrameBufferHandle parameters, driven by the composer chain.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FXAAPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.FXAAPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FXAAPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.FXAAPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFXAAPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.FXAAPass")
    b.constructor {_ => FXAAPass()}
    _prebindPpShaderPassMembers(b, vm)
    b.install(vm)
}
