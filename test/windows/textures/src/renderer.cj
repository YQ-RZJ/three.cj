package sp_textures

/**
 * sp_textures 渲染场景：
 * - 球1：DataTexture 程序生成 64x64 棋盘格纹理（RGBA8，对照 test_loaders 风格）→ 验证程序化纹理上传
 * - 球2：TextureLoader 加载 res/checker.png（python 生成的 128x128 棋盘格）→ 验证图片加载解码
 * - 球3：DataTexture.copy() 拷贝球1纹理（对照 JS Texture.copy）→ 验证拷贝接口
 * - 相机鼠标轨道控制 + 画面内 dbgText 显示纹理尺寸/是否有效
 */

import std.sync.*
import std.time.*
import std.collection.*
import std.math.*
import three.core.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.textures.*
import three.resource.loader.TextureLoader
import three.rendering.ThreeRenderer
import three.window.WindowEngine
import three.window.MouseProvider
import three.window.MouseButton

/// 场景中关键对象的引用，供渲染循环更新
public class SceneObjects {
    public var scene: Scene
    public var camera: PerspectiveCamera
    public var tex1: DataTexture
    public var tex2: DataTexture
    public var tex3: DataTexture

    public init(scene!: Scene, camera!: PerspectiveCamera, tex1!: DataTexture, tex2!: DataTexture, tex3!: DataTexture) {
        this.scene = scene
        this.camera = camera
        this.tex1 = tex1
        this.tex2 = tex2
        this.tex3 = tex3
    }
}

/// 程序生成 64x64 棋盘格纹理数据（红/白相间），返回 DataTexture
func createCheckerDataTexture(): DataTexture {
    let w = 64
    let h = 64
    let data = Array<UInt8>(w * h * 4, { _ => 0u8 })
    for (y in 0..h) {
        for (x in 0..w) {
            let c: UInt8 = if (((x / 8) + (y / 8)) % 2 == 0) { 255u8 } else { 0u8 }
            let i = (y * w + x) * 4
            data[i] = c
            data[i + 1] = if (c == 0u8) { 0u8 } else { 40u8 }
            data[i + 2] = if (c == 0u8) { 0u8 } else { 40u8 }
            data[i + 3] = 255u8
        }
    }
    return DataTexture(data, w, h)
}

/// 辅助类：持有可变纹理引用，供异步回调（lambda 不能捕获可变局部变量）更新
public class TextureHolder {
    public var tex: DataTexture
    public init(tex: DataTexture) { this.tex = tex }
}

/// 创建场景：三个贴纹理球 + 相机 + 光源
public func createScene(width: Int32, height: Int32): SceneObjects {
    let scene = Scene()
    scene.name = "TexturesScene"

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(height)
    let camera = PerspectiveCamera(fov: 60.0, aspect: aspect, near: 0.1, far: 100.0)
    camera.position.set(0.0, 0.0, 0.0)
    camera.name = "CenterCamera"

    // ---- 光源 ----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.5)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.2)
    dirLight.position.set(5.0, 8.0, 5.0)
    scene.add(dirLight)

    // ---- 球1：DataTexture 棋盘格（程序生成）----
    let tex1 = createCheckerDataTexture()
    tex1.name = "DataChecker"
    // 诊断：打印纹理数据前 16 字节，确认 RGBA8 棋盘格内容（(0,0) 应为红 255,40,40）
    let imgDbg = tex1.image
    var dbgStr = ""
    for (k in 0..min(16, imgDbg.size)) { dbgStr += imgDbg[k].toString() + "," }
    println("  [diag] tex1.image[0..16) = " + dbgStr)
    let mat1 = MeshBasicMaterial()
    mat1.map = Some(tex1)
    let mesh1 = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: mat1)
    mesh1.position.set(-3.5, 0.0, 0.0)
    mesh1.name = "MeshDataTex"
    scene.add(mesh1)

    // ---- 球2：TextureLoader 加载 res/checker.png（python 生成）----
    // TextureLoader.load 为异步回调模型（对照 JS: load(url, onLoad, onProgress, onError)）：
    // onLoad 回调中把解码后的像素/尺寸写入 tex2（DataTexture）并 needsUpdate。
    // 仓颉 lambda 不能捕获可变局部变量，用 TextureHolder 持有可变纹理引用。
    var tex2 = DataTexture(Array<UInt8>(1 * 1 * 4, { _ => 0u8 }), 1, 1)
    tex2.name = "PngChecker"
    let holder2 = TextureHolder(tex2)
    let mat2 = MeshBasicMaterial()
    mat2.map = Some(tex2)
    let mesh2 = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: mat2)
    mesh2.position.set(0.0, 0.0, 0.0)
    mesh2.name = "MeshPngTex"
    scene.add(mesh2)
    TextureLoader().load("res/checker.png", { loaded =>
        match (loaded) {
            case lt: Texture =>
                // 对照 JS TextureLoader.load：texture.image = image; texture.needsUpdate = true
                holder2.tex.image = lt.image
                if (lt.width > 0) { holder2.tex.width = lt.width }
                if (lt.height > 0) { holder2.tex.height = lt.height }
                holder2.tex.needsUpdate = true
                println("  TextureLoader 加载 res/checker.png 成功: ${holder2.tex.width}x${holder2.tex.height}")
            case _ => println("  TextureLoader 回调参数类型异常")
        }
    }, { _ => () }, { _ =>
        holder2.tex = createCheckerDataTexture()
        holder2.tex.name = "PngFallback"
        println("  TextureLoader 加载失败，回退程序化纹理")
    })

    // ---- 球3：DataTexture.copy() 拷贝球1纹理（对照 JS Texture.copy）----
    let tex3 = DataTexture(Array<UInt8>(0, { _ => 0u8 }), 1, 1)
    tex3.copy(tex1)
    tex3.name = "CopiedTex"
    let mat3 = MeshBasicMaterial()
    mat3.map = Some(tex3)
    let mesh3 = Mesh(geometry: SphereGeometry(radius: 1.2, widthSegments: 24, heightSegments: 16), material: mat3)
    mesh3.position.set(3.5, 0.0, 0.0)
    mesh3.name = "MeshCopyTex"
    scene.add(mesh3)

    // ---- 第二圈：更多可渲染纹理球（覆盖 textures 包其余 2D 可采样类型）----
    // 对照 textures 包文件清单（16 类，除 HTMLTexture 浏览器专用）：
    //   CanvasTexture / CompressedTexture / DataTexture(球1) / Texture(基类) / VideoTexture 贴球渲染；
    //   其余（Cube/DataArray/Data3D/Depth/Framebuffer/External/Source/VideoFrame/CompressedArray/CubeDepth）
    //   做构造 + 字段验证（部分依赖渲染管线专用路径，构造正确即可）。
    // 生成单色 RGBA8 数据辅助：同尺寸不同颜色便于区分
    func solidData(size: Int64, r: UInt8, g: UInt8, b: UInt8): Array<UInt8> {
        return Array<UInt8>(size * size * 4, { i =>
            let px = i % 4
            if (px == 0) { r } else if (px == 1) { g } else if (px == 2) { b } else { 255u8 }
        })
    }
    let ringTex = ArrayList<(String, Texture)>()
    let canvasTex = CanvasTexture(solidData(32, 255u8, 0u8, 0u8), 32, 32)
    canvasTex.name = "CanvasTexture"; ringTex.add(("Canvas", canvasTex))
    let compressedTex = CompressedTexture(solidData(32, 0u8, 255u8, 0u8), 32, 32)
    compressedTex.name = "CompressedTexture"; ringTex.add(("Compressed", compressedTex))
    let baseTex = Texture(image: solidData(32, 0u8, 0u8, 255u8), width: 32, height: 32)
    baseTex.name = "Texture"; ringTex.add(("Texture", baseTex))
    let videoTex = VideoTexture(solidData(32, 255u8, 255u8, 0u8))
    videoTex.width = 32; videoTex.height = 32
    videoTex.name = "VideoTexture"; ringTex.add(("Video", videoTex))
    for (i in 0..ringTex.size) {
        let (tname, tex) = ringTex[i]
        let rmat = MeshBasicMaterial()
        rmat.map = Some(tex)
        let rmesh = Mesh(geometry: SphereGeometry(radius: 0.9, widthSegments: 20, heightSegments: 14), material: rmat)
        let angle = Float64(i) * PI * 2.0 / Float64(ringTex.size)
        rmesh.position.set(6.5 * sin(angle), 0.0, 6.5 * cos(angle))
        rmesh.name = "Mesh_${tname}"
        scene.add(rmesh)
    }

    // ---- 构造验证：其余纹理类型（创建实例 + 打印关键字段，确认构造/继承/字段对齐）----
    let src = Source(data: solidData(8, 128u8, 128u8, 128u8), width: 8, height: 8)
    println("  [tex] Source: data=${src.data.size} size=${src.getSize()[0]}x${src.getSize()[1]}")
    let ext = ExternalTexture()
    println("  [tex] ExternalTexture: isTexture=${(ext is Texture).toString()} kind=${ext.kind}")
    let fbTex = FramebufferTexture(64, 64)
    println("  [tex] FramebufferTexture: ${fbTex.width}x${fbTex.height}")
    let depthTex = DepthTexture(64, 64)
    println("  [tex] DepthTexture: ${depthTex.width}x${depthTex.height} type=${depthTex.`type`}")
    let cubeDepth = CubeDepthTexture(64, 64)
    println("  [tex] CubeDepthTexture: ${cubeDepth.width}x${cubeDepth.height}")
    let vfTex = VideoFrameTexture(32, 32)
    println("  [tex] VideoFrameTexture: ${vfTex.width}x${vfTex.height}")
    // 数组/3D/压缩数组：构造 + 字段（渲染管线按 2D 上传第一层，此处仅验证构造）
    let arrTex = DataArrayTexture(solidData(16, 0u8, 200u8, 200u8), 16, 16, 2)
    println("  [tex] DataArrayTexture: ${arrTex.width}x${arrTex.height} depth=${arrTex.depth} wrapR=${arrTex.wrapR}")
    let d3Tex = Data3DTexture(solidData(16, 200u8, 0u8, 200u8), 16, 16, 2)
    println("  [tex] Data3DTexture: ${d3Tex.width}x${d3Tex.height} depth=${d3Tex.depth}")
    let compArr = CompressedArrayTexture(solidData(16, 200u8, 200u8, 0u8), 16, 16, 2)
    println("  [tex] CompressedArrayTexture: ${compArr.width}x${compArr.height} depth=${compArr.depth} wrapR=${compArr.wrapR}")
    // Cube 系：6 面图构造 + 字段
    let cubeImages = Array<Array<UInt8>>(6, { _ => solidData(16, 100u8, 100u8, 255u8) })
    let cubeTex = CubeTexture(images: cubeImages)
    println("  [tex] CubeTexture: images=${cubeTex.images.size} mapping=${cubeTex.mapping}")
    let compCube = CompressedCubeTexture(cubeImages, 16, 16)
    println("  [tex] CompressedCubeTexture: ${compCube.width}x${compCube.height}")
    // DataArrayTexture.copy / CompressedArrayTexture.copy（本轮补齐接口）
    let arrCopy = DataArrayTexture(Array<UInt8>(16 * 16 * 2 * 4, { _ => 0u8 }), 16, 16, 2)
    arrCopy.copy(arrTex)
    println("  [tex] DataArrayTexture.copy: wrapR=${arrCopy.wrapR} (copied=${arrCopy.wrapR == arrTex.wrapR})")

    println("  场景创建成功: ${scene.name}")
    println("  纹理覆盖: DataTexture/Canvas/Compressed/Texture/Video/Cube/DataArray/Data3D/Depth/CubeDepth/Framebuffer/External/Source/VideoFrame/CompressedArray/CompressedCube")
    println("  验证: 渲染球(Data/Canvas/Compressed/Texture/Video) + 构造验证(其余) + copy")
    println("")

    return SceneObjects(scene: scene, camera: camera, tex1: tex1, tex2: tex2, tex3: tex3)
}