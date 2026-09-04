/**
 * @file[zh-cn] shadowmap_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: shadowmap_fragment
 *
 * @file[en] shadowmap_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: shadowmap_fragment
 * （较新版本中 shadowmap 的片段着色器逻辑已合并到 lights_fragment_begin 和
 * shadowmask_pars_fragment 中，本 chunk 保留作为独立的阴影遮罩合成入口。）
 * 在主渲染 Pass 中，本片段在所有光照计算之后被包含，用 getShadowMask()
 * 累乘所有投射阴影的光源对当前像素的遮挡贡献，然后将漫反射与镜面反射光照
 * 结果乘以阴影因子，实现阴影效果。
 * 在 bgfx4cj 渲染后端中，阴影遮罩的计算已集成到 lights_fragment_begin 的
 * 各光源循环内部（directLight.color *= getShadow(...)），
 * 本 chunk 作为最终阴影因子累乘的安全兜底。
 */
package three.rendering.shaders.ShaderChunk

/**
 * shadowmap_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const shadowmap_fragment: String = #"
// shadowmap_fragment：占位 chunk
// 主光路的阴影乘法已由 lights_fragment_begin.cj 在各光源循环内完成：
//   directLight.color *= ... getShadow(...) ...
// 本 chunk 仅保留为 ShaderLib 拼接接口的占位符。
// getShadowMask()（见 shadowmask_pars_fragment.cj）专供 MeshShadowMaterial 等仅显示阴影的材质使用。
"#
