/**
 * @file HexEncodeTest
 * @brief Hex 十六进制编解码正确性测试（stdx 驱动版）
 *
 * 对照: Node.js Buffer.toString('hex') 语义
 * 覆盖：
 * - 已知向量（大小写、小写输出）
 * - 往返一致性
 * - 非法输入（非 hex 字符 / 奇数长度）返回空数组
 */
package text_encode

import std.unittest.*
import three.utils.encode.Hex

public class HexEncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("HexEncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_known_vectors(); () }
            suiteBuilder.add(UnitTestCase.create("test_known_vectors", configuration: caseConfig, body: testFunc))
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

    // 已知向量：小写 hex 输出
    func test_known_vectors() {
        assertEqual("empty", "", Hex.encode(Array<UInt8>()), "")
        // [0xDE, 0xAD, 0xBE, 0xEF] -> "deadbeef"
        let data = [0xDEu8, 0xADu8, 0xBEu8, 0xEFu8]
        assertEqual("deadbeef", "deadbeef", Hex.encode(data), "deadbeef")
        // 0..15 -> "000102...0f"
        let seq = Array<UInt8>(16, { i => UInt8(i) })
        assertEqual("seq16", "000102030405060708090a0b0c0d0e0f", Hex.encode(seq), "000102030405060708090a0b0c0d0e0f")
        // 大小写输入均可解码
        let up = Hex.decode("DEADBEEF")
        assertEqual("upper len", "true", (up.size == 4).toString(), "true")
        assertEqual("upper[0]", "true", (up[0] == 0xDEu8).toString(), "true")
        let low = Hex.decode("deadbeef")
        assertEqual("lower[3]", "true", (low[3] == 0xEFu8).toString(), "true")
    }

    // 往返一致性
    func test_roundtrip() {
        for (len in [0i64, 1, 3, 16, 64, 100]) {
            let data = Array<UInt8>(len, { i => UInt8((i * 13 + 7) % 256) })
            let enc = Hex.encode(data)
            let dec = Hex.decode(enc)
            assertEqual("len " + len.toString(), "true", (dec.size == len).toString(), "true")
            var same = true
            for (i in 0..len) {
                if (dec[i] != data[i]) { same = false }
            }
            assertEqual("roundtrip len " + len.toString(), "true", same.toString(), "true")
        }
    }

    // 非法输入：非 hex 字符 / 奇数长度 → 空数组
    func test_invalid_input() {
        let bad1 = Hex.decode("xyz")
        assertEqual("non-hex", "true", (bad1.size == 0).toString(), "true")
        let bad2 = Hex.decode("abc")  // 奇数长度
        assertEqual("odd length", "true", (bad2.size == 0).toString(), "true")
        let bad3 = Hex.decode("")
        assertEqual("empty", "true", (bad3.size == 0).toString(), "true")
    }
}
