/**
 * @file ObjectsInheritanceTest
 * @brief 迁移 three.js test/unit/src/objects 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new Mesh() instanceof Object3D → true
 *   new Line() instanceof Object3D → true 等
 */
package test_j_objects

import std.unittest.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.scene.objects.Object3D
import three.rendering.geometry.BufferGeometry
import three.rendering.materials.Material

public class ObjectsInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ObjectsInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_object3d(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_object3d", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_object3d() {
        // 对照 JS QUnit: obj instanceof Object3D 断言
        let mesh = Mesh()
        assertEqual("Mesh is Object3D", "true", (mesh is Object3D).toString(), "true")

        let points = Points()
        assertEqual("Points is Object3D", "true", (points is Object3D).toString(), "true")

        let line = Line()
        assertEqual("Line is Object3D", "true", (line is Object3D).toString(), "true")

        let lineLoop = LineLoop()
        assertEqual("LineLoop is Object3D", "true", (lineLoop is Object3D).toString(), "true")

        let lineSegments = LineSegments()
        assertEqual("LineSegments is Object3D", "true", (lineSegments is Object3D).toString(), "true")

        let group = Group()
        assertEqual("Group is Object3D", "true", (group is Object3D).toString(), "true")

        let bone = Bone()
        assertEqual("Bone is Object3D", "true", (bone is Object3D).toString(), "true")

        let sprite = Sprite()
        assertEqual("Sprite is Object3D", "true", (sprite is Object3D).toString(), "true")

        let instanced = InstancedMesh(geometry: BufferGeometry(), material: Material(), count: 1)
        assertEqual("InstancedMesh is Object3D", "true", (instanced is Object3D).toString(), "true")

        let skinned = SkinnedMesh(BufferGeometry(), Material())
        assertEqual("SkinnedMesh is Object3D", "true", (skinned is Object3D).toString(), "true")

        let lod = LOD()
        assertEqual("LOD is Object3D", "true", (lod is Object3D).toString(), "true")
    }
}

/// 辅助：BufferGeometry 占位（InstancedMesh 构造需要）
public class BufferGeometryProxy <: BufferGeometry {
    public init() { super() }
}

public class MaterialProxy <: Material {
    public init() { super() }
}
