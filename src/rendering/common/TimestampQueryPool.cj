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
 * @file[zh-cn] 时间戳查询池
 * @brief[zh-cn] 时间戳查询池类，用于 GPU 时间戳查询
 * @explain[zh-cn] TimestampQueryPool 提供GPU端时间戳查询的基础设施，kind 属性标识类型为 "TimestampQueryPool"。对照源码: three.js/src/renderers/common/TimestampQueryPool.js
 *
 * @file[en] Timestamp Query Pool
 * @brief[en] Timestamp query pool class, used for GPU timestamp queries
 * @explain[en] TimestampQueryPool provides infrastructure for GPU-side timestamp queries, with a kind property identifying the type as "TimestampQueryPool". Reference: three.js/src/renderers/common/TimestampQueryPool.js
 */
package three.rendering.common

/**
 * @brief[zh-cn] 时间戳查询池类
 * @explain[zh-cn] 用于 GPU 端渲染管线时间戳查询的基础设施，kind 属性标识类型为 "TimestampQueryPool"。
 *
 * @brief[en] Timestamp query pool class
 * @explain[en] Infrastructure for GPU-side rendering pipeline timestamp queries, with a kind property identifying the type as "TimestampQueryPool".
 */
public open class TimestampQueryPool {

    /**
     * @brief[zh-cn] 类型标识
     *
     * @brief[en] Type identifier
     */
    public var kind: String;

    /**
     * @brief[zh-cn] 构造器，初始化 kind 为 "TimestampQueryPool"
     *
     * @brief[en] Constructor, initializes kind to "TimestampQueryPool"
     */
    public init() { this.kind = "TimestampQueryPool" }
}
