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
 * @file[zh-cn] BgfxEncoderGfx 多线程提交器实现
 * @brief[zh-cn] IGfxEncoder 的 bgfx 实现（每实例包装一个 bgfx Encoder 指针）
 * @explain[zh-cn] 线程模型（与 IGfxEncoder 契约一致）：一个实例同一时刻仅可被
 * 一个线程使用；方法不经命令执行器路由、不持全局锁——bgfx encoder 是官方的
 * 多线程提交机制（forThread 获取即绑定当前线程），外部序列化反而破坏其并发
 * 语义。实例经 BgfxBackend.acquireEncoder/releaseEncoder 获取与归还。
 *
 * @file[en] BgfxEncoderGfx multi-threaded encoder implementation
 * @brief[en] The bgfx implementation of IGfxEncoder (each instance wraps one bgfx Encoder pointer)
 * @explain[en] Threading model (per the IGfxEncoder contract): one instance may be
 * used by only one thread at a time; methods are NOT routed through the command
 * executor and take no global lock — the bgfx encoder is the official multi-threaded
 * submission mechanism (forThread acquisition binds the calling thread), and external
 * serialization would defeat its concurrency semantics. Instances are acquired and
 * released via BgfxBackend.acquireEncoder/releaseEncoder.
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import bgfx4cj.bgfx as bgfx
import bgfx4cj.bx.*
import three.renderers._gfx.*
public import three.renderers._interfaces.IGfxEncoder
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray

internal class BgfxEncoderGfx <: IGfxEncoder {
    /** 底层 bgfx Encoder 指针（获取时绑定线程，生命周期由 acquire/release 管理） */
    private let enc: CPointer<bgfx.Encoder>

    internal init(enc: CPointer<bgfx.Encoder>) {
        this.enc = enc
    }

    /** 供 releaseEncoder 归还时取回底层指针（同包内使用） */
    internal func encPtr(): CPointer<bgfx.Encoder> {
        this.enc
    }

    /** 设置调试标记。 */
    public func setMarker(name: String): Unit {
        let cName = unsafe { LibC.mallocCString(name) }
        let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
        bgfx.bgfx_encoder_set_marker_cj(this.enc, cName, Int32(name.size))
        cNameHolder.dispose()
    }

    /** 设置 per-draw 渲染状态位域。 */
    public func setState(state: UInt64, rgba!: UInt32): Unit {
        bgfx.bgfx_encoder_set_state_cj(this.enc, state, rgba)
    }

    /** 设置 per-draw 模板状态（前/后面位域）。 */
    public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit {
        bgfx.bgfx_encoder_set_stencil_cj(this.enc, fstencil, bstencil)
    }

    /** 设置 per-draw 裁剪矩形；返回可复用的缓存序号。 */
    public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16 {
        bgfx.bgfx_encoder_set_scissor_cj(this.enc, x, y, w, h)
    }

    /** 复用缓存的裁剪矩形。 */
    public func setScissorCached(cache: UInt16): Unit {
        bgfx.bgfx_encoder_set_scissor_cached_cj(this.enc, cache)
    }

    /** 设置模型变换矩阵（列主序 16 元素；num>1 为实例化批量）；返回缓存序号。 */
    public func setTransform(mtx: PtrArray<Float32>, num!: UInt16): UInt32 {
        bgfx.bgfx_encoder_set_transform_cj(this.enc, unsafe { CPointer<Unit>(mtx.data()) }, num)
    }

    /** 复用缓存的变换矩阵。 */
    public func setTransformCached(cache: UInt32, num!: UInt16): Unit {
        bgfx.bgfx_encoder_set_transform_cached_cj(this.enc, cache, num)
    }

    /** 预分配变换矩阵存储（直写通道，绕过 Float64→Float32 转换）；返回 (缓存序号, 矩阵存储)。 */
    public func allocTransform(num: UInt16): (UInt32, PtrArray<Float32>) {
        let holder = AutoFreePtr<bgfx.Transform>(unsafe { LibC.malloc<bgfx.Transform>() })
        unsafe { holder.get().write(bgfx.Transform()) }
        let cache = bgfx.bgfx_encoder_alloc_transform_cj(this.enc, holder.get(), num)
        let t = unsafe { holder.get().read() }
        holder.dispose()
        return (cache, PtrArray<Float32>(t.data, size: Int64(num) * 16))
    }

    /** 设置 uniform 数据（浮点数组；按 uniform 类型解释）。 */
    public func setUniform(h: GfxUniformHandle, data: PtrArray<Float32>, num!: UInt16): Unit {
        bgfx.bgfx_encoder_set_uniform_cj(this.enc, toBgfx(h), unsafe { CPointer<Unit>(data.data()) }, num)
    }

    /** 绑定静态索引缓冲。 */
    public func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
        bgfx.bgfx_encoder_set_index_buffer_cj(this.enc, toBgfx(ib), firstIndex, numIndices)
    }

    /** 绑定动态索引缓冲。 */
    public func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
        bgfx.bgfx_encoder_set_dynamic_index_buffer_cj(this.enc, toBgfx(ib), firstIndex, numIndices)
    }

    /** 绑定静态顶点缓冲（无布局）。 */
    public func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit {
        bgfx.bgfx_encoder_set_vertex_buffer_cj(this.enc, stage, toBgfx(vb), startVertex, numVertices)
    }

    /** 绑定静态顶点缓冲（带布局）。 */
    public func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle,
        startVertex!: UInt32, numVertices!: UInt32): Unit {
        bgfx.bgfx_encoder_set_vertex_buffer_with_layout_cj(this.enc, stage, toBgfx(vb), startVertex, numVertices,
            toBgfx(layout))
    }

    /** 绑定动态顶点缓冲。 */
    public func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32,
        numVertices!: UInt32): Unit {
        bgfx.bgfx_encoder_set_dynamic_vertex_buffer_cj(this.enc, stage, toBgfx(vb), startVertex, numVertices)
    }

    /** 设置顶点计数（无顶点缓冲模式）。 */
    public func setVertexCount(numVertices: UInt32): Unit {
        bgfx.bgfx_encoder_set_vertex_count_cj(this.enc, numVertices)
    }

    /** 设置实例计数。 */
    public func setInstanceCount(numInstances: UInt32): Unit {
        bgfx.bgfx_encoder_set_instance_count_cj(this.enc, numInstances)
    }

    /** 绑定纹理到采样器槽。 */
    public func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit {
        bgfx.bgfx_encoder_set_texture_cj(this.enc, stage, toBgfx(sampler), toBgfx(tex), flags)
    }

    /** 绑定图像（计算着色器读写）。 */
    public func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit {
        bgfx.bgfx_encoder_set_image_cj(this.enc, stage, toBgfx(tex), mip, toBgfx(access).value(), toBgfx(format).value())
    }

    /** 绑定计算索引缓冲。 */
    public func setComputeIndexBuffer(stage: UInt8, ib: GfxIndexBufferHandle, access: GfxAccess): Unit {
        bgfx.bgfx_encoder_set_compute_index_buffer_cj(this.enc, stage, toBgfx(ib), toBgfx(access).value())
    }

    /** 绑定计算顶点缓冲。 */
    public func setComputeVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, access: GfxAccess): Unit {
        bgfx.bgfx_encoder_set_compute_vertex_buffer_cj(this.enc, stage, toBgfx(vb), toBgfx(access).value())
    }

    /** 提交当前 draw 到视图。 */
    public func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit {
        bgfx.bgfx_encoder_submit_cj(this.enc, viewId, toBgfx(program), depth, blend)
    }

    /** 提交间接绘制。 */
    public func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle,
        start: UInt32, num: UInt32, depth!: UInt32, blend!: UInt8): Unit {
        bgfx.bgfx_encoder_submit_indirect_cj(this.enc, viewId, toBgfx(program), toBgfx(indirect), start, num, depth,
            blend)
    }

    /** 提交计算调度。 */
    public func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32,
        flags!: UInt8): Unit {
        bgfx.bgfx_encoder_dispatch_cj(this.enc, viewId, toBgfx(program), numX, numY, numZ, flags)
    }

    /** 纹理拷贝（整图区域）。 */
    public func blit(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, w: UInt16, h: UInt16): Unit {
        bgfx.bgfx_encoder_blit_cj(this.enc, viewId, toBgfx(dst), 0u8, 0u16, 0u16, 0u16, toBgfx(src), 0u8, 0u16, 0u16,
            0u16, w, h, 1u16)
    }

    /** 触发视图空提交。 */
    public func touch(viewId: UInt16): Unit {
        bgfx.bgfx_encoder_touch_cj(this.enc, viewId)
    }

    /** 丢弃当前 draw 的指定状态组。 */
    public func discard(flags: UInt8): Unit {
        bgfx.bgfx_encoder_discard_cj(this.enc, flags)
    }
}
