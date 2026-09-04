/**
 * @file PLYLoaderTest
 * @brief test_loaders: PLYLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.PLYLoader 能力（对照 JS PLYLoader.parse）：
 * - ASCII PLY：vertex 属性（position/color）+ face 索引解析
 */
package test_loaders

import std.unittest.*
import std.collection.*
import std.math.*
import three.resource.loader.PLYLoader
import three.rendering.geometry.BufferGeometry

public class PLYLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("PLYLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_ascii(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_ascii", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_parse_ascii() {
        // 对照 JS: PLYLoader.parse — ASCII PLY（3 顶点 + 1 三角面 + 顶点色）
        let loader = PLYLoader()
        let plyText = #"""
ply
format ascii 1.0
element vertex 3
property float x
property float y
property float z
property uchar red
property uchar green
property uchar blue
element face 1
property list uchar int vertex_indices
end_header
0 0 0 255 0 0
1 0 0 0 255 0
0 1 0 0 0 255
3 0 1 2
"""#
        let geometry = loader.parse(plyText.toArray())
        assertEqual("输出 BufferGeometry", "true", geometry is BufferGeometry, true)

        // position：3 顶点 × 3
        let pos = geometry.getAttribute("position")
        assertEqual("position 存在", "true", pos.isSome(), true)
        match (pos) {
            case Some(p) =>
                assertEqual("position itemSize == 3", "true", p.itemSize == 3, true)
                assertEqual("position count == 3", "true", p.count == 3, true)
                // 第 2 个顶点 (1,0,0)
                assertEqual("v2 x == 1", "true", abs(p.array[3] - 1.0) < 1e-6, true)
            case None => ()
        }

        // color：uchar 缩放 1/255 → (255,0,0) → (1,0,0)
        let col = geometry.getAttribute("color")
        assertEqual("color 存在", "true", col.isSome(), true)
        match (col) {
            case Some(c) =>
                assertEqual("color count == 3", "true", c.count == 3, true)
                assertEqual("v1 color r == 1", "true", abs(c.array[0] - 1.0) < 1e-4, true)
            case None => ()
        }

        // index：面 0 1 2
        assertEqual("index 存在", "true", geometry.index.isSome(), true)
    }
}
