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
 * @file[zh-cn] 渲染束集合
 * @brief[zh-cn] 渲染束集合管理器，按 ID 管理 BundleGroup
 * @explain[zh-cn] 
 * RenderBundles 使用 HashMap 按 ID 管理 BundleGroup 实例，
 * 提供增删清操作。
 *
 * @file[en] RenderBundles
 * @brief[en] Render bundles collection manager, managing BundleGroups by ID
 * @explain[en] 
 * RenderBundles uses HashMap to manage BundleGroup instances by ID,
 * providing add, remove, and clear operations.
 */
package three.rendering.common

import std.collection.*

/**
 * @brief[zh-cn] 渲染束集合管理器
 * @explain[zh-cn] 
 * 按 ID 管理 BundleGroup 实例，提供增删清操作。
 *
 * @brief[en] Render bundles collection manager
 * @explain[en] 
 * Manages BundleGroup instances by ID, providing add, remove, and clear operations.
 */
public open class RenderBundles {
    /**
     * @brief[zh-cn] 渲染束映射表
     *
     * @brief[en] Render bundle map
     */
    public var bundles: HashMap<Int64, BundleGroup>

    /**
     * @brief[zh-cn] 构造默认渲染束集合
     *
     * @brief[en] Constructs a default render bundles collection
     */
    public init() { this.bundles = HashMap<Int64, BundleGroup>() }

    /**
     * @brief[zh-cn] 添加渲染束组
     * @param[zh-cn] bundle 渲染束组
     *
     * @brief[en] Adds a bundle group
     * @param[en] bundle Bundle group
     */
    public func add(bundle: BundleGroup): Unit { this.bundles.add(bundle.id, bundle) }

    /**
     * @brief[zh-cn] 移除渲染束组
     * @param[zh-cn] bundle 渲染束组
     *
     * @brief[en] Removes a bundle group
     * @param[en] bundle Bundle group
     */
    public func remove(bundle: BundleGroup): Unit { this.bundles.remove(bundle.id) }

    /**
     * @brief[zh-cn] 清空所有渲染束
     *
     * @brief[en] Clears all render bundles
     */
    public func clear(): Unit { this.bundles = HashMap<Int64, BundleGroup>() }
}
