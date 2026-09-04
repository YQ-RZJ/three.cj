/**
 * @file[zh-cn] 挤出几何体
 * @brief[zh-cn] Shape 二维轮廓沿深度方向挤出的几何体
 * @explain[zh-cn] 
 * 完整实现：Shape 二维轮廓沿深度方向（z 轴）挤出。
 * 参考 JS 思路：前盖（z=0）/ 后盖（z=depth）/ 侧面（轮廓每段沿深度方向）。
 * 简化：无 bevel、无 extrudePath（直线深度挤出）。
 * 对应 Three.js geometries/ExtrudeGeometry.js。
 *
 * @file[en] Extrude Geometry
 * @brief[en] Geometry extruded from a 2D Shape contour along the depth direction
 * @explain[en] 
 * Full implementation: 2D Shape contour extruded along the depth direction (z-axis).
 * Reference JS approach: front cap (z=0) / back cap (z=depth) / side walls (each contour segment along depth).
 * Simplified: no bevel, no extrudePath (straight depth extrusion).
 * Corresponds to Three.js geometries/ExtrudeGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 挤出几何体类：Shape 轮廓 + 深度挤出
 * @explain[zh-cn] 
 * 将 Shape 二维轮廓沿深度方向挤出，生成前盖、后盖和侧面。
 *
 * @brief[en] Extrude geometry class: Shape contour + depth extrusion
 * @explain[en] 
 * Extrudes a 2D Shape contour along the depth direction, generating front cap, back cap and side walls.
 */
public class ExtrudeGeometry <: BufferGeometry {
    public var parameters: HashMap<String, Any>

    /// 无参构造：默认矩形轮廓 + depth=1
    public init() {
        super()
        this.kind = "ExtrudeGeometry"
        this.parameters = HashMap<String, Any>()
        let shape = Shape([Vector3(-1.0, -1.0, 0.0), Vector3(1.0, -1.0, 0.0), Vector3(1.0, 1.0, 0.0), Vector3(-1.0, 1.0, 0.0)])
        let options = HashMap<String, Any>()
        options.add("depth", 1.0)
        this.parameters.add("shape", shape); this.parameters.add("options", options)
        _buildExtrude(this, shape, options)
    }

    public init(shape: Shape, options: HashMap<String, Any>) {
        super()
        this.kind = "ExtrudeGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("shape", shape); this.parameters.add("options", options)
        _buildExtrude(this, shape, options)
    }
}

/// 顶层辅助：构建挤出数据（前/后盖 + 侧面 + 法线 + UV）
func _buildExtrude(g: ExtrudeGeometry, shape: Shape, options: HashMap<String, Any>): Unit {
    // 外轮廓点（z=0 平面 2D 轮廓）——用 getPoints 取外形（getPointsHoles 仅返回洞、无洞时为空）
    let contourArr = shape.getPoints(12)
    let contour = ArrayList<Vector3>(contourArr)
    let n = contour.size
    // 深度（options 或默认 1）
    var depth: Float64 = 1.0
    match (options.get("depth")) { case Some(d: Float64) => depth = d; case _ => () }

    if (n < 3) { return }  // 轮廓不足 3 点——空几何体

    // 轮廓三角化（Vector2——holes 空）
    let contour2 = ArrayList<Vector2>()
    for (p in contour) { contour2.add(Vector2(p.x, p.y)) }
    let holes = ArrayList<ArrayList<Vector2>>()
    let tris = ShapeUtils.triangulateShape(contour2, holes)

    // 顶点：连续排列（对照 Three.js：先全部 z=0、再全部 z=depth）
    // 注意：此前交错排列（front0,back0,front1,back1...）与索引假设
    // （0..n-1 前盖 / n..2n-1 后盖）完全错位 → 网格扭曲。
    let positions = ArrayList<Float64>()
    let uvs = ArrayList<Float64>()
    for (p in contour) {
        positions.add(p.x); positions.add(p.y); positions.add(0.0)      // z=0 层（后盖）
    }
    for (p in contour) {
        positions.add(p.x); positions.add(p.y); positions.add(depth)    // z=depth 层（前盖）
    }
    // UV（简化——轮廓坐标归一化）
    for (p in contour) { uvs.add(p.x * 0.5 + 0.5); uvs.add(p.y * 0.5 + 0.5) }
    for (p in contour) { uvs.add(p.x * 0.5 + 0.5); uvs.add(p.y * 0.5 + 0.5) }

    let indices = ArrayList<Int64>()
    // z=0 层盖面（后盖，法线 -Z）：反向序（对照 Three.js buildLidFaces bottom: f3(face[2], face[1], face[0])）
    for (tri in tris) {
        if (tri.size == 3) {
            indices.add(Int64(tri[2])); indices.add(Int64(tri[1])); indices.add(Int64(tri[0]))
        }
    }
    // z=depth 层盖面（前盖，法线 +Z）：正向序（对照 Three.js top: f3(face[0], face[1], face[2])）
    for (tri in tris) {
        if (tri.size == 3) {
            indices.add(Int64(tri[0]) + n); indices.add(Int64(tri[1]) + n); indices.add(Int64(tri[2]) + n)
        }
    }
    // 侧面（对照 Three.js sidewalls + f4：a=下层j, b=下层k, c=上层k, d=上层j）
    // 四边形 (a,b,c,d) 剖分为 (a,b,d) + (b,c,d)
    for (i in 0..n) {
        let j = i
        let k = i - 1
        let kk = if (k < 0) { n - 1 } else { k }
        let a = j; let b = kk; let c = kk + n; let d = j + n
        indices.add(Int64(a)); indices.add(Int64(b)); indices.add(Int64(d))
        indices.add(Int64(b)); indices.add(Int64(c)); indices.add(Int64(d))
    }

    let posArr = Array<Float64>(positions.size, { i => positions[i] })
    let uvArr = Array<Float64>(uvs.size, { i => uvs[i] })
    let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
    g.setIndex(BufferAttribute(idxArr, 1))
    g.setAttribute("position", BufferAttribute(posArr, 3))
    g.setAttribute("uv", BufferAttribute(uvArr, 2))
    // 法线：与 Three.js 原版一致，由 computeVertexNormals 按面 winding 自动计算
    // （前盖 +Z / 后盖 -Z / 侧壁水平向外），不再手动写死。
    g.computeVertexNormals()
}
