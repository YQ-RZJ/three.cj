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
 * @file[zh-cn] renderers_textures_pmremgenerator PMREMGenerator 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.PMREMGenerator 绑定为 Lua 类型
 * three.renderers.textures.PMREMGenerator
 * @explain[zh-cn] 覆盖无参构造、kind 属性、CubeUV 布局常量（LEVEL_FACE_SIZES / NUM_LEVELS /
 * TEX_WIDTH / TEX_HEIGHT，以静态方法暴露）、环境贴图生成入口 fromScene（IScene，经 prebindAs
 * 取已绑定的 Scene 对象） / fromCubemap（CubeTexture） / fromEquirectangular（Texture） /
 * fromColor（Color），返回值统一 prebindRegister 为 three.renderers.textures.Texture；
 * 并实现 IReleasable 的 releasable 只读属性与 release()。
 * 生成过程中若参数类型不符或内部异常，一律在 lambda 内捕获并返回 nil，异常不逃逸到 Lua。
 *
 * @file[en] renderers_textures_pmremgenerator  Lua binding of PMREMGenerator
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.PMREMGenerator as the Lua type
 * three.renderers.textures.PMREMGenerator
 * @explain[en] Covers the no-argument constructor, the kind property, the CubeUV layout constants
 * (LEVEL_FACE_SIZES / NUM_LEVELS / TEX_WIDTH / TEX_HEIGHT exposed as static methods), the
 * environment-map entry points fromScene (IScene, fetched via prebindAs from a bound Scene object) /
 * fromCubemap (CubeTexture) / fromEquirectangular (Texture) / fromColor (Color) whose results are
 * registered as three.renderers.textures.Texture via prebindRegister, plus the IReleasable
 * releasable read-only property and release(). Any argument-type mismatch or internal failure is
 * caught inside the lambda and yields nil, so exceptions never escape to Lua.
 */
package three.script.prebind

import three.renderers.textures.*
import three.scene._interfaces.IScene
import three.core.math.Color
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 PMREMGenerator 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.PMREMGenerator）
 *
 * @brief[en] Installs the Lua binding of PMREMGenerator
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.PMREMGenerator)
 */
public func installPMREMGenerator(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.PMREMGenerator")
    // ===== 构造 =====
    b.constructor {_ => PMREMGenerator()}
    // ===== 属性 =====
    b.property("kind", getter: Some({ref => LuaValue.of(ref.cast<PMREMGenerator>().kind)}),
        setter: Some({ref, v => ref.cast<PMREMGenerator>().kind = v.stringValue()}))
    // ===== IReleasable =====
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<PMREMGenerator>().releasable)}))
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<PMREMGenerator>().release())]
    }
    // ===== CubeUV 图集布局常量 =====
    b.staticMethod("LEVEL_FACE_SIZES") {
        _ => [LuaValue.of(PMREMGenerator.LEVEL_FACE_SIZES)]
    }
    b.staticMethod("NUM_LEVELS") {_ => [LuaValue.of(PMREMGenerator.NUM_LEVELS)]}
    b.staticMethod("TEX_WIDTH") {_ => [LuaValue.of(PMREMGenerator.TEX_WIDTH)]}
    b.staticMethod("TEX_HEIGHT") {_ => [LuaValue.of(PMREMGenerator.TEX_HEIGHT)]}
    // ===== 环境贴图生成 =====
    b.method("fromScene") {
        ref, args => try {
            [prebindRegister(
                ref
                    .cast<PMREMGenerator>()
                    .fromScene(prebindAs<IScene>(args, 0), prebindNum(args, 1, default: 0.0),
                        prebindNum(args, 2, default: 0.0), prebindNum(args, 3, default: 0.0)),
                "three.renderers.textures.Texture")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.method("fromCubemap") {
        ref, args => try {
            [prebindRegister(
                ref.cast<PMREMGenerator>().fromCubemap(prebindAs<CubeTexture>(args, 0), prebindNum(args, 1, default: 0.0)),
                "three.renderers.textures.Texture")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.method("fromEquirectangular") {
        ref, args => try {
            [prebindRegister(
                ref
                    .cast<PMREMGenerator>()
                    .fromEquirectangular(prebindAs<Texture>(args, 0), prebindNum(args, 1, default: 0.0)),
                "three.renderers.textures.Texture")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.method("fromColor") {
        ref, args => try {
            [prebindRegister(ref.cast<PMREMGenerator>().fromColor(prebindAs<Color>(args, 0)),
                "three.renderers.textures.Texture")]
        } catch (_: Exception) {
            [LuaValue.Nil]
        }
    }
    b.install(vm)
}
