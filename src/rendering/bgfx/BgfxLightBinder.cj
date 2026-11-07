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
 * @file[zh-cn] BgfxLightBinder
 * @brief[zh-cn] 光照收集 + 光源/相机 uniform 绑定
 * @explain[zh-cn] 对照 WebGLRenderer 的 setLightUniforms / collectRenderObjects。组合注入 BgfxBackend，通过 backend.uniforms / backend.maxDirLights 等字段访问共享资源。覆盖 6 类光源：方向光、点光源、聚光源、半球光、环境光、SH3 球谐。
 *
 * @file[en] BgfxLightBinder
 * @brief[en] Light collection and light/camera uniform binding
 * @explain[en] Corresponds to setLightUniforms / collectRenderObjects in WebGLRenderer. Composed into BgfxBackend, accesses shared resources via backend.uniforms / backend.maxDirLights etc. Covers 6 light types: directional, point, spot, hemisphere, ambient, SH3 spherical harmonics.
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
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*
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
     *
     * @brief[en] Host BgfxBackend (available after bindBackend; shared resources accessed as internal)
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
     *
     * @brief[en] Host BgfxBackend read-only properties (available after bindBackend)
     */
    private prop backend: BgfxBackend {
        get() {
            if (let Some(b) <- this._backend) {
                return b
            } else {
                throw Exception("BgfxLightBinder.backend not bound — call bindBackend first")
            }
        }
    }

    // ===== 光源 uniform 上传缓冲（按槽位复用）=====
    // 原实现每帧为每个光源数组新建 BgfxMemory：相机 4 块 + 方向光 4 块 +
    // 点光 3 块 + 聚光 4 块 + 半球光 3 块 + 环境光 1 块 + 探针 1 块。
    // BgfxMemory 走 bgfx_alloc，其内存只作 set_uniform 的数据源（调用时即 memcpy
    // 进引擎内部 uniform buffer），且不会归还 → 逐帧新建等于持续泄漏原生内存。
    //
    // 为什么按槽位而不是共用一块：同一光源数组 block 内，dirMem/colMem 等是
    // "先在循环里全部写好，再依次 set_uniform 提交"。若共用一块，后写的会覆盖
    // 先写而尚未提交的数据 → uniform 串值。故每个 uniform 独占一个槽位，
    // 槽内缓冲只在该 uniform 被复用时重写，跨帧复用同一块内存。
    // 跨槽位/跨 block 复用是安全的：bgfx_set_uniform 调用时即 memcpy 取走数据。
    private var _uploadMems: ArrayList<Option<BgfxMemory>> = ArrayList<Option<BgfxMemory>>()
    private var _uploadMemSizes: ArrayList<UInt32> = ArrayList<UInt32>()

    /**
     * @brief[zh-cn] uniform 句柄按名缓存
     * @explain[zh-cn] setCameraUniforms / setLightUniforms 每帧都要取这些句柄，
     *               原实现每次调用 backend.uniforms.createUniform(name, ...) —— 内部要对全局
     *               bgfxCallMtx 加解锁 + 对 name 字符串求哈希。相机 4 + 各光源数组句柄逐帧重复，
     *               是 beginRender 自耗时的稳定来源。句柄在进程生命周期内不变，按名缓存一次即可。
     *               key 用 "name@num"：同名数组 uniform 的 num 固定，无需区分实例。
     *
     * @brief[en] Uniform handle cache keyed by name
     * @explain[en] setCameraUniforms / setLightUniforms fetch these handles every frame; the previous
     *               implementation called backend.uniforms.createUniform(name, ...) each time, which locks
     *               the global bgfxCallMtx and hashes the name string. The 4 camera handles plus the light
     *               array handles repeat every frame, a steady source of beginRender self time. Handles are
     *               stable for the process lifetime, so caching them once by name suffices. The key uses
     *               "name@num": the num of a same-named array uniform is fixed, no need to distinguish instances.
     */
    private var _uniformHandleCache: HashMap<String, Box<UniformHandle>> = HashMap<String, Box<UniformHandle>>()

    /**
     * @brief[zh-cn] 按名取 uniform 句柄（首次创建后缓存）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] num 数组长度（非数组传 1）
     * @return[zh-cn] 缓存的 uniform 句柄
     *
     * @brief[en] Gets a uniform handle by name (cached after first creation)
     * @param[en] name Uniform name
     * @param[en] num Array length (1 for non-array)
     * @return[en] Cached uniform handle
     */
    private func _cachedUniform(name: String, num!: UInt16 = 1u16): Box<UniformHandle> {
        let key = if (num == 1u16) { name } else { name + "@" + num.toString() }
        if (let Some(h) <- this._uniformHandleCache.get(key)) {
            return h
        } else {
            let h = this.backend.uniforms.createUniform(name, UniformType.Vec4.value(), num)
            this._uniformHandleCache.add(key, h)
            return h
        }
    }

    /**
     * @brief[zh-cn] 取槽位 slot 对应的复用上传缓冲（容量不足时才重新分配）
     * @param[zh-cn] slot 槽位编号（每个 uniform 一个固定槽位）
     * @param[zh-cn] need 所需容量（字节）
     * @return[zh-cn] 复用缓冲
     *
     * @brief[en] Returns the reusable upload buffer bound to `slot` (reallocates only when it must grow)
     * @param[en] slot Slot index (one fixed slot per uniform)
     * @param[en] need Required capacity in bytes
     * @return[en] The reusable buffer
     */
    private func _uploadMem(slot: Int64, need: UInt32): BgfxMemory {
        while (this._uploadMems.size <= slot) {
            this._uploadMems.add(None)
            this._uploadMemSizes.add(0u32)
        }
        if (let Some(m) <- this._uploadMems[Int64(slot)]) {
            if (this._uploadMemSizes[Int64(slot)] >= need) { return m }
        }
        let m = BgfxMemory(need)
        this._uploadMems[Int64(slot)] = Some(m)
        this._uploadMemSizes[Int64(slot)] = need
        return m
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
    @Zone[three.rendering.bgfx.BgfxLightBinder.collectLights]
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

    /**
     * @brief[zh-cn] 直接写入一个 vec4（避免构造临时数组）
     * @param[zh-cn] mem 目标内存
     * @param[zh-cn] offset 起始偏移（float 个数，非字节）
     * @param[zh-cn] x X 分量
     * @param[zh-cn] y Y 分量
     * @param[zh-cn] z Z 分量
     * @param[zh-cn] w W 分量
     * @explain[zh-cn] 光照 uniform 每帧按 maxLights 个槽位逐个写入，若用数组字面量
     *               传值，每次写入都会产生一次堆分配（每帧数十次）。直接逐分量写入
     *               可省掉这些分配。
     *
     * @brief[en] Writes one vec4 directly (without building a temporary array)
     * @param[en] mem Target memory
     * @param[en] offset Start offset (in floats, not bytes)
     * @param[en] x X component
     * @param[en] y Y component
     * @param[en] z Z component
     * @param[en] w W component
     * @explain[en] Light uniforms are written slot by slot (maxLights slots) every
     *               frame; passing array literals would heap-allocate once per write
     *               (dozens per frame). Writing component by component avoids that.
     */
    public func writeVec4(mem: BgfxMemory, offset: Int64,
                          x: Float64, y: Float64, z: Float64, w: Float64): Unit {
        mem.writeFloat(offset, Float32(x))
        mem.writeFloat(offset + 1, Float32(y))
        mem.writeFloat(offset + 2, Float32(z))
        mem.writeFloat(offset + 3, Float32(w))
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
        // u_cameraPos
        let uCameraPos = this._cachedUniform("u_cameraPos")
        let camPosMem = this._uploadMem(0, 16u32)
        this.writeVec4(camPosMem, 0, camera.position.x, camera.position.y, camera.position.z, 0.0)
        bgfx_set_uniform_cj(uCameraPos.value, unsafe { CPointer<Unit>(camPosMem.data()) }, 1u16)

        // u_cameraNearFar
        let uCameraNearFar = this._cachedUniform("u_cameraNearFar")
        let cfMem = this._uploadMem(1, 16u32)
        this.writeVec4(cfMem, 0, camera.near, camera.far, 0.0, 0.0)
        bgfx_set_uniform_cj(uCameraNearFar.value, unsafe { CPointer<Unit>(cfMem.data()) }, 1u16)

        // toneMappingExposure（对照 JS: p_uniforms.setValue(_gl, 'toneMappingExposure', renderer.toneMappingExposure)）
        let uToneMapExp = this._cachedUniform("toneMappingExposure")
        let tmeMem = this._uploadMem(2, 16u32)
        let exp = if (let Some(r) <- backend.renderer) { r.toneMappingExposure } else { 1.0 }
        this.writeVec4(tmeMem, 0, exp, 0.0, 0.0, 0.0)
        bgfx_set_uniform_cj(uToneMapExp.value, unsafe { CPointer<Unit>(tmeMem.data()) }, 1u16)

        // isOrthographic
        let uIsOrtho = this._cachedUniform("isOrthographic")
        let ioMem = this._uploadMem(3, 16u32)
        let ioVal = match (camera) {
            case _: OrthographicCamera => 1.0
            case _ => 0.0
        }
        this.writeVec4(ioMem, 0, ioVal, 0.0, 0.0, 0.0)
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

        // ===== 方向光数组 uniform（u_lightDir / u_lightColor）=====
        let maxDir = backend.maxDirLights
        let numDir = if (dirLights.size < maxDir) { dirLights.size } else { maxDir }
        if (numDir > 0) {
            let uDir = this._cachedUniform("u_lightDir", num: UInt16(maxDir))
            let uCol = this._cachedUniform("u_lightColor", num: UInt16(maxDir))
            let dirMem = this._uploadMem(4, UInt32(maxDir * 16))
            let colMem = this._uploadMem(5, UInt32(maxDir * 16))
            for (i in 0..maxDir) {
                if (i < numDir) {
                    let light = dirLights[i]
                    // 方向 = light.position → target.position（负极方向）
                    let dir = light.position.clone().sub(light.target.position)
                    dir.normalize()
                    this.writeVec4(dirMem, i * 4, dir.x, dir.y, dir.z, 0.0)
                    this.writeVec4(colMem, i * 4, light.color.r, light.color.g, light.color.b, light.intensity)
                } else {
                    this.writeVec4(dirMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(colMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                }
            }
            bgfx_set_uniform_cj(uDir.value, unsafe { CPointer<Unit>(dirMem.data()) }, UInt16(maxDir))
            bgfx_set_uniform_cj(uCol.value, unsafe { CPointer<Unit>(colMem.data()) }, UInt16(maxDir))

            // 兼容 lightdir debug shader：其 FS 自声明独立命名 uniform u_lightDir0/u_lightColor0
            // （ShaderLibs.cj lightdirFS，debug mode 4 用）。数组化后不再由数组 uniform 覆盖，
            // 故此处额外绑定第 0 个方向光数据供其使用。
            let light0 = dirLights[0]
            let dir0 = light0.position.clone().sub(light0.target.position)
            dir0.normalize()
            let uDir0 = this._cachedUniform("u_lightDir0")
            let uCol0 = this._cachedUniform("u_lightColor0")
            let dirMem0 = this._uploadMem(6, 16u32)
            let colMem0 = this._uploadMem(7, 16u32)
            this.writeVec4(dirMem0, 0, dir0.x, dir0.y, dir0.z, 0.0)
            this.writeVec4(colMem0, 0, light0.color.r, light0.color.g, light0.color.b, light0.intensity)
            bgfx_set_uniform_cj(uDir0.value, unsafe { CPointer<Unit>(dirMem0.data()) }, 1u16)
            bgfx_set_uniform_cj(uCol0.value, unsafe { CPointer<Unit>(colMem0.data()) }, 1u16)
        }

        // ===== 点光源数组 uniform（u_pointPosition / u_pointColor / u_pointParams）=====
        let maxPt = backend.maxPointLights
        let numPt = if (pointLights.size < maxPt) { pointLights.size } else { maxPt }
        if (numPt > 0) {
            let uPtPos = this._cachedUniform("u_pointPosition", num: UInt16(maxPt))
            let uPtCol = this._cachedUniform("u_pointColor", num: UInt16(maxPt))
            let uPtPrm = this._cachedUniform("u_pointParams", num: UInt16(maxPt))
            let ppMem = this._uploadMem(8, UInt32(maxPt * 16))
            let pcMem = this._uploadMem(9, UInt32(maxPt * 16))
            let pprmMem = this._uploadMem(10, UInt32(maxPt * 16))
            for (i in 0..maxPt) {
                if (i < numPt) {
                    let light = pointLights[i]
                    this.writeVec4(ppMem, i * 4, light.position.x, light.position.y, light.position.z, light.distance)
                    this.writeVec4(pcMem, i * 4, light.color.r, light.color.g, light.color.b, light.intensity)
                    this.writeVec4(pprmMem, i * 4, light.decay, 0.0, 0.0, 0.0)
                } else {
                    this.writeVec4(ppMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(pcMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(pprmMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                }
            }
            bgfx_set_uniform_cj(uPtPos.value, unsafe { CPointer<Unit>(ppMem.data()) }, UInt16(maxPt))
            bgfx_set_uniform_cj(uPtCol.value, unsafe { CPointer<Unit>(pcMem.data()) }, UInt16(maxPt))
            bgfx_set_uniform_cj(uPtPrm.value, unsafe { CPointer<Unit>(pprmMem.data()) }, UInt16(maxPt))
        }

        // ===== 聚光源数组 uniform（u_spotPosition / u_spotColor / u_spotDirection / u_spotParams）=====
        let maxSp = backend.maxSpotLights
        let numSp = if (spotLights.size < maxSp) { spotLights.size } else { maxSp }
        if (numSp > 0) {
            let uSpPos = this._cachedUniform("u_spotPosition", num: UInt16(maxSp))
            let uSpCol = this._cachedUniform("u_spotColor", num: UInt16(maxSp))
            let uSpDir = this._cachedUniform("u_spotDirection", num: UInt16(maxSp))
            let uSpPrm = this._cachedUniform("u_spotParams", num: UInt16(maxSp))
            let spMem = this._uploadMem(11, UInt32(maxSp * 16))
            let scMem = this._uploadMem(12, UInt32(maxSp * 16))
            let sdMem = this._uploadMem(13, UInt32(maxSp * 16))
            let sprmMem = this._uploadMem(14, UInt32(maxSp * 16))
            for (i in 0..maxSp) {
                if (i < numSp) {
                    let light = spotLights[i]
                    let spotDir = light.position.clone().sub(light.target.position)
                    spotDir.normalize()
                    let angleCos = Float64(cos(Float32(light.angle)))
                    let penumbraCos = Float64(cos(Float32(light.angle * (1.0 - light.penumbra))))
                    this.writeVec4(spMem, i * 4, light.position.x, light.position.y, light.position.z, light.distance)
                    this.writeVec4(scMem, i * 4, light.color.r, light.color.g, light.color.b, light.intensity)
                    this.writeVec4(sdMem, i * 4, spotDir.x, spotDir.y, spotDir.z, angleCos)
                    this.writeVec4(sprmMem, i * 4, light.angle, light.penumbra, light.decay, penumbraCos)
                } else {
                    this.writeVec4(spMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(scMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(sdMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(sprmMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                }
            }
            bgfx_set_uniform_cj(uSpPos.value, unsafe { CPointer<Unit>(spMem.data()) }, UInt16(maxSp))
            bgfx_set_uniform_cj(uSpCol.value, unsafe { CPointer<Unit>(scMem.data()) }, UInt16(maxSp))
            bgfx_set_uniform_cj(uSpDir.value, unsafe { CPointer<Unit>(sdMem.data()) }, UInt16(maxSp))
            bgfx_set_uniform_cj(uSpPrm.value, unsafe { CPointer<Unit>(sprmMem.data()) }, UInt16(maxSp))
        }

        // ===== 半球光数组 uniform（u_hemiSkyColor / u_hemiGroundColor / u_hemiDirection）=====
        let maxHm = backend.maxHemiLights
        let numHm = if (hemiLights.size < maxHm) { hemiLights.size } else { maxHm }
        if (numHm > 0) {
            let uHmSky = this._cachedUniform("u_hemiSkyColor", num: UInt16(maxHm))
            let uHmGrn = this._cachedUniform("u_hemiGroundColor", num: UInt16(maxHm))
            let uHmDir = this._cachedUniform("u_hemiDirection", num: UInt16(maxHm))
            let hsMem = this._uploadMem(15, UInt32(maxHm * 16))
            let hgMem = this._uploadMem(16, UInt32(maxHm * 16))
            let hdMem = this._uploadMem(17, UInt32(maxHm * 16))
            for (i in 0..maxHm) {
                if (i < numHm) {
                    let light = hemiLights[i]
                    let hemiDir = Vector3(light.position.x, light.position.y, light.position.z).normalize()
                    this.writeVec4(hsMem, i * 4, light.skyColor.r, light.skyColor.g, light.skyColor.b, light.intensity)
                    this.writeVec4(hgMem, i * 4, light.groundColor.r, light.groundColor.g, light.groundColor.b, light.intensity)
                    this.writeVec4(hdMem, i * 4, hemiDir.x, hemiDir.y, hemiDir.z, 0.0)
                } else {
                    this.writeVec4(hsMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(hgMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                    this.writeVec4(hdMem, i * 4, 0.0, 0.0, 0.0, 0.0)
                }
            }
            bgfx_set_uniform_cj(uHmSky.value, unsafe { CPointer<Unit>(hsMem.data()) }, UInt16(maxHm))
            bgfx_set_uniform_cj(uHmGrn.value, unsafe { CPointer<Unit>(hgMem.data()) }, UInt16(maxHm))
            bgfx_set_uniform_cj(uHmDir.value, unsafe { CPointer<Unit>(hdMem.data()) }, UInt16(maxHm))
        }

        // ===== 环境光 uniform（u_ambientColor）=====
        let uAmbCol = this._cachedUniform("u_ambientColor")
        let ambMem = this._uploadMem(18, 16u32)
        if (ambientLights.size > 0) {
            let light = ambientLights[0]
            // 通用引擎惯例：ambientLightColor = color * intensity（rgb 乘 intensity），alpha 为 1.0
            // （对照 WebGLProgram：ambientLightColor.value = getColor(ambientLight.color, ambientLight.intensity)）
            this.writeVec4(ambMem, 0,
                light.color.r * light.intensity,
                light.color.g * light.intensity,
                light.color.b * light.intensity,
                1.0)
        } else {
            this.writeVec4(ambMem, 0, 0.05, 0.05, 0.05, 1.0)
        }
        bgfx_set_uniform_cj(uAmbCol.value, unsafe { CPointer<Unit>(ambMem.data()) }, 1u16)

        // ===== SH3 球谐辐照度系数（u_shCoefficients）=====
        // 无光探针时整段跳过：对应变体的 NUM_LIGHT_PROBES 为 0，不会引用该 uniform。
        if (lightProbes.size > 0) {
            let uShCoeffs = this._cachedUniform("shCoefficients", num: 9u16)
            let shMem = this._uploadMem(19, 144u32)
            let probe = lightProbes[0]
            let coeffs = probe.sh.coefficients
            for (i in 0..9) {
                let c = coeffs[i]
                this.writeVec4(shMem, i * 4, c.x, c.y, c.z, 0.0)
            }
            bgfx_set_uniform_cj(uShCoeffs.value, unsafe { CPointer<Unit>(shMem.data()) }, 9u16)
        }

        @LogTrace(["setLightUniforms",
            "dir=${dirLights.size} pt=${pointLights.size} sp=${spotLights.size} hemi=${hemiLights.size} amb=${ambientLights.size} probe=${lightProbes.size}"])
    }
}
