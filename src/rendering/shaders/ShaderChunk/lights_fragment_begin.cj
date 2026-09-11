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
 * @file[zh-cn] lights_fragment_begin  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: lights_fragment_begin
 *
 * @file[en] lights_fragment_begin  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: lights_fragment_begin
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * lights_fragment_begin GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const lights_fragment_begin: String = #"
/**
 * This is a template that can be used to light a material, it uses pluggable
 * RenderEquations (RE)for specific lighting scenarios.
 *
 * Instructions for use:
 * - Ensure that both RE_Direct, RE_IndirectDiffuse and RE_IndirectSpecular are defined
 * - Create a material parameter that is to be passed as the third parameter to your lighting functions.
 *
 * TODO:
 * Ignore: JS 原文 TODO（area light / sphere light / diffuse light probe 支持），属 three.js 上游未实现项。
 * - Add area light support.
 * - Add sphere light support.
 * - Add diffuse light probe (irradiance cubemap) support.
 */

// bgfx4cj: 使用世界空间坐标（v_worldPos）替代 Three.js 的视图空间（-vViewPosition）
// 因为渲染器传递的光源数据是世界空间坐标，而非视图空间
vec3 geometryPosition = v_worldPos;
vec3 geometryNormal = v_normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( u_cameraPos.xyz - v_worldPos );

vec3 geometryClearcoatNormal = vec3(0.0, 0.0, 0.0);

#ifdef USE_CLEARCOAT

	geometryClearcoatNormal = clearcoatNormal;

#endif

#ifdef USE_IRIDESCENCE

	float dotNVi = saturate( dot( v_normal, geometryViewDir ) );

	if ( material.iridescenceThickness == 0.0 ) {

		material.iridescence = 0.0;

	} else {

		material.iridescence = saturate( material.iridescence );

	}

	if ( material.iridescence > 0.0 ) {

		vec3 iridescenceFresnelDielectric = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		vec3 iridescenceFresnelMetallic = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.diffuseColor );

		material.iridescenceFresnel = mix( iridescenceFresnelDielectric, iridescenceFresnelMetallic, material.metalness );

		// Iridescence F0 approximation
		material.iridescenceF0Dielectric = Schlick_to_F0( iridescenceFresnelDielectric, 1.0, dotNVi );
		material.iridescenceF0Metallic = Schlick_to_F0( iridescenceFresnelMetallic, 1.0, dotNVi );

	}

#endif

#if defined( STANDARD ) && ( NUM_DIR_LIGHTS > 0 || NUM_POINT_LIGHTS > 0 || NUM_SPOT_LIGHTS > 0 )

	// Multi-scattering energy compensation for direct lighting
	// Based on "Practical Multiple Scattering Compensation for Microfacet Models"
	// https://blog.selfshadow.com/publications/turquin/ms_comp_final.pdf
	float dotNVms = saturate( dot( geometryNormal, geometryViewDir ) );

	vec2 fabMs = texture2D( dfgLUT, vec2( material.roughness, dotNVms ) ).rg;

	// Energy of the single-scattering lobe in a white furnace ( F0 = F90 = 1 )
	float EssMs = fabMs.x + fabMs.y;

	// bgfx4cj: dfgLUT 采样可能因格式/平台差异返回 0，导致 1.0/0 无穷 → 高光爆炸（向光面全白）。
	// 保护最小值：若 EssMs 接近 0 则用 1.0（无补偿），避免除零。
	if (EssMs < 0.001) { EssMs = 1.0; }

	// Compensate for the energy lost to multiple scattering, tinting the added term by F0 ( equation 16 )
	// 注意：此处依赖 dfgLUT 采样（1.0/EssMs），dfgLUT 必须用 RG16F 格式正确绑定
	// （BgfxBackend._bindSceneTextures），否则 EssMs=0 → 1/0 无穷 → 高光爆炸。
	material.multiScatteringCompensation = 1.0 + material.specularColorBlended * ( 1.0 / EssMs - 1.0 );

#endif

IncidentLight directLight;

#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )

	PointLight pointLight;

	// bgfx4cj: 点光源循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc：
	// for(int ii = 0; ii < MAX_NUM_LIGHTS; ++ii) { ... u_lightPosRadius[ii] ... }）。
	// 循环上界 = NUM_POINT_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_pointPosition/u_pointColor/u_pointParams（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_POINT_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_POINT_LIGHTS_MAX; i ++ ) {

		pointLight.position = u_pointPosition[ i ].xyz;
		pointLight.color = u_pointColor[ i ].rgb * u_pointColor[ i ].a;
		pointLight.distance = u_pointPosition[ i ].w;
		pointLight.decay = u_pointParams[ i ].x;

		getPointLightInfo( pointLight, geometryPosition, directLight );

		#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
		if ( i < NUM_POINT_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getPointShadow( pointShadowMap[i], shadowMapSize.xy, shadowParams.x, u_pointShadowParams[i].x, shadowParams.w, vec4( geometryPosition - u_pointShadowLightPos[i].xyz, 1.0 ), u_pointShadowNearFar[i].x, u_pointShadowNearFar[i].y ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )

	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;

	// bgfx4cj: 聚光灯循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc）。
	// 循环上界 = NUM_SPOT_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_spotPosition/u_spotColor/u_spotDirection/u_spotParams（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_SPOT_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_SPOT_LIGHTS_MAX; i ++ ) {

		spotLight.position = u_spotPosition[ i ].xyz;
		spotLight.direction = u_spotDirection[ i ].xyz;
		spotLight.color = u_spotColor[ i ].rgb * u_spotColor[ i ].a;
		spotLight.distance = u_spotPosition[ i ].w;
		spotLight.decay = u_spotParams[ i ].z;
		spotLight.coneCos = u_spotDirection[ i ].w;
		spotLight.penumbraCos = u_spotParams[ i ].w;

		getSpotLightInfo( spotLight, geometryPosition, directLight );

		#if ( NUM_SPOT_LIGHT_MAPS > 0 )
		// bgfx4cj: spotLightMap 数组按光源顺序，动态下标访问（当前 NUM_SPOT_LIGHT_MAPS=0 时整段裁剪）
		if ( i < NUM_SPOT_LIGHT_MAPS )
		{
			spotLightCoord = vSpotLightCoord.xyz / vSpotLightCoord.w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3_splat(1.0) ) );
			spotColor = texture2D( spotLightMap[ i ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		}
		#endif

		#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
		if ( i < NUM_SPOT_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getShadow( spotShadowMap[i], shadowMapSize.xy, shadowParams.x, u_spotShadowParams[i].x, shadowParams.w, vSpotLightCoord ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )

	DirectionalLight directionalLight;

	// bgfx4cj: 方向光循环用 for + 动态下标（对照官方 13-stencil fs_stencil_color_lighting.sc）。
	// 循环上界 = NUM_DIR_LIGHTS_MAX（配置上限宏），动态下标访问数组 uniform
	// u_lightDir/u_lightColor（渲染器侧通过数组 uniform 传递）。
	// 实际数量由 NUM_DIR_LIGHTS 宏裁剪（渲染器已将多余槽位填 0，颜色×0 无贡献）。
	for ( int i = 0; i < NUM_DIR_LIGHTS_MAX; i ++ ) {

		directionalLight.direction = u_lightDir[ i ].xyz;
		directionalLight.color = u_lightColor[ i ].rgb * u_lightColor[ i ].a;

		getDirectionalLightInfo( directionalLight, directLight );

		#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
		if ( i < NUM_DIR_LIGHT_SHADOWS )
		{
			directLight.color *= ( directLight.visible && receiveShadow.x > 0.5 ) ? getShadow( directionalShadowMap[i], shadowMapSize.xy, shadowParams.x, u_dirShadowParams[i].x, shadowParams.w, vDirectionalShadowCoord ) : 1.0;
		}
		#endif

		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )

	RectAreaLight rectAreaLight;

	UNROLL
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {

		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );

	}
	

#endif

#if defined( RE_IndirectDiffuse )

	vec3 iblIrradiance = vec3(0.0, 0.0, 0.0);

	vec3 irradiance = getAmbientLightIrradiance( u_ambientColor.xyz );

	#if defined( USE_LIGHT_PROBES )

		// bgfx4cj: LightProbe 的 SH3 系数由渲染器绑定为 shCoefficients（vec4[9] 数组 uniform），
		// 消费走 bgfx_pbr_pars 的 getShIrradianceAt（读 shCoefficients），
		// 而非 JS 原文的 lightProbe（vec3[9]，bgfx 后端未绑定该 uniform）。
		// getShIrradianceAt 仅随 bgfx_pbr_pars 注入 standard/physical 着色器，故用 STANDARD 守卫。
		#if defined( STANDARD )

			irradiance += getShIrradianceAt( geometryNormal );

		#else

			irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );

		#endif

	#endif

	#if ( NUM_HEMI_LIGHTS > 0 )

		// bgfx4cj: 半球光循环用 for + 动态下标（对照点光/聚光/方向光改造）。
		// JS 原文用 struct 数组 uniform `hemisphereLights[NUM_HEMI_LIGHTS]`（未迁移），
		// bgfx 后端改为独立数组 uniform u_hemiSkyColor/u_hemiGroundColor/u_hemiDirection
		// （渲染器 BgfxLightBinder 按数组绑定），此处逐槽位构造 struct 再求辐照度。
		UNROLL
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {

			HemisphereLight hemiLight;
			hemiLight.direction = u_hemiDirection[ i ].xyz;
			hemiLight.skyColor = u_hemiSkyColor[ i ].rgb;
			hemiLight.groundColor = u_hemiGroundColor[ i ].rgb;

			irradiance += getHemisphereLightIrradiance( hemiLight, geometryNormal );

		}
		

	#endif

	#ifdef USE_LIGHT_PROBES_GRID

		vec3 probeWorldPos = ( ( vec4( geometryPosition, 1.0 ) - viewMatrix[ 3 ] ) * viewMatrix ).xyz;
		vec3 probeWorldNormal = transformNormalByInverseViewMatrix( geometryNormal, viewMatrix );
		irradiance += getLightProbeGridIrradiance( probeWorldPos, probeWorldNormal );

	#endif

#endif

#if defined( RE_IndirectSpecular )

	vec3 radiance = vec3(0.0, 0.0, 0.0);
	vec3 clearcoatRadiance = vec3(0.0, 0.0, 0.0);

#endif
"#
