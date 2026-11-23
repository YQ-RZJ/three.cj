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
 * @file[zh-cn] renderers_textures_compressedarraytexture CompressedArrayTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.CompressedArrayTexture 绑定为 Lua 类型
 * three.renderers.textures.CompressedArrayTexture
 * @explain[zh-cn] 构造参数按位置映射：data（压缩像素数组）/ width / height / depth 为位置必填，
 * format 可选（默认 1023）。复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充
 * wrapR（沿 R 维 / 层维的环绕模式）；copy(Texture) 经基类成员虚分派到本类 override。
 *
 * @file[en] renderers_textures_compressedarraytexture  Lua binding of CompressedArrayTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.CompressedArrayTexture as the Lua type
 * three.renderers.textures.CompressedArrayTexture
 * @explain[en] Constructor arguments are mapped positionally: data (compressed pixel array) /
 * width / height / depth are positional and required, format is optional (default 1023).
 * _prebindRtxTextureMembers registers all Texture members; wrapR (the wrap mode along the R/layer
 * dimension) is added on top; copy(Texture) is dispatched virtually to this class's override.
 */
package three.script.prebind

import three.renderers.textures.CompressedArrayTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CompressedArrayTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.CompressedArrayTexture）
 *
 * @brief[en] Installs the Lua binding of CompressedArrayTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.CompressedArrayTexture)
 */
public func installCompressedArrayTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.CompressedArrayTexture")
    // ===== 构造 =====
    b.constructor {
        args => CompressedArrayTexture(prebindBytes(vm, args, 0), prebindInt(args, 1), prebindInt(args, 2),
            prebindInt(args, 3), format: prebindInt(args, 4, default: 1023))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 层维环绕 =====
    b.property("wrapR", getter: Some({ref => LuaValue.of(ref.cast<CompressedArrayTexture>().wrapR)}),
        setter: Some({ref, v => ref.cast<CompressedArrayTexture>().wrapR = v.intValue()}))
    b.install(vm)
}
