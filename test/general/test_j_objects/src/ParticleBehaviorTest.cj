/**
 * @file ParticleBehaviorTest
 * @brief 粒子对象（Points/Sprite）行为单元测试
 *
 * 对照 JS: three.js test/unit/src/objects/Points.tests.js、Sprite.tests.js
 * 覆盖：
 * - Points: kind/geometry/material 默认值、copy/clone（几何与材质独立克隆）、
 *   updateMorphTargets（morphTargetDictionary/influences 填充）、
 *   raycast 命中/未命中/阈值/索引分支
 * - Sprite: kind/material/center 默认值、copy/clone、raycast（UV 插值）、单位 quad、世界包围球
 */
package test_j_objects

import std.unittest.*
import std.collection.*
import std.math.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.rendering.materials.*
import three.rendering.cameras.PerspectiveCamera
import three.rendering.cameras.Camera

public class ParticleBehaviorTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("ParticleBehaviorTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_defaults(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_defaults", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_copy_clone(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_copy_clone", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_update_morph_targets(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_update_morph_targets", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_raycast_hit(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_raycast_hit", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_raycast_miss(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_raycast_miss", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_raycast_threshold(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_raycast_threshold", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_points_raycast_indexed(); () }
            suiteBuilder.add(UnitTestCase.create("test_points_raycast_indexed", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_defaults(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_defaults", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_copy_clone(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_copy_clone", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_unit_quad(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_unit_quad", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_raycast(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_raycast", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sprite_bounding_sphere(); () }
            suiteBuilder.add(UnitTestCase.create("test_sprite_bounding_sphere", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    // Points 默认值：kind/geometry/material（对照 JS: new Points() → type === 'Points'）
    func test_points_defaults() {
        let points = Points()
        assertEqual("Points kind", "Points", points.kind, "Points")
        assertEqual("Points geometry is BufferGeometry", "true", (points.geometry is BufferGeometry).toString(), "true")
        assertEqual("Points material is Material", "true", (points.material is Material).toString(), "true")
    }

    // Points copy/clone：geometry 与 material 均为独立克隆（对照 JS Points.copy: geometry.clone() / material.clone()）
    func test_points_copy_clone() {
        let geom = BufferGeometry()
        let mat = PointsMaterial()
        let src = Points(geometry: geom, material: mat)
        let clone = src.clone()
        match (clone as Points) {
            case Some(cp) =>
                assertEqual("clone is Points", "true", (cp is Points).toString(), "true")
                // 仓颉 BufferGeometry/Material 对象为独立实例（对照 JS notStrictEqual 语义）
                assertEqual("copy geometry different", "true", (cp.geometry.uuid != src.geometry.uuid).toString(), "true")
                assertEqual("copy material different", "true", (cp.material.uuid != src.material.uuid).toString(), "true")
            case None => assertEqual("clone Points", "true", "false", "true")
        }
    }

    // Points.updateMorphTargets：从 geometry.morphAttributes.position 填充字典与影响系数
    // 对照 JS: Points.js updateMorphTargets() — morphTargetDictionary 名称→索引，influences 初值 0
    func test_points_update_morph_targets() {
        let geom = BufferGeometry()
        let morphList = ArrayList<BufferAttribute>()
        morphList.add(BufferAttribute([1.0, 0.0, 0.0], 3))
        morphList.add(BufferAttribute([0.0, 1.0, 0.0], 3))
        geom.morphAttributes.add("position", morphList)
        let points = Points(geometry: geom, material: PointsMaterial())
        points.updateMorphTargets()
        assertEqual("morphTargetDictionary size == 2", "true", (points.morphTargetDictionary.size == 2).toString(), "true")
        assertEqual("morphTargetInfluences size == 2", "true", (points.morphTargetInfluences.size == 2).toString(), "true")
        match (points.morphTargetDictionary.get("morphTarget0")) {
            case Some(v) => assertEqual("morphTarget0 index == 0", "true", (v == 0).toString(), "true")
            case None => assertEqual("morphTarget0 exists", "true", "false", "true")
        }
        match (points.morphTargetDictionary.get("morphTarget1")) {
            case Some(v) => assertEqual("morphTarget1 index == 1", "true", (v == 1).toString(), "true")
            case None => assertEqual("morphTarget1 exists", "true", "false", "true")
        }
    }

    // Points raycast 命中：非索引几何，顶点在射线原点上 → distance=5, distanceToRay=0, index=0
    // 对照 JS: Points.js raycast + testPoint（distance/distanceToRay/point/index/obj 完整 Intersection）
    func test_points_raycast_hit() {
        let geom = BufferGeometry()
        geom.setAttribute("position", BufferAttribute([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0], 3))
        let points = Points(geometry: geom, material: PointsMaterial())
        points.updateMatrixWorld(true)
        let raycaster = Raycaster(origin: Vector3(0.0, 0.0, -5.0), direction: Vector3(0.0, 0.0, 1.0))
        let hits = raycaster.intersectObject(points)
        assertEqual("hit count == 1", "true", (hits.size == 1).toString(), "true")
        if (hits.size > 0) {
            assertEqual("hit distance == 5", "true", (abs(hits[0].distance - 5.0) < 1e-9).toString(), "true")
            assertEqual("hit distanceToRay == 0", "true", (abs(hits[0].distanceToRay) < 1e-9).toString(), "true")
            assertEqual("hit index == 0", "true", (hits[0].index == 0).toString(), "true")
            match (hits[0].obj) {
                case Some(o) => assertEqual("hit obj is Points", "true", (o is Points).toString(), "true")
                case None => assertEqual("hit obj present", "true", "false", "true")
            }
            // 命中点应为世界原点 (0,0,0)（射线最近点）
            assertEqual("hit point x", "true", (abs(hits[0].point.x) < 1e-9).toString(), "true")
            assertEqual("hit point y", "true", (abs(hits[0].point.y) < 1e-9).toString(), "true")
            assertEqual("hit point z", "true", (abs(hits[0].point.z) < 1e-9).toString(), "true")
        }
    }

    // Points raycast 未命中：所有顶点距射线均 > 阈值（threshold=1）→ 空结果
    func test_points_raycast_miss() {
        let geom = BufferGeometry()
        // 顶点都在 y=10 平面，远离 x 轴射线
        geom.setAttribute("position", BufferAttribute([0.0, 10.0, 0.0, 1.0, 10.0, 0.0, 0.0, 10.0, 1.0], 3))
        let points = Points(geometry: geom, material: PointsMaterial())
        points.updateMatrixWorld(true)
        let raycaster = Raycaster(origin: Vector3(0.0, 0.0, -5.0), direction: Vector3(0.0, 0.0, 1.0))
        let hits = raycaster.intersectObject(points)
        assertEqual("miss count == 0", "true", (hits.size == 0).toString(), "true")
    }

    // Points raycast 阈值：调大 pointsThreshold 使远处顶点也可命中（对照 JS raycaster.params.Points.threshold）
    func test_points_raycast_threshold() {
        let geom = BufferGeometry()
        // 顶点在 y=2：与射线距离 2，默认阈值 1 不命中
        geom.setAttribute("position", BufferAttribute([0.0, 2.0, 0.0, 1.0, 2.0, 0.0, 0.0, 2.0, 1.0], 3))
        let points = Points(geometry: geom, material: PointsMaterial())
        points.updateMatrixWorld(true)
        let raycaster = Raycaster(origin: Vector3(0.0, 0.0, -5.0), direction: Vector3(0.0, 0.0, 1.0))
        let hits = raycaster.intersectObject(points)
        assertEqual("default threshold miss", "true", (hits.size == 0).toString(), "true")
        // 调大阈值到 3 → 命中
        let raycaster2 = Raycaster(origin: Vector3(0.0, 0.0, -5.0), direction: Vector3(0.0, 0.0, 1.0))
        raycaster2.params.pointsThreshold = 3.0
        let hits2 = raycaster2.intersectObject(points)
        assertEqual("large threshold hit", "true", (hits2.size > 0).toString(), "true")
    }

    // Points raycast 索引几何分支：通过 geometry.index 走索引路径（对照 JS: indexAttribute 分支）
    func test_points_raycast_indexed() {
        let geom = BufferGeometry()
        geom.setAttribute("position", BufferAttribute([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0], 3))
        geom.setIndex(BufferAttribute([0.0, 1.0, 2.0], 1))
        let points = Points(geometry: geom, material: PointsMaterial())
        points.updateMatrixWorld(true)
        let raycaster = Raycaster(origin: Vector3(0.0, 0.0, -5.0), direction: Vector3(0.0, 0.0, 1.0))
        let hits = raycaster.intersectObject(points)
        assertEqual("indexed hit count == 1", "true", (hits.size == 1).toString(), "true")
        if (hits.size > 0) {
            assertEqual("indexed hit index == 0", "true", (hits[0].index == 0).toString(), "true")
            assertEqual("indexed hit distance", "true", (abs(hits[0].distance - 5.0) < 1e-9).toString(), "true")
        }
    }

    // Sprite 默认值：kind/material/center（对照 JS: new Sprite() → type === 'Sprite'，center 默认 (0.5,0.5)）
    func test_sprite_defaults() {
        let sprite = Sprite()
        assertEqual("Sprite kind", "Sprite", sprite.kind, "Sprite")
        assertEqual("Sprite material is SpriteMaterial", "true", (sprite.material is SpriteMaterial).toString(), "true")
        assertEqual("Sprite center x == 0.5", "true", (abs(sprite.center.x - 0.5) < 1e-9).toString(), "true")
        assertEqual("Sprite center y == 0.5", "true", (abs(sprite.center.y - 0.5) < 1e-9).toString(), "true")
    }

    // Sprite copy/clone：material 独立克隆，center 复制（对照 JS: Sprite.copy 复制 material/center）
    func test_sprite_copy_clone() {
        let src = Sprite(material: SpriteMaterial())
        src.center.set(0.25, 0.75)
        let clone = src.clone()
        match (clone as Sprite) {
            case Some(cs) =>
                assertEqual("clone is Sprite", "true", (cs is Sprite).toString(), "true")
                assertEqual("copy material different", "true", (cs.material.uuid != src.material.uuid).toString(), "true")
                assertEqual("copy center x", "true", (abs(cs.center.x - 0.25) < 1e-9).toString(), "true")
                assertEqual("copy center y", "true", (abs(cs.center.y - 0.75) < 1e-9).toString(), "true")
            case None => assertEqual("clone Sprite", "true", "false", "true")
        }
    }

    // Sprite 共享单位 quad：4 顶点 position/uv + 索引，CCW 点序（对照 JS: WebGLRenderer _getUnitSprite）
    func test_sprite_unit_quad() {
        let geom = Sprite._getUnitQuadGeometry()
        assertEqual("unit quad is BufferGeometry", "true", (geom is BufferGeometry).toString(), "true")
        match (geom.getAttribute("position")) {
            case Some(pos) =>
                assertEqual("unit quad 4 vertices", "true", (pos.count == 4).toString(), "true")
                // 顶点范围 [-0.5, 0.5]（单位 quad）
                assertEqual("unit quad min x", "true", (pos.getX(0) == -0.5).toString(), "true")
                assertEqual("unit quad max x", "true", (pos.getX(2) == 0.5).toString(), "true")
            case None => assertEqual("unit quad position attr", "true", "false", "true")
        }
        match (geom.index) {
            case Some(_) => assertEqual("unit quad index present", "true", "true", "true")
            case None => assertEqual("unit quad index present", "true", "false", "true")
        }
    }

    // Sprite raycast：相机在原点，精灵在 (0,0,5)，射线 +Z → 命中 distance=5、uv=(0.5,0.5)
    // 对照 JS: Sprite.js raycast — 平面相交 + UV 插值（intersection.uv）
    func test_sprite_raycast() {
        let camera = PerspectiveCamera()
        camera.position.set(0.0, 0.0, 0.0)
        camera.updateMatrixWorld(true)
        let sprite = Sprite(material: SpriteMaterial())
        sprite.position.set(0.0, 0.0, 5.0)
        sprite.scale.set(2.0, 2.0, 1.0)
        sprite.updateMatrixWorld(true)
        let raycaster = Raycaster(origin: Vector3(0.0, 0.0, 0.0), direction: Vector3(0.0, 0.0, 1.0))
        raycaster.camera = Some(camera)
        let hits = raycaster.intersectObject(sprite)
        assertEqual("sprite hit count == 1", "true", (hits.size == 1).toString(), "true")
        if (hits.size > 0) {
            assertEqual("sprite hit distance", "true", (abs(hits[0].distance - 5.0) < 1e-6).toString(), "true")
            match (hits[0].uv) {
                case Some(uv) =>
                    assertEqual("sprite hit uv x == 0.5", "true", (abs(uv.x - 0.5) < 1e-6).toString(), "true")
                    assertEqual("sprite hit uv y == 0.5", "true", (abs(uv.y - 0.5) < 1e-6).toString(), "true")
                case None => assertEqual("sprite hit uv present", "true", "false", "true")
            }
        }
    }

    // Sprite 世界包围球（对照 JS: Frustum.intersectsSprite 依赖的包围球）
    func test_sprite_bounding_sphere() {
        let sprite = Sprite(material: SpriteMaterial())
        sprite.position.set(1.0, 2.0, 3.0)
        sprite.updateMatrixWorld(true)
        match (sprite.getWorldBoundingSphere()) {
            case Some(sphere) =>
                assertEqual("sphere radius > 0", "true", (sphere[3] > 0.0).toString(), "true")
                assertEqual("sphere center x == 1", "true", (abs(sphere[0] - 1.0) < 1e-9).toString(), "true")
                assertEqual("sphere center y == 2", "true", (abs(sphere[1] - 2.0) < 1e-9).toString(), "true")
                assertEqual("sphere center z == 3", "true", (abs(sphere[2] - 3.0) < 1e-9).toString(), "true")
            case None => assertEqual("sprite bounding sphere", "true", "false", "true")
        }
    }
}
