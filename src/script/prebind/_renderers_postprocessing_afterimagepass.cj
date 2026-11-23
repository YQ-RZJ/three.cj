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
 * @file[zh-cn] renderers_postprocessing_afterimagepass 残影 pass AfterimagePass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.AfterimagePass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([damp])（默认 0.96），绑定 damp 属性、常量
 * AFTERIMAGE_VIEW_ID_BASE（按函数取值）与只读 releasable，并复用 _prebindPpPassMembers 安装
 * Pass 基类成员（含 setSize / release）。
 * 使用前提：内部双 RT 的创建/销毁与残影合成提交都触达 bgfx，必须由引擎完成 bgfx 初始化后才会
 * 真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄与 _createRTs / _compile* 等为内部实现（bgfx 句柄无 Lua 通道）。
 *
 * @file[en] renderers_postprocessing_afterimagepass  Lua binding of the afterimage pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.AfterimagePass as a Lua type
 * @explain[en] Constructor new([damp]) (default 0.96); binds the damp property, the
 * AFTERIMAGE_VIEW_ID_BASE constant (read as a function) and the read-only releasable, and reuses
 * _prebindPpPassMembers for the Pass base members (including setSize / release).
 * Precondition: internal dual-RT creation/destruction and afterimage compositing reach bgfx and only
 * take effect after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles and _createRTs / _compile* are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AfterimagePass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.AfterimagePass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AfterimagePass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.AfterimagePass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAfterimagePass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.AfterimagePass")
    b.constructor {
        args => AfterimagePass(damp: prebindNum(args, 0, default: 0.96))
    }
    _prebindPpPassMembers(b, vm)
    b.property("damp", getter: Some({ref => LuaValue.of(ref.cast<AfterimagePass>().damp)}),
        setter: Some({ref, v => ref.cast<AfterimagePass>().damp = v.numberValue()}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AfterimagePass>().releasable)}))
    b.staticMethod("AFTERIMAGE_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(AfterimagePass.AFTERIMAGE_VIEW_ID_BASE))]
    }
    b.install(vm)
}
