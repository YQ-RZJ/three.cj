/**
 * @file BvhTest
 * @brief test_dsa: Bvh（包围体层次结构）单元测试
 *
 * 检测 three.core.dsa.Bvh 能力：
 * - 空 BVH 的状态（nodeCount/elementCount/isEmpty）与查询安全性
 * - 单元素与多元素构建后的节点数与元素数
 * - 视锥查询结果与暴力法（逐元素相交测试）完全一致
 * - refit 后（元素移动）查询结果仍与暴力法一致
 * - 射线查询结果与暴力法一致
 * - 根节点包围盒覆盖全部元素
 */
package test_dsa

import std.unittest.*
import std.collection.*
import std.math.*
import std.random.*
import std.sort.*
import three.core.dsa.Bvh
import three.core.math.*
import three.rendering.cameras.PerspectiveCamera

public class BvhTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("BvhTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_empty(); () }
            suiteBuilder.add(UnitTestCase.create("test_empty", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_single_element(); () }
            suiteBuilder.add(UnitTestCase.create("test_single_element", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_multi_element_counts(); () }
            suiteBuilder.add(UnitTestCase.create("test_multi_element_counts", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_frustum_matches_bruteforce(); () }
            suiteBuilder.add(UnitTestCase.create("test_frustum_matches_bruteforce", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_refit_matches_bruteforce(); () }
            suiteBuilder.add(UnitTestCase.create("test_refit_matches_bruteforce", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_ray_matches_bruteforce(); () }
            suiteBuilder.add(UnitTestCase.create("test_ray_matches_bruteforce", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_root_bounds_cover_all(); () }
            suiteBuilder.add(UnitTestCase.create("test_root_bounds_cover_all", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 构造一组测试元素（中心 + 半尺寸），返回 (centerX, centerY, centerZ, halfX, halfY, halfZ)
    private func makeElements(count: Int64): (Array<Float64>, Array<Float64>, Array<Float64>,
                                             Array<Float64>, Array<Float64>, Array<Float64>) {
        let cx = Array<Float64>(count, { _ => 0.0 })
        let cy = Array<Float64>(count, { _ => 0.0 })
        let cz = Array<Float64>(count, { _ => 0.0 })
        let hx = Array<Float64>(count, { _ => 0.0 })
        let hy = Array<Float64>(count, { _ => 0.0 })
        let hz = Array<Float64>(count, { _ => 0.0 })
        // 伪随机但确定的分布（网格 + 扰动）；用 std.random.Random 避免手写 LCG 的 UInt64 溢出
        let rng = Random(20260922u64)
        for (i in 0..count) {
            let rx = rng.nextFloat64()
            let ry = rng.nextFloat64()
            let rz = rng.nextFloat64()
            cx[i] = (Float64(i % 10) - 5.0) * 3.0 + rx * 2.0
            cy[i] = (Float64(i / 10 % 10) - 5.0) * 3.0 + ry * 2.0
            cz[i] = (Float64(i / 100) - 5.0) * 3.0 + rz * 2.0
            hx[i] = 0.5 + rx * 0.5
            hy[i] = 0.5 + ry * 0.5
            hz[i] = 0.5 + rz * 0.5
        }
        return (cx, cy, cz, hx, hy, hz)
    }

    /// 暴力法：逐元素做 AABB 与视锥相交测试
    private func bruteForceFrustum(frustum: Frustum,
                                   cx: Array<Float64>, cy: Array<Float64>, cz: Array<Float64>,
                                   hx: Array<Float64>, hy: Array<Float64>, hz: Array<Float64>): ArrayList<Int64> {
        let result = ArrayList<Int64>()
        for (i in 0..cx.size) {
            let box = Box3(
                Vector3(cx[i] - hx[i], cy[i] - hy[i], cz[i] - hz[i]),
                Vector3(cx[i] + hx[i], cy[i] + hy[i], cz[i] + hz[i])
            )
            if (frustum.intersectsBox(box)) {
                result.add(i)
            }
        }
        return result
    }

    /// 排序后比较两个下标集合是否相同
    private func sameSet(a: ArrayList<Int64>, b: ArrayList<Int64>): Bool {
        if (a.size != b.size) {
            return false
        }
        let sa = a.toArray()
        let sb = b.toArray()
        sort(sa)
        sort(sb)
        for (i in 0..sa.size) {
            if (sa[i] != sb[i]) {
                return false
            }
        }
        return true
    }

    /// 空 BVH 状态与查询安全性
    func test_empty() {
        let bvh = Bvh()
        assertEqual("empty elementCount", "0", 0, bvh.elementCount)
        assertEqual("empty nodeCount", "0", 0, bvh.nodeCount)
        assertEqual("empty isEmpty", "true", true, bvh.isEmpty())

        // 空 BVH 上查询不应崩溃，也不应产生命中
        let frustum = Frustum()
        let hits = ArrayList<Int64>()
        bvh.queryFrustum(frustum, hits)
        assertEqual("empty query hits", "0", 0, hits.size)
    }

    /// 单元素构建
    func test_single_element() {
        let bvh = Bvh()
        bvh.build(
            Array<Float64>(1, { _ => 1.0 }),
            Array<Float64>(1, { _ => 2.0 }),
            Array<Float64>(1, { _ => 3.0 }),
            Array<Float64>(1, { _ => 0.5 }),
            Array<Float64>(1, { _ => 0.5 }),
            Array<Float64>(1, { _ => 0.5 })
        )
        assertEqual("single elementCount", "1", 1, bvh.elementCount)
        assertEqual("single nodeCount", "1", 1, bvh.nodeCount)

        let minV = Vector3()
        let maxV = Vector3()
        assertEqual("single has root", "true", true, bvh.getRootBounds(minV, maxV))
        assertEqual("single root minX", "0.5", 0.5, minV.x)
        assertEqual("single root maxX", "1.5", 1.5, maxV.x)
        assertEqual("single root minY", "1.5", 1.5, minV.y)
        assertEqual("single root maxY", "2.5", 2.5, maxV.y)
        assertEqual("single root minZ", "2.5", 2.5, minV.z)
        assertEqual("single root maxZ", "3.5", 3.5, maxV.z)
    }

    /// 多元素构建后的节点数与元素数
    func test_multi_element_counts() {
        let count = 500
        let (cx, cy, cz, hx, hy, hz) = makeElements(count)
        let bvh = Bvh()
        bvh.build(cx, cy, cz, hx, hy, hz)
        assertEqual("multi elementCount", "expect", bvh.elementCount, count)
        // 满二叉树叶子数 n/2~n，总节点数 2n-1 上下界
        assertEqual("multi nodeCount >= n-1", "true", true, bvh.nodeCount >= count - 1)
        assertEqual("multi nodeCount <= 2n-1", "true", true, bvh.nodeCount <= 2 * count - 1)
    }

    /// 视锥查询与暴力法结果一致（多组相机位姿）
    func test_frustum_matches_bruteforce() {
        let count = 400
        let (cx, cy, cz, hx, hy, hz) = makeElements(count)
        let bvh = Bvh()
        bvh.build(cx, cy, cz, hx, hy, hz)

        // 若干个不同位姿的相机
        let camPoses: Array<(Float64, Float64, Float64)> = [
            (0.0, 0.0, 20.0),
            (0.0, 0.0, 0.0),
            (30.0, 20.0, 30.0),
            (-25.0, -25.0, 10.0),
            (5.0, 40.0, -30.0)
        ]
        for (pose in camPoses) {
            let camera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
            camera.position.set(pose[0], pose[1], pose[2])
            camera.lookAt(Vector3(0.0, 0.0, 0.0))
            camera.updateMatrixWorld(true)

            let projScreen = Matrix4()
            projScreen.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
            let frustum = Frustum()
            frustum.setFromProjectionMatrix(projScreen)

            let hits = ArrayList<Int64>()
            bvh.queryFrustum(frustum, hits)
            let expected = bruteForceFrustum(frustum, cx, cy, cz, hx, hy, hz)
            assertEqual("frustum hits match brute force (pose ${pose[0]},${pose[1]},${pose[2]})",
                        "true", true, sameSet(hits, expected))
        }
    }

    /// refit 后（元素移动）查询结果仍与暴力法一致
    func test_refit_matches_bruteforce() {
        let count = 200
        let (cx0, cy0, cz0, hx, hy, hz) = makeElements(count)
        let bvh = Bvh()
        bvh.build(cx0, cy0, cz0, hx, hy, hz)

        // 把所有元素平移到远处
        let cx = Array<Float64>(count, { _ => 0.0 })
        let cy = Array<Float64>(count, { _ => 0.0 })
        let cz = Array<Float64>(count, { _ => 0.0 })
        for (i in 0..count) {
            cx[i] = cx0[i] + 100.0
            cy[i] = cy0[i]
            cz[i] = cz0[i]
        }
        bvh.updateCenters(cx, cy, cz)

        // 相机仍看向原点：此时应几乎全部不可见
        let camera = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
        camera.position.set(0.0, 0.0, 0.0)
        camera.lookAt(Vector3(0.0, 0.0, -1.0))
        camera.updateMatrixWorld(true)
        let projScreen = Matrix4()
        projScreen.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
        let frustum = Frustum()
        frustum.setFromProjectionMatrix(projScreen)

        let hits = ArrayList<Int64>()
        bvh.queryFrustum(frustum, hits)
        let expected = bruteForceFrustum(frustum, cx, cy, cz, hx, hy, hz)
        assertEqual("refit hits match brute force", "true", true, sameSet(hits, expected))

        // 相机移到平移后的中心附近：应命中大部分元素
        let camera2 = PerspectiveCamera(fov: 60.0, aspect: 1.0, near: 0.1, far: 200.0)
        camera2.position.set(100.0, 0.0, 0.0)
        camera2.lookAt(Vector3(100.0, 0.0, -100.0))
        camera2.updateMatrixWorld(true)
        let projScreen2 = Matrix4()
        projScreen2.multiplyMatrices(camera2.projectionMatrix, camera2.matrixWorldInverse)
        let frustum2 = Frustum()
        frustum2.setFromProjectionMatrix(projScreen2)

        let hits2 = ArrayList<Int64>()
        bvh.queryFrustum(frustum2, hits2)
        let expected2 = bruteForceFrustum(frustum2, cx, cy, cz, hx, hy, hz)
        assertEqual("refit hits2 match brute force", "true", true, sameSet(hits2, expected2))
        assertEqual("refit hits2 > 0", "true", true, hits2.size > 0)
    }

    /// 射线查询与暴力法一致
    func test_ray_matches_bruteforce() {
        let count = 200
        let (cx, cy, cz, hx, hy, hz) = makeElements(count)
        let bvh = Bvh()
        bvh.build(cx, cy, cz, hx, hy, hz)

        let origin = Vector3(0.0, 0.0, 50.0)
        let direction = Vector3(0.0, 0.0, -1.0)
        let maxDistance = 200.0

        let hits = ArrayList<Int64>()
        bvh.queryRay(origin, direction, maxDistance, hits)

        // 暴力法：逐元素用 Box3 的射线相交
        let ray = Ray(origin, direction)
        let expected = ArrayList<Int64>()
        for (i in 0..count) {
            let box = Box3(
                Vector3(cx[i] - hx[i], cy[i] - hy[i], cz[i] - hz[i]),
                Vector3(cx[i] + hx[i], cy[i] + hy[i], cz[i] + hz[i])
            )
            if (ray.intersectsBox(box)) {
                expected.add(i)
            }
        }
        assertEqual("ray hits match brute force", "true", true, sameSet(hits, expected))
    }

    /// 根节点包围盒覆盖全部元素
    func test_root_bounds_cover_all() {
        let count = 100
        let (cx, cy, cz, hx, hy, hz) = makeElements(count)
        let bvh = Bvh()
        bvh.build(cx, cy, cz, hx, hy, hz)

        let minV = Vector3()
        let maxV = Vector3()
        assertEqual("has root", "true", true, bvh.getRootBounds(minV, maxV))

        var minX = Float64.Inf
        var minY = Float64.Inf
        var minZ = Float64.Inf
        var maxX = -Float64.Inf
        var maxY = -Float64.Inf
        var maxZ = -Float64.Inf
        for (i in 0..count) {
            if (cx[i] - hx[i] < minX) { minX = cx[i] - hx[i] }
            if (cy[i] - hy[i] < minY) { minY = cy[i] - hy[i] }
            if (cz[i] - hz[i] < minZ) { minZ = cz[i] - hz[i] }
            if (cx[i] + hx[i] > maxX) { maxX = cx[i] + hx[i] }
            if (cy[i] + hy[i] > maxY) { maxY = cy[i] + hy[i] }
            if (cz[i] + hz[i] > maxZ) { maxZ = cz[i] + hz[i] }
        }
        assertEqual("root minX <= true minX", "true", true, minV.x <= minX + 1e-9)
        assertEqual("root minY <= true minY", "true", true, minV.y <= minY + 1e-9)
        assertEqual("root minZ <= true minZ", "true", true, minV.z <= minZ + 1e-9)
        assertEqual("root maxX >= true maxX", "true", true, maxV.x >= maxX - 1e-9)
        assertEqual("root maxY >= true maxY", "true", true, maxV.y >= maxY - 1e-9)
        assertEqual("root maxZ >= true maxZ", "true", true, maxV.z >= maxZ - 1e-9)
    }
}
