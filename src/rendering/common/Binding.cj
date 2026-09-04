/**
 * @file[zh-cn] 绑定
 * @brief[zh-cn] 单个绑定资源描述，表示 uniform buffer、sampler 等资源绑定
 * @explain[zh-cn] 
 * Binding 描述一个管线资源绑定，包含名称、值、类型（kind）和可见性（visibility）。
 * 对应 WebGPU 中的 BindGroupEntry 概念。
 *
 * @file[en] Binding
 * @brief[en] Single binding resource description, representing uniform buffer, sampler, or other resource bindings
 * @explain[en] 
 * Binding describes a pipeline resource binding, containing name, value, kind, and visibility.
 * Corresponds to the BindGroupEntry concept in WebGPU.
 */
package three.rendering.common


/**
 * @brief[zh-cn] 单个绑定资源描述，表示 uniform buffer、sampler 等资源绑定
 * @explain[zh-cn] 
 * 包含名称、值、类型（kind）和可见性（visibility），对应 WebGPU 的 BindGroupEntry。
 *
 * @brief[en] Single binding resource description, representing uniform buffer, sampler, or other resource bindings
 * @explain[en] 
 * Contains name, value, kind, and visibility, corresponding to WebGPU's BindGroupEntry.
 */
public open class Binding {
    /**
     * @brief[zh-cn] 绑定名称
     *
     * @brief[en] Binding name
     */
    public var name: String

    /**
     * @brief[zh-cn] 绑定值
     *
     * @brief[en] Binding value
     */
    public var value: Any

    /**
     * @brief[zh-cn] 绑定类型（如 "uniform"、"buffer" 等）
     *
     * @brief[en] Binding kind (e.g., "uniform", "buffer", etc.)
     */
    public var kind: String

    /**
     * @brief[zh-cn] 着色器可见性标志
     *
     * @brief[en] Shader visibility flags
     */
    public var visibility: Int64

    /**
     * @brief[zh-cn] 构造绑定，指定名称、值和类型
     * @param[zh-cn] name 绑定名称
     * value 绑定值
     * kind 绑定类型
     *
     * @brief[en] Constructs a binding with the specified name, value, and kind
     * @param[en] name Binding name
     * value Binding value
     * kind Binding kind
     */
    public init(name: String, value: Any, kind: String) { this.name = name; this.value = value; this.kind = kind; this.visibility = 0 }

    /**
     * @brief[zh-cn] 构造绑定，指定名称和值，默认类型为 "uniform"
     * @param[zh-cn] name 绑定名称
     * value 绑定值
     *
     * @brief[en] Constructs a binding with the specified name and value, defaulting kind to "uniform"
     * @param[en] name Binding name
     * value Binding value
     */
    public init(name: String, value: Any) { this.name = name; this.value = value; this.kind = "uniform"; this.visibility = 0 }
}
