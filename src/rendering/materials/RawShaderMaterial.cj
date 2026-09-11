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
 * @file[zh-cn] 原始着色器材质
 * @brief[zh-cn] 原始着色器材质，继承ShaderMaterial但不注入内置uniform
 * @explain[zh-cn] 
 * 对应 Three.js materials/RawShaderMaterial.js。与 ShaderMaterial 的区别在于：
 * ShaderMaterial 会自动注入 Three.js 内置 uniform（如 projectionMatrix、modelViewMatrix 等），
 * 而 RawShaderMaterial 不会注入任何内置 uniform，用户需自行声明所有 uniform 和 attribute。
 *
 * @file[en] Raw Shader Material
 * @brief[en] Raw shader material, extending ShaderMaterial without injecting built-in uniforms
 * @explain[en] 
 * Corresponds to Three.js materials/RawShaderMaterial.js. The difference from ShaderMaterial is:
 * ShaderMaterial automatically injects Three.js built-in uniforms (e.g., projectionMatrix, modelViewMatrix, etc.),
 * while RawShaderMaterial does not inject any built-in uniforms; users must declare all uniforms and attributes themselves.
 */
package three.rendering.materials

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 原始着色器材质，继承ShaderMaterial但不注入内置uniform
 * @explain[zh-cn] 
 * 对应 Three.js materials/RawShaderMaterial.js。不注入任何内置 uniform，用户需自行声明所有 uniform 和 attribute。
 *
 * @brief[en] Raw shader material, extending ShaderMaterial without injecting built-in uniforms
 * @explain[en] 
 * Corresponds to Three.js materials/RawShaderMaterial.js. Does not inject any built-in uniforms;
 * users must declare all uniforms and attributes themselves.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = ShaderMaterial]
public class RawShaderMaterial <: ShaderMaterial {
    /**
     * @brief[zh-cn] 构造一个新的原始着色器材质
     *
     * @brief[en] Construct a new raw shader material
     */
    public init() { super(); }
}
