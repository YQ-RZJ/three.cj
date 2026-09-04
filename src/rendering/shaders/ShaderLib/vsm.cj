/**
 * @file[zh-cn] vsm  ShaderLib 着色器程序定义
 * @brief[zh-cn] ShaderLib 着色器程序定义: vsm
 *
 * @file[en] vsm  ShaderLib shader program definition
 * @brief[en] ShaderLib shader program definition: vsm
 * 该着色器程序由 vertex 和 fragment 两个 GLSL 片段组成,
 * 在运行时由 ShaderLibs 组合为完整着色器后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderLib

/**
 * @brief[zh-cn] vsm 顶点着色器源码
 *
 * @brief[en] vsm vertex shader source
 */
public const vsm_vertex: String = #"
void main() {

	gl_Position = vec4( position, 1.0 );

}
"#

/**
 * @brief[zh-cn] vsm 片段着色器源码
 *
 * @brief[en] vsm fragment shader source
 */
public const vsm_fragment: String = #"
uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;

void main() {

	const float samples = float( VSM_SAMPLES );

	float mean = 0.0;
	float squared_mean = 0.0;

	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {

		float uvOffset = uvStart + i * uvStride;

		#ifdef HORIZONTAL_PASS

			vec2 distribution = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ).rg;
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;

		#else

			float depth = texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ).r;
			mean += depth;
			squared_mean += depth * depth;

		#endif

	}

	mean = mean / samples;
	squared_mean = squared_mean / samples;

	float std_dev = sqrt( max( 0.0, squared_mean - mean * mean ) );

	gl_FragColor = vec4( mean, std_dev, 0.0, 1.0 );

}
"#
