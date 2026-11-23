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
 * @file[zh-cn] renderers_postprocessing_taarenderpass 时间抗锯齿 pass TAARenderPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.TAARenderPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera[, clearColor[, clearAlpha]])，绑定 accumulate /
 * accumulateIndex 属性与常量 TAA_VIEW_ACCUM / TAA_VIEW_HOLD（按同名 staticMethod 取值）。
 * 复用 _prebindPpSSAARenderPassMembers 安装 SSAARenderPass 成员（内部会先安装 Pass 基类成员），
 * 因为 Lua 类表没有继承。
 * 使用前提：sampleRT/holdRT 的创建/销毁与跨帧累加都触达 bgfx，必须由引擎完成 bgfx 初始化后才会
 * 真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 holdRT/纹理句柄、相机位置记忆字段与 _createHoldRT 等为内部实现。
 *
 * @file[en] renderers_postprocessing_taarenderpass  Lua binding of the temporal AA pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.TAARenderPass as a Lua type
 * @explain[en] Constructor new(scene, camera[, clearColor[, clearAlpha]]); binds the accumulate /
 * accumulateIndex properties and the TAA_VIEW_ACCUM / TAA_VIEW_HOLD constants (read as
 * same-named staticMethods). Reuses _prebindPpSSAARenderPassMembers for the SSAARenderPass members
 * (it installs the Pass base members first) because Lua class tables have no inheritance.
 * Precondition: creation/destruction of sampleRT/holdRT and the cross-frame accumulation reach bgfx
 * and only take effect after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private holdRT/texture handles, camera-position memory fields and _createHoldRT are
 *   implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TAARenderPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.TAARenderPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TAARenderPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.TAARenderPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTAARenderPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.TAARenderPass")
    b.constructor {
        args => TAARenderPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1),
            clearColor: UInt32(prebindInt(args, 2, default: 0) & 0xFFFFFFFF),
            clearAlpha: prebindNum(args, 3, default: 0.0))
    }
    _prebindPpSSAARenderPassMembers(b, vm)
    b.property("accumulate", getter: Some({ref => LuaValue.of(ref.cast<TAARenderPass>().accumulate)}),
        setter: Some({ref, v => ref.cast<TAARenderPass>().accumulate = v.boolValue()}))
    b.property("accumulateIndex", getter: Some({ref => LuaValue.of(ref.cast<TAARenderPass>().accumulateIndex)}),
        setter: Some({ref, v => ref.cast<TAARenderPass>().accumulateIndex = v.intValue()}))
    b.staticMethod("TAA_VIEW_ACCUM") {
        _ => [LuaValue.of(Int64(TAARenderPass.TAA_VIEW_ACCUM))]
    }
    b.staticMethod("TAA_VIEW_HOLD") {
        _ => [LuaValue.of(Int64(TAARenderPass.TAA_VIEW_HOLD))]
    }
    b.install(vm)
}
