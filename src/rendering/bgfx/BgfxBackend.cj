/**
 * @file[zh-cn] BgfxBackend 渲染后端
 * @brief[zh-cn] bgfx 渲染后端实现 — 完整即时命令模型
 * @explain[zh-cn] BgfxBackend 继承 Backend，实现全部即时命令接口，把 bgfx 延迟命令缓冲映射到 Backend 的即时命令模型。
 *
 * @file[en] BgfxBackend Rendering Backend
 * @brief[en] bgfx rendering backend implementation — full immediate command model
 * @explain[en] BgfxBackend extends Backend, implementing all immediate command interfaces, mapping bgfx deferred command buffers to Backend's immediate command model.
 */
package three.rendering.bgfx

import three.rendering.common.*
import three.rendering.shaders.ShaderLibs
import three.rendering.shaders.ShaderProgram
import three.rendering.shaders.ShaderVariant
import three.rendering.shaders.*
import three.rendering.textures.Texture
import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.core.math.*
import three.rendering.materials.*;
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.rendering.lights.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.intToCPointer
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.scene.entity.Mesh
import three.scene.entity.Line
import three.scene.entity.Points
import bgfx4cj.bgfx.*
import std.collection.*
import std.math.*
import std.runtime.*

/**
 * @brief[zh-cn] bgfx 渲染后端
 * @explain[zh-cn] 继承 common/Backend，把 bgfx 延迟命令缓冲映射到即时命令模型。即时命令流程：beginRender(renderContext) → draw(renderObject) → finishRender(renderContext)，每个调用立即 -> bgfx 延迟命令入队。bgfx_frame（双缓冲交换）在 finishRender 中触发。
 *
 * @brief[en] bgfx rendering backend
 * @explain[en] Extends common/Backend, mapping bgfx deferred command buffers to an immediate command model. Immediate command flow: beginRender(renderContext) → draw(renderObject) → finishRender(renderContext), each call immediately enqueues bgfx deferred commands. bgfx_frame (double buffer swap) is triggered in finishRender.
 */
/**
 * @brief[zh-cn] 光照计数 defines 字符串列表持有者
 * @explain[zh-cn] 用于在 _getOrCreateProgram 中构建 defines、编译后释放。已安全化：直接持有 Array<String>，由 compileBgfx 内部统一转为 C 字符串数组。
 *
 * @brief[en] Light defines string list holder
 * @explain[en] Used in _getOrCreateProgram to build defines, released after compilation. Safe: directly holds Array<String>, converted to C string array internally by compileBgfx.
 */
private class _LightDefinesHolder {
    let defs: Array<String>

    public init(defs!: Array<String>) {
        this.defs = defs
    }

    public func dispose(): Unit {
        // Array<String> 由 GC 管理，无需手动释放
    }
}

public class BgfxBackend <: Backend {
    /**
     * @brief[zh-cn] 扩展兼容层
     *
     * @brief[en] Extension compatibility layer
     */
    private var extensions: BgfxExtensions
    /**
     * @brief[zh-cn] 能力检测
     *
     * @brief[en] Capabilities detection
     */
    private var capabilities: BgfxCapabilities
    /**
     * @brief[zh-cn] 工具函数
     *
     * @brief[en] Utility functions
     */
    private var utils: BgfxUtils
    /**
     * @brief[zh-cn] 渲染状态
     *
     * @brief[en] Render state
     */
    private var state: BgfxState
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo
    /**
     * @brief[zh-cn] 属性存储
     *
     * @brief[en] Property storage
     */
    private var properties: BgfxProperties
    /**
     * @brief[zh-cn] 纹理管理
     *
     * @brief[en] Texture management
     */
    private var textures: BgfxTextures
    /**
     * @brief[zh-cn] Uniform 管理
     *
     * @brief[en] Uniform management
     */
    internal var uniforms: BgfxUniforms
    /**
     * @brief[zh-cn] 着色器编译
     *
     * @brief[en] Shader compilation
     */
    private var shader: BgfxShader
    /**
     * @brief[zh-cn] 着色器缓存
     *
     * @brief[en] Shader cache
     */
    private var shaderCache: BgfxShaderCache
    /**
     * @brief[zh-cn] 着色器程序
     *
     * @brief[en] Shader program
     */
    private var program: BgfxProgram
    /**
     * @brief[zh-cn] 着色器程序管理
     *
     * @brief[en] Shader program management
     */
    private var programs: BgfxPrograms
    /**
     * @brief[zh-cn] 属性缓冲
     *
     * @brief[en] Attribute buffers
     */
    private var attributes: BgfxAttributes
    /**
     * @brief[zh-cn] 绑定状态
     *
     * @brief[en] Binding states
     */
    private var bindingStates: BgfxBindingStates
    /**
     * @brief[zh-cn] 裁剪
     *
     * @brief[en] Clipping
     */
    private var clipping: BgfxClipping
    /**
     * @brief[zh-cn] 几何体管理
     *
     * @brief[en] Geometry management
     */
    private var geometries: BgfxGeometries
    /**
     * @brief[zh-cn] 对象管理
     *
     * @brief[en] Object management
     */
    private var objects: BgfxObjects
    /**
     * @brief[zh-cn] 材质管理
     *
     * @brief[en] Material management
     */
    private var materials: BgfxMaterials
    /**
     * @brief[zh-cn] 光照管理
     *
     * @brief[en] Light management
     */
    private var lights: BgfxLights
    /**
     * @brief[zh-cn] 阴影贴图
     *
     * @brief[en] Shadow map
     */
    internal var shadowMap: BgfxShadowMap
    /**
     * @brief[zh-cn] 背景
     *
     * @brief[en] Background
     */
    private var background: BgfxBackground
    /**
     * @brief[zh-cn] 输出处理
     *
     * @brief[en] Output handling
     */
    private var output: BgfxOutput
    /**
     * @brief[zh-cn] 环境贴图
     *
     * @brief[en] Environment maps
     */
    private var environments: BgfxEnvironments
    /**
     * @brief[zh-cn] 变形目标
     *
     * @brief[en] Morph targets
     */
    private var morphtargets: BgfxMorphtargets
    /**
     * @brief[zh-cn] 渲染列表
     *
     * @brief[en] Render lists
     */
    private var renderLists: BgfxRenderLists
    /**
     * @brief[zh-cn] 渲染状态栈
     *
     * @brief[en] Render state stack
     */
    private var renderStates: BgfxRenderStates
    /**
     * @brief[zh-cn] 动画
     *
     * @brief[en] Animation
     */
    private var animation: BgfxAnimation

    // ===== 当前帧光照计数（供 _getOrCreateProgram 构建 NUM_*_LIGHTS defines）=====
    // 对照原始有效实现 BgfxRenderer.getOrCreateProg（行 1332-1339）
    // 不传这些 defines 会导致 #if NUM_DIR_LIGHTS > 0 整段被预处理器剔除 → 物体渲染为黑
    private var _numDirLights: Int64 = 0
    private var _numPointLights: Int64 = 0
    private var _numSpotLights: Int64 = 0
    private var _numHemiLights: Int64 = 0
    // LightProbe 数量（供 _buildLightDefines 构建 USE_LIGHT_PROBES define）
    private var _numLightProbes: Int64 = 0
    // 阴影光源计数（对照参考项目 BgfxRenderer 行 178-180、456-461）
    // 不传 NUM_*_LIGHT_SHADOWS defines 会导致 Phong shader 的 shadowmap_pars_fragment / lights_pars_begin
    // 阴影分支被预处理器剔除 → 物体只有材质光照、无阴影投射效果（sp_fullphong 阴影缺失根因）
    private var _numDirShadowLights: Int64 = 0
    private var _numPointShadowLights: Int64 = 0
    private var _numSpotShadowLights: Int64 = 0

    // ===== 光源/阴影数量上限（可配置，编译 shader 时作为宏 NUM_*_LIGHTS_MAX 传入）=====
    // 对照 Three.js：光源数量由场景决定，本引擎用"配置上限"约束 shader 数组声明与手动展开段数。
    // 修改这些值后，_buildLightDefines 会生成对应的 NUM_*_LIGHTS_MAX 编译宏，
    // ShaderLibs.cj 的 uniform 数组声明与 lights_fragment_begin.cj 的循环展开段自动适配。
    // 注意：受 D3D11 纹理单元上限（16）约束，dir+spot+point 三类阴影 sampler 总数 ≤ 16。
    /**
     * @brief[zh-cn] 方向光数量上限（含无阴影的）
     *
     * @brief[en] Max directional lights (including non-shadowed)
     */
    public var maxDirLights: Int64 = 4
    /**
     * @brief[zh-cn] 点光源数量上限（含无阴影的）
     *
     * @brief[en] Max point lights (including non-shadowed)
     */
    public var maxPointLights: Int64 = 4
    /**
     * @brief[zh-cn] 聚光灯数量上限（含无阴影的）
     *
     * @brief[en] Max spot lights (including non-shadowed)
     */
    public var maxSpotLights: Int64 = 4
    /**
     * @brief[zh-cn] 半球光数量上限
     *
     * @brief[en] Max hemisphere lights
     */
    public var maxHemiLights: Int64 = 4
    /**
     * @brief[zh-cn] 带阴影的方向光数量上限
     *
     * @brief[en] Max directional shadow lights
     */
    public var maxDirShadows: Int64 = 4
    /**
     * @brief[zh-cn] 带阴影的点光源数量上限（cube 阴影，每个占 1 个纹理单元）
     *
     * @brief[en] Max point shadow lights (cube shadow, each occupies 1 texture unit)
     */
    public var maxPointShadows: Int64 = 2
    /**
     * @brief[zh-cn] 带阴影的聚光灯数量上限
     *
     * @brief[en] Max spot shadow lights
     */
    public var maxSpotShadows: Int64 = 2

    /**
     * @brief[zh-cn] 常量
     *
     * @brief[en] Constants
     */
    private var constants: BgfxConstants

    // ===== 组合注入的辅助 pass（internal，包内跨文件访问共享资源） =====
    /**
     * @brief[zh-cn] 阴影深度预 pass + 主 pass 阴影 uniform 绑定（initialize 中 bindBackend 注入宿主引用）
     *
     * @brief[en] Shadow depth pre-pass + main pass shadow uniform binding (bindBackend injects host reference in initialize)
     */
    internal var shadowPass: BgfxShadowPass = BgfxShadowPass()
    /**
     * @brief[zh-cn] 光照收集 + 光源/相机 uniform 绑定（initialize 中 bindBackend 注入宿主引用）
     *
     * @brief[en] Light collection + light/camera uniform binding (bindBackend injects host reference in initialize)
     */
    internal var lightBinder: BgfxLightBinder = BgfxLightBinder()
    /**
     * @brief[zh-cn] 全屏四边形 blit 资源管理
     *
     * @brief[en] Full-screen quad blit resource management
     */
    internal var blitQuad: BgfxBlitQuad = BgfxBlitQuad()

    public init() {
        super()
        this.kind = "bgfx"
        this.coordinateSystem = 2001  // WebGPUCoordinateSystem（左手系）

        this.extensions = BgfxExtensions()
        this.capabilities = BgfxCapabilities()
        this.utils = BgfxUtils()
        this.info = BgfxInfo()
        this.properties = BgfxProperties()
        this.state = BgfxState()
        this.textures = BgfxTextures(capabilities: capabilities, utils: utils, info: info, properties: properties)
        this.uniforms = BgfxUniforms()
        this.shader = BgfxShader(info: info)
        this.shaderCache = BgfxShaderCache()
        this.program = BgfxProgram(info: info)
        this.programs = BgfxPrograms(program: program, shaderCache: shaderCache, shader: shader)
        this.attributes = BgfxAttributes()
        this.bindingStates = BgfxBindingStates()
        this.clipping = BgfxClipping()
        this.geometries = BgfxGeometries(attributes: attributes, info: info, bindingStates: bindingStates)
        this.objects = BgfxObjects(geometries: geometries, attributes: attributes, info: info)
        this.materials = BgfxMaterials(info: info)
        this.lights = BgfxLights(info: info)
        this.shadowMap = BgfxShadowMap(info: info)
        this.background = BgfxBackground()
        this.output = BgfxOutput()
        this.environments = BgfxEnvironments()
        this.morphtargets = BgfxMorphtargets()
        this.renderLists = BgfxRenderLists()
        this.renderStates = BgfxRenderStates()
        this.animation = BgfxAnimation()
        this.constants = BgfxConstants()

        // 组合注入辅助 pass（用 this 构造，访问共享资源）
        this.shadowPass = BgfxShadowPass(backend: this)
        this.lightBinder = BgfxLightBinder(backend: this)
    }

    // ===== 2.2 初始化 =====

    /**
     * @brief[zh-cn] 初始化 bgfx 后端
     * @explain[zh-cn] 执行 bgfx_init_cj 初始化 bgfx 渲染库，设置 platformData.nwh，初始化扩展/能力检测/着色器缓存等子模块。
     * @param[zh-cn] renderer 渲染器实例
     *
     * @brief[en] Initialize bgfx backend
     * @explain[en] Executes bgfx_init_cj to initialize the bgfx rendering library, sets platformData.nwh, and initializes extensions/capabilities/shader cache sub-modules.
     * @param[en] renderer Renderer instance
     */
    public override func initialize(renderer: Renderer): Unit {
        super.initialize(renderer)

        // 1. 初始化着色器库
        ShaderLibs.initialize()

        // 2. 创建并配置 bgfx Init 结构
        let initPtrHolder = AutoFreePtr<Init>(unsafe { LibC.malloc<Init>() })
        let initPtr = initPtrHolder.get()
        unsafe { initPtr.write(Init()) }
        bgfx_init_ctor_cj(initPtr)
        var initParams = unsafe { initPtr.read() }
        initParams.`type` = 0u32  // 0 = bgfx自动检测渲染器类型
        initParams.vendorId = PCI_ID_NONE
        initParams.deviceId = PCI_ID_NONE
        initParams.resolution.width = UInt32(1280)
        initParams.resolution.height = UInt32(720)
        initParams.resolution.reset = 0x00000080u32
        initParams.resolution.numBackBuffers = 2
        initParams.resolution.maxFrameLatency = 2
        initParams.resolution.debugTextScale = 1
        initParams.debug = false
        initParams.profile = false
        // 设置平台窗口句柄（backend.hwnd 字段，替代原 parameters["hwnd"]）
        match (this.hwnd) {
            case Some(hwndVal) => initParams.platformData.nwh = intToCPointer(hwndVal)
            case None => ()
        }
        unsafe { initPtr.write(initParams) }
        var ok = bgfx_init_cj(initPtr)
        if (!ok && initParams.`type` != 0u32) {
            initParams.`type` = 0u32
            unsafe { initPtr.write(initParams) }
            ok = bgfx_init_cj(initPtr)
        }
        initPtrHolder.dispose()
        this.initialized = ok

        // 3. 子模块初始化
        extensions.`init`()
        capabilities.initialize()
        shaderCache = BgfxShaderCache()
    }

    // ===== 2.3 beginRender =====

    /**
     * 开始渲染 pass
     *
     * 执行：
     * - bgfx_set_view_rect_cj （视口）
     * - bgfx_set_view_clear_cj （清除标志 + 颜色）
     * - bgfx_set_view_frame_buffer_cj （FBO，若有）
     * - setViewTransform （投影+视图矩阵）
     */
    public override func beginRender(renderContext: IRenderContext): Unit {
        let viewId = renderContext.getViewId()
        let (x, y, w, h) = renderContext.getViewport()

        // 设置视口
        bgfx_set_view_rect_cj(viewId, UInt16(x), UInt16(y), UInt16(w), UInt16(h))

        // 设置清除
        let clearColor = renderContext.getClearColor()
        bgfx_set_view_clear_cj(viewId, CLEAR_COLOR | CLEAR_DEPTH, clearColor, 1.0f32, 0)

        // 设置 FBO（若有）
        match (renderContext.getFrameBuffer()) {
            case Some(fbo) =>
                // bgfx_set_view_frame_buffer 由外部 Renderer 管理
                ()
            case None => ()
        }

        // 设置视角变换（从 camera 获取 view/proj 矩阵）
        match (renderContext.getCamera()) {
            case Some(camera) =>
                // 从 camera 获取 viewMatrix 和 projectionMatrix
                let viewMat = camera.matrixWorldInverse.elements  // 16 Float64
                let projMat = camera.projectionMatrix.elements    // 16 Float64
                this._setViewTransform(viewId, viewMat, projMat)
            case None => ()
        }
    }

    /**
     * beginRender：重载接受 RenderContext 具体类
     * 注意：必须设置 view transform（相机矩阵），否则 bgfx 无视角变换画面全黑
     *
     * 顺序：
     * 1. bgfx_set_view_rect_cj —— 视口（用 renderContext.viewport）
     * 2. bgfx_set_view_clear_cj —— 清除色 + 深度（用 BgfxRenderer.clearColor）
     * 3. _setViewTransform —— view + proj 矩阵（从 renderContext 读取，_render 中已填充）
     *
     * 不调用 bgfx_touch_cj：touch 会重置 view 状态，导致后续 submit 失效（全黑）。
     * bgfx 中 submit 已标记 view 活跃，frame 触发双缓冲交换。
     */
    public override func beginRender(renderContext: RenderContext): Unit {
        let viewId = renderContext.viewId
        let (x, y, w, h) = renderContext.viewport
        bgfx_set_view_rect_cj(viewId, UInt16(x), UInt16(y), UInt16(UInt32(w)), UInt16(UInt32(h)))

        // 设置清除色（从 BgfxRenderer.clearColor 经 backend.parameters 传入，避免循环依赖）
        let clearColor = this._getClearColorFromParams()
        Logger.trace(["clear", "beginRender viewId=${viewId} clearColor=${clearColor} rect=(${x},${y},${w},${h})"])
        bgfx_set_view_clear_cj(viewId, CLEAR_COLOR | CLEAR_DEPTH, clearColor, 1.0f32, 0)

        // 设置 view transform（从 renderContext 读取，_render 中已填充相机矩阵）
        let viewMat = renderContext.viewMatrix
        let projMat = renderContext.projMatrix
        this._setViewTransform(viewId, viewMat, projMat)

        // 设置相机级 uniform（u_cameraPos / u_cameraNearFar / isOrthographic / toneMappingExposure）
        // 对照原始有效实现 _renderImpl 行 467-512
        match (renderContext.camera) {
            case Some(cam) => this.lightBinder.setCameraUniforms(cam)
            case None => ()
        }

        // 收集场景光源 + 设置光照 uniform（对照原始有效实现 setLightUniforms）
        // 必须在 draw 之前完成，供着色器采样光源数据
        match (renderContext.scene) {
            case Some(scene) =>
                let (dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes) = this.lightBinder.collectLights(scene)
                // 记录光照计数，供 _getOrCreateProgram 构建 NUM_*_LIGHTS defines
                // 可配置上限：实际数量 clamp 到 maxXxxLights，超过部分截断（与 _setLightUniforms 一致）
                this._numDirLights = if (dirLights.size < this.maxDirLights) { Int64(dirLights.size) } else { this.maxDirLights }
                this._numPointLights = if (pointLights.size < this.maxPointLights) { Int64(pointLights.size) } else { this.maxPointLights }
                this._numSpotLights = if (spotLights.size < this.maxSpotLights) { Int64(spotLights.size) } else { this.maxSpotLights }
                this._numHemiLights = if (hemiLights.size < this.maxHemiLights) { Int64(hemiLights.size) } else { this.maxHemiLights }
                // LightProbe：SH3 球谐系数（shCoefficients[9]）只取第一个探针，计数恒 0/1
                this._numLightProbes = if (lightProbes.size > 0) { 1 } else { 0 }
                // 记录阴影光源计数（对照参考项目 BgfxRenderer 行 456-461）：
                // 遍历各光源列表统计 castShadow=true 的数量，供 _buildLightDefines 构建
                // NUM_*_LIGHT_SHADOWS defines，否则 Phong shader 阴影分支被预处理器剔除
                // 同样 clamp 到 maxXxxShadows 配置上限
                this._numDirShadowLights = 0
                this._numPointShadowLights = 0
                this._numSpotShadowLights = 0
                for (dl in dirLights) { if (dl.castShadow) { this._numDirShadowLights += 1 } }
                for (pl in pointLights) { if (pl.castShadow) { this._numPointShadowLights += 1 } }
                for (sl in spotLights) { if (sl.castShadow) { this._numSpotShadowLights += 1 } }
                if (this._numDirShadowLights > this.maxDirShadows) { this._numDirShadowLights = this.maxDirShadows }
                if (this._numPointShadowLights > this.maxPointShadows) { this._numPointShadowLights = this.maxPointShadows }
                if (this._numSpotShadowLights > this.maxSpotShadows) { this._numSpotShadowLights = this.maxSpotShadows }
                this.lightBinder.setLightUniforms(dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes)
                // 绑定场景级纹理（DFG LUT 等）——必须在 draw 之前完成，
                // 否则 multiScatteringCompensation 的 dfgLUT 采样为 0 → 1/0 爆炸 → 高光失效
                this._bindSceneTextures()
            case None => ()
        }
    }

    /**
     * 从 this.parameters["clearColor"] 读取清除色
     * 若未设置，返回 0x00000000u32（全黑）
     */
    private func _getClearColorFromParams(): UInt32 {
        return this.clearColor
    }

    // ===== 2.4 draw =====

    /**
     * 执行 draw 调用（IRenderObject 版本）
     *
     * 完整 5 步流程：
     * 1. bgfx_set_transform_cj —— transform matrix（via BgfxMemory）
     * 2. bgfx_set_vertex_buffer_with_layout_cj —— vertex buffer（从几何体创建）
     * 3. bgfx_set_index_buffer_cj —— index buffer（若有）
     * 4. bgfx_set_state_cj —— render state
     * 5. bgfx_submit_cj —— submit with program handle from material
     */
    public override func draw(renderObject: IRenderObject): Unit {
        // 若 renderObject 是具体 RenderObject，直接访问 geometry/material 创建缓冲
        if (renderObject is RenderObject) {
            let roOpt = renderObject as RenderObject
            if (let Some(ro) <- roOpt) {
                this._drawRenderObject(ro)
                return
            }
        }

        // 通用 IRenderObject 接口版本
        let geometryId = renderObject.getGeometryId()
        let matrix = renderObject.getMatrix()
        if (matrix.size >= 16) {
            let mtxMem = BgfxMemory(64u32)
            mtxMem.writeFloats(matrix, 16)
            let mtxData = mtxMem.data()
            bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxData) }, 1u16)
        }
        // 2. set vertex buffer
        let vbOpt = this.geometries.getVertexBuffer(geometryId)
        let lhOpt = this.geometries.getLayoutHandle(geometryId)
        match (vbOpt) {
            case Some(vb) =>
                match (lhOpt) {
                    case Some(lh) =>
                        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb.handle, 0u32, 0xFFFFFFFFu32, lh)
                    case None => ()
                }
            case None => ()
        }
        let ibOpt = this.geometries.getIndexBuffer(geometryId)
        match (ibOpt) {
            case Some(ib) =>
                bgfx_set_index_buffer_cj(ib.handle, 0u32, 0xFFFFFFFFu32)
            case None => ()
        }
        bgfx_set_state_cj(
            0x00000000u64 | 0x00000010u64 | 0x00000020u64 |
            0x00000040u64 | 0x00000080u64 | 0x00100000u64,
            0u32
        )
        if (let Some(sp) <- ShaderLibs.get("standard")) {
            if (sp.programHandle.idx != 65535u16) {
                bgfx_submit_cj(0u16, sp.programHandle, 0u32, 0xFFu8)
            }
        }
    }

    /**
     * draw：旧版兼容
     */
    public override func draw(geometry: BufferGeometry, material: Material): Unit {
        bgfx_submit_cj(0u16, ProgramHandle(65535u16), 0u32, 0u8)
        super.draw(geometry, material)
    }

    // ===== 顶点缓冲/布局创建辅助方法（对照参考代码 getOrCreateVB/getOrCreateIB/getOrCreateLayoutPtr）=====

    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutCache: Option<VertexLayoutHandle> = None
    private var _currentLayout: VertexLayoutHandle = VertexLayoutHandle(65535u16)
    // 材质纹理 → bgfx TextureHandle 缓存。key = texture.uuid.hashCode()。
    // PBR 路径要求把 material.map/metalnessMap/roughnessMap/normalMap/aoMap/emissiveMap
    // 上传为 bgfx 纹理并通过 bgfx_set_texture_cj 绑定到对应 sampler uniform。
    // 未绑定则 USE_*MAP 分支采样的数据全为默认（黑/白）→ PBR 渐变失效（向光白背光黑）。
    private var _matTexCache: HashMap<Int64, TextureHandle> = HashMap<Int64, TextureHandle>()

    /**
     * 用具体 RenderObject 绘制：直接创建顶点缓冲并提交
     */
    private func _drawRenderObject(renderObject: RenderObject): Unit {
        let geom = renderObject.geometry
        let mat = renderObject.material
        let meshName = renderObject.mesh.name
        Logger.trace(["draw", "ENTER obj=${meshName} matKind=${mat.kind} geomId=${geom.uuid.hashCode()} side=${mat.side}"])

        // 1. 创建顶点缓冲
        let vb = this._createVB(geom)
        if (vb.idx == 65535u16) {
            Logger.warn(["draw", "VB INVALID obj=${meshName}"])
            return
        }
        let layout = this._getOrCreateLayout()

        // 2. set transform（模型矩阵）
        let mtxArr = renderObject.worldMatrix.elements
        let mtxMem = BgfxMemory(64u32)
        mtxMem.writeFloats(mtxArr, 16)
        let mtxData = mtxMem.data()
        bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxData) }, 1u16)
        Logger.trace(["draw", "obj=${meshName} worldMtx[0]=${mtxArr[0]} [5]=${mtxArr[5]} [10]=${mtxArr[10]} [12]=${mtxArr[12]} [13]=${mtxArr[13]} [14]=${mtxArr[14]}"])

        // 3. set u_normalMatrix（模型矩阵左上 3x3，用于法线变换）
        // 对照原始有效实现 draw() 行 892-911
        // bgfx mat3 存储为 3 个 vec4（12 floats），列主序：col0=[0,1,2], col1=[4,5,6], col2=[8,9,10]
        let uNormalMat = this.uniforms.createUniform("u_normalMatrix", UniformType.Mat3.value())
        let nmMem = BgfxMemory(48u32)
        let nmData = Array<Float64>(12, { i =>
            if (i < 3) {
                mtxArr[i]             // col0: rows 0-2
            } else if (i < 6) {
                mtxArr[4 + (i - 3)]   // col1: rows 0-2
            } else if (i < 9) {
                mtxArr[8 + (i - 6)]   // col2: rows 0-2
            } else {
                0.0                    // col0/1/2 的 w 分量 = 0
            }
        })
        nmMem.writeFloats(nmData, 12)
        let nmDataPtr = nmMem.data()
        bgfx_set_uniform_cj(uNormalMat.value, unsafe { CPointer<Unit>(nmDataPtr) }, 1u16)

        // 4. set receiveShadow uniform（对照 JS: p_uniforms.setValue(_gl, 'receiveShadow', object.receiveShadow)）
        let uRecvShadow = this.uniforms.createUniform("receiveShadow", UniformType.Vec4.value())
        let rsMem = BgfxMemory(16u32)
        let mesh = renderObject.mesh
        let rsVal = if (mesh.receiveShadow) { 1.0 } else { 0.0 }
        rsMem.writeFloats([rsVal, 0.0, 0.0, 0.0], 4)
        let rsData = rsMem.data()
        bgfx_set_uniform_cj(uRecvShadow.value, unsafe { CPointer<Unit>(rsData) }, 1u16)

        // 5. vertex buffer + layout
        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)

        // 6. index buffer（若有）
        let ib = this._createIB(geom)
        if (ib.idx != 65535u16) {
            bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
        }

        // 7. state —— FRONT_CCW（CCW=front，与 Three.js/OpenGL 一致）+ 按 material.side 设置 CULL
        // 对照原始有效实现 draw() 行 1048-1060
        // bgfx 默认 CW=front（Direct3D 惯例），Three.js 几何体使用 CCW winding，故加 FRONT_CCW
        let baseState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                        BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                        BgfxConstants.MSAA | BgfxConstants.FRONT_CCW
        let state = baseState
        let cullMode = BgfxConstants.convertCullMode(mat.side)
        // 透明材质启用 alpha blend：BGFX_STATE_BLEND_FUNC(SRC_ALPHA, INV_SRC_ALPHA)
        // 对照 bgfx defines.h: BGFX_STATE_BLEND_FUNC(_src,_dst) = _src | (_dst<<4)
        //   其中 _src/_dst 是 STATE_BLEND_* 常量（enum<<12）
        //   BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA, INV_SRC_ALPHA) = 0x6565000
        // 注意：不能直接 OR 三个 BLEND_* 常量 —— 那会把 src/dst factor 合并成
        // 单一 factor（0x7000），导致 alpha blend 完全失效（渲染为不透明）。
        let blendState = if (mat.transparent) {
            BgfxBackend.makeBlendFunc(
                BgfxConstants.BLEND_SRC_ALPHA,
                BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA
            )
        } else {
            0u64
        }
        // 图元类型：对照 three.js（图元由对象类型决定，材质辅助判断）：
        //   Line/LineSegments 或 Line 系材质 → LINES；
        //   Points 或 PointsMaterial → POINTS；其余默认三角形列表。
        // 参考：three.js WebGLGeometries/Lines 的 gl.drawArrays(gl.LINES/POINTS)
        let isLineObj = (mesh is Line) || mat.kind == "LineBasicMaterial" || mat.kind == "LineDashedMaterial"
        let isPointsObj = (mesh is Points) || mat.kind == "PointsMaterial"
        let primState = if (isLineObj) { BgfxConstants.LINES } else if (isPointsObj) { BgfxConstants.POINTS } else { 0u64 }
        bgfx_set_state_cj(baseState | primState | cullMode | blendState, 0x00000000u32)

        // 7.5 绑定材质 uniform（u_color / u_opacity + 各材质特有 uniform）
        // 对照原始有效实现 BgfxRenderer.setMatUniforms（行 1474-1563）
        // Three.js chunk 系统的 meshbasic/meshphong/meshstandard FS 均声明：
        //   uniform vec4 u_color;    // diffuse.rgb + opacity.a
        //   uniform vec4 u_opacity;  // chunk 系统读 u_opacity.x 作为 diffuseColor.a
        // 不绑定则材质渲染为黑（u_color 未初始化）或全透明（u_opacity=0）。
        this._bindMaterialUniforms(mat)

        // 7.6 绑定材质纹理到 bgfx 纹理阶段（PBR 核心路径）
        // 对照 Three.js WebGLTextures.uploadTexture + setValue(map, ...)
        // 不绑定则 map_fragment/metalnessmap_fragment/roughnessmap_fragment 虽被 #ifdef 激活，
        // 但 sampler 读取的是 bgfx 默认采样结果（黑/白）→ 小球渐变失效、呈现纯金属/纯粗糙
        this._bindMaterialTextures(mat)

        // 8. 获取程序句柄 — 从材质量编译 shader program
        let prog = this._getOrCreateProgram(mat)
        Logger.trace(["drawRenderObject", "obj=${meshName} prog.idx=${prog.idx}"])
        if (prog.idx != 65535u16) {
            // 用实际 view id（renderObject.context.viewId）而非硬编码 0：
            // RenderPass 渲 readBuffer 用 view 0，GroundReflector 渲反射场景
            // 用独立 view（renderer.viewId 临时切换），若硬编码 0 会与 readBuffer 冲突
            // （bgfx 同一 view 的所有 draw 输出到最后一次设置的 FB）。
            // ★关键（Line 闪烁根因）：submit 的 flags 必须是 BGFX_DISCARD_ALL (0xFF)！
            // 此前用 1u8（仅 BGFX_DISCARD_BINDINGS=0x01，只清纹理绑定），不会丢弃
            // index buffer（BGFX_DISCARD_INDEX_BUFFER=0x02）——bgfx encoder 的
            // index buffer 绑定跨 draw 残留：Line/LineSegments（Edges/Wireframe 无
            // index，不调 bgfx_set_index_buffer）绘制时会继承前一个 Mesh 的 IB，
            // 用 Mesh 的索引（如 Box 的 36 索引）索引 Line 的少量顶点 → 越界读垃圾
            // 内存 → 线条放射状/三角形平面/时立方体时乱线，且随渲染顺序变化而闪烁。
            // 每个 draw 均已完整重设 transform/VB/IB/state/uniform，DISCARD_ALL 安全。
            bgfx_submit_cj(renderObject.context.viewId, prog, 0u32, 0xFFu8)
            Logger.trace(["drawRenderObject", "obj=${meshName} submit OK"])
        } else {
            Logger.debug(["drawRenderObject", "obj=${meshName} prog 无效, 跳过 submit"])
        }
    }

    /**
     * _bindMaterialUniforms：绑定材质 uniform 到 bgfx
     *
     * 通用 uniform：
     *   u_color   (Vec4) = (mat.color.rgb, mat.opacity)
     *   u_opacity (Vec4) = (mat.opacity, 0, 0, 0)
     *
     * 材质特有 uniform（按 mat.kind 分支）：
     *   MeshPhongMaterial: u_shininess, u_specular
     *   MeshStandardMaterial/MeshPhysicalMaterial: u_roughness, u_metalness, u_emissive
     *   ShaderMaterial: 遍历 sm.uniforms 自定义 uniform
     */
    private func _bindMaterialUniforms(mat: Material): Unit {
        // u_color：材质 diffuse 颜色 + opacity（chunk FS: diffuseColor = vec4(u_color.rgb, u_opacity.x)）
        let uColor = this.uniforms.createUniform("u_color", UniformType.Vec4.value())
        let colorMem = BgfxMemory(16u32)
        colorMem.writeFloats([mat.color.r, mat.color.g, mat.color.b, mat.opacity], 4)
        Logger.trace(["color", "u_color r=${mat.color.r.toString()} g=${mat.color.g.toString()} b=${mat.color.b.toString()} opacity=${mat.opacity.toString()}"])
        bgfx_set_uniform_cj(uColor.value, unsafe { CPointer<Unit>(colorMem.data()) }, 1u16)

        // diffuse：meshbasic/meshphong/meshphysical 等 ShaderLib 片段均声明 `uniform vec3 diffuse`，
        // diffuseColor = vec4(diffuse, opacity)。此前只绑 u_color 与 shader 声明对不上，
        // diffuse 取 bgfx 默认值（黑）→ MeshStandardMaterial 球只剩光源贡献（红色点光通道），
        // 表现为全红球。补绑 diffuse（Vec4 xyz=rgb，w=padding 对齐 bgfx UniformType 无 Vec3）。
        let uDiffuse = this.uniforms.createUniform("diffuse", UniformType.Vec4.value())
        let diffuseMem = BgfxMemory(16u32)
        diffuseMem.writeFloats([mat.color.r, mat.color.g, mat.color.b, 0.0], 4)
        bgfx_set_uniform_cj(uDiffuse.value, unsafe { CPointer<Unit>(diffuseMem.data()) }, 1u16)
        Logger.trace(["diffuse-bind", "kind=${mat.kind} uDiffuse.idx= rgb=(${mat.color.r},${mat.color.g},${mat.color.b})"])

        // u_opacity：chunk 系统读 u_opacity.x 作为 diffuseColor.a
        let uOpacity = this.uniforms.createUniform("u_opacity", UniformType.Vec4.value())
        let opMem = BgfxMemory(16u32)
        opMem.writeFloats([mat.opacity, 0.0, 0.0, 0.0], 4)
        bgfx_set_uniform_cj(uOpacity.value, unsafe { CPointer<Unit>(opMem.data()) }, 1u16)

        // 材质特有 uniform
        match (mat.kind) {
            case "MeshPhongMaterial" =>
                match (mat) {
                    case pm: MeshPhongMaterial =>
                        // u_shininess: 高光指数
                        let uShininess = this.uniforms.createUniform("u_shininess", UniformType.Vec4.value())
                        let shMem = BgfxMemory(16u32)
                        shMem.writeFloats([pm.shininess, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uShininess.value, unsafe { CPointer<Unit>(shMem.data()) }, 1u16)

                        // u_specular: 高光颜色 (rgb, 1.0)
                        let uSpecular = this.uniforms.createUniform("u_specular", UniformType.Vec4.value())
                        let spMem = BgfxMemory(16u32)
                        spMem.writeFloats([pm.specular.r, pm.specular.g, pm.specular.b, 1.0], 4)
                        bgfx_set_uniform_cj(uSpecular.value, unsafe { CPointer<Unit>(spMem.data()) }, 1u16)
                    case _ => ()
                }
            case "MeshStandardMaterial" | "MeshPhysicalMaterial" =>
                // PBR uniform: u_roughness, u_metalness, u_emissive
                let uRoughness = this.uniforms.createUniform("u_roughness", UniformType.Vec4.value())
                let rMem = BgfxMemory(16u32)
                let roughness = match (mat) {
                    case sm: MeshStandardMaterial => sm.roughness
                    case _ => 1.0
                }
                rMem.writeFloats([roughness, 0.0, 0.0, 0.0], 4)
                bgfx_set_uniform_cj(uRoughness.value, unsafe { CPointer<Unit>(rMem.data()) }, 1u16)

                let uMetalness = this.uniforms.createUniform("u_metalness", UniformType.Vec4.value())
                let mMem = BgfxMemory(16u32)
                let metalness = match (mat) {
                    case sm: MeshStandardMaterial => sm.metalness
                    case _ => 0.0
                }
                mMem.writeFloats([metalness, 0.0, 0.0, 0.0], 4)
                bgfx_set_uniform_cj(uMetalness.value, unsafe { CPointer<Unit>(mMem.data()) }, 1u16)

                let uEmissive = this.uniforms.createUniform("u_emissive", UniformType.Vec4.value())
                let eMem = BgfxMemory(16u32)
                let emissive = match (mat) {
                    case sm: MeshStandardMaterial => sm.emissive
                    case _ => Color(0x000000)
                }
                eMem.writeFloats([emissive.r, emissive.g, emissive.b, 1.0], 4)
                bgfx_set_uniform_cj(uEmissive.value, unsafe { CPointer<Unit>(eMem.data()) }, 1u16)
            case "PointsMaterial" =>
                // u_pointSize：点大小（PointsMaterial.size，对照 three.js points.vert gl_PointSize = size）
                match (mat) {
                    case pm: PointsMaterial =>
                        let uPointSize = this.uniforms.createUniform("u_pointSize", UniformType.Vec4.value())
                        let psMem = BgfxMemory(16u32)
                        psMem.writeFloats([pm.size, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uPointSize.value, unsafe { CPointer<Unit>(psMem.data()) }, 1u16)
                    case _ => ()
                }
            case "LineDashedMaterial" =>
                // u_dashParams：x = dashSize, y = totalSize = dashSize + gapSize
                match (mat) {
                    case ldm: LineDashedMaterial =>
                        let uDashParams = this.uniforms.createUniform("u_dashParams", UniformType.Vec4.value())
                        let dpMem = BgfxMemory(16u32)
                        let totalSize = ldm.dashSize + ldm.gapSize
                        dpMem.writeFloats([ldm.dashSize, totalSize, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uDashParams.value, unsafe { CPointer<Unit>(dpMem.data()) }, 1u16)
                    case _ => ()
                }
            case "ReflectorMaterial" =>
                // GroundReflector 反射面材质（对照 JS ReflectorShader 全部 uniforms）
                match (mat) {
                    case rm: ReflectorMaterial =>
                        // tDiffuse（反射 RT color，stage 0）与 tDepth（反射深度 RT，stage 1，useDepthTexture 时）
                        let uTDiffuse = this.uniforms.createUniform("tDiffuse", UniformType.Sampler.value())
                        bgfx_set_texture_cj(0u8, uTDiffuse.value, rm.tDiffuse.value, 0u32)
                        if (rm.useDepthTexture) {
                            let uTDepth = this.uniforms.createUniform("tDepth", UniformType.Sampler.value())
                            bgfx_set_texture_cj(1u8, uTDepth.value, rm.tDepth.value, 0u32)
                        }
                        // textureMatrix（mat4，反射贴图投影到地面）
                        let uTexMtx = this.uniforms.createUniform("u_textureMatrix", UniformType.Mat4.value())
                        let tmArr = rm.textureMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                        let tmMem = BgfxMemory(64u32)
                        tmMem.writeFloats(tmArr, 16)
                        bgfx_set_uniform_cj(uTexMtx.value, unsafe { CPointer<Unit>(tmMem.data()) }, 1u16)
                        // color（vec4 rgb）
                        let uColor = this.uniforms.createUniform("u_color", UniformType.Vec4.value())
                        let cMem = BgfxMemory(16u32)
                        cMem.writeFloats([rm.reflectorColor.r, rm.reflectorColor.g, rm.reflectorColor.b, 0.0], 4)
                        bgfx_set_uniform_cj(uColor.value, unsafe { CPointer<Unit>(cMem.data()) }, 1u16)
                        // maxDistance / opacity（vec4.x；opacity 用父类 Material.opacity）
                        let uMaxDist = this.uniforms.createUniform("u_maxDistance", UniformType.Vec4.value())
                        let mdMem = BgfxMemory(16u32)
                        mdMem.writeFloats([rm.maxDistance, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uMaxDist.value, unsafe { CPointer<Unit>(mdMem.data()) }, 1u16)
                        let uOpacity = this.uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                        let opMem = BgfxMemory(16u32)
                        opMem.writeFloats([mat.opacity, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uOpacity.value, unsafe { CPointer<Unit>(opMem.data()) }, 1u16)
                        // fresnelCoe（vec4.x）
                        let uFresnel = this.uniforms.createUniform("u_fresnelCoe", UniformType.Vec4.value())
                        let fcMem = BgfxMemory(16u32)
                        fcMem.writeFloats([rm.fresnelCoe, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uFresnel.value, unsafe { CPointer<Unit>(fcMem.data()) }, 1u16)
                        // virtualCameraNear / virtualCameraFar（vec4.x）
                        let uVCamNear = this.uniforms.createUniform("u_virtualCameraNear", UniformType.Vec4.value())
                        let vnMem = BgfxMemory(16u32)
                        vnMem.writeFloats([rm.virtualCameraNear, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uVCamNear.value, unsafe { CPointer<Unit>(vnMem.data()) }, 1u16)
                        let uVCamFar = this.uniforms.createUniform("u_virtualCameraFar", UniformType.Vec4.value())
                        let vfMem = BgfxMemory(16u32)
                        vfMem.writeFloats([rm.virtualCameraFar, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uVCamFar.value, unsafe { CPointer<Unit>(vfMem.data()) }, 1u16)
                        // resolution（vec4 xy）
                        let uRes = this.uniforms.createUniform("u_resolution", UniformType.Vec4.value())
                        let resMem = BgfxMemory(16u32)
                        resMem.writeFloats([rm.resolutionX, rm.resolutionY, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uRes.value, unsafe { CPointer<Unit>(resMem.data()) }, 1u16)
                        // virtualCameraProjectionMatrix / ProjectionMatrixInverse / MatrixWorld（mat4）
                        let uProj = this.uniforms.createUniform("u_virtualCameraProjectionMatrix", UniformType.Mat4.value())
                        let pArr = rm.virtualCameraProjectionMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                        let pMem = BgfxMemory(64u32)
                        pMem.writeFloats(pArr, 16)
                        bgfx_set_uniform_cj(uProj.value, unsafe { CPointer<Unit>(pMem.data()) }, 1u16)
                        let uProjInv = this.uniforms.createUniform("u_virtualCameraProjectionMatrixInverse", UniformType.Mat4.value())
                        let piArr = rm.virtualCameraProjectionMatrixInverse.toArray(Array<Float64>(16, { _ => 0.0 }))
                        let piMem = BgfxMemory(64u32)
                        piMem.writeFloats(piArr, 16)
                        bgfx_set_uniform_cj(uProjInv.value, unsafe { CPointer<Unit>(piMem.data()) }, 1u16)
                        let uMtxWorld = this.uniforms.createUniform("u_virtualCameraMatrixWorld", UniformType.Mat4.value())
                        let mwArr = rm.virtualCameraMatrixWorld.toArray(Array<Float64>(16, { _ => 0.0 }))
                        let mwMem = BgfxMemory(64u32)
                        mwMem.writeFloats(mwArr, 16)
                        bgfx_set_uniform_cj(uMtxWorld.value, unsafe { CPointer<Unit>(mwMem.data()) }, 1u16)
                    case _ => ()
                }
            case _ => ()
        }
    }

    /**
     * _bindMaterialTextures：上传并绑定材质纹理到 bgfx 纹理阶段
     *
     * 取材质各 Option<Texture> 贴图（map/metalnessMap/roughnessMap/normalMap/aoMap/emissiveMap），
     * 首次见到该 texture.uuid 时，把 texture.image（RGBA8 字节）上传为 bgfx 2D 纹理，缓存句柄，
     * 通过 bgfx_set_texture_cj(stage, samplerUniform, handle, flags) 绑定到对应 sampler。
     *
     * 纹理阶段分配（与 ShaderLibs.cj / ShaderChunk 的 SAMPLER2D/SAMPLERCUBE 声明保持一致）：
     *   ★关键：bgfx 纹理 stage 是全局共享的，必须与 shadow sampler 区段（0..15）错开，
     *   否则材质 map 绑到 stage 0 会覆盖 directionalShadowMap[0] → 方向光阴影消失；
     *   其他材质 stage 挤占 point cube sampler stage → 点光源采样错乱成矩形。
     *   统一分配表：
     *     shadow 区段（BgfxShadowPass 占用）：
     *       directional: stage 0..3、spot: stage 4..7、point(cube): stage 8..15
     *     材质区段（本函数，从 stage 16 起分配，避开 shadow）：
     *       stage 16 = map               ← MeshStandard.map / MeshBasic.map
     *       stage 17 = roughnessMap       ← MeshStandard.roughnessMap
     *       stage 18 = metalnessMap       ← MeshStandard.metalnessMap
     *       stage 19 = normalMap          ← MeshStandard.normalMap
     *       stage 20 = aoMap              ← MeshStandard.aoMap
     *       stage 21 = emissiveMap        ← MeshStandard.emissiveMap
     *     已占用（非材质，与 shadow 不冲突）：
     *       u_envMap=22（SAMPLERCUBE）、dfgLUT=23（SAMPLER2D）
     *
     * 注意：bgfx uniform 是按名字查找的，shader 中声明的 sampler2D 名字
     * （map/metalnessMap/roughnessMap/normalMap/aoMap/emissiveMap）必须与本函数
     * createUniform 用的名字一致——这正是 task #1 把 pars 的 u_xxxMap 改回 xxxMap 的原因。
     * 且必须用 SAMPLER2D 宏声明：HLSL 分支下 bgfx_shader.sh 定义
     * #define sampler2D BgfxSampler2D，裸 uniform sampler2D 会被替换成 struct，
     * bgfx 无法按名绑定 → 贴图采样不生效。
     */
    private func _bindMaterialTextures(mat: Material): Unit {
        // 收集 (samplerName, texture, stage) 三元组，按材质 kind 分支
        // stage 从 16 起分配，避开 shadow 区段（0..15）
        var bindings = ArrayList<(String, Texture, UInt8)>()
        match (mat.kind) {
            case "MeshStandardMaterial" | "MeshPhysicalMaterial" =>
                match (mat) {
                    case sm: MeshStandardMaterial =>
                        match (sm.map) { case Some(t) => bindings.add(("map", t, BgfxSamplerStages.STAGE_MAP)); case None => () }
                        match (sm.roughnessMap) { case Some(t) => bindings.add(("roughnessMap", t, BgfxSamplerStages.STAGE_ROUGHNESS_MAP)); case None => () }
                        match (sm.metalnessMap) { case Some(t) => bindings.add(("metalnessMap", t, BgfxSamplerStages.STAGE_METALNESS_MAP)); case None => () }
                        match (sm.normalMap) { case Some(t) => bindings.add(("normalMap", t, BgfxSamplerStages.STAGE_NORMAL_MAP)); case None => () }
                        match (sm.aoMap) { case Some(t) => bindings.add(("aoMap", t, BgfxSamplerStages.STAGE_AO_MAP)); case None => () }
                        match (sm.emissiveMap) { case Some(t) => bindings.add(("emissiveMap", t, BgfxSamplerStages.STAGE_EMISSIVE_MAP)); case None => () }
                    case _ => ()
                }
            case "MeshBasicMaterial" =>
                match (mat) {
                    case bm: MeshBasicMaterial =>
                        match (bm.map) { case Some(t) => bindings.add(("map", t, BgfxSamplerStages.STAGE_MAP)); case None => () }
                    case _ => ()
                }
            case _ => ()
        }
        if (bindings.size == 0) { return }
        for (i in 0..bindings.size) {
            let (samplerName, tex, stage) = bindings[i]
            let texId = tex.uuid.hashCode()
            // 1. 取/创建 bgfx 纹理句柄（按 texture.uuid 缓存，避免每帧重传）
            var handle = TextureHandle(65535u16)
            match (this._matTexCache.get(texId)) {
                case Some(h) => handle = h
                case None =>
                    handle = this._uploadMaterialTexture(tex)
                    if (handle.idx != 65535u16) {
                        this._matTexCache.add(texId, handle)
                    }
            }
            if (handle.idx == 65535u16) {
                Logger.warn(["bindTex", "sampler=${samplerName} tex=${tex.uuid} handle INVALID, skip"])
                continue
            }
            // 2. 创建 sampler uniform（按 shader 中声明的名字）并绑定到 stage
            let sampler = this.uniforms.createUniform(samplerName, UniformType.Sampler.value())
            bgfx_set_texture_cj(stage, sampler.value, handle, 0u32)
            Logger.trace(["bindTex", "sampler=${samplerName} stage=${stage.toString()} tex=${tex.uuid} w=${tex.width.toString()} h=${tex.height.toString()}"])
            // 3. 设置对应 mat3 transform uniform（默认单位矩阵）
            // uv_vertex chunk：vMetalnessMapUv = mul( metalnessMapTransform, vec3( METALNESSMAP_UV, 1 ) ).xy
            // 后端若不设置这些 mat3 uniform，bgfx 默认 0 矩阵 → UV=(0,0) → 所有表面采样贴图同一像素
            // → 金属度/粗糙度贴图完全失去渐变效果（对照 Three.js WebGLUniforms：uvTransform 默认单位矩阵）
            let transformName = match (samplerName) {
                case "map" => "mapTransform"
                case "roughnessMap" => "roughnessMapTransform"
                case "metalnessMap" => "metalnessMapTransform"
                case "normalMap" => "normalMapTransform"
                case "aoMap" => "aoMapTransform"
                case "emissiveMap" => "emissiveMapTransform"
                case _ => ""
            }
            if (transformName != "") {
                let uTransform = this.uniforms.createUniform(transformName, UniformType.Mat3.value())
                let tMem = BgfxMemory(48u32)
                // 单位矩阵（bgfx mat3 列主序存储：3 个 vec4，共 12 float）
                tMem.writeFloats([
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0
                ], 12)
                bgfx_set_uniform_cj(uTransform.value, unsafe { CPointer<Unit>(tMem.data()) }, 1u16)
                Logger.trace(["bindTex", "transform=${transformName} handle.idx=${uTransform.value.idx}"])
            }
        }
    }

    /**
     * @return[zh-cn] bgfx TextureHandle；失败返回 INVALID (65535)
     *
     * _uploadMaterialTexture：把单个材质纹理上传为 bgfx 2D 纹理
     *
     * 当前实现假定 tex.image 为已解码的 RGBA8 字节流（DataTexture 直接持有，
     * GltfLoader.loadTexture 已通过 bimg 解码 PNG → RGBA8）。
     * 格式固定 RGBA8（TextureFormat.RGBA8 = 67），纹理标志 0（无 sRGB，材质管线自己处理色彩空间）。
     *
     * @return[en] bgfx TextureHandle; returns INVALID (65535) on failure
     */
    private func _uploadMaterialTexture(tex: Texture): TextureHandle {
        let w = tex.width
        let h = tex.height
        let img = tex.image
        if (w <= 0 || h <= 0 || img.size == 0) {
            Logger.warn(["uploadTex", "tex=${tex.uuid} empty data w=${w.toString()} h=${h.toString()}"])
            return TextureHandle(65535u16)
        }
        // 拷贝 RGBA8 字节到 bgfx 内存
        let mem = BgfxMemory(UInt32(img.size))
        mem.writeUInt8(img, Int64(img.size))
        let memPtr = mem.get()
        // RGBA8 = TextureFormat.RGBA8 = 67
        let handle = bgfx_create_texture_2d_cj(UInt16(w), UInt16(h), false, 1u16, 67u32, 0u64, memPtr)
        Logger.debug(["uploadTex", "tex=${tex.uuid} w=${w.toString()} h=${h.toString()} size=${img.size.toString()} handle.idx=${handle.idx.toString()}"])
        return handle
    }

    /**
     * @param[zh-cn] srcFactor 源因子（STATE_BLEND_* 常量，已 <<12）
     * @param[zh-cn] dstFactor 目标因子（STATE_BLEND_* 常量，已 <<12）
     * @return[zh-cn] 完整的 blend state 值
     *
     * makeBlendFunc：构建 bgfx blend state
     * 对照 bgfx defines.h:
     * BGFX_STATE_BLEND_FUNC_SEPARATE(srcRGB, dstRGB, srcA, dstA) =
     * ((srcRGB | (dstRGB << 4))) | (((srcA | (dstA << 4))) << 8)
     * BGFX_STATE_BLEND_FUNC(src, dst) = FUNC_SEPARATE(src, dst, src, dst)
     * BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA=0x5000, INV_SRC_ALPHA=0x6000) = 0x6565000
     *
     * 注意：不能直接 OR 三个 BLEND_* 常量 —— 那会把 src/dst factor 合并成
     * 单一 factor（0x7000），导致 alpha blend 完全失效（渲染为不透明）。
     *
     * @param[en] srcFactor Source factor (STATE_BLEND_* constant, already <<12)
     * @param[en] dstFactor Destination factor (STATE_BLEND_* constant, already <<12)
     * @return[en] Complete blend state value
     */
    public static func makeBlendFunc(srcFactor: UInt64, dstFactor: UInt64): UInt64 {
        // BGFX_STATE_BLEND_FUNC_SEPARATE(src, dst, src, dst)
        let rgbPart = srcFactor | (dstFactor << 4u64)
        let alphaPart = rgbPart << 8u64
        return rgbPart | alphaPart
    }

    // ===== Shader 程序获取（Three.js 模式：从材质编译自定义 shader）=====
    // 对照 Three.js WebGLBackend: 从 material 获取已编译的 program
    // 对照参考代码 BgfxRenderer.getOrCreateProgram

    private var _customProgCache: HashMap<String, ProgramHandle> = HashMap<String, ProgramHandle>()
    private var _variantProgCache: HashMap<String, ProgramHandle> = HashMap<String, ProgramHandle>()

    /**
     * _getOrCreateProgram：按 mat.kind 选择基础 shader 并编译变体
     *
     * 流程：
     * 1. ShaderMaterial：用材质自带 vertexShader/fragmentShader 编译（varying def 从 $input/$output 提取）
     * 2. 其他材质：按 mat.kind 映射到基础 shader（basic/lambert/phong/standard/physical），
     *    调 ShaderProgram.createVariant 复制已解析的 bgfx 源码，再 compileBgfxWithDefines 编译
     *
     * 变体按 mat.uuid 缓存，避免每帧重编译。
     */
    private func _getOrCreateProgram(mat: Material): ProgramHandle {
        // 1. ShaderMaterial：编译材质自带的自定义 shader
        // 注意：RawShaderMaterial/ShaderMaterial 未设置 vertexShader/fragmentShader 时
        //       （空字符串），空 shader 编译必然失败 → 无模型显示但几何体仍在（射线可命中）。
        //       对照 three.js：ShaderMaterial 无自定义 shader 时回退到默认材质着色
        //       （three.js 中 ShaderMaterial 默认有内置 shader；仓颉侧为空则回退基础路径）。
        if (mat is ShaderMaterial) {
            let smOpt = mat as ShaderMaterial
            match (smOpt) {
                case Some(sm) =>
                    if (sm.vertexShader.size > 0 && sm.fragmentShader.size > 0) {
                        let key = "custom_" + sm.uuid
                        match (this._customProgCache.get(key)) {
                            case Some(prog) =>
                                Logger.debug(["program", "ShaderMaterial cache HIT key=${key} prog.idx=${prog.idx}"])
                                return prog
                            case None => ()
                        }
                        Logger.debug(["program", "compiling custom shader key=${key} vsLen=${sm.vertexShader.size} fsLen=${sm.fragmentShader.size}"])
                        let varyingDef = this._extractVaryingDef(sm.vertexShader)
                        Logger.debug(["program", "varyingDef=${varyingDef}"])
                        let prog = ShaderProgram(key, sm.vertexShader, sm.fragmentShader, varyingDef: varyingDef)
                        prog.compileBgfx()
                        Logger.debug(["program", "custom compile result key=${key} prog.idx=${prog.programHandle.idx}"])
                        if (prog.programHandle.idx != 65535u16) {
                            this._customProgCache.add(key, prog.programHandle)
                            return prog.programHandle
                        }
                        Logger.error(["program", "custom shader compile FAILED key=${key}"])
                        return ProgramHandle(65535u16)
                    } else {
                        // 空 shader 回退：不编译自定义程序，落入下方按 mat.kind 的基础 shader 分发
                        Logger.debug(["program", "ShaderMaterial empty shader, fallback to basic kind=${sm.kind}"])
                    }
                case None => ()
            }
        }

        // 2. 其他材质：按 mat.kind 选择基础 shader 名称
        // 对照 Three.js ShaderLib：材质 kind → ShaderLibs 注册的程序名
        // ShaderLibs.initialize() 中注册的程序：basic/lambert/phong/standard/physical/
        //   normal/depth/depthviz/lightdir/shadowproj/shadowblit/pcf/shadowfrustum/vsm/...
        let shaderName = match (mat.kind) {
            case "MeshBasicMaterial" => "basic"
            case "MeshLambertMaterial" => "lambert"
            case "MeshPhongMaterial" => "phong"
            case "MeshStandardMaterial" => "standard"
            case "MeshPhysicalMaterial" => "physical"
            case "MeshNormalMaterial" => "normal"
            case "MeshMatcapMaterial" => "matcap"
            case "MeshToonMaterial" => "toon"
            case "MeshDepthMaterial" => "depth"
            case "MeshDistanceMaterial" => "distance"
            case "PointsMaterial" => "points"
            case "SpriteMaterial" => "sprite"
            case "ShadowMaterial" => "shadow"
            case "LineDashedMaterial" => "linedashed"
            // bgfx4cj 扩展：debug 可视化材质（对照 Three.js 无，属本仓库扩展）
            case "DepthVizMaterial" => "depthviz"
            case "LightDirMaterial" => "lightdir"
            case "ShadowProjMaterial" => "shadowproj"
            case "ShadowBlitMaterial" => "shadowblit"
            case "PcfVizMaterial" => "pcf"
            case "ShadowFrustumMaterial" => "shadowfrustum"
            // GroundReflector 反射面材质（对照 JS ReflectorShader ShaderMaterial）
            case "ReflectorMaterial" => "reflector"
            case _ => "basic"
        }
        // variant 缓存键含光照/阴影计数+阴影类型+纹理组合（对照参考项目 BgfxRenderer 行 1291 的 lightKey）
        // 否则阴影光源数量或阴影类型变化时不会重编译 shader，导致阴影缺失或多余阴影分支
        // 纹理组合变化时也必须重编译，否则 PBR 路径（USE_MAP/USE_METALNESSMAP/USE_ROUGHNESSMAP）被剔除
        let stKey = this.shadowMap.getShadowType().toString()
        // ShaderVariant.getVariantKey 返回 kind 或 kind_FLAG1_FLAG2...（FLAG 为大写 USE_XXX 前缀名）
        let texVariant = ShaderVariant.getVariantKey(mat)
        // 提取变体中的纹理标志部分（去掉前导 kind），拼到 variantKey 中
        let texFlagsPart = if (texVariant.size > mat.kind.size + 1) {
            texVariant[mat.kind.size + 1..]
        } else {
            ""
        }
        let variantKey = shaderName + "_" + mat.uuid +
            "_D" + this._numDirLights.toString() + "P" + this._numPointLights.toString() +
            "S" + this._numSpotLights.toString() + "H" + this._numHemiLights.toString() +
            "L" + this._numLightProbes.toString() +
            "_dSh" + this._numDirShadowLights.toString() + "pSh" + this._numPointShadowLights.toString() +
            "sSh" + this._numSpotShadowLights.toString() + "st" + stKey +
            "_tex" + texFlagsPart
        match (this._variantProgCache.get(variantKey)) {
            case Some(h) => return h
            case None => ()
        }
        Logger.debug(["program", "compiling variant key=" + variantKey + " shaderName=" + shaderName + " texFlags=" + texFlagsPart])
        match (ShaderLibs.get(shaderName)) {
            case Some(baseProg) =>
                let variantProg = ShaderProgram.createVariant(variantKey, baseProg)
                // 构建光照计数 defines（NUM_DIR_LIGHTS 等）
                // 对照原始有效实现 BgfxRenderer.getOrCreateProg（行 1332-1339）
                // 不传这些 defines 会导致 #if NUM_DIR_LIGHTS > 0 整段被预处理器剔除 → 物体渲染为黑
                let lightDefs = this._buildLightDefines()
                // 合并材质纹理 #define（USE_MAP=1 / USE_METALNESSMAP=1 / USE_ROUGHNESSMAP=1 / ...）
                // 不传则 map_fragment/metalnessmap_fragment/roughnessmap_fragment 整段被预处理器剔除
                // → PBR 纹理路径失效 → 模型呈现纯金属/纯粗糙（向光白背光黑）
                let defines = this._mergeTextureDefines(lightDefs, mat)
                lightDefs.dispose()
                variantProg.compileBgfx(extraDefines: defines.defs)
                defines.dispose()
                if (variantProg.programHandle.idx != 65535u16) {
                    this._variantProgCache.add(variantKey, variantProg.programHandle)
                    Logger.debug(["program", "variant compiled OK key=" + variantKey + " idx=" + variantProg.programHandle.idx.toString()])
                    return variantProg.programHandle
                }
                Logger.error(["program", "variant compile FAILED key=" + variantKey])
                return ProgramHandle(65535u16)
            case None =>
                Logger.error(["program", "base shader not found: " + shaderName])
                return ProgramHandle(65535u16)
        }
    }

    /**
     * _mergeTextureDefines：将材质纹理 #define 合并进光照 defines 数组，返回新的 holder
     *
     * 对照 ShaderVariant.getActiveTextureFlags：MeshStandardMaterial 的 map/roughnessMap/
     * metalnessMap/normalMap/emissiveMap/aoMap/lightMap 各对应一个 USE_XXX=1 define。
     *
     * 同时补 USE_UV=1（uv_pars_vertex/uv_pars_fragment 的 #ifdef USE_UV 包裹 UV 读取段，
     * 不传则 vMapUv 等不会被赋值 → 采样的 UV 永远为 0）。
     *
     * 调用者需先 dispose 旧的 defines，再用本函数返回的新 holder。
     */
    private func _mergeTextureDefines(light: _LightDefinesHolder, mat: Material): _LightDefinesHolder {
        // 1. 收集所有 define 字符串：先取出已有光照 define
        let allDefs = ArrayList<String>()
        for (d in light.defs) {
            allDefs.add(d)
        }
        // 2. 追加材质纹理 USE_XXX=1 defines
        let flags = ShaderVariant.getActiveTextureFlags(mat)
        for (flag in flags) {
            allDefs.add("USE_" + flag + "=1")
        }
        // 2.5 ReflectorMaterial 专属 defines（对照 JS GroundReflector ReflectorShader.defines）：
        //     反射器 FS 用 #ifdef useDepthTexture / #ifdef DISTANCE_ATTENUATION / #ifdef FRESNEL
        //     分支控制深度重建/距离衰减/菲涅尔；不传则走 #else 简化分支（无深度衰减），
        //     地面反射贴图缺失距离衰减与菲涅尔效果。
        if (mat is ReflectorMaterial) {
            match (mat as ReflectorMaterial) {
                case Some(rm) =>
                    if (rm.useDepthTexture) { allDefs.add("useDepthTexture=1") }
                    if (rm.distanceAttenuation) { allDefs.add("DISTANCE_ATTENUATION=1") }
                    if (rm.fresnel) { allDefs.add("FRESNEL=1") }
                case None => ()
            }
        }
        // 3. 纹理路径必然需要 UV（uv_pars_vertex/uv_vertex 的 #ifdef USE_UV 包裹 vUv 赋值，
        //    不传则 v_uv 未声明，texture 采样路径编译失败。二分测试已确认 USE_UV 不是
        //    fcpp work buffer overflow 根因——根因是 23 个 UV varying 被大 #if 块全量激活）
        if (flags.size > 0) {
            allDefs.add("USE_UV=1")
        }
        // 4. 重建数组（Array<String>，指针转换由 compileBgfx 内部完成）
        return _LightDefinesHolder(defs: allDefs.toArray())
    }

    /**
     * @return[zh-cn] _LightDefinesHolder（编译后需 dispose 释放内存）
     *
     * _buildLightDefines：构建光照计数 defines 数组
     *
     * 构建 NUM_DIR_LIGHTS / NUM_POINT_LIGHTS / NUM_SPOT_LIGHTS / NUM_HEMI_LIGHTS defines，
     * 供 Phong/Lambert/Standard 等光照 shader 编译时使用。
     * 不传这些 defines 会导致 #if NUM_DIR_LIGHTS > 0 整段被预处理器剔除 → 物体渲染为黑。
     *
     * @return[en] _LightDefinesHolder (must call dispose after compilation to free memory)
     */
    private func _buildLightDefines(): _LightDefinesHolder {
        let defStrings = ArrayList<String>()
        defStrings.add("NUM_DIR_LIGHTS=" + this._numDirLights.toString())
        defStrings.add("NUM_POINT_LIGHTS=" + this._numPointLights.toString())
        defStrings.add("NUM_SPOT_LIGHTS=" + this._numSpotLights.toString())
        defStrings.add("NUM_HEMI_LIGHTS=" + this._numHemiLights.toString())
        // 可配置上限宏（总是定义，供 shader 数组声明使用）：
        // ShaderLibs.cj 的 uniform 数组声明（u_pointPosition[NUM_POINT_LIGHTS_MAX] 等）
        // 与 lights_fragment_begin.cj 的展开段都用此宏控制，改配置属性即可自动适配。
        defStrings.add("NUM_DIR_LIGHTS_MAX=" + this.maxDirLights.toString())
        defStrings.add("NUM_POINT_LIGHTS_MAX=" + this.maxPointLights.toString())
        defStrings.add("NUM_SPOT_LIGHTS_MAX=" + this.maxSpotLights.toString())
        defStrings.add("NUM_HEMI_LIGHTS_MAX=" + this.maxHemiLights.toString())
        defStrings.add("NUM_DIR_LIGHT_SHADOWS_MAX=" + this.maxDirShadows.toString())
        defStrings.add("NUM_POINT_LIGHT_SHADOWS_MAX=" + this.maxPointShadows.toString())
        defStrings.add("NUM_SPOT_LIGHT_SHADOWS_MAX=" + this.maxSpotShadows.toString())
        // 阴影光源计数 defines（对照参考项目 BgfxRenderer 行 1339-1357）
        // 不传会导致 Phong shader 的 shadowmap_pars_fragment / lights_pars_begin 阴影分支
        // 被预处理器剔除 → 物体只有材质光照、无阴影投射效果（sp_fullphong 阴影缺失根因）
        // 仅在存在任意阴影光源时传（避免无阴景场景多余 define）
        let hasAnyShadow = this._numDirShadowLights > 0 || this._numPointShadowLights > 0 || this._numSpotShadowLights > 0
        if (hasAnyShadow) {
            // USE_SHADOWMAP=1：shadowmap_pars_fragment 的阴影 sampler/getShadow 声明段被 #ifdef USE_SHADOWMAP 包裹，
            // 不传则整段被预处理器剔除 → 无阴影 sampler 绑定 → getShadow 调用失败 → 阴影失效
            defStrings.add("USE_SHADOWMAP=1")
            // SHADOWMAP_TYPE_*：选择 getShadow 实现（PCF/VSM/BASIC），对照参考项目根据 _bgfxShadowMap.getShadowType() 动态设置
            // 注意：PCF_SOFT_SHADOW_MAP(2) 在本引擎统一降级为 PCF
            let st = this.shadowMap.getShadowType()
            if (st == BASIC_SHADOW_MAP) {
                defStrings.add("SHADOWMAP_TYPE_BASIC=1")
            } else if (st == PCF_SHADOW_MAP || st == PCF_SOFT_SHADOW_MAP) {
                defStrings.add("SHADOWMAP_TYPE_PCF=1")
            } else if (st == VSM_SHADOW_MAP) {
                defStrings.add("SHADOWMAP_TYPE_VSM=1")
            }
            defStrings.add("NUM_DIR_LIGHT_SHADOWS=" + this._numDirShadowLights.toString())
            defStrings.add("NUM_POINT_LIGHT_SHADOWS=" + this._numPointShadowLights.toString())
            defStrings.add("NUM_SPOT_LIGHT_SHADOWS=" + this._numSpotShadowLights.toString())
            // bgfx4cj: NUM_SPOT_LIGHT_COORDS = NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_MAPS
            // （当前无 spot light map，故等于 NUM_SPOT_LIGHT_SHADOWS）
            defStrings.add("NUM_SPOT_LIGHT_COORDS=" + this._numSpotShadowLights.toString())
            defStrings.add("NUM_SPOT_LIGHT_MAPS=0")
        }

        // LightProbe（SH3 球谐辐照度）：存在探针时定义 USE_LIGHT_PROBES，
        // lights_fragment_begin 的探针分支（standard 走 getShIrradianceAt 读 shCoefficients）才会被编译。
        if (this._numLightProbes > 0) {
            defStrings.add("USE_LIGHT_PROBES=1")
        }

        // 返回 Array<String>（指针转换由 compileBgfx 内部完成）
        return _LightDefinesHolder(defs: defStrings.toArray())
    }

    /**
     * 从顶点着色器源码的 $input/$output 声明中提取 varying def
     * 用于 ShaderMaterial 的 bgfx shader 编译（shaderc 需要 varying.def.sc 格式）
     */
    private func _extractVaryingDef(vsSource: String): String {
        let lines = vsSource.split("\n")
        var inputDefs = ArrayList<String>()
        var outputDefs = ArrayList<String>()
        for (line in lines) {
            let trimmed = line.trimAscii()
            if (trimmed.startsWith("$input")) {
                inputDefs.add(trimmed)
            } else if (trimmed.startsWith("$output")) {
                outputDefs.add(trimmed)
            }
        }
        // 根据属性名推断语义和类型
        func getSemanticAndType(name: String): (String, String) {
            if (name.contains("position")) { return ("POSITION", "vec3") }
            if (name.contains("normal"))   { return ("NORMAL", "vec3") }
            if (name.contains("color0"))   { return ("COLOR0", "vec4") }
            if (name.contains("color"))    { return ("COLOR0", "vec4") }
            if (name.contains("texcoord0")) { return ("TEXCOORD0", "vec2") }
            if (name.contains("texcoord")) { return ("TEXCOORD0", "vec2") }
            // output 默认 vec3
            return ("TEXCOORD0", "vec3")
        }
        // 解析 $output 行属性列表
        func parseAttrs(line: String): ArrayList<String> {
            // 支持 $input ... 和 $output ...
            let decl = if (line.startsWith("$input ")) { line.replace("$input ", "") }
                      else if (line.startsWith("$output ")) { line.replace("$output ", "") }
                      else { line }
            let parts = decl.split(",")
            let attrs = ArrayList<String>()
            for (i in 0..parts.size) {
                attrs.add(parts[i].trimAscii())
            }
            return attrs
        }
        var result = ""
        // 1. $output → varying def（供 FS 使用，需包含默认值）
        for (i in 0..outputDefs.size) {
            let attrs = parseAttrs(outputDefs[i])
            for (j in 0..attrs.size) {
                let name = attrs[j]
                let (semantic, semaType) = getSemanticAndType(name)
                let defaultVal = if (semaType == "vec3") { "= vec3(0.0, 0.0, 0.0)" }
                                else if (semaType == "vec4") { "= vec4(0.0, 0.0, 0.0, 1.0)" }
                                else { "= vec2(0.0, 0.0)" }
                result = result + semaType + " " + name + " : " + semantic + " " + defaultVal + ";\n"
            }
        }
        // 2. $input → varying def（供 VS 使用）
        if (inputDefs.size > 0) {
            for (i in 0..inputDefs.size) {
                let attrs = parseAttrs(inputDefs[i])
                for (j in 0..attrs.size) {
                    let name = attrs[j]
                    let (semantic, semaType) = getSemanticAndType(name)
                    result = result + semaType + " " + name + " : " + semantic + ";\n"
                }
            }
        } else {
            result = result + "vec3 a_position : POSITION;\n"
        }
        Logger.debug(["extractVaryingDef", "result=" + result])
        return result
    }

    /**
     * 创建顶点缓冲（从 geometry 的 position/normal/color/uv 属性读取）
     */
    internal func _createVB(geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._vbCache.get(geomId)) {
            case Some(vb) => return vb
            case None => ()
        }
        let posAttrOpt = geom.getAttribute("position")
        match (posAttrOpt) {
            case Some(pos) =>
                let vc = pos.count
                if (vc == 0) { return VertexBufferHandle(65535u16) }
                // position(3) + normal(3) + color(4) + uv(2) = 12 floats
                let vertStride: Int64 = 12
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
                // 诊断：打印前 2 个顶点的 pos/uv，确认 a_texcoord0 数据已写入
                Logger.debug(["vbDiag", "vc=${vc.toString()} v0.pos=(${data[0].toString()},${data[1].toString()},${data[2].toString()}) v0.uv=(${data[10].toString()},${data[11].toString()}) v1.uv=(${data[22].toString()},${data[23].toString()})"])
                let layout = this._getOrCreateLayoutPtr()
                let handle = bgfx_create_vertex_buffer_cj(mem.get(), layout, 0u16)
                this._vbCache.add(geomId, handle)
                return handle
            case None => return VertexBufferHandle(65535u16)
        }
    }

    /**
     * 创建索引缓冲
     */
    internal func _createIB(geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._ibCache.get(geomId)) {
            case Some(ib) => return ib
            case None => ()
        }
        match (geom.index) {
            case Some(idxAttr) =>
                let count = idxAttr.count
                if (count == 0) { return IndexBufferHandle(65535u16) }
                // Three.js 索引存 Float64，需转为 UInt16 写入（2字节/索引）
                Logger.debug(["createIB", "index count=" + count.toString()])
                let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
                let mem = BgfxMemory(UInt32(count * 2))
                mem.writeUInt16(idxData, count)
                let handle = bgfx_create_index_buffer_cj(mem.get(), 0u16)
                Logger.debug(["createIB", "handle.idx=" + handle.idx.toString()])
                this._ibCache.add(geomId, handle)
                return handle
            case None => return IndexBufferHandle(65535u16)
        }
    }

    /**
     * 获取/创建顶点布局指针（供 bgfx_create_vertex_buffer_cj 使用）
     */
    private func _getOrCreateLayoutPtr(): CPointer<VertexLayout> {
        let layoutPtrHolder = AutoFreePtr<VertexLayout>(unsafe { LibC.malloc<VertexLayout>() })
        let layoutPtr = layoutPtrHolder.get()
        unsafe { layoutPtr.write(VertexLayout()) }
        bgfx_vertex_layout_begin_cj(layoutPtr, 0u32)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Position.value(), 3u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Normal.value(), 3u8, AttribType.Float.value(), true, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Color0.value(), 4u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.TexCoord0.value(), 2u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_end_cj(layoutPtr)
        // bgfx_create_vertex_buffer_cj 会在内部复制布局数据，因此即使 AutoFreePtr 释放，缓冲的布局信息仍然有效
        return layoutPtr
    }

    /**
     * 获取/创建布局句柄（供 bgfx_set_vertex_buffer_with_layout_cj 使用）
     */
    internal func _getOrCreateLayout(): VertexLayoutHandle {
        return this._getOrCreateLayoutHandle()
    }

    private var _layoutHandleCache: Option<VertexLayoutHandle> = None
    private func _getOrCreateLayoutHandle(): VertexLayoutHandle {
        match (this._layoutHandleCache) {
            case Some(lh) => return lh
            case None => ()
        }
        let layoutPtrHolder = AutoFreePtr<VertexLayout>(unsafe { LibC.malloc<VertexLayout>() })
        let layoutPtr = layoutPtrHolder.get()
        unsafe { layoutPtr.write(VertexLayout()) }
        bgfx_vertex_layout_begin_cj(layoutPtr, 0u32)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Position.value(), 3u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Normal.value(), 3u8, AttribType.Float.value(), true, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Color0.value(), 4u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.TexCoord0.value(), 2u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_end_cj(layoutPtr)
        let handle = bgfx_create_vertex_layout_cj(layoutPtr)
        this._layoutHandleCache = Some(handle)
        return handle
    }

    // ===== 2.5 finishRender =====

    /**
     * 结束渲染 pass
     *
     * 执行 bgfx_touch_cj 标记 view 活跃 + bgfx_frame_cj 触发双缓冲交换
     *（注意：bgfx_frame_cj 必须在每次渲染循环中调用，否则画面不更新）
     */
    public override func finishRender(renderContext: IRenderContext): Unit {
        bgfx_touch_cj(renderContext.getViewId())
        bgfx_frame_cj(false)
    }

    /**
     * finishRender：重载接受 RenderContext 具体类
     *
     * 触发 view 活跃标记 + bgfx_frame 双缓冲交换。
     * bgfx 中 view 只有被 touch/submit 时才渲染
     * （含 clear + draw）。缺 touch 时 view0 的 clear 从未执行 → backbuffer 未清除，
     * 显示 swap chain 初始内容（灰）。此 touch 在 submit 之后调用，不会使已提交的
     * draw call 失效（此前"touch 导致全黑"的注释为误判，实际为缺 touch 导致全灰）。
     */
    public override func finishRender(renderContext: RenderContext): Unit {
        bgfx_touch_cj(renderContext.viewId)
        bgfx_frame_cj(false)
    }

    // ===== 阴影预 pass 钩子 override（对照 Backend 基类 prepareShadowMap/bindShadowUniforms/blitShadowMap） =====

    /**
     * 转调阴影类型设置到内部 BgfxShadowMap 实例。
     * 对照 BgfxShadowMap.setShadowType：记录类型变更（触发后续重建阴影贴图和材质重编译）。
     * sp_vsm 等测试通过 renderer.setShadowType(VSM_SHADOW_MAP) 切换为 VSM 模式。
     */
    public func setShadowType(value: Int64): Unit {
        this.shadowMap.setShadowType(value)
    }

    /**
     * 阴影深度预 pass：收集场景中 castShadow 的方向光，渲染深度到阴影 framebuffer。
     */
    public override func prepareShadowMap(scene: Scene): Unit {
        // 注意：去掉 initialized 守卫——BgfxRenderer 多线程委托机制下，
        // prepareShadowMap 在专用渲染线程上下文调时 initialized 字段跨线程可见性没保证，
        // 早 return 命中导致 _shadowFB 没创建 → blit SKIP。
        // bgfx_init 在 BgfxRenderer.init 时已完成，专用线程启动前 initialized 已 true；
        // 且 prepareShadowMap 内部 bgfx API 调用本身是安全的，无需此守卫。

        // 多光源阴影支持：每帧重置当前帧 shadow slot 注册表与 view ID 游标。
        // 持久资源（_shadowResources）跨帧复用，不在此处清理；光源销毁时由调用方显式释放。
        this.shadowPass.beginFrame()

        // 收集场景中所有方向光 + 聚光灯 + 点光源（castShadow=true 的才参与阴影深度 pass）
        let (dirLights, pointLights, _, spotLights, _, _) = this.lightBinder.collectLights(scene)
        Logger.trace(["shadow", "prepareShadowMap dirLights.size=${dirLights.size} spotLights.size=${spotLights.size} pointLights.size=${pointLights.size}"])
        for (dl in dirLights) {
            if (dl.castShadow) {
                this.shadowPass.renderShadowMap(dl, scene)
            }
        }
        for (sl in spotLights) {
            if (sl.castShadow) {
                this.shadowPass.renderSpotShadowMap(sl, scene)
            }
        }
        for (pl in pointLights) {
            if (pl.castShadow) {
                this.shadowPass.renderPointShadowMap(pl, scene)
            }
        }
        Logger.trace(["shadow", "prepareShadowMap done"])
    }

    /**
     * 绑定阴影 uniform 到主 pass draw。
     */
    public override func bindShadowUniforms(): Unit {
        this.shadowPass.bindShadowUniforms()
    }

    /**
     * 全屏 blit 阴影贴图到屏幕（debug mode 6 用）。
     */
    public override func blitShadowMap(mainViewId: UInt16): Unit {
        // 多光源阴影支持：blit 用第一个方向光 shadow slot（debug 模式专用）。
        // 旧实现用单实例 _shadowFB，现改为查询 _shadowSlots 中 kind="dir" 的第一个 slot。
        var blitSlot: Option<ShadowSlot> = None
        let blitKeys = ArrayList<Int64>()
        for ((k, _) in this.shadowPass._shadowSlots) {
            blitKeys.add(k)
        }
        for (lid in blitKeys) {
            match (this.shadowPass._shadowSlotKind.get(lid)) {
                case Some("dir") =>
                    match (this.shadowPass._shadowSlots.get(lid)) {
                        case Some(s) => blitSlot = Some(s)
                        case None => ()
                    }
                    break
                case _ => ()
            }
        }
        match (blitSlot) {
            case None => Logger.debug(["blit", "SKIP: no dir shadow slot"]); return
            case Some(slot) =>
                if (slot.frameBuffer.idx == 65535u16) { Logger.debug(["blit", "SKIP: shadowFB not created"]); return }
                // 确保 shadowblit shader 已编译
                let blitProgOpt = ShaderLibs.get("shadowblit")
                match (blitProgOpt) {
                    case Some(blitSp) =>
                        if (blitSp.programHandle.idx == 65535u16) {
                            blitSp.compileBgfx()
                        }
                        let blitProg = blitSp.programHandle
                        if (blitProg.idx == 65535u16) { Logger.debug(["blit", "SKIP: shadowblit prog compile failed"]); return }

                        this.blitQuad.ensureBlitVB()
                        // 仓颉不支持多元素 tuple match，改为逐层解构
                        match (this.blitQuad._blitVB) {
                            case Some(vb) =>
                                match (this.blitQuad._blitIB) {
                                    case Some(ib) =>
                                        match (this.blitQuad._blitLayout) {
                                            case Some(layout) =>
                                                // 绑定阴影贴图纹理到 sampler stage 0（shadowblit shader 的 shadowBlitSampler）
                                                // 关键：attachment 0 = color texture（RGBA8，depth shader 写 gl_FragCoord.z 到 color）
                                                let shadowTex = bgfx_get_texture_cj(slot.frameBuffer, 0u8)
                                                Logger.debug(["blit", "shadowTex idx=${shadowTex.idx} shadowFB idx=${slot.frameBuffer.idx}"])
                                                let blitSampler = this.uniforms.createUniform("shadowBlitSampler", UniformType.Sampler.value())
                                                bgfx_set_texture_cj(BgfxSamplerStages.STAGE_SHADOW_BLIT, blitSampler.value, shadowTex, 0u32)

                                                bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)
                                                bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                                                // 关键：blit 不需要深度测试（全屏四边形 z=0），关掉 DEPTH_TEST 避免被主 pass 深度挡
                                                let blitState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW
                                                bgfx_set_state_cj(blitState, 0x00000000u32)
                                                bgfx_submit_cj(mainViewId, blitProg, 0u32, 0xFFu8)
                                                Logger.debug(["blit", "submit OK mainViewId=${mainViewId}"])
                                            case None => Logger.debug(["blit", "SKIP: blitLayout None"])
                                        }
                                    case None => Logger.debug(["blit", "SKIP: blitIB None"])
                                }
                            case None => Logger.debug(["blit", "SKIP: blitVB None"])
                        }
                    case None => Logger.debug(["blit", "SKIP: shadowblit shader not registered"])
                }
        }
    }

    // ===== 2.6 clear =====

    /**
     * 清除缓冲
     *
     * 执行 bgfx_set_view_clear_cj。
     */
    public override func clear(renderContext: IRenderContext, color: Bool, depth: Bool, stencil: Bool): Unit {
        var clearFlags: UInt16 = 0u16
        if (color) { clearFlags = clearFlags | CLEAR_COLOR }
        if (depth) { clearFlags = clearFlags | CLEAR_DEPTH }
        if (stencil) { clearFlags = clearFlags | CLEAR_STENCIL }
        bgfx_set_view_clear_cj(renderContext.getViewId(), clearFlags, renderContext.getClearColor(), 1.0f32, 0)
    }

    /**
     * clear：无参数版本
     */
    public override func clear(): Unit {
        bgfx_frame_cj(false)
    }

    // ===== 2.7 blit =====

    /**
     * Blit 操作
     *
     * 用全屏 quad 触发 bgfx_submit_cj。
     */
    public override func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit {
        // 简化实现：设置视口全屏，提交 blit draw call
        bgfx_set_view_rect_cj(viewId, 0, 0, UInt16(256), UInt16(256))
        bgfx_set_state_cj(0x00000000u64 | 0x00000010u64, 0u32)
        bgfx_submit_cj(viewId, ProgramHandle(65535u16), 0u32, 0u8)
    }

    // ===== 2.8 dispose =====

    /**
     * 销毁后端
     *
     * 执行 bgfx_shutdown_cj。
     */
    public override func dispose(): Unit {
        // 销毁辅助 pass 持久的 GPU 资源
        this.shadowPass.dispose()
        this.blitQuad.dispose()
        textures.dispose()
        uniforms.dispose()
        programs.dispose()
        shadowMap.dispose()
        environments.disposeAll()
        bgfx_shutdown_cj()
        super.dispose()
    }

    /**
     * destroy：dispose 别名
     */
    public override func destroy(): Unit {
        this.dispose()
    }

    // ===== 2.9 coordinateSystem =====

    /**
     * 坐标系统 getter
     * 返回 WebGPUCoordinateSystem（2001，左手系）
     */
    public func getCoordinateSystem(): Int64 {
        return 2001
    }

    // ===== 视口/裁剪/清除颜色 =====

    public override func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit {
        super.setViewport(x, y, w, h)
        state.setViewport(Float64(x), Float64(y), Float64(w), Float64(h))
    }

    public override func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit {
        super.setScissor(x, y, w, h)
    }

    public override func setClearColor(color: UInt32): Unit {
        super.setClearColor(color)
    }

    // ===== 能力查询 =====

    public override func getMaxTextureSize(): Int64 {
        return capabilities.maxTextureSize
    }

    public override func getMaxAnisotropy(): Int64 {
        return capabilities.getMaxAnisotropy()
    }

    public override func hasFeature(name: String): Bool {
        return extensions.has(name)
    }

    // ===== setViewTransform 私有辅助方法 =====

    /**
     * @param[zh-cn] viewId view ID
     * @param[zh-cn] view    view 矩阵（16 Float64，列主序）
     * @param[zh-cn] proj    projection 矩阵（16 Float64，列主序）
     *
     * 设置视角变换矩阵（view + projection）
     *
     * 使用 BgfxMemory 分配内存，写入 16 个 Float64 值，
     * 调用 bgfx_set_view_transform_cj 设置到 bgfx。
     *
     * @param[en] viewId View ID
     * @param[en] view    View matrix (16 Float64, column-major)
     * @param[en] proj    Projection matrix (16 Float64, column-major)
     */
    internal func _setViewTransform(viewId: UInt16, view: Array<Float64>, proj: Array<Float64>): Unit {
        // bgfx4cj 统一左手系：view 和 proj 矩阵已按左手系生成，直接传递
        Logger.trace(["viewTransform", "view[0]=" + view[0].toString() + " view[5]=" + view[5].toString() + " view[10]=" + view[10].toString()])
        Logger.trace(["viewTransform", "proj[0]=" + proj[0].toString() + " proj[5]=" + proj[5].toString() + " proj[10]=" + proj[10].toString() + " proj[14]=" + proj[14].toString()])
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(view, 16)
        projMem.writeFloats(proj, 16)
        let viewData = viewMem.data()
        let projData = projMem.data()
        bgfx_set_view_transform_cj(viewId, unsafe { CPointer<Unit>(viewData) }, unsafe { CPointer<Unit>(projData) })
    }

    // ===== 相机 uniform / 光源收集 / 光源 uniform 绑定已迁出至 BgfxLightBinder =====
    // 详见 BgfxLightBinder.cj（internal 组合注入，包内跨文件访问共享资源）。

    // ===== 光源 uniform 绑定已迁出至 BgfxLightBinder（internal 组合注入） =====

    /**
     * 绑定场景级纹理（DFG LUT、环境贴图）
     *
     * 根因修复（task #3）：此前本方法是空实现，DFG LUT 从未绑定。
     * chunk 系统 lights_fragment_begin 的多散射能量补偿：
     *   vec2 fabMs = texture2D( dfgLUT, vec2( material.roughness, dotNVms ) ).rg;
     *   float EssMs = fabMs.x + fabMs.y;
     *   material.multiScatteringCompensation = 1.0 + specularColorBlended * ( 1.0 / EssMs - 1.0 );
     * dfgLUT 未绑定时采样返回 0 → EssMs=0 → 1.0/0 无穷大 → 直接高光爆炸（向光面全白）。
     * 必须绑定 DFG LUT 到 stage 23（与 lights_physical_pars_fragment 的 SAMPLER2D(dfgLUT, 23) 一致）；
     * stage 23 避开 shadow 区段（0..15）与材质区段（16..21）。
     */
    private func _bindSceneTextures(): Unit {
        // 绑定 DFG LUT（16x16 RG16F 半浮点数据）
        // 注意：格式必须用 TextureFormat.RG16F.value()（=56），不能用 92——
        // 92 是 BGFX_TEXTURE_FORMAT_D16F（深度浮点格式），若用错则纹理采样异常，
        // dfgLUT 采样为 0 → EssMs=0 → 1.0/EssMs 无穷 → 高光爆炸（向光面全白）。
        // 采样 flags 必须用 CLAMP（对照 Three.js dfgLUT 的 ClampToEdgeWrapping）：
        // 否则 wrap 模式下 roughness≈1（粗糙球）时 u 坐标接近 1.0 会绕回 0，
        // 采到错误 LUT 数据 → EssMs 异常 → multiScatteringCompensation 错误 → 黑色光斑。
        let dfgLutTex = getDFGLUT()
        let cacheKey = dfgLutTex.uuid.hashCode()
        let lutFlags = UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP)
        let handle = match (this._matTexCache.get(cacheKey)) {
            case Some(h) => h
            case None =>
                let w = dfgLutTex.width
                let h = dfgLutTex.height
                let img = dfgLutTex.image
                if (w <= 0 || h <= 0 || img.size == 0) {
                    Logger.warn(["bindScene", "dfgLUT empty data w=${w.toString()} h=${h.toString()}"])
                    return
                }
                let mem = BgfxMemory(UInt32(img.size))
                mem.writeUInt8(img, Int64(img.size))
                let newHandle = bgfx_create_texture_2d_cj(UInt16(w), UInt16(h), false, 1u16, TextureFormat.RG16F.value(), lutFlags, mem.get())
                if (newHandle.idx != 65535u16) {
                    this._matTexCache.add(cacheKey, newHandle)
                }
                newHandle
        }
        if (handle.idx == 65535u16) {
            Logger.warn(["bindScene", "dfgLUT handle INVALID, skip"])
            return
        }
        let sampler = this.uniforms.createUniform("dfgLUT", UniformType.Sampler.value())
        bgfx_set_texture_cj(BgfxSamplerStages.STAGE_DFGLUT, sampler.value, handle, UInt32(lutFlags))
        Logger.debug(["bindScene", "dfgLUT bound stage=${BgfxSamplerStages.STAGE_DFGLUT.toString()} w=${dfgLutTex.width.toString()} h=${dfgLutTex.height.toString()}"])
    }

    // ===== 阴影状态字段 + 全屏 blit 资源已迁出至 BgfxShadowPass / BgfxBlitQuad =====
    // 详见 BgfxShadowPass.cj / BgfxBlitQuad.cj（internal 组合注入）。
    // 阴影深度预 pass（renderShadowMap/renderSpotShadowMap/renderPointShadowMap/_render*Depth）
    // + 主 pass 阴影 uniform 绑定（bindShadowUniforms）+ 全屏 blit（ensureBlitVB/getOrCreateBlitLayout*）
    // 全部迁出至 BgfxShadowPass / BgfxBlitQuad，本类仅保留 prepareShadowMap/bindShadowUniforms/blitShadowMap 委托。
}
