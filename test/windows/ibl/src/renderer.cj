package ibl

/**
 * ibl 渲染场景：IBL / PBR 环境贴图工作流验证
 * - 程序化生成"六色天空盒"CubeTexture（±X 红 / -X 绿 / +Y 蓝 / -Y 黄 / +Z 品红 / -Z 青，面带径向渐变）
 * - scene.background = 该 CubeTexture（由 CubeTexturePass 作为天空盒显示）
 * - PMREMGenerator.fromScene(scene) 从场景环境源生成预过滤 PMREM（CubeUV 图集）贴图，
 *   赋给 scene.environment，作为 MeshStandardMaterial 的 IBL 环境（scene.environment → 材质 envMap）
 * - 一排 metalness=1、roughness 递增的金属球：粗糙度越低反射越锐利、越高越模糊，
 *   直观体现 PMREM 各 roughness 层级与 PBR 环境反射（getIBLIrradiance / getIBLRadiance）
 * - 一块高粗糙度地面：体现环境漫反射辐照度（漫反射 IBL）
 *
 * 体现：PMREMGenerator（CPU 预过滤 + CubeUV 打包）、scene.environment → u_envMap 绑定、
 * USE_ENVMAP / ENVMAP_TYPE_CUBE_UV 变体、PBR 材质 IBL 着色路径。
 */

import std.collection.*
import std.math.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.scene.objects.*
import three.rendering.materials.*
import three.rendering.geometry.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.rendering.textures.CubeTexture
import three.rendering.textures.PMREMGenerator
import three.rendering.textures.Texture
import three.core.interfaces.IBackground
import three.utils.log.*
import three.utils.log.macros.*

/// 判断面内像素是否落在"沿主对角线、由左上指向右下"的箭头形状内。
/// @explain 在天空盒每个面绘制同一朝向的箭头，用于直观校验反射朝向/镜像：
/// 在球反射中，某方向上的箭头指向应与在该方向上直接观察天空盒时的箭头指向一致
/// （可直接对比球体轮廓边缘内侧的反射与紧邻外侧的背景）。
/// @param px 像素列（0 .. side-1）
/// @param py 像素行（0 .. side-1）
/// @param side 单面边长
/// @return 命中箭头形状返回 true
private func isArrowPixel(px: Float64, py: Float64, side: Float64): Bool {
    let c = (side - 1.0) * 0.5
    let inv = 0.7071067811865476
    // 沿对角线方向 d=(1,1)/√2 与垂直方向 p=(-1,1)/√2 分解得到局部坐标
    let u = (px - c) * inv + (py - c) * inv
    let v = -(px - c) * inv + (py - c) * inv
    let shaftHalf = side * 0.035
    let shaftEnd = side * 0.30
    // 杆
    if (u >= -shaftEnd && u <= shaftEnd && abs(v) <= shaftHalf) {
        return true
    }
    // 箭头（三角形，宽度线性收敛到尖端）
    let headLen = side * 0.20
    if (u > shaftEnd && u <= shaftEnd + headLen) {
        let t = 1.0 - (u - shaftEnd) / headLen
        if (abs(v) <= shaftHalf * 2.8 * t) {
            return true
        }
    }
    return false
}

/// 程序化生成六色天空盒立方体贴图
/// @explain 每面：非对称对角渐变（左上亮 → 右下暗，便于观察 PMREM 模糊层级）
/// + 沿主对角线的深色箭头（用于校验反射朝向是否与天空盒一致）。
/// @param side 单面边长（像素）
/// @return 立方体贴图（6 面 RGBA8，顺序 +X/-X/+Y/-Y/+Z/-Z）
public func buildSkyCube(side: Int64): CubeTexture {
    // 6 面基色（+X 红 / -X 绿 / +Y 蓝 / -Y 黄 / +Z 品红 / -Z 青）
    let faceColors: Array<(Float64, Float64, Float64)> = [
        (1.0, 0.25, 0.25),
        (0.25, 1.0, 0.25),
        (0.25, 0.25, 1.0),
        (1.0, 1.0, 0.25),
        (1.0, 0.25, 1.0),
        (0.25, 1.0, 1.0)
    ]
    let faceBytes = side * side * 4
    let images = Array<Array<UInt8>>(6, { _ => Array<UInt8>(faceBytes, { _ => 0u8 }) })
    for (f in 0..6) {
        let face = images[f]
        let (br, bg, bb) = faceColors[f]
        for (y in 0..side) {
            for (x in 0..side) {
                // ★非对称对角渐变（左上最亮 → 右下最暗）：面内 UV 若发生翻转/镜像，
                // 反射与背景会在边缘出现明显色差，便于校验面内 UV 约定是否一致
                let ex = Float64(x) / Float64(side - 1)
                let ey = Float64(y) / Float64(side - 1)
                let t = clamp(0.6 * ex + 0.4 * ey, 0.0, 1.0)
                let g = 1.0 - t
                // 箭头像素：压成近黑色，保证在 6 种浅色面上都清晰可见
                let arrow = isArrowPixel(Float64(x), Float64(y), Float64(side))
                let r = if (arrow) { 0.05 } else { br * (0.35 + 0.65 * g) + 0.25 * g }
                let gg = if (arrow) { 0.05 } else { bg * (0.35 + 0.65 * g) + 0.25 * g }
                let b = if (arrow) { 0.05 } else { bb * (0.35 + 0.65 * g) + 0.25 * g }
                let idx = (y * side + x) * 4
                face[idx] = UInt8(Int64(clamp(r, 0.0, 1.0) * 255.0 + 0.5))
                face[idx + 1] = UInt8(Int64(clamp(gg, 0.0, 1.0) * 255.0 + 0.5))
                face[idx + 2] = UInt8(Int64(clamp(b, 0.0, 1.0) * 255.0 + 0.5))
                face[idx + 3] = 0xffu8
            }
        }
    }
    return CubeTexture(images: images)
}

/// 创建 IBL/PBR 测试场景
/// @param width 窗口逻辑宽
/// @param height 窗口逻辑高
/// @return (场景, 相机, 金属球列表, 天空盒立方体贴图, PMREM 环境贴图)
public func createScene(width: Int32, height: Int32): (Scene, PerspectiveCamera, ArrayList<Mesh>, CubeTexture, Texture) {
    let scene = Scene()
    scene.name = "IblPbrScene"

    // ---- 相机 ----
    let aspect = Float64(width) / Float64(if (height > 1i32) { height } else { 1i32 })
    let camera = PerspectiveCamera(fov: 45.0, aspect: aspect, near: 0.1, far: 200.0)
    camera.position.set(0.0, 3.0, 9.0)
    camera.lookAt(Vector3(0.0, 0.0, 0.0))
    camera.name = "MainCamera"

    // ---- 六色天空盒（CubeTexture）----
    let cubeSide: Int64 = 256
    let skyCube = buildSkyCube(cubeSide)
    // 背景：作为 CubeTexturePass 的源（Background.render 对纹理背景暂为 no-op，保留 clearColor）
    scene.background = Option<IBackground>.Some(skyCube)

    // ---- PMREM 环境贴图（IBL）：从场景环境源生成 ----
    // fromScene 读取 scene.background（CubeTexture）→ 逐面预过滤 → CubeUV 图集
    let pmrem = PMREMGenerator()
    let envMap = pmrem.fromScene(scene, 0.0, 0.1, 200.0)
    pmrem.dispose()
    // scene.environment 作为所有 PBR 材质 envMap 的兜底（材质自身 envMap 优先）
    scene.environment = Some(envMap)
    @LogInfo(["ibl", "PMREM 环境贴图生成完成: ${envMap.width}x${envMap.height} mapping=${envMap.mapping}"])

    // ---- 光照：一盏温和方向光 + 很弱环境光（主体照明来自 IBL 环境贴图）----
    let ambient = AmbientLight(color: Color(0xffffff), intensity: 0.15)
    scene.add(ambient)
    let dirLight = DirectionalLight(color: Color(0xffffff), intensity: 1.0)
    dirLight.position.set(6.0, 10.0, 6.0)
    scene.add(dirLight)
    let groundGeo = PlaneGeometry(width: 40.0, height: 40.0, widthSegments: 1, heightSegments: 1)
    let groundMat = MeshStandardMaterial()
    groundMat.color = Color(0x50, 0x50, 0x58)
    groundMat.metalness = 0.1
    groundMat.roughness = 0.85
    let ground = Mesh(geometry: groundGeo, material: groundMat)
    ground.position.set(0.0, -1.5, 0.0)
    ground.rotation.x = -3.141592653589793 / 2.0
    ground.name = "Ground"
    scene.add(ground)

    // ---- 金属球：metalness=1，roughness 从 0 → 1 递增 ----
    let spheres = ArrayList<Mesh>()
    let radius = 1.0
    let count = 6
    let roughnessList: Array<Float64> = [0.0, 0.15, 0.3, 0.5, 0.75, 1.0]
    let spacing = 2.2
    let startX = -Float64(count - 1) * spacing / 2.0
    for (i in 0..count) {
        let geo = SphereGeometry(radius: radius, widthSegments: 64, heightSegments: 48)
        let mat = MeshStandardMaterial()
        mat.color = Color(0xff, 0xff, 0xff)
        mat.metalness = 1.0
        mat.roughness = roughnessList[i]
        mat.envMapIntensity = 1.0
        let sphere = Mesh(geometry: geo, material: mat)
        sphere.position.set(startX + Float64(i) * spacing, 0.0, 0.0)
        sphere.name = "MetalSphere_" + i.toString()
        spheres.add(sphere)
        scene.add(sphere)
    }
    @LogInfo(["ibl", "金属球创建完成: ${spheres.size} 个（roughness 0.0 → 1.0）"])

    // ---- 中心一个非金属球（对比：漫反射为主 + 较弱环境反射）----
    let diffGeo = SphereGeometry(radius: radius, widthSegments: 48, heightSegments: 32)
    let diffMat = MeshStandardMaterial()
    diffMat.color = Color(0xd0, 0xd0, 0xd0)
    diffMat.metalness = 0.0
    diffMat.roughness = 0.35
    let diffSphere = Mesh(geometry: diffGeo, material: diffMat)
    diffSphere.position.set(0.0, 1.9, -3.2)
    diffSphere.name = "DielectricSphere"
    scene.add(diffSphere)

    return (scene, camera, spheres, skyCube, envMap)
}
