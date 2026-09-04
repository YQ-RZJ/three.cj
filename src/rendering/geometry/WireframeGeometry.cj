/**
 * @file[zh-cn] 线框几何体
 * @brief[zh-cn] 从 BufferGeometry 提取线框边线
 * @explain[zh-cn] 
 * WireframeGeometry 继承自 BufferGeometry，从 BufferGeometry 中提取所有边线（去重）。
 * 使用 Set 做边去重（正反两个 hash 都登记），避免多面共边时同一条边被输出多次。
 * 对应 Three.js geometries/WireframeGeometry.js。
 *
 * @file[en] Wireframe Geometry
 * @brief[en] Extracts wireframe edges from BufferGeometry
 * @explain[en] 
 * WireframeGeometry extends BufferGeometry, extracting all unique edges from BufferGeometry.
 * Uses a Set for edge deduplication (both forward and reverse hashes are registered) to avoid outputting the same edge multiple times when faces share edges.
 * Corresponds to Three.js geometries/WireframeGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 线框几何体类，从 BufferGeometry 提取所有边线（去重）
 * @explain[zh-cn] 
 * 从 BufferGeometry 中提取所有边线，使用 Set 做边去重。
 *
 * @brief[en] Wireframe geometry class, extracting all unique edges from BufferGeometry
 * @explain[en] 
 * Extracts all edges from BufferGeometry, using a Set for edge deduplication.
 */
public class WireframeGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造线框几何体
     * @param[zh-cn] geometry 源 BufferGeometry
     *
     * @brief[en] Constructs a wireframe geometry
     * @param[en] geometry Source BufferGeometry
     */
    public init(geometry: BufferGeometry) {
        super()
        this.kind = "WireframeGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("geometry", geometry)

        let positionAttr = geometry.getAttribute("position")
        let indexAttr = geometry.getIndex()
        let vertices = ArrayList<Float64>()
        let posArr = if (let Some(p) <- positionAttr) { p.array } else { Array<Float64>(0, { _ => 0.0 }) }

        // 边去重集合：已输出的边 hash（正反都登记）
        let edges = HashSet<String>()
        let start = Vector3()
        let end = Vector3()

        if (let Some(idx) <- indexAttr) {
            let idxArr = idx.array
            let triCount = idxArr.size / 3
            for (i in 0..triCount) {
                let i0 = Int64(idxArr[i * 3])
                let i1 = Int64(idxArr[i * 3 + 1])
                let i2 = Int64(idxArr[i * 3 + 2])
                // 三条边：(i0,i1) (i1,i2) (i2,i0)
                if (isUniqueEdge(i0, i1, posArr, start, end, edges)) {
                    pushEdge(vertices, start, end)
                }
                if (isUniqueEdge(i1, i2, posArr, start, end, edges)) {
                    pushEdge(vertices, start, end)
                }
                if (isUniqueEdge(i2, i0, posArr, start, end, edges)) {
                    pushEdge(vertices, start, end)
                }
            }
        } else {
            // 没有索引，按连续三角形处理（每 3 个顶点一个三角形）
            let triCount = posArr.size / 9
            for (i in 0..triCount) {
                let base = i * 9
                for (j in 0..3) {
                    let aIdx = base + j * 3
                    let bIdx = base + ((j + 1) % 3) * 3
                    let a = Int64(aIdx / 3)
                    let b = Int64(bIdx / 3)
                    if (isUniqueEdge(a, b, posArr, start, end, edges)) {
                        pushEdge(vertices, start, end)
                    }
                }
            }
        }
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
    }
}

/// 取索引 index1、index2 对应的两端顶点；若该边（正反任一）已输出过则跳过
func isUniqueEdge(index1: Int64, index2: Int64, posArr: Array<Float64>, start: Vector3, end: Vector3, edges: HashSet<String>): Bool {
    let i1 = index1 * 3
    let i2 = index2 * 3
    start.set(posArr[i1], posArr[i1 + 1], posArr[i1 + 2])
    end.set(posArr[i2], posArr[i2 + 1], posArr[i2 + 2])
    let hash1 = "${start.x},${start.y},${start.z}-${end.x},${end.y},${end.z}"
    let hash2 = "${end.x},${end.y},${end.z}-${start.x},${start.y},${start.z}"
    if (edges.contains(hash1) || edges.contains(hash2)) {
        return false
    }
    edges.add(hash1)
    edges.add(hash2)
    return true
}

/// 输出一条边的两端顶点（start、end）
func pushEdge(vertices: ArrayList<Float64>, start: Vector3, end: Vector3): Unit {
    vertices.add(start.x); vertices.add(start.y); vertices.add(start.z)
    vertices.add(end.x); vertices.add(end.y); vertices.add(end.z)
}
