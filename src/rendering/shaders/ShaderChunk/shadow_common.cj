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
 * @file[zh-cn] shadow_common  16-shadowmaps 核心阴影函数 ShaderChunk
 * @brief[zh-cn] 16-shadowmaps 核心阴影函数 ShaderChunk
 *
 * @file[en] shadow_common  16-shadowmaps core shadow function ShaderChunk
 * @brief[en] 16-shadowmaps core shadow function ShaderChunk
 * 包含所有阴影实现类型的核心函数:
 * - PCF: Vogel disk + IGN 采样
 * - PCSS: blocker search → penumbra estimate → PCF filter
 * - VSM: 方差阴影贴图
 * - ESM: 指数阴影贴图
 * - findBlocker: blocker search (PCSS Step 1)
 * - blur9: 9-tap Gaussian blur (VSM/ESM 共用)
 * 本 chunk 由 shadow_*_fragment 系列 ShaderLib 程序按需 #include。
 * 使用仓颉三引号多行字符串语法。
 */
package three.rendering.shaders.ShaderChunk

/**
 * @brief[zh-cn] shadow_common GLSL 片段字符串
 * @explain[zh-cn] 保留 GLSL/bgfx 原文。
 *
 * @brief[en] shadow_common GLSL fragment string
 * @explain[en] Preserving GLSL/bgfx original text.
 */
public const shadow_common: String = #"

// ===== Vogel disk + Poisson 采样 (PCF/PCSS 共用) =====
// 对照 16-shadowmaps/common.sh: sampleVogelDisk/samplePoisson

vec2 sampleVogelDisk(int index, int sampleCount)
{
    const float goldenAngle = 2.39996323; // radians
    float i = float(index);
    float r = sqrt((i + 0.5) / float(sampleCount));
    float a = i * goldenAngle;
    return vec2(cos(a), sin(a)) * r;
}

vec2 samplePoisson(int index)
{
    return sampleVogelDisk(index, 10);
}

// ===== 辅助函数 =====
// 对照 16-shadowmaps/common.sh: linstep/attenuation/spot/lit

float linstep(float _edge0, float _edge1, float _x)
{
    return clamp((_x-_edge0)/(_edge1-_edge0), 0.0, 1.0);
}

float attenuation(float _dist, vec3 _attn)
{
    return 1.0 / ( _attn.x                  //const
                 + _attn.y * _dist          //linear
                 + _attn.z * _dist * _dist  //quadrantic
                 );
}

float spot(float _ldotsd, float _inner, float _outer)
{
    float inner = cos(radians(_inner));
    float outer = cos(radians(min(_outer, _inner - 0.001)));
    float spot = clamp((_ldotsd - inner) / (outer - inner), 0.0, 1.0);
    return spot;
}

vec2 lit(vec3 _ld, vec3 _n, vec3 _vd, float _exp)
{
    //diff
    float ndotl = dot(_n, _ld);

    //spec
    vec3 r = 2.0*ndotl*_n - _ld; // reflect(_ld, _n);
    float rdotv = dot(r, _vd);
    float spec = step(0.0, ndotl) * pow(max(0.0, rdotv), _exp) * (2.0 + _exp)/8.0;

    return max(vec2(ndotl, spec), 0.0);
}

// ===== 光源求值 (evalLight) =====
// 对照 16-shadowmaps/common.sh: Light struct + evalLight

struct Light
{
    vec3 l;
    vec3 ld;
    float attn;
};

Light evalLight(vec3 _v, vec4 _l, vec3 _spotDirection, float _spotInner, float _spotOuter, vec3 _attnParams)
{
    Light light;

    //directional
    light.l    = _l.xyz;
    light.ld   = -normalize(light.l);
    light.attn = 1.0;

    if (0.0 != _l.w) //point or spot
    {
        light.l  = _l.xyz - _v;
        light.ld = normalize(light.l);

        float ldotsd = max(0.0, dot(-light.ld, normalize(_spotDirection)));
        float falloff = spot(ldotsd, _spotOuter, _spotInner);
        light.attn = attenuation(length(light.l), _attnParams) * mix(falloff, 1.0, step(90, _spotOuter));
    }

    return light;
}

// ===== texcoordInRange =====
// 对照 16-shadowmaps/common.sh: texcoordInRange

float texcoordInRange(vec2 _texcoord)
{
    bool inRange = all(greaterThan(_texcoord, vec2_splat(0.0)))
                && all(lessThan   (_texcoord, vec2_splat(1.0)))
                 ;

    return float(inRange);
}

// ===== 采样旋转工具 =====
// 对照 16-shadowmaps/common.sh: rotateSample/interleavedGradientNoise

// Rotate a 2D sample by a precomputed sin/cos pair.
// _sincos = vec2(sin(angle), cos(angle))
vec2 rotateSample(vec2 _sample, vec2 _sincos)
{
    return vec2(_sample.x * _sincos.y - _sample.y * _sincos.x,
                _sample.x * _sincos.x + _sample.y * _sincos.y);
}

// Interleaved gradient noise for per-pixel Poisson disk rotation.
// Produces well-distributed noise that avoids the clustering artifacts of
// traditional fract(sin(...)) hashes. Converts structured Poisson banding
// into smooth, perceptually-uniform noise.
// Source: "Next Generation Post Processing in Call of Duty: AW" (Jimenez 2014)
float interleavedGradientNoise(vec2 _screenPos)
{
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(_screenPos, magic.xy)));
}

// ===== Hard Shadow (BASIC_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: hardShadowLod/hardShadow

float hardShadowLod(sampler2D _sampler, float lod, vec4 _shadowCoord, float _bias)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w;
    float occluder = unpackRgbaToFloat(texture2DLod(_sampler, texCoord, lod) );

    float visibility = step(receiver, occluder);
    return visibility;
}

float hardShadow(sampler2D _sampler, vec4 _shadowCoord, float _bias)
{
    return hardShadowLod(_sampler, 0.0, _shadowCoord, _bias);
}

// ===== PCF (PCF_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: PCFLodOffset/PCFLod/PCF
// BLOCKER_SEARCH_NUM_SAMPLES / PCF_LOD_OFFSET_NUM_SAMPLES 由调用方 #define

float PCFLodOffset(sampler2D _sampler, float lod, vec2 offset, vec4 _shadowCoord, float _bias, vec2 _texelSize, vec2 _diskRotation)
{
    float result = 0.0;

    for ( int i = 0; i < PCF_LOD_OFFSET_NUM_SAMPLES; ++i )
    {
        vec2 jitteredOffset = rotateSample(samplePoisson(i), _diskRotation) * offset;
        result += hardShadowLod(_sampler, lod, _shadowCoord + vec4(jitteredOffset, 0.0, 0.0), _bias);
    }
    return result / float(PCF_LOD_OFFSET_NUM_SAMPLES);
}

float PCFLod(sampler2D _sampler, float lod, vec2 filterRadius, vec4 _shadowCoord, float _bias, vec4 _pcfParams, vec2 _texelSize, vec2 _diskRotation)
{
    vec2 offset = filterRadius * _pcfParams.zw * _texelSize * _shadowCoord.w;

    return PCFLodOffset(_sampler, lod, offset, _shadowCoord, _bias, _texelSize, _diskRotation);
}

float PCF(sampler2D _sampler, vec4 _shadowCoord, float _bias, vec4 _pcfParams, vec2 _texelSize, vec2 fragCoord)
{
    // Per-pixel Poisson disk rotation from shadow map texel coordinates
    vec2 noiseCoord = fragCoord;
    //vec2 noiseCoord = (_shadowCoord.xy / _shadowCoord.w) * (1.0 / _texelSize.x);
    float angle = interleavedGradientNoise(noiseCoord) * 6.283185;
    vec2 diskRotation = vec2(sin(angle), cos(angle));
    return PCFLod(_sampler, 0.0, vec2(2.0, 2.0), _shadowCoord, _bias, _pcfParams, _texelSize, diskRotation);
}

// ===== VSM (VSM_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: VSM

float VSM(sampler2D _sampler, vec4 _shadowCoord, float _bias, float _depthMultiplier, float _minVariance)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w * _depthMultiplier;
    vec4 rgba = texture2D(_sampler, texCoord);
    vec2 occluder = vec2(unpackHalfFloat(rgba.rg), unpackHalfFloat(rgba.ba)) * _depthMultiplier;

    if (receiver < occluder.x)
    {
        return 1.0;
    }

    float variance = max(occluder.y - (occluder.x*occluder.x), _minVariance);
    float d = receiver - occluder.x;

    float visibility = variance / (variance + d*d);

    return visibility;
}

// ===== ESM (ESM_SHADOW_MAP) =====
// 对照 16-shadowmaps/common.sh: ESM

float ESM(sampler2D _sampler, vec4 _shadowCoord, float _bias, float _depthMultiplier)
{
    vec2 texCoord = _shadowCoord.xy/_shadowCoord.w;

    bool outside = any(greaterThan(texCoord, vec2_splat(1.0)))
                || any(lessThan   (texCoord, vec2_splat(0.0)))
                 ;

    if (outside)
    {
        return 1.0;
    }

    float receiver = (_shadowCoord.z-_bias)/_shadowCoord.w;
    float occluder = unpackRgbaToFloat(texture2D(_sampler, texCoord) );

    float visibility = clamp(exp(_depthMultiplier * (occluder-receiver) ), 0.0, 1.0);

    return visibility;
}

// ===== blur9: 9-tap Gaussian blur (VSM/ESM 共用) =====
// 对照 16-shadowmaps/common.sh: blur9/blur9VSM

vec4 blur9(sampler2D _sampler, vec2 _uv0, vec4 _uv1, vec4 _uv2, vec4 _uv3, vec4 _uv4)
{
#define _BLUR9_WEIGHT_0 1.0
#define _BLUR9_WEIGHT_1 0.9
#define _BLUR9_WEIGHT_2 0.55
#define _BLUR9_WEIGHT_3 0.18
#define _BLUR9_WEIGHT_4 0.1
#define _BLUR9_NORMALIZE (_BLUR9_WEIGHT_0+2.0*(_BLUR9_WEIGHT_1+_BLUR9_WEIGHT_2+_BLUR9_WEIGHT_3+_BLUR9_WEIGHT_4) )
#define BLUR9_WEIGHT(_x) (_BLUR9_WEIGHT_##_x/_BLUR9_NORMALIZE)

    float blur;
    blur  = unpackRgbaToFloat(texture2D(_sampler, _uv0)    * BLUR9_WEIGHT(0));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv1.xy) * BLUR9_WEIGHT(1));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv1.zw) * BLUR9_WEIGHT(1));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv2.xy) * BLUR9_WEIGHT(2));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv2.zw) * BLUR9_WEIGHT(2));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv3.xy) * BLUR9_WEIGHT(3));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv3.zw) * BLUR9_WEIGHT(3));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv4.xy) * BLUR9_WEIGHT(4));
    blur += unpackRgbaToFloat(texture2D(_sampler, _uv4.zw) * BLUR9_WEIGHT(4));
    return packFloatToRgba(blur);
}

vec4 blur9VSM(sampler2D _sampler, vec2 _uv0, vec4 _uv1, vec4 _uv2, vec4 _uv3, vec4 _uv4)
{
#define _BLUR9_WEIGHT_0 1.0
#define _BLUR9_WEIGHT_1 0.9
#define _BLUR9_WEIGHT_2 0.55
#define _BLUR9_WEIGHT_3 0.18
#define _BLUR9_WEIGHT_4 0.1
#define _BLUR9_NORMALIZE (_BLUR9_WEIGHT_0+2.0*(_BLUR9_WEIGHT_1+_BLUR9_WEIGHT_2+_BLUR9_WEIGHT_3+_BLUR9_WEIGHT_4) )
#define BLUR9_WEIGHT(_x) (_BLUR9_WEIGHT_##_x/_BLUR9_NORMALIZE)

    vec2 blur;
    vec4 val;
    val = texture2D(_sampler, _uv0) * BLUR9_WEIGHT(0);
    blur = vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv1.xy) * BLUR9_WEIGHT(1);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv1.zw) * BLUR9_WEIGHT(1);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv2.xy) * BLUR9_WEIGHT(2);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv2.zw) * BLUR9_WEIGHT(2);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv3.xy) * BLUR9_WEIGHT(3);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv3.zw) * BLUR9_WEIGHT(3);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv4.xy) * BLUR9_WEIGHT(4);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));
    val = texture2D(_sampler, _uv4.zw) * BLUR9_WEIGHT(4);
    blur += vec2(unpackHalfFloat(val.rg), unpackHalfFloat(val.ba));

    return vec4(packHalfFloat(blur.x), packHalfFloat(blur.y));
}

// ===== PCSS (PCSS_SHADOW_MAP): blocker search → penumbra → PCF =====
// 对照 16-shadowmaps/common.sh: findBlocker/PCSS
// BLOCKER_SEARCH_NUM_SAMPLES 由调用方 #define (16)

// Returns vec3(avgBlockerDepth, closestBlockerDepth, blockerRatio)
//   avgBlockerDepth:     mean depth of all blockers found (for general penumbra)
//   closestBlockerDepth: maximum depth among blockers (nearest to receiver, for contact hardening)
//   blockerRatio:        fraction of search samples that found a blocker [0..1]
// _diskRotation = vec2(sin(angle), cos(angle)) for per-pixel Poisson disk rotation
vec3 findBlocker(sampler2D _sampler, vec4 _shadowCoord, vec2 _searchSize, float _bias, vec2 _diskRotation)
{
    int blockerCount = 0;
    float avgBlockerDepth = 0.0;
    float closestBlockerDepth = 0.0;
    vec2 texCoord = _shadowCoord.xy / _shadowCoord.w;
    float receiverDepth = (_shadowCoord.z / _shadowCoord.w) - _bias;

    // Search around the shadow coordinate to find blockers
    for( int i = 0; i < BLOCKER_SEARCH_NUM_SAMPLES; ++i )
    {
        vec2 offset = rotateSample(samplePoisson(i), _diskRotation) * _searchSize;
        float shadowMapDepth = unpackRgbaToFloat(texture2D(_sampler, texCoord + offset));
        if (shadowMapDepth < receiverDepth)
        {
            avgBlockerDepth += shadowMapDepth;
            closestBlockerDepth = max(closestBlockerDepth, shadowMapDepth);
            blockerCount++;
        }
    }

    // Calculate average blocker depth
    if (blockerCount > 0)
    {
        avgBlockerDepth /= float(blockerCount);
    }
    else
    {
        avgBlockerDepth = -1.0; // No blockers found
    }

    float blockerRatio = float(blockerCount) / float(BLOCKER_SEARCH_NUM_SAMPLES);
    return vec3(avgBlockerDepth, closestBlockerDepth, blockerRatio);
}

float PCSS(sampler2D _sampler, vec4 _shadowCoord, float _bias, vec4 _pcssParams, vec2 _texelSize, vec2 fragCoord)
{
    // -----------------------------------------------------------------------
    // PCSS Parameters
    // -----------------------------------------------------------------------

    // Blocker search radius in UV space (~10 texels on 1024 map).
    float searchRadiusUV = 0.01;

    // Penumbra scale. Amplifies the squared depth ratio into a UV-space
    // filter radius. Higher = softer shadows at distance.
    float penumbraScaleX = _pcssParams.z;
    float penumbraScaleY = _pcssParams.w;

    // Maximum filter radius in UV space (~50 texels on 1024 map).
    float maxFilterRadius = 0.25;

    // -----------------------------------------------------------------------
    // Per-pixel Poisson disk rotation (Interleaved Gradient Noise)
    // -----------------------------------------------------------------------
    vec2 noiseCoord = fragCoord;
    //vec2 noiseCoord = (_shadowCoord.xy / _shadowCoord.w) * (1.0 / _texelSize.x);
    float noise = interleavedGradientNoise(noiseCoord);
    float rotationAngle = noise * 6.283185;
    vec2 diskRotation = vec2(sin(rotationAngle), cos(rotationAngle));

    // Receiver depth in normalized shadow map space
    float receiverDepth = (_shadowCoord.z / _shadowCoord.w) - _bias;

    // -----------------------------------------------------------------------
    // Step 1: Blocker Search
    // -----------------------------------------------------------------------
    vec3 blockerResult = findBlocker(_sampler, _shadowCoord, vec2(searchRadiusUV, searchRadiusUV), _bias, diskRotation);
    float avgBlockerDepth = blockerResult.x;
    float blockerRatio = blockerResult.z;

    if (avgBlockerDepth < -0.99)
    {
        return 1.0;
    }

    // -----------------------------------------------------------------------
    // Step 2: Penumbra Estimation (standard PCSS, Fernando 2005)
    //
    //   penumbraWidth = lightSize * (d_receiver - d_blocker) / d_blocker
    //
    // The depth gap at contact equals the object's thickness along the
    // light direction. For curved objects (spheres, characters), the gap
    // varies across the shadow giving the contact-hardening gradient.
    // For flat objects (cubes), the gap is constant → uniform penumbra.
    // -----------------------------------------------------------------------
    float penumbraWidth = penumbraScaleX * max(0.0, receiverDepth - avgBlockerDepth) / avgBlockerDepth;
    float penumbraHeight = penumbraScaleY * max(0.0, receiverDepth - avgBlockerDepth) / avgBlockerDepth;
    float filterRadiusU = clamp(penumbraWidth, 0.0, maxFilterRadius);
    float filterRadiusV = clamp(penumbraHeight, 0.0, maxFilterRadius);

    // -----------------------------------------------------------------------
    // Step 3: Percentage-Closer Filtering
    // -----------------------------------------------------------------------
    float visibility = PCFLodOffset(_sampler, 0.0, vec2(filterRadiusU, filterRadiusV), _shadowCoord, _bias, _texelSize, diskRotation);

    // -----------------------------------------------------------------------
    // Step 4: Edge fade based on blocker ratio
    // -----------------------------------------------------------------------
    float edgeFade = smoothstep(0.0, 0.25, blockerRatio);
    visibility = mix(1.0, visibility, edgeFade);

    return visibility;
}
"#
