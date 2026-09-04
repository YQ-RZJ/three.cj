/**
 * @file ParticleMaterialBehaviorTest
 * @brief 粒子材质（PointsMaterial/SpriteMaterial）行为单元测试
 *
 * 对照 JS: three.js test/unit/src/materials/PointsMaterial.tests.js、SpriteMaterial.tests.js
 * 覆盖：
 * - PointsMaterial: kind 默认值、size/sizeAttenuation 默认值、copy 语义（size/sizeAttenuation/color/map）
 * - SpriteMaterial: kind 默认值、sizeAttenuation/rotation/transparent/fog 默认值、copy 语义
 */
package test_j_materials

import std.unittest.*
import std.math.*
import three.rendering.materials.*
import three.rendering.textures.*
import three.core.math.*

public class ParticleMaterialBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ParticleMaterialBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_material_defaults(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_material_defaults", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_material_copy(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_material_copy", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_material_defaults(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_material_defaults", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_material_copy(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_material_copy", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // PointsMaterial 默认值（对照 JS: size=1, sizeAttenuation=true, map=null, alphaMap=null）
    func test_points_material_defaults() {
        let pm = PointsMaterial()
        assertEqual("PointsMaterial kind", "PointsMaterial", pm.kind, "PointsMaterial")
        assertEqual("size == 1.0", "true", (pm.size == 1.0).toString(), "true")
        assertEqual("sizeAttenuation == true", "true", (pm.sizeAttenuation == true).toString(), "true")
        assertEqual("map is None", "true", (pm.map.isNone()).toString(), "true")
        assertEqual("alphaMap is None", "true", (pm.alphaMap.isNone()).toString(), "true")
        // 继承自 Material 基类：fog 默认 true、color 默认白
        assertEqual("fog == true", "true", (pm.fog == true).toString(), "true")
        assertEqual("color default white", "true", (abs(pm.color.r - 1.0) < 1e-9).toString(), "true")
    }

    // PointsMaterial.copy：复制 size/sizeAttenuation/color/map/alphaMap（对照 JS: PointsMaterial.js copy()）
    func test_points_material_copy() {
        let src = PointsMaterial()
        src.size = 3.0
        src.sizeAttenuation = false
        src.color.setHex(0xff0000)
        src.map = Some(Texture())
        src.alphaMap = Some(Texture())
        let dst = PointsMaterial()
        dst.copy(src)
        assertEqual("copy size", "true", (dst.size == 3.0).toString(), "true")
        assertEqual("copy sizeAttenuation", "true", (dst.sizeAttenuation == false).toString(), "true")
        assertEqual("copy color r", "true", (abs(dst.color.r - src.color.r) < 1e-9).toString(), "true")
        assertEqual("copy map", "true", (dst.map.isSome()).toString(), "true")
        assertEqual("copy alphaMap", "true", (dst.alphaMap.isSome()).toString(), "true")
    }

    // SpriteMaterial 默认值（对照 JS: sizeAttenuation=true, rotation=0, transparent=true, fog=true）
    func test_sprite_material_defaults() {
        let sm = SpriteMaterial()
        assertEqual("SpriteMaterial kind", "SpriteMaterial", sm.kind, "SpriteMaterial")
        assertEqual("sizeAttenuation == true", "true", (sm.sizeAttenuation == true).toString(), "true")
        assertEqual("rotation == 0.0", "true", (sm.rotation == 0.0).toString(), "true")
        assertEqual("map is None", "true", (sm.map.isNone()).toString(), "true")
        assertEqual("alphaMap is None", "true", (sm.alphaMap.isNone()).toString(), "true")
        // JS 侧 sprite 材质默认透明（this.transparent = true）
        assertEqual("transparent == true", "true", (sm.transparent == true).toString(), "true")
        assertEqual("fog == true", "true", (sm.fog == true).toString(), "true")
    }

    // SpriteMaterial.copy：复制 sizeAttenuation/rotation/color/map/alphaMap（对照 JS: SpriteMaterial.js copy()）
    func test_sprite_material_copy() {
        let src = SpriteMaterial()
        src.sizeAttenuation = false
        src.rotation = 1.5
        src.color.setHex(0x00ff00)
        src.map = Some(Texture())
        let dst = SpriteMaterial()
        dst.copy(src)
        assertEqual("copy sizeAttenuation", "true", (dst.sizeAttenuation == false).toString(), "true")
        assertEqual("copy rotation", "true", (dst.rotation == 1.5).toString(), "true")
        assertEqual("copy color g", "true", (abs(dst.color.g - src.color.g) < 1e-9).toString(), "true")
        assertEqual("copy map", "true", (dst.map.isSome()).toString(), "true")
        // transparent 由基类 copy 复制
        assertEqual("copy transparent", "true", (dst.transparent == true).toString(), "true")
    }
}
