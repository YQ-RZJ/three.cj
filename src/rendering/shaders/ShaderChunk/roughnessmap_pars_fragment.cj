/**
 * @file[zh-cn] roughnessmap_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: roughnessmap_pars_fragment
 *
 * @file[en] roughnessmap_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: roughnessmap_pars_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * roughnessmap_pars_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const roughnessmap_pars_fragment: String = #"
#ifdef USE_ROUGHNESSMAP

	// 必须用 SAMPLER2D 宏而非裸 uniform sampler2D：HLSL 分支下
	// bgfx_shader.sh 定义 #define sampler2D BgfxSampler2D，裸声明会被替换成 struct，
	// bgfx 无法按名绑定 sampler uniform → 贴图采样不生效。
	SAMPLER2D(roughnessMap, __STAGE_ROUGHNESS_MAP__);

#endif
"#
