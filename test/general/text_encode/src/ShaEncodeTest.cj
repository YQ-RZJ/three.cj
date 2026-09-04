/**
 * @file ShaEncodeTest
 * @brief SHA 系列摘要正确性测试（stdx 驱动版）
 *
 * 对照: FIPS 180-4 官方测试向量（SHA-1/SHA-224/SHA-256/SHA-384/SHA-512）
 * 覆盖：
 * - 各算法官方测试向量（"abc" 三字节）
 * - String 与字节数组输入一致性
 * - sha256Raw / sha512Raw 原始字节长度
 * - UTF-8 中文多字节输入
 */
package text_encode

import std.unittest.*
import three.utils.encode.SHA

public class ShaEncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ShaEncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sha1_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_sha1_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sha224_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_sha224_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sha256_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_sha256_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sha384_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_sha384_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sha512_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_sha512_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_str_bytes_agree(); () }
            suiteBuilder.add(UnitTestCase.create("test_str_bytes_agree", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_raw_lengths(); () }
            suiteBuilder.add(UnitTestCase.create("test_raw_lengths", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_utf8_input(); () }
            suiteBuilder.add(UnitTestCase.create("test_utf8_input", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // FIPS 180-4 SHA-1("abc")
    func test_sha1_vectors() {
        assertEqual("sha1(abc)", "a9993e364706816aba3e25717850c26c9cd0d89d",
                    SHA.sha1("abc"), "a9993e364706816aba3e25717850c26c9cd0d89d")
        assertEqual("sha1(empty)", "da39a3ee5e6b4b0d3255bfef95601890afd80709",
                    SHA.sha1(""), "da39a3ee5e6b4b0d3255bfef95601890afd80709")
    }

    // FIPS 180-4 SHA-224("abc")
    func test_sha224_vectors() {
        assertEqual("sha224(abc)", "23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7",
                    SHA.sha224("abc"), "23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7")
    }

    // FIPS 180-4 SHA-256("abc")
    func test_sha256_vectors() {
        assertEqual("sha256(abc)", "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                    SHA.sha256("abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        assertEqual("sha256(empty)", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                    SHA.sha256(""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }

    // FIPS 180-4 SHA-384("abc")
    func test_sha384_vectors() {
        assertEqual("sha384(abc)",
                    "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed" +
                    "8086072ba1e7cc2358baeca134c825a7",
                    SHA.sha384("abc"),
                    "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed" +
                    "8086072ba1e7cc2358baeca134c825a7")
    }

    // FIPS 180-4 SHA-512("abc")
    func test_sha512_vectors() {
        assertEqual("sha512(abc)",
                    "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a" +
                    "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f",
                    SHA.sha512("abc"),
                    "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a" +
                    "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f")
    }

    // String 与字节数组输入一致
    func test_str_bytes_agree() {
        let s = "hello sha"
        assertEqual("sha1 agree", "true", (SHA.sha1(s) == SHA.sha1(s.toArray())).toString(), "true")
        assertEqual("sha256 agree", "true", (SHA.sha256(s) == SHA.sha256(s.toArray())).toString(), "true")
        assertEqual("sha512 agree", "true", (SHA.sha512(s) == SHA.sha512(s.toArray())).toString(), "true")
    }

    // 原始摘要长度：SHA-256=32 字节、SHA-512=64 字节
    func test_raw_lengths() {
        let r256 = SHA.sha256Raw("abc".toArray())
        assertEqual("sha256raw len 32", "true", (r256.size == 32).toString(), "true")
        assertEqual("sha256raw[0] == 0xba", "true", (r256[0] == 0xBAu8).toString(), "true")
        let r512 = SHA.sha512Raw("abc".toArray())
        assertEqual("sha512raw len 64", "true", (r512.size == 64).toString(), "true")
        assertEqual("sha512raw[0] == 0xdd", "true", (r512[0] == 0xDDu8).toString(), "true")
    }

    // UTF-8 多字节输入（确定性 + 32 字符长度）
    func test_utf8_input() {
        let h1 = SHA.sha256("中文")
        let h2 = SHA.sha256("中文".toArray())
        assertEqual("zh agree", "true", (h1 == h2).toString(), "true")
        assertEqual("zh len 64 hex", "true", (h1.size == 64).toString(), "true")
    }
}
