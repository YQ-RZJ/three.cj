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
 * @file[zh-cn] renderers_lights_pointlightshadow 点光源阴影 PointLightShadow 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.PointLightShadow 绑定为 Lua 类型
 * @explain[zh-cn] 绑定无参构造、属性（cubeDirections / cubeUps）与方法（getCubeDirection /
 * getCubeUp / computeFaceViewMatrix）。两个数组均为 Vector3 对象数组，读写时逐项注册/取回。
 * Lua 类表没有继承，本类绑定在 b.install 之前复用 _prebindLgtLightShadowMembers 的成员；
 * updateMatrices 的覆写经 LightShadow 绑定的虚函数分派生效，不重复登记。
 *
 * @file[en] renderers_lights_pointlightshadow  Lua binding of PointLightShadow
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.PointLightShadow as a Lua type
 * @explain[en] Binds the no-arg constructor, properties (cubeDirections / cubeUps) and methods
 * (getCubeDirection / getCubeUp / computeFaceViewMatrix). Both arrays are Vector3 object arrays,
 * registered/fetched item by item. Lua class tables have no inheritance, so this binding reuses
 * _prebindLgtLightShadowMembers before b.install; the updateMatrices override is dispatched
 * virtually through the LightShadow binding and is not registered twice.
 */
package three.script.prebind

import std.collection.*
import three.renderers.lights.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将向量列表转为 Lua 对象数组
 * @param[zh-cn] items 向量列表
 * @return[zh-cn] Lua 数组值（元素注册为 Vector3）
 *
 * @brief[en] Converts a vector list into a Lua object array
 * @param[en] items The vector list
 * @return[en] Lua array value (elements registered as Vector3)
 */
internal func _prebindLgtVector3ListToLua(items: ArrayList<Vector3>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.core.math.Vector3")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 PointLightShadow 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.PointLightShadow）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of PointLightShadow
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.PointLightShadow)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installPointLightShadow(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.PointLightShadow")
    // ===== 构造 =====
    b.constructor {_ => PointLightShadow()}
    // ===== 继承成员：LightShadow =====
    _prebindLgtLightShadowMembers(b, vm)
    // ===== 点光源阴影自有成员 =====
    b.property("cubeDirections", getter: Some({
        ref => _prebindLgtVector3ListToLua(ref.cast<PointLightShadow>().cubeDirections)
    }), setter: Some({
        ref, v => ref.cast<PointLightShadow>().cubeDirections = prebindObjList<Vector3>(vm, [v], 0)
    }))
    b.property("cubeUps", getter: Some({
        ref => _prebindLgtVector3ListToLua(ref.cast<PointLightShadow>().cubeUps)
    }), setter: Some({
        ref, v => ref.cast<PointLightShadow>().cubeUps = prebindObjList<Vector3>(vm, [v], 0)
    }))
    b.method("getCubeDirection") {
        ref, args => [prebindRegister(ref.cast<PointLightShadow>().getCubeDirection(prebindInt(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("getCubeUp") {
        ref, args => [prebindRegister(ref.cast<PointLightShadow>().getCubeUp(prebindInt(args, 0)),
            "three.core.math.Vector3")]
    }
    b.method("computeFaceViewMatrix") {
        ref, args => [prebindRegister(
            ref.cast<PointLightShadow>().computeFaceViewMatrix(prebindAs<Vector3>(args, 0), prebindInt(args, 1)),
            "three.core.math.Matrix4")]
    }
    b.install(vm)
}
