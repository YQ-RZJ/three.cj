/**
 * @file AssetCacheTest
 * @brief test_asset_pipeline: AssetCache 引用计数缓存单元测试（纯逻辑）
 *
 * 检测 three.resource.pipeline.AssetCache 能力：
 * - add/get/acquire/retain/release/refCount 基础生命周期
 * - collect 回收引用归零条目
 * - collectIfNeeded 惰性回收（间隔内不触发）
 * - remove/clear
 */
package test_asset_pipeline

import std.unittest.*
import three.resource.pipeline.*
import three.resource.loader.StringLoadResult
import three.core.interfaces.ILoadResult

public class AssetCacheTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AssetCacheTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_refcount(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_refcount", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_collect(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_collect", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_lazy_collect(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_lazy_collect", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 构造独立缓存实例（避免污染 shared）
    private static func newCache(): AssetCache {
        let cache = AssetCache()
        cache.add("k1", StringLoadResult("v1"))
        return cache
    }

    func test_cache_refcount() {
        let cache = newCache()
        assertEqual("初始计数 0", "true", cache.refCount("k1") == 0, true)
        assertEqual("get 命中", "true", cache.get("k1").isSome(), true)
        // retain 两次 → 2
        assertEqual("retain 成功", "true", cache.retain("k1"), true)
        cache.retain("k1")
        assertEqual("计数 2", "true", cache.refCount("k1") == 2, true)
        // acquire 同样 +1
        let got = cache.acquire("k1")
        assertEqual("acquire 命中", "true", got.isSome(), true)
        assertEqual("计数 3", "true", cache.refCount("k1") == 3, true)
        // release 逐次递减
        cache.release("k1")
        cache.release("k1")
        cache.release("k1")
        assertEqual("归零", "true", cache.refCount("k1") == 0, true)
        // 不存在的 key
        assertEqual("缺失 key 计数 -1", "true", cache.refCount("nope") == -1, true)
        assertEqual("缺失 key retain 失败", "true", !cache.retain("nope"), true)
        // remove 无视计数
        cache.retain("k1")
        cache.remove("k1")
        assertEqual("remove 后 get 为 None", "true", cache.get("k1").isNone(), true)
    }

    func test_cache_collect() {
        // 独立空缓存（不经过 newCache，避免额外条目干扰回收计数）
        let cache = AssetCache()
        cache.add("held", StringLoadResult("held"))
        cache.add("dead", StringLoadResult("dead"))
        cache.retain("held")
        // dead 引用计数 0 → collect 回收；held 计数 1 → 保留
        let removed = cache.collect()
        assertEqual("collect 回收 1 条", "true", removed == 1, true)
        assertEqual("held 保留", "true", cache.get("held").isSome(), true)
        assertEqual("dead 已回收", "true", cache.get("dead").isNone(), true)
        // 释放后再 collect
        cache.release("held")
        assertEqual("再回收 1 条", "true", cache.collect() == 1, true)
        assertEqual("held 已回收", "true", cache.get("held").isNone(), true)
        assertEqual("缓存清空", "true", cache.count == 0, true)
    }

    func test_cache_lazy_collect() {
        // 独立空缓存（不经过 newCache，避免额外条目干扰回收计数）
        let cache = AssetCache()
        cache.add("dead", StringLoadResult("dead"))
        // 第 0 帧触发一次（_lastCollectFrame 初始 -1，必然执行）
        assertEqual("首次立即回收", "true", cache.collectIfNeeded(interval: 60) == 1, true)
        // 间隔内不再触发
        cache.add("dead2", StringLoadResult("dead2"))
        cache.advanceFrame()
        assertEqual("间隔内不触发", "true", cache.collectIfNeeded(interval: 60) == 0, true)
        assertEqual("dead2 仍在", "true", cache.get("dead2").isSome(), true)
        // 推进到间隔后触发
        var i: Int64 = 0
        while (i < 60) {
            cache.advanceFrame()
            i += 1
        }
        assertEqual("间隔后触发", "true", cache.collectIfNeeded(interval: 60) == 1, true)
        assertEqual("dead2 已回收", "true", cache.get("dead2").isNone(), true)
        // clear 无视计数
        cache.add("x", StringLoadResult("x"))
        cache.retain("x")
        cache.release()
        assertEqual("clear 清空全部", "true", cache.count == 0, true)
    }
}
