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
 * @file[zh-cn] renderers_postprocessing_saopass SAO pass 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.SAOPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera)，绑定 output / saoBias / saoIntensity / saoScale /
 * saoKernelRadius / saoMinResolution / saoBlur / saoBlurRadius / saoBlurStdDev /
 * saoBlurDepthCutoff 参数属性与 SAO_VIEW_ID_BASE / OUTPUT_DEFAULT / OUTPUT_SAO / OUTPUT_NORMAL
 * 常量（按同名 staticMethod 取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员
 * （含 setSize / release）。
 * 使用前提：法线/深度/SAO/blur 各 RT 的创建与多次场景提交都触达 bgfx，必须由引擎完成 bgfx
 * 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、uniform 注册表、几何体缓存与 _createRTs / _blurPasses 等为内部实现。
 *
 * @file[en] renderers_postprocessing_saopass  Lua binding of the SAO pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.SAOPass as a Lua type
 * @explain[en] Constructor new(scene, camera); binds the output / saoBias / saoIntensity / saoScale /
 * saoKernelRadius / saoMinResolution / saoBlur / saoBlurRadius / saoBlurStdDev /
 * saoBlurDepthCutoff parameter properties and the SAO_VIEW_ID_BASE / OUTPUT_DEFAULT / OUTPUT_SAO /
 * OUTPUT_NORMAL constants (read as same-named staticMethods), and reuses _prebindPpPassMembers for
 * the Pass base members (including setSize / release).
 * Precondition: creation of the normal/depth/SAO/blur RTs and the multiple scene submissions reach
 * bgfx and only take effect after bgfx initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, uniform registry, geometry caches and the internal
 *   _createRTs / _blurPasses helpers are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SAOPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.SAOPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SAOPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.SAOPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSAOPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.SAOPass")
    b.constructor {
        args => SAOPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    b.property("output", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().output)}),
        setter: Some({ref, v => ref.cast<SAOPass>().output = v.intValue()}))
    b.property("saoBias", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoBias)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoBias = v.numberValue()}))
    b.property("saoIntensity", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoIntensity)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoIntensity = v.numberValue()}))
    b.property("saoScale", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoScale)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoScale = v.numberValue()}))
    b.property("saoKernelRadius", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoKernelRadius)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoKernelRadius = v.numberValue()}))
    b.property("saoMinResolution", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoMinResolution)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoMinResolution = v.numberValue()}))
    b.property("saoBlur", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoBlur)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoBlur = v.boolValue()}))
    b.property("saoBlurRadius", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoBlurRadius)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoBlurRadius = v.intValue()}))
    b.property("saoBlurStdDev", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoBlurStdDev)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoBlurStdDev = v.numberValue()}))
    b.property("saoBlurDepthCutoff", getter: Some({ref => LuaValue.of(ref.cast<SAOPass>().saoBlurDepthCutoff)}),
        setter: Some({ref, v => ref.cast<SAOPass>().saoBlurDepthCutoff = v.numberValue()}))
    b.staticMethod("SAO_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(SAOPass.SAO_VIEW_ID_BASE))]
    }
    b.staticMethod("OUTPUT_DEFAULT") {_ => [LuaValue.of(SAOPass.OUTPUT_DEFAULT)]}
    b.staticMethod("OUTPUT_SAO") {_ => [LuaValue.of(SAOPass.OUTPUT_SAO)]}
    b.staticMethod("OUTPUT_NORMAL") {_ => [LuaValue.of(SAOPass.OUTPUT_NORMAL)]}
    b.install(vm)
}
