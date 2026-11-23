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
 * @file[zh-cn] renderers_postprocessing_shaderpass 通用 shader pass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.ShaderPass 绑定为 Lua 类型并导出子类共用的成员安装函数
 * @explain[zh-cn] 构造 new(shaderName[, textureID])，绑定 shaderName / textureID /
 * stencilTestRef（Option<UInt32>）/ clearView 属性；导出 _prebindPpShaderPassMembers 供
 * FXAAPass / LUTPass / VolumeCloudPass 复用（内部先安装 Pass 基类成员）。
 * 使用前提：shader 编译与全屏提交发生在 render 内，由 EffectComposer.render 在渲染线程执行；
 * 必须在引擎完成 bgfx 初始化后才会真正渲染。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 GfxFrameBufferHandle，无 Lua 通道；
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry)：IUniformRegistry 为抽象层
 *   uniform 注册表，无 Lua 类型可往返，子类绑定也不暴露该钩子。
 *
 * @file[en] renderers_postprocessing_shaderpass  Lua binding of the generic shader pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.ShaderPass and exports the shared subclass installer
 * @explain[en] Constructor new(shaderName[, textureID]); binds the shaderName / textureID /
 * stencilTestRef (Option<UInt32>) / clearView properties. _prebindPpShaderPassMembers is exported for
 * FXAAPass / LUTPass / VolumeCloudPass (it installs the Pass base members first).
 * Precondition: shader compilation and full-screen submission happen inside render, driven by
 * EffectComposer.render on the render thread, and only take effect after render-backend initialization.
 * Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): GfxFrameBufferHandle parameters have no Lua channel;
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry): IUniformRegistry is the abstract uniform
 *   registry and has no Lua type to round-trip, so the hook is not exposed.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 ShaderPass 的成员（构造除外）
 * @explain[zh-cn] 先调用 _prebindPpPassMembers 安装 Pass 基类成员，再补充 shader 相关属性。
 * FXAAPass / LUTPass / VolumeCloudPass 的绑定复用本函数（Lua 类表没有继承）。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the ShaderPass members (except the constructor) on a binder
 * @explain[en] Calls _prebindPpPassMembers first for the Pass base members, then adds the shader
 * properties. The FXAAPass / LUTPass / VolumeCloudPass bindings reuse this function (Lua class
 * tables have no inheritance).
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindPpShaderPassMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    _prebindPpPassMembers(b, vm)
    b.property("shaderName", getter: Some({ref => LuaValue.of(ref.cast<ShaderPass>().shaderName)}))
    b.property("textureID", getter: Some({ref => LuaValue.of(ref.cast<ShaderPass>().textureID)}),
        setter: Some({ref, v => ref.cast<ShaderPass>().textureID = v.stringValue()}))
    b.property("stencilTestRef", getter: Some({
        ref => match (ref.cast<ShaderPass>().stencilTestRef) {
            case Some(r) => LuaValue.of(Int64(r))
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<ShaderPass>().stencilTestRef = if (v.isNil) {
            None
        } else {
            Some(UInt32(v.intValue() & 0xFFFFFFFF))
        }
    }))
    b.property("clearView", getter: Some({ref => LuaValue.of(ref.cast<ShaderPass>().clearView)}),
        setter: Some({ref, v => ref.cast<ShaderPass>().clearView = v.boolValue()}))
}

/**
 * @brief[zh-cn] 安装 ShaderPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.ShaderPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ShaderPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.ShaderPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installShaderPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.ShaderPass")
    b.constructor {
        args => ShaderPass(prebindStr(args, 0), textureID: prebindStr(args, 1, default: "tDiffuse"))
    }
    _prebindPpShaderPassMembers(b, vm)
    b.install(vm)
}
