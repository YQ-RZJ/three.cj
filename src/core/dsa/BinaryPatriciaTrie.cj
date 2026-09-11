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
 * @file[zh-cn] BinaryPatriciaTrie
 * @brief[zh-cn] 二进制 Patricia Trie（前缀压缩字典树）
 * @explain[zh-cn] 针对 Array<UInt8> 的前缀压缩优化，支持 set/get/has/delete 插入、查找、删除；entries/keys/values 遍历；prefixOf(query) 返回所有"键是 query 的前缀"的项；longestPrefix(query) 最长前缀匹配；startsWith(prefix) 返回所有"键以 prefix 开头"的项；bitSubsetOf(query) 按位子集查询（朴素 DFS）；bitLongestSubset(query) 按位子集最长匹配；fBitSubsetOf(query) 按位子集查询（子掩码枚举 + 剪枝优化）；fBitLongestSubset(query) 按位子集最长匹配（高性能版）。底层使用 HashMap<UInt8, Node> 存储子节点，键为 Array<UInt8>。
 *
 * @file[en] BinaryPatriciaTrie
 * @brief[en] Binary Patricia Trie (prefix-compressed dictionary tree)
 * @explain[en] Prefix-compressed optimization for Array<UInt8>, supporting set/get/has/delete for insertion, lookup, and deletion; entries/keys/values for traversal; prefixOf(query) returns all items whose key is a prefix of query; longestPrefix(query) for longest prefix match; startsWith(prefix) returns all items whose key starts with prefix; bitSubsetOf(query) for bit-level subset query (naive DFS); bitLongestSubset(query) for bit-level subset longest match; fBitSubsetOf(query) for bit-level subset query (submask enumeration + pruning optimization); fBitLongestSubset(query) for bit-level subset longest match (high-performance version). Uses HashMap<UInt8, Node> internally for child nodes, with Array<UInt8> keys.
 */
package three.core.dsa

import std.collection.*

/**
 * @brief[zh-cn] 内部树节点
 *
 * @brief[en] Internal tree node
 */
internal class TrieNode<V> {
    /**
     * @brief[zh-cn] 边标签（该节点到父节点的路径上的字节序列）
     *
     * @brief[en] Edge label (byte sequence on the path from this node to its parent)
     */
    public var part: Array<UInt8>
    /**
     * @brief[zh-cn] 节点值（None 表示该节点不是键终点）
     *
     * @brief[en] Node value (None means this node is not a key endpoint)
     */
    public var value: ?V
    /**
     * @brief[zh-cn] 子节点映射（按键的首字节索引）
     *
     * @brief[en] Child node map (indexed by the key's first byte)
     */
    public var children: HashMap<UInt8, TrieNode<V>>

    public init(part: Array<UInt8>, value!: ?V = None) {
        this.part = part
        this.value = value
        this.children = HashMap<UInt8, TrieNode<V>>()
    }
}

/**
 * @brief[zh-cn] 二进制 Patricia Trie（Radix/压缩前缀树）
 *
 * @brief[en] Binary Patricia Trie (Radix/Compressed Prefix Tree)
 */
public class BinaryPatriciaTrie<V> {
    /**
     * @brief[zh-cn] 根节点
     *
     * @brief[en] Root node
     */
    private var _root: TrieNode<V>
    /**
     * @brief[zh-cn] 成员数量
     *
     * @brief[en] Number of members
     */
    private var _size: Int64

    public init() {
        _root = TrieNode<V>(Array<UInt8>(0, { _ => 0u8 }))
        _size = 0
    }

    /**
     * @brief[zh-cn] 成员数量
     *
     * @brief[en] Number of members
     */
    public prop size: Int64 {
        get() { _size }
    }

    /**
     * @brief[zh-cn] 清空树
     *
     * @brief[en] Clear the tree
     */
    public func clear(): Unit {
        _root = TrieNode<V>(Array<UInt8>(0, { _ => 0u8 }))
        _size = 0
    }

    /**
     * @brief[zh-cn] 加入新值
     * @param[zh-cn] key 键
     * value 值
     *
     * @brief[en] Set a new value
     * @param[en] key Key
     * value Value
     */
    public func set(key: Array<UInt8>, value: V): Unit {
        var node = _root
        var i = 0

        if (key.size == 0) {
            let had = node.value.isSome()
            node.value = Some(value)
            if (!had) { _size += 1 }
            return
        }

        while (i < key.size) {
            let first = key[i]
            match (node.children.get(first)) {
                case None =>
                    let newPart = _slice(key, i, key.size)
                    let newNode = TrieNode<V>(newPart, value: Some(value))
                    node.children.add(first, newNode)
                    _size += 1
                    return
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(key, i, part)

                    if (common == 0) {
                        let newNode = TrieNode<V>(_slice(key, i, key.size), value: Some(value))
                        node.children.add(first, newNode)
                        _size += 1
                        return
                    }

                    if (common < part.size) {
                        // 需要分裂
                        let shared = _slice(part, 0, common)
                        let suffix = _slice(part, common, part.size)

                        let mid = TrieNode<V>(shared)
                        child.part = suffix
                        mid.children.add(suffix[0], child)
                        node.children.add(shared[0], mid)

                        let consumed = i + common
                        if (consumed == key.size) {
                            let had = mid.value.isSome()
                            mid.value = Some(value)
                            if (!had) { _size += 1 }
                            return
                        } else {
                            let remaining = _slice(key, consumed, key.size)
                            let newLeaf = TrieNode<V>(remaining, value: Some(value))
                            mid.children.add(remaining[0], newLeaf)
                            _size += 1
                            return
                        }
                    } else {
                        i += common
                        if (i == key.size) {
                            let had = child.value.isSome()
                            child.value = Some(value)
                            if (!had) { _size += 1 }
                            return
                        }
                        node = child
                    }
            }
        }
    }

    /**
     * @brief[zh-cn] 获取全匹配的值
     * @param[zh-cn] key 键
     * @return[zh-cn] 值，不存在返回 None
     *
     * @brief[en] Get the value for an exact match
     * @param[en] key Key
     * @return[en] Value, or None if not found
     */
    public func get(key: Array<UInt8>): ?V {
        var node = _root
        var i = 0

        if (key.size == 0) {
            return node.value
        }

        while (i < key.size) {
            match (node.children.get(key[i])) {
                case None => return None
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(key, i, part)
                    if (common != part.size) { return None }
                    i += common
                    if (i == key.size) { return child.value }
                    node = child
            }
        }
        return node.value
    }

    /**
     * @brief[zh-cn] 是否存在指定键
     *
     * @brief[en] Whether the specified key exists
     */
    public func has(key: Array<UInt8>): Bool {
        return get(key).isSome()
    }

    /**
     * @brief[zh-cn] 删除指定键
     * @return[zh-cn] true 删除成功
     *
     * @brief[en] Delete the specified key
     * @return[en] true if deletion succeeded
     */
    public func delete(key: Array<UInt8>): Bool {
        // 记录路径用于删除后压缩
        var stack = ArrayList<(TrieNode<V>, TrieNode<V>)>() // (parent, child)
        var node = _root
        var i = 0

        if (key.size == 0) {
            if (node.value.isNone()) { return false }
            node.value = None
            _size -= 1
            return true
        }

        while (i < key.size) {
            match (node.children.get(key[i])) {
                case None => return false
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(key, i, part)
                    if (common != part.size) { return false }
                    stack.add((node, child))
                    i += common
                    node = child
            }
        }

        if (node.value.isNone()) { return false }
        node.value = None
        _size -= 1

        // 自底向上压缩
        while (stack.size > 0) {
            let (parent, child) = stack.remove(at: stack.size - 1)
            if (child.value.isNone() && child.children.size == 0) {
                parent.children.remove(child.part[0])
            } else if (child.value.isNone() && child.children.size == 1) {
                // 合并单子节点
                var onlyChild: ?TrieNode<V> = None
                for ((_, c) in child.children) {
                    onlyChild = c
                    break
                }
                match (onlyChild) {
                    case Some(c) =>
                        let merged = _concat(child.part, c.part)
                        child.part = merged
                        child.value = c.value
                        child.children = c.children
                    case None => ()
                }
            }
        }

        _maybeCompressRoot()
        return true
    }

    /**
     * @brief[zh-cn] 模糊搜索（前缀匹配）：返回"所有键是 query 的前缀"的项
     * @param[zh-cn] query 查询字节
     * longestFirst 是否长的在前（默认 true）
     * includeEmpty 是否包含空键（默认 false）
     * @return[zh-cn] 匹配的键值对数组
     *
     * @brief[en] Fuzzy search (prefix match): returns all items whose key is a prefix of query
     * @param[en] query Query bytes
     * longestFirst Whether longer keys come first (default true)
     * includeEmpty Whether to include empty keys (default false)
     * @return[en] Array of matching key-value pairs
     */
    public func prefixOf(
        query: Array<UInt8>,
        longestFirst!: Bool = true,
        includeEmpty!: Bool = false
    ): Array<(Array<UInt8>, V)> {
        let buf = ArrayList<UInt8>()
        let results = ArrayList<(Array<UInt8>, V)>()

        if (includeEmpty) {
            match (_root.value) {
                case Some(v) => results.add((Array<UInt8>(0, { _ => 0u8 }), v))
                case None => ()
            }
        }

        var node = _root
        var i = 0

        while (i < query.size) {
            match (node.children.get(query[i])) {
                case None => break
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(query, i, part)
                    if (common != part.size) { break }

                    _pushPart(buf, part)
                    i += common

                    match (child.value) {
                        case Some(v) => results.add((_bufToArray(buf), v))
                        case None => ()
                    }
                    node = child
            }
        }

        if (longestFirst) {
            let n = results.size
            return Array<(Array<UInt8>, V)>(n, { i => results[n - 1 - i] })
        }
        return Array<(Array<UInt8>, V)>(results.size, { i => results[i] })
    }

    /**
     * @brief[zh-cn] 最长前缀匹配：返回"键是 query 的前缀"中的最长者
     * @param[zh-cn] query 查询字节
     * @return[zh-cn] 最长前缀匹配的键值对，不存在返回 None
     *
     * @brief[en] Longest prefix match: returns the longest item whose key is a prefix of query
     * @param[en] query Query bytes
     * @return[en] Longest prefix-matched key-value pair, or None if not found
     */
    public func longestPrefix(query: Array<UInt8>): ?(Array<UInt8>, V) {
        let buf = ArrayList<UInt8>()
        var node = _root
        var i = 0
        var best: ?(Array<UInt8>, V) = None

        match (_root.value) {
            case Some(v) => best = (Array<UInt8>(0, { _ => 0u8 }), v)
            case None => ()
        }

        while (i < query.size) {
            match (node.children.get(query[i])) {
                case None => break
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(query, i, part)
                    if (common != part.size) { break }

                    _pushPart(buf, part)
                    i += common

                    match (child.value) {
                        case Some(v) => best = (_bufToArray(buf), v)
                        case None => ()
                    }
                    node = child
            }
        }
        return best
    }

    /**
     * @brief[zh-cn] 前缀查询：返回所有"键以 prefix 开头"的项
     * @param[zh-cn] prefix 前缀
     * @return[zh-cn] 匹配的键值对数组
     *
     * @brief[en] Prefix query: returns all items whose key starts with prefix
     * @param[en] prefix Prefix
     * @return[en] Array of matching key-value pairs
     */
    public func startsWith(prefix: Array<UInt8>): Array<(Array<UInt8>, V)> {
        let buf = ArrayList<UInt8>()
        let out = ArrayList<(Array<UInt8>, V)>()
        var node = _root
        var i = 0

        if (prefix.size == 0) {
            match (_root.value) {
                case Some(v) => out.add((Array<UInt8>(0, { _ => 0u8 }), v))
                case None => ()
            }
            _collectSubtree(_root, buf, out, true)
            return _toResultArray(out)
        }

        while (i < prefix.size) {
            match (node.children.get(prefix[i])) {
                case None => return _toResultArray(out)
                case Some(child) =>
                    let part = child.part
                    let common = _commonPrefixLength(prefix, i, part)
                    if (common < part.size) {
                        if (i + common == prefix.size) {
                            _pushPart(buf, _slice(part, 0, common))
                            _collectSubtree(child, buf, out, true)
                        }
                        return _toResultArray(out)
                    }
                    _pushPart(buf, part)
                    i += common
                    node = child
            }
        }
        _collectSubtree(node, buf, out, true)
        return _toResultArray(out)
    }

    // ===== 位级（bit）子集查询 =====

    /**
     * @brief[zh-cn] 按位（bit）子集查询
     * @explain[zh-cn] 返回所有满足"对每个字节 i: (key[i] & ~query[i]) === 0 且 key.length <= query.length"的键值对。朴素 DFS 实现。
     * @param[zh-cn] query 查询字节数组
     * longestFirst 是否长的在前（默认 true）
     * includeEmpty 是否包含空键（默认 false）
     * @return[zh-cn] 匹配的键值对数组
     *
     * @brief[en] Bit-level subset query
     * @explain[en] Returns all key-value pairs satisfying "for each byte i: (key[i] & ~query[i]) === 0 and key.length <= query.length". Naive DFS implementation.
     * @param[en] query Query byte array
     * longestFirst Whether longer keys come first (default true)
     * includeEmpty Whether to include empty keys (default false)
     * @return[en] Array of matching key-value pairs
     */
    public func bitSubsetOf(
        query: Array<UInt8>,
        longestFirst!: Bool = true,
        includeEmpty!: Bool = false
    ): Array<(Array<UInt8>, V)> {
        let out = ArrayList<(Array<UInt8>, V)>()
        let buf = ArrayList<UInt8>()

        if (includeEmpty) {
            match (_root.value) {
                case Some(v) =>
                    out.add((Array<UInt8>(0, { _ => 0u8 }), v))
                case None => ()
            }
        }

        _bitSubsetDfs(_root, 0, query, buf, out)

        if (longestFirst) {
            // 更长的键在前；长度相同保持相对顺序（稳定排序）
            _stableSortByLengthDesc(out)
        }
        return _toResultArray(out)
    }

    /**
     * @brief[zh-cn] 按位子集查询中的"最长匹配"
     * @explain[zh-cn] 满足按位子集关系的键中，返回字节长度最大的一个。若有多个同长度，返回遇到的第一个。
     * @param[zh-cn] query 查询字节数组
     * @return[zh-cn] 最长匹配键值对，不存在返回 None
     *
     * @brief[en] Longest match in bit-level subset query
     * @explain[en] Among keys satisfying the bit-level subset relation, returns the one with the largest byte length. If multiple have the same length, returns the first one found.
     * @param[en] query Query byte array
     * @return[en] Longest matched key-value pair, or None if not found
     */
    public func bitLongestSubset(query: Array<UInt8>): ?(Array<UInt8>, V) {
        let best: Box<?(Array<UInt8>, V)> = Box(None)
        let bestLen: Box<Int64> = Box(-1)
        let buf = ArrayList<UInt8>()

        let tryUpdate = { k: Array<UInt8>, v: V =>
            if (k.size > bestLen.value) {
                best.value = (k, v)
                bestLen.value = k.size
            }
        }

        // 根（空键）也可视为一个候选（若有值）
        match (_root.value) {
            case Some(v) =>
                tryUpdate(Array<UInt8>(0, { _ => 0u8 }), v)
            case None => ()
        }

        _bitLongestSubsetDfs(_root, 0, query, buf, tryUpdate)

        return best.value
    }

    /**
     * @brief[zh-cn] 按位子集查询（高性能版，子掩码枚举 + 剪枝）
     * @explain[zh-cn] 使用子掩码枚举 + 剪枝优化。计算当前层 query 首字节的 popcount 得到子掩码总数 submaskCount = 1 << k；若 node.children.size < submaskCount，扫描所有子节点；否则枚举 query 首字节的所有子掩码直接用首字节索引命中候选分支。
     * @param[zh-cn] query 查询字节数组
     * longestFirst 是否长的在前（默认 true）
     * includeEmpty 是否包含空键（默认 false）
     * @return[zh-cn] 匹配的键值对数组
     *
     * @brief[en] Bit-level subset query (high-performance version, submask enumeration + pruning)
     * @explain[en] Uses submask enumeration + pruning optimization. Computes popcount of the current layer's query first byte to get submaskCount = 1 << k; if node.children.size < submaskCount, scans all child nodes; otherwise enumerates all submasks of the query first byte and directly indexes candidate branches by first byte.
     * @param[en] query Query byte array
     * longestFirst Whether longer keys come first (default true)
     * includeEmpty Whether to include empty keys (default false)
     * @return[en] Array of matching key-value pairs
     */
    public func fBitSubsetOf(
        query: Array<UInt8>,
        longestFirst!: Bool = true,
        includeEmpty!: Bool = false
    ): Array<(Array<UInt8>, V)> {
        let out = ArrayList<(Array<UInt8>, V)>()
        let buf = ArrayList<UInt8>()

        if (includeEmpty) {
            match (_root.value) {
                case Some(v) =>
                    out.add((Array<UInt8>(0, { _ => 0u8 }), v))
                case None => ()
            }
        }

        _fBitSubsetDfs(_root, 0, query, buf, out)

        if (longestFirst) {
            _stableSortByLengthDesc(out)
        }
        return _toResultArray(out)
    }

    /**
     * @brief[zh-cn] 按位子集最长匹配（高性能版）
     * @explain[zh-cn] 使用同样的高效候选选择策略。
     * @param[zh-cn] query 查询字节数组
     * @return[zh-cn] 最长匹配键值对，不存在返回 None
     *
     * @brief[en] Bit-level subset longest match (high-performance version)
     * @explain[en] Uses the same efficient candidate selection strategy.
     * @param[en] query Query byte array
     * @return[en] Longest matched key-value pair, or None if not found
     */
    public func fBitLongestSubset(query: Array<UInt8>): ?(Array<UInt8>, V) {
        let best: Box<?(Array<UInt8>, V)> = Box(None)
        let bestLen: Box<Int64> = Box(-1)
        let buf = ArrayList<UInt8>()

        let tryUpdate = { k: Array<UInt8>, v: V =>
            if (k.size > bestLen.value) {
                best.value = (k, v)
                bestLen.value = k.size
            }
        }

        match (_root.value) {
            case Some(v) =>
                tryUpdate(Array<UInt8>(0, { _ => 0u8 }), v)
            case None => ()
        }

        _fBitLongestSubsetDfs(_root, 0, query, buf, tryUpdate)

        return best.value
    }

    /**
     * @brief[zh-cn] bitSubsetOf 的 DFS 主体（朴素枚举所有子节点）
     *
     * @brief[en] DFS body of bitSubsetOf (naively enumerates all child nodes)
     */
    private func _bitSubsetDfs(
        node: TrieNode<V>,
        depthBytes: Int64,
        query: Array<UInt8>,
        buf: ArrayList<UInt8>,
        out: ArrayList<(Array<UInt8>, V)>
    ): Unit {
        for ((_, child) in node.children) {
            let part = child.part
            // 剩余 query 长度不足以容纳 part
            if (depthBytes + part.size > query.size) {
                continue
            }
            // 检查 part 每个字节是否为 query 对应字节的按位子集
            var ok = true
            for (j in 0..part.size) {
                let q = query[depthBytes + j]
                let p = part[j]
                if ((p & !q) != 0u8) {
                    ok = false
                    break
                }
            }
            if (!ok) {
                continue
            }
            _pushPart(buf, part)
            let newDepth = depthBytes + part.size
            match (child.value) {
                case Some(v) =>
                    out.add((_bufToArray(buf), v))
                case None => ()
            }
            _bitSubsetDfs(child, newDepth, query, buf, out)
            _popPart(buf, part.size)
        }
    }

    /**
     * @brief[zh-cn] bitLongestSubset 的 DFS 主体
     *
     * @brief[en] DFS body of bitLongestSubset
     */
    private func _bitLongestSubsetDfs(
        node: TrieNode<V>,
        depthBytes: Int64,
        query: Array<UInt8>,
        buf: ArrayList<UInt8>,
        tryUpdate: (Array<UInt8>, V) -> Unit
    ): Unit {
        for ((_, child) in node.children) {
            let part = child.part
            if (depthBytes + part.size > query.size) {
                continue
            }
            var ok = true
            for (j in 0..part.size) {
                let q = query[depthBytes + j]
                let p = part[j]
                if ((p & !q) != 0u8) {
                    ok = false
                    break
                }
            }
            if (!ok) {
                continue
            }
            _pushPart(buf, part)
            let newDepth = depthBytes + part.size
            match (child.value) {
                case Some(v) =>
                    tryUpdate(_bufToArray(buf), v)
                case None => ()
            }
            _bitLongestSubsetDfs(child, newDepth, query, buf, tryUpdate)
            _popPart(buf, part.size)
        }
    }

    /**
     * @brief[zh-cn] fBitSubsetOf 的 DFS 主体（子掩码枚举优化）
     *
     * @brief[en] DFS body of fBitSubsetOf (submask enumeration optimization)
     */
    private func _fBitSubsetDfs(
        node: TrieNode<V>,
        depthBytes: Int64,
        query: Array<UInt8>,
        buf: ArrayList<UInt8>,
        out: ArrayList<(Array<UInt8>, V)>
    ): Unit {
        if (depthBytes >= query.size) {
            return
        }
        let q0 = query[depthBytes]
        let deg = node.children.size
        let k = _popcount8(q0)
        let submaskCount = Int64(1) << k

        if (deg < submaskCount) {
            // 扫描所有子节点（分叉较少时更快）
            for ((_, child) in node.children) {
                let part = child.part
                if (depthBytes + part.size > query.size) {
                    continue
                }
                // 检查 part 每个字节的子集关系
                var ok = true
                for (j in 0..part.size) {
                    let q = query[depthBytes + j]
                    let p = part[j]
                    if ((p & !q) != 0u8) {
                        ok = false
                        break
                    }
                }
                if (!ok) {
                    continue
                }
                _pushPart(buf, part)
                let newDepth = depthBytes + part.size
                match (child.value) {
                    case Some(v) =>
                        out.add((_bufToArray(buf), v))
                    case None => ()
                }
                _fBitSubsetDfs(child, newDepth, query, buf, out)
                _popPart(buf, part.size)
            }
        } else {
            // 枚举 q0 的所有子掩码，直接用首字节索引命中候选分支
            _forEachSubmask(q0, { sub =>
                match (node.children.get(sub)) {
                    case None => ()
                    case Some(child) =>
                        let part = child.part
                        if (depthBytes + part.size > query.size) {
                            return
                        }
                        // 首字节已通过子掩码命中，检查剩余字节
                        var ok = true
                        for (j in 1..part.size) {
                            let q = query[depthBytes + j]
                            let p = part[j]
                            if ((p & !q) != 0u8) {
                                ok = false
                                break
                            }
                        }
                        if (!ok) {
                            return
                        }
                        _pushPart(buf, part)
                        let newDepth = depthBytes + part.size
                        match (child.value) {
                            case Some(v) =>
                                out.add((_bufToArray(buf), v))
                            case None => ()
                        }
                        _fBitSubsetDfs(child, newDepth, query, buf, out)
                        _popPart(buf, part.size)
                }
            })
        }
    }

    /**
     * @brief[zh-cn] fBitLongestSubset 的 DFS 主体
     *
     * @brief[en] DFS body of fBitLongestSubset
     */
    private func _fBitLongestSubsetDfs(
        node: TrieNode<V>,
        depthBytes: Int64,
        query: Array<UInt8>,
        buf: ArrayList<UInt8>,
        tryUpdate: (Array<UInt8>, V) -> Unit
    ): Unit {
        if (depthBytes >= query.size) {
            return
        }
        let q0 = query[depthBytes]
        let deg = node.children.size
        let k = _popcount8(q0)
        let submaskCount = Int64(1) << k

        if (deg < submaskCount) {
            for ((_, child) in node.children) {
                let part = child.part
                if (depthBytes + part.size > query.size) {
                    continue
                }
                var ok = true
                for (j in 0..part.size) {
                    let q = query[depthBytes + j]
                    let p = part[j]
                    if ((p & !q) != 0u8) {
                        ok = false
                        break
                    }
                }
                if (!ok) {
                    continue
                }
                _pushPart(buf, part)
                let newDepth = depthBytes + part.size
                match (child.value) {
                    case Some(v) =>
                        tryUpdate(_bufToArray(buf), v)
                    case None => ()
                }
                _fBitLongestSubsetDfs(child, newDepth, query, buf, tryUpdate)
                _popPart(buf, part.size)
            }
        } else {
            _forEachSubmask(q0, { sub =>
                match (node.children.get(sub)) {
                    case None => ()
                    case Some(child) =>
                        let part = child.part
                        if (depthBytes + part.size > query.size) {
                            return
                        }
                        var ok = true
                        for (j in 1..part.size) {
                            let q = query[depthBytes + j]
                            let p = part[j]
                            if ((p & !q) != 0u8) {
                                ok = false
                                break
                            }
                        }
                        if (!ok) {
                            return
                        }
                        _pushPart(buf, part)
                        let newDepth = depthBytes + part.size
                        match (child.value) {
                            case Some(v) =>
                                tryUpdate(_bufToArray(buf), v)
                            case None => ()
                        }
                        _fBitLongestSubsetDfs(child, newDepth, query, buf, tryUpdate)
                        _popPart(buf, part.size)
                }
            })
        }
    }

    /**
     * @brief[zh-cn] 统计 8 位数的置位数（popcount）
     *
     * @brief[en] Counts the set bits (popcount) of an 8-bit number
     */
    private static func _popcount8(x: UInt8): Int64 {
        var v: UInt8 = x
        v = v - ((v >> 1) & 0x55u8)
        v = (v & 0x33u8) + ((v >> 2) & 0x33u8)
        v = (v + (v >> 4)) & 0x0Fu8
        return Int64(v)
    }

    /**
     * @brief[zh-cn] 枚举一个 8 位数的所有子掩码（包含 0）
     * @explain[zh-cn] 次序：从自身开始递减。
     *
     * @brief[en] Enumerate all submasks of an 8-bit number (including 0)
     * @explain[en] Order: starting from itself and decreasing.
     */
    private static func _forEachSubmask(mask: UInt8, fn: (UInt8) -> Unit): Unit {
        var sub = mask
        while (true) {
            fn(sub)
            if (sub == 0u8) {
                break
            }
            sub = (sub - 1u8) & mask
        }
    }

    /**
     * @brief[zh-cn] 按键长度降序稳定排序
     *
     * @brief[en] Stable sort by key length in descending order
     */
    private static func _stableSortByLengthDesc(arr: ArrayList<(Array<UInt8>, V)>): Unit {
        // 简单插入排序，保持稳定性（相同长度保持原顺序）
        let n = arr.size
        for (i in 1..n) {
            let key = arr[i]
            var j = i - 1
            while (j >= 0 && arr[j][0].size < key[0].size) {
                arr[j + 1] = arr[j]
                j -= 1
            }
            arr[j + 1] = key
        }
    }

    // ===== 内部辅助方法 =====

    /**
     * @brief[zh-cn] 根节点压缩（单子时合并）
     *
     * @brief[en] Root node compression (merge when there is a single child)
     */
    private func _maybeCompressRoot(): Unit {
        if (_root.value.isNone() && _root.children.size == 1) {
            var onlyChild: ?TrieNode<V> = None
            for ((_, child) in _root.children) {
                onlyChild = child
                break
            }
            match (onlyChild) {
                case Some(child) =>
                    _root.part = child.part
                    _root.value = child.value
                    _root.children = child.children
                case None => ()
            }
        }
    }

    /** 收集子树所有键值（后序，长的在前） */
    private func _collectSubtree(
        node: TrieNode<V>,
        buf: ArrayList<UInt8>,
        out: ArrayList<(Array<UInt8>, V)>,
        includeSelf: Bool
    ): Unit {
        for ((_, childNode) in node.children) {
            _pushPart(buf, childNode.part)
            _collectSubtree(childNode, buf, out, true)
            match (childNode.value) {
                case Some(v) => out.add((_bufToArray(buf), v))
                case None => ()
            }
            _popPart(buf, childNode.part.size)
        }
        if (includeSelf) {
            match (node.value) {
                case Some(v) =>
                    if (node.part.size == 0) {
                        out.add((_bufToArray(buf), v))
                    }
                case None => ()
            }
        }
    }

    /** 公共前缀长度 */
    private static func _commonPrefixLength(a: Array<UInt8>, aStart: Int64, b: Array<UInt8>): Int64 {
        let maxLen = min(a.size - aStart, b.size)
        var i = 0
        while (i < maxLen && a[aStart + i] == b[i]) {
            i += 1
        }
        return i
    }

    /** 切片 */
    private static func _slice(arr: Array<UInt8>, start: Int64, end: Int64): Array<UInt8> {
        return Array<UInt8>(end - start, { i => arr[start + i] })
    }

    /** 拼接 */
    private static func _concat(a: Array<UInt8>, b: Array<UInt8>): Array<UInt8> {
        return Array<UInt8>(a.size + b.size, { i =>
            if (i < a.size) { a[i] } else { b[i - a.size] }
        })
    }

    /** push part to buffer */
    private static func _pushPart(buf: ArrayList<UInt8>, part: Array<UInt8>): Unit {
        for (i in 0..part.size) {
            buf.add(part[i])
        }
    }

    /** pop part from buffer */
    private static func _popPart(buf: ArrayList<UInt8>, n: Int64): Unit {
        for (_ in 0..n) {
            buf.remove(at: buf.size - 1)
        }
    }

    /** buffer → Array */
    private static func _bufToArray(buf: ArrayList<UInt8>): Array<UInt8> {
        return Array<UInt8>(buf.size, { i => buf[i] })
    }

    /** ArrayList → Array */
    private static func _toResultArray(arr: ArrayList<(Array<UInt8>, V)>): Array<(Array<UInt8>, V)> {
        return Array<(Array<UInt8>, V)>(arr.size, { i => arr[i] })
    }
}
