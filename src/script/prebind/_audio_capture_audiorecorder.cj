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
 * @file[zh-cn] audio_capture_audiorecorder 麦克风录音器 AudioRecorder 的 Lua 绑定
 * （three.script.prebind）
 * @brief[zh-cn] 将 three.audio.capture.AudioRecorder 绑定为 Lua 类型
 * three.audio.capture.AudioRecorder
 * @explain[zh-cn] 覆盖无参构造、5 个只读属性（opened / recording / frequency /
 * channels / format）、open(frequency, channels, bufferSize)（bufferSize 为命名可选参数，
 * Lua 侧按位置传第 3 个参数，缺省 8192）、start / stop / getAvailableSamples、
 * releasable 属性与 release()。
 * readSamples(buffer: CPointer<UInt8>, samples) 接收调用方分配的原始内存指针，
 * 按项目约定不暴露给 Lua；getCaptureDevice 为 protected，不绑定。
 *
 * @file[en] audio_capture_audiorecorder  Lua binding of the microphone recorder AudioRecorder
 * (three.script.prebind)
 * @brief[en] Binds three.audio.capture.AudioRecorder as the Lua type three.audio.capture.AudioRecorder
 * @explain[en] Covers the parameterless constructor, five read-only properties
 * (opened / recording / frequency / channels / format), open(frequency, channels,
 * bufferSize) (bufferSize is a named optional parameter; Lua passes it positionally as the
 * third argument, defaulting to 8192), start / stop / getAvailableSamples, the releasable
 * property and release(). readSamples(buffer: CPointer<UInt8>, samples) takes caller-allocated
 * raw memory, which the project convention keeps away from Lua; getCaptureDevice is
 * protected and not bound.
 */
package three.script.prebind

import three.audio.capture.AudioRecorder
import three.script.vm.*
import three.script.binding.*

/**
 * @brief[zh-cn] 安装 AudioRecorder 的 Lua 绑定
 * @param[zh-cn] vm 目标虚拟机（类表安装到 three.audio.capture.AudioRecorder）
 * @throws[zh-cn] Exception 同名绑定重复安装时抛出
 *
 * @brief[en] Installs the Lua binding of AudioRecorder
 * @param[en] vm The target virtual machine (class table installed at three.audio.capture.AudioRecorder)
 * @throws[en] Exception Thrown when the same bindings are installed twice
 */
public func installAudioRecorder(vm: LuaVM): Unit {
    let b = LuaClassBinder.defineClass(vm, "three.audio.capture.AudioRecorder")
    b.constructor {_ => AudioRecorder()}
    // ===== 只读属性 =====
    b.property("opened", getter: Some({ref => LuaValue.of(ref.cast<AudioRecorder>().opened)}))
    b.property("recording", getter: Some({ref => LuaValue.of(ref.cast<AudioRecorder>().recording)}))
    b.property("frequency", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioRecorder>().frequency))}))
    b.property("channels", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioRecorder>().channels))}))
    b.property("format", getter: Some({ref => LuaValue.of(Int64(ref.cast<AudioRecorder>().format))}))
    b.property("releasable", getter: Some({ref => LuaValue.of(ref.cast<AudioRecorder>().releasable)}))
    // ===== 设备打开 / 捕获控制 =====
    b.method("open") {
        ref, args => [LuaValue.of(
            ref
                .cast<AudioRecorder>()
                .open(UInt32(prebindInt(args, 0, default: 44100)), UInt32(prebindInt(args, 1, default: 1)),
                    bufferSize: Int32(prebindInt(args, 2, default: 8192))))]
    }
    b.method("start") {
        ref, _ => [LuaValue.of(ref.cast<AudioRecorder>().start())]
    }
    b.method("stop") {
        ref, _ =>
            ref.cast<AudioRecorder>().stop()
            Array<LuaValue>()
    }
    b.method("getAvailableSamples") {
        ref, _ => [LuaValue.of(Int64(ref.cast<AudioRecorder>().getAvailableSamples()))]
    }
    b.method("release") {
        ref, _ => [LuaValue.of(ref.cast<AudioRecorder>().release())]
    }
    b.install(vm)
}
