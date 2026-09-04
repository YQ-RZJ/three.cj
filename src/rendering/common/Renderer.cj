/**
 * @file[zh-cn] 渲染器
 * @brief[zh-cn] 渲染器调度层，编排 _render(scene, camera) 完整流程
 * @explain[zh-cn] Renderer 是渲染器抽象基类，编排渲染调度流程：renderContexts.get → renderLists.get → renderList.init() → _collectRenderObjects → renderList.finish() → backend.beginRender → backend.draw → backend.finishRender。BgfxRenderer 继承 Renderer 提供 bgfx 具体实现。对照源码: three.js/src/renderers/common/Renderer.js
 *
 * @file[en] Renderer
 * @brief[en] Renderer scheduling layer, orchestrating the _render(scene, camera) complete flow
 * @explain[en] Renderer is the abstract base class for the renderer, orchestrating the rendering dispatch flow: renderContexts.get → renderLists.get → renderList.init() → _collectRenderObjects → renderList.finish() → backend.beginRender → backend.draw → backend.finishRender. BgfxRenderer extends Renderer to provide the bgfx concrete implementation. Reference: three.js/src/renderers/common/Renderer.js
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
import three.utils.log.Logger

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
     * @brief[zh-cn] 渲染宽度
     *
     * @brief[en] Render width
     */
    public var width: Int64 = 800

    /**
     * @brief[zh-cn] 渲染高度
     *
     * @brief[en] Render height
     */
    public var height: Int64 = 600

    /**
     * @brief[zh-cn] 像素比
     *
     * @brief[en] Pixel ratio
     */
    public var pixelRatio: Float64 = 1.0

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
     * @param[zh-cn] w 渲染宽度
     * h 渲染高度
     *
     * @brief[en] Set rendering dimensions
     * @param[en] w Render width
     * h Render height
     */
    public func setSize(w: Int64, h: Int64): Unit {
        this.width = w
        this.height = h
    }

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
    public open func _render(scene: Scene, camera: Camera): Unit {
        let renderContext = this.renderContexts.get(scene, camera)
        let renderList = this.renderLists.get(scene, camera)
        // BUGFIX: RenderList 在 RenderLists 缓存中跨帧复用，
        // 若不在帧开始时清空 opaque/transparent 列表，_collectRenderObjects
        // 每帧 append 会导致渲染项无限累积（N 帧后渲染 N×objs 个 draw call）。
        // 对照 Three.js RenderList.begin() → 在 renderList.init() 中重置。
        renderList.clear()

        // 填充 RenderContext 的 viewport/viewId/clearColor
        // 对照 Three.js RenderContext: viewport 由 renderer 尺寸决定，viewId 固定为 0（主渲染 view）
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

        // 收集渲染对象
        this._collectRenderObjects(scene, renderList, camera)
        Logger.trace(["_render", "frame=${this.info.frame} collected=${renderList.finish().size} overrideMaterial=${match (scene.overrideMaterial) { case Some(_) => "Some" case None => "None" }}"])

        // 排序并获取渲染项
        let renderItems = renderList.finish()
        Logger.trace(["_render", "frame=${this.info.frame} renderItems=${renderItems.size}"])

        // 阴影深度预 pass（对照 Three.js WebGLShadowMap：在主渲染前生成阴影贴图）
        // 子类 backend override prepareShadowMap 实现具体阴影深度 pass；基类默认 no-op。
        Logger.trace(["_render", "BEFORE prepareShadowMap frame=${this.info.frame}"])
        this.backend.prepareShadowMap(scene)
        Logger.trace(["_render", "AFTER prepareShadowMap frame=${this.info.frame}"])

        
        // 每只眼用各自 viewport（camera2.viewport）渲染一次 renderScene。
        // 仓颉侧：cameraXR（ArrayCamera）的 cameras 为左右眼，i=0 左半屏、i=1 右半屏。
        // ★bgfx 注意：左右眼必须用独立 viewId（左 0 / 右 1）——bgfx 的 view clear 与
        // view rect 是 per-view 状态，共用 viewId 时右眼不执行 clear（每帧仅首次 submit
        // 触发）→ 右半屏残留上一帧内容（中线附近随机色彩），且左右眼 view transform
        // 互相覆盖（按下时左眼黑）。bgfx_frame 每帧只能调用一次，双眼分支统一在
        // 最后调一次 finishRender（内部 bgfx_frame_cj），避免一帧双 swap。
        match (camera as ArrayCamera) {
            case Some(ac) =>
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
                    for (item in renderItems) {
                        let effectiveMat = match (scene.overrideMaterial) {
                            case Some(om) => om
                            case None => item.material
                        }
                        this.backend.bindShadowUniforms()
                        let ro = this.renderObjects.get(
                            item.object, item.geometry, effectiveMat,
                            renderContext, eyeCam, scene
                        )
                        this.backend.draw(ro)
                    }
                    // 注意：不在每眼循环内调 finishRender（其内部 bgfx_frame_cj 每帧仅允许一次）
                }
                // 统一结束渲染 pass（touch + bgfx_frame 一次）
                this.backend.finishRender(renderContext)
                this.info.frame += 1
                return
            case None =>
                // ★修复：单眼渲染流程（普通 Camera/PerpectiveCamera，非 ArrayCamera）。
                // 此前重构双眼分支时误把单眼流程删成空操作，导致普通相机渲染全黑
                // （beginRender/background/draw 全部丢失，只剩 blitShadowMap + finishRender）。
                
                this.backend.beginRender(renderContext)
                this.background.render(scene)
                for (item in renderItems) {
                    let effectiveMat = match (scene.overrideMaterial) {
                        case Some(om) => om
                        case None => item.material
                    }
                    this.backend.bindShadowUniforms()
                    let ro = this.renderObjects.get(
                        item.object, item.geometry, effectiveMat,
                        renderContext, camera, scene
                    )
                    this.backend.draw(ro)
                }
        }

        // 全屏 blit 阴影贴图到屏幕（debug mode 6 用；对照 bgfx4cj-last BgfxRenderer.blitShadowMap）
        // 由测试侧 scene.flag 指示是否启用（默认不启用，仅 sp_shadowmap 测试设标志位）。
        match (scene.userData.get("shadowBlit")) {
            case Some(_) => this.backend.blitShadowMap(UInt16(0))
            case None => ()
        }

        // 结束渲染 pass
        this.backend.finishRender(renderContext)

        this.info.frame += 1
    }

    /**
     * @brief[zh-cn] 子类钩子，填充子类专有的 RenderContext 字段
     * @explain[zh-cn] 基类默认 no-op。子类（如 BgfxRenderer）可重写此方法，填充 clearColor 等子类专有字段。
     * @param[zh-cn] renderContext 待填充的渲染上下文
     *
     * @brief[en] Subclass hook for filling subclass-specific RenderContext fields
     * @explain[en] Base class default is no-op. Subclasses (e.g., BgfxRenderer) can override this method to fill subclass-specific fields like clearColor.
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
     * @explain[en] Base class default returns 0 (main render view). Subclasses (BgfxRenderer) can override to return this.viewId, allowing scene rendering to switch to other views.
     * @return[en] bgfx view id
     */
    public open func getRenderViewId(): UInt16 {
        return 0u16
    }

    /**
     * @brief[zh-cn] 递归收集场景中的渲染对象
     * @explain[zh-cn] 遍历场景及子节点，对 Mesh、Line、Points、Sprite 类型对象计算相机空间深度并加入渲染列表。
     * @param[zh-cn] obj 当前遍历的节点
     * renderList 渲染列表
     * camera 相机
     *
     * @brief[en] Recursively collect render objects from the scene
     * @explain[en] Traverses the scene and child nodes, calculates camera-space depth for Mesh, Line, Points, Sprite objects and adds them to the render list.
     * @param[en] obj Current node being traversed
     * renderList Render list
     * camera Camera
     */
    public open func _collectRenderObjects(obj: Object3D, renderList: RenderList, camera: Camera): Unit {
        // 遍历子节点
        for (child in obj.children) {
            // 先递归子节点
            if (child.children.size > 0) {
                this._collectRenderObjects(child, renderList, camera)
            }

            // 检查是否为渲染对象类型（children 均为 Object3D，原 isObject3D 字段已删除，恒真判断直接展开）
            // 跳过不可见对象（对照 three.js: _collectRenderObjects 跳过 obj.visible === false；
            // 反射面在渲反射贴图时需临时隐藏自身，靠此过滤防止地面出现在反射 RT 中）
            if (!child.visible) { continue }
            // 获取 geometry 和 material
            match (child) {
                case mesh: Mesh =>
                    let geom = mesh.geometry
                    let mat = mesh.material

                    // 计算 z（相机空间深度）
                    let worldPos = mesh.matrixWorld.getPosition()
                    let camPos = camera.position
                    let dz = worldPos.z - camPos.z
                    let z: Float64 = if (dz < 0.0001 && dz > -0.0001) { 0.0 } else { dz }

                    renderList.push(
                        mesh,
                        geom,
                        mat,
                        0,                   // groupOrder
                        Int64(mesh.renderOrder),    // renderOrder
                        z,                   // z
                        0                    // group
                    )
                case line: Line =>
                    // Line/LineSegments 同样参与渲染（EdgesGeometry/WireframeGeometry 用
                    // LineSegments 渲染，此前只有 Mesh 分支导致线不可见）
                    let lgeom = line.geometry
                    let lmat = line.material
                    let lpos = line.matrixWorld.getPosition()
                    let ldz = lpos.z - camera.position.z
                    let lz: Float64 = if (ldz < 0.0001 && ldz > -0.0001) { 0.0 } else { ldz }
                    renderList.push(
                        line,
                        lgeom,
                        lmat,
                        0,                   // groupOrder
                        Int64(line.renderOrder),    // renderOrder
                        lz,                  // z
                        0                    // group
                    )
                case points: Points =>
                    // Points 点云参与渲染（POINTS 图元，BgfxBackend 按材质/对象类型选择）。
                    // 对照 three.js _collectRenderObjects：Points 是 renderable 对象。
                    let pgeom = points.geometry
                    let pmat = points.material
                    let ppos = points.matrixWorld.getPosition()
                    let pdz = ppos.z - camera.position.z
                    let pz: Float64 = if (pdz < 0.0001 && pdz > -0.0001) { 0.0 } else { pdz }
                    renderList.push(
                        points,
                        pgeom,
                        pmat,
                        0,                   // groupOrder
                        Int64(points.renderOrder),  // renderOrder
                        pz,                  // z
                        0                    // group
                    )
                case sprite: Sprite =>
                    // Sprite 广告牌参与渲染：Sprite 无 geometry 字段（对照 JS Sprite 无几何，
                    // 渲染用共享单位面片）。此处构造单位 quad 面片，spriteVS 广告牌变换
                    // 按对象 scale 放大（u_model[0]/[1] 轴长）并始终朝向相机。
                    let sgeom = Sprite._getUnitQuadGeometry()
                    let smat = sprite.material
                    let spos = sprite.matrixWorld.getPosition()
                    let sdz = spos.z - camera.position.z
                    let sz: Float64 = if (sdz < 0.0001 && sdz > -0.0001) { 0.0 } else { sdz }
                    renderList.push(
                        sprite,
                        sgeom,
                        smat,
                        0,                   // groupOrder
                        Int64(sprite.renderOrder),  // renderOrder
                        sz,                  // z
                        0                    // group
                    )
                case _ => ()  // 非 Mesh/Line/Points/Sprite 对象跳过
            }
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
    public open func render(scene: Scene, camera: Camera): Unit {
        this.info.reset()

        // 更新场景图（包括所有子节点）
        if (scene.matrixAutoUpdate) {
            scene.updateMatrixWorld(true)
        }
        // 相机可能不在场景层级中，需单独更新其世界矩阵
        camera.updateMatrixWorld(true)

        // 执行核心渲染调度
        this._render(scene, camera)
    }
}
