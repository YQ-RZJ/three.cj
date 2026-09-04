/**
 * @file GeometriesInstancingTest
 * @brief 迁移 three.js test/unit/src/geometries 目录 tests.js 的 Instancing / isXxx 断言
 *
 * 对照 JS:
 *   new BoxGeometry() → object.isBoxGeometry === true
 *   new SphereGeometry() → object.isSphereGeometry === true 等
 */
package test_j_geometries

import std.unittest.*
import three.rendering.geometry.*
import three.core.math.Vector2
import three.core.math.Vector3
import three.rendering.geometry.CatmullRomCurve3

public class GeometriesInstancingTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("GeometriesInstancingTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_is_flags(); () }
            suiteBuilder.add(UnitTestCase.create("test_is_flags", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_is_flags() {
        // 对照 JS QUnit: object.isXxx 断言（仓颉几何体无 isXxx 标志，改用 kind 断言）
        assertEqual("Box kind", "BoxGeometry", BoxGeometry(width: 1.0, height: 1.0, depth: 1.0).kind, "BoxGeometry")
        assertEqual("Circle kind", "CircleGeometry", CircleGeometry(radius: 1.0, segments: 8).kind, "CircleGeometry")
        assertEqual("Cone kind", "ConeGeometry", ConeGeometry(radius: 1.0, height: 2.0, radialSegments: 8).kind, "ConeGeometry")
        assertEqual("Cylinder kind", "CylinderGeometry", CylinderGeometry(radiusTop: 1.0, radiusBottom: 1.0, height: 2.0, radialSegments: 8).kind, "CylinderGeometry")
        assertEqual("Dodecahedron kind", "DodecahedronGeometry", DodecahedronGeometry(radius: 1.0).kind, "DodecahedronGeometry")
        assertEqual("Icosahedron kind", "IcosahedronGeometry", IcosahedronGeometry(radius: 1.0).kind, "IcosahedronGeometry")
        assertEqual("Octahedron kind", "OctahedronGeometry", OctahedronGeometry(radius: 1.0).kind, "OctahedronGeometry")
        assertEqual("Plane kind", "PlaneGeometry", PlaneGeometry(width: 1.0, height: 1.0).kind, "PlaneGeometry")
        assertEqual("Ring kind", "RingGeometry", RingGeometry(innerRadius: 0.5, outerRadius: 1.0, thetaSegments: 8).kind, "RingGeometry")
        assertEqual("Sphere kind", "SphereGeometry", SphereGeometry(radius: 1.0, widthSegments: 8, heightSegments: 6).kind, "SphereGeometry")
        assertEqual("Tetrahedron kind", "TetrahedronGeometry", TetrahedronGeometry(radius: 1.0).kind, "TetrahedronGeometry")
        assertEqual("Torus kind", "TorusGeometry", TorusGeometry(radius: 1.0, tube: 0.4, radialSegments: 8, tubularSegments: 16).kind, "TorusGeometry")
        assertEqual("TorusKnot kind", "TorusKnotGeometry", TorusKnotGeometry(radius: 1.0, tube: 0.4, tubularSegments: 16, radialSegments: 8).kind, "TorusKnotGeometry")
        assertEqual("Capsule kind", "CapsuleGeometry", CapsuleGeometry(radius: 1.0, length: 1.0, capSegments: 4, radialSegments: 8).kind, "CapsuleGeometry")
        assertEqual("Lathe kind", "LatheGeometry", LatheGeometry([Vector2(0.5, 0.0), Vector2(0.5, 1.0)], segments: 8).kind, "LatheGeometry")
        assertEqual("Tube kind", "TubeGeometry", TubeGeometry(CatmullRomCurve3(points: [Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0)])).kind, "TubeGeometry")
    }
}
