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
 * @file[zh-cn] renderers_helpers_gridhelper GridHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.GridHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（size / divisions / color1 / color2；两个颜色支持 Color 对象或十六进制
 * 数值）以及继承自 LineSegments/Line/Object3D 的全部成员和 releasable / release。GridHelper 没有
 * 自有属性。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D、LineSegments（含
 * Line）与 IReleasable 成员。跳过成员：无。
 *
 * @file[en] renderers_helpers_gridhelper  Lua binding of GridHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.GridHelper as a Lua type
 * @explain[en] Binds the constructor (size / divisions / color1 / color2; both colors accept a Color
 * object or a hex number) plus every inherited LineSegments/Line/Object3D member and releasable /
 * release. GridHelper has no properties of its own. Lua class tables have no inheritance, so the
 * Object3D, LineSegments (including Line) and IReleasable members are reused before b.install.
 * Skipped: none.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GridHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.GridHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GridHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.GridHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGridHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.GridHelper")
    // ===== 构造：size / divisions / color1 / color2 =====
    b.constructor {
        args => GridHelper(size: prebindNum(args, 0, default: 10.0), divisions: prebindInt(args, 1, default: 10),
            color1: _prebindHlpColorArg(args, 2, default: Color(0x444444)),
            color2: _prebindHlpColorArg(args, 3, default: Color(0x888888)))
    }
    // ===== 继承成员：Object3D → Line → LineSegments → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpLineSegmentsMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    b.install(vm)
}
