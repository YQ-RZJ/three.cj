/**
 * @file[zh-cn] bgfx 索引缓冲绘制
 * @brief[zh-cn] 替代 WebGLIndexedBufferRenderer，封装 bgfx 索引绘制调用
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLIndexedBufferRenderer.js。在 WebGL 中通过 gl.drawElements/gl.drawElementsInstanced 绘制索引几何体，在 bgfx 中通过 bgfx_submit_cj 配合 IndexBufferHandle 执行索引绘制。
 *
 * @file[en] bgfx Indexed Buffer Rendering
 * @brief[en] Replaces WebGLIndexedBufferRenderer, wraps bgfx indexed draw calls
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLIndexedBufferRenderer.js. In WebGL, indexed geometry is drawn via gl.drawElements/gl.drawElementsInstanced; in bgfx, indexed drawing is performed via bgfx_submit_cj with IndexBufferHandle.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 索引缓冲绘制器
 * @explain[zh-cn] 对照 WebGLIndexedBufferRenderer，封装索引几何体的绘制调用。bgfx 在设置索引缓冲后通过 bgfx_submit_cj 提交绘制命令。
 *
 * @brief[en] bgfx indexed buffer renderer
 * @explain[en] Corresponds to WebGLIndexedBufferRenderer, wraps indexed geometry draw calls. bgfx submits draw commands via bgfx_submit_cj after setting the index buffer.
 */
public class BgfxIndexedBufferRenderer {
    /**
     * @brief[zh-cn] 当前绘制模式
     *
     * @brief[en] Current draw mode
     */
    private var mode: UInt64 = 0u64
    /**
     * @brief[zh-cn] 索引类型（16位或32位）
     *
     * @brief[en] Index type (16-bit or 32-bit)
     */
    private var indexType: UInt32 = 0u32
    /**
     * @brief[zh-cn] 每个索引的字节数
     *
     * @brief[en] Bytes per index
     */
    private var bytesPerElement: Int64 = 2
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.info = info
    }

    /**
     * @brief[zh-cn] 设置绘制模式
     * @explain[zh-cn] 对照 WebGLIndexedBufferRenderer.setMode()
     * @param[zh-cn] value 绘制模式值
     *
     * @brief[en] Sets draw mode
     * @explain[en] Corresponds to WebGLIndexedBufferRenderer.setMode()
     * @param[en] value Draw mode value
     */
    public func setMode(value: UInt64): Unit {
        mode = value
    }

    /**
     * @brief[zh-cn] 设置索引类型
     * @explain[zh-cn] 对照 WebGLIndexedBufferRenderer.setIndex()
     * @param[zh-cn] indexType 索引类型（0 = UInt16, 1 = UInt32）
     * bytesPerElement 每个索引的字节数
     *
     * @brief[en] Sets index type
     * @explain[en] Corresponds to WebGLIndexedBufferRenderer.setIndex()
     * @param[en] indexType Index type (0 = UInt16, 1 = UInt32)
     * bytesPerElement Bytes per index element
     */
    public func setIndex(indexType: UInt32, bytesPerElement: Int64): Unit {
        this.indexType = indexType
        this.bytesPerElement = bytesPerElement
    }

    /**
     * 索引绘制
     * 对照 WebGLIndexedBufferRenderer.render()
     */
    public func render(viewId: ViewId, program: ProgramHandle, start: Int64, count: Int64, depth: UInt32): Unit {
        bgfx_submit_cj(viewId, program, depth, 0u8)
        info.update(count, mode, 1)
    }

    /**
     * @brief[zh-cn] 实例化索引绘制
     * @explain[zh-cn] 对照 WebGLIndexedBufferRenderer.renderInstances()
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * start 起始索引
     * count 索引数量
     * primcount 实例数量
     * depth 深度值
     *
     * @brief[en] Instanced indexed draw call
     * @explain[en] Corresponds to WebGLIndexedBufferRenderer.renderInstances()
     * @param[en] viewId View ID
     * program Shader program handle
     * start Start index
     * count Index count
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
     * @brief[zh-cn] 多次索引绘制
     * @explain[zh-cn] 对照 WebGLIndexedBufferRenderer.renderMultiDraw()
     * @param[zh-cn] viewId 视图 ID
     * program 着色器程序句柄
     * starts 起始索引数组
     * counts 索引数量数组
     * drawCount 绘制次数
     * depth 深度值
     *
     * @brief[en] Multi-draw indexed rendering
     * @explain[en] Corresponds to WebGLIndexedBufferRenderer.renderMultiDraw()
     * @param[en] viewId View ID
     * program Shader program handle
     * starts Start indices array
     * counts Index counts array
     * drawCount Draw count
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
