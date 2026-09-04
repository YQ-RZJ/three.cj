/**
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
