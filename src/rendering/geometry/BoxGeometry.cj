/**
 * @file[zh-cn] 长方体几何体
 * @brief[zh-cn] 长方体（立方体）几何体，由宽、高、深及分段数定义
 * @explain[zh-cn] 
 * BoxGeometry 继承自 BufferGeometry，生成六面长方体的顶点、法线、UV 和索引数据。
 * 对应 Three.js geometries/BoxGeometry.js。
 *
 * @file[en] Box Geometry
 * @brief[en] Box (cuboid) geometry defined by width, height, depth and segment counts
 * @explain[en] 
 * BoxGeometry extends BufferGeometry, generating vertex, normal, UV and index data for a six-faced box.
 * Corresponds to Three.js geometries/BoxGeometry.js.
 */
package three.rendering.geometry

import three.rendering.buffer.*
import three.core.math.*
import std.collection.*

/**
 * @brief[zh-cn] 长方体几何体类
 * @explain[zh-cn] 
 * 生成六面长方体的顶点、法线、UV 和索引数据，支持分段数设置。
 *
 * @brief[en] Box geometry class
 * @explain[en] 
 * Generates vertex, normal, UV and index data for a six-faced box, supporting segment count settings.
 */
public class BoxGeometry <: BufferGeometry {
    /**
     * @brief[zh-cn] 几何体生成参数
     *
     * @brief[en] Geometry generation parameters
     */
    public var parameters: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造长方体几何体
     * @param[zh-cn] width 宽度，默认为 1
     * height 高度，默认为 1
     * depth 深度，默认为 1
     * widthSegments 宽度方向分段数，默认为 1
     * heightSegments 高度方向分段数，默认为 1
     * depthSegments 深度方向分段数，默认为 1
     *
     * @brief[en] Constructs a box geometry
     * @param[en] width Width, default 1
     * height Height, default 1
     * depth Depth, default 1
     * widthSegments Width segments, default 1
     * heightSegments Height segments, default 1
     * depthSegments Depth segments, default 1
     */
    public init(width!: Float64 = 1.0, height!: Float64 = 1.0, depth!: Float64 = 1.0, widthSegments!: Int64 = 1, heightSegments!: Int64 = 1, depthSegments!: Int64 = 1) {
        super()
        this.kind = "BoxGeometry"
        this.parameters = HashMap<String, Any>()
        this.parameters.add("width", width); this.parameters.add("height", height)
        this.parameters.add("depth", depth); this.parameters.add("widthSegments", widthSegments)
        this.parameters.add("heightSegments", heightSegments); this.parameters.add("depthSegments", depthSegments)

        let w2 = width / 2.0; let h2 = height / 2.0; let d2 = depth / 2.0
        let posData = [ -w2, -h2, d2,  w2, -h2, d2,  w2, h2, d2,  -w2, h2, d2, -w2, -h2, -d2,  -w2, h2, -d2,  w2, h2, -d2,  w2, -h2, -d2, -w2, h2, -d2,  -w2, h2, d2,  w2, h2, d2,  w2, h2, -d2, -w2, -h2, -d2,  w2, -h2, -d2,  w2, -h2, d2,  -w2, -h2, d2, w2, -h2, -d2,  w2, h2, -d2,  w2, h2, d2,  w2, -h2, d2, -w2, -h2, -d2,  -w2, -h2, d2,  -w2, h2, d2,  -w2, h2, -d2 ]
        let normData = [ 0.0,0.0,1.0, 0.0,0.0,1.0, 0.0,0.0,1.0, 0.0,0.0,1.0, 0.0,0.0,-1.0, 0.0,0.0,-1.0, 0.0,0.0,-1.0, 0.0,0.0,-1.0, 0.0,1.0,0.0, 0.0,1.0,0.0, 0.0,1.0,0.0, 0.0,1.0,0.0, 0.0,-1.0,0.0, 0.0,-1.0,0.0, 0.0,-1.0,0.0, 0.0,-1.0,0.0, 1.0,0.0,0.0, 1.0,0.0,0.0, 1.0,0.0,0.0, 1.0,0.0,0.0, -1.0,0.0,0.0, -1.0,0.0,0.0, -1.0,0.0,0.0, -1.0,0.0,0.0 ]
        let uvData = [ 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0 ]
        let idxData = [ 0,1,2, 0,2,3, 4,5,6, 4,6,7, 8,9,10, 8,10,11, 12,13,14, 12,14,15, 16,17,18, 16,18,19, 20,21,22, 20,22,23 ]
        let positions = Array<Float64>(posData.size, { i => posData[i] })
        let normals = Array<Float64>(normData.size, { i => normData[i] })
        let uvs = Array<Float64>(uvData.size, { i => uvData[i] })
        let idxArr = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })
        this.setIndex(BufferAttribute(idxArr, 1))
        this.setAttribute("position", BufferAttribute(positions, 3))
        this.setAttribute("normal", BufferAttribute(normals, 3))
        this.setAttribute("uv", BufferAttribute(uvs, 2))
    }
}