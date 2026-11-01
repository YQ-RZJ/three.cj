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
 * @file[zh-cn] 树状数组
 * @brief[zh-cn] 支持单点增量 + 前缀和查询的数据结构（O(log n)）
 * @explain[zh-cn] 引擎中"动态排名 / 前缀统计"类问题的通用基础设施：
 *             - 渲染列表按深度排序后的动态分位统计（取前 k% 的对象）
 *             - LOD 分级：按视距统计落在某距离内的对象数量
 *             - 场景分层管理：按层级统计对象数
 *             与"每次重新扫描全部元素求和"的朴素做法相比，单点更新与前缀和
 *             查询都只需 O(log n)。
 *
 * @file[en] Fenwick tree (binary indexed tree)
 * @brief[en] Data structure supporting point increments and prefix-sum queries (O(log n))
 * @explain[en] General infrastructure for "dynamic ranking / prefix statistics" problems
 *             in the engine:
 *             - Dynamic quantile statistics over a depth-sorted render list (taking the
 *               top k% of objects)
 *             - LOD tiering: counting the objects within a given view distance
 *             - Scene tier management: counting objects per tier
 *             Compared with the naive "rescan all elements and sum" approach, both
 *             point updates and prefix-sum queries take only O(log n).
 */

package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 树状数组
 * @explain[zh-cn] 下标从 1 开始（0 号位置保留）。add 在下标 i 上增量 delta；
 *             prefixSum(i) 返回 [1, i] 的和。
 *
 * @brief[en] Fenwick tree
 * @explain[en] Indices start at 1 (position 0 is reserved). add increments index i by
 *             delta; prefixSum(i) returns the sum over [1, i].
 */
public class FenwickTree {
    /**
     * @brief[zh-cn] 树状数组存储（下标从 1 开始）
     *
     * @brief[en] Backing storage (1-based indices)
     */
    private var _tree: ArrayList<Int64> = ArrayList<Int64>()
    /**
     * @brief[zh-cn] 元素个数
     *
     * @brief[en] Number of elements
     */
    private var _n: Int64 = 0

    /**
     * @brief[zh-cn] 构造空树
     *
     * @brief[en] Constructs an empty tree
     */
    public init() {}

    /**
     * @brief[zh-cn] 构造指定元素个数的树（初值全 0）
     * @param[zh-cn] size 元素个数
     *
     * @brief[en] Constructs a tree with the given number of elements (all zero)
     * @param[en] size Number of elements
     */
    public init(size: Int64) {
        this.reset(size)
    }

    /**
     * @brief[zh-cn] 元素个数
     *
     * @brief[en] Number of elements
     */
    public prop size: Int64 {
        get() { this._n }
    }

    /**
     * @brief[zh-cn] 重置为指定元素个数（初值全 0）
     * @param[zh-cn] size 元素个数
     *
     * @brief[en] Resets to the given number of elements (all zero)
     * @param[en] size Number of elements
     */
    public func reset(size: Int64): Unit {
        this._n = size
        this._tree.clear()
        // 0 号位置保留：下标从 1 开始
        for (_ in 0..size + 1) {
            this._tree.add(0)
        }
    }

    /**
     * @brief[zh-cn] 单点增量
     * @param[zh-cn] index 下标（1..n）
     * delta 增量
     *
     * @brief[en] Point increment
     * @param[en] index Index (1..n)
     * delta Delta
     */
    public func add(index: Int64, delta: Int64): Unit {
        if (index < 1 || index > this._n) {
            return
        }
        var i = index
        while (i <= this._n) {
            this._tree[i] += delta
            i += i & (-i)
        }
    }

    /**
     * @brief[zh-cn] 查询单点的值
     * @param[zh-cn] index 下标（1..n）
     * @return[zh-cn] 该位置当前的值
     *
     * @brief[en] Queries the value at a single position
     * @param[en] index Index (1..n)
     * @return[en] The current value at that position
     */
    public func query(index: Int64): Int64 {
        if (index < 1 || index > this._n) {
            return 0
        }
        // 单点值 = prefixSum(index) - prefixSum(index-1)
        return this.prefixSum(index) - this.prefixSum(index - 1)
    }

    /**
     * @brief[zh-cn] 前缀和 [1, index]
     * @param[zh-cn] index 上界（1..n）
     * @return[zh-cn] 前缀和
     *
     * @brief[en] Prefix sum over [1, index]
     * @param[en] index Upper bound (1..n)
     * @return[en] The prefix sum
     */
    public func prefixSum(index: Int64): Int64 {
        // 形参不可变：先拷贝到局部变量再夹紧到合法区间
        var idx = index
        if (idx > this._n) {
            idx = this._n
        }
        if (idx < 1) {
            return 0
        }
        var sum = 0
        var i = idx
        while (i > 0) {
            sum += this._tree[i]
            i -= i & (-i)
        }
        return sum
    }

    /**
     * @brief[zh-cn] 区间和 [left, right]
     * @param[zh-cn] left 左界（1..n）
     * right 右界（1..n）
     * @return[zh-cn] 区间和
     *
     * @brief[en] Range sum over [left, right]
     * @param[en] left Left bound (1..n)
     * right Right bound (1..n)
     * @return[en] The range sum
     */
    public func rangeSum(left: Int64, right: Int64): Int64 {
        if (left > right) {
            return 0
        }
        return this.prefixSum(right) - this.prefixSum(left - 1)
    }

    /**
     * @brief[zh-cn] 二分查找最小的、其前缀和不小于 target 的下标
     * @explain[zh-cn] 依赖"所有增量为非负"这一常见前提（计数场景天然满足）。
     * @param[zh-cn] target 目标前缀和
     * @return[zh-cn] 满足前缀和 >= target 的最小下标；总和不足时返回 n+1
     *
     * @brief[en] Binary-searches the smallest index whose prefix sum is at least target
     * @explain[en] Relies on the common precondition that all increments are non-negative
     *               (naturally satisfied in counting scenarios).
     * @param[en] target Target prefix sum
     * @return[en] The smallest index whose prefix sum is >= target; n+1 if the total is insufficient
     */
    public func lowerBound(target: Int64): Int64 {
        var pos = 0
        var remaining = target
        var step = 1
        // 找到不小于 n 的最大 2 的幂
        while (step * 2 <= this._n) {
            step *= 2
        }
        while (step > 0) {
            let next = pos + step
            if (next <= this._n && this._tree[next] < remaining) {
                pos = next
                remaining -= this._tree[next]
            }
            step /= 2
        }
        return pos + 1
    }
}
