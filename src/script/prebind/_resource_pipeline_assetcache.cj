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
 * @file[zh-cn] resource_pipeline_assetcache 引用计数资源缓存的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.pipeline.AssetCache 绑定为 Lua 类型
 * three.resource.pipeline.AssetCache
 * @explain[zh-cn] 绑定无参构造、全局单例 shared（以静态方法 getShared 暴露）、只读属性
 * count/releasable、advanceFrame、add/get/acquire/retain/release/refCount/remove/
 * collect/collectIfNeeded。release 的两个重载合并为一个 Lua 方法：无参 = 清空整个缓存，
 * 带 key = 释放一次引用。
 * ILoadResult 为无成员的标记接口，接口本身不绑定；get/acquire 返回的结果按运行时具体
 * 类型注册（StringLoadResult / BytesLoadResult / ClipsLoadResult，未知实现回退为
 * three.core._interfaces.ILoadResult）。add 的第二个参数不是已注册的加载结果对象时
 * 静默忽略（不抛异常，避免 lua_error 的 longjmp 破坏仓颉栈）。
 * 跳过项：无（公开成员均已绑定）。
 *
 * @file[en] resource_pipeline_assetcache  Lua binding of the ref-counted asset cache
 * (three.script.prebind)
 * @brief[en] Binds three.resource.pipeline.AssetCache as the Lua type
 * three.resource.pipeline.AssetCache
 * @explain[en] Binds the parameterless constructor, the global shared instance (exposed as the
 * static method getShared), the read-only properties count/releasable, advanceFrame,
 * add/get/acquire/retain/release/refCount/remove/collect/collectIfNeeded. The two release
 * overloads merge into one Lua method: no argument clears the whole cache, a key releases one
 * reference.
 * ILoadResult is a member-less marker interface and interfaces are not bound; results returned
 * by get/acquire are registered by runtime concrete type (StringLoadResult / BytesLoadResult /
 * ClipsLoadResult, unknown implementations fall back to three.core._interfaces.ILoadResult).
 * When add's second argument is not a registered load-result object the call is silently
 * ignored (never throws, to avoid lua_error's longjmp corrupting Cangjie stack frames).
 * Skipped members: none (every public member is bound).
 */
package three.script.prebind

import three.resource.pipeline.AssetCache
import three.core._interfaces.ILoadResult
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AssetCache 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.pipeline.AssetCache）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AssetCache
 * @param[en] vm The target virtual machine (class table installed at three.resource.pipeline.AssetCache)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAssetCache(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.pipeline.AssetCache")
    // ===== 构造 =====
    b.constructor {_ => AssetCache()}
    // ===== 全局共享实例（静态 let，以 getShared 暴露） =====
    b.staticMethod("getShared") {
        _ => [prebindRegister(AssetCache.shared, "three.resource.pipeline.AssetCache")]
    }
    // ===== 属性（只读） =====
    b.property("count", getter: Some({ref => LuaValue.of(ref.cast<AssetCache>().count)}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AssetCache>().releasable)}))
    // ===== 帧号推进 =====
    b.method("advanceFrame") {
        ref, _ =>
            ref.cast<AssetCache>().advanceFrame()
            []
    }
    // ===== 写入 / 读取 =====
    b.method("add") {
        ref, args =>
            try {
                ref.cast<AssetCache>().add(prebindStr(args, 0), prebindAs<ILoadResult>(args, 1))
            } catch (_: Exception) {
                // 入参不是已注册的加载结果对象：忽略本次写入
            }
            []
    }
    b.method("get") {
        ref, args => match (ref.cast<AssetCache>().get(prebindStr(args, 0))) {
            case Some(r) => [prebindLoadResultToLua(r)]
            case None => [LuaValue.Nil]
        }
    }
    b.method("acquire") {
        ref, args => match (ref.cast<AssetCache>().acquire(prebindStr(args, 0))) {
            case Some(r) => [prebindLoadResultToLua(r)]
            case None => [LuaValue.Nil]
        }
    }
    // ===== 引用计数 =====
    b.method("retain") {
        ref, args => [LuaValue.of(ref.cast<AssetCache>().retain(prebindStr(args, 0)))]
    }
    b.method("refCount") {
        ref, args => [LuaValue.of(ref.cast<AssetCache>().refCount(prebindStr(args, 0)))]
    }
    // ===== 移除 / 回收 =====
    b.method("remove") {
        ref, args =>
            ref.cast<AssetCache>().remove(prebindStr(args, 0))
            []
    }
    b.method("collect") {
        ref, _ => [LuaValue.of(ref.cast<AssetCache>().collect())]
    }
    b.method("collectIfNeeded") {
        ref, args => [LuaValue.of(ref.cast<AssetCache>().collectIfNeeded(interval: prebindInt(args, 0, default: 60)))]
    }
    // ===== release：无参清空整个缓存；带 key 释放一次引用 =====
    b.method("release") {
        ref, args => if (args.size > 0) {
            [LuaValue.of(ref.cast<AssetCache>().release(prebindStr(args, 0)))]
        } else {
            [LuaValue.of(ref.cast<AssetCache>().release())]
        }
    }
    b.install(vm)
}
