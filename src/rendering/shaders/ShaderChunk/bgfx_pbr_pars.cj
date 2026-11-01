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
 * @file[zh-cn] bgfx_pbr_pars  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: bgfx 专用 PBR 辅助函数
 *
 * @file[en] bgfx_pbr_pars  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: bgfx-specific PBR helper functions
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时通过 #include 引用。
 * 包含 GGX 微表面 BRDF、菲涅尔、球谐辐照度、多散射补偿等函数。
 * 使用 bgfx flat vec4 uniform 命名约定（u_xxx），而非 struct 约定。
 */
package three.rendering.shaders.ShaderChunk

/**
 * @brief[zh-cn] bgfx PBR 辅助函数 GLSL 片段字符串
 * @explain[zh-cn] 用于 standard/physical 材质的片段着色器。
 *
 * @brief[en] bgfx PBR helper functions GLSL fragment string
 * @explain[en] Used in standard/physical material fragment shaders.
 */
public const bgfx_pbr_pars: String = #"

// Schlick 菲涅尔近似
vec3 F_Schlick(vec3 f0, float f90, float dotVH)
{
    float x = clamp(1.0 - dotVH, 0.0, 1.0);
    float x2 = x * x;
    float x5 = x * x2 * x2;
    return f0 + (vec3_splat(f90) - f0) * x5;
}

// GGX 法线分布函数 (Trowbridge-Reitz)
float D_GGX(float alpha, float dotNH)
{
    float a2 = alpha * alpha;
    float denom = dotNH * dotNH * (a2 - 1.0) + 1.0;
    return a2 / (3.14159 * denom * denom);
}

// Smith 可见性函数 (GGX 关联形式)
float V_SmithGGXCorrelated(float alpha, float dotNL, float dotNV)
{
    float a2 = alpha * alpha;
    float gv = dotNL * sqrt(a2 + (1.0 - a2) * dotNV * dotNV);
    float gl = dotNV * sqrt(a2 + (1.0 - a2) * dotNL * dotNL);
    return 0.5 / max(gv + gl, 0.0001);
}

// Lambert 漫反射 BRDF
vec3 BRDF_Lambert(vec3 diffuseColor)
{
    return diffuseColor * (1.0 / 3.14159);
}

// 环境 BRDF 预积分（EnvironmentBRDF + DFGLUT）
vec3 EnvironmentBRDF(vec3 specularColor, float roughness, float dotNV)
{
    vec2 uv = vec2(roughness, dotNV);
    vec2 fab = texture2D(dfgLUT, uv).rg;
    return specularColor * fab.x + vec3_splat(1.0) * fab.y;
}

// 球谐辐照度求值 getShIrradianceAt
vec3 getShIrradianceAt(vec3 normal)
{
    float x = normal.x, y = normal.y, z = normal.z;

    // band 0
    vec3 result = shCoefficients[0].xyz * 0.886227;

    // band 1
    result += shCoefficients[1].xyz * (2.0 * 0.511664) * y;
    result += shCoefficients[2].xyz * (2.0 * 0.511664) * z;
    result += shCoefficients[3].xyz * (2.0 * 0.511664) * x;

    // band 2
    result += shCoefficients[4].xyz * (2.0 * 0.429043) * x * y;
    result += shCoefficients[5].xyz * (2.0 * 0.429043) * y * z;
    result += shCoefficients[6].xyz * (z * z * 0.743125 - 0.247708);
    result += shCoefficients[7].xyz * (2.0 * 0.429043) * x * z;
    result += shCoefficients[8].xyz * 0.429043 * (x * x - y * y);

    return result;
}

// DFG 预积分近似（Karis/Unreal 移动端拟合，无需查表）
vec2 DFGApprox(vec3 normal, vec3 viewDir, float roughness)
{
    float dotNV = saturate(dot(normal, viewDir));
    vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
    vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
    vec4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * dotNV)) * r.x + r.y;
    vec2 fab = vec2(-1.04, 1.04) * a004 + r.zw;
    return fab;
}

// 多散射能量补偿 computeMultiscattering
//   由 DFG 预积分给出单散射能量 Ess 与多散射能量 Ems，粗糙度→0 时 fab→(1,0)（Ems→0，
//   镜面无多散射补偿），粗糙度→1 时 Ems 显著（能量补偿生效）。
//   此前实现忽略 roughness（Ess 恒为 0.6~1.0 区间的经验值），使光滑金属也叠加了一份
//   "模糊环境辐照度 × multiScatter"，把清晰的镜面反射淹没 → 反射颜色/形状失真。
void computeMultiscattering(vec3 normal, vec3 viewDir, vec3 specularColor, float specularF90, float roughness, inout vec3 singleScatter, inout vec3 multiScatter)
{
    vec2 fab = DFGApprox(normal, viewDir, roughness);

    vec3 Fr = specularColor;
    vec3 FssEss = Fr * fab.x + vec3_splat(specularF90) * fab.y;

    float Ess = fab.x + fab.y;
    float Ems = 1.0 - Ess;

    vec3 Favg = Fr + (vec3_splat(1.0) - Fr) * 0.047619;
    vec3 Fms = FssEss * Favg / max(vec3_splat(1.0) - Ems * Favg, vec3_splat(0.001));
    singleScatter += FssEss;
    multiScatter += Fms * Ems;
}

// 切线空间基构建 getTangentFrame
mat3 getTangentFrame(vec3 viewDir, vec3 surfNorm, vec2 uv)
{
    vec3 q0 = dFdx(viewDir);
    vec3 q1 = dFdy(viewDir);
    vec2 st0 = dFdx(uv);
    vec2 st1 = dFdy(uv);
    vec3 N = surfNorm;
    vec3 q1perp = cross(q1, N);
    vec3 q0perp = cross(N, q0);
    vec3 T = q1perp * st0.x + q0perp * st1.x;
    vec3 B = q1perp * st0.y + q0perp * st1.y;
    float det = max(dot(T, T), dot(B, B));
    float scale = (det == 0.0) ? 0.0 : inversesqrt(det);
    return mat3(T.x * scale, T.y * scale, T.z * scale, B.x * scale, B.y * scale, B.z * scale, N.x, N.y, N.z);
}
"#
