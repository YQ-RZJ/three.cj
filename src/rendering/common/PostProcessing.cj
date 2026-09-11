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
 * @file[zh-cn] 后处理
 * @brief[zh-cn] 后处理渲染器，对场景应用后处理效果
 * @explain[zh-cn] 
 * PostProcessing 管理后处理效果链，当 enabled 为 true 时，
 * 在主渲染 pass 之后对场景应用后处理（如泛光、色调映射等）。
 *
 * @file[en] PostProcessing
 * @brief[en] Post-processing renderer, applying post-processing effects to the scene
 * @explain[en] 
 * PostProcessing manages the post-processing effect chain. When enabled is true,
 * post-processing effects (such as bloom, tone mapping, etc.) are applied to the scene after the main render pass.
 */
package three.rendering.common

import three.scene.scenegraph.*
import three.rendering.cameras.Camera

/**
 * @brief[zh-cn] 后处理渲染器
 * @explain[zh-cn] 
 * 管理后处理效果链，在主渲染 pass 后对场景应用后处理效果。
 *
 * @brief[en] Post-processing renderer
 * @explain[en] 
 * Manages the post-processing effect chain, applying post-processing effects after the main render pass.
 */
public class PostProcessing {
    /**
     * @brief[zh-cn] 是否启用后处理
     *
     * @brief[en] Whether post-processing is enabled
     */
    public var enabled: Bool

    /**
     * @brief[zh-cn] 构造默认后处理渲染器（禁用状态）
     *
     * @brief[en] Constructs a default post-processing renderer (disabled)
     */
    public init() { this.enabled = false }

    /**
     * @brief[zh-cn] 执行后处理渲染
     * @param[zh-cn] scene 场景
     * camera 相机
     *
     * @brief[en] Executes post-processing rendering
     * @param[en] scene Scene
     * camera Camera
     */
    public func render(scene: Scene, camera: Camera): Unit { }
}
