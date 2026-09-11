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
 * @file[zh-cn] 渲染器工具
 * @brief[zh-cn] 提供渲染器通用的工具方法
 * @explain[zh-cn] RendererUtils 封装了渲染器清除操作相关的静态工具方法，包括自动清除和手动清除功能，供渲染管线各模块调用。
 *
 * @file[en] Renderer Utilities
 * @brief[en] Provides common utility methods for the renderer
 * @explain[en] RendererUtils encapsulates static utility methods related to renderer clear operations, including auto-clear and manual-clear functionality, for use across the rendering pipeline.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.cameras.Camera
import three.scene.scenegraph.*

/**
 * @brief[zh-cn] 渲染器工具类
 * @explain[zh-cn] 提供渲染器清除相关的静态工具方法，包括根据场景设置自动清除和手动指定颜色/深度/模板缓冲的清除。
 *
 * @brief[en] Renderer utility class
 * @explain[en] Provides static utility methods for renderer clearing, including auto-clear based on scene settings and manual clear with specified color/depth/stencil buffers.
 */
public class RendererUtils {

    /**
     * @brief[zh-cn] 根据渲染器设置自动清除帧缓冲
     * @param[zh-cn] renderer 渲染器实例
     * scene 场景实例
     * camera 相机实例
     *
     * @brief[en] Auto-clear frame buffers based on renderer settings
     * @param[en] renderer Renderer instance
     * scene Scene instance
     * camera Camera instance
     */
    public static func autoClear(renderer: Renderer, scene: Scene, camera: Camera): Unit { }

    /**
     * @brief[zh-cn] 手动清除帧缓冲的指定通道
     * @param[zh-cn] renderer 渲染器实例
     * color 是否清除颜色缓冲
     * depth 是否清除深度缓冲
     * stencil 是否清除模板缓冲
     *
     * @brief[en] Manually clear specified channels of the frame buffer
     * @param[en] renderer Renderer instance
     * color Whether to clear the color buffer
     * depth Whether to clear the depth buffer
     * stencil Whether to clear the stencil buffer
     */
    public static func clear(renderer: Renderer, color: Bool, depth: Bool, stencil: Bool): Unit { }
}
