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
 * @file[zh-cn] resource_loader_stlloader STLLoader 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.STLLoader 绑定为 Lua 类型 three.resource.loader.STLLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员、load（读取 STL 文件，onLoad 收到
 * BufferGeometry，注册为 three.renderers.geometry.BufferGeometry）、parse(data)（字节数组参数，
 * 解析异常返回 nil）。读取 / 解析 / 回调异常均被吞掉，绝不让异常穿出绑定方法。
 *
 * @file[en] resource_loader_stlloader  Lua binding of STLLoader (three.script.prebind)
 * @brief[en] Binds three.resource.loader.STLLoader as the Lua type three.resource.loader.STLLoader
 * @explain[en] Binds construction (optional manager), the Loader common members, load (reads an
 * STL file; onLoad receives a BufferGeometry registered as
 * three.renderers.geometry.BufferGeometry) and parse(data) (byte-array argument; nil on parse
 * failure). Read/parse/callback errors are swallowed and never escape the binding method.
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 STLLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.STLLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of STLLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.STLLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installSTLLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.STLLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            STLLoader(m)
        } else {
            STLLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载 STL 文件（读取 / 回调异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<STLLoader>()
                    .load(prebindStr(args, 0), {
                        r: ILoadResult => if (let Some(c) <- onLoad) {
                            try {
                                c.call(args: [prebindRegister(r, "three.renderers.geometry.BufferGeometry")])
                            } catch (_: Exception) {
                            }
                        }
                    }, {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    // ===== 解析字节数据（异常返回 nil） =====
    b.method("parse") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<STLLoader>().parse(prebindBytes(vm, args, 0)),
                    "three.renderers.geometry.BufferGeometry")
            } catch (_: Exception) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}
