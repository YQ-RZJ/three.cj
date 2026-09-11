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
 * @file[zh-cn] IRenderer 渲染器接口
 * @brief[zh-cn] 渲染器接口，声明 CubeCamera.update 所需的渲染目标切换方法
 * @explain[zh-cn] Three.js 的 CubeCamera.update(renderer, scene) 参数是 WebGLRenderer（renderers 包）。
 * 仓颉侧 cameras 包若直接 import renderers 会形成循环（renderers 依赖 cameras），
 * 因此将"渲染器"抽象为接口，声明 CubeCamera.update 语义上需要的方法：
 * - 实现方（renderers 包 BgfxRenderer）实现本接口；
 * - 使用方（cameras 包 CubeCamera）仅以接口持有渲染器引用并调用接口方法，不依赖实现类型。
 * render 方法不纳入接口：ThreeRenderer.render 是基类 Renderer.render(Scene, Camera) 的
 * override（具体类型签名），接口化会与 override 签名冲突，故 render 保留在具体类。
 *
 * @file[en] IRenderer Renderer interface
 * @brief[en] Renderer interface, declaring render target switching methods needed by CubeCamera.update
 * @explain[en] In Three.js, CubeCamera.update(renderer, scene) expects a WebGLRenderer (renderers package).
 * If the Cangjie cameras package directly imports renderers, a circular dependency forms
 * (renderers depends on cameras), so "renderer" is abstracted as an interface declaring
 * methods semantically needed by CubeCamera.update:
 * - Implementor (ThreeRenderer in renderers package) implements this interface;
 * - Consumer (CubeCamera in cameras package) holds renderer reference by interface only.
 * The render method is not included: ThreeRenderer.render overrides Renderer.render(Scene, Camera)
 * with a concrete signature; interface-izing it would conflict with the override signature.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

/**
 * @brief[zh-cn] 渲染器接口：CubeCamera.update 的 renderer 参数类型，声明渲染目标切换方法
 *
 * @brief[en] Renderer interface: renderer parameter type for CubeCamera.update, declaring render target switching methods
 */
public interface IRenderer {
    /**
     * @brief[zh-cn] 设置渲染目标（CubeCamera 6 面渲染：cubeFace 0~5 + mipLevel）
     * @param[zh-cn] renderTarget 渲染目标
     * cubeFace 立方体面索引（0~5）
     * mipLevel mipmap 层级
     *
     * @brief[en] Sets the render target (CubeCamera 6-face rendering: cubeFace 0~5 + mipLevel)
     * @param[en] renderTarget Render target
     * cubeFace Cube face index (0~5)
     * mipLevel Mipmap level
     */
    func setRenderTarget(renderTarget: IRenderTarget, cubeFace: Int64, mipLevel: Int64): Unit

    /**
     * @brief[zh-cn] 获取当前渲染目标
     * @return[zh-cn] 当前渲染目标（None 表示默认帧缓冲）
     *
     * @brief[en] Gets the current render target
     * @return[en] Current render target (None for default framebuffer)
     */
    func getRenderTarget(): Option<IRenderTarget>
}
