/**
 * @file[zh-cn] 渲染上下文
 * @brief[zh-cn] 渲染上下文，封装一次渲染 pass 的完整状态
 * @explain[zh-cn] 
 * RenderContext 封装 view/projection 矩阵、viewport、scissor、renderTarget、
 * clippingContext、active、occlusion、clearColor/Depth/Stencil 等字段。
 * 实现 IRenderContext 占位接口。
 * 对照源码: three.js/src/renderers/common/RenderContext.js (289 行)
 *
 * @file[en] RenderContext
 * @brief[en] Render context, encapsulating the complete state of a render pass
 * @explain[en] 
 * RenderContext encapsulates view/projection matrices, viewport, scissor, renderTarget,
 * clippingContext, active, occlusion, clearColor/Depth/Stencil and other fields.
 * Implements the IRenderContext placeholder interface.
 * Corresponding source: three.js/src/renderers/common/RenderContext.js (289 lines)
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
import three.rendering.cameras.*

/**
 * @brief[zh-cn] 渲染上下文
 * @explain[zh-cn] 
 * 封装一次渲染 pass 的完整状态，包括 view/projection 矩阵、viewport、scissor、
 * renderTarget、clippingContext、active、occlusion、clearColor/Depth/Stencil 等字段。
 * 实现 IRenderContext 占位接口。
 *
 * @brief[en] Render context
 * @explain[en] 
 * Encapsulates the complete state of a render pass, including view/projection matrices, viewport, scissor,
 * renderTarget, clippingContext, active, occlusion, clearColor/Depth/Stencil and other fields.
 * Implements the IRenderContext placeholder interface.
 */
public open class RenderContext <: IRenderContext {
    /**
     * @brief[zh-cn] 唯一标识
     *
     * @brief[en] Unique identifier
     */
    public var id: Int64

    /**
     * @brief[zh-cn] 场景引用
     *
     * @brief[en] Scene reference
     */
    public var scene: Option<Scene> = None

    /**
     * @brief[zh-cn] 相机引用
     *
     * @brief[en] Camera reference
     */
    public var camera: Option<Camera> = None

    /**
     * @brief[zh-cn] 视图 ID（用于 bgfx view 命令）
     *
     * @brief[en] View ID (used for bgfx view commands)
     */
    public var viewId: UInt16 = 0u16

    /**
     * @brief[zh-cn] 视图矩阵（16 Float64 列主序）
     *
     * @brief[en] View matrix (16 Float64 values in column-major order)
     */
    public var viewMatrix: Array<Float64> = Array<Float64>(16, { _ => 0.0 })

    /**
     * @brief[zh-cn] 投影矩阵（16 Float64 列主序）
     *
     * @brief[en] Projection matrix (16 Float64 values in column-major order)
     */
    public var projMatrix: Array<Float64> = Array<Float64>(16, { _ => 0.0 })

    /**
     * @brief[zh-cn] 视口 (x, y, w, h)
     *
     * @brief[en] Viewport (x, y, w, h)
     */
    public var viewport: (Int32, Int32, Int32, Int32) = (0, 0, 0, 0)

    /**
     * @brief[zh-cn] 裁剪区域 (x, y, w, h)
     *
     * @brief[en] Scissor region (x, y, w, h)
     */
    public var scissor: (Int32, Int32, Int32, Int32) = (0, 0, 0, 0)

    /**
     * @brief[zh-cn] 渲染目标（FBO 句柄，可为空）
     *
     * @brief[en] Render target (FBO handle, may be None)
     */
    public var renderTarget: Option<RenderTarget> = None

    /**
     * @brief[zh-cn] 裁剪上下文（可选）
     *
     * @brief[en] Clipping context (optional)
     */
    public var clippingContext: Option<String> = None

    /**
     * @brief[zh-cn] 是否活跃
     *
     * @brief[en] Whether active
     */
    public var active: Bool = false

    /**
     * @brief[zh-cn] 遮挡查询
     *
     * @brief[en] Occlusion query
     */
    public var occlusion: Bool = false

    /**
     * @brief[zh-cn] 绘制宽度
     *
     * @brief[en] Draw width
     */
    public var width: Int64 = 0

    /**
     * @brief[zh-cn] 绘制高度
     *
     * @brief[en] Draw height
     */
    public var height: Int64 = 0

    /**
     * @brief[zh-cn] 清除颜色（UInt32 RGBA）
     *
     * @brief[en] Clear color (UInt32 RGBA)
     */
    public var clearColor: UInt32 = 0x00000000u32

    /**
     * @brief[zh-cn] 是否清除颜色缓冲
     *
     * @brief[en] Whether to clear the color buffer
     */
    public var clearColorBool: Bool = true

    /**
     * @brief[zh-cn] 是否清除深度缓冲
     *
     * @brief[en] Whether to clear the depth buffer
     */
    public var clearDepth: Bool = true

    /**
     * @brief[zh-cn] 是否清除模板缓冲
     *
     * @brief[en] Whether to clear the stencil buffer
     */
    public var clearStencil: Bool = false

    /**
     * @brief[zh-cn] 深度清除值
     *
     * @brief[en] Depth clear value
     */
    public var depthClearValue: Float64 = 1.0

    /**
     * @brief[zh-cn] 模板清除值
     *
     * @brief[en] Stencil clear value
     */
    public var stencilClearValue: UInt32 = 0u32

    /**
     * @brief[zh-cn] 构造默认渲染上下文
     *
     * @brief[en] Constructs a default render context
     */
    public init() {
        this.id = 0
    }

    // ===== IRenderContext 实现 =====

    /**
     * @brief[zh-cn] 返回视图 ID
     * @return[zh-cn] 视图标识符
     *
     * @brief[en] Returns the view ID
     * @return[en] View identifier
     */
    public func getViewId(): UInt16 {
        return this.viewId
    }

    /**
     * @brief[zh-cn] 返回视口 (x, y, w, h)
     * @return[zh-cn] 视口四元组
     *
     * @brief[en] Returns the viewport (x, y, w, h)
     * @return[en] Viewport tuple
     */
    public func getViewport(): (Int32, Int32, UInt32, UInt32) {
        let (x, y, w, h) = this.viewport
        return (x, y, UInt32(w), UInt32(h))
    }

    /**
     * @brief[zh-cn] 返回清除颜色（UInt32 RGBA）
     * @return[zh-cn] 清除颜色值
     *
     * @brief[en] Returns the clear color (UInt32 RGBA)
     * @return[en] Clear color value
     */
    public func getClearColor(): UInt32 {
        return this.clearColor
    }

    /**
     * @brief[zh-cn] 返回帧缓冲对象
     * @return[zh-cn] 帧缓冲，可能为空
     *
     * @brief[en] Returns the framebuffer object
     * @return[en] Framebuffer, may be None
     */
    public func getFrameBuffer(): Option<RenderTarget> {
        return this.renderTarget
    }

    /**
     * @brief[zh-cn] 返回场景
     * @return[zh-cn] 场景，可能为空
     *
     * @brief[en] Returns the scene
     * @return[en] Scene, may be None
     */
    public func getScene(): Option<Scene> {
        return this.scene
    }

    /**
     * @brief[zh-cn] 返回相机
     * @return[zh-cn] 相机，可能为空
     *
     * @brief[en] Returns the camera
     * @return[en] Camera, may be None
     */
    public func getCamera(): Option<Camera> {
        return this.camera
    }

    // ===== clone =====

    /**
     * @brief[zh-cn] 深拷贝渲染上下文
     * @return[zh-cn] 新 RenderContext 实例（浅拷贝引用字段）
     *
     * @brief[en] Deep copies the render context
     * @return[en] New RenderContext instance (shallow-copied reference fields)
     */
    public func clone(): RenderContext {
        let ctx = RenderContext()
        ctx.id = this.id
        ctx.scene = this.scene
        ctx.camera = this.camera
        ctx.viewId = this.viewId
        ctx.viewMatrix = Array<Float64>(16, { i => this.viewMatrix[i] })
        ctx.projMatrix = Array<Float64>(16, { i => this.projMatrix[i] })
        ctx.viewport = this.viewport
        ctx.scissor = this.scissor
        ctx.renderTarget = this.renderTarget
        ctx.clippingContext = this.clippingContext
        ctx.active = this.active
        ctx.occlusion = this.occlusion
        ctx.width = this.width
        ctx.height = this.height
        ctx.clearColor = this.clearColor
        ctx.clearColorBool = this.clearColorBool
        ctx.clearDepth = this.clearDepth
        ctx.clearStencil = this.clearStencil
        ctx.depthClearValue = this.depthClearValue
        ctx.stencilClearValue = this.stencilClearValue
        return ctx
    }
}
