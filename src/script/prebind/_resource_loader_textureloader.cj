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
 * @file[zh-cn] resource_loader_textureloader 纹理加载器 TextureLoader 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.TextureLoader 绑定为 Lua 类型
 * three.resource.loader.TextureLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员与 load：onLoad 收到
 * three.renderers.textures.Texture（内部 ImageLoader 解码后填充像素与尺寸），
 * 读取/解码/回调异常均被吞掉。跳过：requestHeader / setRequestHeader
 * （HashMap<String, Any> 无 Lua 通道）。
 *
 * @file[en] resource_loader_textureloader  Lua binding of the texture loader TextureLoader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.TextureLoader as the Lua type
 * three.resource.loader.TextureLoader
 * @explain[en] Binds construction (optional manager), the Loader common members and load:
 * onLoad receives three.renderers.textures.Texture (filled with decoded pixels/dimensions
 * by the internal ImageLoader); read/decode/callback errors are swallowed. Skipped:
 * requestHeader / setRequestHeader (HashMap<String, Any> has no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 TextureLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.TextureLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TextureLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.TextureLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTextureLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.TextureLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            TextureLoader(m)
        } else {
            TextureLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载图片并创建 Texture（异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<TextureLoader>()
                    .load(prebindStr(args, 0), {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    b.install(vm)
}
