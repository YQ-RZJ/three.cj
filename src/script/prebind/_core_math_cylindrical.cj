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
 * @file[zh-cn] core_math_cylindrical 圆柱坐标 Cylindrical 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.math.Cylindrical 绑定为 Lua 类型 three.core.math.Cylindrical
 * @explain[zh-cn] 覆盖构造（new/无参与三参）、实例方法（set/copy/setFromVector3/
 * setFromCartesianCoords/clone）与属性（radius/theta/y）。互变异构方法均返回自身
 * （Lua 链式可用）。
 *
 * @file[en] core_math_cylindrical  Lua binding of the cylindrical coordinates Cylindrical (three.script.prebind)
 * @brief[en] Binds three.core.math.Cylindrical as the Lua type three.core.math.Cylindrical
 * @explain[en] Covers construction (new / no-arg / three-arg), instance methods
 * (set/copy/setFromVector3/setFromCartesianCoords/clone) and properties (radius/theta/y).
 * Mutating methods return self for Lua chaining.
 */
package three.script.prebind

import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Cylindrical 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.math.Cylindrical）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Cylindrical
 * @param[en] vm The target virtual machine (class table installed at three.core.math.Cylindrical)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCylindrical(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.math.Cylindrical")
    // ===== 构造 =====
    b.constructor {
        args => if (args.size >= 3) {
            Cylindrical(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
        } else {
            Cylindrical()
        }
    }
    // ===== 属性 =====
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<Cylindrical>().radius)}),
        setter: Some({ref, v => ref.cast<Cylindrical>().radius = v.numberValue()}))
    b.property("theta", getter: Some({ref => LuaValue.of(ref.cast<Cylindrical>().theta)}),
        setter: Some({ref, v => ref.cast<Cylindrical>().theta = v.numberValue()}))
    b.property("y", getter: Some({ref => LuaValue.of(ref.cast<Cylindrical>().y)}),
        setter: Some({ref, v => ref.cast<Cylindrical>().y = v.numberValue()}))
    // ===== 方法 =====
    b.method("set") {
        ref, args =>
            ref.cast<Cylindrical>().set(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("copy") {
        ref, args =>
            ref.cast<Cylindrical>().copy(prebindAs<Cylindrical>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromVector3") {
        ref, args =>
            ref.cast<Cylindrical>().setFromVector3(prebindAs<Vector3>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setFromCartesianCoords") {
        ref, args =>
            ref
                .cast<Cylindrical>()
                .setFromCartesianCoords(args[0].numberValue(), args[1].numberValue(), args[2].numberValue())
            [LuaValue.Object(ref.id)]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Cylindrical>().clone(), "three.core.math.Cylindrical")]
    }
    b.install(vm)
}
