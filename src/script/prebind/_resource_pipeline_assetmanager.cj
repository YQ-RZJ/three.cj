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
 * @file[zh-cn] resource_pipeline_assetmanager 资源管理器的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.pipeline.AssetManager 绑定为 Lua 类型
 * three.resource.pipeline.AssetManager
 * @explain[zh-cn] 绑定无参构造、全局单例 shared（以静态方法 getShared 暴露）、只读属性
 * cache/pendingCount、异步加载 loadBytes/loadText/loadFromBundle、分帧派发 update 与
 * 静态 pumpShared。loadBytes 签名映射为
 * loadBytes(url, onLoad, [onError], [storeCache])；loadText 为
 * loadText(url, onLoad, [onError])；loadFromBundle 为
 * loadFromBundle(bundle, name, onLoad, [onError])。
 * Lua 回调经 LuaCallback 包装并在 update()（Lua 线程）派发：onLoad(ILoadResult) 收到按
 * 运行时具体类型注册的加载结果（StringLoadResult / BytesLoadResult / ClipsLoadResult，
 * 未知实现回退为 three.core._interfaces.ILoadResult），loadText 的 onLoad 收到字符串，
 * onError 收到错误信息字符串。回调内部异常被吞掉（不跨 Lua 边界传播）；
 * 入参缺失/非函数时该回调被忽略。ILoadResult 为无成员的标记接口，接口本身不绑定。
 * loadFromBundle 的 bundle 参数不是已注册的 AssetBundle 时静默返回（不抛异常）。
 * 跳过项：无（公开成员均已绑定；私有完成队列与去重集合不暴露）。
 *
 * @file[en] resource_pipeline_assetmanager  Lua binding of the asset manager
 * (three.script.prebind)
 * @brief[en] Binds three.resource.pipeline.AssetManager as the Lua type
 * three.resource.pipeline.AssetManager
 * @explain[en] Binds the parameterless constructor, the global shared instance (exposed as the
 * static method getShared), the read-only properties cache/pendingCount, the asynchronous
 * loaders loadBytes/loadText/loadFromBundle, the frame-spread dispatcher update and the static
 * pumpShared. Signatures map to loadBytes(url, onLoad, [onError], [storeCache]),
 * loadText(url, onLoad, [onError]) and loadFromBundle(bundle, name, onLoad, [onError]).
 * Lua callbacks are wrapped via LuaCallback and dispatched from update() (the Lua thread):
 * onLoad(ILoadResult) receives the load result registered by its runtime concrete type
 * (StringLoadResult / BytesLoadResult / ClipsLoadResult, unknown implementations fall back to
 * three.core._interfaces.ILoadResult), loadText's onLoad receives a string and onError receives
 * the error message string. Exceptions thrown by a callback are swallowed (never cross the Lua
 * boundary); a missing / non-function argument simply leaves that callback unused. ILoadResult
 * is a member-less marker interface and interfaces are not bound.
 * When loadFromBundle's bundle argument is not a registered AssetBundle the call silently
 * returns (never throws).
 * Skipped members: none (every public member is bound; the private completion queue and
 * in-flight set stay hidden).
 */
package three.script.prebind

import three.resource.pipeline.*
import three.core._interfaces.ILoadResult
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 调用 Lua 加载成功回调（参数为已注册的加载结果对象）
 * @explain[zh-cn] 非函数 / nil 入参直接忽略；回调自身抛出的异常被吞掉，不跨 Lua 边界传播。
 * @param[zh-cn] vm 所属虚拟机
 * @param[zh-cn] funcValue 回调值（Lua 函数或 nil）
 * @param[zh-cn] res 加载结果
 *
 * @brief[en] Invokes a Lua load-success callback with the registered load-result object
 * @explain[en] Non-function / nil arguments are ignored; exceptions raised by the callback are
 * swallowed instead of crossing the Lua boundary.
 * @param[en] vm The owning virtual machine
 * @param[en] funcValue The callback value (a Lua function or nil)
 * @param[en] res The load result
 */
internal func _prebindInvokeLoadCallback(vm: LuaVM, funcValue: LuaValue, res: ILoadResult): Unit {
    if (let Some(cb) <- LuaCallback.fromValue(vm, funcValue)) {
        try {
            cb.call(args: [prebindLoadResultToLua(res)])
        } catch (_: Exception) {
        }
    }
}

/**
 * @brief[zh-cn] 调用 Lua 字符串回调（成功文本 / 错误信息）
 * @explain[zh-cn] 非函数 / nil 入参直接忽略；回调自身抛出的异常被吞掉，不跨 Lua 边界传播。
 * @param[zh-cn] vm 所属虚拟机
 * @param[zh-cn] funcValue 回调值（Lua 函数或 nil）
 * @param[zh-cn] text 字符串参数（加载文本或错误信息）
 *
 * @brief[en] Invokes a Lua string callback (loaded text / error message)
 * @explain[en] Non-function / nil arguments are ignored; exceptions raised by the callback are
 * swallowed instead of crossing the Lua boundary.
 * @param[en] vm The owning virtual machine
 * @param[en] funcValue The callback value (a Lua function or nil)
 * @param[en] text The string argument (loaded text or error message)
 */
internal func _prebindInvokeStringCallback(vm: LuaVM, funcValue: LuaValue, text: String): Unit {
    if (let Some(cb) <- LuaCallback.fromValue(vm, funcValue)) {
        try {
            cb.call(args: [LuaValue.of(text)])
        } catch (_: Exception) {
        }
    }
}

/**
 * @brief[zh-cn] 安装 AssetManager 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.pipeline.AssetManager）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AssetManager
 * @param[en] vm The target virtual machine (class table installed at three.resource.pipeline.AssetManager)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAssetManager(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.pipeline.AssetManager")
    // ===== 构造 =====
    b.constructor {_ => AssetManager()}
    // ===== 全局共享实例（静态 let，以 getShared 暴露） =====
    b.staticMethod("getShared") {
        _ => [prebindRegister(AssetManager.shared, "three.resource.pipeline.AssetManager")]
    }
    // ===== 属性（只读） =====
    b.property("cache", getter: Some({
        ref => prebindRegister(ref.cast<AssetManager>().cache, "three.resource.pipeline.AssetCache")
    }))
    b.property("pendingCount", getter: Some({ref => LuaValue.of(ref.cast<AssetManager>().pendingCount)}))
    // ===== 异步加载字节（回调经 update() 派发） =====
    b.method("loadBytes") {
        ref, args =>
            let onLoad = if (args.size > 1) {
                args[1]
            } else {
                LuaValue.Nil
            }
            let onError = if (args.size > 2) {
                args[2]
            } else {
                LuaValue.Nil
            }
            ref
                .cast<AssetManager>()
                .loadBytes(prebindStr(args, 0), {res: ILoadResult => _prebindInvokeLoadCallback(vm, onLoad, res)},
                    onError: {msg: String => _prebindInvokeStringCallback(vm, onError, msg)},
                    storeCache: prebindBool(args, 3))
            []
    }
    // ===== 异步加载文本 =====
    b.method("loadText") {
        ref, args =>
            let onLoad = if (args.size > 1) {
                args[1]
            } else {
                LuaValue.Nil
            }
            let onError = if (args.size > 2) {
                args[2]
            } else {
                LuaValue.Nil
            }
            ref
                .cast<AssetManager>()
                .loadText(prebindStr(args, 0), {text: String => _prebindInvokeStringCallback(vm, onLoad, text)},
                    onError: {msg: String => _prebindInvokeStringCallback(vm, onError, msg)})
            []
    }
    // ===== 从资源包内分发条目 =====
    b.method("loadFromBundle") {
        ref, args =>
            let onLoad = if (args.size > 2) {
                args[2]
            } else {
                LuaValue.Nil
            }
            let onError = if (args.size > 3) {
                args[3]
            } else {
                LuaValue.Nil
            }
            try {
                ref
                    .cast<AssetManager>()
                    .loadFromBundle(prebindAs<AssetBundle>(args, 0), prebindStr(args, 1),
                        {res: ILoadResult => _prebindInvokeLoadCallback(vm, onLoad, res)},
                        onError: {msg: String => _prebindInvokeStringCallback(vm, onError, msg)})
            } catch (_: Exception) {
                // bundle 参数不是已注册的 AssetBundle：忽略本次调用
            }
            []
    }
    // ===== 每帧派发 =====
    b.method("update") {
        ref, args => [LuaValue.of(
            ref
                .cast<AssetManager>()
                .update(maxPerFrame: prebindInt(args, 0, default: 4), budgetMs: prebindNum(args, 1, default: 2.0)))]
    }
    // ===== 泵全局共享实例 =====
    b.staticMethod("pumpShared") {
        _ =>
            AssetManager.pumpShared()
            []
    }
    b.install(vm)
}
