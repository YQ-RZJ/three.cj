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
 * @file[zh-cn] ThreeRenderTarget 基于 bgfx 帧缓冲的渲染目标定义
 * @brief[zh-cn] 基于 bgfx 帧缓冲的渲染目标类，对应 Three.js WebGLRenderTarget
 * @explain[zh-cn] 提供标准 2D、3D、数组和立方体渲染目标实现，内部使用 bgfx 帧缓冲句柄。
 * ThreeRenderTarget 实现 IRenderTarget 接口，供 cameras/CubeCamera 以接口持有，避免循环依赖。
 * FrameBufferHandle 等句柄别名在 ThreeRenderer.cj（同 package）定义，此处直接使用。
 *
 * @file[en] ThreeRenderTarget bgfx framebuffer-based render target definitions
 * @brief[en] bgfx framebuffer-based render target classes, corresponding to Three.js WebGLRenderTarget
 * @explain[en] Provides standard 2D, 3D, array, and cube render target implementations using bgfx framebuffer handles.
 * ThreeRenderTarget implements IRenderTarget interface, used by cameras/CubeCamera to avoid circular dependency.
 * FrameBufferHandle aliases are defined in ThreeRenderer.cj (same package) and used here directly.
 *
 * @package three.rendering
 */
package three.rendering

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.textures.*
import three.rendering.types.*
import three.rendering.interfaces.IRenderTarget
import bgfx4cj.bgfx as bgfx
import three.core.thread.bgfxCallMtx

/**
 * @brief[zh-cn] 基于 bgfx 帧缓冲的标准 2D 渲染目标
 * @explain[zh-cn] 实现 IRenderTarget 接口，供 cameras/CubeCamera 以接口持有，避免 renderers↔cameras 循环依赖。
 * 内部使用 bgfx 帧缓冲句柄，构造时自动创建帧缓冲。
 *
 * @brief[en] Standard 2D render target based on bgfx framebuffer
 * @explain[en] Implements IRenderTarget interface, used by cameras/CubeCamera to avoid renderers↔cameras circular dependency.
 * Uses bgfx framebuffer handle internally; framebuffer is created automatically on construction.
 */
public class ThreeRenderTarget <: IRenderTarget {
    /**
     * @brief[zh-cn] 渲染目标宽度（像素）
     *
     * @brief[en] Render target width in pixels
     */
    public var width: Int64
    /**
     * @brief[zh-cn] 渲染目标高度（像素）
     *
     * @brief[en] Render target height in pixels
     */
    public var height: Int64
    /**
     * @brief[zh-cn] 渲染目标深度（层数，3D 目标用）
     *
     * @brief[en] Render target depth (layers, for 3D targets)
     */
    public var depth: Int64
    /**
     * @brief[zh-cn] 渲染目标类型标识
     *
     * @brief[en] Render target type identifier
     */
    public var kind: String
    /**
     * @brief[zh-cn] 关联的颜色纹理
     *
     * @brief[en] Associated color texture
     */
    public var texture: Texture
    /**
     * @brief[zh-cn] bgfx 帧缓冲句柄
     *
     * @brief[en] bgfx framebuffer handle
     */
    public var frameBuffer: FrameBufferHandle
    /**
     * @brief[zh-cn] 构造指定尺寸的 2D 渲染目标
     * @param[zh-cn] width 宽度（像素）
     * height 高度（像素）
     *
     * @brief[en] Constructs a 2D render target with the specified dimensions
     * @param[en] width Width in pixels
     * height Height in pixels
     */
    public init(width: Int64, height: Int64) {
        this.width = width; this.height = height; this.depth = 0
        this.kind = "ThreeRenderTarget"; this.texture = Texture()
        bgfxCallMtx.lock()
        try {
            this.frameBuffer = Box(bgfx.bgfx_create_frame_buffer_cj(UInt16(width), UInt16(height), 0x00000000u32, 0u64))
        } finally {
            bgfxCallMtx.unlock()
        }
    }
    /**
     * @brief[zh-cn] 重新设置渲染目标尺寸
     * @param[zh-cn] width 新宽度（像素）
     * height 新高度（像素）
     *
     * @brief[en] Resizes the render target
     * @param[en] width New width in pixels
     * height New height in pixels
     */
    public func setSize(width: Int64, height: Int64): Unit { this.width = width; this.height = height }
    /**
     * @brief[zh-cn] 销毁帧缓冲，释放 GPU 资源
     *
     * @brief[en] Destroys the framebuffer and releases GPU resources
     */
    public func dispose(): Unit {
        if (isValidHandle(this.frameBuffer)) {
            bgfxCallMtx.lock()
            try {
                bgfx.bgfx_destroy_frame_buffer_cj(this.frameBuffer.value)
            } finally {
                bgfxCallMtx.unlock()
            }
        }
    }
}

/**
 * @brief[zh-cn] 基于 bgfx 帧缓冲的 3D 渲染目标
 * @explain[zh-cn] 用于体积渲染等需要 3D 纹理作为渲染目标的场景。
 *
 * @brief[en] 3D render target based on bgfx framebuffer
 * @explain[en] Used for volume rendering and other scenarios requiring 3D textures as render targets.
 */
public class ThreeRenderTarget3D {
    /**
     * @brief[zh-cn] 渲染目标宽度（像素）
     *
     * @brief[en] Render target width in pixels
     */
    public var width: Int64
    /**
     * @brief[zh-cn] 渲染目标高度（像素）
     *
     * @brief[en] Render target height in pixels
     */
    public var height: Int64
    /**
     * @brief[zh-cn] 渲染目标深度（层数）
     *
     * @brief[en] Render target depth (layers)
     */
    public var depth: Int64
    /**
     * @brief[zh-cn] 渲染目标类型标识
     *
     * @brief[en] Render target type identifier
     */
    public var kind: String
    /**
     * @brief[zh-cn] bgfx 帧缓冲句柄
     *
     * @brief[en] bgfx framebuffer handle
     */
    public var frameBuffer: FrameBufferHandle
    /**
     * @brief[zh-cn] 构造指定尺寸的 3D 渲染目标
     * @param[zh-cn] width 宽度（像素）
     * height 高度（像素）
     * depth 深度（层数）
     *
     * @brief[en] Constructs a 3D render target with the specified dimensions
     * @param[en] width Width in pixels
     * height Height in pixels
     * depth Depth in layers
     */
    public init(width: Int64, height: Int64, depth: Int64) {
        this.width = width; this.height = height; this.depth = depth; this.kind = "ThreeRenderTarget3D"
        bgfxCallMtx.lock()
        try {
            this.frameBuffer = Box(bgfx.bgfx_create_frame_buffer_cj(UInt16(width), UInt16(height), 0x00000000u32, 0u64))
        } finally {
            bgfxCallMtx.unlock()
        }
    }
}

/**
 * @brief[zh-cn] 基于 bgfx 帧缓冲的数组渲染目标
 * @explain[zh-cn] 用于多视图（ArrayCamera）渲染，包含多层纹理的帧缓冲。
 *
 * @brief[en] Array render target based on bgfx framebuffer
 * @explain[en] Used for multi-view (ArrayCamera) rendering, containing a framebuffer with layered textures.
 */
public class ThreeArrayRenderTarget {
    /**
     * @brief[zh-cn] 渲染目标宽度（像素）
     *
     * @brief[en] Render target width in pixels
     */
    public var width: Int64
    /**
     * @brief[zh-cn] 渲染目标高度（像素）
     *
     * @brief[en] Render target height in pixels
     */
    public var height: Int64
    /**
     * @brief[zh-cn] 渲染目标深度（图层数）
     *
     * @brief[en] Render target depth (number of layers)
     */
    public var depth: Int64
    /**
     * @brief[zh-cn] 渲染目标类型标识
     *
     * @brief[en] Render target type identifier
     */
    public var kind: String
    /**
     * @brief[zh-cn] bgfx 帧缓冲句柄
     *
     * @brief[en] bgfx framebuffer handle
     */
    public var frameBuffer: FrameBufferHandle
    /**
     * @brief[zh-cn] 构造指定尺寸的数组渲染目标
     * @param[zh-cn] width 宽度（像素）
     * height 高度（像素）
     * depth 图层数
     *
     * @brief[en] Constructs an array render target with the specified dimensions
     * @param[en] width Width in pixels
     * height Height in pixels
     * depth Number of layers
     */
    public init(width: Int64, height: Int64, depth: Int64) {
        this.width = width; this.height = height; this.depth = depth; this.kind = "ThreeArrayRenderTarget"
        this.frameBuffer = Box(bgfx.bgfx_create_frame_buffer_cj(UInt16(width), UInt16(height), 0x00000000u32, 0u64))
    }
}

/**
 * @brief[zh-cn] 基于 bgfx 帧缓冲的立方体渲染目标
 * @explain[zh-cn] 用于环境贴图、CubeMap 反射等 6 面立方体贴图渲染场景。
 *
 * @brief[en] Cube render target based on bgfx framebuffer
 * @explain[en] Used for environment mapping, CubeMap reflections, and other 6-face cube map rendering scenarios.
 */
public class ThreeCubeRenderTarget {
    /**
     * @brief[zh-cn] 渲染目标宽度（像素）
     *
     * @brief[en] Render target width in pixels
     */
    public var width: Int64
    /**
     * @brief[zh-cn] 渲染目标高度（像素）
     *
     * @brief[en] Render target height in pixels
     */
    public var height: Int64
    /**
     * @brief[zh-cn] 渲染目标类型标识
     *
     * @brief[en] Render target type identifier
     */
    public var kind: String
    /**
     * @brief[zh-cn] bgfx 帧缓冲句柄
     *
     * @brief[en] bgfx framebuffer handle
     */
    public var frameBuffer: FrameBufferHandle
    /**
     * @brief[zh-cn] 构造指定尺寸的立方体渲染目标
     * @param[zh-cn] width 宽度（像素，每面边长）
     * height 高度（像素，每面边长）
     *
     * @brief[en] Constructs a cube render target with the specified dimensions
     * @param[en] width Width in pixels (face side length)
     * height Height in pixels (face side length)
     */
    public init(width: Int64, height: Int64) {
        this.width = width; this.height = height; this.kind = "ThreeCubeRenderTarget"
        bgfxCallMtx.lock()
        try {
            this.frameBuffer = Box(bgfx.bgfx_create_frame_buffer_cj(UInt16(width), UInt16(height), 0x00000000u32, 0u64))
        } finally {
            bgfxCallMtx.unlock()
        }
    }
}
