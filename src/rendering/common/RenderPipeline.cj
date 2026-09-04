/**
 * @file[zh-cn] 渲染管线
 * @brief[zh-cn] TSL outputNode 驱动的全屏渲染管线
 * @explain[zh-cn] 
 * RenderPipeline 通过 TSL outputNode + QuadMesh 全屏三角形驱动管线：
 * render() → _update() → quadMesh.render(renderer) → backend.beginRender → backend.draw
 * 对照源码: three.js/src/renderers/common/RenderPipeline.js (252 行)
 *
 * @file[en] RenderPipeline
 * @brief[en] TSL outputNode-driven fullscreen render pipeline
 * @explain[en] 
 * RenderPipeline drives the pipeline via TSL outputNode + QuadMesh fullscreen triangle:
 * render() → _update() → quadMesh.render(renderer) → backend.beginRender → backend.draw
 * Corresponding source: three.js/src/renderers/common/RenderPipeline.js (252 lines)
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import std.collection.*

/**
 * @brief[zh-cn] TSL 渲染管线
 * @explain[zh-cn] 
 * 核心流程：
 * 1. render() 入口
 * 2. _update() 检测 toneMapping/outputColorSpace 变更，更新 contextData
 * 3. _quadMesh.render(renderer) 全屏三角形驱动
 * 4. dispose() 释放资源
 *
 * @brief[en] TSL render pipeline
 * @explain[en] 
 * Core flow:
 * 1. render() entry point
 * 2. _update() detects toneMapping/outputColorSpace changes, updates contextData
 * 3. _quadMesh.render(renderer) fullscreen triangle drive
 * 4. dispose() releases resources
 */
public open class RenderPipeline {
    /**
     * @brief[zh-cn] 类型测试标志
     *
     * @brief[en] Type test flag
     */
    public let isRenderPipeline: Bool = true

    /**
     * @brief[zh-cn] 渲染器引用
     *
     * @brief[en] Renderer reference
     */
    public let renderer: Renderer

    /**
     * @brief[zh-cn] TSL output 节点（占位 Option<Any>）
     *
     * @brief[en] TSL output node (placeholder Option<Any>)
     */
    public var outputNode: Option<Any>

    /**
     * @brief[zh-cn] 是否启用 output 色彩变换
     *
     * @brief[en] Whether to enable output color transform
     */
    public var outputColorTransform: Bool = true

    /**
     * @brief[zh-cn] 是否需要更新
     *
     * @brief[en] Whether update is needed
     */
    public var needsUpdate: Bool = true

    /**
     * @brief[zh-cn] 全屏 quad 网格
     *
     * @brief[en] Fullscreen quad mesh
     */
    private var _quadMesh: QuadMesh

    /**
     * @brief[zh-cn] 缓存的 toneMapping 值
     *
     * @brief[en] Cached toneMapping value
     */
    private var _toneMapping: Int64

    /**
     * @brief[zh-cn] 缓存的 outputColorSpace 值
     *
     * @brief[en] Cached outputColorSpace value
     */
    private var _outputColorSpace: String

    /**
     * @brief[zh-cn] 上下文数据
     *
     * @brief[en] Context data
     */
    private var _contextData: Option<HashMap<String, Any>> = None

    /**
     * @brief[zh-cn] 构造渲染管线
     * @param[zh-cn] renderer 渲染器实例
     * outputNode TSL output 节点
     *
     * @brief[en] Constructs a render pipeline
     * @param[en] renderer Renderer instance
     * outputNode TSL output node
     */
    public init(renderer: Renderer, outputNode: Option<Any>) {
        this.renderer = renderer
        this.outputNode = outputNode
        this.outputColorTransform = true
        this.needsUpdate = true

        // 实例化全屏 quad mesh
        this._quadMesh = QuadMesh()
        this._quadMesh.material = Material()

        // 初始化缓存值
        this._toneMapping = renderer.toneMapping
        this._outputColorSpace = renderer.outputColorSpace
    }

    /**
     * @brief[zh-cn] 无参构造器（向后兼容）
     *
     * @brief[en] No-argument constructor (backward compatible)
     */
    public init() {
        this.renderer = Renderer()
        this.outputNode = None
        this.outputColorTransform = true
        this.needsUpdate = true
        this._quadMesh = QuadMesh()
        this._quadMesh.material = Material()
        this._toneMapping = 0
        this._outputColorSpace = "srgb"
    }

    /**
     * @brief[zh-cn] 执行渲染管线
     * @explain[zh-cn] 
     * 流程：1. _update() 检测配置变更；2. 暂存/设置 renderer 状态；3. _quadMesh.render() 全屏三角形；4. 恢复状态
     *
     * @brief[en] Executes the render pipeline
     * @explain[en] 
     * Flow: 1. _update() detects config changes; 2. save/restore renderer state; 3. _quadMesh.render() fullscreen triangle; 4. restore state
     */
    public func render(): Unit {
        this._update()

        // 暂存 renderer 状态
        let prevToneMapping = this.renderer.toneMapping
        let prevOutputColorSpace = this.renderer.outputColorSpace

        // 设置临时状态
        this.renderer.toneMapping = 0  // NoToneMapping
        this.renderer.outputColorSpace = "srgb"  // 工作色彩空间

        // 暂存并禁用 xr
        // renderer.xr.enabled 暂存/恢复

        // 全屏 triangle
        this._quadMesh.render(this.renderer)

        // 恢复状态
        // renderer.xr.enabled 恢复
        this.renderer.toneMapping = prevToneMapping
        this.renderer.outputColorSpace = prevOutputColorSpace
    }

    /**
     * @brief[zh-cn] 检测配置变更并更新 contextData
     * @explain[zh-cn] 
     * 检测 toneMapping/outputColorSpace 变更，构造 contextData，设置 _quadMesh.material。
     *
     * @brief[en] Detects config changes and updates contextData
     * @explain[en] 
     * Detects toneMapping/outputColorSpace changes, constructs contextData, sets _quadMesh.material.
     */
    public func _update(): Unit {
        // 检测 toneMapping 变更
        if (this._toneMapping != this.renderer.toneMapping) {
            this._toneMapping = this.renderer.toneMapping
            this.needsUpdate = true
        }

        // 检测 outputColorSpace 变更
        if (this._outputColorSpace != this.renderer.outputColorSpace) {
            this._outputColorSpace = this.renderer.outputColorSpace
            this.needsUpdate = true
        }

        if (this.needsUpdate) {
            // 构造 contextData（RenderPipeline 无 hashCode 成员，用 kind 字符串标识）
            let contextData = HashMap<String, Any>()
            contextData.add("renderPipeline", "RenderPipeline")
            // 设置 _quadMesh 材质（仓颉 Material 无 fragmentNode 字段，用 stub）
            this._quadMesh.material = Material()
            this.needsUpdate = false
        }
    }

    /**
     * @brief[zh-cn] 释放渲染管线资源
     *
     * @brief[en] Disposes render pipeline resources
     */
    public func dispose(): Unit {
        this._quadMesh.material.dispose()
    }

    /**
     * @brief[zh-cn] 已废弃的异步渲染方法，请使用 render()
     *
     * @brief[en] Deprecated async render method, use render() instead
     */
    public func renderAsync(): Unit {
        println("RenderPipeline: \"renderAsync()\" has been deprecated. Use \"render()\".")
        this.render()
    }
}
