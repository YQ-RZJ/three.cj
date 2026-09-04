/**
 * @file[zh-cn] 点光源辅助对象
 * @brief[zh-cn] 点光源辅助对象，用于可视化点光源
 * @explain[zh-cn] 
 * 对应 Three.js helpers/PointLightHelper.js。用球形线框网格可视化点光源的位置，
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @file[en] Point Light Helper
 * @brief[en] Point light helper for visualizing point lights
 * @explain[en] 
 * Corresponds to Three.js helpers/PointLightHelper.js. Visualizes point light position
 * with a spherical wireframe mesh. Call update() when the light or its properties change.
 */
package three.rendering.helpers

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.lights.*

/**
 * @brief[zh-cn] 点光源辅助对象，用球形线框网格可视化点光源的位置
 * @explain[zh-cn] 
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @brief[en] Point light helper visualizing point light position with a spherical wireframe mesh
 * @explain[en] 
 * Call update() when the light or its properties change.
 */
public class PointLightHelper <: Mesh {
    /**
     * @brief[zh-cn] 被可视化的光源
     *
     * @brief[en] The light being visualized
     */
    public var light: Light

    /**
     * @brief[zh-cn] 颜色（可选，未设置时使用光源颜色）
     *
     * @brief[en] Color (optional, uses light color when not set)
     */
    public var color: Option<Color>

    /**
     * @brief[zh-cn] 构造点光源辅助对象
     * @param[zh-cn] light 要可视化的点光源
     * sphereSize 球体尺寸，默认 1
     * color 颜色，未设置时使用光源颜色
     *
     * @brief[en] Construct a point light helper
     * @param[en] light The point light to visualize
     * sphereSize Sphere size, default 1
     * color Color, uses light color when not set
     */
    public init(light: Light, sphereSize!: Float64 = 1.0, color!: Option<Color> = None<Color>) {
        super(geometry: SphereGeometry(radius: sphereSize, widthSegments: 4, heightSegments: 2), material: MeshBasicMaterial())
        this.light = light
        this.color = color
        this.kind = "PointLightHelper"
        
        // 缺 wireframe 时球体渲染为实心而非线框
        this.material.wireframe = true
        this.matrix = this.light.matrixWorld
        this.matrixAutoUpdate = false
        this.update()
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.geometry.dispose()
        this.material.dispose()
    }

    /**
     * @brief[zh-cn] 更新辅助对象以匹配光源位置
     *
     * @brief[en] Update helper to match light position
     */
    public func update(): Unit {
        this.matrixWorldNeedsUpdate = true
        this.light.updateWorldMatrix(true, false, false)
        match (this.color) {
            case Some(c) => this.material.color.copy(c)
            case None => this.material.color.copy(this.light.color)
        }
    }
}
