/**
 * @file[zh-cn] shadowmap_pars_vertex  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: shadowmap_pars_vertex
 *
 * @file[en] shadowmap_pars_vertex  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: shadowmap_pars_vertex
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * shadowmap_pars_vertex GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const shadowmap_pars_vertex: String = #"

#if NUM_SPOT_LIGHT_COORDS > 0

	// bgfx4cj: spot 阴影矩阵数组化（对齐 Three.js mat4 spotLightMatrix[NUM_SPOT_LIGHT_COORDS]），
	// 每个带阴影的 spot 光源一份 bias × lightViewProj。
	// varying vSpotLightCoord[] 由 ShaderLibs.cj 头部 $output/$input 声明（bgfx 不支持 chunk 内 varying 关键字）
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];

#endif

#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

	  // bgfx4cj: 数组化 directionalShadowMatrix[NUM_DIR_LIGHT_SHADOWS]
	  // varying vDirectionalShadowCoord[] 由 ShaderLibs.cj 头部 $output/$input 声明
	  uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];

	#endif

	// bgfx4cj: shadowParams 全局参数，所有阴影类型共用（同 shadowmap_pars_fragment.cj 的处理）
	uniform vec4 shadowParams;  // x=intensity, y=bias, z=normalBias, w=radius

	#if NUM_DIR_LIGHT_SHADOWS > 0

	  // per-light bias/normalBias（vertex 端法线偏移 shadowWorldPosition 用，同 fragment 段声明）
	  uniform vec4 u_dirShadowParams[ NUM_DIR_LIGHT_SHADOWS ];  // x=bias, y=normalBias

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

	  // per-light bias/normalBias（聚光 vertex 法线偏移用）
	  uniform vec4 u_spotShadowParams[ NUM_SPOT_LIGHT_SHADOWS ];  // x=bias, y=normalBias

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

		// bgfx4cj: spot 阴影矩阵声明在 NUM_SPOT_LIGHT_COORDS > 0 域（见上方），此处保留占位以对齐 three.js 原结构

	#endif



	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): uniforms for area light shadows
		// Ignore: JS 原文 TODO（area light shadows），属 three.js 上游未实现项。

	#endif
	*/

#endif
"#
