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
 * @file[zh-cn] 数据映射
 * @brief[zh-cn] 通用键值数据映射基类，提供按 ID 存储和查找元数据
 * @explain[zh-cn] 
 * DataMap 是渲染系统中多个组件的公共基类，使用 HashMap<Int64, HashMap<String, Any>>
 * 按递增 ID 存储元数据。子类包括 Attributes、Geometries、Textures 等。
 * 对应 Three.js 中的 DataMap 弱引用映射模式，仓颉侧用 ID 映射替代。
 *
 * @file[en] DataMap
 * @brief[en] Generic key-value data mapping base class, providing ID-based metadata storage and lookup
 * @explain[en] 
 * DataMap is the common base class for multiple components in the rendering system, using HashMap<Int64, HashMap<String, Any>>
 * to store metadata by incrementing ID. Subclasses include Attributes, Geometries, Textures, etc.
 * Corresponds to the DataMap weak-reference mapping pattern in Three.js; the Cangjie side uses ID mapping as a replacement.
 */
package three.rendering.common

import std.collection.*

/**
 * @brief[zh-cn] 通用键值数据映射基类
 * @explain[zh-cn] 
 * 使用 HashMap<Int64, HashMap<String, Any>> 按 ID 存储元数据，
 * 是 Attributes、Geometries、Textures 等组件的公共基类。
 *
 * @brief[en] Generic key-value data mapping base class
 * @explain[en] 
 * Uses HashMap<Int64, HashMap<String, Any>> to store metadata by ID,
 * serving as the common base class for components like Attributes, Geometries, and Textures.
 */
public open class DataMap {
    /**
     * @brief[zh-cn] 内部数据存储
     *
     * @brief[en] Internal data storage
     */
    private var data: HashMap<Int64, HashMap<String, Any>>

    /**
     * @brief[zh-cn] 下一个可用 ID
     *
     * @brief[en] Next available ID
     */
    private var nextId: Int64

    /**
     * @brief[zh-cn] 构造空数据映射
     *
     * @brief[en] Constructs an empty data map
     */
    public init() { this.data = HashMap<Int64, HashMap<String, Any>>(); this.nextId = 0 }

    /**
     * @brief[zh-cn] 获取指定键对应的值映射
     * @param[zh-cn] key 查找键
     * @return[zh-cn] 键对应的值映射
     *
     * @brief[en] Gets the value map for the specified key
     * @param[en] key Lookup key
     * @return[en] Value map for the key
     */
    public func get(key: String): HashMap<String, Any> {
        let id = this.nextId; this.nextId += 1
        let existing = this.data.get(id)
        match (existing) {
            case Some(map) => return map
            case None => let map = HashMap<String, Any>(); this.data.add(id, map); return map
        }
    }

    /**
     * @brief[zh-cn] 检查是否存在指定键
     * @param[zh-cn] key 查找键
     * @return[zh-cn] 是否存在
     *
     * @brief[en] Checks whether the specified key exists
     * @param[en] key Lookup key
     * @return[en] Whether the key exists
     */
    public func has(key: String): Bool { return false }

    /**
     * @brief[zh-cn] 删除指定键
     * @param[zh-cn] key 要删除的键
     *
     * @brief[en] Deletes the specified key
     * @param[en] key Key to delete
     */
    public func delete(key: String): Unit { let id = this.nextId; this.data.remove(id) }

    /**
     * @brief[zh-cn] 释放所有数据
     *
     * @brief[en] Disposes all data
     */
    public func dispose(): Unit { this.data = HashMap<Int64, HashMap<String, Any>>() }
}
