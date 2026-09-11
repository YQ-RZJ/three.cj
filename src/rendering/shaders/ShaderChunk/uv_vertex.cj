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
 * @file[zh-cn] uv_vertex  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: uv_vertex
 *
 * @file[en] uv_vertex  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: uv_vertex
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * uv_vertex GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const uv_vertex: String = #"
#if defined( USE_UV ) || defined( USE_ANISOTROPY )

	vUv = vec3( uv, 1 ).xy;

#endif
#ifdef USE_MAP

	// 对照 three.js uv_vertex：vMapUv = (mapTransform * vec3(uv,1)).xy。
	// bgfx4cj 修复：默认 mapTransform 为单位矩阵（无 offset/repeat/rotation 时），
	// 直接 vMapUv = MAP_UV 等价且规避 Mat3 uniform 在 HLSL 转译下可能未生效
	// （0 矩阵 → v_mapUv 恒 0 → 采样 (0,0) → 纹理显示为左上角单像素颜色）。
	vMapUv = MAP_UV;

#endif
#ifdef USE_ALPHAMAP

	vAlphaMapUv = mul( alphaMapTransform, vec3( ALPHAMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_LIGHTMAP

	vLightMapUv = mul( lightMapTransform, vec3( LIGHTMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_AOMAP

	vAoMapUv = mul( aoMapTransform, vec3( AOMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_BUMPMAP

	vBumpMapUv = mul( bumpMapTransform, vec3( BUMPMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_NORMALMAP

	vNormalMapUv = mul( normalMapTransform, vec3( NORMALMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_DISPLACEMENTMAP

	vDisplacementMapUv = mul( displacementMapTransform, vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_EMISSIVEMAP

	vEmissiveMapUv = mul( emissiveMapTransform, vec3( EMISSIVEMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_METALNESSMAP

	vMetalnessMapUv = mul( metalnessMapTransform, vec3( METALNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_ROUGHNESSMAP

	vRoughnessMapUv = mul( roughnessMapTransform, vec3( ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_ANISOTROPYMAP

	vAnisotropyMapUv = mul( anisotropyMapTransform, vec3( ANISOTROPYMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOATMAP

	vClearcoatMapUv = mul( clearcoatMapTransform, vec3( CLEARCOATMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOAT_NORMALMAP

	vClearcoatNormalMapUv = mul( clearcoatNormalMapTransform, vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP

	vClearcoatRoughnessMapUv = mul( clearcoatRoughnessMapTransform, vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_IRIDESCENCEMAP

	vIridescenceMapUv = mul( iridescenceMapTransform, vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP

	vIridescenceThicknessMapUv = mul( iridescenceThicknessMapTransform, vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SHEEN_COLORMAP

	vSheenColorMapUv = mul( sheenColorMapTransform, vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SHEEN_ROUGHNESSMAP

	vSheenRoughnessMapUv = mul( sheenRoughnessMapTransform, vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULARMAP

	vSpecularMapUv = mul( specularMapTransform, vec3( SPECULARMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULAR_COLORMAP

	vSpecularColorMapUv = mul( specularColorMapTransform, vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_SPECULAR_INTENSITYMAP

	vSpecularIntensityMapUv = mul( specularIntensityMapTransform, vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_TRANSMISSIONMAP

	vTransmissionMapUv = mul( transmissionMapTransform, vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;

#endif
#ifdef USE_THICKNESSMAP

	vThicknessMapUv = mul( thicknessMapTransform, vec3( THICKNESSMAP_UV, 1 ) ).xy;

#endif
"#
