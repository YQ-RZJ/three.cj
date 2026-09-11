package animationTest

/**
 * 骨骼动画测试渲染场景
 *
 * 加载 glTF 模型并集成骨骼动画管线：
 * 1. GltfLoader 解析 skins/animations（GltfSkinData/GltfAnimationData）
 * 2. GltfImportAdapter 转换为 RawSkeleton/RawAnimation
 * 3. SkeletonBuilder 构建 SkeletonData
 * 4. AnimationBuilder 构建 SkeletalAnimationData
 * 5. Skeleton.syncFromSkeletonData 构建 Bone 层级
 * 6. AnimationMixer.updateSkeletal 驱动采样/混合
 * 7. SkinnedMesh.applySkinningJob 执行蒙皮
 */

import std.sync.*
import std.time.*
import std.math.*
import std.fs.*
import std.fs.Path as FsPath
import std.collection.*
import three.core.*
import three.core.math.*
import three.core.math.soa.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.ThreeRenderer
import three.resource.loader.GltfLoader
import three.resource.loader.*
import three.rendering.lights.*
import three.animation.clip.*
import three.animation.blend.*
import three.animation.offline.*
import three.animation.skeletal.*

/**
 * @brief[zh-cn] 骨骼动画运行时状态（跨场景创建与逐帧更新共享）
 */
public class SkeletalTestRuntime {
    /**
     * @brief[zh-cn] 动画混合器（glTF 动画注册成功后可用）
     */
    public var mixer: Option<AnimationMixer>

    /**
     * @brief[zh-cn] 运行时骨骼数据
     */
    public var skeletonData: Option<SkeletonData>

    /**
     * @brief[zh-cn] 场景层骨骼
     */
    public var skeleton: Option<Skeleton>

    /**
     * @brief[zh-cn] 待逐帧蒙皮的蒙皮网格列表
     */
    public var skinnedMeshes: ArrayList<SkinnedMesh>

    public init() {
        this.mixer = None
        this.skeletonData = None
        this.skeleton = None
        this.skinnedMeshes = ArrayList<SkinnedMesh>()
    }
}

/**
 * @brief[zh-cn] 本测试的骨骼动画运行时单例
 */
public let skeletalRuntime = SkeletalTestRuntime()

/// 创建场景、相机和灯光
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, Group) {
    let aspect = Float64(width) / Float64(height)

    let scene = Scene()
    scene.name = "SkeletalAnimScene"
    println("  scene: ${scene.name}")

    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 5000.0)
    camera.position.set(0.0, 2.0, 5.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"

    // 方向光
    let dirLight = DirectionalLight(color: Color(1.0, 1.0, 1.0), intensity: 1.0)
    dirLight.position.set(1.0, 2.0, 3.0)
    scene.add(dirLight)

    // 环境光
    let ambientLight = AmbientLight(color: Color(0.3, 0.3, 0.3), intensity: 0.5)
    scene.add(ambientLight)

    // 加载 glTF 模型并集成骨骼动画
    let modelGroup = loadAndAnimateModel()
    scene.add(modelGroup)

    return (scene, camera, modelGroup)
}

/// 每帧驱动骨骼动画管线：混合器推进 → 采样/混合/局部转模型 → Bone 回写 → 蒙皮
public func updateSkeletalAnimation(deltaSeconds: Float64): Unit {
    match (skeletalRuntime.mixer) {
        case Some(mixer) =>
            // 动作时间推进 + ozz Job 管线
            mixer.update(deltaSeconds)
            match (skeletalRuntime.skeletonData) {
                case Some(skelData) => mixer.updateSkeletal(skelData, Float32(deltaSeconds))
                case None => ()
            }
            // 刷新骨骼层级世界矩阵（根骨不在场景图中，需显式更新）
            match (skeletalRuntime.skeleton) {
                case Some(skel) =>
                    for (bone in skel.bones) {
                        match (bone.parent) {
                            case None => bone.updateMatrixWorld(true)
                            case Some(_) => ()  // 根骨更新会递归到子骨
                        }
                    }
                    skel.update()
                case None => ()
            }
            // CPU 蒙皮
            for (sm in skeletalRuntime.skinnedMeshes) {
                sm.applySkinningJob()
            }
        case None => ()
    }
}

/// 加载 glTF 模型并集成骨骼动画管线
private func loadAndAnimateModel(): Group {
    let modelGroup = Group()
    modelGroup.name = "AnimatedModel"

    let loader = GltfLoader()
    var loaded = false

    // 尝试多个可能的文件名（.glb 为二进制，.gltf 为 JSON 文本）
    let candidates = ["model.glb", "character.glb", "CesiumMan.glb", "glTF.glb", "model.gltf", "character.gltf"]
    for (filename in candidates) {
        let filePath = FsPath("res/" + filename)
        let bytesResult: Option<Array<UInt8>> = try {
            Some(File.readFrom(filePath))
        } catch (_: Exception) {
            None
        }

        match (bytesResult) {
            case Some(bytes) =>
                println("  loading: res/${filename} (${bytes.size} bytes)")
                let parseResult: Option<Group> = try {
                    if (filename.endsWith(".glb")) {
                        let (jsonData, binData) = loader.parseGlb(bytes)
                        Some(loader.parse(jsonData, binData, "."))
                    } else {
                        let jsonStr = String.fromUtf8(bytes)
                        let jsonMap = loader.parseJsonToHashMap(jsonStr)
                        Some(loader.parse(jsonMap, Array<UInt8>(0, { _ => 0u8 }), "res"))
                    }
                } catch (e: Exception) {
                    println("  error loading ${filename}: ${e.toString()}")
                    None
                }
                match (parseResult) {
                    case Some(group) =>
                        modelGroup.add(group)
                        loaded = true
                        println("  model loaded: ${filename}")
                        // 从 userData 取 glTF 骨骼/动画解析结果，搭建运行时骨骼动画
                        setupSkeletalFromUserData(group)
                    case None => ()
                }
            case None => ()
        }

        if (loaded) { break }
    }

    if (!loaded) {
        println("  no model found in res/, using procedural test geometry")
        let testGeom = BoxGeometry(width: 1.0, height: 1.0, depth: 1.0)
        let testMat = MeshBasicMaterial()
        testMat.color = Color(0.4, 0.6, 0.9)
        let testMesh = Mesh(geometry: testGeom, material: testMat)
        testMesh.name = "TestBox"
        modelGroup.add(testMesh)
    }

    // 演示骨骼动画管线（程序化数据，验证各 Job 正常工作）
    println("")
    println("=== Skeletal Animation Pipeline Demo ===")
    demoSkeletalPipeline()

    return modelGroup
}

/// glTF 解析中间数据在 userData 中的临时键（GltfLoader 注入，消费完必须清理：
/// 内含 bin 缓冲/无 adapter 的中间类，若随场景 JSON 序列化会导致膨胀或失败）
private let GLTF_USERDATA_KEYS = ["gltfSkins", "gltfAnimations", "gltfNodes", "gltfAccessors", "gltfBufferViews", "gltfBuffers"]

/// 清理 userData 中的 glTF 解析中间数据
private func clearGltfUserData(ud: HashMap<String, Any>): Unit {
    for (key in GLTF_USERDATA_KEYS) {
        ud.remove(key)
    }
}

/// 从 Group.userData 中取 glTF skins/animations，构建 Skeleton/SkeletalAnimationData/AnimationMixer
private func setupSkeletalFromUserData(root: Group): Unit {
    let ud = root.userData

    // 取 skins
    let skins = match (ud.get("gltfSkins")) {
        case Some(v) => match (v) {
            case a: ArrayList<GltfSkinData> => a
            case _ => ArrayList<GltfSkinData>()
        }
        case None => ArrayList<GltfSkinData>()
    }
    if (skins.size == 0) {
        println("  gltf: no skin data, skip skeletal setup")
        clearGltfUserData(ud)
        return
    }
    let skin = skins[0]

    // 取 nodes/accessors/bufferViews/buffers
    let nodes = match (ud.get("gltfNodes")) {
        case Some(v) => match (v) {
            case a: Array<Any> => a
            case _ => Array<Any>()
        }
        case None => Array<Any>()
    }
    let accessors = match (ud.get("gltfAccessors")) {
        case Some(v) => match (v) {
            case a: Array<Any> => a
            case _ => Array<Any>()
        }
        case None => Array<Any>()
    }
    let bufferViews = match (ud.get("gltfBufferViews")) {
        case Some(v) => match (v) {
            case a: Array<Any> => a
            case _ => Array<Any>()
        }
        case None => Array<Any>()
    }
    let loadedBuffers = match (ud.get("gltfBuffers")) {
        case Some(v) => match (v) {
            case a: ArrayList<Array<UInt8>> => a
            case _ => ArrayList<Array<UInt8>>()
        }
        case None => ArrayList<Array<UInt8>>()
    }

    // 1. 构建运行时骨骼
    println("  gltf: building skeleton from skin '${skin.name}', joints=${skin.joints.size}")
    let rawSkeleton = GltfImportAdapter.buildRawSkeleton(skin, nodes)
    let skelDataOpt = SkeletonBuilder().invoke(rawSkeleton)
    match (skelDataOpt) {
        case Some(skelData) =>
            println("    SkeletonData: ${skelData.numJoints()} joints, ${skelData.numSoaJoints()} soa blocks")
            let skeleton = Skeleton()
            skeleton.syncFromSkeletonData(skelData)

            // glTF 提供 inverseBindMatrices 时优先使用（数量需与关节数一致）
            if (skin.inverseBindMatrices.size == skeleton.bones.size) {
                skeleton.boneInverses.clear()
                for (ibm in skin.inverseBindMatrices) {
                    let m = Matrix4()
                    m.fromArray(ibm)
                    skeleton.boneInverses.add(m)
                }
                println("    boneInverses: ${skin.inverseBindMatrices.size} matrices from glTF")
            }

            skeletalRuntime.skeletonData = Some(skelData)
            skeletalRuntime.skeleton = Some(skeleton)

            // 2. 将带 skinIndex 属性的普通 Mesh 替换为 SkinnedMesh
            replaceSkinnedMeshes(root, skeleton)

            // 3. 构建动画并注册到混合器
            let anims = match (ud.get("gltfAnimations")) {
                case Some(v) => match (v) {
                    case a: ArrayList<GltfAnimationData> => a
                    case _ => ArrayList<GltfAnimationData>()
                }
                case None => ArrayList<GltfAnimationData>()
            }
            let mixer = AnimationMixer(root)
            mixer.bindSceneSkeleton(skeleton)
            var clipCount = 0
            for (anim in anims) {
                let rawAnim = GltfImportAdapter.buildRawAnimation(
                    anim, skin, accessors, bufferViews, loadedBuffers, rawSkeleton: Some(rawSkeleton))
                match (AnimationBuilder().invoke(rawAnim)) {
                    case Some(data) =>
                        let clip = AnimationClip(name: anim.name, duration: Float64(data.duration))
                        mixer.registerSkeletalData(clip.uuid, data)
                        // 只播放第一个 clip：多个 clip 同时 play 会以相等权重混合，姿势互相抵消
                        if (clipCount == 0) {
                            let action = mixer.clipAction(clip)
                            action.play()
                        }
                        clipCount += 1
                        println("    animation '${anim.name}': duration=${data.duration}s, tracks=${data.numTracks}")
                    case None =>
                        println("    animation '${anim.name}': AnimationBuilder failed")
                }
            }
            skeletalRuntime.mixer = Some(mixer)
            println("  gltf: skeletal setup complete, clips=${clipCount}, skinnedMeshes=${skeletalRuntime.skinnedMeshes.size}")
        case None =>
            println("    SkeletonBuilder failed")
    }

    // glTF 解析中间数据已全部消费，清理 userData 临时键（避免随场景 JSON 序列化）
    clearGltfUserData(ud)
}

/// 遍历场景，将 geometry 带 skinIndex 属性的普通 Mesh 替换为绑定骨骼的 SkinnedMesh
private func replaceSkinnedMeshes(obj: Object3D, skeleton: Skeleton): Unit {
    // 复制 children 引用，避免遍历时修改列表
    let children = ArrayList<Object3D>()
    for (c in obj.children) { children.add(c) }
    for (child in children) {
        match (child) {
            case mesh: Mesh =>
                let hasSkin = match (mesh.geometry.getAttribute("skinIndex")) {
                    case Some(_) => true
                    case None => false
                }
                if (hasSkin) {
                    let skinned = SkinnedMesh(geometry: mesh.geometry, material: mesh.material)
                    skinned.name = mesh.name + "_skinned"
                    skinned.position.copy(mesh.position)
                    skinned.quaternion.copy(mesh.quaternion)
                    skinned.scale.copy(mesh.scale)
                    // 用 Mesh 的世界矩阵作为 bindMatrix：蒙皮在骨架空间进行，
                    // 渲染器再用 SkinnedMesh 的世界矩阵变换到世界空间
                    mesh.updateMatrixWorld(true)
                    skinned.bind(skeleton, bindMatrix: Some(mesh.matrixWorld.clone()))
                    skeletalRuntime.skinnedMeshes.add(skinned)
                    match (mesh.parent) {
                        case Some(parent) =>
                            parent.remove(mesh)
                            parent.add(skinned)
                        case None => ()
                    }
                    replaceSkinnedMeshes(skinned, skeleton)
                } else {
                    replaceSkinnedMeshes(mesh, skeleton)
                }
            case _ =>
                replaceSkinnedMeshes(child, skeleton)
        }
    }
}

/// 演示骨骼动画管线的核心流程（程序化数据，即使没有 glTF 模型也能验证管线）
private func demoSkeletalPipeline(): Unit {
    // 1. 构建测试骨骼
    println("  [1/6] building RawSkeleton...")
    let rawSkeleton = RawSkeleton()
    let root = rawSkeleton.addJoint("root", -1)
    root.localTranslation.set(0.0f32, 0.0f32, 0.0f32)
    let spine = rawSkeleton.addJoint("spine", 0)
    spine.localTranslation.set(0.0f32, 1.0f32, 0.0f32)
    let leftArm = rawSkeleton.addJoint("left_arm", 1)
    leftArm.localTranslation.set(-0.5f32, 0.8f32, 0.0f32)
    let rightArm = rawSkeleton.addJoint("right_arm", 1)
    rightArm.localTranslation.set(0.5f32, 0.8f32, 0.0f32)
    println("    ${rawSkeleton.numJoints()} joints")

    // 2. 构建 SkeletonData
    println("  [2/6] building SkeletonData...")
    let skeletonBuilder = SkeletonBuilder()
    match (skeletonBuilder.invoke(rawSkeleton)) {
        case Some(skeletonData) =>
            println("    SkeletonData: ${skeletonData.numJoints()} joints, ${skeletonData.numSoaJoints()} soa elements")

            // 3. 构建测试动画
            println("  [3/6] building RawAnimation...")
            let rawAnim = RawAnimation()
            rawAnim.name = "idle"
            rawAnim.initTracks(rawSkeleton.numJoints())
            rawAnim.duration = 2.0f32

            // 根关节上下浮动
            rawAnim.addTranslationKeyframe(0, 0.0f32, Vector3F(0.0f32, 0.0f32, 0.0f32))
            rawAnim.addTranslationKeyframe(0, 1.0f32, Vector3F(0.0f32, 0.1f32, 0.0f32))
            rawAnim.addTranslationKeyframe(0, 2.0f32, Vector3F(0.0f32, 0.0f32, 0.0f32))

            // 左臂摆动
            rawAnim.addRotationKeyframe(2, 0.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32)
            rawAnim.addRotationKeyframe(2, 1.0f32, 0.0f32, 0.0f32, 0.1f32, 0.995f32)
            rawAnim.addRotationKeyframe(2, 2.0f32, 0.0f32, 0.0f32, 0.0f32, 1.0f32)

            println("    ${rawAnim.trackCount} tracks, duration=${rawAnim.duration}s")

            // 4. 构建 SkeletalAnimationData
            println("  [4/6] building SkeletalAnimationData...")
            let animBuilder = AnimationBuilder()
            match (animBuilder.invoke(rawAnim)) {
                case Some(skeletalData) =>
                    println("    SkeletalAnimationData: ${skeletalData.numTracks} tracks, duration=${skeletalData.duration}s")

                    // 5. 采样测试
                    println("  [5/6] SamplingJob test...")
                    let samplingJob = SamplingJob()
                    samplingJob.ratio = 0.25f32
                    samplingJob.animation = Some(skeletalData)
                    samplingJob.context = SamplingContext()
                    samplingJob.output = Array<SoaTransform>(skeletonData.numSoaJoints(), { _ => SoaTransform() })

                    if (samplingJob.validate() && samplingJob.run()) {
                        println("    SamplingJob OK at ratio=0.25")
                        let t = samplingJob.output[0].getTranslation(0)
                        println("    root translation: (${t.x}, ${t.y}, ${t.z})")
                    } else {
                        println("    SamplingJob failed")
                    }

                    // 6. LocalToModelJob 测试
                    println("  [6/6] LocalToModelJob test...")
                    let modelMatrices = Array<Matrix4F>(skeletonData.numJoints(), { _ => Matrix4F() })
                    let localToModelJob = LocalToModelJob()
                    localToModelJob.skeleton = Some(skeletonData)
                    localToModelJob.input = samplingJob.output
                    localToModelJob.output = modelMatrices
                    localToModelJob.from = 0
                    localToModelJob.to = 0  // <= 0 表示处理到最后一个关节

                    if (localToModelJob.validate() && localToModelJob.run()) {
                        println("    LocalToModelJob OK")
                        println("    root model matrix[12,13,14]: (${modelMatrices[0].elements[12]}, ${modelMatrices[0].elements[13]}, ${modelMatrices[0].elements[14]})")
                    } else {
                        println("    LocalToModelJob failed")
                    }

                    println("")
                    println("=== Pipeline Demo Complete ===")

                case None =>
                    println("    AnimationBuilder failed")
            }

        case None =>
            println("    SkeletonBuilder failed")
    }
}
