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
 * @file[zh-cn] shadowmask_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: shadowmask_pars_fragment
 *
 * @file[en] shadowmask_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: shadowmask_pars_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * shadowmask_pars_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const shadowmask_pars_fragment: String = #"
float getShadowMask() {

	float shadow = 1.0;

	#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

	// bgfx4cj: 数组化方向光阴影，按光源下标逐个累乘。
	#if NUM_DIR_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[0], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[0].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[1], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[1].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[2], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[2].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif
	#if NUM_DIR_LIGHT_SHADOWS >= 4
	shadow *= receiveShadow.x > 0.5 ? getShadow( directionalShadowMap[3], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[3].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
	#endif

	#endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

	// bgfx4cj: 数组化聚光灯阴影，按光源下标逐个累乘。
	#if NUM_SPOT_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[0], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[0].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[1], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[1].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[2], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[2].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS >= 4
	shadow *= receiveShadow.x > 0.5 ? getShadow( spotShadowMap[3], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[3].x, shadowParams.w, vSpotLightCoord ) : 1.0;
	#endif

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0 && ( defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_BASIC ) )

	// bgfx4cj: 数组化点光源 cube 阴影，按光源下标逐个累乘。
	#if NUM_POINT_LIGHT_SHADOWS >= 1
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[0], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[0].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[0].xyz, 1.0 ), u_pointShadowNearFar[0].x, u_pointShadowNearFar[0].y ) : 1.0;
	#endif
	#if NUM_POINT_LIGHT_SHADOWS >= 2
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[1], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[1].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[1].xyz, 1.0 ), u_pointShadowNearFar[1].x, u_pointShadowNearFar[1].y ) : 1.0;
	#endif
	#if NUM_POINT_LIGHT_SHADOWS >= 3
	shadow *= receiveShadow.x > 0.5 ? getPointShadow( pointShadowMap[2], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[2].x, shadowParams.w, vec4( v_worldPos - u_pointShadowLightPos[2].xyz, 1.0 ), u_pointShadowNearFar[2].x, u_pointShadowNearFar[2].y ) : 1.0;
	#endif

	#endif

	/*
	#if NUM_RECT_AREA_LIGHTS > 0

		// TODO (abelnation): update shadow for Area light
		// Ignore: JS 原文 TODO（area light shadow），属 three.js 上游未实现项。

	#endif
	*/

	#endif

	return shadow;

}
"#
