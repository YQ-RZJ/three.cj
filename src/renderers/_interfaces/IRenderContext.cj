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
 * @file[zh-cn] IRenderContext 渲染上下文接口（自 three.renderers.common 迁入本接口包）
 * @brief[zh-cn] 即时命令模型 beginRender/finishRender 的入参契约
 * @explain[zh-cn] 按 C9 约定收纳于 renderers/interfaces（protected 包），经实现包重导出为
 * three.renderers.common.IRenderContext。实现方为 RenderContext（渲染器侧上下文）。
 * 签名中的具体类型已按抽象接口化解除包循环：RenderTarget → IRenderTarget、
 * Scene → IScene（three.scene._interfaces）、Camera → ICamera（本包）。
 *
 * @file[en] IRenderContext  Render context interface (moved from three.renderers.common into this interface package)
 * @brief[en] The input contract of the immediate-command-model beginRender/finishRender
 * @explain[en] Collected into renderers/interfaces per C9 (protected package), re-exported by the implementation package as three.renderers.common.IRenderContext. Concrete types in signatures were abstracted to remove package cycles: RenderTarget → IRenderTarget, Scene → IScene (three.scene._interfaces), Camera → ICamera (this package).
 */
protected package three.renderers._interfaces

import three.scene._interfaces.IScene

/**
 * @brief[zh-cn] 渲染上下文接口，提供视图/视口/清除色/帧缓冲等查询方法
 * @explain[zh-cn] 即时命令模型 beginRender/finishRender 的入参契约。
 * 实现方为 RenderContext（渲染器侧上下文）。
 *
 * @brief[en] Render context interface, providing view/viewport/clear color/framebuffer query methods
 * @explain[en] The input contract of the immediate-command-model beginRender/finishRender.
 * Implemented by RenderContext (renderer-side context).
 */
public interface IRenderContext {
    /**
     * @brief[zh-cn] 返回 view ID
     *
     * @brief[en] Returns view ID
     */
    func getViewId(): UInt16
    /**
     * @brief[zh-cn] 返回视口 (x, y, w, h)
     *
     * @brief[en] Returns viewport (x, y, w, h)
     */
    func getViewport(): (Int32, Int32, UInt32, UInt32)
    /**
     * @brief[zh-cn] 返回清除颜色（UInt32 RGBA）
     *
     * @brief[en] Returns clear color (UInt32 RGBA)
     */
    func getClearColor(): UInt32
    /**
     * @brief[zh-cn] 返回帧缓冲对象（可为空）
     *
     * @brief[en] Returns framebuffer object (optional)
     */
    func getFrameBuffer(): Option<IRenderTarget>
    /**
     * @brief[zh-cn] 返回场景
     *
     * @brief[en] Returns scene
     */
    func getScene(): Option<IScene>
    /**
     * @brief[zh-cn] 返回相机
     *
     * @brief[en] Returns camera
     */
    func getCamera(): Option<ICamera>
}
