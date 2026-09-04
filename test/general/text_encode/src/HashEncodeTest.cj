/**
 * @file HashEncodeTest
 * @brief 非加密哈希（FNV-1a 32 / MurmurHash3 32）正确性测试
 *
 * 对照: three.js（CCC Hash.ts）与业界已知哈希值
 * 覆盖：
 * - FNV-1a 32 已知向量（RFC 官方示例 "foobar"、"hello"）
 * - MurmurHash3 32 已知向量（空串、种子差异）
 * - 确定性（同一输入多次结果一致）
 * - 不同输入不同结果（雪崩差异）
 */
package text_encode

import std.unittest.*
import three.utils.encode.Hash

public class HashEncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("HashEncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_fnv1a32_known(); () }
            suiteBuilder.add(UnitTestCase.create("test_fnv1a32_known", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_murmur_known(); () }
            suiteBuilder.add(UnitTestCase.create("test_murmur_known", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_deterministic(); () }
            suiteBuilder.add(UnitTestCase.create("test_deterministic", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_avalanche(); () }
            suiteBuilder.add(UnitTestCase.create("test_avalanche", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // FNV-1a 32 已知向量（对照 CCC Hash.ts / 业界标准值，Python 权威校验）
    func test_fnv1a32_known() {
        // FNV-1a 32: "" = 2166136261 (offset basis)
        assertEqual("empty = offset basis", "true", (Hash.fnv1a32(Array<UInt8>()) == 2166136261i64).toString(), "true")
        // "a" = 0xE40C292C = 3826002220
        let a = "a".toArray()
        assertEqual("a == 0xe40c292c", "3826002220", Hash.fnv1a32(a).toString(), "3826002220")
        // "foobar" = 0xBF9CF968 = 3214735720
        let foobar = "foobar".toArray()
        assertEqual("foobar == 0xbf9cf968", "3214735720", Hash.fnv1a32(foobar).toString(), "3214735720")
    }

    // MurmurHash3 32 已知向量（seed=0 空串 = 0；对照参考实现）
    func test_murmur_known() {
        // MurmurHash3 x86_32("", seed=0) = 0
        assertEqual("empty seed0 == 0", "true", (Hash.murmurHash32(Array<UInt8>(), seed: 0u32) == 0i64).toString(), "true")
        // MurmurHash3 x86_32("", seed=1102) 确定性（无参考值，只验证稳定）
        let h = Hash.murmurHash32(Array<UInt8>())
        assertEqual("empty default seed stable", "true", (h == Hash.murmurHash32(Array<UInt8>())).toString(), "true")
        // 不同 seed 产生不同值
        assertEqual("seed differs", "true",
            (Hash.murmurHash32("hello".toArray(), seed: 0u32) !=
             Hash.murmurHash32("hello".toArray(), seed: 1u32)).toString(), "true")
    }

    // 确定性：同一输入多次结果一致
    func test_deterministic() {
        let data = Array<UInt8>(100, { i => UInt8((i * 31) % 256) })
        for (_ in 0..5) {
            let h1 = Hash.fnv1a32(data)
            let h2 = Hash.fnv1a32(data)
            assertEqual("fnv deterministic", "true", (h1 == h2).toString(), "true")
            let m1 = Hash.murmurHash32(data)
            let m2 = Hash.murmurHash32(data)
            assertEqual("murmur deterministic", "true", (m1 == m2).toString(), "true")
        }
    }

    // 雪崩差异：相近输入产生不同哈希
    func test_avalanche() {
        let a = "abcdefgh".toArray()
        let b = "abcdefgi".toArray()
        assertEqual("fnv differ", "true", (Hash.fnv1a32(a) != Hash.fnv1a32(b)).toString(), "true")
        assertEqual("murmur differ", "true", (Hash.murmurHash32(a) != Hash.murmurHash32(b)).toString(), "true")
    }
}
