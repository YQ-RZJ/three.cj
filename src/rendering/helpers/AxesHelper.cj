/**
 * @file[zh-cn] 坐标轴辅助对象
 * @brief[zh-cn] 坐标轴辅助对象，用于可视化 X/Y/Z 坐标轴
 * @explain[zh-cn] 
 * 对应 Three.js helpers/AxesHelper.js。以红-绿-蓝线段分别表示 X-Y-Z 轴，
 * 支持自定义各轴颜色。
 *
 * @file[en] Axes Helper
 * @brief[en] Axes helper for visualizing X/Y/Z axes
 * @explain[en] 
 * Corresponds to Three.js helpers/AxesHelper.js. Displays X-Y-Z axes as red-green-blue
 * line segments, supports custom axis colors.
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

/**
 * @brief[zh-cn] 坐标轴辅助对象，用于可视化 X/Y/Z 坐标轴
 * @explain[zh-cn] 
 * 以红-绿-蓝线段分别表示 X-Y-Z 轴，支持自定义各轴颜色。
 *
 * @brief[en] Axes helper for visualizing X/Y/Z axes
 * @explain[en] 
 * Displays X-Y-Z axes as red-green-blue line segments, supports custom axis colors.
 */
public class AxesHelper <: LineSegments {
    /**
     * @brief[zh-cn] 构造坐标轴辅助对象
     * @param[zh-cn] size 轴线长度，默认 1
     *
     * @brief[en] Construct an axes helper
     * @param[en] size Axis line length, default 1
     */
    public init(size!: Float64 = 1.0) {
        super(geometry: BufferGeometry(), material: LineBasicMaterial())
        this.kind = "AxesHelper"
        
        let vertices = Array<Float64>(18, { i =>
            [0.0, 0.0, 0.0, size, 0.0, 0.0,
             0.0, 0.0, 0.0, 0.0, size, 0.0,
             0.0, 0.0, 0.0, 0.0, 0.0, size][i]
        })
        
        // （X 轴红渐变、Y 轴绿渐变、Z 轴蓝渐变；此前写错为灰阶导致轴颜色异常）
        let colors = Array<Float64>(18, { i =>
            [1.0, 0.0, 0.0, 1.0, 0.6, 0.0,
             0.0, 1.0, 0.0, 0.6, 1.0, 0.0,
             0.0, 0.0, 1.0, 0.0, 0.6, 1.0][i]
        })
        this.geometry.setAttribute("position", BufferAttribute(vertices, 3))
        this.geometry.setAttribute("color", BufferAttribute(colors, 3))
        
        // 缺 vertexColors 时 color 属性不参与渲染 → 轴显示为材质单色
        this.material.vertexColors = true
    }

    /**
     * @brief[zh-cn] 设置各轴颜色
     * @param[zh-cn] xAxisColor X 轴颜色
     * yAxisColor Y 轴颜色
     * zAxisColor Z 轴颜色
     * @return[zh-cn] 自身引用
     *
     * @brief[en] Set colors for each axis
     * @param[en] xAxisColor X axis color
     * yAxisColor Y axis color
     * zAxisColor Z axis color
     * @return[en] Self reference
     */
    public func setColors(xAxisColor: Color, yAxisColor: Color, zAxisColor: Color): AxesHelper {
        let array = this.geometry.attributes.get("color")
        match (array) {
            case Some(attr) =>
                xAxisColor.toArray(attr.array, offset: 0)
                xAxisColor.toArray(attr.array, offset: 3)
                yAxisColor.toArray(attr.array, offset: 6)
                yAxisColor.toArray(attr.array, offset: 9)
                zAxisColor.toArray(attr.array, offset: 12)
                zAxisColor.toArray(attr.array, offset: 15)
                
                attr.version += 1
            case None => ()
        }
        return this
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
}
