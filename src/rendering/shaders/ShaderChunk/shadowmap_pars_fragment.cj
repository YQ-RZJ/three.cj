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
 * @file[zh-cn] shadowmap_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: shadowmap_pars_fragment
 *
 * @file[en] shadowmap_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: shadowmap_pars_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * shadowmap_pars_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const shadowmap_pars_fragment: String = #"
#if NUM_SPOT_LIGHT_MAPS > 0

	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];

#endif

#ifdef USE_SHADOWMAP

	#if NUM_DIR_LIGHT_SHADOWS > 0

		// bgfx4cj: 数组化方向光阴影 sampler（对齐 Three.js directionalShadowMap[NUM_DIR_LIGHT_SHADOWS]）
		// bgfx 数组 sampler 通过 setTexture(stage+i, uniform, tex) 逐个绑定连续寄存器
		// ★类型按 SHADOWMAP_TYPE 区分（对照参考版 SAMPLER2DSHADOW/SAMPLER2D 分支）：
		//   - PCF：sampler2DShadow（shadow2D 硬件比较采样）
		//   - VSM/BASIC：sampler2D（texture2D 普通采样读 .rg mean/variance / .r 深度）
		// 类型不匹配会导致 VSM 变体 texture2D 采样比较采样器 → 采样结果错误 → 波浪纹/噪点
		#if defined( SHADOWMAP_TYPE_PCF )
		uniform sampler2DShadow directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#else
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		#endif

	#endif

 // bgfx4cj: shadowParams/shadowMapSize 全局参数，所有阴影类型（方向光/点光源/聚光）共用，
 // 声明在所有 #if NUM_XXX_LIGHT_SHADOWS 之外，确保任何类型启用阴影时均可访问。
 uniform vec4 shadowParams;   // x=intensity, y=bias(保留备用), z=normalBias(保留备用), w=radius
 uniform vec4 shadowMapSize;  // x=width, y=height
 // per-light 独立 bias/normalBias（对齐 three.js：每个 light.shadow.bias/normalBias 独立）：
 // 方向光/聚光阴影沿投影深度方向偏移，过大 bias 导致盒子内壁棱线处阴影错位（接缝缝隙），
 // 抗 acne 主要靠 normalBias（沿世界法线偏移 shadowWorldPosition，棱线处连续，不产生接缝）；
 // 点光源自阴影（acne）在 fragment 端 dp += bias，需要更大负 bias。
 // 类型必须为 vec4：bgfx UniformType 无 Float 类型，C++ 端按 Vec4 绑定（x/y 分量生效）。
 #if NUM_DIR_LIGHT_SHADOWS > 0
 uniform vec4 u_dirShadowParams[ NUM_DIR_LIGHT_SHADOWS ];    // x=bias, y=normalBias（方向光）
 #endif
 #if NUM_SPOT_LIGHT_SHADOWS > 0
 uniform vec4 u_spotShadowParams[ NUM_SPOT_LIGHT_SHADOWS ];  // x=bias, y=normalBias（聚光）
 #endif
 #if NUM_POINT_LIGHT_SHADOWS > 0
 uniform vec4 u_pointShadowParams[ NUM_POINT_LIGHT_SHADOWS ]; // x=bias（点光源）
 #endif

	#if NUM_SPOT_LIGHT_SHADOWS > 0

		// bgfx4cj: 数组化聚光灯阴影 sampler（对齐 Three.js spotShadowMap[NUM_SPOT_LIGHT_SHADOWS]）
		uniform sampler2DShadow spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];

		// bgfx4cj: spot 阴影暂用 shadowParams/shadowMapSize 全局参数

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0

	 // bgfx4cj: 数组化点光源阴影 cube sampler（对齐 Three.js pointShadowMap[NUM_POINT_LIGHT_SHADOWS]）
	 uniform samplerCubeShadow pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];

		// bgfx4cj: point 阴影采样的光源世界坐标数组（fragment 端算 worldPos - lightPos[i] 用）
		// 声明在 fragment 段，因 getPointShadow 调用在 fragment 段，uniform 跨段不可见
		uniform vec4 u_pointShadowLightPos[ NUM_POINT_LIGHT_SHADOWS ];
		// bgfx4cj: point 阴影相机的 near/far 数组（bgfx 无 Vec2 uniform，用 Vec4 打包，xy=near/far）
		uniform vec4 u_pointShadowNearFar[ NUM_POINT_LIGHT_SHADOWS ];

		// bgfx4cj: point 阴影暂用 shadowParams/shadowMapSize 全局参数

	#endif

	#if defined( SHADOWMAP_TYPE_PCF )

		// Interleaved Gradient Noise for randomizing sampling patterns
		float interleavedGradientNoise( vec2 position ) {

			return fract( 52.9829189 * fract( dot( position, vec2( 0.06711056, 0.00583715 ) ) ) );

		}

		// Vogel disk sampling for uniform circular distribution
		vec2 vogelDiskSample( int sampleIndex, int samplesCount, float phi ) {

			const float goldenAngle = 2.399963229728653;
			float r = sqrt( ( float( sampleIndex ) + 0.5 ) / float( samplesCount ) );
			float theta = float( sampleIndex ) * goldenAngle + phi;
			return vec2( cos( theta ), sin( theta ) ) * r;

		}

	#endif

	#if defined( SHADOWMAP_TYPE_PCF )

		float getShadow( sampler2DShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;
			shadowCoord.z += shadowBias;

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				// Hardware PCF with LinearFilter gives us 4-tap filtering per sample
				// 5 samples using Vogel disk + IGN = effectively 20 filtered taps with better distribution
				vec2 texelSize = vec2( 1.0,1.0 ) / shadowMapSize;
				float radius = shadowRadius * texelSize.x;

				// Use IGN to rotate sampling pattern per pixel.
				// bgfx4cj: 用 shadowCoord.xy 替代 gl_FragCoord.xy（bgfx HLSL 路径未声明 gl_FragCoord），
				// 二者均为 per-pixel 唯一的 vec2 种子，对 IGN 旋转效果等价。
				float phi = interleavedGradientNoise( shadowCoord.xy ) * PI2;

				shadow = (
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 0, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 1, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 2, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 3, 5, phi ) * radius, shadowCoord.z ) ) +
					shadow2D( shadowMap, vec3( shadowCoord.xy + vogelDiskSample( 4, 5, phi ) * radius, shadowCoord.z ) )
				) * 0.2;

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#elif defined( SHADOWMAP_TYPE_VSM )

		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;

			#ifdef USE_REVERSED_DEPTH_BUFFER

				shadowCoord.z -= shadowBias;

			#else

				shadowCoord.z += shadowBias;

			#endif

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				vec2 distribution = texture2D( shadowMap, shadowCoord.xy ).rg;

				float mean = distribution.x;
				float variance = distribution.y * distribution.y;

				#ifdef USE_REVERSED_DEPTH_BUFFER

					float hard_shadow = step( mean, shadowCoord.z );

				#else

					float hard_shadow = step( shadowCoord.z, mean );

				#endif
				
				// Early return if fully lit
				if ( hard_shadow == 1.0 ) {

					shadow = 1.0;

				} else {

					// Variance must be non-zero to avoid division by zero
					variance = max( variance, 0.0000001 );

					// Distance from mean
					float d = shadowCoord.z - mean;

					// Chebyshev's inequality for upper bound on probability
					float p_max = variance / ( variance + d * d );

					// Reduce light bleeding by remapping [amount, 1] to [0, 1]
					p_max = clamp( ( p_max - 0.3 ) / 0.65, 0.0, 1.0 );

					shadow = max( hard_shadow, p_max );

				}

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#else // SHADOWMAP_TYPE_BASIC

		float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord ) {

			float shadow = 1.0;

			shadowCoord.xyz /= shadowCoord.w;

			#ifdef USE_REVERSED_DEPTH_BUFFER

				shadowCoord.z -= shadowBias;

			#else

				shadowCoord.z += shadowBias;

			#endif

			bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
			bool frustumTest = inFrustum && shadowCoord.z <= 1.0;

			if ( frustumTest ) {

				float depth = texture2D( shadowMap, shadowCoord.xy ).r;

				#ifdef USE_REVERSED_DEPTH_BUFFER

					shadow = step( depth, shadowCoord.z );

				#else

					shadow = step( shadowCoord.z, depth );

				#endif

			}

			return mix( 1.0, shadow, shadowIntensity );

		}

	#endif

	#if NUM_POINT_LIGHT_SHADOWS > 0

	 #if defined( SHADOWMAP_TYPE_PCF )


	 // bgfx4cj: 使用 shadowCube 硬件比较（shadowCoord.w=dp, shadowCube 内部 SampleCmpLevelZero）
	 // 配合 SAMPLERCUBESHADOW + SAMPLER_COMPARE_LEQUAL flags

	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {

		float shadow = 1.0;

		vec3 lightToPosition = shadowCoord.xyz;
		vec3 bd3D = normalize( lightToPosition );
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );

		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {

			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;

			// bgfx4cj: 用 shadowCube 硬件比较替代手动 textureCube().r + step()
			shadow = shadowCube( shadowMap, vec4( bd3D, dp ) );

		}

		return mix( 1.0, shadow, shadowIntensity );

	}

	#elif defined( SHADOWMAP_TYPE_BASIC )

	float getPointShadow( samplerCubeShadow shadowMap, vec2 shadowMapSize, float shadowIntensity, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {

		float shadow = 1.0;

		// for point lights, the uniform @vShadowCoord is re-purposed to hold
		// the vector from the light to the world-space position of the fragment.
		vec3 lightToPosition = shadowCoord.xyz;

		// For cube shadow maps, depth is stored as distance along each face's view axis, not radial distance
		// The view-space depth is the maximum component of the direction vector (which face is sampled)
		vec3 absVec = abs( lightToPosition );
		float viewSpaceZ = max( max( absVec.x, absVec.y ), absVec.z );

		if ( viewSpaceZ - shadowCameraFar <= 0.0 && viewSpaceZ - shadowCameraNear >= 0.0 ) {

			// viewZ to perspective depth

			float dp = ( shadowCameraFar * ( viewSpaceZ - shadowCameraNear ) ) / ( viewSpaceZ * ( shadowCameraFar - shadowCameraNear ) );
			dp += shadowBias;

			// Direction from light to fragment
			vec3 bd3D = normalize( lightToPosition );

			// bgfx4cj: BASIC 模式同样使用 shadowCube 硬件比较
			shadow = shadowCube( shadowMap, vec4( bd3D, dp ) );

		}

		return mix( 1.0, shadow, shadowIntensity );

	}

	#endif

	#endif

#endif
"#
