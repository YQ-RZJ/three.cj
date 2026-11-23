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
 * @file[zh-cn] animation_blend_animationmixer 动画混合器 AnimationMixer 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.blend.AnimationMixer 绑定为 Lua 类型
 * three.animation.blend.AnimationMixer
 * @explain[zh-cn] 覆盖构造（root: Object3D）、属性 time / timeScale、动作调度
 * （clipAction / existingAction / stopAllAction）、时间推进（update / setTime）、
 * 根对象查询（getRoot）与缓存清理（uncacheClip / uncacheRoot / uncacheAction）。
 * clipAction / existingAction 的返回值（AnimationAction）与新对象注册通道打通；
 * getRoot 返回其内部 root 对象并注册为 three.scene.objects.Object3D 的 Lua 对象
 * （Object3D 绑定尚未建立时该 userdata 仍可持有与回传，只是 Lua 侧无成员可调）。
 * 跳过：stats（HashMap<String, HashMap<String, ()->Int64>>）、registerSkeletalData /
 * bindSceneSkeleton / updateSkeletal（涉及 SkeletalAnimationData / Skeleton / SkeletonData，
 * 属骨骼管线内部类型，暂不绑定）。
 *
 * @file[en] animation_blend_animationmixer  Lua binding of the animation mixer AnimationMixer
 * (three.script.prebind)
 * @brief[en] Binds three.animation.blend.AnimationMixer as the Lua type
 * three.animation.blend.AnimationMixer
 * @explain[en] Covers construction (root: Object3D), the time / timeScale properties, action
 * scheduling (clipAction / existingAction / stopAllAction), time advancement (update /
 * setTime), root lookup (getRoot) and cache eviction (uncacheClip / uncacheRoot /
 * uncacheAction). The AnimationAction values returned by clipAction / existingAction are
 * registered as new objects; getRoot registers its internal root object as a
 * three.scene.objects.Object3D Lua object (before that binding exists the userdata still
 * round-trips, it just exposes no members on the Lua side).
 * Skipped: stats (HashMap<String, HashMap<String, ()->Int64>>) and registerSkeletalData /
 * bindSceneSkeleton / updateSkeletal (they involve SkeletalAnimationData / Skeleton /
 * SkeletonData, internal skeletal-pipeline types, not bound for now).
 */
package three.script.prebind

import three.animation.blend.AnimationMixer
import three.animation.blend.AnimationAction
import three.animation._interfaces.IAnimationClip
import three.scene.objects.Object3D
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 读取可选的对象参数（缺省或 nil → None）
 * @param[zh-cn] args 请求参数
 * @param[zh-cn] idx 参数下标（0 基）
 * @return[zh-cn] Some(Object3D) 或 None
 *
 * @brief[en] Reads an optional object argument (absent or nil → None)
 * @param[en] args The request arguments
 * @param[en] idx The 0-based argument index
 * @return[en] Some(Object3D) or None
 */
private func _prebindMixerOptRoot(args: Array<LuaValue>, idx: Int64): Option<Object3D> {
    if (args.size > idx && !args[idx].isNil) {
        return Some(prebindAs<Object3D>(args, idx))
    }
    return None
}

/**
 * @brief[zh-cn] 安装 AnimationMixer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.blend.AnimationMixer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationMixer
 * @param[en] vm The target virtual machine (class table installed at three.animation.blend.AnimationMixer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationMixer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.blend.AnimationMixer")
    // ===== 构造（root 对象） =====
    b.constructor {
        args => AnimationMixer(prebindAs<Object3D>(args, 0))
    }
    // ===== 属性 =====
    b.property("time", getter: Some({ref => LuaValue.of(ref.cast<AnimationMixer>().time)}),
        setter: Some({ref, v => ref.cast<AnimationMixer>().time = v.numberValue()}))
    b.property("timeScale", getter: Some({ref => LuaValue.of(ref.cast<AnimationMixer>().timeScale)}),
        setter: Some({ref, v => ref.cast<AnimationMixer>().timeScale = v.numberValue()}))
    // ===== 动作调度 =====
    b.method("clipAction") {
        ref, args =>
            let optionalRoot = _prebindMixerOptRoot(args, 1)
            let action = ref
                .cast<AnimationMixer>()
                .clipAction(prebindAs<IAnimationClip>(args, 0), optionalRoot: optionalRoot,
                    blendMode: prebindInt(args, 2, default: -1))
            [prebindRegister(action, "three.animation.blend.AnimationAction")]
    }
    b.method("existingAction") {
        ref, args =>
            let optionalRoot = _prebindMixerOptRoot(args, 1)
            match (ref
                .cast<AnimationMixer>()
                .existingAction(prebindAs<IAnimationClip>(args, 0), optionalRoot: optionalRoot)) {
                case Some(a) => [prebindRegister(a, "three.animation.blend.AnimationAction")]
                case None => [LuaValue.Nil]
            }
    }
    b.method("stopAllAction") {
        ref, _ =>
            ref.cast<AnimationMixer>().stopAllAction()
            [LuaValue.Object(ref.id)]
    }
    // ===== 时间推进（链式返回自身） =====
    b.method("update") {
        ref, args =>
            ref.cast<AnimationMixer>().update(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setTime") {
        ref, args =>
            ref.cast<AnimationMixer>().setTime(prebindNum(args, 0))
            [LuaValue.Object(ref.id)]
    }
    // ===== 根对象 =====
    b.method("getRoot") {
        ref, _ => [prebindRegister(ref.cast<AnimationMixer>().getRoot(), "three.scene.objects.Object3D")]
    }
    // ===== 缓存清理 =====
    b.method("uncacheClip") {
        ref, args =>
            ref.cast<AnimationMixer>().uncacheClip(prebindAs<IAnimationClip>(args, 0))
            Array<LuaValue>()
    }
    b.method("uncacheRoot") {
        ref, args =>
            ref.cast<AnimationMixer>().uncacheRoot(prebindAs<Object3D>(args, 0))
            Array<LuaValue>()
    }
    b.method("uncacheAction") {
        ref, args =>
            let optionalRoot = _prebindMixerOptRoot(args, 1)
            ref.cast<AnimationMixer>().uncacheAction(prebindAs<IAnimationClip>(args, 0), optionalRoot: optionalRoot)
            Array<LuaValue>()
    }
    b.install(vm)
}
