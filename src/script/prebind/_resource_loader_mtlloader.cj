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
 * @file[zh-cn] resource_loader_mtlloader MTL 材质库加载器的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.MTLLoader / MaterialCreator 绑定为 Lua 类型
 * @explain[zh-cn] MTLLoader：构造（可选 LoadingManager）、继承自 Loader 的公共配置
 * （manager/crossOrigin/withCredentials/path/resourcePath 属性与
 * setPath/setResourcePath/setCrossOrigin/setWithCredentials/abort 方法）、
 * load(url, onLoad?, onProgress?, onError?)（同步读取本地文件，onLoad 回传
 * three.resource.loader.MaterialCreator 对象）与 parse(text, path?)（返回
 * MaterialCreator）；失败返回 false / nil，绑定层绝不向 Lua 抛错。
 * MaterialCreator：构造（baseUrl）、baseUrl/crossOrigin/manager 属性、
 * setCrossOrigin/setManager（返回自身以支持链式调用）与 create(name)（按名称懒创建
 * three.renderers.materials.Material，未找到返回 nil）；实现 ILoadResult 的接口本身不绑定。
 * 跳过：MTLLoader.materialOptions（Option<HashMap<String, Any>>）；
 * MaterialCreator.materialsInfo（HashMap<String, Any>）、materials
 * （HashMap<String, Material>，无法就地映射）、setMaterials（参数
 * HashMap<String, Any>）；以及继承自 Loader 的 requestHeader（HashMap<String, Any>）。
 *
 * @file[en] resource_loader_mtlloader  Lua binding of the MTL material library loader
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader.MTLLoader / MaterialCreator as Lua types
 * @explain[en] MTLLoader: construction (optional LoadingManager), Loader's inherited config
 * (manager/crossOrigin/withCredentials/path/resourcePath properties and
 * setPath/setResourcePath/setCrossOrigin/setWithCredentials/abort methods),
 * load(url, onLoad?, onProgress?, onError?) (reads a local file synchronously, onLoad
 * receives a three.resource.loader.MaterialCreator object) and parse(text, path?) (returns a
 * MaterialCreator); failures return false / nil and the binding never throws to Lua.
 * MaterialCreator: construction (baseUrl), baseUrl/crossOrigin/manager properties,
 * setCrossOrigin/setManager (return self for chaining) and create(name) (lazily creates a
 * three.renderers.materials.Material by name, nil when not found); the implemented
 * ILoadResult interface itself is not bound.
 * Skipped: MTLLoader.materialOptions (Option<HashMap<String, Any>>);
 * MaterialCreator.materialsInfo (HashMap<String, Any>), materials
 * (HashMap<String, Material>, not mappable in place), setMaterials (takes a
 * HashMap<String, Any>); and the inherited Loader.requestHeader (HashMap<String, Any>).
 */
package three.script.prebind

import three.resource.loader.*
import three.core._interfaces.ILoadResult
import three.renderers.materials.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 MTLLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.MTLLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MTLLoader
 * @param[en] vm The target virtual machine (class table installed at
 * three.resource.loader.MTLLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMTLLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.MTLLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            MTLLoader(m)
        } else {
            MTLLoader()
        }
    }
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
                    .cast<MTLLoader>()
                    .load(prebindStr(args, 0), {
                        r: ILoadResult => if (let Some(cb) <- onLoad) {
                            try {
                                cb.call(args: [prebindRegister(r, "three.resource.loader.MaterialCreator")])
                            } catch (_: Exception) {
                            }
                        }
                    }, {p: Int64 => prebindCallProgress(onProgress, p)}, {msg: String => prebindCallError(onError, msg)})
                completed = true
            } catch (_: Exception) {
            }
            [LuaValue.of(completed)]
    }
    // ===== 解析 MTL 文本（失败返回 nil） =====
    b.method("parse") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<MTLLoader>().parse(prebindStr(args, 0), prebindStr(args, 1)),
                    "three.resource.loader.MaterialCreator")
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 MaterialCreator 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.MaterialCreator）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of MaterialCreator
 * @param[en] vm The target virtual machine (class table installed at
 * three.resource.loader.MaterialCreator)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installMaterialCreator(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.MaterialCreator")
    // ===== 构造：new(baseUrl) =====
    b.constructor {args => MaterialCreator(prebindStr(args, 0))}
    // ===== 属性 =====
    b.property("baseUrl", getter: Some({ref => LuaValue.of(ref.cast<MaterialCreator>().baseUrl)}),
        setter: Some({ref, v => ref.cast<MaterialCreator>().baseUrl = v.stringValue()}))
    b.property("crossOrigin", getter: Some({ref => LuaValue.of(ref.cast<MaterialCreator>().crossOrigin)}),
        setter: Some({ref, v => ref.cast<MaterialCreator>().crossOrigin = v.stringValue()}))
    b.property("manager", getter: Some({
        ref => prebindRegister(ref.cast<MaterialCreator>().manager, "three.resource.loader.LoadingManager")
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<MaterialCreator>().manager = prebindAsValue<LoadingManager>(v)
        } else {
            ref.cast<MaterialCreator>().manager = LoadingManager()
        }
    }))
    // ===== 配置（返回自身 id 以支持链式调用） =====
    b.method("setCrossOrigin") {
        ref, args =>
            ref.cast<MaterialCreator>().setCrossOrigin(prebindStr(args, 0, default: "anonymous"))
            [LuaValue.Object(ref.id)]
    }
    b.method("setManager") {
        ref, args =>
            ref.cast<MaterialCreator>().setManager(prebindAs<LoadingManager>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 按名称创建材质（未找到 / 失败返回 nil） =====
    b.method("create") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                if (let Some(m) <- ref.cast<MaterialCreator>().create(prebindStr(args, 0))) {
                    out = prebindRegister(m, "three.renderers.materials.Material")
                }
            } catch (_) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}
