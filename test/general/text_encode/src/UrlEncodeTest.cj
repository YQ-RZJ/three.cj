/**
 * @file UrlEncodeTest
 * @brief URL 查询串/百分号编码正确性测试（stdx Form 驱动版）
 *
 * 对照: three.js URLSearchParams / Node.js querystring 语义
 * 覆盖：
 * - encodeQuery：空格→'+'、未保留字符不编码、多键值对
 * - decodeQuery：'&'/'=' 拆分、'+'→空格、%XX 解码、前导 '?' 容忍
 * - percentEncode / percentDecode 单值往返
 * - 往返一致性
 */
package text_encode

import std.unittest.*
import three.utils.encode.UrlEncode

public class UrlEncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("UrlEncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_encode_query(); () }
            suiteBuilder.add(UnitTestCase.create("test_encode_query", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_decode_query(); () }
            suiteBuilder.add(UnitTestCase.create("test_decode_query", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_percent_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_percent_roundtrip", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_encode_decode_roundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("test_encode_decode_roundtrip", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // encodeQuery：空格→'+'、未保留字符不编码
    func test_encode_query() {
        let enc = UrlEncode.encodeQuery([("a", "1"), ("b", "hello world"), ("c", "x/y")])
        // 空格→'+'；'/' 不是未保留字符 → %2F
        assertEqual("basic query", "a=1&b=hello+world&c=x%2Fy", enc, "a=1&b=hello+world&c=x%2Fy")
    }

    // decodeQuery：'&'/'=' 拆分、'+'→空格、%XX 解码、前导 '?' 容忍
    func test_decode_query() {
        let pairs = UrlEncode.decodeQuery("?a=1&b=hello+world&c=x%2Fy")
        assertEqual("pair count", "true", (pairs.size == 3).toString(), "true")
        let (k0, v0) = pairs[0]
        assertEqual("k0", "a", k0, "a")
        assertEqual("v0", "1", v0, "1")
        let (k1, v1) = pairs[1]
        assertEqual("k1", "b", k1, "b")
        assertEqual("v1 plus->space", "hello world", v1, "hello world")
        let (k2, v2) = pairs[2]
        assertEqual("k2", "c", k2, "c")
        assertEqual("v2 pct decode", "x/y", v2, "x/y")
    }

    // percentEncode / percentDecode 单值
    func test_percent_roundtrip() {
        let enc = UrlEncode.percentEncode("hello world/中文")
        // 空格→'+'；'/'→%2F；中文 UTF-8 字节逐字节百分号编码
        assertEqual("space->plus", "hello+world%2F%E4%B8%AD%E6%96%87", enc, "hello+world%2F%E4%B8%AD%E6%96%87")
        let dec = UrlEncode.percentDecode(enc)
        assertEqual("dec roundtrip", "hello world/中文", dec, "hello world/中文")
    }

    // encodeQuery → decodeQuery 往返一致性
    func test_encode_decode_roundtrip() {
        let pairs = [("name", "张三"), ("note", "a b&c"), ("flag", "")]
        let enc = UrlEncode.encodeQuery(pairs)
        let dec = UrlEncode.decodeQuery(enc)
        assertEqual("count", "true", (dec.size == 3).toString(), "true")
        let (n0, v0) = dec[0]
        let (n1, v1) = dec[1]
        let (n2, v2) = dec[2]
        assertEqual("name", "张三", v0, "张三")
        assertEqual("note", "a b&c", v1, "a b&c")
        assertEqual("flag empty", "", v2, "")
        // 防止未使用告警
        assertEqual("k0", "name", n0, "name")
        assertEqual("k1", "note", n1, "note")
        assertEqual("k2", "flag", n2, "flag")
    }
}
