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
 * @file[zh-cn] resource_loader_fileloader 文件加载器 FileLoader 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.FileLoader 绑定为 Lua 类型
 * three.resource.loader.FileLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员、responseType / mimeType
 * 属性、setResponseType / setMimeType 链式方法，以及 load（onLoad 收到
 * StringLoadResult 或 BytesLoadResult，按 responseType 决定；回调异常与读取异常均被
 * 吞掉，绝不让异常穿出绑定方法）。跳过：requestHeader / setRequestHeader
 * （HashMap<String, Any> 无 Lua 通道）。
 *
 * @file[en] resource_loader_fileloader  Lua binding of the file loader FileLoader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.FileLoader as the Lua type three.resource.loader.FileLoader
 * @explain[en] Binds construction (optional manager), the Loader common members, the
 * responseType / mimeType properties, the setResponseType / setMimeType chaining methods,
 * and load (onLoad receives StringLoadResult or BytesLoadResult depending on responseType;
 * callback and read errors are swallowed, never escaping the binding method). Skipped:
 * requestHeader / setRequestHeader (HashMap<String, Any> has no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FileLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.FileLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FileLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.FileLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFileLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.FileLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            FileLoader(m)
        } else {
            FileLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 属性 =====
    b.property("responseType", getter: Some({ref => LuaValue.of(ref.cast<FileLoader>().responseType)}),
        setter: Some({ref, v => ref.cast<FileLoader>().responseType = v.stringValue()}))
    b.property("mimeType", getter: Some({ref => LuaValue.of(ref.cast<FileLoader>().mimeType)}),
        setter: Some({ref, v => ref.cast<FileLoader>().mimeType = v.stringValue()}))
    // ===== 链式配置（返回自身） =====
    b.method("setResponseType") {
        ref, args =>
            ref.cast<FileLoader>().setResponseType(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setMimeType") {
        ref, args =>
            ref.cast<FileLoader>().setMimeType(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 加载（同步本地文件读取，异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<FileLoader>()
                    .load(prebindStr(args, 0), {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    b.install(vm)
}
