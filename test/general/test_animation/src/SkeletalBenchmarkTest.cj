/**
 * @file SkeletalBenchmarkTest
 * @brief animation_test: 骨骼动画管线性能基准测试
 *
 * 测量各 Job 的执行耗时，用于对比标量实现性能。
 * 测试场景：128 关节骨骼，1 秒动画，多次采样取平均。
 */
package animation_test

import std.unittest.*
import std.time.*
import std.math.*
import three.core.math.soa.*
import three.core.math.*
import three.animation.skeletal.*
import three.animation.offline.*

public class SkeletalBenchmarkTest <: TestClass {
    public override func asTestSuite(): TestSuite {
        let suiteBuilder = TestSuite.builder("SkeletalBenchmarkTest")

        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSamplingJobBenchmark(); () }
            suiteBuilder.add(UnitTestCase.create("testSamplingJobBenchmark", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testBlendingJobBenchmark(); () }
            suiteBuilder.add(UnitTestCase.create("testBlendingJobBenchmark", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testLocalToModelJobBenchmark(); () }
            suiteBuilder.add(UnitTestCase.create("testLocalToModelJobBenchmark", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testSkinningJobBenchmark(); () }
            suiteBuilder.add(UnitTestCase.create("testSkinningJobBenchmark", configuration: caseConfig, body: testFunc))
        }()
        { =>
            let caseConfig = Configuration()
            let testFunc = { => testFullPipelineBenchmark(); () }
            suiteBuilder.add(UnitTestCase.create("testFullPipelineBenchmark", configuration: caseConfig, body: testFunc))
        }()

        return suiteBuilder.build()
    }

    /**
     * @brief[zh-cn] 构建测试骨骼数据
     */
    private func buildTestSkeleton(numJoints: Int): SkeletonData {
        let raw = RawSkeleton()
        raw.addJoint("root", -1)
        for (i in 1..numJoints) {
            raw.addJoint("joint_${i}", i - 1)
        }
        let builder = SkeletonBuilder()
        match (builder.invoke(raw)) {
            case Some(skel) => skel
            case None => SkeletonData()
        }
    }

    /**
     * @brief[zh-cn] 构建测试动画数据
     */
    private func buildTestAnimation(numJoints: Int, duration: Float32): SkeletalAnimationData {
        let raw = RawAnimation()
        raw.initTracks(numJoints)
        raw.duration = duration

        for (joint in 0..numJoints) {
            raw.addTranslationKeyframe(joint, 0.0f32, Vector3F(0.0f32, 0.0f32, 0.0f32))
            raw.addTranslationKeyframe(joint, duration * 0.5f32, Vector3F(0.0f32, 0.1f32, 0.0f32))
            raw.addTranslationKeyframe(joint, duration, Vector3F(0.0f32, 0.0f32, 0.0f32))
            raw.addRotationKeyframe(joint, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
            raw.addRotationKeyframe(joint, duration, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
        }

        let builder = AnimationBuilder()
        match (builder.invoke(raw)) {
            case Some(animData) => animData
            case None => SkeletalAnimationData()
        }
    }

    /**
     * @brief[zh-cn] SamplingJob 采样基准
     */
    public func testSamplingJobBenchmark(): Unit {
        let numJoints = 128
        let numFrames = 1000
        let skel = buildTestSkeleton(numJoints)
        let anim = buildTestAnimation(numJoints, 2.0f32)
        let numSoa = skel.numSoaJoints()

        let context = SamplingContext()
        let output = Array<SoaTransform>(numSoa, { _ => SoaTransform() })

        let startTime = MonoTime.now()
        for (f in 0..numFrames) {
            let ratio = Float32(f) / Float32(numFrames)
            let job = SamplingJob()
            job.ratio = ratio
            job.animation = Some(anim)
            job.context = context
            job.output = output
            job.validate()
            job.run()
        }
        let elapsed = MonoTime.now() - startTime
        let elapsedMs = Float64(elapsed.toMilliseconds())

        println("  SamplingJob benchmark: ${numFrames} frames x ${numJoints} joints = ${elapsedMs}ms (${elapsedMs / Float64(numFrames)}ms/frame)")
        assertEqual("elapsed should be positive", "true", elapsedMs > 0.0, true)
    }

    /**
     * @brief[zh-cn] BlendingJob 混合基准
     */
    public func testBlendingJobBenchmark(): Unit {
        let numJoints = 128
        let numFrames = 1000
        let skel = buildTestSkeleton(numJoints)
        let numSoa = skel.numSoaJoints()

        let restPoses = skel.jointRestPoses()
        let output = Array<SoaTransform>(numSoa, { _ => SoaTransform() })

        // 构建两个混合层
        let layer1Transforms = Array<SoaTransform>(numSoa, { _ => SoaTransform() })
        let layer2Transforms = Array<SoaTransform>(numSoa, { _ => SoaTransform() })

        let startTime = MonoTime.now()
        for (f in 0..numFrames) {
            let job = BlendingJob()
            job.threshold = 0.001f32
            job.restPose = Array<SoaTransform>(numSoa, { i => restPoses[i] })
            job.output = output

            let layer1 = BlendLayer()
            layer1.set(0.6f32, layer1Transforms)
            let layer2 = BlendLayer()
            layer2.set(0.4f32, layer2Transforms)

            job.layers.add(layer1)
            job.layers.add(layer2)

            job.validate()
            job.run()
        }
        let elapsed = MonoTime.now() - startTime
        let elapsedMs = Float64(elapsed.toMilliseconds())

        println("  BlendingJob benchmark: ${numFrames} frames x ${numJoints} joints = ${elapsedMs}ms (${elapsedMs / Float64(numFrames)}ms/frame)")
        assertEqual("elapsed should be positive", "true", elapsedMs > 0.0, true)
    }

    /**
     * @brief[zh-cn] LocalToModelJob 局部到模型空间基准
     */
    public func testLocalToModelJobBenchmark(): Unit {
        let numJoints = 128
        let numFrames = 1000
        let skel = buildTestSkeleton(numJoints)
        let numSoa = skel.numSoaJoints()

        let input = Array<SoaTransform>(numSoa, { _ => SoaTransform() })
        let output = Array<Matrix4F>(numJoints, { _ => Matrix4F() })

        let startTime = MonoTime.now()
        for (f in 0..numFrames) {
            let job = LocalToModelJob()
            job.skeleton = Some(skel)
            job.input = input
            job.output = output
            job.from = 0
            job.to = numJoints
            job.validate()
            job.run()
        }
        let elapsed = MonoTime.now() - startTime
        let elapsedMs = Float64(elapsed.toMilliseconds())

        println("  LocalToModelJob benchmark: ${numFrames} frames x ${numJoints} joints = ${elapsedMs}ms (${elapsedMs / Float64(numFrames)}ms/frame)")
        assertEqual("elapsed should be positive", "true", elapsedMs > 0.0, true)
    }

    /**
     * @brief[zh-cn] SkinningJob 蒙皮基准
     */
    public func testSkinningJobBenchmark(): Unit {
        let numJoints = 128
        let numVertices = 10000
        let numInfluences = 4

        // 构建关节矩阵（单位矩阵）
        let jointMatrices = Array<Float32>(numJoints * 16, { i => if (i % 5 == 0) { 1.0f32 } else { 0.0f32 } })

        // 构建顶点数据
        let positions = Array<Float32>(numVertices * 3, { i => Float32(i % 100) * 0.01f32 })
        let jointIndices = Array<Int16>(numVertices * numInfluences, { _ => 0i16 })
        let jointWeights = Array<Float32>(numVertices * numInfluences, { i => if (i % Int64(numInfluences) == 0) { 1.0f32 } else { 0.0f32 } })

        let weights = SkinWeights(numInfluences, jointIndices, jointWeights)
        let skinInput = SkinInput(numVertices, positions)
        let job = SkinningJob()
        job.jointMatrices = jointMatrices
        job.weights = Some(weights)
        job.input = Some(skinInput)

        let startTime = MonoTime.now()
        let numRuns = 100
        for (_ in 0..numRuns) {
            job.validate()
            job.run()
        }
        let elapsed = MonoTime.now() - startTime
        let elapsedMs = Float64(elapsed.toMilliseconds())

        println("  SkinningJob benchmark: ${numRuns} runs x ${numVertices} vertices x ${numJoints} joints = ${elapsedMs}ms (${elapsedMs / Float64(numRuns)}ms/run)")
        assertEqual("elapsed should be positive", "true", elapsedMs > 0.0, true)
    }

    /**
     * @brief[zh-cn] 完整管线（采样 + 局部到模型空间）基准
     */
    public func testFullPipelineBenchmark(): Unit {
        let numJoints = 64
        let numFrames = 500
        let skel = buildTestSkeleton(numJoints)
        let anim = buildTestAnimation(numJoints, 2.0f32)
        let numSoa = skel.numSoaJoints()

        let context = SamplingContext()
        let sampleOutput = Array<SoaTransform>(numSoa, { _ => SoaTransform() })
        let modelOutput = Array<Matrix4F>(numJoints, { _ => Matrix4F() })

        let startTime = MonoTime.now()
        for (f in 0..numFrames) {
            let ratio = Float32(f) / Float32(numFrames)

            // 1. 采样
            let sampleJob = SamplingJob()
            sampleJob.ratio = ratio
            sampleJob.animation = Some(anim)
            sampleJob.context = context
            sampleJob.output = sampleOutput
            sampleJob.validate()
            sampleJob.run()

            // 2. 局部→模型空间
            let ltmJob = LocalToModelJob()
            ltmJob.skeleton = Some(skel)
            ltmJob.input = sampleOutput
            ltmJob.output = modelOutput
            ltmJob.from = 0
            ltmJob.to = numJoints
            ltmJob.validate()
            ltmJob.run()
        }
        let elapsed = MonoTime.now() - startTime
        let elapsedMs = Float64(elapsed.toMilliseconds())

        println("  Full pipeline benchmark: ${numFrames} frames x ${numJoints} joints = ${elapsedMs}ms (${elapsedMs / Float64(numFrames)}ms/frame)")
        assertEqual("elapsed should be positive", "true", elapsedMs > 0.0, true)
    }
}
