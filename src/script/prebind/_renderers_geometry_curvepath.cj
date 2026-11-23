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
 * @file[zh-cn] renderers_geometry_curvepath 复合曲线路径 CurvePath 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.CurvePath 绑定为 Lua 类型并导出共用成员安装函数
 * @explain[zh-cn] 在 Curve 成员之上绑定：curves（只读对象数组，元素注册为 Curve）、autoClose 属性、
 * add(curve)、closePath()（链式返回自身）、getCurveLengths()（Lua 数值数组）。
 * getPoint/getLength/getPoints/getSpacedPoints/updateArcLengths 的重写经 Curve 成员虚分派生效。
 * 子类 Path/Shape 绑定复用 _prebindRgcCurvePathMembers。
 * 跳过成员及原因：
 * - cacheLengths：私有缓存字段。
 *
 * @file[en] renderers_geometry_curvepath  Lua binding of CurvePath (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.CurvePath and exports the shared member installer
 * @explain[en] On top of the Curve members it binds: curves (read-only object array with elements
 * registered as Curve), the autoClose property, add(curve), closePath() (returns self for chaining)
 * and getCurveLengths() (Lua numeric array). The getPoint/getLength/getPoints/getSpacedPoints/
 * updateArcLengths overrides take effect through virtual dispatch from the Curve members.
 * The Path/Shape subclass bindings reuse _prebindRgcCurvePathMembers.
 * Skipped members and reasons:
 * - cacheLengths: private cache field.
 */
package three.script.prebind

import std.collection.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将曲线列表转为 Lua 对象数组（元素注册为 Curve）
 * @param[zh-cn] items 曲线列表
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a curve list into a Lua object array (elements registered as Curve)
 * @param[en] items The curve list
 * @return[en] The Lua array value
 */
internal func _prebindRgcCurveListToLua(items: ArrayList<Curve>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.renderers.geometry.Curve")
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 为绑定器安装 CurvePath 的成员（构造除外）
 * @param[zh-cn] b 目标类绑定器
 *
 * @brief[en] Installs the CurvePath members (except the constructor) on a class binder
 * @param[en] b The target class binder
 */
internal func _prebindRgcCurvePathMembers(b: LuaClassBinder): Unit {
    b.property("curves", getter: Some({ref => _prebindRgcCurveListToLua(ref.cast<CurvePath>().curves)}))
    b.property("autoClose", getter: Some({ref => LuaValue.of(ref.cast<CurvePath>().autoClose)}),
        setter: Some({ref, v => ref.cast<CurvePath>().autoClose = v.boolValue()}))
    b.method("add") {
        ref, args =>
            ref.cast<CurvePath>().add(prebindAs<Curve>(args, 0))
            []
    }
    b.method("closePath") {
        ref, _ =>
            ref.cast<CurvePath>().closePath()
            [LuaValue.Object(ref.id)]
    }
    b.method("getCurveLengths") {
        ref, _ => [LuaValue.of(ref.cast<CurvePath>().getCurveLengths())]
    }
}

/**
 * @brief[zh-cn] 安装 CurvePath 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.CurvePath）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CurvePath
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.CurvePath)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCurvePath(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.CurvePath")
    b.constructor {_ => CurvePath()}
    _prebindRgcCurveMembers(b)
    _prebindRgcCurvePathMembers(b)
    b.install(vm)
}
