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
 * @file[zh-cn] renderers_lights_directionallightshadow 平行光阴影 DirectionalLightShadow 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.DirectionalLightShadow 绑定为 Lua 类型
 * @explain[zh-cn] 绑定无参构造、属性（cascadeMatrices / cascadeFrustums）与方法
 * （enableCSM / updateCSMMatrices / getCascadeMatrix / getCascadeCamera / getCascadeFrustum）。
 * cascadeMatrices 为 Matrix4 对象数组、cascadeFrustums 为 Frustum 对象数组；查询方法返回
 * 对应对象。Lua 类表没有继承，本类绑定在 b.install 之前复用
 * _prebindLgtLightShadowMembers 的成员（含 release / copy / clone / updateMatrices）。
 *
 * @file[en] renderers_lights_directionallightshadow  Lua binding of DirectionalLightShadow
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.DirectionalLightShadow as a Lua type
 * @explain[en] Binds the no-arg constructor, properties (cascadeMatrices / cascadeFrustums) and
 * methods (enableCSM / updateCSMMatrices / getCascadeMatrix / getCascadeCamera /
 * getCascadeFrustum). cascadeMatrices is a Matrix4 object array, cascadeFrustums a Frustum object
 * array, and the query methods return the corresponding objects. Lua class tables have no
 * inheritance, so this binding reuses _prebindLgtLightShadowMembers (including release / copy /
 * clone / updateMatrices) before b.install.
 */
package three.script.prebind

import std.collection.*
import three.renderers.lights.*
import three.renderers.cameras.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将矩阵列表转为 Lua 对象数组
 * @param[zh-cn] items 矩阵列表
 * @return[zh-cn] Lua 数组值（元素注册为 Matrix4）
 *
 * @brief[en] Converts a matrix list into a Lua object array
 * @param[en] items The matrix list
 * @return[en] Lua array value (elements registered as Matrix4)
 */
internal func _prebindLgtMatrixListToLua(items: ArrayList<Matrix4>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Matrix4")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将视锥体列表转为 Lua 对象数组
 * @param[zh-cn] items 视锥体列表
 * @return[zh-cn] Lua 数组值（元素注册为 Frustum）
 *
 * @brief[en] Converts a frustum list into a Lua object array
 * @param[en] items The frustum list
 * @return[en] Lua array value (elements registered as Frustum)
 */
internal func _prebindLgtFrustumListToLua(items: ArrayList<Frustum>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Frustum")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 DirectionalLightShadow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.DirectionalLightShadow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DirectionalLightShadow
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.lights.DirectionalLightShadow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDirectionalLightShadow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.DirectionalLightShadow")
    // ===== 构造 =====
    b.constructor {_ => DirectionalLightShadow()}
    // ===== 继承成员：LightShadow =====
    _prebindLgtLightShadowMembers(b, vm)
    // ===== 平行光阴影自有成员 =====
    b.property("cascadeMatrices", getter: Some({
        ref => _prebindLgtMatrixListToLua(ref.cast<DirectionalLightShadow>().cascadeMatrices)
    }), setter: Some({
        ref, v => ref.cast<DirectionalLightShadow>().cascadeMatrices = prebindObjList<Matrix4>(vm, [v], 0)
    }))
    b.property("cascadeFrustums", getter: Some({
        ref => _prebindLgtFrustumListToLua(ref.cast<DirectionalLightShadow>().cascadeFrustums)
    }), setter: Some({
        ref, v => ref.cast<DirectionalLightShadow>().cascadeFrustums = prebindObjList<Frustum>(vm, [v], 0)
    }))
    b.method("enableCSM") {
        ref, args =>
            ref.cast<DirectionalLightShadow>().enableCSM(prebindAs<Camera>(args, 0))
            []
    }
    b.method("updateCSMMatrices") {
        ref, args =>
            ref.cast<DirectionalLightShadow>().updateCSMMatrices(prebindAs<Light>(args, 0), prebindAs<Camera>(args, 1))
            []
    }
    b.method("getCascadeMatrix") {
        ref, args => [prebindRegister(ref.cast<DirectionalLightShadow>().getCascadeMatrix(prebindInt(args, 0)),
            "three.core.math.Matrix4")]
    }
    b.method("getCascadeCamera") {
        ref, args => [prebindRegister(ref.cast<DirectionalLightShadow>().getCascadeCamera(prebindInt(args, 0)),
            "three.renderers.cameras.OrthographicCamera")]
    }
    b.method("getCascadeFrustum") {
        ref, args => [prebindRegister(ref.cast<DirectionalLightShadow>().getCascadeFrustum(prebindInt(args, 0)),
            "three.core.math.Frustum")]
    }
    b.install(vm)
}
