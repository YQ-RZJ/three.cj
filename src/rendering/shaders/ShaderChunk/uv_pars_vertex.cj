/**
 * @file[zh-cn] uv_pars_vertex  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: uv_pars_vertex
 *
 * @file[en] uv_pars_vertex  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: uv_pars_vertex
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * uv_pars_vertex GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const uv_pars_vertex: String = #"
#ifdef USE_MAP

	uniform mat3 mapTransform;

#endif
#ifdef USE_ALPHAMAP

	uniform mat3 alphaMapTransform;

#endif
#ifdef USE_LIGHTMAP

	uniform mat3 lightMapTransform;

#endif
#ifdef USE_AOMAP

	uniform mat3 aoMapTransform;

#endif
#ifdef USE_BUMPMAP

	uniform mat3 bumpMapTransform;

#endif
#ifdef USE_NORMALMAP

	uniform mat3 normalMapTransform;

#endif
#ifdef USE_DISPLACEMENTMAP

	uniform mat3 displacementMapTransform;

#endif
#ifdef USE_EMISSIVEMAP

	uniform mat3 emissiveMapTransform;

#endif
#ifdef USE_METALNESSMAP

	uniform mat3 metalnessMapTransform;

#endif
#ifdef USE_ROUGHNESSMAP

	uniform mat3 roughnessMapTransform;

#endif
#ifdef USE_ANISOTROPYMAP

	uniform mat3 anisotropyMapTransform;

#endif
#ifdef USE_CLEARCOATMAP

	uniform mat3 clearcoatMapTransform;

#endif
#ifdef USE_CLEARCOAT_NORMALMAP

	uniform mat3 clearcoatNormalMapTransform;

#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP

	uniform mat3 clearcoatRoughnessMapTransform;

#endif
#ifdef USE_SHEEN_COLORMAP

	uniform mat3 sheenColorMapTransform;

#endif
#ifdef USE_SHEEN_ROUGHNESSMAP

	uniform mat3 sheenRoughnessMapTransform;

#endif
#ifdef USE_IRIDESCENCEMAP

	uniform mat3 iridescenceMapTransform;

#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP

	uniform mat3 iridescenceThicknessMapTransform;

#endif
#ifdef USE_SPECULARMAP

	uniform mat3 specularMapTransform;

#endif
#ifdef USE_SPECULAR_COLORMAP

	uniform mat3 specularColorMapTransform;

#endif
#ifdef USE_SPECULAR_INTENSITYMAP

	uniform mat3 specularIntensityMapTransform;

#endif
#ifdef USE_TRANSMISSIONMAP

	uniform mat3 transmissionMapTransform;

#endif
#ifdef USE_THICKNESSMAP

	uniform mat3 thicknessMapTransform;

#endif
"#
