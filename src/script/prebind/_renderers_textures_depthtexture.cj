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
 * @file[zh-cn] renderers_textures_depthtexture DepthTexture 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.textures.DepthTexture 绑定为 Lua 类型
 * three.renderers.textures.DepthTexture
 * @explain[zh-cn] 构造参数按位置映射：width / height 必填，type 可选（默认 1014
 * UnsignedIntType）。复用 _prebindRtxTextureMembers 登记 Texture 全部成员，并补充
 * compareFunction（Option<Int64>，Lua nil 表示无比较）。构造时的 type 校验仅记录告警，
 * 不抛异常。
 *
 * @file[en] renderers_textures_depthtexture  Lua binding of DepthTexture (three.script.prebind)
 * @brief[en] Binds three.renderers.textures.DepthTexture as the Lua type
 * three.renderers.textures.DepthTexture
 * @explain[en] Constructor arguments are mapped positionally: width / height are required and type
 * is optional (default 1014, UnsignedIntType). _prebindRtxTextureMembers registers all Texture
 * members; compareFunction (Option<Int64>, Lua nil means no comparison) is added on top. The
 * constructor's type check only logs a warning and never throws.
 */
package three.script.prebind

import three.renderers.textures.DepthTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 DepthTexture 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.textures.DepthTexture）
 *
 * @brief[en] Installs the Lua binding of DepthTexture
 * @param[en] vm The target virtual machine (class table installed at
 * three.renderers.textures.DepthTexture)
 */
public func installDepthTexture(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.textures.DepthTexture")
    // ===== 构造 =====
    b.constructor {
        args => DepthTexture(prebindInt(args, 0), prebindInt(args, 1), `type`: prebindInt(args, 2, default: 1014))
    }
    _prebindRtxTextureMembers(b, vm)
    // ===== 深度比较函数 =====
    b.property("compareFunction", getter: Some({
        ref => match (ref.cast<DepthTexture>().compareFunction) {
            case Some(v) => LuaValue.of(v)
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => ref.cast<DepthTexture>().compareFunction = if (v.isNil) {
            None
        } else {
            Some(v.intValue())
        }
    }))
    b.install(vm)
}
