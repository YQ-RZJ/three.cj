/**
 * @file[zh-cn] 可编程阶段
 * @brief[zh-cn] 着色器可编程阶段描述，封装着色器代码和阶段类型
 * @explain[zh-cn] 
 * ProgrammableStage 封装一个着色器阶段的代码和类型信息（如 vertex/fragment/compute），
 * 对应 Three.js 渲染器中 Program 对象的着色器阶段描述。
 *
 * @file[en] ProgrammableStage
 * @brief[en] Shader programmable stage description, encapsulating shader code and stage type
 * @explain[en] 
 * ProgrammableStage encapsulates the code and type information of a shader stage (e.g., vertex/fragment/compute),
 * corresponding to the shader stage description of the Program object in the Three.js renderer.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 着色器可编程阶段描述
 * @explain[zh-cn] 
 * 封装着色器代码和阶段类型（vertex/fragment/compute）。
 *
 * @brief[en] Shader programmable stage description
 * @explain[en] 
 * Encapsulates shader code and stage type (vertex/fragment/compute).
 */
public open class ProgrammableStage {
    /**
     * @brief[zh-cn] 着色器代码
     *
     * @brief[en] Shader code
     */
    public var code: String

    /**
     * @brief[zh-cn] 着色器类型（如 "vertex"、"fragment"、"compute"）
     *
     * @brief[en] Shader kind (e.g., "vertex", "fragment", "compute")
     */
    public var kind: String

    /**
     * @brief[zh-cn] 着色器阶段（默认与 kind 相同）
     *
     * @brief[en] Shader stage (defaults to the same as kind)
     */
    public var stage: String

    /**
     * @brief[zh-cn] 构造可编程阶段，指定代码和类型
     * @param[zh-cn] code 着色器代码
     * kind 着色器类型
     *
     * @brief[en] Constructs a programmable stage with specified code and kind
     * @param[en] code Shader code
     * kind Shader kind
     */
    public init(code: String, kind: String) { this.code = code; this.kind = kind; this.stage = kind }

    /**
     * @brief[zh-cn] 获取着色器代码
     * @return[zh-cn] 着色器代码
     *
     * @brief[en] Gets the shader code
     * @return[en] Shader code
     */
    public func getCode(): String { return this.code }

    /**
     * @brief[zh-cn] 获取着色器阶段
     * @return[zh-cn] 着色器阶段
     *
     * @brief[en] Gets the shader stage
     * @return[en] Shader stage
     */
    public func getStage(): String { return this.stage }
}
