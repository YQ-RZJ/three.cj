/**
 * @file[zh-cn] GL 缓冲区属性
 * @brief[zh-cn] 提供对 VBO 的更细粒度控制，对应 Three.js GLBufferAttribute.js
 * @explain[zh-cn] 渲染器不会为此类属性构造 VBO，而是使用构造函数中传入的缓冲区。
 * 此类最常见的用例是 GPGPU 计算干扰或产生 VBO 的情况。
 * 在 bgfx 渲染后端中，buffer 属性对应 bgfx 的顶点缓冲区句柄。
 * 安全化说明（对照任务 3 调整建议）：buffer 字段由裸 CPointer<Unit> 改为
 * three.rendering.types.VertexBufferHandle（Box 包装的 bgfx 顶点缓冲句柄），
 * 对外不暴露指针；外部无须管理句柄生命周期，由 renderer 高阶 API 处理。
 *
 * @file[en] GL Buffer Attribute
 * @brief[en] Provides finer-grained control over VBO, corresponding to Three.js GLBufferAttribute.js
 * @explain[en] The renderer does not construct VBOs for this attribute type, but uses the buffer
 * passed in the constructor. The most common use case is when GPGPU computation
 * interferes with or produces VBOs. In the bgfx rendering backend, the buffer attribute
 * corresponds to the bgfx vertex buffer handle.
 * Safety note (per task 3 adjustment): buffer field changed from raw CPointer<Unit> to
 * three.rendering.types.VertexBufferHandle (Box-wrapped bgfx vertex buffer handle),
 * no raw pointer exposed externally; external code does not need to manage handle lifecycle,
 * handled by renderer high-level APIs.
 *
 * @package three.rendering.buffer
 */
package three.rendering.buffer
import three.rendering.types.VertexBufferHandle
import three.rendering.types.INVALID_VERTEX_BUFFER_HANDLE

/**
 * @brief[zh-cn] GL 缓冲区属性类
 * @explain[zh-cn] 与 BufferAttribute 不同，GLBufferAttribute 允许直接使用已有的 GPU 缓冲区，
 * 而不是由渲染器自动创建。这在 GPGPU 场景中特别有用。
 *
 * @brief[en] GL buffer attribute class
 * @explain[en] Unlike BufferAttribute, GLBufferAttribute allows direct use of an existing GPU buffer
 * instead of having the renderer create one automatically. This is particularly useful in GPGPU scenarios.
 */
public class GLBufferAttribute {
    /**
     * @brief[zh-cn] 缓冲区属性名称
     *
     * @brief[en] Buffer attribute name
     */
    public var name: String

    /**
     * @brief[zh-cn] 原生缓冲区句柄（Box 包装的 bgfx 顶点缓冲句柄）
     *
     * @brief[en] Native buffer handle (Box-wrapped bgfx vertex buffer handle)
     */
    public var buffer: VertexBufferHandle

    /**
     * @brief[zh-cn] 数据类型标识，对应 bgfx 顶点格式中的属性类型
     * @explain[zh-cn] 原始 JS 属性名为 type，因与仓颉关键字冲突改名为 kind
     *
     * @brief[en] Data type identifier, corresponding to bgfx vertex format attribute type
     * @explain[en] Original JS property name is type, renamed to kind due to Cangjie keyword conflict
     */
    public var kind: Int64

    /**
     * @brief[zh-cn] 每个顶点的数据项大小
     *
     * @brief[en] Data item size per vertex
     */
    public var itemSize: Int64

    /**
     * @brief[zh-cn] 对应 kind 参数的字节大小
     *
     * @brief[en] Byte size corresponding to the kind parameter
     */
    public var elementSize: Int64

    /**
     * @brief[zh-cn] VBO 中预期的顶点数量
     *
     * @brief[en] Expected number of vertices in VBO
     */
    public var count: Int64

    /**
     * @brief[zh-cn] 是否对整数数据进行归一化
     *
     * @brief[en] Whether to normalize integer data
     */
    public var normalized: Bool

    /**
     * @brief[zh-cn] 版本号，每次 needsUpdate 设为 true 时递增
     *
     * @brief[en] Version number, incremented each time needsUpdate is set to true
     */
    public var version: Int64

    /**
     * @brief[zh-cn] 构造一个新的 GL 缓冲区属性
     * @param[zh-cn] buffer 原生缓冲区句柄（Box 包装）
     * kind 数据类型标识（对应 JS 中的 type）
     * itemSize 每个顶点的数据项大小
     * elementSize 对应 kind 的字节大小
     * count 预期的顶点数量
     * normalized 是否归一化，默认为 false
     *
     * @brief[en] Construct a new GL buffer attribute
     * @param[en] buffer Native buffer handle (Box-wrapped)
     * kind Data type identifier (corresponding to type in JS)
     * itemSize Data item size per vertex
     * elementSize Byte size corresponding to kind
     * count Expected number of vertices
     * normalized Whether to normalize, default false
     */
    public init(buffer: VertexBufferHandle, kind!: Int64 = 0, itemSize!: Int64 = 0, elementSize!: Int64 = 0, count!: Int64 = 0, normalized!: Bool = false) {
        this.name = ""
        this.buffer = buffer
        this.kind = kind
        this.itemSize = itemSize
        this.elementSize = elementSize
        this.count = count
        this.normalized = normalized
        this.version = 0
    }

    /**
     * @brief[zh-cn] 标记属性是否需要更新
     * @explain[zh-cn] 设置为 true 时，version 会自动递增
     * @param[zh-cn] value 是否需要更新
     *
     * @brief[en] Mark whether the attribute needs update
     * @explain[en] When set to true, version is automatically incremented
     * @param[en] value Whether needs update
     */
    public func setNeedsUpdate(value: Bool): Unit {
        if (value) {
            this.version += 1
        }
    }

    /**
     * @brief[zh-cn] 检查属性是否需要更新
     * @return[zh-cn] 如果 version > 0 则返回 true
     *
     * @brief[en] Check whether the attribute needs update
     * @return[en] Returns true if version > 0
     */
    public func getNeedsUpdate(): Bool {
        return this.version > 0
    }

    /**
     * @brief[zh-cn] 设置原生缓冲区
     * @param[zh-cn] buffer 新的缓冲区句柄（Box 包装）
     * @return[zh-cn] 当前实例（支持链式调用）
     *
     * @brief[en] Set native buffer
     * @param[en] buffer New buffer handle (Box-wrapped)
     * @return[en] Current instance (supports chaining)
     */
    public func setBuffer(buffer: VertexBufferHandle): GLBufferAttribute {
        this.buffer = buffer
        return this
    }

    /**
     * @brief[zh-cn] 设置数据类型和元素大小
     * @param[zh-cn] kind 数据类型标识（对应 JS 中的 type）
     * elementSize 对应 kind 的字节大小
     * @return[zh-cn] 当前实例（支持链式调用）
     *
     * @brief[en] Set data type and element size
     * @param[en] kind Data type identifier (corresponding to type in JS)
     * elementSize Byte size corresponding to kind
     * @return[en] Current instance (supports chaining)
     */
    public func setType(kind: Int64, elementSize: Int64): GLBufferAttribute {
        this.kind = kind
        this.elementSize = elementSize
        return this
    }

    /**
     * @brief[zh-cn] 设置数据项大小
     * @param[zh-cn] itemSize 每个顶点的数据项大小
     * @return[zh-cn] 当前实例（支持链式调用）
     *
     * @brief[en] Set data item size
     * @param[en] itemSize Data item size per vertex
     * @return[en] Current instance (supports chaining)
     */
    public func setItemSize(itemSize: Int64): GLBufferAttribute {
        this.itemSize = itemSize
        return this
    }

    /**
     * @brief[zh-cn] 设置顶点数量
     * @param[zh-cn] count 预期的顶点数量
     * @return[zh-cn] 当前实例（支持链式调用）
     *
     * @brief[en] Set vertex count
     * @param[en] count Expected number of vertices
     * @return[en] Current instance (supports chaining)
     */
    public func setCount(count: Int64): GLBufferAttribute {
        this.count = count
        return this
    }
}
