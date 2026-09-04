/**
 * @file Md5EncodeTest
 * @brief MD5 摘要正确性测试（stdx 驱动版）
 *
 * 对照: RFC 1321 官方测试向量（The MD5 Message-Digest Algorithm）
 * 覆盖：
 * - RFC 1321 §A.5 五组官方测试向量（空串 / "a" / "abc" / "message digest" / "abcdefghijklmnopqrstuvwxyz"）
 * - compute(String) 与 compute(Array<UInt8>) 一致性
 * - computeRaw 16 字节原始摘要
 * - UTF-8 中文输入（多字节）
 */
package text_encode

import std.unittest.*
import std.math.*
import three.utils.encode.MD5
import three.utils.encode.Hex

public class Md5EncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("Md5EncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_rfc1321_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_rfc1321_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_string_and_bytes_agree(); () }
            suiteBuilder.add(UnitTestCase.create("test_string_and_bytes_agree", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_compute_raw(); () }
            suiteBuilder.add(UnitTestCase.create("test_compute_raw", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_utf8_input(); () }
            suiteBuilder.add(UnitTestCase.create("test_utf8_input", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // RFC 1321 §A.5 官方测试向量
    func test_rfc1321_vectors() {
        assertEqual("empty", "d41d8cd98f00b204e9800998ecf8427e", MD5.compute(""), "d41d8cd98f00b204e9800998ecf8427e")
        assertEqual("a", "0cc175b9c0f1b6a831c399e269772661", MD5.compute("a"), "0cc175b9c0f1b6a831c399e269772661")
        assertEqual("abc", "900150983cd24fb0d6963f7d28e17f72", MD5.compute("abc"), "900150983cd24fb0d6963f7d28e17f72")
        assertEqual("message digest", "f96b697d7cb7938d525a2f31aaf161d0", MD5.compute("message digest"), "f96b697d7cb7938d525a2f31aaf161d0")
        assertEqual("alphabet", "c3fcd3d76192e4007dfb496cca67e13b", MD5.compute("abcdefghijklmnopqrstuvwxyz"), "c3fcd3d76192e4007dfb496cca67e13b")
    }

    // compute(String) 与 compute(Array<UInt8>) 一致（UTF-8 字节输入）
    func test_string_and_bytes_agree() {
        let s = "hello world"
        let viaStr = MD5.compute(s)
        let viaBytes = MD5.compute(s.toArray())
        assertEqual("str == bytes", "true", (viaStr == viaBytes).toString(), "true")
        assertEqual("known hex", "5eb63bbbe01eeed093cb22bb8f5acdc3", viaStr, "5eb63bbbe01eeed093cb22bb8f5acdc3")
    }

    // computeRaw：16 字节原始摘要
    func test_compute_raw() {
        let raw = MD5.computeRaw("abc".toArray())
        assertEqual("raw len 16", "true", (raw.size == 16).toString(), "true")
        assertEqual("raw[0] == 0x90", "true", (raw[0] == 0x90u8).toString(), "true")
        assertEqual("raw[15] == 0x72", "true", (raw[15] == 0x72u8).toString(), "true")
        // raw → hex 与 compute 一致
        let hexOfRaw = Hex.encode(raw)
        assertEqual("raw hex == compute", "900150983cd24fb0d6963f7d28e17f72", hexOfRaw, "900150983cd24fb0d6963f7d28e17f72")
    }

    // UTF-8 多字节输入
    func test_utf8_input() {
        // "中文" 的 UTF-8 字节 = E4 B8 AD E6 96 87；用字节数组直接验证确定性
        let zh = "中文".toArray()
        let h1 = MD5.compute(zh)
        let h2 = MD5.compute("中文")
        assertEqual("zh str == bytes", "true", (h1 == h2).toString(), "true")
        assertEqual("zh deterministic", "true", (h1.size == 32).toString(), "true")
    }
}
