/**
 * @file LoaderUtilsTest
 * @brief test_loaders: LoaderUtils 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.LoaderUtils 能力：
 * - extractUrlBase（提取 URL 基础路径）
 * - resolveURL（绝对/相对/data:/blob:/host-relative 解析）
 */
package test_loaders

import std.unittest.*
import three.resource.loader.LoaderUtils

public class LoaderUtilsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("LoaderUtilsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_extract_url_base(); () }
            suiteBuilder.add(UnitTestCase.create("test_extract_url_base", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_resolve_url_absolute(); () }
            suiteBuilder.add(UnitTestCase.create("test_resolve_url_absolute", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_resolve_url_relative(); () }
            suiteBuilder.add(UnitTestCase.create("test_resolve_url_relative", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_resolve_url_host_relative(); () }
            suiteBuilder.add(UnitTestCase.create("test_resolve_url_host_relative", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_extract_url_base() {
        // 对照 JS: extractUrlBase('models/box.json') === 'models/'
        assertEqual("extractUrlBase 目录路径", "true", LoaderUtils.extractUrlBase("models/box.json") == "models/", true)
        // 对照 JS: extractUrlBase('box.json') === './'
        assertEqual("extractUrlBase 无目录返回 ./", "true", LoaderUtils.extractUrlBase("box.json") == "./", true)
    }

    func test_resolve_url_absolute() {
        // 对照 JS: resolveURL 绝对 URL 原样返回
        assertEqual("http 绝对 URL", "true", LoaderUtils.resolveURL("http://example.com/a.png", "x/") == "http://example.com/a.png", true)
        assertEqual("https 绝对 URL", "true", LoaderUtils.resolveURL("https://example.com/a.png", "x/") == "https://example.com/a.png", true)
        assertEqual("协议相对 // URL", "true", LoaderUtils.resolveURL("//example.com/a.png", "x/") == "//example.com/a.png", true)
        // 对照 JS: data:/blob: 原样返回
        assertEqual("data URL", "true", LoaderUtils.resolveURL("data:image/png;base64,AA==", "x/") == "data:image/png;base64,AA==", true)
        assertEqual("blob URL", "true", LoaderUtils.resolveURL("blob:abc", "x/") == "blob:abc", true)
        // 对照 JS: 空 URL 返回空串
        assertEqual("空 URL 返回空串", "true", LoaderUtils.resolveURL("", "x/") == "", true)
    }

    func test_resolve_url_relative() {
        // 对照 JS: resolveURL('tex.png', 'models/') === 'models/tex.png'
        assertEqual("相对 URL 拼接 path", "true", LoaderUtils.resolveURL("tex.png", "models/") == "models/tex.png", true)
    }

    func test_resolve_url_host_relative() {
        // 对照 JS: path 为 http(s):// 且 url 以 / 开头时，path 截断为协议+主机
        //   resolveURL('/a.png', 'https://example.com/models/') === 'https://example.com/a.png'
        assertEqual("host-relative 截断 path", "true", LoaderUtils.resolveURL("/a.png", "https://example.com/models/") == "https://example.com/a.png", true)
        assertEqual("host-relative http", "true", LoaderUtils.resolveURL("/a.png", "http://example.com/models/") == "http://example.com/a.png", true)
        // url 不以 / 开头时保持相对拼接
        assertEqual("非 / 开头不截断", "true", LoaderUtils.resolveURL("a.png", "https://example.com/models/") == "https://example.com/models/a.png", true)
    }
}
