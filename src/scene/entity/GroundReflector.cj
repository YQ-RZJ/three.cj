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
 * @file[zh-cn] GroundReflector 地面反射器
 * @brief[zh-cn] 地面反射器（SSRPass 专用）—— 平面反射（planar reflection）对象
 * @explain[zh-cn] Three.cj 重构命名：类为对象（Mesh 子类），保留在 three.scene.entity 包，
 * 命名去掉 "Pass" 后缀 → GroundReflector，避免与后处理 pass 混淆
 *
 * @file[en] GroundReflector  Ground reflector
 * @brief[en] Ground reflector (SSRPass dedicated) — planar reflection object
 * @explain[en] Three.cj refactored naming: class is an object (Mesh subclass), kept in three.scene.entity package,
 * "Pass" suffix removed → GroundReflector, avoiding confusion with post-processing passes
 * 设计：
 * - 继承 Mesh：地面平面网格，材质是 ReflectorMaterial
 * - 持反射 RT（RGBA16F + D24；useDepthTexture=true 时额外 RGBA32F 深度 RT）
 * - computeVirtualCamera(camera)：镜像相机数学核心
 * 1. fresnelCoe = (dot(normalize(camera.position), reflect(normalize, yAxis)) + 1) / 2
 * 2. 反射面朝向检测（view.dot(normal) > 0 时反射面背向相机 → 返回 false）
 * 3. 构造镜像虚拟相机 virtualCamera（位置/up/看向 target 全部按 normal 镜像）
 * 4. textureMatrix = 0.5偏移矩阵 × virtualCamera.projectionMatrix ×
 * virtualCamera.matrixWorldInverse × scope.matrixWorld
 * - 实际渲场景到反射 RT 的动作由 BgfxSSRPass（postprocessing 包）编排调用
 * （Three.cj 包依赖约束：three.scene.scenegraph 不能 import three.rendering，
 * 循环依赖 objects → renderers → common → objects；渲染需要 renderer.execBgfx +
 * renderer.render，故渲染编排放在能同时依赖 objects 与 renderers 的 postprocessing 层）。
 * - 反射面自绘：主场景渲染（RenderPass → renderer.render）时经 BgfxBackend
 * 按 ReflectorMaterial kind 映射到 "reflector" shader，把反射贴图经 textureMatrix
 * 投影到地面（blendOverlay 混合 + useDepthTexture 分支距离衰减/菲涅尔）。
 * Three.cj bgfx 差异：
 * - Three.cj 由 SSRPass 用 RenderPass 范式：execBgfx 设 view 0 frame buffer = 反射 RT +
 * clear，再 renderer.render(scene, virtualCamera)（renderer.render 内部用 virtualCamera 的
 * matrixWorldInverse/projectionMatrix 设 view transform，BgfxBackend 从 camera 读取）。
 * - bgfx D24 深度 attachment 不可直接采样，故 useDepthTexture=true 时由 SSRPass
 * 用 aodepth shader 渲 NDC 深度到 RGBA32F 深度 RT（对齐 SSR/GTAO 独立深度 RT 范式）。
 * - bgfx 渲染管线无 clippingPlanes 概念，
 * clipBias 存字段作预留（默认 0 无影响），不应用全局裁剪。
 * 用法：
 * let reflector = GroundReflector(groundGeometry,
 * textureWidth: 512, textureHeight: 512, color: Color(0x777777),
 * useDepthTexture: true, clipBias: 0.003)
 * scene.add(reflector)
 * let ssrPass = SSRPass(scene, camera)
 * ssrPass.groundReflector = Some(reflector)
 * composer.addPass(ssrPass)
 *
 * @package three.scene.entity
 */

package three.scene.entity

import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

import three.rendering.geometry.BufferGeometry
import three.rendering.materials.ReflectorMaterial
import three.utils.memory.AutoFreePtr
import three.resource.bgfx.ResourceOps
import three.utils.log.Logger
import three.rendering.cameras.Camera
import three.rendering.cameras.PerspectiveCamera
import three.core.math.Color
import three.core.math.Matrix4
import three.core.math.Vector3
import three.rendering.types.*
import bgfx4cj.bgfx as bgfx

/**
 * @brief[zh-cn] 地面反射器（SSRPass 专用平面反射组件）
 * @explain[zh-cn] 地面反射器组件，继承 Mesh。
 * 持反射 RT + 镜像相机数学（computeVirtualCamera）；渲场景到反射 RT 的动作
 * 由 SSRPass 编排（Three.cj 包依赖约束，见文件头注释）。
 *
 * @brief[en] Ground reflector (SSRPass dedicated planar reflection component)
 * @explain[en] Ground reflector component, extends Mesh.
 * Holds reflection RT + mirror camera math (computeVirtualCamera); rendering scene to reflection RT
 * is orchestrated by SSRPass (Three.cj package dependency constraint, see file header comments).
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true ; withSuperClass = Mesh]
public class GroundReflector <: Mesh {
    /**
     * 分配给本组件的 bgfx view ID 段。
     *   +0: 反射场景渲染（用 view 0 语义 + renderer.render，见 SSRPass._renderGroundReflector）
     *   +1: 反射深度渲染（useDepthTexture=true 时，aodepth → RGBA32F 深度 RT）
     * 取 237 起避开 SSAO 160 / SSR 176 / Bloom 200~212 / ShaderPass 200~209 /
     * SavePass 210 / TexturePass 211 / OutputPass 212 / FXAA 213 / SMAA 214~216 /
     * SSAA 217 / TAA 219~220 / Afterimage 221~223 / FilmPass 224 / GlitchPass 225 /
     * DotScreenPass 226 / HalftonePass 227 / BokehPass 228~229 /
     * RenderPixelatedPass 230~233 / RenderTransitionPass 234~236。
     */
    @JsonIgnore
    public static let REFLECTOR_VIEW_ID_BASE: UInt16 = 237u16

    /**
     * 反射 RT color（RGBA16F）。
     */
    private var _reflectTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 反射 RT 的 depth attachment（D24）
     */
    private var _reflectDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 反射 RT frame buffer。
     */
    private var _reflectFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /**
     * 反射深度 RT color（RGBA32F 存 NDC 深度，useDepthTexture=true 时创建）。
     */
    private var _reflectDepthRT: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 反射深度 RT 的 depth attachment（D24）
     */
    private var _reflectDepthRTDepth: TextureHandle = INVALID_TEXTURE_HANDLE

    /**
     * 反射深度 RT frame buffer
     */
    private var _reflectDepthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE

    /**
     * 反射纹理尺寸（宽/高），默认 512
     */
    private var _textureWidth: Int64 = 512
    private var _textureHeight: Int64 = 512

    /**
     * clipBias（预留字段：bgfx 无全局裁剪平面，默认 0 无影响）
     */
    public var clipBias: Float64 = 0.0

    /**
     * 是否使用深度纹理（useDepthTexture define）
     */
    public var useDepthTexture: Bool = false

    /** 反射 RT 尺寸缓存（已创建标志） */
    private var _rtCreated: Bool = false

    /**
     * 镜像虚拟相机（computeVirtualCamera 计算结果）。
     */
    @JsonIgnore
    public var virtualCamera: PerspectiveCamera = PerspectiveCamera()

    /**
     * 纹理投影矩阵（computeVirtualCamera 计算结果）。
     */
    public var textureMatrix: Matrix4 = Matrix4()

    /**
     * 菲涅尔系数（computeVirtualCamera 计算结果）。
     */
    public var fresnelCoe: Float64 = 1.0

    /**
     * @param[zh-cn] geometry 地面平面几何（PlaneGeometry/BoxGeometry）
     * @param[zh-cn] textureWidth 反射纹理宽（默认 512）
     * @param[zh-cn] textureHeight 反射纹理高（默认 512）
     * @param[zh-cn] color 反射贴图混合色（默认 0x7F7F7F）
     * @param[zh-cn] clipBias 裁剪偏置（默认 0；bgfx 无全局裁剪平面，预留）
     * @param[zh-cn] useDepthTexture 是否用深度纹理（默认 false；true 时启用距离衰减/菲涅尔）
     *
     * 构造 GroundReflector。
     *
     * @param[en] geometry Ground plane geometry (PlaneGeometry/BoxGeometry)
     * @param[en] textureWidth Reflection texture width (default 512)
     * @param[en] textureHeight Reflection texture height (default 512)
     * @param[en] color Reflection map blend color (default 0x7F7F7F)
     * @param[en] clipBias Clip bias (default 0; bgfx has no global clip plane, reserved)
     * @param[en] useDepthTexture Whether to use depth texture (default false; true enables distance attenuation/Fresnel)
     */
    public init() {
        this(BufferGeometry())
    }
    public init(
        geometry: BufferGeometry,
        textureWidth!: Int64 = 512,
        textureHeight!: Int64 = 512,
        color!: Color = Color(0x7f, 0x7f, 0x7f),
        clipBias!: Float64 = 0.0,
        useDepthTexture!: Bool = false
    ) {
        super(geometry: geometry, material: ReflectorMaterial())
        this._textureWidth = textureWidth
        this._textureHeight = textureHeight
        this.clipBias = clipBias
        this.useDepthTexture = useDepthTexture
        // 材质参数同步（对照 JS: 构造里给 material.uniforms 赋值 color/maxDistance/opacity 默认值）
        let mat = this.material
        if (mat is ReflectorMaterial) {
            match (mat as ReflectorMaterial) {
                case Some(rm) =>
                    rm.reflectorColor.copy(color)
                    rm.maxDistance = 180.0
                    rm.opacity = 0.5
                    rm.useDepthTexture = useDepthTexture
                    rm.distanceAttenuation = true
                    rm.fresnel = true
                case None => ()
            }
        }
        Logger.debug(["reflector", "GroundReflector constructed: tex=${textureWidth}x${textureHeight}" +
                      " color=(${color.r},${color.g},${color.b}) useDepthTexture=${useDepthTexture}"])
    }

    /**
     * 创建反射 RT（RGBA16F + D24；useDepthTexture=true 时额外 RGBA32F 深度 RT）。
     */
    public func ensureRTs(): Unit {
        if (this._rtCreated) { return }
        Logger.debug(["reflector", "ensureRTs: creating reflect RT ${this._textureWidth}x${this._textureHeight}"])
        // 经 ResourceOps 封装创建/销毁资源（避免 objects 包依赖 renderers 包导致循环依赖）
        let resOps = ResourceOps()

        let reflectTex = resOps.createTexture2D(
            UInt16(this._textureWidth), UInt16(this._textureHeight), false, 1u16,
            TextureFormat.RGBA16F.value(),
            bgfx.TEXTURE_RT | UInt64(bgfx.SAMPLER_U_CLAMP) | UInt64(bgfx.SAMPLER_V_CLAMP) | UInt64(bgfx.SAMPLER_MIN_POINT) | UInt64(bgfx.SAMPLER_MAG_POINT),
            None)
        this._reflectTex = reflectTex
        let reflectDepth = resOps.createTexture2D(
            UInt16(this._textureWidth), UInt16(this._textureHeight), false, 1u16,
            TextureFormat.D24.value(),
            bgfx.TEXTURE_RT | UInt64(bgfx.SAMPLER_U_CLAMP) | UInt64(bgfx.SAMPLER_V_CLAMP) | UInt64(bgfx.SAMPLER_MIN_POINT) | UInt64(bgfx.SAMPLER_MAG_POINT),
            None)
        this._reflectDepthTex = reflectDepth
        this._reflectFB = this._createFBWithDepth(resOps, reflectTex, reflectDepth)
        Logger.debug(["reflector", "  reflectFB created: tex=${handleIdx(reflectTex)} depth=${handleIdx(reflectDepth)}"])

        if (this.useDepthTexture) {
            // 反射深度 RT：RGBA32F（存 NDC 深度 gl_FragCoord.z）+ D24
            let depthRT = resOps.createTexture2D(
                UInt16(this._textureWidth), UInt16(this._textureHeight), false, 1u16,
                TextureFormat.RGBA32F.value(),
                bgfx.TEXTURE_RT | UInt64(bgfx.SAMPLER_U_CLAMP) | UInt64(bgfx.SAMPLER_V_CLAMP) | UInt64(bgfx.SAMPLER_MIN_POINT) | UInt64(bgfx.SAMPLER_MAG_POINT),
                None)
            this._reflectDepthRT = depthRT
            let depthRTDepth = resOps.createTexture2D(
                UInt16(this._textureWidth), UInt16(this._textureHeight), false, 1u16,
                TextureFormat.D24.value(),
                bgfx.TEXTURE_RT | UInt64(bgfx.SAMPLER_U_CLAMP) | UInt64(bgfx.SAMPLER_V_CLAMP) | UInt64(bgfx.SAMPLER_MIN_POINT) | UInt64(bgfx.SAMPLER_MAG_POINT),
                None)
            this._reflectDepthRTDepth = depthRTDepth
            this._reflectDepthFB = this._createFBWithDepth(resOps, depthRT, depthRTDepth)
            Logger.debug(["reflector", "  reflectDepthFB created: tex=${handleIdx(depthRT)} depth=${handleIdx(depthRTDepth)}"])
        }

        // 同步材质纹理句柄（对照 JS: material.uniforms.tDiffuse.value = renderTarget.texture）
        let mat = this.material
        if (mat is ReflectorMaterial) {
            match (mat as ReflectorMaterial) {
                case Some(rm) =>
                    rm.tDiffuse = this._reflectTex
                    if (this.useDepthTexture) {
                        rm.tDepth = this._reflectDepthRT
                    }
                case None => ()
            }
        }
        this._rtCreated = true
    }

    /** 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。handle 顺序：[0]=color, [1]=depth */
    private func _createFBWithDepth(resOps: ResourceOps, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = resOps.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /**
     * @param[zh-cn] camera 主相机
     * @return[zh-cn] true=可渲染（朝向正确），false=反射面背向相机（跳过）
     *
     * 镜像相机数学核心。
     *
     * @param[en] camera Main camera
     * @return[en] true = renderable (facing correct), false = reflector facing away from camera (skip)
     *
     * 流程：
     * 1. fresnelCoe = (dot(normalize(camera.position), reflect(normalize(camera.position), yAxis)) + 1) / 2
     * 2. 反射面朝向检测：view = reflectorWorldPosition - cameraWorldPosition；
     * view.dot(normal) > 0 → 反射面背向相机 → 返回 false（跳过本次渲染）
     * 3. 镜像构造 virtualCamera（位置/up/看向 target 全部按 normal 镜像）
     * 4. textureMatrix = 0.5偏移 × proj × viewInv × matrixWorld
     */
    public func computeVirtualCamera(camera: Camera): Bool {
        this.ensureRTs()
        if (!isValidHandle(this._reflectFB)) {
            Logger.debug(["reflector", "computeVirtualCamera: reflectFB invalid"])
            return false
        }

        // ---- 1. fresnelCoe（对照 JS: vecTemp0.dot(vecTemp1) + 1 / 2）----
        let yAxis = Vector3(0.0, 1.0, 0.0)
        let vecTemp0 = Vector3(camera.position.x, camera.position.y, camera.position.z).normalize()
        let vecTemp1 = Vector3(vecTemp0.x, vecTemp0.y, vecTemp0.z).reflect(yAxis)
        this.fresnelCoe = (vecTemp0.dot(vecTemp1) + 1.0) / 2.0

        // ---- 2. 反射面朝向检测（对照 JS 逐行）----
        let reflectorWorldPosition = this.matrixWorld.getPosition()
        let cameraWorldPosition = camera.matrixWorld.getPosition()

        let rotationMatrix = Matrix4().extractRotation(this.matrixWorld)
        let normal = Vector3(0.0, 0.0, 1.0).applyMatrix4(rotationMatrix)

        let view = Vector3().subVectors(reflectorWorldPosition, cameraWorldPosition)
        if (view.dot(normal) > 0.0) {
            Logger.debug(["reflector", "computeVirtualCamera: reflector facing away, skip"])
            return false
        }

        // ---- 3. 镜像虚拟相机（对照 JS 逐行）----
        view.reflect(normal).negate()
        view.add(reflectorWorldPosition)

        rotationMatrix.extractRotation(camera.matrixWorld)
        // ★关键修复（lookAtPosition 前向方向，bgfx 左手系 vs JS 右手系）：
        //   JS/three.js 相机看向 -Z，`lookAtPosition = (0,0,-1)` 是相机前方 1 单位点；
        //   bgfx4cj 的 Matrix4.lookAt 约定相机看向 +Z（左手系，Z = target - eye），
        //   故 (0,0,-1) 在 bgfx4cj 中指向相机**后方** → lookAtPosition 落在相机后方 →
        //   target 计算错误（target 几乎与 virtualCamera.position 重合，cap11 实证：
        //   target.z=5.995 vs pos.z=5.000）→ 镜像相机视线方向错误 → 几何全部在视锥外
        //   被裁剪 → 反射 RT 全 clear、地面反射完全失效。
        //   修复：改用 (0,0,+1)（bgfx4cj 相机前方方向），lookAtPosition 才落在相机前方。
        let lookAtPosition = Vector3(0.0, 0.0, 1.0).applyMatrix4(rotationMatrix)
        lookAtPosition.add(cameraWorldPosition)

        let target = Vector3().subVectors(reflectorWorldPosition, lookAtPosition)
        target.reflect(normal).negate()
        target.add(reflectorWorldPosition)

        this.virtualCamera.position.copy(view)
        this.virtualCamera.up.set(0.0, 1.0, 0.0)
        this.virtualCamera.up.applyMatrix4(rotationMatrix)
        this.virtualCamera.up.reflect(normal)
        // ★关键修复（镜像相机 view 矩阵，绕过 Object3D.lookAt 的共轭修正）：
        //   Object3D.lookAt 内部对 quaternion 做共轭修正（negate xyz），该修正仅对
        //   up=(0,1,0) 的标准相机正确；virtualCamera 的 up 经反射后 ≠ (0,1,0)，
        //   共轭修正会生成错误朝向 → 渲反射场景时几何全部在视锥外被裁剪 →
        //   反射 RT 只有 clear 色、地面反射完全失效。
        //   （capture 二分实证：主相机渲反射场景 reflectRT 有内容，virtualCamera 渲全
        //   clear；两者仅 view 矩阵不同 → 根因锁定 virtualCamera view 矩阵。）
        //   修复：直接用 Matrix4.lookAt 构造 view 矩阵（返回标准"世界→相机"矩阵，
        //   Z = target - eye 看向目标），写入 matrixWorldInverse；matrixWorld 取其逆
        //   （ReflectorShader 的 u_virtualCameraMatrixWorld 需要镜像相机世界矩阵）。
        //   关键：必须禁用 matrixAutoUpdate/matrixWorldAutoUpdate——否则 renderer.render
        //   渲反射场景时 Object3D.updateMatrixWorld 会用单位四元数重算 matrix 覆盖
        //   手写的 matrixWorld（实证：修复前 view 矩阵变单位矩阵 view[0]=1 [5]=1 [10]=1，
        //   反射场景依旧全 clear）。禁用后 Camera.updateMatrixWorld 仍会从 matrixWorld
        //   重算 matrixWorldInverse = vm.invert() = vm（view 矩阵）✓。
        let vm = Matrix4()
        vm.lookAt(this.virtualCamera.position, target, this.virtualCamera.up)
        this.virtualCamera.matrixWorldInverse.copy(vm)
        let wm = Matrix4()
        wm.copy(vm).invert()
        this.virtualCamera.matrixWorld.copy(wm)
        this.virtualCamera.matrixAutoUpdate = false
        this.virtualCamera.matrixWorldAutoUpdate = false
        this.virtualCamera.far = camera.far
        this.virtualCamera.projectionMatrix.copy(camera.projectionMatrix)
        this.virtualCamera.projectionMatrixInverse.copy(camera.projectionMatrixInverse)

        // ---- 4. textureMatrix = 0.5偏移 × proj × viewInv × matrixWorld（对照 JS 逐行）----
        // ★bgfx 差异（UV 原点修正）：JS/WebGL 纹理 v=0 在底部（NDC y=-1 → v=0）；
        //   bgfx 纹理 v=0 在顶部。故 0.5 偏移矩阵的 Y 行取反：
        //   v = -0.5*y + 0.5（NDC y=+1 顶部 → v=0 顶部，与 bgfx 纹理约定一致），
        //   否则反射贴图上下翻转（地面反射的物体镜像颠倒、采样错位）。
        //   X 行保持 u = 0.5*x + 0.5（bgfx/WebGL 纹理 u=0 均在左侧，方向一致）。
        this.textureMatrix.set(
            0.5, 0.0, 0.0, 0.5,
            0.0, -0.5, 0.0, 0.5,
            0.0, 0.0, 0.5, 0.5,
            0.0, 0.0, 0.0, 1.0
        )
        this.textureMatrix.multiply(this.virtualCamera.projectionMatrix)
        this.textureMatrix.multiply(this.virtualCamera.matrixWorldInverse)
        this.textureMatrix.multiply(this.matrixWorld)

        // 同步材质 uniforms（对照 JS doRender 内 material.uniforms 赋值）
        let mat = this.material
        if (mat is ReflectorMaterial) {
            match (mat as ReflectorMaterial) {
                case Some(rm) =>
                    rm.textureMatrix.copy(this.textureMatrix)
                    rm.fresnelCoe = this.fresnelCoe
                    rm.virtualCameraNear = camera.near
                    rm.virtualCameraFar = camera.far
                    rm.virtualCameraMatrixWorld.copy(this.virtualCamera.matrixWorld)
                    rm.virtualCameraProjectionMatrix.copy(camera.projectionMatrix)
                    rm.virtualCameraProjectionMatrixInverse.copy(camera.projectionMatrixInverse)
                    rm.resolutionX = Float64(this._textureWidth)
                    rm.resolutionY = Float64(this._textureHeight)
                case None => ()
            }
        }

        Logger.debug(["reflector", "computeVirtualCamera done: fresnelCoe=${this.fresnelCoe.toString()}" +
                      " tex=${handleIdx(this._reflectTex)} useDepthTexture=${this.useDepthTexture}"])
        return true
    }

    /**
     * 取反射 RT frame buffer（渲染目标，由 SSRPass 设到 view）。
     */
    public func getReflectFB(): FrameBufferHandle {
        return this._reflectFB
    }

    /**
     * 取反射深度 RT frame buffer（useDepthTexture=true 时有效）。
     */
    public func getReflectDepthFB(): FrameBufferHandle {
        return this._reflectDepthFB
    }

    /**
     * 取反射器内部 RT 的 color 纹理句柄。
     */
    public func getRenderTarget(): TextureHandle {
        return this._reflectTex
    }

    /**
     * 取反射深度 RT 纹理句柄（useDepthTexture=true 时有效，RGBA32F 存 NDC 深度）。
     * 供 capture 等调试工具回读验证。
     */
    public func getReflectDepthTex(): TextureHandle {
        return this._reflectDepthRT
    }

    /**
     * @return[zh-cn] (宽, 高)
     *
     * 取反射 RT 尺寸。
     *
     * @return[en] (width, height)
     */
    public func getTextureSize(): (Int64, Int64) {
        return (this._textureWidth, this._textureHeight)
    }

    /**
     * 释放反射器 GPU 资源。
     */
    public func dispose(): Unit {
        // 经 ResourceOps 封装销毁资源（避免 objects 包依赖 renderers 包导致循环依赖）
        let resOps = ResourceOps()
        if (isValidHandle(this._reflectFB)) { resOps.destroyFrameBuffer(this._reflectFB) }
        if (isValidHandle(this._reflectTex)) { resOps.destroyTexture(this._reflectTex) }
        if (isValidHandle(this._reflectDepthTex)) { resOps.destroyTexture(this._reflectDepthTex) }
        if (isValidHandle(this._reflectDepthFB)) { resOps.destroyFrameBuffer(this._reflectDepthFB) }
        if (isValidHandle(this._reflectDepthRT)) { resOps.destroyTexture(this._reflectDepthRT) }
        if (isValidHandle(this._reflectDepthRTDepth)) { resOps.destroyTexture(this._reflectDepthRTDepth) }
        this._reflectFB = INVALID_FRAME_BUFFER_HANDLE
        this._reflectTex = INVALID_TEXTURE_HANDLE
        this._reflectDepthTex = INVALID_TEXTURE_HANDLE
        this._reflectDepthFB = INVALID_FRAME_BUFFER_HANDLE
        this._reflectDepthRT = INVALID_TEXTURE_HANDLE
        this._reflectDepthRTDepth = INVALID_TEXTURE_HANDLE
        this._rtCreated = false
        Logger.debug(["reflector", "disposed"])
    }
}
