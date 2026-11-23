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
 * @file[zh-cn] renderers_postprocessing_volumecloudpass 体积云 pass VolumeCloudPass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.VolumeCloudPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new(camera[, cloudCenter[, cloudHalfSize[, base[, threshold[, range[,
 * opacity[, steps[, texSize]]]]]]]])，默认值 Vector3(0,0,0) / Vector3(4,2,4) / Color(0x798aa0) /
 * 0.25 / 0.1 / 0.25 / 100 / 64；绑定 camera / cloudCenter / cloudHalfSize / base / threshold /
 * range / opacity / steps / frame / texSize 属性，复用 _prebindPpShaderPassMembers 安装
 * ShaderPass 基类成员（其内部先安装 Pass 基类成员）。
 * 使用前提：3D 噪声纹理的创建（onAttach 触发）与全屏 ray marching 提交都触达渲染后端，必须由引擎
 * 完成渲染后端初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 GfxFrameBufferHandle，由 composer 链驱动；
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry)：IUniformRegistry 无 Lua 类型可往返；
 * - 私有 3D 噪声纹理句柄、矩阵暂存与 _createNoiseTexture 等为内部实现。
 *
 * @file[en] renderers_postprocessing_volumecloudpass  Lua binding of the volumetric cloud pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.VolumeCloudPass as a Lua type
 * @explain[en] Constructor new(camera[, cloudCenter[, cloudHalfSize[, base[, threshold[, range[,
 * opacity[, steps[, texSize]]]]]]]]), defaults Vector3(0,0,0) / Vector3(4,2,4) / Color(0x798aa0) /
 * 0.25 / 0.1 / 0.25 / 100 / 64; binds the camera / cloudCenter / cloudHalfSize / base / threshold /
 * range / opacity / steps / frame / texSize properties, and reuses _prebindPpShaderPassMembers for
 * the ShaderPass base members (it installs the Pass base members first).
 * Precondition: creation of the 3D noise texture (triggered by onAttach) and the full-screen ray
 * marching submission reach the render backend and only take effect after render-backend
 * initialization. Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): GfxFrameBufferHandle parameters, driven by the composer chain;
 * - bindExtraUniforms(renderer, uniforms: IUniformRegistry): IUniformRegistry has no Lua type to round-trip;
 * - the private 3D noise texture handle, matrix scratch and _createNoiseTexture are implementation
 *   details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.core.math.{Vector3, Color}
import three.renderers.cameras.Camera
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 VolumeCloudPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.VolumeCloudPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of VolumeCloudPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.VolumeCloudPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installVolumeCloudPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.VolumeCloudPass")
    b.constructor {
        args => VolumeCloudPass(prebindAs<Camera>(args, 0),
            cloudCenter: prebindVec3(args, 1, default: Vector3(0.0, 0.0, 0.0)),
            cloudHalfSize: prebindVec3(args, 2, default: Vector3(4.0, 2.0, 4.0)),
            base: _prebindPpColor(args, 3, default: Color(0x798aa0)), threshold: prebindNum(args, 4, default: 0.25),
            range: prebindNum(args, 5, default: 0.1), opacity: prebindNum(args, 6, default: 0.25),
            steps: prebindNum(args, 7, default: 100.0), texSize: prebindInt(args, 8, default: 64))
    }
    _prebindPpShaderPassMembers(b, vm)
    b.property("camera", getter: Some({
        ref => prebindRegister(ref.cast<VolumeCloudPass>().camera, "three.renderers.cameras.Camera")
    }), setter: Some({
        ref, v => ref.cast<VolumeCloudPass>().camera = prebindAsValue<Camera>(v)
    }))
    b.property("cloudCenter", getter: Some({
        ref => prebindRegister(ref.cast<VolumeCloudPass>().cloudCenter, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<VolumeCloudPass>().cloudCenter = prebindAsValue<Vector3>(v)
    }))
    b.property("cloudHalfSize", getter: Some({
        ref => prebindRegister(ref.cast<VolumeCloudPass>().cloudHalfSize, "three.core.math.Vector3")
    }), setter: Some({
        ref, v => ref.cast<VolumeCloudPass>().cloudHalfSize = prebindAsValue<Vector3>(v)
    }))
    b.property("base", getter: Some({
        ref => prebindRegister(ref.cast<VolumeCloudPass>().base, "three.core.math.Color")
    }), setter: Some({
        ref, v => ref.cast<VolumeCloudPass>().base = prebindAsValue<Color>(v)
    }))
    b.property("threshold", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().threshold)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().threshold = v.numberValue()}))
    b.property("range", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().range)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().range = v.numberValue()}))
    b.property("opacity", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().opacity)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().opacity = v.numberValue()}))
    b.property("steps", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().steps)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().steps = v.numberValue()}))
    b.property("frame", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().frame)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().frame = v.intValue()}))
    b.property("texSize", getter: Some({ref => LuaValue.of(ref.cast<VolumeCloudPass>().texSize)}),
        setter: Some({ref, v => ref.cast<VolumeCloudPass>().texSize = v.intValue()}))
    b.install(vm)
}
