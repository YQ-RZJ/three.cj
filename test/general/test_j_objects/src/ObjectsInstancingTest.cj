/**
 * @file ObjectsInstancingTest
 * @brief 迁移 three.js test/unit/src/objects 目录 tests.js 的 Instancing / isXxx 断言
 *
 * 对照 JS:
 *   new Mesh() → object.isMesh === true
 *   new Points() → object.isPoints === true 等
 */
package test_j_objects

import std.unittest.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.geometry.BufferGeometry
import three.rendering.materials.Material

public class ObjectsInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ObjectsInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言
        let mesh = Mesh()
        assertEqual("Mesh isMesh", "true", (mesh is Mesh).toString(), "true")

        let points = Points()
        assertEqual("Points isPoints", "true", (points is Points).toString(), "true")

        let line = Line()
        assertEqual("Line isLine", "true", (line is Line).toString(), "true")

        let lineLoop = LineLoop()
        assertEqual("LineLoop isLineLoop", "true", (lineLoop is LineLoop).toString(), "true")

        let lineSegments = LineSegments()
        assertEqual("LineSegments isLineSegments", "true", (lineSegments is LineSegments).toString(), "true")

        let group = Group()
        assertEqual("Group isGroup", "true", (group is Group).toString(), "true")

        let bone = Bone()
        assertEqual("Bone isBone", "true", (bone is Bone).toString(), "true")

        let sprite = Sprite()
        assertEqual("Sprite isSprite", "true", (sprite is Sprite).toString(), "true")

        let instanced = InstancedMesh(geometry: BufferGeometry(), material: Material(), count: 1)
        assertEqual("InstancedMesh isInstancedMesh", "true", (instanced is InstancedMesh).toString(), "true")

        let skinned = SkinnedMesh(geometry: BufferGeometry(), material: Material())
        assertEqual("SkinnedMesh isSkinnedMesh", "true", (skinned is SkinnedMesh).toString(), "true")

        let lod = LOD()
        assertEqual("LOD isLOD", "true", (lod is LOD).toString(), "true")
    }
}
