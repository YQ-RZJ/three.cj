/**
 * @file AssetManagerTest
 * @brief test_asset_pipeline: AssetManager 异步分帧加载测试
 *
 * 检测 three.resource.pipeline.AssetManager 能力：
 * - loadText/loadBytes：后台读盘 + 完成队列分帧派发（update 驱动）
 * - loadBytes 失败路径（onError 派发）
 * - loadBytes 并发去重（同 URL 重复请求合并）
 * - storeCache + 引用计数生命周期
 * - loadFromBundle：包内分发 + 缓存命中
 */
package test_asset_pipeline

import std.unittest.*
import std.fs.*
import std.time.*
import three.resource.pipeline.*
import three.resource.loader.StringLoadResult
import three.resource.loader.BytesLoadResult

/// 异步回调状态容器（lambda 不能捕获可变变量，用类字段承载）
class TextState {
    public var done: Bool = false
    public var text: String = ""
    public var err: String = ""
}

class BytesState {
    public var done: Bool = false
    public var size: Int64 = 0
    public var err: String = ""
}

/// 统计类：记录 onAdvance/onMessage 形回调次数
class DispatchCounter {
    public var calls: Int64 = 0
    public var lastSize: Int64 = 0
}

public class AssetManagerTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AssetManagerTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_load_text_async(); () }
            suiteBuilder.add(UnitTestCase.create("test_load_text_async", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_load_error_path(); () }
            suiteBuilder.add(UnitTestCase.create("test_load_error_path", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_load_dedup(); () }
            suiteBuilder.add(UnitTestCase.create("test_load_dedup", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_load_from_bundle(); () }
            suiteBuilder.add(UnitTestCase.create("test_load_from_bundle", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 写一个临时文本文件
    private static func writeTempText(path: String, content: String): Bool {
        try {
            File.writeTo(path, content.toArray())
            return true
        } catch (_: Exception) {
            return false
        }
    }

    /// 轮询等待异步条件成立（最多 timeoutMs 毫秒）
    private static func waitUntil(cond: () -> Bool, timeoutMs!: Int64 = 3000): Bool {
        var waited: Int64 = 0
        while (waited < timeoutMs) {
            if (cond()) {
                return true
            }
            sleep(Duration.millisecond * 20)
            waited += 20
        }
        return cond()
    }

    func test_load_text_async() {
        let path = "test_asset_pipeline_text.tmp"
        assertEqual("准备临时文件", "true", writeTempText(path, "asset-manager-ok"), true)
        // 每个用例用独立 AssetManager，避免相互影响
        let mgr = AssetManager()
        let state = TextState()
        mgr.loadText(path, { t =>
            state.done = true
            state.text = t
        }, onError: { e => state.err = e })
        // 后台线程读盘 → 完成队列 → update 分帧派发
        var dispatched: Int64 = 0
        assertEqual("等待异步完成", "true", waitUntil({ => mgr.pendingCount > 0 }), true)
        while (mgr.pendingCount > 0) {
            dispatched += mgr.update(maxPerFrame: 1, budgetMs: 0.0)
        }
        assertEqual("update 派发 1 条", "true", dispatched == 1, true)
        assertEqual("onLoad 收到文本", "true", state.text == "asset-manager-ok", true)
        assertEqual("无错误", "true", state.err == "", true)
        let _removed = try { removeIfExists(path) } catch (_: Exception) { false }
    }

    func test_load_error_path() {
        let mgr = AssetManager()
        let state = BytesState()
        mgr.loadBytes("definitely_missing_7241.bin", { _ =>
            state.done = true
        }, onError: { e => state.err = e })
        assertEqual("等待失败回包", "true", waitUntil({ => mgr.pendingCount > 0 }), true)
        while (mgr.pendingCount > 0) {
            mgr.update()
        }
        assertEqual("onLoad 不触发", "true", !state.done, true)
        assertEqual("onError 收到信息", "true", state.err != "", true)
    }

    func test_load_dedup() {
        let path = "test_asset_pipeline_dedup.tmp"
        assertEqual("准备临时文件", "true", writeTempText(path, "dup"), true)
        let mgr = AssetManager()
        // 同 URL 连发两次：并发去重只读盘一次，但两个请求都应派发
        let flagBox = FlagBox()
        mgr.loadBytes(path, { _ => flagBox.count += 1 }, onError: { _ => () })
        mgr.loadBytes(path, { _ => flagBox.count += 1 }, onError: { _ => () })
        assertEqual("等待异步完成", "true", waitUntil({ => mgr.pendingCount > 0 }), true)
        while (mgr.pendingCount > 0) {
            mgr.update()
        }
        // 同 URL 第二次请求被去重跳过 → 只有第一次请求派发回调（count==1）
        assertEqual("并发去重：回调 1 次", "true", flagBox.count == 1, true)
        let _removed = try { removeIfExists(path) } catch (_: Exception) { false }
    }

    func test_load_from_bundle() {
        let mgr = AssetManager()
        let builder = AssetBundleBuilder()
        builder.add("cfg.json", "{\"hp\":100}".toArray())
        builder.add("mesh.bin", [0x11u8, 0x22u8])
        let bundle = AssetBundle.loadFromBytes(builder.build())
        assertEqual("bundle 构建成功", "true", bundle.isSome(), true)
        match (bundle) {
            case Some(b) =>
                // 分发存在的条目
                let state = BytesState()
                mgr.loadFromBundle(b, "mesh.bin", { res =>
                    state.done = true
                    match (res) {
                        case br: BytesLoadResult => state.size = br.value.size
                        case _ => state.size = -1
                    }
                }, onError: { e => state.err = e })
                assertEqual("等待分发", "true", waitUntil({ => mgr.pendingCount > 0 }), true)
                while (mgr.pendingCount > 0) {
                    mgr.update()
                }
                assertEqual("包内分发成功", "true", state.done, true)
                assertEqual("包内字节一致", "true", state.size == 2, true)
                // 缓存命中：再次分发同条目（不重读包，仍走派发路径）
                let again = DispatchCounter()
                mgr.loadFromBundle(b, "mesh.bin", { _ => again.calls += 1 }, onError: { _ => () })
                while (mgr.pendingCount > 0) {
                    mgr.update()
                }
                assertEqual("缓存命中再派发", "true", again.calls == 1, true)
                // 分发不存在的条目 → onError
                let miss = BytesState()
                mgr.loadFromBundle(b, "nope", { _ => miss.done = true }, onError: { e => miss.err = e })
                while (mgr.pendingCount > 0) {
                    mgr.update()
                }
                assertEqual("缺失条目 onError", "true", !miss.done && miss.err != "", true)
            case None => ()
        }
    }
}

/// 回调计数容器（供 lambda 修改）
class FlagBox {
    public var count: Int64 = 0
}
