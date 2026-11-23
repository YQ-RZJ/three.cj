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
 * @file[zh-cn] renderers_postprocessing_bokehpass 景深 bokeh pass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.BokehPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera[, focus[, aperture[, maxblur]]])（默认 1.0 / 0.025 /
 * 1.0），绑定 focus / aperture / maxblur / debugMode 属性与常量 BOKEH_VIEW_ID_BASE
 * （按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员（含 setSize / release）。
 * 使用前提：深度 RT 创建/销毁、场景深度渲染与 41 抽头合成都触达 bgfx，必须由引擎完成 bgfx 初始化
 * 后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、场景几何体缓存、逐帧上传缓冲与 _createRTs 等为内部实现。
 *
 * @file[en] renderers_postprocessing_bokehpass  Lua binding of the depth-of-field bokeh pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.BokehPass as a Lua type
 * @explain[en] Constructor new(scene, camera[, focus[, aperture[, maxblur]]]) (defaults 1.0 / 0.025 /
 * 1.0); binds the focus / aperture / maxblur / debugMode properties and the BOKEH_VIEW_ID_BASE
 * constant (read as a function), and reuses _prebindPpPassMembers for the Pass base members
 * (including setSize / release).
 * Precondition: depth RT creation/destruction, scene depth renderers and the 41-tap composite reach
 * bgfx and only take effect after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, geometry caches, per-frame upload buffers and _createRTs
 *   are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 BokehPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.BokehPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BokehPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.BokehPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBokehPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.BokehPass")
    b.constructor {
        args => BokehPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1), focus: prebindNum(args, 2, default: 1.0),
            aperture: prebindNum(args, 3, default: 0.025), maxblur: prebindNum(args, 4, default: 1.0))
    }
    _prebindPpPassMembers(b, vm)
    b.property("focus", getter: Some({ref => LuaValue.of(ref.cast<BokehPass>().focus)}),
        setter: Some({ref, v => ref.cast<BokehPass>().focus = v.numberValue()}))
    b.property("aperture", getter: Some({ref => LuaValue.of(ref.cast<BokehPass>().aperture)}),
        setter: Some({ref, v => ref.cast<BokehPass>().aperture = v.numberValue()}))
    b.property("maxblur", getter: Some({ref => LuaValue.of(ref.cast<BokehPass>().maxblur)}),
        setter: Some({ref, v => ref.cast<BokehPass>().maxblur = v.numberValue()}))
    b.property("debugMode", getter: Some({ref => LuaValue.of(ref.cast<BokehPass>().debugMode)}),
        setter: Some({ref, v => ref.cast<BokehPass>().debugMode = v.intValue()}))
    b.staticMethod("BOKEH_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(BokehPass.BOKEH_VIEW_ID_BASE))]
    }
    b.install(vm)
}
