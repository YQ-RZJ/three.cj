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
 * @file[zh-cn] renderers_textures_dataarraytexture DataArrayTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.DataArrayTexture 绑定为 Lua 类型
 * three.renderers.textures.DataArrayTexture
 * @explain[zh-cn] 构造参数按位置映射：data（像素数组）/ width / height / depth 全部必填。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充 wrapR（沿 R 维 / 层维的
 * 环绕模式）；copy(Texture) 由基类成员统一绑定，虚分派会命中本类的 override。
 *
 * @file[en] renderers_textures_dataarraytexture  Lua binding of DataArrayTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.DataArrayTexture as the Lua type
 * three.renderers.textures.DataArrayTexture
 * @explain[en] Constructor arguments are mapped positionally: data (pixel array) / width / height /
 * depth, all required. _prebindRtxTextureMembers registers all Texture members; wrapR (the wrap
 * mode along the R/layer dimension) is added on top; copy(Texture) is bound by the shared base
 * members and virtual dispatch reaches this class's override.
 */
package three.script.prebind

import three.renderers.textures.DataArrayTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 DataArrayTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.DataArrayTexture）
 *
 * @brief[en] Installs the Lua binding of DataArrayTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.DataArrayTexture)
 */
public func installDataArrayTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.DataArrayTexture")
    // ===== 构造 =====
    b.constructor {
        args => DataArrayTexture(prebindBytes(vm, args, 0), prebindInt(args, 1), prebindInt(args, 2), prebindInt(args, 3))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 层维环绕 =====
    b.property("wrapR", getter: Some({ref => LuaValue.of(ref.cast<DataArrayTexture>().wrapR)}),
        setter: Some({ref, v => ref.cast<DataArrayTexture>().wrapR = v.intValue()}))
    b.install(vm)
}
