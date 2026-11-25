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
 * @file[zh-cn] BgfxBackendGfxResources 后端抽象接口实现（资源域）
 * @brief[zh-cn] BgfxBackend 对 IRenderBackend 域 3-6 的实现（纹理/帧缓冲/缓冲与布局/着色器程序 uniform）
 * @explain[zh-cn] 数据承载约定：资源初始/更新数据以 PtrArray<UInt8>（借用视图）传入，
 * 经 gfxCopyRef 以 bgfx_copy 立即拷贝进 bgfx 自管内存（当帧有效），源视图随后即可
 * 被回收——避免 bgfx_make_ref 零拷贝引用调用方局部内存、在其被 GC 回收后读到全 0
 * 的缺陷（曾导致全屏 quad 顶点归零、后处理全黑）；顶点布局的宿主内存由包级
 * GfxLayoutPtrRegistry 按 idx 登记，供创建顶点缓冲时查回布局指针、销毁布局时释放。
 *
 * @file[en] BgfxBackendGfxResources backend abstraction interface implementation (resource domains)
 * @brief[en] BgfxBackend's implementation of IRenderBackend domains 3-6 (textures / frame buffers / buffers & layouts / shaders-programs-uniforms)
 * @explain[en] Data convention: resource initial/update data arrives as PtrArray<UInt8>
 * (a borrowed view) and is copied immediately into bgfx-owned frame-scoped memory via
 * gfxCopyRef (bgfx_copy), so the source view may be reclaimed right after the call.
 * This avoids the bgfx_make_ref zero-copy pitfall of referencing caller-local memory
 * that the GC recycles afterward, leaving bgfx reading all zeros (once collapsed the
 * full-screen quad to the origin and blanked all post-processing). The host memory of
 * vertex layouts is registered by idx in the package-level GfxLayoutPtrRegistry, for
 * layout-pointer lookup at vertex buffer creation and release at layout destruction.
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import std.collection.HashMap
import three._vendor.bgfx4cj.bgfx as bgfx
import three._vendor.bgfx4cj.bx.*
import three.renderers._gfx.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray
import three.utils.memory.VoidPtr

// ============================================================================
// ===== 资源域辅助 =====
// ============================================================================

/**
 * @brief[zh-cn] 把字节视图拷贝进 bgfx 自管内存并返回 Memory 指针
 * @explain[zh-cn] bgfx_copy 语义：bgfx 立即拷贝一份数据到自管内存（本帧内有效），
 * 源 PtrArray 随后即可被回收。所有接受 PtrArray<UInt8> 的资源接口（顶点/索引缓冲、
 * 纹理创建与更新、动态缓冲更新、着色器创建）均走此路径，因为源视图多为调用方
 * 局部对象、生命周期无法覆盖到 bgfx 消费时刻。曾用 bgfx_make_ref（零拷贝）引用
 * 局部 PtrArray，ensureResources 返回后其被 GC 回收，bgfx 侧读到的顶点数据变为 0
 * → 全屏 quad 顶点全部退化为原点 → 不覆盖任何像素 → 后处理全屏 pass 黑屏。
 * 空视图返回空指针（bgfx 语义：null mem = 无初始数据）。
 *
 * @brief[en] Copies a byte view into bgfx-owned memory and returns a Memory pointer
 * @explain[en] bgfx_copy semantics: bgfx immediately copies the data into its own
 * frame-scoped memory, so the source PtrArray may be reclaimed afterward. Every
 * resource API that accepts a PtrArray<UInt8> (vertex/index buffers, texture
 * creation & updates, dynamic buffer updates, shader creation) uses this path,
 * because the source view is usually a caller-local object whose lifetime cannot be
 * guaranteed to cover the moment bgfx consumes it. The previous bgfx_make_ref
 * (zero copy) referenced such a local PtrArray that was GC-reclaimed right after
 * ensureResources returned, so bgfx read zeroed vertex data → the full-screen quad
 * collapsed to the origin → covered no pixels → black full-screen post passes.
 * An empty view returns a null pointer.
 */
internal func gfxCopyRef(data: PtrArray<UInt8>): CPointer<bgfx.Memory> {
    if (data.size() <= 0) {
        return CPointer<bgfx.Memory>()
    }
    BgfxMemory(unsafe { CPointer<Unit>(data.data()) }, UInt32(data.size())).get()
}

/**
 * @brief[zh-cn] 顶点布局宿主内存登记表
 * @explain[zh-cn] createVertexLayout 的布局描述内存（begin/add/end 构建产物）按
 * 布局句柄 idx 登记：创建顶点缓冲时按 idx 查回 CPointer<VertexLayout>（bgfx
 * 创建 VB 需要布局内存指针而非句柄），销毁布局时释放。仅命令线程访问
 * （全部操作都在 gfxBackendExec 闭包内），无须加锁。bgfx 布局句柄空间是进程级
 * 的，故登记表为包级单例。
 *
 * @brief[en] Vertex layout host-memory registry
 * @explain[en] The layout descriptor memory built by begin/add/end is registered by
 * layout handle idx: vertex buffer creation looks up CPointer<VertexLayout> by idx
 * (bgfx VB creation needs the layout memory pointer, not the handle), and layout
 * destruction releases it. Accessed only from the command thread (all operations
 * sit inside gfxBackendExec closures), so no lock is needed. The bgfx layout handle
 * space is process-wide, hence the registry is a package-level singleton.
 */
internal class GfxLayoutPtrRegistry {
    private var ptrs = HashMap<Int64, AutoFreePtr<bgfx.VertexLayout>>()

    internal func get(idx: Int64): Option<AutoFreePtr<bgfx.VertexLayout>> {
        ptrs.get(idx)
    }

    internal func put(idx: Int64, holder: AutoFreePtr<bgfx.VertexLayout>): Unit {
        ptrs.add(idx, holder)
    }

    internal func remove(idx: Int64): Unit {
        ptrs.remove(idx)
    }
}

internal let gfxLayoutPtrs = GfxLayoutPtrRegistry()

// ============================================================================
// ===== 域 3：纹理与采样 =====
// ============================================================================

extend BgfxBackend {
    /** 创建 2D 纹理；data 为 None 表示空渲染目标纹理。 */
    public func createTexture2D(w: UInt16, h: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        let resultBox: Box<GfxTextureHandle> = Box(GfxTextureHandle.INVALID)
        let dataRef = data
        gfxBackendExec.execSync(
            {
                =>
                    let memPtr = match (dataRef) {
                        case Some(p) => gfxCopyRef(p)
                        case None => CPointer<bgfx.Memory>()
                    }
                    resultBox.value = GfxTextureHandle(
                        bgfx.bgfx_create_texture_2d_cj(w, h, hasMips, numLayers, toBgfx(format).value(), flags, memPtr)
                            .idx)
            }
        )
        return resultBox.value
    }

    /** 创建与后缓冲成比例的 2D 纹理。 */
    public func createTexture2DScaled(ratio: GfxBackbufferRatio, hasMips: Bool, numLayers: UInt16,
        format: GfxTextureFormat, flags: UInt64): GfxTextureHandle {
        let resultBox: Box<GfxTextureHandle> = Box(GfxTextureHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxTextureHandle(
                bgfx
                    .bgfx_create_texture_2d_scaled_cj(toBgfx(ratio).value(), hasMips, numLayers, toBgfx(format).value(),
                        flags)
                    .idx)
        })
        return resultBox.value
    }

    /** 创建 3D 纹理。 */
    public func createTexture3D(w: UInt16, h: UInt16, depth: UInt16, hasMips: Bool, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        let resultBox: Box<GfxTextureHandle> = Box(GfxTextureHandle.INVALID)
        let dataRef = data
        gfxBackendExec.execSync(
            {
                =>
                    let memPtr = match (dataRef) {
                        case Some(p) => gfxCopyRef(p)
                        case None => CPointer<bgfx.Memory>()
                    }
                    resultBox.value = GfxTextureHandle(
                        bgfx.bgfx_create_texture_3d_cj(w, h, depth, hasMips, toBgfx(format).value(), flags, memPtr).idx)
            }
        )
        return resultBox.value
    }

    /** 创建立方体纹理（6 面连续数据）。 */
    public func createTextureCube(side: UInt16, hasMips: Bool, numLayers: UInt16, format: GfxTextureFormat,
        flags: UInt64, data: Option<PtrArray<UInt8>>): GfxTextureHandle {
        let resultBox: Box<GfxTextureHandle> = Box(GfxTextureHandle.INVALID)
        let dataRef = data
        gfxBackendExec.execSync(
            {
                =>
                    let memPtr = match (dataRef) {
                        case Some(p) => gfxCopyRef(p)
                        case None => CPointer<bgfx.Memory>()
                    }
                    resultBox.value = GfxTextureHandle(
                        bgfx
                            .bgfx_create_texture_cube_cj(side, hasMips, numLayers, toBgfx(format).value(), flags, memPtr)
                            .idx)
            }
        )
        return resultBox.value
    }

    /** 更新 2D 纹理子区域。 */
    public func updateTexture2D(tex: GfxTextureHandle, layer: UInt16, mip: UInt8, x: UInt16, y: UInt16, width: UInt16,
        height: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_update_texture_2d_cj(toBgfx(tex), layer, mip, x, y, width, height, gfxCopyRef(data), pitch)
        })
    }

    /** 更新 3D 纹理子区域。 */
    public func updateTexture3D(tex: GfxTextureHandle, mip: UInt8, x: UInt16, y: UInt16, z: UInt16, width: UInt16,
        height: UInt16, depth: UInt16, data: PtrArray<UInt8>): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_update_texture_3d_cj(toBgfx(tex), mip, x, y, z, width, height, depth, gfxCopyRef(data))
        })
    }

    /** 更新立方体纹理面子区域。 */
    public func updateTextureCube(tex: GfxTextureHandle, layer: UInt16, side: UInt8, mip: UInt8, x: UInt16, y: UInt16,
        width: UInt16, height: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_update_texture_cube_cj(toBgfx(tex), layer, side, mip, x, y, width, height, gfxCopyRef(data),
                pitch)
        })
    }

    /** 销毁纹理。 */
    public func destroyTexture(tex: GfxTextureHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_texture_cj(toBgfx(tex))})
    }

    /** 纹理拷贝（整图区域）。 */
    public func blitTexture(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, width: UInt16, height: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_blit_cj(viewId, toBgfx(dst), 0u8, 0u16, 0u16, 0u16, toBgfx(src), 0u8, 0u16, 0u16, 0u16, width,
                height, 1u16)
        })
    }

    /** 异步回读纹理到 CPU 缓冲；返回数据就绪的帧序号（此后才可安全读 out）。 */
    public func readTexture(tex: GfxTextureHandle, out: PtrArray<UInt8>, mip!: UInt8): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        let outRef = out
        gfxBackendExec.execSync(
            {
                =>
                    // 以 TextureRegion 描述源区域（mip 参数化、区域取整图）
                    let regionHolder = AutoFreePtr<bgfx.TextureRegion>(unsafe { LibC.malloc<bgfx.TextureRegion>() })
                    let region = regionHolder.get()
                    bgfx.bgfx_texture_region_init_cj(region, toBgfx(tex), 0u16, 0u16, 0u16, 0u16)
                    var regionVal = unsafe { region.read() }
                    regionVal.mip = mip
                    unsafe { region.write(regionVal) }
                    resultBox.value = bgfx.bgfx_read_texture_cj(region, unsafe { CPointer<Unit>(outRef.data()) })
                    regionHolder.dispose()
            }
        )
        return resultBox.value
    }

    /** 查询纹理参数组合是否有效（创建前预检）。 */
    public func isTextureValid(depth: UInt16, cubeMap: Bool, numLayers: UInt16, format: GfxTextureFormat, flags: UInt64): Bool {
        let resultBox: Box<Bool> = Box(false)
        gfxBackendExec.execSync({
            => resultBox.value = bgfx.bgfx_is_texture_valid_cj(depth, cubeMap, numLayers, toBgfx(format).value(), flags)
        })
        return resultBox.value
    }

    /** 计算纹理存储信息；返回 (storageSize, width, height, depth, numMips)。 */
    public func calcTextureSize(width: UInt16, height: UInt16, depth: UInt16, cubeMap: Bool, hasMips: Bool,
        numLayers: UInt16, format: GfxTextureFormat): (UInt32, UInt32, UInt32, UInt32, UInt32) {
        let resultBox: Box<(UInt32, UInt32, UInt32, UInt32, UInt32)> = Box((0u32, 0u32, 0u32, 0u32, 0u32))
        gfxBackendExec.execSync(
            {
                =>
                    let infoHolder = AutoFreePtr<bgfx.TextureInfo>(unsafe { LibC.malloc<bgfx.TextureInfo>() })
                    bgfx.bgfx_calc_texture_size_cj(infoHolder.get(), width, height, depth, cubeMap, hasMips, numLayers,
                        toBgfx(format).value())
                    let info = unsafe { infoHolder.get().read() }
                    resultBox.value = (info.storageSize, UInt32(info.width), UInt32(info.height), UInt32(info.depth),
                        UInt32(info.numMips))
                    infoHolder.dispose()
            }
        )
        return resultBox.value
    }

    /** 取帧缓冲某附着位的纹理句柄。 */
    public func getTextureFromFrameBuffer(fb: GfxFrameBufferHandle, attachment: UInt8): GfxTextureHandle {
        let resultBox: Box<GfxTextureHandle> = Box(GfxTextureHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxTextureHandle(bgfx.bgfx_get_texture_cj(toBgfx(fb), attachment).idx)
        })
        return resultBox.value
    }

    /** 设置纹理调试名称。 */
    public func setTextureName(tex: GfxTextureHandle, name: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_set_texture_name_cj(toBgfx(tex), cName, Int32(name.size))
                    cNameHolder.dispose()
            }
        )
    }

    // ========================================================================
    // ===== 域 4：帧缓冲 =====
    // ========================================================================

    /** 由宽高与格式创建帧缓冲（含深度附着）。 */
    public func createFrameBuffer(w: UInt16, h: UInt16, format: GfxTextureFormat, depthFlags: UInt64): GfxFrameBufferHandle {
        let resultBox: Box<GfxFrameBufferHandle> = Box(GfxFrameBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxFrameBufferHandle(
                bgfx.bgfx_create_frame_buffer_cj(w, h, toBgfx(format).value(), depthFlags).idx)
        })
        return resultBox.value
    }

    /** 由既有纹理句柄列表创建帧缓冲；destroyHandles 决定销毁时是否级联销毁纹理。 */
    public func createFrameBufferFromHandles(handles: Array<GfxTextureHandle>, destroyHandles: Bool): GfxFrameBufferHandle {
        let resultBox: Box<GfxFrameBufferHandle> = Box(GfxFrameBufferHandle.INVALID)
        let handlesRef = handles
        gfxBackendExec.execSync(
            {
                =>
                    // 构造连续内存的 bgfx TextureHandle 数组（attachment 顺序对应索引）
                    let holder = AutoFreePtr<bgfx.TextureHandle>(
                        unsafe { LibC.malloc<bgfx.TextureHandle>(count: Int64(handlesRef.size)) })
                    for (i in 0..handlesRef.size) {
                        unsafe { (holder.get() + i).write(0, toBgfx(handlesRef[i])) }
                    }
                    resultBox.value = GfxFrameBufferHandle(
                        bgfx
                            .bgfx_create_frame_buffer_from_handles_cj(UInt8(handlesRef.size), holder.get(),
                                destroyHandles)
                            .idx)
                    holder.dispose()
            }
        )
        return resultBox.value
    }

    /** 创建与后缓冲成比例的帧缓冲。 */
    public func createFrameBufferScaled(ratio: GfxBackbufferRatio, format: GfxTextureFormat, textureFlags: UInt64): GfxFrameBufferHandle {
        let resultBox: Box<GfxFrameBufferHandle> = Box(GfxFrameBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxFrameBufferHandle(
                bgfx.bgfx_create_frame_buffer_scaled_cj(toBgfx(ratio).value(), toBgfx(format).value(), textureFlags).idx)
        })
        return resultBox.value
    }

    /** 由平台窗口句柄创建帧缓冲（多窗口/离屏交换链）；depthFormat 为深度附着格式。 */
    public func createFrameBufferFromNwh(nwh: VoidPtr, w: UInt16, h: UInt16, format: GfxTextureFormat,
        depthFormat: GfxTextureFormat): GfxFrameBufferHandle {
        let resultBox: Box<GfxFrameBufferHandle> = Box(GfxFrameBufferHandle.INVALID)
        gfxBackendExec.execSync(
            {
                =>
                    let descHolder = AutoFreePtr<bgfx.SwapChain>(unsafe { LibC.malloc<bgfx.SwapChain>() })
                    let desc = descHolder.get()
                    unsafe { desc.write(bgfx.SwapChain()) }
                    var sc = unsafe { desc.read() }
                    sc.nwh = nwh.value
                    sc.width = UInt32(w)
                    sc.height = UInt32(h)
                    sc.formatColor = toBgfx(format).value()
                    sc.formatDepthStencil = toBgfx(depthFormat).value()
                    unsafe { desc.write(sc) }
                    resultBox.value = GfxFrameBufferHandle(bgfx.bgfx_create_frame_buffer_from_swap_chain_cj(desc).idx)
                    descHolder.dispose()
            }
        )
        return resultBox.value
    }

    /** 销毁帧缓冲。 */
    public func destroyFrameBuffer(fb: GfxFrameBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_frame_buffer_cj(toBgfx(fb))})
    }

    /** 查询附着组合是否有效。 */
    public func isFrameBufferValid(attachments: Array<GfxAttachmentDesc>): Bool {
        let resultBox: Box<Bool> = Box(false)
        let attachmentsRef = attachments
        gfxBackendExec.execSync(
            {
                =>
                    let num = UInt8(attachmentsRef.size)
                    let holder = AutoFreePtr<bgfx.Attachment>(
                        unsafe { LibC.malloc<bgfx.Attachment>(count: Int64(num)) })
                    for (i in 0..Int64(num)) {
                        let d = attachmentsRef[i]
                        unsafe {
                            bgfx.bgfx_attachment_init_cj(holder.get() + i, toBgfx(d.texture), toBgfx(d.access).value(),
                                d.layer, d.numLayers, UInt16(d.mip), flags: d.resolve)
                        }
                    }
                    resultBox.value = bgfx.bgfx_is_frame_buffer_valid_cj(num, holder.get())
                    holder.dispose()
            }
        )
        return resultBox.value
    }

    /** 设置帧缓冲调试名称。 */
    public func setFrameBufferName(fb: GfxFrameBufferHandle, name: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_set_frame_buffer_name_cj(toBgfx(fb), cName, Int32(name.size))
                    cNameHolder.dispose()
            }
        )
    }

    // ========================================================================
    // ===== 域 5：缓冲与布局 =====
    // ========================================================================

    /** 由属性描述列表创建声明式顶点布局（begin → add×N → end → create 序列）。 */
    public func createVertexLayout(attributes: Array<GfxAttributeDesc>): GfxVertexLayoutHandle {
        let resultBox: Box<GfxVertexLayoutHandle> = Box(GfxVertexLayoutHandle.INVALID)
        gfxBackendExec.execSync(
            {
                =>
                    let layoutHolder = AutoFreePtr<bgfx.VertexLayout>(unsafe { LibC.malloc<bgfx.VertexLayout>() })
                    let layout = layoutHolder.get()
                    bgfx.bgfx_vertex_layout_begin_cj(layout, bgfx.RendererType.Noop.value())
                    for (attr in attributes) {
                        bgfx.bgfx_vertex_layout_add_cj(layout, toBgfx(attr.attrib).value(), attr.num,
                            toBgfx(attr.attribType).value(), attr.normalized, attr.asInt)
                    }
                    bgfx.bgfx_vertex_layout_end_cj(layout)
                    let handle = bgfx.bgfx_create_vertex_layout_cj(layout)
                    resultBox.value = GfxVertexLayoutHandle(handle.idx)
                    // 保存布局宿主内存，供 destroyVertexLayout 释放与 createVertexBuffer 查回
                    gfxLayoutPtrs.put(Int64(handle.idx), layoutHolder)
            }
        )
        return resultBox.value
    }

    /** 销毁顶点布局并释放其宿主内存。 */
    public func destroyVertexLayout(layout: GfxVertexLayoutHandle): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    bgfx.bgfx_destroy_vertex_layout_cj(toBgfx(layout))
                    if (let Some(holder) <- gfxLayoutPtrs.get(Int64(layout.idx))) {
                        holder.dispose()
                    }
                    gfxLayoutPtrs.remove(Int64(layout.idx))
            }
        )
    }

    /** 创建静态顶点缓冲（布局经 createVertexLayout 创建）。 */
    public func createVertexBuffer(layout: GfxVertexLayoutHandle, data: PtrArray<UInt8>, flags: UInt16): GfxVertexBufferHandle {
        let resultBox: Box<GfxVertexBufferHandle> = Box(GfxVertexBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => match (gfxLayoutPtrs.get(Int64(layout.idx))) {
                case Some(holder) => resultBox.value = GfxVertexBufferHandle(
                    bgfx.bgfx_create_vertex_buffer_cj(gfxCopyRef(data), holder.get(), flags).idx)
                case None => resultBox.value = GfxVertexBufferHandle.INVALID
            }
        })
        return resultBox.value
    }

    /** 创建静态索引缓冲。 */
    public func createIndexBuffer(data: PtrArray<UInt8>, flags: UInt16): GfxIndexBufferHandle {
        let resultBox: Box<GfxIndexBufferHandle> = Box(GfxIndexBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxIndexBufferHandle(bgfx.bgfx_create_index_buffer_cj(gfxCopyRef(data), flags).idx)
        })
        return resultBox.value
    }

    /** 销毁静态顶点缓冲。 */
    public func destroyVertexBuffer(vb: GfxVertexBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_vertex_buffer_cj(toBgfx(vb))})
    }

    /** 销毁静态索引缓冲。 */
    public func destroyIndexBuffer(ib: GfxIndexBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_index_buffer_cj(toBgfx(ib))})
    }

    /** 创建动态顶点缓冲（容量按顶点数，数据由 update 填充）。 */
    public func createDynamicVertexBuffer(num: UInt32, layout: GfxVertexLayoutHandle, flags: UInt16): GfxDynamicVertexBufferHandle {
        let resultBox: Box<GfxDynamicVertexBufferHandle> = Box(GfxDynamicVertexBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => match (gfxLayoutPtrs.get(Int64(layout.idx))) {
                case Some(holder) => resultBox.value = GfxDynamicVertexBufferHandle(
                    bgfx.bgfx_create_dynamic_vertex_buffer_cj(num, holder.get(), flags).idx)
                case None => resultBox.value = GfxDynamicVertexBufferHandle.INVALID
            }
        })
        return resultBox.value
    }

    /** 更新动态顶点缓冲（自 startVertex 起）。 */
    public func updateDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle, startVertex: UInt32, data: PtrArray<UInt8>): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_update_dynamic_vertex_buffer_cj(toBgfx(h), startVertex, gfxCopyRef(data))
        })
    }

    /** 销毁动态顶点缓冲。 */
    public func destroyDynamicVertexBuffer(h: GfxDynamicVertexBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_dynamic_vertex_buffer_cj(toBgfx(h))})
    }

    /** 创建动态索引缓冲（容量按索引数）。 */
    public func createDynamicIndexBuffer(num: UInt32, flags: UInt16): GfxDynamicIndexBufferHandle {
        let resultBox: Box<GfxDynamicIndexBufferHandle> = Box(GfxDynamicIndexBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxDynamicIndexBufferHandle(bgfx.bgfx_create_dynamic_index_buffer_cj(num, flags).idx)
        })
        return resultBox.value
    }

    /** 更新动态索引缓冲（自 startIndex 起）。 */
    public func updateDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle, startIndex: UInt32, data: PtrArray<UInt8>): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_update_dynamic_index_buffer_cj(toBgfx(h), startIndex, gfxCopyRef(data))
        })
    }

    /** 销毁动态索引缓冲。 */
    public func destroyDynamicIndexBuffer(h: GfxDynamicIndexBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_dynamic_index_buffer_cj(toBgfx(h))})
    }

    /** 创建间接绘制缓冲。 */
    public func createIndirectBuffer(num: UInt32): GfxIndirectBufferHandle {
        let resultBox: Box<GfxIndirectBufferHandle> = Box(GfxIndirectBufferHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxIndirectBufferHandle(bgfx.bgfx_create_indirect_buffer_cj(num).idx)
        })
        return resultBox.value
    }

    /** 销毁间接绘制缓冲。 */
    public func destroyIndirectBuffer(h: GfxIndirectBufferHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_indirect_buffer_cj(toBgfx(h))})
    }

    // ========================================================================
    // ===== 域 6：着色器 / 程序 / uniform =====
    // ========================================================================

    /** 创建着色器（后端二进制格式数据）。 */
    public func createShader(data: PtrArray<UInt8>): GfxShaderHandle {
        let resultBox: Box<GfxShaderHandle> = Box(GfxShaderHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxShaderHandle(bgfx.bgfx_create_shader_cj(gfxCopyRef(data)).idx)
        })
        return resultBox.value
    }

    /** 销毁着色器。 */
    public func destroyShader(h: GfxShaderHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_shader_cj(toBgfx(h))})
    }

    /** 设置着色器调试名称。 */
    public func setShaderName(h: GfxShaderHandle, name: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_set_shader_name_cj(toBgfx(h), cName, Int32(name.size))
                    cNameHolder.dispose()
            }
        )
    }

    /** 反射查询着色器 uniform 列表；返回 (句柄数组, 实际数量)。 */
    public func getShaderUniforms(h: GfxShaderHandle, max: UInt16): (Array<GfxUniformHandle>, UInt16) {
        let resultBox: Box<(Array<GfxUniformHandle>, UInt16)> = Box((Array<GfxUniformHandle>(), 0u16))
        gfxBackendExec.execSync(
            {
                =>
                    let holder = AutoFreePtr<bgfx.UniformHandle>(
                        unsafe { LibC.malloc<bgfx.UniformHandle>(count: Int64(max)) })
                    let num = bgfx.bgfx_get_shader_uniforms_cj(toBgfx(h), holder.get(), max)
                    let arr = Array<GfxUniformHandle>(Int64(num), {_ => GfxUniformHandle.INVALID})
                    for (i in 0..Int64(num)) {
                        arr[i] = GfxUniformHandle(unsafe { (holder.get() + i).read() }.idx)
                    }
                    holder.dispose()
                    resultBox.value = (arr, num)
            }
        )
        return resultBox.value
    }

    /** 链接顶点+片段着色器为程序；destroyShaders 决定销毁时是否级联销毁着色器。 */
    public func createProgram(vsh: GfxShaderHandle, fsh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle {
        let resultBox: Box<GfxProgramHandle> = Box(GfxProgramHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxProgramHandle(
                bgfx.bgfx_create_program_cj(toBgfx(vsh), toBgfx(fsh), destroyShaders).idx)
        })
        return resultBox.value
    }

    /** 创建计算程序。 */
    public func createComputeProgram(csh: GfxShaderHandle, destroyShaders: Bool): GfxProgramHandle {
        let resultBox: Box<GfxProgramHandle> = Box(GfxProgramHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxProgramHandle(bgfx.bgfx_create_compute_program_cj(toBgfx(csh), destroyShaders).idx)
        })
        return resultBox.value
    }

    /** 销毁程序。 */
    public func destroyProgram(h: GfxProgramHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_program_cj(toBgfx(h))})
    }

    /** 按名称与类型创建全局 uniform。 */
    public func createUniform(name: String, uniformType: GfxUniformType, num!: UInt16): GfxUniformHandle {
        let resultBox: Box<GfxUniformHandle> = Box(GfxUniformHandle.INVALID)
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    resultBox.value = GfxUniformHandle(
                        bgfx.bgfx_create_uniform_cj(cName, toBgfx(uniformType).value(), num).idx)
                    cNameHolder.dispose()
            }
        )
        return resultBox.value
    }

    /** 销毁 uniform。 */
    public func destroyUniform(h: GfxUniformHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_uniform_cj(toBgfx(h))})
    }

    /** 反射查询 uniform 信息（名称/类型/数量）；无信息返回 None。 */
    public func getUniformInfo(h: GfxUniformHandle): Option<GfxUniformDesc> {
        let resultBox: Box<Option<GfxUniformDesc>> = Box(None)
        gfxBackendExec.execSync(
            {
                =>
                    let infoHolder = AutoFreePtr<bgfx.UniformInfo>(unsafe { LibC.malloc<bgfx.UniformInfo>() })
                    // 零初始化：绑定不返回有效性标志，无效句柄时 name 保持全 0
                    unsafe { infoHolder.get().write(bgfx.UniformInfo()) }
                    bgfx.bgfx_get_uniform_info_cj(toBgfx(h), infoHolder.get())
                    let info = unsafe { infoHolder.get().read() }
                    infoHolder.dispose()
                    // name 为 256 字节定长数组，遇 NUL 截断转字符串
                    let nameHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: 257) })
                    let np = nameHolder.get()
                    var len: Int64 = 0
                    while (len < 256) {
                        let b = info.name[len]
                        unsafe { np.write(len, b) }
                        if (b == 0u8) {
                            break
                        }
                        len += 1
                    }
                    unsafe { np.write(256, 0u8) }
                    let name = CString(np).toString()
                    nameHolder.dispose()
                    if (len == 0) {
                        resultBox.value = None
                    } else {
                        resultBox.value = Some(
                            GfxUniformDesc(name: name, uniformType: toGfx(bgfx.UniformType.fromValue(info.`type`)),
                                num: info.num))
                    }
            }
        )
        return resultBox.value
    }
}
