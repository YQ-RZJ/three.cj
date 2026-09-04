/**
 * @file[zh-cn] bgfx 后端缓冲绘制
 * @brief[zh-cn] 对照 webgl-fallback/WebGLBufferRenderer.js，后端层缓冲绘制
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLBufferRenderer.js。后端层封装，委托给 bgfx/ 模块的 BgfxBufferRenderer。
 *
 * @file[en] bgfx Backend Buffer Renderer
 * @brief[en] Backend buffer draw call wrapper, mirroring webgl-fallback/WebGLBufferRenderer.js
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLBufferRenderer.js. Backend layer wrapper that delegates to BgfxBufferRenderer.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 后端缓冲绘制器
 * @explain[zh-cn] 后端层封装，委托给 BgfxBufferRenderer。
 *
 * @brief[en] bgfx backend buffer renderer
 * @explain[en] Backend layer wrapper that delegates to BgfxBufferRenderer.
 */
public class BgfxBackendBufferRenderer {
    /**
     * @brief[zh-cn] 底层缓冲绘制器
     */
    private var renderer: BgfxBufferRenderer

    public init(renderer!: BgfxBufferRenderer = BgfxBufferRenderer()) {
        this.renderer = renderer
    }

    /**
     * @brief[zh-cn] 设置绘制模式
     * @param[zh-cn] value 绘制模式值
     *
     * @brief[en] Set draw mode
     * @param[en] value Draw mode value
     */
    public func setMode(value: UInt64): Unit {
        renderer.setMode(value)
    }

    /**
     * @brief[zh-cn] 非索引绘制
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * start 起始顶点索引
     * count 绘制顶点数
     * depth 深度值
     *
     * @brief[en] Non-indexed draw
     * @param[en] viewId View ID
     * program Shader program handle
     * start Start vertex index
     * count Number of vertices to draw
     * depth Depth value
     */
    public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit {
        renderer.render(viewId, program, start, count, depth)
    }

    /**
     * @brief[zh-cn] 实例化非索引绘制
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * start 起始顶点索引
     * count 绘制顶点数
     * primcount 实例数
     * depth 深度值
     *
     * @brief[en] Instanced non-indexed draw
     * @param[en] viewId View ID
     * program Shader program handle
     * start Start vertex index
     * count Number of vertices to draw
     * primcount Instance count
     * depth Depth value
     */
    public func renderInstances(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, primcount: Int64, depth: UInt32): Unit {
        renderer.renderInstances(viewId, program, start, count, primcount, depth)
    }
}
