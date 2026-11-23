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
 * @file[zh-cn] renderers_helpers_axeshelper AxesHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.AxesHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（size）与方法 setColors（三轴颜色，返回自身）。AxesHelper 继承
 * LineSegments（LineSegments 继承 Line，Line 继承 Object3D），Lua 类表没有继承，本类绑定在
 * b.install 之前依次复用 Object3D、LineSegments（含 Line）与 IReleasable 成员。跳过成员：
 * 无（getCullingGeometry 由基类绑定统一跳过）。
 *
 * @file[en] renderers_helpers_axeshelper  Lua binding of AxesHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.AxesHelper as a Lua type
 * @explain[en] Binds the constructor (size) and setColors (three axis colors, returns self).
 * AxesHelper extends LineSegments (LineSegments extends Line, Line extends Object3D); since Lua
 * class tables have no inheritance, the Object3D, LineSegments (including Line) and IReleasable
 * members are reused before b.install. Skipped: none (getCullingGeometry is skipped by the base
 * binding).
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AxesHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.AxesHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AxesHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.AxesHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAxesHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.AxesHelper")
    // ===== 构造：size =====
    b.constructor {
        args => AxesHelper(size: prebindNum(args, 0, default: 1.0))
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 坐标轴自有成员 =====
    b.method("setColors") {
        ref, args =>
            ref
                .cast<AxesHelper>()
                .setColors(_prebindHlpColorArg(args, 0, default: Color(0xff0000)),
                    _prebindHlpColorArg(args, 1, default: Color(0x00ff00)),
                    _prebindHlpColorArg(args, 2, default: Color(0x0000ff)))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
