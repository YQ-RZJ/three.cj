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
 * @file[zh-cn] BgfxShadowPass
 * @brief[zh-cn] 阴影深度预 pass — 三类光源（方向/聚光/点）的阴影贴图渲染 + 主 pass 阴影 uniform 绑定
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLShadowMap.js。组合注入 BgfxBackend，覆盖三类阴影光源：方向光（2D 阴影）、聚光灯（2D 阴影）、点光源（cube 阴影 6 face）。
 *
 * @file[en] BgfxShadowPass
 * @brief[en] Shadow depth pre-pass — shadow map rendering for three light types (directional/spot/point) + main pass shadow uniform binding
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLShadowMap.js. Composed into BgfxBackend, covers three shadow light types: directional (2D shadow), spot (2D shadow), point (cube shadow 6 faces).
 */
package three.rendering.bgfx

import three.rendering.common.*
import three.rendering.shaders.ShaderLibs
import three.rendering.shaders.ShaderProgram
import three.rendering.shaders.SamplerStages
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.rendering.lights.*
import three.rendering.cameras.*
import three.scene.entity.Mesh
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import bgfx4cj.bgfx.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 阴影深度预 pass
 * @explain[zh-cn] 组合注入 BgfxBackend，持有阴影状态字段（_shadowSlots/_shadowResources/...）。BgfxBackend 在 prepareShadowMap/bindShadowUniforms 时委托给本类
 *
 * @brief[en] Shadow depth pre-pass
 * @explain[en] Composed into BgfxBackend, holds shadow state fields (_shadowSlots/_shadowResources/...). BgfxBackend delegates to this class for prepareShadowMap/bindShadowUniforms
 */
public class BgfxShadowPass {
    /**
     * @brief[zh-cn] 宿主 BgfxBackend（bindBackend 后可用，internal 访问共享资源）
     *
     * @brief[en] Host BgfxBackend (available after bindBackend, internal access to shared resources)
     */
    private var _backend: Option<BgfxBackend> = None

    /**
     * @brief[zh-cn] 阴影深度预 pass 用的 view ID 段约定：主渲染 view 0，阴影 view 从 64 开始
     *
     * @brief[en] Shadow depth pre-pass view ID segment convention: main render view 0, shadow views start from 64
     */
    public static let SHADOW_VIEW_ID_BASE: UInt16 = 64u16

    /**
     * @brief[zh-cn] 当前帧各阴影光源的 ShadowSlot，按光源 ID 索引（每帧 prepareShadowMap 时清空重建）
     *
     * @brief[en] Current frame ShadowSlots per shadow light, indexed by light ID (cleared and rebuilt each frame during prepareShadowMap)
     */
    internal var _shadowSlots: HashMap<Int64, ShadowSlot> = HashMap<Int64, ShadowSlot>()
    /**
     * @brief[zh-cn] 持久化的阴影 framebuffer/纹理资源池（按光源 ID 索引），跨帧复用，光源销毁时释放
     *
     * @brief[en] Persistent shadow framebuffer/texture resource pool (indexed by light ID), reused across frames, released when light is destroyed
     */
    private var _shadowResources: HashMap<Int64, ShadowSlot> = HashMap<Int64, ShadowSlot>()
    /**
     * @brief[zh-cn] view ID 分配游标：每个阴影光源占用若干连续 view ID，从 SHADOW_VIEW_ID_BASE 开始
     *
     * @brief[en] View ID allocation cursor: each shadow light occupies several consecutive view IDs, starting from SHADOW_VIEW_ID_BASE
     */
    private var _nextShadowViewId: UInt16 = BgfxShadowPass.SHADOW_VIEW_ID_BASE
    /**
     * @brief[zh-cn] 当前帧各阴影光源的类型标记（"dir"/"spot"/"point"），供 _bindShadowUniforms 区分 2D 阴影的类型
     *
     * @brief[en] Current frame shadow light type markers ("dir"/"spot"/"point"), used by _bindShadowUniforms to distinguish 2D shadow types
     */
    internal var _shadowSlotKind: HashMap<Int64, String> = HashMap<Int64, String>()

    public init() {}

    /**
     * @brief[zh-cn] 带宿主引用的构造
     * @explain[zh-cn] 供 BgfxBackend.init 末尾重新构造注入（此时 BgfxBackend 所有成员已初始化，访问 this 合法——声明处默认构造已保证 shadowPass 字段有值，此处用真实宿主替换）
     * @param[zh-cn] backend 宿主 BgfxBackend 实例
     *
     * @brief[en] Constructor with host reference
     * @explain[en] Used at end of BgfxBackend.init for re-construction injection (all BgfxBackend members are initialized at this point, accessing this is legal — the default constructor at declaration ensures shadowPass field has a value, replaced here with the real host)
     * @param[en] backend Host BgfxBackend instance
     */
    public init(backend!: BgfxBackend) {
        this._backend = Some(backend)
    }

    /**
     * @brief[zh-cn] 宿主 BgfxBackend 只读属性（bindBackend 后可用）
     *
     * @brief[en] Host BgfxBackend read-only property (available after bindBackend)
     */
    private prop backend: BgfxBackend {
        get() {
            match (this._backend) {
                case Some(b) => return b
                case None => throw Exception("BgfxShadowPass.backend not bound — call bindBackend first")
            }
        }
    }

    /**
     * @brief[zh-cn] 每帧开始时清空当前帧阴影槽（持久资源 _shadowResources 不清，跨帧复用）
     *
     * @brief[en] Clear current frame shadow slots at frame start (persistent resources _shadowResources are not cleared, reused across frames)
     */
    public func beginFrame(): Unit {
        this._shadowSlots.clear()
        this._shadowSlotKind.clear()
        this._nextShadowViewId = BgfxShadowPass.SHADOW_VIEW_ID_BASE
    }

    // ===== 方向光阴影 =====

    /**
     * @brief[zh-cn] 渲染方向光阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderShadowMap：用 lightView/lightProj 设 view transform，把所有 caster 几何体用 depth shader submit 到 shadowViewId 对应的 shadow framebuffer，内部计算 _shadowMatrix = lightProj × lightView
     * @param[zh-cn] light 方向光（含 shadow.camera 正交相机 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render directional light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderShadowMap: sets view transform with lightView/lightProj, submits all caster geometry using depth shader to shadow framebuffer at shadowViewId, internally computes _shadowMatrix = lightProj × lightView
     * @param[en] light Directional light (with shadow.camera orthographic camera + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    public func renderShadowMap(light: DirectionalLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        Logger.trace(["shadow", "renderShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)
        // VSM 类型：需要 RG16F mean/variance 纹理链（D32 深度 → blur → RG16F final），
        // 与 PCF/BASIC 的 D24 深度纹理不同（对照参考版 ThreeRenderer.renderShadowMap + BgfxShadowMap.createShadowMap VSM 分支）
        let isVsm = backend.shadowMap.getShadowType() == VSM_SHADOW_MAP

        // 持久资源：尺寸不变则跨帧复用；变更则销毁重建
        var slot = match (this._shadowResources.get(lightId)) {
            case Some(s) =>
                if (s.size != shadowSize) {
                    this._destroySlot(s)
                    let fresh = ShadowSlot()
                    fresh.size = shadowSize
                    this._shadowResources.add(lightId, fresh)
                    fresh
                } else {
                    s
                }
            case None =>
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                this._shadowResources.add(lightId, fresh)
                fresh
        }

        if (slot.texture.idx == 65535u16) {
            if (isVsm) {
                // VSM 模式：三步纹理链（对照 BgfxShadowMap.createShadowMap VSM 分支）：
                //   ① D32 深度纹理 → frameBuffer（深度 pass 写入）
                //   ② RG16F pass 纹理 → passFrameBuffer（垂直 blur 输出）
                //   ③ RG16F final 纹理 → finalFrameBuffer（水平 blur 输出，主 pass 采样 slot.texture）
                // 全部用 from_handles 把外部句柄包进 FB，确保 blur 读到的就是同一份 GPU 资源
                let depthTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.D32.value(), TEXTURE_RT, CPointer<Memory>())
                slot.vsmDepthTexture = depthTex
                let depthHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { depthHolder.get().write(0, depthTex) }
                slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, depthHolder.get(), false)
                depthHolder.dispose()

                let passTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>())
                slot.vsmPassTexture = passTex
                let passHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { passHolder.get().write(0, passTex) }
                slot.vsmPassFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, passHolder.get(), false)
                passHolder.dispose()

                let finalTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>())
                slot.texture = finalTex
                let finalHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { finalHolder.get().write(0, finalTex) }
                slot.vsmFinalFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, finalHolder.get(), false)
                finalHolder.dispose()
                Logger.trace(["shadow", "dir created VSM chain D32=${depthTex.idx} RG16F pass=${passTex.idx} final=${finalTex.idx} size=${shadowSize}"])
            } else {
                // PCF/BASIC 模式：D24 深度纹理（比较采样器）
                let depthTex = bgfx_create_texture_2d_cj(
                    UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                    TextureFormat.D24.value(),
                    TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL) |
                        UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP),
                    CPointer<Memory>())
                slot.texture = depthTex
                let handlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { handlesHolder.get().write(0, depthTex) }
                slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, handlesHolder.get(), true)
                handlesHolder.dispose()
                Logger.trace(["shadow", "dir created shadowFB(D24) idx=${slot.frameBuffer.idx} tex=${depthTex.idx} size=${shadowSize}"])
            }
        }

        // 分配 view ID（每光源独占一段）并登记到当前帧 _shadowSlots
        // VSM 需 2 个连续 view：baseViewId=深度 pass，baseViewId+1=blur pass
        slot.baseViewId = this._allocShadowViewId(count: if (isVsm) { 2 } else { 1 })
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "dir")
        // per-light bias/normalBias（来自 light.shadow，主 pass 绑 u_dirShadowParams[i]）
        slot.bias = light.shadow.bias
        slot.normalBias = light.shadow.normalBias

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染深度 pass（内部计算 slot.shadowMatrix = bias × lightViewProj）
        this._renderShadowDepth(light, scene, slot)
        // VSM：深度 pass 后执行 blur（D32 → RG16F pass → RG16F final）
        if (isVsm) {
            this._vsmBlurPass(slot)
        }
    }

    /**
     * @brief[zh-cn] 渲染方向光阴影深度到指定 framebuffer
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderShadowDepth：从光源视角设置 view/proj，遍历场景几何体用 depth shader submit 到 shadowViewId
     * @param[zh-cn] light 方向光
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render directional light shadow depth to specified framebuffer
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderShadowDepth: sets view/proj from light perspective, iterates scene geometry using depth shader to submit to shadowViewId
     * @param[en] light Directional light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderShadowDepth(light: DirectionalLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let shadowViewId = slot.baseViewId
        let fb = slot.frameBuffer
        let shadowCamera = light.shadow.camera
        Logger.trace(["shadow", "_renderShadowDepth ENTER shadowViewId=${shadowViewId} fb.idx=${fb.idx} shadowSize=${shadowSize}"])

        bgfx_set_view_rect_cj(shadowViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
        bgfx_set_view_frame_buffer_cj(shadowViewId, fb)

        // 关键修复：显式 update shadowCamera 的 position/lookAt/matrixWorld。
        // DirectionalLightShadow/DirectionalLight 基类不会自动 update shadowCamera，
        // 故 shadowCamera.matrixWorld 默认是单位矩阵（位置 0,0,0 朝向 -Z），
        // 用它的 matrixWorldInverse 会把所有 caster 顶点映到 [-5,5] 外 → 全灰。
        // 必须把 shadowCamera 定位到光源位置朝向光源 target，再 updateMatrixWorld。
        shadowCamera.position.copy(light.position)
        shadowCamera.lookAt(light.target.position)
        shadowCamera.updateMatrixWorld(true)
        // 正交相机 bounds 已含 [-5,5]×[-5,5]×[0.5,500]，updateProjectionMatrix 确保 projectionMatrix 已算
        // updateProjectionMatrix 是 OrthographicCamera 子类独有方法（Camera 基类无），需 cast 调
        match (shadowCamera as OrthographicCamera) {
            case Some(ortho) => ortho.updateProjectionMatrix()
            case None => ()
        }

        // 从光源视角设置 view/proj 矩阵：用 shadowCamera 自己的 matrixWorldInverse + projectionMatrix
        // （不再手算 lookAt —— shadowCamera.matrixWorldInverse 已含位置/朝向，projectionMatrix 已含正交 bounds）
        let lightView = shadowCamera.matrixWorldInverse
        let lightProj = shadowCamera.projectionMatrix
        let viewArr = lightView.toArray(Array<Float64>(16, { _ => 0.0 }))
        let projArr = lightProj.toArray(Array<Float64>(16, { _ => 0.0 }))
        backend._setViewTransform(shadowViewId, viewArr, projArr)

        // 计算阴影矩阵（lightViewProj → 用于主 pass 的阴影坐标变换）
        let lightViewProj = lightProj.clone().multiply(lightView)
        slot.shadowMatrix = lightViewProj

        // 渲染深度 pass：遍历场景几何体用 depth shader submit
        bgfx_set_view_clear_cj(shadowViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
        let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                         BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

        // 确保 depth shader 已编译
        let depthProgOpt = ShaderLibs.get("depth")
        Logger.trace(["shadow", "_renderShadowDepth depthProgOpt=${match (depthProgOpt) { case Some(_) => "Some" case None => "None" }}"])
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (depthSp.programHandle.idx == 65535u16) {
                    depthSp.compileBgfx()
                }
                let depthProg = depthSp.programHandle
                Logger.trace(["shadow", "_renderShadowDepth depthProg.idx=${depthProg.idx}"])
                if (depthProg.idx == 65535u16) { Logger.trace(["shadow", "_renderShadowDepth SKIP: depthProg compile failed"]); return }

                // 遍历场景几何体 submit（简化：复用 _collectRenderObjects 的几何体收集逻辑）
                let renderObjects = ArrayList<RenderObject>()
                this._collectShadowCasters(scene, renderObjects)
                Logger.trace(["shadow", "_renderShadowDepth casters.size=${renderObjects.size}"])
                let layout = backend._getOrCreateLayout()
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = backend._createVB(ro.geometry)
                    if (vb.idx == 65535u16) { Logger.trace(["shadow", "_renderShadowDepth caster SKIP: vb invalid geom=${ro.mesh.name}"]); continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(posAttr) =>
                            let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                            bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                            let ib = backend._createIB(ro.geometry)
                            if (ib.idx != 65535u16) {
                                bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                            }
                            bgfx_set_state_cj(depthState, 0x00000000u32)
                            bgfx_submit_cj(shadowViewId, depthProg, 0u32, 0xFFu8)
                            submitCnt += 1
                        case None => ()
                    }
                }
                Logger.trace(["shadow", "_renderShadowDepth done submitCnt=${submitCnt}"])
            case None => Logger.trace(["shadow", "_renderShadowDepth SKIP: depth shader not registered"])
        }
    }

    /**
     * @brief[zh-cn] VSM blur pass：对阴影深度图执行垂直+水平两个方向的 Gaussian-like blur
     * @explain[zh-cn] 对照参考版 ThreeRenderer.vsmBlurPass（2081-2128）：① 垂直 blur：输入 slot.vsmDepthTexture (D32) → 输出 slot.vsmPassFrameBuffer (RG16F pass)；② 水平 blur：输入 slot.vsmPassTexture (RG16F) → 输出 slot.vsmFinalFrameBuffer (RG16F final = slot.texture)。blur view ID = slot.baseViewId + 1
     * @param[zh-cn] slot 阴影槽
     *
     * @brief[en] VSM blur pass: execute vertical + horizontal Gaussian-like blur on shadow depth map
     * @explain[en] Corresponds to ThreeRenderer.vsmBlurPass (2081-2128): ① vertical blur: input slot.vsmDepthTexture (D32) → output slot.vsmPassFrameBuffer (RG16F pass); ② horizontal blur: input slot.vsmPassTexture (RG16F) → output slot.vsmFinalFrameBuffer (RG16F final = slot.texture). blur view ID = slot.baseViewId + 1
     * @param[en] slot Shadow slot
     */
    private func _vsmBlurPass(slot: ShadowSlot): Unit {
        let blurViewId = UInt16(UInt16(slot.baseViewId) + 1u16)
        let w = UInt16(slot.size)
        let h = UInt16(slot.size)
        Logger.trace(["shadow", "_vsmBlurPass ENTER blurViewId=${blurViewId} size=${slot.size}"])

        let vsmOpt = ShaderLibs.get("vsm")
        match (vsmOpt) {
            case None => Logger.trace(["shadow", "_vsmBlurPass SKIP: vsm shader not registered"]); return
            case Some(vsmSp) =>
                // 垂直变体（无 HORIZONTAL_PASS）
                if (vsmSp.programHandle.idx == 65535u16) {
                    vsmSp.compileBgfx()
                }
                let vProg = vsmSp.programHandle
                if (vProg.idx == 65535u16) { Logger.trace(["shadow", "_vsmBlurPass SKIP: vsm vertical compile failed"]); return }
                // 水平变体（HORIZONTAL_PASS=1）
                let hVariant = ShaderProgram.createVariant("vsm_h", vsmSp)
                let defStrings = ArrayList<String>()
                defStrings.add("HORIZONTAL_PASS=1")
                hVariant.compileBgfx(extraDefines: defStrings.toArray())
                let hProg = hVariant.programHandle
                if (hProg.idx == 65535u16) { Logger.trace(["shadow", "_vsmBlurPass SKIP: vsm horizontal compile failed"]); return }

                // 全屏四边形 VB（与 vsmVaryingDef 对齐：position + texcoord0）
                backend.blitQuad.ensureBlitVB()
                let uniforms = backend.uniforms
                let shadowSampler = uniforms.createUniform("s_shadowPass", UniformType.Sampler.value())
                let uResolution = uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                let uRadius = uniforms.createUniform("u_radius", UniformType.Vec4.value())
                let blurState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW

                // ── ① 垂直 blur：vsmDepthTexture → vsmPassFrameBuffer ──
                bgfx_set_view_rect_cj(blurViewId, 0u16, 0u16, w, h)
                bgfx_set_view_frame_buffer_cj(blurViewId, slot.vsmPassFrameBuffer)
                bgfx_set_view_clear_cj(blurViewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, 1.0f32, 0)
                bgfx_set_texture_cj(0u8, shadowSampler.value, slot.vsmDepthTexture, 0u32)
                let resMem = BgfxMemory(16u32)
                resMem.writeFloats([Float64(w), Float64(h), 0.0, 0.0], 4)
                bgfx_set_uniform_cj(uResolution.value, unsafe { CPointer<Unit>(resMem.data()) }, 1u16)
                let radMem = BgfxMemory(16u32)
                radMem.writeFloats([4.0, 0.0, 0.0, 0.0], 4)
                bgfx_set_uniform_cj(uRadius.value, unsafe { CPointer<Unit>(radMem.data()) }, 1u16)
                match (backend.blitQuad._blitVB) {
                    case Some(vb) =>
                        match (backend.blitQuad._blitIB) {
                            case Some(ib) =>
                                match (backend.blitQuad._blitLayout) {
                                    case Some(layout) =>
                                        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)
                                        bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                                        bgfx_set_state_cj(blurState, 0x00000000u32)
                                        bgfx_submit_cj(blurViewId, vProg, 0u32, 0xFFu8)
                                        Logger.trace(["shadow", "_vsmBlurPass vertical submit done"])

                                        // ── ② 水平 blur：vsmPassTexture → vsmFinalFrameBuffer ──
                                        bgfx_set_view_frame_buffer_cj(blurViewId, slot.vsmFinalFrameBuffer)
                                        bgfx_set_view_clear_cj(blurViewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, 1.0f32, 0)
                                        bgfx_set_texture_cj(0u8, shadowSampler.value, slot.vsmPassTexture, 0u32)
                                        // resolution/radius 不变（同一帧 blur 参数固定）
                                        bgfx_set_state_cj(blurState, 0x00000000u32)
                                        bgfx_submit_cj(blurViewId, hProg, 0u32, 0xFFu8)
                                        Logger.trace(["shadow", "_vsmBlurPass horizontal submit done"])
                                    case None => Logger.trace(["shadow", "_vsmBlurPass SKIP: blitLayout None"])
                                }
                            case None => Logger.trace(["shadow", "_vsmBlurPass SKIP: blitIB None"])
                        }
                    case None => Logger.trace(["shadow", "_vsmBlurPass SKIP: blitVB None"])
                }
        }
    }

    // ===== 聚光灯阴影 =====

    /**
     * @brief[zh-cn] 渲染聚光灯阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderSpotShadowMap：用 SpotLightShadow.camera（PerspectiveCamera）从光源视角渲染深度到阴影 framebuffer，按 SpotLight.id 分配独立 FB。与方向光阴影的区别：shadowCamera 是 PerspectiveCamera，需调 SpotLightShadow.updateMatrices(light)
     * @param[zh-cn] light 聚光灯（含 shadow.camera 透视相机 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render spot light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderSpotShadowMap: renders depth from light perspective using SpotLightShadow.camera (PerspectiveCamera) to shadow framebuffer, allocates independent FB per SpotLight.id. Difference from directional light: shadowCamera is PerspectiveCamera, needs SpotLightShadow.updateMatrices(light)
     * @param[en] light Spot light (with shadow.camera perspective camera + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    public func renderSpotShadowMap(light: SpotLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        Logger.trace(["shadow", "renderSpotShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)

        var slot = match (this._shadowResources.get(lightId)) {
            case Some(s) =>
                if (s.size != shadowSize) {
                    this._destroySlot(s)
                    let fresh = ShadowSlot()
                    fresh.size = shadowSize
                    this._shadowResources.add(lightId, fresh)
                    fresh
                } else {
                    s
                }
            case None =>
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                this._shadowResources.add(lightId, fresh)
                fresh
        }

        if (slot.texture.idx == 65535u16) {
            let depthTex = bgfx_create_texture_2d_cj(
                UInt16(shadowSize), UInt16(shadowSize), false, 1u16,
                TextureFormat.D24.value(),
                TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL) |
                    UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP),
                CPointer<Memory>())
            slot.texture = depthTex
            let handlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
            unsafe { handlesHolder.get().write(0, depthTex) }
            slot.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(1u8, handlesHolder.get(), true)
            handlesHolder.dispose()
            Logger.trace(["shadow", "spot created shadowFB(D24) idx=${slot.frameBuffer.idx} size=${shadowSize}"])
        }

        slot.baseViewId = this._allocShadowViewId()
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "spot")
        // per-light bias/normalBias（来自 light.shadow，主 pass 绑 u_spotShadowParams[i]）
        slot.bias = light.shadow.bias
        slot.normalBias = light.shadow.normalBias

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染聚光灯深度 pass（内部计算 slot.shadowMatrix = bias × lightViewProj）
        this._renderSpotShadowDepth(light, scene, slot)

        // 缓存聚光灯主 pass 绑定所需的 bias 矩阵（即 shader 期望的 spotLightMatrix[i]）
        let biasMtx = Matrix4().set(
            0.5, 0.0, 0.0, 0.5,
            0.0, -0.5, 0.0, 0.5,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        )
        slot.shadowMatrix = biasMtx.multiply(slot.shadowMatrix)
    }

    /**
     * @brief[zh-cn] 渲染聚光灯阴影深度到指定 framebuffer
     * @explain[zh-cn] 对照 _renderShadowDepth 但用 SpotLightShadow.camera（PerspectiveCamera），并调 SpotLightShadow.updateMatrices(light) 确保 camera 位置/朝向/projectionMatrix 已 update
     * @param[zh-cn] light 聚光灯
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render spot light shadow depth to specified framebuffer
     * @explain[en] Corresponds to _renderShadowDepth but uses SpotLightShadow.camera (PerspectiveCamera), and calls SpotLightShadow.updateMatrices(light) to ensure camera position/orientation/projectionMatrix are updated
     * @param[en] light Spot light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderSpotShadowDepth(light: SpotLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let shadowViewId = slot.baseViewId
        let fb = slot.frameBuffer
        let shadowCamera = light.shadow.camera
        Logger.trace(["shadow", "_renderSpotShadowDepth ENTER shadowViewId=${shadowViewId} fb.idx=${fb.idx} shadowSize=${shadowSize}"])

        bgfx_set_view_rect_cj(shadowViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
        bgfx_set_view_frame_buffer_cj(shadowViewId, fb)

        // 关键：调 SpotLightShadow.updateMatrices(light) 确保 camera 位置/朝向/projectionMatrix 已 update
        // （SpotLightShadow 的 updateMatrices 会按 light.position/target/angle/focus 自动调整 PerspectiveCamera）
        light.shadow.updateMatrices(light)

        // 从光源视角设置 view/proj 矩阵：用 shadowCamera 自己的 matrixWorldInverse + projectionMatrix
        let lightView = shadowCamera.matrixWorldInverse
        let lightProj = shadowCamera.projectionMatrix
        let viewArr = lightView.toArray(Array<Float64>(16, { _ => 0.0 }))
        let projArr = lightProj.toArray(Array<Float64>(16, { _ => 0.0 }))
        backend._setViewTransform(shadowViewId, viewArr, projArr)

        // 计算阴影矩阵（lightViewProj → 用于主 pass 的阴影坐标变换）
        let lightViewProj = lightProj.clone().multiply(lightView)
        slot.shadowMatrix = lightViewProj

        // 渲染深度 pass：遍历场景几何体用 depth shader submit
        bgfx_set_view_clear_cj(shadowViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
        let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                         BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

        let depthProgOpt = ShaderLibs.get("depth")
        match (depthProgOpt) {
            case Some(depthSp) =>
                if (depthSp.programHandle.idx == 65535u16) {
                    depthSp.compileBgfx()
                }
                let depthProg = depthSp.programHandle
                if (depthProg.idx == 65535u16) { return }

                let renderObjects = ArrayList<RenderObject>()
                this._collectShadowCasters(scene, renderObjects)
                let layout = backend._getOrCreateLayout()
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    let vb = backend._createVB(ro.geometry)
                    if (vb.idx == 65535u16) { continue }
                    let posAttrOpt = ro.geometry.getAttribute("position")
                    match (posAttrOpt) {
                        case Some(posAttr) =>
                            let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                            let mtxMem = BgfxMemory(64u32)
                            mtxMem.writeFloats(mtxArr, 16)
                            bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                            bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                            let ib = backend._createIB(ro.geometry)
                            if (ib.idx != 65535u16) {
                                bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                            }
                            bgfx_set_state_cj(depthState, 0x00000000u32)
                            bgfx_submit_cj(shadowViewId, depthProg, 0u32, 0xFFu8)
                            submitCnt += 1
                        case None => ()
                    }
                }
                Logger.trace(["shadow", "_renderSpotShadowDepth done submitCnt=${submitCnt}"])
            case None => ()
        }
    }

    // ===== 点光源阴影（cube） =====

    /**
     * @brief[zh-cn] 渲染点光源阴影贴图（预 pass）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderPointShadowMap：点光源阴影是立方体贴图（6 个面），每面独立 view ID，主 pass 采样 cube shadow map（pointShadowMap sampler，cube 采样方向 = normalize(worldPos - lightPos)）
     * @param[zh-cn] light 点光源（含 shadow.camera PerspectiveCamera fov=90 + shadow.mapSize）
     * scene 场景（收集 caster 几何体）
     *
     * @brief[en] Render point light shadow map (pre-pass)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderPointShadowMap: point light shadow is a cube map (6 faces), each face has independent view ID, main pass samples cube shadow map (pointShadowMap sampler, cube sample direction = normalize(worldPos - lightPos))
     * @param[en] light Point light (with shadow.camera PerspectiveCamera fov=90 + shadow.mapSize)
     * scene Scene (collects caster geometry)
     */
    public func renderPointShadowMap(light: PointLight, scene: Scene): Unit {
        let shadowSize = Int64(light.shadow.mapSize.x)
        Logger.trace(["shadow", "renderPointShadowMap ENTER shadowSize=${shadowSize} lightId=${light.id}"])
        let lightId = Int64(light.id)

        var slot = match (this._shadowResources.get(lightId)) {
            case Some(s) =>
                if (s.size != shadowSize) {
                    this._destroySlot(s)
                    let fresh = ShadowSlot()
                    fresh.size = shadowSize
                    fresh.isCube = true
                    this._shadowResources.add(lightId, fresh)
                    fresh
                } else {
                    s
                }
            case None =>
                let fresh = ShadowSlot()
                fresh.size = shadowSize
                fresh.isCube = true
                this._shadowResources.add(lightId, fresh)
                fresh
        }

        // 创建 cube 阴影纹理（6 face cube）+ 6 个 face framebuffer
        if (slot.texture.idx == 65535u16) {
            // cube 纹理用 TextureFormat.D24S8（D24 在某些后端 cube 路径不稳，参考项目用 D24S8）
            // + TEXTURE_RT（render target）+ SAMPLER_COMPARE_LEQUAL（硬件深度比较）
            // 注意：cube 纹理不能加 SAMPLER_U_CLAMP|SAMPLER_V_CLAMP（cube 无 UV wrap 概念）
            let cubeFlags = TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_COMPARE_LEQUAL)
            let cubeTex = bgfx_create_texture_cube_cj(
                UInt16(shadowSize), false, 1u16,
                TextureFormat.D24S8.value(), cubeFlags, CPointer<Memory>())
            slot.texture = cubeTex
            // 为每个 face（0-5）创建独立 framebuffer：Attachment(cubeTex, Write, layer=faceIdx)
            for (faceIdx in 0..6) {
                let atHolder = AutoFreePtr<Attachment>(unsafe { LibC.malloc<Attachment>(count: 1i64) })
                let at = atHolder.get()
                bgfx_attachment_init_cj(at, cubeTex, 0u32, UInt16(faceIdx), 1u16, 0u16, 0u8)
                let faceFb = bgfx_create_frame_buffer_from_attachment_cj(1u8, at, false)
                atHolder.dispose()
                slot.faceFrameBuffers.add(faceFb)
                Logger.trace(["shadow", "point cube face ${faceIdx} fb.idx=${faceFb.idx}"])
            }
            // frameBuffer 保留为第 0 个 face 的 fb（兼容性占位；实际按 faceFrameBuffers 索引）
            slot.frameBuffer = slot.faceFrameBuffers[0]
            Logger.trace(["shadow", "point created cube shadowFB(D24S8) tex.idx=${cubeTex.idx} size=${shadowSize}"])
        }

        // cube 阴影占 6 个连续 view ID
        slot.baseViewId = this._allocShadowViewId(count: 6)
        this._shadowSlots.add(lightId, slot)
        this._shadowSlotKind.add(lightId, "point")
        // per-light bias（来自 light.shadow，主 pass 绑 u_pointShadowParams[i]）
        slot.bias = light.shadow.bias

        // 缓存点光源世界坐标（主 pass 绑定 u_pointShadowLightPos[i] 用）+ near/far（u_pointShadowNearFar[i]）
        slot.lightPos = light.position.clone()
        match (light.shadow.camera as PerspectiveCamera) {
            case Some(persp) =>
                slot.near = persp.near
                slot.far = persp.far
            case None => ()
        }

        if (slot.frameBuffer.idx == 65535u16) { return }

        // 渲染 6 个 face 的深度 pass
        this._renderPointShadowDepth(light, scene, slot)
    }

    /**
     * @brief[zh-cn] 渲染点光源阴影深度到 cube 纹理的 6 个 face
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.renderPointShadowMap。关键：cube 阴影采样方向 = normalize(worldPos - lightPos)，故每个 face 用 PerspectiveCamera(fov=90) 从光源位置朝 6 个轴向渲染
     * @param[zh-cn] light 点光源
     * scene 场景
     * slot 阴影槽
     *
     * @brief[en] Render point light shadow depth to 6 faces of cube texture
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.renderPointShadowMap. Key: cube shadow sample direction = normalize(worldPos - lightPos), so each face uses PerspectiveCamera(fov=90) to render from light position towards 6 axis directions
     * @param[en] light Point light
     * scene Scene
     * slot Shadow slot
     */
    private func _renderPointShadowDepth(light: PointLight, scene: Scene, slot: ShadowSlot): Unit {
        let shadowSize = slot.size
        let baseViewId = slot.baseViewId
        let lightPos = slot.lightPos
        Logger.trace(["shadow", "_renderPointShadowDepth ENTER baseViewId=${baseViewId} lightPos=${lightPos.x},${lightPos.y},${lightPos.z}"])

        let faceDirs: Array<Vector3> = [
            Vector3(1.0, 0.0, 0.0),    // face 0: +X
            Vector3(-1.0, 0.0, 0.0),   // face 1: -X
            Vector3(0.0, 1.0, 0.0),    // face 2: +Y
            Vector3(0.0, -1.0, 0.0),   // face 3: -Y
            Vector3(0.0, 0.0, 1.0),    // face 4: +Z
            Vector3(0.0, 0.0, -1.0)    // face 5: -Z
        ]
        // D3D11 cube face 约定（MSDN）：每个 face 的 s（right）与 t（up）方向
        //   face 0 (+X): s=-z, t=-y   face 1 (-X): s=+z, t=-y
        //   face 2 (+Y): s=+x, t=+z   face 3 (-Y): s=+x, t=-z
        //   face 4 (+Z): s=+x, t=-y   face 5 (-Z): s=-x, t=-y
        // 手动构造 view 矩阵（right/up/dir 列向量），绕开 lookAt 的左手系手性差异：
        // Three.cj 左手系 lookAt 的 x = cross(up, z) 与 D3D11 的 s 方向相反 →
        // 渲染内容左右镜像（左上↔右下）。用 D3D11 约定直接构建即可严格对齐 bgfx cube 采样方向。
        let faceRights: Array<Vector3> = [
            Vector3(0.0, 0.0, -1.0),   // +X: right = -Z
            Vector3(0.0, 0.0, 1.0),    // -X: right = +Z
            Vector3(1.0, 0.0, 0.0),    // +Y: right = +X
            Vector3(1.0, 0.0, 0.0),    // -Y: right = +X
            Vector3(1.0, 0.0, 0.0),    // +Z: right = +X
            Vector3(-1.0, 0.0, 0.0)    // -Z: right = -X
        ]
        let faceUps: Array<Vector3> = [
            Vector3(0.0, 1.0, 0.0),    // +X: up = +Y
            Vector3(0.0, 1.0, 0.0),    // -X: up = +Y
            Vector3(0.0, 0.0, -1.0),   // +Y: up = -Z
            Vector3(0.0, 0.0, 1.0),    // -Y: up = +Z
            Vector3(0.0, 1.0, 0.0),    // +Z: up = +Y
            Vector3(0.0, 1.0, 0.0)     // -Z: up = +Y
        ]

        for (faceIdx in 0..6) {
            let faceViewId = UInt16(UInt16(baseViewId) + UInt16(faceIdx))
            let fb = slot.faceFrameBuffers[faceIdx]
            Logger.trace(["shadow", "_renderPointShadowDepth face ${faceIdx} viewId=${faceViewId} fb.idx=${fb.idx}"])

            bgfx_set_view_rect_cj(faceViewId, 0u16, 0u16, UInt16(shadowSize), UInt16(shadowSize))
            bgfx_set_view_frame_buffer_cj(faceViewId, fb)

            // 关键修复①：near/far 必须与主 pass 绑定的 u_pointShadowNearFar 一致
            // （slot.near/slot.far 已在 renderPointShadowMap 中从 light.shadow.camera 读取）。
            // 旧实现硬编码 near=0.5, far=30，而 PointLightShadow 默认 far=500 →
            // getPointShadow 用 far=500 重构 dp，与 far=30 渲染的深度贴图不匹配 → 阴影形状错乱。
            // 关键修复②：手动构造 view 矩阵（D3D11 cube face 约定），不用 lookAt——
            // Three.cj 左手系 lookAt 的 x = cross(up, z) 使渲染内容左右镜像。
            let dir = faceDirs[faceIdx]
            let right = faceRights[faceIdx]
            let up = faceUps[faceIdx]
            let viewMtx = Matrix4().set(
                right.x, right.y, right.z, -right.dot(lightPos),
                up.x,    up.y,    up.z,    -up.dot(lightPos),
                dir.x,   dir.y,   dir.z,   -dir.dot(lightPos),
                0.0, 0.0, 0.0, 1.0
            )
            // 投影：fov=90 透视（左手系，与 view 匹配）
            let shadowCamera = PerspectiveCamera(fov: 90.0, aspect: 1.0, near: slot.near, far: slot.far)
            shadowCamera.updateProjectionMatrix()
            Logger.trace(["shadow", "_renderPointShadowDepth face ${faceIdx} camPos=${lightPos.x},${lightPos.y},${lightPos.z} dir=${dir.x},${dir.y},${dir.z}"])

            let lightView = viewMtx
            let lightProj = shadowCamera.projectionMatrix
            let viewArr = lightView.toArray(Array<Float64>(16, { _ => 0.0 }))
            let projArr = lightProj.toArray(Array<Float64>(16, { _ => 0.0 }))
            backend._setViewTransform(faceViewId, viewArr, projArr)

            bgfx_set_view_clear_cj(faceViewId, CLEAR_COLOR | CLEAR_DEPTH, 0x00000000u32, 1.0f32, 0)
            let depthState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.WRITE_Z |
                             BgfxConstants.DEPTH_TEST_LESS | BgfxConstants.FRONT_CCW

            let depthProgOpt = ShaderLibs.get("depth")
            match (depthProgOpt) {
                case Some(depthSp) =>
                    if (depthSp.programHandle.idx == 65535u16) {
                        depthSp.compileBgfx()
                    }
                    let depthProg = depthSp.programHandle
                    if (depthProg.idx == 65535u16) { continue }

                    let renderObjects = ArrayList<RenderObject>()
                    this._collectShadowCasters(scene, renderObjects)
                    let layout = backend._getOrCreateLayout()
                    var submitCnt: Int64 = 0
                    for (ro in renderObjects) {
                        let vb = backend._createVB(ro.geometry)
                        if (vb.idx == 65535u16) { continue }
                        let posAttrOpt = ro.geometry.getAttribute("position")
                        match (posAttrOpt) {
                            case Some(posAttr) =>
                                let mtxArr = ro.worldMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                                let mtxMem = BgfxMemory(64u32)
                                mtxMem.writeFloats(mtxArr, 16)
                                bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxMem.data()) }, 1u16)
                                bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, UInt32(posAttr.count), layout)
                                let ib = backend._createIB(ro.geometry)
                                if (ib.idx != 65535u16) {
                                    bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                                }
                                bgfx_set_state_cj(depthState, 0x00000000u32)
                                bgfx_submit_cj(faceViewId, depthProg, 0u32, 0xFFu8)
                                submitCnt += 1
                            case None => ()
                        }
                    }
                    Logger.trace(["shadow", "_renderPointShadowDepth face ${faceIdx} done submitCnt=${submitCnt}"])
                case None => ()
            }
        }
        Logger.trace(["shadow", "_renderPointShadowDepth ALL 6 faces done"])
    }

    // ===== 阴影辅助方法 =====

    /**
     * @brief[zh-cn] 销毁一个 ShadowSlot 持有的所有 GPU 资源（framebuffer + 纹理 + cube face framebuffer + VSM 链）
     * @param[zh-cn] slot 阴影槽
     *
     * @brief[en] Destroy all GPU resources held by a ShadowSlot (framebuffer + texture + cube face framebuffers + VSM chain)
     * @param[en] slot Shadow slot
     */
    public func _destroySlot(slot: ShadowSlot): Unit {
        if (slot.isCube) {
            // cube：frameBuffer 与 faceFrameBuffers[0] 同句柄，避免重复销毁
            slot.frameBuffer.idx = 0xFFFFu16
        }
        for (faceFb in slot.faceFrameBuffers) {
            if (faceFb.idx != 0xFFFFu16) {
                bgfx_destroy_frame_buffer_cj(faceFb)
            }
        }
        slot.faceFrameBuffers.clear()
        // VSM 链：vsmDepthTexture / vsmPassTexture / vsmPassFrameBuffer / vsmFinalFrameBuffer
        // 注意 slot.frameBuffer（D32 深度 FB）与 slot.texture（RG16F final）由下方统一销毁，
        // vsm 链的额外 FB（pass/final）与 vsmDepthTexture/vsmPassTexture 是独立句柄需单独释放
        if (slot.vsmPassFrameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.vsmPassFrameBuffer)
            slot.vsmPassFrameBuffer.idx = 0xFFFFu16
        }
        if (slot.vsmFinalFrameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.vsmFinalFrameBuffer)
            slot.vsmFinalFrameBuffer.idx = 0xFFFFu16
        }
        if (slot.vsmDepthTexture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.vsmDepthTexture)
            slot.vsmDepthTexture.idx = 0xFFFFu16
        }
        if (slot.vsmPassTexture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.vsmPassTexture)
            slot.vsmPassTexture.idx = 0xFFFFu16
        }
        if (slot.frameBuffer.idx != 0xFFFFu16) {
            bgfx_destroy_frame_buffer_cj(slot.frameBuffer)
            slot.frameBuffer.idx = 0xFFFFu16
        }
        if (slot.texture.idx != 0xFFFFu16) {
            bgfx_destroy_texture_cj(slot.texture)
            slot.texture.idx = 0xFFFFu16
        }
    }

    /**
     * @brief[zh-cn] 为新的阴影光源分配 view ID 段
     * @param[zh-cn] count 该光源占用的 view ID 数（2D 阴影=1，cube 阴影=6）
     * @return[zh-cn] 起始 view ID
     *
     * @brief[en] Allocate view ID segment for a new shadow light
     * @param[en] count Number of view IDs this light occupies (2D shadow=1, cube shadow=6)
     * @return[en] Starting view ID
     */
    public func _allocShadowViewId(count!: Int64 = 1): UInt16 {
        let base = this._nextShadowViewId
        this._nextShadowViewId = UInt16(UInt16(this._nextShadowViewId) + UInt16(count))
        return base
    }

    /**
     * @brief[zh-cn] 递归收集场景中所有 castShadow 的 Mesh 几何体作为阴影 caster
     * @explain[zh-cn] 对照 bgfx4cj-last collectRenderObjects：当前简化为收集所有 Mesh（不区分 castShadow 标志，因 Light 基类无 castShadow 字段，默认所有几何体都参与阴影深度 pass）
     * @param[zh-cn] obj 场景对象
     * renderObjects 渲染对象列表
     *
     * @brief[en] Recursively collect all castShadow Mesh geometry in the scene as shadow casters
     * @explain[en] Corresponds to bgfx4cj-last collectRenderObjects: currently simplified to collect all Meshes (no castShadow flag distinction, as Light base class has no castShadow field, all geometry participates in shadow depth pass by default)
     * @param[en] obj Scene object
     * renderObjects Render object list
     */
    public func _collectShadowCasters(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectShadowCasters(child, renderObjects)
            }
            // 关键：仓颉 `match (child as Mesh)` 的运行时 cast 检查对 Mesh 子类不生效
            // （GroundPlane/FloatingCube 的 kind=Mesh 但 cast 不匹配 → casters.size=0 → blit 空 = 黑）
            // 改用 kind 字段判断（对照 Renderer._collectRenderObjects 既有风格），
            // 然后用 match (child as Mesh) 解构 Option<Mesh> 拿 Mesh 实例（child.kind=Mesh 已保证安全）。
            if (child.kind == "Mesh") {
                match (child as Mesh) {
                    case Some(mesh) =>
                        // Mesh.material 字段类型是 Material（非 Option<Material>），直接用
                        let ro = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        renderObjects.add(ro)
                        Logger.trace(["shadow", "_collectShadowCasters ADD caster name=${mesh.name}"])
                    case None => Logger.trace(["shadow", "_collectShadowCasters cast FAILED kind=${child.kind}"])
                }
            }
        }
    }

    // ===== 主 pass 阴影 uniform 绑定 =====

    /**
     * @brief[zh-cn] 绑定阴影 uniform 到主 pass draw（在 _drawRenderObject 中调用）
     * @explain[zh-cn] 对照 bgfx4cj-last ThreeRenderer.draw 行 788-819 + bindMultiSpotShadows/bindMultiPointShadows：directionalShadowMap 纹理绑定到 sampler stage 0..numDir-1，spotShadowMap 纹理绑定到 sampler stage numDir..，pointShadowMap 纹理绑定到 sampler stage numDir+numSpot..，各 ShadowMatrix = bias × lightViewProj。关键修复：原实现仅绑定方向光阴影，聚光灯/点光源阴影贴图从未被采样 → 无阴影
     *
     * @brief[en] Bind shadow uniforms to main pass draw (called in _drawRenderObject)
     * @explain[en] Corresponds to bgfx4cj-last ThreeRenderer.draw lines 788-819 + bindMultiSpotShadows/bindMultiPointShadows: directionalShadowMap texture bound to sampler stage 0..numDir-1, spotShadowMap to stage numDir.., pointShadowMap to stage numDir+numSpot.., each ShadowMatrix = bias × lightViewProj. Key fix: original implementation only bound directional light shadows, spot/point light shadow maps were never sampled → no shadows
     */
    public func bindShadowUniforms(): Unit {
        // 多光源阴影支持：按当前帧 _shadowSlots 逐光源绑定数组化 uniform。
        // shader 端已数组化（uniform sampler2DShadow directionalShadowMap[NUM_DIR_LIGHT_SHADOWS] 等），
        // bgfx 数组 uniform 绑定方式（对照 u_pointPosition[4] 先例）：
        //   - 数组 uniform（mat4/vec4）：createUniform(name, type, num) 一次创建 + setUniform 一次传整个数组
        //   - 数组 sampler：createUniform(name, Sampler, num) 一次创建 + setTexture(stage, uniform, tex) 按 stage 逐个绑定
        // 注意：数组 sampler 的 stage 从 0 起连续分配（bgfx 按声明顺序分配寄存器），
        // 故 directional/spot/point 三类阴影 sampler 的 stage 段必须互不重叠：
        //   directional: stage 0..numDir-1
        //   spot:        stage 4..4+numSpot-1（预留 4 个）
        //   point(cube): stage 8..8+numPoint-1（预留 8 个）
        // 对应 uniform 数组：directionalShadowMatrix[i] / spotLightMatrix[i] / pointShadowMatrix[i]
        //   + u_pointShadowLightPos[i] / u_pointShadowNearFar[i]
        //
        // 旧实现仅绑定方向光阴影，聚光灯/点光源阴影贴图从未被采样 → 无阴影。
        // 现按三类光源独立 framebuffer（_shadowFB/_spotShadowFB/_pointShadowFB）分别绑定。

        // bias 矩阵：NDC [-1,1] → 纹理 UV [0,1]，D3D11 Y-flip 风格（-0.5）。
        let biasMtx = Matrix4().set(
            0.5, 0.0, 0.0, 0.5,
            0.0, -0.5, 0.0, 0.5,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        )
        let cmpFlags = BgfxConstants.SAMPLER_COMPARE_LEQUAL | BgfxConstants.SAMPLER_MIN_ANISOTROPIC | BgfxConstants.SAMPLER_MAG_ANISOTROPIC

        // 收集三类阴影光源的 slot（按 lightId 排序保证帧间一致）
        let dirSlots = ArrayList<ShadowSlot>()
        let spotSlots = ArrayList<ShadowSlot>()
        let pointSlots = ArrayList<ShadowSlot>()
        let lightIds = ArrayList<Int64>()
        for ((lid, _) in this._shadowSlots) {
            lightIds.add(lid)
        }
        // 排序（升序）
        for (i in 0..lightIds.size) {
            for (j in i + 1..lightIds.size) {
                if (lightIds[j] < lightIds[i]) {
                    let tmp = lightIds[i]
                    lightIds[i] = lightIds[j]
                    lightIds[j] = tmp
                }
            }
        }
        for (lid in lightIds) {
            match (this._shadowSlots.get(lid)) {
                case Some(slot) =>
                    // 区分类型：cube → point；2D 中按 texture 是否带 cube 标记再次区分
                    if (slot.isCube) {
                        pointSlots.add(slot)
                    } else {
                        // 这里无法直接区分 directional/spot，需通过 _shadowSlotKind 查询
                        match (this._shadowSlotKind.get(lid)) {
                            case Some("dir") => dirSlots.add(slot)
                            case Some("spot") => spotSlots.add(slot)
                            case _ => dirSlots.add(slot)
                        }
                    }
                case None => ()
            }
        }

        let uniforms = backend.uniforms

        // ===== 1. 方向光阴影（数组 sampler stage 0..numDir-1 + 数组 uniform directionalShadowMatrix）=====
        if (dirSlots.size > 0) {
            let numDir = UInt16(dirSlots.size)
            // VSM：RG16F mean/variance 纹理用普通采样（texture2D 读 .rg，无比较），
            // 与 PCF/BASIC 的 D24 比较采样器（shadow2D 硬件比较）区分。
            let isVsm = backend.shadowMap.getShadowType() == VSM_SHADOW_MAP
            let dirFlags = if (isVsm) {
                UInt32(SAMPLER_U_CLAMP) | UInt32(SAMPLER_V_CLAMP)
            } else {
                cmpFlags
            }
            // 数组 sampler：一次创建，逐 stage 绑定（dir 从 stage 0 起）
            let shadowSampler = uniforms.createUniform("directionalShadowMap", UniformType.Sampler.value(), numDir)
            for (i in 0..dirSlots.size) {
                bgfx_set_texture_cj(UInt8(UInt32(i)), shadowSampler.value, dirSlots[i].texture, dirFlags)
            }
            // 数组 uniform：一次 setUniform 传整个数组（bias × lightViewProj）
            let uShadowMatrix = uniforms.createUniform("directionalShadowMatrix", UniformType.Mat4.value(), numDir)
            let smMem = BgfxMemory(UInt32(dirSlots.size * 64))
            for (i in 0..dirSlots.size) {
                let shadowMtx = biasMtx.multiply(dirSlots[i].shadowMatrix)
                let smArr = shadowMtx.toArray(Array<Float64>(16, { _ => 0.0 }))
                for (k in 0..16) { smMem.writeFloat(Int64(i * 16 + k), Float32(smArr[k])) }
            }
            bgfx_set_uniform_cj(uShadowMatrix.value, unsafe { CPointer<Unit>(smMem.data()) }, numDir)
            // per-light bias/normalBias（对齐 three.js light.shadow.bias/normalBias）：
            // x=bias, y=normalBias（vertex 端法线偏移用，方向光接缝靠 normalBias 而非 depth bias）
            let uDirP = uniforms.createUniform("u_dirShadowParams", UniformType.Vec4.value(), numDir)
            let dirPMem = BgfxMemory(UInt32(dirSlots.size * 16))
            for (i in 0..dirSlots.size) {
                dirPMem.writeFloat(Int64(i * 4 + 0), Float32(dirSlots[i].bias))
                dirPMem.writeFloat(Int64(i * 4 + 1), Float32(dirSlots[i].normalBias))
                dirPMem.writeFloat(Int64(i * 4 + 2), 0.0f32)
                dirPMem.writeFloat(Int64(i * 4 + 3), 0.0f32)
            }
            bgfx_set_uniform_cj(uDirP.value, unsafe { CPointer<Unit>(dirPMem.data()) }, numDir)
        }

        // ===== 2. 聚光灯阴影（数组 sampler stage numDir..numDir+numSpot-1 + 数组 uniform spotLightMatrix）=====
        // stage 顺延：dir 占 0..numDir-1，spot 从 numDir 起（D3D11 纹理单元上限 16）
        if (spotSlots.size > 0) {
            let numSpot = UInt16(spotSlots.size)
            let spotStageBase = dirSlots.size
            let spotSampler = uniforms.createUniform("spotShadowMap", UniformType.Sampler.value(), numSpot)
            for (i in 0..spotSlots.size) {
                bgfx_set_texture_cj(UInt8(UInt32(spotStageBase) + UInt32(i)), spotSampler.value, spotSlots[i].texture, cmpFlags)
            }
            // spotLightMatrix（已在 renderSpotShadowMap 内预乘 bias）
            let uSM = uniforms.createUniform("spotLightMatrix", UniformType.Mat4.value(), numSpot)
            let smMem = BgfxMemory(UInt32(spotSlots.size * 64))
            for (i in 0..spotSlots.size) {
                let smArr = spotSlots[i].shadowMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                for (k in 0..16) { smMem.writeFloat(Int64(i * 16 + k), Float32(smArr[k])) }
            }
            bgfx_set_uniform_cj(uSM.value, unsafe { CPointer<Unit>(smMem.data()) }, numSpot)
            // per-light bias/normalBias（对齐 three.js light.shadow.bias/normalBias）
            let uSpotP = uniforms.createUniform("u_spotShadowParams", UniformType.Vec4.value(), numSpot)
            let spotPMem = BgfxMemory(UInt32(spotSlots.size * 16))
            for (i in 0..spotSlots.size) {
                spotPMem.writeFloat(Int64(i * 4 + 0), Float32(spotSlots[i].bias))
                spotPMem.writeFloat(Int64(i * 4 + 1), Float32(spotSlots[i].normalBias))
                spotPMem.writeFloat(Int64(i * 4 + 2), 0.0f32)
                spotPMem.writeFloat(Int64(i * 4 + 3), 0.0f32)
            }
            bgfx_set_uniform_cj(uSpotP.value, unsafe { CPointer<Unit>(spotPMem.data()) }, numSpot)
        }

        // ===== 3. 点光源阴影（数组 cube sampler stage numDir+numSpot.. + 数组 uniform）=====
        // stage 顺延：dir 占 0..numDir-1，spot 占 numDir..numDir+numSpot-1，point 从 numDir+numSpot 起
        if (pointSlots.size > 0) {
            let numPoint = UInt16(pointSlots.size)
            let pointStageBase = dirSlots.size + spotSlots.size
            // 绑定 cube 纹理本身（不是 face framebuffer 的 get_texture 结果）
            let pointSampler = uniforms.createUniform("pointShadowMap", UniformType.Sampler.value(), numPoint)
            for (i in 0..pointSlots.size) {
                Logger.trace(["shadow", "bindShadowUniforms POINT[${i}] cubeTex.idx=${pointSlots[i].texture.idx} stage=${pointStageBase + i}"])
                bgfx_set_texture_cj(UInt8(UInt32(pointStageBase) + UInt32(i)), pointSampler.value, pointSlots[i].texture, cmpFlags)
            }

            // u_pointShadowLightPos 数组（fragment 端算 worldPos - lightPos[i] 时需要）
            let uPLP = uniforms.createUniform("u_pointShadowLightPos", UniformType.Vec4.value(), numPoint)
            let plpMem = BgfxMemory(UInt32(pointSlots.size * 16))
            for (i in 0..pointSlots.size) {
                plpMem.writeFloat(Int64(i * 4 + 0), Float32(pointSlots[i].lightPos.x))
                plpMem.writeFloat(Int64(i * 4 + 1), Float32(pointSlots[i].lightPos.y))
                plpMem.writeFloat(Int64(i * 4 + 2), Float32(pointSlots[i].lightPos.z))
                plpMem.writeFloat(Int64(i * 4 + 3), 0.0f32)
            }
            bgfx_set_uniform_cj(uPLP.value, unsafe { CPointer<Unit>(plpMem.data()) }, numPoint)

            // u_pointShadowNearFar 数组（fragment 端 getPointShadow 深度重构用）
            let uPNF = uniforms.createUniform("u_pointShadowNearFar", UniformType.Vec4.value(), numPoint)
            let pnfMem = BgfxMemory(UInt32(pointSlots.size * 16))
            for (i in 0..pointSlots.size) {
                pnfMem.writeFloat(Int64(i * 4 + 0), Float32(pointSlots[i].near))
                pnfMem.writeFloat(Int64(i * 4 + 1), Float32(pointSlots[i].far))
                pnfMem.writeFloat(Int64(i * 4 + 2), 0.0f32)
                pnfMem.writeFloat(Int64(i * 4 + 3), 0.0f32)
            }
            bgfx_set_uniform_cj(uPNF.value, unsafe { CPointer<Unit>(pnfMem.data()) }, numPoint)
            // per-light bias（对齐 three.js light.shadow.bias）：x=bias
            let uPointP = uniforms.createUniform("u_pointShadowParams", UniformType.Vec4.value(), numPoint)
            let pointPMem = BgfxMemory(UInt32(pointSlots.size * 16))
            for (i in 0..pointSlots.size) {
                pointPMem.writeFloat(Int64(i * 4 + 0), Float32(pointSlots[i].bias))
                pointPMem.writeFloat(Int64(i * 4 + 1), 0.0f32)
                pointPMem.writeFloat(Int64(i * 4 + 2), 0.0f32)
                pointPMem.writeFloat(Int64(i * 4 + 3), 0.0f32)
            }
            bgfx_set_uniform_cj(uPointP.value, unsafe { CPointer<Unit>(pointPMem.data()) }, numPoint)
        }

        // ===== 4. 全局阴影参数（三类光源共用）=====
        // shadowParams: x=intensity, y=bias, z=normalBias, w=radius
        // 注意：PcfVizMaterial 的 "pcf" 调试 shader（ShaderLibs 16c）仍在读 shadowParams.y/z
        // 作为 bias/threshold（pcf shader 自注释"用 shadowParams.z 作为阈值"），
        // 故此处从第一个方向光 slot 填入实际 bias/normalBias，避免 pcf 可视化出现 self-shadow acne 斑马纹。
        // 主渲染 shader 走 per-light 数组（u_dirShadowParams[i]），不受此 y/z 影响。
        // 本实现比较语义下 bias 为负（正 bias 实测导致全画面反转成阴影）。
        let uShadowParams = uniforms.createUniform("shadowParams", UniformType.Vec4.value())
        let spMem = BgfxMemory(16u32)
        let spBias = if (dirSlots.size > 0) { dirSlots[0].bias } else { 0.0 }
        let spNormalBias = if (dirSlots.size > 0) { dirSlots[0].normalBias } else { 0.0 }
        spMem.writeFloats([1.0, spBias, spNormalBias, 1.0], 4)
        bgfx_set_uniform_cj(uShadowParams.value, unsafe { CPointer<Unit>(spMem.data()) }, 1u16)

        // shadowMapSize（vec4 打包，xyz=size, w=0）
        // 取三类 framebuffer 尺寸中非零者（同一场景通常尺寸一致）。
        let activeSize = if (dirSlots.size > 0) {
            dirSlots[0].size
        } else if (spotSlots.size > 0) {
            spotSlots[0].size
        } else if (pointSlots.size > 0) {
            pointSlots[0].size
        } else {
            0
        }
        let uShadowMapSize = uniforms.createUniform("shadowMapSize", UniformType.Vec4.value())
        let smSizeMem = BgfxMemory(16u32)
        let smSizeVal = Float64(activeSize)
        smSizeMem.writeFloats([smSizeVal, smSizeVal, smSizeVal, 0.0], 4)
        bgfx_set_uniform_cj(uShadowMapSize.value, unsafe { CPointer<Unit>(smSizeMem.data()) }, 1u16)
    }

    /**
     * @brief[zh-cn] 销毁所有持久阴影资源（_shadowResources），供 BgfxBackend.dispose 调用
     *
     * @brief[en] Destroy all persistent shadow resources (_shadowResources), called by BgfxBackend.dispose
     */
    public func dispose(): Unit {
        for ((_, slot) in this._shadowResources) {
            this._destroySlot(slot)
        }
        this._shadowResources.clear()
        this._shadowSlots.clear()
        this._shadowSlotKind.clear()
    }
}
