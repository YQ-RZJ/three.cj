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
 * @file[zh-cn] scene_scenegraph_fog Fog 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.scenegraph.Fog 绑定为 Lua 类型 three.scene.scenegraph.Fog
 * @explain[zh-cn] 构造按首个参数分派：无参 → Fog()；对象 → Fog(color: Color, near, far)；
 * 数值 → Fog(hex: UInt32, near, far)。绑定 color/near/far/name 属性与 clone（返回新 Fog，
 * 经 prebindRegister 注册）。两个带参构造的 near/far 为具名参数，Lua 侧按位置 1/2 传入即可。
 * 无跳过成员。
 *
 * @file[en] scene_scenegraph_fog  Lua binding of Fog (three.script.prebind)
 * @brief[en] Binds three.scene.scenegraph.Fog as the Lua type three.scene.scenegraph.Fog
 * @explain[en] The constructor dispatches on the first argument: no arguments -> Fog();
 * an object -> Fog(color: Color, near, far); a number -> Fog(hex: UInt32, near, far). Binds the
 * color/near/far/name properties and clone (returns a new Fog registered via prebindRegister).
 * The near/far parameters of both value constructors are named in Cangjie; on the Lua side they
 * are simply passed at positions 1/2. No members are skipped.
 */
package three.script.prebind

import three.core.math.*
import three.scene.scenegraph.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Fog 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.scenegraph.Fog）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Fog
 * @param[en] vm The target virtual machine (class table installed at three.scene.scenegraph.Fog)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFog(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.scenegraph.Fog")
    // ===== 构造（无参 / Color / hex） =====
    b.constructor {
        args => if (args.size >= 1 && args[0].isObject) {
            Fog(prebindAs<Color>(args, 0), near: prebindNum(args, 1, default: 1.0),
                far: prebindNum(args, 2, default: 1000.0))
        } else if (args.size >= 1) {
            Fog(UInt32(prebindInt(args, 0) & 0xFFFFFFFF), near: prebindNum(args, 1, default: 1.0),
                far: prebindNum(args, 2, default: 1000.0))
        } else {
            Fog()
        }
    }
    // ===== 属性 =====
    b.property("color", getter: Some({ref => prebindRegister(ref.cast<Fog>().color, "three.core.math.Color")}),
        setter: Some({ref, v => ref.cast<Fog>().color = prebindAsValue<Color>(v)}))
    b.property("near", getter: Some({ref => LuaValue.of(ref.cast<Fog>().near)}),
        setter: Some({ref, v => ref.cast<Fog>().near = v.numberValue()}))
    b.property("far", getter: Some({ref => LuaValue.of(ref.cast<Fog>().far)}),
        setter: Some({ref, v => ref.cast<Fog>().far = v.numberValue()}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<Fog>().name)}),
        setter: Some({ref, v => ref.cast<Fog>().name = v.stringValue()}))
    // ===== 克隆 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<Fog>().clone(), "three.scene.scenegraph.Fog")]
    }
    b.install(vm)
}
