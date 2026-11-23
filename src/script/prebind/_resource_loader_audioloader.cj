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
 * @file[zh-cn] resource_loader_audioloader 音频加载器 AudioLoader 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.AudioLoader 绑定为 Lua 类型
 * three.resource.loader.AudioLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员、load 与 loadFromBytes：
 * load 按参数个数分派——仅 1 个参数时直接返回 AudioBuffer，带回调时走
 * load(url, onLoad, onProgress, onError) 并回传 AudioBuffer；loadFromBytes 从字节数组
 * 解码返回 AudioBuffer。解码异常被吞掉，返回 nil。跳过：requestHeader /
 * setRequestHeader（HashMap<String, Any> 无 Lua 通道）。
 *
 * @file[en] resource_loader_audioloader  Lua binding of the audio loader AudioLoader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.AudioLoader as the Lua type three.resource.loader.AudioLoader
 * @explain[en] Binds construction (optional manager), the Loader common members, load and
 * loadFromBytes: load dispatches by arity — with a single argument it returns the AudioBuffer
 * directly, with callbacks it uses load(url, onLoad, onProgress, onError) and delivers the
 * AudioBuffer; loadFromBytes decodes a byte array and returns the AudioBuffer. Decode errors
 * are swallowed and nil is returned. Skipped: requestHeader / setRequestHeader
 * (HashMap<String, Any> has no Lua channel).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.audio.source.AudioBuffer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.AudioLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.AudioLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.AudioLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            AudioLoader(m)
        } else {
            AudioLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载：1 参返回 AudioBuffer；带回调时走回调重载 =====
    b.method("load") {
        ref, args => if (args.size >= 2) {
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<AudioLoader>()
                    .load(prebindStr(args, 0), {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
        } else {
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<AudioLoader>().load(prebindStr(args, 0)),
                    "three.audio.source.AudioBuffer")
            } catch (_: Exception) {
            }
            [out]
        }
    }
    // ===== 从内存字节解码（异常静默） =====
    b.method("loadFromBytes") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<AudioLoader>().loadFromBytes(prebindBytes(vm, args, 0)),
                    "three.audio.source.AudioBuffer")
            } catch (_: Exception) {
            }
            [out]
    }
    b.install(vm)
}
