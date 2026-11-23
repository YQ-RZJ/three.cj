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
 * @file[zh-cn] audio_source_audiobuffer 音频缓冲区 AudioBuffer 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.audio.source.AudioBuffer 绑定为 Lua 类型
 * three.audio.source.AudioBuffer
 * @explain[zh-cn] 覆盖无参构造、6 个 public 可变属性（bufferId / channels / sampleRate /
 * format / frameCount / dataSize）、releasable 只读属性与 release()。
 * 静态工厂 create / createChunk 接收 CPointer<Unit> PCM 指针，按项目约定不暴露给
 * Lua（Lua 侧无法构造原始 C 内存），因此不绑定。
 *
 * @file[en] audio_source_audiobuffer  Lua binding of the audio buffer AudioBuffer
 * (three.script.prebind)
 * @brief[en] Binds three.audio.source.AudioBuffer as the Lua type three.audio.source.AudioBuffer
 * @explain[en] Covers the parameterless constructor, the six public mutable properties
 * (bufferId / channels / sampleRate / format / frameCount / dataSize), the read-only
 * releasable property and release(). The static factories create / createChunk take
 * CPointer<Unit> PCM pointers, which the project convention keeps away from Lua (Lua
 * cannot build raw C memory), so they are not bound.
 */
package three.script.prebind

import three.audio.source.AudioBuffer
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioBuffer 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.source.AudioBuffer）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioBuffer
 * @param[en] vm The target virtual machine (class table installed at three.audio.source.AudioBuffer)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioBuffer(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.source.AudioBuffer")
    // ===== 构造（空缓冲，随后由 create / createChunk 填充） =====
    b.constructor {_ => AudioBuffer()}
    // ===== 属性 =====
    b.property("bufferId", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().bufferId))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().bufferId = UInt32(v.intValue())}))
    b.property("channels", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().channels))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().channels = UInt32(v.intValue())}))
    b.property("sampleRate", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().sampleRate))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().sampleRate = UInt32(v.intValue())}))
    b.property("format", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().format))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().format = UInt32(v.intValue())}))
    b.property("frameCount", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().frameCount))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().frameCount = UInt64(v.intValue())}))
    b.property("dataSize", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioBuffer>().dataSize))}),
        setter: Some({ref, v => ref.cast<AudioBuffer>().dataSize = Int32(v.intValue())}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioBuffer>().releasable)}))
    // ===== 释放 =====
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioBuffer>().release())]
    }
    b.install(vm)
}
