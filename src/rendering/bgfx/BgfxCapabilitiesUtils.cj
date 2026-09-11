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
 * @file[zh-cn] bgfx 能力查询工具
 * @brief[zh-cn] 对照 WebGLCapabilities.js，通过 bgfx_get_caps_cj 查询渲染能力
 * @explain[zh-cn] 提供独立的静态查询方法，直接从 bgfx Caps 结构体读取能力值，无需实例化 BgfxCapabilities。
 *
 * @file[en] bgfx Capabilities Query Utilities
 * @brief[en] Corresponds to WebGLCapabilities.js, queries rendering capabilities via bgfx_get_caps_cj
 * @explain[en] Provides standalone static query methods that read capability values directly from bgfx Caps struct, without needing a BgfxCapabilities instance.
 */
package three.rendering.bgfx

import bgfx4cj.bgfx.*

/**
 * @brief[zh-cn] bgfx 能力查询工具
 * @explain[zh-cn] 对照 WebGLCapabilities，通过 bgfx_get_caps_cj 查询渲染能力。
 *
 * @brief[en] bgfx capabilities query utilities
 * @explain[en] Corresponds to WebGLCapabilities, queries rendering capabilities via bgfx_get_caps_cj.
 */
public class BgfxCapabilitiesUtils {
    public init() {}

    /**
     * @brief[zh-cn] 获取最大纹理尺寸
     * @return[zh-cn] 最大纹理尺寸
     *
     * @brief[en] Gets maximum texture size
     * @return[en] Maximum texture size
     */
    public func getMaxTextureSize(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxTextureSize)
    }

    /**
     * @brief[zh-cn] 获取最大纹理层数
     * @return[zh-cn] 最大纹理层数
     *
     * @brief[en] Gets maximum texture layers
     * @return[en] Maximum texture layers
     */
    public func getMaxTextureLayers(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxTextureLayers)
    }

    /**
     * @brief[zh-cn] 获取最大 3D 纹理尺寸
     * @return[zh-cn] 最大 3D 纹理尺寸
     *
     * @brief[en] Gets maximum 3D texture size
     * @return[en] Maximum 3D texture size
     */
    public func getMax3DTextureSize(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxTextureSize)
    }

    /**
     * @brief[zh-cn] 获取最大各向异性
     * @return[zh-cn] 最大各向异性级别
     *
     * @brief[en] Gets maximum anisotropy
     * @return[en] Maximum anisotropy level
     */
    public func getMaxAnisotropy(): Int64 {
        return 16
    }

    /**
     * @brief[zh-cn] 获取最大顶点属性数
     * @return[zh-cn] 最大顶点属性数
     *
     * @brief[en] Gets maximum vertex attributes
     * @return[en] Maximum vertex attributes
     */
    public func getMaxVertexAttributes(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxVertexStreams)
    }

    /**
     * @brief[zh-cn] 获取最大顶点 Uniform 向量数
     * @return[zh-cn] 最大顶点 Uniform 向量数
     *
     * @brief[en] Gets maximum vertex uniform vectors
     * @return[en] Maximum vertex uniform vectors
     */
    public func getMaxVertexUniformVectors(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxUniforms) / 4
    }

    /**
     * @brief[zh-cn] 获取最大片段 Uniform 向量数
     * @return[zh-cn] 最大片段 Uniform 向量数
     *
     * @brief[en] Gets maximum fragment uniform vectors
     * @return[en] Maximum fragment uniform vectors
     */
    public func getMaxFragmentUniformVectors(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxUniforms) / 4
    }

    /**
     * @brief[zh-cn] 获取最大纹理采样器数
     * @return[zh-cn] 最大纹理采样器数
     *
     * @brief[en] Gets maximum texture image units
     * @return[en] Maximum texture image units
     */
    public func getMaxTextureImageUnits(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxTextureSamplers)
    }

    /**
     * @brief[zh-cn] 获取最大渲染目标数
     * @return[zh-cn] 最大渲染目标数
     *
     * @brief[en] Gets maximum color attachments
     * @return[en] Maximum color attachments
     */
    public func getMaxColorAttachments(): Int64 {
        let capsPtr = bgfx_get_caps_cj()
        let caps = unsafe { capsPtr.read() }
        return Int64(caps.limits.maxFBAttachments)
    }

    /**
     * @brief[zh-cn] 获取精度
     * @return[zh-cn] 精度字符串（始终为 highp）
     *
     * @brief[en] Gets precision
     * @return[en] Precision string (always highp)
     */
    public func getPrecision(): String {
        return "highp"
    }
}
