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
 * @file[zh-cn] renderers_helpers_arrowhelper ArrowHelper 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.helpers.ArrowHelper 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（dir / origin / length / color / headLength / headWidth，按源码顺序
 * 以位置参数传入；color 支持 Color 对象或十六进制数值）、属性（line / cone）与方法
 * （setDirection / setLength / setColor / releasable / release）。Lua 类表没有继承，本类绑定在
 * b.install 之前依次复用 Object3D 与 IReleasable 成员。跳过成员：copy 仅重写 Object3D.copy，
 * 由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_helpers_arrowhelper  Lua binding of ArrowHelper (three.script.prebind)
 * @brief[en] Binds three.renderers.helpers.ArrowHelper as a Lua type
 * @explain[en] Binds the constructor (dir / origin / length / color / headLength / headWidth as
 * positional arguments in source order; color accepts a Color object or a hex number), the
 * properties line / cone and the methods setDirection / setLength / setColor / releasable / release.
 * Lua class tables have no inheritance, so the Object3D and IReleasable members are reused before
 * b.install. Skipped: copy, an override of Object3D.copy covered by the base binding via virtual
 * dispatch.
 */
package three.script.prebind

import three.renderers.helpers.*
import three.scene.objects.*
import three.scene.entity.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ArrowHelper 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.helpers.ArrowHelper）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ArrowHelper
 * @param[en] vm The target virtual machine (class table at three.renderers.helpers.ArrowHelper)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installArrowHelper(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.helpers.ArrowHelper")
    // ===== 构造：dir / origin / length / color / headLength / headWidth =====
    b.constructor {
        args => ArrowHelper(dir: prebindVec3(args, 0, default: Vector3(0.0, 0.0, 1.0)), origin: prebindVec3(args, 1),
            length: prebindNum(args, 2, default: 1.0), color: _prebindHlpHexArg(args, 3, default: 0xffff00),
            headLength: prebindNum(args, 4), headWidth: prebindNum(args, 5))
    }
    // ===== 继承成员：Object3D → IReleasable =====
    prebindInstallObject3DMembers(b, vm)
    _prebindHlpHelperMembers(b, vm)
    // ===== 箭头自有成员 =====
    b.property("line", getter: Some({
        ref => prebindRegister(ref.cast<ArrowHelper>().line, "three.scene.entity.Line")
    }), setter: Some({
        ref, v => ref.cast<ArrowHelper>().line = prebindAsValue<Line>(v)
    }))
    b.property("cone", getter: Some({
        ref => prebindRegister(ref.cast<ArrowHelper>().cone, "three.scene.entity.Mesh")
    }), setter: Some({
        ref, v => ref.cast<ArrowHelper>().cone = prebindAsValue<Mesh>(v)
    }))
    b.method("setDirection") {
        ref, args =>
            ref.cast<ArrowHelper>().setDirection(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setLength") {
        ref, args =>
            ref.cast<ArrowHelper>().setLength(prebindNum(args, 0), prebindNum(args, 1), prebindNum(args, 2))
            [LuaValue.Object(ref.id)]
    }
    b.method("setColor") {
        ref, args =>
            ref.cast<ArrowHelper>().setColor(_prebindHlpColorArg(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}
