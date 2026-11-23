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
 * @file[zh-cn] animation_clip_animationclip 动画剪辑 AnimationClip 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.clip.AnimationClip 绑定为 Lua 类型
 * three.animation.clip.AnimationClip
 * @explain[zh-cn] 覆盖构造（name/duration/tracks/blendMode 全可选）与全部可绑定成员：
 * 属性 name/duration/tracks/blendMode/uuid；方法 resetDuration/trim/validate/
 * optimize/clone。tracks 走「对象数组通道」：读取时按每个轨道的真实运行时类型注册为
 * 对应的 Lua 类表，写入时按 IKeyframeTrack 接口取回。跳过（缺通道或无对应语义）：
 * userData / skeletalData（HashMap / Option<SkeletalAnimationData>）、
 * static parse(HashMap) / CreateFromMorphTargetSequence(Array<Any>) /
 * CreateClipsFromMorphTargetSequences(Array<Any>) / findByName(Any)。
 *
 * @file[en] animation_clip_animationclip  Lua binding of the animation clip AnimationClip
 * (three.script.prebind)
 * @brief[en] Binds three.animation.clip.AnimationClip as the Lua type
 * three.animation.clip.AnimationClip
 * @explain[en] Covers construction (all of name/duration/tracks/blendMode optional) and every
 * bindable member: the properties name/duration/tracks/blendMode/uuid and the methods
 * resetDuration/trim/validate/optimize/clone. tracks uses the object-array channel: reads
 * register each track under its real runtime type's Lua class table, writes fetch it back as
 * IKeyframeTrack. Skipped (no channel / no Lua semantics): userData / skeletalData
 * (HashMap / Option<SkeletalAnimationData>) and the statics parse(HashMap) /
 * CreateFromMorphTargetSequence(Array<Any>) / CreateClipsFromMorphTargetSequences(Array<Any>) /
 * findByName(Any).
 */
package three.script.prebind

import three.animation.clip.AnimationClip
import three.animation._interfaces.IKeyframeTrack
import three.animation.blend.KeyframeTrack
import three.animation.tracks.*
import three.utils.constants.NormalAnimationBlendMode
import three.script.vm.*
import three.script.binding.*
import std.collection.*

/**
 * @brief[zh-cn] 按轨道的运行时类型给出其 Lua 绑定类全名（用于注册对象）
 * @param[zh-cn] track 关键帧轨道（接口引用）
 * @return[zh-cn] Lua 侧类表路径
 *
 * @brief[en] Maps a track's runtime type to its full Lua bound class name (for registration)
 * @param[en] track The keyframe track (interface reference)
 * @return[en] The Lua-side class path
 */
private func _prebindTrackClassName(track: IKeyframeTrack): String {
    match (track) {
        case _: NumberKeyframeTrack => "three.animation.tracks.NumberKeyframeTrack"
        case _: VectorKeyframeTrack => "three.animation.tracks.VectorKeyframeTrack"
        case _: ColorKeyframeTrack => "three.animation.tracks.ColorKeyframeTrack"
        case _: QuaternionKeyframeTrack => "three.animation.tracks.QuaternionKeyframeTrack"
        case _: BooleanKeyframeTrack => "three.animation.tracks.BooleanKeyframeTrack"
        case _: StringKeyframeTrack => "three.animation.tracks.StringKeyframeTrack"
        case _: KeyframeTrack => "three.animation.blend.KeyframeTrack"
        case _ => "three.animation.blend.KeyframeTrack"
    }
}

/**
 * @brief[zh-cn] 安装 AnimationClip 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.clip.AnimationClip）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AnimationClip
 * @param[en] vm The target virtual machine (class table installed at three.animation.clip.AnimationClip)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAnimationClip(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.clip.AnimationClip")
    // ===== 构造：name / duration / tracks / blendMode 全部可选 =====
    b.constructor {
        args => AnimationClip(name: prebindStr(args, 0), duration: prebindNum(args, 1, default: -1.0),
            tracks: prebindObjList<IKeyframeTrack>(vm, args, 2).toArray(),
            blendMode: prebindInt(args, 3, default: NormalAnimationBlendMode))
    }
    // ===== 属性 =====
    b.property("name", getter: Some({ref => LuaValue.of(ref.cast<AnimationClip>().name)}),
        setter: Some({ref, v => ref.cast<AnimationClip>().name = v.stringValue()}))
    b.property("duration", getter: Some({ref => LuaValue.of(ref.cast<AnimationClip>().duration)}),
        setter: Some({ref, v => ref.cast<AnimationClip>().duration = v.numberValue()}))
    b.property("blendMode", getter: Some({ref => LuaValue.of(ref.cast<AnimationClip>().blendMode)}),
        setter: Some({ref, v => ref.cast<AnimationClip>().blendMode = v.intValue()}))
    b.property("uuid", getter: Some({ref => LuaValue.of(ref.cast<AnimationClip>().uuid)}),
        setter: Some({ref, v => ref.cast<AnimationClip>().uuid = v.stringValue()}))
    b.property(
        "tracks",
        getter: Some(
            {
                ref =>
                    let tracks = ref.cast<AnimationClip>().tracks
                    let arr = Array<LuaValue>(tracks.size, {
                        i => prebindRegister(tracks[i], _prebindTrackClassName(tracks[i]))
                    })
                    LuaValue.of(arr)
            }
        ),
        setter: Some(
            {
                ref, v =>
                    let list = ArrayList<IKeyframeTrack>()
                    for (elem in prebindArray(vm, [v], 0)) {
                        if (elem.isObject) {
                            list.add(LuaObjectRegistry.getAs<IKeyframeTrack>(elem.objectId()))
                        }
                    }
                    ref.cast<AnimationClip>().tracks = list.toArray()
            }
        )
    )
    // ===== 时长与轨道维护（链式返回自身） =====
    b.method("resetDuration") {
        ref, _ =>
            ref.cast<AnimationClip>().resetDuration()
            [LuaValue.Object(ref.id)]
    }
    b.method("trim") {
        ref, _ =>
            ref.cast<AnimationClip>().trim()
            [LuaValue.Object(ref.id)]
    }
    b.method("optimize") {
        ref, _ =>
            ref.cast<AnimationClip>().optimize()
            [LuaValue.Object(ref.id)]
    }
    b.method("validate") {
        ref, _ => [LuaValue.of(ref.cast<AnimationClip>().validate())]
    }
    b.method("clone") {
        ref, _ => [prebindRegister(ref.cast<AnimationClip>().clone(), "three.animation.clip.AnimationClip")]
    }
    b.install(vm)
}
