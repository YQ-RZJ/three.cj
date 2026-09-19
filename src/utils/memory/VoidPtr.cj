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
 * @file[zh-cn] VoidPtr — 无类型指针包装
 * @brief[zh-cn] void* 指针安全包装，供跨模块传递不透明指针（如 ImGui/渲染句柄、用户数据指针）
 * @explain[zh-cn] 与 three.rendering.types.BgfxTypes 中 UnitPtr 的模式一致，
 *         用于存储任意用户数据指针；外部只持有 Box 引用，不解包、不释放。
 *         各上层模块（如 three.window.ui）通过本类型在公开 API 传递不透明指针，
 *         避免直接暴露裸 CPointer。
 *
 * @file[en] VoidPtr — Untyped pointer wrapper
 * @brief[en] Safe wrapper for void* pointers, for passing opaque pointers across modules
 *         (e.g. ImGui/render handles, user-data pointers)
 * @explain[en] Consistent with the UnitPtr pattern in three.rendering.types.BgfxTypes;
 *         used to store arbitrary user-data pointers. External code only holds
 *         the Box reference and never unwraps or frees it. Upper modules
 *         (e.g. three.window.ui) use this type in public APIs to pass opaque
 *         pointers without exposing raw CPointer.
 * @package three.utils.memory
 */
package three.utils.memory

/**
 * @brief[zh-cn] void* 指针包装
 * @explain[zh-cn] 包装 CPointer<Unit> 为安全的 Box 类型。外部项目可通过
 *         VoidPtr 在公开 API 中传递不透明指针；包内持有者可用 .value 解包。
 *         仅作句柄传递，不负责内存生命周期。
 *
 * @brief[en] void* pointer wrapper
 * @explain[en] Wraps CPointer<Unit> into a safe Box type. External projects can pass
 *         opaque pointers through VoidPtr in public APIs; package-internal
 *         holders can unwrap it via .value. Used as a handle only; it does not
 *         manage memory lifecycle.
 */
public type VoidPtr = Box<CPointer<Unit>>
