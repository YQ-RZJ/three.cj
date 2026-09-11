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
