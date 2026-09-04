/**
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
