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
 * @file[zh-cn] renderers_textures_cubetexture CubeTexture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.CubeTexture 绑定为 Lua 类型
 * three.renderers.textures.CubeTexture
 * @explain[zh-cn] 构造参数按位置映射：images（6 面二维像素表，按 ±X/±Y/±Z 顺序）为可选
 * 首参，其后 mapping / wrapS / wrapT / magFilter / minFilter / format / type / anisotropy /
 * colorSpace 缺省为 301 / 1001 / 1001 / 1006 / 1008 / 1023 / 1009 / 1 / 空串。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充 images 读写
 * （Lua 二维表 ↔ Array<Array<UInt8>>）。
 *
 * @file[en] renderers_textures_cubetexture  Lua binding of CubeTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.CubeTexture as the Lua type
 * three.renderers.textures.CubeTexture
 * @explain[en] Constructor arguments are mapped positionally: images (a 2-D table of the six faces
 * in ±X/±Y/±Z order) is the optional first argument; mapping / wrapS / wrapT / magFilter /
 * minFilter / format / type / anisotropy / colorSpace default to 301 / 1001 / 1001 / 1006 / 1008 /
 * 1023 / 1009 / 1 / "". _prebindRtxTextureMembers registers all Texture members; images is added
 * as a read-write property (Lua 2-D table <-> Array<Array<UInt8>>).
 */
package three.script.prebind

import three.renderers.textures.CubeTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 从单个 Lua 值读取 6 面图像（二维表 → Array<Array<UInt8>>）
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] v 待转换的 Lua 值（二维表或 nil）
 * @return[zh-cn] 六面字节数组（nil/非表返回空数组）
 *
 * @brief[en] Reads the six faces from a single Lua value (2-D table -> Array<Array<UInt8>>)
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] v The Lua value to convert (a 2-D table or nil)
 * @return[en] The six face byte arrays (empty for nil or non-table values)
 */
internal func _prebindRtxFacesFromValue(vm: LuaVM, v: LuaValue): Array<Array<UInt8>> {
    if (v.isNil) {
        return Array<Array<UInt8>>()
    }
    return _prebindRtxFaces(vm, [v], 0)
}

/**
 * @brief[zh-cn] 安装 CubeTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.CubeTexture）
 *
 * @brief[en] Installs the Lua binding of CubeTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.CubeTexture)
 */
public func installCubeTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.CubeTexture")
    // ===== 构造 =====
    b.constructor {
        args => CubeTexture(images: _prebindRtxFaces(vm, args, 0), mapping: prebindInt(args, 1, default: 301),
            wrapS: prebindInt(args, 2, default: 1001), wrapT: prebindInt(args, 3, default: 1001),
            magFilter: prebindInt(args, 4, default: 1006), minFilter: prebindInt(args, 5, default: 1008),
            format: prebindInt(args, 6, default: 1023), `type`: prebindInt(args, 7, default: 1009),
            anisotropy: prebindInt(args, 8, default: 1), colorSpace: prebindStr(args, 9))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 六面像素数据 =====
    b.property("images", getter: Some({ref => _prebindRtxFacesToLua(ref.cast<CubeTexture>().images)}),
        setter: Some({ref, v => ref.cast<CubeTexture>().images = _prebindRtxFacesFromValue(vm, v)}))
    b.install(vm)
}
