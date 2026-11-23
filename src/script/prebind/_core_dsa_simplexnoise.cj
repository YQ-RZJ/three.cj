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
 * @file[zh-cn] core_dsa_simplexnoise Simplex 噪声的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.core.dsa.SimplexNoise 绑定为 Lua 类型 three.core.dsa.SimplexNoise
 * @explain[zh-cn] 覆盖构造（new，可选整数种子，缺省 987654321）与全部公共方法
 * （noise2D/noise/noise3d/noise4d/createSeamlessNoise2D），输入输出均为浮点数。
 *
 * @file[en] core_dsa_simplexnoise  Lua binding of the Simplex noise (three.script.prebind)
 * @brief[en] Binds three.core.dsa.SimplexNoise as the Lua type three.core.dsa.SimplexNoise
 * @explain[en] Covers construction (new with optional integer seed, default 987654321) and all
 * public methods (noise2D/noise/noise3d/noise4d/createSeamlessNoise2D) taking/returning floats.
 */
package three.script.prebind

import three.core.dsa.SimplexNoise
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 SimplexNoise 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.core.dsa.SimplexNoise）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of SimplexNoise
 * @param[en] vm The target virtual machine (class table installed at three.core.dsa.SimplexNoise)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSimplexNoise(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.core.dsa.SimplexNoise")
    // ===== 构造 =====
    b.constructor { args =>
        SimplexNoise(seed: UInt64(prebindInt(args, 0, default: 987654321)))
    }
    // ===== 2D =====
    b.method("noise2D") { ref, args =>
        [LuaValue.of(ref.cast<SimplexNoise>().noise2D(args[0].numberValue(), args[1].numberValue()))]
    }
    b.method("noise") { ref, args =>
        [LuaValue.of(ref.cast<SimplexNoise>().noise(args[0].numberValue(), args[1].numberValue()))]
    }
    // ===== 3D / 4D =====
    b.method("noise3d") { ref, args =>
        [LuaValue.of(ref.cast<SimplexNoise>().noise3d(args[0].numberValue(), args[1].numberValue(),
                                                      args[2].numberValue()))]
    }
    b.method("noise4d") { ref, args =>
        [LuaValue.of(ref.cast<SimplexNoise>().noise4d(args[0].numberValue(), args[1].numberValue(),
                                                      args[2].numberValue(), args[3].numberValue()))]
    }
    // ===== 无缝 2D =====
    b.method("createSeamlessNoise2D") { ref, args =>
        [LuaValue.of(ref.cast<SimplexNoise>().createSeamlessNoise2D(args[0].numberValue(),
                                                                    args[1].numberValue(),
                                                                    args[2].numberValue()))]
    }
    b.install(vm)
}