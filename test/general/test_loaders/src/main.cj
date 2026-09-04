/**
 * @file main
 * @brief test_loaders 独立测试项目入口
 *
 * 直接使用 std.unittest 框架手动注册测试套件并运行：
 * - 在测试子项目内 cjpm run（触发编译 + 运行）
 * - 测试文件命名为普通 .cj（避免 _test.cj 后缀在普通构建模式下被 cjpm 排除）
 */
package test_loaders

import std.unittest.*

main(): Int64 {
    let testPackage = TestPackage("test_loaders")
    testPackage.registerSuite({ => LoaderUtilsTest().asTestSuite() })
    testPackage.registerSuite({ => CacheTest().asTestSuite() })
    testPackage.registerSuite({ => LoadingManagerTest().asTestSuite() })
    testPackage.registerSuite({ => BufferGeometryLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => MaterialLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => DataTextureLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => ObjectLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => OBJLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => MTLLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => STLLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => DDSLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => HDRLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => PLYLoaderTest().asTestSuite() })
    testPackage.registerSuite({ => TGALoaderTest().asTestSuite() })
    testPackage.registerSuite({ => CompressedFormatLoaderTest().asTestSuite() })
    return entryMain(testPackage)
}
