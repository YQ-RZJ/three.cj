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
 * @file[zh-cn] resource_loader_datatextureloader 数据纹理加载器的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.DataTextureLoader 绑定为 Lua 类型
 * @explain[zh-cn] 绑定构造（可选 LoadingManager）、Loader 公共成员（复用
 * prebindInstallLoaderMembers）、load(url, onLoad?, onProgress?, onError?)（同步读取
 * 本地文件，onLoad 回传 three.renderers.textures.DataTexture 对象）与
 * createDataTexture(buffer)（内存字节 → DataTexture，解析失败返回 nil）；绑定层捕获
 * 异常后返回 false / nil，绝不向 Lua 抛错。
 * 本文件的 prebindInstallDataTextureLoaderMembers 同时供 EXR/HDR/RGBE/TGA 绑定复用。
 * 跳过：parse（返回 HashMap<String, Any> 纹理数据字典，无法映射为 Lua 值）；
 * _applyTexData（参数为 HashMap<String, Any>）；requestHeader / setRequestHeader
 * （HashMap<String, Any>）。
 *
 * @file[en] resource_loader_datatextureloader  Lua binding of the data texture loader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.DataTextureLoader as a Lua type
 * @explain[en] Binds construction (optional LoadingManager), Loader's common members
 * (reusing prebindInstallLoaderMembers), load(url, onLoad?, onProgress?, onError?) (reads a
 * local file synchronously, onLoad receives a three.renderers.textures.DataTexture object)
 * and createDataTexture(buffer) (in-memory bytes -> DataTexture, nil on parse failure); the
 * binding catches exceptions and returns false / nil, never throwing to Lua.
 * prebindInstallDataTextureLoaderMembers is reused by the EXR/HDR/RGBE/TGA bindings.
 * Skipped: parse (returns a HashMap<String, Any> texture-data dictionary, not mappable to
 * Lua values); _applyTexData (takes a HashMap<String, Any>); requestHeader /
 * setRequestHeader (HashMap<String, Any>).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 为数据纹理加载器家族登记成员（Loader 公共配置 + load + createDataTexture）
 * @param[zh-cn] b 类绑定器（DataTextureLoader 或其子类）
 * @param[zh-cn] vm 目标虚拟机（用于构造回调）
 * @explain[zh-cn] load 为同步调用，回调在返回前触发；Lua 回调内异常被吞掉。
 *
 * @brief[en] Registers the members of the data texture loader family
 * (Loader common config + load + createDataTexture)
 * @param[en] b The class binder (DataTextureLoader or a subclass)
 * @param[en] vm The target virtual machine (used to build callbacks)
 * @explain[en] load is synchronous and callbacks fire before it returns; errors inside Lua
 * callbacks are swallowed.
 */
internal func prebindInstallDataTextureLoaderMembers(b: LuaClassBinder, vm: LuaVM): Unit {
    prebindInstallLoaderMembers(b)
    // ===== 加载（同步；失败返回 false） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            var completed = false
            try {
                ref
                    .cast<DataTextureLoader>()
                    .load(prebindStr(args, 0), {
                        r: ILoadResult => if (let Some(cb) <- onLoad) {
                            try {
                                cb.call(args: [prebindRegister(r, "three.renderers.textures.DataTexture")])
                            } catch (_: Exception) {
                            }
                        }
                    }, {p: Int64 => prebindCallProgress(onProgress, p)}, {msg: String => prebindCallError(onError, msg)})
                completed = true
            } catch (_: Exception) {
            }
            [LuaValue.of(completed)]
    }
    // ===== 内存字节 → DataTexture（失败返回 nil） =====
    b.method("createDataTexture") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<DataTextureLoader>().createDataTexture(prebindBytes(vm, args, 0)),
                    "three.renderers.textures.DataTexture")
            } catch (_: Exception) {
            }
            [out]
    }
}

/**
 * @brief[zh-cn] 安装 DataTextureLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.DataTextureLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of DataTextureLoader
 * @param[en] vm The target virtual machine (class table installed at
 * three.resource.loader.DataTextureLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installDataTextureLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.DataTextureLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            DataTextureLoader(m)
        } else {
            DataTextureLoader()
        }
    }
    prebindInstallDataTextureLoaderMembers(b, vm)
    b.install(vm)
}
