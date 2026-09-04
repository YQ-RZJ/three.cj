/**
 * @file[zh-cn] BgfxLightBinder
 * @brief[zh-cn] 光照收集 + 光源/相机 uniform 绑定
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLRenderer.js setLightUniforms / collectRenderObjects。组合注入 BgfxBackend，通过 backend.uniforms / backend.maxDirLights 等字段访问共享资源。覆盖 6 类光源：方向光、点光源、聚光源、半球光、环境光、SH3 球谐。
 *
 * @file[en] BgfxLightBinder
 * @brief[en] Light collection and light/camera uniform binding
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLRenderer.js setLightUniforms / collectRenderObjects. Composed into BgfxBackend, accesses shared resources via backend.uniforms / backend.maxDirLights etc. Covers 6 light types: directional, point, spot, hemisphere, ambient, SH3 spherical harmonics.
 */
package three.rendering.bgfx

import three.rendering.common.*
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.rendering.lights.*
import three.rendering.cameras.*
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import bgfx4cj.bgfx.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 光照收集 + uniform 绑定辅助类
 * @explain[zh-cn] 组合注入 BgfxBackend，BgfxBackend 在 beginRender/draw 时委托给本类。本类访问 backend.uniforms / backend.maxXxxLights 等 internal 字段。
 *
 * @brief[en] Light collection and uniform binding helper class
 * @explain[en] Composed into BgfxBackend, BgfxBackend delegates to this class during beginRender/draw. This class accesses backend.uniforms / backend.maxXxxLights etc. internal fields.
 */
internal class BgfxLightBinder {
    /**
     * @brief[zh-cn] 宿主 BgfxBackend（bindBackend 后可用，internal 访问共享资源）
     */
    private var _backend: Option<BgfxBackend> = None

    public init() {}

    /**
     * @brief[zh-cn] 带宿主引用的构造
     * @explain[zh-cn] 供 BgfxBackend.init 末尾重新构造注入，此时 BgfxBackend 所有成员已初始化
     * @param[zh-cn] backend 宿主 BgfxBackend
     *
     * @brief[en] Constructor with host reference
     * @explain[en] Called at end of BgfxBackend.init for re-injection, when all BgfxBackend members are initialized
     * @param[en] backend Host BgfxBackend
     */
    public init(backend!: BgfxBackend) {
        this._backend = Some(backend)
    }

    /**
     * @brief[zh-cn] 宿主 BgfxBackend 只读属性（bindBackend 后可用）
     */
    private prop backend: BgfxBackend {
        get() {
            match (this._backend) {
                case Some(b) => return b
                case None => throw Exception("BgfxLightBinder.backend not bound — call bindBackend first")
            }
        }
    }

    // ===== 光源收集 =====

    /**
     * @brief[zh-cn] 递归收集场景中所有光源
     * @explain[zh-cn] 对照原始有效实现 _renderImpl 行 441-448 / collectRenderObjects（光源部分）
     * @param[zh-cn] scene 场景
     * @return[zh-cn] 六类光源列表的元组
     *
     * @brief[en] Recursively collects all lights in the scene
     * @explain[en] Corresponds to _renderImpl lines 441-448 / collectRenderObjects (light portion)
     * @param[en] scene Scene
     * @return[en] Tuple of six light type lists
     */
    public func collectLights(scene: Scene): (
        ArrayList<DirectionalLight>, ArrayList<PointLight>,
        ArrayList<AmbientLight>, ArrayList<SpotLight>,
        ArrayList<HemisphereLight>, ArrayList<LightProbe>) {
        let dirLights = ArrayList<DirectionalLight>()
        let pointLights = ArrayList<PointLight>()
        let ambientLights = ArrayList<AmbientLight>()
        let spotLights = ArrayList<SpotLight>()
        let hemiLights = ArrayList<HemisphereLight>()
        let lightProbes = ArrayList<LightProbe>()
        this._traverseLights(scene, dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes)
        return (dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes)
    }

    private func _traverseLights(obj: Object3D,
        dirLights: ArrayList<DirectionalLight>,
        pointLights: ArrayList<PointLight>,
        ambientLights: ArrayList<AmbientLight>,
        spotLights: ArrayList<SpotLight>,
        hemiLights: ArrayList<HemisphereLight>,
        lightProbes: ArrayList<LightProbe>): Unit {
        match (obj) {
            case dl: DirectionalLight => dirLights.add(dl)
            case pl: PointLight => pointLights.add(pl)
            case al: AmbientLight => ambientLights.add(al)
            case sl: SpotLight => spotLights.add(sl)
            case hl: HemisphereLight => hemiLights.add(hl)
            case lp: LightProbe => lightProbes.add(lp)
            case _ => ()
        }
        for (child in obj.children) {
            this._traverseLights(child, dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes)
        }
    }

    // ===== uniform 写入辅助 =====

    /**
     * @brief[zh-cn] 写入 Float32 数据到 BgfxMemory
     * @explain[zh-cn] 对照原始有效实现 writeF32ToMem
     * @param[zh-cn] mem BgfxMemory 缓冲区
     * values Float64 数组
     * count 写入数量
     * offset 偏移位置
     *
     * @brief[en] Writes Float32 data to BgfxMemory
     * @explain[en] Corresponds to original writeF32ToMem implementation
     * @param[en] mem BgfxMemory buffer
     * values Float64 array
     * count Write count
     * offset Offset position
     */
    public func writeF32ToMem(mem: BgfxMemory, values: Array<Float64>, count: Int64, offset: Int64): Unit {
        for (i in 0..count) {
            if (offset + i < 1024i64) {
                mem.writeFloat(offset + i, Float32(values[i]))
            }
        }
    }

    // ===== 相机 uniform =====

    /**
     * @brief[zh-cn] 设置相机级 uniform
     * @explain[zh-cn] 对照原始有效实现 _renderImpl 行 467-512，设置 u_cameraPos / u_cameraNearFar / isOrthographic / toneMappingExposure
     * @param[zh-cn] camera 相机
     *
     * @brief[en] Sets camera-level uniforms
     * @explain[en] Corresponds to _renderImpl lines 467-512, sets u_cameraPos / u_cameraNearFar / isOrthographic / toneMappingExposure
     * @param[en] camera Camera
     */
    public func setCameraUniforms(camera: Camera): Unit {
        let uniforms = backend.uniforms

        // u_cameraPos
        let uCameraPos = uniforms.createUniform("u_cameraPos", UniformType.Vec4.value())
        let camPosMem = BgfxMemory(16u32)
        camPosMem.writeFloats([camera.position.x, camera.position.y, camera.position.z, 0.0], 4)
        bgfx_set_uniform_cj(uCameraPos.value, unsafe { CPointer<Unit>(camPosMem.data()) }, 1u16)

        // u_cameraNearFar
        let uCameraNearFar = uniforms.createUniform("u_cameraNearFar", UniformType.Vec4.value())
        let cfMem = BgfxMemory(16u32)
        cfMem.writeFloats([camera.near, camera.far, 0.0, 0.0], 4)
        bgfx_set_uniform_cj(uCameraNearFar.value, unsafe { CPointer<Unit>(cfMem.data()) }, 1u16)

        // toneMappingExposure（对照 JS: p_uniforms.setValue(_gl, 'toneMappingExposure', renderer.toneMappingExposure)）
        let uToneMapExp = uniforms.createUniform("toneMappingExposure", UniformType.Vec4.value())
        let tmeMem = BgfxMemory(16u32)
        let exp = match (backend.renderer) { case Some(r) => r.toneMappingExposure case None => 1.0 }
        tmeMem.writeFloats([exp, 0.0, 0.0, 0.0], 4)
        bgfx_set_uniform_cj(uToneMapExp.value, unsafe { CPointer<Unit>(tmeMem.data()) }, 1u16)

        // isOrthographic
        let uIsOrtho = uniforms.createUniform("isOrthographic", UniformType.Vec4.value())
        let ioMem = BgfxMemory(16u32)
        let ioVal = match (camera) {
            case _: OrthographicCamera => 1.0
            case _ => 0.0
        }
        ioMem.writeFloats([ioVal, 0.0, 0.0, 0.0], 4)
        bgfx_set_uniform_cj(uIsOrtho.value, unsafe { CPointer<Unit>(ioMem.data()) }, 1u16)
    }

    // ===== 光源 uniform 绑定 =====

    /**
     * @brief[zh-cn] 设置所有光源的 uniform 数据
     * @explain[zh-cn] 对照原始有效实现 setLightUniforms（行 655-806）。覆盖 6 类光源：方向光、点光源、聚光源、半球光、环境光、SH3 球谐
     * @param[zh-cn] dirLights 方向光列表
     * pointLights 点光源列表
     * ambientLights 环境光列表
     * spotLights 聚光源列表
     * hemiLights 半球光列表
     * lightProbes 光探针列表
     *
     * @brief[en] Sets all light uniform data
     * @explain[en] Corresponds to setLightUniforms (lines 655-806). Covers 6 light types: directional, point, spot, hemisphere, ambient, SH3 spherical harmonics
     * @param[en] dirLights Directional light list
     * pointLights Point light list
     * ambientLights Ambient light list
     * spotLights Spot light list
     * hemiLights Hemisphere light list
     * lightProbes Light probe list
     */
    public func setLightUniforms(
        dirLights: ArrayList<DirectionalLight>,
        pointLights: ArrayList<PointLight>,
        ambientLights: ArrayList<AmbientLight>,
        spotLights: ArrayList<SpotLight>,
        hemiLights: ArrayList<HemisphereLight>,
        lightProbes: ArrayList<LightProbe>): Unit {

        let uniforms = backend.uniforms

        // ===== 方向光数组 uniform（u_lightDir / u_lightColor）=====
        let maxDir = backend.maxDirLights
        let numDir = if (dirLights.size < maxDir) { dirLights.size } else { maxDir }
        let uDir = uniforms.createUniform("u_lightDir", UniformType.Vec4.value(), UInt16(maxDir))
        let uCol = uniforms.createUniform("u_lightColor", UniformType.Vec4.value(), UInt16(maxDir))
        let dirMem = BgfxMemory(UInt32(maxDir * 16))
        let colMem = BgfxMemory(UInt32(maxDir * 16))
        for (i in 0..maxDir) {
            if (i < numDir) {
                let light = dirLights[i]
                // 方向 = light.position → target.position（负极方向）
                let dir = light.position.clone().sub(light.target.position)
                dir.normalize()
                this.writeF32ToMem(dirMem, [dir.x, dir.y, dir.z, 0.0], 4, i * 4)
                this.writeF32ToMem(colMem, [light.color.r, light.color.g, light.color.b, light.intensity], 4, i * 4)
            } else {
                this.writeF32ToMem(dirMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(colMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
            }
        }
        bgfx_set_uniform_cj(uDir.value, unsafe { CPointer<Unit>(dirMem.data()) }, UInt16(maxDir))
        bgfx_set_uniform_cj(uCol.value, unsafe { CPointer<Unit>(colMem.data()) }, UInt16(maxDir))

        // 兼容 lightdir debug shader：其 FS 自声明独立命名 uniform u_lightDir0/u_lightColor0
        // （ShaderLibs.cj lightdirFS，debug mode 4 用）。数组化后不再由数组 uniform 覆盖，
        // 故此处额外绑定第 0 个方向光数据供其使用。
        if (numDir >= 1) {
            let light0 = dirLights[0]
            let dir0 = light0.position.clone().sub(light0.target.position)
            dir0.normalize()
            let uDir0 = uniforms.createUniform("u_lightDir0", UniformType.Vec4.value())
            let uCol0 = uniforms.createUniform("u_lightColor0", UniformType.Vec4.value())
            let dirMem0 = BgfxMemory(16u32)
            let colMem0 = BgfxMemory(16u32)
            dirMem0.writeFloats([dir0.x, dir0.y, dir0.z, 0.0], 4)
            colMem0.writeFloats([light0.color.r, light0.color.g, light0.color.b, light0.intensity], 4)
            bgfx_set_uniform_cj(uDir0.value, unsafe { CPointer<Unit>(dirMem0.data()) }, 1u16)
            bgfx_set_uniform_cj(uCol0.value, unsafe { CPointer<Unit>(colMem0.data()) }, 1u16)
        }

        // ===== 点光源数组 uniform（u_pointPosition / u_pointColor / u_pointParams）=====
        let maxPt = backend.maxPointLights
        let numPt = if (pointLights.size < maxPt) { pointLights.size } else { maxPt }
        let uPtPos = uniforms.createUniform("u_pointPosition", UniformType.Vec4.value(), UInt16(maxPt))
        let uPtCol = uniforms.createUniform("u_pointColor", UniformType.Vec4.value(), UInt16(maxPt))
        let uPtPrm = uniforms.createUniform("u_pointParams", UniformType.Vec4.value(), UInt16(maxPt))
        let ppMem = BgfxMemory(UInt32(maxPt * 16))
        let pcMem = BgfxMemory(UInt32(maxPt * 16))
        let pprmMem = BgfxMemory(UInt32(maxPt * 16))
        for (i in 0..maxPt) {
            if (i < numPt) {
                let light = pointLights[i]
                this.writeF32ToMem(ppMem, [light.position.x, light.position.y, light.position.z, light.distance], 4, i * 4)
                this.writeF32ToMem(pcMem, [light.color.r, light.color.g, light.color.b, light.intensity], 4, i * 4)
                this.writeF32ToMem(pprmMem, [light.decay, 0.0, 0.0, 0.0], 4, i * 4)
            } else {
                this.writeF32ToMem(ppMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(pcMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(pprmMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
            }
        }
        bgfx_set_uniform_cj(uPtPos.value, unsafe { CPointer<Unit>(ppMem.data()) }, UInt16(maxPt))
        bgfx_set_uniform_cj(uPtCol.value, unsafe { CPointer<Unit>(pcMem.data()) }, UInt16(maxPt))
        bgfx_set_uniform_cj(uPtPrm.value, unsafe { CPointer<Unit>(pprmMem.data()) }, UInt16(maxPt))

        // ===== 聚光源数组 uniform（u_spotPosition / u_spotColor / u_spotDirection / u_spotParams）=====
        let maxSp = backend.maxSpotLights
        let numSp = if (spotLights.size < maxSp) { spotLights.size } else { maxSp }
        let uSpPos = uniforms.createUniform("u_spotPosition", UniformType.Vec4.value(), UInt16(maxSp))
        let uSpCol = uniforms.createUniform("u_spotColor", UniformType.Vec4.value(), UInt16(maxSp))
        let uSpDir = uniforms.createUniform("u_spotDirection", UniformType.Vec4.value(), UInt16(maxSp))
        let uSpPrm = uniforms.createUniform("u_spotParams", UniformType.Vec4.value(), UInt16(maxSp))
        let spMem = BgfxMemory(UInt32(maxSp * 16))
        let scMem = BgfxMemory(UInt32(maxSp * 16))
        let sdMem = BgfxMemory(UInt32(maxSp * 16))
        let sprmMem = BgfxMemory(UInt32(maxSp * 16))
        for (i in 0..maxSp) {
            if (i < numSp) {
                let light = spotLights[i]
                let spotDir = light.position.clone().sub(light.target.position)
                spotDir.normalize()
                let angleCos = Float64(cos(Float32(light.angle)))
                let penumbraCos = Float64(cos(Float32(light.angle * (1.0 - light.penumbra))))
                this.writeF32ToMem(spMem, [light.position.x, light.position.y, light.position.z, light.distance], 4, i * 4)
                this.writeF32ToMem(scMem, [light.color.r, light.color.g, light.color.b, light.intensity], 4, i * 4)
                this.writeF32ToMem(sdMem, [spotDir.x, spotDir.y, spotDir.z, angleCos], 4, i * 4)
                this.writeF32ToMem(sprmMem, [light.angle, light.penumbra, light.decay, penumbraCos], 4, i * 4)
            } else {
                this.writeF32ToMem(spMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(scMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(sdMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(sprmMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
            }
        }
        bgfx_set_uniform_cj(uSpPos.value, unsafe { CPointer<Unit>(spMem.data()) }, UInt16(maxSp))
        bgfx_set_uniform_cj(uSpCol.value, unsafe { CPointer<Unit>(scMem.data()) }, UInt16(maxSp))
        bgfx_set_uniform_cj(uSpDir.value, unsafe { CPointer<Unit>(sdMem.data()) }, UInt16(maxSp))
        bgfx_set_uniform_cj(uSpPrm.value, unsafe { CPointer<Unit>(sprmMem.data()) }, UInt16(maxSp))

        // ===== 半球光数组 uniform（u_hemiSkyColor / u_hemiGroundColor / u_hemiDirection）=====
        let maxHm = backend.maxHemiLights
        let numHm = if (hemiLights.size < maxHm) { hemiLights.size } else { maxHm }
        let uHmSky = uniforms.createUniform("u_hemiSkyColor", UniformType.Vec4.value(), UInt16(maxHm))
        let uHmGrn = uniforms.createUniform("u_hemiGroundColor", UniformType.Vec4.value(), UInt16(maxHm))
        let uHmDir = uniforms.createUniform("u_hemiDirection", UniformType.Vec4.value(), UInt16(maxHm))
        let hsMem = BgfxMemory(UInt32(maxHm * 16))
        let hgMem = BgfxMemory(UInt32(maxHm * 16))
        let hdMem = BgfxMemory(UInt32(maxHm * 16))
        for (i in 0..maxHm) {
            if (i < numHm) {
                let light = hemiLights[i]
                let hemiDir = Vector3(light.position.x, light.position.y, light.position.z).normalize()
                this.writeF32ToMem(hsMem, [light.skyColor.r, light.skyColor.g, light.skyColor.b, light.intensity], 4, i * 4)
                this.writeF32ToMem(hgMem, [light.groundColor.r, light.groundColor.g, light.groundColor.b, light.intensity], 4, i * 4)
                this.writeF32ToMem(hdMem, [hemiDir.x, hemiDir.y, hemiDir.z, 0.0], 4, i * 4)
            } else {
                this.writeF32ToMem(hsMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(hgMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
                this.writeF32ToMem(hdMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4)
            }
        }
        bgfx_set_uniform_cj(uHmSky.value, unsafe { CPointer<Unit>(hsMem.data()) }, UInt16(maxHm))
        bgfx_set_uniform_cj(uHmGrn.value, unsafe { CPointer<Unit>(hgMem.data()) }, UInt16(maxHm))
        bgfx_set_uniform_cj(uHmDir.value, unsafe { CPointer<Unit>(hdMem.data()) }, UInt16(maxHm))

        // ===== 环境光 uniform（u_ambientColor）=====
        let uAmbCol = uniforms.createUniform("u_ambientColor", UniformType.Vec4.value())
        let ambMem = BgfxMemory(16u32)
        if (ambientLights.size > 0) {
            let light = ambientLights[0]
            // Three.js 标准：ambientLightColor = color * intensity（rgb 乘 intensity），alpha 为 1.0
            // （对照 Three.js WebGLProgram：ambientLightColor.value = getColor(ambientLight.color, ambientLight.intensity)）
            ambMem.writeFloats([
                light.color.r * light.intensity,
                light.color.g * light.intensity,
                light.color.b * light.intensity,
                1.0
            ], 4)
        } else {
            ambMem.writeFloats([0.05, 0.05, 0.05, 1.0], 4)
        }
        bgfx_set_uniform_cj(uAmbCol.value, unsafe { CPointer<Unit>(ambMem.data()) }, 1u16)

        // ===== SH3 球谐辐照度系数（u_shCoefficients）=====
        let uShCoeffs = uniforms.createUniform("shCoefficients", UniformType.Vec4.value(), 9u16)
        let shMem = BgfxMemory(144u32)
        if (lightProbes.size > 0) {
            let probe = lightProbes[0]
            let coeffs = probe.sh.coefficients
            for (i in 0..9) {
                let c = coeffs[i]
                this.writeF32ToMem(shMem, [c.x, c.y, c.z, 0.0], 4, i * 4)
            }
        } else {
            for (i in 0..9) { this.writeF32ToMem(shMem, [0.0, 0.0, 0.0, 0.0], 4, i * 4) }
        }
        bgfx_set_uniform_cj(uShCoeffs.value, unsafe { CPointer<Unit>(shMem.data()) }, 9u16)

        Logger.trace(["setLightUniforms",
            "dir=${dirLights.size} pt=${pointLights.size} sp=${spotLights.size} hemi=${hemiLights.size} amb=${ambientLights.size} probe=${lightProbes.size}"])
    }
}
