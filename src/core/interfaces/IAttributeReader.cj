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
 * @file[zh-cn] IAttributeReader
 * @brief[zh-cn] 顶点属性只读接口
 * @explain[zh-cn] 本包只存放接口声明，不依赖 three 内任何其他包；其他包（math/core 等）单向依赖本包，从而避免包间循环依赖。three.js 中 Vector/Color/Box3 的 fromBufferAttribute 直接接收 BufferAttribute（core 包）。cj 侧若让 math 依赖 core 会形成循环（core 依赖 math），因此将只读访问契约提取为本接口，由 core 的 BufferAttribute 实现。
 *
 * @file[en] IAttributeReader
 * @brief[en] Read-only interface for vertex attributes
 * @explain[en] This package only contains interface declarations with no dependency on any other three packages; other packages (math/core etc.) depend on this package unidirectionally, avoiding circular dependencies. In three.js, Vector/Color/Box3's fromBufferAttribute directly receives BufferAttribute (core package). In Cangjie, if math depends on core it would form a cycle (core depends on math), so the read-only access contract is extracted into this interface, implemented by core's BufferAttribute. JS reference: BufferAttribute#getX/getY/getZ/getW + count.
 */
package three.core.interfaces

/**
 * @brief[zh-cn] 顶点属性只读访问接口（getX/getY/getZ/getW + count）
 * @explain[zh-cn] 供 Vector/Color/Box3 从 BufferAttribute 读取分量数据，避免 math 与 core 包的循环依赖
 *
 * @brief[en] Read-only vertex attribute access interface (getX/getY/getZ/getW + count)
 * @explain[en] Allows Vector/Color/Box3 to read component data from BufferAttribute, avoiding circular dependency between math and core packages
 */
public interface AttributeReader {
    /**
     * @brief[zh-cn] 读取指定索引的 x（第 0）分量
     * @param[zh-cn] index 顶点索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Read the x (0th) component at the specified index
     * @param[en] index Vertex index
     * @return[en] Component value
     */
    func getX(index: Int64): Float64

    /**
     * @brief[zh-cn] 读取指定索引的 y（第 1）分量
     * @param[zh-cn] index 顶点索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Read the y (1st) component at the specified index
     * @param[en] index Vertex index
     * @return[en] Component value
     */
    func getY(index: Int64): Float64

    /**
     * @brief[zh-cn] 读取指定索引的 z（第 2）分量
     * @param[zh-cn] index 顶点索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Read the z (2nd) component at the specified index
     * @param[en] index Vertex index
     * @return[en] Component value
     */
    func getZ(index: Int64): Float64

    /**
     * @brief[zh-cn] 读取指定索引的 w（第 3）分量
     * @param[zh-cn] index 顶点索引
     * @return[zh-cn] 分量值
     *
     * @brief[en] Read the w (3rd) component at the specified index
     * @param[en] index Vertex index
     * @return[en] Component value
     */
    func getW(index: Int64): Float64

    /**
     * @brief[zh-cn] 顶点数量
     *
     * @brief[en] Vertex count
     */
    mut prop count: Int64
}
