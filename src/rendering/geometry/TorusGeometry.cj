/**
 * @file[zh-cn] 圆环几何体
 * @brief[zh-cn] 圆环体（甜甜圈形）几何体
 * @explain[zh-cn] 
 * TorusGeometry 继承自 BufferGeometry，生成圆环体的顶点、法线、UV 和索引数据。
 * 对应 Three.js geometries/TorusGeometry.js。
 *
 * @file[en] Torus Geometry
 * @brief[en] Torus (donut-shaped) geometry
 * @explain[en] 
 * TorusGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a torus.
 * Corresponds to Three.js geometries/TorusGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 圆环几何体类
 * @explain[zh-cn] 
 * 生成圆环体的顶点、法线、UV 和索引数据，支持环半径、管半径、分段数和弧长参数。
 *
 * @brief[en] Torus geometry class
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a torus, supporting ring radius, tube radius, segments, and arc parameters.
 */
public class TorusGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 构造参数
     *
     * @brief[en] Construction parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造圆环几何体
     * @param[zh-cn] radius 环半径（中心到管中心），默认 1.0
     * tube 管半径，默认 0.4
     * radialSegments 径向分段数，默认 12
     * tubularSegments 管状分段数，默认 48
     * arc 弧长（弧度），默认 2π
     * thetaStart 径向起始角，默认 0
     * thetaLength 径向弧长，默认 2π
     *
     * @brief[en] Constructs a torus geometry
     * @param[en] radius Ring radius (center to tube center), default 1.0
     * tube Tube radius, default 0.4
     * radialSegments Radial segments, default 12
     * tubularSegments Tubular segments, default 48
     * arc Arc length in radians, default 2π
     * thetaStart Radial start angle, default 0
     * thetaLength Radial arc length, default 2π
     */
    public init(radius!: Float64 = 1.0, tube!: Float64 = 0.4, radialSegments!: Int64 = 12, tubularSegments!: Int64 = 48, arc!: Float64 = PI * 2.0, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0) {
        super()
        this.kind = "TorusGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("tube", tube)
        this.parameters.add("radialSegments", radialSegments); this.parameters.add("tubularSegments", tubularSegments)
        this.parameters.add("arc", arc); this.parameters.add("thetaStart", thetaStart)
        this.parameters.add("thetaLength", thetaLength)

        let rSeg = radialSegments; let tSeg = tubularSegments
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        for (j in 0..=rSeg) {
            let v = thetaStart + Float64(j) / Float64(rSeg) * thetaLength
            for (i in 0..=tSeg) {
                let u = Float64(i) / Float64(tSeg) * arc
                let x = (radius + tube * cos(v)) * cos(u)
                let y = (radius + tube * cos(v)) * sin(u)
                let z = tube * sin(v)
                vertices.add(x); vertices.add(y); vertices.add(z)
                let cx = radius * cos(u); let cy = radius * sin(u)
                let nx = x - cx; let ny = y - cy; let nz = z
                let len = sqrt(nx * nx + ny * ny + nz * nz)
                normals.add(nx / len); normals.add(ny / len); normals.add(nz / len)
                uvs.add(Float64(i) / Float64(tSeg)); uvs.add(Float64(j) / Float64(rSeg))
            }
        }

        for (j in 1..=rSeg) {
            for (i in 1..=tSeg) {
                let a = (tSeg + 1) * j + i - 1
                let b = (tSeg + 1) * (j - 1) + i - 1
                let c = (tSeg + 1) * (j - 1) + i
                let d = (tSeg + 1) * j + i
                indices.add(a); indices.add(b); indices.add(d)
                indices.add(b); indices.add(c); indices.add(d)
            }
        }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}