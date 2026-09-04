/**
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
@JsonAdapter[withSuperClass = ShaderMaterial]
public class RawShaderMaterial <: ShaderMaterial {
    /**
     * @brief[zh-cn] 构造一个新的原始着色器材质
     *
     * @brief[en] Construct a new raw shader material
     */
    public init() { super(); this.kind = "RawShaderMaterial" }
}
