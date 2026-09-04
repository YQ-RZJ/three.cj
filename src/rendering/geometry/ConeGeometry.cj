/**
 * @file[zh-cn] 圆锥体几何体
 * @brief[zh-cn] 圆锥体几何体，CylinderGeometry 的特例（顶部半径为 0）
 * @explain[zh-cn] 
 * ConeGeometry 继承自 CylinderGeometry，对应 Three.js geometries/ConeGeometry.js。
 *
 * @file[en] Cone Geometry
 * @brief[en] Cone geometry, a special case of CylinderGeometry with top radius of 0
 * @explain[en] 
 * ConeGeometry extends CylinderGeometry, corresponding to Three.js geometries/ConeGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 圆锥体几何体类，是 CylinderGeometry 的特例（radiusTop = 0）
 * @explain[zh-cn] 
 * 圆锥体由底面圆和侧面组成，可设置是否开放底面。
 *
 * @brief[en] Cone geometry class, a special case of CylinderGeometry (radiusTop = 0)
 * @explain[en] 
 * A cone consists of a circular base and side faces, with an option for an open bottom.
 */
public class ConeGeometry <: CylinderGeometry {
    /**
     * @brief[zh-cn] 构造圆锥体几何体
     * @param[zh-cn] radius 底面半径，默认为 1
     * height 高度，默认为 1
     * radialSegments 径向段数，默认为 8
     * heightSegments 高度段数，默认为 1
     * openEnded 是否开放底面，默认为 false
     * thetaStart 起始角，默认为 0
     * thetaLength 角度范围，默认为 2π
     *
     * @brief[en] Constructs a cone geometry
     * @param[en] radius Bottom radius, default 1
     * height Height, default 1
     * radialSegments Radial segments, default 8
     * heightSegments Height segments, default 1
     * openEnded Whether the bottom is open, default false
     * thetaStart Start angle, default 0
     * thetaLength Angle length, default 2π
     */
    public init(radius!: Float64 = 1.0, height!: Float64 = 1.0, radialSegments!: Int64 = 8, heightSegments!: Int64 = 1, openEnded!: Bool = false, thetaStart!: Float64 = 0.0, thetaLength!: Float64 = PI * 2.0) {
        super()
        this.kind = "ConeGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("radius", radius); this.parameters.add("height", height)
        this.parameters.add("radialSegments", radialSegments); this.parameters.add("heightSegments", heightSegments)
        this.parameters.add("openEnded", openEnded); this.parameters.add("thetaStart", thetaStart)
        this.parameters.add("thetaLength", thetaLength)

        // 圆锥体 = CylinderGeometry(radiusTop=0, radiusBottom=radius, ...)
        let rSeg = max(3, radialSegments); let hSeg = max(1, heightSegments)
        let halfH = height / 2.0
        let vertices = ArrayList<Float64>(); let normals = ArrayList<Float64>(); let uvs = ArrayList<Float64>()
        let indices = ArrayList<Int64>()

        // 侧面
        for (iy in 0..=hSeg) {
            let v = Float64(iy) / Float64(hSeg)
            let r = radius * (1.0 - v)
            let y = -halfH + v * height
            for (ix in 0..=rSeg) {
                let u = Float64(ix) / Float64(rSeg)
                let theta = thetaStart + u * thetaLength
                let x = r * sin(theta); let z = r * cos(theta)
                vertices.add(x); vertices.add(y); vertices.add(z)
                // 法线：沿圆锥面外法线
                let nx = x / radius; let ny = radius / height; let nz = z / radius
                let len = sqrt(nx * nx + ny * ny + nz * nz)
                normals.add(nx / len); normals.add(ny / len); normals.add(nz / len)
                uvs.add(u); uvs.add(1.0 - v)
            }
        }
        for (iy in 0..hSeg) {
            for (ix in 0..rSeg) {
                let a = iy * (rSeg + 1) + ix; let b = iy * (rSeg + 1) + ix + 1
                let c = (iy + 1) * (rSeg + 1) + ix; let d = (iy + 1) * (rSeg + 1) + ix + 1
                indices.add(a); indices.add(b); indices.add(c)
                indices.add(b); indices.add(d); indices.add(c)
            }
        }
        // 底面（非 openEnded）
        if (!openEnded) {
            // 底面顶点
            vertices.add(0.0); vertices.add(-halfH); vertices.add(0.0)
            normals.add(0.0); normals.add(-1.0); normals.add(0.0)
            uvs.add(0.5); uvs.add(0.5)
            let centerIdx = (hSeg + 1) * (rSeg + 1)
            for (ix in 0..rSeg) {
                let u = Float64(ix) / Float64(rSeg)
                let theta = thetaStart + u * thetaLength
                let x = radius * sin(theta); let z = radius * cos(theta)
                vertices.add(x); vertices.add(-halfH); vertices.add(z)
                normals.add(0.0); normals.add(-1.0); normals.add(0.0)
                uvs.add((x / radius + 1.0) / 2.0); uvs.add((z / radius + 1.0) / 2.0)
            }
            for (i in 0..rSeg) {
                let next = (i + 1) % rSeg
                indices.add(centerIdx + 1 + i); indices.add(centerIdx + 1 + next); indices.add(centerIdx)
            }
        }
        let idxArr = Array<Float64>(indices.size, { i => Float64(indices[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(vertices.toArray(), 3))
        this.setAttribute("normal", BufferAttribute(normals.toArray(), 3))
        this.setAttribute("uv", BufferAttribute(uvs.toArray(), 2))
    }
}