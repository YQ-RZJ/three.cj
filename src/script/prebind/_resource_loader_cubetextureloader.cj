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
 * @file[zh-cn] resource_loader_cubetextureloader 立方体贴图加载器 CubeTextureLoader 的
 * Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.CubeTextureLoader 绑定为 Lua 类型
 * three.resource.loader.CubeTextureLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员与 load：入参为 6 面文件路径
 * 数组（pos-x, neg-x, pos-y, neg-y, pos-z, neg-z），onLoad 收到 CubeTexture（按
 * three.renderers.textures.CubeTexture 注册），方法同时返回该 CubeTexture；读取 /
 * 回调异常被吞掉并返回 nil。跳过：requestHeader / setRequestHeader
 * （HashMap<String, Any> 无 Lua 通道）。
 *
 * @file[en] resource_loader_cubetextureloader  Lua binding of the cube texture loader
 * CubeTextureLoader (three.script.prebind)
 * @brief[en] Binds three.resource.loader.CubeTextureLoader as the Lua type
 * three.resource.loader.CubeTextureLoader
 * @explain[en] Binds construction (optional manager), the Loader common members and load:
 * the argument is an array of 6 face paths (pos-x, neg-x, pos-y, neg-y, pos-z, neg-z),
 * onLoad receives a CubeTexture (registered under three.renderers.textures.CubeTexture)
 * and the method also returns it; read/callback errors are swallowed and nil is returned.
 * Skipped: requestHeader / setRequestHeader (HashMap<String, Any> has no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.renderers.textures.CubeTexture
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 CubeTextureLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.CubeTextureLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of CubeTextureLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.CubeTextureLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCubeTextureLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.CubeTextureLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            CubeTextureLoader(m)
        } else {
            CubeTextureLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载 6 面立方体贴图（异常静默，失败返回 nil） =====
    b.method("load") {
        ref, args =>
            let elems = prebindArray(vm, args, 0)
            let urls = Array<String>(elems.size, {i => elems[i].stringValue()})
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            var out = LuaValue.Nil
            try {
                let texture = ref
                    .cast<CubeTextureLoader>()
                    .load(urls, {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
                out = prebindRegister(texture, "three.renderers.textures.CubeTexture")
            } catch (_: Exception) {
            }
            [out]
    }
    b.install(vm)
}
