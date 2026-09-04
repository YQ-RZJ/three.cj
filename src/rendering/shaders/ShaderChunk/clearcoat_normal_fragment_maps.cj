/**
 * @file[zh-cn] clearcoat_normal_fragment_maps  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: clearcoat_normal_fragment_maps
 *
 * @file[en] clearcoat_normal_fragment_maps  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: clearcoat_normal_fragment_maps
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * clearcoat_normal_fragment_maps GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const clearcoat_normal_fragment_maps: String = #"
#ifdef USE_CLEARCOAT_NORMALMAP

	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;

	clearcoatNormal = normalize( tbn2 * clearcoatMapN );

#endif
"#
