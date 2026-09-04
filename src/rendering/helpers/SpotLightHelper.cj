/**
 * @file[zh-cn] 聚光灯辅助对象
 * @brief[zh-cn] 聚光灯辅助对象，用于可视化聚光灯的锥体范围
 * @explain[zh-cn] 
 * 对应 Three.js helpers/SpotLightHelper.js。用锥体线框可视化聚光灯的照射范围，
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @file[en] Spot Light Helper
 * @brief[en] Spot light helper for visualizing spot light cone range
 * @explain[en] 
 * Corresponds to Three.js helpers/SpotLightHelper.js. Visualizes spot light illumination range
 * with a cone wireframe. Call update() when the light or its properties change.
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
import three.rendering.lights.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 聚光灯辅助对象，用锥体线框可视化聚光灯的照射范围
 * @explain[zh-cn] 
 * 当光源变换或属性改变时，需要调用 update() 方法更新。
 *
 * @brief[en] Spot light helper visualizing illumination range with a cone wireframe
 * @explain[en] 
 * Call update() when the light or its properties change.
 */
public class SpotLightHelper <: Object3D {
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
     * @brief[zh-cn] 锥体线框
     *
     * @brief[en] Cone wireframe
     */
    public var cone: LineSegments

    /**
     * @brief[zh-cn] 构造聚光灯辅助对象
     * @param[zh-cn] light 要可视化的聚光灯
     * color 颜色，未设置时使用光源颜色
     *
     * @brief[en] Construct a spot light helper
     * @param[en] light The spot light to visualize
     * color Color, uses light color when not set
     */
    public init(light: Light, color!: Option<Color> = None<Color>) {
        super()
        this.light = light
        this.color = color
        this.kind = "SpotLightHelper"
        this.matrixAutoUpdate = false

        let geometry = BufferGeometry()
        let positions = ArrayList<Float64>()
        
        let conePositions = [
            0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
            0.0, 0.0, 0.0, 1.0, 0.0, 1.0,
            0.0, 0.0, 0.0, -1.0, 0.0, 1.0,
            0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
            0.0, 0.0, 0.0, 0.0, -1.0, 1.0
        ]
        for (v in conePositions) { positions.add(v) }
        
        let l: Int64 = 32
        for (i in 0..l) {
            let j = i + 1
            let p1 = (Float64(i) / Float64(l)) * PI * 2.0
            let p2 = (Float64(j) / Float64(l)) * PI * 2.0
            positions.add(cos(p1)); positions.add(sin(p1)); positions.add(1.0)
            positions.add(cos(p2)); positions.add(sin(p2)); positions.add(1.0)
        }
        geometry.setAttribute("position", BufferAttribute(positions.toArray(), 3))
        let material = LineBasicMaterial()
        this.cone = LineSegments(geometry: geometry, material: material)
        this.children.add(this.cone)
        this.update()
    }

    /**
     * @brief[zh-cn] 更新辅助对象以匹配光源位置和角度
     * @explain[zh-cn] 
     * 本对象矩阵 = parent.matrixWorld⁻¹ × light.matrixWorld；
     * 锥体按 distance/angle 缩放并朝向 target。
     *
     * @brief[en] Update helper to match light position and angle
     * @explain[en] 
     * Local matrix = parent.matrixWorld⁻¹ × light.matrixWorld;
     * cone scales by distance/angle and faces target.
     */
    public func update(): Unit {
        this.light.updateWorldMatrix(true, false, false)
        
        match (this.light) {
            case sl: SpotLight => sl.target.updateWorldMatrix(true, false, false)
            case _ => ()
        }

        
        match (this.parent) {
            case Some(p) =>
                p.updateWorldMatrix(true, false, false)
                let inv = Matrix4().copy(p.matrixWorld).invert()
                this.matrix.copy(inv).multiply(this.light.matrixWorld)
            case None =>
                this.matrix.copy(this.light.matrixWorld)
        }
        this.matrixWorldNeedsUpdate = true

        
        var coneLength: Float64 = 1000.0
        var coneWidth: Float64 = 0.0
        match (this.light) {
            case sl: SpotLight =>
                coneLength = if (sl.distance > 0.0) { sl.distance } else { 1000.0 }
                coneWidth = coneLength * tan(sl.angle)
            case _ => ()
        }
        this.cone.scale.set(coneWidth, coneWidth, coneLength)

        
        let targetPos = Vector3()
        match (this.light) {
            case sl: SpotLight => targetPos.setFromMatrixPosition(sl.target.matrixWorld)
            case _ => ()
        }
        this.cone.lookAt(targetPos)

        match (this.color) {
            case Some(c) => this.cone.material.color.copy(c)
            case None => this.cone.material.color.copy(this.light.color)
        }
    }

    /**
     * @brief[zh-cn] 释放 GPU 资源
     *
     * @brief[en] Dispose GPU resources
     */
    public func dispose(): Unit {
        this.cone.geometry.dispose()
        this.cone.material.dispose()
    }
}
