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
 * @file[zh-cn] animation_offline_rawanimation 离线动画数据 RawAnimation 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.animation.offline.RawAnimation 绑定为 Lua 类型
 * three.animation.offline.RawAnimation
 * @explain[zh-cn] 覆盖无参构造、只读/可变属性 duration / trackCount / name、以及全部
 * 操作方法（initTracks / addTranslationKeyframe / addRotationKeyframe / addScaleKeyframe /
 * numTranslationKeyframes / numRotationKeyframes / numScaleKeyframes / validate /
 * sortKeyframes / recalcDuration）。关键帧统一以「标量参数」传入（时间 + Vector3F 对象
 * 或四元数四分量），避免依赖嵌套 ArrayList 通道。
 * 跳过：translations / rotations / scales —— 类型为 ArrayList<ArrayList<Float3Keyframe>>
 * 等嵌套容器，当前无「Lua 表 ↔ 嵌套容器」通道。
 *
 * @file[en] animation_offline_rawanimation  Lua binding of the offline animation data RawAnimation
 * (three.script.prebind)
 * @brief[en] Binds three.animation.offline.RawAnimation as the Lua type
 * three.animation.offline.RawAnimation
 * @explain[en] Covers the parameterless constructor, the duration / trackCount / name
 * properties and every operation (initTracks / addTranslationKeyframe /
 * addRotationKeyframe / addScaleKeyframe / numTranslationKeyframes /
 * numRotationKeyframes / numScaleKeyframes / validate / sortKeyframes /
 * recalcDuration). Keyframes are passed as scalars (time + a Vector3F object or four
 * quaternion components) so no nested-container channel is needed.
 * Skipped: translations / rotations / scales — they are nested containers
 * (ArrayList<ArrayList<Float3Keyframe>> etc.) and there is no
 * "Lua table ↔ nested container" channel yet.
 */
package three.script.prebind

import three.animation.offline.RawAnimation
import three.core.math.Vector3F
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 RawAnimation 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.animation.offline.RawAnimation）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of RawAnimation
 * @param[en] vm The target virtual machine (class table installed at three.animation.offline.RawAnimation)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installRawAnimation(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.animation.offline.RawAnimation")
    // ===== 构造（仅无参） =====
    b.constructor { _ =>
        RawAnimation()
    }
    // ===== 属性 =====
    b.property("duration",
        getter: Some({ ref => LuaValue.of(Float64(ref.cast<RawAnimation>().duration)) }),
        setter: Some({ ref, v => ref.cast<RawAnimation>().duration = Float32(v.numberValue()) }))
    b.property("trackCount",
        getter: Some({ ref => LuaValue.of(Int64(ref.cast<RawAnimation>().trackCount)) }),
        setter: Some({ ref, v => ref.cast<RawAnimation>().trackCount = Int64(v.intValue()) }))
    b.property("name",
        getter: Some({ ref => LuaValue.of(ref.cast<RawAnimation>().name) }),
        setter: Some({ ref, v => ref.cast<RawAnimation>().name = v.stringValue() }))
    // ===== 轨道初始化 =====
    b.method("initTracks") { ref, args =>
        ref.cast<RawAnimation>().initTracks(Int64(prebindInt(args, 0)))
        [LuaValue.Object(ref.id)]
    }
    // ===== 关键帧追加（时间 + Vector3F 对象 / 四元数四分量） =====
    b.method("addTranslationKeyframe") { ref, args =>
        ref.cast<RawAnimation>().addTranslationKeyframe(
            Int64(prebindInt(args, 0)),
            Float32(prebindNum(args, 1)),
            prebindAs<Vector3F>(args, 2))
        [LuaValue.Object(ref.id)]
    }
    b.method("addRotationKeyframe") { ref, args =>
        ref.cast<RawAnimation>().addRotationKeyframe(
            Int64(prebindInt(args, 0)),
            Float32(prebindNum(args, 1)),
            Float32(prebindNum(args, 2)),
            Float32(prebindNum(args, 3)),
            Float32(prebindNum(args, 4)),
            Float32(prebindNum(args, 5)))
        [LuaValue.Object(ref.id)]
    }
    b.method("addScaleKeyframe") { ref, args =>
        ref.cast<RawAnimation>().addScaleKeyframe(
            Int64(prebindInt(args, 0)),
            Float32(prebindNum(args, 1)),
            prebindAs<Vector3F>(args, 2))
        [LuaValue.Object(ref.id)]
    }
    // ===== 关键帧计数 =====
    b.method("numTranslationKeyframes") { ref, args =>
        [LuaValue.of(Int64(ref.cast<RawAnimation>().numTranslationKeyframes(Int64(prebindInt(args, 0)))))]
    }
    b.method("numRotationKeyframes") { ref, args =>
        [LuaValue.of(Int64(ref.cast<RawAnimation>().numRotationKeyframes(Int64(prebindInt(args, 0)))))]
    }
    b.method("numScaleKeyframes") { ref, args =>
        [LuaValue.of(Int64(ref.cast<RawAnimation>().numScaleKeyframes(Int64(prebindInt(args, 0)))))]
    }
    // ===== 校验 / 排序 / 时长 =====
    b.method("validate") { ref, _ =>
        [LuaValue.of(ref.cast<RawAnimation>().validate())]
    }
    b.method("sortKeyframes") { ref, _ =>
        ref.cast<RawAnimation>().sortKeyframes()
        [LuaValue.Object(ref.id)]
    }
    b.method("recalcDuration") { ref, _ =>
        ref.cast<RawAnimation>().recalcDuration()
        [LuaValue.Object(ref.id)]
    }
    b.install(vm)
}


