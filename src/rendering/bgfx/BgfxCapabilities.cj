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
 * @file[zh-cn] bgfx 渲染能力检测
 * @brief[zh-cn] 替代 WebGLCapabilities，通过 bgfx API 查询渲染能力
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLCapabilities.js。在 WebGL 中通过 gl.getParameter() 查询 GPU 能力，在 bgfx 中通过 bgfx_get_caps_cj() 获取能力信息，此类封装为 three.js 兼容接口。
 *
 * @file[en] bgfx Rendering Capabilities
 * @brief[en] Replaces WebGLCapabilities, queries rendering capabilities via bgfx API
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLCapabilities.js. In WebGL, GPU capabilities are queried via gl.getParameter(); in bgfx, capabilities are obtained via bgfx_get_caps_cj(). This class wraps them into a three.js-compatible interface.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*
import std.collection.*

/**
 * @brief[zh-cn] bgfx 渲染能力
 * @explain[zh-cn] 对照 WebGLCapabilities，提供 GPU 能力查询。bgfx 通过 Caps 结构体提供能力信息，此类封装为 three.js 兼容接口。
 *
 * @brief[en] bgfx rendering capabilities
 * @explain[en] Corresponds to WebGLCapabilities, provides GPU capability queries. bgfx provides capability info through Caps struct, this class wraps it into a three.js-compatible interface.
 */
public class BgfxCapabilities {
    /**
     * @brief[zh-cn] 最大各向异性过滤级别
     *
     * @brief[en] Maximum anisotropy filtering level
     */
    public var maxAnisotropy: Int64
    /**
     * @brief[zh-cn] 着色器精度（bgfx 始终支持高精度）
     *
     * @brief[en] Shader precision (bgfx always supports highp)
     */
    public var precision: String
    /**
     * @brief[zh-cn] 是否支持对数深度缓冲
     *
     * @brief[en] Whether logarithmic depth buffer is supported
     */
    public var logarithmicDepthBuffer: Bool
    /**
     * @brief[zh-cn] 是否支持反向深度缓冲
     *
     * @brief[en] Whether reversed depth buffer is supported
     */
    public var reversedDepthBuffer: Bool
    /**
     * @brief[zh-cn] 最大纹理单元数
     *
     * @brief[en] Maximum texture units
     */
    public var maxTextures: Int64
    /**
     * @brief[zh-cn] 最大顶点纹理单元数
     *
     * @brief[en] Maximum vertex texture units
     */
    public var maxVertexTextures: Int64
    /**
     * @brief[zh-cn] 最大纹理尺寸
     *
     * @brief[en] Maximum texture size
     */
    public var maxTextureSize: Int64
    /**
     * @brief[zh-cn] 最大立方体贴图尺寸
     *
     * @brief[en] Maximum cubemap size
     */
    public var maxCubemapSize: Int64
    /**
     * @brief[zh-cn] 最大顶点属性数
     *
     * @brief[en] Maximum vertex attributes
     */
    public var maxAttributes: Int64
    /**
     * @brief[zh-cn] 最大顶点 Uniform 向量数
     *
     * @brief[en] Maximum vertex uniform vectors
     */
    public var maxVertexUniforms: Int64
    /**
     * @brief[zh-cn] 最大 Varying 向量数
     *
     * @brief[en] Maximum varying vectors
     */
    public var maxVaryings: Int64
    /**
     * @brief[zh-cn] 最大片段 Uniform 向量数
     *
     * @brief[en] Maximum fragment uniform vectors
     */
    public var maxFragmentUniforms: Int64
    /**
     * @brief[zh-cn] 最大 MSAA 采样数
     *
     * @brief[en] Maximum MSAA sample count
     */
    public var maxSamples: Int64

    /**
     * @brief[zh-cn] 扩展兼容层
     *
     * @brief[en] Extension compatibility layer
     */
    private var extensions: BgfxExtensions
    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether initialized
     */
    private var initialized: Bool

    /**
     * @brief[zh-cn] 构造渲染能力实例
     * @param[zh-cn] extensions 扩展兼容层实例
     * precision 着色器精度（默认 highp）
     * logarithmicDepthBuffer 是否支持对数深度缓冲
     * reversedDepthBuffer 是否支持反向深度缓冲
     *
     * @brief[en] Constructs a rendering capabilities instance
     * @param[en] extensions Extension compatibility layer instance
     * precision Shader precision (default highp)
     * logarithmicDepthBuffer Whether logarithmic depth buffer is supported
     * reversedDepthBuffer Whether reversed depth buffer is supported
     */
    public init(extensions!: BgfxExtensions = BgfxExtensions(), precision!: String = "highp", logarithmicDepthBuffer!: Bool = false, reversedDepthBuffer!: Bool = false) {
        this.extensions = extensions
        this.maxAnisotropy = 16
        this.precision = precision
        this.logarithmicDepthBuffer = logarithmicDepthBuffer
        this.reversedDepthBuffer = reversedDepthBuffer
        this.maxTextures = 16
        this.maxVertexTextures = 4
        this.maxTextureSize = 4096
        this.maxCubemapSize = 4096
        this.maxAttributes = 16
        this.maxVertexUniforms = 256
        this.maxVaryings = 8
        this.maxFragmentUniforms = 256
        this.maxSamples = 4
        this.initialized = false
    }

    /**
     * @brief[zh-cn] 从 bgfx Caps 初始化能力信息
     * @explain[zh-cn] 在 bgfx 初始化后调用，通过 bgfx_get_caps_cj 获取实际能力
     *
     * @brief[en] Initializes capability info from bgfx Caps
     * @explain[en] Called after bgfx initialization, obtains actual capabilities via bgfx_get_caps_cj
     */
    public func initialize(): Unit {
        if (this.initialized) { return }
        this.initialized = true

        // 通过 bgfx API 查询能力
        let capsPtr = bgfx_get_caps_cj()
        if (!capsPtr.isNull()) {
            unsafe {
                let caps = capsPtr.read()
                // Caps 结构体中 limits 子结构体包含能力限制信息
                this.maxTextureSize = Int64(caps.limits.maxTextureSize)
                this.maxCubemapSize = Int64(caps.limits.maxTextureSize)
                this.maxTextures = Int64(caps.limits.maxTextureSamplers)
                this.maxVertexTextures = Int64(caps.limits.maxTextureSamplers / 4)
                this.maxVertexUniforms = Int64(caps.limits.maxUniforms)
                this.maxFragmentUniforms = Int64(caps.limits.maxUniforms)
            }
        }

        // 各向异性过滤
        if (this.extensions.has("EXT_texture_filter_anisotropic")) {
            this.maxAnisotropy = 16
        } else {
            this.maxAnisotropy = 1
        }
    }

    /**
     * @brief[zh-cn] 获取最大各向异性过滤级别
     * @return[zh-cn] 最大各向异性过滤级别
     *
     * @brief[en] Gets maximum anisotropy filtering level
     * @return[en] Maximum anisotropy filtering level
     */
    public func getMaxAnisotropy(): Int64 {
        return this.maxAnisotropy
    }

    /**
     * @brief[zh-cn] 获取最大着色器精度
     * @explain[zh-cn] bgfx 始终支持高精度
     * @param[zh-cn] precision 请求的精度级别
     * @return[zh-cn] 实际支持的精度级别
     *
     * @brief[en] Gets maximum shader precision
     * @explain[en] bgfx always supports highp
     * @param[en] precision Requested precision level
     * @return[en] Actually supported precision level
     */
    public static func getMaxPrecision(precision!: String): String {
        if (precision == "highp") { return "highp" }
        if (precision == "mediump") { return "mediump" }
        return "lowp"
    }

    /**
     * @brief[zh-cn] 检查纹理格式是否可读
     * @param[zh-cn] textureFormat 纹理格式
     * @return[zh-cn] 是否可读
     *
     * @brief[en] Checks if a texture format is readable
     * @param[en] textureFormat Texture format
     * @return[en] Whether readable
     */
    public func textureFormatReadable(textureFormat: Int64): Bool {
        // bgfx 支持大多数格式的回读
        return true
    }

    /**
     * @brief[zh-cn] 检查纹理类型是否可读
     * @param[zh-cn] textureType 纹理类型
     * @return[zh-cn] 是否可读
     *
     * @brief[en] Checks if a texture type is readable
     * @param[en] textureType Texture type
     * @return[en] Whether readable
     */
    public func textureTypeReadable(textureType: Int64): Bool {
        // bgfx 支持 Float 和 HalfFloat 回读
        return true
    }
}
