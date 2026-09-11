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
 * @file[zh-cn] IAudioEffect 音频效果对象接口（解耦 source 与 mixer）
 * @brief[zh-cn] 本文件定义音频效果对象接口 IAudioEffect
 * @explain[zh-cn] 预留接口：当 source 包未来需要直接引用 AudioEffect 时，
 * 通过此接口避免直接依赖 mixer 包，从而打破 source → mixer 的潜在循环依赖边界。
 *
 * @file[en] IAudioEffect  Audio effect object interface (decoupling source and mixer)
 * @brief[en] This file defines the audio effect object interface IAudioEffect
 * @explain[en] Reserved interface: when the source package needs to reference AudioEffect
 * in the future, it uses this interface to avoid a direct dependency on the mixer
 * package, breaking the potential circular dependency boundary of source → mixer.
 */
package three.audio.interfaces

/**
 * @brief[zh-cn] 音频效果对象接口
 * @explain[zh-cn] 暴露 OpenAL 效果句柄 effectId，供 source 包按需引用音频效果。
 *
 * @brief[en] Audio effect object interface
 * @explain[en] Exposes the OpenAL effect handle effectId so the source package can
 * reference audio effects as needed.
 */
public interface IAudioEffect {
    /**
     * @brief[zh-cn] 获取 OpenAL 效果句柄
     * @return[zh-cn] OpenAL 效果句柄（ALuint）
     *
     * @brief[en] Returns the OpenAL effect handle
     * @return[en] The OpenAL effect handle (ALuint)
     */
    func getEffectId(): UInt32
}
