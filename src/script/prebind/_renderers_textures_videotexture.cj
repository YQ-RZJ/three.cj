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
 * @file[zh-cn] renderers_textures_videotexture VideoTexture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.VideoTexture 绑定为 Lua 类型
 * three.renderers.textures.VideoTexture
 * @explain[zh-cn] 构造参数按位置映射：video（像素数组）为可选首参，其后 mapping / wrapS /
 * wrapT / magFilter / minFilter / format / type / anisotropy 缺省为 300 / 1001 / 1001 /
 * 1006 / 1006 / 1023 / 1009 / 1。复用 _prebindRtxTextureMembers 登记 Texture 全部成员
 * （其中 update() 经虚分派命中本类的 override，bgfx4cj 下为 stub，像素数据由调用方经 image 写入）。
 *
 * @file[en] renderers_textures_videotexture  Lua binding of VideoTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.VideoTexture as the Lua type
 * three.renderers.textures.VideoTexture
 * @explain[en] Constructor arguments are mapped positionally: video (pixel array) is the optional
 * first argument; mapping / wrapS / wrapT / magFilter / minFilter / format / type / anisotropy
 * default to 300 / 1001 / 1001 / 1006 / 1006 / 1023 / 1009 / 1. _prebindRtxTextureMembers
 * registers all Texture members (update() is dispatched virtually to this class's override, a stub
 * under bgfx4cj; pixel data is written through image by the caller).
 */
package three.script.prebind

import three.renderers.textures.VideoTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 VideoTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.VideoTexture）
 *
 * @brief[en] Installs the Lua binding of VideoTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.VideoTexture)
 */
public func installVideoTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.VideoTexture")
    // ===== 构造 =====
    b.constructor {
        args => VideoTexture(prebindBytes(vm, args, 0), mapping: prebindInt(args, 1, default: 300),
            wrapS: prebindInt(args, 2, default: 1001), wrapT: prebindInt(args, 3, default: 1001),
            magFilter: prebindInt(args, 4, default: 1006), minFilter: prebindInt(args, 5, default: 1006),
            format: prebindInt(args, 6, default: 1023), `type`: prebindInt(args, 7, default: 1009),
            anisotropy: prebindInt(args, 8, default: 1))
    }
    _prebindRtxTextureMembers(b, vm)
    b.install(vm)
}
