/**
 * @file CacheTest
 * @brief test_loaders: Cache 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.Cache 能力：
 * - enabled=false 时不缓存
 * - enabled=true 时 add/get/remove/clear 行为
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.cache.Cache
import three.resource.loader.StringLoadResult

public class CacheTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("CacheTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_disabled(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_disabled", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_enabled(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_enabled", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_cache_remove_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_cache_remove_clear", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_cache_disabled() {
        // 对照 JS: Cache.enabled = false 时 add 不生效
        Cache.enabled = false
        Cache.clear()
        Cache.add("file:test.json", StringLoadResult("data1"))
        assertEqual("enabled=false 不缓存", "true", Cache.get("file:test.json").isNone(), true)
    }

    func test_cache_enabled() {
        // 对照 JS: Cache.enabled = true 时 add/get 生效
        Cache.enabled = true
        Cache.clear()
        Cache.add("file:test.json", StringLoadResult("data1"))
        let got = Cache.get("file:test.json")
        assertEqual("enabled=true get 命中", "true", got.isSome(), true)
        match (got) {
            case Some(v) =>
                match (v) {
                    case s: StringLoadResult => assertEqual("缓存值一致", "true", s.value == "data1", true)
                    case _ => assertEqual("缓存值类型", "true", false, true)
                }
            case None => ()
        }
    }

    func test_cache_remove_clear() {
        Cache.enabled = true
        Cache.clear()
        Cache.add("file:a.json", StringLoadResult("a"))
        Cache.add("file:b.json", StringLoadResult("b"))
        // 对照 JS: remove 移除单项
        Cache.remove("file:a.json")
        assertEqual("remove 后 a 不存在", "true", Cache.get("file:a.json").isNone(), true)
        assertEqual("remove 后 b 仍在", "true", Cache.get("file:b.json").isSome(), true)
        // 对照 JS: clear 清空全部
        Cache.clear()
        assertEqual("clear 后 b 不存在", "true", Cache.get("file:b.json").isNone(), true)
        Cache.enabled = false
    }
}
