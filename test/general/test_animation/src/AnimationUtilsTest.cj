/**
 * @file AnimationUtilsTest
 * @brief animation_test: AnimationUtils 单元测试
 *
 * 检测 three.animation.AnimationUtils 静态工具能力：
 * - getKeyframeOrder / sortedArray
 * （convertArray/isTypedArray 已移除：仓颉 Array 即高性能定长数组，无 JS TypedArray 概念）
 */
package animation_test

import std.unittest.*
import std.collection.*
import three.animation.clip.AnimationUtils

public class AnimationUtilsTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("AnimationUtilsTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_get_keyframe_order(); () }
            suiteBuilder.add(UnitTestCase.create("test_get_keyframe_order", configuration: caseConfig, body: testFunc))
        }()

        { =>
            let caseConfig = Configuration()
            let testFunc = { => test_sorted_array(); () }
            suiteBuilder.add(UnitTestCase.create("test_sorted_array", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func test_get_keyframe_order() {
        let order = AnimationUtils.getKeyframeOrder([0.5, 0.1, 0.9])
        assertEqual("order.size == 3", "true", order.size == 3, true)
    }

    func test_sorted_array() {
        let order = AnimationUtils.getKeyframeOrder([0.5, 0.1, 0.9])
        let sorted = AnimationUtils.sortedArray([1.0, 2.0, 3.0], 1, order)
        assertEqual("sorted.size == 3", "true", sorted.size == 3, true)
    }
}
