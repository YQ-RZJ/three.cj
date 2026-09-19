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
 * @file[zh-cn] bgfx 阴影贴图管理
 * @brief[zh-cn] 替代 WebGLShadowMap，使用 FrameBufferHandle 管理阴影贴图
 * @explain[zh-cn] 对照源码 three.js/src/renderers/webgl/WebGLShadowMap.js。WebGLShadowMap 使用 WebGLRenderTarget 管理阴影贴图，bgfx 版本使用 FrameBufferHandle 替代。支持三种阴影贴图类型：BasicShadowMap、PCFShadowMap、VSMShadowMap。
 *
 * @file[en] bgfx Shadow Map Management
 * @brief[en] Replaces WebGLShadowMap, manages shadow maps using FrameBufferHandle
 * @explain[en] Corresponds to three.js/src/renderers/webgl/WebGLShadowMap.js. WebGLShadowMap uses WebGLRenderTarget for shadow maps; the bgfx version uses FrameBufferHandle instead. Supports three shadow map types: BasicShadowMap, PCFShadowMap, VSMShadowMap.
 */
package three.rendering.bgfx

import std.collection.*
import bgfx4cj.bgfx.*
import three.rendering.lights.*
import three.utils.log.*
import three.utils.log.macros.*
import three.utils.memory.AutoFreePtr

/**
 * @brief[zh-cn] 阴影贴图信息
 * @explain[zh-cn] 存储单个阴影贴图的 GPU 资源句柄和元数据
 *
 * @brief[en] Shadow map information
 * @explain[en] Stores GPU resource handles and metadata for a single shadow map
 */
public class ShadowMapInfo {
    /**
     * @brief[zh-cn] bgfx 帧缓冲句柄
     *
     * @brief[en] bgfx frame buffer handle
     */
    public var frameBuffer: FrameBufferHandle = FrameBufferHandle()
    /**
     * @brief[zh-cn] 阴影贴图纹理句柄（深度纹理，或 VSM/ESM 的颜色纹理）
     *
     * @brief[en] Shadow map texture handle (depth texture, or color texture for VSM/ESM)
     */
    public var texture: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] VSM/ESM 深度纹理句柄（仅 VSM/ESM 模式需要：原生深度 -> blur -> 颜色）
     *
     * @brief[en] VSM/ESM depth texture handle (only for VSM/ESM mode: native depth -> blur -> color)
     */
    public var depthTexture: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] VSM/ESM pass 的临时帧缓冲（仅 VSM/ESM 模式需要）
     *
     * @brief[en] VSM/ESM pass temporary frame buffer (only for VSM/ESM mode)
     */
    public var passFrameBuffer: FrameBufferHandle = FrameBufferHandle()
    /**
     * @brief[zh-cn] VSM/ESM pass 的临时纹理（仅 VSM/ESM 模式需要）
     *
     * @brief[en] VSM/ESM pass temporary texture (only for VSM/ESM mode)
     */
    public var passTexture: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] VSM/ESM 最终颜色纹理的帧缓冲（水平 blur 写入目标，仅 VSM/ESM 模式）
     *
     * @brief[en] VSM/ESM final color texture frame buffer (horizontal blur target, only for VSM/ESM mode)
     */
    public var finalFrameBuffer: FrameBufferHandle = FrameBufferHandle()
    /**
     * @brief[zh-cn] 阴影贴图宽度
     *
     * @brief[en] Shadow map width
     */
    public var width: Int64 = 512
    /**
     * @brief[zh-cn] 阴影贴图高度
     *
     * @brief[en] Shadow map height
     */
    public var height: Int64 = 512
    /**
     * @brief[zh-cn] 阴影类型（创建时确定的 SmImpl 类型）
     *
     * @brief[en] Shadow type (SmImpl type determined at creation)
     */
    public var shadowType: Int64 = PCF_SHADOW_MAP
    /**
     * @brief[zh-cn] 阴影贴图分布类型（SmType: Single/Omni/Cascade）
     *
     * @brief[en] Shadow map distribution type (SmType: Single/Omni/Cascade)
     */
    public var smType: Int64 = SM_TYPE_SINGLE
    /**
     * @brief[zh-cn] 深度计算方式（DepthImpl: InvZ/Linear）
     *
     * @brief[en] Depth implementation (DepthImpl: InvZ/Linear)
     */
    public var depthImpl: Int64 = DEPTH_IMPL_INVZ
    /**
     * @brief[zh-cn] 深度打包方式（PackDepth: RGBA/VSM）
     *
     * @brief[en] Depth packing mode (PackDepth: RGBA/VSM)
     */
    public var packDepth: Int64 = PACK_DEPTH_RGBA
    /**
     * @brief[zh-cn] 是否为立方体贴图（PointLight）
     *
     * @brief[en] Whether this is a cube map (PointLight)
     */
    public var isCube: Bool = false
    /**
     * @brief[zh-cn] CSM 级联数量（0 表示非 CSM）
     *
     * @brief[en] CSM cascade count (0 means non-CSM)
     */
    public var cascadeCount: Int64 = 0
    /**
     * @brief[zh-cn] CSM atlas 子纹理数组（每级一个子纹理句柄，atlas 模式下复用 texture）
     *
     * @brief[en] CSM atlas sub-texture array (one sub-texture handle per level, reuses texture in atlas mode)
     */
    public var cascadeTextures: ArrayList<TextureHandle> = ArrayList<TextureHandle>()
    /**
     * @brief[zh-cn] CSM atlas 子 framebuffer 数组（每级一个子 FB，atlas 模式下按 quadrant 切分）
     *
     * @brief[en] CSM atlas sub-framebuffer array (one sub-FB per level, split by quadrant in atlas mode)
     */
    public var cascadeFrameBuffers: ArrayList<FrameBufferHandle> = ArrayList<FrameBufferHandle>()
    /**
     * @brief[zh-cn] PCSS blocker search 专用 framebuffer（仅 PCSS 模式需要）
     *
     * @brief[en] PCSS blocker search dedicated framebuffer (only for PCSS mode)
     */
    public var blockerFrameBuffer: FrameBufferHandle = FrameBufferHandle()
    /**
     * @brief[zh-cn] PCSS blocker search 专用纹理（仅 PCSS 模式需要）
     *
     * @brief[en] PCSS blocker search dedicated texture (only for PCSS mode)
     */
    public var blockerTexture: TextureHandle = TextureHandle()
    /**
     * @brief[zh-cn] 立方体贴图阴影各 face 的独立 framebuffer（仅 isCube=true 时使用，6 个 face 各一个）
     *
     * @brief[en] Per-face framebuffers for cube shadow maps (only when isCube=true, one per face)
     */
    public var faceFrameBuffers: ArrayList<FrameBufferHandle> = ArrayList<FrameBufferHandle>()
    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether initialized
     */
    public var initialized: Bool = false

    public init() {}
}

/**
 * @brief[zh-cn] bgfx 阴影贴图管理
 * @explain[zh-cn] 对照 WebGLShadowMap，管理阴影贴图的创建、渲染和释放。bgfx 使用 FrameBufferHandle 替代 WebGLRenderTarget。Basic/PCF 使用直接深度纹理 FrameBuffer，VSM 使用两步创建（深度纹理 -> blur pass -> RG 颜色纹理）
 *
 * @brief[en] bgfx shadow map management
 * @explain[en] Corresponds to WebGLShadowMap, manages shadow map creation, rendering and release. bgfx uses FrameBufferHandle instead of WebGLRenderTarget. Basic/PCF uses direct depth texture FrameBuffer, VSM uses two-step creation (depth texture -> blur pass -> RG color texture)
 */
public class BgfxShadowMap {
    /**
     * @brief[zh-cn] 阴影贴图映射（光源 ID -> ShadowMapInfo）
     *
     * @brief[en] Shadow map mapping (light ID -> ShadowMapInfo)
     */
    private var shadowMaps: HashMap<Int64, ShadowMapInfo>
    /**
     * @brief[zh-cn] 是否启用阴影
     *
     * @brief[en] Whether shadow is enabled
     */
    private var enabled: Bool = false
    /**
     * @brief[zh-cn] 阴影类型（BASIC_SHADOW_MAP / PCF_SHADOW_MAP / VSM_SHADOW_MAP）
     *
     * @brief[en] Shadow type (BASIC_SHADOW_MAP / PCF_SHADOW_MAP / VSM_SHADOW_MAP)
     */
    private var shadowType: Int64 = PCF_SHADOW_MAP
    /**
     * @brief[zh-cn] 上一帧的阴影类型，用于检测类型变更时重建阴影贴图和重新编译材质
     *
     * @brief[en] Previous frame shadow type, used to detect type changes to rebuild shadow maps and recompile materials
     */
    private var previousType: Int64 = PCF_SHADOW_MAP
    /**
     * @brief[zh-cn] 渲染统计
     *
     * @brief[en] Render statistics
     */
    private var info: BgfxInfo

    public init(info!: BgfxInfo = BgfxInfo()) {
        this.shadowMaps = HashMap<Int64, ShadowMapInfo>()
        this.info = info
    }

    /**
     * @brief[zh-cn] 是否启用阴影
     * @return[zh-cn] 是否启用
     *
     * @brief[en] Whether shadow is enabled
     * @return[en] Whether enabled
     */
    public func isEnabled(): Bool {
        return enabled
    }

    /**
     * @brief[zh-cn] 设置阴影启用状态
     * @param[zh-cn] value 是否启用
     *
     * @brief[en] Set shadow enabled state
     * @param[en] value Whether to enable
     */
    public func setEnabled(value: Bool): Unit {
        enabled = value
    }

    /**
     * @brief[zh-cn] 获取阴影类型
     * @return[zh-cn] 阴影类型
     *
     * @brief[en] Get shadow type
     * @return[en] Shadow type
     */
    public func getShadowType(): Int64 {
        return shadowType
    }

    /**
     * @brief[zh-cn] 设置阴影类型
     * @param[zh-cn] value 阴影类型
     *
     * @brief[en] Set shadow type
     * @param[en] value Shadow type
     */
    public func setShadowType(value: Int64): Unit {
        // 记录类型变更（触发后续重建阴影贴图和材质重编译）
        this.previousType = this.shadowType
        this.shadowType = value
    }

    /**
     * @brief[zh-cn] 检查阴影类型是否在上一帧到当前帧之间发生了变化
     * @explain[zh-cn] 渲染器可用此标志决定是否需要重新编译材质（sampler2D vs sampler2DShadow 差异）
     * @return[zh-cn] 是否发生变化
     *
     * @brief[en] Check if shadow type changed between the previous frame and current frame
     * @explain[en] Renderer can use this flag to decide whether materials need recompilation (sampler2D vs sampler2DShadow difference)
     * @return[en] Whether changed
     */
    public func hasTypeChanged(): Bool {
        return this.shadowType != this.previousType
    }

    /**
     * @brief[zh-cn] 获取或创建阴影贴图
     * @param[zh-cn] lightId 光源 ID
     * width 阴影贴图宽度
     * height 阴影贴图高度
     * isCube 是否为立方体贴图（点光源）
     * @return[zh-cn] 阴影贴图信息
     *
     * @brief[en] Get or create shadow map
     * @param[en] lightId Light ID
     * width Shadow map width
     * height Shadow map height
     * isCube Whether this is a cube map (point light)
     * @return[en] Shadow map information
     */
    public func getShadowMap(lightId: Int64, width: Int64, height: Int64, isCube!: Bool = false): ShadowMapInfo {
        @LogDebug(["shadowMap", "getShadowMap lightId=${lightId} w=${width} h=${height} isCube=${isCube}"])
        match (shadowMaps.get(lightId)) {
            case Some(shadowMap) =>
                @LogDebug(["shadowMap", "cache hit, w=${shadowMap.width} h=${shadowMap.height} type=${shadowMap.shadowType}"])
                // 如果尺寸或类型变化，需要重新创建
                if (shadowMap.width != width || shadowMap.height != height ||
                    shadowMap.shadowType != this.shadowType || shadowMap.isCube != isCube) {
                    @LogDebug(["shadowMap", "cache invalid, recreating"])
                    destroyShadowMap(lightId)
                    return createShadowMap(lightId, width, height, isCube)
                }
                @LogDebug(["shadowMap", "returning cached, fb.idx=${shadowMap.frameBuffer.idx}"])
                return shadowMap
            case None =>
                @LogDebug(["shadowMap", "cache miss, creating new"])
                return createShadowMap(lightId, width, height, isCube)
        }
    }

    /**
     * @brief[zh-cn] 创建阴影贴图
     * @explain[zh-cn] 根据当前 shadowType 选择不同的纹理格式和创建方式。Basic/PCF 使用 D24S8 深度纹理，VSM 使用深度纹理 + RG16F 颜色纹理
     * @param[zh-cn] lightId 光源 ID
     * width 阴影贴图宽度
     * height 阴影贴图高度
     * isCube 是否为立方体贴图
     * @return[zh-cn] 阴影贴图信息
     *
     * @brief[en] Create shadow map
     * @explain[en] Creates shadow map with different texture formats based on current shadowType. Basic/PCF uses D24S8 depth texture, VSM uses depth texture + RG16F color texture
     * @param[en] lightId Light ID
     * width Shadow map width
     * height Shadow map height
     * isCube Whether this is a cube map
     * @return[en] Shadow map information
     */
    private func createShadowMap(lightId: Int64, width: Int64, height: Int64, isCube: Bool): ShadowMapInfo {
        @LogDebug(["shadowMap", "createShadowMap ENTRY lightId=${lightId} w=${width} h=${height} isCube=${isCube} type=${this.shadowType}"])
        let shadowMap = ShadowMapInfo()
        shadowMap.width = width
        shadowMap.height = height
        shadowMap.shadowType = this.shadowType
        shadowMap.isCube = isCube

        if (this.shadowType == VSM_SHADOW_MAP) {
            // VSM 模式：
            //   depthTexture (D32)  -> frameBuffer  : 深度 pass 写入
            //   passTexture  (RG16F) -> passFrameBuffer : 垂直 blur 中间结果
            //   texture      (RG16F) : 水平 blur 最终结果（直接绑定到外部句柄）
            //
            // 关键：所有 framebuffer 必须用 bgfx_create_frame_buffer_from_handles_cj
            // 把"外部创建的纹理句柄"包进 FB，这样：
            //   ① 深度 pass 写入 frameBuffer 的内容 = depthTexture 句柄的内容
            //   ② blur pass 读 depthTexture / passTexture 时拿到的是同一份 GPU 资源
            // 否则 bgfx_create_frame_buffer_cj 创建的 FB 内部 RT 纹理与外部句柄是两套资源，
            // VSM blur 会读到空纹理。

            // 1. 深度纹理（D32，原生深度）
            let depthTex = bgfx_create_texture_2d_cj(
                UInt16(width), UInt16(height), false, 1u16,
                TextureFormat.D32.value(), TEXTURE_RT, CPointer<Memory>()
            )
            shadowMap.depthTexture = depthTex
            // 用 from_handles 把 depthTex 包进 FB（destroyTexture=false，由 destroyShadowMap 统一释放）
            let depthHandlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
            unsafe { depthHandlesHolder.get().write(0, depthTex) }
            shadowMap.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(
                1u8, depthHandlesHolder.get(), false)
            depthHandlesHolder.dispose()

            // 2. VSM 中间纹理（RG16F，垂直 blur 输出 / 水平 blur 输入）
            let passTex = bgfx_create_texture_2d_cj(
                UInt16(width), UInt16(height), false, 1u16,
                TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>()
            )
            shadowMap.passTexture = passTex
            let passHandlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
            unsafe { passHandlesHolder.get().write(0, passTex) }
            shadowMap.passFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(
                1u8, passHandlesHolder.get(), false)
            passHandlesHolder.dispose()

            // 3. VSM 最终阴影纹理（RG16F，水平 blur 输出）
            //    主 pass 通过此句柄采样
            let colorTex = bgfx_create_texture_2d_cj(
                UInt16(width), UInt16(height), false, 1u16,
                TextureFormat.RG16F.value(), TEXTURE_RT, CPointer<Memory>()
            )
            shadowMap.texture = colorTex
            // 注意：最终纹理也需要一个 FB 供水平 blur 写入
            // 复用 frameBuffer 字段不合适（那是深度 FB），故再加一个 finalFrameBuffer
            let finalHandlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
            unsafe { finalHandlesHolder.get().write(0, colorTex) }
            shadowMap.finalFrameBuffer = bgfx_create_frame_buffer_from_handles_cj(
                1u8, finalHandlesHolder.get(), false)
            finalHandlesHolder.dispose()
        } else {
            // Basic/PCF 模式：D24S8 深度纹理（cube/2D 统一；新版 bgfx D3D11 下 D24 无 DSV，
            // 作为深度附件创建 FB 会失败 → 方向光阴影整体消失）
            // PCF 模式下，HLSL 使用 sampler2DShadow 配合 LinearFilter（硬件 PCF）
            // Basic 模式下，HLSL 使用 sampler2D 配合 NearestFilter（直接深度比较）
            let depthTex: TextureHandle
            if (isCube) {
                // bgfx4cj: PointLight 立方体贴图阴影需用 bgfx_create_texture_cube_cj 创建真 cube 纹理
                let fmt = TextureFormat.D24S8.value()
                let cubeFlags = TEXTURE_RT | UInt64(SAMPLER_COMPARE_LEQUAL) | UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP)
                depthTex = bgfx_create_texture_cube_cj(
                    UInt16(width), false, 1u16,
                    fmt, cubeFlags, CPointer<Memory>()
                )
            } else {
                let fmt = TextureFormat.D24S8.value()
                // bgfx4cj: 必须加 SAMPLER_COMPARE_LEQUAL 启用硬件深度比较，否则 shadow2D 永远返回 0
                let texFlags = TEXTURE_RT | UInt64(SAMPLER_COMPARE_LEQUAL) | UInt64(SAMPLER_U_CLAMP) | UInt64(SAMPLER_V_CLAMP)
                depthTex = bgfx_create_texture_2d_cj(
                    UInt16(width), UInt16(height), false, 1u16,
                    fmt, texFlags, CPointer<Memory>()
                )
            }
            shadowMap.texture = depthTex
            if (isCube) {
                // bgfx 渲染到立方体贴图的单个 face 需用 Attachment 指定 layer（face 索引）。
                // 为每个 face（0-5）创建独立的 framebuffer，确保每个 face 写入正确的 cube 面。
                // 对照 bgfx 08-update 示例：Attachment::init(texture, access, layer)
                for (faceIdx in 0..6) {
                    let atHolder = AutoFreePtr<Attachment>(unsafe { LibC.malloc<Attachment>(count: 1i64) })
                    let at = atHolder.get()
                    bgfx_attachment_init_cj(at, depthTex, 0u32 /*Write (BGFX_ACCESS_WRITE=0)*/,
                        UInt16(faceIdx), 1u16, 0u16, flags: ATTACHMENT_NONE)
                    let faceFb = bgfx_create_frame_buffer_from_attachment_cj(1u8, at, false)
                    @LogDebug(["shadowMap", "cube face ${faceIdx} fb.idx=${faceFb.idx}"])
                    atHolder.dispose()
                    shadowMap.faceFrameBuffers.add(faceFb)
                }
                // frameBuffer 保留为第一个 face 的 fb（兼容性占位，实际渲染按 faceFrameBuffers 索引）
                shadowMap.frameBuffer = shadowMap.faceFrameBuffers[0]
            } else {
                // 非 cube：直接 from_handles 创建单层帧缓冲
                let handlesHolder = AutoFreePtr<TextureHandle>(unsafe { LibC.malloc<TextureHandle>(count: 1i64) })
                unsafe { handlesHolder.get().write(0, depthTex) }
                shadowMap.frameBuffer = bgfx_create_frame_buffer_from_handles_cj(
                    1u8, handlesHolder.get(), false)
                handlesHolder.dispose()
            }
        }

        shadowMap.initialized = true
        shadowMaps.add(lightId, shadowMap)
        return shadowMap
    }

    /**
     * @brief[zh-cn] 销毁阴影贴图（包括 VSM 的辅助纹理和帧缓冲）
     * @param[zh-cn] lightId 光源 ID
     *
     * @brief[en] Destroy shadow map (including VSM auxiliary textures and frame buffers)
     * @param[en] lightId Light ID
     */
    public func destroyShadowMap(lightId: Int64): Unit {
        @LogDebug(["shadowMap", "destroyShadowMap lightId=${lightId}"])
        match (shadowMaps.get(lightId)) {
            case Some(shadowMap) =>
                // 清理 cube face framebuffers（每个 face 独立的 fb）
                // 注意：shadowMap.frameBuffer 与 faceFrameBuffers[0] 是同一个句柄，
                // 避免重复销毁，先置空 frameBuffer 的 idx。
                if (shadowMap.isCube) {
                    shadowMap.frameBuffer.idx = 0xFFFFu16
                }
                for (faceFb in shadowMap.faceFrameBuffers) {
                    if (faceFb.idx != 0xFFFFu16) {
                        bgfx_destroy_frame_buffer_cj(faceFb)
                    }
                }
                shadowMap.faceFrameBuffers.clear()
                if (shadowMap.frameBuffer.idx != 0xFFFFu16) {
                    bgfx_destroy_frame_buffer_cj(shadowMap.frameBuffer)
                }
                if (shadowMap.texture.idx != 0xFFFFu16) {
                    bgfx_destroy_texture_cj(shadowMap.texture)
                }
                // 清理 VSM 额外资源
                if (shadowMap.depthTexture.idx != 0xFFFFu16) {
                    bgfx_destroy_texture_cj(shadowMap.depthTexture)
                }
                if (shadowMap.passFrameBuffer.idx != 0xFFFFu16) {
                    bgfx_destroy_frame_buffer_cj(shadowMap.passFrameBuffer)
                }
                if (shadowMap.passTexture.idx != 0xFFFFu16) {
                    bgfx_destroy_texture_cj(shadowMap.passTexture)
                }
                shadowMaps.remove(lightId)
            case None =>
                ()
        }
    }

    /**
     * @brief[zh-cn] 释放所有阴影贴图
     *
     * @brief[en] Dispose all shadow maps
     */
    public func dispose(): Unit {
        // 遍历的 key 收集后逐个释放（避免迭代中修改 HashMap）
        let keys = ArrayList<Int64>()
        for ((key, _) in shadowMaps) {
            keys.add(key)
        }
        for (key in keys) {
            destroyShadowMap(key)
        }
        shadowMaps = HashMap<Int64, ShadowMapInfo>()
    }
}
