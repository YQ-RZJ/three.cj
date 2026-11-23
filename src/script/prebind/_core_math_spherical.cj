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
 * @file[zh-cn] core_math_spherical 球坐标 Spherical 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Spherical 绑定为 Lua 类型 three.core.math.Spherical
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/copy/makeSafe/setFromVector3/
 * setFromCartesianCoords/toVector3/clone）与属性（radius/phi/theta）。互变异构方法均返回
 * 自身（Lua 链式可用）；toVector3 返回新的 Vector3 实例。
 *
 * @file[en] core_math_spherical  Lua binding of the spherical coordinates Spherical (three.script.prebind)
 * @brief[en] Binds three.core.math.Spherical as the Lua type three.core.math.Spherical
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/copy/makeSafe/setFromVector3/setFromCartesianCoords/toVector3/clone) and properties
 * (radius/phi/theta). Mutating methods return self for Lua chaining; toVector3 returns a
 * new Vector3 instance.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Spherical 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Spherical）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Spherical
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Spherical)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSpherical(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Spherical")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Spherical(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
        } else {
            Spherical()
        }
    }
    // ===== 属性 =====
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<Spherical>().radius)}),
        setter: Some({ref, v => ref.cast<Spherical>().radius = v.numberValue()}))
    b.property("phi", getter: Some({ref => LuaValue.of(ref.cast<Spherical>().phi)}),
        setter: Some({ref, v => ref.cast<Spherical>().phi = v.numberValue()}))
    b.property("theta", getter: Some({ref => LuaValue.of(ref.cast<Spherical>().theta)}),
        setter: Some({ref, v => ref.cast<Spherical>().theta = v.numberValue()}))
    // ===== 方法 =====
    b.method("set") {
        ref, args =>
            ref.cast<Spherical>().set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Spherical>().copy(prebindAs<Spherical>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("makeSafe") {
        ref, _ =>
            ref.cast<Spherical>().makeSafe()
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromVector3") {
        ref, args =>
            ref.cast<Spherical>().setFromVector3(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCartesianCoords") {
        ref, args =>
            ref
                .cast<Spherical>()
                .setFromCartesianCoords(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("toVector3") {
        ref, _ => [prebindRegister(ref.cast<Spherical>().toVector3(), "three.core.math.Vector3")]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Spherical>().clone(), "three.core.math.Spherical")]
    }
    b.install(vm)
}
