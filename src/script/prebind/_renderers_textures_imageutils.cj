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
 * @file[zh-cn] renderers_textures_imageutils ImageUtils 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.ImageUtils 绑定为 Lua 命名空间
 * three.renderers.textures.ImageUtils
 * @explain[zh-cn] ImageUtils 是纯静态工具类（无构造器，不安装 new）。绑定 getDataURL
 * （image 为 Array<UInt8>；type 可选，缺省 "image/png"）与 sRGBToLinear（返回新的字节数组，
 * 经 prebindBytesToLua 转 Lua 数值表）。
 *
 * @file[en] renderers_textures_imageutils  Lua binding of ImageUtils (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.ImageUtils as the Lua namespace
 * three.renderers.textures.ImageUtils
 * @explain[en] ImageUtils is a pure static utility (no constructor, no `new`). getDataURL is bound
 * (image is Array<UInt8>; type is optional, defaulting to "image/png") along with sRGBToLinear
 * (returns a fresh byte array converted to a Lua number table by prebindBytesToLua).
 */
package three.script.prebind

import three.renderers.textures.ImageUtils
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ImageUtils 的 Lua 绑定（纯静态类，无构造器，不安装 new）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.renderers.textures.ImageUtils）
 *
 * @brief[en] Installs the Lua binding of ImageUtils (a pure static class; no constructor, no `new`)
 * @param[en] vm The target virtual machine (namespace table installed at
 * three.renderers.textures.ImageUtils)
 */
public func installImageUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.ImageUtils")
    // ===== data URI（type 缺省 image/png） =====
    b.staticMethod("getDataURL") {
        args => [LuaValue.of(ImageUtils.getDataURL(prebindBytes(vm, args, 0), prebindStr(args, 1, default: "image/png")))]
    }
    // ===== sRGB → Linear =====
    b.staticMethod("sRGBToLinear") {
        args => [prebindBytesToLua(ImageUtils.sRGBToLinear(prebindBytes(vm, args, 0)))]
    }
    b.install(vm)
}
