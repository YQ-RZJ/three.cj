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
 * @file[zh-cn] scene_scenegraph_fogexp2 FogExp2 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.scene.scenegraph.FogExp2 绑定为 Lua 类型 three.scene.scenegraph.FogExp2
 * @explain[zh-cn] 构造按首个参数分派：无参 → FogExp2()；对象 → FogExp2(color: Color, density)；
 * 数值 → FogExp2(hex: UInt32, density)。绑定 color/density/name 属性与 clone（返回新 FogExp2，
 * 经 prebindRegister 注册）。无跳过成员。
 *
 * @file[en] scene_scenegraph_fogexp2  Lua binding of FogExp2 (three.script.prebind)
 * @brief[en] Binds three.scene.scenegraph.FogExp2 as the Lua type three.scene.scenegraph.FogExp2
 * @explain[en] The constructor dispatches on the first argument: no arguments -> FogExp2();
 * an object -> FogExp2(color: Color, density); a number -> FogExp2(hex: UInt32, density). Binds
 * the color/density/name properties and clone (returns a new FogExp2 registered via
 * prebindRegister). No members are skipped.
 */
package three.script.prebind

import three.core.math.*
import three.scene.scenegraph.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FogExp2 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.scene.scenegraph.FogExp2）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FogExp2
 * @param[en] vm The target virtual machine (class table installed at three.scene.scenegraph.FogExp2)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFogExp2(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.scene.scenegraph.FogExp2")
    // ===== 构造（无参 / Color / hex） =====
    b.constructor {
        args => if (args.size >= 1 && args[0].isObject) {
            FogExp2(prebindAs<Color>(args, 0), density: prebindNum(args, 1, default: 0.00025))
        } else if (args.size >= 1) {
            FogExp2(UInt32(prebindInt(args, 0) & 0xFFFFFFFF), density: prebindNum(args, 1, default: 0.00025))
        } else {
            FogExp2()
        }
    }
    // ===== 属性 =====
    b.property("color", getter: Some({ref => prebindRegister(ref.cast<FogExp2>().color, "three.core.math.Color")}),
        setter: Some({ref, v => ref.cast<FogExp2>().color = prebindAsValue<Color>(v)}))
    b.property("density", getter: Some({ref => LuaValue.of(ref.cast<FogExp2>().density)}),
        setter: Some({ref, v => ref.cast<FogExp2>().density = v.numberValue()}))
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<FogExp2>().name)}),
        setter: Some({ref, v => ref.cast<FogExp2>().name = v.stringValue()}))
    // ===== 克隆 =====
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<FogExp2>().clone(), "three.scene.scenegraph.FogExp2")]
    }
    b.install(vm)
}
