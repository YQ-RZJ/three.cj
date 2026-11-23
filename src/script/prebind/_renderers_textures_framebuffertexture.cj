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
 * @file[zh-cn] renderers_textures_framebuffertexture FramebufferTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.FramebufferTexture 绑定为 Lua 类型
 * three.renderers.textures.FramebufferTexture
 * @explain[zh-cn] 构造参数按位置映射：width / height 必填，format 可选（默认 1023 RGBAFormat）。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员。
 *
 * @file[en] renderers_textures_framebuffertexture  Lua binding of FramebufferTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.FramebufferTexture as the Lua type
 * three.renderers.textures.FramebufferTexture
 * @explain[en] Constructor arguments are mapped positionally: width / height are required and
 * format is optional (default 1023, RGBAFormat). _prebindRtxTextureMembers registers all Texture
 * members.
 */
package three.script.prebind

import three.renderers.textures.FramebufferTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FramebufferTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.FramebufferTexture）
 *
 * @brief[en] Installs the Lua binding of FramebufferTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.FramebufferTexture)
 */
public func installFramebufferTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.FramebufferTexture")
    // ===== 构造 =====
    b.constructor {
        args => FramebufferTexture(prebindInt(args, 0), prebindInt(args, 1), format: prebindInt(args, 2, default: 1023))
    }
    _prebindRtxTextureMembers(b, vm)
    b.install(vm)
}
