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
 * @file[zh-cn] 链式映射
 * @brief[zh-cn] 链式键值映射，按优先级在多个 DataMap 中查找键
 * @explain[zh-cn] 
 * ChainMap 维护一个 DataMap 列表，查找时按添加顺序逐个搜索，
 * 返回第一个匹配的结果。类似于作用域链的查找机制。
 *
 * @file[en] ChainMap
 * @brief[en] Chained key-value map, looking up keys across multiple DataMaps by priority
 * @explain[en] 
 * ChainMap maintains a list of DataMaps and searches them in insertion order,
 * returning the first match. This is similar to the scope chain lookup mechanism.
 */
package three.rendering.common

import std.collection.*

/**
 * @brief[zh-cn] 链式键值映射，按优先级在多个 DataMap 中查找键
 * @explain[zh-cn] 
 * 维护一个 DataMap 列表，查找时按添加顺序逐个搜索，返回第一个匹配的结果。
 *
 * @brief[en] Chained key-value map, looking up keys across multiple DataMaps by priority
 * @explain[en] 
 * Maintains a list of DataMaps, searching in insertion order and returning the first match.
 */
public open class ChainMap {
    /**
     * @brief[zh-cn] 内部 DataMap 列表
     *
     * @brief[en] Internal DataMap list
     */
    private var maps: ArrayList<DataMap>

    /**
     * @brief[zh-cn] 构造空链式映射
     *
     * @brief[en] Constructs an empty chain map
     */
    public init() { this.maps = ArrayList<DataMap>() }

    /**
     * @brief[zh-cn] 添加 DataMap 到链尾
     * @param[zh-cn] map 要添加的 DataMap
     *
     * @brief[en] Adds a DataMap to the end of the chain
     * @param[en] map DataMap to add
     */
    public func addMap(map: DataMap): Unit { this.maps.add(map) }

    /**
     * @brief[zh-cn] 按链顺序查找键对应的值
     * @param[zh-cn] key 查找键
     * @return[zh-cn] 找到的值映射，未找到返回 None
     *
     * @brief[en] Looks up a key in chain order
     * @param[en] key Lookup key
     * @return[en] Found value map, or None if not found
     */
    public func get(key: String): Option<HashMap<String, Any>> {
        for (map in this.maps) { if (map.has(key)) { return Some(map.get(key)) } }
        return Option<HashMap<String, Any>>.None
    }

    /**
     * @brief[zh-cn] 检查链中是否存在指定键
     * @param[zh-cn] key 查找键
     * @return[zh-cn] 是否存在
     *
     * @brief[en] Checks whether the specified key exists in the chain
     * @param[en] key Lookup key
     * @return[en] Whether the key exists
     */
    public func has(key: String): Bool { for (map in this.maps) { if (map.has(key)) { return true } }; return false }

    /**
     * @brief[zh-cn] 从链中所有 DataMap 删除指定键
     * @param[zh-cn] key 要删除的键
     *
     * @brief[en] Deletes the specified key from all DataMaps in the chain
     * @param[en] key Key to delete
     */
    public func delete(key: String): Unit { for (map in this.maps) { map.delete(key) } }
}
