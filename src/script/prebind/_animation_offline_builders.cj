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
 * @file[zh-cn] animation_offline_builders 离线构建器（AnimationBuilder / TrackBuilder /
 * SkeletonBuilder / AdditiveAnimationBuilder）与 RawAnimationUtils 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 把离线数据流水线的构建器与静态工具绑定为 Lua 类型
 * @explain[zh-cn] 构建器统一以 invoke(input) 形式返回 Option<T>：Some → 注册为对应 Lua
 * 对象，None → nil。RawAnimationUtils 提供静态方法 retarget / resample /
 * makeAdditiveDelta / concatenate（数组参数走「Lua 表 ↔ 字符串数组」通道）。
 * 跳过：SkeletonBuilder / GltfImportAdapter —— 前者返回 SkeletonData（依赖 SoaTransform
 * 数组初始化），后者依赖 GltfSkinData 等 resource.loader 类型，当前均无可用通道。
 *
 * @file[en] animation_offline_builders  Lua bindings of the offline builders (AnimationBuilder /
 * TrackBuilder / SkeletonBuilder / AdditiveAnimationBuilder) and RawAnimationUtils
 * (three.script.prebind)
 * @brief[en] Binds the builders and static utilities of the offline data pipeline as Lua types
 * @explain[en] Every builder exposes invoke(input) returning Option<T>: Some → registered as
 * the corresponding Lua object, None → nil. RawAnimationUtils provides the static methods
 * retarget / resample / makeAdditiveDelta / concatenate (array arguments go through the
 * "Lua table ↔ string array" channel).
 * Skipped: SkeletonBuilder / GltfImportAdapter — the former returns SkeletonData (needs
 * SoaTransform array initialization) and the latter depends on resource.loader types such as
 * GltfSkinData; neither has a usable channel yet.
 */
package three.script.prebind

import three.animation.offline.*
import three.animation.skeletal.SkeletalAnimationData
import three.animation.skeletal.SkeletalTrackData
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AnimationBuilder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.AnimationBuilder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationBuilder
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.AnimationBuilder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationBuilder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.AnimationBuilder")
    b.constructor {_ => AnimationBuilder()}
    b.method("invoke") {
        ref, args => match (ref.cast<AnimationBuilder>().invoke(prebindAs<RawAnimation>(args, 0))) {
            case Some(data) => [prebindRegister(data, "three.animation.skeletal.SkeletalAnimationData")]
            case None => [LuaValue.Nil]
        }
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 TrackBuilder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.TrackBuilder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of TrackBuilder
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.TrackBuilder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installTrackBuilder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.TrackBuilder")
    b.constructor {_ => TrackBuilder()}
    b.method("invoke") {
        ref, args => match (ref.cast<TrackBuilder>().invoke(prebindAs<RawFloatTrack>(args, 0))) {
            case Some(data) => [prebindRegister(data, "three.animation.skeletal.SkeletalTrackData")]
            case None => [LuaValue.Nil]
        }
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 安装 AdditiveAnimationBuilder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.AdditiveAnimationBuilder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AdditiveAnimationBuilder
 * @param[en] vm The target virtual machine (class table installed at
 *            three.animation.offline.AdditiveAnimationBuilder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAdditiveAnimationBuilder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.AdditiveAnimationBuilder")
    b.constructor {_ => AdditiveAnimationBuilder()}
    b.method("invoke") {
        ref, args => match (ref
            .cast<AdditiveAnimationBuilder>()
            .invoke(prebindAs<RawAnimation>(args, 0), prebindAs<RawAnimation>(args, 1))) {
            case Some(data) => [prebindRegister(data, "three.animation.offline.RawAnimation")]
            case None => [LuaValue.Nil]
        }
    }
    b.install(vm)
}

/**
 * @brief[zh-cn] 读取 Lua 数组参数为字符串数组
 * @param[zh-cn] vm 目标虚拟机（Lua 表参数需经此读取）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] 字符串数组
 *
 * @brief[en] Reads a Lua array argument as a string array
 * @param[en] vm The target virtual machine (needed to read Lua table arguments)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] The string array
 */
private func _prebindStrArray(vm: LuaVM, args: Array<LuaValue>, idx: Int64): Array<String> {
    let elems = prebindArray(vm, args, idx)
    let n = elems.size
    var out = Array<String>(n, {_ => ""})
    for (i in 0..n) {
        out[i] = elems[i].stringValue()
    }
    return out
}

/**
 * @brief[zh-cn] 安装 RawAnimationUtils 的 Lua 绑定（纯静态类，无构造器）
 * @param[zh-cn] vm 目标虚拟机（命名空间表安装到 three.animation.offline.RawAnimationUtils）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawAnimationUtils (a pure static class; no constructor)
 * @param[en] vm The target virtual machine (namespace table installed at
 *            three.animation.offline.RawAnimationUtils)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawAnimationUtils(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawAnimationUtils")
    b.staticMethod("retarget") {
        args => [
            prebindRegister(
                RawAnimationUtils.retarget(
                    prebindAs<RawAnimation>(args, 0),
                    _prebindStrArray(vm, args, 1),
                    _prebindStrArray(vm, args, 2)
                ),
                "three.animation.offline.RawAnimation"
            )
        ]
    }
    b.staticMethod("resample") {
        args => [
            prebindRegister(
                RawAnimationUtils.resample(
                    prebindAs<RawAnimation>(args, 0),
                    Float32(prebindNum(args, 1, default: 30.0))
                ),
                "three.animation.offline.RawAnimation"
            )
        ]
    }
    b.staticMethod("makeAdditiveDelta") {
        args => match (RawAnimationUtils.makeAdditiveDelta(prebindAs<RawAnimation>(args, 0),
            prebindAs<RawAnimation>(args, 1))) {
            case Some(delta) => [prebindRegister(delta, "three.animation.offline.RawAnimation")]
            case None => [LuaValue.Nil]
        }
    }
    b.staticMethod("concatenate") {
        args => match (RawAnimationUtils.concatenate(prebindAs<RawAnimation>(args, 0), prebindAs<RawAnimation>(args, 1))) {
            case Some(joined) => [prebindRegister(joined, "three.animation.offline.RawAnimation")]
            case None => [LuaValue.Nil]
        }
    }
    b.install(vm)
}
