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
 * @file[zh-cn] audio_listener 音频监听器 AudioListener 的 Lua 绑定（three.script.prebind）
 * @brief[zh-cn] 将 three.audio.listener.AudioListener 绑定为 Lua 类型
 * three.audio.listener.AudioListener
 * @explain[zh-cn] 构造接受可选音频上下文（缺省用 AudioContext.context 单例）；
 * context / gain / timeDelta 可读写属性、getMasterVolume / setMasterVolume、
 * release 与 updateMatrixWorld（把世界变换同步到 OpenAL 监听器）。
 * AudioListener 继承 Object3D，但 Object3D 尚未绑定，故父类成员（position/rotation 等）
 * 在 Lua 侧不可用；本绑定只覆盖 AudioListener 自身的 public 成员。
 *
 * @file[en] audio_listener  Lua binding of the audio listener AudioListener (three.script.prebind)
 * @brief[en] Binds three.audio.listener.AudioListener as the Lua type
 * three.audio.listener.AudioListener
 * @explain[en] The constructor takes an optional audio context (defaults to the
 * AudioContext.context singleton); context / gain / timeDelta mutable properties,
 * getMasterVolume / setMasterVolume, release, and updateMatrixWorld (which syncs the world
 * transform to the OpenAL listener). AudioListener extends Object3D, which is not bound
 * yet, so the parent members (position/rotation, ...) are unavailable from Lua; this
 * binding only covers AudioListener's own public members.
 */
package three.script.prebind

import three.audio.device.AudioContext
import three.audio.listener.AudioListener
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioListener 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.listener.AudioListener）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioListener
 * @param[en] vm The target virtual machine (class table installed at three.audio.listener.AudioListener)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioListener(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.listener.AudioListener")
    // ===== 构造（可选音频上下文） =====
    b.constructor {
        args => if (let Some(ctx) <- _prebindOptAudioContext(args, 0)) {
            AudioListener(context: ctx)
        } else {
            AudioListener()
        }
    }
    // ===== 属性 =====
    b.property("context",
        getter: Some({ref => prebindRegister(ref.cast<AudioListener>().context, "three.audio.device.AudioContext")}),
        setter: Some({
            ref, v => ref.cast<AudioListener>().context = LuaObjectRegistry.getAs<AudioContext>(v.objectId())
        }))
    b.property("gain", getter: Some({ref => LuaValue.of(ref.cast<AudioListener>().gain)}),
        setter: Some({ref, v => ref.cast<AudioListener>().gain = v.numberValue()}))
    b.property("timeDelta", getter: Some({ref => LuaValue.of(ref.cast<AudioListener>().timeDelta)}),
        setter: Some({ref, v => ref.cast<AudioListener>().timeDelta = v.numberValue()}))
    // ===== 主音量 =====
    b.method("getMasterVolume") {
        ref, _ => [LuaValue.of(ref.cast<AudioListener>().getMasterVolume())]
    }
    b.method("setMasterVolume") {
        ref, args =>
            ref.cast<AudioListener>().setMasterVolume(prebindNum(args, 0, default: 1.0))
            Array<LuaValue>()
    }
    // ===== 世界变换同步 / 释放 =====
    b.method("updateMatrixWorld") {
        ref, args =>
            ref.cast<AudioListener>().updateMatrixWorld(prebindBool(args, 0))
            Array<LuaValue>()
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioListener>().release())]
    }
    b.install(vm)
}
