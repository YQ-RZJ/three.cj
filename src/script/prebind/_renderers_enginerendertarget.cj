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
 * @file[zh-cn] renderers_enginerendertarget 后处理渲染目标资源对象 EngineRenderTarget 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.rendertarget.EngineRenderTarget 绑定为 Lua 类型
 * three.renderers.rendertarget.EngineRenderTarget
 * @explain[zh-cn] 绑定构造 new(renderer, width, height, format, flags[, depth])、resize /
 * dispose / release / releasable、width / height 只读属性，以及供自定义 pass 使用的
 * 整数句柄访问器 colorTexture / depthTexture / frameBuffer（0xFFFF = 无效）。
 * 构造与 resize 会创建/销毁 GPU 资源，必须由引擎完成渲染后端初始化后调用；
 * 属性读取与无效句柄判断可安全调用。
 *
 * @file[en] renderers_enginerendertarget  Lua binding of the post-processing render-target resource
 * object EngineRenderTarget (three.script.prebind)
 * @brief[en] Binds three.renderers.rendertarget.EngineRenderTarget as the Lua type three.renderers.rendertarget.EngineRenderTarget
 * @explain[en] Binds the constructor new(renderer, width, height, format, flags[, depth]), resize /
 * dispose / release / releasable, the read-only width / height props, and the integer handle
 * accessors colorTexture / depthTexture / frameBuffer (0xFFFF = invalid) for custom passes.
 * Construction and resize create/destroy GPU resources and may only be called after the engine has
 * finished render-backend initialization; property reads and invalid-handle checks are safe.
 */
package three.script.prebind

import three.renderers.rendertarget.EngineRenderTarget
import three.renderers.ThreeRenderer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 EngineRenderTarget 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.rendertarget.EngineRenderTarget）
 *
 * @brief[en] Installs the Lua binding of EngineRenderTarget
 * @param[en] vm The target virtual machine (class table at three.renderers.rendertarget.EngineRenderTarget)
 */
public func installEngineRenderTarget(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.rendertarget.EngineRenderTarget")
    // ===== 构造：new(renderer, width, height, format, flags[, depth]) =====
    b.constructor {
        args => EngineRenderTarget(prebindAs<ThreeRenderer>(args, 0).gfxBackend(), prebindInt(args, 1), prebindInt(args, 2),
            format: UInt32(prebindInt(args, 3) & 0xFFFFFFFF), flags: UInt64(prebindInt(args, 4)),
            depth: prebindBool(args, 5, default: true))
    }
    // ===== 只读属性 =====
    b.property("width", getter: Some({ref => LuaValue.of(ref.cast<EngineRenderTarget>().width)}))
    b.property("height", getter: Some({ref => LuaValue.of(ref.cast<EngineRenderTarget>().height)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<EngineRenderTarget>().releasable)}))
    // ===== 自定义 pass 用的整数句柄访问器 =====
    b.property("colorTexture",
        getter: Some({ref => LuaValue.of(prebindGfxHandleIdx(ref.cast<EngineRenderTarget>().colorTexture))}))
    b.property("depthTexture",
        getter: Some({ref => LuaValue.of(prebindGfxHandleIdx(ref.cast<EngineRenderTarget>().depthTexture))}))
    b.property("frameBuffer",
        getter: Some({ref => LuaValue.of(prebindGfxHandleIdx(ref.cast<EngineRenderTarget>().frameBuffer))}))
    // ===== 生命周期 =====
    b.method("resize") {
        ref, args =>
            ref.cast<EngineRenderTarget>().resize(prebindInt(args, 0), prebindInt(args, 1))
            Array<LuaValue>()
    }
    b.method("dispose") {
        ref, _ =>
            ref.cast<EngineRenderTarget>().dispose()
            Array<LuaValue>()
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<EngineRenderTarget>().release())]
    }
    b.install(vm)
}
