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
 * @file[zh-cn] UniformsLib 材质 Uniform 代码块库
 * @brief[zh-cn] 通过 ShaderChunks 定义材质常用 uniform 代码块
 * @explain[zh-cn] 原定义在 bgfx 包 ShaderLibs.cj 中；因只依赖 shaders 包的 ShaderChunks，
 * 迁至 three.renderers.shaders 与 ShaderChunks 同包，避免跨包依赖 bgfx。
 *
 * @file[en] UniformsLib material uniform chunk library
 * @brief[en] Defines common material uniform chunks through ShaderChunks
 * @explain[en] Originally defined in the bgfx package's ShaderLibs.cj; since it only depends on
 * ShaderChunks in the shaders package it moved to three.renderers.shaders, avoiding any bgfx dependency.
 *
 * @package three.renderers.shaders
 */
package three.renderers.shaders

/**
 * @brief[zh-cn] 材质 Uniform 库
 *
 * @brief[en] Material uniform library
 */
public class UniformsLib {
    public static func initialize(): Unit {
        // common
        ShaderChunks.define("common_uniforms",
            """
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform mat4 u_viewProj;
uniform vec3 u_cameraPosition;
uniform float u_time;
""")
        // model
        ShaderChunks.define("model_uniforms", """
uniform mat4 u_model;
""")
        // normal
        ShaderChunks.define("normal_uniforms", """
uniform mat3 u_normalMatrix;
""")
        // fog
        ShaderChunks.define("fog_uniforms",
            """
uniform vec3 u_fogColor;
#ifdef FOG_EXP2
uniform float u_fogDensity;
#else
uniform float u_fogNear;
uniform float u_fogFar;
#endif
""")
        // lights
        ShaderChunks.define("lights_uniforms",
            """
struct DirectionalLight {
    vec3 direction;
    vec3 color;
};
#define NUM_DIR_LIGHTS 1
uniform DirectionalLight u_dirLights[NUM_DIR_LIGHTS];
""")
        // points
        ShaderChunks.define("points_uniforms", """
uniform float u_pointSize;
""")
    }
}
