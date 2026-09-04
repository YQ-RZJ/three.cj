/**
 * @file[zh-cn] normal_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: normal_fragment
 *
 * @file[en] normal_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: normal_fragment
 */
package three.rendering.shaders.ShaderChunk

/**
 * normal_fragment GLSL 片段字符串
 */
public const normal_fragment: String = #"
vec3 normal = normalize( vNormal );
"#
