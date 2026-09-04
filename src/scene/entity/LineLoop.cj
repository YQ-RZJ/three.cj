/**
 * @file[zh-cn] LineLoop 线环
 * @brief[zh-cn] 从一组顶点构造的闭合线段，首末顶点自动连接成环
 * @explain[zh-cn] 继承自 Line，仅类型标志不同；raycast 等行为与 Line 一致
 *
 * @file[en] LineLoop  Line loop
 * @brief[en] Closed line loop constructed from vertices, first and last vertices auto-connected
 * @explain[en] Inherits from Line with only the type flag different; raycast behavior matches Line
 */
package three.scene.entity
import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*

/**
 * @brief[zh-cn] 线环，首末顶点自动连接成环的闭合折线
 *
 * @brief[en] Line loop, a closed polyline with first and last vertices auto-connected
 */
public class LineLoop <: Line {

    /**
     * @brief[zh-cn] 构造一个新的线环
     * @param[zh-cn] geometry 顶点/索引几何，默认空 BufferGeometry
     * material 线材质，默认空 LineBasicMaterial
     *
     * @brief[en] Construct a new line loop
     * @param[en] geometry Vertex/index geometry, default empty BufferGeometry
     * material Line material, default LineBasicMaterial
     */
    public init(geometry!: BufferGeometry = BufferGeometry(), material!: Material = LineBasicMaterial()) {
        super(geometry: geometry, material: material)
        this.kind = "LineLoop"
    }
}
