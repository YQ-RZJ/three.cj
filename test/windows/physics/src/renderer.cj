package threePhysicsTest

/**
 * 物理测试渲染着色器源码（对照 test/audio/src/renderer.cj 风格）
 *
 * 着色器清单：
 *   GROUND_VS/FS    — 地面网格着色器（冷色调网格）
 *   BOX_VS/FS       — 下落立方体着色器（暖色调，按面着色）
 *   SPHERE_VS/FS    — 球体着色器（高光，高弹性视觉标识）
 *   CAPSULE_VS/FS   — 胶囊体着色器（金属质感）
 *   CYLINDER_VS/FS  — 圆柱体着色器（蓝绿渐变，用于铰链钟摆/力演示体）
 *   HINGE_VS/FS     — 约束演示体着色器（铰链连接的钟摆杆）
 *
 * 着色器统一遵循 bgfx .sc 格式：
 *   $input / $output 声明 varying
 *   #include <bgfx_shader.sh> 引入 bgfx 内置宏/函数
 *   u_model[0] / u_viewProj / u_lightDir 为 renderer 注入的 uniform
 */

// =========================================================================
// 地面着色器
// =========================================================================

public let GROUND_VS: String = """
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

public let GROUND_FS: String = """
$input v_normal, v_color, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 冷色调网格
    vec3 gridColor = v_color * (ambient + diff * 0.5);
    gl_FragColor = vec4(gridColor, 1.0);
}
"""

// =========================================================================
// 下落立方体着色器（按法线着色，让 6 个面有不同颜色）
// =========================================================================

public let BOX_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let BOX_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // 按法线着色：+X 红、-X 青、+Y 绿、-Y 蓝、+Z 黄、-Z 紫
    vec3 n = abs(normal);
    vec3 baseColor;
    if (normal.x > 0.5)        baseColor = vec3(1.0, 0.3, 0.3);
    else if (normal.x < -0.5)  baseColor = vec3(0.3, 0.8, 0.9);
    else if (normal.y > 0.5)   baseColor = vec3(0.3, 0.9, 0.4);
    else if (normal.y < -0.5)  baseColor = vec3(0.3, 0.4, 1.0);
    else if (normal.z > 0.5)   baseColor = vec3(1.0, 0.9, 0.3);
    else                        baseColor = vec3(0.8, 0.3, 1.0);

    vec3 litColor = baseColor * (ambient + diff * 0.8);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// =========================================================================
// 球体着色器（高光，弹跳球视觉标识）
// =========================================================================

public let SPHERE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let SPHERE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.3;

    // 高光（Phong 简化）
    vec3 viewDir = normalize(vec3(0.0, 0.0, 1.0));
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);

    // 暖色调橙红 + 高光
    vec3 baseColor = vec3(1.0, 0.5, 0.2);
    vec3 litColor = baseColor * (ambient + diff * 0.8) + vec3_splat(spec) * vec3(1.0, 1.0, 0.8);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// =========================================================================
// 胶囊体着色器（金属质感）
// =========================================================================

public let CAPSULE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CAPSULE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.2;

    // 金属质感：高对比度 + Fresnel 边缘光
    vec3 viewDir = normalize(vec3(0.0, 0.0, 1.0));
    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 3.0);

    vec3 baseColor = vec3(0.6, 0.65, 0.7);  // 冷色调金属灰
    vec3 litColor = baseColor * (ambient + diff * 1.2);
    litColor += vec3_splat(fresnel) * vec3(0.8, 0.9, 1.0);

    gl_FragColor = vec4(litColor, 1.0);
}
"""

// =========================================================================
// 圆柱体着色器（蓝绿渐变，用于约束演示/滚动体）
// =========================================================================

public let CYLINDER_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CYLINDER_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 蓝绿渐变：顶部亮青、底部深蓝（沿局部 Y 用世界 Y 近似）
    float t = clamp((v_worldPos.y + 2.0) * 0.25, 0.0, 1.0);
    vec3 baseColor = mix(vec3(0.1, 0.3, 0.8), vec3(0.2, 0.9, 0.6), t);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// =========================================================================
// 约束演示体着色器（铰链连接的钟摆杆，暖橙色调）
// =========================================================================

public let HINGE_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let HINGE_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 暖橙色调（与球体区分）
    vec3 baseColor = vec3(0.95, 0.55, 0.15);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

// =========================================================================
// 扩展形状演示体着色器（Mesh 三角网格 / ConvexHull 凸包 / Compound 复合）
// =========================================================================

/// Mesh 三角网格形状演示（青绿色，静态坡道/地形）
public let MESH_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let MESH_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 青绿色（三角网格形状）
    vec3 baseColor = vec3(0.15, 0.85, 0.65);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

/// ConvexHull 凸包形状演示（亮紫色，下落翻滚）
public let CONVEX_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let CONVEX_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 亮紫色（凸包形状）
    vec3 baseColor = vec3(0.75, 0.35, 0.95);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""

/// Compound 复合形状演示（亮黄色，多个子形状组合体）
public let COMPOUND_VS: String = """
$input a_position, a_normal
$output v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    v_normal  = mul(u_model[0], vec4(a_normal, 0.0)).xyz;
    v_worldPos = worldPos.xyz;
}
"""

public let COMPOUND_FS: String = """
$input v_normal, v_worldPos

#include <bgfx_shader.sh>

void main()
{
    vec3 lightDir = normalize(vec3(0.5, 1.0, 0.3));
    vec3 normal   = normalize(v_normal);
    float diff    = max(dot(normal, lightDir), 0.0);
    float ambient = 0.25;

    // 亮黄色（复合形状）
    vec3 baseColor = vec3(0.95, 0.85, 0.2);

    vec3 litColor = baseColor * (ambient + diff * 0.9);
    gl_FragColor = vec4(litColor, 1.0);
}
"""
