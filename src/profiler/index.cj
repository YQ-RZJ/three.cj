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
 */

/**
 * @file[zh-cn] index.cj — three.profiler 子包入口
 * @brief[zh-cn] 性能剖析（Tracy）统一门面 + 宏自动化侵入
 * @package three.profiler
 *
 * @explain[zh-cn] ## 两层设计
 * 1. **运行时门面**（本包 `three.profiler`，无环境变量门控）：
 *    `Zone` / `Frame` / `Plot` / `Message` / `Memory` / `Gpu` / `Lock` /
 *    `Fiber` / `Sampling` / `ProfilerState`。用户直接调用即视为明确的剖析
 *    意图，**无论如何都有效侵入**。
 * 2. **宏自动化侵入**（子包 `three.profiler.macros`，THREE_PROFILER 门控）：
 *    `@Zone[链路]` / `@FrameMark` / `@Plot[链路]` / `@Message[链路]` 等属性宏
 *    在编译期读取环境变量 THREE_PROFILER，与属性链路做**段级前缀匹配**，
 *    未命中则零侵入（宏原样透传）。规则见 macros 包文档。
 *
 * ## THREE_PROFILER 取值示例
 * ```
 * THREE_PROFILER=off                     # 全部零侵入（默认）
 * THREE_PROFILER=all                     # 全部侵入
 * THREE_PROFILER=three                   # 链路以 "three." 开头的侵入
 * THREE_PROFILER=three.test              # 前缀 "three.test" 的侵入
 * THREE_PROFILER=three.render,three.test # 逗号分隔多链路，任一命中即侵入
 * ```
 *
 * @file[en] index.cj — three.profiler package entry
 * @brief[en] Tracy profiling facade + compile-time prunable macros
 * @package three.profiler
 * @explain[en] Two layers: (1) unconditional runtime facade in this package —
 * direct API use is always instrumented; (2) macro auto instrumentation in
 * three.profiler.macros — gated at expansion time by the THREE_PROFILER env
 * var with segment-level link-prefix matching; misses pass through untouched.
 */
package three.profiler
