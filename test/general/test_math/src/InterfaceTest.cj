/**
 * @file InterfaceTest
 * @brief test_math: three.interfaces 接口包新接口单元测试
 *
 * 覆盖：
 * - IFrustumCullable：Object3D/Mesh/Sprite 的世界包围球（Frustum.intersectsObject/intersectsSprite）
 * - IArrayCameraSource：ArrayCamera 子相机数据（FrustumArray.setFromArrayCamera）
 * - IBox3Expandable：Box3.setFromObject/expandByObject（含子对象递归）
 */
package test_math

import std.unittest.*
import std.math.*
import std.collection.*
import three.core.math.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.entity.*
import three.rendering.geometry.*
import three.rendering.materials.*
import three.rendering.cameras.*

public class InterfaceTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("InterfaceTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_frustum_intersects_mesh(); () }
            suiteBuilder.add(UnitTestCase.create("test_frustum_intersects_mesh", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_frustum_intersects_sprite(); () }
            suiteBuilder.add(UnitTestCase.create("test_frustum_intersects_sprite", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_box3_setFromObject(); () }
            suiteBuilder.add(UnitTestCase.create("test_box3_setFromObject", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_box3_setFromObject_precise(); () }
            suiteBuilder.add(UnitTestCase.create("test_box3_setFromObject_precise", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_frustum_array_setFromArrayCamera(); () }
            suiteBuilder.add(UnitTestCase.create("test_frustum_array_setFromArrayCamera", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 用默认投影构造一个 Frustum（对照 JS: new Frustum().setFromProjectionMatrix(pMatrix)）
    func makeDefaultFrustum(): Frustum {
        let camera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
        camera.position.set(0.0, 0.0, 5.0)
        camera.lookAt(Vector3(0.0, 0.0, 0.0))
        // 对照 JS: Camera.updateMatrixWorld 自动维护 matrixWorldInverse（渲染器无需手动 invert）
        camera.updateMatrixWorld(true)
        let projScreen = Matrix4().multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
        let f = Frustum()
        f.setFromProjectionMatrix(projScreen)
        return f
    }

    func test_frustum_intersects_mesh() {
        let frustum = makeDefaultFrustum()
        // 位于视锥内的网格（相机前方原点附近）
        let mesh = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0), material: MeshBasicMaterial())
        mesh.position.set(0.0, 0.0, 0.0)
        mesh.updateMatrixWorld(true)
        assertEqual("视锥内网格 intersectsObject == true", "true", frustum.intersectsObject(mesh), true)
        // 相机在 z=5 面向 -Z，farMesh 在 z=50（相机后方）→ 应不可见
        let farMesh = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0), material: MeshBasicMaterial())
        farMesh.position.set(0.0, 0.0, 50.0)
        farMesh.updateMatrixWorld(true)
        assertEqual("相机后方网格不可见（z=50）", "true", !frustum.intersectsObject(farMesh), true)
    }

    func test_frustum_intersects_sprite() {
        let frustum = makeDefaultFrustum()
        // Sprite 位于相机前方 → 相交
        let sprite = Sprite()
        sprite.material = SpriteMaterial()
        sprite.position.set(0.0, 0.0, 2.0)
        sprite.updateMatrixWorld(true)
        assertEqual("前方 Sprite intersectsSprite == true", "true", frustum.intersectsSprite(sprite), true)
    }

    func test_box3_setFromObject() {
        // 一个含子对象的组：父 Mesh 在原点（边长2），子 Mesh 平移到 (10,0,0)（边长2）
        let parent = Mesh(geometry: BoxGeometry(width: 2.0, height: 2.0, depth: 2.0), material: MeshBasicMaterial())
        let child = Mesh(geometry: BoxGeometry(width: 2.0, height: 2.0, depth: 2.0), material: MeshBasicMaterial())
        child.position.set(10.0, 0.0, 0.0)
        parent.add(child)
        // Box3.setFromObject 应覆盖父与子 → min.x = -1, max.x = 11
        let box = Box3().setFromObject(parent)
        assertEqual("setFromObject min.x == -1", "true", abs(box.min.x + 1.0) < 1e-6, true)
        assertEqual("setFromObject max.x == 11", "true", abs(box.max.x - 11.0) < 1e-6, true)
        assertEqual("setFromObject min.y == -1", "true", abs(box.min.y + 1.0) < 1e-6, true)
        assertEqual("setFromObject max.y == 1", "true", abs(box.max.y - 1.0) < 1e-6, true)
    }

    func test_box3_setFromObject_precise() {
        // 三角形 (0,0,0)(1,0,0)(0,1,0) 绕 Z 旋转 -30°：
        // - 保守路径用 geometry.boundingBox（含多余角点 (1,1,0)）→ max.x = cos30+sin30 ≈ 1.366
        // - 精确路径逐顶点遍历真实 3 顶点 → max.x = cos30 ≈ 0.866（更紧）
        let geom = BufferGeometry()
        geom.setAttribute("position", BufferAttribute([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0], 3))
        let mesh = Mesh(geometry: geom, material: MeshBasicMaterial())
        mesh.rotation.z = -PI / 6.0
        mesh.updateMatrixWorld(true)
        let boxConservative = Box3().setFromObject(mesh, precise: false)
        let boxPrecise = Box3().setFromObject(mesh, precise: true)
        // 精确路径应比保守路径更紧（真实顶点范围更小）
        assertEqual("precise max.x < 保守 max.x", "true", boxPrecise.max.x < boxConservative.max.x, true)
        // 精确路径 max.x ≈ cos30°
        assertEqual("precise max.x ≈ 0.866", "true", abs(boxPrecise.max.x - cos(PI / 6.0)) < 1e-6, true)
        // 保守路径 max.x ≈ cos30+sin30
        assertEqual("保守 max.x ≈ 1.366", "true", abs(boxConservative.max.x - (cos(PI / 6.0) + sin(PI / 6.0))) < 1e-6, true)
    }

    func test_frustum_array_setFromArrayCamera() {
        // ArrayCamera 含两个子相机
        let cam0 = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
        let cam1 = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 100.0)
        cam1.position.set(1.0, 0.0, 0.0)
        let arrayCam = ArrayCamera(cameras: ArrayList<PerspectiveCamera>([cam0, cam1]))
        // 对照 JS: 渲染器对每个相机调用 updateMatrixWorld（Camera 自动维护 matrixWorldInverse）
        arrayCam.updateMatrixWorld(true)
        for (c in arrayCam.cameras) {
            c.updateMatrixWorld(true)
        }
        let frustumArray = FrustumArray(Array<Frustum>(0, { _ => Frustum() }))
        frustumArray.setFromArrayCamera(arrayCam)
        assertEqual("FrustumArray 视锥数 == 2", "true", frustumArray.frustums.size == 2, true)
        // 两个视锥都覆盖原点附近
        let mesh = Mesh(geometry: BoxGeometry(width: 1.0, height: 1.0, depth: 1.0), material: MeshBasicMaterial())
        mesh.position.set(0.5, 0.0, 2.0)
        mesh.updateMatrixWorld(true)
        assertEqual("ArrayCamera 任一视锥 intersectsObject", "true", frustumArray.intersectsObject(mesh), true)
    }
}
