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
 * @file[zh-cn] IGfxEncoder 多线程提交器抽象接口
 * @brief[zh-cn] 渲染后端多线程提交的抽象形态（每线程一个提交器实例）
 * @explain[zh-cn] 约定：
 * - 一个 encoder 实例同一时刻仅可被一个线程使用（由实现断言）；
 * - 实例经 IRenderBackend.acquireEncoder/releaseEncoder 获取与归还，
 *   begin/end 生命周期由后端实现管理；
 * - 本接口 internal：引擎全部子包可见、模块外不可见；引擎外的多线程
 *   提交需求走 ThreeRenderer.runOnRenderThread 逃生舱。
 *
 * @file[en] IGfxEncoder multi-threaded encoder abstraction interface
 * @brief[en] The abstraction of multi-threaded backend submission (one encoder instance per thread)
 * @explain[en] Conventions:
 * - One encoder instance may be used by only one thread at a time (asserted by
 *   the implementation);
 * - Instances are acquired/released via IRenderBackend.acquireEncoder/
 *   releaseEncoder; the begin/end lifecycle is managed by the backend;
 * - This interface is internal: visible to all engine subpackages and invisible
 *   outside the module; external multi-threaded submission needs go through the
 *   ThreeRenderer.runOnRenderThread escape hatch.
 *
 * @package three
 */
protected package three.renderers._interfaces

import three.renderers._gfx.*
import three.utils.memory.PtrArray

public interface IGfxEncoder {
    /** 设置调试标记。 */
    func setMarker(name: String): Unit

    /** 设置 per-draw 渲染状态位域。 */
    func setState(state: UInt64, rgba!: UInt32): Unit

    /** 设置 per-draw 模板状态（前/后面位域）。 */
    func setStencil(fstencil: UInt32, bstencil: UInt32): Unit

    /** 设置 per-draw 裁剪矩形；返回可复用的缓存序号。 */
    func setScissor(x: UInt16, y: UInt16, w: UInt16, h: UInt16): UInt16

    /** 复用缓存的裁剪矩形。 */
    func setScissorCached(cache: UInt16): Unit

    /** 设置模型变换矩阵（列主序 16 元素 Float32；num>1 为实例化批量）；返回缓存序号。 */
    func setTransform(mtx: PtrArray<Float32>, num!: UInt16): UInt32

    /** 复用缓存的变换矩阵。 */
    func setTransformCached(cache: UInt32, num!: UInt16): Unit

    /** 预分配变换矩阵存储（直写通道，绕过 Float64→Float32 转换）；返回 (缓存序号, 矩阵存储)。 */
    func allocTransform(num: UInt16): (UInt32, PtrArray<Float32>)

    /** 设置 uniform 数据（Float32 数组；按 uniform 类型解释）。 */
    func setUniform(h: GfxUniformHandle, data: PtrArray<Float32>, num!: UInt16): Unit

    /** 绑定静态索引缓冲。 */
    func setIndexBuffer(ib: GfxIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit

    /** 绑定动态索引缓冲。 */
    func setDynamicIndexBuffer(ib: GfxDynamicIndexBufferHandle, firstIndex!: UInt32, numIndices!: UInt32): Unit

    /** 绑定静态顶点缓冲（无布局）。 */
    func setVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, startVertex!: UInt32, numVertices!: UInt32): Unit

    /** 绑定静态顶点缓冲（带布局）。 */
    func setVertexBufferWithLayout(stage: UInt8, vb: GfxVertexBufferHandle, layout: GfxVertexLayoutHandle,
        startVertex!: UInt32, numVertices!: UInt32): Unit

    /** 绑定动态顶点缓冲。 */
    func setDynamicVertexBuffer(stage: UInt8, vb: GfxDynamicVertexBufferHandle, startVertex!: UInt32,
        numVertices!: UInt32): Unit

    /** 设置顶点计数（无顶点缓冲模式）。 */
    func setVertexCount(numVertices: UInt32): Unit

    /** 设置实例计数。 */
    func setInstanceCount(numInstances: UInt32): Unit

    /** 绑定纹理到采样器槽。 */
    func setTexture(stage: UInt8, sampler: GfxUniformHandle, tex: GfxTextureHandle, flags: UInt32): Unit

    /** 绑定图像（计算着色器读写）。 */
    func setImage(stage: UInt8, tex: GfxTextureHandle, mip: UInt8, access: GfxAccess, format: GfxTextureFormat): Unit

    /** 绑定计算索引缓冲。 */
    func setComputeIndexBuffer(stage: UInt8, ib: GfxIndexBufferHandle, access: GfxAccess): Unit

    /** 绑定计算顶点缓冲。 */
    func setComputeVertexBuffer(stage: UInt8, vb: GfxVertexBufferHandle, access: GfxAccess): Unit

    /** 提交当前 draw 到视图。 */
    func submit(viewId: UInt16, program: GfxProgramHandle, depth!: UInt32, blend!: UInt8): Unit

    /** 提交间接绘制。 */
    func submitIndirect(viewId: UInt16, program: GfxProgramHandle, indirect: GfxIndirectBufferHandle, start: UInt32,
        num: UInt32, depth!: UInt32, blend!: UInt8): Unit

    /** 提交计算调度。 */
    func dispatch(viewId: UInt16, program: GfxProgramHandle, numX: UInt32, numY: UInt32, numZ: UInt32, flags!: UInt8): Unit

    /** 纹理拷贝（整图区域）。 */
    func blit(viewId: UInt16, dst: GfxTextureHandle, src: GfxTextureHandle, w: UInt16, h: UInt16): Unit

    /** 触发视图空提交。 */
    func touch(viewId: UInt16): Unit

    /** 丢弃当前 draw 的指定状态组。 */
    func discard(flags: UInt8): Unit
}
