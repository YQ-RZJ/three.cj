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
 * @file[zh-cn] roughnessmap_pars_fragment  ShaderChunk GLSL 片段
 * @brief[zh-cn] ShaderChunk GLSL 片段: roughnessmap_pars_fragment
 *
 * @file[en] roughnessmap_pars_fragment  ShaderChunk GLSL fragment
 * @brief[en] ShaderChunk GLSL fragment: roughnessmap_pars_fragment
 * 该 GLSL 片段由 ShaderLib 在构建完整着色器程序时按需拼接。
 * 在 bgfx4cj 渲染后端中,由 BgfxShader/BgfxShaderCache 在运行时
 * 拼接为完整 GLSL 源码后交给 bgfx4j 封装的 shaderc API 编译。
 */
package three.rendering.shaders.ShaderChunk

/**
 * roughnessmap_pars_fragment GLSL 片段字符串
 * 
 * 使用仓颉三引号多行字符串语法 `"""..."""`。
 */
public const roughnessmap_pars_fragment: String = #"
#ifdef USE_ROUGHNESSMAP

	// 必须用 SAMPLER2D 宏而非裸 uniform sampler2D：HLSL 分支下
	// bgfx_shader.sh 定义 #define sampler2D BgfxSampler2D，裸声明会被替换成 struct，
	// bgfx 无法按名绑定 sampler uniform → 贴图采样不生效。
	SAMPLER2D(roughnessMap, __STAGE_ROUGHNESS_MAP__);

#endif
"#
