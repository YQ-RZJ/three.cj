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
 * @file[zh-cn] resource_loader_gltftypes GltfTypes 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.resource.loader.GltfAnimationChannel / GltfAnimationSampler /
 * GltfAnimationData / GltfSkinData 绑定为 Lua 类型
 * @explain[zh-cn] 四个类型均为 public let 字段的只读数据类：绑定全参构造与只读属性；
 * Int 统一按 Int64 呈现，Array<Float64> / Array<Int> / Array<Array<Float64>> 转为 Lua 数组
 * （逆绑定矩阵为二维数组），GltfAnimationChannel / GltfAnimationSampler 数组元素按
 * three.resource.loader.<Type> 注册。无跳过成员。
 *
 * @file[en] resource_loader_gltftypes  Lua binding of GltfTypes (three.script.prebind)
 * @brief[en] Binds three.resource.loader.GltfAnimationChannel / GltfAnimationSampler /
 * GltfAnimationData / GltfSkinData as Lua types
 * @explain[en] All four types are read-only data classes with public let fields: the full
 * constructors and read-only properties are bound; Int is exposed as Int64, and Array<Float64> /
 * Array<Int> / Array<Array<Float64>> become Lua arrays (inverse bind matrices are nested
 * arrays), while GltfAnimationChannel / GltfAnimationSampler arrays register their elements as
 * three.resource.loader.<Type>. No members are skipped.
 */
package three.script.prebind

import three.resource.loader.*
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/// 将 AnimationChannel 数组转为 Lua 对象数组
private func _prebindGltfChannelsToLua(items: Array<GltfAnimationChannel>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.resource.loader.GltfAnimationChannel")
    }
    return LuaValue.Array(out)
}

/// 将 AnimationSampler 数组转为 Lua 对象数组
private func _prebindGltfSamplersToLua(items: Array<GltfAnimationSampler>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = prebindRegister(items[i], "three.resource.loader.GltfAnimationSampler")
    }
    return LuaValue.Array(out)
}

/// 将二维浮点数组转为嵌套 Lua 数值数组
private func _prebindGltfMatricesToLua(mats: Array<Array<Float64>>): LuaValue {
    let n = mats.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        let row = mats[i]
        var luaRow = Array<LuaValue>(row.size, {_ => LuaValue.Nil})
        for (j in 0..row.size) {
            luaRow[j] = LuaValue.of(row[j])
        }
        out[i] = LuaValue.Array(luaRow)
    }
    return LuaValue.Array(out)
}

/// 将 Int 数组转为 Lua 数值数组
private func _prebindGltfIntsToLua(items: Array<Int>): LuaValue {
    let n = items.size
    var out = Array<LuaValue>(n, {_ => LuaValue.Nil})
    for (i in 0..n) {
        out[i] = LuaValue.of(Int64(items[i]))
    }
    return LuaValue.Array(out)
}

/// 读取 Lua 对象数组为 AnimationChannel 数组
private func _prebindGltfReadChannels(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<GltfAnimationChannel> {
    let list = ArrayList<GltfAnimationChannel>()
    for (elem in prebindArray(vm, args, idx)) {
        if (elem.isObject) {
            list.add(LuaObjectRegistry.getAs<GltfAnimationChannel>(elem.objectId()))
        }
    }
    return Array<GltfAnimationChannel>(list.size, {i => list[i]})
}

/// 读取 Lua 对象数组为 AnimationSampler 数组
private func _prebindGltfReadSamplers(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<GltfAnimationSampler> {
    let list = ArrayList<GltfAnimationSampler>()
    for (elem in prebindArray(vm, args, idx)) {
        if (elem.isObject) {
            list.add(LuaObjectRegistry.getAs<GltfAnimationSampler>(elem.objectId()))
        }
    }
    return Array<GltfAnimationSampler>(list.size, {i => list[i]})
}

/// 读取 Lua 二维数值数组为 Array<Array<Float64>>
private func _prebindGltfReadMatrices(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Array<Float64>> {
    let rows = prebindArray(vm, args, idx)
    var out = Array<Array<Float64>>(rows.size, {_ => Array<Float64>()})
    for (i in 0..rows.size) {
        out[i] = prebindFloatArray(vm, [rows[i]], 0)
    }
    return out
}

/// 读取 Lua 数值数组为 Array<Int64>
private func _prebindGltfReadInts(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<Int64> {
    let elems = prebindArray(vm, args, idx)
    var out = Array<Int64>(elems.size, {_ => 0})
    for (i in 0..elems.size) {
        out[i] = elems[i].intValue()
    }
    return out
}

/**
 * @brief[zh-cn] 安装 GltfAnimationChannel 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.GltfAnimationChannel）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GltfAnimationChannel
 * @param[en] vm The target virtual machine (class table installed at
 *            three.resource.loader.GltfAnimationChannel)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGltfAnimationChannel(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.GltfAnimationChannel")
    // ===== 构造：new(sampler, targetNode, targetPath) =====
    b.constructor {
        args => GltfAnimationChannel(Int64(prebindInt(args, 0)), Int64(prebindInt(args, 1)), prebindStr(args, 2))
    }
    // ===== 只读属性 =====
    b.property("sampler", getter: Some({ref => LuaValue.of(Int64(ref.cast<GltfAnimationChannel>().sampler))}))
    b.property("targetNode", getter: Some({ref => LuaValue.of(Int64(ref.cast<GltfAnimationChannel>().targetNode))}))
    b.property("targetPath", getter: Some({ref => LuaValue.of(ref.cast<GltfAnimationChannel>().targetPath)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GltfAnimationSampler 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.GltfAnimationSampler）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GltfAnimationSampler
 * @param[en] vm The target virtual machine (class table installed at
 *            three.resource.loader.GltfAnimationSampler)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGltfAnimationSampler(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.GltfAnimationSampler")
    // ===== 构造：new(input, output, interpolation) =====
    b.constructor {
        args => GltfAnimationSampler(Int64(prebindInt(args, 0)), Int64(prebindInt(args, 1)), prebindStr(args, 2))
    }
    // ===== 只读属性 =====
    b.property("input", getter: Some({ref => LuaValue.of(Int64(ref.cast<GltfAnimationSampler>().input))}))
    b.property("output", getter: Some({ref => LuaValue.of(Int64(ref.cast<GltfAnimationSampler>().output))}))
    b.property("interpolation", getter: Some({ref => LuaValue.of(ref.cast<GltfAnimationSampler>().interpolation)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GltfAnimationData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.GltfAnimationData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GltfAnimationData
 * @param[en] vm The target virtual machine (class table installed at
 *            three.resource.loader.GltfAnimationData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGltfAnimationData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.GltfAnimationData")
    // ===== 构造：new(name, channels, samplers) =====
    b.constructor {
        args => GltfAnimationData(prebindStr(args, 0), _prebindGltfReadChannels(vm, args, 1),
            _prebindGltfReadSamplers(vm, args, 2))
    }
    // ===== 只读属性 =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<GltfAnimationData>().name)}))
    b.property("channels", getter: Some({ref => _prebindGltfChannelsToLua(ref.cast<GltfAnimationData>().channels)}))
    b.property("samplers", getter: Some({ref => _prebindGltfSamplersToLua(ref.cast<GltfAnimationData>().samplers)}))
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 GltfSkinData 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.resource.loader.GltfSkinData）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of GltfSkinData
 * @param[en] vm The target virtual machine (class table installed at
 *            three.resource.loader.GltfSkinData)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installGltfSkinData(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.resource.loader.GltfSkinData")
    // ===== 构造：new(name, inverseBindMatrices, skeletonRoot, joints) =====
    b.constructor {
        args => GltfSkinData(prebindStr(args, 0), _prebindGltfReadMatrices(vm, args, 1), Int64(prebindInt(args, 2)),
            _prebindGltfReadInts(vm, args, 3))
    }
    // ===== 只读属性 =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<GltfSkinData>().name)}))
    b.property("inverseBindMatrices",
        getter: Some({ref => _prebindGltfMatricesToLua(ref.cast<GltfSkinData>().inverseBindMatrices)}))
    b.property("skeletonRoot", getter: Some({ref => LuaValue.of(Int64(ref.cast<GltfSkinData>().skeletonRoot))}))
    b.property("joints", getter: Some({ref => _prebindGltfIntsToLua(ref.cast<GltfSkinData>().joints)}))
    b.install(vm)
}
