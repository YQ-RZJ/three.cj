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
 * @file[zh-cn] 渲染信息
 * @brief[zh-cn] 渲染统计信息，跟踪渲染调用、三角形和顶点数等指标
 * @explain[zh-cn] 
 * Info 及其内部类 RenderInfo、ComputeInfo、MemoryInfo 用于跟踪渲染管线的性能指标，
 * 包括 draw call 数量、三角形/顶点数、计算调用数、纹理/几何体内存占用等。
 * 对应 Three.js 中的 renderer.info 对象。
 *
 * @file[en] Render Info
 * @brief[en] Rendering statistics, tracking metrics such as render calls, triangles, and vertex counts
 * @explain[en] 
 * Info and its inner classes RenderInfo, ComputeInfo, MemoryInfo are used to track rendering pipeline performance metrics,
 * including draw call count, triangle/vertex counts, compute call counts, texture/geometry memory usage, etc.
 * Corresponds to the renderer.info object in Three.js.
 */
package three.rendering.common

/**
 * @brief[zh-cn] 渲染统计信息
 * @explain[zh-cn] 
 * 跟踪 draw call 数量、三角形/顶点数、帧号等渲染管线性能指标。
 *
 * @brief[en] Rendering statistics
 * @explain[en] 
 * Tracks rendering pipeline performance metrics such as draw call count, triangle/vertex counts, and frame number.
 */
public open class Info {
    /**
     * @brief[zh-cn] 是否每帧自动重置统计
     *
     * @brief[en] Whether to automatically reset statistics each frame
     */
    public var autoReset: Bool

    /**
     * @brief[zh-cn] 当前帧号
     *
     * @brief[en] Current frame number
     */
    public var frame: Int64

    /**
     * @brief[zh-cn] 总 draw call 数
     *
     * @brief[en] Total draw call count
     */
    public var calls: Int64

    /**
     * @brief[zh-cn] 总三角形数
     *
     * @brief[en] Total triangle count
     */
    public var triangles: Int64

    /**
     * @brief[zh-cn] 总顶点数
     *
     * @brief[en] Total vertex count
     */
    public var vertices: Int64

    /**
     * @brief[zh-cn] 渲染子统计
     *
     * @brief[en] Render sub-statistics
     */
    public var render: RenderInfo

    /**
     * @brief[zh-cn] 计算子统计
     *
     * @brief[en] Compute sub-statistics
     */
    public var compute: ComputeInfo

    /**
     * @brief[zh-cn] 内存子统计
     *
     * @brief[en] Memory sub-statistics
     */
    public var memory: MemoryInfo

    /**
     * @brief[zh-cn] 构造默认渲染信息
     *
     * @brief[en] Constructs default render info
     */
    public init() {
        this.autoReset = true; this.frame = 0; this.calls = 0; this.triangles = 0; this.vertices = 0
        this.render = RenderInfo(); this.compute = ComputeInfo(); this.memory = MemoryInfo()
    }

    /**
     * @brief[zh-cn] 重置渲染统计
     *
     * @brief[en] Resets render statistics
     */
    public func reset(): Unit { this.calls = 0; this.triangles = 0; this.vertices = 0; this.render.calls = 0; this.render.triangles = 0; this.render.vertices = 0 }

    /**
     * @brief[zh-cn] 更新当前帧号
     * @param[zh-cn] frame 帧号
     *
     * @brief[en] Updates the current frame number
     * @param[en] frame Frame number
     */
    public func update(frame: Int64): Unit { this.frame = frame }
}

/**
 * @brief[zh-cn] 渲染子统计信息
 * @explain[zh-cn] 
 * 跟踪渲染 pass 的 draw call、三角形和顶点数。
 *
 * @brief[en] Render sub-statistics
 * @explain[en] 
 * Tracks draw calls, triangle count, and vertex count for the render pass.
 */
public open class RenderInfo {
    /**
     * @brief[zh-cn] 渲染 draw call 数
     *
     * @brief[en] Render draw call count
     */
    public var calls: Int64

    /**
     * @brief[zh-cn] 渲染三角形数
     *
     * @brief[en] Render triangle count
     */
    public var triangles: Int64

    /**
     * @brief[zh-cn] 渲染顶点数
     *
     * @brief[en] Render vertex count
     */
    public var vertices: Int64

    /**
     * @brief[zh-cn] 构造默认渲染子统计
     *
     * @brief[en] Constructs default render sub-statistics
     */
    public init() { this.calls = 0; this.triangles = 0; this.vertices = 0 }
}

/**
 * @brief[zh-cn] 计算子统计信息
 * @explain[zh-cn] 
 * 跟踪 compute pass 的调用数。
 *
 * @brief[en] Compute sub-statistics
 * @explain[en] 
 * Tracks compute pass call counts.
 */
public open class ComputeInfo {
    /**
     * @brief[zh-cn] 总调用数
     *
     * @brief[en] Total call count
     */
    public var calls: Int64

    /**
     * @brief[zh-cn] 计算调用数
     *
     * @brief[en] Compute call count
     */
    public var computeCalls: Int64

    /**
     * @brief[zh-cn] 构造默认计算子统计
     *
     * @brief[en] Constructs default compute sub-statistics
     */
    public init() { this.calls = 0; this.computeCalls = 0 }
}

/**
 * @brief[zh-cn] 内存子统计信息
 * @explain[zh-cn] 
 * 跟踪纹理和几何体的内存占用数量。
 *
 * @brief[en] Memory sub-statistics
 * @explain[en] 
 * Tracks memory usage counts for textures and geometries.
 */
public open class MemoryInfo {
    /**
     * @brief[zh-cn] 纹理数量
     *
     * @brief[en] Texture count
     */
    public var textures: Int64

    /**
     * @brief[zh-cn] 几何体数量
     *
     * @brief[en] Geometry count
     */
    public var geometries: Int64

    /**
     * @brief[zh-cn] 构造默认内存子统计
     *
     * @brief[en] Constructs default memory sub-statistics
     */
    public init() { this.textures = 0; this.geometries = 0 }
}
