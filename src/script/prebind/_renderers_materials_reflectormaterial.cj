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
 * @file[zh-cn] renderers_materials_reflectormaterial 反射面材质 ReflectorMaterial 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.materials.ReflectorMaterial 绑定为 Lua 类型
 * @explain[zh-cn] 绑定 ReflectorMaterial 的反射参数：textureMatrix（Matrix4 注册对象）/
 * reflectorColor（Color 注册对象）/maxDistance/fresnelCoe/virtualCameraNear/virtualCameraFar/
 * virtualCameraProjectionMatrix/virtualCameraMatrixWorld/virtualCameraProjectionMatrixInverse/
 * resolutionX/resolutionY/useDepthTexture/distanceAttenuation/fresnel，并在 b.install 之前
 * 复用 _prebindMatMaterialMembers 安装 Material 基类成员。
 * 跳过成员及原因：
 * - tDiffuse / tDepth：TextureHandle 为 bgfx 句柄封装，无 Lua 通道；
 * - copy(source: ReflectorMaterial)：与基类 copy 同名，统一由 Material 级 copy 覆盖。
 *
 * @file[en] renderers_materials_reflectormaterial  Lua binding of ReflectorMaterial
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.materials.ReflectorMaterial as a Lua type
 * @explain[en] Binds the reflection parameters of ReflectorMaterial: textureMatrix (registered
 * Matrix4)/reflectorColor (registered Color)/maxDistance/fresnelCoe/virtualCameraNear/
 * virtualCameraFar/virtualCameraProjectionMatrix/virtualCameraMatrixWorld/
 * virtualCameraProjectionMatrixInverse/resolutionX/resolutionY/useDepthTexture/
 * distanceAttenuation/fresnel, and reuses _prebindMatMaterialMembers to install the Material base
 * members before b.install.
 * Skipped members and reasons:
 * - tDiffuse / tDepth: TextureHandle is a bgfx handle wrapper with no Lua channel;
 * - copy(source: ReflectorMaterial): it shares the Lua name with the base copy, which the
 *   Material-level copy covers.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ReflectorMaterial 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.materials.ReflectorMaterial）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ReflectorMaterial
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.materials.ReflectorMaterial)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installReflectorMaterial(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.materials.ReflectorMaterial")
    b.constructor {_ => ReflectorMaterial()}
    b.property("textureMatrix", getter: Some({
        ref => prebindRegister(ref.cast<ReflectorMaterial>().textureMatrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<ReflectorMaterial>().textureMatrix = prebindAsValue<Matrix4>(v)
    }))
    b.property("reflectorColor",
        getter: Some({ref => _prebindMatColorToLua(ref.cast<ReflectorMaterial>().reflectorColor)}), setter: Some({
            ref, v => ref.cast<ReflectorMaterial>().reflectorColor = _prebindMatColorFromLua(v)
        }))
    b.property("maxDistance", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().maxDistance)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().maxDistance = v.numberValue()}))
    b.property("fresnelCoe", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().fresnelCoe)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().fresnelCoe = v.numberValue()}))
    b.property("virtualCameraNear", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().virtualCameraNear)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().virtualCameraNear = v.numberValue()}))
    b.property("virtualCameraFar", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().virtualCameraFar)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().virtualCameraFar = v.numberValue()}))
    b.property("virtualCameraProjectionMatrix", getter: Some({
        ref => prebindRegister(ref.cast<ReflectorMaterial>().virtualCameraProjectionMatrix, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<ReflectorMaterial>().virtualCameraProjectionMatrix = prebindAsValue<Matrix4>(v)
    }))
    b.property("virtualCameraMatrixWorld", getter: Some({
        ref => prebindRegister(ref.cast<ReflectorMaterial>().virtualCameraMatrixWorld, "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<ReflectorMaterial>().virtualCameraMatrixWorld = prebindAsValue<Matrix4>(v)
    }))
    b.property("virtualCameraProjectionMatrixInverse", getter: Some({
        ref => prebindRegister(ref.cast<ReflectorMaterial>().virtualCameraProjectionMatrixInverse,
            "three.core.math.Matrix4")
    }), setter: Some({
        ref, v => ref.cast<ReflectorMaterial>().virtualCameraProjectionMatrixInverse = prebindAsValue<Matrix4>(v)
    }))
    b.property("resolutionX", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().resolutionX)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().resolutionX = v.numberValue()}))
    b.property("resolutionY", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().resolutionY)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().resolutionY = v.numberValue()}))
    b.property("useDepthTexture", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().useDepthTexture)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().useDepthTexture = v.boolValue()}))
    b.property("distanceAttenuation",
        getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().distanceAttenuation)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().distanceAttenuation = v.boolValue()}))
    b.property("fresnel", getter: Some({ref => LuaValue.of(ref.cast<ReflectorMaterial>().fresnel)}),
        setter: Some({ref, v => ref.cast<ReflectorMaterial>().fresnel = v.boolValue()}))
    _prebindMatMaterialMembers(b, vm)
    b.install(vm)
}
