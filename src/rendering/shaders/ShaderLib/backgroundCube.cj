/**
 * @file[zh-cn] backgroundCube  ShaderLib 着色器程序定义
 * @brief[zh-cn] ShaderLib 着色器程序定义: backgroundCube
 *
 * @file[en] backgroundCube  ShaderLib shader program definition
 * @brief[en] ShaderLib shader program definition: backgroundCube
 * 该着色器程序由 vertex 和 fragment 两个 GLSL 片段组成,
 * 在运行时由 ShaderLibs 组合为完整着色器后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderLib

/**
 * @brief[zh-cn] backgroundCube 顶点着色器源码
 *
 * @brief[en] backgroundCube vertex shader source
 */
public const backgroundCube_vertex: String = #"
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
 * @brief[zh-cn] backgroundCube 片段着色器源码
 *
 * @brief[en] backgroundCube fragment shader source
 */
public const backgroundCube_fragment: String = #"

#ifdef ENVMAP_TYPE_CUBE

	uniform samplerCube envMap;

#elif defined( ENVMAP_TYPE_CUBE_UV )

	uniform sampler2D envMap;

#endif

uniform float backgroundBlurriness;
uniform float backgroundIntensity;
uniform mat3 backgroundRotation;

varying vec3 vWorldDirection;

#include <cube_uv_reflection_fragment>

void main() {

	#ifdef ENVMAP_TYPE_CUBE

		vec4 texColor = textureCube( envMap, backgroundRotation * vWorldDirection );

	#elif defined( ENVMAP_TYPE_CUBE_UV )

		vec4 texColor = textureCubeUV( envMap, backgroundRotation * vWorldDirection, backgroundBlurriness );

	#else

		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );

	#endif

	texColor.rgb *= backgroundIntensity;

	gl_FragColor = texColor;

	#include <tonemapping_fragment>
	#include <colorspace_fragment>

}
"#
