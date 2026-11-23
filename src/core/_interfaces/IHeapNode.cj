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
 * @file[zh-cn] IHeapNode 堆节点接口（原名 HeapNode，自 core/dsa/BinaryHeap.cj 收纳至本接口包）
 * @brief[zh-cn] 二叉堆元素的公共契约，实现方（FrameTask、LuaValue 等）实现本接口
 * @explain[zh-cn] 收纳至 interfaces 子包并按 C9 约定 protected + 实现包重导出（three.core.dsa.IHeapNode）。
 *
 * @file[en] IHeapNode  Heap node interface (moved from core/dsa/BinaryHeap.cj into this interface package)
 * @brief[en] The public contract of binary heap elements, implemented by FrameTask, LuaValue etc.
 * @explain[en] Collected into the interfaces subpackage per C9: protected package + re-export from the implementation package (three.core.dsa.IHeapNode).
 */
protected package three.core._interfaces

/**
 * @brief[zh-cn] 堆节点接口
 * @explain[zh-cn] 堆节点需要维护自身在堆中的索引（index），以便支持 O(log n) 的 remove/update。
 *
 * @brief[en] Heap node interface
 * @explain[en] Heap nodes need to maintain their index in the heap to support O(log n) remove/update operations.
 */
public interface IHeapNode {
    /**
     * @brief[zh-cn] 在堆中的索引，-1 表示不在堆中
     *
     * @brief[en] Index in the heap, -1 means not in the heap
     */
    mut prop index: Int64

    /**
     * @brief[zh-cn] 比较函数
     * @param[zh-cn] other 另一个节点
     * @return[zh-cn] true 表示 this 比 other 更优先（应排在更前面）
     *
     * @brief[en] Comparison function
     * @param[en] other Another node
     * @return[en] true means this has higher priority than other (should be placed ahead)
     */
    func lessThan(other: IHeapNode): Bool
}
