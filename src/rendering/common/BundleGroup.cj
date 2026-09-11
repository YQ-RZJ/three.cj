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
 * @file[zh-cn] 渲染包组
 * @brief[zh-cn] 渲染包分组，用于将多个渲染对象打包为渲染束
 * @explain[zh-cn] 
 * BundleGroup 对应 Three.js 中的 BundleGroup 概念，用于将多个渲染对象组合为一个渲染束，
 * 以便在一次 draw call 中批量提交，提高渲染性能。
 *
 * @file[en] BundleGroup
 * @brief[en] Render bundle group, used to package multiple render objects into render bundles
 * @explain[en] 
 * BundleGroup corresponds to the BundleGroup concept in Three.js, used to combine multiple render objects
 * into a render bundle for batch submission in a single draw call, improving rendering performance.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染包分组，用于将多个渲染对象打包为渲染束
 * @explain[zh-cn] 
 * 将多个渲染对象组合为一个渲染束，以便批量提交。
 *
 * @brief[en] Render bundle group, used to package multiple render objects into render bundles
 * @explain[en] 
 * Combines multiple render objects into a render bundle for batch submission.
 */
public open class BundleGroup {
    /**
     * @brief[zh-cn] 渲染包组标识符
     *
     * @brief[en] Bundle group identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 构造默认渲染包组
     *
     * @brief[en] Constructs a default bundle group
     */
    public init() { this.id = 0 }
}
