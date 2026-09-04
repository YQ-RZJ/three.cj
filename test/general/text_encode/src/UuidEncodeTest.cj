/**
 * @file UuidEncodeTest
 * @brief UUID v4 生成正确性测试
 *
 * 对照: RFC 4122 v4（随机 UUID）格式约束
 * 覆盖：
 * - 36 字符长度 + 4 个连字符位置（8-4-4-4-12）
 * - 版本位 = '4'（第 14 位）
 * - 变体位 ∈ {8,9,a,b}（第 19 位高 2 位为 10）
 * - 唯一性（多次生成互不相同）
 * - 小写 16 进制字符集
 *
 * 仓颉要点：String 索引 s[i] 返回 UInt8（即 Byte 别名），
 * 字符比较用字节字面量 b'x'（与 ASCII 字符码一致）。
 */
package text_encode

import std.unittest.*
import std.collection.*
import three.utils.encode.UUID

public class UuidEncodeTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("UuidEncodeTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_format(); () }
            suiteBuilder.add(UnitTestCase.create("test_format", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_version_and_variant(); () }
            suiteBuilder.add(UnitTestCase.create("test_version_and_variant", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_uniqueness(); () }
            suiteBuilder.add(UnitTestCase.create("test_uniqueness", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // 格式：36 字符，连字符在 8/13/18/23 位
    func test_format() {
        let u = UUID.uuid()
        assertEqual("len 36", "true", (u.size == 36).toString(), "true")
        assertEqual("dash@8", "true", (u[8] == b'-').toString(), "true")
        assertEqual("dash@13", "true", (u[13] == b'-').toString(), "true")
        assertEqual("dash@18", "true", (u[18] == b'-').toString(), "true")
        assertEqual("dash@23", "true", (u[23] == b'-').toString(), "true")
        // 其余 32 位为小写 hex（字节值：'0'-'9'=48-57、'a'-'f'=97-102）
        for (i in 0..36) {
            if (i == 8 || i == 13 || i == 18 || i == 23) { continue }
            let c = u[i]
            let isHex = (c >= b'0' && c <= b'9') || (c >= b'a' && c <= b'f')
            assertEqual("hex@" + i.toString(), "true", isHex.toString(), "true")
        }
    }

    // 版本位 = '4'，变体位 ∈ {8,9,a,b}
    func test_version_and_variant() {
        for (_ in 0..20) {
            let u = UUID.uuid()
            assertEqual("version 4", "true", (u[14] == b'4').toString(), "true")
            let v = u[19]
            let ok = (v == b'8') || (v == b'9') || (v == b'a') || (v == b'b')
            assertEqual("variant 8/9/a/b", "true", ok.toString(), "true")
        }
    }

    // 唯一性：100 次生成互不相同
    func test_uniqueness() {
        let seen = HashSet<String>()
        var unique = true
        for (_ in 0..100) {
            let u = UUID.uuid()
            if (seen.contains(u)) {
                unique = false
            }
            seen.add(u)
        }
        assertEqual("100 unique", "true", unique.toString(), "true")
        assertEqual("set size 100", "true", (seen.size == 100).toString(), "true")
    }
}
