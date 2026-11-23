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
 * @file[zh-cn] renderers_textures_canvastexture CanvasTexture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.CanvasTexture 绑定为 Lua 类型
 * three.renderers.textures.CanvasTexture
 * @explain[zh-cn] 构造参数按位置映射：canvas（像素数组）/ width / height 为位置必填，
 * mapping / wrapS / wrapT / magFilter / minFilter / format / type / anisotropy 为可选，
 * 缺省值分别为 300 / 1001 / 1001 / 1006 / 1008 / 1023 / 1009 / 1。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充 update()。
 *
 * @file[en] renderers_textures_canvastexture  Lua binding of CanvasTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.CanvasTexture as the Lua type
 * three.renderers.textures.CanvasTexture
 * @explain[en] Constructor arguments are mapped positionally: canvas (pixel array) / width /
 * height are positional and required; mapping / wrapS / wrapT / magFilter / minFilter / format /
 * type / anisotropy are optional with defaults 300 / 1001 / 1001 / 1006 / 1008 / 1023 / 1009 / 1.
 * _prebindRtxTextureMembers registers all Texture members; update() is added on top.
 */
package three.script.prebind

import three.renderers.textures.CanvasTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CanvasTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.CanvasTexture）
 *
 * @brief[en] Installs the Lua binding of CanvasTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.CanvasTexture)
 */
public func installCanvasTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.CanvasTexture")
    // ===== 构造 =====
    b.constructor {
        args => CanvasTexture(prebindBytes(vm, args, 0), prebindInt(args, 1), prebindInt(args, 2),
            mapping: prebindInt(args, 3, default: 300), wrapS: prebindInt(args, 4, default: 1001),
            wrapT: prebindInt(args, 5, default: 1001), magFilter: prebindInt(args, 6, default: 1006),
            minFilter: prebindInt(args, 7, default: 1008), format: prebindInt(args, 8, default: 1023),
            `type`: prebindInt(args, 9, default: 1009), anisotropy: prebindInt(args, 10, default: 1))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 内容更新 =====
    b.method("update") {
        ref, _ =>
            ref.cast<CanvasTexture>().update()
            Array<LuaValue>()
    }
    b.install(vm)
}
