/**
 * @LICENSE
 * Copyright 2026 RaoZiJun
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Runtime Library Exception to the Apache 2.0 License:
 *
 * As an exception, if you use this Software to compile your source code and
 * portions of this Software are embedded into the binary product as a result,
 * you may redistribute such product without providing attribution as would
 * otherwise be required by Sections 4(a), 4(b) and 4(d) of the License.
 *
 * @file[zh-cn] PMREM 生成器
 * @brief[zh-cn] PMREMGenerator 预过滤 Mipmap 环境贴图生成器
 * @explain[zh-cn] PMREMGenerator 用于从场景生成预过滤 Mipmap 环境贴图（CubeUV 图集）。
 * 仓颉侧 scenes 包与 textures 包存在循环依赖，scene 参数经 interfaces 包 IScene 接口持有。
 * 生成流程：取环境源（CubeTexture / 等距柱状 Texture / 背景颜色）→ 按 5 个 roughness 层级
 * 逐面做锥形模糊（cone blur 近似 PMREM 预过滤）→ 打包为 2D CubeUV 图集（DataTexture）。
 * 生成的贴图 mapping = CubeUVReflectionMapping，供 standard/physical 材质的 IBL 采样
 * （shader chunk cube_uv_reflection_fragment，两者布局常量必须一致）。
 *
 * @file[en] PMREM Generator
 * @brief[en] PMREMGenerator pre-filtered mipmap environment map generator
 * @explain[en] PMREMGenerator generates pre-filtered mipmap environment maps (CubeUV atlas) from scenes.
 * The Cangjie scenes and textures packages have a circular dependency, so the scene parameter is
 * held via the interfaces package IScene interface.
 * Pipeline: resolve the environment source (CubeTexture / equirectangular Texture / background color)
 * -> cone-blur each cube face across 5 roughness levels (a cone-blur approximation of PMREM pre-filtering)
 * -> pack into a 2D CubeUV atlas (DataTexture). The generated texture has
 * mapping = CubeUVReflectionMapping for IBL sampling by standard/physical materials
 * (shader chunk cube_uv_reflection_fragment; layout constants must stay in sync).
 */
package three.rendering.textures

import three.utils.safe.IReleasable
import three.scene.interfaces.IScene
import three.core.interfaces.IBackground
import three.core.math.Color
import three.utils.constants.CubeUVReflectionMapping
import three.utils.constants.ClampToEdgeWrapping
import three.utils.constants.LinearFilter
import std.math.*
import std.collection.*

/**
 * @brief[zh-cn] PMREM 生成器类
 * @explain[zh-cn] 预过滤 Mipmap 环境贴图生成器。生成 CubeUV 图集（DataTexture），
 * 布局与 shader chunk cube_uv_reflection_fragment 严格对应。
 *
 * @brief[en] PMREM generator class
 * @explain[en] Pre-filtered mipmap environment map generator. Produces a CubeUV atlas (DataTexture)
 * whose layout strictly matches the shader chunk cube_uv_reflection_fragment.
 */
public class PMREMGenerator <: IReleasable {
    /**
     * @brief[zh-cn] 类型标签
     *
     * @brief[en] Type tag
     */
    public var kind: String

    // ===== CubeUV 图集布局常量（必须与 cube_uv_reflection_fragment 的 GLSL 常量完全一致）=====
    /**
     * @brief[zh-cn] 各 roughness 层级的立方体面尺寸（像素，level 0 最清晰）
     *
     * @brief[en] Cube face size per roughness level in pixels (level 0 is the sharpest)
     */
    public static let LEVEL_FACE_SIZES: Array<Int64> = [256, 128, 64, 32, 16]

    /**
     * @brief[zh-cn] roughness 层级数量
     *
     * @brief[en] Number of roughness levels
     */
    public static let NUM_LEVELS: Int64 = 5

    /**
     * @brief[zh-cn] CubeUV 图集宽度（3 × 256）
     *
     * @brief[en] CubeUV atlas width (3 x 256)
     */
    public static let TEX_WIDTH: Int64 = 768

    /**
     * @brief[zh-cn] CubeUV 图集高度（2 × (256+128+64+32+16)）
     *
     * @brief[en] CubeUV atlas height (2 x (256+128+64+32+16))
     */
    public static let TEX_HEIGHT: Int64 = 992

    /**
     * @brief[zh-cn] 各层级采样数（低粗糙度少采样、高粗糙度多采样，兼顾质量与耗时）
     *
     * @brief[en] Sample count per level (fewer for low roughness, more for high)
     */
    private static let LEVEL_SAMPLES: Array<Int64> = [1, 8, 16, 24, 32]

    /**
     * @brief[zh-cn] 锥形模糊最大半角（弧度），roughness=1 时覆盖近半球
     *
     * @brief[en] Maximum cone blur half-angle (radians); roughness=1 covers nearly a hemisphere
     */
    private static let MAX_CONE_ANGLE: Float64 = 1.4

    /**
     * @brief[zh-cn] 构造 PMREM 生成器
     *
     * @brief[en] Construct PMREM generator
     */
    public init() { this.kind = "PMREMGenerator" }

    /**
     * @brief[zh-cn] 从场景生成预过滤 Mipmap 环境贴图
     * @explain[zh-cn] 取场景背景（CubeTexture / 等距柱状 Texture / Color）作为环境源。
     * 无背景时生成中灰常量环境贴图（保证调用方始终拿到有效 PMREM 贴图）。
     * @param[zh-cn] scene 场景接口
     * sigma 附加模糊强度（叠加到各层 roughness 上）
     * near 近裁剪面（CPU 生成路径未使用，保留以对齐通用引擎签名）
     * far 远裁剪面（同上）
     * @return[zh-cn] 生成的 CubeUV 环境贴图
     *
     * @brief[en] Generate pre-filtered mipmap environment map from scene
     * @explain[en] Uses the scene background (CubeTexture / equirectangular Texture / Color) as the
     * environment source. Falls back to a mid-gray constant environment when no background is set.
     * @param[en] scene Scene interface
     * sigma Extra blur strength (added on top of each level's roughness)
     * near Near clipping plane (unused by the CPU path; kept to match the common engine signature)
     * far Far clipping plane (same as above)
     * @return[en] Generated CubeUV environment map
     */
    public func fromScene(scene: IScene, sigma: Float64, near: Float64, far: Float64): Texture {
        if (let Some(bg) <- scene.getBackground()) {
            match (bg) {
                // CubeTexture 是 Texture 子类，必须优先匹配
                case ct: CubeTexture => return fromCubemap(ct, sigma)
                case t: Texture => return fromEquirectangular(t, sigma)
                case c: Color => return fromColor(c)
                case _ => ()
            }
        }
        // 无可用环境源：返回中灰常量环境，避免调用方拿到空贴图导致 IBL 全黑
        return fromColor(Color(0x808080))
    }

    /**
     * @brief[zh-cn] 从立方体贴图生成 PMREM 环境贴图
     * @param[zh-cn] cubeTex 源立方体贴图（6 面 RGBA8 数据，顺序 ±X/±Y/±Z）
     * sigma 附加模糊强度
     * @return[zh-cn] CubeUV 环境贴图
     *
     * @brief[en] Generate a PMREM environment map from a cube texture
     * @param[en] cubeTex Source cube texture (6 RGBA8 faces, order +X/-X/+Y/-Y/+Z/-Z)
     * sigma Extra blur strength
     * @return[en] CubeUV environment map
     */
    public func fromCubemap(cubeTex: CubeTexture, sigma: Float64): Texture {
        let faces = cubeTex.images
        if (faces.size < 6) {
            return fromColor(Color(0x808080))
        }
        let side = cubeTex.width
        if (side <= 0) {
            return fromColor(Color(0x808080))
        }
        let data = Array<UInt8>(PMREMGenerator.TEX_WIDTH * PMREMGenerator.TEX_HEIGHT * 4, { _ => 0u8 })
        for (level in 0..PMREMGenerator.NUM_LEVELS) {
            let s = PMREMGenerator.LEVEL_FACE_SIZES[level]
            let roughness = Float64(level) / Float64(PMREMGenerator.NUM_LEVELS - 1)
            let samples = PMREMGenerator.LEVEL_SAMPLES[level]
            let yBase = PMREMGenerator.levelYOffset(level)
            for (f in 0..6) {
                let row = f / 3
                let col = f % 3
                let yOff = yBase + row * s
                let xOff = col * s
                for (y in 0..s) {
                    for (x in 0..s) {
                        // 面内 UV（0-1），与 shader 的 uv*(faceSize-1)+0.5 采样点对齐
                        let u = Float64(x) / Float64(s - 1)
                        let v = Float64(y) / Float64(s - 1)
                        let (dx, dy, dz) = PMREMGenerator.dirForUV(u, v, f)
                        let (r, g, b) = PMREMGenerator.blurDir(faces, side, dx, dy, dz, roughness, sigma, samples)
                        let idx = ((yOff + y) * PMREMGenerator.TEX_WIDTH + (xOff + x)) * 4
                        data[idx] = PMREMGenerator.toByte(r)
                        data[idx + 1] = PMREMGenerator.toByte(g)
                        data[idx + 2] = PMREMGenerator.toByte(b)
                        data[idx + 3] = 255u8
                    }
                }
            }
        }
        return PMREMGenerator.makeTexture(data)
    }

    /**
     * @brief[zh-cn] 从等距柱状投影贴图生成 PMREM 环境贴图
     * @param[zh-cn] tex 源等距柱状贴图（RGBA8）
     * sigma 附加模糊强度
     * @return[zh-cn] CubeUV 环境贴图
     *
     * @brief[en] Generate a PMREM environment map from an equirectangular texture
     * @param[en] tex Source equirectangular texture (RGBA8)
     * sigma Extra blur strength
     * @return[en] CubeUV environment map
     */
    public func fromEquirectangular(tex: Texture, sigma: Float64): Texture {
        let w = tex.width
        let h = tex.height
        let img = tex.image
        if (w <= 0 || h <= 0 || img.size == 0) {
            return fromColor(Color(0x808080))
        }
        let data = Array<UInt8>(PMREMGenerator.TEX_WIDTH * PMREMGenerator.TEX_HEIGHT * 4, { _ => 0u8 })
        for (level in 0..PMREMGenerator.NUM_LEVELS) {
            let s = PMREMGenerator.LEVEL_FACE_SIZES[level]
            let roughness = Float64(level) / Float64(PMREMGenerator.NUM_LEVELS - 1)
            let samples = PMREMGenerator.LEVEL_SAMPLES[level]
            let yBase = PMREMGenerator.levelYOffset(level)
            for (f in 0..6) {
                let row = f / 3
                let col = f % 3
                let yOff = yBase + row * s
                let xOff = col * s
                for (y in 0..s) {
                    for (x in 0..s) {
                        let u = Float64(x) / Float64(s - 1)
                        let v = Float64(y) / Float64(s - 1)
                        let (dx, dy, dz) = PMREMGenerator.dirForUV(u, v, f)
                        let (r, g, b) = PMREMGenerator.blurEquirect(img, w, h, dx, dy, dz, roughness, sigma, samples)
                        let idx = ((yOff + y) * PMREMGenerator.TEX_WIDTH + (xOff + x)) * 4
                        data[idx] = PMREMGenerator.toByte(r)
                        data[idx + 1] = PMREMGenerator.toByte(g)
                        data[idx + 2] = PMREMGenerator.toByte(b)
                        data[idx + 3] = 255u8
                    }
                }
            }
        }
        return PMREMGenerator.makeTexture(data)
    }

    /**
     * @brief[zh-cn] 从纯色生成常量 PMREM 环境贴图
     * @param[zh-cn] c 环境颜色
     * @return[zh-cn] CubeUV 环境贴图（所有层级/面均为该颜色）
     *
     * @brief[en] Generate a constant PMREM environment map from a solid color
     * @param[en] c Environment color
     * @return[en] CubeUV environment map (every level/face is that color)
     */
    public func fromColor(c: Color): Texture {
        let r = PMREMGenerator.toByte(c.r)
        let g = PMREMGenerator.toByte(c.g)
        let b = PMREMGenerator.toByte(c.b)
        let total = PMREMGenerator.TEX_WIDTH * PMREMGenerator.TEX_HEIGHT * 4
        let data = Array<UInt8>(total, { i =>
            match (i % 4) {
                case 0 => r
                case 1 => g
                case 2 => b
                case _ => 255u8
            }
        })
        return PMREMGenerator.makeTexture(data)
    }

    /**
     * @brief[zh-cn] 释放生成器占用的资源
     * @explain[zh-cn] 当前实现为纯 CPU 生成，无 GPU 资源持有，保留接口以对齐通用引擎用法。
     *
     * @brief[en] Release resources held by the generator
     * @explain[en] The current implementation is pure CPU generation and holds no GPU resources;
     * the interface is kept to match common engine usage.
     */
    public func release(): Bool {
        return true
    }

    // ===== 内部实现 =====

    /**
     * @brief[zh-cn] 某层级在图集中的 y 偏移（与 shader 内硬编码值一致）
     * @param[zh-cn] level 层级索引（0..4）
     * @return[zh-cn] y 偏移（像素）
     *
     * @brief[en] y offset of a level in the atlas (matches the hardcoded values in the shader)
     * @param[en] level Level index (0..4)
     * @return[en] y offset in pixels
     */
    private static func levelYOffset(level: Int64): Int64 {
        if (level <= 0) { return 0 }
        if (level == 1) { return 512 }
        if (level == 2) { return 768 }
        if (level == 3) { return 896 }
        return 960
    }

    /**
     * @brief[zh-cn] 由面内 UV 与面索引反算方向向量（getUV 的逆映射）
     * @param[zh-cn] u 面内 u（0-1）
     * v 面内 v（0-1）
     * face 面索引（0-5）
     * @return[zh-cn] 单位方向向量 (x, y, z)
     *
     * @brief[en] Reconstruct the direction vector from face UV and face index (inverse of getUV)
     * @param[en] u In-face u (0-1)
     * v In-face v (0-1)
     * face Face index (0-5)
     * @return[en] Unit direction vector (x, y, z)
     */
    private static func dirForUV(u: Float64, v: Float64, face: Int64): (Float64, Float64, Float64) {
        let ux = 2.0 * u - 1.0
        let uy = 2.0 * v - 1.0
        let (dx, dy, dz) = match (face) {
            case 0 => (1.0, uy, ux)
            case 1 => (-ux, 1.0, -uy)
            case 2 => (-ux, uy, 1.0)
            case 3 => (-1.0, uy, -ux)
            case 4 => (-ux, -1.0, uy)
            case _ => (ux, uy, -1.0)
        }
        let len = sqrt(dx * dx + dy * dy + dz * dz)
        if (len <= 0.000001) { return (0.0, 0.0, 1.0) }
        return (dx / len, dy / len, dz / len)
    }

    /**
     * @brief[zh-cn] 按方向对立方体源采样（含与天空盒显示一致的 X 轴翻转）
     * @param[zh-cn] faces 6 面像素数据
     * side 单面边长
     * dx 方向 x
     * dy 方向 y
     * dz 方向 z
     * @return[zh-cn] 颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Sample the cube source by direction (with the same X-axis flip as the skybox display)
     * @param[en] faces 6-face pixel data
     * side Face side length
     * dx Direction x, dy Direction y, dz Direction z
     * @return[en] Color (r, g, b), each component in 0-1
     */
    private static func sampleCube(faces: Array<Array<UInt8>>, side: Int64, dx: Float64, dy: Float64, dz: Float64): (Float64, Float64, Float64) {
        // 天空盒显示路径使用 tFlip = -1（X 轴翻转），此处保持一致，避免反射与背景错位
        let (face, u, v) = PMREMGenerator.hardwareCubeFaceUV(-dx, dy, dz)
        return PMREMGenerator.sampleFaceBilinear(faces[face], side, u, v)
    }

    /**
     * @brief[zh-cn] 硬件立方体贴图约定的方向 → (面索引, u, v) 映射
     * @param[zh-cn] dx 方向 x
     * dy 方向 y
     * dz 方向 z
     * @return[zh-cn] (面索引 0-5, u, v)
     *
     * @brief[en] Direction -> (face index, u, v) mapping using the hardware cube-map convention
     * @param[en] dx Direction x, dy Direction y, dz Direction z
     * @return[en] (face index 0-5, u, v)
     */
    private static func hardwareCubeFaceUV(dx: Float64, dy: Float64, dz: Float64): (Int64, Float64, Float64) {
        let ax = abs(dx)
        let ay = abs(dy)
        let az = abs(dz)
        if (ax >= ay && ax >= az) {
            if (dx > 0.0) { return (0, 0.5 * (1.0 - dz / ax), 0.5 * (1.0 - dy / ax)) }
            return (1, 0.5 * (1.0 + dz / ax), 0.5 * (1.0 - dy / ax))
        } else if (ay >= az) {
            if (dy > 0.0) { return (2, 0.5 * (1.0 + dx / ay), 0.5 * (1.0 + dz / ay)) }
            return (3, 0.5 * (1.0 + dx / ay), 0.5 * (1.0 - dz / ay))
        }
        if (dz > 0.0) { return (4, 0.5 * (1.0 + dx / az), 0.5 * (1.0 - dy / az)) }
        return (5, 0.5 * (1.0 - dx / az), 0.5 * (1.0 - dy / az))
    }

    /**
     * @brief[zh-cn] 单面 RGBA8 数据的双线性采样
     * @param[zh-cn] face 面像素数据（RGBA8）
     * side 单面边长
     * u 面内 u（0-1）
     * v 面内 v（0-1）
     * @return[zh-cn] 颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Bilinear sample of a single RGBA8 face
     * @param[en] face Face pixel data (RGBA8)
     * side Face side length
     * u In-face u (0-1), v In-face v (0-1)
     * @return[en] Color (r, g, b), each component in 0-1
     */
    private static func sampleFaceBilinear(face: Array<UInt8>, side: Int64, u: Float64, v: Float64): (Float64, Float64, Float64) {
        let fx = clamp(u, 0.0, 1.0) * Float64(side - 1)
        let fy = clamp(v, 0.0, 1.0) * Float64(side - 1)
        let x0 = Int64(floor(fx))
        let y0 = Int64(floor(fy))
        let x1 = if (x0 + 1 < side) { x0 + 1 } else { side - 1 }
        let y1 = if (y0 + 1 < side) { y0 + 1 } else { side - 1 }
        let tx = fx - Float64(x0)
        let ty = fy - Float64(y0)
        let (r00, g00, b00) = PMREMGenerator.readPixel(face, side, x0, y0)
        let (r10, g10, b10) = PMREMGenerator.readPixel(face, side, x1, y0)
        let (r01, g01, b01) = PMREMGenerator.readPixel(face, side, x0, y1)
        let (r11, g11, b11) = PMREMGenerator.readPixel(face, side, x1, y1)
        let rTop = r00 + (r10 - r00) * tx
        let gTop = g00 + (g10 - g00) * tx
        let bTop = b00 + (b10 - b00) * tx
        let rBot = r01 + (r11 - r01) * tx
        let gBot = g01 + (g11 - g01) * tx
        let bBot = b01 + (b11 - b01) * tx
        return (rTop + (rBot - rTop) * ty, gTop + (gBot - gTop) * ty, bTop + (bBot - bTop) * ty)
    }

    /**
     * @brief[zh-cn] 读取单面中某像素的颜色
     * @param[zh-cn] face 面像素数据（RGBA8）
     * side 单面边长
     * x 像素列
     * y 像素行
     * @return[zh-cn] 颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Read the color of a pixel in a face
     * @param[en] face Face pixel data (RGBA8)
     * side Face side length
     * x Pixel column, y Pixel row
     * @return[en] Color (r, g, b), each component in 0-1
     */
    private static func readPixel(face: Array<UInt8>, side: Int64, x: Int64, y: Int64): (Float64, Float64, Float64) {
        let idx = (y * side + x) * 4
        if (idx + 2 >= face.size) { return (0.0, 0.0, 0.0) }
        return (Float64(face[idx]) / 255.0, Float64(face[idx + 1]) / 255.0, Float64(face[idx + 2]) / 255.0)
    }

    /**
     * @brief[zh-cn] 以锥形模糊对立方体源采样（PMREM 预过滤近似）
     * @explain[zh-cn] 在方向 d 周围按 roughness 决定的锥角内均匀取 samples 个样本求平均：
     * roughness=0 → 单样本（清晰）；roughness=1 → 近半球平均（最模糊）。
     * @param[zh-cn] faces 6 面像素数据
     * side 单面边长
     * dx 中心方向 x
     * dy 中心方向 y
     * dz 中心方向 z
     * roughness 粗糙度（0-1）
     * sigma 附加模糊
     * samples 采样数
     * @return[zh-cn] 平均颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Cone-blur sampling of the cube source (PMREM pre-filtering approximation)
     * @param[en] faces 6-face pixel data, side Face side length
     * dx/dy/dz Center direction, roughness Roughness (0-1), sigma Extra blur, samples Sample count
     * @return[en] Averaged color (r, g, b), each component in 0-1
     */
    private static func blurDir(faces: Array<Array<UInt8>>, side: Int64, dx: Float64, dy: Float64, dz: Float64, roughness: Float64, sigma: Float64, samples: Int64): (Float64, Float64, Float64) {
        let spread = clamp(roughness + sigma, 0.0, 1.0)
        let theta = spread * PMREMGenerator.MAX_CONE_ANGLE
        if (theta < 0.001 || samples <= 1) {
            return PMREMGenerator.sampleCube(faces, side, dx, dy, dz)
        }
        let (tx, ty, tz, bx, by, bz) = PMREMGenerator.tangentFrame(dx, dy, dz)
        let sinT = sin(theta)
        var sr = 0.0
        var sg = 0.0
        var sb = 0.0
        for (i in 0..samples) {
            let r = sqrt((Float64(i) + 0.5) / Float64(samples)) * sinT
            let phi = Float64(i) * 2.399963229728653
            let lx = r * cos(phi)
            let ly = r * sin(phi)
            let lz = sqrt(max(0.0, 1.0 - r * r))
            // 切线空间 → 世界方向：T*lx + B*ly + N*lz
            let sx = tx * lx + bx * ly + dx * lz
            let sy = ty * lx + by * ly + dy * lz
            let sz = tz * lx + bz * ly + dz * lz
            let (cr, cg, cb) = PMREMGenerator.sampleCube(faces, side, sx, sy, sz)
            sr += cr
            sg += cg
            sb += cb
        }
        let inv = 1.0 / Float64(samples)
        return (sr * inv, sg * inv, sb * inv)
    }

    /**
     * @brief[zh-cn] 以锥形模糊对等距柱状源采样
     * @param[zh-cn] img 等距柱状像素数据（RGBA8）
     * w 贴图宽度
     * h 贴图高度
     * dx 中心方向 x
     * dy 中心方向 y
     * dz 中心方向 z
     * roughness 粗糙度（0-1）
     * sigma 附加模糊
     * samples 采样数
     * @return[zh-cn] 平均颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Cone-blur sampling of the equirectangular source
     * @param[en] img Equirectangular pixel data (RGBA8), w Width, h Height
     * dx/dy/dz Center direction, roughness Roughness, sigma Extra blur, samples Sample count
     * @return[en] Averaged color (r, g, b), each component in 0-1
     */
    private static func blurEquirect(img: Array<UInt8>, w: Int64, h: Int64, dx: Float64, dy: Float64, dz: Float64, roughness: Float64, sigma: Float64, samples: Int64): (Float64, Float64, Float64) {
        let spread = clamp(roughness + sigma, 0.0, 1.0)
        let theta = spread * PMREMGenerator.MAX_CONE_ANGLE
        if (theta < 0.001 || samples <= 1) {
            return PMREMGenerator.sampleEquirect(img, w, h, dx, dy, dz)
        }
        let (tx, ty, tz, bx, by, bz) = PMREMGenerator.tangentFrame(dx, dy, dz)
        let sinT = sin(theta)
        var sr = 0.0
        var sg = 0.0
        var sb = 0.0
        for (i in 0..samples) {
            let r = sqrt((Float64(i) + 0.5) / Float64(samples)) * sinT
            let phi = Float64(i) * 2.399963229728653
            let lx = r * cos(phi)
            let ly = r * sin(phi)
            let lz = sqrt(max(0.0, 1.0 - r * r))
            let sx = tx * lx + bx * ly + dx * lz
            let sy = ty * lx + by * ly + dy * lz
            let sz = tz * lx + bz * ly + dz * lz
            let (cr, cg, cb) = PMREMGenerator.sampleEquirect(img, w, h, sx, sy, sz)
            sr += cr
            sg += cg
            sb += cb
        }
        let inv = 1.0 / Float64(samples)
        return (sr * inv, sg * inv, sb * inv)
    }

    /**
     * @brief[zh-cn] 按方向对等距柱状源双线性采样
     * @explain[zh-cn] 采用与 shader chunk common 的 equirectUv 相同约定
     * （u = atan2(z, x)/2π + 0.5，v = asin(y)/π + 0.5），并按图像行序翻转 v。
     * @param[zh-cn] img 等距柱状像素数据（RGBA8）
     * w 贴图宽度
     * h 贴图高度
     * dx 方向 x
     * dy 方向 y
     * dz 方向 z
     * @return[zh-cn] 颜色 (r, g, b)，各分量 0-1
     *
     * @brief[en] Bilinear sample of the equirectangular source by direction
     * @param[en] img Equirectangular pixel data (RGBA8), w Width, h Height, dx/dy/dz Direction
     * @return[en] Color (r, g, b), each component in 0-1
     */
    private static func sampleEquirect(img: Array<UInt8>, w: Int64, h: Int64, dx: Float64, dy: Float64, dz: Float64): (Float64, Float64, Float64) {
        let len = sqrt(dx * dx + dy * dy + dz * dz)
        if (len <= 0.000001) { return (0.0, 0.0, 0.0) }
        let x = dx / len
        let y = dy / len
        let z = dz / len
        let u = atan2(z, x) / (2.0 * 3.141592653589793) + 0.5
        let v = asin(clamp(y, -1.0, 1.0)) / 3.141592653589793 + 0.5
        // 图像行序与 v 相反（v=0 对应球面下方，图像首行对应上方），故翻转
        let fx = clamp(u, 0.0, 1.0) * Float64(w - 1)
        let fy = (1.0 - clamp(v, 0.0, 1.0)) * Float64(h - 1)
        let x0 = Int64(floor(fx))
        let y0 = Int64(floor(fy))
        let x1 = if (x0 + 1 < w) { x0 + 1 } else { w - 1 }
        let y1 = if (y0 + 1 < h) { y0 + 1 } else { h - 1 }
        let tx = fx - Float64(x0)
        let ty = fy - Float64(y0)
        let (r00, g00, b00) = PMREMGenerator.readPixel(img, w, x0, y0)
        let (r10, g10, b10) = PMREMGenerator.readPixel(img, w, x1, y0)
        let (r01, g01, b01) = PMREMGenerator.readPixel(img, w, x0, y1)
        let (r11, g11, b11) = PMREMGenerator.readPixel(img, w, x1, y1)
        let rTop = r00 + (r10 - r00) * tx
        let gTop = g00 + (g10 - g00) * tx
        let bTop = b00 + (b10 - b00) * tx
        let rBot = r01 + (r11 - r01) * tx
        let gBot = g01 + (g11 - g01) * tx
        let bBot = b01 + (b11 - b01) * tx
        return (rTop + (rBot - rTop) * ty, gTop + (gBot - gTop) * ty, bTop + (bBot - bTop) * ty)
    }

    /**
     * @brief[zh-cn] 由方向构造正交切线基（T, B 为切/副切线，N 即方向）
     * @param[zh-cn] dx 方向 x
     * dy 方向 y
     * dz 方向 z
     * @return[zh-cn] (tx, ty, tz, bx, by, bz)
     *
     * @brief[en] Build an orthonormal tangent frame from a direction (T, B tangents; N is the direction)
     * @param[en] dx/dy/dz Direction
     * @return[en] (tx, ty, tz, bx, by, bz)
     */
    private static func tangentFrame(dx: Float64, dy: Float64, dz: Float64): (Float64, Float64, Float64, Float64, Float64, Float64) {
        let (ux, uy, uz) = if (abs(dy) > 0.999) { (1.0, 0.0, 0.0) } else { (0.0, 1.0, 0.0) }
        // T = normalize(cross(up, d))
        var tx = uy * dz - uz * dy
        var ty = uz * dx - ux * dz
        var tz = ux * dy - uy * dx
        let tl = sqrt(tx * tx + ty * ty + tz * tz)
        if (tl > 0.000001) { tx /= tl; ty /= tl; tz /= tl }
        // B = cross(d, T)
        let bx = dy * tz - dz * ty
        let by = dz * tx - dx * tz
        let bz = dx * ty - dy * tx
        return (tx, ty, tz, bx, by, bz)
    }

    /**
     * @brief[zh-cn] 浮点颜色分量（0-1）转 UInt8（0-255），自动 clamp
     * @param[zh-cn] v 颜色分量（0-1）
     * @return[zh-cn] 字节值
     *
     * @brief[en] Convert a float color component (0-1) to UInt8 (0-255), clamped
     * @param[en] v Color component (0-1)
     * @return[en] Byte value
     */
    private static func toByte(v: Float64): UInt8 {
        let x = clamp(v, 0.0, 1.0) * 255.0 + 0.5
        if (x <= 0.0) { return 0u8 }
        if (x >= 255.0) { return 255u8 }
        return UInt8(Int64(x))
    }

    /**
     * @brief[zh-cn] 由 RGBA8 数据构造 CubeUV 环境贴图（DataTexture）
     * @param[zh-cn] data 图集像素数据
     * @return[zh-cn] CubeUV 环境贴图
     *
     * @brief[en] Build the CubeUV environment map (DataTexture) from RGBA8 data
     * @param[en] data Atlas pixel data
     * @return[en] CubeUV environment map
     */
    private static func makeTexture(data: Array<UInt8>): Texture {
        return DataTexture(
            data,
            PMREMGenerator.TEX_WIDTH,
            PMREMGenerator.TEX_HEIGHT,
            mapping: CubeUVReflectionMapping,
            wrapS: ClampToEdgeWrapping,
            wrapT: ClampToEdgeWrapping,
            magFilter: LinearFilter,
            minFilter: LinearFilter
        )
    }
}
