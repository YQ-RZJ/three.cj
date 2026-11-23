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
 * @file[zh-cn] resource_loader_loadingmanager 加载管理器 LoadingManager 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.LoadingManager 绑定为 Lua 类型
 * three.resource.loader.LoadingManager
 * @explain[zh-cn] 绑定构造（可选 onLoad / onProgress / onError 回调，回调异常被吞掉）、
 * itemStart / itemEnd / itemError / resolveURL / setURLModifier（Lua 函数包装为
 * (String) -> String）/ addHandler / getHandler（返回的加载器按真实运行时类型注册）。
 * 跳过：onStart / onLoad / onProgress / onError 四个闭包字段（无法双向映射为 Lua 值，
 * 仅可通过构造参数设置）。
 *
 * @file[en] resource_loader_loadingmanager  Lua binding of the loading manager
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.LoadingManager as the Lua type
 * three.resource.loader.LoadingManager
 * @explain[en] Binds construction (optional onLoad / onProgress / onError callbacks whose
 * errors are swallowed), itemStart / itemEnd / itemError / resolveURL / setURLModifier
 * (a Lua function wrapped as (String) -> String) / addHandler / getHandler (returned loaders
 * are registered under their real runtime types). Skipped: the four closure fields onStart /
 * onLoad / onProgress / onError (no bidirectional Lua channel; settable only via the
 * constructor).
 */
package three.script.prebind

import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 按加载器的真实运行时类型给出其 Lua 绑定类全名
 * @param[zh-cn] l 加载器
 * @return[zh-cn] Lua 侧类表路径（未绑定的具体类型回退为 Loader）
 *
 * @brief[en] Maps a loader's real runtime type to its full Lua bound class name
 * @param[en] l The loader
 * @return[en] The Lua-side class path (unbound concrete types fall back to Loader)
 */
private func _prebindLoaderClassName(l: Loader): String {
    match (l) {
        case _: FileLoader => "three.resource.loader.FileLoader"
        case _: ImageLoader => "three.resource.loader.ImageLoader"
        case _: TextureLoader => "three.resource.loader.TextureLoader"
        case _: CubeTextureLoader => "three.resource.loader.CubeTextureLoader"
        case _: FontLoader => "three.resource.loader.FontLoader"
        case _: AnimationLoader => "three.resource.loader.AnimationLoader"
        case _: AudioLoader => "three.resource.loader.AudioLoader"
        case _: MaterialLoader => "three.resource.loader.MaterialLoader"
        case _ => "three.resource.loader.Loader"
    }
}

/**
 * @brief[zh-cn] 安全执行一条 LoadingManager 回调
 * @param[zh-cn] cb 目标回调
 * @param[zh-cn] args 回调参数
 *
 * @brief[en] Runs one LoadingManager callback safely
 * @param[en] cb The target callback
 * @param[en] args The callback arguments
 */
private func _prebindCallManagerCb(cb: LuaCallback, args: Array<LuaValue>): Unit {
    try {
        cb.call(args: args)
    } catch (_: Exception) {
        // 回调自身出错：跳过，不向引擎抛出
    }
}

/**
 * @brief[zh-cn] 安装 LoadingManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.LoadingManager）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of LoadingManager
 * @param[en] vm The target virtual machine (class table at three.resource.loader.LoadingManager)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLoadingManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.LoadingManager")
    // ===== 构造：可选 onLoad / onProgress / onError =====
    b.constructor {
        args =>
            let onLoadCb = prebindOptCallback(vm, args, 0)
            let onProgressCb = prebindOptCallback(vm, args, 1)
            let onErrorCb = prebindOptCallback(vm, args, 2)
            var onLoadF: Option<() -> Unit> = None
            if (let Some(c) <- onLoadCb) {
                onLoadF = Some({=> _prebindCallManagerCb(c, Array<LuaValue>())})
            }
            var onProgressF: Option<(String, Int64, Int64) -> Unit> = None
            if (let Some(c) <- onProgressCb) {
                onProgressF = Some({
                    url: String, loaded: Int64, total: Int64 => _prebindCallManagerCb(c,
                        [LuaValue.of(url), LuaValue.of(loaded), LuaValue.of(total)])
                })
            }
            var onErrorF: Option<(String) -> Unit> = None
            if (let Some(c) <- onErrorCb) {
                onErrorF = Some({msg: String => _prebindCallManagerCb(c, [LuaValue.of(msg)])})
            }
            LoadingManager(onLoad: onLoadF, onProgress: onProgressF, onError: onErrorF)
    }
    // ===== 项目计数 =====
    b.method("itemStart") {
        ref, args =>
            ref.cast<LoadingManager>().itemStart(prebindStr(args, 0))
            []
    }
    b.method("itemEnd") {
        ref, args =>
            ref.cast<LoadingManager>().itemEnd(prebindStr(args, 0))
            []
    }
    b.method("itemError") {
        ref, args =>
            ref.cast<LoadingManager>().itemError(prebindStr(args, 0))
            []
    }
    // ===== URL 解析 =====
    b.method("resolveURL") {
        ref, args => [LuaValue.of(ref.cast<LoadingManager>().resolveURL(prebindStr(args, 0)))]
    }
    b.method("setURLModifier") {
        ref, args =>
            let cb = prebindOptCallback(vm, args, 0)
            ref.cast<LoadingManager>().setURLModifier(
                {
                    url: String =>
                        var out = url
                        if (let Some(c) <- cb) {
                            try {
                                let r = c.call(args: [LuaValue.of(url)])
                                if (r.size > 0) {
                                    out = r[0].stringValue(default: url)
                                }
                            } catch (_: Exception) {
                            }
                        }
                        out
                }
            )
            [LuaValue.Object(ref.id)]
    }
    // ===== 处理器注册与查找 =====
    b.method("addHandler") {
        ref, args =>
            ref.cast<LoadingManager>().addHandler(prebindStr(args, 0), prebindAs<Loader>(args, 1))
            [LuaValue.Object(ref.id)]
    }
    b.method("getHandler") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                if (let Some(l) <- ref.cast<LoadingManager>().getHandler(prebindStr(args, 0))) {
                    out = prebindRegister(l, _prebindLoaderClassName(l))
                }
            } catch (_: Exception) {
            }
            [out]
    }
    b.install(vm)
}
