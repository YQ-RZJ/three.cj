/**
 * @file[zh-cn] 圆柱几何体
 * @brief[zh-cn] 圆柱几何体，由侧面和可选的顶底封闭面组成
 * @explain[zh-cn] 
 * CylinderGeometry 继承自 BufferGeometry，生成圆柱体的顶点、法线、UV 和索引数据。
 * 包含 torso（侧面）和 top/bottom cap（顶底封闭面，openEnded=false 时）。
 * 对应 Three.js geometries/CylinderGeometry.js。
 *
 * @file[en] Cylinder Geometry
 * @brief[en] Cylinder geometry composed of a torso and optional top/bottom caps
 * @explain[en] 
 * CylinderGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a cylinder.
 * Includes torso (side) and top/bottom cap (when openEnded=false).
 * Corresponds to Three.js geometries/CylinderGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 圆柱几何体类
 * @explain[zh-cn] 
 * 参照 Three.js CylinderGeometry.js 实现，包含 torso（侧面）和 top/bottom cap（顶底封闭面，openEnded=false 时）。
 *
 * @brief[en] Cylinder geometry class
 * @explain[en] 
 * Implements Three.js CylinderGeometry.js, including torso (side) and top/bottom cap (when openEnded=false).
 */
public open class CylinderGeometry <: BufferGeometry {
    public var parameters: HashMap<String, Any>

    public init(radiusTop!: Float64 = 1.0, radiusBottom!: Float64 = 1.0, height!: Float64 = 1.0, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1, openEnded!: Bool = false, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0) {
        super()
        this.kind = "CylinderGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radiusTop", radiusTop); this.parameters.add("radiusBottom", radiusBottom)
        this.parameters.add("height", height); this.parameters.add("radialSegments", radialSegments)
        this.parameters.add("heightSegments", heightSegments); this.parameters.add("openEnded", openEnded)
        this.parameters.add("thetaStart", thetaStart); this.parameters.add("thetaLength", thetaLength)

        let rSeg = max(3, Int64(radialSegments))
        let hSeg = max(1, Int64(heightSegments))
        let halfH = height / 2.0

        let vertices = ArrayList<Float64>()
        let normals = ArrayList<Float64>()
        let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        // ---- torso（侧面）----
        // indexArray[y][x]：第 y 行第 x 列顶点的全局索引
        let indexArray = ArrayList<ArrayList<Int64>>()
        var index: Int64 = 0
        let slope = (radiusBottom - radiusTop) / height

        for (y in 0..=hSeg) {
            let indexRow = ArrayList<Int64>()
            let v = Float64(y) / Float64(hSeg)
            let radius = v * (radiusBottom - radiusTop) + radiusTop
            for (x in 0..=rSeg) {
                let u = Float64(x) / Float64(rSeg)
                let theta = u * thetaLength + thetaStart
                let sinTheta = sin(theta)
                let cosTheta = cos(theta)
                // vertex
                vertices.add(radius * sinTheta)
                vertices.add(-v * height + halfH)
                vertices.add(radius * cosTheta)
                // normal
                let nx = sinTheta; let ny = slope; let nz = cosTheta
                let len = sqrt(nx * nx + ny * ny + nz * nz)
                if (len > 0.0) {
                    normals.add(nx / len); normals.add(ny / len); normals.add(nz / len)
                } else {
                    normals.add(0.0); normals.add(1.0); normals.add(0.0)
                }
                // uv
                uvs.add(u); uvs.add(1.0 - v)
                // 索引
                indexRow.add(index)
                index++
            }
            indexArray.add(indexRow)
        }

        // torso 索引
        for (x in 0..rSeg) {
            for (y in 0..hSeg) {
                let a = indexArray[y][x]
                let b = indexArray[y + 1][x]
                let c = indexArray[y + 1][x + 1]
                let d = indexArray[y][x + 1]
                if (radiusTop > 0.0 || y != 0) {
                    indices.add(a); indices.add(b); indices.add(d)
                }
                if (radiusBottom > 0.0 || y != hSeg - 1) {
                    indices.add(b); indices.add(c); indices.add(d)
                }
            }
        }

        // ---- cap（顶底封闭面）----
        if (!openEnded) {
            if (radiusTop > 0.0) {
                index = _generateCap(vertices, normals, uvs, indices, true, radiusTop, halfH, rSeg, thetaStart, thetaLength, index)
            }
            if (radiusBottom > 0.0) {
                index = _generateCap(vertices, normals, uvs, indices, false, radiusBottom, halfH, rSeg, thetaStart, thetaLength, index)
            }
        }

        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        let (attrs, idxAttr) = _buildCylinderAttributes(vertices, normals, uvs, idxArr)
        // open 类构造器不能 this 方法调用（setIndex/setAttribute）——字段直接赋值
        this.attributes = attrs
        this.index = Some(idxAttr)
    }

    /// 生成一个 cap（顶或底），返回更新后的 index
    /// top=true 顶 cap（y=+halfH，法线 +Y）
    /// top=false 底 cap（y=-halfH，法线 -Y）
    static func _generateCap(
        vertices: ArrayList<Float64>, normals: ArrayList<Float64>, uvs: ArrayList<Float64>, indices: ArrayList<Int64>,
        top: Bool, radius: Float64, halfH: Float64, rSeg: Int64, thetaStart: Float64, thetaLength: Float64,
        index: Int64
    ): Int64 {
        var idx = index
        let sign: Float64 = if (top) { 1.0 } else { -1.0 }
        // centerIndexStart：第一个中心顶点的索引
        let centerIndexStart = idx

        // 先生成中心顶点（每个扇形段一个，因为每面需独立 uv）
        for (x in 1..=rSeg) {
            // vertex
            vertices.add(0.0); vertices.add(halfH * sign); vertices.add(0.0)
            // normal
            normals.add(0.0); normals.add(sign); normals.add(0.0)
            // uv
            uvs.add(0.5); uvs.add(0.5)
            // index
            idx++
        }
        // 保存最后一个中心顶点的索引
        let centerIndexEnd = idx

        // 周边顶点
        for (x in 0..=rSeg) {
            let u = Float64(x) / Float64(rSeg)
            let theta = u * thetaLength + thetaStart
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)
            // vertex
            vertices.add(radius * sinTheta); vertices.add(halfH * sign); vertices.add(radius * cosTheta)
            // normal
            normals.add(0.0); normals.add(sign); normals.add(0.0)
            // uv
            uvs.add(cosTheta * 0.5 + 0.5); uvs.add(sinTheta * 0.5 * sign + 0.5)
            // index
            idx++
        }

        // 索引（顶 cap 与底 cap 三角形顶点顺序相反，保证外法线朝外）
        for (x in 0..rSeg) {
            let c = centerIndexStart + x
            let i = centerIndexEnd + x
            if (top) {
                indices.add(i); indices.add(i + 1); indices.add(c)
            } else {
                indices.add(i + 1); indices.add(i); indices.add(c)
            }
        }
        return idx
    }

    /// open 类构造器不能 this 方法调用——构建数据由静态方法计算（BufferAttribute 构造非 this）
    static func _buildCylinderAttributes(vertices: ArrayList<Float64>, normals: ArrayList<Float64>, uvs: ArrayList<Float64>, idxArr: Array<Float64>): (HashMap<String, BufferAttribute>, BufferAttribute) {
        let attrs = HashMap<String, BufferAttribute>()
        attrs.add("position", BufferAttribute(vertices.toArray(), 3))
        attrs.add("normal", BufferAttribute(normals.toArray(), 3))
        attrs.add("uv", BufferAttribute(uvs.toArray(), 2))
        return (attrs, BufferAttribute(idxArr, 1))
    }
}
