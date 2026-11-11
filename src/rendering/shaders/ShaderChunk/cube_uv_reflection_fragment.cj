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
 * @file[zh-cn] cube_uv_reflection_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: cube_uv_reflection_fragment
 * @explain[zh-cn] PMREM CubeUV 环境贴图采样（方向 → 面/UV → 2D 图集纹理）。
 *         布局必须与 PMREMGenerator 生成器严格一致（见下），否则反射方向错位。
 *         本片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 *
 * @file[en] cube_uv_reflection_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: cube_uv_reflection_fragment
 * @explain[en] PMREM CubeUV environment map sampling (direction -> face/UV -> 2D atlas texture).
 *         The layout must match PMREMGenerator exactly (see below), otherwise reflections are misaligned.
 */
package three.rendering.shaders.ShaderChunk

/**
 * cube_uv_reflection_fragment GLSL 片段字符串
 *
 * ★CubeUV 图集布局（与 PMREMGenerator 的常量一一对应，改动必须两边同步）：
 *   - 共 5 个 mip 层级，面尺寸 faceSize = 256 / 128 / 64 / 32 / 16（level 0 最清晰）；
 *   - 每层平面为 3 列 × 2 行 的 faceSize 方块（face 0,1,2 → 第 0 行；face 3,4,5 → 第 1 行）；
 *   - 各层自上而下堆叠，y 偏移依次为 0 / 512 / 768 / 896 / 960；
 *   - 图集总尺寸 768 × 992；
 *   - 单像素采样点为 texel 中心（uv * (faceSize - 1) + 0.5），配合 ClampToEdge + LinearFilter。
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const cube_uv_reflection_fragment: String = #"
#ifdef ENVMAP_TYPE_CUBE_UV

	// 这些函数在"立方体单面 UV 坐标 / 0-5 面索引 / 方向向量"之间转换。

	float getFace( vec3 direction ) {

		vec3 absDirection = abs( direction );

		float face = - 1.0;

		if ( absDirection.x > absDirection.z ) {

			if ( absDirection.x > absDirection.y )

				face = direction.x > 0.0 ? 0.0 : 3.0;

			else

				face = direction.y > 0.0 ? 1.0 : 4.0;

		} else {

			if ( absDirection.z > absDirection.y )

				face = direction.z > 0.0 ? 2.0 : 5.0;

			else

				face = direction.y > 0.0 ? 1.0 : 4.0;

		}

		return face;

	}

	// 面内 UV（0-1 范围）
	vec2 getUV( vec3 direction, float face ) {

		vec2 uv;

		if ( face == 0.0 ) {

			uv = vec2( direction.z, direction.y ) / abs( direction.x ); // pos x

		} else if ( face == 1.0 ) {

			uv = vec2( - direction.x, - direction.z ) / abs( direction.y ); // pos y

		} else if ( face == 2.0 ) {

			uv = vec2( - direction.x, direction.y ) / abs( direction.z ); // pos z

		} else if ( face == 3.0 ) {

			uv = vec2( - direction.z, direction.y ) / abs( direction.x ); // neg x

		} else if ( face == 4.0 ) {

			uv = vec2( - direction.x, direction.z ) / abs( direction.y ); // neg y

		} else {

			uv = vec2( direction.x, direction.y ) / abs( direction.z ); // neg z

		}

		return 0.5 * ( uv + 1.0 );

	}

	// 采样某一 mip 层级（level：0=256px 面，1=128，2=64，3=32，4=16）
	// 直接引用全局 u_envMap（envmap_common_pars_fragment 声明），避免把 sampler 作为函数参数
	// 传递（HLSL 下 sampler 参数经 glslang 翻译易出错）。
	vec3 sampleCubeUVLevel( vec3 direction, float level ) {

		float face = getFace( direction );

		// faceSize = 256 / 2^level
		float faceSize = 256.0 / exp2( level );

		// 面内像素坐标（中心对齐）
		vec2 uv = getUV( direction, face ) * ( faceSize - 1.0 ) + 0.5;

		float row = face >= 3.0 ? 1.0 : 0.0;
		float col = face - row * 3.0;

		// 各层 y 偏移（与生成器一致）
		float yOffset = 0.0;
		if ( level > 3.5 ) {

			yOffset = 960.0;

		} else if ( level > 2.5 ) {

			yOffset = 896.0;

		} else if ( level > 1.5 ) {

			yOffset = 768.0;

		} else if ( level > 0.5 ) {

			yOffset = 512.0;

		}

		uv.x += col * faceSize;
		uv.y += row * faceSize + yOffset;

		uv /= vec2( 768.0, 992.0 );

		return texture2D( u_envMap, uv ).rgb;

	}

	// roughness(0-1) → CubeUV 层级（0=最清晰，4=最模糊），并在相邻层级间线性插值
	vec3 textureCubeUV( vec3 direction, float roughness ) {

		float m = clamp( roughness, 0.0, 1.0 ) * 4.0;

		float l0 = floor( m );
		float l1 = min( l0 + 1.0, 4.0 );
		float f = m - l0;

		vec3 color0 = sampleCubeUVLevel( direction, l0 );
		vec3 color1 = sampleCubeUVLevel( direction, l1 );

		return mix( color0, color1, f );

	}

#endif
"#
