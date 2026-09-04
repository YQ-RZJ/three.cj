/**
 * @file Base64EncodeTest
 * @brief Base64 编解码正确性测试（stdx 驱动版）
 *
 * 对照: RFC 4648 官方测试向量 + three.js（CCC Base64.ts）行为
 * 覆盖：
 * - RFC 4648 §10 标准向量（空串、单字节、双字节、三字节…）
 * - 编码折行（每 76 字符 \r\n）
 * - 解码兼容折行（\r\n / \r / \n）
 * - 往返一致性（encode∘decode == id）
 * - 非法输入返回空数组
 */
package text_encode

import std.unittest.*
import std.math.*
import three.utils.encode.Base64

public class Base64EncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("Base64EncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_rfc4648_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_rfc4648_vectors", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_encode_wrap_lines(); () }
            suiteBuilder.add(UnitTestCase.create("test_encode_wrap_lines", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_decode_wrap_compat(); () }
            suiteBuilder.add(UnitTestCase.create("test_decode_wrap_compat", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_roundtrip", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_invalid_input(); () }
            suiteBuilder.add(UnitTestCase.create("test_invalid_input", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // RFC 4648 §10 官方测试向量（原文逐字节比对）
    func test_rfc4648_vectors() {
        // "" -> ""
        assertEqual("empty encode", "", Base64.encode(Array<UInt8>()), "")
        // "f" -> "Zg=="
        assertEqual("1 byte", "Zg==", Base64.encode([102u8]), "Zg==")
        // "fo" -> "Zm8="
        assertEqual("2 bytes", "Zm8=", Base64.encode([102u8, 111u8]), "Zm8=")
        // "foo" -> "Zm9v"
        assertEqual("3 bytes", "Zm9v", Base64.encode([102u8, 111u8, 111u8]), "Zm9v")
        // "foob" -> "Zm9vYg=="
        assertEqual("4 bytes", "Zm9vYg==", Base64.encode([102u8, 111u8, 111u8, 98u8]), "Zm9vYg==")
        // "fooba" -> "Zm9vYmE="
        assertEqual("5 bytes", "Zm9vYmE=", Base64.encode([102u8, 111u8, 111u8, 98u8, 97u8]), "Zm9vYmE=")
        // "foobar" -> "Zm9vYmFy"
        assertEqual("6 bytes", "Zm9vYmFy", Base64.encode([102u8, 111u8, 111u8, 98u8, 97u8, 114u8]), "Zm9vYmFy")

        // 解码对称验证
        let dec = Base64.decode("Zm9vYmFy")
        assertEqual("decode len", "true", (dec.size == 6).toString(), "true")
        assertEqual("decode[0]", "true", (dec[0] == 102u8).toString(), "true")
        assertEqual("decode[5]", "true", (dec[5] == 114u8).toString(), "true")
    }

    // 编码折行：>76 字符的输入按每 76 字符插入 \r\n
    func test_encode_wrap_lines() {
        // 60 字节 → 80 个 Base64 字符 → 折行一次（76 + \r\n + 4）
        let data = Array<UInt8>(60, { i => UInt8(i % 256) })
        let enc = Base64.encode(data)
        assertEqual("wrap present", "true", enc.contains("\r\n").toString(), "true")
        let noWrap = enc.replace("\r\n", "")
        // 60 字节 → 80 字符（无填充）
        assertEqual("chars count", "true", (noWrap.size == 80).toString(), "true")
        // 解码折行结果仍正确
        let dec = Base64.decode(enc)
        assertEqual("wrap decode len", "true", (dec.size == 60).toString(), "true")
        for (i in 0..60) {
            assertEqual("byte " + i.toString(), "true", (dec[i] == data[i]).toString(), "true")
        }
    }

    // 解码兼容 \r\n / \r / \n 折行
    func test_decode_wrap_compat() {
        let plain = "Zm9vYmFy"
        let a = Base64.decode("Zm9v\r\nYmFy")
        let b = Base64.decode("Zm9v\rYmFy")
        let c = Base64.decode("Zm9v\nYmFy")
        assertEqual("crlf len", "true", (a.size == 6).toString(), "true")
        assertEqual("cr len", "true", (b.size == 6).toString(), "true")
        assertEqual("lf len", "true", (c.size == 6).toString(), "true")
        assertEqual("crlf equals plain", "true", (a[0] == 102u8 && a[5] == 114u8).toString(), "true")
        // 忽略"未使用"告警：plain 仅作对照说明
        assertEqual("plain reference", "true", (plain.size == 8).toString(), "true")
    }

    // 往返一致性：随机数据 encode∘decode == id
    func test_roundtrip() {
        // 多种长度覆盖余数 0/1/2
        for (len in [0i64, 1, 2, 3, 4, 5, 6, 7, 8, 57, 100, 255]) {
            let data = Array<UInt8>(len, { i => UInt8((i * 37 + 11) % 256) })
            let enc = Base64.encode(data)
            let dec = Base64.decode(enc)
            assertEqual("len " + len.toString(), "true", (dec.size == len).toString(), "true")
            var same = true
            for (i in 0..len) {
                if (dec[i] != data[i]) { same = false }
            }
            assertEqual("roundtrip len " + len.toString(), "true", same.toString(), "true")
        }
    }

    // 非法输入返回空数组
    func test_invalid_input() {
        let bad1 = Base64.decode("!!!not-base64!!!")
        assertEqual("invalid chars", "true", (bad1.size == 0).toString(), "true")
        let bad2 = Base64.decode("Zm9vY===")
        assertEqual("bad padding len", "true", (bad2.size == 0).toString(), "true")
    }
}
