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
 * @file[zh-cn] renderers_textures_externaltexture ExternalTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.ExternalTexture 绑定为 Lua 类型
 * three.renderers.textures.ExternalTexture
 * @explain[zh-cn] 构造无参数（Lua 侧 ExternalTexture.new()）。复用 _prebindRtxTextureMembers
 * 登记 Texture 全部成员，copy / clone 由基类成员虚分派到本类 override。
 * 跳过：sourceTexture（Option<TextureHandle>，GPU 句柄无 Lua 通道，构造时的同名可选参数
 * 亦跳过，始终按 None 构造）。
 *
 * @file[en] renderers_textures_externaltexture  Lua binding of ExternalTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.ExternalTexture as the Lua type
 * three.renderers.textures.ExternalTexture
 * @explain[en] The constructor takes no arguments (Lua: ExternalTexture.new()).
 * _prebindRtxTextureMembers registers all Texture members; copy / clone are dispatched virtually to
 * this class's overrides. Skipped: sourceTexture (Option<TextureHandle>; GPU handles have no Lua
 * channel) along with the same-named optional constructor argument, so instances always start with
 * None.
 */
package three.script.prebind

import three.renderers.textures.ExternalTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 ExternalTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.ExternalTexture）
 *
 * @brief[en] Installs the Lua binding of ExternalTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.ExternalTexture)
 */
public func installExternalTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.ExternalTexture")
    // ===== 构造（无参数；sourceTexture 为 GPU 句柄，跳过） =====
    b.constructor {_ => ExternalTexture()}
    _prebindRtxTextureMembers(b, vm)
    b.install(vm)
}
