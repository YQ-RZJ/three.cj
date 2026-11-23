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
 * @file[zh-cn] resource_cache_cache 资源缓存 Cache 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.cache.Cache 绑定为 Lua 类型 three.resource.cache.Cache
 * @explain[zh-cn] Cache 为纯静态类（无构造器）：静态属性 enabled 以 getEnabled/setEnabled
 * 静态方法暴露，add/get/remove/clear 映射为同名静态方法。
 * 跳过项与原因：
 * - files（HashMap<String, ILoadResult>）：缺少「Lua 表 ↔ HashMap」通道，不绑定；
 *   按 key 取单个条目请用 get(key)；
 * - ILoadResult 为无成员的标记接口，接口本身不绑定；get 返回的加载结果按运行时具体
 *   类型注册（StringLoadResult / BytesLoadResult / ClipsLoadResult），未知实现回退
 *   注册为 three.core._interfaces.ILoadResult（可原样传回 add）。
 * add 的第二个参数不是已注册的加载结果对象时静默忽略（不抛异常，避免 lua_error 的
 * longjmp 破坏仓颉栈）。
 *
 * @file[en] resource_cache_cache  Lua binding of the resource cache (three.script.prebind)
 * @brief[en] Binds three.resource.cache.Cache as the Lua type three.resource.cache.Cache
 * @explain[en] Cache is a purely static class (no constructor): the static property enabled is
 * exposed via getEnabled/setEnabled static methods, and add/get/remove/clear map to static
 * methods of the same names.
 * Skipped members and reasons:
 * - files (HashMap<String, ILoadResult>): there is no "Lua table ↔ HashMap" channel, so it is
 *   not bound; use get(key) to fetch a single entry;
 * - ILoadResult is a member-less marker interface and interfaces are not bound; results
 *   returned by get are registered by their runtime concrete type
 *   (StringLoadResult / BytesLoadResult / ClipsLoadResult), and unknown implementations fall
 *   back to three.core._interfaces.ILoadResult (still passable back to add).
 * When add's second argument is not a registered load-result object the call is silently
 * ignored (never throws, to avoid lua_error's longjmp corrupting Cangjie stack frames).
 */
package three.script.prebind

import three.resource.cache.*
import three.resource.loader.{StringLoadResult, BytesLoadResult, ClipsLoadResult}
import three.core._interfaces.ILoadResult
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 加载结果转 Lua 值（按运行时具体类型注册，未知实现回退为标记接口）
 * @explain[zh-cn] 供 Cache / AssetCache / AssetManager 绑定复用：StringLoadResult、
 * BytesLoadResult、ClipsLoadResult 用各自完整类名注册（可配合对应绑定读取 value）；
 * 其余实现统一注册为 three.core._interfaces.ILoadResult（不透明，但可回传引擎方法）。
 * @param[zh-cn] res 加载结果
 * @return[zh-cn] 已注册的 Lua 对象值
 *
 * @brief[en] Converts a load result to a Lua value (registered by runtime concrete type,
 * falling back to the marker interface for unknown implementations)
 * @explain[en] Reused by the Cache / AssetCache / AssetManager bindings: StringLoadResult,
 * BytesLoadResult and ClipsLoadResult are registered under their own fully-qualified names
 * (so matching bindings can expose value); any other implementation is registered as
 * three.core._interfaces.ILoadResult (opaque, yet still passable back into engine methods).
 * @param[en] res The load result
 * @return[en] The registered Lua object value
 */
internal func prebindLoadResultToLua(res: ILoadResult): LuaValue {
    match (res) {
        case v: StringLoadResult => prebindRegister(v, "three.resource.loader.StringLoadResult")
        case v: BytesLoadResult => prebindRegister(v, "three.resource.loader.BytesLoadResult")
        case v: ClipsLoadResult => prebindRegister(v, "three.resource.loader.ClipsLoadResult")
        case _ => prebindRegister(res, "three.core._interfaces.ILoadResult")
    }
}

/**
 * @brief[zh-cn] 安装 Cache 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.resource.cache.Cache）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of Cache (static-only class, no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at three.resource.cache.Cache)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installCache(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.cache.Cache")
    // ===== 静态属性（以 get/set 静态方法暴露）=====
    b.staticMethod("getEnabled") {_ => [LuaValue.of(Cache.enabled)]}
    b.staticMethod("setEnabled") {
        args =>
            Cache.enabled = prebindBool(args, 0)
            []
    }
    // ===== 缓存读写 =====
    b.staticMethod("add") {
        args =>
            try {
                Cache.add(prebindStr(args, 0), prebindAs<ILoadResult>(args, 1))
            } catch (_: Exception) {
                // 入参不是已注册的加载结果对象：忽略本次写入
            }
            []
    }
    b.staticMethod("get") {
        args => match (Cache.get(prebindStr(args, 0))) {
            case Some(r) => [prebindLoadResultToLua(r)]
            case None => [LuaValue.Nil]
        }
    }
    b.staticMethod("remove") {
        args =>
            Cache.remove(prebindStr(args, 0))
            []
    }
    b.staticMethod("clear") {
        _ =>
            Cache.clear()
            []
    }
    b.install(vm)
}
