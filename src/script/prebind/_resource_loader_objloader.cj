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
 * @file[zh-cn] resource_loader_objloader OBJLoader 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.OBJLoader 绑定为 Lua 类型 three.resource.loader.OBJLoader
 * @explain[zh-cn] 绑定构造（可选 manager）、Loader 公共成员、materials 属性
 * （Option<MaterialCreator>：Some 注册为 three.resource.loader.MaterialCreator / None 为 nil）、
 * load（读取 OBJ 文件，onLoad 收到 Group，注册为 three.scene.scenegraph.Group）、
 * setMaterials（链式返回自身）、parse(text)（解析异常返回 nil）。读取 / 解析 / 回调异常
 * 均被吞掉，绝不让异常穿出绑定方法。
 *
 * @file[en] resource_loader_objloader  Lua binding of OBJLoader (three.script.prebind)
 * @brief[en] Binds three.resource.loader.OBJLoader as the Lua type three.resource.loader.OBJLoader
 * @explain[en] Binds construction (optional manager), the Loader common members, the materials
 * property (Option<MaterialCreator>: Some registers as three.resource.loader.MaterialCreator,
 * None is nil), load (reads an OBJ file; onLoad receives a Group registered as
 * three.scene.scenegraph.Group), setMaterials (chaining, returns self) and parse(text) (nil on
 * parse failure). Read/parse/callback errors are swallowed and never escape the binding method.
 */
package three.script.prebind

import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 OBJLoader 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.OBJLoader）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of OBJLoader
 * @param[en] vm The target virtual machine (class table at three.resource.loader.OBJLoader)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installOBJLoader(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.OBJLoader")
    // ===== 构造：可选 manager =====
    b.constructor {
        args => if (let Some(m) <- prebindOptLoadingManager(args, 0)) {
            OBJLoader(m)
        } else {
            OBJLoader()
        }
    }
    prebindInstallLoaderMembers(b)
    // ===== 材质创建器（可空） =====
    b.property("materials", getter: Some({
        ref => match (ref.cast<OBJLoader>().materials) {
            case Some(m) => prebindRegister(m, "three.resource.loader.MaterialCreator")
            case None => LuaValue.Nil
        }
    }), setter: Some({
        ref, v => if (v.isObject) {
            ref.cast<OBJLoader>().materials = Some(prebindAsValue<MaterialCreator>(v))
        } else {
            ref.cast<OBJLoader>().materials = None
        }
    }))
    // ===== 加载 OBJ 文件（读取 / 回调异常静默） =====
    b.method("load") {
        ref, args =>
            let onLoad = prebindOptCallback(vm, args, 1)
            let onProgress = prebindOptCallback(vm, args, 2)
            let onError = prebindOptCallback(vm, args, 3)
            try {
                ref
                    .cast<OBJLoader>()
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
    // ===== 设置材质创建器（链式返回自身） =====
    b.method("setMaterials") {
        ref, args =>
            ref.cast<OBJLoader>().setMaterials(prebindAs<MaterialCreator>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 解析 OBJ 文本（异常返回 nil） =====
    b.method("parse") {
        ref, args =>
            var out = LuaValue.Nil
            try {
                out = prebindRegister(ref.cast<OBJLoader>().parse(prebindStr(args, 0)), "three.scene.scenegraph.Group")
            } catch (_: Exception) {
                out = LuaValue.Nil
            }
            [out]
    }
    b.install(vm)
}
