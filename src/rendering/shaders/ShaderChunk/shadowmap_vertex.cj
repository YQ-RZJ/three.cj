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
 * @file[zh-cn] shadowmap_vertex  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: shadowmap_vertex
 *
 * @file[en] shadowmap_vertex  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: shadowmap_vertex
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * shadowmap_vertex GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const shadowmap_vertex: String = #"

#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )

	#ifdef HAS_NORMAL

		// Offsetting the position used for querying occlusion along the world normal can be used to reduce shadow acne.

		vec3 shadowWorldNormal = transformNormalByInverseViewMatrix( transformedNormal, viewMatrix );

	#else

		vec3 shadowWorldNormal = vec3(0.0, 0.0, 0.0); // fallback, see #21483

	#endif

	vec4 shadowWorldPosition;

#endif

#if defined( USE_SHADOWMAP )

  #if NUM_DIR_LIGHT_SHADOWS > 0

   // bgfx4cj: 方向光阴影坐标（varying 单实例，用 directionalShadowMatrix 数组的第 0 个矩阵）。
   // normalBias 用 per-light 数组 u_dirShadowParams[0].y（对齐 three.js：每光源独立 shadowNormalBias）。
   // 法线偏移沿世界法线方向，棱线处相邻面自然连续，不产生接缝缝隙（depth bias 才造成接缝）。
   shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * u_dirShadowParams[0].y, 0 );
   vDirectionalShadowCoord = mul(directionalShadowMatrix[0], shadowWorldPosition);

  #endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update vAreaShadowCoord with area light info
		// Ignore: JS 原文 TODO（area light shadow coord），属 three.js 上游未实现项。

	#endif
	*/

#endif

// spot lights can be evaluated without active shadow mapping (when SpotLight.map is used)

#if NUM_SPOT_LIGHT_COORDS > 0

 // bgfx4cj: spot 阴影坐标（varying 单实例，用 spotLightMatrix 数组的第 0 个矩阵）。
 shadowWorldPosition = worldPosition;
 #if defined( USE_SHADOWMAP )
  shadowWorldPosition.xyz += shadowWorldNormal * u_spotShadowParams[0].y;
 #endif
 vSpotLightCoord = mul ( spotLightMatrix[0] , shadowWorldPosition );

#endif
"#
