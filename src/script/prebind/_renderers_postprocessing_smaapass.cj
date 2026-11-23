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
 * @file[zh-cn] renderers_postprocessing_smaapass SMAA pass 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SMAAPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new()；绑定常量 SMAA_VIEW_EDGES / SMAA_VIEW_WEIGHTS / SMAA_VIEW_BLEND
 * （按同名 staticMethod 取值）与只读 releasable，并复用 _prebindPpPassMembers 安装 Pass 基类成员
 * （含 setSize / release）。SMAAPass 自身没有 public 字段。
 * 使用前提：edges/weights RT 与 SMAA LUT 纹理的创建、三遍全屏提交都触达 bgfx，必须由引擎完成
 * bgfx 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program/uniform 句柄与 _createRTs / _createLUT 等为内部实现。
 *
 * @file[en] renderers_postprocessing_smaapass  Lua binding of the SMAA pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SMAAPass as a Lua type
 * @explain[en] Constructor new(); binds the SMAA_VIEW_EDGES / SMAA_VIEW_WEIGHTS / SMAA_VIEW_BLEND
 * constants (read as same-named staticMethods) and the read-only releasable, and reuses
 * _prebindPpPassMembers for the Pass base members (including setSize / release). SMAAPass has no
 * public fields of its own.
 * Precondition: creation of the edges/weights RTs and the SMAA LUT textures plus the three
 * full-screen submissions reach bgfx and only take effect after bgfx initialization. Construction
 * and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program/uniform handles and _createRTs / _createLUT are implementation
 *   details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SMAAPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SMAAPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SMAAPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.SMAAPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSMAAPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SMAAPass")
    b.constructor {_ => SMAAPass()}
    _prebindPpPassMembers(b, vm)
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SMAAPass>().releasable)}))
    b.staticMethod("SMAA_VIEW_EDGES") {
        _ => [LuaValue.of(Int64(SMAAPass.SMAA_VIEW_EDGES))]
    }
    b.staticMethod("SMAA_VIEW_WEIGHTS") {
        _ => [LuaValue.of(Int64(SMAAPass.SMAA_VIEW_WEIGHTS))]
    }
    b.staticMethod("SMAA_VIEW_BLEND") {
        _ => [LuaValue.of(Int64(SMAAPass.SMAA_VIEW_BLEND))]
    }
    b.install(vm)
}
