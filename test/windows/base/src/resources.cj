package threeTest

/**
 * 自定义着色器源码与几何体辅助函数
 */

import three.core.*
import three.rendering.geometry.*
import three.rendering.buffer.*

// ========== 自定义着色器源码（bgfx .sc 格式）==========

// 顶点着色器：接收位置 + 法线 + 顶点颜色，输出到片元
public let CUBE_VS: String = """
$input a_position, a_normal, a_color0
$output v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);

    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_color   = a_color0;
    v_worldPos = worldPos.xyz;
}
"""

// 片段着色器：漫反射光照 + 顶点颜色 + 边缘光
public let CUBE_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(1.0, 1.0, -0.5));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // Simple rim light effect for visual interest
    float rim = 1.0 - max(dot(normal, vec3(0.0, 0.0, 1.0)), 0.0);
    rim = pow(rim, 3.0) * 0.4;

    vec3 litColor = v_color * (ambient + diff * 0.7) + vec3_splat(rim);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// ========== 几何体辅助函数 ==========

/// 创建带逐面顶点颜色的立方体几何体
/// 匹配 base 测试的彩虹立方体效果：6 个面各不同颜色 + 法线
public func createColoredBoxGeometry(width: Float64, height: Float64, depth: Float64): BufferGeometry {
    let w2 = width / 2.0
    let h2 = height / 2.0
    let d2 = depth / 2.0

    // 24 个顶点位置（6 个面 × 4 个顶点/面）
    let posData = [
        -w2, -h2,  d2,   w2, -h2,  d2,   w2,  h2,  d2,  -w2,  h2,  d2,  // front
         w2, -h2, -d2,  -w2, -h2, -d2,  -w2,  h2, -d2,   w2,  h2, -d2,  // back
        -w2,  h2,  d2,   w2,  h2,  d2,   w2,  h2, -d2,  -w2,  h2, -d2,  // top
        -w2, -h2, -d2,   w2, -h2, -d2,   w2, -h2,  d2,  -w2, -h2,  d2,  // bottom
         w2, -h2,  d2,   w2, -h2, -d2,   w2,  h2, -d2,   w2,  h2,  d2,  // right
        -w2, -h2, -d2,  -w2, -h2,  d2,  -w2,  h2,  d2,  -w2,  h2, -d2,  // left
    ]
    // 24 个顶点法线（每面相同）
    let normData = [
        0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  0.0, 0.0, 1.0,  // front
        0.0, 0.0,-1.0,  0.0, 0.0,-1.0,  0.0, 0.0,-1.0,  0.0, 0.0,-1.0,  // back
        0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  0.0, 1.0, 0.0,  // top
        0.0,-1.0, 0.0,  0.0,-1.0, 0.0,  0.0,-1.0, 0.0,  0.0,-1.0, 0.0,  // bottom
        1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  1.0, 0.0, 0.0,  // right
       -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0,  // left
    ]
    // 24 个顶点颜色（每面不同颜色）
    let colData = [
        1.0, 0.2, 0.2,   1.0, 0.2, 0.2,   1.0, 0.2, 0.2,   1.0, 0.2, 0.2,  // front: red
        0.2, 1.0, 1.0,   0.2, 1.0, 1.0,   0.2, 1.0, 1.0,   0.2, 1.0, 1.0,  // back: cyan
        0.2, 1.0, 0.2,   0.2, 1.0, 0.2,   0.2, 1.0, 0.2,   0.2, 1.0, 0.2,  // top: green
        1.0, 1.0, 0.2,   1.0, 1.0, 0.2,   1.0, 1.0, 0.2,   1.0, 1.0, 0.2,  // bottom: yellow
        1.0, 0.2, 1.0,   1.0, 0.2, 1.0,   1.0, 0.2, 1.0,   1.0, 0.2, 1.0,  // right: magenta
        0.2, 0.2, 1.0,   0.2, 0.2, 1.0,   0.2, 0.2, 1.0,   0.2, 0.2, 1.0,  // left: blue
    ]
    // 36 个索引（12 个三角形）
    let idxData = [
        0, 1, 2,  0, 2, 3,      // front
        4, 5, 6,  4, 6, 7,      // back
        8, 9, 10, 8, 10, 11,    // top
        12, 13, 14, 12, 14, 15, // bottom
        16, 17, 18, 16, 18, 19, // right
        20, 21, 22, 20, 22, 23, // left
    ]

    let positions = Array<Float64>(posData.size, { i => posData[i] })
    let normals = Array<Float64>(normData.size, { i => normData[i] })
    let colors = Array<Float64>(colData.size, { i => colData[i] })
    let indices = Array<Float64>(idxData.size, { i => Float64(idxData[i]) })

    let geom = BufferGeometry()
    geom.setIndex(BufferAttribute(indices, 1))
    geom.setAttribute("position", BufferAttribute(positions, 3))
    geom.setAttribute("normal", BufferAttribute(normals, 3))
    geom.setAttribute("color", BufferAttribute(colors, 3))
    return geom
}
