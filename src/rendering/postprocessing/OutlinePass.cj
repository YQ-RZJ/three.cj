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
 *         1. maskRT：先渲非选中物体（只写 Z），再渲选中物体（写 RGB/A/Z + 深度测试 LESS）
 *            —— 被遮挡的选中片元深度测试失败 → 不写 mask，描边被遮挡处不显示
 *         2. materialCopy 把 maskBuffer 降采样到 renderTargetMaskDownSampleBuffer
 *         3. edgeDetectionMaterial 对降采样 mask 做边缘检测 → renderTargetEdgeBuffer1
 *         4. separableBlurMaterial1 (半分辨率) H/V 模糊 → renderTargetEdgeBuffer1
 *         5. separableBlurMaterial2 (1/4 分辨率) H/V 模糊 → renderTargetEdgeBuffer2
 *         6. overlayMaterial 把 edge1/edge2/mask/pattern 加性叠加到 readBuffer
 *         本 pass 不依赖 EffectComposer 的双 RT ping-pong（needsSwap=false），
 *         内部自持 6 个 RT + 5 个 shader，完整实现 outline 效果。
 *         渲染差异：
 *         - bgfx 用 FrameBufferHandle + TextureHandle 自持 RT，setSize 时销毁重建。
 *         - 深度比较经 DEPTH_TO_VIEW_Z + perspectiveDepthToViewZ；bgfx 在 prepareMask shader
 *           内联 perspectiveDepthToViewZ（无需 chunk）。
 *         - 全屏四边形渲染；bgfx 用共享 FullScreenQuad.submit(viewId, prog)。
 *         - 6 个 RT：bgfx 用 6 个 FrameBufferHandle（color + depth attachment）。
 *         用法：
 *         let outlinePass = OutlinePass(Vector2(w, h), scene, camera, [obj1, obj2])
 *         composer.addPass(outlinePass)
 *
 * @file[en] OutlinePass object outline post-processing pass
 * @brief[en] Object outline post-processing pass - depth-buffer-based edge detection +
 *         separable Gaussian blur
 * @explain[en] Algorithm flow:
 *         1. maskRT: first render non-selected objects (depth only), then selected objects
 *            (RGB/A/Z + depth test LESS) - occluded selected fragments fail the depth test
 *            → mask is not written, so the outline is hidden where it is occluded
 *         2. materialCopy downsamples the maskBuffer to renderTargetMaskDownSampleBuffer
 *         3. edgeDetectionMaterial performs edge detection on the downsampled mask →
 *            renderTargetEdgeBuffer1
 *         4. separableBlurMaterial1 (half res) H/V blur → renderTargetEdgeBuffer1
 *         5. separableBlurMaterial2 (quarter res) H/V blur → renderTargetEdgeBuffer2
 *         6. overlayMaterial additively combines edge1/edge2/mask/pattern into readBuffer
 *         This pass does not rely on the EffectComposer dual-RT ping-pong (needsSwap=false);
 *         it holds 6 internal RTs + 5 shaders to fully implement the outline effect.
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

import three.utils.safe.IReleasable
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
import three.profiler.*
import three.profiler.macros.*

/**
 * @brief[zh-cn] Outline 后处理 pass
 * @explain[zh-cn] 基于 depth buffer 的边缘检测 + 可分离高斯模糊。
 *
 * @brief[en] Outline post-processing pass
 * @explain[en] Depth-buffer-based edge detection + separable Gaussian blur.
 */
public class OutlinePass <: Pass & IReleasable {
    /**
     * @brief[zh-cn] 待渲染场景
     *
     * @brief[en] The scene to render
     */
    public let renderScene: Scene

    /**
     * @brief[zh-cn] 待渲染相机
     *
     * @brief[en] The camera to render with
     */
    public let renderCamera: Camera

    /**
     * @brief[zh-cn] 选中的 3D 物体（描边目标）
     *
     * @brief[en] The selected 3D objects (outline targets)
     */
    public var selectedObjects: ArrayList<Object3D>

    /**
     * @brief[zh-cn] 可见边颜色
     *
     * @brief[en] Visible edge color
     */
    public var visibleEdgeColor: Color = Color(1.0, 1.0, 1.0)

    /**
     * @brief[zh-cn] 隐藏边颜色
     *
     * @brief[en] Hidden edge color
     */
    public var hiddenEdgeColor: Color = Color(0.1, 0.04, 0.02)

    /**
     * @brief[zh-cn] 边缘发光强度（动画 glow/pulse）
     *
     * @brief[en] Edge glow strength (animated glow/pulse)
     */
    public var edgeGlow: Float64 = 0.0

    /**
     * @brief[zh-cn] 是否使用图案纹理
     *
     * @brief[en] Whether to use the pattern texture
     */
    public var usePatternTexture: Bool = false

    /**
     * @brief[zh-cn] 图案纹理（需 usePatternTexture=true）
     *
     * @brief[en] The pattern texture (requires usePatternTexture=true)
     */
    public var patternTexture: Option<Texture> = None

    /**
     * @brief[zh-cn] 边缘厚度
     *
     * @brief[en] Edge thickness
     */
    public var edgeThickness: Float64 = 1.0

    /**
     * @brief[zh-cn] 边缘强度
     *
     * @brief[en] Edge strength
     */
    public var edgeStrength: Float64 = 3.0

    /**
     * @brief[zh-cn] 降采样比例
     *
     * @brief[en] Downsample ratio
     */
    public var downSampleRatio: Int64 = 2

    /**
     * @brief[zh-cn] 脉冲周期（动画 pulse）
     *
     * @brief[en] Pulse period (animated pulse)
     */
    public var pulsePeriod: Float64 = 0.0

    /**
     * @brief[zh-cn] 效果分辨率（Vector2）
     *
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

    /**
     * @brief[zh-cn] 内部 RT 是否已创建且未被释放
     *
     * @brief[en] whether the internal RTs exist and have not been released
     */
    public prop releasable: Bool {
        get() { return this._rtsCreated }
    }

    /** 渲染器引用（render() 时注入；RT 创建/销毁与几何体缓存释放走 renderer 高阶 API） */
    private var _renderer: Option<ThreeRenderer> = None

    // ===== 缓存（选中集合；Object3D 不 Hashable，用 ArrayList 存） =====
    private var _selectionCache: ArrayList<Object3D> = ArrayList<Object3D>()

    // ===== 编译后 program handle 缓存 =====
    private var _copyProg: Option<ProgramHandle> = None   // outline_copy（降采样）
    private var _whiteProg: Option<ProgramHandle> = None   // outline_white（mask 几何 pass 用）
    private var _edgeDetectionProg: Option<ProgramHandle> = None
    private var _separableBlurProg: Option<ProgramHandle> = None
    private var _overlayProg: Option<ProgramHandle> = None

    // ===== 几何 submit 缓存（参照 SSAO：VB/IB/layout 按 geomId 缓存复用） =====
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    // ===== uniform 句柄缓存（逐帧复用，避免每帧 createUniform 的全局锁 + 字符串哈希）=====
    // 逐帧新建 uniform 句柄的开销：BgfxUniforms.createUniform 内部要取全局 bgfxCallMtx
    // 互斥锁 + 对 name 字符串求哈希；本 pass 每帧要取 20 个 uniform 句柄（7 个子 pass），
    // 故句柄在此一次性缓存后复用（按整数槽位索引，避免再引入字符串键哈希）。
    /** uniform 句柄槽位索引（与 _uniform 的 slot 参数对应）。 */
    private static let U_TEX_DIFFUSE: Int64 = 0
    private static let U_OPACITY: Int64 = 1
    private static let U_MASK_TEXTURE: Int64 = 2
    private static let U_TEX_SIZE: Int64 = 3
    private static let U_VISIBLE_EDGE_COLOR: Int64 = 4
    private static let U_HIDDEN_EDGE_COLOR: Int64 = 5
    private static let U_COLOR_TEXTURE: Int64 = 6
    private static let U_DIRECTION: Int64 = 7
    private static let U_KERNEL_RADIUS: Int64 = 8
    private static let U_EDGE_TEXTURE1: Int64 = 9
    private static let U_EDGE_TEXTURE2: Int64 = 10
    private static let U_PATTERN_TEXTURE: Int64 = 11
    private static let U_OVERLAY_PARAMS: Int64 = 12

    private var _uniformHandles: ArrayList<Option<UniformHandle>> = ArrayList<Option<UniformHandle>>()

    // ===== 复用的上传缓冲（逐帧新建 BgfxMemory 会走 bgfx_alloc 且永不归还 → 原生内存泄漏）=====
    // bgfx_set_uniform / bgfx_set_view_transform / bgfx_set_transform 在调用时即把数据
    // memcpy 进引擎内部缓冲，故同一块内存可安全跨帧复用。
    // 注：view 与 proj 矩阵必须用两块独立缓冲（set_view_transform 一次读走两者，
    // 共用一块会让后写覆盖先写）。
    // vec4 uniform 走基类 Pass._uploadMem / _setVec4Uniform 的槽位复用机制。
    private var _viewMemStore: Option<BgfxMemory> = None
    private var _projMemStore: Option<BgfxMemory> = None
    private var _mtxMemStore: Option<BgfxMemory> = None
    /** 复用的脉冲颜色实例（避免逐帧新建两个 Color 堆对象）。 */
    private let _pulseColor1: Color = Color(1.0, 1.0, 1.0)
    private let _pulseColor2: Color = Color(0.1, 0.04, 0.02)

    /**
     * @brief[zh-cn] 取槽位 slot 对应的 uniform 句柄（首次创建后缓存，逐帧复用）
     * @param[zh-cn] slot 槽位编号（见 U_* 常量）
     * @param[zh-cn] name uniform 名称
     * @param[zh-cn] uniformType uniform 类型
     * @return[zh-cn] uniform 句柄
     *
     * @brief[en] Gets the uniform handle of `slot` (created once, then cached and reused)
     * @param[en] slot Slot index (see the U_* constants)
     * @param[en] name Uniform name
     * @param[en] uniformType Uniform type
     * @return[en] Uniform handle
     */
    private func _uniform(slot: Int64, name: String, uniformType: UInt32): UniformHandle {
        while (this._uniformHandles.size <= slot) {
            this._uniformHandles.add(None)
        }
        if (let Some(h) <- this._uniformHandles[Int64(slot)]) {
            return h
        }
        let h = this._passUniforms().createUniform(name, uniformType)
        this._uniformHandles[Int64(slot)] = Some(h)
        return h
    }

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
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
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
        if (let Some(renderer) <- this._renderer) {
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
        }
    }

    /**
     * 销毁所有 RT。
     */
    private func _destroyRTs(): Unit {
        if (!this._rtsCreated) {
            return
        }
        if (let Some(renderer) <- this._renderer) {
            renderer.destroyFrameBuffer(this._maskFB)
            renderer.destroyTexture(this._maskTex)
            renderer.destroyTexture(this._maskDepthTex)
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
                // 经 renderer.render 走 Mesh filter；Cangjie 用 `if (let Some(_) <- (o as Mesh))` 下转检查（参考 BgfxShadowPass）。
                if (let Some(_) <- (o as Mesh)) {
                    this._selectionCache.add(o)
                }
            })
        }
    }

    /**
     * 执行 Outline pass。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 不用，结果写 readBuffer）
     * @param readBuffer 读 buffer（renderToScreen=false 时写这里）
     * @param deltaTime 帧间隔
     */
    @Zone[three.rendering.postprocessing.OutlinePass.render, name=outlinePass]
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

        // 准备选中缓存（_isSelected 判定"选中物体"的唯一依据）
        this._updateSelectionCache()

        // ===== 1. 选中物体 → maskRT =====
        // 非选中物体先渲深度（写入 maskRT 的 depth attachment），选中物体再以
        // DEPTH_TEST_LESS 写入颜色——被遮挡的选中片元深度测试失败 → 不写 mask。
        //
        // 注：可见性开关（_changeVisibilityOf*）已移除——本 pass 直接提交几何体
        // （setVertexBufferWithLayout + submit），不经 renderer.render 的可见性过滤，
        // 参与提交与否完全由 _isSelected 决定，开关只是徒增场景遍历与闭包分配。
        this._renderSceneToMask(renderer)
        this._selectionCache.clear()

        // ===== 2. materialCopy 把 maskBuffer 降采样到 maskDownBuffer =====
        this._renderDownsample(renderer)

        // 准备脉冲颜色（复用 Color 实例，避免逐帧新建两个堆对象）
        let pulseColor1 = this._pulseColor1
        let pulseColor2 = this._pulseColor2
        pulseColor1.r = this.visibleEdgeColor.r
        pulseColor1.g = this.visibleEdgeColor.g
        pulseColor1.b = this.visibleEdgeColor.b
        pulseColor2.r = this.hiddenEdgeColor.r
        pulseColor2.g = this.hiddenEdgeColor.g
        pulseColor2.b = this.hiddenEdgeColor.b
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

    // ===== 几何 submit 工具（参照 SSAO._createVB/_createIB/_getOrCreateLayout/_setViewTransformFor） =====

    /**
     * 取共享顶点 layout handle（缓存复用）。
     */
    private func _getOrCreateLayout(renderer: ThreeRenderer): VertexLayoutHandle {
        if (let Some(lh) <- this._layoutHandleCache) {
            return lh
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
        let geomId = geom.id
        if (let Some(vb) <- this._vbCache.get(geomId)) {
            return vb
        }
        let posAttrOpt = geom.getAttribute("position")
        if (let Some(pos) <- posAttrOpt) {
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
                if (let Some(na) <- normAttrOpt) {
                    data[base + 3] = na.getX(vi)
                    data[base + 4] = na.getY(vi)
                    data[base + 5] = na.getZ(vi)
                } else { data[base + 5] = 1.0 }
                if (let Some(ca) <- colAttrOpt) {
                    data[base + 6] = ca.getX(vi)
                    data[base + 7] = ca.getY(vi)
                    data[base + 8] = ca.getZ(vi)
                    data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                } else {
                    for (j in 0..4) { data[base + 6 + j] = 1.0 }
                }
                if (let Some(ua) <- uvAttrOpt) {
                    data[base + 10] = ua.getX(vi)
                    data[base + 11] = ua.getY(vi)
                }
            }
            let mem = BgfxMemory(UInt32(totalFloats * 4))
            mem.writeFloats(data, totalFloats)
            let layout = this._getOrCreateLayout(renderer)
            let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
            this._vbCache.add(geomId, handle)
            return handle
        } else { return INVALID_VERTEX_BUFFER_HANDLE }
    }

    /**
     * 创建/复用 geometry 的索引缓冲（按 geomId 缓存）。
     */
    private func _createIB(renderer: ThreeRenderer, geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.id
        if (let Some(ib) <- this._ibCache.get(geomId)) {
            return ib
        }
        if (let Some(idxAttr) <- geom.index) {
            let count = idxAttr.count
            if (count == 0) { return INVALID_INDEX_BUFFER_HANDLE }
            let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
            let mem = BgfxMemory(UInt32(count * 2))
            mem.writeUInt16(idxData, count)
            let handle = renderer.createIndexBuffer(mem, flags: 0u16)
            this._ibCache.add(geomId, handle)
            return handle
        } else { return INVALID_INDEX_BUFFER_HANDLE }
    }

    /**
     * 设置 view 的相机变换（view + projection 矩阵）。
     *
     * 用 renderer.setViewTransform 高阶 API（自身走 execBgfx 序列化到渲染线程）。
     */
    private func _setViewTransformFor(renderer: ThreeRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.elements
        let projArr = camera.projectionMatrix.elements
        // 复用缓冲：view 与 proj 各一块（set_view_transform 一次读走两者，不能共用）
        let viewMem = if (let Some(m) <- this._viewMemStore) {
            m
        } else {
            let m = BgfxMemory(64u32)
            this._viewMemStore = Some(m)
            m
        }
        let projMem = if (let Some(m) <- this._projMemStore) {
            m
        } else {
            let m = BgfxMemory(64u32)
            this._projMemStore = Some(m)
            m
        }
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
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
     * 渲染场景到 maskRT（选中物体 → 白色 mask，view 独立）。
     *
     * bgfx 差异：不走 renderer.render（其 _collectRenderObjects 不检查 visible，
     * 且 finishRender 触发 bgfx_frame 破坏 composer 帧序），
     * 改为遍历场景直接 submit（参照 SSAO._renderDepth 模式）。
     * 用独立 view id（OUTLINE_VIEW_ID_BASE+2），不碰 view 0。
     *
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
        if (let None <- this._whiteProg) {
            if (let Some(sp) <- PostProcessingShaders.get("outline_white")) {
                sp.compileBgfx()
                this._whiteProg = Some(Box(sp.programHandle))
            } else {
                @LogTrace(["OutlinePass", "outline_white shader NOT REGISTERED"])
                return
            }
        }
        if (let Some(progRaw) <- this._whiteProg) {
            if (!Handle.isValid(progRaw)) { return }
            let prog = progRaw
            // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear / 变换
            this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
            this.setRenderTarget(renderer, viewId, this._maskFB)
            this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR | BgfxConstants.CLEAR_DEPTH, 0x00000000u32)
            this._setViewTransformFor(renderer, viewId, this.renderCamera)
            // 几何提交 API 走 renderer 高阶 API（对齐 SSAOPass._renderNormals）
            let renderObjects = renderer.getSceneMeshes(this.renderScene)
            let layout = this._getOrCreateLayout(renderer)
            // 复用的 bgfx 变换内存（setTransform 经 execBgfx 同步消费，可安全复用）
            let mtxMem = if (let Some(m) <- this._mtxMemStore) {
                m
            } else {
                let m = BgfxMemory(64u32)
                this._mtxMemStore = Some(m)
                m
            }

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
        }
        @LogTrace(["OutlinePass", "_renderSceneToMask done"])
    }

    /**
     * 降采样：materialCopy 把 maskBuffer 拷到 maskDownBuffer。
     *
     * 用 outline_copy shader（copy + 不透明）做全屏四边形降采样。
     */
    private func _renderDownsample(renderer: ThreeRenderer): Unit {
        // 程序句柄缓存：原实现每帧重新查 PostProcessingShaders + Box 包装，
        // 改为首次解析后缓存句柄。
        if (let None <- this._copyProg) {
            this._ensureShaders()
        }
        if (let Some(progRaw) <- this._copyProg) {
            if (!Handle.isValid(progRaw)) { return }
            let prog = progRaw
            let viewId = UInt16(UInt16(OutlinePass.OUTLINE_VIEW_ID_BASE) + 7u16)
            let dw = UInt16(this._downW)
            let dh = UInt16(this._downH)
            // 高阶 API（各自走 execBgfx）设置 view 矩形 / 渲染目标 / clear
            this.setViewport(renderer, viewId, 0u16, 0u16, dw, dh)
            this.setRenderTarget(renderer, viewId, this._maskDownFB)
            this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
            // bindTexture / setUniform 高阶 API（各自走 execBgfx）
            let uTex = this._uniform(OutlinePass.U_TEX_DIFFUSE, "tDiffuse", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uTex, this._maskTex, 0u32)
            let uOpacity = this._uniform(OutlinePass.U_OPACITY, "u_opacity", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uOpacity, 0, 1.0, 0.0, 0.0, 0.0)
            this.submitQuad(viewId, prog)
        } else {
            @LogTrace(["OutlinePass", "outline_copy shader NOT REGISTERED"])
        }
    }

    /**
     * 边缘检测：edgeDetectionMaterial 对 maskDownBuffer 做边缘检测 → edge1Buffer。
     */
    private func _renderEdgeDetection(renderer: ThreeRenderer, pulseColor1: Color, pulseColor2: Color): Unit {
        if (let None <- this._edgeDetectionProg) {
            this._ensureShaders()
        }
        if (let Some(progRaw) <- this._edgeDetectionProg) {
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
            let uMask = this._uniform(OutlinePass.U_MASK_TEXTURE, "maskTexture", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uMask, this._maskDownTex, 0u32)
            let uTexSize = this._uniform(OutlinePass.U_TEX_SIZE, "texSize", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uTexSize, 1, Float64(this._downW), Float64(this._downH), 0.0, 0.0)
            let uVis = this._uniform(
                OutlinePass.U_VISIBLE_EDGE_COLOR,
                "visibleEdgeColor",
                UniformType.Vec4.value()
            )
            this._setVec4Uniform(renderer, uVis, 2, pc1.r, pc1.g, pc1.b, 1.0)
            let uHid = this._uniform(
                OutlinePass.U_HIDDEN_EDGE_COLOR,
                "hiddenEdgeColor",
                UniformType.Vec4.value()
            )
            this._setVec4Uniform(renderer, uHid, 3, pc2.r, pc2.g, pc2.b, 1.0)
            this.submitQuad(viewId, prog)
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
        if (let None <- this._separableBlurProg) {
            this._ensureShaders()
        }
        if (let Some(progRaw) <- this._separableBlurProg) {
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
            let uColor = this._uniform(
                OutlinePass.U_COLOR_TEXTURE,
                "colorTexture",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 0u8, uColor, this._edge1Tex, 0u32)
            let uTexSize = this._uniform(OutlinePass.U_TEX_SIZE, "texSize", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uTexSize, 4, Float64(this._downW), Float64(this._downH), 0.0, 0.0)
            let uDir = this._uniform(OutlinePass.U_DIRECTION, "direction", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uDir, 5, 1.0, 0.0, 0.0, 0.0)  // X
            let uKernel = this._uniform(
                OutlinePass.U_KERNEL_RADIUS,
                "kernelRadius",
                UniformType.Vec4.value()
            )
            this._setVec4Uniform(renderer, uKernel, 6, et, 0.0, 0.0, 0.0)
            this.submitQuad(viewH, prog)

            // V：blur1 → edge1
            let viewV = UInt16(UInt16(baseView) + 10u16)
            this.setViewport(renderer, viewV, 0u16, 0u16, dw, dh)
            this.setRenderTarget(renderer, viewV, this._edge1FB)
            this.clearRenderTarget(renderer, viewV, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
            let uColor2 = this._uniform(
                OutlinePass.U_COLOR_TEXTURE,
                "colorTexture",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 0u8, uColor2, this._blur1Tex, 0u32)
            let uDir2 = this._uniform(OutlinePass.U_DIRECTION, "direction", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uDir2, 7, 0.0, 1.0, 0.0, 0.0)  // Y
            this.submitQuad(viewV, prog)
        }
    }

    /**
     * 模糊2：separableBlurMaterial2 (1/4 分辨率) H/V 模糊 → edge2Buffer。
     */
    private func _renderBlur2(renderer: ThreeRenderer): Unit {
        if (let None <- this._separableBlurProg) {
            this._ensureShaders()
        }
        if (let Some(progRaw) <- this._separableBlurProg) {
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
            let uColor = this._uniform(
                OutlinePass.U_COLOR_TEXTURE,
                "colorTexture",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 0u8, uColor, this._edge1Tex, 0u32)
            let uDir = this._uniform(OutlinePass.U_DIRECTION, "direction", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uDir, 8, 1.0, 0.0, 0.0, 0.0)  // X
            this.submitQuad(viewH, prog)

            // V：edge2 → edge2（同 buffer，1/4 分辨率）
            // 注意：bgfx view 同 frame buffer 可二次 submit，但 view clear 仅首次生效
            // 这里用单独 view id（+13）避免 H view 的 clear 残留
            let viewV = UInt16(UInt16(baseView) + 13u16)
            this.setViewport(renderer, viewV, 0u16, 0u16, qw, qh)
            this.setRenderTarget(renderer, viewV, this._edge2FB)
            this.clearRenderTarget(renderer, viewV, BgfxConstants.CLEAR_COLOR, 0x00000000u32)
            let uColor2 = this._uniform(
                OutlinePass.U_COLOR_TEXTURE,
                "colorTexture",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 0u8, uColor2, this._edge2Tex, 0u32)
            let uDir2 = this._uniform(OutlinePass.U_DIRECTION, "direction", UniformType.Vec4.value())
            this._setVec4Uniform(renderer, uDir2, 9, 0.0, 1.0, 0.0, 0.0)  // Y
            this.submitQuad(viewV, prog)
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
        if (let None <- this._overlayProg) {
            this._ensureShaders()
        }
        if (let Some(progRaw) <- this._overlayProg) {
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
            // stage 0=tDiffuse(场景), 1=maskTexture, 2=edgeTexture1, 3=edgeTexture2, 4=patternTexture
            let uScene = this._uniform(OutlinePass.U_TEX_DIFFUSE, "tDiffuse", UniformType.Sampler.value())
            this.bindTexture(renderer, 0u8, uScene, sceneTex, 0u32)
            let uMask = this._uniform(OutlinePass.U_MASK_TEXTURE, "maskTexture", UniformType.Sampler.value())
            this.bindTexture(renderer, 1u8, uMask, this._maskTex, 0u32)
            let uEdge1 = this._uniform(
                OutlinePass.U_EDGE_TEXTURE1,
                "edgeTexture1",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 2u8, uEdge1, this._edge1Tex, 0u32)
            let uEdge2 = this._uniform(
                OutlinePass.U_EDGE_TEXTURE2,
                "edgeTexture2",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 3u8, uEdge2, this._edge2Tex, 0u32)
            // patternTexture 占位：用 maskTex（不实际使用 pattern）
            let uPattern = this._uniform(
                OutlinePass.U_PATTERN_TEXTURE,
                "patternTexture",
                UniformType.Sampler.value()
            )
            this.bindTexture(renderer, 4u8, uPattern, this._maskTex, 0u32)
            let uParams = this._uniform(
                OutlinePass.U_OVERLAY_PARAMS,
                "u_overlayParams",
                UniformType.Vec4.value()
            )
            this._setVec4Uniform(renderer, uParams, 10, es, eg, upt, 0.0)
            this.submitQuad(viewId, prog)
        }
    }

    /**
     * 编译所有 outline shader（首次）。
     * shader 已在 PostProcessingShaders 注册。
     */
    private func _ensureShaders(): Unit {
        // copy shader（降采样）
        if (let None <- this._copyProg) {
            if (let Some(sp) <- PostProcessingShaders.get("outline_copy")) {
                sp.compileBgfx()
                this._copyProg = Some(Box(sp.programHandle))
            } else {
                @LogTrace(["OutlinePass", "outline_copy shader NOT REGISTERED"])
            }
        }
        // edgeDetection shader
        if (let None <- this._edgeDetectionProg) {
            if (let Some(sp) <- PostProcessingShaders.get("outline_edge_detection")) {
                sp.compileBgfx()
                this._edgeDetectionProg = Some(Box(sp.programHandle))
            } else {
                @LogTrace(["OutlinePass", "outline_edge_detection shader NOT REGISTERED"])
            }
        }
        // separableBlur shader
        if (let None <- this._separableBlurProg) {
            if (let Some(sp) <- PostProcessingShaders.get("outline_separable_blur")) {
                sp.compileBgfx()
                this._separableBlurProg = Some(Box(sp.programHandle))
            } else {
                @LogTrace(["OutlinePass", "outline_separable_blur shader NOT REGISTERED"])
            }
        }
        // overlay shader
        if (let None <- this._overlayProg) {
            if (let Some(sp) <- PostProcessingShaders.get("outline_overlay")) {
                sp.compileBgfx()
                this._overlayProg = Some(Box(sp.programHandle))
            } else {
                @LogTrace(["OutlinePass", "outline_overlay shader NOT REGISTERED"])
            }
        }
    }

    /**
     * 释放 OutlinePass 占用的 GPU 资源（所有 RT + shader 缓存）。
     */
    public override func release(): Bool {
        this._destroyRTs()
        this._copyProg = None
        this._whiteProg = None
        this._edgeDetectionProg = None
        this._separableBlurProg = None
        this._overlayProg = None
        // 释放共享顶点布局句柄（_getOrCreateLayout 经 renderer.createVertexLayout 创建）
        if (let Some(renderer) <- this._renderer && let Some(lh) <- this._layoutHandleCache) {
            renderer.destroyVertexLayout(lh)
            this._layoutHandleCache = None
        }
        // 必须经 _disposePassUniforms() 释放，否则 composer 重建/切换后句柄泄漏（同 SMAA 修复点①）。
        this._disposePassUniforms()
        return true
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
