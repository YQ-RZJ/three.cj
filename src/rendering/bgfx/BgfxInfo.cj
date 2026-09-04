/**
 * @file[zh-cn] bgfx 渲染统计信息
 * @brief[zh-cn] 替代 WebGLInfo，跟踪渲染统计信息
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLInfo.js。在 WebGL 中通过 gl.getParameter() 和手动计数跟踪渲染统计，在 bgfx 中通过手动计数跟踪。
 *
 * @file[en] bgfx Rendering Statistics
 * @brief[en] Replaces WebGLInfo, tracks rendering statistics
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLInfo.js. In WebGL, rendering statistics are tracked via gl.getParameter() and manual counting; in bgfx, they are tracked via manual counting.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] 内存统计信息
 * @explain[zh-cn] 跟踪 GPU 资源的数量统计，包括几何体、纹理、着色器和着色器程序
 *
 * @brief[en] Memory statistics
 * @explain[en] Tracks GPU resource count statistics, including geometries, textures, shaders, and shader programs
 */
public class BgfxMemoryInfo {
    /**
     * @brief[zh-cn] 几何体数量
     *
     * @brief[en] Geometry count
     */
    public var geometries: Int64
    /**
     * @brief[zh-cn] 纹理数量
     *
     * @brief[en] Texture count
     */
    public var textures: Int64
    /**
     * @brief[zh-cn] 着色器数量
     *
     * @brief[en] Shader count
     */
    public var shaders: Int64
    /**
     * @brief[zh-cn] 着色器程序数量
     *
     * @brief[en] Shader program count
     */
    public var programs: Int64

    public init() {
        this.geometries = 0
        this.textures = 0
        this.shaders = 0
        this.programs = 0
    }
}

/**
 * @brief[zh-cn] 渲染统计信息
 * @explain[zh-cn] 跟踪每帧的渲染调用统计，包括绘制调用次数和图元数量
 *
 * @brief[en] Render statistics
 * @explain[en] Tracks per-frame render call statistics, including draw call count and primitive count
 */
public class BgfxRenderInfo {
    /**
     * @brief[zh-cn] 帧编号
     *
     * @brief[en] Frame number
     */
    public var frame: Int64
    /**
     * @brief[zh-cn] 绘制调用次数
     *
     * @brief[en] Draw call count
     */
    public var calls: Int64
    /**
     * @brief[zh-cn] 三角形数量
     *
     * @brief[en] Triangle count
     */
    public var triangles: Int64
    /**
     * @brief[zh-cn] 点数量
     *
     * @brief[en] Point count
     */
    public var points: Int64
    /**
     * @brief[zh-cn] 线段数量
     *
     * @brief[en] Line count
     */
    public var lines: Int64

    public init() {
        this.frame = 0
        this.calls = 0
        this.triangles = 0
        this.points = 0
        this.lines = 0
    }
}

/**
 * @brief[zh-cn] bgfx 渲染统计
 * @explain[zh-cn] 对照 WebGLInfo，跟踪内存使用和渲染调用统计。bgfx 内部有自己的统计系统，此类提供 three.js 兼容的统计接口。
 *
 * @brief[en] bgfx rendering statistics
 * @explain[en] Corresponds to WebGLInfo, tracks memory usage and render call statistics. bgfx has its own statistics system; this class provides a three.js-compatible statistics interface.
 */
public class BgfxInfo {
    /**
     * @brief[zh-cn] 内存统计
     *
     * @brief[en] Memory statistics
     */
    public var memory: BgfxMemoryInfo
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    public var render: BgfxRenderInfo
    /**
     * @brief[zh-cn] 着色器程序列表
     *
     * @brief[en] Shader program list
     */
    public var programs: Option<ArrayList<String>>
    /**
     * @brief[zh-cn] 是否自动重置统计（每帧开始时重置）
     *
     * @brief[en] Whether to auto-reset statistics at frame start
     */
    public var autoReset: Bool

    public init() {
        this.memory = BgfxMemoryInfo()
        this.render = BgfxRenderInfo()
        this.programs = None
        this.autoReset = true
    }

    /**
     * @brief[zh-cn] 更新渲染统计
     * @explain[zh-cn] 对照 WebGLInfo.update()，根据绘制模式更新三角形、线段、点的数量统计
     * @param[zh-cn] count 顶点/索引数量
     * mode 绘制模式（三角形、线段、点等）
     * instanceCount 实例数量
     *
     * @brief[en] Updates render statistics
     * @explain[en] Corresponds to WebGLInfo.update(), updates triangle/line/point count statistics based on draw mode
     * @param[en] count Vertex/index count
     * mode Draw mode (triangles, lines, points, etc.)
     * instanceCount Instance count
     */
    public func update(count: Int64, mode: UInt64, instanceCount: Int64): Unit {
        this.render.calls += 1

        // 根据绘制模式更新统计
        if (mode == 0u64) {
            // 三角形列表
            this.render.triangles += instanceCount * (count / 3)
        } else if (mode == STATE_PT_LINES) {
            // 线段列表
            this.render.lines += instanceCount * (count / 2)
        } else if (mode == STATE_PT_LINESTRIP) {
            // 线段条带
            this.render.lines += instanceCount * (count - 1)
        } else if (mode == STATE_PT_POINTS) {
            // 点列表
            this.render.points += instanceCount * count
        } else if (mode == STATE_PT_TRISTRIP) {
            // 三角形条带
            this.render.triangles += instanceCount * (count - 2)
        }
    }

    /**
     * @brief[zh-cn] 重置渲染统计
     * @explain[zh-cn] 对照 WebGLInfo.reset()
     *
     * @brief[en] Resets render statistics
     * @explain[en] Corresponds to WebGLInfo.reset()
     */
    public func reset(): Unit {
        this.render.calls = 0
        this.render.triangles = 0
        this.render.points = 0
        this.render.lines = 0
    }

    /**
     * @brief[zh-cn] 帧开始时调用
     * @explain[zh-cn] 如果 autoReset 为 true，则重置统计
     *
     * @brief[en] Called at frame start
     * @explain[en] Resets statistics if autoReset is true
     */
    public func beginFrame(): Unit {
        if (this.autoReset) {
            this.reset()
        }
        this.render.frame += 1
    }
}
