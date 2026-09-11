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
 * @file[zh-cn] IShaderProgram 着色器程序标记接口
 * @brief[zh-cn] 着色器程序标记接口，解耦 materials 与 shaders 的包级循环依赖
 * @explain[zh-cn] Three.js 的 Material.onBeforeCompile(shaderobject, renderer) 回调参数
 * shaderobject 是着色器编译对象。仓颉侧对应 ShaderProgram（shaders 包），
 * materials 包若直接 import shaders 会形成循环（shaders 的 ShaderVariant 依赖 materials），
 * 因此将"着色器程序"抽象为标记接口：
 * - 实现方（shaders 包 ShaderProgram）实现本接口；
 * - 使用方（materials 包 Material 回调参数）仅以接口持有着色器程序引用。
 *
 * @file[en] IShaderProgram Shader program marker interface
 * @brief[en] Shader program marker interface, decoupling circular dependency between materials and shaders
 * @explain[en] In Three.js, Material.onBeforeCompile(shaderobject, renderer) callback parameter
 * shaderobject is the shader compilation object. In Cangjie, this corresponds to ShaderProgram (shaders package).
 * If the materials package directly imports shaders, a circular dependency forms
 * (shaders' ShaderVariant depends on materials), so "shader program" is abstracted as a marker interface:
 * - Implementor (ShaderProgram in shaders package) implements this interface;
 * - Consumer (Material callback parameter in materials package) holds shader program reference by interface only.
 *
 * @package three.rendering.interfaces
 */
package three.rendering.interfaces

/**
 * @brief[zh-cn] 着色器程序标记接口：Material.onBeforeCompile 回调的 shaderobject 参数类型
 *
 * @brief[en] Shader program marker interface: shaderobject parameter type for Material.onBeforeCompile callback
 */
public interface IShaderProgram {
}
