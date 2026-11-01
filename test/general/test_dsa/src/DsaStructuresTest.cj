/**
 * @file DsaStructuresTest
 * @brief test_dsa: 常用数据结构补充单元测试
 *
 * 检测 three.core.dsa 中新增的常用结构：
 * - SpatialHashGrid：空间哈希网格（球/盒邻域查询）
 * - LruCache：定容量 LRU 缓存
 * - UnionFind：并查集
 * - FenwickTree：树状数组
 */
package test_dsa

import std.unittest.*
import std.collection.*
import three.core.dsa.SpatialHashGrid
import three.core.dsa.LruCache
import three.core.dsa.UnionFind
import three.core.dsa.FenwickTree

public class DsaStructuresTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("DsaStructuresTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_spatialHashGrid_sphereQuery(); () }
            suiteBuilder.add(UnitTestCase.create("test_spatialHashGrid_sphereQuery", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_spatialHashGrid_boxQuery(); () }
            suiteBuilder.add(UnitTestCase.create("test_spatialHashGrid_boxQuery", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_spatialHashGrid_clear(); () }
            suiteBuilder.add(UnitTestCase.create("test_spatialHashGrid_clear", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_lruCache_basic(); () }
            suiteBuilder.add(UnitTestCase.create("test_lruCache_basic", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_lruCache_eviction(); () }
            suiteBuilder.add(UnitTestCase.create("test_lruCache_eviction", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_unionFind(); () }
            suiteBuilder.add(UnitTestCase.create("test_unionFind", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_fenwickTree(); () }
            suiteBuilder.add(UnitTestCase.create("test_fenwickTree", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // ===== SpatialHashGrid =====

    func test_spatialHashGrid_sphereQuery() {
        let grid = SpatialHashGrid(1.0)
        // 三个元素：(0,0,0) r=0.5；(2,0,0) r=0.5；(0,0,10) r=0.5
        grid.insert(0, 0.0, 0.0, 0.0, 0.5)
        grid.insert(1, 2.0, 0.0, 0.0, 0.5)
        grid.insert(2, 0.0, 0.0, 10.0, 0.5)
        assertEqual("elementCount", "3", grid.elementCount, 3)

        let hits = ArrayList<Int64>()
        // 查询球覆盖 (0,0,0)：应命中 0；与 1 的距离为 2 > 0.5+1.0 → 不命中
        grid.querySphere(0.0, 0.0, 0.0, 1.0, hits)
        assertEqual("sphere hit count", "1", hits.size, 1)
        assertEqual("sphere hit index", "0", hits[0], 0)

        // 查询球覆盖 (0,0,0) 与 (2,0,0)：半径 1.5 时两者都应命中
        let hits2 = ArrayList<Int64>()
        grid.querySphere(1.0, 0.0, 0.0, 1.5, hits2)
        assertEqual("sphere hit count 2", "2", hits2.size, 2)

        // 远处的元素不应被命中
        let hits3 = ArrayList<Int64>()
        grid.querySphere(0.0, 0.0, 0.0, 0.1, hits3)
        assertEqual("far element not hit", "1", hits3.size, 1)
        assertEqual("far element index", "0", hits3[0], 0)
    }

    func test_spatialHashGrid_boxQuery() {
        let grid = SpatialHashGrid(1.0)
        grid.insert(0, 0.0, 0.0, 0.0, 0.5)
        grid.insert(1, 5.0, 5.0, 5.0, 0.5)

        let hits = ArrayList<Int64>()
        // 盒 (-1,-1,-1) ~ (1,1,1) 只覆盖元素 0
        grid.queryAabb(-1.0, -1.0, -1.0, 1.0, 1.0, 1.0, hits)
        assertEqual("box hit count", "1", hits.size, 1)
        assertEqual("box hit index", "0", hits[0], 0)

        // 盒 (4,4,4) ~ (6,6,6) 只覆盖元素 1
        let hits2 = ArrayList<Int64>()
        grid.queryAabb(4.0, 4.0, 4.0, 6.0, 6.0, 6.0, hits2)
        assertEqual("box hit count 2", "1", hits2.size, 1)
        assertEqual("box hit index 2", "1", hits2[0], 1)
    }

    func test_spatialHashGrid_clear() {
        let grid = SpatialHashGrid(1.0)
        grid.insert(0, 0.0, 0.0, 0.0, 0.5)
        assertEqual("cells not empty", "false", grid.cellCount == 0, false)
        grid.clear()
        assertEqual("elementCount cleared", "0", grid.elementCount, 0)
        assertEqual("cellCount cleared", "0", grid.cellCount, 0)
    }

    // ===== LruCache =====

    func test_lruCache_basic() {
        let cache = LruCache<Int64, String>(4)
        assertEqual("empty", "true", cache.isEmpty(), true)
        cache.put(1, "one")
        cache.put(2, "two")
        assertEqual("size", "2", cache.size, 2)
        assertEqual("get hit", "one", cache.get(1).getOrThrow(), "one")
        assertEqual("hits", "1", cache.hits, 1)
        let missHit = match (cache.get(99)) {
            case Some(_) => false
            case None => true
        }
        assertEqual("miss", "true", missHit, true)
        assertEqual("misses", "1", cache.misses, 1)
        assertEqual("contains", "true", cache.contains(2), true)
        assertEqual("peek does not count hit", "1", cache.hits, 1)
        cache.remove(1)
        assertEqual("after remove size", "1", cache.size, 1)
        assertEqual("removed key gone", "true", cache.contains(1), false)
    }

    func test_lruCache_eviction() {
        let cache = LruCache<Int64, String>(2)
        cache.put(1, "one")
        cache.put(2, "two")
        // 访问 1，使其成为最近使用 → 淘汰时应淘汰 2
        cache.get(1)
        cache.put(3, "three")
        assertEqual("size capped", "2", cache.size, 2)
        assertEqual("evicted oldest", "true", cache.contains(2), false)
        assertEqual("kept recent", "true", cache.contains(1), true)
        assertEqual("newest present", "true", cache.contains(3), true)
        assertEqual("eviction count", "1", cache.evictions, 1)
    }

    // ===== UnionFind =====

    func test_unionFind() {
        let uf = UnionFind(5)
        assertEqual("size", "5", uf.size, 5)
        assertEqual("components", "5", uf.componentCount, 5)
        assertEqual("not connected", "false", uf.connected(0, 1), false)
        assertEqual("union returns true", "true", uf.union(0, 1), true)
        assertEqual("union returns false", "false", uf.union(0, 1), false)
        assertEqual("connected", "true", uf.connected(0, 1), true)
        assertEqual("components after union", "4", uf.componentCount, 4)
        uf.union(1, 2)
        assertEqual("transitive connected", "true", uf.connected(0, 2), true)
        assertEqual("components after 2 unions", "3", uf.componentCount, 3)
        assertEqual("other set untouched", "false", uf.connected(0, 3), false)
        uf.reset(2)
        assertEqual("after reset size", "2", uf.size, 2)
        assertEqual("after reset components", "2", uf.componentCount, 2)
    }

    // ===== FenwickTree =====

    func test_fenwickTree() {
        let ft = FenwickTree(8)
        ft.add(1, 5)
        ft.add(3, 7)
        ft.add(8, 2)
        assertEqual("query 1", "5", ft.query(1), 5)
        assertEqual("query 3", "7", ft.query(3), 7)
        assertEqual("prefix 1", "5", ft.prefixSum(1), 5)
        assertEqual("prefix 3", "12", ft.prefixSum(3), 12)
        assertEqual("prefix 8", "14", ft.prefixSum(8), 14)
        assertEqual("range 2..3", "7", ft.rangeSum(2, 3), 7)
        assertEqual("range 1..8", "14", ft.rangeSum(1, 8), 14)
        // 前缀和首次达到 8 的最小下标是 3
        assertEqual("lowerBound 8", "3", ft.lowerBound(8), 3)
        // 前缀和首次达到 1 的最小下标是 1
        assertEqual("lowerBound 1", "1", ft.lowerBound(1), 1)
        ft.add(3, -2)
        assertEqual("after negative add", "12", ft.prefixSum(8), 12)
    }
}
