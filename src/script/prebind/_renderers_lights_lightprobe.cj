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
 * @file[zh-cn] renderers_lights_lightprobe 光照探针 LightProbe 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.lights.LightProbe 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（sh / intensity）与属性 sh（SphericalHarmonics3 对象往返）。
 * 构造支持 new()、new(sh)、new(intensity) 与 new(sh, intensity) 四种形态：首参为对象时视为
 * 球面调和系数，否则视为强度。Lua 类表没有继承，本类绑定在 b.install 之前依次复用 Object3D
 * 与 Light 的成员。跳过成员：copy 仅重写 Object3D.copy，由基类绑定经虚函数分派覆盖。
 *
 * @file[en] renderers_lights_lightprobe  Lua binding of LightProbe (three.script.prebind)
 * @brief[en] Binds three.renderers.lights.LightProbe as a Lua type
 * @explain[en] Binds the constructor (sh / intensity) and the sh property (SphericalHarmonics3
 * round-trip). The constructor accepts new(), new(sh), new(intensity) and new(sh, intensity): an
 * object first argument is the spherical-harmonics coefficient, otherwise it is the intensity.
 * Lua class tables have no inheritance, so this binding reuses the Object3D and Light members
 * before b.install. Skipped: copy, which only overrides Object3D.copy and is covered by the base
 * binding via virtual dispatch.
 */
package three.script.prebind

import three.renderers.lights.*
import three.core.math.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 LightProbe 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.lights.LightProbe）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LightProbe
 * @param[en] vm The target virtual machine (class table at three.renderers.lights.LightProbe)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLightProbe(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.lights.LightProbe")
    // ===== 构造：可选 sh / intensity =====
    b.constructor {
        args =>
            let hasSh = args.size > 0 && !args[0].isNil && args[0].isObject
            let sh = if (hasSh) {
                prebindAsValue<SphericalHarmonics3>(args[0])
            } else {
                SphericalHarmonics3()
            }
            let intensity = if (args.size > 0 && !hasSh) {
                prebindNum(args, 0, default: 1.0)
            } else {
                prebindNum(args, 1, default: 1.0)
            }
            LightProbe(sh: sh, intensity: intensity)
    }
    // ===== 继承成员：Object3D → Light =====
    prebindInstallObject3DMembers(b, vm)
    _prebindLgtLightMembers(b, vm)
    // ===== 光照探针自有成员 =====
    b.property("sh", getter: Some({
        ref => prebindRegister(ref.cast<LightProbe>().sh, "three.core.math.SphericalHarmonics3")
    }), setter: Some({
        ref, v => ref.cast<LightProbe>().sh = prebindAsValue<SphericalHarmonics3>(v)
    }))
    b.install(vm)
}
