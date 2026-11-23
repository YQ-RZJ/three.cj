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
 * @file[zh-cn] renderers_geometry_ellipsecurve 椭圆曲线 EllipseCurve 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.EllipseCurve 绑定为 Lua 类型并导出共用成员安装函数
 * @explain[zh-cn] 复用 Curve 成员，并绑定构造（aX/aY/xRadius/yRadius/aStartAngle/aEndAngle/
 * aClockwise/aRotation，缺省值与源码一致，其中 aEndAngle 默认 2π）与同名的 8 个读写属性。
 * 子类 ArcCurve 复用 _prebindRgcEllipseCurveMembers。
 *
 * @file[en] renderers_geometry_ellipsecurve  Lua binding of EllipseCurve (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.EllipseCurve and exports the shared member installer
 * @explain[en] Reuses the Curve members and binds the constructor (aX/aY/xRadius/yRadius/
 * aStartAngle/aEndAngle/aClockwise/aRotation with the same defaults as the source, aEndAngle
 * defaulting to 2π) plus the eight matching read-write properties. The ArcCurve subclass reuses
 * _prebindRgcEllipseCurveMembers.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为绑定器安装 EllipseCurve 的成员（构造除外）
 * @param[zh-cn] b 目标类绑定器
 *
 * @brief[en] Installs the EllipseCurve members (except the constructor) on a class binder
 * @param[en] b The target class binder
 */
internal func _prebindRgcEllipseCurveMembers(b: LuaClassBinder): Unit {
    b.property("aX", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aX)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aX = v.numberValue()}))
    b.property("aY", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aY)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aY = v.numberValue()}))
    b.property("xRadius", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().xRadius)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().xRadius = v.numberValue()}))
    b.property("yRadius", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().yRadius)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().yRadius = v.numberValue()}))
    b.property("aStartAngle", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aStartAngle)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aStartAngle = v.numberValue()}))
    b.property("aEndAngle", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aEndAngle)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aEndAngle = v.numberValue()}))
    b.property("aClockwise", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aClockwise)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aClockwise = v.boolValue()}))
    b.property("aRotation", getter: Some({ref => LuaValue.of(ref.cast<EllipseCurve>().aRotation)}),
        setter: Some({ref, v => ref.cast<EllipseCurve>().aRotation = v.numberValue()}))
}

/**
 * @brief[zh-cn] 安装 EllipseCurve 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.EllipseCurve）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of EllipseCurve
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.EllipseCurve)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installEllipseCurve(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.EllipseCurve")
    b.constructor {
        args => EllipseCurve(aX: prebindNum(args, 0), aY: prebindNum(args, 1), xRadius: prebindNum(args, 2, default: 1.0),
            yRadius: prebindNum(args, 3, default: 1.0), aStartAngle: prebindNum(args, 4),
            aEndAngle: prebindNum(args, 5, default: 2.0 * PI), aClockwise: prebindBool(args, 6),
            aRotation: prebindNum(args, 7))
    }
    _prebindRgcCurveMembers(b)
    _prebindRgcEllipseCurveMembers(b)
    b.install(vm)
}
