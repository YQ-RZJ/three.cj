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
 * @file[zh-cn] Audio 音频模块父包（锚点文件）
 * @brief[zh-cn] 音频模块父包，仅用于声明 three.audio 包
 * @explain[zh-cn] 本文件不含任何类型声明，仅作为包锚点，便于 cjpm 识别
 * device/source/listener/mixer/interfaces/capture 等子包。
 *
 * @file[en] Audio  The audio module parent package (anchor file)
 * @brief[en] The audio module parent package, used only to declare the three.audio package
 * @explain[en] This file contains no type declarations and serves only as a package
 * anchor so that cjpm can recognize the device/source/listener/mixer/
 * interfaces/capture subpackages.
 *
 * @intro[zh-cn] three.audio 提供基于 OpenAL 的音频子系统，包括音频上下文
 * （AudioContext）、监听器（AudioListener）、静态/位置/流式音频源
 * （Audio/PositionalAudio/StreamingAudio）、录音（AudioRecorder）以及
 * EFX 效果与滤波器（AudioEffect/AudioFilter/AudioEffectSlot）。
 * @intro[en] three.audio provides an OpenAL-based audio subsystem, including the
 * audio context (AudioContext), listener (AudioListener), static/positional/
 * streaming audio sources (Audio/PositionalAudio/StreamingAudio), recording
 * (AudioRecorder), and EFX effects and filters (AudioEffect/AudioFilter/AudioEffectSlot).
 */
package three.audio
