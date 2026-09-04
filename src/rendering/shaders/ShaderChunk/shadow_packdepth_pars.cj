/**
 * @file[zh-cn] shadow_packdepth_pars  PackDepth/UnpackDepth/HBlur/VBlur ShaderChunk 声明段
 * @brief[zh-cn] PackDepth/UnpackDepth/HBlur/VBlur ShaderChunk 声明段
 *
 * @file[en] shadow_packdepth_pars  PackDepth/UnpackDepth/HBlur/VBlur ShaderChunk declarations
 * @brief[en] PackDepth/UnpackDepth/HBlur/VBlur ShaderChunk declarations
 * 本文件聚合 4 类辅助 pass 的 shader chunk 字符串：
 * ① PackDepth pass：将深度值打包为 RGBA8（或 VSM 的 depth+depth²）
 * ② UnpackDepth pass：将 RGBA8 解包为可视化深度值（debug 用）
 * ③ HBlur pass：水平 9-tap Gaussian 模糊（VSM/ESM 共用）
 * ④ VBlur pass：垂直 9-tap Gaussian 模糊（VSM/ESM 共用）
 * 每类 chunk 同时提供 RGBA 与 VSM 两种打包方式的变体源码，
 * 由 ShaderLib 程序按 SHADOWMAP_TYPE_VSM #define 分派。
 */
package three.rendering.shaders.ShaderChunk

/**
 * PackDepth pass 顶点着色器 chunk。
 *
 * InvZ 模式（默认）：depth = v_position.z / v_position.w * 0.5 + 0.5
 * Linear 模式：depth = v_depth（由 vertex 端预先计算的线性光空间距离）
 *
 * 顶点着色器仅负责传递 v_position（NDC）和 v_depth（线性深度），
 * 打包逻辑在 fragment 端完成。
 */
public const shadow_packdepth_vertex: String = #"
// PackDepth pass 顶点着色器
// 对照 16-shadowmaps: vs_shadowmaps_packdepth.sc / vs_shadowmaps_packdepth_linear.sc
//
// InvZ 模式：传递 v_position（NDC），fragment 端算 depth = z/w*0.5+0.5
// Linear 模式：额外传递 v_depth（线性光空间距离）
// 两种模式由编译期 #define SM_LINEAR 切换

$input a_position

#if defined( SM_LINEAR )
$output v_depth
uniform mat4 u_lightMtx;
#endif

$output v_position

#include <bgfx_shader.sh>

void main()
{
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));

#if defined( SM_LINEAR )
    // Linear 模式：v_depth = 光空间线性距离（由 u_lightMtx 变换）
    v_depth = mul(u_lightMtx, vec4(a_position, 1.0)).z;
#endif

    v_position = gl_Position;
}
"#

/**
 * PackDepth pass 片段着色器 chunk。
 *
 * 四种变体由编译期 #define 切换：
 *   - SHADOWMAP_TYPE_VSM：打包为 depth + depth²（2× half float）
 *   - SM_LINEAR：使用线性光空间距离而非透视 Z 倒数
 *
 * RGBA 路径：gl_FragColor = packFloatToRgba(depth)
 * VSM 路径：gl_FragColor = vec4(packHalfFloat(depth), packHalfFloat(depth*depth))
 */
public const shadow_packdepth_fragment: String = #"
// PackDepth pass 片段着色器
// 对照 16-shadowmaps: fs_shadowmaps_packdepth*.sc
//
// 四种变体由编译期 #define 组合切换：
//   SHADOWMAP_TYPE_VSM × { SM_LINEAR, SM_INVZ }
//   SHADOWMAP_TYPE_RGBA × { SM_LINEAR, SM_INVZ }

$input v_position

#if defined( SM_LINEAR )
$input v_depth
#endif

#include <bgfx_shader.sh>

void main()
{
#if defined( SM_LINEAR )
    // Linear 模式：depth = v_depth（线性光空间距离）
    float depth = v_depth;
#else
    // InvZ 模式（默认）：depth = v_position.z / v_position.w * 0.5 + 0.5
    float depth = v_position.z / v_position.w * 0.5 + 0.5;
#endif

#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：打包 depth + depth²（2× half float）
    float depthSq = depth * depth;
    gl_FragColor = vec4(packHalfFloat(depth), packHalfFloat(depthSq));
#else
    // RGBA 路径：打包 depth 为 RGBA8
    gl_FragColor = packFloatToRgba(depth);
#endif
}
"#

/**
 * UnpackDepth pass 片段着色器 chunk（debug 用）。
 *
 * RGBA 路径：depth = unpackRgbaToFloat(texture2D(s_shadowMap0, v_texcoord0))
 * VSM 路径：depth = unpackHalfFloat(texture2D(s_shadowMap0, v_texcoord0).rg)
 *
 * 可视化：gl_FragColor = vec4(pow(depth, u_depthValuePow))
 */
public const shadow_unpackdepth_fragment: String = #"
// UnpackDepth pass 片段着色器（debug 用）
// 对照 16-shadowmaps: fs_shadowmaps_unpackdepth.sc / fs_shadowmaps_unpackdepth_vsm.sc

$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

uniform vec4 u_params2;
#define u_depthValuePow u_params2.x

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：从 RG half float 解包 depth
    vec4 val = texture2D(s_shadowMap0, v_texcoord0);
    float depth = unpackHalfFloat(val.rg);
#else
    // RGBA 路径：从 RGBA8 解包 depth
    float depth = unpackRgbaToFloat(texture2D(s_shadowMap0, v_texcoord0));
#endif

    vec3 rgba = pow(vec3_splat(depth), vec3_splat(u_depthValuePow));
    gl_FragColor = vec4(rgba, 1.0);
}
"#

/**
 * HBlur pass 片段着色器 chunk（水平 9-tap Gaussian）。
 *
 * RGBA 路径：gl_FragColor = blur9(s_shadowMap0, ...)
 * VSM 路径：gl_FragColor = blur9VSM(s_shadowMap0, ...)
 *
 * 9 个采样点 UV 坐标由 vertex 端预计算，通过 varying 传入：
 *   v_texcoord0（中心）+ v_texcoord1..4（8 个偏移）
 */
public const shadow_hblur_fragment: String = #"
// HBlur pass 片段着色器（水平 9-tap Gaussian）
// 对照 16-shadowmaps: fs_shadowmaps_hblur.sc / fs_shadowmaps_hblur_vsm.sc

$input v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    // VSM 路径：blur9VSM 处理 depth + depth² 双通道
    gl_FragColor = blur9VSM(s_shadowMap0
                          , v_texcoord0
                          , v_texcoord1
                          , v_texcoord2
                          , v_texcoord3
                          , v_texcoord4
                          );
#else
    // RGBA 路径：blur9 处理单通道 depth
    gl_FragColor = blur9(s_shadowMap0
                       , v_texcoord0
                       , v_texcoord1
                       , v_texcoord2
                       , v_texcoord3
                       , v_texcoord4
                       );
#endif
}
"#

/**
 * VBlur pass 片段着色器 chunk（垂直 9-tap Gaussian）。
 *
 * 实现与 HBlur 完全一致（9-tap Gaussian），区别仅在于 vertex 端
 * UV 偏移方向（水平 vs 垂直）。
 */
public const shadow_vblur_fragment: String = #"
// VBlur pass 片段着色器（垂直 9-tap Gaussian）
// 对照 16-shadowmaps: fs_shadowmaps_vblur.sc / fs_shadowmaps_vblur_vsm.sc
//
// 实现与 HBlur 一致，区别仅在于 vertex 端 UV 偏移方向

$input v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

SAMPLER2D(s_shadowMap0, 4);

void main()
{
#if defined( SHADOWMAP_TYPE_VSM )
    gl_FragColor = blur9VSM(s_shadowMap0
                          , v_texcoord0
                          , v_texcoord1
                          , v_texcoord2
                          , v_texcoord3
                          , v_texcoord4
                          );
#else
    gl_FragColor = blur9(s_shadowMap0
                       , v_texcoord0
                       , v_texcoord1
                       , v_texcoord2
                       , v_texcoord3
                       , v_texcoord4
                       );
#endif
}
"#

/**
 * HBlur/VBlur pass 顶点着色器 chunk。
 *
 * 预计算 9 个采样点 UV 坐标，通过 varying 传入 fragment：
 *   v_texcoord0（中心）+ v_texcoord1..4（8 个偏移）
 *
 * HBlur: UV 偏移方向 = 水平（u 增减）
 * VBlur: UV 偏移方向 = 垂直（v 增减）
 *
 * 由编译期 #define HBLUR_PASS / VBLUR_PASS 切换偏移方向。
 */
public const shadow_blur_vertex: String = #"
// HBlur/VBlur pass 顶点着色器
// 对照 16-shadowmaps: vs_shadowmaps_hblur.sc / vs_shadowmaps_vblur.sc
//
// 预计算 9 个采样点 UV，通过 varying 传入 fragment
// 由 #define HBLUR_PASS / VBLUR_PASS 切换偏移方向

$input a_position, a_texcoord0

$output v_texcoord0, v_texcoord1, v_texcoord2, v_texcoord3, v_texcoord4

#include <bgfx_shader.sh>

uniform vec4 u_inverseTextureSize;

void main()
{
    vec2 texcoord = a_texcoord0;

    // 中心采样点
    v_texcoord0 = texcoord;

    // 8 个偏移采样点（4 对对称偏移）
    // u_inverseTextureSize.xy = 1/width, 1/height（纹理尺寸倒数）
    vec2 invTexSize = u_inverseTextureSize.xy;

#if defined( HBLUR_PASS )
    // 水平模糊：UV 偏移方向 = u（水平）
    vec2 offset = vec2(invTexSize.x, 0.0);
#elif defined( VBLUR_PASS )
    // 垂直模糊：UV 偏移方向 = v（垂直）
    vec2 offset = vec2(0.0, invTexSize.y);
#else
    // 兜底：默认水平模糊
    vec2 offset = vec2(invTexSize.x, 0.0);
#endif

    // 9-tap Gaussian 偏移（权重 1.0, 0.9, 0.55, 0.18, 0.1）
    // 对照 blur9 的采样模式
    v_texcoord1 = vec4(texcoord + offset * 1.0, texcoord - offset * 1.0);
    v_texcoord2 = vec4(texcoord + offset * 2.0, texcoord - offset * 2.0);
    v_texcoord3 = vec4(texcoord + offset * 3.0, texcoord - offset * 3.0);
    v_texcoord4 = vec4(texcoord + offset * 4.0, texcoord - offset * 4.0);

    // 全屏四边形：a_position 已是 NDC 坐标
    gl_Position = vec4(a_position, 0.0, 1.0);
}
"#
