/**
 * @file GeometriesInheritanceTest
 * @brief 迁移 three.js test/unit/src/geometries 目录 tests.js 的 Extending 断言
 *
 * 对照 JS:
 *   new BoxGeometry() instanceof BufferGeometry → true
 *   new SphereGeometry() instanceof BufferGeometry → true 等（均继承 BufferGeometry）
 */
package test_j_geometries

import std.unittest.*
import three.rendering.geometry.*
import three.core.math.Vector2
import three.core.math.Vector3
import three.rendering.geometry.BufferGeometry
import three.rendering.geometry.CatmullRomCurve3

public class GeometriesInheritanceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("GeometriesInheritanceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_all_extend_geometry(); () }
            suiteBuilder.add(UnitTestCase.create("test_all_extend_geometry", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_all_extend_geometry() {
        // 对照 JS QUnit: obj instanceof BufferGeometry 断言（仓颉用 kind 判断几何类型）
        // 仓颉构造器为命名参数（对照 JS 位置参数）
        let geoms: Array<BufferGeometry> = [
            BoxGeometry(width: 1.0, height: 1.0, depth: 1.0),
            CapsuleGeometry(radius: 1.0, length: 1.0, capSegments: 4, radialSegments: 8),
            CircleGeometry(radius: 1.0, segments: 8),
            ConeGeometry(radius: 1.0, height: 2.0, radialSegments: 8),
            CylinderGeometry(radiusTop: 1.0, radiusBottom: 1.0, height: 2.0, radialSegments: 8),
            DodecahedronGeometry(radius: 1.0),
            IcosahedronGeometry(radius: 1.0),
            LatheGeometry([Vector2(0.5, 0.0), Vector2(0.5, 1.0)], segments: 8),
            OctahedronGeometry(radius: 1.0),
            PlaneGeometry(width: 1.0, height: 1.0),
            RingGeometry(innerRadius: 0.5, outerRadius: 1.0, thetaSegments: 8),
            SphereGeometry(radius: 1.0, widthSegments: 8, heightSegments: 6),
            TetrahedronGeometry(radius: 1.0),
            TorusGeometry(radius: 1.0, tube: 0.4, radialSegments: 8, tubularSegments: 16),
            TorusKnotGeometry(radius: 1.0, tube: 0.4, tubularSegments: 16, radialSegments: 8),
            // CatmullRomCurve3 需非空 points（空数组触发除零，对照 JS TubeGeometry 测试用曲线）
            TubeGeometry(CatmullRomCurve3(points: [Vector3(0.0, 0.0, 0.0), Vector3(1.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0)]))
        ]
        for (g in geoms) {
            assertEqual("${g.kind} isBufferGeometry", "true", (g is BufferGeometry).toString(), "true")
        }
    }
}
