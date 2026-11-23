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
 * @file[zh-cn] renderers_postprocessing_gtaopass GTAO pass 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.GTAOPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(scene, camera)，绑定 output / blendIntensity / radius /
 * distanceExponent / thickness / distanceFallOff / scale / lumaPhi / depthPhi / normalPhi /
 * pdRadius 参数属性，OUTPUT_OFF / OUTPUT_DEFAULT / OUTPUT_DIFFUSE / OUTPUT_DEPTH / OUTPUT_NORMAL /
 * OUTPUT_AO / OUTPUT_DENOISE / GTAO_VIEW_ID_BASE 常量（按同名 staticMethod 取值），并复用
 * _prebindPpPassMembers 安装 Pass 基类成员（含 setSize / release）。
 * 使用前提：法线/深度/GTAO/PoissonDenoise 各 RT 的创建与多次场景提交都触达 bgfx，必须由引擎完成
 * bgfx 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/噪声纹理/program 句柄、Poisson 采样表、几何体缓存与 _createRTs /
 *   _generatePoissonDisk 等为内部实现。
 *
 * @file[en] renderers_postprocessing_gtaopass  Lua binding of the GTAO pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.GTAOPass as a Lua type
 * @explain[en] Constructor new(scene, camera); binds the output / blendIntensity / radius /
 * distanceExponent / thickness / distanceFallOff / scale / lumaPhi / depthPhi / normalPhi
 * parameter properties and the OUTPUT_OFF / OUTPUT_DEFAULT / OUTPUT_DIFFUSE / OUTPUT_DEPTH /
 * OUTPUT_NORMAL / OUTPUT_AO / OUTPUT_DENOISE / GTAO_VIEW_ID_BASE constants (read as same-named
 * staticMethods), and reuses _prebindPpPassMembers for the Pass base members (including setSize /
 * release).
 * Precondition: creation of the normal/depth/GTAO/PoissonDenoise RTs and the multiple scene
 * submissions reach bgfx and only take effect after bgfx initialization. Construction and property
 * access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/noise-texture/program handles, Poisson sample table, geometry caches and
 *   _createRTs / _generatePoissonDisk are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.scene.scenegraph.Scene
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GTAOPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.GTAOPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GTAOPass
 * @param[en] vm The target virtual machine (class table at three.renderers.postprocessing.GTAOPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGTAOPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.GTAOPass")
    b.constructor {
        args => GTAOPass(prebindAs<Scene>(args, 0), prebindAs<Camera>(args, 1))
    }
    _prebindPpPassMembers(b, vm)
    b.property("output", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().output)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().output = v.intValue()}))
    b.property("blendIntensity", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().blendIntensity)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().blendIntensity = v.numberValue()}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().radius)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().radius = v.numberValue()}))
    b.property("distanceExponent", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().distanceExponent)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().distanceExponent = v.numberValue()}))
    b.property("thickness", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().thickness)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().thickness = v.numberValue()}))
    b.property("distanceFallOff", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().distanceFallOff)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().distanceFallOff = v.numberValue()}))
    b.property("scale", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().scale)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().scale = v.numberValue()}))
    b.property("lumaPhi", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().lumaPhi)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().lumaPhi = v.numberValue()}))
    b.property("depthPhi", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().depthPhi)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().depthPhi = v.numberValue()}))
    b.property("normalPhi", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().normalPhi)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().normalPhi = v.numberValue()}))
    b.property("pdRadius", getter: Some({ref => LuaValue.of(ref.cast<GTAOPass>().pdRadius)}),
        setter: Some({ref, v => ref.cast<GTAOPass>().pdRadius = v.numberValue()}))
    b.staticMethod("GTAO_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(GTAOPass.GTAO_VIEW_ID_BASE))]
    }
    b.staticMethod("OUTPUT_OFF") {_ => [LuaValue.of(GTAOPass.OUTPUT_OFF)]}
    b.staticMethod("OUTPUT_DEFAULT") {_ => [LuaValue.of(GTAOPass.OUTPUT_DEFAULT)]}
    b.staticMethod("OUTPUT_DIFFUSE") {_ => [LuaValue.of(GTAOPass.OUTPUT_DIFFUSE)]}
    b.staticMethod("OUTPUT_DEPTH") {_ => [LuaValue.of(GTAOPass.OUTPUT_DEPTH)]}
    b.staticMethod("OUTPUT_NORMAL") {_ => [LuaValue.of(GTAOPass.OUTPUT_NORMAL)]}
    b.staticMethod("OUTPUT_AO") {_ => [LuaValue.of(GTAOPass.OUTPUT_AO)]}
    b.staticMethod("OUTPUT_DENOISE") {_ => [LuaValue.of(GTAOPass.OUTPUT_DENOISE)]}
    b.install(vm)
}
