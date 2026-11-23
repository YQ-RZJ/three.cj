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
 * @file[zh-cn] renderers_postprocessing_renderpass 场景渲染 pass RenderPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.RenderPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera)，绑定 scene / camera / overrideMaterial /
 * clearColor / clearAlpha / clearDepth 属性，并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：Pass.render 由 EffectComposer.render 在渲染线程内调用，本身不经脚本触发；
 * 但 EffectComposer.addPass / setSize 会因本 pass 的 setSize 调用而触达 bgfx，必须在引擎完成
 * bgfx 初始化后执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(renderer, writeBuffer, readBuffer, deltaTime)：参数含 FrameBufferHandle，
 *   无 Lua 通道，由 composer 链驱动。
 *
 * @file[en] renderers_postprocessing_renderpass  Lua binding of the scene render pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.RenderPass as a Lua type
 * @explain[en] Constructor new(scene, camera); binds the scene / camera / overrideMaterial /
 * clearColor / clearAlpha / clearDepth properties and reuses _prebindPpPassMembers for the Pass base
 * members.
 * Precondition: Pass.render is invoked by EffectComposer.render on the render thread and is not
 * triggered from scripts; however EffectComposer.addPass / setSize reach bgfx through this pass's
 * setSize and may only run after bgfx initialization. Construction and property access are safe.
 * Skipped member and reason:
 * - render(renderer, writeBuffer, readBuffer, deltaTime): FrameBufferHandle parameters have no Lua
 *   channel; driven by the composer chain.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.renderers.materials.Material
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RenderPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.RenderPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.RenderPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.RenderPass")
    b.constructor {
        args => RenderPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    // ===== 场景 / 相机 =====
    b.property("scene", getter: Some({
        ref => prebindRegister(ref.cast<RenderPass>().scene, "three.scene.scenegraph.Scene")
    }))
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<RenderPass>().camera, "three.renderers.cameras.Camera")
    }))
    // ===== 覆盖材质 / 清屏参数 =====
    b.property("overrideMaterial", getter: Some({
        ref => match (ref.cast<RenderPass>().overrideMaterial) {
            case Some(m) => prebindRegister(m, "three.renderers.materials.Material")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderPass>().overrideMaterial = if (v.isObject) {
            Some(prebindAsValue<Material>(v))
        } else {
            None
        }
    }))
    b.property("clearColor", getter: Some({
        ref => match (ref.cast<RenderPass>().clearColor) {
            case Some(c) => LuaValue.of(Int64(c))
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderPass>().clearColor = if (v.isNil) {
            None
        } else {
            Some(UInt32(v.intValue() & 0xFFFFFFFF))
        }
    }))
    b.property("clearAlpha", getter: Some({
        ref => match (ref.cast<RenderPass>().clearAlpha) {
            case Some(a) => LuaValue.of(a)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderPass>().clearAlpha = if (v.isNil) {
            None
        } else {
            Some(v.numberValue())
        }
    }))
    b.property("clearDepth", getter: Some({ref => LuaValue.of(ref.cast<RenderPass>().clearDepth)}),
        setter: Some({ref, v => ref.cast<RenderPass>().clearDepth = v.boolValue()}))
    b.install(vm)
}
