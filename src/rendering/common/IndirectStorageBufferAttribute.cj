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
