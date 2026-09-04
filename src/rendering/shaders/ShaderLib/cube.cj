/**
 * @file[zh-cn] cube  ShaderLib 着色器程序定义
 * @brief[zh-cn] ShaderLib 着色器程序定义: cube
 *
 * @file[en] cube  ShaderLib shader program definition
 * @brief[en] ShaderLib shader program definition: cube
 * 该着色器程序由 vertex 和 fragment 两个 GLSL 片段组成,
 * 在运行时由 ShaderLibs 组合为完整着色器后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderLib

/**
 * @brief[zh-cn] cube 顶点着色器源码
 *
 * @brief[en] cube vertex shader source
 */
public const cube_vertex: String = #"
varying vec3 vWorldDirection;

#include <common>

void main() {

	vWorldDirection = transformDirection( position, modelMatrix );

	#include <begin_vertex>
	#include <project_vertex>

	gl_Position.z = gl_Position.w; // set z to camera.far

}
"#

/**
 * @brief[zh-cn] cube 片段着色器源码
 *
 * @brief[en] cube fragment shader source
 */
public const cube_fragment: String = #"
uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;

varying vec3 vWorldDirection;

void main() {

	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );

	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;

	#include <tonemapping_fragment>
	#include <colorspace_fragment>

}
"#
