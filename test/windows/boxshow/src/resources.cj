package boxshow

/**
 * resources.cj
 *
 * 开放盒子几何体构造：
 * - 盒子尺寸 width × height × depth，中心位于原点
 * - 去掉前面板（+Z 面），让相机从 +Z 方向能看到盒子内部
 * - 内壁朝向盒子内部（法线向内），便于光照/阴影正确显示
 *
 * 法线方向（内壁法线指向盒内，即朝向相机可见的一侧）：
 *   - back  (-Z): normal +Z （指向盒内）
 *   - top   (+Y): normal -Y
 *   - bottom(-Y): normal +Y
 *   - right (+X): normal -X
 *   - left  (-X): normal +X
 */

import three.core.*
import three.rendering.geometry.*
import three.rendering.buffer.*

/// 创建开放盒子几何体（无前面板 +Z，内壁法线向内）
public func createOpenBoxGeometry(width: Float64, height: Float64, depth: Float64): BufferGeometry {
    let w2 = width / 2.0
    let h2 = height / 2.0
    let d2 = depth / 2.0

    // 5 个面 × 4 顶点 = 20 顶点
    // 顺序：back(-Z), top(+Y), bottom(-Y), right(+X), left(-X)
    let posData = [
        // back (-Z)
        -w2, -h2, -d2,   w2, -h2, -d2,   w2,  h2, -d2,  -w2,  h2, -d2,
        // top (+Y)
        -w2,  h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,  -w2,  h2,  d2,
        // bottom (-Y)
        -w2, -h2,  d2,   w2, -h2,  d2,   w2, -h2, -d2,  -w2, -h2, -d2,
        // right (+X)
         w2, -h2,  d2,   w2, -h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,
        // left (-X)
        -w2, -h2, -d2,  -w2, -h2,  d2,  -w2,  h2,  d2,  -w2,  h2, -d2,
    ]
    // 内壁法线：每个面法线指向盒内
    let normData = [
        // back (-Z): normal +Z
        0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,   0.0, 0.0, 1.0,
        // top (+Y): normal -Y
        0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,   0.0,-1.0, 0.0,
        // bottom (-Y): normal +Y
        0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,   0.0, 1.0, 0.0,
        // right (+X): normal -X
       -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,  -1.0, 0.0, 0.0,
        // left (-X): normal +X
        1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    ]
    // 5 个面 × 2 三角形 × 3 顶点 = 30 索引
    let idxData = [
        0, 1, 2,  0, 2, 3,       // back
        4, 5, 6,  4, 6, 7,       // top
        8, 9,10,  8,10,11,       // bottom
       12,14,13, 12,15,14,       // right (reversed winding for inward normal -X)
       16,18,17, 16,19,18,       // left (reversed winding for inward normal +X)
    ]

    let positions = Array<Float64>(posData.size, { i => posData[i] })
    let normals = Array<Float64>(normData.size, { i => normData[i] })
    let indices = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })

    let geom = BufferGeometry()
    geom.setIndex(BufferAttribute(indices, 1))
    geom.setAttribute("position", BufferAttribute(positions, 3))
    geom.setAttribute("normal", BufferAttribute(normals, 3))
    return geom
}
