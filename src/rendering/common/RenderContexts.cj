/**
 * @file[zh-cn] 渲染上下文缓存
 * @brief[zh-cn] 渲染上下文缓存管理器，按 (scene, camera) 组合键缓存 RenderContext
 * @explain[zh-cn] 
 * RenderContexts 管理多个 RenderContext 实例，按 (scene, camera) 组合键缓存，
 * 避免每帧重复创建 RenderContext。内部 HashMap 使用 scene.id * 100000 + camera.id 作为组合键。
 * 对照源码: three.js/src/renderers/common/RenderContexts.js (131 行)
 *
 * @file[en] RenderContexts
 * @brief[en] Render context cache manager, caching RenderContext by (scene, camera) composite key
 * @explain[en] 
 * RenderContexts manages multiple RenderContext instances, caching them by (scene, camera) composite key,
 * avoiding repeated creation of RenderContext each frame. Internally uses scene.id * 100000 + camera.id as the composite key.
 * Corresponding source: three.js/src/renderers/common/RenderContexts.js (131 lines)
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import std.collection.*

/**
 * @brief[zh-cn] 渲染上下文缓存管理器
 * @explain[zh-cn] 
 * 按 (scene, camera) 组合键缓存 RenderContext，内部 HashMap 使用 scene.id * 100000 + camera.id 作为组合键。
 *
 * @brief[en] Render context cache manager
 * @explain[en] 
 * Caches RenderContext by (scene, camera) composite key. Internally uses scene.id * 100000 + camera.id as the composite key.
 */
public open class RenderContexts {
    /**
     * @brief[zh-cn] 渲染上下文缓存（组合键 -> RenderContext）
     */
    private var contexts: HashMap<Int64, RenderContext>

    /**
     * @brief[zh-cn] 构造默认渲染上下文缓存
     *
     * @brief[en] Constructs a default render context cache
     */
    public init() {
        this.contexts = HashMap<Int64, RenderContext>()
    }

    /**
     * @brief[zh-cn] 获取或创建 (scene, camera) 对应的 RenderContext
     * @explain[zh-cn] 
     * 若已有缓存的 RenderContext 则返回，否则新建并缓存。
     * @param[zh-cn] scene 场景
     * camera 相机
     * @return[zh-cn] RenderContext 实例
     *
     * @brief[en] Gets or creates the RenderContext for the given (scene, camera)
     * @explain[en] 
     * If a cached RenderContext exists, returns it; otherwise, creates a new one and caches it.
     * @param[en] scene Scene
     * camera Camera
     * @return[en] RenderContext instance
     */
    public func get(scene: Scene, camera: Camera): RenderContext {
        let key = scene.id * 100000 + camera.id
        match (this.contexts.get(key)) {
            case Some(ctx) => return ctx
            case None =>
                let ctx = RenderContext()
                ctx.id = key
                ctx.scene = Some(scene)
                ctx.camera = Some(camera)
                this.contexts.add(key, ctx)
                return ctx
        }
    }

    /**
     * @brief[zh-cn] 清空所有上下文
     *
     * @brief[en] Clears all contexts
     */
    public func clear(): Unit {
        this.contexts = HashMap<Int64, RenderContext>()
    }
}
