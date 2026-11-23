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
 * @file[zh-cn] audio_mixer_effectslot EFX 效果槽 AudioEffectSlot 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.audio.mixer.AudioEffectSlot 绑定为 Lua 类型
 * three.audio.mixer.AudioEffectSlot
 * @explain[zh-cn] 构造接受可选音频上下文（缺省用 AudioContext.context 单例）；
 * slotId / context（只读）属性、getSlotId、create、setEffect、setGain、clearEffect、
 * releasable 属性与 release()。返回 AudioEffectSlot 的方法统一回传自身 id 以支持链式调用。
 *
 * @file[en] audio_mixer_effectslot  Lua binding of the EFX effect slot AudioEffectSlot
 * (three.script.prebind)
 * @brief[en] Binds three.audio.mixer.AudioEffectSlot as the Lua type
 * three.audio.mixer.AudioEffectSlot
 * @explain[en] The constructor takes an optional audio context (defaults to the
 * AudioContext.context singleton); slotId / context (read-only) properties, getSlotId,
 * create, setEffect, setGain, clearEffect, the releasable property and release(). Methods
 * returning AudioEffectSlot hand back the object's own id for chaining.
 */
package three.script.prebind

import three.audio.mixer.AudioEffect
import three.audio.mixer.AudioEffectSlot
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioEffectSlot 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.mixer.AudioEffectSlot）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioEffectSlot
 * @param[en] vm The target virtual machine (class table installed at three.audio.mixer.AudioEffectSlot)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioEffectSlot(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.mixer.AudioEffectSlot")
    // ===== 构造（可选音频上下文） =====
    b.constructor {
        args => if (let Some(ctx) <- _prebindOptAudioContext(args, 0)) {
            AudioEffectSlot(context: ctx)
        } else {
            AudioEffectSlot()
        }
    }
    // ===== 属性 =====
    b.property("slotId", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioEffectSlot>().slotId))}),
        setter: Some({ref, v => ref.cast<AudioEffectSlot>().slotId = UInt32(v.intValue())}))
    b.property("context",
        getter: Some({ref => prebindRegister(ref.cast<AudioEffectSlot>().context, "three.audio.device.AudioContext")}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioEffectSlot>().releasable)}))
    // ===== 创建 / 绑定效果 =====
    b.method("getSlotId") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioEffectSlot>().getSlotId()))]
    }
    b.method("create") {
        ref, _ =>
            ref.cast<AudioEffectSlot>().create()
            [LuaValue.Object(ref.id)]
    }
    b.method("setEffect") {
        ref, args =>
            ref.cast<AudioEffectSlot>().setEffect(prebindAs<AudioEffect>(args, 0))
            [LuaValue.Object(ref.id)]
    }
    b.method("setGain") {
        ref, args =>
            ref.cast<AudioEffectSlot>().setGain(Float32(prebindNum(args, 0, default: 1.0)))
            [LuaValue.Object(ref.id)]
    }
    b.method("clearEffect") {
        ref, _ =>
            ref.cast<AudioEffectSlot>().clearEffect()
            [LuaValue.Object(ref.id)]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioEffectSlot>().release())]
    }
    b.install(vm)
}
