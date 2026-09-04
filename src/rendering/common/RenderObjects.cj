/**
 * @file[zh-cn] 渲染对象缓存
 * @brief[zh-cn] 渲染对象缓存管理器，按 (object, material, camera) 组合键缓存 RenderObject
 * @explain[zh-cn] 
 * RenderObjects 管理多个 RenderObject 实例，按 (object, material, camera) 组合键缓存，
 * 避免每帧重复创建 RenderObject。内部 HashMap 使用组合 Int64 键。
 * 对照源码: three.js/src/renderers/common/RenderObjects.js (131 行)
 *
 * @file[en] RenderObjects
 * @brief[en] Render object cache manager, caching RenderObject by (object, material, camera) composite key
 * @explain[en] 
 * RenderObjects manages multiple RenderObject instances, caching them by (object, material, camera) composite key,
 * avoiding repeated creation of RenderObject each frame. Internally uses a composite Int64 key.
 * Corresponding source: three.js/src/renderers/common/RenderObjects.js (131 lines)
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.utils.log.Logger
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.rendering.materials.*
import std.collection.*

/**
 * @brief[zh-cn] 渲染对象缓存管理器
 * @explain[zh-cn] 
 * 按 (object, material, camera) 组合键缓存 RenderObject，内部 HashMap 使用组合 Int64 键。
 *
 * @brief[en] Render object cache manager
 * @explain[en] 
 * Caches RenderObject by (object, material, camera) composite key. Internally uses a composite Int64 key.
 */
public open class RenderObjects {
    /**
     * @brief[zh-cn] 渲染对象缓存（组合键 -> RenderObject）
     */
    private var cache: HashMap<Int64, RenderObject>

    /**
     * @brief[zh-cn] 构造默认渲染对象缓存
     *
     * @brief[en] Constructs a default render object cache
     */
    public init() {
        this.cache = HashMap<Int64, RenderObject>()
    }

    /**
     * @brief[zh-cn] 获取或创建 (object, material, camera) 对应的 RenderObject
     * @explain[zh-cn] 
     * 若已有缓存的 RenderObject 则返回，否则新建并缓存。
     * @param[zh-cn] mesh 渲染对象
     * geometry 几何体
     * material 材质
     * context 渲染上下文
     * camera 相机
     * scene 场景
     * @return[zh-cn] RenderObject 实例
     *
     * @brief[en] Gets or creates the RenderObject for the given (object, material, camera)
     * @explain[en] 
     * If a cached RenderObject exists, returns it; otherwise, creates a new one and caches it.
     * @param[en] mesh Render object
     * geometry Geometry
     * material Material
     * context Render context
     * camera Camera
     * scene Scene
     * @return[en] RenderObject instance
     */
    public func get(mesh: Object3D, geometry: BufferGeometry, material: Material,
                    context: RenderContext, camera: Camera, scene: Scene): RenderObject {
        // ★关键修复（bgfx view 语义）：缓存 key 必须含 camera.id！
        //   对照 three.js WebGLRenderObjects.get：`key = object.id + material.id + camera.id`。
        //   此前 key 只含 mesh.id + material.uuid，导致渲反射场景（virtualCamera 镜像相机）
        //   时缓存命中渲 readBuffer（view 0）时创建的旧 RenderObject —— 其 context.viewId=0，
        //   draw 被提交到 view 0（readBuffer）而非反射 view 237，反射 RT 只有 clear 色、
        //   ReflectorShader 采样到空贴图 → 地面反射完全失效（capture 实证：reflectRT 全像素
        //   = renderer.clearColor 且 min==max、reflectDepthRT 100% far）。
        //   加 camera.id 后，主相机与镜像相机各用独立 RenderObject，viewId 正确。
        let key = mesh.id * 100000000 + material.uuid.hashCode() + camera.id
        Logger.trace(["RenderObjects.get", "mesh.id=${mesh.id} mesh.name=${mesh.name} mat.uuid=${material.uuid} camera.id=${camera.id} key=${key}"])
        match (this.cache.get(key)) {
            case Some(ro) =>
                Logger.trace(["RenderObjects.get", "CACHE HIT key=${key} cached.mesh.name=${ro.mesh.name}"])
                ro.updateWorldMatrix()
                return ro
            case None =>
                let ro = RenderObject(this.cache.size + 1, mesh, geometry, material,
                                     context, camera, scene)
                ro.updateWorldMatrix()
                this.cache.add(key, ro)
                return ro
        }
    }

    /**
     * @brief[zh-cn] 清空所有缓存
     *
     * @brief[en] Clears all caches
     */
    public func clear(): Unit {
        this.cache = HashMap<Int64, RenderObject>()
    }
}
