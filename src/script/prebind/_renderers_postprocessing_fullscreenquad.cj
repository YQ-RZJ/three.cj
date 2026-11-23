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
 * @file[zh-cn] renderers_postprocessing_fullscreenquad 全屏四边形共享资源 FullScreenQuad
 * 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.FullScreenQuad 绑定为 Lua 类型
 * @explain[zh-cn] 绑定：构造 new()、setRenderer(renderer) / ensureResources(renderer) /
 * submit(viewId, programIdx) / submitWithState(viewId, programIdx, state) /
 * release() / releasable（实现 IReleasable）。VB/IB/layout 全部为私有，公开类型中只有
 * 上述方法，通常由 EffectComposer 持单例并自动注入，自定义 pass 也可在渲染线程内经
 * Pass.submitQuad 间接提交。
 * 使用前提：setRenderer / ensureResources / submit* / release 会创建/销毁渲染后端资源或提交
 * 绘制，必须由引擎完成渲染后端初始化、且位于渲染线程（EffectComposer.render 链内或
 * runOnRenderThread 包裹）时调用。
 *
 * @file[en] renderers_postprocessing_fullscreenquad  Lua binding of the shared full-screen quad
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.FullScreenQuad as a Lua type
 * @explain[en] Binds the constructor new(), setRenderer(renderer) / ensureResources(renderer) /
 * submit(viewId, programIdx) / submitWithState(viewId, programIdx, state) /
 * release() / releasable (implements IReleasable). The VB/IB/layout are private; the composer owns
 * the singleton and injects it automatically, and custom passes may also submit indirectly through
 * Pass.submitQuad on the render thread.
 * Precondition: setRenderer / ensureResources / submit* / release create/destroy render-backend
 * resources or submit draws, so they may only be called after render-backend initialization and on
 * the render thread (inside the EffectComposer.render chain or wrapped by runOnRenderThread).
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.renderers.ThreeRenderer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FullScreenQuad 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.FullScreenQuad）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FullScreenQuad
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.FullScreenQuad)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFullScreenQuad(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.FullScreenQuad")
    b.constructor {_ => FullScreenQuad()}
    b.method("setRenderer") {
        ref, args =>
            ref.cast<FullScreenQuad>().setRenderer(prebindAs<ThreeRenderer>(args, 0))
            Array<LuaValue>()
    }
    b.method("ensureResources") {
        ref, args =>
            ref.cast<FullScreenQuad>().ensureResources(prebindAs<ThreeRenderer>(args, 0))
            Array<LuaValue>()
    }
    // ===== 提交（程序句柄用整数 idx） =====
    b.method("submit") {
        ref, args =>
            ref.cast<FullScreenQuad>().submit(UInt16(prebindInt(args, 0) & 0xFFFF), prebindProgramHandle(args, 1))
            Array<LuaValue>()
    }
    b.method("submitWithState") {
        ref, args =>
            ref
                .cast<FullScreenQuad>()
                .submitWithState(UInt16(prebindInt(args, 0) & 0xFFFF), prebindProgramHandle(args, 1),
                    UInt64(prebindInt(args, 2)))
            Array<LuaValue>()
    }
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<FullScreenQuad>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<FullScreenQuad>().release())]
    }
    b.install(vm)
}
