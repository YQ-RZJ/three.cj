/**
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
