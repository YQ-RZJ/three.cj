/**
 * @file[zh-cn] lights_lambert_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: lights_lambert_fragment
 *
 * @file[en] lights_lambert_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: lights_lambert_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * lights_lambert_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const lights_lambert_fragment: String = #"
	LambertMaterial material;
	material.diffuseColor = diffuseColor.rgb;
	material.specularStrength = specularStrength;
"#
