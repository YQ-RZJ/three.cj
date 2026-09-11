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
 * @file[zh-cn] Thread
 * @brief[zh-cn] 包锚文件：three.core.thread 包（线程与同步原语）
 * @explain[zh-cn] 本包基于 sdl4cj 库做高级封装（对应 SDL_thread / SDL_mutex），提供线程、互斥锁、条件变量、信号量、读写锁与延时能力，供 three 各模块与外部使用。根据 cjpm 的目录扫描规则，父目录必须存在至少一个 .cj 文件，否则子目录不会被扫描为源码，故保留本锚文件。
 *
 * @file[en] Thread
 * @brief[en] Anchor file for the three.core.thread package (threads and synchronization primitives)
 * @explain[en] This package provides high-level wrappers based on the sdl4cj library (corresponding to SDL_thread / SDL_mutex), offering threads, mutexes, condition variables, semaphores, read-write locks, and sleep capabilities for all three modules and external use. Per cjpm directory scanning rules, the parent directory must contain at least one .cj file; otherwise subdirectories will not be scanned as source, so this anchor file is retained.
 */
package three.core.thread