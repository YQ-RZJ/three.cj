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
 * @file[zh-cn] renderers_geometry_arccurve 圆弧曲线 ArcCurve 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.geometry.ArcCurve 绑定为 Lua 类型
 * @explain[zh-cn] 复用 Curve 与 EllipseCurve 成员，绑定构造（aX/aY/aRadius/aStartAngle/
 * aEndAngle/aClockwise，缺省值与源码一致，aEndAngle 默认 2π）。ArcCurve 自身无新增 public 字段。
 *
 * @file[en] renderers_geometry_arccurve  Lua binding of ArcCurve (three.script.prebind)
 * @brief[en] Binds three.renderers.geometry.ArcCurve as a Lua type
 * @explain[en] Reuses the Curve and EllipseCurve members and binds the constructor (aX/aY/aRadius/
 * aStartAngle/aEndAngle/aClockwise with the same defaults as the source, aEndAngle defaulting to
 * 2π). ArcCurve adds no public fields of its own.
 */
package three.script.prebind

import three.core.math.*
import three.renderers.geometry.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ArcCurve 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.geometry.ArcCurve）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ArcCurve
 * @param[en] vm The target virtual machine (class table at three.renderers.geometry.ArcCurve)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installArcCurve(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.geometry.ArcCurve")
    b.constructor {
        args => ArcCurve(aX: prebindNum(args, 0), aY: prebindNum(args, 1), aRadius: prebindNum(args, 2, default: 1.0),
            aStartAngle: prebindNum(args, 3), aEndAngle: prebindNum(args, 4, default: 2.0 * PI),
            aClockwise: prebindBool(args, 5))
    }
    _prebindRgcCurveMembers(b)
    _prebindRgcEllipseCurveMembers(b)
    b.install(vm)
}
