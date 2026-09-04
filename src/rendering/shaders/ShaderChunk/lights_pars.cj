/**
 * @file[zh-cn] lights_pars  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: lights_pars
 *
 * @file[en] lights_pars  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: lights_pars
 */
package three.rendering.shaders.ShaderChunk

/**
 * lights_pars GLSL 片段字符串
 */
public const lights_pars: String = #"
struct DirectionalLight {
	vec3 direction;
	vec3 color;
};
struct PointLight {
	vec3 position;
	vec3 color;
	float distance;
	float decay;
};
struct SpotLight {
	vec3 position;
	vec3 direction;
	vec3 color;
	float distance;
	float angle;
	float decay;
};
"#
