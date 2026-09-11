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
 * @file[zh-cn] bgfxMemory 安全包装 bgfx Memory 分配
 * @brief[zh-cn] 封装 bgfx 内存分配与瞬态缓冲 API，提供类型安全的构造/写入/访问接口
 * @explain[zh-cn] 本文件封装 bgfx_alloc / bgfx_copy / bgfx_make_ref / bgfx_make_ref_release
 * 以及 bgfx_alloc_transform 和各类瞬态缓冲（TransientIndex/VertexBuffer、
 * InstanceDataBuffer）分配接口，避免在渲染层直接操作裸指针。
 * bgfx 内存的生命周期由 bgfx 引擎管理（每帧自动回收）。
 *
 * @file[en] bgfxMemory  Safe wrappers around bgfx Memory allocation
 * @brief[en] Wraps bgfx memory allocation and transient-buffer APIs with type-safe
 * construction, writing and access
 * @explain[en] This file wraps bgfx_alloc / bgfx_copy / bgfx_make_ref / bgfx_make_ref_release
 * plus bgfx_alloc_transform and the transient-buffer allocation APIs
 * (TransientIndex/VertexBuffer, InstanceDataBuffer), avoiding raw pointer
 * handling at the render layer. The lifetime of bgfx memory is managed by the
 * bgfx engine (reclaimed every frame).
 *
 * @package three.utils.memory
 */
package three.utils.memory

import bgfx4cj.bgfx.*
import three.rendering.types.VertexLayoutPtr


// =============================================================================
// BgfxMemory — 安全包装 bgfx Memory 分配
// =============================================================================

/**
 * @brief[zh-cn] 安全包装 bgfx Memory 分配
 * @explain[zh-cn] 封装 bgfx_alloc/bgfx_copy/bgfx_make_ref 返回的 CPointer<Memory>。
 * bgfx 内存的生命周期由 bgfx 引擎管理（每帧自动回收），
 * 本类仅提供安全的构造/写入/裸指针临时访问接口。
 * 三种构造方式：
 * - BgfxMemory(size)     → bgfx_alloc
 * - BgfxMemory(data, sz) → bgfx_copy
 * - BgfxMemory.ref(d,s)  → bgfx_make_ref（静态工厂，包装已有内存）
 * 使用示例：
 * let buf = BgfxMemory(16u32)
 * buf.writeFloats([1.0, 2.0, 3.0, 0.0], 4)
 * bgfx_set_uniform_cj(uHandle, buf.data(), 1u16)
 *
 * @brief[en] Safe wrapper around bgfx Memory allocation
 * @explain[en] Wraps the CPointer<Memory> returned by bgfx_alloc/bgfx_copy/bgfx_make_ref.
 * The lifetime of bgfx memory is managed by the bgfx engine (reclaimed every
 * frame); this class only offers safe construction, writing and temporary raw
 * pointer access.
 * Three construction modes:
 * - BgfxMemory(size)     → bgfx_alloc
 * - BgfxMemory(data, sz) → bgfx_copy
 * - BgfxMemory.ref(d,s)  → bgfx_make_ref (static factory wrapping existing memory)
 * Usage example:
 * let buf = BgfxMemory(16u32)
 * buf.writeFloats([1.0, 2.0, 3.0, 0.0], 4)
 * bgfx_set_uniform_cj(uHandle, buf.data(), 1u16)
 */
public class BgfxMemory {
    private var mem: CPointer<Memory>

    /**
     * @brief[zh-cn] 通过 bgfx_alloc 分配内存
     * @param[zh-cn] size 分配大小（字节）
     *
     * @brief[en] Allocates memory via bgfx_alloc
     * @param[en] size Allocation size in bytes
     */
    public init(size: UInt32) {
        this.mem = unsafe { bgfx_alloc_cj(size) }
    }

    /**
     * @brief[zh-cn] 通过 bgfx_copy 分配并拷贝数据
     * @param[zh-cn] data 源数据指针
     * size 数据大小（字节）
     *
     * @brief[en] Allocates and copies data via bgfx_copy
     * @param[en] data Source data pointer
     * size Data size in bytes
     */
    public init(data: CPointer<Unit>, size: UInt32) {
        this.mem = unsafe { bgfx_copy_cj(data, size) }
    }

    /**
     * @brief[zh-cn] 私有构造（供 ref 静态工厂使用）
     * @param[zh-cn] mem bgfx Memory 指针
     *
     * @brief[en] Private constructor (used by the ref static factory)
     * @param[en] mem The bgfx Memory pointer
     */
    private init(mem: CPointer<Memory>) {
        this.mem = mem
    }

    /**
     * @brief[zh-cn] 获取原始 CPointer<Memory>（给 bgfx_create_vertex_buffer 等 API 使用）
     * @return[zh-cn] CPointer<Memory>
     *
     * @brief[en] Returns the raw CPointer<Memory> (for bgfx_create_vertex_buffer etc.)
     * @return[en] CPointer<Memory>
     */
    public func get(): CPointer<Memory> {
        return this.mem
    }

    /**
     * @brief[zh-cn] 获取数据指针（用于 bgfx_set_uniform 等 API）
     * @return[zh-cn] CPointer<UInt8>
     *
     * @brief[en] Returns the data pointer (for bgfx_set_uniform etc.)
     * @return[en] CPointer<UInt8>
     */
    public func data(): CPointer<UInt8> {
        return unsafe { this.mem.read().data }
    }

    /**
     * @brief[zh-cn] 写入 Float64 数组（转为 Float32，按 count 个元素写入）
     * @param[zh-cn] values Float64 数组
     * count 写入元素数量
     *
     * @brief[en] Writes a Float64 array (converted to Float32, up to count elements)
     * @param[en] values The Float64 array
     * count Number of elements to write
     */
    public func writeFloats(values: Array<Float64>, count: Int64): Unit {
        unsafe {
            let fPtr = CPointer<Float32>(this.mem.read().data)
            for (i in 0..count) {
                fPtr.write(i, Float32(values[i]))
            }
        }
    }

    /**
     * @brief[zh-cn] 写入 UInt16 数组（用于索引缓冲区）
     * @param[zh-cn] values UInt16 数组
     * count 写入元素数量
     *
     * @brief[en] Writes a UInt16 array (for index buffers)
     * @param[en] values The UInt16 array
     * count Number of elements to write
     */
    public func writeUInt16(values: Array<UInt16>, count: Int64): Unit {
        unsafe {
            let iPtr = CPointer<UInt16>(this.mem.read().data)
            for (i in 0..count) {
                iPtr.write(i, values[i])
            }
        }
    }

    /**
     * @brief[zh-cn] 写入 UInt8 数组
     * @param[zh-cn] values UInt8 数组
     * count 写入元素数量
     *
     * @brief[en] Writes a UInt8 array
     * @param[en] values The UInt8 array
     * count Number of elements to write
     *
     * @note[zh-cn] 用于顶点缓冲区。
     * @note[en] For vertex buffers.
     */
    public func writeUInt8(values: Array<UInt8>, count: Int64): Unit {
        unsafe {
            let bPtr = CPointer<UInt8>(this.mem.read().data)
            for (i in 0..count) {
                if (i < values.size) { bPtr.write(i, values[i]) }
            }
        }
    }

    /**
     * @brief[zh-cn] 写入单个 Float32 值到指定偏移（float 数，非字节）
     * @param[zh-cn] index 元素索引
     * value Float32 值
     *
     * @brief[en] Writes a single Float32 value at the given offset (element index, not bytes)
     * @param[en] index Element index
     * value The Float32 value
     */
    public func writeFloat(index: Int64, value: Float32): Unit {
        unsafe {
            CPointer<Float32>(this.mem.read().data).write(index, value)
        }
    }

    /**
     * @brief[zh-cn] 读取指定偏移的 Float32 值
     * @param[zh-cn] index 元素索引
     * @return[zh-cn] Float32
     *
     * @brief[en] Reads the Float32 value at the given offset
     * @param[en] index Element index
     * @return[en] Float32
     */
    public func readFloat(index: Int64): Float32 {
        return unsafe { CPointer<Float32>(this.mem.read().data).read(index) }
    }

    /**
     * @brief[zh-cn] 静态工厂：通过 bgfx_make_ref 包装已有内存
     * @param[zh-cn] data 数据指针
     * size 数据大小（字节）
     * @return[zh-cn] BgfxMemory 实例
     *
     * @brief[en] Static factory: wraps existing memory via bgfx_make_ref
     * @param[en] data Data pointer
     * size Data size in bytes
     * @return[en] A BgfxMemory instance
     *
     * @note[zh-cn] 不拷贝，不管理生命周期。
     * @note[en] Does not copy and does not manage the lifetime.
     */
    public static func ref(data: CPointer<Unit>, size: UInt32): BgfxMemory {
        return BgfxMemory(unsafe { bgfx_make_ref_cj(data, size) })
    }

    // =========================================================================
    // 瞬态缓冲 / 实例数据分配（线程安全，直接调用；瞬态缓冲每帧分配、提交后自动回收）
    // =========================================================================

    /**
     * @brief[zh-cn] 通过 bgfx_make_ref_release 包装已有内存（释放时回调）
     * @param[zh-cn] data 数据指针
     * size 数据大小（字节）
     * releaseFn 释放回调
     * userData 回调用户数据
     * @return[zh-cn] bgfx Memory 指针（CPointer，释放回调由 bgfx 在帧末调用）
     *
     * @brief[en] Wraps existing memory via bgfx_make_ref_release (with release callback)
     * @param[en] data Data pointer
     * size Data size in bytes
     * releaseFn Release callback
     * userData Callback user data
     * @return[en] bgfx Memory pointer (CPointer; the release callback is invoked by bgfx at frame end)
     */
    public static func refRelease(data: CPointer<Unit>, size: UInt32, releaseFn: ReleaseFn, userData: CPointer<Unit>): CPointer<Memory> {
        return unsafe { bgfx_make_ref_release_cj(data, size, releaseFn, userData) }
    }

    /**
     * @brief[zh-cn] bgfx_alloc_transform：分配变换矩阵内存
     * @param[zh-cn] num 矩阵数量
     * @return[zh-cn] (Transform Box 包装, cache 序号)
     *
     * @brief[en] bgfx_alloc_transform: allocates transform matrix memory
     * @param[en] num Number of matrices
     * @return[en] (Box<Transform> wrapper, cache sequence number)
     */
    public static func allocTransform(num: UInt16): (Box<Transform>, UInt32) {
        let holder = AutoFreePtr<Transform>(unsafe { LibC.malloc<Transform>() })
        let t = holder.get()
        let cache = bgfx_alloc_transform_cj(t, num)
        let result = (unsafe { Box(t.read()) }, cache)
        holder.dispose()
        return result
    }

    /**
     * @brief[zh-cn] bgfx_alloc_transient_index_buffer：分配瞬态索引缓冲
     * @param[zh-cn] num 索引数量
     * index32 是否 32bit 索引
     * @return[zh-cn] 瞬态索引缓冲（Box 包装）
     *
     * @brief[en] bgfx_alloc_transient_index_buffer: allocates a transient index buffer
     * @param[en] num Number of indices
     * index32 Whether to use 32-bit indices
     * @return[en] The transient index buffer (Box-wrapped)
     */
    public static func allocTransientIndexBuffer(num: UInt32, index32: Bool): Box<TransientIndexBuffer> {
        let holder = AutoFreePtr<TransientIndexBuffer>(unsafe { LibC.malloc<TransientIndexBuffer>() })
        let tib = holder.get()
        bgfx_alloc_transient_index_buffer_cj(tib, num, index32)
        let result = unsafe { Box(tib.read()) }
        holder.dispose()
        return result
    }

    /**
     * @brief[zh-cn] bgfx_alloc_transient_vertex_buffer：分配瞬态顶点缓冲
     * @param[zh-cn] num 顶点数量
     * layout 顶点布局指针（由调用方 malloc）
     * @return[zh-cn] 瞬态顶点缓冲（Box 包装）
     *
     * @brief[en] bgfx_alloc_transient_vertex_buffer: allocates a transient vertex buffer
     * @param[en] num Number of vertices
     * layout Vertex layout pointer (malloced by the caller)
     * @return[en] The transient vertex buffer (Box-wrapped)
     */
    public static func allocTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): Box<TransientVertexBuffer> {
        let holder = AutoFreePtr<TransientVertexBuffer>(unsafe { LibC.malloc<TransientVertexBuffer>() })
        let tvb = holder.get()
        bgfx_alloc_transient_vertex_buffer_cj(tvb, num, layout.value)
        let result = unsafe { Box(tvb.read()) }
        holder.dispose()
        return result
    }

    /**
     * @brief[zh-cn] bgfx_alloc_transient_buffers：同时分配瞬态顶点+索引缓冲
     * @param[zh-cn] layout 顶点布局指针
     * numVertices 顶点数量
     * numIndices 索引数量
     * index32 是否 32bit 索引
     * @return[zh-cn] (TransientVertexBuffer, TransientIndexBuffer, 是否成功)
     *
     * @brief[en] bgfx_alloc_transient_buffers: allocates both transient vertex and index buffers
     * @param[en] layout Vertex layout pointer
     * numVertices Number of vertices
     * numIndices Number of indices
     * index32 Whether to use 32-bit indices
     * @return[en] (TransientVertexBuffer, TransientIndexBuffer, whether successful)
     */
    public static func allocTransientBuffers(
        layout: CPointer<VertexLayout>,
        numVertices: UInt32,
        numIndices: UInt32,
        index32: Bool
    ): (Box<TransientVertexBuffer>, Box<TransientIndexBuffer>, Bool) {
        let tvbHolder = AutoFreePtr<TransientVertexBuffer>(unsafe { LibC.malloc<TransientVertexBuffer>() })
        let tibHolder = AutoFreePtr<TransientIndexBuffer>(unsafe { LibC.malloc<TransientIndexBuffer>() })
        let ok = bgfx_alloc_transient_buffers_cj(tvbHolder.get(), layout, numVertices, tibHolder.get(), numIndices, index32)
        let result = (unsafe { Box(tvbHolder.get().read()) }, unsafe { Box(tibHolder.get().read()) }, ok)
        tvbHolder.dispose()
        tibHolder.dispose()
        return result
    }

    /**
     * @brief[zh-cn] bgfx_alloc_instance_data_buffer：分配实例数据缓冲
     * @param[zh-cn] num 实例数量
     * stride 每实例步长（字节）
     * @return[zh-cn] 实例数据缓冲（Box 包装）
     *
     * @brief[en] bgfx_alloc_instance_data_buffer: allocates an instance data buffer
     * @param[en] num Number of instances
     * stride Per-instance stride in bytes
     * @return[en] The instance data buffer (Box-wrapped)
     */
    public static func allocInstanceDataBuffer(num: UInt32, stride: UInt16): Box<InstanceDataBuffer> {
        let holder = AutoFreePtr<InstanceDataBuffer>(unsafe { LibC.malloc<InstanceDataBuffer>() })
        let idb = holder.get()
        bgfx_alloc_instance_data_buffer_cj(idb, num, stride)
        let result = unsafe { Box(idb.read()) }
        holder.dispose()
        return result
    }

    /**
     * @brief[zh-cn] 查询可用瞬态索引缓冲量（bgfx_get_avail_transient_index_buffer）
     * @param[zh-cn] num 请求数量
     * index32 是否 32bit 索引
     * @return[zh-cn] 可用数量
     *
     * @brief[en] Queries the available transient index buffer space (bgfx_get_avail_transient_index_buffer)
     * @param[en] num Requested count
     * index32 Whether to use 32-bit indices
     * @return[en] The available count
     */
    public static func getAvailTransientIndexBuffer(num: UInt32, index32: Bool): UInt32 {
        return bgfx_get_avail_transient_index_buffer_cj(num, index32)
    }

    /**
     * @brief[zh-cn] 查询可用瞬态顶点缓冲量（bgfx_get_avail_transient_vertex_buffer）
     * @param[zh-cn] num 请求数量
     * layout 顶点布局指针
     * @return[zh-cn] 可用数量
     *
     * @brief[en] Queries the available transient vertex buffer space (bgfx_get_avail_transient_vertex_buffer)
     * @param[en] num Requested count
     * layout Vertex layout pointer
     * @return[en] The available count
     */
    public static func getAvailTransientVertexBuffer(num: UInt32, layout: VertexLayoutPtr): UInt32 {
        return bgfx_get_avail_transient_vertex_buffer_cj(num, layout.value)
    }

    /**
     * @brief[zh-cn] 查询可用实例数据缓冲量（bgfx_get_avail_instance_data_buffer）
     * @param[zh-cn] num 请求数量
     * stride 每实例步长（字节）
     * @return[zh-cn] 可用数量
     *
     * @brief[en] Queries the available instance data buffer space (bgfx_get_avail_instance_data_buffer)
     * @param[en] num Requested count
     * stride Per-instance stride in bytes
     * @return[en] The available count
     */
    public static func getAvailInstanceDataBuffer(num: UInt32, stride: UInt16): UInt32 {
        return bgfx_get_avail_instance_data_buffer_cj(num, stride)
    }
}
