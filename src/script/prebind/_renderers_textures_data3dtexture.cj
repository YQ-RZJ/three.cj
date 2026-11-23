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
 * @file[zh-cn] renderers_textures_data3dtexture Data3DTexture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.Data3DTexture 绑定为 Lua 类型
 * three.renderers.textures.Data3DTexture
 * @explain[zh-cn] 构造参数按位置映射：data（像素数组）/ width / height / depth 全部必填。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充 Data3DTexture 独有的
 * wrapR（沿 R 维 / 层维的环绕模式）。
 *
 * @file[en] renderers_textures_data3dtexture  Lua binding of Data3DTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.Data3DTexture as the Lua type
 * three.renderers.textures.Data3DTexture
 * @explain[en] Constructor arguments are mapped positionally: data (pixel array) / width / height /
 * depth, all required. _prebindRtxTextureMembers registers all Texture members; wrapR (the wrap
 * mode along the R/layer dimension), unique to Data3DTexture, is added on top.
 */
package three.script.prebind

import three.renderers.textures.Data3DTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 Data3DTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.Data3DTexture）
 *
 * @brief[en] Installs the Lua binding of Data3DTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.Data3DTexture)
 */
public func installData3DTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.Data3DTexture")
    // ===== 构造 =====
    b.constructor {
        args => Data3DTexture(prebindBytes(vm, args, 0), prebindInt(args, 1), prebindInt(args, 2), prebindInt(args, 3))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 层维环绕 =====
    b.property("wrapR", getter: Some({ref => LuaValue.of(ref.cast<Data3DTexture>().wrapR)}),
        setter: Some({ref, v => ref.cast<Data3DTexture>().wrapR = v.intValue()}))
    b.install(vm)
}
