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
 * @file[zh-cn] OutlinePass 物体轮廓描边后处理 pass
 * @brief[zh-cn] 物体轮廓描边后处理 pass —— 基于 depth buffer 的边缘检测 + 可分离高斯模糊
 * @explain[zh-cn] 算法流程：
 *         1. 非选中物体 → depthMaterial → renderTargetDepthBuffer（深度图）
 *         2. 选中物体（隐藏非选中）→ prepareMaskMaterial → renderTargetMaskBuffer
 *           （用深度图比较，输出 r=mask, g=depthTest, b=1, a=1）
 *         3. materialCopy 把 maskBuffer 降采样到 renderTargetMaskDownSampleBuffer
 *         4. edgeDetectionMaterial 对降采样 mask 做边缘检测 → renderTargetEdgeBuffer1
 *         5. separableBlurMaterial1 (半分辨率) H/V 模糊 → renderTargetEdgeBuffer1
 *         6. separableBlurMaterial2 (1/4 分辨率) H/V 模糊 → renderTargetEdgeBuffer2
 *         7. overlayMaterial 把 edge1/edge2/mask/pattern 加性叠加到 readBuffer
 *         本 pass 不依赖 EffectComposer 的双 RT ping-pong（needsSwap=false），
 *         内部自持 7 个 RT + 6 个 shader，完整实现 outline 效果。
 *         渲染差异：
 *         - bgfx 用 FrameBufferHandle + TextureHandle 自持 RT，setSize 时销毁重建。
 *         - overrideMaterial 经 scene.overrideMaterial 设（Scene.cj 已支持）。
 *         - 深度比较经 DEPTH_TO_VIEW_Z + perspectiveDepthToViewZ；bgfx 在 prepareMask shader
 *           内联 perspectiveDepthToViewZ（无需 chunk）。
 *         - 全屏四边形渲染；bgfx 用共享 FullScreenQuad.submit(viewId, prog)。
 *         - 7 个 RT：bgfx 用 7 个 FrameBufferHandle（color + depth attachment）。
 *         用法：
 *         let outlinePass = OutlinePass(Vector2(w, h), scene, camera, [obj1, obj2])
 *         composer.addPass(outlinePass)
 *
 * @file[en] OutlinePass object outline post-processing pass
 * @brief[en] Object outline post-processing pass - depth-buffer-based edge detection +
 *         separable Gaussian blur
 * @explain[en] Algorithm flow:
 *         1. Non-selected objects → depthMaterial → renderTargetDepthBuffer (depth map)
 *         2. Selected objects (non-selected hidden) → prepareMaskMaterial → renderTargetMaskBuffer
 *           (compared against the depth map, output r=mask, g=depthTest, b=1, a=1)
 *         3. materialCopy downsamples the maskBuffer to renderTargetMaskDownSampleBuffer
 *         4. edgeDetectionMaterial performs edge detection on the downsampled mask →
 *            renderTargetEdgeBuffer1
 *         5. separableBlurMaterial1 (half res) H/V blur → renderTargetEdgeBuffer1
 *         6. separableBlurMaterial2 (quarter res) H/V blur → renderTargetEdgeBuffer2
 *         7. overlayMaterial additively combines edge1/edge2/mask/pattern into readBuffer
 *         This pass does not rely on the EffectComposer dual-RT ping-pong (needsSwap=false);
 *         it holds 7 internal RTs + 6 shaders to fully implement the outline effect.
 *         Rendering differences:
 *         - bgfx holds RTs via FrameBufferHandle + TextureHandle, destroyed and rebuilt on setSize.
 *         - overrideMaterial is set via scene.overrideMaterial (supported by Scene.cj).
 *         - Depth comparison uses DEPTH_TO_VIEW_Z + perspectiveDepthToViewZ; bgfx inlines
 *           perspectiveDepthToViewZ in the prepareMask shader (no chunk needed).
 *         - Fullscreen quad rendering; bgfx uses the shared FullScreenQuad.submit(viewId, prog).
 *         - The 7 RTs: bgfx uses 7 FrameBufferHandles (color + depth attachment).
 *         Usage:
 *         let outlinePass = OutlinePass(Vector2(w, h), scene, camera, [obj1, obj2])
 *         composer.addPass(outlinePass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import std.time.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.materials.*
import three.core.math.*
import three.rendering.textures.Texture
import three.rendering.ThreeRenderer
import three.rendering.common.*
import three.rendering.bgfx.*
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.shaders.ShaderLibs
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.*
import three.utils.log.macros.*
import three.rendering.types.*
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] Outline 后处理 pass
 * @brief[en] Outline post-processing pass
 * @explain[zh-cn] 基于 depth buffer 的边缘检测 + 可分离高斯模糊。
 * @explain[en] Depth-buffer-based edge detection + separable Gaussian blur.
 */
public class OutlinePass <: Pass {
    /**
     * @brief[zh-cn] 待渲染场景
     * @brief[en] The scene to render
     */
    public let renderScene: Scene

    /**
     * @brief[zh-cn] 待渲染相机
     * @brief[en] The camera to render with
     */
    public let renderCamera: Camera

    /**
     * @brief[zh-cn] 选中的 3D 物体（描边目标）
     * @brief[en] The selected 3D objects (outline targets)
     */
    public var selectedObjects: ArrayList<Object3D>

    /**
     * @brief[zh-cn] 可见边颜色
     * @brief[en] Visible edge color
     */
    public var visibleEdgeColor: Color = Color(1.0, 1.0, 1.0)

    /**
     * @brief[zh-cn] 隐藏边颜色
     * @brief[en] Hidden edge color
     */
    public var hiddenEdgeColor: Color = Color(0.1, 0.04, 0.02)

    /**
     * @brief[zh-cn] 边缘发光强度（动画 glow/pulse）
     * @brief[en] Edge glow strength (animated glow/pulse)
     */
    public var edgeGlow: Float64 = 0.0

    /**
     * @brief[zh-cn] 是否使用图案纹理
     * @brief[en] Whether to use the pattern texture
     */
    public var usePatternTexture: Bool = false

    /**
     * @brief[zh-cn] 图案纹理（需 usePatternTexture=true）
     * @brief[en] The pattern texture (requires usePatternTexture=true)
     */
    public var patternTexture: Option<Texture> = None

    /**
     * @brief[zh-cn] 边缘厚度
     * @brief[en] Edge thickness
     */
    public var edgeThickness: Float64 = 1.0

    /**
     * @brief[zh-cn] 边缘强度
     * @brief[en] Edge strength
     */
    public var edgeStrength: Float64 = 3.0

    /**
     * @brief[zh-cn] 降采样比例
     * @brief[en] Downsample ratio
     */
    public var downSampleRatio: Int64 = 2

    /**
     * @brief[zh-cn] 脉冲周期（动画 pulse）
     * @brief[en] Pulse period (animated pulse)
     */
    public var pulsePeriod: Float64 = 0.0

    /**
     * @brief[zh-cn] 效果分辨率（Vector2）
     * @brief[en] Effect resolution (Vector2)
     */
    public var resolution: Vector2 = Vector2(256.0, 256.0)

    /**
     * view id 基址（223，避开 SSAO 160/Bloom 200/ShaderPass 200~209/
     * SavePass 210/TexturePass 211/OutputPass 212/SMAA 214~216/
     * SSAA 217/TAA 219~220/MaskPass 220~221/CubeTexturePass 222 区段）。
     * OutlinePass 内部 7+ 个 pass，分配 223~239（17 个 view id 够用）。
     */
    public static let OUTLINE_VIEW_ID_BASE: UInt16 = 223u16

    // ===== RT 句柄（懒创建） =====
    private var _maskFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _maskTex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _maskDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE  // mask RT 的 depth attachment（遮挡剔除用）
    private var _depthFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _depthTex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _depthDepthTex: TextureHandle = INVALID_TEXTURE_HANDLE  // depth pass 用的 depth attachment
    private var _maskDownFB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _maskDownTex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _blur1FB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blur1Tex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _blur2FB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _blur2Tex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _edge1FB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _edge1Tex: TextureHandle = INVALID_TEXTURE_HANDLE
    private var _edge2FB: FrameBufferHandle = INVALID_FRAME_BUFFER_HANDLE
    private var _edge2Tex: TextureHandle = INVALID_TEXTURE_HANDLE

    // ===== RT 尺寸缓存 =====
    private var _width: Int64 = 0
    private var _height: Int64 = 0
    private var _downW: Int64 = 0   // 半分辨率
    private var _downH: Int64 = 0
    private var _quarterW: Int64 = 0   // 1/4 分辨率
    private var _quarterH: Int64 = 0
    private var _rtsCreated: Bool = false

    /** 渲染器引用（render() 时注入；RT 创建/销毁与几何体缓存释放走 renderer 高阶 API） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 缓存（Object3D 不 Hashable，用 ArrayList<(Object3D, Bool)> 存原可见性） =====
    private var _visibilityCache: ArrayList<(Object3D, Bool)> = ArrayList<(Object3D, Bool)>()
    private var _selectionCache: ArrayList<Object3D> = ArrayList<Object3D>()
    private var _textureMatrix: Matrix4 = Matrix4()

    // ===== 编译后 program handle 缓存 =====
    private var _depthProg: Option<ProgramHandle> = None
    private var _prepareMaskProg: Option<ProgramHandle> = None
    private var _whiteProg: Option<ProgramHandle> = None   // outline_white（mask/depth 几何 pass 用）
    private var _edgeDetectionProg: Option<ProgramHandle> = None
    private var _separableBlurProg: Option<ProgramHandle> = None
    private var _overlayProg: Option<ProgramHandle> = None

    // ===== 几何 submit 缓存（参照 SSAO：VB/IB/layout 按 geomId 缓存复用） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /**
     * 构造 OutlinePass。
     *
     * @param resolution 效果分辨率（Vector2）
     * @param scene 待渲染场景
     * @param camera 待渲染相机
     * @param selectedObjects 选中的 3D 物体（描边目标）
     */
    public init(
        resolution: Vector2,
        scene: Scene,
        camera: Camera,
        selectedObjects: ArrayList<Object3D>
    ) {
        super()
        this.renderScene = scene
        this.renderCamera = camera
        this.selectedObjects = selectedObjects
        this.resolution = Vector2(resolution.x, resolution.y)
        // needsSwap 语义：本 pass 不参与双 RT ping-pong；
        // 但 bgfx 版 overlay 输出到 writeBuffer（从 readBuffer 采样场景合成），
        // 必须 needsSwap=true 才能把结果 swap 回 readBuffer 供后续上屏/下一 pass 使用
        // （对齐 SSAO apply 输出 writeBuffer + needsSwap=true 的成熟模式）。
        this.needsSwap = true
    }

    /**
     * 设置 pass 尺寸（重建所有 RT）。
     */
    public override func setSize(width: Int64, height: Int64): Unit {
        if (width == this._width && height == this._height && this._rtsCreated) {
            return
        }
        this._width = width
        this._height = height
        this.resolution = Vector2(Float64(width), Float64(height))
        this._downW = width / this.downSampleRatio
        this._downH = height / this.downSampleRatio
        this._quarterW = this._downW / 2
        this._quarterH = this._downH / 2
        this._createRTs()
    }

    /**
     * 创建所有 RT：mask/depth/maskDown/blur1/blur2/edge1/edge2。
     */
    private func _createRTs(): Unit {
        this._destroyRTs()
        if (this._width <= 0 || this._height <= 0) {
            return
        }
        match (this._renderer) {
            case Some(renderer) =>
                let w = UInt16(this._width)
                let h = UInt16(this._height)
                let dw = UInt16(this._downW)
                let dh = UInt16(this._downH)
                let qw = UInt16(this._quarterW)
                let qh = UInt16(this._quarterH)
                let colorFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
                let rtFmt: UInt32 = TextureFormat.RGBA8.value()  // outline 用 RGBA8 足够

                // mask RT（全分辨率，color + depth attachment）
                // depth attachment 用于遮挡剔除：mask pass 先渲非选中物体深度（depth-only），
                // 再渲选中物体（深度测试 LESS），被非选中物体遮挡的选中部分深度测试失败 → 不写 mask，
                // 描边被遮挡处不显示（prepareMask 的 depthTexture 比较语义）。
                this._maskTex = renderer.createTexture2D(w, h, false, 1u16, rtFmt, colorFlags, None)
                this._maskDepthTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.D24S8.value(), colorFlags, None)
                this._maskFB = this._createFBWithDepth(renderer, this._maskTex, this._maskDepthTex)

                // depth RT（全分辨率，color + depth attachment）
                this._depthTex = renderer.createTexture2D(w, h, false, 1u16, rtFmt, colorFlags, None)
                this._depthDepthTex = renderer.createTexture2D(w, h, false, 1u16, TextureFormat.D24S8.value(), colorFlags, None)
                this._depthFB = this._createFBWithDepth(renderer, this._depthTex, this._depthDepthTex)

                // maskDown RT（半分辨率）
                this._maskDownTex = renderer.createTexture2D(dw, dh, false, 1u16, rtFmt, colorFlags, None)
                this._maskDownFB = this._createFB(renderer, this._maskDownTex)

                // blur1 RT（半分辨率）
                this._blur1Tex = renderer.createTexture2D(dw, dh, false, 1u16, rtFmt, colorFlags, None)
                this._blur1FB = this._createFB(renderer, this._blur1Tex)

                // blur2 RT（1/4 分辨率）
                this._blur2Tex = renderer.createTexture2D(qw, qh, false, 1u16, rtFmt, colorFlags, None)
                this._blur2FB = this._createFB(renderer, this._blur2Tex)

                // edge1 RT（半分辨率）
                this._edge1Tex = renderer.createTexture2D(dw, dh, false, 1u16, rtFmt, colorFlags, None)
                this._edge1FB = this._createFB(renderer, this._edge1Tex)

                // edge2 RT（1/4 分辨率）
                this._edge2Tex = renderer.createTexture2D(qw, qh, false, 1u16, rtFmt, colorFlags, None)
                this._edge2FB = this._createFB(renderer, this._edge2Tex)

                this._rtsCreated = true
                @LogTrace(["OutlinePass", "_createRTs done: mask/depth/maskDown/blur1/blur2/edge1/edge2"])
            case None => ()
        }
    }

    /**
     * 销毁所有 RT。
     */
    private func _destroyRTs(): Unit {
        if (!this._rtsCreated) {
            return
        }
        match (this._renderer) {
            case Some(renderer) =>
                renderer.destroyFrameBuffer(this._maskFB)
                renderer.destroyTexture(this._maskTex)
                renderer.destroyTexture(this._maskDepthTex)
                renderer.destroyFrameBuffer(this._depthFB)
                renderer.destroyTexture(this._depthTex)
                renderer.destroyTexture(this._depthDepthTex)
                renderer.destroyFrameBuffer(this._maskDownFB)
                renderer.destroyTexture(this._maskDownTex)
                renderer.destroyFrameBuffer(this._blur1FB)
                renderer.destroyTexture(this._blur1Tex)
                renderer.destroyFrameBuffer(this._blur2FB)
                renderer.destroyTexture(this._blur2Tex)
                renderer.destroyFrameBuffer(this._edge1FB)
                renderer.destroyTexture(this._edge1Tex)
                renderer.destroyFrameBuffer(this._edge2FB)
                renderer.destroyTexture(this._edge2Tex)
            case None => ()
        }
        this._rtsCreated = false
    }

    /**
     * 创建单 color attachment 的 frame buffer。
     */
    private func _createFB(renderer: ThreeRenderer, colorTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(1, { _ => colorTex })
        let fb = renderer.createFrameBuffer(1u8, handles, true)
        return fb
    }

    /**
     * 创建 color + depth attachment 的 frame buffer。
     */
    private func _createFBWithDepth(renderer: ThreeRenderer, colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /**
     * 更新选中缓存（traverse selectedObjects 收集所有 isMesh 子节点）。
     */
    private func _updateSelectionCache(): Unit {
        this._selectionCache.clear()
        for (i in 0..this.selectedObjects.size) {
            let obj = this.selectedObjects[i]
            obj.traverse({ o =>
                // 经 renderer.render 走 Mesh filter；Cangjie 用 `match (o as Mesh)` 下转检查（参考 BgfxShadowPass）。
                match (o as Mesh) {
                    case Some(_) => this._selectionCache.add(o)
                    case None => ()
                }
            })
        }
    }

    /**
     * 切换选中物体的可见性（保存/恢复 visible）。
     *
     * @param bVisible true=恢复可见性（从 cache 取），false=隐藏选中（cache 存原值）
     */
    private func _changeVisibilityOfSelectedObjects(bVisible: Bool): Unit {
        let cache = this._visibilityCache
        for (mesh in this._selectionCache) {
            if (bVisible) {
                // 在 cache 中查找 mesh 的原可见性（ArrayList 无 .get(key)，线性查找）
                var restored: Bool = false
                for (i in 0..cache.size) {
                    let entry = cache[i]
                    if (entry[0] == mesh) {
                        mesh.visible = entry[1]
                        restored = true
                        break
                    }
                }
                // 未找到则不动（防御性，正常不应发生）
            } else {
                cache.add((mesh, mesh.visible))
                mesh.visible = false
            }
        }
    }

    /**
     * 切换非选中物体的可见性。
     *
     * @param bVisible true=恢复可见性（从 cache 取），false=隐藏非选中（cache 存原值）
     */
    private func _changeVisibilityOfNonSelectedObjects(bVisible: Bool): Unit {
        let visibilityCache = this._visibilityCache
        let selectionCache = this._selectionCache
        // 工具：判断 obj 是否在 selectionCache 中（ArrayList 无 .contains，线性查找）
        let isInSelection: (Object3D) -> Bool = { obj =>
            for (i in 0..selectionCache.size) {
                if (selectionCache[i] == obj) { return true }
            }
            return false
        }
        // 工具：在 visibilityCache 中查找 obj 的原可见性
        let findInCache: (Object3D) -> Option<Bool> = { obj =>
            for (i in 0..visibilityCache.size) {
                let entry = visibilityCache[i]
                if (entry[0] == obj) { return Some(entry[1]) }
            }
            return None
        }
        let cb: (Object3D) -> Unit = { obj =>
            // Points/Line/Line2 不参与 outline 计算
            // Cangjie 用 `match (obj as Mesh)` 下转检查（参考 BgfxShadowPass）
            match (obj as Mesh) {
                case Some(_) =>
                    if (!isInSelection(obj)) {
                        if (bVisible) {
                            match (findInCache(obj)) {
                                case Some(v) => obj.visible = v
                                case None => ()
                            }
                        } else {
                            visibilityCache.add((obj, obj.visible))
                            obj.visible = false
                        }
                    }
                case None => ()
            }
        }
        this.renderScene.traverse(cb)
    }

    /**
     * 更新纹理矩阵（用于 prepareMask 的 depthTexture 投影比较）。
     *
     * textureMatrix = 0.5*projectionMatrix * matrixWorldInverse + bias
     * （把世界坐标投影到 depthTexture 的 UV 空间）
     */
    private func _updateTextureMatrix(): Unit {
        let m = this._textureMatrix
        m.set(0.5, 0.0, 0.0, 0.5,
              0.0, 0.5, 0.0, 0.5,
              0.0, 0.0, 0.5, 0.5,
              0.0, 0.0, 0.0, 1.0)
        m.multiply(this.renderCamera.projectionMatrix)
        m.multiply(this.renderCamera.matrixWorldInverse)
    }

    /**
     * 执行 Outline pass。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 不用，结果写 readBuffer）
     * @param readBuffer 读 buffer（renderToScreen=false 时写这里）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 注入渲染器引用（setSize/_createRTs 在 composer.setSize 阶段可能早于 render 被调用，
        // 此时 _renderer 仍为 None，RT 懒创建延后到 render 内完成）
        this._renderer = Some(renderer)
        // 无选中物体则跳过
        if (this.selectedObjects.size == 0) {
            @LogTrace(["OutlinePass", "render: no selectedObjects, skip"])
            return
        }
        // 确保 RT 已创建
        if (!this._rtsCreated) {
            this.setSize(this._width, this._height)
        }
        // 编译所有 shader（首次）
        this._ensureShaders()

        // 准备选中/可见性缓存
        this._updateSelectionCache()
        this._changeVisibilityOfSelectedObjects(false)

        // 保存场景状态
        let currentBackground = this.renderScene.background
        let currentOverrideMaterial = this.renderScene.overrideMaterial
        this.renderScene.background = None

        // ===== 1. 非选中物体 → depthMaterial → depthRT =====
        // 隐藏选中物体，用 depthMaterial 渲染非选中物体到 depthRT
        this.renderScene.overrideMaterial = this._getDepthMaterial()
        this._renderSceneToDepth(renderer)

        // 恢复选中物体可见性
        this._changeVisibilityOfSelectedObjects(true)
        this._visibilityCache.clear()

        // 更新 textureMatrix
        this._updateTextureMatrix()

        // ===== 2. 选中物体 → prepareMaskMaterial → maskRT =====
        // 隐藏非选中物体，用 prepareMaskMaterial 渲染选中物体到 maskRT
        this._changeVisibilityOfNonSelectedObjects(false)
        this.renderScene.overrideMaterial = this._getPrepareMaskMaterial()
        this._renderSceneToMask(renderer)
        this._changeVisibilityOfNonSelectedObjects(true)
        this._visibilityCache.clear()
        this._selectionCache.clear()

        // 恢复场景状态
        this.renderScene.background = currentBackground
        this.renderScene.overrideMaterial = currentOverrideMaterial

        // ===== 3. materialCopy 把 maskBuffer 降采样到 maskDownBuffer =====
        this._renderDownsample(renderer)

        // 准备脉冲颜色
        let pulseColor1 = Color(this.visibleEdgeColor.r, this.visibleEdgeColor.g, this.visibleEdgeColor.b)
        let pulseColor2 = Color(this.hiddenEdgeColor.r, this.hiddenEdgeColor.g, this.hiddenEdgeColor.b)
        if (this.pulsePeriod > 0.0) {
            let scalar = (1.0 + 0.25) / 2.0 + cos(Float64(getCurrentMillis()) * 0.01 / this.pulsePeriod) * (1.0 - 0.25) / 2.0
            pulseColor1.multiplyScalar(scalar)
            pulseColor2.multiplyScalar(scalar)
        }

        // ===== 4. edgeDetectionMaterial 对 maskDownBuffer 做边缘检测 → edge1Buffer =====
        this._renderEdgeDetection(renderer, pulseColor1, pulseColor2)

        // ===== 5. separableBlurMaterial1 (半分辨率) H/V 模糊 → edge1Buffer =====
        this._renderBlur1(renderer)

        // ===== 6. separableBlurMaterial2 (1/4 分辨率) H/V 模糊 → edge2Buffer =====
        this._renderBlur2(renderer)

        // ===== 7. overlayMaterial 把 edge1/edge2/mask/pattern 加性叠加到 readBuffer =====
        this._renderOverlay(renderer, writeBuffer, readBuffer)

        @LogTrace(["OutlinePass", "render done (7-pass chain)"])
    }

    /**
     * 取深度材质（MeshDepthMaterial，side=DoubleSide, depthPacking=RGBADepthPacking）。
     *
     * 简化：返回 None，depth pass 用 outline_white 几何 shader 直接 submit（参照 SSAO）。
     */
    private func _getDepthMaterial(): Option<Material> {
        return None
    }

    /**
     * 取 prepareMask 材质。
     *
     * 简化：返回 None，mask pass 用 outline_white 几何 shader 直接 submit（参照 SSAO）。
     */
    private func _getPrepareMaskMaterial(): Option<Material> {
        return None
    }

    // ===== 几何 submit 工具（参照 SSAO._createVB/_createIB/_getOrCreateLayout/_setViewTransformFor） =====

    /**
     * 取共享顶点 layout handle（缓存复用）。
     */
    private func _getOrCreateLayout(renderer: ThreeRenderer): VertexLayoutHandle {
        match (this._layoutHandleCache) {
            case Some(lh) => return lh
            case None => ()
        }
        // 经 renderer.createVertexLayout(attrs) 高阶 API 创建布局句柄（封装 begin/add/end/create 序列）。
        // _createVB 经 renderer.createVertexBufferFromLayout(handle) 创建顶点缓冲
        // （renderer 内部从 handle 查回 layout 内存指针，无须接触 CPointer<VertexLayout>）。
        let handle = renderer.createVertexLayout(this._getLayoutAttrs())
        this._layoutHandleCache = Some(handle)
        return handle
    }

    /** 构建顶点布局属性描述（对齐旧 begin/add/end 序列：position(3) + normal(3) + color(4) + uv(2)） */
    private func _getLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        let normal = BgfxAttributeDesc()
        normal.attrib = Attrib.Normal.value()
        normal.num = 3u8
        normal.attribType = AttribType.Float.value()
        normal.normalized = true
        normal.asInt = false
        list.add(normal)
        let color = BgfxAttributeDesc()
        color.attrib = Attrib.Color0.value()
        color.num = 4u8
        color.attribType = AttribType.Float.value()
        color.normalized = false
        color.asInt = false
        list.add(color)
        let uv = BgfxAttributeDesc()
        uv.attrib = Attrib.TexCoord0.value()
        uv.num = 2u8
        uv.attribType = AttribType.Float.value()
        uv.normalized = false
        uv.asInt = false
        list.add(uv)
        return list.toArray()
    }

    /**
     * 创建/复用 geometry 的顶点缓冲（按 geomId 缓存）。
     */
    private func _createVB(renderer: ThreeRenderer, geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._vbCache.get(geomId)) {
            case Some(vb) => return vb
            case None => ()
        }
        let posAttrOpt = geom.getAttribute("position")
        match (posAttrOpt) {
            case Some(pos) =>
                let vc = pos.count
                if (vc == 0) { return INVALID_VERTEX_BUFFER_HANDLE }
                let vertStride: Int64 = 12   // position(3) + normal(3) + color(4) + uv(2)
                let totalFloats = vc * vertStride
                let data = Array<Float64>(totalFloats, { i => 0.0 })
                let normAttrOpt = geom.getAttribute("normal")
                let colAttrOpt = geom.getAttribute("color")
                let uvAttrOpt = geom.getAttribute("uv")
                for (vi in 0..vc) {
                    let base = vi * vertStride
                    data[base] = pos.getX(vi)
                    data[base + 1] = pos.getY(vi)
                    data[base + 2] = pos.getZ(vi)
                    match (normAttrOpt) {
                        case Some(na) =>
                            data[base + 3] = na.getX(vi)
                            data[base + 4] = na.getY(vi)
                            data[base + 5] = na.getZ(vi)
                        case None => data[base + 5] = 1.0
                    }
                    match (colAttrOpt) {
                        case Some(ca) =>
                            data[base + 6] = ca.getX(vi)
                            data[base + 7] = ca.getY(vi)
                            data[base + 8] = ca.getZ(vi)
                            data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                        case None =>
                            for (j in 0..4) { data[base + 6 + j] = 1.0 }
                    }
                    match (uvAttrOpt) {
                        case Some(ua) =>
                            data[base + 10] = ua.getX(vi)
                            data[base + 11] = ua.getY(vi)
                        case None => ()
                    }
                }
                let mem = BgfxMemory(UInt32(totalFloats * 4))
                mem.writeFloats(data, totalFloats)
                let layout = this._getOrCreateLayout(renderer)
                let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
                this._vbCache.add(geomId, handle)
                return handle
            case None => return INVALID_VERTEX_BUFFER_HANDLE
        }
    }

    /**
     * 创建/复用 geometry 的索引缓冲（按 geomId 缓存）。
     */
    private func _createIB(renderer: ThreeRenderer, geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._ibCache.get(geomId)) {
            case Some(ib) => return ib
            case None => ()
        }
        match (geom.index) {
            case Some(idxAttr) =>
                let count = idxAttr.count
                if (count == 0) { return INVALID_INDEX_BUFFER_HANDLE }
                let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
                let mem = BgfxMemory(UInt32(count * 2))
                mem.writeUInt16(idxData, count)
                let handle = renderer.createIndexBuffer(mem, flags: 0u16)
                this._ibCache.add(geomId, handle)
                return handle
            case None => return INVALID_INDEX_BUFFER_HANDLE
        }
    }

    /**
     * 设置 view 的相机变换（view + projection 矩阵）。
     *
     * 用 renderer.setViewTransform 高阶 API（自身走 execBgfx 序列化到渲染线程）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.elements
        let projArr = camera.projectionMatrix.elements
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
    }

    /**
     * 递归收集场景中的 Mesh（参照 SSAO._collectMeshes）。
     */
    private func _collectMeshes(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectMeshes(child, renderObjects)
            }
            if (child.kind == "Mesh") {
                match (child as Mesh) {
                    case Some(mesh) =>
                        let ro = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        renderObjects.add(ro)
                    case None => ()
                }
            }
        }
    }

    /**
     * 判断 mesh 是否在选中缓存中（选中集合含 selectedObjects 及其子 Mesh）。
     */
    private func _isSelected(mesh: Object3D): Bool {
        for (i in 0..this._selectionCache.size) {
            if (this._selectionCache[i] == mesh) { return true }
        }
        return false
    }

    /**
     * 渲染场景到 depthRT（非选中物体 → 白色 mask，view 独立）。
     *
     * bgfx 差异：不走 renderer.render（其 _collectRenderObjects 不检查 visible，
     * 且 finishRender 触发 bgfx_frame 破坏 composer 帧序），
     * 改为遍历场景直接 submit（参照 SSAO._renderDepth 模式）。
     * 用独立 view id（OUTLINE_VIEW_ID_BASE+1），不碰 view 0。
     */
    private func _renderSceneToDepth(renderer: ThreeRenderer): Unit {
        let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 1u16)
        let w = UInt16(renderer.width)
        let h = UInt16(renderer.height)
        // outline_white shader 编译（首次）
        match (this._whiteProg) {
            case None =>
                match (PostProcessingShaders.get("outline_white")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._whiteProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_white shader NOT REGISTERED"]); return
                }
            case Some(_) => ()
        }
        match (this._whiteProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear / 变换
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                this.setRenderTarget(renderer, viewId, this._depthFB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00000000u32)
                this._setViewTransformFor(renderer, viewId, this.renderCamera)
                // 几何提交 API 走 renderer 高阶 API（setTransform / setVertexBufferWithLayout /
                // setIndexBuffer / setState / submit），各自内部 execBgfx 序列化到渲染线程
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(this.renderScene, renderObjects)
                let layout = this._getOrCreateLayout(renderer)
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    // depth pass 只渲非选中物体
                    if (this._isSelected(ro.mesh)) { continue }
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.elements
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    let state: UInt64 = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                        BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                        BgfxConstants.FRONT_CCW
                    renderer.setState(state, rgba: 0x00000000u32)
                    renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
                @LogTrace(["OutlinePass", "_renderSceneToDepth submitCnt=" + submitCnt.toString()])
            case None => ()
        }
        @LogTrace(["OutlinePass", "_renderSceneToDepth done"])
    }

    /**
     * 渲染场景到 maskRT（选中物体 → 白色 mask，view 独立）。
     *
     * bgfx 差异：同 _renderSceneToDepth，遍历场景直接 submit。
     * 遮挡剔除（prepareMask 的 depthTexture 比较语义）：
     *   - 第一步：渲非选中物体到 maskFB 的 depth attachment（state 只写 Z，不写 RGB/A），
     *     建立"遮挡深度"（选中物体被非选中物体挡住的部分应隐藏描边）。
     *   - 第二步：渲选中物体（state 写 RGB/A/Z + DEPTH_TEST_LESS），
     *     被非选中物体遮挡的选中部分深度测试失败 → mask 不写 → 描边被遮挡处不显示。
     * 背景 clear 黑（r=g=0）。
     */
    private func _renderSceneToMask(renderer: ThreeRenderer): Unit {
        let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 2u16)
        let w = UInt16(renderer.width)
        let h = UInt16(renderer.height)
        match (this._whiteProg) {
            case None =>
                match (PostProcessingShaders.get("outline_white")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._whiteProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_white shader NOT REGISTERED"]); return
                }
            case Some(_) => ()
        }
        match (this._whiteProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear / 变换
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                this.setRenderTarget(renderer, viewId, this._maskFB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00000000u32)
                this._setViewTransformFor(renderer, viewId, this.renderCamera)
                // 几何提交 API 走 renderer 高阶 API（对齐 SSAOPass._renderNormals）
                let renderObjects = ArrayList<RenderObject>()
                this._collectMeshes(this.renderScene, renderObjects)
                let layout = this._getOrCreateLayout(renderer)

                // ===== 第一步：渲非选中物体到 depth attachment（只写 Z，遮挡剔除） =====
                // state 不设 WRITE_RGB/WRITE_A：bgfx 不写颜色，仅深度写入
                let depthOnlyState: UInt64 = BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                             BgfxConstants.FRONT_CCW
                var depthSubmitCnt: Int64 = 0
                for (ro in renderObjects) {
                    if (this._isSelected(ro.mesh)) { continue }
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.elements
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    renderer.setState(depthOnlyState, rgba: 0x00000000u32)
                    renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                    depthSubmitCnt += 1
                }

                // ===== 第二步：渲选中物体到 color（白色 mask + 深度测试 LESS） =====
                var submitCnt: Int64 = 0
                for (ro in renderObjects) {
                    if (!this._isSelected(ro.mesh)) { continue }
                    let vb = this._createVB(renderer, ro.geometry)
                    if (!Handle.isValid(vb)) { continue }
                    let mtxArr = ro.worldMatrix.elements
                    let mtxMem = BgfxMemory(64u32)
                    mtxMem.writeFloats(mtxArr, 16)
                    renderer.setTransform(mtxMem, num: 1u16)
                    renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                    let ib = this._createIB(renderer, ro.geometry)
                    if (Handle.isValid(ib)) {
                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                    }
                    // 深度测试 LESS：被非选中物体（第一步已写深度）遮挡的选中片元测试失败 → mask 不写
                    let state: UInt64 = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                        BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                        BgfxConstants.FRONT_CCW
                    renderer.setState(state, rgba: 0x00000000u32)
                    renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                }
                @LogTrace(["OutlinePass", "_renderSceneToMask depthSubmitCnt=" + depthSubmitCnt.toString() + " maskSubmitCnt=" + submitCnt.toString()])
            case None => ()
        }
        @LogTrace(["OutlinePass", "_renderSceneToMask done"])
    }

    /**
     * 降采样：materialCopy 把 maskBuffer 拷到 maskDownBuffer。
     *
     * 用 outline_copy shader（copy + 不透明）做全屏四边形降采样。
     */
    private func _renderDownsample(renderer: ThreeRenderer): Unit {
        match (PostProcessingShaders.get("outline_copy")) {
            case Some(sp) =>
                if (!Handle.isValid(Box(sp.programHandle))) {
                    sp.compileBgfx()
                }
                let progRaw = Box(sp.programHandle)
                if (!Handle.isValid(progRaw)) { @LogTrace(["OutlinePass", "outline_copy prog compile failed"]); return }
                let prog = progRaw
                let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 7u16)
                let dw = UInt16(this._downW)
                let dh = UInt16(this._downH)
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
                this.setViewport(renderer, viewId, 0u16, 0u16, dw, dh)
                this.setRenderTarget(renderer, viewId, this._maskDownFB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                // bindTexture / setUniform 高阶 API（各自走 execBgfx）
                let uniforms = BgfxUniforms()
                let uTex = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uTex, this._maskTex, 0u32)
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let opMem = BgfxMemory(16u32)
                opMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, opMem)
                this.submitQuad(viewId, prog)
            case None => @LogTrace(["OutlinePass", "outline_copy shader NOT REGISTERED"])
        }
    }

    /**
     * 边缘检测：edgeDetectionMaterial 对 maskDownBuffer 做边缘检测 → edge1Buffer。
     */
    private func _renderEdgeDetection(renderer: ThreeRenderer, pulseColor1: Color, pulseColor2: Color): Unit {
        match (this._edgeDetectionProg) {
            case Some(_) => ()
            case None => this._ensureShaders()
        }
        match (this._edgeDetectionProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 8u16)
                let dw = UInt16(this._downW)
                let dh = UInt16(this._downH)
                let pc1 = pulseColor1
                let pc2 = pulseColor2
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
                this.setViewport(renderer, viewId, 0u16, 0u16, dw, dh)
                this.setRenderTarget(renderer, viewId, this._edge1FB)
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                // bindTexture / setUniform 高阶 API（各自走 execBgfx）
                let uniforms = BgfxUniforms()
                let uMask = uniforms.createUniform("maskTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uMask, this._maskDownTex, 0u32)
                let uTexSize = uniforms.createUniform("texSize", UniformType.Vec4.value())
                let tsMem = BgfxMemory(16u32)
                tsMem.writeFloats([Float64(this._downW), Float64(this._downH), 0.0, 0.0], 4)
                this.setUniform(renderer, uTexSize, tsMem)
                let uVis = uniforms.createUniform("visibleEdgeColor", UniformType.Vec4.value())
                let visMem = BgfxMemory(16u32)
                visMem.writeFloats([pc1.r, pc1.g, pc1.b, 1.0], 4)
                this.setUniform(renderer, uVis, visMem)
                let uHid = uniforms.createUniform("hiddenEdgeColor", UniformType.Vec4.value())
                let hidMem = BgfxMemory(16u32)
                hidMem.writeFloats([pc2.r, pc2.g, pc2.b, 1.0], 4)
                this.setUniform(renderer, uHid, hidMem)
                this.submitQuad(viewId, prog)
            case None => ()
        }
    }

    /**
     * 模糊1：separableBlurMaterial1 (半分辨率) H/V 模糊 → edge1Buffer。
     *
     * 两遍模糊（4. Apply Blur on Half res）：
     *   H：edge1 → blur1（direction=X）
     *   V：blur1 → edge1（direction=Y）
     */
    private func _renderBlur1(renderer: ThreeRenderer): Unit {
        match (this._separableBlurProg) {
            case Some(_) => ()
            case None => this._ensureShaders()
        }
        match (this._separableBlurProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                let baseView = OutlinePass.OUTLINE_VIEW_ID_BASE
                let dw = UInt16(this._downW)
                let dh = UInt16(this._downH)
                let et = this.edgeThickness

                // H：edge1 → blur1
                let viewH = UInt16(UInt16(baseView) + 9u16)
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
                this.setViewport(renderer, viewH, 0u16, 0u16, dw, dh)
                this.setRenderTarget(renderer, viewH, this._blur1FB)
                this.clearRenderTarget(renderer, viewH, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                // bindTexture / setUniform 高阶 API（各自走 execBgfx）
                let uniforms = BgfxUniforms()
                let uColor = uniforms.createUniform("colorTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uColor, this._edge1Tex, 0u32)
                let uTexSize = uniforms.createUniform("texSize", UniformType.Vec4.value())
                let tsMem = BgfxMemory(16u32)
                tsMem.writeFloats([Float64(this._downW), Float64(this._downH), 0.0, 0.0], 4)
                this.setUniform(renderer, uTexSize, tsMem)
                let uDir = uniforms.createUniform("direction", UniformType.Vec4.value())
                let dirMem = BgfxMemory(16u32)
                dirMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)  // X
                this.setUniform(renderer, uDir, dirMem)
                let uKernel = uniforms.createUniform("kernelRadius", UniformType.Vec4.value())
                let krMem = BgfxMemory(16u32)
                krMem.writeFloats([et, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uKernel, krMem)
                this.submitQuad(viewH, prog)

                // V：blur1 → edge1
                let viewV = UInt16(UInt16(baseView) + 10u16)
                this.setViewport(renderer, viewV, 0u16, 0u16, dw, dh)
                this.setRenderTarget(renderer, viewV, this._edge1FB)
                this.clearRenderTarget(renderer, viewV, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                let uniforms2 = BgfxUniforms()
                let uColor2 = uniforms2.createUniform("colorTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uColor2, this._blur1Tex, 0u32)
                let uDir2 = uniforms2.createUniform("direction", UniformType.Vec4.value())
                let dirMem2 = BgfxMemory(16u32)
                dirMem2.writeFloats([0.0, 1.0, 0.0, 0.0], 4)  // Y
                this.setUniform(renderer, uDir2, dirMem2)
                this.submitQuad(viewV, prog)
            case None => ()
        }
    }

    /**
     * 模糊2：separableBlurMaterial2 (1/4 分辨率) H/V 模糊 → edge2Buffer。
     */
    private func _renderBlur2(renderer: ThreeRenderer): Unit {
        match (this._separableBlurProg) {
            case Some(_) => ()
            case None => this._ensureShaders()
        }
        match (this._separableBlurProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                let baseView = OutlinePass.OUTLINE_VIEW_ID_BASE
                let qw = UInt16(this._quarterW)
                let qh = UInt16(this._quarterH)

                // H：edge1 → edge2（1/4 分辨率）
                let viewH = UInt16(UInt16(baseView) + 11u16)
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
                this.setViewport(renderer, viewH, 0u16, 0u16, qw, qh)
                this.setRenderTarget(renderer, viewH, this._edge2FB)
                this.clearRenderTarget(renderer, viewH, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                // bindTexture / setUniform 高阶 API（各自走 execBgfx）
                let uniforms = BgfxUniforms()
                let uColor = uniforms.createUniform("colorTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uColor, this._edge1Tex, 0u32)
                let uDir = uniforms.createUniform("direction", UniformType.Vec4.value())
                let dirMem = BgfxMemory(16u32)
                dirMem.writeFloats([1.0, 0.0, 0.0, 0.0], 4)  // X
                this.setUniform(renderer, uDir, dirMem)
                this.submitQuad(viewH, prog)

                // V：edge2 → edge2（同 buffer，1/4 分辨率）
                // 注意：bgfx view 同 frame buffer 可二次 submit，但 view clear 仅首次生效
                // 这里用单独 view id（+13）避免 H view 的 clear 残留
                let viewV = UInt16(UInt16(baseView) + 13u16)
                this.setViewport(renderer, viewV, 0u16, 0u16, qw, qh)
                this.setRenderTarget(renderer, viewV, this._edge2FB)
                this.clearRenderTarget(renderer, viewV, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                let uniforms2 = BgfxUniforms()
                let uColor2 = uniforms2.createUniform("colorTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uColor2, this._edge2Tex, 0u32)
                let uDir2 = uniforms2.createUniform("direction", UniformType.Vec4.value())
                let dirMem2 = BgfxMemory(16u32)
                dirMem2.writeFloats([0.0, 1.0, 0.0, 0.0], 4)  // Y
                this.setUniform(renderer, uDir2, dirMem2)
                this.submitQuad(viewV, prog)
            case None => ()
        }
    }

    /**
     * 叠加：overlayMaterial 把 edge1/edge2/mask/pattern 加性叠加到场景。
     *
     * bgfx 差异：bgfx 每 view 先 clear（不能保留 readBuffer 内容），
     * 故 overlay shader 显式采样 readBuffer 场景（tDiffuse）+ 描边色合成，
     * 输出到 writeBuffer（renderToScreen=true 时输出屏幕），对齐 SSAO apply 成熟模式。
     */
    private func _renderOverlay(renderer: ThreeRenderer, writeBuffer: FrameBufferHandle, readBuffer: FrameBufferHandle): Unit {
        match (this._overlayProg) {
            case Some(_) => ()
            case None => this._ensureShaders()
        }
        match (this._overlayProg) {
            case Some(progRaw) =>
                if (!Handle.isValid(progRaw)) { return }
                let prog = progRaw
                let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 12u16)
                let w = UInt16(renderer.width)
                let h = UInt16(renderer.height)
                let rt = this.renderToScreen
                // 输出目标：renderToScreen（最后一个 enabled pass）→ 屏幕；否则 → writeBuffer
                // （bgfx 差异：overlay 需从 readBuffer 采样场景合成，故目标不能是 readBuffer，
                //   对照 SSAO apply 输出 writeBuffer + needsSwap=true 的成熟模式）
                // 场景纹理 = readBuffer 的 color attachment 0（composer 的 RT）
                let sceneTex = this.getTexture(renderer, readBuffer, 0u8)
                let es = this.edgeStrength
                let eg = this.edgeGlow
                let upt = if (this.usePatternTexture) { 1.0 } else { 0.0 }
                // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                if (rt) {
                    this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
                } else {
                    this.setRenderTarget(renderer, viewId, writeBuffer)
                }
                this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
                // bindTexture / setUniform 高阶 API（各自走 execBgfx）
                let uniforms = BgfxUniforms()
                // stage 0=tDiffuse(场景), 1=maskTexture, 2=edgeTexture1, 3=edgeTexture2, 4=patternTexture
                let uScene = uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
                let uMask = uniforms.createUniform("maskTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 1u8, uMask, this._maskTex, 0u32)
                let uEdge1 = uniforms.createUniform("edgeTexture1", UniformType.Sampler.value())
                this.bindTexture(renderer, 2u8, uEdge1, this._edge1Tex, 0u32)
                let uEdge2 = uniforms.createUniform("edgeTexture2", UniformType.Sampler.value())
                this.bindTexture(renderer, 3u8, uEdge2, this._edge2Tex, 0u32)
                // patternTexture 占位：用 maskTex（不实际使用 pattern）
                let uPattern = uniforms.createUniform("patternTexture", UniformType.Sampler.value())
                this.bindTexture(renderer, 4u8, uPattern, this._maskTex, 0u32)
                let uParams = uniforms.createUniform("u_overlayParams", UniformType.Vec4.value())
                let pMem = BgfxMemory(16u32)
                pMem.writeFloats([es, eg, upt, 0.0], 4)
                this.setUniform(renderer, uParams, pMem)
                this.submitQuad(viewId, prog)
            case None => ()
        }
    }

    /**
     * 编译所有 outline shader（首次）。
     * shader 已在 PostProcessingShaders 注册。
     */
    private func _ensureShaders(): Unit {
        // depth shader（outline 用）
        match (this._depthProg) {
            case None =>
                match (PostProcessingShaders.get("outline_depth")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._depthProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_depth shader NOT REGISTERED"])
                }
            case Some(_) => ()
        }
        // prepareMask shader
        match (this._prepareMaskProg) {
            case None =>
                match (PostProcessingShaders.get("outline_prepare_mask")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._prepareMaskProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_prepare_mask shader NOT REGISTERED"])
                }
            case Some(_) => ()
        }
        // edgeDetection shader
        match (this._edgeDetectionProg) {
            case None =>
                match (PostProcessingShaders.get("outline_edge_detection")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._edgeDetectionProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_edge_detection shader NOT REGISTERED"])
                }
            case Some(_) => ()
        }
        // separableBlur shader
        match (this._separableBlurProg) {
            case None =>
                match (PostProcessingShaders.get("outline_separable_blur")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._separableBlurProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_separable_blur shader NOT REGISTERED"])
                }
            case Some(_) => ()
        }
        // overlay shader
        match (this._overlayProg) {
            case None =>
                match (PostProcessingShaders.get("outline_overlay")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._overlayProg = Some(Box(sp.programHandle))
                    case None => @LogTrace(["OutlinePass", "outline_overlay shader NOT REGISTERED"])
                }
            case Some(_) => ()
        }
    }

    /**
     * 释放 OutlinePass 占用的 GPU 资源（所有 RT + shader 缓存）。
     */
    public override func dispose(): Unit {
        this._destroyRTs()
        this._depthProg = None
        this._prepareMaskProg = None
        this._edgeDetectionProg = None
        this._separableBlurProg = None
        this._overlayProg = None
        // 释放共享顶点布局句柄（_getOrCreateLayout 经 renderer.createVertexLayout 创建）
        match (this._renderer) {
            case Some(renderer) =>
                match (this._layoutHandleCache) {
                    case Some(lh) =>
                        renderer.destroyVertexLayout(lh)
                        this._layoutHandleCache = None
                    case None => ()
                }
            case None => ()
        }
    }
}

/**
 * 取当前毫秒时间戳（用于 pulsePeriod 动画）。
 *
 * 跨平台：std.time.MonoTime 单调时钟（毫秒精度）
 */
var _monoStart = MonoTime.now()

/**
 * 取当前毫秒（封装 MonoTime 差值 → Int64）。
 */
func getCurrentMillis(): Int64 {
    return Int64((MonoTime.now() - _monoStart).toMilliseconds())
}
