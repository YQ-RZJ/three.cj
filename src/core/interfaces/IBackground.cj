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
 * @file[zh-cn] IBackground
 * @brief[zh-cn] 场景背景标记接口
 * @explain[zh-cn] three.js 的 Scene.background 类型为 Color | Texture | CubeTexture（联合类型）。cj 侧仓颉无联合类型，原用 Option<Any> 表达；为消除 Any，定义本标记接口。实现方（math 包 Color、textures 包 Texture/CubeTexture）实现本接口；使用方（scenes 包 Scene）仅以接口持有背景引用，渲染器（Background）运行时 match 具体类型分派（Color → clear 色，Texture/CubeTexture → 环境贴图）。
 *
 * @file[en] IBackground
 * @brief[en] Scene background marker interface
 * @explain[en] In three.js, Scene.background is of type Color | Texture | CubeTexture (union type). Cangjie has no union types, so Option<Any> was originally used; to eliminate Any, this marker interface is defined. Implementers (math package Color, textures package Texture/CubeTexture) implement this interface; consumers (scenes package Scene) hold background references via the interface, and the renderer (Background) dispatches at runtime by matching concrete types (Color → clear color, Texture/CubeTexture → environment map). JS reference: Scene.background (Color/Texture/CubeTexture union).
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 场景背景标记接口：Scene.background 的元素类型
 * @explain[zh-cn] 消除 Any，让 Color/Texture/CubeTexture 共享统一接口类型
 *
 * @brief[en] Scene background marker interface: element type of Scene.background
 * @explain[en] Eliminates Any, allowing Color/Texture/CubeTexture to share a unified interface type
 */
public interface IBackground {
}
