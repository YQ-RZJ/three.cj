/**
 * @file[zh-cn] equirect  ShaderLib 着色器程序定义
 * @brief[zh-cn] ShaderLib 着色器程序定义: equirect
 *
 * @file[en] equirect  ShaderLib shader program definition
 * @brief[en] ShaderLib shader program definition: equirect
 * 该着色器程序由 vertex 和 fragment 两个 GLSL 片段组成,
 * 在运行时由 ShaderLibs 组合为完整着色器后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderLib

/**
 * @brief[zh-cn] equirect 顶点着色器源码
 *
 * @brief[en] equirect vertex shader source
 */
public const equirect_vertex: String = #"""
varying vec3 vWorldDirection;

#include <common>

void main() {

	vWorldDirection = transformDirection( position, modelMatrix );

	#include <begin_vertex>
	#include <project_vertex>

}
"#

/**
 * @brief[zh-cn] equirect 片段着色器源码
 *
 * @brief[en] equirect fragment shader source
 */
public const equirect_fragment: String = #"""
uniform sampler2D tEquirect;

varying vec3 vWorldDirection;

#include <common>

void main() {

	vec3 direction = normalize( vWorldDirection );

	vec2 sampleUV = equirectUv( direction );

	gl_FragColor = texture2D( tEquirect, sampleUV );

	#include <tonemapping_fragment>
	#include <colorspace_fragment>

}
"#
