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
 * @file[zh-cn] renderers_postprocessing_maskpass 遮罩 pass MaskPass 与清遮罩 pass
 * ClearMaskPass 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.MaskPass / ClearMaskPass 绑定为 Lua 类型
 * @explain[zh-cn] MaskPass：构造 new(scene, camera)，绑定 scene / camera / inverse 属性与
 * 常量 MASK_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * ClearMaskPass：构造 new()，仅复用 Pass 基类成员。
 * 使用前提：模板标记与几何提交发生在 render 内，由 EffectComposer.render 在渲染线程执行；
 * setSize / release 会触达 bgfx，必须在引擎完成 bgfx 初始化后调用。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(renderer, writeBuffer, readBuffer, deltaTime)：参数含 FrameBufferHandle，无 Lua 通道；
 * - MaskPass 的几何缓存与 _encodeStencilState / _submitSceneToStencil / _getOrCreateLayout /
 *   _getLayoutAttrs 等私有实现，涉及 bgfx 句柄与 CPointer，不对脚本暴露。
 *
 * @file[en] renderers_postprocessing_maskpass  Lua binding of MaskPass and ClearMaskPass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.MaskPass / ClearMaskPass as Lua types
 * @explain[en] MaskPass: constructor new(scene, camera); binds the scene / camera / inverse
 * properties and the MASK_VIEW_ID_BASE constant (read as a function), and reuses
 * _prebindPpPassMembers for the Pass base members. ClearMaskPass: constructor new() with only the
 * Pass base members.
 * Precondition: stencil marking and geometry submission happen inside render, driven by
 * EffectComposer.render on the render thread; setSize / release reach bgfx and may only be called
 * after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(renderer, writeBuffer, readBuffer, deltaTime): FrameBufferHandle parameters have no Lua
 *   channel;
 * - MaskPass internals (_encodeStencilState / _submitSceneToStencil / _getOrCreateLayout /
 *   _getLayoutAttrs and the geometry caches) involve bgfx handles and CPointer and are not exposed.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MaskPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.MaskPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MaskPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.MaskPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMaskPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.MaskPass")
    b.constructor {
        args => MaskPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    b.property("scene", getter: Some({
        ref => prebindRegister(ref.cast<MaskPass>().scene, "three.scene.scenegraph.Scene")
    }))
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<MaskPass>().camera, "three.renderers.cameras.Camera")
    }))
    b.property("inverse", getter: Some({ref => LuaValue.of(ref.cast<MaskPass>().inverse)}),
        setter: Some({ref, v => ref.cast<MaskPass>().inverse = v.boolValue()}))
    b.staticMethod("MASK_VIEW_ID_BASE") {_ => [LuaValue.of(Int64(MaskPass.MASK_VIEW_ID_BASE))]}
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ClearMaskPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.ClearMaskPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ClearMaskPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.ClearMaskPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installClearMaskPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.ClearMaskPass")
    b.constructor {_ => ClearMaskPass()}
    _prebindPpPassMembers(b, vm)
    b.install(vm)
}
