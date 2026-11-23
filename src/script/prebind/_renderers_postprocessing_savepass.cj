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
 * @file[zh-cn] renderers_postprocessing_savepass 保存 pass SavePass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SavePass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new()，绑定只读 releasable 与 release()，并复用
 * _prebindPpPassMembers 安装 Pass 基类成员（含 setSize）。
 * 使用前提：内部 RT 的创建/销毁与拷贝提交都触达 bgfx，必须在引擎完成 bgfx 初始化后才会真正执行；
 * 构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - renderTarget：FrameBufferHandle（bgfx 句柄），Lua 无通道；
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT 句柄（_rtColor / _prog）与 _createRT 为内部实现。
 *
 * @file[en] renderers_postprocessing_savepass  Lua binding of the save pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SavePass as a Lua type
 * @explain[en] Constructor new(); binds the read-only releasable and release(), and reuses
 * _prebindPpPassMembers for the Pass base members (including setSize).
 * Precondition: internal RT creation/destruction and copy submission reach bgfx and only take effect
 * after bgfx initialization; construction and property access are safe.
 * Skipped members and reasons:
 * - renderTarget: a FrameBufferHandle (bgfx handle) with no Lua channel;
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/program handles and _createRT are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SavePass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SavePass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SavePass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.SavePass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSavePass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SavePass")
    b.constructor {_ => SavePass()}
    _prebindPpPassMembers(b, vm)
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<SavePass>().releasable)}))
    b.install(vm)
}
