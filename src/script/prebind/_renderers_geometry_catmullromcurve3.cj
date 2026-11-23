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
 * @file[zh-cn] renderers_geometry_catmullromcurve3 CatmullRomCurve3 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.CatmullRomCurve3 绑定为 Lua 类型
 * @explain[zh-cn] 复用 Curve 成员（getPoint/copy 等虚分派生效），绑定 points（Array<Vector3>，
 * 读取为对象数组、写入经 prebindObjList<Vector3>）、closed、curveType、tension 属性，
 * 以及构造（points/closed/curveType/tension，缺省值与源码一致）。
 *
 * @file[en] renderers_geometry_catmullromcurve3  Lua binding of CatmullRomCurve3
 * @brief[en] Binds three.renderers.geometry.CatmullRomCurve3 as a Lua type
 * @explain[en] Reuses the Curve members (getPoint/copy etc. take effect through virtual dispatch)
 * and binds the points (Array<Vector3>: read as an object array, written through
 * prebindObjList<Vector3>), closed, curveType and tension properties plus the constructor
 * (points/closed/curveType/tension with the same defaults as the source).
 */
package three.script.prebind

import std.collection.*
import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CatmullRomCurve3 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.CatmullRomCurve3）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CatmullRomCurve3
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.CatmullRomCurve3)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCatmullRomCurve3(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.CatmullRomCurve3")
    b.constructor {
        args => CatmullRomCurve3(points: prebindObjList<Vector3>(vm, args, 0).toArray(), closed: prebindBool(args, 1),
            curveType: prebindStr(args, 2, default: "centripetal"), tension: prebindNum(args, 3, default: 0.5))
    }
    _prebindRgcCurveMembers(b)
    b.property("points", getter: Some({ref => _prebindRgcVec3ArrayToLua(ref.cast<CatmullRomCurve3>().points)}),
        setter: Some({
            ref, v => ref.cast<CatmullRomCurve3>().points = prebindObjList<Vector3>(vm, [v], 0).toArray()
        }))
    b.property("closed", getter: Some({ref => LuaValue.of(ref.cast<CatmullRomCurve3>().closed)}),
        setter: Some({ref, v => ref.cast<CatmullRomCurve3>().closed = v.boolValue()}))
    b.property("curveType", getter: Some({ref => LuaValue.of(ref.cast<CatmullRomCurve3>().curveType)}),
        setter: Some({ref, v => ref.cast<CatmullRomCurve3>().curveType = v.stringValue()}))
    b.property("tension", getter: Some({ref => LuaValue.of(ref.cast<CatmullRomCurve3>().tension)}),
        setter: Some({ref, v => ref.cast<CatmullRomCurve3>().tension = v.numberValue()}))
    b.install(vm)
}
