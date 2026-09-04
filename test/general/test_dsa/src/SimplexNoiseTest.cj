/**
 * @file SimplexNoiseTest
 * @brief test_dsa: SimplexNoise 单元测试
 *
 * 检测 three.infra.dsa.SimplexNoise 能力：
 * - 构造（默认种子 / 指定种子 / 可复现性）
 * - noise2D 返回值范围 [-1, 1]
 * - noise3d 返回值范围 [-1, 1]
 * - noise4d 返回值范围 [-1, 1]
 * - noise(xin, yin) 兼容接口与 noise2D 一致
 * - createSeamlessNoise2D 返回值范围及无缝性（边界值相等）
 * - 同种子结果一致、不同种子结果不同
 */
package test_dsa

import std.unittest.*
import std.math.*
import three.core.dsa.SimplexNoise

public class SimplexNoiseTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("SimplexNoiseTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_construct_default(); () }
            suiteBuilder.add(UnitTestCase.create("test_construct_default", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_noise2d_range(); () }
            suiteBuilder.add(UnitTestCase.create("test_noise2d_range", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_noise3d_range(); () }
            suiteBuilder.add(UnitTestCase.create("test_noise3d_range", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_noise4d_range(); () }
            suiteBuilder.add(UnitTestCase.create("test_noise4d_range", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_noise_compat(); () }
            suiteBuilder.add(UnitTestCase.create("test_noise_compat", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_same_seed_reproducible(); () }
            suiteBuilder.add(UnitTestCase.create("test_same_seed_reproducible", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_different_seed_different(); () }
            suiteBuilder.add(UnitTestCase.create("test_different_seed_different", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_noise2d_zero_origin(); () }
            suiteBuilder.add(UnitTestCase.create("test_noise2d_zero_origin", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_createSeamlessNoise2D_range(); () }
            suiteBuilder.add(UnitTestCase.create("test_createSeamlessNoise2D_range", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_createSeamlessNoise2D_seamless(); () }
            suiteBuilder.add(UnitTestCase.create("test_createSeamlessNoise2D_seamless", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_createSeamlessNoise2D_consistency(); () }
            suiteBuilder.add(UnitTestCase.create("test_createSeamlessNoise2D_consistency", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /// 构造默认种子不崩溃
    func test_construct_default() {
        let n1 = SimplexNoise()
        let n2 = SimplexNoise(seed: 42u64)
        // 只要构造不崩溃就算通过
        assertEqual("default construct", "true", true, true)
        assertEqual("seed construct", "true", true, true)
    }

    /// noise2D 返回值在 [-1, 1]
    func test_noise2d_range() {
        let n = SimplexNoise(seed: 12345u64)
        var minVal = 1.0
        var maxVal = -1.0
        // 采样 100 个点
        for (i in 0..10) {
            for (j in 0..10) {
                let x = Float64(i) * 0.5
                let y = Float64(j) * 0.5
                let v = n.noise2D(x, y)
                if (v < minVal) { minVal = v }
                if (v > maxVal) { maxVal = v }
            }
        }
        assertEqual("noise2D min >= -1.0", "true", minVal >= -1.0, true)
        assertEqual("noise2D max <= 1.0", "true", maxVal <= 1.0, true)
        // 至少有一些变化（非全零）
        assertEqual("noise2D has variation", "true", maxVal > minVal, true)
    }

    /// noise3d 返回值在 [-1, 1]
    func test_noise3d_range() {
        let n = SimplexNoise(seed: 12345u64)
        var minVal = 1.0
        var maxVal = -1.0
        for (i in 0..5) {
            for (j in 0..5) {
                for (k in 0..5) {
                    let x = Float64(i) * 0.7
                    let y = Float64(j) * 0.7
                    let z = Float64(k) * 0.7
                    let v = n.noise3d(x, y, z)
                    if (v < minVal) { minVal = v }
                    if (v > maxVal) { maxVal = v }
                }
            }
        }
        assertEqual("noise3d min >= -1.0", "true", minVal >= -1.0, true)
        assertEqual("noise3d max <= 1.0", "true", maxVal <= 1.0, true)
        assertEqual("noise3d has variation", "true", maxVal > minVal, true)
    }

    /// noise4d 返回值在 [-1, 1]
    func test_noise4d_range() {
        let n = SimplexNoise(seed: 12345u64)
        var minVal = 1.0
        var maxVal = -1.0
        for (i in 0..4) {
            for (j in 0..4) {
                for (k in 0..4) {
                    for (l in 0..4) {
                        let x = Float64(i) * 0.9
                        let y = Float64(j) * 0.9
                        let z = Float64(k) * 0.9
                        let w = Float64(l) * 0.9
                        let v = n.noise4d(x, y, z, w)
                        if (v < minVal) { minVal = v }
                        if (v > maxVal) { maxVal = v }
                    }
                }
            }
        }
        assertEqual("noise4d min >= -1.0", "true", minVal >= -1.0, true)
        assertEqual("noise4d max <= 1.0", "true", maxVal <= 1.0, true)
        assertEqual("noise4d has variation", "true", maxVal > minVal, true)
    }

    /// noise(xin, yin) 兼容接口与 noise2D 一致
    func test_noise_compat() {
        let n = SimplexNoise(seed: 42u64)
        let v1 = n.noise2D(1.5, 2.3)
        let v2 = n.noise(1.5, 2.3)
        assertEqual("noise == noise2D", "true", v1 == v2, true)
    }

    /// 同种子结果可复现
    func test_same_seed_reproducible() {
        let n1 = SimplexNoise(seed: 999u64)
        let n2 = SimplexNoise(seed: 999u64)
        var allEqual = true
        for (i in 0..20) {
            let x = Float64(i) * 0.3
            let y = Float64(i) * 0.7
            if (n1.noise2D(x, y) != n2.noise2D(x, y)) {
                allEqual = false
                break
            }
        }
        assertEqual("same seed reproducible", "true", allEqual, true)
    }

    /// 不同种子结果不同
    func test_different_seed_different() {
        let n1 = SimplexNoise(seed: 100u64)
        let n2 = SimplexNoise(seed: 200u64)
        var anyDiff = false
        for (i in 0..20) {
            let x = Float64(i) * 0.3
            let y = Float64(i) * 0.7
            if (n1.noise2D(x, y) != n2.noise2D(x, y)) {
                anyDiff = true
                break
            }
        }
        assertEqual("different seed gives different result", "true", anyDiff, true)
    }

    /// noise2D(0, 0) 不崩溃，返回有限值
    func test_noise2d_zero_origin() {
        let n = SimplexNoise(seed: 1u64)
        let v = n.noise2D(0.0, 0.0)
        assertEqual("noise2D(0,0) is finite", "true", v == v, true) // NaN != NaN
        assertEqual("noise2D(0,0) in range", "true", v >= -1.0 && v <= 1.0, true)
    }

    /// createSeamlessNoise2D 返回值在 [-1, 1]
    func test_createSeamlessNoise2D_range() {
        let n = SimplexNoise(seed: 54321u64)
        let diameter = 10.0
        var minVal = 1.0
        var maxVal = -1.0
        for (i in 0..20) {
            for (j in 0..20) {
                let x = Float64(i) * 0.5
                let y = Float64(j) * 0.5
                let v = n.createSeamlessNoise2D(x, y, diameter)
                if (v < minVal) { minVal = v }
                if (v > maxVal) { maxVal = v }
            }
        }
        assertEqual("seamless2D min >= -1.0", "true", minVal >= -1.0, true)
        assertEqual("seamless2D max <= 1.0", "true", maxVal <= 1.0, true)
        assertEqual("seamless2D has variation", "true", maxVal > minVal, true)
    }

    /// createSeamlessNoise2D 无缝性：x=0 与 x=diameter 应该产生相同噪声值
    func test_createSeamlessNoise2D_seamless() {
        let n = SimplexNoise(seed: 111u64)
        let diameter = 8.0
        // 在 y 固定时，x=0 和 x=diameter 应产生相同的噪声值
        let y = 3.7
        let v0 = n.createSeamlessNoise2D(0.0, y, diameter)
        let vD = n.createSeamlessNoise2D(diameter, y, diameter)
        assertEqual("seamless x=0 == x=diameter", "true", v0 == vD, true)

        // 同理 y=0 和 y=diameter
        let x = 2.5
        let h0 = n.createSeamlessNoise2D(x, 0.0, diameter)
        let hD = n.createSeamlessNoise2D(x, diameter, diameter)
        assertEqual("seamless y=0 == y=diameter", "true", h0 == hD, true)

        // 角点也一致
        let c00 = n.createSeamlessNoise2D(0.0, 0.0, diameter)
        let cDD = n.createSeamlessNoise2D(diameter, diameter, diameter)
        assertEqual("seamless corner (0,0) == (D,D)", "true", c00 == cDD, true)
    }

    /// createSeamlessNoise2D 同实例多次调用结果一致
    func test_createSeamlessNoise2D_consistency() {
        let n = SimplexNoise(seed: 222u64)
        let diameter = 10.0
        var allConsistent = true
        for (i in 0..10) {
            let x = Float64(i) * 1.1
            let y = Float64(i) * 0.8
            let v1 = n.createSeamlessNoise2D(x, y, diameter)
            let v2 = n.createSeamlessNoise2D(x, y, diameter)
            if (v1 != v2) {
                allConsistent = false
                break
            }
        }
        assertEqual("seamless2D consistent calls", "true", allConsistent, true)
    }
}
