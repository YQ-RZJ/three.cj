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
import three.utils.constants.CubeUVReflectionMapping
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
import three.utils.log.*
import three.utils.log.macros.*
import three.profiler.*
import three.profiler.macros.*
import three.scene.entity.Mesh
import three.scene.entity.Line
import three.scene.entity.Points
import three.scene.entity.InstancedMesh
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

/**
 * 几何 draw plan：把逐 draw 需要的 VB / IB / 三角形数合并为一次查表。
 *
 * 逐 draw 分别调用 _createVB/_createIB/统计三角形数会重复做 geom.uuid.hashCode()、
 * 多次 getAttribute("position") 字符串查找与多次 HashMap 查找；同一几何体每帧被
 * N 个对象绘制时这些开销乘以 N。plan 以几何体 uuid 的 hash 为键，position 属性
 * 版本号为版本戳：版本未变直接复用，变化时整体重建（顶点数据与索引同时失效）。
 */
private class GeomPlan {
    let geomId: Int64
    var vb: VertexBufferHandle = VertexBufferHandle(65535u16)
    var ib: IndexBufferHandle = IndexBufferHandle(65535u16)
    var triCount: Int64 = 0
    var posVersion: Int64 = -1

    init(geomId: Int64) {
        this.geomId = geomId
    }
}

/**
 * 材质渲染状态：cullMode / blendState / 线点图元判定，只取决于材质属性，按 uuid 缓存。
 */
private class MatState {
    var cullMode: UInt64 = 0u64
    var blendState: UInt64 = 0u64
    var isLineKind: Bool = false
    var isPointsKind: Bool = false
    // 简易材质（Points/Sprite）：其着色器（ShaderLibs "points"/"sprite"）只声明
    // u_color/u_opacity(+map)，不声明 u_normalMatrix / receiveShadow / diffuse。
    // 逐 draw 上传这些 uniform 是纯空转（每次 3 个 bgfx_set_uniform + 临时缓冲写入）。
    var simpleKind: Bool = false
    // 参与缓存的材质属性指纹：side/transparent/kind 任一变化即失效
    var sideKey: Int64 = 0
    var transparentKey: Bool = false
    var kindKey: String = ""

    init() {}
}

/**
 * program 快路径缓存条目：mat.uuid → 上次命中的变体指纹
 * （帧级光照后缀 + 实例化标记 + env 标记）+ 对应句柄。
 */
private class FastProg {
    var lightSuffix: String = ""
    var instSuffix: String = ""
    var envSuffix: String = ""
    var handle: ProgramHandle = ProgramHandle(65535u16)

    init() {}
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
    public var info: BgfxInfo
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
    // 对照原始有效实现 ThreeRenderer.getOrCreateProg（行 1332-1339）
    // 不传这些 defines 会导致 #if NUM_DIR_LIGHTS > 0 整段被预处理器剔除 → 物体渲染为黑
    private var _numDirLights: Int64 = 0
    private var _numPointLights: Int64 = 0
    private var _numSpotLights: Int64 = 0
    private var _numHemiLights: Int64 = 0
    // LightProbe 数量（供 _buildLightDefines 构建 USE_LIGHT_PROBES define）
    private var _numLightProbes: Int64 = 0
    // ===== 当前场景环境贴图（IBL）=====
    // beginRender 时从 renderContext.scene 读取 scene.environment / scene.environmentIntensity，
    // 作为材质 envMap 的兜底（material.envMap 优先，缺失时回退 scene.environment）。
    // 同时决定变体编译是否注入 USE_ENVMAP / ENVMAP_TYPE_CUBE_UV 宏。
    private var _currentEnvMap: Option<Texture> = None
    private var _currentEnvIntensity: Float64 = 1.0
    // 阴影光源计数（对照参考项目 ThreeRenderer 行 178-180、456-461）
    // 不传 NUM_*_LIGHT_SHADOWS defines 会导致 Phong shader 的 shadowmap_pars_fragment / lights_pars_begin
    // 阴影分支被预处理器剔除 → 物体只有材质光照、无阴影投射效果（sp_fullphong 阴影缺失根因）
    private var _numDirShadowLights: Int64 = 0
    private var _numPointShadowLights: Int64 = 0
    private var _numSpotShadowLights: Int64 = 0

    // ===== 光源/阴影数量上限（可配置，编译 shader 时作为宏 NUM_*_LIGHTS_MAX 传入）=====
    // 对照通用引擎惯例：光源数量由场景决定，本引擎用"配置上限"约束 shader 数组声明与手动展开段数。
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

        // 2. 创建并配置 bgfx Init 结构（新版 bgfx：主窗口交换链经 Init.swapChain 传入）
        let initPtrHolder = AutoFreePtr<Init>(unsafe { LibC.malloc<Init>() })
        let initPtr = initPtrHolder.get()
        unsafe { initPtr.write(Init()) }
        bgfx_init_ctor_cj(initPtr)
        var initParams = unsafe { initPtr.read() }
        initParams.`type` = 0u32  // 0 = bgfx自动检测渲染器类型
        initParams.vendorId = PCI_ID_NONE
        initParams.deviceId = PCI_ID_NONE
        initParams.swapChain.width = UInt32(1280)
        initParams.swapChain.height = UInt32(720)
        initParams.reset = 0x00000080u32  // RESET_VSYNC
        initParams.swapChain.numBackBuffers = 2
        initParams.swapChain.maxFrameLatency = 2
        initParams.debug = false
        initParams.profile = false
        // 设置平台窗口句柄（backend.hwnd 字段，替代原 parameters["hwnd"]；
        // 新版 bgfx 的 nwh 从 platformData 移入 swapChain）
        if (let Some(hwndVal) <- this.hwnd) { initParams.swapChain.nwh = intToCPointer(hwndVal) }
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
        if (let Some(_) <- renderContext.getFrameBuffer()) {
            // bgfx_set_view_frame_buffer 由外部 Renderer 管理
            ()
        }

        // 设置视角变换（从 camera 获取 view/proj 矩阵）
        if (let Some(camera) <- renderContext.getCamera()) {
            // 从 camera 获取 viewMatrix 和 projectionMatrix
            let viewMat = camera.matrixWorldInverse.elements  // 16 Float64
            let projMat = camera.projectionMatrix.elements    // 16 Float64
            this._setViewTransform(viewId, viewMat, projMat)
        }
    }

    /**
     * beginRender：重载接受 RenderContext 具体类
     * 注意：必须设置 view transform（相机矩阵），否则 bgfx 无视角变换画面全黑
     *
     * 顺序：
     * 1. bgfx_set_view_rect_cj —— 视口（用 renderContext.viewport）
     * 2. bgfx_set_view_clear_cj —— 清除色 + 深度（用 ThreeRenderer.clearColor）
     * 3. _setViewTransform —— view + proj 矩阵（从 renderContext 读取，_render 中已填充）
     *
     * 不调用 bgfx_touch_cj：touch 会重置 view 状态，导致后续 submit 失效（全黑）。
     * bgfx 中 submit 已标记 view 活跃，frame 触发双缓冲交换。
     */
    @Zone[three.rendering.bgfx.BgfxBackend.beginRender]
    public override func beginRender(renderContext: RenderContext): Unit {
        let viewId = renderContext.viewId
        let (x, y, w, h) = renderContext.viewport
        bgfx_set_view_rect_cj(viewId, UInt16(x), UInt16(y), UInt16(UInt32(w)), UInt16(UInt32(h)))

        // 设置清除色（从 ThreeRenderer.clearColor 经 backend.parameters 传入，避免循环依赖）
        let clearColor = this._getClearColorFromParams()
        @LogTrace(["clear", "beginRender viewId=${viewId} clearColor=${clearColor} rect=(${x},${y},${w},${h})"])
        bgfx_set_view_clear_cj(viewId, CLEAR_COLOR | CLEAR_DEPTH, clearColor, 1.0f32, 0)

        // 设置 view transform（从 renderContext 读取，_render 中已填充相机矩阵）
        let viewMat = renderContext.viewMatrix
        let projMat = renderContext.projMatrix
        this._setViewTransform(viewId, viewMat, projMat)

        // 设置相机级 uniform（u_cameraPos / u_cameraNearFar / isOrthographic / toneMappingExposure）
        // 对照原始有效实现 _renderImpl 行 467-512
        if (let Some(cam) <- renderContext.camera) { this.lightBinder.setCameraUniforms(cam) }

        // 收集场景光源 + 设置光照 uniform（对照原始有效实现 setLightUniforms）
        // 必须在 draw 之前完成，供着色器采样光源数据
        if (let Some(scene) <- renderContext.scene) {
            let (dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes) = this._collectLightsCached(scene)
            // 记录光照计数，供 _getOrCreateProgram 构建 NUM_*_LIGHTS defines
                // 可配置上限：实际数量 clamp 到 maxXxxLights，超过部分截断（与 _setLightUniforms 一致）
                this._numDirLights = if (dirLights.size < this.maxDirLights) { Int64(dirLights.size) } else { this.maxDirLights }
                this._numPointLights = if (pointLights.size < this.maxPointLights) { Int64(pointLights.size) } else { this.maxPointLights }
                this._numSpotLights = if (spotLights.size < this.maxSpotLights) { Int64(spotLights.size) } else { this.maxSpotLights }
                this._numHemiLights = if (hemiLights.size < this.maxHemiLights) { Int64(hemiLights.size) } else { this.maxHemiLights }
                // LightProbe：SH3 球谐系数（shCoefficients[9]）只取第一个探针，计数恒 0/1
                this._numLightProbes = if (lightProbes.size > 0) { 1 } else { 0 }
                // 记录阴影光源计数（对照参考项目 ThreeRenderer 行 456-461）：
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
                // D 项：构建帧级光照后缀（variantKey 的光照/阴影计数 + shadow 类型部分）。
                // 仅在计数/阴影类型变化时重建：每帧重建会产生十余次 toString 与字符串拼接。
                let shadowType = this.shadowMap.getShadowType()
                if (this._lsDir != this._numDirLights || this._lsPoint != this._numPointLights ||
                    this._lsSpot != this._numSpotLights || this._lsHemi != this._numHemiLights ||
                    this._lsProbe != this._numLightProbes ||
                    this._lsDirShadow != this._numDirShadowLights ||
                    this._lsPointShadow != this._numPointShadowLights ||
                    this._lsSpotShadow != this._numSpotShadowLights ||
                    this._lsShadowType != shadowType) {
                    this._frameLightSuffix = "_D" + this._numDirLights.toString() + "P" + this._numPointLights.toString() +
                        "S" + this._numSpotLights.toString() + "H" + this._numHemiLights.toString() +
                        "L" + this._numLightProbes.toString() +
                        "_dSh" + this._numDirShadowLights.toString() + "pSh" + this._numPointShadowLights.toString() +
                        "sSh" + this._numSpotShadowLights.toString() + "st" + shadowType.toString()
                    this._lsDir = this._numDirLights
                    this._lsPoint = this._numPointLights
                    this._lsSpot = this._numSpotLights
                    this._lsHemi = this._numHemiLights
                    this._lsProbe = this._numLightProbes
                    this._lsDirShadow = this._numDirShadowLights
                    this._lsPointShadow = this._numPointShadowLights
                    this._lsSpotShadow = this._numSpotShadowLights
                    this._lsShadowType = shadowType
                }
                this.lightBinder.setLightUniforms(dirLights, pointLights, ambientLights, spotLights, hemiLights, lightProbes)
                // 记录场景环境贴图（IBL）：作为材质 envMap 的兜底来源，
                // 供 _bindEnvMap 绑定 u_envMap、_getOrCreateProgram 注入 USE_ENVMAP 宏
                this._currentEnvMap = scene.environment
                this._currentEnvIntensity = scene.environmentIntensity
                // 注：场景级纹理（dfgLUT）改在每次 draw 前绑定（见 _drawRenderObject）——
                // submit 用 DISCARD_ALL 会清空纹理绑定，只在 beginRender 绑一次会导致
                // 第二次及以后的 draw 丢失 dfgLUT。
        }
    }

    /**
     * 从 this.parameters["clearColor"] 读取清除色
     * 若未设置，返回 0x00000000u32（全黑）
     */
    private func _getClearColorFromParams(): UInt32 {
        return this.clearColor
    }

    /**
     * @brief[zh-cn] 收集场景光源（带帧内缓存）
     * @explain[zh-cn] 阴影预 pass（prepareShadowMap）与主 pass（beginRender）处于同一帧，
     *               场景内容不变；原实现各自遍历一次整棵场景树收集光源，大场景下
     *               每帧多一次全量遍历。此处按帧缓存结果，第二次调用直接复用。
     *
     * @brief[en] Collects scene lights (with a per-frame cache)
     * @explain[en] The shadow pre-pass (prepareShadowMap) and the main pass
     *               (beginRender) run in the same frame with an unchanged scene;
     *               the previous implementation traversed the whole scene tree
     *               twice per frame. The result is now cached per frame.
     */
    private func _collectLightsCached(scene: Scene): (
        ArrayList<DirectionalLight>, ArrayList<PointLight>,
        ArrayList<AmbientLight>, ArrayList<SpotLight>,
        ArrayList<HemisphereLight>, ArrayList<LightProbe>) {
        if (this._lightCacheFrame == this._lightFrameIndex) {
            if (let Some(c) <- this._lightCache) { return c }
        }
        let lights = this.lightBinder.collectLights(scene)
        this._lightCache = Some(lights)
        this._lightCacheFrame = this._lightFrameIndex
        return lights
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
    @Zone[three.rendering.bgfx.BgfxBackend.draw]
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
            // 复用 _uMem64（原实现每次新建 BgfxMemory，走 bgfx_alloc 且不归还 → 逐帧泄漏）
            let mtxMem = this._uMem64
            mtxMem.writeFloats(matrix, 16)
            let mtxData = mtxMem.data()
            bgfx_set_transform_cj(unsafe { CPointer<Unit>(mtxData) }, 1u16)
        }
        // 2. set vertex buffer
        let vbOpt = this.geometries.getVertexBuffer(geometryId)
        let lhOpt = this.geometries.getLayoutHandle(geometryId)
        if (let Some(vb) <- vbOpt && let Some(lh) <- lhOpt) {
            bgfx_set_vertex_buffer_with_layout_cj(0u8, vb.handle, 0u32, 0xFFFFFFFFu32, lh)
        }
        let ibOpt = this.geometries.getIndexBuffer(geometryId)
        if (let Some(ib) <- ibOpt) {
            bgfx_set_index_buffer_cj(ib.handle, 0u32, 0xFFFFFFFFu32)
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
    // 顶点缓冲对应的 position 属性版本号：版本变化时销毁旧缓冲并重建（CPU 蒙皮/形态目标等动态几何）
    private var _vbVersions: HashMap<Int64, Int64> = HashMap<Int64, Int64>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    // 顶点布局结构指针缓存：布局是常量，逐次重建（malloc + 4 次 bgfx 调用）纯属浪费
    private var _layoutPtrCache: ?CPointer<VertexLayout> = None
    private var _layoutCache: Option<VertexLayoutHandle> = None
    private var _currentLayout: VertexLayoutHandle = VertexLayoutHandle(65535u16)
    // 材质纹理 → bgfx TextureHandle 缓存。key = texture.uuid.hashCode()。
    // PBR 路径要求把 material.map/metalnessMap/roughnessMap/normalMap/aoMap/emissiveMap
    // 上传为 bgfx 纹理并通过 bgfx_set_texture_cj 绑定到对应 sampler uniform。
    // 未绑定则 USE_*MAP 分支采样的数据全为默认（黑/白）→ PBR 渐变失效（向光白背光黑）。
    private var _matTexCache: HashMap<Int64, TextureHandle> = HashMap<Int64, TextureHandle>()

    // E 项性能优化：uniform 句柄一次性缓存 + 可复用 CPU buffer。
    // _bindMaterialUniforms/_bindMaterialTextures/_bindSceneTextures 每 draw 调用，原实现每次
    // createUniform（bgfxCallMtx 全局互斥锁 + 字符串 HashMap 查找）并新建 BgfxMemory/Array。
    // 句柄缓存后每 draw 只做 HashMap 查询；buffer 复用（bgfx_set_uniform/transform 均拷贝数据，
    // submit 用 DISCARD_ALL，覆写安全）。
    private var _uniformHandleCache: HashMap<String, Box<UniformHandle>> = HashMap<String, Box<UniformHandle>>()
    // 惰性分配（关键修复）：BgfxMemory(size) 构造器即调用 bgfx_alloc_cj（bgfx FFI），
    // 而 BgfxBackend 在 ThreeRenderer 构造期（bgfx_init 之前）就被创建——若在字段初始化器
    // 里分配，会在 bgfx 未初始化时调用 bgfx_alloc 导致初始化卡死。改为只读属性，
    // 首次访问时才分配（首次访问必在渲染路径，bgfx 已初始化且持 bgfxCallMtx）。
    private var _uMem16Store: ?BgfxMemory = None
    private var _uMem48Store: ?BgfxMemory = None
    private var _uMem64Store: ?BgfxMemory = None
    // 投影矩阵专用缓冲：_setViewTransform 中 view 与 proj 同时写入后一起提交，
    // 不能共用同一块（后写会覆盖先写的数据）。
    private var _viewProjMemStore: ?BgfxMemory = None
    private prop _viewProjMem: BgfxMemory {
        get() {
            if (let Some(m) <- this._viewProjMemStore) {
                m
            } else {
                let m = BgfxMemory(64u32)  // proj mat4（16 float）
                this._viewProjMemStore = Some(m)
                m
            }
        }
    }
    private prop _uMem16: BgfxMemory {
        get() {
            if (let Some(m) <- this._uMem16Store) {
                m
            } else {
                let m = BgfxMemory(16u32)  // vec4 / vec3（4 float）
                this._uMem16Store = Some(m)
                m
            }
        }
    }
    private prop _uMem48: BgfxMemory {
        get() {
            if (let Some(m) <- this._uMem48Store) {
                m
            } else {
                let m = BgfxMemory(48u32)  // mat3（12 float）
                this._uMem48Store = Some(m)
                m
            }
        }
    }
    private prop _uMem64: BgfxMemory {
        get() {
            if (let Some(m) <- this._uMem64Store) {
                m
            } else {
                let m = BgfxMemory(64u32)  // mat4 / transform（16 float）
                this._uMem64Store = Some(m)
                m
            }
        }
    }
    // 逐 draw 复用的临时 Float64 缓冲：避免每 draw 为法线矩阵/标量 uniform
    // 新建数组字面量（每次都是一次堆分配 + GC 压力），改为就地写入复用缓冲。
    // writeFloats 内部立即拷贝，缓冲可安全复用。
    private var _scratch4: Array<Float64> = Array<Float64>(4, { _ => 0.0 })
    private var _scratch12: Array<Float64> = Array<Float64>(12, { _ => 0.0 })
    // 逐 draw 复用的 uniform 句柄（避免每 draw 以字符串键查 HashMap）：
    // 键为固定字面量，句柄创建一次后永久有效。
    private var _uNormalMatrix: ?Box<UniformHandle> = None
    private var _uReceiveShadow: ?Box<UniformHandle> = None
    private var _uColor: ?Box<UniformHandle> = None
    private var _uDiffuse: ?Box<UniformHandle> = None
    private var _uOpacity: ?Box<UniformHandle> = None
    // dfgLUT 采样器句柄与纹理句柄（_bindSceneTextures 每 draw 调用，句柄与纹理均只需解析一次）
    private var _dfgLutSampler: ?Box<UniformHandle> = None
    private var _dfgLutHandle: TextureHandle = TextureHandle(65535u16)
    // 帧内光源收集缓存：prepareShadowMap 与 beginRender 各收集一次光源，
    // 两者处于同一帧（场景未变），第二次直接复用，避免每帧两次全场景遍历
    // （800 对象场景每次遍历约 0.18 ms）。
    private var _lightFrameIndex: Int64 = 0
    private var _lightCacheFrame: Int64 = -1
    private var _lightCache: ?(ArrayList<DirectionalLight>, ArrayList<PointLight>,
        ArrayList<AmbientLight>, ArrayList<SpotLight>,
        ArrayList<HemisphereLight>, ArrayList<LightProbe>) = None

    /**
     * _cachedUniform：按名取 uniform 句柄，首次创建后缓存，避免每 draw 重复 createUniform 的
     * 全局互斥锁与字符串查找（E 项）。num 为数组 uniform 长度，非数组时恒 1。
     */
    private func _cachedUniform(name: String, uniformType: UInt32, num!: UInt16 = 1u16): Box<UniformHandle> {
        if (let Some(h) <- this._uniformHandleCache.get(name)) { return h }
        let h = this.uniforms.createUniform(name, uniformType, num)
        this._uniformHandleCache.add(name, h)
        return h
    }

    /**
     * @brief[zh-cn] 写入单个 vec4 uniform（复用临时数组 + 复用内存缓冲）
     * @explain[zh-cn] 原实现每次都构造数组字面量（如 `[c.r, c.g, c.b, opacity]`），
     *               逐 draw 场景下是稳定的堆分配来源；此处就地写入复用的 4 元缓冲。
     *
     * @brief[en] Writes a single vec4 uniform (reusing the scratch array and memory buffer)
     * @explain[en] The previous implementation allocated an array literal per call
     *              (e.g. `[c.r, c.g, c.b, opacity]`) — a steady source of heap
     *              allocations in per-draw paths; now it writes into a reused buffer.
     */
    private func _setVec4(handle: Box<UniformHandle>, x: Float64, y: Float64,
                          z: Float64, w: Float64): Unit {
        let s = this._scratch4
        s[0] = x
        s[1] = y
        s[2] = z
        s[3] = w
        this._uMem16.writeFloats(s, 4)
        bgfx_set_uniform_cj(handle.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
    }

    private var _geomPlans: HashMap<Int64, GeomPlan> = HashMap<Int64, GeomPlan>()

    /** 材质渲染状态缓存（MatState 为文件级私有类），key = Material.id（整数，避免逐 draw 对 uuid 字符串求哈希） */
    private var _matStates: HashMap<Int64, MatState> = HashMap<Int64, MatState>()
    // 固定渲染状态：与材质/对象无关，逐 draw 无需重算 OR
    private let _baseRenderState: UInt64 = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
        BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
        BgfxConstants.MSAA | BgfxConstants.FRONT_CCW

    private func _getMatState(mat: Material): MatState {
        if (let Some(st) <- this._matStates.get(mat.id)) {
            if (st.sideKey == mat.side && st.transparentKey == mat.transparent && st.kindKey == mat.kind) {
                return st
            }
            this._refreshMatState(st, mat)
            return st
        }
        let st = MatState()
        this._refreshMatState(st, mat)
        this._matStates[mat.id] = st
        return st
    }

    private func _refreshMatState(st: MatState, mat: Material): Unit {
        st.sideKey = mat.side
        st.transparentKey = mat.transparent
        st.kindKey = mat.kind
        st.cullMode = BgfxConstants.convertCullMode(mat.side)
        // 透明材质启用 alpha blend：BGFX_STATE_BLEND_FUNC(SRC_ALPHA, INV_SRC_ALPHA)
        // 对照 bgfx defines.h: BGFX_STATE_BLEND_FUNC(_src,_dst) = _src | (_dst<<4)
        //   其中 _src/_dst 是 STATE_BLEND_* 常量（enum<<12）
        //   BGFX_STATE_BLEND_ALPHA = FUNC(SRC_ALPHA, INV_SRC_ALPHA) = 0x6565000
        // 注意：不能直接 OR 三个 BLEND_* 常量 —— 那会把 src/dst factor 合并成
        // 单一 factor（0x7000），导致 alpha blend 完全失效（渲染为不透明）。
        st.blendState = if (mat.transparent) {
            BgfxBackend.makeBlendFunc(
                BgfxConstants.BLEND_SRC_ALPHA,
                BgfxConstants.BLEND_ONE_MINUS_SRC_ALPHA
            )
        } else {
            0u64
        }
        st.isLineKind = (mat.kind == "LineBasicMaterial" || mat.kind == "LineDashedMaterial")
        st.isPointsKind = (mat.kind == "PointsMaterial")
        st.simpleKind = (mat.kind == "PointsMaterial" || mat.kind == "SpriteMaterial")
    }

    @Zone[three.rendering.bgfx.BgfxBackend._getGeomPlan]
    private func _getGeomPlan(geom: BufferGeometry): GeomPlan {
        let geomId = geom.id
        // position 属性版本号：CPU 蒙皮/变形等每帧改写顶点数据时会自增
        let posVersion = if (let Some(p) <- geom.getAttribute("position")) { p.version } else { 0 }
        if (let Some(pl) <- this._geomPlans.get(geomId)) {
            if (pl.posVersion == posVersion) { return pl }
        }
        let pl = GeomPlan(geomId)
        pl.vb = this._createVB(geom)
        pl.ib = this._createIB(geom)
        // 每实例三角形数（索引优先；无索引时按 position 顶点数）
        if (let Some(idx) <- geom.index) {
            pl.triCount = idx.count / 3
        } else if (let Some(pos) <- geom.getAttribute("position")) {
            pl.triCount = pos.count / 3
        } else {
            pl.triCount = 0
        }
        pl.posVersion = posVersion
        this._geomPlans[geomId] = pl
        return pl
    }

    /**
     * 用具体 RenderObject 绘制：直接创建顶点缓冲并提交
     */
    @Zone[three.rendering.bgfx.BgfxBackend._drawRenderObject]
    private func _drawRenderObject(renderObject: RenderObject): Unit {
        let geom = renderObject.geometry
        let mat = renderObject.material
        let meshName = renderObject.mesh.name
        // 实例化对象（InstancedMesh）：走 USE_INSTANCING 变体程序 + 实例数据缓冲（对照方案 C1）。
        // transform/normalMatrix 仍用对象自身 matrixWorld：VS 中 u_model * instanceMatrix 组合变换
        // （聚合自动路由时 matrixWorld=单位阵，手动 InstancedMesh 时实例矩阵在局部空间），均正确。
        let isInstanced = if (let Some(_) <- (renderObject.mesh as InstancedMesh)) { true } else { false }
        @LogTrace(["draw", "ENTER obj=${meshName} matKind=${mat.kind} geomId=${geom.id} side=${mat.side} instanced=${isInstanced}"])

        // 1. 顶点缓冲（draw plan 一次查表拿到 VB/IB/三角形数）
        let plan = this._getGeomPlan(geom)
        let vb = plan.vb
        if (vb.idx == 65535u16) {
            @LogWarn(["draw", "VB INVALID obj=${meshName}"])
            return
        }
        let layout = this._getOrCreateLayout()
        // 材质渲染状态提前取用（步骤 3/4 需要 simpleKind 判定是否跳过无带着色器 uniform）
        let matState = this._getMatState(mat)

        // 2. set transform（模型矩阵）
        let mtxArr = renderObject.worldMatrix.elements
        this._uMem64.writeFloats(mtxArr, 16)
        bgfx_set_transform_cj(unsafe { CPointer<Unit>(this._uMem64.data()) }, 1u16)
        @LogTrace(["draw", "obj=${meshName} worldMtx[0]=${mtxArr[0]} [5]=${mtxArr[5]} [10]=${mtxArr[10]} [12]=${mtxArr[12]} [13]=${mtxArr[13]} [14]=${mtxArr[14]}"])

        // 3. set u_normalMatrix（模型矩阵左上 3x3，用于法线变换）
        // 对照原始有效实现 draw() 行 892-911
        // bgfx mat3 存储为 3 个 vec4（12 floats），列主序：col0=[0,1,2], col1=[4,5,6], col2=[8,9,10]
        // 句柄与临时缓冲均复用：逐 draw 不再重复字符串键查找与数组分配。
        // Points/Sprite 着色器不声明该 uniform（也不需要法线），跳过整段写入。
        if (!matState.simpleKind) {
            let uNormalMat = if (let Some(h) <- this._uNormalMatrix) {
                h
            } else {
                let h = this._cachedUniform("u_normalMatrix", UniformType.Mat3.value())
                this._uNormalMatrix = Some(h)
                h
            }
            let nm = this._scratch12
            nm[0] = mtxArr[0]
            nm[1] = mtxArr[1]
            nm[2] = mtxArr[2]
            nm[3] = mtxArr[4]
            nm[4] = mtxArr[5]
            nm[5] = mtxArr[6]
            nm[6] = mtxArr[8]
            nm[7] = mtxArr[9]
            nm[8] = mtxArr[10]
            nm[9] = 0.0
            nm[10] = 0.0
            nm[11] = 0.0
            this._uMem48.writeFloats(nm, 12)
            bgfx_set_uniform_cj(uNormalMat.value, unsafe { CPointer<Unit>(this._uMem48.data()) }, 1u16)
        }

        // 4. set receiveShadow uniform（对照 JS: p_uniforms.setValue(_gl, 'receiveShadow', object.receiveShadow)）
        // receiveShadow 由 chunk 系统的 shadowmap_pars_fragment 消费；Points/Sprite 不走这些 chunk，跳过。
        let mesh = renderObject.mesh
        if (!matState.simpleKind) {
            let uRecvShadow = if (let Some(h) <- this._uReceiveShadow) {
                h
            } else {
                let h = this._cachedUniform("receiveShadow", UniformType.Vec4.value())
                this._uReceiveShadow = Some(h)
                h
            }
            let rsVal = if (mesh.receiveShadow) { 1.0 } else { 0.0 }
            this._setVec4(uRecvShadow, rsVal, 0.0, 0.0, 0.0)
        }

        // 5. vertex buffer + layout
        bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)

        // 6. index buffer（若有）
        let ib = plan.ib
        if (ib.idx != 65535u16) {
            bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
        }

        // 6.5 instance data buffer（仅实例化对象，对照方案 C1）：
        // stride 64 字节 = 4×vec4（i_data0..3，VS 中重组为 instanceMatrix，column-major）。
        // instanceMatrix.array 每实例 16 个 Float64，转 Float32 写入 bgfx 帧内分配的实例缓冲。
        // struct 本体用 AutoFreePtr 管理（data 指针由 bgfx 生命周期管理，无需手动释放）。
        if (isInstanced) {
            let im = (renderObject.mesh as InstancedMesh).getOrThrow()
            let count = im.count
            if (count > 0) {
                let idbHolder = AutoFreePtr<InstanceDataBuffer>(unsafe { LibC.malloc<InstanceDataBuffer>() })
                let idbPtr = idbHolder.get()
                unsafe { bgfx_alloc_instance_data_buffer_cj(idbPtr, UInt32(count), 64u16) }
                let arr = im.instanceMatrix.array
                let dataPtr = unsafe { idbPtr.read().data }
                unsafe {
                    let fPtr = CPointer<Float32>(dataPtr)
                    var fi: Int64 = 0
                    for (i in 0..(count * 16)) {
                        fPtr.write(fi, Float32(arr[i]))
                        fi += 1
                    }
                }
                unsafe { bgfx_set_instance_data_buffer_cj(idbPtr, 0u32, UInt32(count)) }
                idbHolder.dispose()
            }
        }

        // 7. state —— FRONT_CCW（CCW=front，与主流 Web 引擎/OpenGL 一致）+ 按 material.side 设置 CULL
        // 对照原始有效实现 draw() 行 1048-1060
        // bgfx 默认 CW=front（Direct3D 惯例），主流 Web 引擎几何体使用 CCW winding，故加 FRONT_CCW
        // 与 kind 相关的判定（cullMode / blendState / 线点图元）只取决于材质属性，
        // 按 mat.id 缓存一次，避免逐 draw 重复多次 kind 字符串比较（matState 已在步骤 3 前取用）。
        let cullMode = matState.cullMode
        let blendState = matState.blendState
        // 图元类型：（图元由对象类型决定，材质辅助判断）：
        //   Line/LineSegments 或 Line 系材质 → LINES；
        //   Points 或 PointsMaterial → POINTS；其余默认三角形列表。
        // 参考：通用引擎 WebGLGeometries/Lines 的 gl.drawArrays(gl.LINES/POINTS)
        let isLineObj = (mesh is Line) || matState.isLineKind
        let isPointsObj = (mesh is Points) || matState.isPointsKind
        let primState = if (isLineObj) { BgfxConstants.LINES } else if (isPointsObj) { BgfxConstants.POINTS } else { 0u64 }
        bgfx_set_state_cj(this._baseRenderState | primState | cullMode | blendState, 0x00000000u32)

        // 7.5 绑定材质 uniform（u_color / u_opacity + 各材质特有 uniform）
        // 对照原始有效实现 ThreeRenderer.setMatUniforms（行 1474-1563）
        // 通用 chunk 系统的 meshbasic/meshphong/meshstandard FS 均声明：
        //   uniform vec4 u_color;    // diffuse.rgb + opacity.a
        //   uniform vec4 u_opacity;  // chunk 系统读 u_opacity.x 作为 diffuseColor.a
        // 不绑定则材质渲染为黑（u_color 未初始化）或全透明（u_opacity=0）。
        // ★必须在每次 draw 前重绑场景级纹理（dfgLUT）：submit 用 DISCARD_ALL 清空纹理绑定，
        //   bgfx 的 texture 绑定是"提交即消费"的瞬时状态，若只在 beginRender 绑一次，
        //   第二次及以后的 draw 都会丢失去 dfgLUT → EssMs=0 → 1/0 → 高光爆炸/发黑
        //  （表现为"多物体场景中只有一个物体光照正常"）。
        this._bindSceneTextures()
        this._bindMaterialUniforms(mat, matState.simpleKind)

        // 7.6 绑定材质纹理到 bgfx 纹理阶段（PBR 核心路径）
        // 对照 WebGLTextures.uploadTexture + setValue(map, ...)
        // 不绑定则 map_fragment/metalnessmap_fragment/roughnessmap_fragment 虽被 #ifdef 激活，
        // 但 sampler 读取的是 bgfx 默认采样结果（黑/白）→ 小球渐变失效、呈现纯金属/纯粗糙
        this._bindMaterialTextures(mat)

        // 8. 获取程序句柄 — 从材质量编译 shader program（实例化对象用 USE_INSTANCING 变体）
        let prog = this._getOrCreateProgram(mat, instanced: isInstanced)
        @LogTrace(["drawRenderObject", "obj=${meshName} prog.idx=${prog.idx}"])
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
            // 渲染统计（对照通用引擎惯例的 info.render.calls/triangles）：直接提交路径不经过
            // BufferRenderer（其 info.update 不会被触发），在此手动累加。
            // 帧末由 Renderer._syncRenderStats 同步到抽象层 Info 并清零本统计。
            this.info.render.calls += 1
            var triCount: Int64 = plan.triCount
            if (isInstanced) {
                let imStat = (renderObject.mesh as InstancedMesh).getOrThrow()
                triCount *= imStat.count
            }
            this.info.render.triangles += triCount
            @LogTrace(["drawRenderObject", "obj=${meshName} submit OK"])
        } else {
            @LogDebug(["drawRenderObject", "obj=${meshName} prog 无效, 跳过 submit"])
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
    @Zone[three.rendering.bgfx.BgfxBackend._bindMaterialUniforms]
    private func _bindMaterialUniforms(mat: Material, simpleKind: Bool): Unit {
        // u_color：材质 diffuse 颜色 + opacity（chunk FS: diffuseColor = vec4(u_color.rgb, u_opacity.x)）
        // 句柄复用（不再每 draw 以字符串键查表）+ 值写入复用缓冲（不再每 draw 分配数组字面量）。
        let uColor = if (let Some(h) <- this._uColor) {
            h
        } else {
            let h = this._cachedUniform("u_color", UniformType.Vec4.value())
            this._uColor = Some(h)
            h
        }
        this._setVec4(uColor, mat.color.r, mat.color.g, mat.color.b, mat.opacity)
        @LogTrace(["color", "u_color r=${mat.color.r.toString()} g=${mat.color.g.toString()} b=${mat.color.b.toString()} opacity=${mat.opacity.toString()}"])

        // diffuse：meshbasic/meshphong/meshphysical 等 ShaderLib 片段均声明 `uniform vec3 diffuse`，
        // diffuseColor = vec4(diffuse, opacity)。此前只绑 u_color 与 shader 声明对不上，
        // diffuse 取 bgfx 默认值（黑）→ MeshStandardMaterial 球只剩光源贡献（红色点光通道），
        // 表现为全红球。补绑 diffuse（Vec4 xyz=rgb，w=padding 对齐 bgfx UniformType 无 Vec3）。
        // Points/Sprite 着色器只声明 u_color/u_opacity(+map)，不声明 diffuse —— 跳过这次空转上传。
        if (!simpleKind) {
            let uDiffuse = if (let Some(h) <- this._uDiffuse) {
                h
            } else {
                let h = this._cachedUniform("diffuse", UniformType.Vec4.value())
                this._uDiffuse = Some(h)
                h
            }
            this._setVec4(uDiffuse, mat.color.r, mat.color.g, mat.color.b, 0.0)
            @LogTrace(["diffuse-bind", "kind=${mat.kind} uDiffuse.idx= rgb=(${mat.color.r},${mat.color.g},${mat.color.b})"])
        }

        // u_opacity：chunk 系统读 u_opacity.x 作为 diffuseColor.a
        let uOpacity = if (let Some(h) <- this._uOpacity) {
            h
        } else {
            let h = this._cachedUniform("u_opacity", UniformType.Vec4.value())
            this._uOpacity = Some(h)
            h
        }
        this._setVec4(uOpacity, mat.opacity, 0.0, 0.0, 0.0)

        // 材质特有 uniform
        match (mat.kind) {
            case "MeshPhongMaterial" =>
                match (mat) {
                    case pm: MeshPhongMaterial =>
                        // u_shininess: 高光指数
                        let uShininess = this._cachedUniform("u_shininess", UniformType.Vec4.value())
                        this._setVec4(uShininess, pm.shininess, 0.0, 0.0, 0.0)

                        // u_specular: 高光颜色 (rgb, 1.0)
                        let uSpecular = this._cachedUniform("u_specular", UniformType.Vec4.value())
                        this._setVec4(uSpecular, pm.specular.r, pm.specular.g, pm.specular.b, 1.0)
                    case _ => ()
                }
            case "MeshStandardMaterial" | "MeshPhysicalMaterial" =>
                // PBR uniform: u_roughness, u_metalness, u_emissive
                let uRoughness = this._cachedUniform("u_roughness", UniformType.Vec4.value())
                let roughness = match (mat) {
                    case sm: MeshStandardMaterial => sm.roughness
                    case _ => 1.0
                }
                this._setVec4(uRoughness, roughness, 0.0, 0.0, 0.0)

                let uMetalness = this._cachedUniform("u_metalness", UniformType.Vec4.value())
                let metalness = match (mat) {
                    case sm: MeshStandardMaterial => sm.metalness
                    case _ => 0.0
                }
                this._setVec4(uMetalness, metalness, 0.0, 0.0, 0.0)

                let uEmissive = this._cachedUniform("u_emissive", UniformType.Vec4.value())
                let emissive = match (mat) {
                    case sm: MeshStandardMaterial => sm.emissive
                    case _ => Color(0x000000)
                }
                this._setVec4(uEmissive, emissive.r, emissive.g, emissive.b, 1.0)
            case "PointsMaterial" =>
                // u_pointSize：点大小（PointsMaterial.size，对照 points.vert 的 gl_PointSize = size）
                match (mat) {
                    case pm: PointsMaterial =>
                        let uPointSize = this._cachedUniform("u_pointSize", UniformType.Vec4.value())
                        this._setVec4(uPointSize, pm.size, 0.0, 0.0, 0.0)
                    case _ => ()
                }
            case "LineDashedMaterial" =>
                // u_dashParams：x = dashSize, y = totalSize = dashSize + gapSize
                match (mat) {
                    case ldm: LineDashedMaterial =>
                        let uDashParams = this._cachedUniform("u_dashParams", UniformType.Vec4.value())
                        let totalSize = ldm.dashSize + ldm.gapSize
                        this._setVec4(uDashParams, ldm.dashSize, totalSize, 0.0, 0.0)
                    case _ => ()
                }
            case "ReflectorMaterial" =>
                // GroundReflector 反射面材质（对照 JS ReflectorShader 全部 uniforms）
                match (mat) {
                    case rm: ReflectorMaterial =>
                        // tDiffuse（反射 RT color，stage 0）与 tDepth（反射深度 RT，stage 1，useDepthTexture 时）
                        let uTDiffuse = this._cachedUniform("tDiffuse", UniformType.Sampler.value())
                        bgfx_set_texture_cj(0u8, uTDiffuse.value, rm.tDiffuse.value, 0u32)
                        if (rm.useDepthTexture) {
                            let uTDepth = this._cachedUniform("tDepth", UniformType.Sampler.value())
                            bgfx_set_texture_cj(1u8, uTDepth.value, rm.tDepth.value, 0u32)
                        }
                        // textureMatrix（mat4，反射贴图投影到地面）
                        let uTexMtx = this._cachedUniform("u_textureMatrix", UniformType.Mat4.value())
                        let tmArr = rm.textureMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                        this._uMem64.writeFloats(tmArr, 16)
                        bgfx_set_uniform_cj(uTexMtx.value, unsafe { CPointer<Unit>(this._uMem64.data()) }, 1u16)
                        // color（vec4 rgb）
                        let uColorR = this._cachedUniform("u_color", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.reflectorColor.r, rm.reflectorColor.g, rm.reflectorColor.b, 0.0], 4)
                        bgfx_set_uniform_cj(uColorR.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        // maxDistance / opacity（vec4.x；opacity 用父类 Material.opacity）
                        let uMaxDist = this._cachedUniform("u_maxDistance", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.maxDistance, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uMaxDist.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        let uOpacityR = this._cachedUniform("u_opacity", UniformType.Vec4.value())
                        this._uMem16.writeFloats([mat.opacity, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uOpacityR.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        // fresnelCoe（vec4.x）
                        let uFresnel = this._cachedUniform("u_fresnelCoe", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.fresnelCoe, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uFresnel.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        // virtualCameraNear / virtualCameraFar（vec4.x）
                        let uVCamNear = this._cachedUniform("u_virtualCameraNear", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.virtualCameraNear, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uVCamNear.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        let uVCamFar = this._cachedUniform("u_virtualCameraFar", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.virtualCameraFar, 0.0, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uVCamFar.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        // resolution（vec4 xy）
                        let uRes = this._cachedUniform("u_resolution", UniformType.Vec4.value())
                        this._uMem16.writeFloats([rm.resolutionX, rm.resolutionY, 0.0, 0.0], 4)
                        bgfx_set_uniform_cj(uRes.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
                        // virtualCameraProjectionMatrix / ProjectionMatrixInverse / MatrixWorld（mat4）
                        let uProj = this._cachedUniform("u_virtualCameraProjectionMatrix", UniformType.Mat4.value())
                        let pArr = rm.virtualCameraProjectionMatrix.toArray(Array<Float64>(16, { _ => 0.0 }))
                        this._uMem64.writeFloats(pArr, 16)
                        bgfx_set_uniform_cj(uProj.value, unsafe { CPointer<Unit>(this._uMem64.data()) }, 1u16)
                        let uProjInv = this._cachedUniform("u_virtualCameraProjectionMatrixInverse", UniformType.Mat4.value())
                        let piArr = rm.virtualCameraProjectionMatrixInverse.toArray(Array<Float64>(16, { _ => 0.0 }))
                        this._uMem64.writeFloats(piArr, 16)
                        bgfx_set_uniform_cj(uProjInv.value, unsafe { CPointer<Unit>(this._uMem64.data()) }, 1u16)
                        let uMtxWorld = this._cachedUniform("u_virtualCameraMatrixWorld", UniformType.Mat4.value())
                        let mwArr = rm.virtualCameraMatrixWorld.toArray(Array<Float64>(16, { _ => 0.0 }))
                        this._uMem64.writeFloats(mwArr, 16)
                        bgfx_set_uniform_cj(uMtxWorld.value, unsafe { CPointer<Unit>(this._uMem64.data()) }, 1u16)
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
    @Zone[three.rendering.bgfx.BgfxBackend._bindMaterialTextures]
    private func _bindMaterialTextures(mat: Material): Unit {
        // 按材质 kind 直接绑定（不再每 draw 构造 bindings 数组：逐 draw 的
        // ArrayList + 元组装箱是无贴图材质场景下最纯粹的浪费）。
        // stage 从 16 起分配，避开 shadow 区段（0..15）
        match (mat.kind) {
            case "MeshStandardMaterial" | "MeshPhysicalMaterial" =>
                match (mat) {
                    case sm: MeshStandardMaterial =>
                        this._bindMatTexture("map", sm.map, SamplerStages.STAGE_MAP)
                        this._bindMatTexture("roughnessMap", sm.roughnessMap, SamplerStages.STAGE_ROUGHNESS_MAP)
                        this._bindMatTexture("metalnessMap", sm.metalnessMap, SamplerStages.STAGE_METALNESS_MAP)
                        this._bindMatTexture("normalMap", sm.normalMap, SamplerStages.STAGE_NORMAL_MAP)
                        this._bindMatTexture("aoMap", sm.aoMap, SamplerStages.STAGE_AO_MAP)
                        this._bindMatTexture("emissiveMap", sm.emissiveMap, SamplerStages.STAGE_EMISSIVE_MAP)
                    case _ => ()
                }
            case "MeshBasicMaterial" =>
                match (mat) {
                    case bm: MeshBasicMaterial =>
                        this._bindMatTexture("map", bm.map, SamplerStages.STAGE_MAP)
                    case _ => ()
                }
            case _ => ()
        }
        // 环境贴图（IBL）：常规材质贴图绑定完成后统一处理
        this._bindEnvMap(mat)
    }

    /**
     * @brief[zh-cn] 绑定单张材质贴图到指定纹理阶段
     * @explain[zh-cn] 上传（按 texture.uuid 缓存，避免每帧重传）+ 绑定 sampler +
     *               设置对应 mat3 uv 变换矩阵（默认单位矩阵）。
     *               uv_vertex chunk：vMetalnessMapUv = mul( metalnessMapTransform,
     *               vec3( METALNESSMAP_UV, 1 ) ).xy——后端若不设置这些 mat3 uniform，
     *               bgfx 默认 0 矩阵 → UV=(0,0) → 所有表面采样贴图同一像素
     *               → 金属度/粗糙度贴图完全失去渐变效果（对照 WebGLUniforms：
     *               uvTransform 默认单位矩阵）。
     *
     * @brief[en] Binds a single material texture to the given texture stage
     * @explain[en] Uploads (cached by texture.uuid, avoiding per-frame re-upload),
     *               binds the sampler and sets the matching mat3 uv transform
     *               (identity by default).
     *
     * @param[zh-cn] samplerName shader 中声明的 sampler 名
     * @param[zh-cn] texOpt 材质贴图（None 表示该材质无此贴图）
     * @param[zh-cn] stage bgfx 纹理阶段
     */
    private func _bindMatTexture(samplerName: String, texOpt: Option<Texture>, stage: UInt8): Unit {
        let tex = if (let Some(t) <- texOpt) { t } else { return }
        let texId = tex.id
        // 1. 取/创建 bgfx 纹理句柄（按 texture.uuid 缓存，避免每帧重传）
        var handle = TextureHandle(65535u16)
        if (let Some(h) <- this._matTexCache.get(texId)) {
            handle = h
        } else {
            handle = this._uploadMaterialTexture(tex)
            if (handle.idx != 65535u16) {
                this._matTexCache.add(texId, handle)
            }
        }
        if (handle.idx == 65535u16) {
            @LogWarn(["bindTex", "sampler=${samplerName} tex=${tex.uuid} handle INVALID, skip"])
            return
        }
        // 2. 创建 sampler uniform（按 shader 中声明的名字）并绑定到 stage
        let sampler = this._cachedUniform(samplerName, UniformType.Sampler.value())
        bgfx_set_texture_cj(stage, sampler.value, handle, 0u32)
        @LogTrace(["bindTex", "sampler=${samplerName} stage=${stage.toString()} tex=${tex.uuid} w=${tex.width.toString()} h=${tex.height.toString()}"])
        // 3. 设置对应 mat3 transform uniform（默认单位矩阵）
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
            let uTransform = this._cachedUniform(transformName, UniformType.Mat3.value())
            // 单位矩阵（bgfx mat3 列主序存储：3 个 vec4，共 12 float）
            let t = this._scratch12
            t[0] = 1.0
            t[1] = 0.0
            t[2] = 0.0
            t[3] = 0.0
            t[4] = 0.0
            t[5] = 1.0
            t[6] = 0.0
            t[7] = 0.0
            t[8] = 0.0
            t[9] = 0.0
            t[10] = 1.0
            t[11] = 0.0
            this._uMem48.writeFloats(t, 12)
            bgfx_set_uniform_cj(uTransform.value, unsafe { CPointer<Unit>(this._uMem48.data()) }, 1u16)
            @LogTrace(["bindTex", "transform=${transformName} handle.idx=${uTransform.value.idx}"])
        }
    }

    /**
     * _effectiveEnvMap：取材质实际生效的环境贴图（IBL）
     *
     * 语义对照通用引擎：material.envMap 优先，缺失时回退 scene.environment；
     * 生效强度 = Material.envMapIntensity × Scene.environmentIntensity。
     * 返回值为 (纹理, 强度)；无环境贴图时返回 None。
     *
     * @param[zh-cn] mat 材质
     * @return[zh-cn] Some((环境贴图, 强度)) 或 None
     *
     * @brief[en] _effectiveEnvMap: resolve the effective environment map (IBL) of a material
     * @param[en] mat Material
     * @return[en] Some((envMap, intensity)) or None
     */
    private func _effectiveEnvMap(mat: Material): Option<(Texture, Float64)> {
        // 仅 PBR 材质（standard/physical）走 IBL 路径
        if (mat.kind != "MeshStandardMaterial" && mat.kind != "MeshPhysicalMaterial") {
            return None
        }
        let texOpt = if (let Some(t) <- mat.envMap) { Some(t) } else { this._currentEnvMap }
        if (let Some(t) <- texOpt) {
            // 当前仅实现 PMREM CubeUV 路径；非 CubeUV 映射的贴图会被按 CubeUV 布局采样（告警提示）
            if (t.mapping != CubeUVReflectionMapping) {
                @LogDebug(["env", "envMap mapping=${t.mapping} != CubeUVReflectionMapping; sampled as CubeUV atlas"])
            }
            return Some((t, mat.envMapIntensity * this._currentEnvIntensity))
        }
        return None
    }

    /**
     * _bindEnvMap：绑定环境贴图（IBL）到 STAGE_ENV_MAP 并设置强度 uniform
     *
     * 对照 WebGLRenderer 的 envMap 绑定：材质 prepare 后把生效环境贴图
     * （material.envMap ?? scene.environment）绑到 u_envMap，强度写入 u_envMapIntensity。
     * 未绑定时标准/物理材质的 envmap_physical_pars_fragment 采样返回 0 → 无环境光照
     * （向光面仅剩直接光照，背光面全黑）。
     *
     * @param[zh-cn] mat 材质
     *
     * @brief[en] _bindEnvMap: bind the environment map (IBL) to STAGE_ENV_MAP and set the intensity uniform
     * @param[en] mat Material
     */
    private func _bindEnvMap(mat: Material): Unit {
        let effOpt = this._effectiveEnvMap(mat)
        if (let Some((envTex, intensity)) <- effOpt) {
            let texId = envTex.uuid.hashCode()
            var handle = TextureHandle(65535u16)
            if (let Some(h) <- this._matTexCache.get(texId)) {
                handle = h
            } else {
                handle = this._uploadEnvMapTexture(envTex)
                if (handle.idx != 65535u16) {
                    this._matTexCache.add(texId, handle)
                }
            }
            if (handle.idx == 65535u16) {
                @LogWarn(["bindEnv", "envMap handle INVALID, skip"])
                return
            }
            // ClampToEdge：CubeUV 图集边界必须 clamp，否则线性过滤会绕回采到错误层级/面
            let envFlags = UInt32(SAMPLER_U_CLAMP) | UInt32(SAMPLER_V_CLAMP)
            let sampler = this._cachedUniform("u_envMap", UniformType.Sampler.value())
            bgfx_set_texture_cj(SamplerStages.STAGE_ENV_MAP, sampler.value, handle, envFlags)
            let uIntensity = this._cachedUniform("u_envMapIntensity", UniformType.Vec4.value())
            this._uMem16.writeFloats([intensity, 0.0, 0.0, 0.0], 4)
            bgfx_set_uniform_cj(uIntensity.value, unsafe { CPointer<Unit>(this._uMem16.data()) }, 1u16)
            @LogTrace(["bindEnv", "u_envMap stage=${SamplerStages.STAGE_ENV_MAP.toString()} w=${envTex.width.toString()} h=${envTex.height.toString()} intensity=${intensity}"])
        }
    }

    /**
     * _uploadEnvMapTexture：把 PMREM CubeUV 环境贴图上传为 bgfx 2D 纹理
     *
     * 与 _uploadMaterialTexture 的区别：采样标志固定为 U/V ClampToEdge
     * （CubeUV 是图集，边界必须 clamp），无 mip 链（层级是图集内的独立平面）。
     *
     * @param[zh-cn] tex CubeUV 环境贴图（DataTexture）
     * @return[zh-cn] bgfx TextureHandle；失败返回 INVALID (65535)
     *
     * @brief[en] _uploadEnvMapTexture: upload a PMREM CubeUV env map as a bgfx 2D texture
     * @param[en] tex CubeUV env map (DataTexture)
     * @return[en] bgfx TextureHandle; INVALID (65535) on failure
     */
    private func _uploadEnvMapTexture(tex: Texture): TextureHandle {
        let w = tex.width
        let h = tex.height
        let img = tex.image
        if (w <= 0 || h <= 0 || img.size == 0) {
            @LogWarn(["uploadEnv", "tex=${tex.uuid} empty data w=${w.toString()} h=${h.toString()}"])
            return TextureHandle(65535u16)
        }
        let mem = BgfxMemory(UInt32(img.size))
        mem.writeUInt8(img, Int64(img.size))
        let flags = UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP)
        let handle = bgfx_create_texture_2d_cj(UInt16(w), UInt16(h), false, 1u16, TextureFormat.RGBA8.value(), flags, mem.get())
        @LogDebug(["uploadEnv", "tex=${tex.uuid} w=${w.toString()} h=${h.toString()} handle.idx=${handle.idx.toString()}"])
        return handle
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
            @LogWarn(["uploadTex", "tex=${tex.uuid} empty data w=${w.toString()} h=${h.toString()}"])
            return TextureHandle(65535u16)
        }
        // 拷贝 RGBA8 字节到 bgfx 内存
        let mem = BgfxMemory(UInt32(img.size))
        mem.writeUInt8(img, Int64(img.size))
        let memPtr = mem.get()
        // RGBA8 = TextureFormat.RGBA8 = 67
        let handle = bgfx_create_texture_2d_cj(UInt16(w), UInt16(h), false, 1u16, TextureFormat.RGBA8.value(), 0u64, memPtr)
        @LogDebug(["uploadTex", "tex=${tex.uuid} w=${w.toString()} h=${h.toString()} size=${img.size.toString()} handle.idx=${handle.idx.toString()}"])
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

    // ===== Shader 程序获取（主流 Web 引擎模式：从材质编译自定义 shader）=====
    // 对照 WebGLBackend: 从 material 获取已编译的 program
    // 对照参考代码 ThreeRenderer.getOrCreateProgram

    private var _customProgCache: HashMap<String, ProgramHandle> = HashMap<String, ProgramHandle>()
    private var _variantProgCache: HashMap<String, ProgramHandle> = HashMap<String, ProgramHandle>()

    /**
     * ShaderMaterial program 快路径缓存：Material.id → ProgramHandle。
     * 原实现每 draw 拼一次 "custom_" + sm.uuid 字符串（一次堆分配）再查 HashMap。
     * ShaderMaterial 的自定义 shader 与实例一一对应（uuid 唯一），故用 mat.id 作键即可。
     * 注意：只服务 ShaderMaterial 路径，不与内置材质的变体缓存混用。
     */
    private var _customProgByMatId: HashMap<Int64, ProgramHandle> = HashMap<Int64, ProgramHandle>()

    // D 项性能优化：variantKey 记忆化。
    // variantKey 由「材质前缀（shaderName_uuid_tex）+ 帧级光照后缀 + inst/env 后缀」组成。
    // 材质前缀在材质生命周期内恒定（mat.uuid/kind/纹理组合不变）→ 缓存，避免每 draw 重算
    // ShaderVariant.getVariantKey（数组分配 + join）与长字符串拼接；
    // 帧级光照后缀（9 个计数 + shadow 类型）在 beginRender 每帧拼一次，避免每 draw 9 次 toString。
    // 注意：若运行时替换材质的纹理/kind，前缀缓存会过期（罕见操作，换纹理后需重建 program，
    // 与本缓存预期一致：perf_render 等共享材质场景命中率 100%）。
    private var _frameLightSuffix: String = ""
    private var _matVariantPrefixCache: HashMap<Int64, String> = HashMap<Int64, String>()

    /**
     * @brief[zh-cn] 光照后缀的重建判据（上次重建时的各计数与阴影类型）
     * @explain[zh-cn] 光照后缀由 9 个计数 + 阴影类型拼成，每帧重建会产生十余次
     *               toString 与字符串拼接（实测 beginRender 自耗时 54µs 的一部分）。
     *               绝大多数帧这些值不变，故缓存上次取值，仅在变化时重建后缀串。
     *
     * @brief[en] Rebuild criteria for the light suffix (counts and shadow type at last rebuild)
     * @explain[en] The light suffix is built from 9 counts plus the shadow type; rebuilding
     *               it every frame costs a dozen toString calls and string concatenations
     *               (part of beginRender's 54µs self time). These values rarely change,
     *               so the last ones are cached and the suffix is rebuilt only on change.
     */
    private var _lsDir: Int64 = -1
    private var _lsPoint: Int64 = -1
    private var _lsSpot: Int64 = -1
    private var _lsHemi: Int64 = -1
    private var _lsProbe: Int64 = -1
    private var _lsDirShadow: Int64 = -1
    private var _lsPointShadow: Int64 = -1
    private var _lsSpotShadow: Int64 = -1
    private var _lsShadowType: Int64 = -1

    /**
     * program 快路径缓存：Material.id → 上次命中的变体指纹（帧级光照后缀 + 实例化标记 + env 标记）。
     * 命中时直接返回句柄，跳过 variantKey 的 3 次字符串拼接与长字符串哈希；
     * 指纹任一分量变化即回退完整键路径重新解析，语义与原实现一致。
     */
    private var _fastProgCache: HashMap<Int64, FastProg> = HashMap<Int64, FastProg>()

    private func _storeFastProg(matId: Int64, instSuffix: String, envSuffix: String,
                               lightSuffix: String, handle: ProgramHandle): Unit {
        if (let Some(fp) <- this._fastProgCache.get(matId)) {
            fp.lightSuffix = lightSuffix
            fp.instSuffix = instSuffix
            fp.envSuffix = envSuffix
            fp.handle = handle
        } else {
            let fp = FastProg()
            fp.lightSuffix = lightSuffix
            fp.instSuffix = instSuffix
            fp.envSuffix = envSuffix
            fp.handle = handle
            this._fastProgCache[matId] = fp
        }
    }

    /**
     * _getOrCreateProgram：按 mat.kind 选择基础 shader 并编译变体
     *
     * 流程：
     * 1. ShaderMaterial：用材质自带 vertexShader/fragmentShader 编译（varying def 从 $input/$output 提取）
     * 2. 其他材质：按 mat.kind 映射到基础 shader（basic/lambert/phong/standard/physical），
     *    调 ShaderProgram.createVariant 复制已解析的 bgfx 源码，再 compileBgfxWithDefines 编译
     *
     * 变体按 mat.uuid 缓存，避免每帧重编译。
     *
     * @param[zh-cn] instanced 是否为实例化变体：追加 USE_INSTANCING=1 define（激活 chunk 实例分支
     * 与 VS 的 i_data0..3 注入），variantKey 加 "_inst" 后缀与普通变体区分缓存
     */
    @Zone[three.rendering.bgfx.BgfxBackend._getOrCreateProgram]
    private func _getOrCreateProgram(mat: Material, instanced!: Bool = false): ProgramHandle {
        // 1. ShaderMaterial：编译材质自带的自定义 shader
        // 注意：RawShaderMaterial/ShaderMaterial 未设置 vertexShader/fragmentShader 时
        //       （空字符串），空 shader 编译必然失败 → 无模型显示但几何体仍在（射线可命中）。
        //       对照通用引擎惯例：ShaderMaterial 无自定义 shader 时回退到默认材质着色
        //       （主流 Web 引擎中 ShaderMaterial 默认有内置 shader；仓颉侧为空则回退基础路径）。
        if (mat is ShaderMaterial) {
            let smOpt = mat as ShaderMaterial
            if (let Some(sm) <- smOpt) {
                if (sm.vertexShader.size > 0 && sm.fragmentShader.size > 0) {
                    // 按材质 id 直接缓存 program：原实现每 draw 拼一次 "custom_" + sm.uuid
                    // 字符串（一次堆分配）再查 HashMap。ShaderMaterial 的自定义 shader
                    // 与实例一一对应（uuid 唯一），故用 mat.id 作键即可，无需拼前缀。
                    // 注意：ShaderMaterial 走独立缓存，不与内置材质的变体缓存混用。
                    if (let Some(prog) <- this._customProgByMatId.get(mat.id)) {
                        @LogDebug(["program", "ShaderMaterial cache HIT matId=${mat.id} prog.idx=${prog.idx}"])
                        return prog
                    }
                    let key = "custom_" + sm.uuid
                    if (let Some(prog) <- this._customProgCache.get(key)) {
                        @LogDebug(["program", "ShaderMaterial cache HIT key=${key} prog.idx=${prog.idx}"])
                        this._customProgByMatId[mat.id] = prog
                        return prog
                    }
                    @LogDebug(["program", "compiling custom shader key=${key} vsLen=${sm.vertexShader.size} fsLen=${sm.fragmentShader.size}"])
                    let varyingDef = this._extractVaryingDef(sm.vertexShader)
                    @LogDebug(["program", "varyingDef=${varyingDef}"])
                    let prog = ShaderProgram(key, sm.vertexShader, sm.fragmentShader, varyingDef: varyingDef)
                    prog.compileBgfx()
                    @LogDebug(["program", "custom compile result key=${key} prog.idx=${prog.programHandle.idx}"])
                    if (prog.programHandle.idx != 65535u16) {
                        this._customProgCache.add(key, prog.programHandle)
                        this._customProgByMatId[mat.id] = prog.programHandle
                        return prog.programHandle
                    }
                    @LogError(["program", "custom shader compile FAILED key=${key}"])
                    // 负缓存：同 variant，失败不缓存会导致每帧重编译
                    this._customProgCache.add(key, ProgramHandle(65535u16))
                    this._customProgByMatId[mat.id] = ProgramHandle(65535u16)
                    return ProgramHandle(65535u16)
                } else {
                    // 空 shader 回退：不编译自定义程序，落入下方按 mat.kind 的基础 shader 分发
                    @LogDebug(["program", "ShaderMaterial empty shader, fallback to basic kind=${sm.kind}"])
                }
            }
        }

        // 2. 其他材质：按 mat.kind 选择基础 shader 名称
        // 对照 ShaderLib 惯例：材质 kind → ShaderLibs 注册的程序名
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
            // bgfx4cj 扩展：debug 可视化材质（主流 Web 引擎无此扩展，属本仓库扩展）
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
        // variant 缓存键含光照/阴影计数+阴影类型+纹理组合（对照参考项目 ThreeRenderer 行 1291 的 lightKey）
        // 否则阴影光源数量或阴影类型变化时不会重编译 shader，导致阴影缺失或多余阴影分支
        // 纹理组合变化时也必须重编译，否则 PBR 路径（USE_MAP/USE_METALNESSMAP/USE_ROUGHNESSMAP）被剔除
        // D 项：帧级光照后缀（_num*Lights 计数 + 阴影计数 + shadow 类型）已由 beginRender 每帧构建一次，
        // 此处直接复用，避免每 draw 重复 9 次 toString 与长字符串拼接
        let frameLightSuffix = this._frameLightSuffix
        // 实例化变体标记
        let instSuffix = if (instanced) { "_inst" } else { "" }
        // IBL 变体：存在生效环境贴图时追加 "_env" 后缀，与无 envMap 的变体区分缓存
        // （否则同一材质在不同场景/不同环境贴图状态下会误用已编译变体）
        let envSuffix = if (let Some(_) <- this._effectiveEnvMap(mat)) { "_env" } else { "" }
        // 快路径：按 mat.id 记忆「上次命中的变体指纹」。命中时不重建 70+ 字符的 variantKey
        // （3 次字符串拼接）也不做长字符串哈希，只比对 3 个短分量。
        // 指纹任一分量变化（光照数量/阴影类型/实例化/环境贴图）即回退到完整键路径。
        if (let Some(fp) <- this._fastProgCache.get(mat.id)) {
            if (fp.instSuffix == instSuffix && fp.envSuffix == envSuffix &&
                fp.lightSuffix == frameLightSuffix) {
                return fp.handle
            }
        }
        // 材质前缀（shader 语义分组）记忆化：同一材质重复 draw 时不再重算
        // ShaderVariant.getVariantKey（数组分配 + join）与 shaderName/kind/texFlags 拼接
        //
        // 变体键按 shader 语义分组，不再按 mat.uuid（实例级）隔离：
        // 内置材质的编译产物（源码 + defines）只取决于 shader 名、材质 kind、
        // 纹理标志、光照/实例化/env 后缀，与材质实例本身无关。相同 kind 的多个材质
        // （如 5 个无贴图 MeshPhongMaterial）此前会各自编译一份完全相同的 shader
        // （bokeh_pass 场景实测 7 次重复编译合计约 1.97s），现共享同一 program。
        // 例外：ReflectorMaterial 的 useDepthTexture / distanceAttenuation / fresnel
        // 是随实例变化的编译期 define，保留 uuid 隔离以维持既有行为。
        var matPrefix = ""
        if (let Some(p) <- this._matVariantPrefixCache.get(mat.id)) {
            matPrefix = p
        } else {
            // ShaderVariant.getVariantKey 返回 kind 或 kind_FLAG1_FLAG2...（FLAG 为大写 USE_XXX 前缀名）
            let texVariant = ShaderVariant.getVariantKey(mat)
            // 提取变体中的纹理标志部分（去掉前导 kind），拼到 variantKey 中
            let texFlagsPart = if (texVariant.size > mat.kind.size + 1) {
                texVariant[mat.kind.size + 1..]
            } else {
                ""
            }
            matPrefix = if (mat is ReflectorMaterial) {
                shaderName + "_" + mat.uuid + "_tex" + texFlagsPart
            } else {
                shaderName + "_" + mat.kind + "_tex" + texFlagsPart
            }
            this._matVariantPrefixCache.add(mat.id, matPrefix)
        }
        let variantKey = matPrefix + frameLightSuffix + instSuffix + envSuffix
        if (let Some(h) <- this._variantProgCache.get(variantKey)) {
            this._storeFastProg(mat.id, instSuffix, envSuffix, frameLightSuffix, h)
            return h
        }
        @LogDebug(["program", "compiling variant key=" + variantKey + " shaderName=" + shaderName + " texFlags=" + texFlagsPart])
        if (let Some(baseProg) <- ShaderLibs.get(shaderName)) {
            let variantProg = ShaderProgram.createVariant(variantKey, baseProg)
            // 构建光照计数 defines（NUM_DIR_LIGHTS 等）
            // 对照原始有效实现 ThreeRenderer.getOrCreateProg（行 1332-1339）
            // 不传这些 defines 会导致 #if NUM_DIR_LIGHTS > 0 整段被预处理器剔除 → 物体渲染为黑
            let lightDefs = this._buildLightDefines()
            // 合并材质纹理 #define（USE_MAP=1 / USE_METALNESSMAP=1 / USE_ROUGHNESSMAP=1 / ...）
            // 不传则 map_fragment/metalnessmap_fragment/roughnessmap_fragment 整段被预处理器剔除
            // → PBR 纹理路径失效 → 模型呈现纯金属/纯粗糙（向光白背光黑）
            let defines = this._mergeTextureDefines(lightDefs, mat)
            // 实例化变体：追加 USE_INSTANCING=1（激活 project_vertex/defaultnormal_vertex/
            // worldpos_vertex 等 chunk 的实例分支 + VS 的 i_data0..3 输入注入）
            var defArray = defines.defs
            if (instanced) {
                let arr = ArrayList<String>()
                for (d in defArray) { arr.add(d) }
                arr.add("USE_INSTANCING=1")
                defArray = arr.toArray()
            }
            lightDefs.dispose()
            variantProg.compileBgfx(extraDefines: defArray)
            defines.dispose()
            if (variantProg.programHandle.idx != 65535u16) {
                this._variantProgCache.add(variantKey, variantProg.programHandle)
                this._storeFastProg(mat.id, instSuffix, envSuffix, frameLightSuffix, variantProg.programHandle)
                @LogDebug(["program", "variant compiled OK key=" + variantKey + " idx=" + variantProg.programHandle.idx.toString()])
                return variantProg.programHandle
            }
            @LogError(["program", "variant compile FAILED key=" + variantKey])
            // 负缓存：把失败结果（无效句柄）也写入缓存。编译失败不缓存时，每次 draw 都会重新
            // 走完整编译流程（实测 800 对象场景每帧重试，单帧多花数百 ms）。
            // 调用方按 idx==65535 跳过 submit，语义与首次失败一致。
            this._variantProgCache.add(variantKey, ProgramHandle(65535u16))
            this._storeFastProg(mat.id, instSuffix, envSuffix, frameLightSuffix, ProgramHandle(65535u16))
            return ProgramHandle(65535u16)
        }
        @LogError(["program", "base shader not found: " + shaderName])
        return ProgramHandle(65535u16)
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
            if (let Some(rm) <- (mat as ReflectorMaterial)) {
                if (rm.useDepthTexture) { allDefs.add("useDepthTexture=1") }
                if (rm.distanceAttenuation) { allDefs.add("DISTANCE_ATTENUATION=1") }
                if (rm.fresnel) { allDefs.add("FRESNEL=1") }
            }
        }
        // 2.7 环境贴图（IBL）：存在生效 envMap 时注入 USE_ENVMAP + ENVMAP_TYPE_CUBE_UV，
        //     激活 cube_uv_reflection_fragment / envmap_physical_pars_fragment 的 CubeUV 路径；
        //     不传则 lights_fragment_maps 的 IBL 补光段被预处理器整体剔除 → 无环境反射。
        if (let Some(_) <- this._effectiveEnvMap(mat)) {
            allDefs.add("USE_ENVMAP=1")
            allDefs.add("ENVMAP_TYPE_CUBE_UV=1")
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
        // 阴影光源计数 defines（对照参考项目 ThreeRenderer 行 1339-1357）
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
        @LogDebug(["extractVaryingDef", "result=" + result])
        return result
    }

    /**
     * 创建顶点缓冲（从 geometry 的 position/normal/color/uv 属性读取）
     */
    @Zone[three.rendering.bgfx.BgfxBackend._createVB]
    internal func _createVB(geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.id
        // position 属性版本号：CPU 蒙皮等每帧修改数据时会自增
        let posVersion = if (let Some(p) <- geom.getAttribute("position")) { p.version } else { 0 }
        if (let Some(vb) <- this._vbCache.get(geomId)) {
            // 版本未变 → 复用缓存
            if (let Some(v) <- this._vbVersions.get(geomId)) {
                if (v == posVersion) { return vb }
            }
            // 版本变化 → 销毁旧缓冲并重建
            if (vb.idx != 65535u16) {
                bgfx_destroy_vertex_buffer_cj(vb)
            }
            this._vbCache.remove(geomId)
        }
        let posAttrOpt = geom.getAttribute("position")
        if (let Some(pos) <- posAttrOpt) {
            let vc = pos.count
            if (vc == 0) { return VertexBufferHandle(65535u16) }
            // position(3) + normal(3) + color(4) + uv(2) = 12 floats
            let vertStride: Int64 = 12
            let totalFloats = vc * vertStride
            // ★直接以 Float32 写入 bgfx 内存：原实现先落一份 Float64 中间数组
            //   （每帧 vc*12 个 double），再由 writeFloats 逐个转成 Float32——
            //   多一遍分配 + 多一遍内存遍历。改为一次遍历直写。
            let mem = BgfxMemory(UInt32(totalFloats * 4))
            let fPtr = unsafe { CPointer<Float32>(mem.data()) }
            // 属性数组与步长一次性取出，避免逐顶点做 Option 匹配与方法调用
            let posArr = pos.array
            let posStep = pos.itemSize
            let normAttrOpt = geom.getAttribute("normal")
            let colAttrOpt = geom.getAttribute("color")
            let uvAttrOpt = geom.getAttribute("uv")
            var normArr = Array<Float64>(0, { _ => 0.0 })
            var normStep: Int64 = 0
            var hasNormal = false
            if (let Some(na) <- normAttrOpt) {
                normArr = na.array
                normStep = na.itemSize
                hasNormal = true
            }
            var colArr = Array<Float64>(0, { _ => 0.0 })
            var colStep: Int64 = 0
            var colHasW = false
            var hasColor = false
            if (let Some(ca) <- colAttrOpt) {
                colArr = ca.array
                colStep = ca.itemSize
                colHasW = ca.itemSize > 3
                hasColor = true
            }
            var uvArr = Array<Float64>(0, { _ => 0.0 })
            var uvStep: Int64 = 0
            var hasUv = false
            if (let Some(ua) <- uvAttrOpt) {
                uvArr = ua.array
                uvStep = ua.itemSize
                hasUv = true
            }
                for (vi in 0..vc) {
                    let base = vi * vertStride
                    let pb = vi * posStep
                    unsafe {
                        fPtr.write(base, Float32(posArr[pb]))
                        fPtr.write(base + 1, Float32(posArr[pb + 1]))
                        fPtr.write(base + 2, Float32(posArr[pb + 2]))
                        // ★缺省分量必须显式写 0：bgfx_alloc 的内存不做零初始化，
                        //   漏写会让该分量取到垃圾值（法线 x/y 垃圾 → 着色闪烁）。
                        if (hasNormal) {
                            let nb = vi * normStep
                            fPtr.write(base + 3, Float32(normArr[nb]))
                            fPtr.write(base + 4, Float32(normArr[nb + 1]))
                            fPtr.write(base + 5, Float32(normArr[nb + 2]))
                        } else {
                            fPtr.write(base + 3, 0.0)
                            fPtr.write(base + 4, 0.0)
                            fPtr.write(base + 5, 1.0)
                        }
                        if (hasColor) {
                            let cb = vi * colStep
                            fPtr.write(base + 6, Float32(colArr[cb]))
                            fPtr.write(base + 7, Float32(colArr[cb + 1]))
                            fPtr.write(base + 8, Float32(colArr[cb + 2]))
                            fPtr.write(base + 9, if (colHasW) { Float32(colArr[cb + 3]) } else { 1.0 })
                        } else {
                            fPtr.write(base + 6, 1.0)
                            fPtr.write(base + 7, 1.0)
                            fPtr.write(base + 8, 1.0)
                            fPtr.write(base + 9, 1.0)
                        }
                        if (hasUv) {
                            let ub = vi * uvStep
                            fPtr.write(base + 10, Float32(uvArr[ub]))
                            fPtr.write(base + 11, Float32(uvArr[ub + 1]))
                        } else {
                            fPtr.write(base + 10, 0.0)
                            fPtr.write(base + 11, 0.0)
                        }
                    }
                }
                let layout = this._getOrCreateLayoutPtr()
                let handle = bgfx_create_vertex_buffer_cj(mem.get(), layout, 0u16)
                this._vbCache.add(geomId, handle)
                this._vbVersions.add(geomId, posVersion)
                return handle
        }
        return VertexBufferHandle(65535u16)
    }

    /**
     * 创建索引缓冲
     */
    @Zone[three.rendering.bgfx.BgfxBackend._createIB]
    internal func _createIB(geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.id
        if (let Some(ib) <- this._ibCache.get(geomId)) { return ib }
        if (let Some(idxAttr) <- geom.index) {
            let count = idxAttr.count
            if (count == 0) { return IndexBufferHandle(65535u16) }
            // 索引数组存 Float64，需转为 UInt16 写入（2字节/索引）
            @LogDebug(["createIB", "index count=" + count.toString()])
            let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
            let mem = BgfxMemory(UInt32(count * 2))
            mem.writeUInt16(idxData, count)
            let handle = bgfx_create_index_buffer_cj(mem.get(), 0u16)
            @LogDebug(["createIB", "handle.idx=" + handle.idx.toString()])
            this._ibCache.add(geomId, handle)
            return handle
        }
        return IndexBufferHandle(65535u16)
    }

    /**
     * 获取/创建顶点布局指针（供 bgfx_create_vertex_buffer_cj 使用）
     */
    private func _getOrCreateLayoutPtr(): CPointer<VertexLayout> {
        // 布局是常量：缓存结构指针，避免每次创建顶点缓冲都 malloc + 重建一次布局。
        // 注意：此处刻意不用 AutoFreePtr（其终结器会在 GC 回收时 free 掉内存，
        // 缓存后即成悬垂指针）；改为一次性 malloc 并常驻，布局体积极小。
        if (let Some(p) <- this._layoutPtrCache) { return p }
        let layoutPtr = unsafe { LibC.malloc<VertexLayout>() }
        unsafe { layoutPtr.write(VertexLayout()) }
        bgfx_vertex_layout_begin_cj(layoutPtr, 0u32)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Position.value(), 3u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Normal.value(), 3u8, AttribType.Float.value(), true, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.Color0.value(), 4u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_add_cj(layoutPtr, Attrib.TexCoord0.value(), 2u8, AttribType.Float.value(), false, false)
        bgfx_vertex_layout_end_cj(layoutPtr)
        // bgfx_create_vertex_buffer_cj 会在内部复制布局数据，因此布局结构本身可长期持有
        this._layoutPtrCache = Some(layoutPtr)
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
        if (let Some(lh) <- this._layoutHandleCache) { return lh }
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
        bgfx_frame_cj(flags: FRAME_NONE)
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
    @Zone[three.rendering.bgfx.BgfxBackend.finishRender]
    public override func finishRender(renderContext: RenderContext): Unit {
        bgfx_touch_cj(renderContext.viewId)
        bgfx_frame_cj(flags: FRAME_NONE)
        // 帧计数推进：下一帧的光源收集缓存失效（帧内复用，跨帧不复用）
        this._lightFrameIndex += 1
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
    @Zone[three.rendering.bgfx.BgfxBackend.prepareShadowMap]
    public override func prepareShadowMap(scene: Scene): Unit {
        // 注意：去掉 initialized 守卫——ThreeRenderer 多线程委托机制下，
        // prepareShadowMap 在专用渲染线程上下文调时 initialized 字段跨线程可见性没保证，
        // 早 return 命中导致 _shadowFB 没创建 → blit SKIP。
        // bgfx_init 在 ThreeRenderer.init 时已完成，专用线程启动前 initialized 已 true；
        // 且 prepareShadowMap 内部 bgfx API 调用本身是安全的，无需此守卫。

        // 多光源阴影支持：每帧重置当前帧 shadow slot 注册表与 view ID 游标。
        // 持久资源（_shadowResources）跨帧复用，不在此处清理；光源销毁时由调用方显式释放。
        // 收集场景中所有方向光 + 聚光灯 + 点光源（castShadow=true 的才参与阴影深度 pass）
        // 复用帧内缓存（与 beginRender 同帧同场景，无需第二次全场景遍历）
        let (dirLights, pointLights, _, spotLights, _, _) = this._collectLightsCached(scene)
        @LogTrace(["shadow", "prepareShadowMap dirLights.size=${dirLights.size} spotLights.size=${spotLights.size} pointLights.size=${pointLights.size}"])
        // 无投影光源时整段阴影预 pass 为空转（每帧仅剩注册表清空 + 三趟空循环）：
        // 直接返回，仅保留必要的状态失效（上一帧若有槽位必须先清，否则 bindShadowUniforms
        // 的 hasShadowSlots() 仍为真、继续逐 draw 绑定过期槽位）。
        var hasCaster = false
        for (dl in dirLights) { if (dl.castShadow) { hasCaster = true; break } }
        if (!hasCaster) {
            for (sl in spotLights) { if (sl.castShadow) { hasCaster = true; break } }
        }
        if (!hasCaster) {
            for (pl in pointLights) { if (pl.castShadow) { hasCaster = true; break } }
        }
        if (!hasCaster) {
            if (this.shadowPass.hasShadowSlots()) {
                this.shadowPass.beginFrame()
            }
            return
        }
        this.shadowPass.beginFrame()

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
        @LogTrace(["shadow", "prepareShadowMap done"])
    }

    /**
     * 绑定阴影 uniform 到主 pass draw。
     */
    @Zone[three.rendering.bgfx.BgfxBackend.bindShadowUniforms]
    public override func bindShadowUniforms(): Unit {
        // 无 castShadow 光源时当帧没有阴影槽，逐 draw 调用是纯空转，直接跳过
        if (!this.shadowPass.hasShadowSlots()) {
            return
        }
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
            if (let Some(kind) <- this.shadowPass._shadowSlotKind.get(lid)) {
                if (kind == "dir") {
                    if (let Some(s) <- this.shadowPass._shadowSlots.get(lid)) {
                        blitSlot = Some(s)
                    }
                    break
                }
            }
        }
        if (let Some(slot) <- blitSlot) {
            if (slot.frameBuffer.idx == 65535u16) { @LogDebug(["blit", "SKIP: shadowFB not created"]); return }
            // 确保 shadowblit shader 已编译
            let blitProgOpt = ShaderLibs.get("shadowblit")
            if (let Some(blitSp) <- blitProgOpt) {
                if (blitSp.programHandle.idx == 65535u16) {
                    blitSp.compileBgfx()
                }
                let blitProg = blitSp.programHandle
                if (blitProg.idx == 65535u16) { @LogDebug(["blit", "SKIP: shadowblit prog compile failed"]); return }

                this.blitQuad.ensureBlitVB()
                // 仓颉不支持多元素 tuple match，改为逐层解构
                if (let Some(vb) <- this.blitQuad._blitVB && let Some(ib) <- this.blitQuad._blitIB && let Some(layout) <- this.blitQuad._blitLayout) {
                    // 绑定阴影贴图纹理到 sampler stage 0（shadowblit shader 的 shadowBlitSampler）
                    // 关键：attachment 0 = color texture（RGBA8，depth shader 写 gl_FragCoord.z 到 color）
                    let shadowTex = bgfx_get_texture_cj(slot.frameBuffer, 0u8)
                    @LogDebug(["blit", "shadowTex idx=${shadowTex.idx} shadowFB idx=${slot.frameBuffer.idx}"])
                    let blitSampler = this.uniforms.createUniform("shadowBlitSampler", UniformType.Sampler.value())
                    bgfx_set_texture_cj(SamplerStages.STAGE_SHADOW_BLIT, blitSampler.value, shadowTex, 0u32)

                    bgfx_set_vertex_buffer_with_layout_cj(0u8, vb, 0u32, 0xFFFFFFFFu32, layout)
                    bgfx_set_index_buffer_cj(ib, 0u32, 0xFFFFFFFFu32)
                    // 关键：blit 不需要深度测试（全屏四边形 z=0），关掉 DEPTH_TEST 避免被主 pass 深度挡
                    let blitState = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW
                    bgfx_set_state_cj(blitState, 0x00000000u32)
                    bgfx_submit_cj(mainViewId, blitProg, 0u32, 0xFFu8)
                    @LogDebug(["blit", "submit OK mainViewId=${mainViewId}"])
                } else {
                    @LogDebug(["blit", "SKIP: blitVB/IB/Layout None"])
                }
            } else {
                @LogDebug(["blit", "SKIP: shadowblit shader not registered"])
            }
        } else {
            @LogDebug(["blit", "SKIP: no dir shadow slot"])
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
        bgfx_frame_cj(flags: FRAME_NONE)
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
        @LogTrace(["viewTransform", "view[0]=" + view[0].toString() + " view[5]=" + view[5].toString() + " view[10]=" + view[10].toString()])
        @LogTrace(["viewTransform", "proj[0]=" + proj[0].toString() + " proj[5]=" + proj[5].toString() + " proj[10]=" + proj[10].toString() + " proj[14]=" + proj[14].toString()])
        // 复用的上传缓冲：原实现每次调用新建 2 块 BgfxMemory（走 bgfx_alloc，
        // 内存不会归还 → 逐帧调用等于持续泄漏原生内存）。
        // view/proj 必须是两块独立缓冲：二者在同一调用内同时写入后一起传给
        // bgfx_set_view_transform_cj，共用一块会让后写覆盖先写的数据。
        // 复用安全性：bgfx_set_view_transform 调用时即 memcpy 两者（View::setTransform），
        // 数据在返回前已被引擎取走。
        let viewMem = this._uMem64
        let projMem = this._viewProjMem
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
    @Zone[three.rendering.bgfx.BgfxBackend._bindSceneTextures]
    private func _bindSceneTextures(): Unit {
        // 绑定 DFG LUT（16x16 RG16F 半浮点数据）
        // 注意：格式必须用 TextureFormat.RG16F.value()（=56），不能用 92——
        // 92 是 BGFX_TEXTURE_FORMAT_D16F（深度浮点格式），若用错则纹理采样异常，
        // dfgLUT 采样为 0 → EssMs=0 → 1.0/EssMs 无穷 → 高光爆炸（向光面全白）。
        // 采样 flags 必须用 CLAMP（对照通用引擎 dfgLUT 的 ClampToEdgeWrapping）：
        // 否则 wrap 模式下 roughness≈1（粗糙球）时 u 坐标接近 1.0 会绕回 0，
        // 采到错误 LUT 数据 → EssMs 异常 → multiScatteringCompensation 错误 → 黑色光斑。
        // ★逐 draw 调用：纹理句柄与采样器句柄只解析一次并缓存（避免每 draw 重复
        //   uuid 字符串哈希 + 字符串键 HashMap 查找），绑定动作仍需每 draw 执行
        //   （submit 用 DISCARD_ALL 会清空纹理绑定）。
        let lutFlags = UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP)
        let sampler = if (let Some(h) <- this._dfgLutSampler) {
            h
        } else {
            let h = this._cachedUniform("dfgLUT", UniformType.Sampler.value())
            this._dfgLutSampler = Some(h)
            h
        }
        var handle = this._dfgLutHandle
        if (handle.idx == 65535u16) {
            let dfgLutTex = getDFGLUT()
            let cacheKey = dfgLutTex.id
            handle = if (let Some(h) <- this._matTexCache.get(cacheKey)) {
                h
            } else {
                let w = dfgLutTex.width
                let h = dfgLutTex.height
                let img = dfgLutTex.image
                if (w <= 0 || h <= 0 || img.size == 0) {
                    @LogWarn(["bindScene", "dfgLUT empty data w=${w.toString()} h=${h.toString()}"])
                    return
                }
                let mem = BgfxMemory(UInt32(img.size))
                mem.writeUInt8(img, Int64(img.size))
                let newHandle = bgfx_create_texture_2d_cj(UInt16(w), UInt16(h), false, 1u16, TextureFormat.RG16F.value(), lutFlags, mem.get())
                if (newHandle.idx != 65535u16) {
                    this._matTexCache.add(cacheKey, newHandle)
                    this._dfgLutHandle = newHandle
                }
                newHandle
            }
        }
        if (handle.idx == 65535u16) {
            @LogWarn(["bindScene", "dfgLUT handle INVALID, skip"])
            return
        }
        bgfx_set_texture_cj(SamplerStages.STAGE_DFGLUT, sampler.value, handle, UInt32(lutFlags))
    }

    // ===== 阴影状态字段 + 全屏 blit 资源已迁出至 BgfxShadowPass / BgfxBlitQuad =====
    // 详见 BgfxShadowPass.cj / BgfxBlitQuad.cj（internal 组合注入）。
    // 阴影深度预 pass（renderShadowMap/renderSpotShadowMap/renderPointShadowMap/_render*Depth）
    // + 主 pass 阴影 uniform 绑定（bindShadowUniforms）+ 全屏 blit（ensureBlitVB/getOrCreateBlitLayout*）
    // 全部迁出至 BgfxShadowPass / BgfxBlitQuad，本类仅保留 prepareShadowMap/bindShadowUniforms/blitShadowMap 委托。
}
