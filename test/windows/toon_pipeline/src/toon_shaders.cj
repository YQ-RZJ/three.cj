package toon_pipeline

/**
 * 自定义卡通渲染着色器（toon shaders）
 *
 * 设计目标：完整实现自定义卡通渲染管线，不复用引擎内置 ShaderLib 的 meshtoon。
 *
 * 渲染管线流程（对照 three.js 官方 toon 案例 webgl_materials_toon.html）：
 *   1. 主场景 pass：ToonShader（量化光照 + gradientMap 控制明暗分界）
 *   2. 描边 pass：ToonOutlineShader（基于法线/深度的边缘检测描边）
 *
 * bgfx 着色器特性（对照 WebGL 差异）：
 *   - bgfx .sc 格式：$input/$output 声明 varying；#include <bgfx_shader.sh> 获取标准 uniform
 *   - bgfx uniform 最小单位 vec4；float/vec3 用 vec4（xyz=数据，w=padding）
 *   - bgfx 内置 uniform：u_view/u_proj/u_model[0]/u_viewProj/u_modelViewProj 等
 *   - 顶点属性：a_position/a_normal/a_texcoord0（由 VertexLayout 决定）
 *   - 纹理采样：SAMPLER2D(name, stage) + texture2D(name, uv)
 *   - 矩阵乘法：mul(mat, vec)（非 GLSL 的 mat*vec）
 *
 * 卡通着色算法（对照 three.js MeshToonMaterial + getGradientIrradiance）：
 *   - 计算 N·L（法线与光照方向点积），映射到 [0,1]
 *   - 用 gradientMap（1D 量化梯度贴图）采样得到量化光照强度
 *   - 若无 gradientMap，用硬编码 3 级量化（亮/中/暗）
 *   - 最终颜色 = diffuseColor × quantizedIrradiance + ambient
 *
 * bgfx shaderc 转 HLSL 合规要点（项目记忆）：
 *   - 不能用单参数 splat 构造 vec3(标量) → 必须显式三参数 vec3(s, s, s)
 *   - varying 直接用的函数须内联到 main() 或改参数传入
 *   - 变量名避开 HLSL 保留字 point/samples/pattern 等
 *   - GLSL const int N → #define N（HLSL const 语法差异）
 *   - int/bool uniform 用 vec4.x 表示，比较时 == 1.0
 */

// ============================================================================
// 主场景 Toon Shader（量化光照卡通渲染）
// ============================================================================

/**
 * Toon Shader 顶点着色器源码（bgfx .sc 格式）
 *
 * 功能：
 *   - 传递世界空间法线 v_normal（用于 N·L 光照计算）
 *   - 传递 UV v_uv（采样 gradientMap/diffuseMap）
 *   - gl_Position = u_modelViewProj × position
 *
 * 顶点属性：a_position(vec3), a_normal(vec3), a_texcoord0(vec2)
 * Varying 输出：v_normal(vec3), v_uv(vec2)
 *
 * 注意：不传递 v_worldPos，方向光方向在 CPU 端转世界空间后由 shader 直接用 u_lightDir。
 */
public let TOON_VS: String = #"
$input a_position
$input a_normal
$input a_texcoord0

$output v_normal
$output v_texcoord0

#include <bgfx_shader.sh>

void main()
{
    // 世界空间法线（u_model[0] 假设无非均匀缩放，直接用模型矩阵旋转部分）
    v_normal = normalize(mul(u_model[0], vec4(a_normal, 0.0)).xyz);

    // UV 传递
    v_texcoord0 = a_texcoord0;

    // 裁剪空间位置
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
"#

/**
 * Toon Shader 片段着色器源码（bgfx .sc 格式）
 *
 * 功能：
 *   - 采样 gradientMap 得到量化光照强度（toon 风格明暗分界）
 *   - 多方向光累加：irradiance = Σ getGradientIrradiance(N, L_i) × color_i
 *   - 环境光 + 自发光 + 量化光照 = 最终颜色
 *
 * Uniforms（bgfx vec4 对齐）：
 *   - u_baseColor: vec4 xyz=漫反射颜色 rgb，w=opacity
 *   - u_ambientColor: vec4 xyz=环境光颜色，w=环境光强度
 *   - u_emissive: vec4 xyz=自发光颜色，w=0
 *   - u_lightCount: vec4 x=有效方向光数量
 *   - u_lightDir[MAX_TOON_LIGHTS]: vec4 数组 xyz=方向光方向（已归一化）
 *   - u_lightColor[MAX_TOON_LIGHTS]: vec4 数组 xyz=方向光颜色，w=强度
 *
 * Samplers:
 *   - t_gradientMap: stage 0，1D 量化梯度贴图（控制明暗分界）
 *   - t_diffuseMap: stage 1，漫反射纹理（可选）
 *
 * 卡通量化算法（对照 three.js gradientmap_pars_fragment.glsl.js: getGradientIrradiance）：
 *   dotNL = dot(normal, lightDirection)  // [-1, 1]
 *   coord = dotNL * 0.5 + 0.5            // 映射到 [0, 1]
 *   irradiance = texture(gradientMap, coord).r  // 量化采样
 *   若无 gradientMap，用硬编码 3 级量化：
 *     if (dotNL < 0.3) irradiance = 0.4  // 暗部
 *     else if (dotNL < 0.7) irradiance = 0.7  // 中间部
 *     else irradiance = 1.0  // 亮部
 *
 * bgfx shaderc 合规修正：
 *   - vec3(scalar) 单参数 splat → vec3(scalar, scalar, scalar)（HLSL X3014）
 *   - getToonIrradiance 内联到 main() 避免函数返回 vec3 构造问题
 */
public let TOON_FS: String = #"
$input v_normal
$input v_texcoord0

#include <bgfx_shader.sh>

// 最大支持方向光数量（与 CPU 端 u_lightDir/u_lightColor 数组对齐）
#define MAX_TOON_LIGHTS 4

// 卡通渲染 uniforms
uniform vec4 u_baseColor;       // xyz=漫反射颜色 rgb，w=opacity
uniform vec4 u_ambientColor;    // xyz=环境光颜色，w=环境光强度
uniform vec4 u_emissive;        // xyz=自发光颜色，w=0
uniform vec4 u_lightCount;      // x=有效方向光数量
uniform vec4 u_lightDir[MAX_TOON_LIGHTS];    // xyz=方向光方向
uniform vec4 u_lightColor[MAX_TOON_LIGHTS];  // xyz=颜色，w=强度

// 卡通量化贴图（1D 梯度，控制明暗分界）
SAMPLER2D(t_gradientMap, 0);
// 漫反射纹理（可选）
SAMPLER2D(t_diffuseMap, 1);

void main()
{
    // 归一化法线（插值后可能非单位长度）
    vec3 N = normalize(v_normal);

    // 采样漫反射纹理（若未绑定为黑色，由 CPU 端控制）
    vec4 diffuseTex = texture2D(t_diffuseMap, v_texcoord0);

    // 漫反射颜色 = baseColor × diffuseMap（若启用）
    vec3 diffuseColor = u_baseColor.xyz * diffuseTex.rgb;

    // 环境光贡献
    vec3 ambient = u_ambientColor.xyz * u_ambientColor.w * diffuseColor;

    // 方向光累加（卡通量化光照，内联 getToonIrradiance 避免函数返回 vec3 构造问题）
    vec3 directLight = vec3(0.0, 0.0, 0.0);
    float lightCount = u_lightCount.x;
    for (int i = 0; i < MAX_TOON_LIGHTS; i++) {
        if (float(i) >= lightCount) { break; }
        vec3 L = normalize(u_lightDir[i].xyz);
        vec3 lightColor = u_lightColor[i].xyz * u_lightColor[i].w;

        // 卡通量化辐照度（对照 three.js getGradientIrradiance）
        float dotNL = dot(N, L);
        float coord = dotNL * 0.5 + 0.5;

        float irradiance;
#ifdef USE_GRADIENTMAP
        // 使用 gradientMap 量化采样（vec3(s,s,s) 显式三参数，避免 HLSL X3014）
        float gradR = texture2D(t_gradientMap, vec2(coord, 0.5)).r;
        irradiance = gradR;
#else
        // 硬编码 3 级量化（对照 three.js 默认 MeshToonMaterial 无 gradientMap 时的离散光照）
        if (dotNL < 0.3) {
            irradiance = 0.4;  // 暗部
        } else if (dotNL < 0.7) {
            irradiance = 0.7;  // 中间部
        } else {
            irradiance = 1.0;  // 亮部
        }
#endif
        // vec3(scalar, scalar, scalar) 显式三参数，避免 HLSL X3014
        directLight += vec3(irradiance, irradiance, irradiance) * lightColor;
    }

    // 最终颜色 = 环境光 + 量化方向光 × 漫反射 + 自发光
    vec3 finalColor = ambient + diffuseColor * directLight + u_emissive.xyz;

    gl_FragColor = vec4(finalColor, u_baseColor.w);
}
"#

// ============================================================================
// 边缘检测后处理 Shader（基于深度+法线的 Sobel 边缘检测）
// ============================================================================

/**
 * 边缘检测顶点着色器（全屏四边形）
 *
 * 功能：传递 UV，gl_Position = vec4(position.xy, 0, 1)
 */
public let TOON_EDGE_VS: String = #"
$input a_position
$input a_texcoord0

$output vec2 v_blitUV

#include <bgfx_shader.sh>

void main()
{
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
    v_blitUV = a_texcoord0;
}
"#

/**
 * 边缘检测片段着色器（基于深度的 Sobel 边缘检测 + 场景色合成）
 *
 * 功能：
 *   - 采样深度缓冲，用 Sobel 算子检测边缘
 *   - 边缘像素输出描边颜色，非边缘像素输出原始场景色
 *
 * Uniforms：
 *   - u_texelOffset: vec4 xy=单像素 UV 偏移（1/width, 1/height）
 *   - u_edgeColor: vec4 xyz=描边颜色，w=描边强度
 *   - u_edgeThreshold: vec4 x=边缘检测阈值
 *
 * Samplers:
 *   - t_scene: stage 0，场景颜色纹理
 *   - t_depth: stage 1，场景深度纹理
 */
public let TOON_EDGE_FS: String = #"
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(t_scene, 0);
SAMPLER2D(t_depth, 1);

uniform vec4 u_texelOffset;     // xy = 1/width, 1/height
uniform vec4 u_edgeColor;       // xyz = 描边颜色，w = 描边强度
uniform vec4 u_edgeThreshold;   // x = 边缘检测阈值

void main()
{
    // 场景色
    vec3 sceneColor = texture2D(t_scene, v_blitUV).rgb;

    // Sobel 边缘检测（基于深度，3×3 邻域）
    vec2 texel = u_texelOffset.xy;
    float d00 = texture2D(t_depth, v_blitUV + vec2(-texel.x, -texel.y)).r;
    float d01 = texture2D(t_depth, v_blitUV + vec2( 0.0,    -texel.y)).r;
    float d02 = texture2D(t_depth, v_blitUV + vec2( texel.x, -texel.y)).r;
    float d10 = texture2D(t_depth, v_blitUV + vec2(-texel.x,  0.0)).r;
    float d12 = texture2D(t_depth, v_blitUV + vec2( texel.x,  0.0)).r;
    float d20 = texture2D(t_depth, v_blitUV + vec2(-texel.x,  texel.y)).r;
    float d21 = texture2D(t_depth, v_blitUV + vec2( 0.0,     texel.y)).r;
    float d22 = texture2D(t_depth, v_blitUV + vec2( texel.x,  texel.y)).r;

    // Sobel 算子（垂直方向）
    float gx = -d00 - 2.0 * d01 - d02 + d20 + 2.0 * d21 + d22;
    // Sobel 算子（水平方向）
    float gy = -d00 + d02 - 2.0 * d10 + 2.0 * d12 - d20 + d22;

    // 边缘强度 = |gx| + |gy|
    float edgeStrength = abs(gx) + abs(gy);

    // 阈值化：超过阈值则为边缘
    float edgeMask = step(u_edgeThreshold.x, edgeStrength);

    // 合成：边缘像素混合描边颜色
    vec3 outlineColor = u_edgeColor.xyz;
    float blendFactor = edgeMask * u_edgeColor.w;

    // vec3(s,s,s) 显式三参数避免 HLSL X3014，用 mix 合成
    vec3 finalColor = mix(sceneColor, outlineColor, vec3(blendFactor, blendFactor, blendFactor));

    gl_FragColor = vec4(finalColor, 1.0);
}
"#

/**
 * Toon Shader Varying 定义（bgfx shaderc 需要 varying.def.sc 格式）
 * 用于 ShaderMaterial 编译时传入 varying def
 */
public let TOON_VARYING_DEF: String = #"
vec3 a_position   : POSITION;
vec3 a_normal      : NORMAL;
vec2 a_texcoord0   : TEXCOORD0;

vec3 v_normal      : NORMAL    = vec3(0.0, 0.0, 0.0);
vec2 v_uv          : TEXCOORD0 = vec2(0.0, 0.0);
"#

/**
 * ToonEdge Shader Varying 定义（全屏四边形）
 */
public let TOON_EDGE_VARYING_DEF: String = #"
vec3 a_position   : POSITION;
vec2 a_texcoord0   : TEXCOORD0;

vec2 v_blitUV      : TEXCOORD0 = vec2(0.0, 0.0);
"#
