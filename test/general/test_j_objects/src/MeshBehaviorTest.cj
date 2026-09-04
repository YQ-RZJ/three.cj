/**
 * @file MeshBehaviorTest
 * @brief 补充迁移 three.js test/unit/src/objects/Mesh.tests.js 的 copy/material 断言
 *
 * 对照 JS:
 *   const mesh = new Mesh(); mesh.material = new Material();
 *   const copy = mesh.clone(); copy.material 与原件引用不同
 */
package test_j_objects

import std.unittest.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.Material
import three.rendering.geometry.BufferGeometry

public class MeshBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("MeshBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_copy_material(); () }
            suiteBuilder.add(UnitTestCase.create("test_copy_material", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_copy_material() {
        // 对照 JS: clone() 后 material 为新引用（不同对象）
        let mesh = Mesh(geometry: BufferGeometry(), material: Material())
        let clone = mesh.clone()
        match (clone as Mesh) {
            case Some(cm) =>
                assertEqual("clone is Mesh", "true", (cm is Mesh).toString(), "true")
                // 仓颉 Material 对象为独立实例（对照 JS notStrictEqual 语义）
                assertEqual("copy material different", "true", (cm.material.uuid != mesh.material.uuid).toString(), "true")
            case None => assertEqual("clone Mesh", "true", "false", "true")
        }
    }
}
