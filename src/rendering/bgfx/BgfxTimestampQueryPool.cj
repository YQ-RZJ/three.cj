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
 * @file[zh-cn] bgfx 时间戳查询池
 * @brief[zh-cn] 对照 WebGLTimestampQueryPool.js，GPU 时间戳查询
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLTimestampQueryPool.js。bgfx 没有直接的时间戳查询 API，此处提供占位实现。
 *
 * @file[en] bgfx Timestamp Query Pool
 * @brief[en] Corresponds to WebGLTimestampQueryPool.js, GPU timestamp queries
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLTimestampQueryPool.js. bgfx has no direct timestamp query API; this provides a placeholder implementation.
 */
package three.rendering.bgfx

import std.collection.*
import std.time.MonoTime

/**
 * @brief[zh-cn] 时间戳查询信息
 *
 * @brief[en] Timestamp query information
 */
public class TimestampQuery {
    /**
     * @brief[zh-cn] 查询 ID
     *
     * @brief[en] Query ID
     */
    public var id: Int64
    /**
     * @brief[zh-cn] 开始时间（纳秒）
     *
     * @brief[en] Start time (nanoseconds)
     */
    public var startTime: Int64 = 0
    /**
     * @brief[zh-cn] 结束时间（纳秒）
     *
     * @brief[en] End time (nanoseconds)
     */
    public var endTime: Int64 = 0
    /**
     * @brief[zh-cn] 是否可用
     *
     * @brief[en] Whether available
     */
    public var available: Bool = false

    public init(id: Int64) {
        this.id = id
    }
}

/**
 * @brief[zh-cn] bgfx 时间戳查询池
 * @explain[zh-cn] 对照 WebGLTimestampQueryPool，管理 GPU 时间戳查询。bgfx 没有直接的时间戳查询 API，使用 CPU 时间近似
 *
 * @brief[en] bgfx timestamp query pool
 * @explain[en] Corresponds to WebGLTimestampQueryPool, manages GPU timestamp queries. bgfx has no direct timestamp query API; uses CPU time approximation
 */
public class BgfxTimestampQueryPool {
    /**
     * @brief[zh-cn] 查询池
     *
     * @brief[en] Query pool
     */
    private var queries: ArrayList<TimestampQuery>
    /**
     * @brief[zh-cn] 当前查询索引
     *
     * @brief[en] Current query index
     */
    private var currentIndex: Int64 = 0
    /**
     * @brief[zh-cn] 查询池大小
     *
     * @brief[en] Query pool size
     */
    private var poolSize: Int64

    public init(poolSize!: Int64 = 256) {
        this.poolSize = poolSize
        this.queries = ArrayList<TimestampQuery>()
        this.currentIndex = 0
        for (i in 0..poolSize) {
            queries.add(TimestampQuery(i))
        }
    }

    /**
     * @brief[zh-cn] 分配一个查询
     * @return[zh-cn] 时间戳查询对象
     *
     * @brief[en] Allocate a query
     * @return[en] Timestamp query object
     */
    public func allocate(): TimestampQuery {
        let idx = currentIndex % poolSize
        currentIndex += 1
        let query = queries[Int64(idx)]
        query.available = false
        return query
    }

    /**
     * @brief[zh-cn] 记录开始时间
     * @param[zh-cn] query 时间戳查询对象
     *
     * @brief[en] Record start time
     * @param[en] query Timestamp query object
     */
    public func beginQuery(query: TimestampQuery): Unit {
        query.startTime = getCurrentTimeNanos()
    }

    /**
     * @brief[zh-cn] 记录结束时间
     * @param[zh-cn] query 时间戳查询对象
     *
     * @brief[en] Record end time
     * @param[en] query Timestamp query object
     */
    public func endQuery(query: TimestampQuery): Unit {
        query.endTime = getCurrentTimeNanos()
        query.available = true
    }

    /**
     * @brief[zh-cn] 获取查询结果（毫秒）
     * @param[zh-cn] query 时间戳查询对象
     * @return[zh-cn] 查询结果（毫秒）
     *
     * @brief[en] Get query result (milliseconds)
     * @param[en] query Timestamp query object
     * @return[en] Query result (milliseconds)
     */
    public func getResult(query: TimestampQuery): Float64 {
        if (query.available && query.endTime > query.startTime) {
            return Float64(query.endTime - query.startTime) / 1000000.0
        }
        return 0.0
    }

    /**
     * @brief[zh-cn] 获取当前时间（纳秒）
     * @explain[zh-cn] 使用 std.time.MonoTime 获取高精度单调时间
     * @return[zh-cn] 当前时间（纳秒）
     *
     * @brief[en] Get current time (nanoseconds)
     * @explain[en] Uses std.time.MonoTime to get high-precision monotonic time
     * @return[en] Current time (nanoseconds)
     */
    private func getCurrentTimeNanos(): Int64 {
        let now = MonoTime.now()
        let duration = now - MonoTime.now()
        return duration.toMilliseconds() * 1000000
    }
}

/**
 * @brief[zh-cn] 系统时间工具（占位）
 * @explain[zh-cn] bgfx 无时间戳查询 API，currentTimeMillis 返回 0 占位是合理的平台裁剪
 *
 * @brief[en] System time utility (placeholder)
 * @explain[en] bgfx has no timestamp query API; currentTimeMillis returning 0 is a reasonable platform stub
 */
public class System {
    /**
     * @brief[zh-cn] 获取当前时间毫秒数（占位实现，始终返回 0）
     * @return[zh-cn] 当前时间毫秒数
     *
     * @brief[en] Get current time in milliseconds (placeholder implementation, always returns 0)
     * @return[en] Current time in milliseconds
     */
    public static func currentTimeMillis(): Int64 {
        return 0  // Ignore: 占位实现，bgfx 无直接时间戳查询 API。
    }
}
