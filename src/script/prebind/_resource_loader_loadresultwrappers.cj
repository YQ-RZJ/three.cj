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
 * @file[zh-cn] resource_loader_loadresultwrappers 加载结果包装类的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader 的 StringLoadResult / BytesLoadResult /
 * ClipsLoadResult 绑定为 Lua 类型
 * @explain[zh-cn] 三个包装类均绑定构造（value）与只读属性 value：string、字节数组
 * （Lua 数值数组，元素 0~255）、AnimationClip 对象数组（按真实类名注册）。
 * 另提供内部工具 prebindLoadResultClassName / prebindCallLoadResult /
 * prebindCallProgress / prebindCallError，供各加载器绑定把 ILoadResult 回传给
 * Lua 回调（回调异常被吞掉，不穿出绑定方法）。ILoadResult 接口本身不绑定。
 *
 * @file[en] resource_loader_loadresultwrappers  Lua bindings of the load-result wrappers
 * (three.script.prebind)
 * @brief[en] Binds three.resource.loader's StringLoadResult / BytesLoadResult /
 * ClipsLoadResult as Lua types
 * @explain[en] All three wrappers bind their constructor (value) and the read-only value
 * property: string, byte array (Lua number array with elements 0..255), and AnimationClip
 * object array (registered under real class names). Internal helpers
 * prebindLoadResultClassName / prebindCallLoadResult / prebindCallProgress /
 * prebindCallError are provided so loader bindings can deliver ILoadResult to Lua
 * callbacks (callback errors are swallowed and never escape the binding). The ILoadResult
 * interface itself is not bound.
 */
package three.script.prebind

import std.collection.*
import three.core._interfaces.ILoadResult
import three.resource.loader.*
import three.animation.clip.AnimationClip
import three.audio.source.AudioBuffer
import three.renderers.materials.Material
import three.renderers.textures.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 按加载结果的真实运行时类型给出其 Lua 绑定类全名
 * @param[zh-cn] r 加载结果（ILoadResult）
 * @return[zh-cn] 已绑定类的 Lua 路径；无对应绑定时返回 None
 *
 * @brief[en] Maps a load result's real runtime type to its full Lua bound class name
 * @param[en] r The load result (ILoadResult)
 * @return[en] The Lua path of the bound class, or None when unbound
 */
internal func prebindLoadResultClassName(r: ILoadResult): Option<String> {
    match (r) {
        case _: StringLoadResult => Some("three.resource.loader.StringLoadResult")
        case _: BytesLoadResult => Some("three.resource.loader.BytesLoadResult")
        case _: ClipsLoadResult => Some("three.resource.loader.ClipsLoadResult")
        case _: CubeTexture => Some("three.renderers.textures.CubeTexture")
        case _: Texture => Some("three.renderers.textures.Texture")
        case _: Source => Some("three.renderers.textures.Source")
        case _: Material => Some("three.renderers.materials.Material")
        case _: AudioBuffer => Some("three.audio.source.AudioBuffer")
        case _: AnimationClip => Some("three.animation.clip.AnimationClip")
        case _ => None
    }
}

/**
 * @brief[zh-cn] 调用 Lua 的 onLoad 回调并传入已注册的加载结果
 * @param[zh-cn] cb 可选 Lua 回调（None 时无操作）
 * @param[zh-cn] r 加载结果（按真实类型注册；未绑定的实现回退为 ILoadResult 注册）
 *
 * @brief[en] Invokes the Lua onLoad callback with the registered load result
 * @param[en] cb The optional Lua callback (no-op when None)
 * @param[en] r The load result (registered by real type; unbound implementations fall back to ILoadResult)
 */
internal func prebindCallLoadResult(cb: Option<LuaCallback>, r: ILoadResult): Unit {
    if (let Some(c) <- cb) {
        let arg = match (prebindLoadResultClassName(r)) {
            case Some(name) => prebindRegister(r, name)
            case None => prebindLoadResultToLua(r)
        }
        try {
            c.call(args: [arg])
        } catch (_: Exception) {
        }
    }
}

/**
 * @brief[zh-cn] 调用 Lua 的 onProgress 回调（异常被吞掉）
 * @param[zh-cn] cb 可选 Lua 回调（None 时无操作）
 * @param[zh-cn] p 进度值（字节数）
 *
 * @brief[en] Invokes the Lua onProgress callback (errors swallowed)
 * @param[en] cb The optional Lua callback (no-op when None)
 * @param[en] p The progress value (bytes)
 */
internal func prebindCallProgress(cb: Option<LuaCallback>, p: Int64): Unit {
    if (let Some(c) <- cb) {
        try {
            c.call(args: [LuaValue.of(p)])
        } catch (_: Exception) {
        }
    }
}

/**
 * @brief[zh-cn] 调用 Lua 的 onError 回调（异常被吞掉）
 * @param[zh-cn] cb 可选 Lua 回调（None 时无操作）
 * @param[zh-cn] msg 错误消息
 *
 * @brief[en] Invokes the Lua onError callback (errors swallowed)
 * @param[en] cb The optional Lua callback (no-op when None)
 * @param[en] msg The error message
 */
internal func prebindCallError(cb: Option<LuaCallback>, msg: String): Unit {
    if (let Some(c) <- cb) {
        try {
            c.call(args: [LuaValue.of(msg)])
        } catch (_: Exception) {
        }
    }
}

/**
 * @brief[zh-cn] 安装 StringLoadResult 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.StringLoadResult）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of StringLoadResult
 * @param[en] vm The target virtual machine (class table at three.resource.loader.StringLoadResult)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installStringLoadResult(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.StringLoadResult")
    // ===== 构造 =====
    b.constructor {args => StringLoadResult(prebindStr(args, 0))}
    // ===== 属性（只读） =====
    b.property("value", getter: Some({ref => LuaValue.of(ref.cast<StringLoadResult>().value)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 BytesLoadResult 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.BytesLoadResult）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of BytesLoadResult
 * @param[en] vm The target virtual machine (class table at three.resource.loader.BytesLoadResult)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installBytesLoadResult(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.BytesLoadResult")
    // ===== 构造（字节来自 Lua 数值数组，取低 8 位） =====
    b.constructor {args => BytesLoadResult(prebindBytes(vm, args, 0))}
    // ===== 属性（只读，按 0~255 整数数组回传） =====
    b.property("value", getter: Some({ref => prebindBytesToLua(ref.cast<BytesLoadResult>().value)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 ClipsLoadResult 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.ClipsLoadResult）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of ClipsLoadResult
 * @param[en] vm The target virtual machine (class table at three.resource.loader.ClipsLoadResult)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installClipsLoadResult(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.ClipsLoadResult")
    // ===== 构造（AnimationClip 对象数组） =====
    b.constructor {args => ClipsLoadResult(prebindObjList<AnimationClip>(vm, args, 0))}
    // ===== 属性（只读，对象数组通道） =====
    b.property(
        "value",
        getter: Some(
            {
                ref =>
                    let clips = ref.cast<ClipsLoadResult>().value
                    let arr = Array<LuaValue>(clips.size, {
                        i => prebindRegister(clips[i], "three.animation.clip.AnimationClip")
                    })
                    LuaValue.Array(arr)
            }
        )
    )
    b.install(vm)
}
