/**
 * @file main
 * @brief text_encode 独立测试项目入口
 *
 * 对 three.utils.encode 子包（stdx 驱动改造后）做全量编解码正确性验证：
 *   Base64 / Hex / MD5 / SHA（sha1/224/256/384/512）/ UrlEncode / Hash（fnv1a/murmur）/ UUID
 *
 * 断言方式（对照 three.js test/unit 风格 + std.unittest）：
 *   - 已知向量（RFC 1321 MD5、FIPS 180-4 SHA 测试向量）精确比对
 *   - 编码→解码往返一致性
 *   - 边界输入（空串、单字节、折行、非法字符、UTF-8 中文）
 *   - 确定性与格式约束（UUID v4 格式、大小写）
 */
package text_encode

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("text_encode")
    testPackage.registerSuite({ => Base64EncodeTest().asTestSuite() })
    testPackage.registerSuite({ => HexEncodeTest().asTestSuite() })
    testPackage.registerSuite({ => Md5EncodeTest().asTestSuite() })
    testPackage.registerSuite({ => ShaEncodeTest().asTestSuite() })
    testPackage.registerSuite({ => UrlEncodeTest().asTestSuite() })
    testPackage.registerSuite({ => HashEncodeTest().asTestSuite() })
    testPackage.registerSuite({ => UuidEncodeTest().asTestSuite() })
    return entryMain(testPackage)
}
