/**
 * @file[zh-cn] 自定义着色器材质
 * @brief[zh-cn] 自定义着色器材质，允许传入自定义vertex/fragment shader源码
 * @explain[zh-cn] 
 * 对应 Three.js src/renderers/shaders/ShaderMaterial.js。
 * 允许用户传入自定义的 bgfx .sc 格式 vertex/fragment shader 源码以及 uniforms 对象。
 * 渲染器在首次渲染时编译 shader 并创建 program。
 * 注意：shader 源码需使用 bgfx 的 $input/$output 语法，
 * 并包含 #include <bgfx_shader.sh> 以获取标准 uniform 定义和辅助函数。
 *
 * @file[en] Shader Material
 * @brief[en] Custom shader material, allowing custom vertex/fragment shader source code
 * @explain[en] 
 * Corresponds to Three.js src/renderers/shaders/ShaderMaterial.js.
 * Allows users to provide custom bgfx .sc format vertex/fragment shader source code and uniforms.
 * The renderer compiles the shader and creates the program on first render.
 * Note: shader source code must use bgfx $input/$output syntax,
 * and include #include <bgfx_shader.sh> for standard uniform definitions and helper functions.
 */
package three.rendering.materials

import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 自定义着色器材质，允许传入自定义vertex/fragment shader源码
 * @explain[zh-cn] 
 * 对应 Three.js src/renderers/shaders/ShaderMaterial.js。
 * 允许用户传入自定义的 bgfx .sc 格式 vertex/fragment shader 源码以及 uniforms 对象。
 * shader 源码需使用 bgfx 的 $input/$output 语法。
 *
 * @brief[en] Custom shader material, allowing custom vertex/fragment shader source code
 * @explain[en] 
 * Corresponds to Three.js src/renderers/shaders/ShaderMaterial.js.
 * Allows custom bgfx .sc format vertex/fragment shader source code and uniforms.
 * Shader source code must use bgfx $input/$output syntax.
 */
@JsonAdapter[withSuperClass = Material]
public open class ShaderMaterial <: Material {
    /**
     * @brief[zh-cn] 顶点着色器源码（bgfx .sc格式）
     *
     * @brief[en] Vertex shader source code (bgfx .sc format)
     */
    public var vertexShader: String

    /**
     * @brief[zh-cn] 片段着色器源码（bgfx .sc格式）
     *
     * @brief[en] Fragment shader source code (bgfx .sc format)
     */
    public var fragmentShader: String

    /**
     * @brief[zh-cn] 自定义uniform表，key为uniform名，value为UniformValue对象
     *
     * @brief[en] Custom uniform table, key is uniform name, value is UniformValue object
     */
    public var uniforms: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造一个新的自定义着色器材质
     *
     * @brief[en] Construct a new custom shader material
     */
    public init() {
        super()
        this.kind = "ShaderMaterial"
        this.vertexShader = ""
        this.fragmentShader = ""
        this.uniforms = HashMap<String, Any>()
    }

    /**
     * @brief[zh-cn] 构造一个带指定着色器源码的自定义着色器材质
     * @param[zh-cn] vertexShader 顶点着色器源码
     * fragmentShader 片段着色器源码
     * uniforms 自定义uniform表
     *
     * @brief[en] Construct a custom shader material with specified shader source code
     * @param[en] vertexShader Vertex shader source code
     * fragmentShader Fragment shader source code
     * uniforms Custom uniform table
     */
    public init(vertexShader: String, fragmentShader: String, uniforms!: HashMap<String, Any> = HashMap<String, Any>()) {
        super()
        this.kind = "ShaderMaterial"
        this.vertexShader = vertexShader
        this.fragmentShader = fragmentShader
        this.uniforms = uniforms
    }

    /**
     * @brief[zh-cn] 将给定ShaderMaterial的属性复制到本实例
     * @param[zh-cn] source 源材质
     * recursive 是否递归复制
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the properties from the given ShaderMaterial to this instance
     * @param[en] source Source material
     * recursive Whether to copy recursively
     * @return[en] This instance
     */
    public func copy(source: ShaderMaterial, recursive!: Bool = true): ShaderMaterial {
        super.copy(source)
        this.vertexShader = source.vertexShader
        this.fragmentShader = source.fragmentShader
        this.uniforms = HashMap<String, Any>(source.uniforms)
        return this
    }
}
