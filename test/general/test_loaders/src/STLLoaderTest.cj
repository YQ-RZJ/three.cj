/**
 * @file STLLoaderTest
 * @brief test_loaders: STLLoader 单元测试（纯逻辑，不涉及渲染）
 *
 * 检测 three.loaders.STLLoader 能力（对照 JS STLLoader.parse）：
 * - 二进制 STL 解析（84 字节头 + 面数据）
 * - ASCII STL 解析（solid/facet normal/vertex）
 */
package test_loaders

import std.unittest.*
import std.collection.*
import std.math.*
import three.utils.memory.AutoFreePtr
import three.resource.loader.STLLoader
import three.rendering.geometry.BufferGeometry

public class STLLoaderTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("STLLoaderTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_binary(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_binary", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_parse_ascii(); () }
            suiteBuilder.add(UnitTestCase.create("test_parse_ascii", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // 构造一个包含 1 个三角形的二进制 STL（80 字节头 + 4 字节面数 + 50 字节面）
    func buildBinarySTL(): Array<UInt8> {
        let bytes = ArrayList<UInt8>()
        // 头 80 字节（全 0）
        for (_ in 0..80) { bytes.add(0u8) }
        // 面数 = 1（小端 UInt32）
        bytes.add(1u8); bytes.add(0u8); bytes.add(0u8); bytes.add(0u8)
        // 法线 (0,0,1) — Float32 小端
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(1.0f32)) { bytes.add(b) }
        // 顶点1 (0,0,0)
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        // 顶点2 (1,0,0)
        for (b in float32LE(1.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        // 顶点3 (0,1,0)
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        for (b in float32LE(1.0f32)) { bytes.add(b) }
        for (b in float32LE(0.0f32)) { bytes.add(b) }
        // 属性字（2 字节）
        bytes.add(0u8); bytes.add(0u8)
        return bytes.toArray()
    }

    // Float32 → 小端 4 字节（IEEE 754 位模式）
    func float32LE(v: Float32): Array<UInt8> {
        let bits = unsafe {
            let holder = AutoFreePtr<Float32>(LibC.malloc<Float32>())
            holder.get().write(v)
            let u32 = CPointer<UInt32>(holder.get()).read()
            holder.dispose()
            u32
        }
        return Array<UInt8>(4, { i =>
            match (i) {
                case 0 => UInt8(bits & 0xFFu32)
                case 1 => UInt8((bits >> 8) & 0xFFu32)
                case 2 => UInt8((bits >> 16) & 0xFFu32)
                case _ => UInt8((bits >> 24) & 0xFFu32)
            }
        })
    }

    func test_parse_binary() {
        let loader = STLLoader()
        let geometry = loader.parse(buildBinarySTL())
        assertEqual("输出 BufferGeometry", "true", geometry is BufferGeometry, true)
        // 对照 JS: position 属性 — 1 个三角形 3 顶点
        let pos = geometry.getAttribute("position")
        assertEqual("position 存在", "true", pos.isSome(), true)
        match (pos) {
            case Some(p) =>
                assertEqual("position itemSize == 3", "true", p.itemSize == 3, true)
                assertEqual("position count == 3", "true", p.count == 3, true)
                // 第二个顶点 x == 1.0
                assertEqual("v2 x == 1", "true", abs(p.array[3] - 1.0) < 1e-6, true)
                // 第三个顶点 y == 1.0
                assertEqual("v3 y == 1", "true", abs(p.array[7] - 1.0) < 1e-6, true)
            case None => ()
        }
        // 对照 JS: normal 属性（面法线 0,0,1）
        let nor = geometry.getAttribute("normal")
        assertEqual("normal 存在", "true", nor.isSome(), true)
        match (nor) {
            case Some(n) =>
                assertEqual("normal z == 1", "true", abs(n.array[2] - 1.0) < 1e-6, true)
            case None => ()
        }
    }

    func test_parse_ascii() {
        let loader = STLLoader()
        let ascii = #"""
solid test
facet normal 0 0 1
  outer loop
    vertex 0 0 0
    vertex 1 0 0
    vertex 0 1 0
  endloop
endfacet
endsolid test
"""#
        let geometry = loader.parse(ascii.toArray())
        assertEqual("输出 BufferGeometry", "true", geometry is BufferGeometry, true)
        let pos = geometry.getAttribute("position")
        assertEqual("position 存在", "true", pos.isSome(), true)
        match (pos) {
            case Some(p) =>
                assertEqual("position count == 3", "true", p.count == 3, true)
                assertEqual("v2 x == 1", "true", abs(p.array[3] - 1.0) < 1e-6, true)
            case None => ()
        }
    }
}
