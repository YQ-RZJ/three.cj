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
 * @file[zh-cn] resource_loader_gltfloader GltfLoader 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.GltfLoader 绑定为 Lua 类型 three.resource.loader.GltfLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员与 load：同步读取 .gltf/.glb，
 * onLoad 收到 Group（注册为 three.scene.scenegraph.Group）；读取 / 解析 / 回调异常均被吞掉，
 * 绝不让异常穿出绑定方法。跳过：parse / parseGlb / parseJsonToHashMap——前两者的参数或
 * 返回值含 HashMap<String, Any> 或 (HashMap<String, Any>, Array<UInt8>) 元组，无法从 Lua 表
 * 稳定映射；后者返回 HashMap<String, Any>，无 Lua 通道。
 *
 * @file[en] resource_loader_gltfloader  Lua binding of GltfLoader (three.script.prebind)
 * @brief[en] Binds three.resource.loader.GltfLoader as the Lua type three.resource.loader.GltfLoader
 * @explain[en] Binds construction (optional manager), the Loader common members and load: reads
 * .gltf/.glb synchronously and onLoad receives a Group registered as
 * three.scene.scenegraph.Group; read/parse/callback errors are swallowed and never escape the
 * binding method. Skipped: parse / parseGlb / parseJsonToHashMap — the first two take or return
 * HashMap<String, Any> or a (HashMap<String, Any>, Array<UInt8>) tuple that cannot be mapped
 * reliably from Lua tables, and the last returns HashMap<String, Any> (no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 GltfLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.GltfLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GltfLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.GltfLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGltfLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.GltfLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            GltfLoader(m)
        } else {
            GltfLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载 glTF / GLB（读取 / 回调异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<GltfLoader>()
                    .load(prebindStr(args, 0), {
                        r: ILoadResult => if (let Some(c) <- onLoad) {
                            try {
                                c.call(args: [prebindRegister(r, "three.scene.scenegraph.Group")])
                            } catch (_: Exception) {
                            }
                        }
                    }, {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    b.install(vm)
}
