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
 * @file[zh-cn] envmap_physical_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: envmap_physical_pars_fragment
 * @explain[zh-cn] 基于 PMREM（CubeUV）环境贴图的 IBL 光照明：
 *         getIBLIrradiance 提供漫反射辐照度（roughness=1 采样最模糊层级 ×PI），
 *         getIBLRadiance 提供镜面反射辐射度（按材质 roughness 选择 CubeUV 层级）。
 *         sampler 名 u_envMap 与强度 u_envMapIntensity 由 envmap_common_pars_fragment 声明。
 *
 * @file[en] envmap_physical_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: envmap_physical_pars_fragment
 * @explain[en] PMREM (CubeUV) environment-map based IBL:
 *         getIBLIrradiance returns diffuse irradiance (roughness=1 sampled from the blurriest level, x PI),
 *         getIBLRadiance returns specular radiance (CubeUV level selected by material roughness).
 *         The sampler u_envMap and intensity u_envMapIntensity are declared in envmap_common_pars_fragment.
 */
package three.rendering.shaders.ShaderChunk

/**
 * envmap_physical_pars_fragment GLSL 片段字符串
 *
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const envmap_physical_pars_fragment: String = #"
#ifdef USE_ENVMAP

	vec3 getIBLIrradiance( const in vec3 normal ) {

		#ifdef ENVMAP_TYPE_CUBE_UV

			// ★本引擎约定：vNormal 已是世界空间（u_normalMatrix = 物体世界矩阵 3x3，
			// 光源 uniform 也是世界空间），故直接用世界法线采样环境贴图，不可再做
			// 逆视图变换（否则会随相机旋转而错位，反射与天空盒对不上）。
			vec3 envMapColor = textureCubeUV( normal, 1.0 );

			return PI * envMapColor * u_envMapIntensity.x;

		#else

			return vec3( 0.0, 0.0, 0.0 );

		#endif

	}

	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {

		#ifdef ENVMAP_TYPE_CUBE_UV

			// ★本引擎约定：geometryNormal 与 geometryViewDir 均为世界空间
			// （见 lights_fragment_begin：geometryViewDir = normalize(u_cameraPos - v_worldPos)，
			//   法线由 u_normalMatrix（世界模型矩阵）变换得到），环境贴图也在世界空间，
			//   故直接求反射方向，绝不可再做视图空间↔世界空间变换。
			vec3 reflectVec = reflect( - viewDir, normal );

			// Mixing the reflection with the normal is more accurate and keeps rough objects from gathering light from behind their tangent plane.
			reflectVec = normalize( mix( reflectVec, normal, pow4( roughness ) ) );

			vec3 envMapColor = textureCubeUV( reflectVec, roughness );

			return envMapColor * u_envMapIntensity.x;

		#else

			return vec3( 0.0, 0.0, 0.0 );

		#endif

	}

	#ifdef USE_ANISOTROPY

		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {

			#ifdef ENVMAP_TYPE_CUBE_UV

				// https://google.github.io/filament/Filament.md.html#lighting/imagebasedlights/anisotropy
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );

				return getIBLRadiance( viewDir, bentNormal, roughness );

			#else

				return vec3( 0.0, 0.0, 0.0 );

			#endif

		}

	#endif

#endif
"#
