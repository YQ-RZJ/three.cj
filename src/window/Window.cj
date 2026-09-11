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
 * @file[zh-cn] Window 窗口模块父包（仅用于声明 three.window 包，便于 cjpm 识别 window 子包）
 * @brief[zh-cn] 窗口模块的包级占位文件
 * @explain[zh-cn] 对照 Engine/Core/Platform 与 Engine/Input 目录规划（doc/dir.md）：
 * - WindowEngine : 窗口引擎（跨平台窗口创建 + 事件泵，独立 SThread）
 * - InputEngine  : 输入引擎（键盘/鼠标/手柄/触摸状态查询）
 * - InputEvent   : 输入事件类型定义
 * - KeyCode      : 键盘/鼠标常量
 * - Enums        : 窗口/输入枚举（SystemCursor / GamepadAxis / GamepadButton）
 *
 * @file[en] Window Parent package of the window module (only declares the three.window package so that cjpm can recognize the window sub-package)
 * @brief[en] Package-level placeholder file of the window module
 * @explain[en] Per the Engine/Core/Platform and Engine/Input directory plan (doc/dir.md):
 * - WindowEngine : window engine (cross-platform window creation + event pump, dedicated SThread)
 * - InputEngine  : input engine (keyboard/mouse/gamepad/touch state queries)
 * - InputEvent   : input event type definitions
 * - KeyCode      : keyboard/mouse constants
 * - Enums        : window/input enums (SystemCursor / GamepadAxis / GamepadButton)
 *
 * @note[zh-cn] 本模块基于 sdl4cj 库做高级封装（three 不迁入 sdl4cj 的 FFI 代码）。
 * 系统信息/线程/定时器见 three.core.system / three.core.thread / three.core.time。
 * @note[en] This module is a high-level wrapper over the sdl4cj library (three does not host the sdl4cj FFI code).
 * System info / threads / timers live in three.core.system / three.core.thread / three.core.time.
 */
package three.window
