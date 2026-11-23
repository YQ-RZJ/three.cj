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
 * @file[zh-cn] resource_loader_fontloader 字体加载器 FontLoader 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.FontLoader 绑定为 Lua 类型
 * three.resource.loader.FontLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员与 load：读取 JSON 字体文件，
 * onLoad 收到 StringLoadResult（JSON 字符串）；读取 / 回调异常均被吞掉。跳过：
 * requestHeader / setRequestHeader（HashMap<String, Any> 无 Lua 通道）。
 *
 * @file[en] resource_loader_fontloader  Lua binding of the font loader FontLoader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.FontLoader as the Lua type three.resource.loader.FontLoader
 * @explain[en] Binds construction (optional manager), the Loader common members and load:
 * reads a JSON font file and onLoad receives a StringLoadResult (the JSON string);
 * read/callback errors are swallowed. Skipped: requestHeader / setRequestHeader
 * (HashMap<String, Any> has no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 FontLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.FontLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of FontLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.FontLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installFontLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.FontLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            FontLoader(manager: m)
        } else {
            FontLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载 JSON 字体（异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<FontLoader>()
                    .load(prebindStr(args, 0), {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    b.install(vm)
}
