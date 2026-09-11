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
 * @file[zh-cn] IAudioEffectSlot 音频效果槽接口（解耦 source 与 mixer）
 * @brief[zh-cn] 本文件定义音频效果槽接口 IAudioEffectSlot
 * @explain[zh-cn] source 包通过此接口引用效果槽，避免直接依赖 mixer 包的具体类 AudioEffectSlot，
 * 从而打破 source → mixer 的潜在循环依赖边界。
 *
 * @file[en] IAudioEffectSlot  Audio effect slot interface (decoupling source and mixer)
 * @brief[en] This file defines the audio effect slot interface IAudioEffectSlot
 * @explain[en] The source package references effect slots through this interface instead of
 * the concrete mixer class AudioEffectSlot, breaking the potential circular
 * dependency boundary of source → mixer.
 */
package three.audio.interfaces

/**
 * @brief[zh-cn] 音频效果槽接口
 * @explain[zh-cn] 暴露 source 包所需的唯一属性：OpenAL 效果槽句柄 slotId。
 *
 * @brief[en] Audio effect slot interface
 * @explain[en] Exposes the only property the source package needs: the OpenAL effect
 * slot handle slotId.
 */
public interface IAudioEffectSlot {
    /**
     * @brief[zh-cn] 获取 OpenAL 效果槽句柄
     * @return[zh-cn] OpenAL 效果槽句柄（ALuint）
     *
     * @brief[en] Returns the OpenAL effect slot handle
     * @return[en] The OpenAL effect slot handle (ALuint)
     */
    func getSlotId(): UInt32
}
