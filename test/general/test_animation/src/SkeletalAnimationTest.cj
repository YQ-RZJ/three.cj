/**
 * @file SkeletalAnimationTest
 * @brief animation_test: 骨骼动画 ozz 管线单元测试
 *
 * 检测能力：
 * - SoaTransform/SimdFloat SoA 数学基础
 * - SkeletalAnimationData/SkeletalTrackData 运行时数据与采样
 * - SkeletonData 关节层次查询
 * - RawSkeleton/RawAnimation 离线数据校验
 * - SkeletonBuilder 离线→运行时构建
 * - GroupVarint 编解码往返
 */
package animation_test

import std.unittest.*
import std.math.*
import three.core.math.soa.*
import three.core.math.*
import three.animation.skeletal.*
import three.animation.offline.*
import three.utils.encode.*

public class SkeletalAnimationTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("SkeletalAnimationTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSoaTransform(); () }
            suiteBuilder.add(UnitTestCase.create("testSoaTransform", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSoaTransformFromFour(); () }
            suiteBuilder.add(UnitTestCase.create("testSoaTransformFromFour", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSoaTransformSetTranslation(); () }
            suiteBuilder.add(UnitTestCase.create("testSoaTransformSetTranslation", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSimdFloat(); () }
            suiteBuilder.add(UnitTestCase.create("testSimdFloat", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSimdFloatFromFour(); () }
            suiteBuilder.add(UnitTestCase.create("testSimdFloatFromFour", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSimdFloatLerp(); () }
            suiteBuilder.add(UnitTestCase.create("testSimdFloatLerp", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletalAnimationData(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletalAnimationData", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletalTrackDataFloat(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletalTrackDataFloat", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletalTrackDataQuaternion(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletalTrackDataQuaternion", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletalTrackDataFloat3(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletalTrackDataFloat3", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletonData(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletonData", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletonDataWithJoints(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletonDataWithJoints", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testRawSkeletonValidation(); () }
            suiteBuilder.add(UnitTestCase.create("testRawSkeletonValidation", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testRawSkeletonInvalidParent(); () }
            suiteBuilder.add(UnitTestCase.create("testRawSkeletonInvalidParent", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testRawAnimationValidation(); () }
            suiteBuilder.add(UnitTestCase.create("testRawAnimationValidation", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testRawAnimationUnsortedKeyframes(); () }
            suiteBuilder.add(UnitTestCase.create("testRawAnimationUnsortedKeyframes", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkeletonBuilder(); () }
            suiteBuilder.add(UnitTestCase.create("testSkeletonBuilder", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testGroupVarintRoundtrip(); () }
            suiteBuilder.add(UnitTestCase.create("testGroupVarintRoundtrip", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testVector3F(); () }
            suiteBuilder.add(UnitTestCase.create("testVector3F", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testMatrix4FCompose(); () }
            suiteBuilder.add(UnitTestCase.create("testMatrix4FCompose", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    func testSoaTransform() {
        // 测试默认构造（单位变换）
        let identity = SoaTransform()
        let t = identity.getTranslation(0)
        assertEqual("identity tx should be 0", "true", t.x == 0.0f32, true)
        assertEqual("identity ty should be 0", "true", t.y == 0.0f32, true)
        assertEqual("identity tz should be 0", "true", t.z == 0.0f32, true)

        let r = identity.getRotation(0)
        assertEqual("identity rx should be 0", "true", r.x == 0.0f32, true)
        assertEqual("identity rw should be 1", "true", r.w == 1.0f32, true)

        let s = identity.getScale(0)
        assertEqual("identity sx should be 1", "true", s.x == 1.0f32, true)
        assertEqual("identity sy should be 1", "true", s.y == 1.0f32, true)
        assertEqual("identity sz should be 1", "true", s.z == 1.0f32, true)
    }

    func testSoaTransformFromFour() {
        let t = SoaTransform.fromFour(
            1.0f32, 2.0f32, 3.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32, 1.0f32, 1.0f32, 1.0f32,
            4.0f32, 5.0f32, 6.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32, 1.0f32, 1.0f32, 1.0f32,
            7.0f32, 8.0f32, 9.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32, 1.0f32, 1.0f32, 1.0f32,
            10.0f32, 11.0f32, 12.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32, 1.0f32, 1.0f32, 1.0f32
        )
        let t0 = t.getTranslation(0)
        assertEqual("slot0 tx should be 1", "true", t0.x == 1.0f32, true)
        assertEqual("slot0 ty should be 2", "true", t0.y == 2.0f32, true)
        assertEqual("slot0 tz should be 3", "true", t0.z == 3.0f32, true)

        let t3 = t.getTranslation(3)
        assertEqual("slot3 tx should be 10", "true", t3.x == 10.0f32, true)
        assertEqual("slot3 ty should be 11", "true", t3.y == 11.0f32, true)
        assertEqual("slot3 tz should be 12", "true", t3.z == 12.0f32, true)
    }

    func testSoaTransformSetTranslation() {
        let t = SoaTransform()
        t.setTranslation(2, 10.0f32, 20.0f32, 30.0f32)
        let t2 = t.getTranslation(2)
        assertEqual("slot2 tx should be 10 after set", "true", t2.x == 10.0f32, true)
        assertEqual("slot2 ty should be 20 after set", "true", t2.y == 20.0f32, true)
        assertEqual("slot2 tz should be 30 after set", "true", t2.z == 30.0f32, true)

        // 其他槽位不受影响
        let t0 = t.getTranslation(0)
        assertEqual("slot0 tx should remain 0", "true", t0.x == 0.0f32, true)
    }

    func testSimdFloat() {
        let a = SimdFloat(2.0f32)
        let b = SimdFloat(3.0f32)
        a.add(b)
        assertEqual("a+b should be 5", "true", a.values[0] == 5.0f32, true)
        assertEqual("a+b should be 5", "true", a.values[1] == 5.0f32, true)
        assertEqual("a+b should be 5", "true", a.values[2] == 5.0f32, true)
        assertEqual("a+b should be 5", "true", a.values[3] == 5.0f32, true)
    }

    func testSimdFloatFromFour() {
        let v = SimdFloat.fromFour(1.0f32, 2.0f32, 3.0f32, 4.0f32)
        assertEqual("v0 should be 1", "true", v.values[0] == 1.0f32, true)
        assertEqual("v1 should be 2", "true", v.values[1] == 2.0f32, true)
        assertEqual("v2 should be 3", "true", v.values[2] == 3.0f32, true)
        assertEqual("v3 should be 4", "true", v.values[3] == 4.0f32, true)
    }

    func testSimdFloatLerp() {
        let a = SimdFloat(0.0f32)
        let b = SimdFloat(10.0f32)
        let t = SimdFloat(0.5f32)
        let result = SimdFloat.lerp(a, b, t)
        assertEqual("lerp(0,10,0.5) should be 5", "true", result.values[0] == 5.0f32, true)
    }

    func testSkeletalAnimationData() {
        let data = SkeletalAnimationData()
        assertEqual("empty data numTracks should be 0", "true", data.numTracks == 0, true)
        assertEqual("empty data tracks should be empty", "true", data.tracks.size == 0, true)
    }

    func testSkeletalTrackDataFloat() {
        let track = SkeletalTrackData(
            name: "test_float",
            trackType: TrackType.Float,
            times: Array<Float32>(3, { i => Float32(i) }),
            floatValues: Array<Float32>(3, { i => Float32(i) * 10.0f32 }),
            numKeyframes: 3
        )
        assertEqual("should have 3 keyframes", "true", track.numKeyframes == 3, true)
        assertEqual("sample at 0 should be 0", "true", track.sampleFloat(0.0f32) == 0.0f32, true)
        assertEqual("sample at 1 should be 20", "true", track.sampleFloat(1.0f32) == 20.0f32, true)
    }

    func testSkeletalTrackDataQuaternion() {
        let track = SkeletalTrackData(
            name: "test_quat",
            trackType: TrackType.Quaternion,
            times: Array<Float32>(2, { i => Float32(i) }),
            quatValues: Array<Float32>(8, { i =>
                match (i) {
                    case 0 => 0.0f32
                    case 1 => 0.0f32
                    case 2 => 0.0f32
                    case 3 => 1.0f32  // identity at t=0
                    case 4 => 0.0f32
                    case 5 => 0.0f32
                    case 6 => 0.0f32
                    case _ => 1.0f32  // identity at t=1
                }
            }),
            numKeyframes: 2
        )
        let q = track.sampleQuaternion(0.5f32)
        assertEqual("interpolated identity should have w near 1", "true", q.w >= 0.99f32, true)
    }

    func testSkeletalTrackDataFloat3() {
        let track = SkeletalTrackData(
            name: "test_float3",
            trackType: TrackType.Float3,
            times: Array<Float32>(2, { i => Float32(i) }),
            float3Values: Array<Float32>(6, { i => Float32(i) }),
            numKeyframes: 2
        )
        let v = track.sampleFloat3(0.5f32)
        assertEqual("x lerp should be ~1.5", "true", abs(v.x - 1.5f32) < 0.01f32, true)
        assertEqual("y lerp should be ~2.5", "true", v.y - 2.5f32 < 0.01f32 && v.y - 2.5f32 > -0.01f32, true)
    }

    func testSkeletonData() {
        let skel = SkeletonData()
        assertEqual("empty skeleton should have 0 joints", "true", skel.numJoints() == 0, true)
    }

    func testSkeletonDataWithJoints() {
        let restPoses = Array<SoaTransform>(1, { _ => SoaTransform() })
        let parents = Array<Int16>(2, { i => if (i == 0) { -1i16 } else { 0i16 } })
        let names = Array<String>(2, { i => if (i == 0) { "root" } else { "child" } })
        let skel = SkeletonData(restPoses, parents, names)
        assertEqual("should have 2 joints", "true", skel.numJoints() == 2, true)
        assertEqual("root parent should be -1", "true", skel.jointParent(0) == -1, true)
        assertEqual("child parent should be 0", "true", skel.jointParent(1) == 0, true)
        assertEqual("joint0 name should be root", "true", skel.jointName(0) == "root", true)
        assertEqual("findJointIndex child should return 1", "true", skel.findJointIndex("child") == 1, true)
        assertEqual("findJointIndex nonexistent should return -1", "true", skel.findJointIndex("nonexistent") == -1, true)
    }

    func testRawSkeletonValidation() {
        let raw = RawSkeleton()
        assertEqual("empty skeleton should be valid", "true", raw.validate(), true)

        raw.addJoint("root", -1)
        raw.addJoint("child", 0)
        assertEqual("2-joint skeleton should be valid", "true", raw.validate(), true)
        assertEqual("should have 2 joints", "true", raw.numJoints() == 2, true)
    }

    func testRawSkeletonInvalidParent() {
        let raw = RawSkeleton()
        raw.addJoint("root", -1)
        raw.addJoint("child", 5)  // 无效父索引
        assertEqual("invalid parent should fail validation", "true", !raw.validate(), true)
    }

    func testRawAnimationValidation() {
        let anim = RawAnimation()
        assertEqual("empty animation should be valid", "true", anim.validate(), true)

        anim.initTracks(2)
        anim.duration = 1.0f32
        anim.addTranslationKeyframe(0, 0.0f32, Vector3F(0.0f32, 0.0f32, 0.0f32))
        anim.addTranslationKeyframe(0, 1.0f32, Vector3F(1.0f32, 0.0f32, 0.0f32))
        assertEqual("animation with sorted keyframes should be valid", "true", anim.validate(), true)
    }

    func testRawAnimationUnsortedKeyframes() {
        let anim = RawAnimation()
        anim.initTracks(1)
        anim.duration = 1.0f32
        anim.addTranslationKeyframe(0, 1.0f32, Vector3F(1.0f32, 0.0f32, 0.0f32))
        anim.addTranslationKeyframe(0, 0.0f32, Vector3F(0.0f32, 0.0f32, 0.0f32))
        // 未排序时 validate 应该失败
        assertEqual("unsorted keyframes should fail validation", "true", !anim.validate(), true)

        // 排序后应该通过
        anim.sortKeyframes()
        assertEqual("sorted keyframes should pass validation", "true", anim.validate(), true)
    }

    func testSkeletonBuilder() {
        let raw = RawSkeleton()
        let root = raw.addJoint("root", -1)
        root.localTranslation.set(1.0f32, 2.0f32, 3.0f32)
        raw.addJoint("child1", 0)
        raw.addJoint("child2", 0)

        let builder = SkeletonBuilder()
        let result = builder.invoke(raw)
        match (result) {
            case Some(skel) =>
                assertEqual("built skeleton should have 3 joints", "true", skel.numJoints() == 3, true)
                assertEqual("joint0 should be root", "true", skel.jointName(0) == "root", true)
                assertEqual("root parent should be -1", "true", skel.jointParent(0) == -1, true)
                assertEqual("child1 parent should be 0", "true", skel.jointParent(1) == 0, true)
            case None =>
                assertEqual("build should succeed", "true", false, true)
        }
    }

    func testGroupVarintRoundtrip() {
        let values = Array<UInt32>(8, { i => UInt32(i * 10) })
        let encoded = GroupVarint.encodeStream(values)
        let decoded = GroupVarint.decodeStream(encoded, values.size)
        for (i in 0..values.size) {
            assertEqual("roundtrip value should match", "true", decoded[i] == values[i], true)
        }
    }

    func testVector3F() {
        let a = Vector3F(1.0f32, 2.0f32, 3.0f32)
        let b = Vector3F(4.0f32, 5.0f32, 6.0f32)
        let dot = a.dot(b)
        assertEqual("dot product should be ~32", "true", abs(dot - 32.0f32) < 0.01f32, true)

        let len = a.length()
        assertEqual("length should be sqrt(14)", "true", abs(len - sqrt(14.0f32)) < 0.01f32, true)
    }

    func testMatrix4FCompose() {
        let m = Matrix4F()
        m.compose(1.0f32, 2.0f32, 3.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32, 1.0f32, 1.0f32, 1.0f32)
        // 平移应该在第 12,13,14 个元素
        assertEqual("m[12] should be tx=1", "true", abs(m.elements[12] - 1.0f32) < 0.01f32, true)
        assertEqual("m[13] should be ty=2", "true", abs(m.elements[13] - 2.0f32) < 0.01f32, true)
        assertEqual("m[14] should be tz=3", "true", abs(m.elements[14] - 3.0f32) < 0.01f32, true)
    }
}
