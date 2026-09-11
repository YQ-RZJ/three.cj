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
