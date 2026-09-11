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
 * @file[zh-cn] IAudioFilter 音频滤波器接口（解耦 source 与 mixer）
 * @brief[zh-cn] 本文件定义音频滤波器接口 IAudioFilter
 * @explain[zh-cn] source 包通过此接口引用滤波器，避免直接依赖 mixer 包的具体类 AudioFilter，
 * 从而打破 source → mixer 的潜在循环依赖边界。
 *
 * @file[en] IAudioFilter  Audio filter interface (decoupling source and mixer)
 * @brief[en] This file defines the audio filter interface IAudioFilter
 * @explain[en] The source package references filters through this interface instead of
 * the concrete mixer class AudioFilter, breaking the potential circular
 * dependency boundary of source → mixer.
 */
package three.audio.interfaces

/**
 * @brief[zh-cn] 音频滤波器接口
 * @explain[zh-cn] 暴露 source 包所需的唯一属性：OpenAL 滤波器句柄 filterId。
 *
 * @brief[en] Audio filter interface
 * @explain[en] Exposes the only property the source package needs: the OpenAL filter
 * handle filterId.
 */
public interface IAudioFilter {
    /**
     * @brief[zh-cn] 获取 OpenAL 滤波器句柄
     * @return[zh-cn] OpenAL 滤波器句柄（ALuint）
     *
     * @brief[en] Returns the OpenAL filter handle
     * @return[en] The OpenAL filter handle (ALuint)
     */
    func getFilterId(): UInt32
}
