/**
 * @file[zh-cn] 间接存储缓冲区属性
 * @brief[zh-cn] 间接存储缓冲区属性标记类
 * @explain[zh-cn] 
 * IndirectStorageBufferAttribute 用于标记间接存储缓冲区属性类型，
 * 对应 WebGPU 中的 indirect storage buffer 绑定。
 *
 * @file[en] IndirectStorageBufferAttribute
 * @brief[en] Indirect storage buffer attribute marker class
 * @explain[en] 
 * IndirectStorageBufferAttribute is used to mark the indirect storage buffer attribute type,
 * corresponding to the indirect storage buffer binding in WebGPU.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 间接存储缓冲区属性标记类
 * @explain[zh-cn] 
 * 用于标记间接存储缓冲区属性类型，对应 WebGPU 的 indirect storage buffer 绑定。
 *
 * @brief[en] Indirect storage buffer attribute marker class
 * @explain[en] 
 * Used to mark the indirect storage buffer attribute type, corresponding to WebGPU's indirect storage buffer binding.
 */
public open class IndirectStorageBufferAttribute {
    /**
     * @brief[zh-cn] 属性类型标识
     *
     * @brief[en] Attribute type identifier
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造默认间接存储缓冲区属性
     *
     * @brief[en] Constructs a default indirect storage buffer attribute
     */
    public init() { this.kind = "IndirectStorageBufferAttribute" }
}
