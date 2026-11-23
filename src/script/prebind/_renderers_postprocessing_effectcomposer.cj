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
 * @file[zh-cn] renderers_postprocessing_effectcomposer 后处理 pass 链调度器 EffectComposer
 * 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.EffectComposer 绑定为 Lua 类型
 * @explain[zh-cn] 绑定：构造 new(renderer)、renderer / renderToScreen / passes / quad 属性、
 * allocViewId / addPass / insertPass / removePass / setSize / render([deltaTime]) 方法，
 * 以及 release / releasable（实现 IReleasable）。
 * 使用前提：render / setSize / addPass / insertPass / release 会经 runOnRenderThread 投递到
 * 渲染线程并等待完成（pass.setSize 内部创建/销毁渲染目标），必须由引擎完成渲染后端初始化
 * （渲染线程已启动）后调用，否则主线程会阻塞等待。new(renderer) 只记录渲染器并注入共享 quad，
 * 可在任何阶段安全调用；passes / renderToScreen 等纯数据读写同样安全。
 * 跳过成员及原因：
 * - writeBuffer()：返回 GfxFrameBufferHandle（抽象层帧缓冲句柄），Lua 无通道；
 * - allocViewId 内部、_createRTs / swapBuffers / isLastEnabledPass：
 *   私有实现细节，不对脚本暴露。
 *
 * @file[en] renderers_postprocessing_effectcomposer  Lua binding of the post-processing pass chain
 * scheduler EffectComposer (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.EffectComposer as a Lua type
 * @explain[en] Binds the constructor new(renderer), the renderer / renderToScreen / passes / quad
 * properties, the allocViewId / addPass / insertPass / removePass / setSize / render([deltaTime])
 * methods, plus release / releasable (implements IReleasable).
 * Precondition: render / setSize / addPass / insertPass / release go through runOnRenderThread,
 * which posts to the render thread and waits (pass.setSize creates/destroys render targets); they
 * may only be called after the engine has finished render-backend initialization (render thread
 * running), otherwise the caller thread blocks. new(renderer) only stores the renderer and injects
 * the shared quad and is safe at any time, as are pure data operations on passes / renderToScreen.
 * Skipped members and reasons:
 * - writeBuffer(): returns a GfxFrameBufferHandle (abstract frame-buffer handle) with no Lua channel;
 * - the private internals (_createRTs / swapBuffers / isLastEnabledPass) are implementation
 *   details and not exposed.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.renderers.ThreeRenderer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EffectComposer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.EffectComposer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EffectComposer
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.EffectComposer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEffectComposer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.EffectComposer")
    // ===== 构造 =====
    b.constructor {
        args => EffectComposer(prebindAs<ThreeRenderer>(args, 0))
    }
    // ===== 属性 =====
    b.property("renderer", getter: Some({
        ref => prebindRegister(ref.cast<EffectComposer>().renderer, "three.renderers.ThreeRenderer")
    }))
    b.property("renderToScreen", getter: Some({ref => LuaValue.of(ref.cast<EffectComposer>().renderToScreen)}),
        setter: Some({ref, v => ref.cast<EffectComposer>().renderToScreen = v.boolValue()}))
    b.property("passes", getter: Some({ref => _prebindPpPassArrayToLua(ref.cast<EffectComposer>().passes)}),
        setter: Some({
            ref, v => ref.cast<EffectComposer>().passes = _prebindPpPassArrayFromLua(vm, v)
        }))
    b.property("quad", getter: Some({
        ref => prebindRegister(ref.cast<EffectComposer>().quad, "three.renderers.postprocessing.FullScreenQuad")
    }))
    // ===== pass 链管理 =====
    b.method("allocViewId") {
        ref, _ => [LuaValue.of(Int64(ref.cast<EffectComposer>().allocViewId()))]
    }
    b.method("addPass") {
        ref, args =>
            ref.cast<EffectComposer>().addPass(prebindAs<Pass>(args, 0))
            Array<LuaValue>()
    }
    b.method("insertPass") {
        ref, args =>
            ref.cast<EffectComposer>().insertPass(prebindAs<Pass>(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.method("removePass") {
        ref, args =>
            ref.cast<EffectComposer>().removePass(prebindAs<Pass>(args, 0))
            Array<LuaValue>()
    }
    b.method("setSize") {
        ref, args =>
            ref.cast<EffectComposer>().setSize(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.method("render") {
        ref, args =>
            ref.cast<EffectComposer>().render(deltaTime: prebindNum(args, 0, default: 0.016))
            Array<LuaValue>()
    }
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<EffectComposer>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<EffectComposer>().release())]
    }
    b.install(vm)
}
