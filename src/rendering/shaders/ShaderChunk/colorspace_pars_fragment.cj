/**
 * @file[zh-cn] colorspace_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: colorspace_pars_fragment
 *
 * @file[en] colorspace_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: colorspace_pars_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * colorspace_pars_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const colorspace_pars_fragment: String = #"

vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}

// sRGBTransferEOTF/OETF 未在基础渲染管线中使用（linearToOutputTexel 为空定义），
// 注释掉以避免 HLSL 编译器中 mix/pow 嵌套调用导致的 X3014 参数数量错误。
// 后续需要 srgb 编解码时再恢复，并确认 bgfx GLSL→HLSL 翻译器兼容性。

#define linearToOutputTexel
"#
