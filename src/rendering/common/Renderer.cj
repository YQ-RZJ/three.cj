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
 * @file[zh-cn] 渲染器
 * @brief[zh-cn] 渲染器调度层，编排 _render(scene, camera) 完整流程
 * @explain[zh-cn] Renderer 是渲染器抽象基类，编排渲染调度流程：renderContexts.get → renderLists.get → renderList.init() → _collectRenderObjects → renderList.finish() → backend.beginRender → backend.draw → backend.finishRender。ThreeRenderer 继承 Renderer 提供 bgfx 具体实现。
 *
 * @file[en] Renderer
 * @brief[en] Renderer scheduling layer, orchestrating the _render(scene, camera) complete flow
 * @explain[en] Renderer is the abstract base class for the renderer, orchestrating the rendering dispatch flow: renderContexts.get → renderLists.get → renderList.init() → _collectRenderObjects → renderList.finish() → backend.beginRender → backend.draw → backend.finishRender. ThreeRenderer extends Renderer to provide the bgfx concrete implementation.
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.materials.*
import three.rendering.cameras.*
import three.rendering.textures.*
import std.collection.*
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*

/**
 * @brief[zh-cn] 自动实例化分组：同组成员的渲染项与网格引用
 * @explain[zh-cn] 收集阶段已完成类型判定，分组时顺带缓存 Mesh 引用，
 *               烘焙实例矩阵时无需再做一次向下转型（800 对象 × 每帧 3 次转型
 *               是合批路由阶段的主要开销之一）。
 *
 * @brief[en] Auto-instancing group: render items plus cached mesh references
 * @explain[en] Type checks are already done during collection, so the group also
 *               caches the Mesh references, sparing a downcast when baking the
 *               instance matrices (three casts per object per frame were a
 *               major cost of the batching route).
 */
private class InstGroup {
    let items: ArrayList<RenderItem> = ArrayList<RenderItem>(64)
    let meshes: ArrayList<Mesh> = ArrayList<Mesh>(64)

    init() {}
}

/**
 * @brief[zh-cn] 渲染器抽象基类
 * @explain[zh-cn] Renderer 是渲染器抽象基类，管理渲染后端、渲染列表、渲染上下文、渲染对象等子系统，提供清除控制、颜色空间、色调映射、排序等配置，并编排完整的渲染调度流程。
 *
 * @brief[en] Abstract base class for the renderer
 * @explain[en] Renderer is the abstract base class for the renderer, managing rendering backend, render lists, render contexts, render objects and other subsystems, providing clear control, color space, tone mapping, sorting and other configurations, and orchestrating the complete rendering dispatch flow.
 */
public open class Renderer {

    // ===== 后端与子系统 =====

    /**
     * @brief[zh-cn] 渲染后端
     *
     * @brief[en] Rendering backend
     */
    public var backend: Backend

    /**
     * @brief[zh-cn] 渲染列表缓存
     *
     * @brief[en] Render lists cache
     */
    public var renderLists: RenderLists

    /**
     * @brief[zh-cn] 渲染上下文缓存
     *
     * @brief[en] Render contexts cache
     */
    public var renderContexts: RenderContexts

    /**
     * @brief[zh-cn] 渲染对象缓存
     *
     * @brief[en] Render objects cache
     */
    public var renderObjects: RenderObjects

    /**
     * @brief[zh-cn] 帧序号（每次 render() 自增）
     * @explain[zh-cn] 供帧级缓存（如场景网格缓存）判断"是否跨帧"，避免同一帧内
     *               多个后期处理 pass 重复遍历整棵场景树。
     *
     * @brief[en] Frame index (incremented on every render())
     * @explain[en] Lets frame-scoped caches (e.g. the scene mesh cache) detect frame
     *               boundaries, so several post-processing passes in one frame do not
     *               each walk the whole scene tree.
     */
    public var frameIndex: Int64 = 0

    /**
     * @brief[zh-cn] 帧级场景网格缓存
     *
     * @brief[en] Frame-level scene mesh cache
     */
    private var _sceneMeshCache: SceneMeshCache = SceneMeshCache()

    // ===== 渲染统计 =====

    /**
     * @brief[zh-cn] 渲染统计信息
     *
     * @brief[en] Rendering statistics info
     */
    public var info: Info = Info()

    // ===== 清除控制 =====

    /**
     * @brief[zh-cn] 是否自动清除帧缓冲
     *
     * @brief[en] Whether to auto-clear the frame buffer
     */
    public var autoClear: Bool = true

    /**
     * @brief[zh-cn] 是否自动清除颜色缓冲
     *
     * @brief[en] Whether to auto-clear the color buffer
     */
    public var autoClearColor: Bool = true

    /**
     * @brief[zh-cn] 是否自动清除深度缓冲
     *
     * @brief[en] Whether to auto-clear the depth buffer
     */
    public var autoClearDepth: Bool = true

    /**
     * @brief[zh-cn] 是否自动清除模板缓冲
     *
     * @brief[en] Whether to auto-clear the stencil buffer
     */
    public var autoClearStencil: Bool = true

    // ===== 渲染状态 =====

    /**
     * @brief[zh-cn] 是否启用透明
     *
     * @brief[en] Whether alpha is enabled
     */
    public var alpha: Bool = true

    /**
     * @brief[zh-cn] 是否启用深度缓冲
     *
     * @brief[en] Whether depth buffer is enabled
     */
    public var depth: Bool = true

    /**
     * @brief[zh-cn] 是否启用模板缓冲
     *
     * @brief[en] Whether stencil buffer is enabled
     */
    public var stencil: Bool = false

    // ===== 颜色空间与色调映射 =====

    /**
     * @brief[zh-cn] 输出颜色空间
     *
     * @brief[en] Output color space
     */
    public var outputColorSpace: String = "srgb"

    /**
     * @brief[zh-cn] 色调映射模式
     *
     * @brief[en] Tone mapping mode
     */
    public var toneMapping: Int64 = 0  // NoToneMapping

    /**
     * @brief[zh-cn] 色调映射曝光度
     *
     * @brief[en] Tone mapping exposure
     */
    public var toneMappingExposure: Float64 = 1.0

    // ===== 深度缓冲 =====

    /**
     * @brief[zh-cn] 是否启用对数深度缓冲
     *
     * @brief[en] Whether logarithmic depth buffer is enabled
     */
    public var logarithmicDepthBuffer: Bool = false

    /**
     * @brief[zh-cn] 是否启用反转深度缓冲
     *
     * @brief[en] Whether reversed depth buffer is enabled
     */
    public var reversedDepthBuffer: Bool = false

    // ===== 排序控制 =====

    /**
     * @brief[zh-cn] 是否自动排序渲染对象
     *
     * @brief[en] Whether to auto-sort render objects
     */
    public var sortObjects: Bool = true

    // ===== 子系统 =====

    /**
     * @brief[zh-cn] 光照管理器
     *
     * @brief[en] Lighting manager
     */
    public var lighting: Lighting = Lighting()

    /**
     * @brief[zh-cn] 采样数（MSAA）
     *
     * @brief[en] Sample count (MSAA)
     */
    public var samples: Int64 = 0

    // ===== 尺寸 =====

    /**
     * @brief[zh-cn] 渲染宽度（物理像素 / 后备缓冲宽度）
     * @explain[zh-cn] 内部渲染目标宽度，已乘以 pixelRatio。如需逻辑尺寸请使用 getSize()。
     *
     * @brief[en] Render width (physical pixels / backbuffer width)
     * @explain[en] Internal render target width, already multiplied by pixelRatio. Use getSize() for logical dimensions.
     */
    public var width: Int64 = 800

    /**
     * @brief[zh-cn] 渲染高度（物理像素 / 后备缓冲高度）
     * @explain[zh-cn] 内部渲染目标高度，已乘以 pixelRatio。如需逻辑尺寸请使用 getSize()。
     *
     * @brief[en] Render height (physical pixels / backbuffer height)
     * @explain[en] Internal render target height, already multiplied by pixelRatio. Use getSize() for logical dimensions.
     */
    public var height: Int64 = 600

    /**
     * @brief[zh-cn] 像素比
     * @explain[zh-cn] 物理像素与逻辑像素的比值，默认 1.0。设置为窗口 DPI 缩放因子可在 HiDPI 屏幕上获得清晰渲染。
     *
     * @brief[en] Pixel ratio
     * @explain[en] Ratio of physical pixels to logical pixels, defaults to 1.0. Set to the window DPI scale factor for crisp rendering on HiDPI displays.
     */
    public var pixelRatio: Float64 = 1.0

    /**
     * @brief[zh-cn] 逻辑宽度（setSize 传入值）
     *
     * @brief[en] Logical width (value passed to setSize)
     */
    private var _logicalWidth: Int64 = 800

    /**
     * @brief[zh-cn] 逻辑高度（setSize 传入值）
     *
     * @brief[en] Logical height (value passed to setSize)
     */
    private var _logicalHeight: Int64 = 600

    // ===== 已有子系统（兼容既有代码） =====

    /**
     * @brief[zh-cn] 渲染包管理器
     *
     * @brief[en] Render bundles manager
     */
    public var renderBundles: RenderBundles = RenderBundles()

    /**
     * @brief[zh-cn] 背景渲染器
     *
     * @brief[en] Background renderer
     */
    public var background: Background = Background()

    /**
     * @brief[zh-cn] 构造器，指定渲染后端和渲染选项
     * @param[zh-cn] backend 渲染后端实例
     * alpha 是否启用透明，默认 true
     * depth 是否启用深度缓冲，默认 true
     * stencil 是否启用模板缓冲，默认 false
     * antialias 是否启用抗锯齿，默认 false
     * samples 采样数，0 表示自动，默认 0
     * logarithmicDepthBuffer 是否启用对数深度缓冲，默认 false
     * reversedDepthBuffer 是否启用反转深度缓冲，默认 false
     *
     * @brief[en] Constructor with specified backend and rendering options
     * @param[en] backend Rendering backend instance
     * alpha Whether to enable alpha, default true
     * depth Whether to enable depth buffer, default true
     * stencil Whether to enable stencil buffer, default false
     * antialias Whether to enable antialiasing, default false
     * samples Sample count, 0 for auto, default 0
     * logarithmicDepthBuffer Whether to enable logarithmic depth buffer, default false
     * reversedDepthBuffer Whether to enable reversed depth buffer, default false
     */
    public init(backend: Backend,
                alpha!: Bool = true,
                depth!: Bool = true,
                stencil!: Bool = false,
                antialias!: Bool = false,
                samples!: Int64 = 0,
                logarithmicDepthBuffer!: Bool = false,
                reversedDepthBuffer!: Bool = false) {
        this.backend = backend

        this.alpha = alpha
        this.depth = depth
        this.stencil = stencil
        this.logarithmicDepthBuffer = logarithmicDepthBuffer
        this.reversedDepthBuffer = reversedDepthBuffer

        // 计算采样数
        var computedSamples: Int64 = 0
        if (samples > 0) {
            computedSamples = samples
        } else if (antialias) {
            computedSamples = 4
        } else {
            computedSamples = 0
        }
        this.samples = computedSamples

        // 实例化子系统
        this.renderLists = RenderLists()
        this.renderContexts = RenderContexts()
        this.renderObjects = RenderObjects()
        this.info = Info()
        this.lighting = Lighting()
        this.background = Background()

        // 初始化已有子系统
    }

    /**
     * @brief[zh-cn] 默认无参构造器，向后兼容
     *
     * @brief[en] Default no-argument constructor for backward compatibility
     */
    public init() {
        this.backend = Backend()
        this.renderLists = RenderLists()
        this.renderContexts = RenderContexts()
        this.renderObjects = RenderObjects()
        this.info = Info()
        this.lighting = Lighting()
        this.background = Background()
    }

    // ===== 尺寸设置 =====

    /**
     * @brief[zh-cn] 设置渲染尺寸
     * @param[zh-cn] w 渲染逻辑宽度
     * h 渲染逻辑高度
     * @explain[zh-cn] 内部会乘以 pixelRatio 得到物理后备缓冲尺寸。如需直接设置物理尺寸，请同时调整 pixelRatio=1.0 后调用本方法。
     *
     * @brief[en] Set rendering dimensions
     * @param[en] w Render logical width
     * h Render logical height
     * @explain[en] Internally multiplies by pixelRatio to obtain the physical backbuffer dimensions. To set physical dimensions directly, set pixelRatio=1.0 before calling this method.
     */
    public func setSize(w: Int64, h: Int64): Unit {
        this._logicalWidth = w
        this._logicalHeight = h
        this.width = Int64(Float64(w) * this.pixelRatio)
        this.height = Int64(Float64(h) * this.pixelRatio)
    }

    /**
     * @brief[zh-cn] 获取逻辑渲染尺寸
     * @return[zh-cn] (逻辑宽度, 逻辑高度)
     *
     * @brief[en] Get logical rendering dimensions
     * @return[en] (logical width, logical height)
     */
    public func getSize(): (Int64, Int64) {
        return (this._logicalWidth, this._logicalHeight)
    }

    /**
     * @brief[zh-cn] 设置像素比
     * @param[zh-cn] value 新的像素比（必须 > 0）
     * @explain[zh-cn] 修改 pixelRatio 后会用当前逻辑尺寸重新计算物理尺寸。通常在 initBgfx 之前根据窗口 DPI 设置。
     *
     * @brief[en] Set pixel ratio
     * @param[en] value New pixel ratio (must be > 0)
     * @explain[en] After changing pixelRatio, physical dimensions are recalculated from the current logical dimensions. Usually set according to the window DPI before initBgfx.
     */
    public func setPixelRatio(value: Float64): Unit {
        if (value <= 0.0) { return }
        this.pixelRatio = value
        this.setSize(this._logicalWidth, this._logicalHeight)
    }

    /**
     * @brief[zh-cn] 获取当前像素比
     * @return[zh-cn] 像素比
     *
     * @brief[en] Get current pixel ratio
     * @return[en] Pixel ratio
     */
    public func getPixelRatio(): Float64 {
        return this.pixelRatio
    }

    // ===== 视锥剔除与自动合批（内部复用对象，避免每帧分配） =====

    /**
     * @brief[zh-cn] 视锥体（单眼），每帧由投影×视图矩阵提取 6 平面
     *
     * @brief[en] Frustum (monocular), 6 planes extracted from projection×view matrix each frame
     */
    private var _frustum: Frustum = Frustum()

    /**
     * @brief[zh-cn] 视锥体集合（ArrayCamera 多眼），每帧逐眼提取平面
     *
     * @brief[en] Frustum collection (ArrayCamera multi-eye), planes extracted per eye each frame
     */
    private var _frustumArray: FrustumArray = FrustumArray()

    /**
     * @brief[zh-cn] 投影×视图矩阵，提取视锥平面与计算排序深度共用
     *
     * @brief[en] Projection×view matrix, shared by frustum plane extraction and sort depth computation
     */
    private var _projScreenMatrix: Matrix4 = Matrix4()

    /**
     * @brief[zh-cn] 排序深度计算的复用向量（投影空间 z）
     *
     * @brief[en] Reused vector for sort depth computation (projected space z)
     */
    private var _cullVector: Vector3 = Vector3()

    /**
     * @brief[zh-cn] 当前帧是否使用 ArrayCamera 视锥集合
     *
     * @brief[en] Whether the current frame uses the ArrayCamera frustum collection
     */
    private var _usingArrayFrustum: Bool = false

    /**
     * @brief[zh-cn] 自动实例化聚合缓存：键 "(geometry.uuid|material.uuid)" → 跨帧复用的聚合 InstancedMesh
     * @explain[zh-cn] 聚合对象跨帧复用保证 id 稳定（RenderObjects 缓存键含 mesh.id），每帧仅重填 instanceMatrix/count。
     *
     * @brief[en] Auto-instancing aggregate cache: key "(geometry.uuid|material.uuid)" → reused InstancedMesh across frames
     * @explain[en] Aggregate objects are reused across frames to keep id stable (RenderObjects cache key contains mesh.id); each frame only refills instanceMatrix/count.
     */
    private var _autoInstancingMeshes: HashMap<Int64, InstancedMesh> = HashMap<Int64, InstancedMesh>()
    /**
     * @brief[zh-cn] 合批分组对象池（跨帧复用，避免每帧重建分组列表）
     *
     * @brief[en] Batching group pool (reused across frames)
     */
    private var _instGroupPool: ArrayList<InstGroup> = ArrayList<InstGroup>(16)
    /**
     * @brief[zh-cn] 合批分组池游标
     *
     * @brief[en] Batching group pool cursor
     */
    private var _instGroupPoolUsed: Int64 = 0
    /**
     * @brief[zh-cn] 合批分组表（跨帧复用，避免每帧重建哈希表）
     * @explain[zh-cn] 每帧分组时复用同一张表：clear 后重新填充，保留哈希表容量，
     *               避免每帧分配/扩容一次哈希表（大场景每帧数百次插入）。
     *
     * @brief[en] Batching group table (reused across frames)
     * @explain[en] The same table is reused every frame: cleared and refilled, keeping the
     *               hash table capacity, avoiding a per-frame allocation/expansion.
     */
    private var _instGroups: HashMap<Int64, InstGroup> = HashMap<Int64, InstGroup>(64)
    /**
     * @brief[zh-cn] 场景空间索引缓存（scene.id → 索引）
     * @explain[zh-cn] 空间索引把场景可剔除对象组织成 BVH，把"逐对象视锥测试"降为
     *               O(log N + K)。索引按场景缓存：BVH 与相机无关，多相机共享同一份。
     *
     * @brief[en] Scene spatial index cache (scene.id → index)
     * @explain[en] The spatial index organizes a scene's cullable objects into a BVH,
     *               reducing per-object frustum tests to O(log N + K). Cached per scene:
     *               the BVH is camera independent and shared across cameras.
     */
    private var _cullIndexes: HashMap<Int64, SceneCullIndex> = HashMap<Int64, SceneCullIndex>(8)
    /**
     * @brief[zh-cn] 启用空间剔除的最小对象数
     * @explain[zh-cn] 对象数少于该阈值时 BVH 的查询收益不足以抵消索引维护成本，
     *               继续走逐对象视锥测试路径（行为与性能均与优化前一致）。
     *
     * @brief[en] Minimum object count for enabling spatial culling
     * @explain[en] Below this threshold the BVH query gains do not offset the index
     *               maintenance cost, so the per-object frustum test path is kept
     *               (identical behavior and performance to the pre-optimization path).
     */
    private let _spatialCullingThreshold: Int64 = 32
    /**
     * @brief[zh-cn] 空间剔除是否启用（本帧）
     * @explain[zh-cn] 由 _updateSpatialCulling 按索引对象数与阈值决定；关闭时
     *               _isCulled 回退到逐对象视锥测试，行为与优化前完全一致。
     *
     * @brief[en] Whether spatial culling is active (this frame)
     * @explain[en] Decided by _updateSpatialCulling from the indexed object count and the
     *               threshold; when off, _isCulled falls back to per-object frustum tests
     *               with behavior identical to the pre-optimization path.
     */
    private var _spatialCullingActive: Bool = false
    /**
     * @brief[zh-cn] 是否启用空间剔除（BVH 加速）
     * @explain[zh-cn] 关闭后退回逐对象视锥测试路径（行为与优化前一致），可用于
     *               对照验证空间剔除结果、或在特殊场景下临时禁用。
     *
     * @brief[en] Whether spatial culling (BVH acceleration) is enabled
     * @explain[en] When off, the per-object frustum test path is used (behavior identical
     *               to the pre-optimization path). This allows validating spatial culling
     *               results by comparison, or temporarily disabling it in special cases.
     */
    public var enableSpatialCulling: Bool = true

    // ===== _render 核心调度（子类可重写） =====

    /**
     * @brief[zh-cn] 渲染调度主流程，编排完整的渲染管线
     * @explain[zh-cn] 完整流程：获取渲染上下文 → 获取渲染列表 → 清空列表 → 收集渲染对象 → 排序 → 阴影预 pass → 开始渲染 → 绘制 → 结束渲染
     * @param[zh-cn] scene 场景
     * camera 相机
     *
     * @brief[en] Main rendering dispatch flow, orchestrating the complete rendering pipeline
     * @explain[en] Complete flow: get render context → get render list → clear list → collect render objects → sort → shadow pre-pass → begin render → draw → finish render
     * @param[en] scene Scene
     * camera Camera
     */
    @Zone[three.rendering.common.Renderer._render]
    public open func _render(scene: Scene, camera: Camera): Unit {
        let renderContext = this.renderContexts.get(scene, camera)
        let renderList = this.renderLists.get(scene, camera)
        // BUGFIX: RenderList 在 RenderLists 缓存中跨帧复用，
        // 若不在帧开始时清空 opaque/transparent 列表，_collectRenderObjects
        // 每帧 append 会导致渲染项无限累积（N 帧后渲染 N×objs 个 draw call）。
        // 对照通用渲染列表的 begin() 语义 → 在 renderList.init() 中重置。
        renderList.clear()

        // 填充 RenderContext 的 viewport/viewId/clearColor
        // 对照通用渲染上下文约定：viewport 由 renderer 尺寸决定，viewId 固定为 0（主渲染 view）
        // clearColor 由子类（BgfxRenderer）通过 _fillRenderContext 钩子填充
        renderContext.viewId = this.getRenderViewId()
        renderContext.viewport = (0, 0, Int32(this.width), Int32(this.height))
        renderContext.scissor = (0, 0, Int32(this.width), Int32(this.height))
        renderContext.width = this.width
        renderContext.height = this.height
        // 填充相机矩阵：view = matrixWorldInverse，proj = projectionMatrix
        let viewArr = camera.matrixWorldInverse.elements
        let projArr = camera.projectionMatrix.elements
        for (i in 0..16) {
            renderContext.viewMatrix[i] = viewArr[i]
            renderContext.projMatrix[i] = projArr[i]
        }
        this._fillRenderContext(renderContext)

        // 构建视锥（渲染器每帧遍历场景图时的通用做法：projScreenMatrix = proj * view → frustum.setFromProjectionMatrix）
        // ArrayCamera 多眼走 FrustumArray（逐眼平面）；单眼走 Frustum（6 平面）。
        // _projScreenMatrix 同时用于排序深度计算（两种相机类型都计算，保证 z 有值）。
        this._projScreenMatrix.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse)
        if (let Some(ac) <- (camera as ArrayCamera)) {
            this._usingArrayFrustum = true
            this._frustumArray.setFromArrayCamera(ac)
        } else {
            this._usingArrayFrustum = false
            this._frustum.setFromProjectionMatrix(this._projScreenMatrix)
        }

        // 空间索引：批量判定对象是否落在视锥内（结果写入对象标记，供 _isCulled 读取）
        this._updateSpatialCulling(scene)

        // 收集渲染对象
        this._collectRenderObjects(scene, renderList, camera)

        // 自动实例化路由：将同几何+同材质的静态网格聚合为 InstancedMesh（排序前完成，对照方案 C3）
        this._routeAutoInstancing(renderList)
        @LogTrace(["_render", "frame=${this.info.frame} collected=${renderList.finish().size} overrideMaterial=${if (let Some(_) <- scene.overrideMaterial) { "Some" } else { "None" }}"])

        // 排序并获取渲染项
        let renderItems = renderList.finish()
        @LogTrace(["_render", "frame=${this.info.frame} renderItems=${renderItems.size}"])

        // 阴影深度预 pass（对照 WebGL 阴影贴图管理模型：在主渲染前生成阴影贴图）
        // 子类 backend override prepareShadowMap 实现具体阴影深度 pass；基类默认 no-op。
        @LogTrace(["_render", "BEFORE prepareShadowMap frame=${this.info.frame}"])
        this.backend.prepareShadowMap(scene)
        @LogTrace(["_render", "AFTER prepareShadowMap frame=${this.info.frame}"])

        
        // 每只眼用各自 viewport（camera2.viewport）渲染一次 renderScene。
        // 仓颉侧：cameraXR（ArrayCamera）的 cameras 为左右眼，i=0 左半屏、i=1 右半屏。
        // ★bgfx 注意：左右眼必须用独立 viewId（左 0 / 右 1）——bgfx 的 view clear 与
        // view rect 是 per-view 状态，共用 viewId 时右眼不执行 clear（每帧仅首次 submit
        // 触发）→ 右半屏残留上一帧内容（中线附近随机色彩），且左右眼 view transform
        // 互相覆盖（按下时左眼黑）。bgfx_frame 每帧只能调用一次，双眼分支统一在
        // 最后调一次 finishRender（内部 bgfx_frame_cj），避免一帧双 swap。
        if (let Some(ac) <- (camera as ArrayCamera)) {
            let baseView = this.getRenderViewId()
            let eyeCount = ac.cameras.size
            let halfW = Int32(this.width) / Int32(max(1, eyeCount))
            for (ei in 0..eyeCount) {
                let eyeCam = ac.cameras[ei]
                // 每眼独立 viewId：左眼 baseView、右眼 baseView+1（bgfx per-view 状态隔离）
                renderContext.viewId = UInt16(UInt32(baseView) + UInt32(ei))
                // 设置该眼视口（左/右半屏）与相机矩阵
                renderContext.viewport = (Int32(ei) * halfW, 0, halfW, Int32(this.height))
                renderContext.scissor = (Int32(ei) * halfW, 0, halfW, Int32(this.height))
                let eView = eyeCam.matrixWorldInverse.elements
                let eProj = eyeCam.projectionMatrix.elements
                for (i in 0..16) {
                    renderContext.viewMatrix[i] = eView[i]
                    renderContext.projMatrix[i] = eProj[i]
                }
                // 开始渲染 pass（每眼一次：各自 clear + view transform）
                this.backend.beginRender(renderContext)
                this.background.render(scene)
                // 对每个渲染项执行 draw（用该眼相机）
                this._drawRenderItems(renderItems, renderContext, eyeCam, scene)
                // 注意：不在每眼循环内调 finishRender（其内部 bgfx_frame_cj 每帧仅允许一次）
            }
            // 统一结束渲染 pass（touch + bgfx_frame 一次）
            this.backend.finishRender(renderContext)
            // 帧末驱逐：移除本帧未被访问的 RenderObject（从场景移除的对象不再被缓存持有）
            this.renderObjects.endFrame()
            this.info.frame += 1
            return
        } else {
            // ★修复：单眼渲染流程（普通 Camera/PerpectiveCamera，非 ArrayCamera）。
            // 此前重构双眼分支时误把单眼流程删成空操作，导致普通相机渲染全黑
            // （beginRender/background/draw 全部丢失，只剩 blitShadowMap + finishRender）。
            
            this.backend.beginRender(renderContext)
            this.background.render(scene)
            // 逐项绘制循环单独计时（见 _drawRenderItems）
            this._drawRenderItems(renderItems, renderContext, camera, scene)
        }

        // 全屏 blit 阴影贴图到屏幕（debug mode 6 用；对照 bgfx4cj-last ThreeRenderer.blitShadowMap）
        // 由测试侧 scene.flag 指示是否启用（默认不启用，仅 sp_shadowmap 测试设标志位）。
        if (let Some(_) <- scene.userData.get("shadowBlit")) {
            this.backend.blitShadowMap(UInt16(0))
        }

        // 结束渲染 pass
        this.backend.finishRender(renderContext)

        // 同步后端渲染统计到抽象层 info（draw call / 三角形数，供 renderer.info 消费方读取）
        this._syncRenderStats()

        // 帧末驱逐：移除本帧未被访问的 RenderObject（从场景移除的对象不再被缓存持有）
        this.renderObjects.endFrame()
        this.info.frame += 1
    }

    /**
     * @brief[zh-cn] 后端渲染统计同步钩子（帧末调用）
     * @explain[zh-cn] 基类默认 no-op。bgfx 等具体后端在直接提交路径（不走 BufferRenderer）
     * 不会触发 info.update，绘制统计落在后端私有 info 上；子类覆写此方法把后端统计
     * 同步到 this.info.render 并清零后端计数，保证 renderer.info 每帧读到本帧数据。
     *
     * @brief[en] Backend render stats sync hook (called at frame end)
     * @explain[en] Base class default is no-op. Concrete backends like bgfx bypass BufferRenderer on
     * direct submit paths, so draw stats accumulate in the backend-private info; subclasses override
     * this to sync backend stats into this.info.render and reset backend counters, ensuring renderer.info
     * reflects the current frame.
     */
    protected open func _syncRenderStats(): Unit {
        // base: no-op，子类按需重写
    }

    /**
     * @brief[zh-cn] 子类钩子，填充子类专有的 RenderContext 字段
     * @explain[zh-cn] 基类默认 no-op。子类（如 BgfxRenderer）可重写此方法，填充 clearColor 等子类专有字段。
     * @param[zh-cn] renderContext 待填充的渲染上下文
     *
     * @brief[en] Subclass hook for filling subclass-specific RenderContext fields
     * @explain[en] Base class default is no-op. Subclasses (e.g., ThreeRenderer) can override this method to fill subclass-specific fields like clearColor.
     * @param[en] renderContext Render context to be filled
     */
    public open func _fillRenderContext(renderContext: RenderContext): Unit {
        // base: no-op，子类按需重写
    }

    /**
     * @brief[zh-cn] 获取当前渲染使用的 bgfx view id
     * @explain[zh-cn] 基类默认返回 0（主渲染 view）。子类（BgfxRenderer）可重写返回 this.viewId，允许将场景渲染切到其他 view。
     * @return[zh-cn] bgfx view id
     *
     * @brief[en] Get the bgfx view id used for current rendering
     * @explain[en] Base class default returns 0 (main render view). Subclasses (ThreeRenderer) can override to return this.viewId, allowing scene rendering to switch to other views.
     * @return[en] bgfx view id
     */
    public open func getRenderViewId(): UInt16 {
        return 0u16
    }

    /**
     * @brief[zh-cn] 递归收集场景中的渲染对象
     * @explain[zh-cn] 遍历场景及子节点，对 Mesh、Line、Points、Sprite 类型对象计算投影空间深度并加入渲染列表。
     * 对齐场景图遍历的通用语义：先判可见性与视锥剔除，不可见/被剔除则跳过整棵子树，再递归子节点。
     * （修复：此前实现"先递归子节点后判 visible"，导致不可见节点的子节点仍被提交绘制。）
     * @param[zh-cn] obj 当前遍历的节点
     * renderList 渲染列表
     * camera 相机
     *
     * @brief[en] Recursively collect render objects from the scene
     * @explain[en] Traverses the scene and child nodes, calculates projected-space depth for Mesh, Line, Points, Sprite objects and adds them to the render list.
     * Aligns with the usual scene-graph traversal semantics: check visibility and frustum culling first, skip the entire subtree if invisible/culled, then recurse into children.
     * (Fix: the previous implementation recursed before checking visible, causing children of invisible nodes to still be submitted for drawing.)
     * @param[en] obj Current node being traversed
     * renderList Render list
     * camera Camera
     */
    @Zone[three.rendering.common.Renderer._collectRenderObjects]
    public open func _collectRenderObjects(obj: Object3D, renderList: RenderList, camera: Camera): Unit {
        // 遍历子节点
        for (child in obj.children) {
            // 先判可见性与剔除：不可见/被剔除则跳过整棵子树（对照场景图遍历流程）
            if (!child.visible) { continue }
            if (this._isCulled(child)) { continue }

            // 递归子节点
            if (child.children.size > 0) {
                this._collectRenderObjects(child, renderList, camera)
            }

            // 检查是否为渲染对象类型（children 均为 Object3D，原 isObject3D 字段已删除，恒真判断直接展开）
            // 获取 geometry 和 material
            match (child) {
                case mesh: Mesh =>
                    let geom = mesh.geometry
                    let mat = mesh.material

                    renderList.push(
                        mesh,
                        geom,
                        mat,
                        0,                   // groupOrder
                        Int64(mesh.renderOrder),    // renderOrder
                        this._computeProjectedZ(mesh.matrixWorld),  // z（投影空间深度）
                        0                    // group
                    )
                case line: Line =>
                    // Line/LineSegments 同样参与渲染（EdgesGeometry/WireframeGeometry 用
                    // LineSegments 渲染，此前只有 Mesh 分支导致线不可见）
                    let lgeom = line.geometry
                    let lmat = line.material
                    renderList.push(
                        line,
                        lgeom,
                        lmat,
                        0,                   // groupOrder
                        Int64(line.renderOrder),    // renderOrder
                        this._computeProjectedZ(line.matrixWorld),  // lz（投影空间深度）
                        0                    // group
                    )
                case points: Points =>
                    // Points 点云参与渲染（POINTS 图元，BgfxBackend 按材质/对象类型选择）。
                    // 对照渲染对象收集流程：Points 是 renderable 对象。
                    let pgeom = points.geometry
                    let pmat = points.material
                    renderList.push(
                        points,
                        pgeom,
                        pmat,
                        0,                   // groupOrder
                        Int64(points.renderOrder),  // renderOrder
                        this._computeProjectedZ(points.matrixWorld),  // pz（投影空间深度）
                        0                    // group
                    )
                case sprite: Sprite =>
                    // Sprite 广告牌参与渲染：Sprite 无 geometry 字段
                    // 此处构造单位 quad 面片，spriteVS 广告牌变换
                    // 按对象 scale 放大（u_model[0]/[1] 轴长）并始终朝向相机。
                    let sgeom = Sprite._getUnitQuadGeometry()
                    let smat = sprite.material
                    renderList.push(
                        sprite,
                        sgeom,
                        smat,
                        0,                   // groupOrder
                        Int64(sprite.renderOrder),  // renderOrder
                        this._computeProjectedZ(sprite.matrixWorld),  // sz（投影空间深度）
                        0                    // group
                    )
                case _ => ()  // 非 Mesh/Line/Points/Sprite 对象跳过
            }
        }
    }

    /**
     * @brief[zh-cn] 视锥剔除测试
     * @explain[zh-cn] frustumCulled=false 的对象永不剔除。单眼用 _frustum（6 平面对包围球测试），
     * ArrayCamera 用 _frustumArray（任一眼可见即不剔除）。对象无包围球时视为可见（见 Frustum.intersectsObject）。
     * @param[zh-cn] object 待测试对象
     * @return[zh-cn] true 表示被剔除（不可见）
     *
     * @brief[en] Frustum culling test
     * @explain[en] Objects with frustumCulled=false are never culled. Monocular uses _frustum (6-plane test against bounding sphere);
     * ArrayCamera uses _frustumArray (visible if any eye sees it). Objects without a bounding sphere are treated as visible (see Frustum.intersectsObject).
     * @param[en] object Object to test
     * @return[en] true if culled (invisible)
     */
    private func _isCulled(object: Object3D): Bool {
        if (!object.frustumCulled) { return false }
        // 空间索引已用 BVH 批量回答"是否落在视锥内"（结果写入 cullVisible）：
        // 命中与否在查询阶段一次算完，遍历时只读标记，省掉逐对象 6 平面测试。
        // 未被索引收录的对象（默认 cullVisible=true）按可见处理，行为与优化前一致。
        if (this._spatialCullingActive) {
            return !object.cullVisible
        }
        if (this._usingArrayFrustum) {
            return !this._frustumArray.intersectsObject(object)
        }
        return !this._frustum.intersectsObject(object)
    }

    /**
     * @brief[zh-cn] 刷新场景空间索引并执行视锥查询
     * @explain[zh-cn] 流程：结构版本变化时重建索引（对象增删）→ 刷新失效对象的包围球
     *               → BVH 视锥查询 → 结果写入各对象的 cullVisible 标记。
     *               索引对象数低于阈值时关闭空间剔除（走逐对象视锥测试路径）。
     * @param[zh-cn] scene 场景
     *
     * @brief[en] Refresh the scene spatial index and run the frustum query
     * @explain[en] Rebuild the index when the structure version changed (objects added or
     *               removed), refresh the bounds of stale objects, run the BVH frustum
     *               query, and write the results into each object's cullVisible flag.
     *               Spatial culling is disabled when the indexed object count is below
     *               the threshold (falling back to per-object frustum tests).
     * @param[en] scene Scene
     */
    private func _updateSpatialCulling(scene: Scene): Unit {
        // 关闭开关：回退到逐对象视锥测试路径
        if (!this.enableSpatialCulling) {
            this._spatialCullingActive = false
            return
        }
        var index = if (let Some(idx) <- this._cullIndexes.get(scene.id)) {
            idx
        } else {
            let created = SceneCullIndex()
            this._cullIndexes.add(scene.id, created)
            created
        }
        if (index.needsRebuild()) {
            index.rebuild(scene)
        }
        this._spatialCullingActive = index.indexedCount >= this._spatialCullingThreshold
        if (!this._spatialCullingActive) {
            return
        }
        if (this._usingArrayFrustum) {
            // 多眼相机：逐眼判断，任一眼可见即不剔除
            this._cullIndexes.get(scene.id).getOrThrow().queryArrayFrustum(this._frustumArray)
        } else {
            index.query(this._frustum)
        }
    }

    /**
     * @brief[zh-cn] 计算对象在投影空间的排序深度
     * @explain[zh-cn] 取 matrixWorld 平移分量经 projScreen 变换后的 z。相比旧实现"worldPos.z - camera.position.z"
     * （忽略相机旋转，斜视角下排序错误），投影空间深度对任意相机姿态都单调正确，直接对接 RenderList 三级排序。
     * @param[zh-cn] matrixWorld 对象世界矩阵
     * @return[zh-cn] 投影空间 z 值
     *
     * @brief[en] Compute the object's sort depth in projected space
     * @explain[en] Takes the matrixWorld translation component transformed by projScreen and returns z. Compared with the old
     * implementation "worldPos.z - camera.position.z" (ignoring camera rotation, wrong sorting under oblique views),
     * projected-space depth is monotonically correct for any camera orientation, feeding directly into RenderList's 3-level sort.
     * @param[en] matrixWorld Object world matrix
     * @return[en] Projected-space z value
     */
    private func _computeProjectedZ(matrixWorld: Matrix4): Float64 {
        this._cullVector.setFromMatrixPosition(matrixWorld)
        this._cullVector.applyMatrix4(this._projScreenMatrix)
        return this._cullVector.z
    }

    /**
     * @brief[zh-cn] 逐个渲染项提交绘制
     * @explain[zh-cn] 单独成方法以便用函数级 @Zone 计时：draw call 提交（含逐 draw 的
     *               uniform/纹理绑定）是主 pass 的主要成本，与场景收集/合批路由分离统计。
     * @param[zh-cn] renderItems 本帧渲染项
     * @param[zh-cn] renderContext 渲染上下文
     * @param[zh-cn] camera 相机
     * @param[zh-cn] scene 场景
     *
     * @brief[en] Submits a draw for each render item
     * @explain[en] Extracted into its own method so it can be timed with a function-level
     *
     *               @Zone: the draw call submission (including the per-draw uniform and
     *               texture binding) is the main cost of the main pass, measured apart
     *               from scene collection and batching.
     */
    @Zone[three.rendering.common.Renderer.drawLoop]
    private func _drawRenderItems(renderItems: ArrayList<RenderItem>, renderContext: RenderContext,
                                  camera: Camera, scene: Scene): Unit {
        for (item in renderItems) {
            let effectiveMat = if (let Some(om) <- scene.overrideMaterial) {
                om
            } else {
                item.material
            }
            this.backend.bindShadowUniforms()
            let ro = this.renderObjects.get(
                item.object, item.geometry, effectiveMat,
                renderContext, camera, scene
            )
            this.backend.draw(ro)
        }
    }

    /**
     * @brief[zh-cn] 自动实例化路由：将同几何+同材质的静态网格聚合为 InstancedMesh
     * @explain[zh-cn] 遍历本帧不透明渲染项，把 isStatic 的普通 Mesh（排除 InstancedMesh 等实例化子类）
     * 按 (geometry.uuid, material.uuid, castShadow, receiveShadow) 分组；组内 ≥2 成员时路由到 Renderer 级聚合缓存的复用
     * InstancedMesh：成员 matrixWorld 烘焙为实例矩阵（成员自身不改 visible，收集阶段每帧照常提交，路由在收集后进行），
     * 聚合项 frustumCulled=false（聚合包围球未计算，避免误裁）、z 取成员最远值；
     * 从渲染列表移除成员项并 push 聚合项。N 个同质 draw call 折叠为 1 个实例化 draw call。
     *
     * 阴影标志纳入分组键、聚合体沿用首成员标志：混合标志的成员若被合并，聚合体只保留首成员的标志，
     * 其余成员会丢失投射/接收阴影。
     *
     * 不以 isStatic 为前置条件：实例矩阵每帧从成员当前 matrixWorld 重新烘焙，运动物体同样正确；
     * 烘焙成本为 16 float/成员，远低于一次 draw call 的 CPU+驱动开销。
     * 路由发生在视锥剔除之后，被剔除对象不会进入分组，故合批不会削弱剔除。
     * @param[zh-cn] renderList 本帧渲染列表
     *
     * @brief[en] Auto-instancing route: aggregate meshes with same geometry+material into InstancedMesh
     * @explain[en] Iterates this frame's opaque render items, groups plain Meshes (excluding instancing subclasses like
     * InstancedMesh) by (geometry.uuid, material.uuid, castShadow, receiveShadow); when a group has ≥2 members, routes them to a
     * reused InstancedMesh in the Renderer-level aggregate cache: member matrixWorld baked as instance matrices (members keep
     * visible untouched; they are collected normally each frame, routing happens after collection), aggregate frustumCulled=false
     * (aggregate bounding sphere not computed, avoiding false culling), z takes the farthest member value; removes member items from
     * the render list and pushes the aggregate item. N homogeneous draw calls collapse into 1 instanced draw call.
     *
     * Shadow flags are part of the group key and the aggregate inherits the first member's flags: merging members with mixed flags
     * would keep only the first member's flags and lose cast/receive shadow on the others.
     *
     * isStatic is not a precondition: instance matrices are re-baked from each member's current matrixWorld every frame, so moving
     * objects stay correct; the bake costs 16 floats per member, far below the CPU+driver cost of a draw call. Routing happens after
     * frustum culling, so culled objects never enter a group and culling effectiveness is preserved.
     * @param[en] renderList Current frame's render list
     */
    @Zone[three.rendering.common.Renderer._routeAutoInstancing]
    private func _routeAutoInstancing(renderList: RenderList): Unit {
        let opaqueItems = renderList.getOpaqueItems()
        if (opaqueItems.size < 2) { return }

        // 按 (geometry.id, material.id, castShadow, receiveShadow) 分组普通 Mesh（保持首次出现顺序）。
        // 用整数复合键而非字符串键：几何体/材质都有进程内稳定整数 id，
        // 逐项拼 "uuid|uuid|bool|bool" 会每帧构造 N 个临时 String 并做长字符串哈希。
        // 位段：geom(24) | mat(24) | cast(1) | recv(1) → 合成 Int64，互不重叠。
        // 分组表跨帧复用：clear 后重新填充，保留哈希表容量（避免每帧重建表并扩容）
        let groups = this._instGroups
        groups.clear()
        // 分组对象池游标归零：本帧的分组对象从池中顺序取用（跨帧复用，保留容量）
        this._instGroupPoolUsed = 0
        for (item in opaqueItems) {
            let obj = item.object
            // 单次向下转型：原实现每项做 3 次（isMesh / isInstanced / getOrThrow），
            // 大场景下每帧数千次转型是路由阶段的主要开销。
            let meshOpt = obj as Mesh
            let mesh = if (let Some(m) <- meshOpt) {
                m
            } else {
                continue
            }
            if (mesh is InstancedMesh) { continue }
            // 阴影标志入键：聚合体沿用首成员的标志，混合标志的成员不能合并，否则丢阴影
            let flags = (if (mesh.castShadow) { 1 } else { 0 }) + (if (mesh.receiveShadow) { 2 } else { 0 })
            let key = (mesh.geometry.id << 26) | (mesh.material.id << 2) | flags
            if (let Some(g) <- groups.get(key)) {
                g.items.add(item)
                g.meshes.add(mesh)
            } else {
                // 取用池中的分组对象（清空后复用，保留 ArrayList 容量）
                let g = if (this._instGroupPoolUsed < this._instGroupPool.size) {
                    let pooled = this._instGroupPool[this._instGroupPoolUsed]
                    pooled.items.clear()
                    pooled.meshes.clear()
                    pooled
                } else {
                    let created = InstGroup()
                    this._instGroupPool.add(created)
                    created
                }
                this._instGroupPoolUsed += 1
                g.items.add(item)
                g.meshes.add(mesh)
                groups.add(key, g)
            }
        }
        if (groups.size == 0) { return }

        // 组内 ≥2 成员才路由（单实例走实例化反而多一次间接）
        var suppressedAny = false
        for ((key, group) in groups) {
            let members = group.items
            if (members.size < 2) { continue }
            let firstMesh = group.meshes[0]
            let geom = firstMesh.geometry
            let mat = firstMesh.material

            // 取跨帧复用的聚合 InstancedMesh（保证 id 稳定，RenderObjects 缓存键不抖动）
            // 单次查表：命中直接复用，未命中则创建后写入（原先连续两次 get 同一键）
            let agg = if (let Some(cached) <- this._autoInstancingMeshes.get(key)) {
                cached
            } else {
                let im = InstancedMesh(geometry: geom, material: mat, count: 0)
                im.isStatic = true
                im.frustumCulled = false  // 聚合包围球未计算，禁用剔除避免误裁
                im.matrixAutoUpdate = false
                // 阴影标志与首成员一致（分组键已保证同组成员标志相同）
                im.castShadow = firstMesh.castShadow
                im.receiveShadow = firstMesh.receiveShadow
                this._autoInstancingMeshes.add(key, im)
                im
            }

            // 容量不足时重建实例矩阵缓冲（成员数可能逐帧变化）
            if (agg.instanceMatrix.array.size < members.size * 16) {
                agg.instanceMatrix = InstancedBufferAttribute(
                    Array<Float64>(members.size * 16, { _ => 0.0 }), 16)
            }

            // 成员 matrixWorld 烘焙为实例矩阵（聚合自身 matrixWorld 保持单位阵：不在场景树中，从未被更新）
            var n: Int64 = 0
            var farZ = members[0].z
            let arr = agg.instanceMatrix.array
            for (i in 0..members.size) {
                let base = i * 16
                // 批量拷贝 16 个分量（copyTo 走 memcpy 路径，优于逐元素带边界检查的赋值）
                group.meshes[i].matrixWorld.elements.copyTo(arr, 0, base, 16)
                if (members[i].z > farZ) { farZ = members[i].z }
                n += 1
            }
            agg.count = n

            // 成员项只打标记，最后统一单遍压缩（逐项 removeOpaqueItem 是 O(n) 扫描，
            // 800 成员时退化为 O(n²)；且它会打乱不透明列表的原始顺序）
            for (item in members) {
                item.routeSuppressed = true
                suppressedAny = true
            }
            renderList.push(agg, geom, mat, members[0].groupOrder, members[0].renderOrder, farZ, 0)
        }
        if (suppressedAny) {
            renderList.removeOpaqueMarked()
        }
    }

    // ===== render 入口 =====

    /**
     * @brief[zh-cn] 渲染入口，更新场景变换矩阵后执行渲染
     * @param[zh-cn] scene 场景
     * camera 相机
     *
     * @brief[en] Rendering entry point, updates scene transform matrices and executes rendering
     * @param[en] scene Scene
     * camera Camera
     */
    @Zone[three.rendering.common.Renderer.render]
    public open func render(scene: Scene, camera: Camera): Unit {
        this.info.reset()
        // 帧号自增：帧级缓存（场景网格缓存）据此判断是否需要重建
        this.frameIndex += 1

        // 更新场景图与相机世界矩阵（单独计时：场景树规模大时，逐对象的世界矩阵
        // 重算是每帧的固定成本）
        this._updateWorldMatrices(scene, camera)

        // 执行核心渲染调度
        this._render(scene, camera)
    }

    /**
     * @brief[zh-cn] 获取本帧场景中的 Mesh 渲染对象列表（帧级共享缓存）
     * @explain[zh-cn] 供后期处理 pass（Outline/SSAO/SSR/SAO/GTAO/Mask/Bokeh/
     *               RenderPixelated）与阴影 pass 使用：同一帧内多个消费者共享
     *               同一份列表，避免各自重复遍历整棵场景树并重复分配 RenderObject。
     * @param[zh-cn] scene 场景根节点
     * visibleOnly 是否只返回可见对象（SSR 等 pass 需要跳过不可见对象防止自反射）
     * @return[zh-cn] Mesh 渲染对象列表（内部引用，调用方只读）
     *
     * @brief[en] Get this frame's list of Mesh render objects (frame-scoped shared cache)
     * @explain[en] Used by post-processing passes (Outline/SSAO/SSR/SAO/GTAO/Mask/
     *               Bokeh/RenderPixelated) and the shadow pass: several consumers in
     *               one frame share the same list instead of each walking the whole
     *               scene tree and allocating RenderObjects separately.
     * @param[en] scene Scene root node
     * visibleOnly Whether to return only visible objects (passes such as SSR skip
     *              invisible objects to avoid self-reflection)
     * @return[en] Mesh render object list (internal reference, read-only for callers)
     */
    public func getSceneMeshes(scene: Object3D, visibleOnly!: Bool = false): ArrayList<RenderObject> {
        return this._sceneMeshCache.get(scene, this.frameIndex, visibleOnly: visibleOnly)
    }

    /**
     * @brief[zh-cn] 更新场景树与相机的世界矩阵
     * @explain[zh-cn] 单独成方法以便用函数级 @Zone 计时：场景树规模大时，逐对象的
     *               世界矩阵重算是每帧的固定成本（与收集/合批/提交各阶段分离统计）。
     * @param[zh-cn] scene 场景
     * @param[zh-cn] camera 相机
     *
     * @brief[en] Updates the world matrices of the scene tree and the camera
     * @explain[en] Extracted into its own method so it can be timed with a function-level
     *
     *               @Zone: with a large scene tree the per-object world matrix update is
     *               a fixed per-frame cost, measured apart from collection/batching/submit.
     */
    @Zone[three.rendering.common.Renderer.updateMatrixWorld]
    private func _updateWorldMatrices(scene: Scene, camera: Camera): Unit {
        // 更新场景图（包括所有子节点）
        if (scene.matrixAutoUpdate) {
            scene.updateMatrixWorld(true)
        }
        // 相机可能不在场景层级中，需单独更新其世界矩阵
        camera.updateMatrixWorld(true)
    }
}
