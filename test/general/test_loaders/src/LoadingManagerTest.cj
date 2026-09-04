/**
 * @file LoadingManagerTest
 * @brief test_loaders: LoadingManager 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.LoadingManager 能力：
 * - itemStart/itemEnd 计数与 onLoad 回调
 * - setURLModifier / resolveURL
 * - addHandler / getHandler（正则匹配，对照 JS regex.test）
 */
package test_loaders

import std.unittest.*
import std.collection.*
import three.resource.loader.LoadingManager
import three.resource.loader.Loader

public class LoadingManagerTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("LoadingManagerTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_item_counting(); () }
            suiteBuilder.add(UnitTestCase.create("test_item_counting", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_url_modifier(); () }
            suiteBuilder.add(UnitTestCase.create("test_url_modifier", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_get_handler_regex(); () }
            suiteBuilder.add(UnitTestCase.create("test_get_handler_regex", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_item_counting() {
        // 对照 JS: 连续 itemStart/itemEnd，全部完成时触发 onLoad
        let holder = ArrayList<Int64>()
        let mgr = LoadingManager(onLoad: Some({ => holder.add(Int64(1)) }))
        mgr.itemStart("a.json")
        mgr.itemStart("b.json")
        // 只完成一项，不应触发 onLoad
        mgr.itemEnd("a.json")
        assertEqual("未全部完成不触发 onLoad", "true", holder.size == 0, true)
        // 全部完成触发 onLoad
        mgr.itemEnd("b.json")
        assertEqual("全部完成触发 onLoad", "true", holder.size == 1, true)
    }

    func test_url_modifier() {
        // 对照 JS: setURLModifier(transform) — resolveURL 应用修改器
        let mgr = LoadingManager()
        mgr.setURLModifier({ url => "base/" + url })
        assertEqual("urlModifier 生效", "true", mgr.resolveURL("tex.png") == "base/tex.png", true)
    }

    func test_get_handler_regex() {
        // 对照 JS: addHandler(regex, loader) + getHandler(file) 用 regex.test(file)
        let mgr = LoadingManager()
        let ddsLoader = FileLoaderStub()
        mgr.addHandler(".*\\.dds", ddsLoader)
        let hit = mgr.getHandler("textures/ground.dds")
        assertEqual("dds 命中", "true", hit.isSome(), true)
        match (hit) {
            case Some(v) =>
                match (v) {
                    case s: FileLoaderStub => assertEqual("命中加载器一致", "true", s.id == "dds", true)
                    case _ => assertEqual("命中类型", "true", false, true)
                }
            case None => ()
        }
        // 不匹配的文件返回 None
        let miss = mgr.getHandler("textures/ground.png")
        assertEqual("png 不命中", "true", miss.isNone(), true)
    }
}

// 测试用加载器桩（继承 Loader 以适配 addHandler(regex, loader: Loader) 新签名）
public class FileLoaderStub <: Loader {
    public let id: String = "dds"
    public init() {
        super(manager: LoadingManager())
    }
}
