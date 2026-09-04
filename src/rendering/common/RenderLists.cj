/**
 * @file[zh-cn] 渲染列表缓存
 * @brief[zh-cn] 渲染列表缓存管理器，按 (scene, camera) 组合键缓存 RenderList
 * @explain[zh-cn] 
 * RenderLists 管理多个 RenderList 实例，按 (scene, camera) 组合键缓存，
 * 避免每帧重复创建 RenderList。内部 HashMap 使用 scene.id * 100000 + camera.id 作为组合键。
 * 对照源码: three.js/src/renderers/common/RenderLists.js (131 行)
 *
 * @file[en] RenderLists
 * @brief[en] Render list cache manager, caching RenderList by (scene, camera) composite key
 * @explain[en] 
 * RenderLists manages multiple RenderList instances, caching them by (scene, camera) composite key,
 * avoiding repeated creation of RenderList each frame. Internally uses scene.id * 100000 + camera.id as the composite key.
 * Corresponding source: three.js/src/renderers/common/RenderLists.js (131 lines)
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
 * @brief[zh-cn] 渲染列表缓存管理器
 * @explain[zh-cn] 
 * 按 (scene, camera) 组合键缓存 RenderList，内部 HashMap 使用组合 Int64 键。
 *
 * @brief[en] Render list cache manager
 * @explain[en] 
 * Caches RenderList by (scene, camera) composite key. Internally uses a composite Int64 key.
 */
public open class RenderLists {
    /**
     * @brief[zh-cn] 渲染列表缓存（组合键 -> RenderList）
     */
    private var lists: HashMap<Int64, RenderList>

    /**
     * @brief[zh-cn] 构造默认渲染列表缓存
     *
     * @brief[en] Constructs a default render list cache
     */
    public init() {
        this.lists = HashMap<Int64, RenderList>()
    }

    /**
     * @brief[zh-cn] 获取或创建 (scene, camera) 对应的 RenderList
     * @explain[zh-cn] 
     * 若已有缓存的 RenderList 则返回，否则新建并缓存。
     * @param[zh-cn] scene 场景
     * camera 相机
     * @return[zh-cn] RenderList 实例
     *
     * @brief[en] Gets or creates the RenderList for the given (scene, camera)
     * @explain[en] 
     * If a cached RenderList exists, returns it; otherwise, creates a new one and caches it.
     * @param[en] scene Scene
     * camera Camera
     * @return[en] RenderList instance
     */
    public func get(scene: Scene, camera: Camera): RenderList {
        let key = scene.id * 100000 + camera.id
        match (this.lists.get(key)) {
            case Some(list) => return list
            case None =>
                let list = RenderList()
                this.lists.add(key, list)
                return list
        }
    }

    /**
     * @brief[zh-cn] 清空所有渲染列表
     *
     * @brief[en] Clears all render lists
     */
    public func clear(): Unit {
        this.lists = HashMap<Int64, RenderList>()
    }
}
