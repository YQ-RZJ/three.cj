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
 * @file[zh-cn] renderers_postprocessing_unrealbloompass UnrealBloom pass 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.renderers.postprocessing.UnrealBloomPass 绑定为 Lua 类型
 * @explain[zh-cn] 构造 new([strength[, threshold[, radius]]])（默认 1.0 / 1.0 / 0.4），绑定
 * strength / threshold / radius 属性、只读 nMips / kernelSizeArray / bloomFactors 属性与常量
 * BLOOM_VIEW_ID_BASE（按函数取值），并复用 _prebindPpPassMembers 安装 Pass 基类成员
 * （含 setSize / release）。
 * 使用前提：亮度提取 RT 与 5 级金字塔 RT 的创建/销毁、逐级模糊与合成提交都触达 bgfx，必须由引擎
 * 完成 bgfx 初始化后才会真正执行。构造与属性读写可安全调用。
 * 跳过成员及原因：
 * - render(...)：参数含 FrameBufferHandle，由 composer 链驱动；
 * - 私有 RT/纹理/program 句柄、金字塔层级缓存（BloomMipLevel）与 _createRTs / _blur 等为内部实现。
 *
 * @file[en] renderers_postprocessing_unrealbloompass  Lua binding of the UnrealBloom pass
 * (three.script.prebind)
 * @brief[en] Binds three.renderers.postprocessing.UnrealBloomPass as a Lua type
 * @explain[en] Constructor new([strength[, threshold[, radius]]]) (defaults 1.0 / 1.0 / 0.4); binds
 * the strength / threshold / radius properties, the read-only nMips / kernelSizeArray /
 * bloomFactors properties and the BLOOM_VIEW_ID_BASE constant (read as a function), and reuses
 * _prebindPpPassMembers for the Pass base members (including setSize / release).
 * Precondition: creation/destruction of the bright RT and 5-level pyramid RTs plus the per-level
 * blur and composite submissions reach bgfx and only take effect after bgfx initialization.
 * Construction and property access are safe.
 * Skipped members and reasons:
 * - render(...): FrameBufferHandle parameters, driven by the composer chain;
 * - the private RT/texture/program handles, pyramid level cache (BloomMipLevel) and
 *   _createRTs / _blur are implementation details.
 */
package three.script.prebind

import three.renderers.postprocessing.*
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 将 Int64 原生数组转为 Lua 数值数组
 * @param[zh-cn] src 源数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a native Int64 array into a Lua number array
 * @param[en] src The source array
 * @return[en] The Lua array value
 */
internal func _prebindPpI64ArrayToLua(src: Array<Int64>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(src[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 将 Float64 原生数组转为 Lua 数值数组
 * @param[zh-cn] src 源数组
 * @return[zh-cn] Lua 数组值
 *
 * @brief[en] Converts a native Float64 array into a Lua number array
 * @param[en] src The source array
 * @return[en] The Lua array value
 */
internal func _prebindPpF64ArrayToLua(src: Array<Float64>): LuaValue {
    let n = src.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(src[i])
    }
    return LuaValue.Array(out)
}

/**
 * @brief[zh-cn] 安装 UnrealBloomPass 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.renderers.postprocessing.UnrealBloomPass）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of UnrealBloomPass
 * @param[en] vm The target virtual machine (class table at
 * three.renderers.postprocessing.UnrealBloomPass)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installUnrealBloomPass(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.renderers.postprocessing.UnrealBloomPass")
    b.constructor {
        args => UnrealBloomPass(strength: prebindNum(args, 0, default: 1.0), threshold: prebindNum(args, 1, default: 1.0),
            radius: prebindNum(args, 2, default: 0.4))
    }
    _prebindPpPassMembers(b, vm)
    b.property("strength", getter: Some({ref => LuaValue.of(ref.cast<UnrealBloomPass>().strength)}),
        setter: Some({ref, v => ref.cast<UnrealBloomPass>().strength = v.numberValue()}))
    b.property("threshold", getter: Some({ref => LuaValue.of(ref.cast<UnrealBloomPass>().threshold)}),
        setter: Some({ref, v => ref.cast<UnrealBloomPass>().threshold = v.numberValue()}))
    b.property("radius", getter: Some({ref => LuaValue.of(ref.cast<UnrealBloomPass>().radius)}),
        setter: Some({ref, v => ref.cast<UnrealBloomPass>().radius = v.numberValue()}))
    b.property("nMips", getter: Some({ref => LuaValue.of(ref.cast<UnrealBloomPass>().nMips)}))
    b.property("kernelSizeArray", getter: Some({
        ref => _prebindPpI64ArrayToLua(ref.cast<UnrealBloomPass>().kernelSizeArray)
    }))
    b.property("bloomFactors", getter: Some({
        ref => _prebindPpF64ArrayToLua(ref.cast<UnrealBloomPass>().bloomFactors)
    }))
    b.staticMethod("BLOOM_VIEW_ID_BASE") {
        _ => [LuaValue.of(Int64(UnrealBloomPass.BLOOM_VIEW_ID_BASE))]
    }
    b.install(vm)
}
