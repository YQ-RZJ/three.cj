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
 * @file[zh-cn] BgfxBackendGfxSubmit 后端抽象接口实现（提交/查询/调试/encoder 域）
 * @brief[zh-cn] BgfxBackend 对 IRenderBackend 域 7-9 的实现与接口 conformance 收口
 * @explain[zh-cn] 域 7（主线程提交）经命令执行器路由；域 8（查询）以值拷贝摘要
 * 结构返回（能力/统计字段全为基本类型，无指针——第二阶段指针收敛的结构承诺）；
 * 域 9（调试文本）用单向投递（纯输出型调用免跨线程往返）。文件末尾的空 conformance
 * 声明把 BgfxBackend 的 IRenderBackend 实现（分置于三个 Gfx 文件的 extend 成员）
 * 收口为接口关系。
 *
 * @file[en] BgfxBackendGfxSubmit backend abstraction interface implementation (submission/query/debug/encoder domains)
 * @brief[en] BgfxBackend's implementation of IRenderBackend domains 7-9 and the interface conformance finalization
 * @explain[en] Domain 7 (main-thread submission) routes through the command executor;
 * domain 8 (queries) returns value-copied summary structs (capability/statistics fields
 * are all primitive types with no pointers — the structural promise for the phase-two
 * pointer convergence); domain 9 (debug text) uses fire-and-forget submission (output-only
 * calls skip the cross-thread round trip). The empty conformance declaration at the end
 * of this file binds BgfxBackend's IRenderBackend implementation (the extend members
 * spread across three Gfx files) into the interface relation.
 *
 * @package three.renderers._bgfx
 */
protected package three.renderers._bgfx
import three._vendor.bgfx4cj.bgfx as bgfx
import three._vendor.bgfx4cj.bx.*
import three.renderers._gfx.*
import three.renderers._interfaces.IGfxEncoder
import three.renderers._interfaces.IRenderBackend
import three.renderers.common.IRenderPipeline
import three.utils.memory.AutoFreePtr
import three.utils.memory.PtrArray

// ============================================================================
// ===== 域 7：主线程提交（encoder0 语义路径） =====
// ============================================================================

extend BgfxBackend {
    /** 设置 per-draw 渲染状态位域（每次 submit 前需重设）。 */
    public func setState(state: UInt64, rgba!: UInt32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_state_cj(state, rgba)})
    }

    /** 设置 per-draw 模板状态（前/后面位域）。 */
    public func setStencil(fstencil: UInt32, bstencil: UInt32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_stencil_cj(fstencil, bstencil)})
    }

    /** 设置 per-draw 裁剪矩形；返回可复用的缓存序号。 */
    public func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16 {
        let resultBox: Box<UInt16> = Box(0u16)
        gfxBackendExec.execSync({
            => resultBox.value = bgfx.bgfx_set_scissor_cj(x, y, w, h)
        })
        return resultBox.value
    }

    /** 复用缓存的裁剪矩形。 */
    public func setScissorCached(cache: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_scissor_cached_cj(cache)})
    }

    /** 设置 per-draw 模型变换矩阵（列主序 16 元素；num>1 为实例化批量）。 */
    public func setTransform(matrix: PtrArray<Float32>, num!: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_transform_cj(unsafe { CPointer<Unit>(matrix.data()) }, num)
        })
    }

    /** 复用缓存的变换矩阵。 */
    public func setTransformCached(cache: UInt32, num!: UInt16): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_transform_cached_cj(cache, num)})
    }

    /** 设置 per-draw uniform 数据（浮点数组；按 uniform 类型解释）。 */
    public func setUniform(h: GfxUniformHandle, data: PtrArray<Float32>, num!: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_uniform_cj(toBgfx(h), unsafe { CPointer<Unit>(data.data()) }, num)
        })
    }

    /** 设置 per-draw 调试标记。 */
    public func setMarker(name: String): Unit {
        gfxBackendExec.execSync(
            {
                =>
                    let cName = unsafe { LibC.mallocCString(name) }
                    let cNameHolder = AutoFreePtr<UInt8>(unsafe { cName.getChars() })
                    bgfx.bgfx_set_marker_cj(cName, Int32(name.size))
                    cNameHolder.dispose()
            }
        )
    }

    /** 绑定纹理到采样器槽（flags 为 0 沿用纹理自身采样设置）。 */
    public func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_texture_cj(stage, toBgfx(sampler), toBgfx(tex), flags)
        })
    }

    /** 绑定图像（计算着色器读写）。 */
    public func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_image_cj(stage, toBgfx(tex), mip, toBgfx(access).value(), toBgfx(format).value())
        })
    }

    /** 绑定静态顶点缓冲（无布局，布局需已绑定）。 */
    public func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_vertex_buffer_cj(stage, toBgfx(vb), startVertex, numVertices)
        })
    }

    /** 绑定静态顶点缓冲（带布局）。 */
    public func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle,
        startVertex!: UInt32, numVertices!: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_vertex_buffer_with_layout_cj(stage, toBgfx(vb), startVertex, numVertices, toBgfx(layout))
        })
    }

    /** 绑定静态索引缓冲。 */
    public func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_index_buffer_cj(toBgfx(ib), firstIndex, numIndices)
        })
    }

    /** 绑定动态顶点缓冲。 */
    public func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32,
        numVertices!: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_dynamic_vertex_buffer_cj(stage, toBgfx(vb), startVertex, numVertices)
        })
    }

    /** 绑定动态索引缓冲。 */
    public func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_dynamic_index_buffer_cj(toBgfx(ib), firstIndex, numIndices)
        })
    }

    /** 设置 per-draw 实例计数。 */
    public func setInstanceCount(numInstances: UInt32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_instance_count_cj(numInstances)})
    }

    /** 设置顶点计数（无顶点缓冲模式）。 */
    public func setVertexCount(numVertices: UInt32): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_set_vertex_count_cj(numVertices)})
    }

    /** 提交当前 draw 到视图（depth 供排序，0xFF 的 blend 表示用程序默认）。 */
    public func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_submit_cj(viewId, toBgfx(program), depth, blend)
        })
    }

    /** 提交间接绘制（GPU 侧生成 draw 参数）。 */
    public func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle,
        start: UInt32, num: UInt32, depth!: UInt32, blend!: UInt8): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_submit_indirect_cj(viewId, toBgfx(program), toBgfx(indirect), start, num, depth, blend)
        })
    }

    /** 提交带遮挡查询的 draw。 */
    public func submitOcclusionQuery(viewId: UInt16, program: GfxProgramHandle, query: GfxOcclusionQueryHandle,
        depth!: UInt32, blend!: UInt8): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_submit_occlusion_query_cj(viewId, toBgfx(program), toBgfx(query), depth, blend)
        })
    }

    /** 提交计算调度。 */
    public func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32,
        flags!: UInt8): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_dispatch_cj(viewId, toBgfx(program), numX, numY, numZ, flags)
        })
    }

    /** 丢弃当前 draw 的指定状态组（性能提示）。 */
    public func discard(flags: UInt8): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_discard_cj(flags)})
    }

    /** 设置遮挡查询条件（visible 决定后续 draw 是否执行）。 */
    public func setCondition(query: GfxOcclusionQueryHandle, visible: Bool): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_set_condition_cj(toBgfx(query), visible)
        })
    }

    /** 创建遮挡查询。 */
    public func createOcclusionQuery(): GfxOcclusionQueryHandle {
        let resultBox: Box<GfxOcclusionQueryHandle> = Box(GfxOcclusionQueryHandle.INVALID)
        gfxBackendExec.execSync({
            => resultBox.value = GfxOcclusionQueryHandle(bgfx.bgfx_create_occlusion_query_cj().idx)
        })
        return resultBox.value
    }

    /** 获取遮挡查询结果（out 承载可见像素数）；返回后端状态码。 */
    public func getOcclusionQueryResult(h: GfxOcclusionQueryHandle, out: PtrArray<Int32>): UInt32 {
        let resultBox: Box<UInt32> = Box(0u32)
        let outRef = out
        gfxBackendExec.execSync({
            => resultBox.value = bgfx.bgfx_get_result_cj(toBgfx(h), outRef.data())
        })
        return resultBox.value
    }

    /** 销毁遮挡查询。 */
    public func destroyOcclusionQuery(h: GfxOcclusionQueryHandle): Unit {
        gfxBackendExec.execSync({=> bgfx.bgfx_destroy_occlusion_query_cj(toBgfx(h))})
    }

    // ========================================================================
    // ===== 域 8：查询（值拷贝摘要——第二阶段指针收敛的结构承诺） =====
    // ========================================================================

    /** 获取当前渲染后端类型。 */
    public func getRendererType(): GfxRendererType {
        let resultBox: Box<GfxRendererType> = Box(GfxRendererType.Noop)
        gfxBackendExec.execSync({
            => resultBox.value = toGfx(bgfx.RendererType.fromValue(bgfx.bgfx_get_renderer_type_cj()))
        })
        return resultBox.value
    }

    /** 获取指定类型的渲染后端名称。 */
    public func getRendererName(`type`: GfxRendererType): String {
        let resultBox: Box<String> = Box("")
        gfxBackendExec.execSync(
            {
                =>
                    let name = bgfx.bgfx_get_renderer_name_cj(toBgfx(`type`).value())
                    resultBox.value = name.toString()
            }
        )
        return resultBox.value
    }

    /** 获取当前平台支持的后端类型列表。 */
    public func getSupportedRenderers(): Array<GfxRendererType> {
        let resultBox: Box<Array<GfxRendererType>> = Box(Array<GfxRendererType>())
        gfxBackendExec.execSync(
            {
                =>
                    let holder = AutoFreePtr<UInt32>(unsafe { LibC.malloc<UInt32>(count: 16) })
                    let num = bgfx.bgfx_get_supported_renderers_cj(16u8, holder.get())
                    let arr = Array<GfxRendererType>(Int64(num), {_ => GfxRendererType.Noop})
                    for (i in 0..Int64(num)) {
                        arr[i] = toGfx(bgfx.RendererType.fromValue(unsafe { (holder.get() + i).read() }))
                    }
                    holder.dispose()
                    resultBox.value = arr
            }
        )
        return resultBox.value
    }

    /** 获取设备能力摘要（值拷贝；字段全为基本类型，无指针）。 */
    public func getCapsSummary(): GfxCapsSummary {
        let resultBox: Box<GfxCapsSummary> = Box(GfxCapsSummary(GfxRendererType.Noop))
        gfxBackendExec.execSync(
            {
                =>
                    let capsPtr = bgfx.bgfx_get_caps_cj()
                    let caps = unsafe { capsPtr.read() }
                    resultBox.value = GfxCapsSummary(toGfx(bgfx.RendererType.fromValue(caps.rendererType)),
                        vendorId: caps.vendorId, deviceId: caps.deviceId, supported: caps.supported,
                        originBottomLeft: caps.originBottomLeft, maxTextureSize: caps.limits.maxTextureSize,
                        maxViews: caps.limits.maxViews)
            }
        )
        return resultBox.value
    }

    /** 获取帧统计摘要（值拷贝；数据在下一帧前有效）。 */
    public func getStatsSummary(): GfxStatsSummary {
        let resultBox: Box<GfxStatsSummary> = Box(GfxStatsSummary())
        gfxBackendExec.execSync(
            {
                =>
                    let statsPtr = bgfx.bgfx_get_stats_cj()
                    let s = unsafe { statsPtr.read() }
                    // 原始计时为 tick 值，按计时器频率换算毫秒
                    let cpuMs = if (s.cpuTimerFreq > 0) {
                        Float64(s.cpuTimeFrame) / Float64(s.cpuTimerFreq) * 1000.0
                    } else {
                        0.0
                    }
                    let gpuMs = if (s.gpuTimerFreq > 0) {
                        Float64(s.gpuTimeEnd - s.gpuTimeBegin) / Float64(s.gpuTimerFreq) * 1000.0
                    } else {
                        0.0
                    }
                    resultBox.value = GfxStatsSummary(cpuTimeFrame: cpuMs, gpuTimeFrame: gpuMs, drawCalls: s.numDraw,
                        computeCalls: s.numCompute, blitCalls: s.numBlit, textureMemoryUsed: s.textureMemoryUsed)
            }
        )
        return resultBox.value
    }

    // ========================================================================
    // ===== 域 9：调试 =====
    // ========================================================================

    /** 清空调试文本覆盖层（纯输出型：单向投递，免跨线程往返）。 */
    public func dbgTextClear(attr: UInt8, small: Bool): Unit {
        gfxBackendExec.execAsync({=> bgfx.bgfx_dbg_text_clear_cj(attr, small)})
    }

    /** 在调试文本覆盖层打印（C 风格格式字符串；CString 分配/释放在命令线程上完成）。 */
    public func dbgTextPrintf(x: UInt16, y: UInt16, attr: UInt8, format: String): Unit {
        gfxBackendExec.execAsync(
            {
                =>
                    let cFormat = unsafe { LibC.mallocCString(format) }
                    bgfx.bgfx_dbg_text_printf_cj(x, y, attr, cFormat)
                    unsafe { LibC.free(cFormat) }
            }
        )
    }

    /** 在调试文本覆盖层绘制图像（8bit 每像素）。 */
    public func dbgTextImage(x: UInt16, y: UInt16, w: UInt16, h: UInt16, data: PtrArray<UInt8>, pitch: UInt16): Unit {
        gfxBackendExec.execSync({
            => bgfx.bgfx_dbg_text_image_cj(x, y, w, h, unsafe { CPointer<Unit>(data.data()) }, pitch)
        })
    }

    // ========================================================================
    // ===== encoder 受控获取口 =====
    // ========================================================================

    /**
     * 获取一个 encoder（forThread=true 时绑定当前线程）；同一时刻一个 encoder
     * 仅可被一个线程使用。begin 直接在调用线程执行（bgfx encoder 是官方多线程
     * 提交机制，forThread 获取即绑定线程，无须也不应经命令线程中转）。
     */
    public func acquireEncoder(forThread!: Bool): IGfxEncoder {
        BgfxEncoderGfx(bgfx.bgfx_encoder_begin_cj(forThread))
    }

    /** 归还 encoder（结束其提交序列）；与其获取线程一致。 */
    public func releaseEncoder(encoder: IGfxEncoder): Unit {
        if (let Some(e) <- (encoder as BgfxEncoderGfx)) {
            bgfx.bgfx_encoder_end_cj(e.encPtr())
        }
    }
}

// ============================================================================
// ===== 接口 conformance 收口 =====
// ============================================================================
// IRenderBackend 实现成员分置于 BgfxBackendGfx.cj（域 1-2）/
// BgfxBackendGfxResources.cj（域 3-6）/ 本文件（域 7-9 + encoder 获取口）；
// IRenderPipeline（编排契约，原 Backend 抽象基类职责）由 BgfxBackend 既有
// override 方法（beginRender/draw/finishRender/prepareShadowMap/
// bindShadowUniforms/blitShadowMap）天然满足。

extend BgfxBackend <: IRenderBackend {}

extend BgfxBackend <: IRenderPipeline {}
