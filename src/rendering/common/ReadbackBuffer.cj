/**
 * @file[zh-cn] 回读缓冲区
 * @brief[zh-cn] GPU 回读缓冲区标记类，用于从 GPU 读取数据
 * @explain[zh-cn] 
 * ReadbackBuffer 用于标记 GPU 到 CPU 的回读缓冲区类型，
 * 对应 WebGPU 中的 readback buffer 绑定。用于从 GPU 读取计算结果或像素数据。
 *
 * @file[en] ReadbackBuffer
 * @brief[en] GPU readback buffer marker class, used for reading data from GPU
 * @explain[en] 
 * ReadbackBuffer is used to mark the GPU-to-CPU readback buffer type,
 * corresponding to the readback buffer binding in WebGPU. Used for reading compute results or pixel data from GPU.
 */
package three.rendering.common

/**
 * @brief[zh-cn] GPU 回读缓冲区标记类
 * @explain[zh-cn] 
 * 用于标记 GPU 到 CPU 的回读缓冲区类型，对应 WebGPU 的 readback buffer 绑定。
 *
 * @brief[en] GPU readback buffer marker class
 * @explain[en] 
 * Used to mark the GPU-to-CPU readback buffer type, corresponding to WebGPU's readback buffer binding.
 */
public open class ReadbackBuffer {
    /**
     * @brief[zh-cn] 缓冲区类型标识
     *
     * @brief[en] Buffer type identifier
     */
    public var kind: String

    /**
     * @brief[zh-cn] 构造默认回读缓冲区
     *
     * @brief[en] Constructs a default readback buffer
     */
    public init() { this.kind = "ReadbackBuffer" }
}
