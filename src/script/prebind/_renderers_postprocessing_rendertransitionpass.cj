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
 * @file[zh-cn] renderers_postprocessing_rendertransitionpass 场景过渡 pass RenderTransitionPass
 * 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.RenderTransitionPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(sceneA, cameraA, sceneB, cameraB)，绑定 sceneA / cameraA / sceneB /
 * cameraB（均为 Option，nil 表示未设置）/ mixRatio / threshold / useMixTexture 属性、
 * setTransition(value) / useTexture(value) / setTextureThreshold(value) 方法与常量
 * TRANSITION_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：A/B 两个 RT 的创建/销毁与两次场景提交、合成都触达 bgfx，必须由引擎完成 bgfx 初始化
 * 后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - tMixTexture：TextureHandle（bgfx 句柄），Lua 无通道；
 * - setTexture(value: TextureHandle)：参数为 bgfx 纹理句柄，同上跳过；
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄与 _ensureRTs / _destroyRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_rendertransitionpass  Lua binding of the scene transition pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.RenderTransitionPass as a Lua type
 * @explain[en] Constructor new(sceneA, cameraA, sceneB, cameraB); binds the sceneA / cameraA /
 * sceneB / cameraB (all Option; nil means unset) / mixRatio / threshold / useMixTexture properties,
 * the setTransition(value) / useTexture(value) / setTextureThreshold(value) methods and the
 * TRANSITION_VIEW_ID_BASE constant (read as a function), and reuses _prebindPpPassMembers for the
 * Pass base members.
 * Precondition: creation/destruction of the A/B RTs and the two scene submissions plus compositing
 * reach bgfx and only take effect after bgfx initialization. Construction and property access are
 * safe.
 * Skipped members and reasons:
 * - tMixTexture: a TextureHandle (bgfx handle) with no Lua channel;
 * - setTexture(value: TextureHandle): takes a bgfx texture handle, skipped for the same reason;
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles and _ensureRTs / _destroyRTs are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RenderTransitionPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.RenderTransitionPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RenderTransitionPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.RenderTransitionPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRenderTransitionPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.RenderTransitionPass")
    b.constructor {
        args => RenderTransitionPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1), prebindAs<Scene>(args, 2),
            prebindAs<Camera>(args, 3))
    }
    _prebindPpPassMembers(b, vm)
    b.property("sceneA", getter: Some({
        ref => match (ref.cast<RenderTransitionPass>().sceneA) {
            case Some(s) => prebindRegister(s, "three.scene.scenegraph.Scene")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderTransitionPass>().sceneA = if (v.isObject) {
            Some(prebindAsValue<Scene>(v))
        } else {
            None
        }
    }))
    b.property("cameraA", getter: Some({
        ref => match (ref.cast<RenderTransitionPass>().cameraA) {
            case Some(c) => prebindRegister(c, "three.renderers.cameras.Camera")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderTransitionPass>().cameraA = if (v.isObject) {
            Some(prebindAsValue<Camera>(v))
        } else {
            None
        }
    }))
    b.property("sceneB", getter: Some({
        ref => match (ref.cast<RenderTransitionPass>().sceneB) {
            case Some(s) => prebindRegister(s, "three.scene.scenegraph.Scene")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderTransitionPass>().sceneB = if (v.isObject) {
            Some(prebindAsValue<Scene>(v))
        } else {
            None
        }
    }))
    b.property("cameraB", getter: Some({
        ref => match (ref.cast<RenderTransitionPass>().cameraB) {
            case Some(c) => prebindRegister(c, "three.renderers.cameras.Camera")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<RenderTransitionPass>().cameraB = if (v.isObject) {
            Some(prebindAsValue<Camera>(v))
        } else {
            None
        }
    }))
    b.property("mixRatio", getter: Some({ref => LuaValue.of(ref.cast<RenderTransitionPass>().mixRatio)}),
        setter: Some({ref, v => ref.cast<RenderTransitionPass>().mixRatio = v.numberValue()}))
    b.property("threshold", getter: Some({ref => LuaValue.of(ref.cast<RenderTransitionPass>().threshold)}),
        setter: Some({ref, v => ref.cast<RenderTransitionPass>().threshold = v.numberValue()}))
    b.property("useMixTexture", getter: Some({ref => LuaValue.of(ref.cast<RenderTransitionPass>().useMixTexture)}),
        setter: Some({
            ref, v => ref.cast<RenderTransitionPass>().useMixTexture = v.boolValue()
        }))
    b.method("setTransition") {
        ref, args =>
            ref.cast<RenderTransitionPass>().setTransition(prebindNum(args, 0))
            Array<LuaValue>()
    }
    b.method("useTexture") {
        ref, args =>
            ref.cast<RenderTransitionPass>().useTexture(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("setTextureThreshold") {
        ref, args =>
            ref.cast<RenderTransitionPass>().setTextureThreshold(prebindNum(args, 0))
            Array<LuaValue>()
    }
    b.staticMethod("TRANSITION_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(RenderTransitionPass.TRANSITION_VIEW_ID_BASE))]
    }
    b.install(vm)
}
