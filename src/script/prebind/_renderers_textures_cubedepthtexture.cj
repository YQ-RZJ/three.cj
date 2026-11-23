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
 * @file[zh-cn] renderers_textures_cubedepthtexture CubeDepthTexture 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.CubeDepthTexture 绑定为 Lua 类型
 * three.renderers.textures.CubeDepthTexture
 * @explain[zh-cn] 构造参数按位置映射：width / height（单面尺寸，像素）必填。
 * 复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充继承自 DepthTexture 的
 * compareFunction（Option<Int64>）。
 *
 * @file[en] renderers_textures_cubedepthtexture  Lua binding of CubeDepthTexture
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.CubeDepthTexture as the Lua type
 * three.renderers.textures.CubeDepthTexture
 * @explain[en] Constructor arguments are mapped positionally: width / height (per-face size in
 * pixels), both required. _prebindRtxTextureMembers registers all Texture members; compareFunction
 * (Option<Int64>) inherited from DepthTexture is added on top.
 */
package three.script.prebind

import three.renderers.textures.CubeDepthTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CubeDepthTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.CubeDepthTexture）
 *
 * @brief[en] Installs the Lua binding of CubeDepthTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.CubeDepthTexture)
 */
public func installCubeDepthTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.CubeDepthTexture")
    // ===== 构造 =====
    b.constructor {
        args => CubeDepthTexture(prebindInt(args, 0), prebindInt(args, 1))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 深度比较函数（继承自 DepthTexture） =====
    b.property("compareFunction", getter: Some({
        ref => match (ref.cast<CubeDepthTexture>().compareFunction) {
            case Some(v) => LuaValue.of(v)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<CubeDepthTexture>().compareFunction = if (v.isNil) {
            None
        } else {
            Some(v.intValue())
        }
    }))
    b.install(vm)
}
