/**
 * @file[zh-cn] 形状几何体
 * @brief[zh-cn] 从 Shape（2D 轮廓）三角化生成平面网格
 * @explain[zh-cn] 
 * ShapeGeometry 继承自 BufferGeometry，取 shape 外形点 + holes，
 * 用 ShapeUtils.triangulateShape 三角化，顶点 z=0、法线 +Z。
 * 对应 Three.js geometries/ShapeGeometry.js。
 *
 * @file[en] Shape Geometry
 * @brief[en] Generates a plane mesh from a Shape (2D contour) via triangulation
 * @explain[en] 
 * ShapeGeometry extends BufferGeometry, taking shape outer contour points + holes,
 * triangulated using ShapeUtils.triangulateShape, with vertex z=0 and normal +Z.
 * Corresponds to Three.js geometries/ShapeGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 形状几何体类，从 Shape 三角化生成平面网格
 * @explain[zh-cn] 
 * 取 shape 外形点 + holes，
 * 用 ShapeUtils.triangulateShape 三角化，顶点 z=0、法线 +Z。
 *
 * @brief[en] Shape geometry class, generating a plane mesh from a Shape via triangulation
 * @explain[en] 
 * takes shape outer contour points + holes,
 * triangulated using ShapeUtils.triangulateShape, with vertex z=0 and normal +Z.
 */
public class ShapeGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造形状几何体
     * @param[zh-cn] shape 定义外形的 Shape 对象
     * curveSegments 曲线分段数，默认 12
     *
     * @brief[en] Constructs a shape geometry
     * @param[en] shape Shape object defining the outline
     * curveSegments Curve segments, default 12
     */
    public init(shape: Shape, curveSegments!: Int64 = 12) {
        super()
        this.kind = "ShapeGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("shape", shape); this.parameters.add("curveSegments", curveSegments)

        // shape.getPoints 返回 Array<Vector3>（外形轮廓点）
        let shapePtsArr = shape.getPoints(curveSegments)
        // holes：Array<Array<Vector3>>，每个洞的轮廓点
        let holesPtsArr = shape.getPointsHoles(curveSegments)

        // 转 Vector2（取 x,y，丢弃 z）
        var sv: Array<Vector2> = Array<Vector2>(shapePtsArr.size, { i => Vector2(shapePtsArr[i].x, shapePtsArr[i].y) })
        var shapeHolesArr: ArrayList<ArrayList<Vector2>> = ArrayList<ArrayList<Vector2>>()
        for (i in 0..holesPtsArr.size) {
            let hole3 = holesPtsArr[i]
            let hole2 = ArrayList<Vector2>()
            for (j in 0..hole3.size) {
                hole2.add(Vector2(hole3[j].x, hole3[j].y))
            }
            shapeHolesArr.add(hole2)
        }

        // 统一缠绕方向：外形 CCW、洞 CW（与 Three.js 一致）
        if (!ShapeUtils.isClockWise(sv)) { sv.reverse() }
        for (i in 0..shapeHolesArr.size) {
            let holeArr = shapeHolesArr[i].toArray()
            if (ShapeUtils.isClockWise(holeArr)) { holeArr.reverse() }
            shapeHolesArr[i] = ArrayList<Vector2>()
            for (v in holeArr) { shapeHolesArr[i].add(v) }
        }

        // 三角化（外形 + 洞）
        let shapeVertsArr = ArrayList<Vector2>()
        for (v in sv) { shapeVertsArr.add(v) }
        let faces = ShapeUtils.triangulateShape(shapeVertsArr, shapeHolesArr)

        // 拼合所有顶点（外形 + 各洞）
        let allVerts = ArrayList<Vector2>()
        for (v in sv) { allVerts.add(v) }
        for (i in 0..shapeHolesArr.size) { for (v in shapeHolesArr[i]) { allVerts.add(v) } }

        // 输出顶点/法线/UV（z=0，法线 +Z）
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()
        let nVerts = allVerts.size
        for (i in 0..nVerts) {
            vertices.add(allVerts[i].x); vertices.add(allVerts[i].y); vertices.add(0.0)
            normals.add(0.0); normals.add(0.0); normals.add(1.0)
            uvs.add(allVerts[i].x); uvs.add(allVerts[i].y)
        }

        // 索引（三角化结果）
        let indexOffset = 0
        for (i in 0..faces.size) {
            let faceArr = faces[i]
            for (j in 0..faceArr.size) {
                indices.add(Int64(faceArr[j]) + indexOffset)
            }
        }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}
