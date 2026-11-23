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
 * @file[zh-cn] resource_loader_loader 加载器基类 Loader 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.Loader 绑定为 Lua 类型
 * three.resource.loader.Loader
 * @explain[zh-cn] 绑定构造（可选 manager）、属性 manager / crossOrigin / withCredentials /
 * path / resourcePath、链式方法 setPath / setResourcePath / setCrossOrigin /
 * setWithCredentials / abort，以及 load（回调参数经 LuaCallback 包装，结果按其真实
 * 类型注册后回传；加载异常被吞掉并保持静默）。跳过：requestHeader 字段与
 * setRequestHeader（HashMap<String, Any> 无 Lua 通道）。另提供内部工具
 * prebindInstallLoaderMembers / prebindOptLoadingManager 供各具体加载器复用
 * （绑定层无 __index 继承链，子类需重复登记基类成员）。
 *
 * @file[en] resource_loader_loader  Lua binding of the loader base class Loader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.Loader as the Lua type three.resource.loader.Loader
 * @explain[en] Binds construction (optional manager), the properties manager / crossOrigin /
 * withCredentials / path / resourcePath, the chaining methods setPath / setResourcePath /
 * setCrossOrigin / setWithCredentials / abort, and load (callback args wrapped via
 * LuaCallback; results registered under their real type; load errors are swallowed).
 * Skipped: the requestHeader field and setRequestHeader (HashMap<String, Any> has no Lua
 * channel). Internal helpers prebindInstallLoaderMembers / prebindOptLoadingManager are
 * provided for concrete loaders (the binding layer has no __index inheritance chain, so
 * subclasses repeat the base members).
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选加载管理器参数（缺省 / nil / 非对象 → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(LoadingManager) 或 None
 *
 * @brief[en] Reads an optional loading-manager argument (absent / nil / non-object → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(LoadingManager) or None
 */
internal func prebindOptLoadingManager(args: Array<LuaValue>, idx: Int64): Option<LoadingManager> {
    if (args.size <= idx || args[idx].isNil || !args[idx].isObject) {
        return None
    }
    return Some(LuaObjectRegistry.getAs<LoadingManager>(args[idx].objectId()))
}

/**
 * @brief[zh-cn] 为绑定类登记 Loader 的公共成员（属性与链式配置方法）
 * @explain[zh-cn] 供 Loader 及其具体子类的绑定复用；不登记 load（各具体类签名不同）。
 * @param[zh-cn] b 目标类的绑定器
 *
 * @brief[en] Registers Loader's common members (properties and chaining setters) on a binder
 * @explain[en] Reused by Loader and its concrete subclasses; load is not registered here
 * (each concrete class has its own signature).
 * @param[en] b The class binder
 */
internal func prebindInstallLoaderMembers(b: LuaClassBinder): Unit {
    // ===== 属性 =====
    b.property("manager", getter: Some({
        ref => prebindRegister(ref.cast<Loader>().manager, "three.resource.loader.LoadingManager")
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<Loader>().manager = prebindAsValue<LoadingManager>(v)
        } else {
            ref.cast<Loader>().manager = LoadingManager()
        }
    }))
    b.property("crossOrigin", getter: Some({ref => LuaValue.of(ref.cast<Loader>().crossOrigin)}),
        setter: Some({ref, v => ref.cast<Loader>().crossOrigin = v.stringValue()}))
    b.property("withCredentials", getter: Some({ref => LuaValue.of(ref.cast<Loader>().withCredentials)}),
        setter: Some({ref, v => ref.cast<Loader>().withCredentials = v.boolValue()}))
    b.property("path", getter: Some({ref => LuaValue.of(ref.cast<Loader>().path)}),
        setter: Some({ref, v => ref.cast<Loader>().path = v.stringValue()}))
    b.property("resourcePath", getter: Some({ref => LuaValue.of(ref.cast<Loader>().resourcePath)}),
        setter: Some({ref, v => ref.cast<Loader>().resourcePath = v.stringValue()}))
    // ===== 链式配置（返回自身） =====
    b.method("setPath") {
        ref, args =>
            ref.cast<Loader>().setPath(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setResourcePath") {
        ref, args =>
            ref.cast<Loader>().setResourcePath(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setCrossOrigin") {
        ref, args =>
            ref.cast<Loader>().setCrossOrigin(prebindStr(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setWithCredentials") {
        ref, args =>
            ref.cast<Loader>().setWithCredentials(prebindBool(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("abort") {
        ref, _ =>
            ref.cast<Loader>().abort()
            [LuaValue.Object(ref.id)]
    }
}

/**
 * @brief[zh-cn] 安装 Loader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.Loader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Loader
 * @param[en] vm The target virtual machine (class table installed at three.resource.loader.Loader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.Loader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            Loader(manager: m)
        } else {
            Loader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 加载（基类实现为空，保持接口一致） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<Loader>()
                    .load(prebindStr(args, 0), {r: ILoadResult => prebindCallLoadResult(onLoad, r)},
                        {p: Int64 => prebindCallProgress(onProgress, p)}, {m: String => prebindCallError(onError, m)})
            } catch (_: Exception) {
            }
            []
    }
    b.install(vm)
}
