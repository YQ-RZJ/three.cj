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
 * @file[zh-cn] IRenderTarget 渲染目标标记接口
 * @brief[zh-cn] 渲染目标标记接口，解耦 cameras 与 renderers 的包级循环依赖
 * @explain[zh-cn] Three.js 的 CubeCamera.renderTarget 是 WebGLCubeRenderTarget（renderers 包）。
 * 仓颉侧 cameras 包若直接 import renderers 会形成循环（renderers 依赖 cameras），
 * 因此将"渲染目标"抽象为本标记接口：
 * - 实现方（renderers 包 BgfxRenderTarget）实现本接口；
 * - 使用方（cameras 包 CubeCamera）仅以接口持有渲染目标引用，不依赖实现类型。
 *
 * @file[en] IRenderTarget Render target marker interface
 * @brief[en] Render target marker interface, decoupling circular dependency between cameras and renderers
 * @explain[en] In Three.js, CubeCamera.renderTarget is WebGLCubeRenderTarget (renderers package).
 * If the Cangjie cameras package directly imports renderers, a circular dependency forms
 * (renderers depends on cameras), so "render target" is abstracted as this marker interface:
 * - Implementor (ThreeRenderTarget in renderers package) implements this interface;
 * - Consumer (CubeCamera in cameras package) holds render target reference by interface only.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

/**
 * @brief[zh-cn] 渲染目标标记接口：CubeCamera.renderTarget 的元素类型
 *
 * @brief[en] Render target marker interface: element type of CubeCamera.renderTarget
 */
public interface IRenderTarget {
}
