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
 * @file[zh-cn] renderers_textures_compressedcubetexture CompressedCubeTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.CompressedCubeTexture 绑定为 Lua 类型
 * three.renderers.textures.CompressedCubeTexture
 * @explain[zh-cn] 构造参数按位置映射：images（6 面压缩像素二维表，按 ±X/±Y/±Z 顺序）/
 * width / height 为位置必填，format 可选（默认 1023）。复用 _prebindRtxTextureMembers 登记
 * Texture 全部成员；本类未保留 images 字段，故不提供 images 属性。
 *
 * @file[en] renderers_textures_compressedcubetexture  Lua binding of CompressedCubeTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.CompressedCubeTexture as the Lua type
 * three.renderers.textures.CompressedCubeTexture
 * @explain[en] Constructor arguments are mapped positionally: images (a 2-D table of the six
 * compressed faces in ±X/±Y/±Z order) / width / height are positional and required, format is
 * optional (default 1023). _prebindRtxTextureMembers registers all Texture members; this class
 * keeps no images field, so no images property is exposed.
 */
package three.script.prebind

import three.renderers.textures.CompressedCubeTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CompressedCubeTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.CompressedCubeTexture）
 *
 * @brief[en] Installs the Lua binding of CompressedCubeTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.CompressedCubeTexture)
 */
public func installCompressedCubeTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.CompressedCubeTexture")
    // ===== 构造 =====
    b.constructor {
        args => CompressedCubeTexture(_prebindRtxFaces(vm, args, 0), prebindInt(args, 1), prebindInt(args, 2),
            format: prebindInt(args, 3, default: 1023))
    }
    _prebindRtxTextureMembers(b, vm)
    b.install(vm)
}
