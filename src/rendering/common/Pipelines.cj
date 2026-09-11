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
 * @file[zh-cn] 管线集合
 * @brief[zh-cn] 管线集合管理器，管理多个 Pipeline 实例
 * @explain[zh-cn] 
 * Pipelines 继承自 DataMap，使用 HashMap<Int64, Pipeline> 按 ID 管理 Pipeline 实例，
 * 提供增删查清等操作。
 *
 * @file[en] Pipelines
 * @brief[en] Pipeline collection manager, managing multiple Pipeline instances
 * @explain[en] 
 * Pipelines extends DataMap, using HashMap<Int64, Pipeline> to manage Pipeline instances by ID,
 * providing add, remove, get, and clear operations.
 */
package three.rendering.common

import std.collection.*

/**
 * @brief[zh-cn] 管线集合管理器
 * @explain[zh-cn] 
 * 使用 HashMap 按 ID 管理 Pipeline 实例，提供增删查清操作。
 *
 * @brief[en] Pipeline collection manager
 * @explain[en] 
 * Uses HashMap to manage Pipeline instances by ID, providing add, remove, get, and clear operations.
 */
public open class Pipelines <: DataMap {
    /**
     * @brief[zh-cn] 管线映射表
     *
     * @brief[en] Pipeline map
     */
    public var pipelines: HashMap<Int64, Pipeline>

    /**
     * @brief[zh-cn] 构造默认管线集合
     *
     * @brief[en] Constructs a default pipelines collection
     */
    public init() {
        super()
        this.pipelines = HashMap<Int64, Pipeline>()
    }

    /**
     * @brief[zh-cn] 按 ID 获取管线
     * @param[zh-cn] id 管线标识符
     * @return[zh-cn] 管线实例
     *
     * @brief[en] Gets a pipeline by ID
     * @param[en] id Pipeline identifier
     * @return[en] Pipeline instance
     */
    public func get(id: Int64): Pipeline { return this.pipelines.get(id).getOrThrow() }

    /**
     * @brief[zh-cn] 添加管线到集合
     * @param[zh-cn] pipeline 管线实例
     *
     * @brief[en] Adds a pipeline to the collection
     * @param[en] pipeline Pipeline instance
     */
    public func add(pipeline: Pipeline): Unit { this.pipelines.add(pipeline.id, pipeline) }

    /**
     * @brief[zh-cn] 按 ID 移除管线
     * @param[zh-cn] id 管线标识符
     *
     * @brief[en] Removes a pipeline by ID
     * @param[en] id Pipeline identifier
     */
    public func remove(id: Int64): Unit { this.pipelines.remove(id) }

    /**
     * @brief[zh-cn] 清空所有管线
     *
     * @brief[en] Clears all pipelines
     */
    public func clear(): Unit { this.pipelines = HashMap<Int64, Pipeline>() }
}
