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
 * @file[zh-cn] renderers_postprocessing_glitchpass 数字故障 pass GlitchPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.GlitchPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([dt_size])（源码参数名 dt_size，默认 64），绑定 dtSize（只读）/
 * goWild 属性、常量 GLITCH_VIEW_ID_BASE（按函数取值）与只读 releasable，并复用
 * _prebindPpPassMembers 安装 Pass 基类成员。
 * 使用前提：位移贴图的创建发生在 onAttach（由 composer.addPass 触发），残影合成在 render 内，
 * 均触达 bgfx，必须由引擎完成 bgfx 初始化后执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有位移贴图句柄、随机种子/帧计数、program 缓存与 _generateHeightmap 等为内部实现。
 *
 * @file[en] renderers_postprocessing_glitchpass  Lua binding of the digital glitch pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.GlitchPass as a Lua type
 * @explain[en] Constructor new([dt_size]) (source parameter name dt_size, default 64); binds the
 * read-only dtSize / goWild properties, the GLITCH_VIEW_ID_BASE constant (read as a function) and
 * the read-only releasable, and reuses _prebindPpPassMembers for the Pass base members.
 * Precondition: the displacement map is created in onAttach (triggered by composer.addPass) and
 * compositing happens in render; both reach bgfx and require completed bgfx initialization.
 * Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private heightmap handle, random seed/frame counters, program cache and _generateHeightmap
 *   are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GlitchPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.GlitchPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GlitchPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.GlitchPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGlitchPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.GlitchPass")
    b.constructor {
        args => GlitchPass(dt_size: prebindInt(args, 0, default: 64))
    }
    _prebindPpPassMembers(b, vm)
    b.property("dtSize", getter: Some({ref => LuaValue.of(ref.cast<GlitchPass>().dtSize)}))
    b.property("goWild", getter: Some({ref => LuaValue.of(ref.cast<GlitchPass>().goWild)}),
        setter: Some({ref, v => ref.cast<GlitchPass>().goWild = v.boolValue()}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<GlitchPass>().releasable)}))
    b.staticMethod("GLITCH_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(GlitchPass.GLITCH_VIEW_ID_BASE))]
    }
    b.install(vm)
}
