/**
 * @file[zh-cn] 胶囊体几何体
 * @brief[zh-cn] 由圆柱体 + 两个半球帽组成的胶囊体几何体
 * @explain[zh-cn] 
 * CapsuleGeometry 继承自 BufferGeometry，由圆柱体中间段和两个半球帽组成。
 * 对应 Three.js geometries/CapsuleGeometry.js。
 *
 * @file[en] Capsule Geometry
 * @brief[en] Capsule geometry composed of a cylinder and two hemispherical caps
 * @explain[en] 
 * CapsuleGeometry extends BufferGeometry, composed of a cylindrical middle section and two hemispherical caps.
 * Corresponds to Three.js geometries/CapsuleGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 胶囊体几何体类，由圆柱体中间段和两个半球帽组成
 * @explain[zh-cn] 
 * 生成胶囊体的顶点、法线、UV 和索引数据，支持帽段数、径向段数和高度段数设置。
 *
 * @brief[en] Capsule geometry class, composed of a cylindrical middle section and two hemispherical caps
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a capsule, supporting cap segments, radial segments and height segments settings.
 */
public class CapsuleGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 几何体生成参数
     *
     * @brief[en] Geometry generation parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造胶囊体几何体
     * @param[zh-cn] radius 半径，默认为 1
     * length 圆柱段长度，默认为 1
     * capSegments 帽段数，默认为 4
     * radialSegments 径向段数，默认为 8
     * heightSegments 高度段数，默认为 1
     *
     * @brief[en] Constructs a capsule geometry
     * @param[en] radius Radius, default 1
     * length Cylinder section length, default 1
     * capSegments Cap segments, default 4
     * radialSegments Radial segments, default 8
     * heightSegments Height segments, default 1
     */
    public init(radius!: Float64 = 1.0, length!: Float64 = 1.0, capSegments!: Int64 = 4, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1) {
        super()
        this.kind = "CapsuleGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("length", length)
        this.parameters.add("capSegments", capSegments); this.parameters.add("radialSegments", radialSegments)
        this.parameters.add("heightSegments", heightSegments)

        let h = max(0.0, length); let cSeg = max(1, capSegments); let rSeg = max(3, radialSegments); let hSeg = max(1, heightSegments)
        let halfH = h / 2.0
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        // 生成顶点
        for (j in 0..=(cSeg + hSeg + cSeg)) {
            var v = Float64(j) / Float64(cSeg + hSeg + cSeg)
            var theta: Float64
            if (j <= cSeg) { // 上帽半球
                theta = PI * 0.5 * (1.0 - Float64(j) / Float64(cSeg))
                theta = max(0.0, theta)
            } else if (j <= cSeg + hSeg) { // 中间圆柱
                theta = 0.0
            } else { // 下帽半球
                let t = Float64(j - cSeg - hSeg) / Float64(cSeg)
                theta = -PI * 0.5 * t
            }
            let y = radius * sin(theta) + (if (j <= cSeg) { halfH } else if (j <= cSeg + hSeg) { halfH - Float64(j - cSeg) / Float64(hSeg) * h } else { -halfH })
            let ringRadius = radius * cos(theta)
            for (i in 0..=rSeg) {
                let u = Float64(i) / Float64(rSeg)
                let phi = u * PI * 2.0
                let x = ringRadius * cos(phi); let z = ringRadius * sin(phi)
                vertices.add(x); vertices.add(y); vertices.add(z)
                let len = sqrt(x * x + y * y + z * z)
                if (len > 0.0) { normals.add(x / len); normals.add(y / len); normals.add(z / len) }
                else { normals.add(0.0); normals.add(1.0); normals.add(0.0) }
                uvs.add(u); uvs.add(1.0 - v)
            }
        }
        // 生成索引
        let totalVSeg = cSeg + hSeg + cSeg
        for (j in 0..totalVSeg) {
            for (i in 0..rSeg) {
                let a = (rSeg + 1) * j + i
                let b = (rSeg + 1) * (j + 1) + i
                let c = (rSeg + 1) * (j + 1) + i + 1
                let d = (rSeg + 1) * j + i + 1
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