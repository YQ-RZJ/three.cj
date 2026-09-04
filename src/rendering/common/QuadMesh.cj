/**
 * @file[zh-cn] 四边形网格
 * @brief[zh-cn] 全屏四边形网格，用于后处理等全屏渲染 pass
 * @explain[zh-cn] 
 * QuadMesh 封装了一个全屏四边形的几何体和材质，用于后处理 pass、blit 操作等
 * 需要全屏渲染的场景。对应 Three.js 中的 QuadMesh 概念。
 *
 * @file[en] QuadMesh
 * @brief[en] Fullscreen quad mesh, used for post-processing and other fullscreen render passes
 * @explain[en] 
 * QuadMesh encapsulates the geometry and material of a fullscreen quad, used for post-processing passes, blit operations,
 * and other scenarios requiring fullscreen rendering. Corresponds to the QuadMesh concept in Three.js.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] 全屏四边形网格
 * @explain[zh-cn] 
 * 封装全屏四边形的几何体和材质，用于后处理和 blit 操作。
 *
 * @brief[en] Fullscreen quad mesh
 * @explain[en] 
 * Encapsulates the geometry and material of a fullscreen quad, used for post-processing and blit operations.
 */
public open class QuadMesh {
    /**
     * @brief[zh-cn] 四边形几何体
     *
     * @brief[en] Quad geometry
     */
    public var geometry: BufferGeometry

    /**
     * @brief[zh-cn] 四边形材质
     *
     * @brief[en] Quad material
     */
    public var material: Material

    /**
     * @brief[zh-cn] 构造默认四边形网格
     *
     * @brief[en] Constructs a default quad mesh
     */
    public init() {
        this.geometry = BufferGeometry()
        this.material = Material()
    }

    /**
     * @brief[zh-cn] 渲染四边形
     * @param[zh-cn] renderer 渲染器
     *
     * @brief[en] Renders the quad
     * @param[en] renderer Renderer
     */
    public func render(renderer: Renderer): Unit { }
}
