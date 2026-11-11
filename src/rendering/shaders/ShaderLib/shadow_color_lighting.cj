/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] shadow_color_lighting  ShaderLib 着色器程序定义
 * @brief[zh-cn] 16-shadowmaps color_lighting 系列 ShaderLib 程序
 *
 * @file[en] shadow_color_lighting  ShaderLib shader program definition
 * @brief[en] 16-shadowmaps color_lighting ShaderLib program series
 * 本文件提供 5 种 SmImpl × 3 种 SmType × 2 种 DepthImpl 的完整组合：
 * SmImpl: Hard/PCF/PCSS/VSM/ESM
 * SmType: Single/Omni/Cascade
 * DepthImpl: InvZ/Linear
 * 每种组合对应一个 ShaderProgram，由 ShaderLibs.register() 注册。
 * 变体通过编译期 #define 切换：
 * SM_HARD / SM_PCF / SM_PCSS / SM_VSM / SM_ESM
 * SM_LINEAR (可选)
 * SM_CSM / SM_OMNI (互斥)
 */
package three.rendering.shaders.ShaderLib

import three.rendering.shaders.ShaderChunk.*

/**
 * @brief[zh-cn] color_lighting 共享头 chunk（fs_shadowmaps_color_lighting.sh）
 *
 * @brief[en] color_lighting shared header chunk (fs_shadowmaps_color_lighting.sh)
 * 定义 Shader struct、evalShader、computeVisibility 函数。
 * computeVisibility 通过 #if SM_HARD/PCF/PCSS/VSM/ESM 分派到对应阴影实现。
 */
public const shadow_color_lighting_header: String = #"
// color_lighting 共享头
// 对照 16-shadowmaps: fs_shadowmaps_color_lighting.sh

#define u_ambientPass    u_params0.x
#define u_lightingPass   u_params0.y

#define u_shadowMapBias   u_params1.x
#define u_shadowMapOffset u_params1.y
#define u_shadowMapParam0 u_params1.z
#define u_shadowMapParam1 u_params1.w

#define u_shadowMapShowCoverage u_params2.y
#define u_shadowMapTexelSize    u_params2.z

#define u_spotDirection   u_lightSpotDirectionInner.xyz
#define u_spotInner       u_lightSpotDirectionInner.w
#define u_lightAttnParams u_lightAttenuationSpotOuter.xyz
#define u_spotOuter       u_lightAttenuationSpotOuter.w

// Pcf
#define u_shadowMapPcfMode     u_shadowMapParam0
#define u_shadowMapNoiseAmount u_shadowMapParam1

// Vsm
#define u_shadowMapMinVariance     u_shadowMapParam0
#define u_shadowMapDepthMultiplier u_shadowMapParam1

// Esm
#define u_shadowMapHardness        u_shadowMapParam0
#define u_shadowMapDepthMultiplier u_shadowMapParam1

struct Shader
{
    vec3 ambi;
    vec3 diff;
    vec3 spec;
};

Shader evalShader(float _diff, float _spec)
{
    Shader shader;

    shader.ambi = u_lightAmbientPower.xyz  * u_lightAmbientPower.w  * u_materialKa.xyz;
    shader.diff = u_lightDiffusePower.xyz  * u_lightDiffusePower.w  * u_materialKd.xyz * _diff;
    shader.spec = u_lightSpecularPower.xyz * u_lightSpecularPower.w * u_materialKs.xyz * _spec;

    return shader;
}

float computeVisibility(sampler2D _sampler
                      , vec4 _shadowCoord
                      , float _bias
                      , vec4 _samplingParams
                      , vec2 _texelSize
                      , float _depthMultiplier
                      , float _minVariance
                      , float _hardness
                      , vec2 _fragCoord
                      )
{
    float visibility;

#if SM_LINEAR
    vec4 shadowcoord = vec4(_shadowCoord.xy / _shadowCoord.w, _shadowCoord.z, 1.0);
#else
    vec4 shadowcoord = _shadowCoord;
#endif

#if SM_HARD
    visibility = hardShadow(_sampler, shadowcoord, _bias);
#elif SM_PCF
    visibility = PCF(_sampler, shadowcoord, _bias, _samplingParams, _texelSize, _fragCoord);
#elif SM_PCSS
    visibility = PCSS(_sampler, shadowcoord, _bias, _samplingParams, _texelSize, _fragCoord);
#elif SM_VSM
    visibility = VSM(_sampler, shadowcoord, _bias, _depthMultiplier, _minVariance);
#elif SM_ESM
    visibility = ESM(_sampler, shadowcoord, _bias, _depthMultiplier * _hardness);
#endif

    return visibility;
}
"#

/**
 * @brief[zh-cn] color_lighting main 体 chunk（fs_shadowmaps_color_lighting_main.sh）
 *
 * @brief[en] color_lighting main body chunk (fs_shadowmaps_color_lighting_main.sh)
 * 通过 #if SM_CSM / SM_OMNI / else 分派到 Single/Omni/Cascade 路径。
 * 每条路径计算 visibility 后，执行 BRDF (lit) + fog + 最终颜色合成。
 */
public const shadow_color_lighting_main: String = #"
// color_lighting main 体
// 对照 16-shadowmaps: fs_shadowmaps_color_lighting_main.sh

{
    vec3 colorCoverage;
    float visibility;

    vec2 fragCoord = gl_FragCoord.xy;
#if SM_CSM
    vec2 texelSize = vec2_splat(u_shadowMapTexelSize);

    vec2 texcoord1 = v_texcoord1.xy/v_texcoord1.w;
    vec2 texcoord2 = v_texcoord2.xy/v_texcoord2.w;
    vec2 texcoord3 = v_texcoord3.xy/v_texcoord3.w;
    vec2 texcoord4 = v_texcoord4.xy/v_texcoord4.w;

    bool selection0 = all(lessThan(texcoord1, vec2_splat(0.99))) && all(greaterThan(texcoord1, vec2_splat(0.01)));
    bool selection1 = all(lessThan(texcoord2, vec2_splat(0.99))) && all(greaterThan(texcoord2, vec2_splat(0.01)));
    bool selection2 = all(lessThan(texcoord3, vec2_splat(0.99))) && all(greaterThan(texcoord3, vec2_splat(0.01)));
    bool selection3 = all(lessThan(texcoord4, vec2_splat(0.99))) && all(greaterThan(texcoord4, vec2_splat(0.01)));

    if (selection0)
    {
        vec4 shadowcoord = v_texcoord1;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.4;
        colorCoverage = vec3(-coverage, coverage, -coverage);
        visibility = computeVisibility(s_shadowMap0, shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
    }
    else if (selection1)
    {
        vec4 shadowcoord = v_texcoord2;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.4;
        colorCoverage = vec3(coverage, coverage, -coverage);
        visibility = computeVisibility(s_shadowMap1, shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize/2.0, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
    }
    else if (selection2)
    {
        vec4 shadowcoord = v_texcoord3;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.4;
        colorCoverage = vec3(-coverage, -coverage, coverage);
        visibility = computeVisibility(s_shadowMap2, shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize/3.0, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
    }
    else //selection3
    {
        vec4 shadowcoord = v_texcoord4;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.4;
        colorCoverage = vec3(coverage, -coverage, -coverage);
        visibility = computeVisibility(s_shadowMap3, shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize/4.0, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
    }
#elif SM_OMNI
    vec2 texelSize = vec2_splat(u_shadowMapTexelSize/4.0);

    vec4 faceSelection;
    vec3 pos = v_position.xyz;
    faceSelection.x = dot(u_tetraNormalGreen.xyz,  pos);
    faceSelection.y = dot(u_tetraNormalYellow.xyz, pos);
    faceSelection.z = dot(u_tetraNormalBlue.xyz,   pos);
    faceSelection.w = dot(u_tetraNormalRed.xyz,    pos);

    vec4 shadowcoord;
    float faceMax = max(max(faceSelection.x, faceSelection.y), max(faceSelection.z, faceSelection.w));
    if (faceSelection.x == faceMax)
    {
        shadowcoord = v_texcoord1;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.3;
        colorCoverage = vec3(-coverage, coverage, -coverage);
    }
    else if (faceSelection.y == faceMax)
    {
        shadowcoord = v_texcoord2;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.3;
        colorCoverage = vec3(coverage, coverage, -coverage);
    }
    else if (faceSelection.z == faceMax)
    {
        shadowcoord = v_texcoord3;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.3;
        colorCoverage = vec3(-coverage, -coverage, coverage);
    }
    else // (faceSelection.w == faceMax)
    {
        shadowcoord = v_texcoord4;
        float coverage = texcoordInRange(shadowcoord.xy/shadowcoord.w) * 0.3;
        colorCoverage = vec3(coverage, -coverage, -coverage);
    }

    visibility = computeVisibility(s_shadowMap0, shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
#else
    vec2 texelSize = vec2_splat(u_shadowMapTexelSize);
    float coverage = texcoordInRange(v_shadowcoord.xy/v_shadowcoord.w) * 0.3;
    colorCoverage = vec3(coverage, -coverage, -coverage);
    visibility = computeVisibility(s_shadowMap0, v_shadowcoord, u_shadowMapBias, u_smSamplingParams, texelSize, u_shadowMapDepthMultiplier, u_shadowMapMinVariance, u_shadowMapHardness, fragCoord);
#endif

    vec3 v = v_view;
    vec3 vd = -normalize(v_view);
    vec3 n = v_normal;
    Light light = evalLight(v, u_lightPosition, u_spotDirection, u_spotInner, u_spotOuter, u_lightAttnParams);

    vec2 lc = lit(light.ld, n, vd, u_materialKs.w) * light.attn;
    Shader shader = evalShader(lc.x, lc.y);

    //Fog.
    vec3 fogColor = vec3_splat(0.0);
    float fogDensity = 0.0035;
    float LOG2 = 1.442695;
    float z = length(v);
    float fogFactor = clamp(1.0/exp2(fogDensity*fogDensity*z*z*LOG2), 0.0, 1.0);

    vec3 color = u_color.xyz;
    vec3 ambient = shader.ambi * color;
    vec3 brdf    = (shader.diff + shader.spec) * color * visibility;
    vec3 final = toGamma(abs(ambient + brdf)) + (colorCoverage * u_shadowMapShowCoverage);

    gl_FragColor.xyz = mix(fogColor, final, fogFactor);
    gl_FragColor.w = 1.0;
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（Single 模式，InvZ）
 *
 * @brief[en] color_lighting vertex shader chunk (Single mode, InvZ)
 * 计算 v_shadowcoord = u_lightMtx × (pos + normal × offset)
 */
public const shadow_color_lighting_vertex_single: String = #"
// color_lighting 顶点着色器（Single 模式，InvZ）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting.sc

$input a_position, a_normal
$output v_normal, v_view, v_shadowcoord

#include <bgfx_shader.sh>

uniform mat4 u_lightMtx;
uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec3 posOffset = a_position + normal.xyz * u_shadowMapOffset;
    v_shadowcoord = mul(u_lightMtx, vec4(posOffset, 1.0) );
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（CSM 模式，InvZ）
 *
 * @brief[en] color_lighting vertex shader chunk (CSM mode, InvZ)
 * 计算 4 级 v_texcoord1..4 = u_shadowMapMtx{0..3} × wpos
 */
public const shadow_color_lighting_vertex_csm: String = #"
// color_lighting 顶点着色器（CSM 模式，InvZ）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting_csm.sc

$input a_position, a_normal
$output v_position, v_normal, v_view, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

uniform mat4 u_lightMtx;
uniform mat4 u_shadowMapMtx0;
uniform mat4 u_shadowMapMtx1;
uniform mat4 u_shadowMapMtx2;
uniform mat4 u_shadowMapMtx3;

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec4 posOffset = vec4(a_position + normal.xyz * u_shadowMapOffset, 1.0);
    v_position = mul(u_modelView, posOffset);

    vec4 wpos = vec4(mul(u_model[0], posOffset).xyz, 1.0);
    v_texcoord1 = mul(u_shadowMapMtx0, wpos);
    v_texcoord2 = mul(u_shadowMapMtx1, wpos);
    v_texcoord3 = mul(u_shadowMapMtx2, wpos);
    v_texcoord4 = mul(u_shadowMapMtx3, wpos);
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（Omni 模式）
 *
 * @brief[en] color_lighting vertex shader chunk (Omni mode)
 * 计算 4 面 tetrahedron 的 v_texcoord1..4 = u_shadowMapMtx{0..3} × v_position
 */
public const shadow_color_lighting_vertex_omni: String = #"
// color_lighting 顶点着色器（Omni 模式）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting_omni.sc

$input a_position, a_normal
$output v_position, v_normal, v_view, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

uniform mat4 u_lightMtx;
uniform mat4 u_shadowMapMtx0;
uniform mat4 u_shadowMapMtx1;
uniform mat4 u_shadowMapMtx2;
uniform mat4 u_shadowMapMtx3;

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec4 posOffset = vec4(a_position + normal.xyz * u_shadowMapOffset, 1.0);
    v_position = mul(u_lightMtx, posOffset);

    v_texcoord1 = mul(u_shadowMapMtx0, v_position);
    v_texcoord2 = mul(u_shadowMapMtx1, v_position);
    v_texcoord3 = mul(u_shadowMapMtx2, v_position);
    v_texcoord4 = mul(u_shadowMapMtx3, v_position);
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（Single 模式，Linear）
 *
 * @brief[en] color_lighting vertex shader chunk (Single mode, Linear)
 * Linear 模式：v_shadowcoord.z += 0.5（光空间线性距离补偿）
 */
public const shadow_color_lighting_vertex_single_linear: String = #"
// color_lighting 顶点着色器（Single 模式，Linear）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting_linear.sc

$input a_position, a_normal
$output v_normal, v_view, v_shadowcoord

#include <bgfx_shader.sh>

uniform mat4 u_lightMtx;
uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec3 posOffset = a_position + normal.xyz * u_shadowMapOffset;
    v_shadowcoord = mul(u_lightMtx, vec4(posOffset, 1.0) );
    v_shadowcoord.z += 0.5;
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（CSM 模式，Linear）
 *
 * @brief[en] color_lighting vertex shader chunk (CSM mode, Linear)
 * Linear 模式：4 级 v_texcoord1..4.z += 0.5
 */
public const shadow_color_lighting_vertex_csm_linear: String = #"
// color_lighting 顶点着色器（CSM 模式，Linear）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting_linear_csm.sc

$input a_position, a_normal
$output v_position, v_normal, v_view, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

uniform mat4 u_lightMtx;
uniform mat4 u_shadowMapMtx0;
uniform mat4 u_shadowMapMtx1;
uniform mat4 u_shadowMapMtx2;
uniform mat4 u_shadowMapMtx3;

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec4 posOffset = vec4(a_position + normal.xyz * u_shadowMapOffset, 1.0);
    v_position = mul(u_modelView, posOffset);

    vec4 wpos = vec4(mul(u_model[0], posOffset).xyz, 1.0);
    v_texcoord1 = mul(u_shadowMapMtx0, wpos);
    v_texcoord2 = mul(u_shadowMapMtx1, wpos);
    v_texcoord3 = mul(u_shadowMapMtx2, wpos);
    v_texcoord4 = mul(u_shadowMapMtx3, wpos);

    v_texcoord1.z += 0.5;
    v_texcoord2.z += 0.5;
    v_texcoord3.z += 0.5;
    v_texcoord4.z += 0.5;
}
"#

/**
 * @brief[zh-cn] color_lighting 顶点着色器 chunk（Omni 模式，Linear）
 *
 * @brief[en] color_lighting vertex shader chunk (Omni mode, Linear)
 */
public const shadow_color_lighting_vertex_omni_linear: String = #"
// color_lighting 顶点着色器（Omni 模式，Linear）
// 对照 16-shadowmaps: vs_shadowmaps_color_lighting_linear_omni.sc

$input a_position, a_normal
$output v_position, v_normal, v_view, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_params1;
#define u_shadowMapOffset u_params1.y

uniform mat4 u_lightMtx;
uniform mat4 u_shadowMapMtx0;
uniform mat4 u_shadowMapMtx1;
uniform mat4 u_shadowMapMtx2;
uniform mat4 u_shadowMapMtx3;

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );

    vec4 normal = a_normal * 2.0 - 1.0;
    v_normal = normalize(mul(u_modelView, vec4(normal.xyz, 0.0) ).xyz);
    v_view = mul(u_modelView, vec4(a_position, 1.0)).xyz;

    vec4 posOffset = vec4(a_position + normal.xyz * u_shadowMapOffset, 1.0);
    v_position = mul(u_lightMtx, posOffset);

    v_texcoord1 = mul(u_shadowMapMtx0, v_position);
    v_texcoord2 = mul(u_shadowMapMtx1, v_position);
    v_texcoord3 = mul(u_shadowMapMtx2, v_position);
    v_texcoord4 = mul(u_shadowMapMtx3, v_position);

    v_texcoord1.z += 0.5;
    v_texcoord2.z += 0.5;
    v_texcoord3.z += 0.5;
    v_texcoord4.z += 0.5;
}
"#
