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
 * otherwise be required by Sections 4(a), 5(b) and 6(d) of the License.
 *
 * @file[zh-cn] 并查集
 * @brief[zh-cn] 带路径压缩与按秩合并的 disjoint-set（union-find）结构
 * @explain[zh-cn] 引擎中"分组/去重/连通性"类问题的通用基础设施：
 *             - 纹理图集分组、材质批次归并（把共享属性的对象归到同一组）
 *             - 连通区域标记（洪水填充式的区域划分）
 *             - 场景图子树归属的等价类归并
 *             平均时间复杂度近乎常数（α(n)），远优于每次重新扫描全部元素分组。
 *
 * @file[en] Union-Find
 * @brief[en] Disjoint-set (union-find) structure with path compression and union by rank
 * @explain[en] General infrastructure for "grouping / deduplication / connectivity"
 *             problems in the engine:
 *             - Texture atlas grouping, material batch merging (grouping objects that
 *               share attributes)
 *             - Connected-region marking (flood-fill style partitioning)
 *             - Merging equivalence classes of scene-graph subtrees
 *             The amortized time complexity is near-constant (α(n)), far better than
 *             rescanning all elements to regroup them.
 */

package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 并查集
 * @explain[zh-cn] 元素下标从 0 开始。find 时做路径压缩（迭代版，避免深递归），
 *             union 时按秩合并，保证树高为 O(log n)。
 *
 * @brief[en] Union-Find
 * @explain[en] Element indices start at 0. find applies path compression (iterative,
 *             avoiding deep recursion) and union merges by rank, keeping the tree
 *             height at O(log n).
 */
public class UnionFind {
    /**
     * @brief[zh-cn] 父节点数组
     *
     * @brief[en] Parent array
     */
    private var _parent: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 秩数组（按秩合并用）
     *
     * @brief[en] Rank array (used by union by rank)
     */
    private var _rank: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 连通分量数量
     *
     * @brief[en] Number of connected components
     */
    private var _components: Int64 = 0

    /**
     * @brief[zh-cn] 构造空的并查集
     *
     * @brief[en] Constructs an empty union-find
     */
    public init() {}

    /**
     * @brief[zh-cn] 构造指定元素个数的并查集
     * @param[zh-cn] size 元素个数（下标 0..size-1）
     *
     * @brief[en] Constructs a union-find with the given number of elements
     * @param[en] size Number of elements (indices 0..size-1)
     */
    public init(size: Int64) {
        for (_ in 0..size) {
            this.makeSet()
        }
    }

    /**
     * @brief[zh-cn] 元素个数
     *
     * @brief[en] Number of elements
     */
    public prop size: Int64 {
        get() { this._parent.size }
    }

    /**
     * @brief[zh-cn] 连通分量数量
     *
     * @brief[en] Number of connected components
     */
    public prop componentCount: Int64 {
        get() { this._components }
    }

    /**
     * @brief[zh-cn] 新增一个元素（自成一个集合），返回其下标
     * @return[zh-cn] 新元素下标
     *
     * @brief[en] Adds an element (as its own set) and returns its index
     * @return[en] Index of the new element
     */
    public func makeSet(): Int64 {
        let idx = this._parent.size
        this._parent.add(idx)
        this._rank.add(0)
        this._components += 1
        return idx
    }

    /**
     * @brief[zh-cn] 查找元素所属集合的代表元（路径压缩）
     * @param[zh-cn] x 元素下标
     * @return[zh-cn] 代表元下标
     *
     * @brief[en] Finds the representative of the set containing an element (path compression)
     * @param[en] x Element index
     * @return[en] Representative index
     */
    public func find(x: Int64): Int64 {
        var root = x
        while (this._parent[root] != root) {
            root = this._parent[root]
        }
        // 路径压缩：把路径上的所有节点直接挂到根
        var cur = x
        while (this._parent[cur] != root) {
            let next = this._parent[cur]
            this._parent[cur] = root
            cur = next
        }
        return root
    }

    /**
     * @brief[zh-cn] 合并两个元素所属的集合（按秩合并）
     * @param[zh-cn] a 元素下标
     * b 元素下标
     * @return[zh-cn] 合并发生在不同集合时返回 true
     *
     * @brief[en] Merges the sets containing two elements (union by rank)
     * @param[en] a Element index
     * b Element index
     * @return[en] True when the merge joined two distinct sets
     */
    public func union(a: Int64, b: Int64): Bool {
        let ra = this.find(a)
        let rb = this.find(b)
        if (ra == rb) {
            return false
        }
        let rankA = this._rank[ra]
        let rankB = this._rank[rb]
        if (rankA < rankB) {
            this._parent[ra] = rb
        } else if (rankA > rankB) {
            this._parent[rb] = ra
        } else {
            this._parent[rb] = ra
            this._rank[ra] = rankA + 1
        }
        this._components -= 1
        return true
    }

    /**
     * @brief[zh-cn] 判断两个元素是否属于同一集合
     * @param[zh-cn] a 元素下标
     * b 元素下标
     * @return[zh-cn] 是否同属一个集合
     *
     * @brief[en] Whether two elements belong to the same set
     * @param[en] a Element index
     * b Element index
     * @return[en] Whether they are in the same set
     */
    public func connected(a: Int64, b: Int64): Bool {
        return this.find(a) == this.find(b)
    }

    /**
     * @brief[zh-cn] 重置为指定元素个数（全部自成一个集合）
     * @param[zh-cn] size 元素个数
     *
     * @brief[en] Resets to the given number of elements (each in its own set)
     * @param[en] size Number of elements
     */
    public func reset(size: Int64): Unit {
        this._parent.clear()
        this._rank.clear()
        this._components = 0
        for (_ in 0..size) {
            this.makeSet()
        }
    }
}
