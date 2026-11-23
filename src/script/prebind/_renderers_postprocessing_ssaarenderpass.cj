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
 * @file[zh-cn] renderers_postprocessing_ssaarenderpass 超采样抗锯齿 pass SSAARenderPass 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SSAARenderPass 绑定为 Lua 类型并导出子类共用的
 * 成员安装函数
 * @explain[zh-cn] 构造 new(scene, camera[, clearColor[, clearAlpha]])，绑定 scene / camera /
 * sampleLevel / unbiased / clearColor（UInt32）/ clearAlpha 属性、常量 SSAA_VIEW_ACCUM
 * （按函数取值）与只读 releasable；导出 _prebindPpSSAARenderPassMembers 供 TAARenderPass 复用
 * （内部先安装 Pass 基类成员）。
 * 使用前提：内部 sampleRT 的创建/销毁与多 jitter 样本累加都触达 bgfx，必须由引擎完成 bgfx
 * 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 sampleRT/纹理/program 句柄与 _createRTs / _destroyRTs 为内部实现。
 *
 * @file[en] renderers_postprocessing_ssaarenderpass  Lua binding of the supersampling pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SSAARenderPass and exports the shared subclass
 * installer
 * @explain[en] Constructor new(scene, camera[, clearColor[, clearAlpha]]); binds the scene / camera /
 * sampleLevel / unbiased / clearColor (UInt32) / clearAlpha properties, the SSAA_VIEW_ACCUM constant
 * (read as a function) and the read-only releasable; exports _prebindPpSSAARenderPassMembers for
 * TAARenderPass (it installs the Pass base members first).
 * Precondition: creation/destruction of the internal sampleRT and the multi-jitter accumulation
 * reach bgfx and only take effect after bgfx initialization. Construction and property access are
 * safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private sampleRT/texture/program handles and _createRTs / _destroyRTs are implementation
 *   details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 SSAARenderPass 的成员（构造除外）
 * @explain[zh-cn] 先调用 _prebindPpPassMembers 安装 Pass 基类成员，再补充超采样参数。
 * TAARenderPass 的绑定复用本函数（Lua 类表没有继承）。
 * @param[zh-cn] b 目标类绑定器
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 *
 * @brief[en] Installs the SSAARenderPass members (except the constructor) on a binder
 * @explain[en] Calls _prebindPpPassMembers first for the Pass base members, then adds the
 * supersampling parameters. The TAARenderPass binding reuses this function (Lua class tables have no
 * inheritance).
 * @param[en] b The target class binder
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 */
internal func _prebindPpSSAARenderPassMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    _prebindPpPassMembers(b, vm)
    b.property("scene", getter: Some({
        ref => prebindRegister(ref.cast<SSAARenderPass>().scene, "three.scene.scenegraph.Scene")
    }))
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<SSAARenderPass>().camera, "three.renderers.cameras.Camera")
    }))
    b.property("sampleLevel", getter: Some({ref => LuaValue.of(ref.cast<SSAARenderPass>().sampleLevel)}),
        setter: Some({ref, v => ref.cast<SSAARenderPass>().sampleLevel = v.intValue()}))
    b.property("unbiased", getter: Some({ref => LuaValue.of(ref.cast<SSAARenderPass>().unbiased)}),
        setter: Some({ref, v => ref.cast<SSAARenderPass>().unbiased = v.boolValue()}))
    b.property("clearColor", getter: Some({ref => LuaValue.of(Int64(ref.cast<SSAARenderPass>().clearColor))}),
        setter: Some({
            ref, v => ref.cast<SSAARenderPass>().clearColor = UInt32(v.intValue() & 0xFFFFFFFF)
        }))
    b.property("clearAlpha", getter: Some({ref => LuaValue.of(ref.cast<SSAARenderPass>().clearAlpha)}),
        setter: Some({ref, v => ref.cast<SSAARenderPass>().clearAlpha = v.numberValue()}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SSAARenderPass>().releasable)}))
    b.staticMethod("SSAA_VIEW_ACCUM") {
        _ => [LuaValue.of(Int64(SSAARenderPass.SSAA_VIEW_ACCUM))]
    }
}

/**
 * @brief[zh-cn] 安装 SSAARenderPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SSAARenderPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SSAARenderPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.SSAARenderPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSSAARenderPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SSAARenderPass")
    b.constructor {
        args => SSAARenderPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1),
            clearColor: UInt32(prebindInt(args, 2, default: 0) & 0xFFFFFFFF),
            clearAlpha: prebindNum(args, 3, default: 0.0))
    }
    _prebindPpSSAARenderPassMembers(b, vm)
    b.install(vm)
}
