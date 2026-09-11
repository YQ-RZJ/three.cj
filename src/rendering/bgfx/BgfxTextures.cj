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
 * @file[zh-cn] bgfx 纹理管理
 * @brief[zh-cn] 替代 WebGLTextures，使用 bgfx TextureHandle 管理纹理生命周期
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLTextures.js。在 WebGL 中通过 gl.createTexture/gl.texImage2D 管理纹理，在 bgfx 中通过 bgfx_create_texture_2d_cj/bgfx_destroy_texture_cj 管理。
 *
 * @file[en] bgfx Texture Management
 * @brief[en] Replaces WebGLTextures, manages texture lifecycle using bgfx TextureHandle
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLTextures.js. In WebGL, textures are managed via gl.createTexture/gl.texImage2D; in bgfx, they are managed via bgfx_create_texture_2d_cj/bgfx_destroy_texture_cj.
 */
package three.rendering.bgfx

import std.collection.*
import three.utils.constants.*
import bgfx4cj.bgfx.*
import three.utils.memory.BgfxMemory

/**
 * @brief[zh-cn] 纹理信息缓存
 * @explain[zh-cn] 对照 WebGLTextures 中存储的纹理属性
 *
 * @brief[en] Texture information cache
 * @explain[en] Corresponds to texture properties stored in WebGLTextures
 */
public class TextureInfo {
    /**
     * @brief[zh-cn] bgfx 纹理句柄
     *
     * @brief[en] bgfx texture handle
     */
    public var handle: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] 纹理格式
     *
     * @brief[en] Texture format
     */
    public var format: UInt32 = 0u32
    /**
     * @brief[zh-cn] 纹理宽度
     *
     * @brief[en] Texture width
     */
    public var width: Int64 = 0
    /**
     * @brief[zh-cn] 纹理高度
     *
     * @brief[en] Texture height
     */
    public var height: Int64 = 0
    /**
     * @brief[zh-cn] 是否需要更新
     *
     * @brief[en] Whether needs update
     */
    public var needsUpdate: Bool = true
    /**
     * @brief[zh-cn] 版本号
     *
     * @brief[en] Version number
     */
    public var version: Int64 = -1

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 纹理管理
 * @explain[zh-cn] 对照 WebGLTextures，管理纹理的创建、更新和销毁。使用 bgfx TextureHandle 替代 WebGL 纹理对象。bgfx 的纹理采样模式通过 sampler uniform 设置，而非纹理标志
 *
 * @brief[en] bgfx texture management
 * @explain[en] Corresponds to WebGLTextures, manages texture creation, update and destruction. Uses bgfx TextureHandle instead of WebGL texture objects. bgfx texture sampling modes are set via sampler uniforms, not texture flags
 */
public class BgfxTextures {
    /**
     * @brief[zh-cn] 纹理映射（纹理 ID -> 纹理信息）
     *
     * @brief[en] Texture mapping (texture ID -> texture info)
     */
    private var textures: HashMap<Int64, TextureInfo>
    /**
     * @brief[zh-cn] 渲染能力
     *
     * @brief[en] Render capabilities
     */
    private var capabilities: BgfxCapabilities
    /**
     * @brief[zh-cn] 工具函数
     *
     * @brief[en] Utility functions
     */
    private var utils: BgfxUtils
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo
    /**
     * @brief[zh-cn] 属性存储
     *
     * @brief[en] Property storage
     */
    private var properties: BgfxProperties

    public init(capabilities!: BgfxCapabilities, utils!: BgfxUtils, info!: BgfxInfo, properties!: BgfxProperties) {
        this.textures = HashMap<Int64, TextureInfo>()
        this.capabilities = capabilities
        this.utils = utils
        this.info = info
        this.properties = properties
    }

    /**
     * @brief[zh-cn] 获取纹理信息
     * @explain[zh-cn] 对照 WebGLTextures.getTexture()
     * @param[zh-cn] textureId 纹理 ID
     * @return[zh-cn] 纹理信息
     *
     * @brief[en] Get texture information
     * @explain[en] Corresponds to WebGLTextures.getTexture()
     * @param[en] textureId Texture ID
     * @return[en] Texture information
     */
    public func get(textureId: Int64): Option<TextureInfo> {
        return textures.get(textureId)
    }

    /**
     * @brief[zh-cn] 创建 2D 纹理
     * @explain[zh-cn] 对照 WebGLTextures.createTexture()
     * @param[zh-cn] textureId 纹理对象 ID
     * width 纹理宽度
     * height 纹理高度
     * format bgfx 纹理格式
     * flags 纹理标志（TEXTURE_RT、TEXTURE_SRGB 等）
     * mem 纹理数据内存（Some=有数据；None=空 RT）
     * @return[zh-cn] 纹理句柄
     *
     * @brief[en] Create 2D texture
     * @explain[en] Corresponds to WebGLTextures.createTexture()
     * @param[en] textureId Texture object ID
     * width Texture width
     * height Texture height
     * format bgfx texture format
     * flags Texture flags (TEXTURE_RT, TEXTURE_SRGB, etc.)
     * mem Texture data memory (Some=has data; None=empty RT)
     * @return[en] Texture handle
     */
    public func createTexture2D(textureId: Int64, width: Int64, height: Int64, format: UInt32, flags: UInt64, mem: Option<BgfxMemory>): TextureHandle {
        let memPtr = match (mem) {
            case Some(m) => m.get()
            case None => CPointer<Memory>()
        }
        let handle = bgfx_create_texture_2d_cj(UInt16(width), UInt16(height), false, 1u16, format, flags, memPtr)
        let texInfo = TextureInfo()
        texInfo.handle = handle
        texInfo.format = format
        texInfo.width = width
        texInfo.height = height
        texInfo.needsUpdate = false
        textures.add(textureId, texInfo)
        info.memory.textures += 1
        return handle
    }

    /**
     * @brief[zh-cn] 更新 2D 纹理数据
     * @explain[zh-cn] 对照 WebGLTextures.updateTexture()
     * @param[zh-cn] textureId 纹理 ID
     * x 更新区域 X 偏移
     * y 更新区域 Y 偏移
     * width 更新区域宽度
     * height 更新区域高度
     * mem 纹理数据内存
     * pitch 行间距
     *
     * @brief[en] Update 2D texture data
     * @explain[en] Corresponds to WebGLTextures.updateTexture()
     * @param[en] textureId Texture ID
     * x Update region X offset
     * y Update region Y offset
     * width Update region width
     * height Update region height
     * mem Texture data memory
     * pitch Row pitch
     */
    public func updateTexture2D(textureId: Int64, x: UInt16, y: UInt16, width: UInt16, height: UInt16, mem: BgfxMemory, pitch: UInt16): Unit {
        match (textures.get(textureId)) {
            case Some(texInfo) =>
                if (texInfo.handle.idx != 0xFFFFu16) {
                    bgfx_update_texture_2d_cj(texInfo.handle, 0u16, 0u8, x, y, width, height, mem.get(), pitch)
                    texInfo.needsUpdate = false
                }
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 销毁纹理
     * @explain[zh-cn] 对照 WebGLTextures.destroyTexture()
     * @param[zh-cn] textureId 纹理 ID
     *
     * @brief[en] Destroy texture
     * @explain[en] Corresponds to WebGLTextures.destroyTexture()
     * @param[en] textureId Texture ID
     */
    public func destroyTexture(textureId: Int64): Unit {
        match (textures.get(textureId)) {
            case Some(texInfo) =>
                if (texInfo.handle.idx != 0xFFFFu16) {
                    bgfx_destroy_texture_cj(texInfo.handle)
                    texInfo.handle = TextureHandle()
                }
                textures.remove(textureId)
                info.memory.textures -= 1
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 将 three.js 纹理参数转换为 bgfx 纹理标志
     * @explain[zh-cn] 对照 WebGLTextures.setTextureParameters()。bgfx 的采样模式通过 sampler uniform 设置，纹理标志主要用于渲染目标、sRGB、MSAA 等特性
     * @param[zh-cn] sRGB 是否使用 sRGB
     * renderTarget 是否为渲染目标
     * msaa MSAA 采样数
     * @return[zh-cn] bgfx 纹理标志
     *
     * @brief[en] Convert three.js texture parameters to bgfx texture flags
     * @explain[en] Corresponds to WebGLTextures.setTextureParameters(). bgfx sampling modes are set via sampler uniforms; texture flags are mainly for render target, sRGB, MSAA features
     * @param[en] sRGB Whether to use sRGB
     * renderTarget Whether this is a render target
     * msaa MSAA sample count
     * @return[en] bgfx texture flags
     */
    public static func convertTextureFlags(sRGB: Bool, renderTarget: Bool, msaa: Int64): UInt64 {
        var flags: UInt64 = TEXTURE_NONE

        if (sRGB) {
            flags = flags | TEXTURE_SRGB
        }

        if (renderTarget) {
            flags = flags | TEXTURE_RT
        }

        if (msaa == 2) {
            flags = flags | TEXTURE_RT_MSAA_X2
        } else if (msaa == 4) {
            flags = flags | TEXTURE_RT_MSAA_X4
        } else if (msaa == 8) {
            flags = flags | TEXTURE_RT_MSAA_X8
        } else if (msaa == 16) {
            flags = flags | TEXTURE_RT_MSAA_X16
        }

        return flags
    }

    /**
     * @brief[zh-cn] 释放所有纹理
     *
     * @brief[en] Dispose all textures
     */
    public func dispose(): Unit {
        for ((_, texInfo) in textures) {
            if (texInfo.handle.idx != 0xFFFFu16) {
                bgfx_destroy_texture_cj(texInfo.handle)
            }
        }
        textures = HashMap<Int64, TextureInfo>()
        info.memory.textures = 0
    }
}
