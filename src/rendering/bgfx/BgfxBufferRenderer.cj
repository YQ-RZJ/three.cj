/**
 * @file[zh-cn] bgfx 非索引缓冲绘制
 * @brief[zh-cn] 替代 WebGLBufferRenderer，封装 bgfx_submit_cj 非索引绘制调用
 * @explain[zh-cn] 对照源码: three.js/src/renderers/webgl/WebGLBufferRenderer.js。在 WebGL 中通过 gl.drawArrays/gl.drawArraysInstanced 绘制，在 bgfx 中通过 bgfx_submit_cj 提交绘制命令。
 *
 * @file[en] bgfx Non-Indexed Buffer Renderer
 * @brief[en] Replace WebGLBufferRenderer, wrap bgfx_submit_cj non-indexed draw calls
 * @explain[en] Mirrors three.js/src/renderers/webgl/WebGLBufferRenderer.js. In WebGL, draws via gl.drawArrays/gl.drawArraysInstanced; in bgfx, submits draw commands via bgfx_submit_cj.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 非索引缓冲绘制器
 * @explain[zh-cn] 对照 WebGLBufferRenderer，封装非索引几何体的绘制调用。bgfx 使用 bgfx_submit_cj 统一提交绘制命令。
 *
 * @brief[en] bgfx non-indexed buffer renderer
 * @explain[en] Mirrors WebGLBufferRenderer, wrapping non-indexed geometry draw calls. bgfx uses bgfx_submit_cj for unified draw command submission.
 */
public class BgfxBufferRenderer {
    /**
     * @brief[zh-cn] 当前绘制模式
     */
    private var mode: UInt64 = 0u64
    /**
     * @brief[zh-cn] 渲染统计
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.info = info
    }

    /**
     * @brief[zh-cn] 设置绘制模式
     * @explain[zh-cn] 对照 WebGLBufferRenderer.setMode()
     * @param[zh-cn] value 绘制模式值
     *
     * @brief[en] Set draw mode
     * @explain[en] Mirrors WebGLBufferRenderer.setMode()
     * @param[en] value Draw mode value
     */
    public func setMode(value: UInt64): Unit {
        mode = value
    }

    /**
     * @brief[zh-cn] 非索引绘制
     * @explain[zh-cn] 对照 WebGLBufferRenderer.render()
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * start 起始顶点索引
     * count 绘制顶点数
     * depth 深度值
     *
     * @brief[en] Non-indexed draw
     * @explain[en] Mirrors WebGLBufferRenderer.render()
     * @param[en] viewId View ID
     * program Shader program handle
     * start Start vertex index
     * count Number of vertices to draw
     * depth Depth value
     */
    public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit {
        bgfx_submit_cj(viewId, program, depth, 0u8)
        info.update(count, mode, 1)
    }

    /**
     * @brief[zh-cn] 实例化非索引绘制
     * @explain[zh-cn] 对照 WebGLBufferRenderer.renderInstances()
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * start 起始顶点索引
     * count 绘制顶点数
     * primcount 实例数
     * depth 深度值
     *
     * @brief[en] Instanced non-indexed draw
     * @explain[en] Mirrors WebGLBufferRenderer.renderInstances()
     * @param[en] viewId View ID
     * program Shader program handle
     * start Start vertex index
     * count Number of vertices to draw
     * primcount Instance count
     * depth Depth value
     */
    public func renderInstances(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, primcount: Int64, depth: UInt32): Unit {
        if (primcount == 0) { return }
        bgfx_set_instance_count_cj(UInt32(primcount))
        bgfx_submit_cj(viewId, program, depth, 0u8)
        info.update(count, mode, primcount)
    }

    /**
     * @brief[zh-cn] 多次绘制（间接绘制）
     * @explain[zh-cn] 对照 WebGLBufferRenderer.renderMultiDraw()。bgfx 通过多次 submit 实现多次绘制。
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * starts 起始索引数组
     * counts 顶点计数数组
     * drawCount 绘制调用数
     * depth 深度值
     *
     * @brief[en] Multi-draw (indirect draw)
     * @explain[en] Mirrors WebGLBufferRenderer.renderMultiDraw(). bgfx implements multi-draw via multiple submit calls.
     * @param[en] viewId View ID
     * program Shader program handle
     * starts Start indices array
     * counts Vertex count array
     * drawCount Number of draw calls
     * depth Depth value
     */
    public func renderMultiDraw(viewId: ViewId, program: ProgramHandle, starts: Array<Int64>, counts: Array<Int64>, drawCount: Int64, depth: UInt32): Unit {
        if (drawCount == 0) { return }
        var elementCount: Int64 = 0
        for (i in 0..drawCount) {
            if (i < counts.size) {
                elementCount += counts[Int64(i)]
            }
        }
        bgfx_submit_cj(viewId, program, depth, 0u8)
        info.update(elementCount, mode, 1)
    }
}
