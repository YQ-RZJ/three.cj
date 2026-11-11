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
 * @file[zh-cn] PostProcessingShaders 后处理内部 shader 注册模块
 * @brief[zh-cn] 后处理 pass 专用 shader 的注册表
 * @explain[zh-cn] 设计动机（架构修正）：
 *         此前后处理 pass 的 shader（copy/output/bloom/fxaa/smaa/ssao 系列）全部注册在
 *         内置渲染管线的 ShaderLibs 中，由后处理 pass 通过 ShaderLibs.get() 取用 —— 职责混淆。
 *         本模块把这些 shader 迁移到 postprocessing 包内独立注册（PostProcessingShaders），
 *         使"后处理的 shader 由后处理内部管理"（对齐 examples/jsm/shaders 目录的组织方式）。
 *         迁移清单（14 个，从 ShaderLibs 移出）：
 *         - copy        → SavePass/TexturePass/ShaderPass 共用（CopyShader）
 *         - output      → OutputPass 专用（OutputShader，7 种 ToneMapping + sRGB）
 *         - bloom_*     → UnrealBloomPass 专用（luminosity/blur/composite/blend）
 *         - fxaa        → FXAAPass 专用（NVIDIA FXAA 3.11）
 *         - smaa*       → SMAAPass 专用（Edges/Weights/Blend 三遍）
 *         - ssao/ssaoblur/ssaodepth/ssaoapply → SSAOPass 专用
 *         保留在 ShaderLibs 的：
 *         - normal：SSAO 法线 pass 借用，但本质是渲染管线通用 shader（meshnormal 材质用）
 *         - shadowblit：阴影 debug blit（渲染管线）
 *         - hblur/vblur：阴影 VSM/ESM blur（渲染管线）
 *         依赖说明：ShaderProgram/ShaderChunks 是渲染管线基础类型（three.rendering.shaders），
 *         本模块引用它们形成 postprocessing → renderers.shaders 单向依赖，无循环依赖。
 *
 * @file[en] PostProcessingShaders post-processing internal shader registration module
 * @brief[en] Registry for shaders used exclusively by post-processing passes
 * @explain[en] Design motivation (architecture fix):
 *         Previously all post-processing pass shaders (copy/output/bloom/fxaa/smaa/ssao family) were registered in
 *         the built-in render pipeline's ShaderLibs and fetched by post-processing passes via ShaderLibs.get() — a responsibility mix-up.
 *         This module moves them into an independent registry inside the postprocessing package (PostProcessingShaders),
 *         so "post-processing shaders are managed inside post-processing" (aligned with the examples/jsm/shaders directory layout).
 *         Migration list (14, moved out of ShaderLibs):
 *         - copy        → shared by SavePass/TexturePass/ShaderPass (CopyShader)
 *         - output      → OutputPass only (OutputShader, 7 ToneMapping + sRGB)
 *         - bloom_*     → UnrealBloomPass only (luminosity/blur/composite/blend)
 *         - fxaa        → FXAAPass only (NVIDIA FXAA 3.11)
 *         - smaa*       → SMAAPass only (Edges/Weights/Blend three passes)
 *         - ssao/ssaoblur/ssaodepth/ssaoapply → SSAOPass only
 *         Remaining in ShaderLibs:
 *         - normal: borrowed by the SSAO normal pass, but essentially a general render-pipeline shader (used by meshnormal materials)
 *         - shadowblit: shadow debug blit (render pipeline)
 *         - hblur/vblur: shadow VSM/ESM blur (render pipeline)
 *         Dependency note: ShaderProgram/ShaderChunks are render-pipeline base types (three.rendering.shaders);
 *         this module references them forming a one-way postprocessing → renderers.shaders dependency with no cycles.
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.shaders.ShaderProgram
import std.collection.*

/**
 * 全屏四边形 VS（等价 ShaderLibs.shadowblitVS：a_position + a_texcoord0 → v_blitUV）。
 * 所有后处理全屏 pass 复用（copy/output/bloom/fxaa/smaa/ssao）。
 */
let POST_BLIT_VS = """
$input a_position
$input a_texcoord0
$output v_blitUV

#include <bgfx_shader.sh>

void main()
{
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
    v_blitUV = a_texcoord0;
}
"""

/**
 * 全屏四边形 varying def（等价 ShaderLibs.shadowblitVaryingDef）。
 */
let POST_BLIT_VARYING_DEF = """
vec3 a_position : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec2 v_blitUV : TEXCOORD0 = vec2(0.0, 0.0);
"""

/**
 * CopyShader FS：把 readBuffer 颜色按 opacity 透传（SavePass/TexturePass/ShaderPass 共用）。
 * uniforms: tDiffuse(sampler0), u_opacity(vec4: x=opacity)
 */
let COPY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_opacity;  // x=opacity

void main()
{
    vec4 texel = texture2D(tDiffuse, v_blitUV);
    gl_FragColor = texel * u_opacity.x;
}
"""

/**
 * OutputShader FS：色调映射 + sRGB 色彩空间转换（OutputPass 专用）。
 * uniforms: tDiffuse(sampler0), u_toneMappingExposure(vec4: x=exposure)
 * 编译时经 #define 选 ToneMapping（TONE_LINEAR/REINHARD/CINEON/ACES_FILMIC/AGX/NEUTRAL）与 SRGB_TRANSFER。
 */
let OUTPUT_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_toneMappingExposure;  // x=exposure

// Tone Mapping 函数体（内联自 Tonemapping.glsl，避免 chunk 依赖）
vec3 LinearToneMapping(vec3 color) {
    return u_toneMappingExposure.x * color;
}
vec3 ReinhardToneMapping(vec3 color) {
    color *= u_toneMappingExposure.x;
    return color / (color + vec3(1.0, 1.0, 1.0));
}
vec3 CineonToneMapping(vec3 color) {
    color *= u_toneMappingExposure.x;
    color = max(vec3(0.0, 0.0, 0.0), color - 0.92);
    return color / (color + vec3(0.08, 0.08, 0.08));
}
vec3 ACESFilmicToneMapping(vec3 color) {
    color *= u_toneMappingExposure.x;
    return clamp((color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.14), vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
}
vec3 AgXToneMapping(vec3 color) {
    color *= u_toneMappingExposure.x;
    const mat3 agxMat = mat3(0.842, 0.579, 0.079, 0.078, 0.876, 0.816, 0.078, 0.876, 0.816);
    const mat3 invAgxMat = mat3(1.111, -0.709, -0.246, -0.597, 1.111, -0.246, -0.597, -0.709, 1.111);
    color = mul(agxMat, color);
    color = log2(color + 0.00055) / log2(10);
    color = clamp(color, -10.0, 10.0);
    color = pow(vec3(2.0, 2.0, 2.0), color) - vec3(0.018, 0.018, 0.018);
    color = clamp(color, 0.0, 1.0);
    return mul(invAgxMat, color);
}
vec3 NeutralToneMapping(vec3 color) {
    color *= u_toneMappingExposure.x;
    const float startOffset = 0.152;
    const float startTime = 0.2;
    const float duration = 0.5;
    color = color * startTime + startOffset;
    color = color / (color + duration) - startOffset / (1.0 + duration);
    return color;
}

void main()
{
    vec4 texel = texture2D(tDiffuse, v_blitUV);
    vec3 color = texel.rgb;

    // Tone Mapping（OutputPass.compile 时按 renderer.toneMapping 选一个 #define）
    #ifdef TONE_LINEAR
        color = LinearToneMapping(color);
    #elif defined(TONE_REINHARD)
        color = ReinhardToneMapping(color);
    #elif defined(TONE_CINEON)
        color = CineonToneMapping(color);
    #elif defined(TONE_ACES_FILMIC)
        color = ACESFilmicToneMapping(color);
    #elif defined(TONE_AGX)
        color = AgXToneMapping(color);
    #elif defined(TONE_NEUTRAL)
        color = NeutralToneMapping(color);
    #endif

    // sRGB OETF（线性 → sRGB，sqrt 近似；OutputPass.compile 时按 renderer.outputColorSpace 决定）
    #ifdef SRGB_TRANSFER
        color = pow(color, vec3(1.0/2.2, 1.0/2.2, 1.0/2.2));
    #endif

    gl_FragColor = vec4(color, texel.a);
}
"""

/**
 * Bloom 亮度提取 FS（UnrealBloomPass 专用，LuminosityHighPassShader）。
 * uniforms: bloomDiffuse(sampler0), bloomParams(vec4: x=threshold, y=smoothWidth, z=strength)
 */
let BLOOM_LUM_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(bloomDiffuse, 0);
uniform vec4 bloomParams;  // x=threshold, y=smoothWidth, z=strength

float lum(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void main()
{
    vec4 texel = texture2D(bloomDiffuse, v_blitUV);
    float v = lum(texel.rgb);
    // 亮度超过 threshold 的像素保留，smoothstep 平滑过渡
    float alpha = smoothstep(bloomParams.x, bloomParams.x + bloomParams.y, v);
    gl_FragColor = texel * alpha;
}
"""

/**
 * Bloom 可分离高斯模糊 FS（UnrealBloomPass 专用，_getSeparableBlurMaterial）。
 * 编译时经 compileBgfxWithDefines 传 KERNEL_RADIUS={6,10,14,18,22}，shader 内宏展开数组大小与循环。
 * uniforms: bloomColorTexture(sampler0), bloomInvSize(vec4: 1/w,1/h),
 *           bloomDirection(vec4: (1,0)水平 / (0,1)垂直), bloomGaussCoefs(vec4 数组 KERNEL_RADIUS)
 */
let BLOOM_BLUR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(bloomColorTexture, 0);
uniform vec4 bloomInvSize;   // xy = 1/width, 1/height
uniform vec4 bloomDirection; // xy = 模糊方向（水平 (1,0) / 垂直 (0,1)）
uniform vec4 bloomGaussCoefs[KERNEL_RADIUS];  // 预计算高斯系数（x=系数，yzw=padding）

void main()
{
    float weightSum = bloomGaussCoefs[0].x;
    vec3 diffuseSum = texture2D(bloomColorTexture, v_blitUV).rgb * weightSum;
    for (int i = 1; i < KERNEL_RADIUS; i++) {
        float w = bloomGaussCoefs[i].x;
        vec2 uvOffset = bloomDirection.xy * bloomInvSize.xy * float(i);
        vec3 sample1 = texture2D(bloomColorTexture, v_blitUV + uvOffset).rgb;
        vec3 sample2 = texture2D(bloomColorTexture, v_blitUV - uvOffset).rgb;
        diffuseSum += (sample1 + sample2) * w;
    }
    gl_FragColor = vec4(diffuseSum, 1.0);
}
"""

/**
 * Bloom 5 级金字塔加权混合 FS（UnrealBloomPass 专用，_getCompositeMaterial）。
 * uniforms: bloomBlur1..5(sampler0-4), bloomStrength, bloomRadius, bloomFactors(vec4 数组 5：各级权重 x)
 */
let BLOOM_COMPOSITE_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(bloomBlur1, 0);
SAMPLER2D(bloomBlur2, 1);
SAMPLER2D(bloomBlur3, 2);
SAMPLER2D(bloomBlur4, 3);
SAMPLER2D(bloomBlur5, 4);
uniform vec4 bloomStrength;  // x=strength
uniform vec4 bloomRadius;    // x=radius
uniform vec4 bloomFactors[5]; // 各级权重（x）

float lerpBloomFactor(in float factor) {
    float mirrorFactor = 1.2 - factor;
    return mix(factor, mirrorFactor, bloomRadius.x);
}

void main()
{
    vec3 bloom = 3.0 * bloomStrength.x * (
        lerpBloomFactor(bloomFactors[0].x) * texture2D(bloomBlur1, v_blitUV).rgb +
        lerpBloomFactor(bloomFactors[1].x) * texture2D(bloomBlur2, v_blitUV).rgb +
        lerpBloomFactor(bloomFactors[2].x) * texture2D(bloomBlur3, v_blitUV).rgb +
        lerpBloomFactor(bloomFactors[3].x) * texture2D(bloomBlur4, v_blitUV).rgb +
        lerpBloomFactor(bloomFactors[4].x) * texture2D(bloomBlur5, v_blitUV).rgb
    );
    float bloomAlpha = max(bloom.r, max(bloom.g, bloom.b));
    gl_FragColor = vec4(bloom, bloomAlpha);
}
"""

/**
 * Bloom 加性叠加 FS（UnrealBloomPass 专用，CopyShader + AdditiveBlending）。
 * uniforms: bloomTexture(sampler0 = composite 结果), bloomScene(sampler1 = readBuffer 场景)
 */
let BLOOM_BLEND_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(bloomTexture, 0);
SAMPLER2D(bloomScene, 1);

void main()
{
    vec3 sceneColor = texture2D(bloomScene, v_blitUV).rgb;
    vec3 bloomColor = texture2D(bloomTexture, v_blitUV).rgb;
    gl_FragColor = vec4(sceneColor + bloomColor, 1.0);
}
"""

/**
 * BloomPass（简单版）卷积 VS（BloomPass 专用，ConvolutionShader）。
 *
 * bgfx 差异：
 *   - VS 在 vUv 基础上整体偏移 (KERNEL_SIZE_FLOAT-1)/2 × uImageIncrement，
 *     使 FS 循环采样从"核左端"开始、逐次递增到右端（核中心对齐像素）。
 *   - bgfx uniform 最小单位 vec4，uImageIncrement 用 vec4（xy=增量，zw=0）。
 *   - KERNEL_SIZE_FLOAT 由 compileBgfxWithDefines 传入（默认 25.0）。
 */
let BLOOM_CONV_VS = """
$input a_position
$input a_texcoord0
$output v_blitUV

#include <bgfx_shader.sh>

uniform vec4 uImageIncrement;  // xy = 卷积采样步长

void main()
{
    v_blitUV = a_texcoord0 - ((KERNEL_SIZE_FLOAT - 1.0) / 2.0) * uImageIncrement.xy;
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
}
"""

/**
 * BloomPass（简单版）卷积 FS（BloomPass 专用，ConvolutionShader）。
 *
 * bgfx 差异：
 *   - cKernel 是 float 数组；bgfx uniform 数组按 vec4 对齐，cKernel[i] 用 vec4（x=系数，yzw=padding）。
 *   - KERNEL_SIZE_INT 由 compileBgfxWithDefines 传入（默认 25），与 CPU 端 buildKernel 实际长度一致。
 */
let BLOOM_CONV_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 uImageIncrement;  // xy = 卷积采样步长
uniform vec4 cKernel[KERNEL_SIZE_INT];  // 归一化高斯核（x=系数，yzw=padding）

void main()
{
    vec2 imageCoord = v_blitUV;
    vec4 sum = vec4(0.0, 0.0, 0.0, 0.0);
    for (int i = 0; i < KERNEL_SIZE_INT; i++) {
        sum += texture2D(tDiffuse, imageCoord) * cKernel[i].x;
        imageCoord += uImageIncrement.xy;
    }
    gl_FragColor = sum;
}
"""

/**
 * BloomPass（简单版）合成 FS（BloomPass 专用，CombineShader + AdditiveBlending）。
 *
 * bgfx 差异：
 *   - CombineShader 只采样 tDiffuse（模糊结果），靠 AdditiveBlending 叠加到 readBuffer 既有内容；
 *     bgfx 无全局混合状态，改为 shader 内显式相加：sceneColor + strength × blurColor。
 *   - uniforms: bloomScene(sampler0 = readBuffer 场景), bloomBlur(sampler1 = 垂直卷积结果),
 *               uStrength(vec4: x=strength)
 */
let BLOOM_COMBINE_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(bloomScene, 0);
SAMPLER2D(bloomBlur, 1);
uniform vec4 uStrength;  // x=strength

void main()
{
    vec3 sceneColor = texture2D(bloomScene, v_blitUV).rgb;
    vec3 blurColor = texture2D(bloomBlur, v_blitUV).rgb;
    gl_FragColor = vec4(sceneColor + uStrength.x * blurColor, 1.0);
}
"""

/**
 * Afterimage FS（AfterimagePass 专用，AfterimageShader）。
 * 残影算法：result = max(tNew, tOld * damp * when_gt(tOld, 0.1))
 *   - tOld 上一帧残影纹理，tNew 当前帧输入纹理
 *   - damp 阻尼系数（0~1），越大残影衰减越慢、拖尾越长
 *   - when_gt(x, y) 逐分量阈值门控：x>y 返回 1，否则 0
 *     用于把亮度低于 0.1 的残影像素清零，避免低能量噪声无限累积
 * bgfx 差异：
 *   - shader 用 texture2D（GLSL ES），bgfx .sc 同样用 texture2D（shaderc 跨平台兼容）
 *   - uniform damp 是 float；bgfx uniform 最小单位 vec4，故用 u_damp(vec4: x=damp)
 *   - tOld/tNew 是 sampler2D；bgfx 用 SAMPLER2D 宏声明（stage 由 SamplerStages 注入）
 *     本 shader 按固定 stage 0=tOld、1=tNew 绑定（AfterimagePass.render 内 bindTexture）
 */
let AFTERIMAGE_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tOld, 0);
SAMPLER2D(tNew, 1);
uniform vec4 u_damp;  // x=damp (0~1)

vec4 when_gt(vec4 x, float y)
{
    return max(sign(x - y), 0.0);
}

void main()
{
    vec4 texelOld = texture2D(tOld, v_blitUV);
    vec4 texelNew = texture2D(tNew, v_blitUV);

    texelOld *= u_damp.x * when_gt(texelOld, 0.1);

    gl_FragColor = max(texelNew, texelOld);
}
"""

/**
 * Film FS（FilmPass 专用，FilmShader）。
 *
 * 算法：
 *   1. base = texture2D(tDiffuse, v_blitUV)              // 当前帧输入
 *   2. noise = rand(fract(vUv + time))                   // 逐像素随机噪声
 *   3. color = base.rgb + base.rgb * clamp(0.1 + noise, 0, 1)  // 噪声叠加
 *   4. color = mix(base.rgb, color, intensity)           // 按强度混合
 *   5. if grayscale: color = vec3(luminance(color))      // 灰度转换
 *
 * uniforms：
 *   - tDiffuse  : sampler2D（当前帧输入）→ SAMPLER2D(tDiffuse, 0)
 *   - time      : float（动画时间）→ u_time(vec4: x=time)
 *   - intensity : float（0~1，颗粒强度）→ u_intensity(vec4: x=intensity)
 *   - grayscale : bool（是否灰度）→ u_grayscale(vec4: x=grayscale, 0/1)
 *
 * bgfx 差异：
 *   - shader 用 texture2D（GLSL ES），bgfx .sc 同样用 texture2D（shaderc 跨平台兼容）
 *   - uniform 是 float/bool；bgfx uniform 最小单位 vec4，故用 u_xxx(vec4: x=value)
 *   - 用 #include <common> 引入 rand/luminance；bgfx 侧内联实现（避免 chunk 依赖）
 *   - rand 本质是伪随机哈希：
 *       float rand(vec2 co) { return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453); }
 *   - luminance 用 Rec. 709 权重：
 *       float luminance(vec3 rgb) { return dot(rgb, vec3(0.2126, 0.7152, 0.0722)); }
 */
let FILM_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_intensity;   // x = intensity (0~1)
uniform vec4 u_grayscale;   // x = grayscale (0.0 / 1.0)
uniform vec4 u_time;        // x = time (秒)

// 伪随机噪声 rand
// rand(co) = fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453)
float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// 亮度（Rec. 709 权重）
float luminance(vec3 rgb)
{
    return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

void main()
{
    // 1. 当前帧输入
    vec4 base = texture2D(tDiffuse, v_blitUV);

    // 2. 逐像素随机噪声（vUv + time 偏移产生动态颗粒）
    float noise = rand(fract(v_blitUV + u_time.x));

    // 3. 噪声叠加到颜色（低强度噪声 + 基色增强）
    vec3 color = base.rgb + base.rgb * clamp(0.1 + noise, 0.0, 1.0);

    // 4. 按 intensity 混合原色与噪声色
    color = mix(base.rgb, color, u_intensity.x);

    // 5. 灰度转换（可选）
    // 注意：单参数 vec3(luminance(...)) 经 shaderc 转 HLSL 后报
    // X3014 incorrect number of arguments（D3DCompile 不接受 float3(funcCall) 形式），
    // 故先取标量再用显式三参数构造。
    if (u_grayscale.x > 0.5) {
        float lum = luminance(color);
        color = vec3(lum, lum, lum);
    }

    gl_FragColor = vec4(color, base.a);
}
"""

/**
 * Glitch FS（GlitchPass 专用，DigitalGlitch 完整非简化移植）。
 *
 * 算法：
 *   1. disp = texture2D(tDisp, p*seed*seed).r        // 数字方块位移贴图
 *   2. 行块扭曲：if(p.y<distortion_x+col_s && p.y>distortion_x-col_s*seed) p.y = ...
 *   3. 列块扭曲：if(p.x<distortion_y+col_s && p.x>distortion_y-col_s*seed) p.x = ...
 *   4. p.x += disp*seed_x*(seed/5.); p.y += disp*seed_y*(seed/5.)  // 位移叠加
 *   5. RGB shift：offset = amount * vec2(cos(angle), sin(angle))
 *      cr = texture2D(tDiffuse, p + offset); cb = texture2D(tDiffuse, p - offset)
 *      gl_FragColor = vec4(cr.r, cga.g, cb.b, cga.a)
 *   6. snow 噪声：gl_FragColor += 200.*amount*vec4(rand(...)*0.2)
 *   7. byp>=1 时直接 texture2D(tDiffuse, vUv) 透传
 *
 * uniforms（完整 9 个 + byp）：
 *   - tDiffuse    : sampler2D（当前帧输入）→ SAMPLER2D(tDiffuse, 0)
 *   - tDisp       : sampler2D（位移贴图）→ SAMPLER2D(tDisp, 1)
 *   - byp         : int（是否跳过 glitch）→ u_byp(vec4: x=byp, 0/1)
 *   - amount      : float（RGB shift 量）→ u_amount(vec4: x=amount)
 *   - angle       : float（RGB shift 方向）→ u_angle(vec4: x=angle)
 *   - seed        : float（每帧 Math.random()）→ u_seed(vec4: x=seed)
 *   - seed_x      : float（-1,1 横向位移种子）→ u_seed_x(vec4: x=seed_x)
 *   - seed_y      : float（-1,1 纵向位移种子）→ u_seed_y(vec4: x=seed_y)
 *   - distortion_x: float（行块扭曲中心）→ u_distortion_x(vec4: x=distortion_x)
 *   - distortion_y: float（列块扭曲中心）→ u_distortion_y(vec4: x=distortion_y)
 *   - col_s       : float（块宽阈值，默认 0.05）→ u_col_s(vec4: x=col_s)
 *
 * bgfx 差异：
 *   - shader 用 texture2D（GLSL ES）；bgfx .sc 同样用 texture2D（shaderc 跨平台兼容）
 *   - uniform 是 float/int；bgfx uniform 最小单位 vec4，故用 u_xxx(vec4: x=value)
 *     byp 是 int → 用 vec4.x 表示（>0.5 视为 byp=1）
 *   - 用 uniform sampler2D tDisp；bgfx 用 SAMPLER2D(tDisp, 1) 绑 stage 1
 *     （stage 0 = tDiffuse，stage 1 = tDisp，避免冲突）
 *   - gl_FragCoord 像素坐标；bgfx 同样提供 gl_FragCoord（shaderc 内置）
 *   - rand 函数与 FilmShader 共用同一实现（fract(sin(dot)*43758.5453)）
 *   - UV 差异：bgfx 纹理原点左上（V 向下），但 tDiffuse/tDisp 均来自 RT/upload，
 *     shader 内 v_blitUV 一致地来自 a_texcoord0，与 FilmPass 范式一致无需翻转。
 */
let GLITCH_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);   // stage 0: 当前帧输入
SAMPLER2D(tDisp, 1);      // stage 1: 位移贴图（数字方块噪声）

// uniforms（bgfx 最小单位 vec4，x=value）
uniform vec4 u_byp;          // x = byp (0.0 / 1.0)
uniform vec4 u_amount;       // x = amount (RGB shift 量)
uniform vec4 u_angle;        // x = angle (RGB shift 方向)
uniform vec4 u_seed;         // x = seed (每帧随机)
uniform vec4 u_seed_x;       // x = seed_x (-1,1)
uniform vec4 u_seed_y;       // x = seed_y (-1,1)
uniform vec4 u_distortion_x; // x = distortion_x (行块扭曲中心)
uniform vec4 u_distortion_y; // x = distortion_y (列块扭曲中心)
uniform vec4 u_col_s;        // x = col_s (块宽阈值)

// 伪随机噪声 rand
float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    // byp >= 1: 直接透传，不应用 glitch
    if (u_byp.x >= 0.5) {
        gl_FragColor = texture2D(tDiffuse, v_blitUV);
        return;
    }

    vec2 p = v_blitUV;
    float seed = u_seed.x;

    // 数字方块位移（disp = texture2D(tDisp, p*seed*seed).r）
    float disp = texture2D(tDisp, p * seed * seed).r;

    // 行块扭曲（if(p.y<distortion_x+col_s && p.y>distortion_x-col_s*seed)）
    float dx = u_distortion_x.x;
    float dy = u_distortion_y.x;
    float cs = u_col_s.x;
    if (p.y < dx + cs && p.y > dx - cs * seed) {
        if (u_seed_x.x > 0.0) {
            p.y = 1.0 - (p.y + dy);
        } else {
            p.y = dy;
        }
    }
    // 列块扭曲（if(p.x<distortion_y+col_s && p.x>distortion_y-col_s*seed)）
    if (p.x < dy + cs && p.x > dy - cs * seed) {
        if (u_seed_y.x > 0.0) {
            p.x = dx;
        } else {
            p.x = 1.0 - (p.x + dx);
        }
    }

    // 位移叠加（p.x+=disp*seed_x*(seed/5.); p.y+=disp*seed_y*(seed/5.)）
    p.x += disp * u_seed_x.x * (seed / 5.0);
    p.y += disp * u_seed_y.x * (seed / 5.0);

    // RGB shift（offset = amount * vec2(cos(angle), sin(angle))）
    vec2 offset = u_amount.x * vec2(cos(u_angle.x), sin(u_angle.x));
    vec4 cr = texture2D(tDiffuse, p + offset);
    vec4 cga = texture2D(tDiffuse, p);
    vec4 cb = texture2D(tDiffuse, p - offset);
    gl_FragColor = vec4(cr.r, cga.g, cb.b, cga.a);

    // snow 噪声（snow = 200.*amount*vec4(rand(...)*0.2)）
    // 用 gl_FragCoord.x/0.5 floor 作为 rand 输入，此处对齐
    float xs = floor(gl_FragCoord.x / 0.5);
    float ys = floor(gl_FragCoord.y / 0.5);
    // snow 噪声（snow = 200.*amount*vec4(rand(...)*0.2)）
    // 注意：shaderc 转 HLSL 后，单参数 vec4(scalar) 报 X3014，
    // 故先取标量 s，再用 vec4(s, s, s, s) 显式构造。
    float snowScalar = 200.0 * u_amount.x * (rand(vec2(xs * seed, ys * seed * 50.0)) * 0.2);
    vec4 snow = vec4(snowScalar, snowScalar, snowScalar, snowScalar);
    gl_FragColor = gl_FragColor + snow;
}
"""

/**
 * DotScreen FS（DotScreenPass 专用，DotScreenShader 完整非简化移植）。
 *
 * 算法：
 *   1. pattern() 旋转点阵生成：
 *      s = sin(angle); c = cos(angle)
 *      tex = vUv * tSize - center
 *      point = (c*tex.x - s*tex.y, s*tex.x + c*tex.y) * scale
 *      return (sin(point.x) * sin(point.y)) * 4.0
 *   2. color = texture2D(tDiffuse, vUv)
 *   3. average = (color.r + color.g + color.b) / 3.0
 *   4. gl_FragColor = vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a)
 *      ↑ average*10-5 把 [0,1] 亮度映射到 [-5,5]，
 *        pattern() 返回 [-4,4]，二者之和落在 [-9,9]，
 *        再 vec3() 构造灰度 → 最终 clamping 到 [0,1] 由 RT 完成
 *
 * uniforms（完整 5 个）：
 *   - tDiffuse : sampler2D（当前帧输入）→ SAMPLER2D(tDiffuse, 0)
 *   - center   : vec2（点阵中心，默认 (0.5,0.5)）→ u_center(vec4: xy=center)
 *   - angle    : float（点阵旋转角，默认 1.57）→ u_angle(vec4: x=angle)
 *   - scale    : float（点阵密度，值越大点越小，默认 1.0）→ u_scale(vec4: x=scale)
 *   - tSize    : vec2（纹理尺寸，默认 (256,256)）→ u_tSize(vec4: xy=tSize)
 *
 * bgfx 差异：
 *   - shader 用 texture2D（GLSL ES）；bgfx .sc 同样用 texture2D（shaderc 跨平台兼容）
 *   - uniform center/tSize 是 vec2，angle/scale 是 float；
 *     bgfx uniform 最小单位 vec4，故用 u_center/u_tSize(vec4: xy=值)、
 *     u_angle/u_scale(vec4: x=值)。读取时用 .xy / .x。
 *   - tDiffuse 是 sampler2D；bgfx 用 SAMPLER2D 宏声明（stage 0）。
 *   - vUv 来自顶点 uv；bgfx 侧 FullScreenQuad 的 a_texcoord0 → v_blitUV，
 *     与 FilmPass/GlitchPass 范式一致，无需 UV 翻转（bgfx 原点左上，但 RT 纹理采样坐标一致）。
 *   - view id 概念不存在（渲染 API 隐式管理 view）；bgfx view id 全局稀缺，
 *     DotScreenPass 用 DOTSCREEN_VIEW_ID_BASE=226（FilmPass 224 / GlitchPass 225 之后）。
 */
let DOT_SCREEN_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_center;  // xy = center (默认 0.5, 0.5)
uniform vec4 u_angle;   // x = angle (默认 1.57)
uniform vec4 u_scale;   // x = scale (默认 1.0)
uniform vec4 u_tSize;   // xy = texture size (默认 256, 256)

void main()
{
    // 旋转点阵图案（对应 pattern()）
    // 注意：pattern() 原版是独立函数，GLSL 中 varying vUv 全局可访问；
    // bgfx shaderc 转 HLSL 后，varying v_blitUV 是 main() 的参数，作用域仅在 main() 内，
    // 外部函数无法访问 v_blitUV → 必须将 pattern() 逻辑内联到 main() 中。
    float s = sin(u_angle.x);
    float c = cos(u_angle.x);

    vec2 tex = v_blitUV * u_tSize.xy - u_center.xy;
    // 注意：变量名不能用 'point' —— HLSL 中 point 是保留关键字（点光源输入结构）
    vec2 pt = vec2(c * tex.x - s * tex.y, s * tex.x + c * tex.y) * u_scale.x;
    float pattern = (sin(pt.x) * sin(pt.y)) * 4.0;

    vec4 color = texture2D(tDiffuse, v_blitUV);

    float average = (color.r + color.g + color.b) / 3.0;

    // vec4(vec3(average * 10.0 - 5.0 + pattern()), color.a)
    // average*10-5 ∈ [-5,5]，pattern ∈ [-4,4]，之和 ∈ [-9,9]，最终灰度 RT 输出
    float v = average * 10.0 - 5.0 + pattern;
    gl_FragColor = vec4(vec3(v, v, v), color.a);
}
"""

/**
 * Halftone FS（HalftonePass 专用，HalftoneShader 完整非简化移植）。
 *
 * 算法：
 *   1. setup: p = vec2(vUV.x*width, vUV.y*height); origin=(0,0);
 *      aa = (radius<2.5)? radius*0.5 : 1.25
 *   2. getReferenceCell(p, origin, rotateR/G/B, radius) → 3 个 Cell（R/G/B 各自网格）
 *      - 计算旋转网格 n=vec2(cos,sin)，mod 步进定位到最近格点 p1 + 邻格点 p2/p3/p4
 *      - scatter!=0 时给 p1 叠加随机偏移（散点抖动）
 *   3. getDotColour(cell, p, channel, angle, aa) → 各通道网点亮度
 *      - getSample(pN) 取 8 抽头平均采样（radius*0.66 半径圆周采样）
 *      - distanceToDotRadius 按 shape(1=Dot/2=Ellipse/3=Line/4=Square/5=Diamond) 变换半径
 *      - 4 邻格点距离 → dot 半径，clamp 累加得 channel 亮度 [0,1]
 *   4. blendColour(r/g/b, colour.r/g/b, blending) 按 blendingMode(1=Linear/2=Multiply/3=Add/4=Lighter/5=Darker) 混合
 *   5. greyscale 时 r=g=b=(r+g+b)/3
 *   6. disable 时直接透传 texture2D(tDiffuse, vUV)
 *
 * uniforms（完整 12 个）：
 *   - tDiffuse   : sampler2D → SAMPLER2D(tDiffuse, 0)
 *   - shape      : int（1-5，网点形状）→ u_shape(vec4: x=shape, 1.0-5.0)
 *   - radius     : float（网点半径，默认 4）→ u_radius(vec4: x=radius)
 *   - rotateR/G/B: float（R/G/B 通道网格旋转角）→ u_rotateR/G/B(vec4: x=angle)
 *   - scatter    : float（散点抖动量，默认 0）→ u_scatter(vec4: x=scatter)
 *   - width      : float（纹理宽度）→ u_width(vec4: x=width)
 *   - height     : float（纹理高度）→ u_height(vec4: x=height)
 *   - blending   : float（混合强度 0-1）→ u_blending(vec4: x=blending)
 *   - blendingMode: int（1-5，混合模式）→ u_blendingMode(vec4: x=mode, 1.0-5.0)
 *   - greyscale  : bool（灰度切换）→ u_greyscale(vec4: x=0.0/1.0)
 *   - disable    : bool（禁用透传）→ u_disable(vec4: x=0.0/1.0)
 *
 * bgfx 差异：
 *   - shader 用 texture2D（GLSL ES）；bgfx .sc 同样用 texture2D（shaderc 跨平台兼容）
 *   - uniform 是 float/int/bool；bgfx uniform 最小单位 vec4，故用 u_xxx(vec4: x=value)
 *     int/bool 用 vec4.x 表示，比较时 u_shape.x == 1.0 视为 shape=1
 *   - varying vUV 全局可访问；bgfx HLSL 中 v_blitUV 是 main() 参数，作用域仅 main() 内。
 *     ★本 shader 的 8 个辅助函数均不直接使用 varying，只通过参数 pt/coord 等传入，
 *       故无需内联到 main()（与 DotScreen 的 pattern() 直接用 varying 不同）。
 *   - struct Cell；bgfx HLSL 支持 struct（FXAA LuminanceData/EdgeData 已验证可用）
 *   - atan(y, x)；bgfx_shader.sh 已 #define atan2(_x,_y) atan(_x,_y)，用 atan2
 *   - mod/hypot；bgfx_shader.sh 已提供 mod（BgfxShaderSource.cj:622），hypot 内联实现
 *   - 变量名规避 HLSL 保留字：point → pt，samples → SAMPLES_COUNT
 *   - const int samples = 8；bgfx 用 #define SAMPLES_COUNT 8（HLSL const 语法差异）
 *   - view id 概念不存在；bgfx view id 全局稀缺，
 *     HalftonePass 用 HALFTONE_VIEW_ID_BASE=227（FilmPass 224 / GlitchPass 225 / DotScreenPass 226 之后）。
 */
let HALFTONE_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_shape;        // x = shape (1.0=Dot 2.0=Ellipse 3.0=Line 4.0=Square 5.0=Diamond)
uniform vec4 u_radius;       // x = radius (默认 4)
uniform vec4 u_rotateR;      // x = rotateR (默认 PI/12)
uniform vec4 u_rotateG;      // x = rotateG (默认 PI/12*2)
uniform vec4 u_rotateB;      // x = rotateB (默认 PI/12*3)
uniform vec4 u_scatter;      // x = scatter (默认 0)
uniform vec4 u_width;        // x = width (纹理宽)
uniform vec4 u_height;       // x = height (纹理高)
uniform vec4 u_blending;     // x = blending (0~1)
uniform vec4 u_blendingMode; // x = blendingMode (1.0-5.0)
uniform vec4 u_greyscale;    // x = greyscale (0.0/1.0)
uniform vec4 u_disable;      // x = disable (0.0/1.0)

#define SQRT2_MINUS_ONE 0.41421356
#define SQRT2_HALF_MINUS_ONE 0.20710678
#define PI 3.14159265
#define PI2 6.28318531
#define SHAPE_DOT 1.0
#define SHAPE_ELLIPSE 2.0
#define SHAPE_LINE 3.0
#define SHAPE_SQUARE 4.0
#define SHAPE_DIAMOND 5.0
#define BLENDING_LINEAR 1.0
#define BLENDING_MULTIPLY 2.0
#define BLENDING_ADD 3.0
#define BLENDING_LIGHTER 4.0
#define BLENDING_DARKER 5.0
#define SAMPLES_COUNT 8

// 线性混合（blend）
float blend(float a, float b, float t) {
    return a * (1.0 - t) + b * t;
}

// 向量长度（hypot；bgfx 无 hypot，内联 sqrt(x*x+y*y)）
float hypot(float x, float y) {
    return sqrt(x * x + y * y);
}

// 伪随机数（rand，与 FilmShader/rand 同实现）
float rand(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// 网格采样单元（Cell）
struct Cell {
    vec2 normal;
    vec2 p1;
    vec2 p2;
    vec2 p3;
    vec2 p4;
    float samp2;
    float samp1;
    float samp3;
    float samp4;
};

// 按形状变换 dot 半径并减去距离（distanceToDotRadius）
// channel = 该通道采样亮度，coord/p = 待测点与格点，normal = 网格法向，angle = 通道旋转角，rad_max = radius
float distanceToDotRadius(float channel, vec2 coord, vec2 normal, vec2 p, float angle, float rad_max) {
    float dist = hypot(coord.x - p.x, coord.y - p.y);
    float rad = channel;

    if (u_shape.x == SHAPE_DOT) {
        rad = pow(abs(rad), 1.125) * rad_max;
    } else if (u_shape.x == SHAPE_ELLIPSE) {
        rad = pow(abs(rad), 1.125) * rad_max;
        if (dist != 0.0) {
            float dot_p = abs((p.x - coord.x) / dist * normal.x + (p.y - coord.y) / dist * normal.y);
            dist = (dist * (1.0 - SQRT2_HALF_MINUS_ONE)) + dot_p * dist * SQRT2_MINUS_ONE;
        }
    } else if (u_shape.x == SHAPE_LINE) {
        rad = pow(abs(rad), 1.5) * rad_max;
        float dot_p = (p.x - coord.x) * normal.x + (p.y - coord.y) * normal.y;
        dist = hypot(normal.x * dot_p, normal.y * dot_p);
    } else if (u_shape.x == SHAPE_SQUARE) {
        float theta = atan2(p.y - coord.y, p.x - coord.x) - angle;
        float sin_t = abs(sin(theta));
        float cos_t = abs(cos(theta));
        rad = pow(abs(rad), 1.4);
        rad = rad_max * (rad + ((sin_t > cos_t) ? rad - sin_t * rad : rad - cos_t * rad));
    } else if (u_shape.x == SHAPE_DIAMOND) {
        float angle45 = PI / 4.0;
        float theta = atan2(p.y - coord.y, p.x - coord.x) - angle - angle45;
        float sin_t = abs(sin(theta));
        float cos_t = abs(cos(theta));
        rad = pow(abs(rad), 1.4);
        rad = rad_max * (rad + ((sin_t > cos_t) ? rad - sin_t * rad : rad - cos_t * rad));
    }

    return rad - dist;
}

// 8 抽头圆周平均采样（getSample）
// 注意：参数名用 pt（HLSL point 是保留字）
vec4 getSample(vec2 pt) {
    vec4 tex = texture2D(tDiffuse, vec2(pt.x / u_width.x, pt.y / u_height.x));
    float base = rand(vec2(floor(pt.x), floor(pt.y))) * PI2;
    float step = PI2 / float(SAMPLES_COUNT);
    float dist = u_radius.x * 0.66;

    for (int i = 0; i < SAMPLES_COUNT; ++i) {
        float r = base + step * float(i);
        vec2 coord = pt + vec2(cos(r) * dist, sin(r) * dist);
        tex += texture2D(tDiffuse, vec2(coord.x / u_width.x, coord.y / u_height.x));
    }

    tex /= float(SAMPLES_COUNT) + 1.0;
    return tex;
}

// 取通道网点亮度（getDotColour）
// channel: 0=R 1=G 2=B；aa = 抗锯齿半径
float getDotColour(Cell c, vec2 p, int channel, float angle, float aa) {
    float dist_c_1, dist_c_2, dist_c_3, dist_c_4, res;

    if (channel == 0) {
        c.samp1 = getSample(c.p1).r;
        c.samp2 = getSample(c.p2).r;
        c.samp3 = getSample(c.p3).r;
        c.samp4 = getSample(c.p4).r;
    } else if (channel == 1) {
        c.samp1 = getSample(c.p1).g;
        c.samp2 = getSample(c.p2).g;
        c.samp3 = getSample(c.p3).g;
        c.samp4 = getSample(c.p4).g;
    } else {
        c.samp1 = getSample(c.p1).b;
        c.samp3 = getSample(c.p3).b;
        c.samp2 = getSample(c.p2).b;
        c.samp4 = getSample(c.p4).b;
    }

    dist_c_1 = distanceToDotRadius(c.samp1, c.p1, c.normal, p, angle, u_radius.x);
    dist_c_2 = distanceToDotRadius(c.samp2, c.p2, c.normal, p, angle, u_radius.x);
    dist_c_3 = distanceToDotRadius(c.samp3, c.p3, c.normal, p, angle, u_radius.x);
    dist_c_4 = distanceToDotRadius(c.samp4, c.p4, c.normal, p, angle, u_radius.x);
    res = (dist_c_1 > 0.0) ? clamp(dist_c_1 / aa, 0.0, 1.0) : 0.0;
    res += (dist_c_2 > 0.0) ? clamp(dist_c_2 / aa, 0.0, 1.0) : 0.0;
    res += (dist_c_3 > 0.0) ? clamp(dist_c_3 / aa, 0.0, 1.0) : 0.0;
    res += (dist_c_4 > 0.0) ? clamp(dist_c_4 / aa, 0.0, 1.0) : 0.0;
    res = clamp(res, 0.0, 1.0);
    return res;
}

// 计算包含给定点的网格单元（getReferenceCell）
// p = 待测点，origin = 网格原点，grid_angle = 通道旋转角，step = 网格步长（=radius）
Cell getReferenceCell(vec2 p, vec2 origin, float grid_angle, float step) {
    Cell c;

    vec2 n = vec2(cos(grid_angle), sin(grid_angle));
    float threshold = step * 0.5;
    float dot_normal = n.x * (p.x - origin.x) + n.y * (p.y - origin.y);
    float dot_line = -n.y * (p.x - origin.x) + n.x * (p.y - origin.y);
    vec2 offset = vec2(n.x * dot_normal, n.y * dot_normal);
    float offset_normal = mod(hypot(offset.x, offset.y), step);
    float normal_dir = (dot_normal < 0.0) ? 1.0 : -1.0;
    float normal_scale = ((offset_normal < threshold) ? -offset_normal : step - offset_normal) * normal_dir;
    float offset_line = mod(hypot((p.x - offset.x) - origin.x, (p.y - offset.y) - origin.y), step);
    float line_dir = (dot_line < 0.0) ? 1.0 : -1.0;
    float line_scale = ((offset_line < threshold) ? -offset_line : step - offset_line) * line_dir;

    // 最近角点
    c.normal = n;
    c.p1.x = p.x - n.x * normal_scale + n.y * line_scale;
    c.p1.y = p.y - n.y * normal_scale - n.x * line_scale;

    // scatter 散点抖动
    if (u_scatter.x != 0.0) {
        float off_mag = u_scatter.x * threshold * 0.5;
        float off_angle = rand(vec2(floor(c.p1.x), floor(c.p1.y))) * PI2;
        c.p1.x += cos(off_angle) * off_mag;
        c.p1.y += sin(off_angle) * off_mag;
    }

    // 邻格点
    float normal_step = normal_dir * ((offset_normal < threshold) ? step : -step);
    float line_step = line_dir * ((offset_line < threshold) ? step : -step);
    c.p2.x = c.p1.x - n.x * normal_step;
    c.p2.y = c.p1.y - n.y * normal_step;
    c.p3.x = c.p1.x + n.y * line_step;
    c.p3.y = c.p1.y - n.x * line_step;
    c.p4.x = c.p1.x - n.x * normal_step + n.y * line_step;
    c.p4.y = c.p1.y - n.y * normal_step - n.x * line_step;

    return c;
}

// 5 种混合模式（blendColour）
float blendColour(float a, float b, float t) {
    if (u_blendingMode.x == BLENDING_LINEAR) {
        return blend(a, b, 1.0 - t);
    } else if (u_blendingMode.x == BLENDING_ADD) {
        return blend(a, min(1.0, a + b), t);
    } else if (u_blendingMode.x == BLENDING_MULTIPLY) {
        return blend(a, max(0.0, a * b), t);
    } else if (u_blendingMode.x == BLENDING_LIGHTER) {
        return blend(a, max(a, b), t);
    } else if (u_blendingMode.x == BLENDING_DARKER) {
        return blend(a, min(a, b), t);
    } else {
        return blend(a, b, 1.0 - t);
    }
}

void main() {
    // disable: 直接透传原图
    if (u_disable.x > 0.5) {
        gl_FragColor = texture2D(tDiffuse, v_blitUV);
        return;
    }

    // setup
    vec2 p = vec2(v_blitUV.x * u_width.x, v_blitUV.y * u_height.x);
    vec2 origin = vec2(0.0, 0.0);
    float aa = (u_radius.x < 2.5) ? u_radius.x * 0.5 : 1.25;

    // R/G/B 各通道网格（不同旋转角 → 经典 RGB halftone 印刷风）
    Cell cell_r = getReferenceCell(p, origin, u_rotateR.x, u_radius.x);
    Cell cell_g = getReferenceCell(p, origin, u_rotateG.x, u_radius.x);
    Cell cell_b = getReferenceCell(p, origin, u_rotateB.x, u_radius.x);
    float r = getDotColour(cell_r, p, 0, u_rotateR.x, aa);
    float g = getDotColour(cell_g, p, 1, u_rotateG.x, aa);
    float b = getDotColour(cell_b, p, 2, u_rotateB.x, aa);

    // 与原色按 blending 混合
    vec4 colour = texture2D(tDiffuse, v_blitUV);
    r = blendColour(r, colour.r, u_blending.x);
    g = blendColour(g, colour.g, u_blending.x);
    b = blendColour(b, colour.b, u_blending.x);

    // 灰度（可选）
    if (u_greyscale.x > 0.5) {
        float avg = (r + b + g) / 3.0;
        r = avg; g = avg; b = avg;
    }

    gl_FragColor = vec4(r, g, b, 1.0);
}
"""

/**
 * FXAA FS（FXAAPass 专用，FXAAShader，NVIDIA FXAA 3.11 完整移植）。
 * uniforms: tDiffuse(sampler0), u_resolution(vec4: xy = 1/w, 1/h)
 */
let FXAA_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_resolution;  // xy = 1/width, 1/height

#define EDGE_STEP_COUNT 6
#define EDGE_GUESS 8.0
// 注：GLSL 数组构造器 float[EDGE_STEP_COUNT](...) 在 bgfx shaderc 转 HLSL 时不支持
// （D3DCompile 报 unexpected token '['）。
// 改用 edgeStepAt(i) 函数，GLSL/HLSL 均兼容。
float edgeStepAt(int i) {
    if (i == 0) return 1.0;
    if (i == 1) return 1.5;
    if (i == 2) return 2.0;
    if (i == 3) return 2.0;
    if (i == 4) return 2.0;
    return 4.0;
}
float _ContrastThreshold = 0.0312;
float _RelativeThreshold = 0.063;
float _SubpixelBlending = 1.0;

vec4 Sample(sampler2D tex2D, vec2 uv) {
    return texture2D(tex2D, uv);
}
float SampleLuminance(sampler2D tex2D, vec2 uv) {
    return dot(Sample(tex2D, uv).rgb, vec3(0.3, 0.59, 0.11));
}
float SampleLuminance(sampler2D tex2D, vec2 texSize, vec2 uv, float uOffset, float vOffset) {
    uv += texSize * vec2(uOffset, vOffset);
    return SampleLuminance(tex2D, uv);
}
struct LuminanceData {
    float m, n, e, s, w;
    float ne, nw, se, sw;
    float highest, lowest, contrast;
};
LuminanceData SampleLuminanceNeighborhood(sampler2D tex2D, vec2 texSize, vec2 uv) {
    LuminanceData l;
    l.m = SampleLuminance(tex2D, uv);
    l.n = SampleLuminance(tex2D, texSize, uv, 0.0, 1.0);
    l.e = SampleLuminance(tex2D, texSize, uv, 1.0, 0.0);
    l.s = SampleLuminance(tex2D, texSize, uv, 0.0, -1.0);
    l.w = SampleLuminance(tex2D, texSize, uv, -1.0, 0.0);
    l.ne = SampleLuminance(tex2D, texSize, uv, 1.0, 1.0);
    l.nw = SampleLuminance(tex2D, texSize, uv, -1.0, 1.0);
    l.se = SampleLuminance(tex2D, texSize, uv, 1.0, -1.0);
    l.sw = SampleLuminance(tex2D, texSize, uv, -1.0, -1.0);
    l.highest = max(max(max(max(l.n, l.e), l.s), l.w), l.m);
    l.lowest = min(min(min(min(l.n, l.e), l.s), l.w), l.m);
    l.contrast = l.highest - l.lowest;
    return l;
}
bool ShouldSkipPixel(LuminanceData l) {
    float threshold = max(_ContrastThreshold, _RelativeThreshold * l.highest);
    return l.contrast < threshold;
}
float DeterminePixelBlendFactor(LuminanceData l) {
    float f = 2.0 * (l.n + l.e + l.s + l.w);
    f += l.ne + l.nw + l.se + l.sw;
    f *= 1.0 / 12.0;
    f = abs(f - l.m);
    f = clamp(f / l.contrast, 0.0, 1.0);
    float blendFactor = smoothstep(0.0, 1.0, f);
    return blendFactor * blendFactor * _SubpixelBlending;
}
struct EdgeData {
    bool isHorizontal;
    float pixelStep;
    float oppositeLuminance, gradient;
};
EdgeData DetermineEdge(vec2 texSize, LuminanceData l) {
    EdgeData e;
    float horizontal =
        abs(l.n + l.s - 2.0 * l.m) * 2.0 +
        abs(l.ne + l.se - 2.0 * l.e) +
        abs(l.nw + l.sw - 2.0 * l.w);
    float vertical =
        abs(l.e + l.w - 2.0 * l.m) * 2.0 +
        abs(l.ne + l.nw - 2.0 * l.n) +
        abs(l.se + l.sw - 2.0 * l.s);
    e.isHorizontal = horizontal >= vertical;
    float pLuminance = e.isHorizontal ? l.n : l.e;
    float nLuminance = e.isHorizontal ? l.s : l.w;
    float pGradient = abs(pLuminance - l.m);
    float nGradient = abs(nLuminance - l.m);
    e.pixelStep = e.isHorizontal ? texSize.y : texSize.x;
    if (pGradient < nGradient) {
        e.pixelStep = -e.pixelStep;
        e.oppositeLuminance = nLuminance;
        e.gradient = nGradient;
    } else {
        e.oppositeLuminance = pLuminance;
        e.gradient = pGradient;
    }
    return e;
}
float DetermineEdgeBlendFactor(sampler2D tex2D, vec2 texSize, LuminanceData l, EdgeData e, vec2 uv) {
    vec2 uvEdge = uv;
    vec2 edgeStep;
    if (e.isHorizontal) {
        uvEdge.y += e.pixelStep * 0.5;
        edgeStep = vec2(texSize.x, 0.0);
    } else {
        uvEdge.x += e.pixelStep * 0.5;
        edgeStep = vec2(0.0, texSize.y);
    }
    float edgeLuminance = (l.m + e.oppositeLuminance) * 0.5;
    float gradientThreshold = e.gradient * 0.25;
    vec2 puv = uvEdge + edgeStep * edgeStepAt(0);
    float pLuminanceDelta = SampleLuminance(tex2D, puv) - edgeLuminance;
    bool pAtEnd = abs(pLuminanceDelta) >= gradientThreshold;
    for (int i = 1; i < EDGE_STEP_COUNT && !pAtEnd; i++) {
        puv += edgeStep * edgeStepAt(i);
        pLuminanceDelta = SampleLuminance(tex2D, puv) - edgeLuminance;
        pAtEnd = abs(pLuminanceDelta) >= gradientThreshold;
    }
    if (!pAtEnd) {
        puv += edgeStep * EDGE_GUESS;
    }
    vec2 nuv = uvEdge - edgeStep * edgeStepAt(0);
    float nLuminanceDelta = SampleLuminance(tex2D, nuv) - edgeLuminance;
    bool nAtEnd = abs(nLuminanceDelta) >= gradientThreshold;
    for (int i = 1; i < EDGE_STEP_COUNT && !nAtEnd; i++) {
        nuv -= edgeStep * edgeStepAt(i);
        nLuminanceDelta = SampleLuminance(tex2D, nuv) - edgeLuminance;
        nAtEnd = abs(nLuminanceDelta) >= gradientThreshold;
    }
    if (!nAtEnd) {
        nuv -= edgeStep * EDGE_GUESS;
    }
    float pDistance, nDistance;
    if (e.isHorizontal) {
        pDistance = puv.x - uv.x;
        nDistance = uv.x - nuv.x;
    } else {
        pDistance = puv.y - uv.y;
        nDistance = uv.y - nuv.y;
    }
    float shortestDistance;
    bool deltaSign;
    if (pDistance <= nDistance) {
        shortestDistance = pDistance;
        deltaSign = pLuminanceDelta >= 0.0;
    } else {
        shortestDistance = nDistance;
        deltaSign = nLuminanceDelta >= 0.0;
    }
    if (deltaSign == (l.m - edgeLuminance >= 0.0)) {
        return 0.0;
    }
    return 0.5 - shortestDistance / (pDistance + nDistance);
}
vec4 ApplyFXAA(sampler2D tex2D, vec2 texSize, vec2 uv) {
    LuminanceData luminance = SampleLuminanceNeighborhood(tex2D, texSize, uv);
    if (ShouldSkipPixel(luminance)) {
        return Sample(tex2D, uv);
    }
    float pixelBlend = DeterminePixelBlendFactor(luminance);
    EdgeData edge = DetermineEdge(texSize, luminance);
    float edgeBlend = DetermineEdgeBlendFactor(tex2D, texSize, luminance, edge, uv);
    float finalBlend = max(pixelBlend, edgeBlend);
    if (edge.isHorizontal) {
        uv.y += edge.pixelStep * finalBlend;
    } else {
        uv.x += edge.pixelStep * finalBlend;
    }
    return Sample(tex2D, uv);
}
void main() {
    gl_FragColor = ApplyFXAA(tDiffuse, u_resolution.xy, v_blitUV);
}
"""

/**
 * SMAA Edges FS（SMAAPass 第 1 遍，SMAAShader SMAAColorEdgeDetectionPS）。
 * uniforms: tDiffuse(sampler0), u_resolution(vec4: xy = 1/w, 1/h)
 * 输出 vec4 edges（xy = 水平/垂直边缘标志，zw=0）
 */
let SMAA_EDGES_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

uniform vec4 u_resolution;  // xy = 1/width, 1/height

SAMPLER2D(tDiffuse, 0);

#define SMAA_THRESHOLD 0.1

vec4 SMAAColorEdgeDetectionPS(vec2 texcoord, vec2 texel, sampler2D colorTex) {
    vec2 threshold = vec2(SMAA_THRESHOLD, SMAA_THRESHOLD);
    vec4 delta;
    vec3 C = texture2D(colorTex, texcoord).rgb;
    vec3 Cleft = texture2D(colorTex, texcoord - vec2(texel.x, 0.0)).rgb;
    vec3 t = abs(C - Cleft);
    delta.x = max(max(t.r, t.g), t.b);
    vec3 Ctop = texture2D(colorTex, texcoord - vec2(0.0, texel.y)).rgb;
    t = abs(C - Ctop);
    delta.y = max(max(t.r, t.g), t.b);
    vec2 edges = step(threshold, delta.xy);
    if (dot(edges, vec2(1.0, 1.0)) == 0.0) {
        discard;
    }
    vec3 Cright = texture2D(colorTex, texcoord + vec2(texel.x, 0.0)).rgb;
    t = abs(C - Cright);
    delta.z = max(max(t.r, t.g), t.b);
    vec3 Cbottom = texture2D(colorTex, texcoord + vec2(0.0, texel.y)).rgb;
    t = abs(C - Cbottom);
    delta.w = max(max(t.r, t.g), t.b);
    float maxDelta = max(max(max(delta.x, delta.y), delta.z), delta.w);
    vec3 Cleftleft = texture2D(colorTex, texcoord - 2.0 * vec2(texel.x, 0.0)).rgb;
    t = abs(C - Cleftleft);
    delta.z = max(max(t.r, t.g), t.b);
    vec3 Ctoptop = texture2D(colorTex, texcoord - 2.0 * vec2(0.0, texel.y)).rgb;
    t = abs(C - Ctoptop);
    delta.w = max(max(t.r, t.g), t.b);
    maxDelta = max(max(maxDelta, delta.z), delta.w);
    edges.xy *= step(0.5 * maxDelta, delta.xy);
    return vec4(edges, 0.0, 0.0);
}

void main() {
    gl_FragColor = SMAAColorEdgeDetectionPS(v_blitUV, u_resolution.xy, tDiffuse);
}
"""

/**
 * SMAA Weights FS（SMAAPass 第 2 遍，SMAAShader SMAABlendingWeightCalculationPS）。
 * uniforms: tDiffuse(edgesTex, sampler0), tArea(areaTex, sampler1), tSearch(searchTex, sampler2),
 *           u_resolution(vec4: xy = 1/w, 1/h)
 * 输出 vec4 weights（混合权重，rg = 水平方向，ba = 垂直方向）
 */
let SMAA_WEIGHTS_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

uniform vec4 u_resolution;  // xy = 1/width, 1/height

SAMPLER2D(tDiffuse, 0);  // edges texture
SAMPLER2D(tArea, 1);     // area texture
SAMPLER2D(tSearch, 2);   // search texture

#define SMAA_MAX_SEARCH_STEPS 8
#define SMAA_AREATEX_MAX_DISTANCE 16
#define SMAA_AREATEX_PIXEL_SIZE (1.0 / vec2(160.0, 560.0))
#define SMAA_AREATEX_SUBTEX_SIZE (1.0 / 7.0)

vec2 round(vec2 x) {
    return sign(x) * floor(abs(x) + 0.5);
}

float SMAASearchLength(sampler2D searchTex, vec2 e, float bias, float scale) {
    e.r = bias + e.r * scale;
    return 255.0 * texture2D(searchTex, e).r;
}

float SMAASearchXLeft(sampler2D edgesTex, sampler2D searchTex, vec2 texcoord, float end) {
    vec2 e = vec2(0.0, 1.0);
    for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
        e = texture2D(edgesTex, texcoord).rg;
        texcoord -= 2.0 * vec2(u_resolution.x, 0.0);
        if (!(texcoord.x > end && e.g > 0.8281 && e.r == 0.0)) break;
    }
    texcoord.x += 0.25 * u_resolution.x;
    texcoord.x += u_resolution.x;
    texcoord.x += 2.0 * u_resolution.x;
    texcoord.x -= u_resolution.x * SMAASearchLength(searchTex, e, 0.0, 0.5);
    return texcoord.x;
}

float SMAASearchXRight(sampler2D edgesTex, sampler2D searchTex, vec2 texcoord, float end) {
    vec2 e = vec2(0.0, 1.0);
    for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
        e = texture2D(edgesTex, texcoord).rg;
        texcoord += 2.0 * vec2(u_resolution.x, 0.0);
        if (!(texcoord.x < end && e.g > 0.8281 && e.r == 0.0)) break;
    }
    texcoord.x -= 0.25 * u_resolution.x;
    texcoord.x -= u_resolution.x;
    texcoord.x -= 2.0 * u_resolution.x;
    texcoord.x += u_resolution.x * SMAASearchLength(searchTex, e, 0.5, 0.5);
    return texcoord.x;
}

float SMAASearchYUp(sampler2D edgesTex, sampler2D searchTex, vec2 texcoord, float end) {
    vec2 e = vec2(1.0, 0.0);
    for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
        e = texture2D(edgesTex, texcoord).rg;
        texcoord += 2.0 * vec2(0.0, u_resolution.y);
        if (!(texcoord.y > end && e.r > 0.8281 && e.g == 0.0)) break;
    }
    texcoord.y -= 0.25 * u_resolution.y;
    texcoord.y -= u_resolution.y;
    texcoord.y -= 2.0 * u_resolution.y;
    texcoord.y += u_resolution.y * SMAASearchLength(searchTex, e.gr, 0.0, 0.5);
    return texcoord.y;
}

float SMAASearchYDown(sampler2D edgesTex, sampler2D searchTex, vec2 texcoord, float end) {
    vec2 e = vec2(1.0, 0.0);
    for (int i = 0; i < SMAA_MAX_SEARCH_STEPS; i++) {
        e = texture2D(edgesTex, texcoord).rg;
        texcoord -= 2.0 * vec2(0.0, u_resolution.y);
        if (!(texcoord.y < end && e.r > 0.8281 && e.g == 0.0)) break;
    }
    texcoord.y += 0.25 * u_resolution.y;
    texcoord.y += u_resolution.y;
    texcoord.y += 2.0 * u_resolution.y;
    texcoord.y -= u_resolution.y * SMAASearchLength(searchTex, e.gr, 0.5, 0.5);
    return texcoord.y;
}

vec2 SMAAArea(sampler2D areaTex, vec2 dist, float e1, float e2, float offset) {
    vec2 texcoord = float(SMAA_AREATEX_MAX_DISTANCE) * round(4.0 * vec2(e1, e2)) + dist;
    texcoord = SMAA_AREATEX_PIXEL_SIZE * texcoord + (0.5 * SMAA_AREATEX_PIXEL_SIZE);
    texcoord.y += SMAA_AREATEX_SUBTEX_SIZE * offset;
    return texture2D(areaTex, texcoord).rg;
}

vec4 SMAABlendingWeightCalculationPS(vec2 texcoord, sampler2D edgesTex, sampler2D areaTex, sampler2D searchTex) {
    vec4 weights = vec4(0.0, 0.0, 0.0, 0.0);
    vec2 e = texture2D(edgesTex, texcoord).rg;
    if (e.g > 0.0) {
        vec2 d;
        vec2 coords;
        coords.x = SMAASearchXLeft(edgesTex, searchTex, texcoord - vec2(0.25, 0.125) * u_resolution, texcoord.x - 2.0 * u_resolution.x);
        d.x = coords.x;
        coords.y = texcoord.y - 0.25 * u_resolution.y;
        float e1 = texture2D(edgesTex, coords).r;
        coords.x = SMAASearchXRight(edgesTex, searchTex, texcoord + vec2(0.125, 0.25) * u_resolution - vec2(0.0, 0.0), texcoord.x + 2.0 * u_resolution.x);
        d.y = coords.x;
        d = d / u_resolution.x - (texcoord.x / u_resolution.x - 0.5 * (texcoord.x / u_resolution.x));
        vec2 sqrt_d = sqrt(abs(d));
        coords.y -= 1.0 * u_resolution.y;
        float e2 = texture2D(edgesTex, coords).r;
        weights.rg = SMAAArea(areaTex, sqrt_d, e1, e2, 0.0);
    }
    if (e.r > 0.0) {
        vec2 d;
        vec2 coords;
        coords.y = SMAASearchYUp(edgesTex, searchTex, texcoord + vec2(0.25, 0.125) * u_resolution, texcoord.y + 2.0 * u_resolution.y);
        d.x = coords.y;
        coords.x = texcoord.x + 0.25 * u_resolution.x;
        float e1 = texture2D(edgesTex, coords).g;
        coords.y = SMAASearchYDown(edgesTex, searchTex, texcoord + vec2(0.125, -0.25) * u_resolution, texcoord.y - 2.0 * u_resolution.y);
        d.y = coords.y;
        d = d / u_resolution.y - (texcoord.y / u_resolution.y - 0.5 * (texcoord.y / u_resolution.y));
        vec2 sqrt_d = sqrt(abs(d));
        coords.y -= 1.0 * u_resolution.y;
        float e2 = texture2D(edgesTex, coords).g;
        weights.ba = SMAAArea(areaTex, sqrt_d, e1, e2, 1.0);
    }
    return weights;
}

void main() {
    gl_FragColor = SMAABlendingWeightCalculationPS(v_blitUV, tDiffuse, tArea, tSearch);
}
"""

/**
 * SMAA Blend FS（SMAAPass 第 3 遍，SMAAShader SMAANeighborhoodBlendingPS）。
 * uniforms: tColor(colorTex, sampler0), tDiffuse(blendTex, sampler1), u_resolution(vec4: xy = 1/w, 1/h)
 */
let SMAA_BLEND_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

uniform vec4 u_resolution;  // xy = 1/width, 1/height

SAMPLER2D(tColor, 0);     // original color texture
SAMPLER2D(tDiffuse, 1);   // blend weights texture

vec4 SMAANeighborhoodBlendingPS(vec2 texcoord, vec2 texel, sampler2D colorTex, sampler2D blendTex) {
    vec4 a;
    a.xz = texture2D(blendTex, texcoord).xz;
    a.y = texture2D(blendTex, texcoord + vec2(0.0, texel.y)).g;
    a.w = texture2D(blendTex, texcoord + vec2(texel.x, 0.0)).a;
    if (dot(a, vec4(1.0, 1.0, 1.0, 1.0)) < 1e-5) {
        return texture2D(colorTex, texcoord);
    } else {
        vec2 offset;
        offset.x = a.a > a.b ? a.a : -a.b;
        offset.y = a.g > a.r ? -a.g : a.r;
        if (abs(offset.x) > abs(offset.y)) {
            offset.y = 0.0;
        } else {
            offset.x = 0.0;
        }
        vec4 C = texture2D(colorTex, texcoord);
        texcoord += sign(offset) * texel;
        vec4 Cop = texture2D(colorTex, texcoord);
        float s = abs(offset.x) > abs(offset.y) ? abs(offset.x) : abs(offset.y);
        C.xyz = pow(C.xyz, vec3(2.2, 2.2, 2.2));
        Cop.xyz = pow(Cop.xyz, vec3(2.2, 2.2, 2.2));
        vec4 mixed = mix(C, Cop, s);
        mixed.xyz = pow(mixed.xyz, vec3(1.0 / 2.2, 1.0 / 2.2, 1.0 / 2.2));
        return mixed;
    }
}

void main() {
    gl_FragColor = SMAANeighborhoodBlendingPS(v_blitUV, u_resolution.xy, tColor, tDiffuse);
}
"""

/**
 * SSAO 全屏四边形 varying def（SSAOPass 专用，等价 shadowblit 的 a_position + a_texcoord0 → v_blitUV）。
 */
let SSAO_VARYING_DEF = """
vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec2 v_blitUV    : TEXCOORD1 = vec2(0.0, 0.0);
"""

/**
 * SSAO 全屏四边形 VS（SSAOPass 专用，等价 shadowblitVS）。
 */
let SSAO_VS = """
$input a_position
$input a_texcoord0
$output v_blitUV

#include <bgfx_shader.sh>

void main()
{
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
    v_blitUV = a_texcoord0;
}
"""

/**
 * SSAO 计算 FS（SSAOPass 专用，SSAOShader，KERNEL_SIZE=32, PERSPECTIVE_CAMERA=1）。
 * uniforms: tNormal(sampler0), tDepth(sampler1), tNoise(sampler2),
 *           u_kernel(vec4 数组 32), u_resolution, u_cameraNearFar,
 *           u_projMatrix, u_invProjMatrix, u_ssaoParams(x=kernelRadius, y=minDistance, z=maxDistance)
 */
let SSAO_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tNormal, 0);
SAMPLER2D(tDepth, 1);
SAMPLER2D(tNoise, 2);

uniform vec4 u_kernel[32];
uniform vec4 u_resolution;
uniform vec4 u_cameraNearFar;
uniform mat4 u_projMatrix;
uniform mat4 u_invProjMatrix;
uniform vec4 u_ssaoParams;  // x=kernelRadius, y=minDistance, z=maxDistance

// 左手系深度反投影（perspectiveDepthToViewZ：viewZ 为正，depth ∈ [0,1]（near→0, far→1））
// 右手系公式分母是 (far-near)*depth - far，符号相反，直接用会得到负 viewZ → 波纹
float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

// 线性深度 [0,1]（viewZToOrthographicDepth：viewZ 为正，(viewZ-near)/(far-near)）
float getLinearDepth(in vec2 uv) {
    float fragCoordZ = texture2D(tDepth, uv).x;
    float viewZ = getViewZ(fragCoordZ);
    return (viewZ - u_cameraNearFar.x) / (u_cameraNearFar.y - u_cameraNearFar.x);
}

// 左手系 view 空间位置反投影：直接用逆投影矩阵反投影 NDC。
//   bgfx 左手系 NDC z ∈ [0,1]（viewZ=near→0, far→1），故 ndc.z = depth 直接用，
//   不用 clipW 技巧（其依赖右手系投影矩阵元素与 NDC z ∈ [-1,1]）。
vec3 getViewPosition(in vec2 uv, in float depth, in float viewZ) {
    // 修复：bgfx uv.v=0 顶 ↔ NDC y=+1 顶（quad 顶点 NDC(-1,-1)↔uv(0,1)），ndc.y = 1 - 2*uv.y
    vec4 ndc = vec4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, depth, 1.0);
    vec4 viewPos = mul(u_invProjMatrix, ndc);
    return viewPos.xyz / viewPos.w;
}

void main()
{
    float depth = texture2D(tDepth, v_blitUV).x;
    // 背景：depth RT clear 为 1.0（白），far 处深度≈1.0，用阈值跳过（避免深度精度误差误判）
    if (depth >= 0.999) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }

    float viewZ = getViewZ(depth);
    vec3 viewPosition = getViewPosition(v_blitUV, depth, viewZ);
    vec3 viewNormal = texture2D(tNormal, v_blitUV).xyz * 2.0 - 1.0;

    vec2 noiseScale = vec2(u_resolution.x / 4.0, u_resolution.y / 4.0);
    // bgfx shaderc 转 HLSL 时 vec3(标量) 标量扩展构造会报 X3014，需显式分量
    float noiseR = texture2D(tNoise, v_blitUV * noiseScale).r;
    vec3 random = vec3(noiseR, noiseR, noiseR);

    vec3 tangent = normalize(random - viewNormal * dot(random, viewNormal));
    vec3 bitangent = cross(viewNormal, tangent);
    mat3 kernelMatrix = mat3(tangent, bitangent, viewNormal);

    float occlusion = 0.0;
    for (int i = 0; i < 32; i++) {
        vec3 sampleVector = mul(kernelMatrix, u_kernel[i].xyz);
        vec3 samplePoint = viewPosition + (sampleVector * u_ssaoParams.x);
        vec4 samplePointNDC = mul(u_projMatrix, vec4(samplePoint, 1.0));
        samplePointNDC /= samplePointNDC.w;
        vec2 samplePointUv = samplePointNDC.xy * 0.5 + 0.5;
        float realDepth = getLinearDepth(samplePointUv);
        float sampleDepth = (samplePoint.z - u_cameraNearFar.x) / (u_cameraNearFar.y - u_cameraNearFar.x);
        float delta = sampleDepth - realDepth;
        if (delta > u_ssaoParams.y && delta < u_ssaoParams.z) {
            occlusion += 1.0;
        }
    }
    occlusion = clamp(occlusion / 32.0, 0.0, 1.0);
    gl_FragColor = vec4(1.0 - occlusion, 1.0 - occlusion, 1.0 - occlusion, 1.0);
}
"""

/**
 * SSAO 5x5 平均模糊 FS（SSAOPass 专用，SSAOBlurShader）。
 * uniforms: tDiffuse(sampler0), u_resolution(vec4: xy = 1/w, 1/h)
 */
let SSAO_BLUR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_resolution;

void main()
{
    vec2 texelSize = vec2(1.0 / u_resolution.x, 1.0 / u_resolution.y);
    float result = 0.0;
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * texelSize;
            result += texture2D(tDiffuse, v_blitUV + offset).r;
        }
    }
    gl_FragColor = vec4(result / 25.0, result / 25.0, result / 25.0, 1.0);
}
"""

/**
 * SSAO 深度 pass varying def（SSAOPass 专用，a_position + dummy v_ndcDummy）。
 * 同 AO_DEPTH_VARYING_DEF：修复"零输入 varying 像素着色器"触发 D3DCompiler 硬崩的边缘 bug。
 */
let SSAO_DEPTH_VARYING_DEF = """
vec3 a_position : POSITION;
vec2 v_ndcDummy : TEXCOORD0 = vec2(0.0, 0.0);
"""

/**
 * SSAO 深度 pass VS（SSAOPass 专用，场景 → 深度 RT）。
 * uniforms: u_model[0]（模型矩阵）, u_viewProj（视图投影矩阵）
 */
let SSAO_DEPTH_VS = """
$input a_position
$output v_ndcDummy

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    // dummy 占位：避免 FS 零输入 varying 触发 D3DCompiler 崩
    v_ndcDummy = gl_Position.xy * 0.5 + 0.5;
}
"""

/**
 * SSAO 深度 pass FS（SSAOPass 专用，渲 viewZToOrthographicDepth 线性深度 [0,1]）。
 * uniforms: u_cameraNearFar(vec4: x=near, y=far)
 */
let SSAO_DEPTH_FS = """
$input v_ndcDummy

#include <bgfx_shader.sh>

uniform vec4 u_cameraNearFar;

void main()
{
    // v_ndcDummy 读一次避免未使用警告
    float _dummy = v_ndcDummy.x + v_ndcDummy.y;
    // gl_FragCoord.z = NDC z ∈ [0,1]（bgfx 左手系，near→0, far→1）
    // viewZ = near*far / (far - (far-near)*z_ndc)（perspectiveDepthToViewZ，左手系）
    // linDepth = (viewZ - near) / (far - near)（viewZToOrthographicDepth，near→0, far→1）
    float zNdc = gl_FragCoord.z;
    float viewZ = (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * zNdc);
    float linDepth = (viewZ - u_cameraNearFar.x) / (u_cameraNearFar.y - u_cameraNearFar.x);
    gl_FragColor = vec4(linDepth, linDepth, linDepth, _dummy * 0.0 + 1.0);
}
"""

/**
 * SSAO 遮蔽应用 FS（SSAOPass 专用，对应 SSAOPass 输出阶段）。
 * uniforms: tDiffuse(sceneColor, sampler0), tAO(blur 遮蔽图, sampler1)
 * 输出 sceneColor × ao（遮蔽变暗）。
 */
let SSAO_APPLY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tAO, 1);

void main()
{
    vec3 sceneColor = texture2D(tDiffuse, v_blitUV).rgb;
    float ao = texture2D(tAO, v_blitUV).r;
    gl_FragColor = vec4(sceneColor * ao, 1.0);
}
"""

// ============================================================================
// GTAO 系列（GTAOShader + PoissonDenoiseShader）
// ============================================================================

/**
 * AO 深度 pass varying def（GTAO/SAO/SSR 共用，a_position 唯一属性 + dummy varying v_ndcDummy）。
 *
 * 【关键修复：强制至少一个 FS varying 输入】
 * 历史上 D3DCompiler 在编译"零输入 varying 寄存器"的像素着色器时会走极端边缘路径，
 * 导致内部空指针/除零硬崩（无错误码，进程直接终止）。
 * 此处加 v_ndcDummy：texcoord0 占位，内容无用，仅保证 HLSL 至少有 1 个 input semantic。
 */
let AO_DEPTH_VARYING_DEF = """
vec3 a_position : POSITION;
vec2 v_ndcDummy : TEXCOORD0 = vec2(0.0, 0.0);
"""

/**
 * AO 深度 pass VS（GTAO/SAO 共用，场景 → 深度 RT）。
 * uniforms: u_model[0]（模型矩阵）, u_viewProj（视图投影矩阵，bgfx 预置）
 */
let AO_DEPTH_VS = """
$input a_position
$output v_ndcDummy

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    // dummy 占位：避免 FS 零输入 varying 触发 D3DCompiler 崩
    v_ndcDummy = gl_Position.xy * 0.5 + 0.5;
}
"""

/**
 * AO 深度 pass FS（GTAO/SAO 共用）：写 NDC 深度 gl_FragCoord.z 到 RGBA32F。
 * 与 ssaodepth（写线性深度）不同：GTAO/SAO shader 需要原始 NDC 深度，
 * 经 perspectiveDepthToViewZ 反算 viewZ（tDepth 语义同 DepthTexture）。
 * 深度 RT clear 为 1.0（白色=far），背景无片元时保持 1.0。
 */
let AO_DEPTH_FS = """
$input v_ndcDummy

#include <bgfx_shader.sh>

void main()
{
    // v_ndcDummy 读一次避免"未使用 varying"警告（虽不致命，保持日志干净）
    float _dummy = v_ndcDummy.x + v_ndcDummy.y;
    float zNdc = gl_FragCoord.z;
    gl_FragColor = vec4(zNdc, zNdc, zNdc, _dummy * 0.0 + 1.0);
}
"""

/**
 * GTAO 主计算 FS（GTAOPass 专用，GTAOShader）。
 *
 * 移植要点（bgfx 差异）：
 *   - SAMPLES=16 → DIRECTIONS=3 / STEPS=6 编译期常量（#define 硬编码）
 *   - NORMAL_VECTOR_TYPE=1：法线 RT 存 0.5+0.5 编码 view 空间法线，直接 *2-1 解码
 *   - DEPTH_SWIZZLING='x'：深度 RT 为 RGBA32F，NDC 深度存 x 通道
 *   - SCREEN_SPACE_RADIUS=0 / SCENE_CLIP_BOX=0：相应分支移除
 *   - 左手系：viewZ 为正，depth∈[0,1]（near→0, far→1），
 *     perspectiveDepthToViewZ 分母为 far-(far-near)*depth（无负号）
 *   - textureLod → texture2D（RT 纹理无 mip）
 *   - textureSize(tNoise) → uniform u_noiseResolution（CPU 端生成时已知尺寸）
 *   - 背景（depth>=1.0）输出白色 AO=1（RT clear 同色，等价 discard）
 *
 * uniforms: tNormal(0), tDepth(1), tNoise(2),
 *           u_resolution(vec4 xy), u_noiseResolution(vec4 xy), u_cameraNearFar(vec4 x=near y=far),
 *           u_projMatrix(mat4), u_invProjMatrix(mat4),
 *           u_gtaoParams(vec4: x=radius, y=distanceExponent, z=thickness, w=distanceFallOff),
 *           u_scale(vec4: x=scale)
 */
let GTAO_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tNormal, 0);
SAMPLER2D(tDepth, 1);
SAMPLER2D(tNoise, 2);

uniform vec4 u_resolution;
uniform vec4 u_noiseResolution;
uniform vec4 u_cameraNearFar;
uniform mat4 u_projMatrix;
uniform mat4 u_invProjMatrix;
uniform vec4 u_gtaoParams;  // x=radius, y=distanceExponent, z=thickness, w=distanceFallOff
uniform vec4 u_scale;       // x=scale

#define PI 3.141592653589793
#define SAMPLES 16

// 左手系深度反投影：viewZ 为正，depth ∈ [0,1]（near→0, far→1）
float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

// 修复：bgfx 纹理坐标 v=0 在顶部（左上角原点，v 向下），与 quad 顶点 uv 自洽；
//   uv.y 与 NDC y 反向（uv.y=0 ↔ NDC y=+1 顶）。原实现 ndc.y = uv.y*2-1 使
//   viewPos.y 上下颠倒 → AO 阴影出现在模型顶部而非底部。
vec3 getViewPosition(in vec2 screenPosition, in float depth) {
    vec4 ndc = vec4(screenPosition.x * 2.0 - 1.0, 1.0 - screenPosition.y * 2.0, depth, 1.0);
    vec4 viewPos = mul(u_invProjMatrix, ndc);
    return viewPos.xyz / viewPos.w;
}

float getDepth(in vec2 uv) {
    return texture2D(tDepth, uv).x;
}

vec3 getViewNormal(in vec2 uv) {
    return texture2D(tNormal, uv).rgb * 2.0 - 1.0;
}

vec3 getSceneUvAndDepth(in vec3 sampleViewPos) {
    vec4 sampleClipPos = mul(u_projMatrix, vec4(sampleViewPos, 1.0));
    vec2 sampleUv = vec2(sampleClipPos.x / sampleClipPos.w * 0.5 + 0.5,
                         0.5 - sampleClipPos.y / sampleClipPos.w * 0.5);
    float sampleSceneDepth = getDepth(sampleUv);
    return vec3(sampleUv, sampleSceneDepth);
}

void main()
{
    float depth = getDepth(v_blitUV);
    // 背景：depth RT clear 为 1.0（far），输出 AO=1（无遮蔽）
    if (depth >= 1.0) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }

    vec3 viewPos = getViewPosition(v_blitUV, depth);
    vec3 viewNormal = getViewNormal(v_blitUV);

    float radiusToUse = u_gtaoParams.x;

    // 噪声旋转：magic square 噪声纹理（5x5 RGBA8，RepeatWrapping）
    vec2 noiseUv = v_blitUV * u_resolution.xy / u_noiseResolution.xy;
    vec4 noiseTexel = texture2D(tNoise, noiseUv);
    vec3 randomVec = vec3(noiseTexel.x * 2.0 - 1.0, noiseTexel.y * 2.0 - 1.0, 0.0);
    vec3 tangent = normalize(randomVec);
    vec3 bitangent = vec3(-tangent.y, tangent.x, 0.0);
    mat3 kernelMatrix = mat3(tangent, bitangent, vec3(0.0, 0.0, 1.0));

    // SAMPLES=16 → DIRECTIONS=3, STEPS=(16+3-1)/3=6（编译期常量）
    const int DIRECTIONS = 3;
    const int STEPS = 6;
    float ao = 0.0;
    for (int i = 0; i < DIRECTIONS; ++i) {
        float angle = float(i) / float(DIRECTIONS) * PI;
        vec4 sampleDir = vec4(cos(angle), sin(angle), 0.0, 0.5 + 0.5 * noiseTexel.w);
        sampleDir.xyz = normalize(mul(kernelMatrix, sampleDir.xyz));

        vec3 viewDir = normalize(-viewPos.xyz);
        vec3 sliceBitangent = normalize(cross(sampleDir.xyz, viewDir));
        vec3 sliceTangent = cross(sliceBitangent, viewDir);
        vec3 normalInSlice = normalize(viewNormal - sliceBitangent * dot(viewNormal, sliceBitangent));

        vec3 tangentToNormalInSlice = cross(normalInSlice, sliceBitangent);
        vec2 cosHorizons = vec2(dot(viewDir, tangentToNormalInSlice), dot(viewDir, -tangentToNormalInSlice));

        for (int j = 0; j < STEPS; ++j) {
            vec3 sampleViewOffset = sampleDir.xyz * radiusToUse * sampleDir.w * pow(float(j + 1) / float(STEPS), u_gtaoParams.y);
            vec3 sampleSceneUvDepth = getSceneUvAndDepth(viewPos + sampleViewOffset);
            vec3 sampleSceneViewPos = getViewPosition(sampleSceneUvDepth.xy, sampleSceneUvDepth.z);
            vec3 viewDelta = sampleSceneViewPos - viewPos;
            if (abs(viewDelta.z) < u_gtaoParams.z) {
                float sampleCosHorizon = dot(viewDir, normalize(viewDelta));
                cosHorizons.x += max(0.0, (sampleCosHorizon - cosHorizons.x) * mix(1.0, 2.0 / float(j + 2), u_gtaoParams.w));
            }
            sampleSceneUvDepth = getSceneUvAndDepth(viewPos - sampleViewOffset);
            sampleSceneViewPos = getViewPosition(sampleSceneUvDepth.xy, sampleSceneUvDepth.z);
            viewDelta = sampleSceneViewPos - viewPos;
            if (abs(viewDelta.z) < u_gtaoParams.z) {
                float sampleCosHorizon = dot(viewDir, normalize(viewDelta));
                cosHorizons.y += max(0.0, (sampleCosHorizon - cosHorizons.y) * mix(1.0, 2.0 / float(j + 2), u_gtaoParams.w));
            }
        }

        vec2 sinHorizons = sqrt(vec2(1.0, 1.0) - cosHorizons * cosHorizons);
        float nx = dot(normalInSlice, sliceTangent);
        float ny = dot(normalInSlice, viewDir);
        float nxb = 0.5 * (acos(cosHorizons.y) - acos(cosHorizons.x) + sinHorizons.x * cosHorizons.x - sinHorizons.y * cosHorizons.y);
        float nyb = 0.5 * (2.0 - cosHorizons.x * cosHorizons.x - cosHorizons.y * cosHorizons.y);
        float occlusion = nx * nxb + ny * nyb;
        ao += occlusion;
    }

    ao = clamp(ao / float(DIRECTIONS), 0.0, 1.0);
    ao = pow(ao, u_scale.x);

    gl_FragColor = vec4(ao, ao, ao, 1.0);
}
"""

/**
 * GTAO 深度可视化 FS（GTAOPass 专用，GTAODepthShader）。
 * 输出 1.0 - 线性深度（far→黑, near→白），用于 OUTPUT.Depth 调试视图。
 * uniforms: tDepth(0), u_cameraNearFar(vec4: x=near, y=far)
 */
let GTAO_DEPTH_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDepth, 0);

uniform vec4 u_cameraNearFar;

// 左手系深度反投影（perspectiveDepthToViewZ）
float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

void main()
{
    float fragCoordZ = texture2D(tDepth, v_blitUV).x;
    float viewZ = getViewZ(fragCoordZ);
    float linDepth = (viewZ - u_cameraNearFar.x) / (u_cameraNearFar.y - u_cameraNearFar.x);
    gl_FragColor = vec4(1.0 - linDepth, 1.0 - linDepth, 1.0 - linDepth, 1.0);
}
"""

/**
 * GTAO 混合 FS（GTAOPass 专用，GTAOBlendShader）。
 * 输出 mix(1.0, tDiffuse.rgb, intensity)，配合 Default 输出模式将 AO 应用到场景。
 * uniforms: tDiffuse(0, pd RT), u_intensity(vec4: x=blendIntensity)
 */
let GTAO_BLEND_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);

uniform vec4 u_intensity;

void main()
{
    vec4 texel = texture2D(tDiffuse, v_blitUV);
    gl_FragColor = vec4(mix(vec3(1.0, 1.0, 1.0), texel.rgb, u_intensity.x), texel.a);
}
"""

/**
 * PoissonDenoise FS（GTAOPass 专用，PoissonDenoiseShader）。
 *
 * 移植要点（bgfx 差异）：
 *   - SAMPLE_VECTORS（编译期常量数组）→ uniform vec4 数组 u_poissonDisk[16]（CPU 端生成采样点）
 *   - NORMAL_VECTOR_TYPE=1：法线 RT 存 0.5+0.5 编码 view 空间法线，直接 *2-1 解码
 *   - DEPTH_VALUE_SOURCE=0：深度 RT 为 RGBA32F，NDC 深度存 x 通道
 *   - index uniform（恒为 0）→ 噪声纹理固定取 .x 通道
 *   - textureLod → texture2D；textureSize(tNoise) → uniform u_noiseResolution
 *   - 背景（depth>=1.0 或法线为 0）输出白色 AO=1（等价 discard，RT clear 同色）
 *
 * uniforms: tDiffuse(0, gtao RT), tNormal(1), tDepth(2), tNoise(3),
 *           u_resolution(vec4 xy), u_noiseResolution(vec4 xy), u_invProjMatrix(mat4),
 *           u_pdParams(vec4: x=lumaPhi, y=depthPhi, z=normalPhi, w=radius),
 *           u_poissonDisk(vec4 数组 16: xyz=采样点, w=0)
 */
let GTAO_PD_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tNormal, 1);
SAMPLER2D(tDepth, 2);
SAMPLER2D(tNoise, 3);

uniform vec4 u_resolution;
uniform vec4 u_noiseResolution;
uniform mat4 u_invProjMatrix;
uniform vec4 u_pdParams;  // x=lumaPhi, y=depthPhi, z=normalPhi, w=radius
uniform vec4 u_poissonDisk[16];

#define PI 3.141592653589793
#define SAMPLES 16

float getDepth(in vec2 uv) {
    return texture2D(tDepth, uv).x;
}

vec3 getViewPosition(in vec2 screenPosition, in float depth) {
    // 修复：bgfx uv.v=0 顶 ↔ NDC y=+1 顶，ndc.y 需 1 - 2*uv.y（同 GTAO_FS）
    vec4 ndc = vec4(screenPosition.x * 2.0 - 1.0, 1.0 - screenPosition.y * 2.0, depth, 1.0);
    vec4 viewPos = mul(u_invProjMatrix, ndc);
    return viewPos.xyz / viewPos.w;
}

vec3 getViewNormal(in vec2 uv) {
    return texture2D(tNormal, uv).rgb * 2.0 - 1.0;
}

float getLuminance(in vec3 a) {
    return dot(vec3(0.2125, 0.7154, 0.0721), a);
}

void denoiseSample(in vec3 center, in vec3 viewNormal, in vec3 viewPos, in vec2 sampleUv, inout vec3 denoised, inout float totalWeight) {
    vec3 neighborColor = texture2D(tDiffuse, sampleUv).rgb;
    float sampleDepth = getDepth(sampleUv);
    vec3 sampleNormal = getViewNormal(sampleUv);
    vec3 viewPosSample = getViewPosition(sampleUv, sampleDepth);

    float normalDiff = dot(viewNormal, sampleNormal);
    float normalSimilarity = pow(max(normalDiff, 0.0), u_pdParams.z);
    float lumaDiff = abs(getLuminance(neighborColor) - getLuminance(center));
    float lumaSimilarity = max(1.0 - lumaDiff / u_pdParams.x, 0.0);
    float depthDiff = abs(dot(viewPos - viewPosSample, viewNormal));
    float depthSimilarity = max(1.0 - depthDiff / u_pdParams.y, 0.0);
    float w = lumaSimilarity * depthSimilarity * normalSimilarity;

    denoised += w * neighborColor;
    totalWeight += w;
}

void main()
{
    float depth = getDepth(v_blitUV);
    vec3 viewNormal = getViewNormal(v_blitUV);
    // 背景：depth RT clear 为 1.0（far），输出 AO=1（无遮蔽）
    if (depth >= 1.0 || dot(viewNormal, viewNormal) == 0.0) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }
    vec3 center = texture2D(tDiffuse, v_blitUV).rgb;
    vec3 viewPos = getViewPosition(v_blitUV, depth);

    vec2 noiseUv = v_blitUV * u_resolution.xy / u_noiseResolution.xy;
    vec4 noiseTexel = texture2D(tNoise, noiseUv);
    // index 固定 0（默认 0）→ 取 .x 通道
    float nv = noiseTexel.x;
    vec2 noiseVec = vec2(sin(nv * 2.0 * PI), cos(nv * 2.0 * PI));
    mat2 rotationMatrix = mat2(noiseVec.x, -noiseVec.y, noiseVec.x, noiseVec.y);

    float totalWeight = 1.0;
    vec3 denoised = center;
    for (int i = 0; i < SAMPLES; i++) {
        vec3 sampleDir = u_poissonDisk[i].xyz;
        vec2 offset = mul(rotationMatrix, sampleDir.xy * (1.0 + sampleDir.z * (u_pdParams.w - 1.0)) / u_resolution.xy);
        vec2 sampleUv = v_blitUV + offset;
        denoiseSample(center, viewNormal, viewPos, sampleUv, denoised, totalWeight);
    }
    if (totalWeight > 0.0) {
        denoised /= totalWeight;
    }
    gl_FragColor = vec4(denoised, 1.0);
}
"""

/**
 * GTAO 遮蔽应用 FS（GTAOPass 专用，对应 GTAOPass 输出阶段的
 * CopyShader + GTAOBlendShader（CustomBlending）两步 → 合并为一步：
 * 输出 sceneColor × mix(1.0, ao, intensity)。
 * uniforms: tDiffuse(sceneColor, sampler0=readBuffer), tAO(ao 图, sampler1=pd RT),
 *           u_intensity(vec4: x=blendIntensity)
 */
let GTAO_APPLY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tAO, 1);

uniform vec4 u_intensity;

void main()
{
    vec3 sceneColor = texture2D(tDiffuse, v_blitUV).rgb;
    float ao = texture2D(tAO, v_blitUV).r;
    gl_FragColor = vec4(sceneColor * mix(1.0, ao, u_intensity.x), 1.0);
}
"""

// ============================================================================
// SAO 系列（SAOShader + DepthLimitedBlurShader）
// ============================================================================

/**
 * SAO 全屏四边形 varying def（与 SSAO_VARYING_DEF 等价，独立声明避免耦合）。
 */
let SAO_VARYING_DEF = """
vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec2 v_blitUV    : TEXCOORD1 = vec2(0.0, 0.0);
"""

/**
 * SAO 全屏四边形 VS（与 SSAO_VS 等价）。
 */
let SAO_VS = """
$input a_position
$input a_texcoord0
$output v_blitUV

#include <bgfx_shader.sh>

void main()
{
    gl_Position = vec4(a_position.xy, 0.0, 1.0);
    v_blitUV = a_texcoord0;
}
"""

/**
 * SAO 计算 FS（SAOShader，NUM_SAMPLES=7, NUM_RINGS=4）。
 *
 * 移植要点（bgfx 差异）：
 *   - 噪声：SAO 用 rand() 内联（GLSL common），bgfx 无 rand → 内联 hash 实现
 *   - 左手系：viewZ 为正，depth ∈ [0,1]（near→0, far→1），
 *     perspectiveDepthToViewZ 分母为 far-(far-near)*depth（无负号）
 *   - bgfx uv 原点左上、v 向下，与 quad uv 自洽；NDC y = 1 - 2*uv.y
 *   - 输出 1-occlusion 到 SAO RT（白色=1=无遮蔽），saoapply 用 sceneColor × ao
 *   - 背景（depth>=1.0-EPSILON）discard，保持 RT clear 色（白色=无遮蔽）
 *
 * uniforms:
 *   tDepth(sampler0) - NDC 深度（RGBA32F，aodepth pass 写 gl_FragCoord.z）
 *   tNormal(sampler1) - view 空间法线（0.5+0.5 编码，RGBA16F）
 *   u_size(vec4 xy) - RT 尺寸
 *   u_cameraNearFar(vec4 x=near y=far)
 *   u_projMatrix(mat4), u_invProjMatrix(mat4)
 *   u_saoParams(vec4: x=scale, y=intensity, z=bias, w=kernelRadius)
 *   u_minResSeed(vec4: x=minResolution, y=randomSeed)
 */
let SAO_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

#define PI 3.141592653589793
#define PI2 6.283185307179586
#define EPSILON 0.0001
#define NUM_SAMPLES 7
#define NUM_RINGS 4

SAMPLER2D(tDepth, 0);
SAMPLER2D(tNormal, 1);

uniform vec4 u_size;
uniform vec4 u_cameraNearFar;
uniform mat4 u_projMatrix;
uniform mat4 u_invProjMatrix;
uniform vec4 u_saoParams;     // x=scale, y=intensity, z=bias, w=kernelRadius
uniform vec4 u_minResSeed;    // x=minResolution, y=randomSeed

// 左手系 perspectiveDepthToViewZ：viewZ 为正，depth ∈ [0,1]
float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

float getDepth(in vec2 uv) {
    return texture2D(tDepth, uv).x;
}

// bgfx uv 原点左上、v 向下；NDC y = 1 - 2*uv.y（uv.y=0 ↔ NDC y=+1 顶）
vec3 getViewPosition(in vec2 screenPosition, in float depth, in float viewZ) {
    vec4 ndc = vec4(screenPosition.x * 2.0 - 1.0, 1.0 - screenPosition.y * 2.0, depth, 1.0);
    vec4 viewPos = mul(u_invProjMatrix, ndc);
    return viewPos.xyz / viewPos.w;
}

vec3 getViewNormal(in vec2 screenPosition) {
    return texture2D(tNormal, screenPosition).xyz * 2.0 - 1.0;
}

// 内联伪随机（bgfx 无 rand）：基于 uv + seed 的 hash
float rand(in vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float getOcclusion(in vec3 centerViewPosition, in vec3 centerViewNormal, in vec3 sampleViewPosition) {
    float scaleDividedByCameraFar = u_saoParams.x / u_cameraNearFar.y;
    float minResolutionMultipliedByCameraFar = u_minResSeed.x * u_cameraNearFar.y;

    vec3 viewDelta = sampleViewPosition - centerViewPosition;
    float viewDistance = length(viewDelta);
    float scaledScreenDistance = scaleDividedByCameraFar * viewDistance;

    return max(0.0, (dot(centerViewNormal, viewDelta) - minResolutionMultipliedByCameraFar) / scaledScreenDistance - u_saoParams.z) / (1.0 + scaledScreenDistance * scaledScreenDistance);
}

void main()
{
    float centerDepth = getDepth(v_blitUV);
    if (centerDepth >= 1.0 - EPSILON) {
        // bgfx4cj: 背景像素保留场景色（ao=1.0），不 discard → 否则 ao=0 使 apply 后背景全黑
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }

    float centerViewZ = getViewZ(centerDepth);
    vec3 viewPosition = getViewPosition(v_blitUV, centerDepth, centerViewZ);
    vec3 centerViewNormal = getViewNormal(v_blitUV);

    // 全部内联到 main()，避免辅助函数引用 v_blitUV 导致 shaderc HLSL 转译报
    // "undeclared identifier 'v_blitUV'"（varying 不自动传播到函数作用域）
    float angle = rand(v_blitUV + vec2(u_minResSeed.y, u_minResSeed.y)) * PI2;
    // 注意：bgfx shaderc 转 HLSL 时 vec2(标量) 标量扩展构造报 X3014，必须用 vec2(x,x)
    float radiusScalar = u_saoParams.w * (1.0 / float(NUM_SAMPLES));
    vec2 radius = vec2(radiusScalar, radiusScalar) / u_size.xy;
    vec2 radiusStep = radius;
    float occlusionSum = 0.0;
    float weightSum = 0.0;

    for (int i = 0; i < NUM_SAMPLES; i++) {
        vec2 sampleUv = v_blitUV + vec2(cos(angle), sin(angle)) * radius;
        radius += radiusStep;
        angle += PI2 * float(NUM_RINGS) / float(NUM_SAMPLES);

        float sampleDepth = getDepth(sampleUv);
        if (sampleDepth >= 1.0 - EPSILON) {
            continue;
        }

        float sampleViewZ = getViewZ(sampleDepth);
        vec3 sampleViewPosition = getViewPosition(sampleUv, sampleDepth, sampleViewZ);
        occlusionSum += getOcclusion(viewPosition, centerViewNormal, sampleViewPosition);
        weightSum += 1.0;
    }

    float ambientOcclusion = 0.0;
    if (weightSum > 0.0) {
        ambientOcclusion = occlusionSum * (u_saoParams.y / weightSum);
    }

    // 输出 1-occlusion（白色=无遮蔽），saoapply 用 sceneColor × ao
    float ao = clamp(1.0 - ambientOcclusion, 0.0, 1.0);
    gl_FragColor = vec4(ao, ao, ao, 1.0);
}
"""

/**
 * SAO 深度受限高斯模糊 FS（DepthLimitedBlurShader）。
 *
 * 两遍分离高斯：vBlur(0,1)→blur RT，hBlur(1,0)→写回 sao RT。
 * 深度受限：邻近片元 view 空间深度差超 depthCutoff 时停止模糊（保边）。
 * KERNEL_RADIUS 固定 8（默认 saoBlurRadius=8），shader 数组 9 项。
 *
 * uniforms:
 *   tDiffuse(sampler0) - 输入图（sao RT 或 blur RT）
 *   tDepth(sampler1) - NDC 深度（用于深度受限判断）
 *   u_size(vec4 xy) - RT 尺寸
 *   u_cameraNearFar(vec4 x=near y=far)
 *   u_depthCutoff(vec4 x=cutoff) - 视图空间深度差阈值
 *   u_sampleOffsets(vec4 数组 9) - 像素偏移（xy=offset，shader 内除以 size 转 uv）
 *   u_sampleWeights(vec4 数组 9) - 高斯权重（x=weight）
 */
let SAO_BLUR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

#define KERNEL_RADIUS 8
#define EPSILON 0.0001

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tDepth, 1);

uniform vec4 u_size;
uniform vec4 u_cameraNearFar;
uniform vec4 u_depthCutoff;
uniform vec4 u_sampleOffsets[9];
uniform vec4 u_sampleWeights[9];

float getDepth(in vec2 uv) {
    return texture2D(tDepth, uv).x;
}

float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

void main()
{
    vec2 invSize = vec2(1.0 / u_size.x, 1.0 / u_size.y);
    float depth = getDepth(v_blitUV);
    if (depth >= 1.0 - EPSILON) {
        // bgfx4cj: 背景像素保留原始 AO 值（不修改），不 discard → 否则 ao=0 使 apply 后背景全黑
        gl_FragColor = texture2D(tDiffuse, v_blitUV);
        return;
    }

    float centerViewZ = -getViewZ(depth);
    bool rBreak = false;
    bool lBreak = false;

    float weightSum = u_sampleWeights[0].x;
    vec4 diffuseSum = texture2D(tDiffuse, v_blitUV) * weightSum;

    for (int i = 1; i <= KERNEL_RADIUS; i++) {
        float sampleWeight = u_sampleWeights[i].x;
        vec2 sampleUvOffset = u_sampleOffsets[i].xy * invSize;

        vec2 sampleUv = v_blitUV + sampleUvOffset;
        float viewZ = -getViewZ(getDepth(sampleUv));

        if (abs(viewZ - centerViewZ) > u_depthCutoff.x) {
            rBreak = true;
        }

        if (!rBreak) {
            diffuseSum += texture2D(tDiffuse, sampleUv) * sampleWeight;
            weightSum += sampleWeight;
        }

        sampleUv = v_blitUV - sampleUvOffset;
        viewZ = -getViewZ(getDepth(sampleUv));

        if (abs(viewZ - centerViewZ) > u_depthCutoff.x) {
            lBreak = true;
        }

        if (!lBreak) {
            diffuseSum += texture2D(tDiffuse, sampleUv) * sampleWeight;
            weightSum += sampleWeight;
        }
    }

    gl_FragColor = diffuseSum / weightSum;
}
"""

/**
 * SAO 遮蔽应用 FS（对应 SAOPass.render 输出阶段 Default 模式）。
 *
 * 合并 materialCopy + CustomBlending(DstColorFactor×ZeroFactor) 乘法两步。
 * uniforms:
 *   tDiffuse(sampler0) - 场景色（readBuffer）
 *   tAO(sampler1) - blur 后的遮蔽图（白色=无遮蔽）
 * 输出 sceneColor × ao（遮蔽变暗）。
 */
let SAO_APPLY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tAO, 1);

void main()
{
    vec3 sceneColor = texture2D(tDiffuse, v_blitUV).rgb;
    float ao = texture2D(tAO, v_blitUV).r;
    gl_FragColor = vec4(sceneColor * ao, 1.0);
}
"""

// ============================================================================
// SSR 系列（SSRShader + SSRPass）
// 迁移要点（bgfx 差异）：
//   - 左手系：viewZ 为正（near→0, far→far），深度比较符号与右手系相反
//   - bgfx UV 原点左上、v 向下；NDC y = 1 - 2*uv.y（uv.y=0 ↔ NDC y=+1 顶）
//   - NDC z ∈ [0,1]（near→0, far→1），perspectiveDepthToViewZ 分母 far-(far-near)*depth
//   - texture2D 替代 textureLod（RT 纹理无 mip）
//   - MAX_STEP 通过 compileBgfxWithDefines 传入（= sqrt(w²+h²)）
//   - SELECTIVE/DISTANCE_ATTENUATION/FRESNEL/INFINITE_THICK 通过 #define 控制
// ============================================================================

/**
 * SSR 主计算 FS（SSRShader）。
 *
 * 算法：逐像素从深度/法线重建视图空间位置 → 计算反射方向 → 屏幕空间射线步进 →
 *      命中后采样场景颜色，输出反射色(rgb)+不透明度(a)。
 *
 * bgfx 适配关键：
 *   - viewZ 正值（左手系），深度比较用 >=（右手系用 <=，符号相反）
 *   - 近平面裁剪：d1viewPosition.z < cameraNear（右手系: > -cameraNear）
 *   - 远平面跳过：viewZ >= cameraFar（右手系: -viewZ >= cameraFar）
 *   - UV↔NDC 转换：ndc.y = 1 - 2*uv.y
 *   - texture2DLod 替代 texture2D：RT 无 mip，lod=0 等价 SampleLevel；非 gradient 指令，
 *     避免 HLSL 在循环内因 gradient 而强制 unroll（MAX_STEP 可达 1435+，unroll 失败）
 *   - 参数名避开 HLSL 保留字 point（改用 pnt）
 *
 * uniforms:
 *   tDiffuse(sampler0) - 场景颜色（readBuffer，用于采样反射色）
 *   tNormal(sampler1) - 视图空间法线（0.5+0.5 编码，RGBA16F）
 *   tDepth(sampler2) - NDC 深度（RGBA32F，x 通道，aodepth pass 写 gl_FragCoord.z）
 *   u_resolution(vec4 xy) - RT 尺寸
 *   u_cameraNearFar(vec4 x=near y=far)
 *   u_projMatrix(mat4), u_invProjMatrix(mat4)
 *   u_ssrParams(vec4: x=opacity, y=maxDistance, z=thickness, w=cameraRange)
 *
 * 编译期 define：
 *   MAX_STEP - 最大射线步数（= sqrt(width² + height²)）
 *   DISTANCE_ATTENUATION - 距离衰减
 *   FRESNEL - 菲涅耳效应
 *   INFINITE_THICK - 无限厚度（跳过厚度检测）
 */
let SSR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tNormal, 1);
SAMPLER2D(tDepth, 2);
#ifdef SELECTIVE
SAMPLER2D(tMetalness, 3);
#endif

uniform vec4 u_resolution;
uniform vec4 u_cameraNearFar;
uniform mat4 u_projMatrix;
uniform mat4 u_invProjMatrix;
uniform vec4 u_ssrParams;  // x=opacity, y=maxDistance, z=thickness, w=cameraRange
// 诊断可视化开关：u_debug.x > 0.5 时启用（用 uniform 控制，无需重编译）
//   0=正常；1=按拒绝原因着色：
//     命中=反射原色；背景跳过=蓝；厚度未命中=红；背面剔除=绿；距离剔除=黄；循环结束未命中=紫
uniform vec4 u_debug;
// 移除 u_ssrStep uniform（用户决策：纯编译期 MAX_STEP define 方案）
// MAX_STEP = min(sqrt(w²+h²), 1024) 作为编译期 define 动态传入：
//   - 中低分辨率（rawMaxStep≤1024）传实际值 → stepSize=totalStep/MAX_STEP ≤1 → 细密1像素步采样
//   - 超高分辨率（rawMaxStep>1024）截 1024 → stepSize=totalStep/1024 放缩 → 1024 步覆盖全射线不截断
// 配合 `if (i >= MAX_STEP+1) break;` 静态整型比较，D3DCompiler 可静态识别循环上界 CFG 可控

// bgfx 左手系 perspectiveDepthToViewZ：viewZ 为正，depth ∈ [0,1]（near→0, far→1）
// 相机在原点(0,0,0)，看向+Z方向，viewZ ∈ [near, far]（正数）
// 对齐 perspectiveDepthToViewZ 语义：无 clamp，直接用 depth 计算
float getViewZ(in float depth) {
    float denom = u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth;
    return (u_cameraNearFar.x * u_cameraNearFar.y) / max(denom, 1e-5);
}

float getDepth(in vec2 uv) {
    // 用 texture2DLod 而非 texture2D：RT 无 mip，lod=0 等价 SampleLevel，
    // 非 gradient 指令，避免 HLSL 在循环内强制 unroll（MAX_STEP 可达 1435+）。
    return texture2DLod(tDepth, uv, 0.0).x;
}

vec3 getViewPosition(in vec2 uv, in float depth) {
    // bgfx uv 原点左上、v 向下；NDC y = 1 - 2*uv.y（uv.y=0 ↔ NDC y=+1 顶）
    // bgfx 左手系 NDC z ∈ [0,1]（near→0, far→1），直接使用 depth 作为 NDC z
    vec4 ndc = vec4(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, depth, 1.0);
    vec4 viewPos = mul(u_invProjMatrix, ndc);
    // 防御：透视除法 w≈0 时避免 Inf/NaN
    float wDiv = max(abs(viewPos.w), 1e-5);
    return viewPos.xyz / (sign(viewPos.w) * wDiv);
}

vec3 getViewNormal(in vec2 uv) {
    // 防御：法线解码后归一化；采样到 clear 色（0.5,0.5,1.0）不会产生零向量
    vec3 n = texture2DLod(tNormal, uv, 0.0).xyz * 2.0 - 1.0;
    float nl = length(n);
    return nl < 1e-5 ? vec3(0.0, 0.0, 1.0) : (n / nl);
}

// 视图空间位置 → 屏幕像素坐标
vec2 viewPositionToPixel(in vec3 viewPosition) {
    vec4 clip = mul(u_projMatrix, vec4(viewPosition, 1.0));
    // 防御：clip.w 接近 0 时避免 Inf/NaN
    float wDiv = max(abs(clip.w), 1e-5);
    vec2 ndc = clip.xy / (sign(clip.w) * wDiv);
    // bgfx: uv.x = (ndc.x+1)/2, uv.y = (1-ndc.y)/2
    vec2 uv = vec2(ndc.x * 0.5 + 0.5, 0.5 - ndc.y * 0.5);
    return uv * u_resolution.xy;
}

// 点到直线距离（3D）
float pointToLineDistance(vec3 x0, vec3 x1, vec3 x2) {
    // 防御：x1/x2 几乎重合时避免除 0；分子 cross 此时也接近 0，商趋近于 0 即可
    float denom = max(length(x2 - x1), 1e-5);
    return length(cross(x0 - x1, x0 - x2)) / denom;
}

// 点到平面距离（注：参数名避开 HLSL 保留字 point，改用 pnt）
float pointPlaneDistance(vec3 pnt, vec3 planePoint, vec3 planeNormal) {
    float a = planeNormal.x, b = planeNormal.y, c = planeNormal.z;
    float x0 = pnt.x, y0 = pnt.y, z0 = pnt.z;
    float x = planePoint.x, y = planePoint.y, z = planePoint.z;
    float d = -(a * x + b * y + c * z);
    return a * x0 + b * y0 + c * z0 + d;
}

void main() {
    float depth = getDepth(v_blitUV);
    float viewZ = getViewZ(depth);
    // 对齐原实现：if(-viewZ>=cameraFar) return;（左手系等价 viewZ>=cameraFar）
    // 背景 depth=1.0 → viewZ=far → 此条件覆盖，无需额外 depth>=0.999 检查
    if (viewZ >= u_cameraNearFar.y) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // SELECTIVE 模式：采样 metalness RT，metalness==0 的非金属表面直接跳过 SSR
    // 原 SSRShader 逻辑：
    //   #ifdef SELECTIVE
    //       float metalness=texture2D(tMetalness,vUv).r;
    //       if(metalness==0.) return;
    //   #endif
    // 这跳过球/立方体/甜甜圈等非金属表面的掠射自相交伪影（命中自身邻域像素、采样自身明暗色叠到地板）
    // 仅金属表面（selects 列表中的 mesh）执行 SSR 射线步进
    #ifdef SELECTIVE
        float metalness = texture2DLod(tMetalness, v_blitUV, 0.0).r;
        // 对齐原实现：if(metalness==0.) return;
        //   metalness RT 为 RGBA16F，写入值精确 0.0（off）/1.0（on），==0. 判定安全
        if (metalness == 0.0) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
            return;
        }
    #endif

    vec3 viewPosition = getViewPosition(v_blitUV, depth);
    vec3 viewNormal = getViewNormal(v_blitUV);

    // 反射方向（左手系：viewIncidentDir = normalize(viewPosition)，指向表面）
    vec3 viewIncidentDir = normalize(viewPosition);
    vec3 viewReflectDir = reflect(viewIncidentDir, viewNormal);

    // 反射方向与射线起点（严格对齐原版 SSRShader，无 ray origin bias）：
    //   原版用 viewPosition 作为射线起点，away/distance/Z 插值全部基于 viewPosition。
    //   此前加入的 rayBias（沿 viewDir 偏移起点）会平移整条射线，使 pointToLineDistance
    //   的 away 对真实命中点增大、超过厚度阈值 tk，导致真实反射被错误判为厚度拒绝（诊断红色），
    //   反射与伪影连成拉伸状。平面反射由 GroundReflector 处理，非靠 bias。
    //   故此处回退为与 viewPosition 一致的基线。

    // 最大反射射线长度（dot(-incident, normal) = cos(theta) > 0 对正面）
    float maxReflectRayLen = u_ssrParams.y / max(dot(-viewIncidentDir, viewNormal), 0.0001);
    vec3 d1viewPosition = viewPosition + viewReflectDir * maxReflectRayLen;

    // 近平面裁剪：左手系 d1viewPosition.z < cameraNear 时射线穿过近平面
    // 防御性加 epsilon：viewReflectDir.z 接近 0 时避免除以 0 产生 Inf/NaN
    if (d1viewPosition.z < u_cameraNearFar.x) {
        float vz = max(abs(viewReflectDir.z), 1e-5);
        float t = (u_cameraNearFar.x - viewPosition.z) / (sign(viewReflectDir.z) * vz);
        d1viewPosition = viewPosition + viewReflectDir * t;
    }

    // 起点/终点像素坐标
    vec2 d0 = v_blitUV * u_resolution.xy;
    vec2 d1 = viewPositionToPixel(d1viewPosition);

    float xLen = d1.x - d0.x;
    float yLen = d1.y - d0.y;
    float totalStep = max(abs(xLen), abs(yLen));

    // 防御：反射射线过短（totalStep<1 像素）时直接跳过，避免后续 0/0=NaN
    if (totalStep < 0.5) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // 循环结构对齐原版 SSRShader：
    //   原版：for(float i=1.; i<float(MAX_STEP); i++) { if(i>=totalStep) break; ... }
    //     —— 每步 1 像素（xSpan=xLen/totalStep, sStep=1/totalStep），
    //     totalStep > MAX_STEP 时射线在 MAX_STEP 步处截断（只采样前 MAX_STEP 像素）。
    //   此前 stepSize=max(1,totalStep/MAX_STEP) 放缩：totalStep>MAX_STEP 时
    //     MAX_STEP 步覆盖全射线（稀疏采样、不截断）——与截断行为不同，
    //     长射线（如墙面掠射）会采样到远处像素，产生额外命中/漏命中。
    //   对齐后：stepSize 恒 1（每步 1 像素），静态上界 `if (i >= MAX_STEP) break`
    //     截断射线（对齐原版 i<MAX_STEP）。
    //   D3D 崩溃规避：保持开放式 [loop] for（不写成 for(i=1;i<MAX_STEP;i++) 防止
    //     HLSL 编译器静态 unroll 1024 次）——[loop] 属性 + 动态 break + 静态整型
    //     上界比较，D3DCompiler 可识别上界但强制不展开，CFG/寄存器规模可控。
    float invTotal = 1.0 / max(totalStep, 1.0);
    float xSpan = xLen * invTotal;
    float ySpan = yLen * invTotal;
    float sStep = invTotal;
    // 起点 s=sStep，循环从 i=1 开始（严格对齐原版：s=sStep, for(i=1;...)）
    float s = sStep;

    // 诊断：记录首次拒绝原因（u_debug.x>0.5 时输出诊断色）
    //   0=未拒绝/命中, 1=背景, 2=厚度未命中(穿透), 3=背面剔除, 4=距离剔除, 5=循环结束未命中
    float dbgReason = 0.0;

    [loop]
    for (int i = 1; ; i++) {
        // 退出条件 1：距离覆盖完整射线（动态比较，对齐原版 if(i>=totalStep) break）
        if (float(i) >= totalStep) break;
        // 退出条件 2（静态上界截断，对齐原版 for 上界 i<float(MAX_STEP)）：
        //   编译期常量整型比较 MAX_STEP，D3DCompiler 静态识别循环上界，
        //   totalStep>MAX_STEP 时长射线在此截断（只采样前 MAX_STEP 像素，与原版一致）。
        if (i >= MAX_STEP) break;
        // GPU hang 绝对兜底（i > 65536，不参与 D3DCompiler 静态分析）
        if (i > 65536) break;
        vec2 xy = vec2(d0.x + float(i) * xSpan, d0.y + float(i) * ySpan);
        if (xy.x < 0.0 || xy.x > u_resolution.x || xy.y < 0.0 || xy.y > u_resolution.y) break;
        vec2 uv = xy / u_resolution.xy;

        float d = getDepth(uv);
        // 对齐原版：不检查 d>=0.999，只用 vZ>=cameraFar 跳过（等价原版 -vZ>=cameraFar）
        // 关键：continue 跳过循环体末尾的 s+=sStep（与原版行为一致）。
        //   原版 for 循环中 continue 会跳过 s+=sStep，使 s 与 i 不同步——
        //   背景像素后 s 滞后于 i，viewReflectRayZ 用更早的 s 值计算（射线 Z 偏小），
        //   深度比较更保守（不容易触发命中），减少幽灵命中点。
        //   之前误加 s += sStep 会让 s 始终同步 i，可能产生原版不会出现的额外命中，
        //   导致暗色/亮色伪影。
        float vZ = getViewZ(d);
        if (vZ >= u_cameraNearFar.y) { dbgReason = 1.0; continue; }
        vec3 vP = getViewPosition(uv, d);

        // 透视正确插值射线 Z（左手系：z 为正）
        // 起点用 viewPosition（对齐原版：1./viewPosition.z）
        float recipVPZ = 1.0 / max(viewPosition.z, 1e-5);
        float recipD1Z = 1.0 / max(d1viewPosition.z, 1e-5);
        float denom = recipVPZ + s * (recipD1Z - recipVPZ);
        // denom 兜底（对齐原版 ±inf 语义——墙面斑马纹修复）：
        //   原版：viewReflectRayZ = 1./(recipVPZ+s*(1./d1viewPosition.z-recipVPZ))，无兜底。
        //   denom 穿越 0 时 GLSL 除零给 ±inf：
        //     denom→0-（1/denom→-∞，射线 Z 极近）→ 右手系 `<= vZ` 不命中
        //     denom→0+（1/denom→+∞，射线 Z 极远）→ 右手系 `<= vZ` 命中
        //   手性翻转后（左手系 viewZ 正、越大越远）：
        //     denom≥0 → viewReflectRayZ=+1e9（极远）→ `>= vZ` 命中
        //     denom<0  → viewReflectRayZ=-1e9（后方）→ `>= vZ` 不命中
        //   此前用 d1viewPosition.z（有限值）兜底：d1.z 与 ±inf 语义完全不同，
        //   在 denom≈0 的像素带（墙面掠射时射线 Z 插值穿越 0）命中/未命中翻转，
        //   叠加浮点噪声 → 相邻像素规律性交替 → 条纹/斑马纹。
        float viewReflectRayZ = (abs(denom) < 1e-6)
            ? ((denom >= 0.0) ? 1.0e9 : -1.0e9)
            : (1.0 / denom);

        // 左手系深度检测：viewZ 为正，越大越远
        // 射线从表面出发，rayZ 增大表示向远处步进
        // 当 rayZ >= vZ 时，射线到达或穿过了表面
        bool rayHit = viewReflectRayZ >= vZ;

        if (rayHit) {
            bool hit;
            #ifdef INFINITE_THICK
                hit = true;
            #else
                float away = pointToLineDistance(vP, viewPosition, d1viewPosition);
                // 计算最小厚度（邻域像素的视图空间间距 × 3）
                vec2 xyNeighbor = xy;
                xyNeighbor.x += 1.0;
                vec2 uvNeighbor = xyNeighbor / u_resolution.xy;
                vec3 vPNeighbor = getViewPosition(uvNeighbor, d);
                // minThickness：邻域像素的视图空间 x 间距 × 3（严格对齐原版 SSRShader 行 215-216）
                //   原版：minThickness=vPNeighbor.x-vP.x; minThickness*=3;（不取 abs）
                //   若邻域在左（vPNeighbor.x<vP.x）则 minThickness 为负，tk=max(负,thickness)=thickness
                //   退化为常数，厚度判定更保守（少命中）。实测 abs 化对掠射面红色条纹无改善且偏离原版，
                //   故保持与原版逐字符一致。
                float minThickness = (vPNeighbor.x - vP.x) * 3.0;
                float tk = max(minThickness, u_ssrParams.z);
                hit = away <= tk;
                if (!hit) { dbgReason = 2.0; }
            #endif

            if (hit) {
                vec3 vN = getViewNormal(uv);
                // 对齐原版：treat backfaces as opaque（break 而非 continue）
                if (dot(viewReflectDir, vN) >= 0.0) { dbgReason = 3.0; break; }

                float distance = pointPlaneDistance(vP, viewPosition, viewNormal);
                if (distance > u_ssrParams.y) { dbgReason = 4.0; break; }

                float op = u_ssrParams.x;
                #ifdef DISTANCE_ATTENUATION
                    float invMaxDist = 1.0 / max(u_ssrParams.y, 1e-4);
                    float ratio = 1.0 - (distance * invMaxDist);
                    // 防御：ratio 裁剪到 [0,1] 避免负值产生负 op 或 >1 溢出
                    ratio = clamp(ratio, 0.0, 1.0);
                    float attenuation = ratio * ratio;
                    op = u_ssrParams.x * attenuation;
                #endif
                #ifdef FRESNEL
                    // 对齐原版 SSRShader 的 FRESNEL 实现（严格 1:1 迁移）：
                    //   float fresnelCoe=(dot(viewIncidentDir,viewReflectDir)+1.)/2.;
                    //   op*=fresnelCoe;
                    //
                    // 说明：
                    //   - viewIncidentDir = normalize(viewPosition)（与原版一致）
                    //   - viewReflectDir = reflect(viewIncidentDir, viewNormal)（与原版一致）
                    //   - dot(viewIncidentDir, viewReflectDir) + 1 范围 [0, 2]，/2 后 ∈ [0, 1]
                    //   - 当入射方向与反射方向同向（掠射角）时 fresnelCoe→1（强反射）
                    //   - 当入射方向与反射方向反向（垂直入射）时 fresnelCoe→0（弱反射）
                    //
                    // 历史教训：上一轮曾误以为原版用 pow(1 - dot(N, V), 4) 的 Schlick 菲涅耳，
                    // 并据此"修复"为该公式。但实际查阅原版 SSRShader 第 256-258 行，
                    // 原版就是 (dot(incident, reflect) + 1) / 2，并非 Schlick 形式。
                    // 误改后会削弱掠射角的反射强度，导致整体反射偏暗、地板反射消失等回归问题。
                    // 现回滚为与原版严格一致的实现。
                    float fresnelCoe = (dot(viewIncidentDir, viewReflectDir) + 1.0) * 0.5;
                    // 防御：fresnelCoe 裁剪到 [0,1]（理论上已在范围内，防御浮点误差）
                    fresnelCoe = clamp(fresnelCoe, 0.0, 1.0);
                    op = op * fresnelCoe;
                #endif
                vec4 reflectColor = texture2DLod(tDiffuse, uv, 0.0);
                // 防御：若 reflectColor 是 NaN/Inf（例如 RT 受驱动 bug 污染），替换为 0
                //   isNaN等价：!(x >= 0.0 && x <= 1.0)（颜色纹理采样理论范围[0,1]）
                if (!(reflectColor.r >= -1.0 && reflectColor.r <= 2.0)) { reflectColor.r = 0.0; }
                if (!(reflectColor.g >= -1.0 && reflectColor.g <= 2.0)) { reflectColor.g = 0.0; }
                if (!(reflectColor.b >= -1.0 && reflectColor.b <= 2.0)) { reflectColor.b = 0.0; }
                if (!(reflectColor.a >= -1.0 && reflectColor.a <= 2.0)) { reflectColor.a = 0.0; }
                // 防御：最终 op 裁剪到 [0, max(opacity, 1e-4)]，避免 NaN/负值/超界
                // 即使上游计算有微小浮点误差，也不会写出异常 alpha
                op = clamp(op, 0.0, max(u_ssrParams.x, 1e-4));
                gl_FragColor = vec4(reflectColor.xyz, op);
                // 诊断：命中（dbgReason=0）直接返回反射色
                return;
            }
        }
        s += sStep;
    }
    // 循环结束未命中
    if (dbgReason == 0.0) { dbgReason = 5.0; }
    // 诊断输出（u_debug.x>0.5 时按拒绝原因着色）
    if (u_debug.x > 0.5) {
        vec3 dbg = vec3(0.0, 0.0, 0.0);
        if (dbgReason == 1.0) dbg = vec3(0.0, 0.0, 1.0);   // 背景=蓝
        else if (dbgReason == 2.0) dbg = vec3(1.0, 0.0, 0.0); // 厚度穿透=红
        else if (dbgReason == 3.0) dbg = vec3(0.0, 1.0, 0.0); // 背面剔除=绿
        else if (dbgReason == 4.0) dbg = vec3(1.0, 1.0, 0.0); // 距离剔除=黄
        else if (dbgReason == 5.0) dbg = vec3(1.0, 0.0, 1.0); // 未命中=紫
        gl_FragColor = vec4(dbg, 1.0);
        return;
    }
    // 未命中：输出透明黑
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
"""

/**
 * SSR 模糊 FS（SSRBlurShader）。
 * 5 抽头 alpha 加权模糊（中心 0.2 + 四邻域各 0.2）。
 * uniforms: tDiffuse(sampler0, ssr RT), u_resolution(vec4 xy)
 */
let SSR_BLUR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_resolution;

void main() {
    vec2 texelSize = vec2(1.0 / u_resolution.x, 1.0 / u_resolution.y);
    vec4 c = texture2D(tDiffuse, v_blitUV);
    vec2 offset;

    offset = vec2(-1.0, 0.0) * texelSize;
    vec4 cl = texture2D(tDiffuse, v_blitUV + offset);
    offset = vec2(1.0, 0.0) * texelSize;
    vec4 cr = texture2D(tDiffuse, v_blitUV + offset);
    offset = vec2(0.0, -1.0) * texelSize;
    vec4 cb = texture2D(tDiffuse, v_blitUV + offset);
    offset = vec2(0.0, 1.0) * texelSize;
    vec4 ct = texture2D(tDiffuse, v_blitUV + offset);

    float coeCenter = 0.2;
    float coeSide = 0.2;
    float a = c.a * coeCenter + cl.a * coeSide + cr.a * coeSide + cb.a * coeSide + ct.a * coeSide;
    // 对齐原版 SSRBlurShader：直接除以 a（不加 if 防护）。
    // 原版：vec3 rgb = (...)/a; gl_FragColor = vec4(rgb, a);
    // 当 a=0 时原版产生 NaN，但后续 SSR_APPLY 的 mix(color, NaN, 0) = color 不受影响。
    // 本实现用 max(a, 1e-6) 防止除以 0 产生 NaN，行为更安全且与原版一致：
    //   a 很小但不为 0 时，加权和与 a 同比例缩小，rgb 是正常颜色（非 0）。
    //   之前用 if(a>0.0001) 会将小 alpha 像素颜色置 0，模糊后扩散产生暗色伪影。
    vec3 rgb = (c.rgb * c.a * coeCenter + cl.rgb * cl.a * coeSide + cr.rgb * cr.a * coeSide + cb.rgb * cb.a * coeSide + ct.rgb * ct.a * coeSide) / max(a, 1e-6);
    gl_FragColor = vec4(rgb, a);
}
"""

/**
 * SSR 深度可视化 FS（SSRDepthShader）。
 * 输出 1.0 - 线性深度（far→黑, near→白），用于 Depth 调试视图。
 * uniforms: tDepth(sampler0), u_cameraNearFar(vec4 x=near y=far)
 */
let SSR_DEPTH_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDepth, 0);
uniform vec4 u_cameraNearFar;

float getViewZ(in float depth) {
    return (u_cameraNearFar.x * u_cameraNearFar.y) / (u_cameraNearFar.y - (u_cameraNearFar.y - u_cameraNearFar.x) * depth);
}

void main() {
    float fragCoordZ = texture2D(tDepth, v_blitUV).x;
    float viewZ = getViewZ(fragCoordZ);
    float linDepth = (viewZ - u_cameraNearFar.x) / (u_cameraNearFar.y - u_cameraNearFar.x);
    float d = 1.0 - linDepth;
    gl_FragColor = vec4(d, d, d, 1.0);
}
"""

/**
 * SSR 应用 FS（合并 CopyShader × 2 步：先 NoBlending copy beauty，再 NormalBlending 叠 SSR）。
 * 输出 sceneColor × (1 - ssrAlpha) + ssrColor × ssrAlpha（等价 NormalBlending 混合）。
 * uniforms: tDiffuse(sampler0, beauty=readBuffer), tSSR(sampler1, blur 后的 SSR 结果)
 */
let SSR_APPLY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tSSR, 1);

// NaN/Inf 防御工具：颜色 RT 采样值正常范围 [0,1]，HDR 下可能略超但有限
// 任何 NaN/Inf 都会导致 !(v >= -1 && v <= 2) 成立，清为 0 避免污染最终 RT
float ssrClampC(float v) {
    return (v >= -1.0 && v <= 2.0) ? v : 0.0;
}

void main() {
    vec3 sceneColor = texture2D(tDiffuse, v_blitUV).rgb;
    vec4 ssr = texture2D(tSSR, v_blitUV);
    // 对采样值做 NaN/Inf 防御（防止上游 pass 因驱动 bug 产生异常值破坏最终帧）
    sceneColor.r = ssrClampC(sceneColor.r);
    sceneColor.g = ssrClampC(sceneColor.g);
    sceneColor.b = ssrClampC(sceneColor.b);
    ssr.r = ssrClampC(ssr.r);
    ssr.g = ssrClampC(ssr.g);
    ssr.b = ssrClampC(ssr.b);
    ssr.a = ssrClampC(ssr.a);
    // 裁剪混合权重到 [0,1]（正常 SSR alpha 本来就在这个范围）
    ssr.a = clamp(ssr.a, 0.0, 1.0);
    // NormalBlending: out = src*srcAlpha + dst*(1-srcAlpha)
    vec3 finalColor = mix(sceneColor, ssr.rgb, ssr.a);
    // 最终防御：混合后也裁剪颜色范围，防止浮点越界/负值
    finalColor.r = clamp(finalColor.r, 0.0, 1.0);
    finalColor.g = clamp(finalColor.g, 0.0, 1.0);
    finalColor.b = clamp(finalColor.b, 0.0, 1.0);
    gl_FragColor = vec4(finalColor, 1.0);
}
"""

/**
 * SSR 金属度 pass varying def（与 AO_DEPTH_VARYING_DEF 范式一致：仅 a_position + dummy v_ndcDummy）。
 * CPU 侧按 mesh 是否在 selects 列表中设 u_metalness uniform（1.0=on/0.0=off）。
 * 对应 SSRPass._renderMetalness：selects 中的 mesh 渲为白（metalness=1），其他渲为黑。
 *   原版用纯色材质（白/黑）+ per-mesh 材质替换；
 *   本实现走与 normal/depth pass 一致的"自建几何 + shader override"范式，
 *   用 uniform u_metalness 区分 on/off，避开材质替换的渲染线程并发改写风险。
 */
let SSR_METALNESS_VARYING_DEF = """
vec3 a_position : POSITION;
vec2 v_ndcDummy : TEXCOORD0 = vec2(0.0, 0.0);
"""

/** metalness pass VS：场景几何 → metalness RT（仅 a_position，与 AO_DEPTH_VS 范式一致） */
let SSR_METALNESS_VS = """
$input a_position
$output v_ndcDummy

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    // dummy 占位：避免 FS 无输入 varying 触发 D3DCompiler 警
    v_ndcDummy = gl_Position.xy * 0.5 + 0.5;
}
"""

/**
 * metalness pass FS：写 u_metalness 到 RGBA16F（r=m, g=m, b=m, a=1）。
 * RT clear 为黑色（0,0,0,1）= metalness=0（非金属背景），
 * selects 中的 mesh 覆写为白色（1,1,1,1）= metalness=1。
 */
let SSR_METALNESS_FS = """
$input v_ndcDummy

#include <bgfx_shader.sh>

uniform vec4 u_metalness;  // x = metalness 值（1.0=on / 0.0=off）

void main()
{
    // dummy 读取避免未使用警告
    float _dummy = v_ndcDummy.x + v_ndcDummy.y;
    float m = u_metalness.x;
    gl_FragColor = vec4(m, m, m, 1.0);
}
"""

// ============================================================================
// OutlinePass shaders
// 对齐 OutlinePass 的四类材质（prepareMask/edgeDetection/separableBlur/overlay）组织方式
// ============================================================================

/**
 * outline_copy shader（降采样 copy，对应 OutlinePass materialCopy）。
 * uniforms: tDiffuse(s0), u_opacity(vec4: x=opacity)
 */
let OUTLINE_COPY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
uniform vec4 u_opacity;

void main()
{
    vec4 texel = texture2D(tDiffuse, v_blitUV);
    gl_FragColor = texel * u_opacity.x;
}
"""

/**
 * outline_edge_detection shader（Sobel 边缘检测）。
 * 对应 OutlinePass 的 edgeDetectionMaterial
 * uniforms: maskTexture(s0), texSize(vec4: xy=width,height),
 *           visibleEdgeColor(vec4), hiddenEdgeColor(vec4)
 */
let OUTLINE_EDGE_DETECTION_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(maskTexture, 0);
uniform vec4 texSize;
uniform vec4 visibleEdgeColor;
uniform vec4 hiddenEdgeColor;

void main()
{
    vec2 invSize = 1.0 / texSize.xy;
    vec4 uvOffset = vec4(1.0, 0.0, 0.0, 1.0) * vec4(invSize, invSize);
    vec4 c1 = texture2D(maskTexture, v_blitUV + uvOffset.xy);
    vec4 c2 = texture2D(maskTexture, v_blitUV - uvOffset.xy);
    vec4 c3 = texture2D(maskTexture, v_blitUV + uvOffset.yw);
    vec4 c4 = texture2D(maskTexture, v_blitUV - uvOffset.yw);
    float diff1 = (c1.r - c2.r) * 0.5;
    float diff2 = (c3.r - c4.r) * 0.5;
    float d = length(vec2(diff1, diff2));
    float a1 = min(c1.g, c2.g);
    float a2 = min(c3.g, c4.g);
    float visibilityFactor = min(a1, a2);
    vec3 edgeColor = (1.0 - visibilityFactor > 0.001) ? visibleEdgeColor.xyz : hiddenEdgeColor.xyz;
    // 注意：GLSL 允许 vec4(d) 标量广播，但 bgfx shaderc 转 HLSL 时 float4(float) 非法（X3014），
    // 必须显式 4 分量。
    gl_FragColor = vec4(edgeColor, 1.0) * vec4(d, d, d, 1.0);
}
"""

/**
 * outline_separable_blur shader（可分离高斯模糊）。
 * 对照: OutlinePass _getSeparableBlurMaterial
 * uniforms: colorTexture(s0), texSize(vec4: xy=width,height),
 *           direction(vec4: xy), kernelRadius(vec4: x)
 */
let OUTLINE_SEPARABLE_BLUR_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(colorTexture, 0);
uniform vec4 texSize;
uniform vec4 direction;
uniform vec4 kernelRadius;

float gaussianPdf(in float x, in float sigma) {
    return 0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}

void main()
{
    vec2 invSize = 1.0 / texSize.xy;
    float sigma = kernelRadius.x * 0.5;
    float weightSum = gaussianPdf(0.0, sigma);
    vec4 diffuseSum = texture2D(colorTexture, v_blitUV) * weightSum;
    vec2 delta = direction.xy * invSize * kernelRadius.x;
    vec2 uvOffset = delta;
    for (int i = 1; i <= 4; i++) {
        float x = kernelRadius.x * float(i) * 0.25;
        float w = gaussianPdf(x, sigma);
        vec4 sample1 = texture2D(colorTexture, v_blitUV + uvOffset);
        vec4 sample2 = texture2D(colorTexture, v_blitUV - uvOffset);
        diffuseSum += (sample1 + sample2) * w;
        weightSum += 2.0 * w;
        uvOffset += delta;
    }
    gl_FragColor = diffuseSum / weightSum;
}
"""

/**
 * outline_overlay shader（edge1/edge2/mask 叠加到场景）。
 * 对应 OutlinePass 的 overlayMaterial
 * uniforms: tDiffuse(s0=readBuffer 场景), maskTexture(s1), edgeTexture1(s2),
 *           edgeTexture2(s3), patternTexture(s4),
 *           u_overlayParams(vec4: x=edgeStrength, y=edgeGlow, z=usePattern)
 *
 * 原版 overlayMaterial 用 AdditiveBlending 叠加到 readBuffer 已有场景。
 * bgfx 差异：bgfx 每 view 先 clear（不能保留 readBuffer 内容），
 * 故改在 shader 内显式采样 readBuffer 场景（tDiffuse）+ 描边色合成，
 * 输出 sceneColor + finalColor（等价 additive 叠加结果）。
 */
let OUTLINE_OVERLAY_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(maskTexture, 1);
SAMPLER2D(edgeTexture1, 2);
SAMPLER2D(edgeTexture2, 3);
SAMPLER2D(patternTexture, 4);
uniform vec4 u_overlayParams;  // x=edgeStrength, y=edgeGlow, z=usePattern

void main()
{
    vec3 sceneColor = texture2D(tDiffuse, v_blitUV).rgb;
    vec4 edgeValue1 = texture2D(edgeTexture1, v_blitUV);
    vec4 edgeValue2 = texture2D(edgeTexture2, v_blitUV);
    vec4 maskColor = texture2D(maskTexture, v_blitUV);
    vec4 patternColor = texture2D(patternTexture, 6.0 * v_blitUV);
    float visibilityFactor = (1.0 - maskColor.g > 0.0) ? 1.0 : 0.5;
    vec4 edgeValue = edgeValue1 + edgeValue2 * u_overlayParams.y;
    vec4 finalColor = u_overlayParams.x * maskColor.r * edgeValue;
    if (u_overlayParams.z > 0.5) {
        finalColor += visibilityFactor * (1.0 - maskColor.r) * (1.0 - patternColor.r);
    }
    // 等价 AdditiveBlending：场景 + 描边
    gl_FragColor = vec4(sceneColor + finalColor.rgb, 1.0);
}
"""

/**
 * outline_depth shader（深度图渲染，对照 MeshDepthMaterial RGBADepthPacking）。
 * uniforms: u_cameraNearFar(vec4: x=near, y=far)
 * 简化：仅输出线性深度到 R 通道（OutlinePass prepareMask 用此比较）。
 */
let OUTLINE_DEPTH_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

uniform vec4 u_cameraNearFar;  // x=near, y=far

void main()
{
    // outline depth pass 由 renderer.render 走 scene.overrideMaterial，
    // 这里仅占位（实际 depth 由 beautyRT depth attachment 提供）。
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
"""

/**
 * outline_prepare_mask shader（选中物体 mask + depth test）。
 * 对照: OutlinePass _getPrepareMaskMaterial
 * uniforms: depthTexture(s0), cameraNearFar(vec4: xy), textureMatrix(mat4)
 * 输出: r=mask, g=depthTest, b=1, a=1
 */
let OUTLINE_PREPARE_MASK_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(maskTexture, 0);
uniform vec4 u_cameraNearFar;

void main()
{
    vec4 maskColor = texture2D(maskTexture, v_blitUV);
    gl_FragColor = vec4(maskColor.r, 1.0, 1.0, 1.0);
}
"""

/**
 * outline_white 几何 shader：渲选中物体为纯白 mask（背景黑）。
 * 对应 OutlinePass prepareMaskMaterial 的简化版：
 *   - VS 用几何变换（u_model × u_viewProj，与 depthVS 相同）
 *   - FS 输出 r=1（mask），g=1（depthTest 简化恒 1），b=1, a=1
 * 背景由 view clear 为黑（r=g=0），Sobel 边缘检测在轮廓处 d>0，
 * visibilityFactor=min(邻域 g)=0（邻域含背景）→ 用 visibleEdgeColor（白色描边）。
 */
let OUTLINE_WHITE_VS = """
$input a_position

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
}
"""
let OUTLINE_WHITE_VARYING_DEF = """
vec3 a_position : POSITION;
"""
let OUTLINE_WHITE_FS = """
#include <bgfx_shader.sh>

void main()
{
    // r=mask(1), g=depthTest(简化恒 1), b=1, a=1
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
"""

/**
 * cube_tex 几何 VS：立方体 mesh 顶点变换（u_model[0] × u_viewProj），输出世界方向。
 * 对应 cube.glsl 的 cube VS：vWorldDirection = transformDirection(position, modelMatrix)；
 * gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0)；
 * 且 gl_Position.z = gl_Position.w（推到远平面，使 cube 深度=1.0，
 * 配合 FS 的 DEPTH_TEST_LEQUAL：背景(depth=1.0)通过、场景物体(depth<1.0)不通过 → 只填背景）。
 */
let CUBE_TEX_VS = """
$input a_position
$output v_worldDirection

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    v_worldDirection = worldPos.xyz;
    gl_Position = mul(u_viewProj, worldPos);
    // 推到远平面：cube 深度 = 1.0（背景），场景物体深度 < 1.0 在前
    gl_Position.z = gl_Position.w;
}
"""
let CUBE_TEX_VARYING_DEF = """
vec3 a_position : POSITION;
vec3 v_worldDirection : TEXCOORD0 = vec3(0.0, 0.0, 0.0);
"""

/**
 * cube_tex FS：采样立方体贴图 tCube 作为背景色（天空盒）。
 * 对应 cube.glsl fragment：
 *   gl_FragColor = textureCube(tCube, vec3(tFlip * vWorldDirection.x, vWorldDirection.yz));
 * uniforms: tCube(samplerCube, stage 0), u_tFlip(vec4: x=±1 翻转 X), u_opacity(vec4: x=opacity)
 */
let CUBE_TEX_FS = """
$input v_worldDirection

#include <bgfx_shader.sh>

SAMPLERCUBE(tCube, 0);
uniform vec4 u_tFlip;
uniform vec4 u_opacity;

void main()
{
    vec3 dir = vec3(u_tFlip.x * v_worldDirection.x, v_worldDirection.y, v_worldDirection.z);
    vec4 cubeColor = textureCube(tCube, dir);
    gl_FragColor = cubeColor * u_opacity.x;
}
"""

/**
 * bokeh_depth 几何 VS：渲场景到深度 RT（写 packDepthToRGBA(gl_FragCoord.z)）。
 * 对应 BokehPass 的 _materialDepth（MeshDepthMaterial + RGBADepthPacking）。
 * 与 AO_DEPTH_VS 同构（u_model[0] × u_viewProj），v_ndcDummy 占位避免 D3DCompiler 崩。
 */
let BOKEH_DEPTH_VS = """
$input a_position
$output v_ndcDummy

#include <bgfx_shader.sh>

void main()
{
    vec4 worldPos = mul(u_model[0], vec4(a_position, 1.0));
    gl_Position = mul(u_viewProj, worldPos);
    // dummy 占位：避免 FS 零输入 varying 触发 D3DCompiler 崩
    v_ndcDummy = gl_Position.xy * 0.5 + 0.5;
}
"""
let BOKEH_DEPTH_VARYING_DEF = """
vec3 a_position : POSITION;
vec2 v_ndcDummy : TEXCOORD0 = vec2(0.0, 0.0);
"""

/**
 * bokeh_depth FS：把 NDC 深度打包进 RGBA 四通道（RGBADepthPacking 编码）。
 * 对应 MeshDepthMaterial depth_fragment 的 DEPTH_PACKING==3201 → packDepthToRGBA(fragCoordZ)。
 * bgfx 左手系 NDC z ∈ [0,1]（near→0, far→1），与 fragCoordZ = 0.5*z/w+0.5 映射一致。
 * packDepthToRGBA 用 fract 版实现（对应 packing.glsl 的 modf 版，两者编码等价；
 * 避免 modf 的 out 参数在 shaderc 跨后端（GLSL→HLSL/SPIR-V）的兼容风险）。
 */
let BOKEH_DEPTH_FS = """
$input v_ndcDummy

#include <bgfx_shader.sh>

// packDepthToRGBA：32 位 float 深度 [0,1] → 4×8bit 通道（对应 packing.glsl 的 modf 版）
vec4 packDepthToRGBA(float v) {
    if (v <= 0.0) return vec4(0.0, 0.0, 0.0, 0.0);
    if (v >= 1.0) return vec4(1.0, 1.0, 1.0, 1.0);
    vec4 enc = vec4(1.0, 255.0, 65025.0, 16581375.0) * v;
    enc = fract(enc);
    enc -= enc.yzww * vec4(1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 0.0);
    return enc;
}

void main()
{
    float _dummy = v_ndcDummy.x + v_ndcDummy.y;  // 读一次避免未使用 varying 警告
    gl_FragColor = packDepthToRGBA(gl_FragCoord.z);
}
"""

/**
 * bokeh FS：BokehShader 完整非简化移植（41 抽头 lens blur，bokeh 效果）。
 * 对应 BokehShader。
 *
 * bgfx 差异：
 *   - uniforms 是 float；bgfx uniform 最小单位 vec4，故用 u_focus/u_aspect/u_aperture/
 *     u_maxblur/u_nearClip/u_farClip（vec4.x = 值）。
 *   - DEPTH_PACKING==1 分支（unpackRGBAToDepth）与 PERSPECTIVE_CAMERA==1 分支
 *     （perspectiveDepthToViewZ）在此内联为固定路径（BokehPass 固定用 RGBADepthPacking
 *     + 透视相机，defines 恒为真，不再 #define 开关）。
 *   - 左手系 viewZ 符号修正：右手系 viewZ<=0，factor = focus + viewZ（差值方程）；
 *     bgfx4cj 左手系 viewZ>=0（near→near, far→far），故 factor = focus - viewZ，
 *     效果等价（|viewZ| 与 focus 的差决定模糊量，符号相反）。
 *   - tColor(sampler0) / tDepth(sampler1) 两路纹理绑定。
 */
let BOKEH_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tColor, 0);
SAMPLER2D(tDepth, 1);

uniform vec4 u_focus;    // x=focus（焦点距离，世界单位）
uniform vec4 u_aspect;   // x=aspect（宽高比）
uniform vec4 u_aperture; // x=aperture（光圈）
uniform vec4 u_maxblur;  // x=maxblur（最大模糊量）
uniform vec4 u_nearClip; // x=nearClip
uniform vec4 u_farClip;  // x=farClip
uniform vec4 u_debugMode;// x=0 完整 bokeh / 1 深度图 / 2 原图直出（测试扩展）

// unpackRGBAToDepth：RGBADepthPacking 4×8bit → float [0,1]（对应 packing.glsl 编码）
float unpackRGBAToDepth(vec4 v) {
    return dot(v, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

// 深度采样：unpack 打包深度 → [0,1]
float getDepth(vec2 screenPosition) {
    return unpackRGBAToDepth(texture2D(tDepth, screenPosition));
}

// 深度反投影 → viewZ（bgfx 左手系 perspectiveDepthToViewZ：
//   viewZ = near*far / (far - (far-near)*depth)，near→near, far→far，viewZ 为正）
float getViewZ(float depth) {
    return (u_nearClip.x * u_farClip.x) / (u_farClip.x - (u_farClip.x - u_nearClip.x) * depth);
}

void main()
{
    vec2 aspectcorrect = vec2(1.0, u_aspect.x);

    float viewZ = getViewZ(getDepth(v_blitUV));

    // 对应原版：factor = (focus + viewZ)，viewZ<=0 → 差值方程；
    // bgfx 左手系 viewZ>=0，故用 focus - viewZ（等价差值）
    float factor = (u_focus.x - viewZ);

    // 注：不用 vec2(clamp(...)) 单参数 splat 构造 —— shaderc 转 HLSL 后
    // float2(标量) 被 D3DCompiler 判 X3014（numeric-type constructor 参数个数错误），
    // 改显式双参数构造（float2(v, v)）。
    float dofblurAmt = clamp(factor * u_aperture.x, -u_maxblur.x, u_maxblur.x);
    vec2 dofblur = vec2(dofblurAmt, dofblurAmt);
    vec2 dofblur9 = dofblur * 0.9;
    vec2 dofblur7 = dofblur * 0.7;
    vec2 dofblur4 = dofblur * 0.4;

    vec4 col = vec4(0.0, 0.0, 0.0, 0.0);

    // ---- 调试模式（测试扩展，u_debugMode.x: 0=完整 bokeh / 1=深度图 / 2=原图直出）----
    if (u_debugMode.x == 1.0) {
        // 深度图可视化：解包深度 → 伪彩（红=近, 蓝=远），便于验证深度 RT 正确性
        float depth = getDepth(v_blitUV);
        gl_FragColor = vec4(depth, depth * 0.5, 1.0 - depth, 1.0);
        return;
    }
    if (u_debugMode.x == 2.0) {
        // 原图直出：跳过 41 抽头模糊，验证 tColor 绑定正确
        gl_FragColor = vec4(texture2D(tColor, v_blitUV).rgb, 1.0);
        return;
    }

    // ---- 41 抽头（对照 BokehShader 逐行移植）----
    col += texture2D(tColor, v_blitUV.xy);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, 0.4) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.15, 0.37) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, 0.29) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.37, 0.15) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.40, 0.0) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.37, -0.15) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, -0.29) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.15, -0.37) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, -0.4) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.15, 0.37) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, 0.29) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.37, 0.15) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.4, 0.0) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.37, -0.15) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, -0.29) * aspectcorrect) * dofblur);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.15, -0.37) * aspectcorrect) * dofblur);

    col += texture2D(tColor, v_blitUV.xy + (vec2(0.15, 0.37) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.37, 0.15) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.37, -0.15) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.15, -0.37) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.15, 0.37) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.37, 0.15) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.37, -0.15) * aspectcorrect) * dofblur9);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.15, -0.37) * aspectcorrect) * dofblur9);

    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, 0.29) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.40, 0.0) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, -0.29) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, -0.4) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, 0.29) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.4, 0.0) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, -0.29) * aspectcorrect) * dofblur7);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, 0.4) * aspectcorrect) * dofblur7);

    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, 0.29) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.4, 0.0) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.29, -0.29) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, -0.4) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, 0.29) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.4, 0.0) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(-0.29, -0.29) * aspectcorrect) * dofblur4);
    col += texture2D(tColor, v_blitUV.xy + (vec2(0.0, 0.4) * aspectcorrect) * dofblur4);

    gl_FragColor = col / 41.0;
    gl_FragColor.a = 1.0;
}
"""

/**
 * lut FS：LUTPass 专用（LUTShader 完整非简化移植）。
 * 3D LUT 颜色分级：tDiffuse 采样 → uvw 定位 3D LUT → 按 intensity 混合。
 *
 * bgfx 差异：
 *   - `uniform sampler3D lut` + `texture(lut, uvw)`；bgfx 用 SAMPLER3D(lut, 1) 宏
 *     + texture3D(lut, uvw)（bgfx_shader.sh 已提供，stage 1 由 LUTPass 绑定 3D 纹理）。
 *   - uniforms 是 float（lutSize/intensity）；bgfx uniform 最小单位 vec4，
 *     故用 u_lutSize(vec4.x=lutSize) / u_intensity(vec4.x=intensity)。
 *   - `vec3 uvw = vec3( halfPixelWidth ) + val.rgb * ( 1.0 - pixelWidth );`
 *     的 vec3(标量) splat 构造在 shaderc 转 HLSL 后有 X3014 风险（同 vec2 单参数 splat），
 *     改显式 vec3(hw, hw, hw) 三参数构造。
 *   - `lutVal = vec4( texture( lut, uvw ).rgb, val.a );` 保持（vec4(vec3, float) 合法）。
 */
let LUT_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER3D(lut, 1);

uniform vec4 u_lutSize;   // x=lutSize（LUT 边长，如 16/32）
uniform vec4 u_intensity; // x=intensity（混合强度 [0,1]）

void main()
{
    vec4 val = texture2D(tDiffuse, v_blitUV);
    vec4 lutVal;

    // pull the sample in by half a pixel so the sample begins
    // at the center of the edge pixels.（注释原文）
    float pixelWidth = 1.0 / u_lutSize.x;
    float halfPixelWidth = 0.5 / u_lutSize.x;
    // 显式三参数 splat（规避 shaderc 转 HLSL 的 X3014 单参数构造问题）
    vec3 uvw = vec3(halfPixelWidth, halfPixelWidth, halfPixelWidth) + val.rgb * (1.0 - pixelWidth);

    lutVal = vec4(texture3D(lut, uvw).rgb, val.a);

    gl_FragColor = vec4(mix(val, lutVal, u_intensity.x));
}
"""

/**
 * pixelated FS：RenderPixelatedPass 合成专用（RenderPixelatedPass 内嵌
 * pixelatedMaterial 完整非简化移植）。
 * 低分辨率 beauty 放大 + 深度/法线边缘检测降采样（像素化风格）。
 *
 * bgfx 差异：
 *   - uniforms 是 float（normalEdgeStrength/depthEdgeStrength）与 vec4（resolution）；
 *     bgfx uniform 最小单位 vec4，故用 u_normalEdgeStrength(vec4.x) / u_depthEdgeStrength(vec4.x) /
 *     u_resolution(vec4: xy=低分辨率尺寸, zw=1/尺寸)。
 *   - `getDepth(int x, int y)` / `getNormal(int x, int y)` 的 vec2(x, y) 参数是 int，
 *     转 HLSL 时 int→float 隐式构造有 X3014 风险，改显式 vec2(float(x), float(y))。
 *   - `2.` / `.01` 等省略尾零字面量在 HLSL 兼容性差，全部改 2.0 / 0.01。
 *   - tDiffuse(sampler0) / tDepth(sampler1) / tNormal(sampler2) 三路纹理绑定。
 */
let PIXELATED_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER2D(tDepth, 1);
SAMPLER2D(tNormal, 2);

uniform vec4 u_resolution;         // xy=低分辨率尺寸, zw=1/尺寸
uniform vec4 u_normalEdgeStrength; // x=normalEdgeStrength
uniform vec4 u_depthEdgeStrength;  // x=depthEdgeStrength

float getDepth(vec2 uv, int x, int y) {
    // int→float 显式转换，规避 shaderc 转 HLSL 的 X3014 构造问题
    return texture2D(tDepth, uv + vec2(float(x), float(y)) * u_resolution.zw).r;
}

vec3 getNormal(vec2 uv, int x, int y) {
    return texture2D(tNormal, uv + vec2(float(x), float(y)) * u_resolution.zw).rgb * 2.0 - 1.0;
}

float depthEdgeIndicator(vec2 uv, float depth, vec3 normal) {
    float diff = 0.0;
    diff += clamp(getDepth(uv, 1, 0) - depth, 0.0, 1.0);
    diff += clamp(getDepth(uv, -1, 0) - depth, 0.0, 1.0);
    diff += clamp(getDepth(uv, 0, 1) - depth, 0.0, 1.0);
    diff += clamp(getDepth(uv, 0, -1) - depth, 0.0, 1.0);
    return floor(smoothstep(0.01, 0.02, diff) * 2.0) / 2.0;
}

float neighborNormalEdgeIndicator(vec2 uv, int x, int y, float depth, vec3 normal) {
    float depthDiff = getDepth(uv, x, y) - depth;
    vec3 neighborNormal = getNormal(uv, x, y);

    // Edge pixels should yield to faces who's normals are closer to the bias normal.
    vec3 normalEdgeBias = vec3(1.0, 1.0, 1.0); // This should probably be a parameter.
    float normalDiff = dot(normal - neighborNormal, normalEdgeBias);
    float normalIndicator = clamp(smoothstep(-0.01, 0.01, normalDiff), 0.0, 1.0);

    // Only the shallower pixel should detect the normal edge.
    float depthIndicator = clamp(sign(depthDiff * 0.25 + 0.0025), 0.0, 1.0);

    return (1.0 - dot(normal, neighborNormal)) * depthIndicator * normalIndicator;
}

float normalEdgeIndicator(vec2 uv, float depth, vec3 normal) {
    float indicator = 0.0;

    indicator += neighborNormalEdgeIndicator(uv, 0, -1, depth, normal);
    indicator += neighborNormalEdgeIndicator(uv, 0, 1, depth, normal);
    indicator += neighborNormalEdgeIndicator(uv, -1, 0, depth, normal);
    indicator += neighborNormalEdgeIndicator(uv, 1, 0, depth, normal);

    return step(0.1, indicator);
}

void main()
{
    vec4 texel = texture2D(tDiffuse, v_blitUV);

    float depth = 0.0;
    // 注：不用 vec3(0.0) 单参数 splat 构造 —— shaderc 转 HLSL 后 float3(标量)
    // 被 D3DCompiler 判 X3014（numeric-type constructor 参数个数错误），改显式三参数。
    vec3 normal = vec3(0.0, 0.0, 0.0);

    if (u_depthEdgeStrength.x > 0.0 || u_normalEdgeStrength.x > 0.0) {
        depth = getDepth(v_blitUV, 0, 0);
        normal = getNormal(v_blitUV, 0, 0);
    }

    float dei = 0.0;
    if (u_depthEdgeStrength.x > 0.0) {
        dei = depthEdgeIndicator(v_blitUV, depth, normal);
    }

    float nei = 0.0;
    if (u_normalEdgeStrength.x > 0.0) {
        nei = normalEdgeIndicator(v_blitUV, depth, normal);
    }

    float Strength = dei > 0.0 ? (1.0 - u_depthEdgeStrength.x * dei) : (1.0 + u_normalEdgeStrength.x * nei);

    gl_FragColor = texel * Strength;
}
"""

/**
 * transition FS：RenderTransitionPass 合成专用（RenderTransitionPass 内嵌
 * transitionMaterial 完整非简化移植）。
 * 场景A/场景B 双纹理按 mixRatio 混合，可选过渡纹理（tMixTexture）做阈值过渡。
 *
 * bgfx 差异：
 *   - uniforms 是 float（mixRatio/threshold）与 int（useTexture）；
 *     bgfx uniform 最小单位 vec4，故用 u_mixRatio(vec4.x) / u_threshold(vec4.x) /
 *     u_useTexture(vec4.x: 1.0=用纹理过渡, 0.0=纯比例混合)。
 *   - `uniform int useTexture` + `if (useTexture == 1)`；bgfx 用 vec4.x 表示，
 *     比较时 `== 1.0`（沿用 u_shape.x == 1.0 范式）。
 *   - tDiffuse1(sampler0) / tDiffuse2(sampler1) / tMixTexture(sampler2) 三路纹理绑定。
 */
let TRANSITION_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse1, 0);
SAMPLER2D(tDiffuse2, 1);
SAMPLER2D(tMixTexture, 2);

uniform vec4 u_mixRatio;   // x=mixRatio（过渡比例 [0,1]）
uniform vec4 u_threshold;  // x=threshold（过渡纹理阈值，0=全效果, 1=无效果）
uniform vec4 u_useTexture; // x=1.0 用纹理过渡 / 0.0 纯比例混合

void main()
{
    vec4 texel1 = texture2D(tDiffuse1, v_blitUV);
    vec4 texel2 = texture2D(tDiffuse2, v_blitUV);

    if (u_useTexture.x == 1.0) {
        vec4 transitionTexel = texture2D(tMixTexture, v_blitUV);
        float r = u_mixRatio.x * (1.0 + u_threshold.x * 2.0) - u_threshold.x;
        float mixf = clamp((transitionTexel.r - r) * (1.0 / u_threshold.x), 0.0, 1.0);

        gl_FragColor = mix(texel1, texel2, mixf);
    } else {
        gl_FragColor = mix(texel2, texel1, u_mixRatio.x);
    }
}
"""

/**
 * volumecloud FS：VolumeCloudPass 专用（webgl_volume_cloud 示例完整非简化移植）。
 * 全屏后处理体积云：每像素重建世界射线 → 云盒 AABB 相交 → 逐层步进采样 3D 噪声纹理 →
 * wang_hash 抖动 + smoothstep 密度 + 差分着色 → alpha 累积 → 与场景色（tDiffuse）合成。
 *
 * 对照原示例（webgl_volume_cloud）：
 *   - 原版用 BoxGeometry + 原始着色器材质的物体级 ray marching（vOrigin/vDirection 来自 VS）；
 *     bgfx 后处理 pass 用全屏 quad，射线在原片元中由逆视图投影矩阵重建（u_cloudInvViewProj + u_cameraPos）。
 *   - 原版在模型本地空间 [-0.5,0.5] 步进、采样坐标 p+0.5 → [0,1]；本实现云盒为世界空间
 *     AABB（u_boxCenter/u_boxHalfSize），步进点经 (p-boxMin)/(boxMax-boxMin) 映射到 [0,1]³ 纹理坐标。
 *   - 原版 `textureSize(map,0)` 取噪声尺寸做抖动缩放；bgfx 无 textureSize 跨平台保证，
 *     改 uniform u_texSize（vec4.x=尺寸）传入。
 *   - 原版输出 `color = linearToSRGB(ac)` 由透明材质混合；bgfx 后处理需显式合成：
 *     final = scene*(1-ac.a) + linearToSRGB(ac.rgb)*ac.a。
 *   - wang_hash/randomFloat/hitBox/shading/linearToSRGB 与原版一致（uint 位运算 HLSL 兼容）。
 * uniforms: tDiffuse(sampler0 场景色), u_cloudMap(sampler3D stage1 噪声),
 *           u_cloudInvViewProj(mat4), u_cameraPos(vec4.xyz), u_boxCenter/u_boxHalfSize(vec4.xyz),
 *           u_base(vec4.rgb 云基准色), u_threshold/u_range/u_opacity/u_steps/u_frame/u_texSize(vec4.x)
 */
let VOLUME_CLOUD_FS = """
$input v_blitUV

#include <bgfx_shader.sh>

SAMPLER2D(tDiffuse, 0);
SAMPLER3D(u_cloudMap, 1);

uniform mat4 u_cloudInvViewProj; // 逆视图投影矩阵（重建世界射线；避开 bgfx 内置 u_invViewProj）
uniform vec4 u_cameraPos;     // xyz=相机世界位置
uniform vec4 u_boxCenter;     // xyz=云盒中心（世界坐标）
uniform vec4 u_boxHalfSize;   // xyz=云盒半尺寸（世界坐标）
uniform vec4 u_base;          // rgb=云基准色
uniform vec4 u_threshold;     // x=density threshold
uniform vec4 u_range;         // x=smoothstep range
uniform vec4 u_opacity;       // x=opacity
uniform vec4 u_steps;         // x=ray marching 步数
uniform vec4 u_frame;         // x=帧号（抖动种子动画）
uniform vec4 u_texSize;       // x=3D 噪声纹理尺寸（抖动缩放）

uint wang_hash(uint seed)
{
    seed = (seed ^ 61u) ^ (seed >> 16u);
    seed *= 9u;
    seed = seed ^ (seed >> 4u);
    seed *= 0x27d4eb2du;
    seed = seed ^ (seed >> 15u);
    return seed;
}

float randomFloat(inout uint seed)
{
    return float(wang_hash(seed)) / 4294967296.0;
}

// 射线与云盒 AABB 相交（世界空间，返回 (t0, t1)；t0>t1 表示未命中）
vec2 hitBox(vec3 orig, vec3 dir)
{
    vec3 boxMin = u_boxCenter.xyz - u_boxHalfSize.xyz;
    vec3 boxMax = u_boxCenter.xyz + u_boxHalfSize.xyz;
    vec3 invDir = 1.0 / dir;
    vec3 tminTmp = (boxMin - orig) * invDir;
    vec3 tmaxTmp = (boxMax - orig) * invDir;
    vec3 tmin = min(tminTmp, tmaxTmp);
    vec3 tmax = max(tminTmp, tmaxTmp);
    float t0 = max(tmin.x, max(tmin.y, tmin.z));
    float t1 = min(tmax.x, min(tmax.y, tmax.z));
    return vec2(t0, t1);
}

// 采样 3D 噪声密度（对应 sample1( p )：texture( map, p ).r）
// bgfx 差异：循环内 texture3D 是隐式梯度采样，HLSL 下可变迭代次数循环会报 X3511
//（unable to unroll loop）；改用显式 Lod=0 的 texture3DLod 消除梯度，保留运行时可调步数。
float sample1(vec3 p)
{
    return texture3DLod(u_cloudMap, p, 0.0).r;
}

// 差分着色（对应 shading( coord ) — 中心差分近似密度梯度）
float shading(vec3 coord)
{
    float step = 0.01;
    // 显式三参数构造（规避 shaderc 转 HLSL 的 X3014 单参数 splat 问题）
    return sample1(coord + vec3(-step, -step, -step)) - sample1(coord + vec3(step, step, step));
}

vec4 linearToSRGB(in vec4 value)
{
    // 显式三参数 splat（同 LUT_FS 规避 X3014 的处理）
    return vec4(mix(pow(value.rgb, vec3(0.41666, 0.41666, 0.41666)) * 1.055 - vec3(0.055, 0.055, 0.055),
                    value.rgb * 12.92,
                    vec3(lessThanEqual(value.rgb, vec3(0.0031308, 0.0031308, 0.0031308)))),
                value.a);
}

void main()
{
    // 重建世界射线方向：NDC（bgfx UV 原点左上，v 向下 → NDC y = 1 - 2*uv.y）
    vec2 ndc = vec2(v_blitUV.x * 2.0 - 1.0, 1.0 - v_blitUV.y * 2.0);
    vec4 farPos = mul(u_cloudInvViewProj, vec4(ndc, 1.0, 1.0));
    vec3 rayDir = normalize(farPos.xyz / farPos.w - u_cameraPos.xyz);
    vec3 rayOrigin = u_cameraPos.xyz;

    vec2 bounds = hitBox(rayOrigin, rayDir);
    if (bounds.x > bounds.y) {
        gl_FragColor = texture2D(tDiffuse, v_blitUV);
        return;
    }

    bounds.x = max(bounds.x, 0.0);

    float stepSize = (bounds.y - bounds.x) / u_steps.x;

    // 抖动（对应原版种子：uint(gl_FragCoord.x)*1973 + uint(gl_FragCoord.y)*9277 + uint(frame)*26699）
    uint seed = uint(gl_FragCoord.x) * uint(1973) + uint(gl_FragCoord.y) * uint(9277) + uint(u_frame.x) * uint(26699);
    float randNum = randomFloat(seed) * 2.0 - 1.0;

    vec3 boxMin = u_boxCenter.xyz - u_boxHalfSize.xyz;
    vec3 boxMax = u_boxCenter.xyz + u_boxHalfSize.xyz;
    vec3 boxSize = boxMax - boxMin;

    vec3 p = rayOrigin + bounds.x * rayDir;
    p += rayDir * randNum * (1.0 / u_texSize.x);

    // alpha 累积（对应原版：vec4 ac = vec4( base, 0.0 );）
    vec4 ac = vec4(u_base.rgb, 0.0);

    for (float i = 0.0; i < u_steps.x; i += 1.0) {
        float t = bounds.x + i * stepSize;
        // 世界坐标 → [0,1]³ 纹理坐标（映射云盒 AABB 到噪声纹理）
        vec3 texCoord = (p - boxMin) / boxSize;

        float d = sample1(texCoord);
        d = smoothstep(u_threshold.x - u_range.x, u_threshold.x + u_range.x, d) * u_opacity.x;

        float col = shading(texCoord) * 3.0 + ((texCoord.x + texCoord.y) * 0.25) + 0.2;

        ac.rgb += (1.0 - ac.a) * d * col;
        ac.a += (1.0 - ac.a) * d;

        if (ac.a >= 0.95) break;

        p += rayDir * stepSize;
    }

    // 与场景色合成（对应原版：color = linearToSRGB( ac )；透明材质混合改为显式 over 合成）
    vec4 scene = texture2D(tDiffuse, v_blitUV);
    vec3 cloudColor = linearToSRGB(ac).rgb;
    gl_FragColor = vec4(mix(scene.rgb, cloudColor, ac.a), 1.0);
}
"""

/**
 * 后处理内部 shader 注册表。
 *
 * 各后处理 shader 的注册与使用（按效果族组织）。
 * 取代此前从 ShaderLibs.get() 取后处理 shader 的方式。
 */
public class PostProcessingShaders {
    /**
     * 后处理 shader 注册表（name → ShaderProgram）。
     */
    private static var programs: HashMap<String, ShaderProgram> = HashMap<String, ShaderProgram>()

    /**
     * 取后处理 shader 程序（未注册返回 None）。
     * 惰性初始化：首次调用时自动注册全部后处理 shader（幂等）。
     *
     * @param name shader 注册名（copy/output/bloom 系列/fxaa/smaa 系列/ssao 系列）
     */
    public static func get(name: String): ?ShaderProgram {
        PostProcessingShaders.initialize()
        return programs.get(name)
    }

    /**
     * 注册全部后处理 shader（copy/output/bloom/fxaa/smaa/ssao 系列）。
     * 由 ThreeRenderer 初始化或各 pass 首次使用时调用（幂等）。
     */
    public static func initialize(): Unit {
        if (programs.size > 0) {
            return
        }
        // copy：SavePass/TexturePass/ShaderPass 共用（CopyShader）
        programs.add("copy", ShaderProgram("copy", POST_BLIT_VS, COPY_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // output：OutputPass 专用（OutputShader）
        programs.add("output", ShaderProgram("output", POST_BLIT_VS, OUTPUT_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // cube_tex：CubeTexturePass 专用（真正采样 textureCube 的天空盒 shader，
        // 替代 ShaderLibs 中 basic 占位的 "cube"）
        programs.add("cube_tex", ShaderProgram("cube_tex", CUBE_TEX_VS, CUBE_TEX_FS, varyingDef: CUBE_TEX_VARYING_DEF))
        // bloom：UnrealBloomPass 专用（LuminosityHighPassShader + UnrealBloomPass）
        programs.add("bloom_luminosity", ShaderProgram("bloom_luminosity", POST_BLIT_VS, BLOOM_LUM_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // bloom_blur 按 KERNEL_RADIUS 注册 5 个独立变体（6/10/14/18/22），
        // 每级 mip 用自己编译的 program —— 避免共享单例只编译首个 radius 导致各级模糊半径失效。
        programs.add("bloom_blur_k6", ShaderProgram("bloom_blur_k6", POST_BLIT_VS, BLOOM_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_blur_k10", ShaderProgram("bloom_blur_k10", POST_BLIT_VS, BLOOM_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_blur_k14", ShaderProgram("bloom_blur_k14", POST_BLIT_VS, BLOOM_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_blur_k18", ShaderProgram("bloom_blur_k18", POST_BLIT_VS, BLOOM_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_blur_k22", ShaderProgram("bloom_blur_k22", POST_BLIT_VS, BLOOM_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_composite", ShaderProgram("bloom_composite", POST_BLIT_VS, BLOOM_COMPOSITE_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_blend", ShaderProgram("bloom_blend", POST_BLIT_VS, BLOOM_BLEND_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // bloom 简单版（BloomPass 专用，BloomPass：ConvolutionShader + CombineShader）：
        //   - bloom_conv：卷积模糊，编译时经 compileBgfxWithDefines 传 KERNEL_SIZE_FLOAT/KERNEL_SIZE_INT
        //   - bloom_combine：scene + strength × blur 合成（bgfx 无全局混合状态，shader 内相加替代 AdditiveBlending）
        programs.add("bloom_conv", ShaderProgram("bloom_conv", BLOOM_CONV_VS, BLOOM_CONV_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("bloom_combine", ShaderProgram("bloom_combine", POST_BLIT_VS, BLOOM_COMBINE_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // fxaa：FXAAPass 专用（FXAAShader）
        programs.add("fxaa", ShaderProgram("fxaa", POST_BLIT_VS, FXAA_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // smaa：SMAAPass 专用（SMAAShader 三遍）
        programs.add("smaaEdges", ShaderProgram("smaaEdges", POST_BLIT_VS, SMAA_EDGES_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("smaaWeights", ShaderProgram("smaaWeights", POST_BLIT_VS, SMAA_WEIGHTS_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("smaaBlend", ShaderProgram("smaaBlend", POST_BLIT_VS, SMAA_BLEND_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // ssao：SSAOPass 专用（SSAOShader/SSAOBlurShader/SSAODepthShader）
        programs.add("ssao", ShaderProgram("ssao", SSAO_VS, SSAO_FS, varyingDef: SSAO_VARYING_DEF))
        programs.add("ssaoblur", ShaderProgram("ssaoblur", SSAO_VS, SSAO_BLUR_FS, varyingDef: SSAO_VARYING_DEF))
        programs.add("ssaodepth", ShaderProgram("ssaodepth", SSAO_DEPTH_VS, SSAO_DEPTH_FS, varyingDef: SSAO_DEPTH_VARYING_DEF))
        programs.add("ssaoapply", ShaderProgram("ssaoapply", SSAO_VS, SSAO_APPLY_FS, varyingDef: SSAO_VARYING_DEF))
        // sao：SAOPass 专用（SAOShader + DepthLimitedBlurShader + 应用）
        programs.add("sao", ShaderProgram("sao", SAO_VS, SAO_FS, varyingDef: SAO_VARYING_DEF))
        programs.add("saoblur", ShaderProgram("saoblur", SAO_VS, SAO_BLUR_FS, varyingDef: SAO_VARYING_DEF))
        programs.add("saoapply", ShaderProgram("saoapply", SAO_VS, SAO_APPLY_FS, varyingDef: SAO_VARYING_DEF))
        // aodepth：GTAOPass/SAOPass 共用（写 NDC 深度到 RGBA32F）
        programs.add("aodepth", ShaderProgram("aodepth", AO_DEPTH_VS, AO_DEPTH_FS, varyingDef: AO_DEPTH_VARYING_DEF))
        // gtao：GTAOPass 专用（GTAOShader/GTAODepthShader/GTAOBlendShader/PoissonDenoiseShader）
        programs.add("gtao", ShaderProgram("gtao", POST_BLIT_VS, GTAO_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("gtaodepth", ShaderProgram("gtaodepth", POST_BLIT_VS, GTAO_DEPTH_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("gtaoblend", ShaderProgram("gtaoblend", POST_BLIT_VS, GTAO_BLEND_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("gtaopd", ShaderProgram("gtaopd", POST_BLIT_VS, GTAO_PD_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("gtaoapply", ShaderProgram("gtaoapply", POST_BLIT_VS, GTAO_APPLY_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // outline：OutlinePass 专用（copy/edge_detection/separable_blur/overlay/depth/prepare_mask）
        programs.add("outline_copy", ShaderProgram("outline_copy", POST_BLIT_VS, OUTLINE_COPY_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("outline_edge_detection", ShaderProgram("outline_edge_detection", POST_BLIT_VS, OUTLINE_EDGE_DETECTION_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("outline_separable_blur", ShaderProgram("outline_separable_blur", POST_BLIT_VS, OUTLINE_SEPARABLE_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("outline_overlay", ShaderProgram("outline_overlay", POST_BLIT_VS, OUTLINE_OVERLAY_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("outline_depth", ShaderProgram("outline_depth", POST_BLIT_VS, OUTLINE_DEPTH_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("outline_prepare_mask", ShaderProgram("outline_prepare_mask", POST_BLIT_VS, OUTLINE_PREPARE_MASK_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // outline_white：渲选中物体为纯白 mask 的几何 shader（OutlinePass depth/mask pass 直接 submit 用）
        programs.add("outline_white", ShaderProgram("outline_white", OUTLINE_WHITE_VS, OUTLINE_WHITE_FS, varyingDef: OUTLINE_WHITE_VARYING_DEF))
        // ssr：SSRPass 专用（SSRShader/SSRBlurShader/SSRDepthShader/SSRApplyShader）
        programs.add("ssr", ShaderProgram("ssr", POST_BLIT_VS, SSR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("ssrblur", ShaderProgram("ssrblur", POST_BLIT_VS, SSR_BLUR_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("ssrdepth", ShaderProgram("ssrdepth", POST_BLIT_VS, SSR_DEPTH_FS, varyingDef: POST_BLIT_VARYING_DEF))
        programs.add("ssrapply", ShaderProgram("ssrapply", POST_BLIT_VS, SSR_APPLY_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // metalness：SSR selective 模式专用，画场景几何到 metalness RT（u_metalness uniform 区分 on/off）
        programs.add("ssr_metalness", ShaderProgram("ssr_metalness", SSR_METALNESS_VS, SSR_METALNESS_FS, varyingDef: SSR_METALNESS_VARYING_DEF))
        // afterimage：AfterimagePass 专用（AfterimageShader）
        // uniforms: tOld(sampler0, 上一帧残影), tNew(sampler1, 当前帧), u_damp(vec4: x=damp)
        programs.add("afterimage", ShaderProgram("afterimage", POST_BLIT_VS, AFTERIMAGE_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // film：FilmPass 专用（FilmShader）
        // uniforms: tDiffuse(sampler0), u_intensity(vec4: x=intensity), u_grayscale(vec4: x=grayscale), u_time(vec4: x=time)
        programs.add("film", ShaderProgram("film", POST_BLIT_VS, FILM_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // glitch：GlitchPass 专用（DigitalGlitch 完整非简化移植）
        // uniforms: tDiffuse(sampler0), tDisp(sampler1), u_byp/u_amount/u_angle/u_seed/u_seed_x/u_seed_y/u_distortion_x/u_distortion_y/u_col_s
        programs.add("glitch", ShaderProgram("glitch", POST_BLIT_VS, GLITCH_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // dot_screen：DotScreenPass 专用（DotScreenShader 完整非简化移植）
        // uniforms: tDiffuse(sampler0), u_center(vec4: xy=center), u_angle(vec4: x=angle),
        //           u_scale(vec4: x=scale), u_tSize(vec4: xy=texture size)
        programs.add("dot_screen", ShaderProgram("dot_screen", POST_BLIT_VS, DOT_SCREEN_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // halftone：HalftonePass 专用（HalftoneShader 完整非简化移植）
        // uniforms: tDiffuse(sampler0), u_shape/u_radius/u_rotateR/u_rotateG/u_rotateB/u_scatter/
        //           u_width/u_height/u_blending/u_blendingMode/u_greyscale/u_disable
        programs.add("halftone", ShaderProgram("halftone", POST_BLIT_VS, HALFTONE_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // bokeh_depth：BokehPass 深度 pass 专用（MeshDepthMaterial + RGBADepthPacking）
        // 几何 VS（u_model[0] × u_viewProj），FS 写 packDepthToRGBA(gl_FragCoord.z) 到深度 RT
        programs.add("bokeh_depth", ShaderProgram("bokeh_depth", BOKEH_DEPTH_VS, BOKEH_DEPTH_FS, varyingDef: BOKEH_DEPTH_VARYING_DEF))
        // bokeh：BokehPass 主计算专用（BokehShader 完整非简化移植）
        // uniforms: tColor(sampler0), tDepth(sampler1), u_focus/u_aspect/u_aperture/u_maxblur/
        //           u_nearClip/u_farClip（vec4.x=值）
        programs.add("bokeh", ShaderProgram("bokeh", POST_BLIT_VS, BOKEH_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // lut：LUTPass 专用（内嵌 LUTShader 完整非简化移植）
        // uniforms: tDiffuse(sampler0), lut(sampler3D, stage 1), u_lutSize(vec4.x=lutSize),
        //           u_intensity(vec4.x=intensity)
        programs.add("lut", ShaderProgram("lut", POST_BLIT_VS, LUT_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // pixelated：RenderPixelatedPass 合成专用（内嵌 pixelatedMaterial 完整非简化移植）
        // uniforms: tDiffuse(sampler0), tDepth(sampler1), tNormal(sampler2),
        //           u_resolution(vec4: xy=低分辨率尺寸, zw=1/尺寸), u_normalEdgeStrength(vec4.x),
        //           u_depthEdgeStrength(vec4.x)
        programs.add("pixelated", ShaderProgram("pixelated", POST_BLIT_VS, PIXELATED_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // transition：RenderTransitionPass 合成专用（内嵌 transitionMaterial 完整非简化移植）
        // uniforms: tDiffuse1(sampler0, 场景A), tDiffuse2(sampler1, 场景B),
        //           tMixTexture(sampler2, 过渡纹理), u_mixRatio(vec4.x), u_threshold(vec4.x),
        //           u_useTexture(vec4.x: 1=用纹理过渡, 0=纯比例混合)
        programs.add("transition", ShaderProgram("transition", POST_BLIT_VS, TRANSITION_FS, varyingDef: POST_BLIT_VARYING_DEF))
        // volumecloud：VolumeCloudPass 专用（webgl_volume_cloud 示例完整非简化移植）
        // uniforms: tDiffuse(sampler0 场景色), u_cloudMap(sampler3D stage1 噪声),
        //           u_cloudInvViewProj(mat4), u_cameraPos(u_boxCenter/u_boxHalfSize/u_base vec4),
        //           u_threshold/u_range/u_opacity/u_steps/u_frame/u_texSize(vec4.x)
        programs.add("volumecloud", ShaderProgram("volumecloud", POST_BLIT_VS, VOLUME_CLOUD_FS, varyingDef: POST_BLIT_VARYING_DEF))
    }
}


