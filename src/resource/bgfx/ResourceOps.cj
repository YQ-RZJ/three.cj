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
 * @file[zh-cn] ResourceOps bgfx 底层资源操作
 * @brief[zh-cn] bgfx 底层资源生命周期操作的独立封装类
 * @explain[zh-cn] 设计动机：three.scene.scenegraph 包（如 GroundReflector）需要创建/销毁纹理与 frame buffer，但直接 import three.rendering.ThreeRenderer 会形成包级循环依赖。本类把纹理/帧缓冲的创建与销毁下沉到 three.resource.bgfx（无 renderers 依赖的底层包），供 objects 包与 renderers 包共同引用，消除循环依赖，同时避免外部直接接触底层 bgfx_*_cj FFI。对外签名与 ThreeRenderer 高阶 API 保持一致，指针操作在内部完成。线程模型：本类方法直接调用 bgfx FFI，不做线程序列化。
 *
 * @file[en] ResourceOps  bgfx low-level resource operations
 * @brief[en] Standalone wrapper class for bgfx low-level resource lifecycle operations
 * @explain[en] Design motivation: The three.scene.scenegraph package (e.g., GroundReflector) needs to create/destroy textures and frame buffers, but directly importing three.rendering.ThreeRenderer creates a package-level circular dependency. This class encapsulates texture/framebuffer creation and destruction in three.resource.bgfx (a low-level package with no renderers dependency), allowing both objects and renderers packages to reference it, eliminating circular dependencies while preventing external access to low-level bgfx_*_cj FFI. Public signatures are consistent with ThreeRenderer high-level API; pointer operations are internal. Threading model: Methods call bgfx FFI directly without thread serialization.
 */
package three.resource.bgfx

import bgfx4cj.bgfx as bgfx
import three.rendering.types.*
import three.utils.memory.*
import three.core.thread.bgfxCallMtx

/**
 * @brief[zh-cn] bgfx 底层资源操作封装类
 * @explain[zh-cn] 封装纹理/帧缓冲的创建、销毁、查询等生命周期操作，签名与 ThreeRenderer 高阶 API 保持一致，便于两侧复用同一套约定。
 *
 * @brief[en] Wrapper class for bgfx low-level resource operations
 * @explain[en] Encapsulates texture/framebuffer creation, destruction, and query lifecycle operations with signatures consistent with ThreeRenderer high-level API for reuse across modules.
 * bgfx 底层资源操作。
 */
public class ResourceOps {
    public init() {}

    // ===== 纹理创建/销毁 =====

    /**
     * @brief[zh-cn] 创建 2D 纹理
     * @param[zh-cn] w 纹理宽（像素）
     * h 纹理高（像素）
     * hasMips 是否生成 mipmap
     * numLayers 图层数（1=普通 2D 纹理）
     * format 纹理格式（TextureFormat.RGBA16F.value() 等）
     * flags 纹理 flags（TEXTURE_RT | SAMPLER_U_CLAMP | SAMPLER_V_CLAMP 等）
     * mem 纹理数据内存（None 表示空 RT；Some 表示有数据）
     * @return[zh-cn] 纹理句柄
     *
     * @brief[en] Create a 2D texture
     * @param[en] w Texture width in pixels
     * h Texture height in pixels
     * hasMips Whether to generate mipmaps
     * numLayers Number of layers (1 for regular 2D texture)
     * format Texture format (e.g., TextureFormat.RGBA16F.value())
     * flags Texture flags (e.g., TEXTURE_RT | SAMPLER_U_CLAMP | SAMPLER_V_CLAMP)
     * mem Texture data memory (None for empty RT; Some for data)
     * @return[en] Texture handle
     * 创建 2D 纹理。
     */
    public func createTexture2D(
        w: UInt16,
        h: UInt16,
        hasMips: Bool,
        numLayers: UInt16,
        format: UInt32,
        flags: UInt64,
        mem: Option<BgfxMemory>
    ): TextureHandle {
        let memPtr = match (mem) {
            case Some(m) => m.get()
            case None => CPointer<bgfx.Memory>()
        }
        return Box(bgfx.bgfx_create_texture_2d_cj(w, h, hasMips, numLayers, format, flags, memPtr))
    }

    /**
     * @brief[zh-cn] 销毁纹理句柄
     * @param[zh-cn] tex 待销毁纹理句柄
     *
     * @brief[en] Destroy a texture handle
     * @param[en] tex Texture handle to destroy
     * 销毁纹理句柄。
     */
    public func destroyTexture(tex: TextureHandle): Unit {
        bgfx.bgfx_destroy_texture_cj(tex.value)
    }

    // ===== FrameBuffer 创建/销毁 =====

    /**
     * @brief[zh-cn] 由多个纹理句柄创建帧缓冲
     * @param[zh-cn] numAttachments attachment 数量
     * handles attachments 纹理句柄数组
     * destroyHandles bgfx 销毁 FB 时是否自动销毁这些 texture 句柄
     * @return[zh-cn] frame buffer 句柄
     *
     * @brief[en] Create a frame buffer from multiple texture handles
     * @param[en] numAttachments Number of attachments
     * handles Array of attachment texture handles
     * destroyHandles Whether bgfx automatically destroys these texture handles when the FB is destroyed
     * @return[en] Frame buffer handle
     * 由多个纹理句柄创建 frame buffer（attachments 顺序对应 attachment 索引）。
     */
    public func createFrameBuffer(
        numAttachments: UInt8,
        handles: Array<TextureHandle>,
        destroyHandles: Bool
    ): FrameBufferHandle {
        // 构造连续内存的 bgfx TextureHandle 数组（attachment 顺序对应索引）
        let holder = AutoFreePtr<bgfx.TextureHandle>(unsafe { LibC.malloc<bgfx.TextureHandle>(count: Int64(handles.size)) })
        for (i in 0..handles.size) {
            unsafe { (holder.get() + i).write(0, handles[i].value) }
        }
        bgfxCallMtx.lock()
        let fb: bgfx.FrameBufferHandle
        try {
            fb = bgfx.bgfx_create_frame_buffer_from_handles_cj(numAttachments, holder.get(), destroyHandles)
        } finally {
            holder.dispose()
            bgfxCallMtx.unlock()
        }
        return Box(fb)
    }
    /**
     * @brief[zh-cn] 销毁帧缓冲句柄
     * @param[zh-cn] fb 待销毁 frame buffer 句柄
     *
     * @brief[en] Destroy a frame buffer handle
     * @param[en] fb Frame buffer handle to destroy
     * 销毁 frame buffer 句柄。
     */
    public func destroyFrameBuffer(fb: FrameBufferHandle): Unit {
        bgfxCallMtx.lock()
        try {
            bgfx.bgfx_destroy_frame_buffer_cj(fb.value)
        } finally {
            bgfxCallMtx.unlock()
        }
    }
}
