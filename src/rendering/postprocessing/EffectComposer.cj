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
 * @file[zh-cn] BgfxEffectComposer 后处理 pass 链调度器
 * @brief[zh-cn] 后处理 pass 链调度器 —— 双 RT ping-pong
 * @explain[zh-cn] 设计：
 *         - 内部持两个 frame buffer（renderTarget1/renderTarget2），ping-pong 交换
 *         - passes: ArrayList<Pass>，按顺序执行 enabled 的 pass
 *         - 每个 pass.render(renderer, writeBuffer, readBuffer, deltaTime)
 *         - 若 pass.needsSwap，渲染后 swapBuffers()
 *         - 最后一个 enabled pass 自动 renderToScreen=true（结果写屏幕）
 *         用法：
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(UnrealBloomPass(strength: 1.0))
 *         composer.setSize(width, height)
 *         composer.render()  // 每帧
 *
 * @file[en] BgfxEffectComposer post-processing pass chain scheduler
 * @brief[en] Post-processing pass chain scheduler - dual RT ping-pong
 * @explain[en] Design:
 *         - Holds two internal frame buffers (renderTarget1/renderTarget2), ping-pong swapped
 *         - passes: ArrayList<Pass>, enabled passes executed in order
 *         - each pass.render(renderer, writeBuffer, readBuffer, deltaTime)
 *         - if pass.needsSwap, swapBuffers() after rendering
 *         - the last enabled pass is automatically renderToScreen=true (result written to the screen)
 *         Usage:
 *         let composer = EffectComposer(renderer)
 *         composer.addPass(RenderPass(scene, camera))
 *         composer.addPass(UnrealBloomPass(strength: 1.0))
 *         composer.setSize(width, height)
 *         composer.render()  // each frame
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.ThreeRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.types.*
import three.utils.memory.AutoFreePtr
import std.collection.*

/**
 * @brief[zh-cn] 后处理 pass 链调度器
 * @brief[en] Post-processing pass chain scheduler
 * @explain[zh-cn] 内部双 RT ping-pong，按 pass 链顺序执行。
 * @explain[en] Internal dual-RT ping-pong, executing the pass chain in order.
 */
public class EffectComposer {
    /**
     * @brief[zh-cn] 渲染器引用
     * @brief[en] Renderer reference
     */
    public let renderer: ThreeRenderer

    /**
     * @brief[zh-cn] 是否把最终 pass 结果渲染到屏幕，默认 true
     * @brief[en] Whether to render the final pass result to the screen, default true
     */
    public var renderToScreen: Bool = true

    /**
     * @brief[zh-cn] pass 链（有序）
     * @brief[en] The pass chain (ordered)
     */
    public var passes: ArrayList<Pass> = ArrayList<Pass>()

    /**
     * 像素比（来自 renderer，用于把逻辑尺寸放大为物理 RT 尺寸）。
     */
    private var _pixelRatio: Float64 = 1.0

    /**
     * 共享全屏 quad 单例（所有 pass 共用，addPass 时注入）。
     */
    public let quad: FullScreenQuad = FullScreenQuad()

    /**
     * bgfx view id 分配器（从 230 起递增分配）。
     * 对齐 bgfx 需全局唯一 view id，由 composer 统一分配，避免各 pass 硬编码魔数冲突。
     * 起点 230 避开既有硬编码段：ClearPass 60 / SSAO 160~164 /
     * Bloom 200~212 / ShaderPass 池 200~209 / SavePass 210 / TexturePass 211 /
     * OutputPass 212 / FXAAPass 213 / SMAA 214~216 / SSAA 217 / TAA 219~220。
     */
    private var _nextViewId: UInt16 = 230u16

    /**
     * RT 宽度（像素）。
     */
    private var _width: Int64 = 0

    /**
     * RT 高度（像素）。
     */
    private var _height: Int64 = 0

    /**
     * 内部双 RT：renderTarget1 / renderTarget2。
     */
    private var _rt1: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)
    private var _rt2: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)

    /**
     * 当前写 buffer（pass 把结果写到这里）。
     */
    private var _writeBuffer: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)

    /**
     * 当前读 buffer（pass 从这里取上一 pass 结果）。
     */
    private var _readBuffer: Box<FrameBufferHandle> = Box(INVALID_FRAME_BUFFER_HANDLE)

    /**
     * @brief[zh-cn] 取当前写 buffer（capture.cj 调试回读用）
     * @brief[en] Fetches the current write buffer (used by capture.cj debug readback)
     * @return[zh-cn] 当前写 buffer 的 FrameBufferHandle
     * @return[en] The FrameBufferHandle of the current write buffer
     */
    public func writeBuffer(): FrameBufferHandle {
        return this._writeBuffer.value
    }

    /**
     * RT 是否已创建（避免重复创建）。
     */
    private var _rtsCreated: Bool = false

    /**
     * RT 纹理格式（RGBA16F 半浮点）。
     */
    private static let RT_FORMAT: UInt32 = TextureFormat.RGBA16F.value()

    /**
     * @brief[zh-cn] 构造 EffectComposer
     * @brief[en] Constructs EffectComposer
     * @param[zh-cn] renderer 渲染器
     * @param[en] renderer Renderer
     * @explain[zh-cn] 尺寸初始为渲染器尺寸；setSize 后真正创建 RT。
     *         统一注入 renderer 到共享 quad 单例：FullScreenQuad.submit 依赖 _renderer 提交 draw，
     *         若为 None 则 submitQuad 静默跳过（画面全白）。此处统一注入后，
     *         所有 pass（含未显式调用 quad.setRenderer 的 BloomPass/SSRPass 等）均能正常提交。
     * @explain[en] The size is initialized to the renderer size; RTs are created after setSize.
     *         Injects the renderer into the shared quad singleton: FullScreenQuad.submit depends on _renderer
     *         to submit the draw, silently skipping if None (blank screen). After this unified injection,
     *         all passes (including BloomPass/SSRPass that do not explicitly call quad.setRenderer) submit correctly.
     */
    public init(renderer: ThreeRenderer) {
        this.renderer = renderer
        // 尺寸初始为渲染器逻辑尺寸；setSize / _createRTs 会乘以 pixelRatio 得到物理 RT 尺寸
        let (lw, lh) = renderer.getSize()
        this._width = lw
        this._height = lh
        this._pixelRatio = renderer.getPixelRatio()
        // 统一注入 renderer 到共享 quad 单例：FullScreenQuad.submit 依赖 _renderer 提交 draw，
        // 若为 None 则 submitQuad 静默跳过（画面全白）。此处统一注入后，
        // 所有 pass（含未显式调用 quad.setRenderer 的 BloomPass/SSRPass 等）均能正常提交。
        this.quad.setRenderer(renderer)
    }

    /**
     * 交换 read/write buffer。
     */
    private func swapBuffers(): Unit {
        let tmp = this._readBuffer
        this._readBuffer = this._writeBuffer
        this._writeBuffer = tmp
    }

    /**
     * @brief[zh-cn] 分配一个唯一 bgfx view id（从 230 起递增）
     * @brief[en] Allocates a unique bgfx view id (incrementing from 230)
     * @return[zh-cn] 新分配的 view id
     * @return[en] The newly allocated view id
     * @explain[zh-cn] bgfx 需全局唯一 view id；各 pass 在 onAttach 钩子里调用本方法申请，
     *         取代散落各文件的硬编码魔数。
     * @explain[en] bgfx requires globally unique view ids; each pass calls this method in its onAttach hook to
     *         request one, replacing hardcoded magic numbers scattered across files.
     */
    public func allocViewId(): UInt16 {
        let id = this._nextViewId
        this._nextViewId = UInt16(UInt16(this._nextViewId) + 1u16)
        return id
    }

    /**
     * @brief[zh-cn] 添加 pass 到链尾
     * @brief[en] Adds a pass to the end of the chain
     * @param[zh-cn] pass 待添加的 pass
     * @param[en] pass The pass to add
     * @explain[zh-cn] 注入共享全屏 quad 单例 + 挂载钩子（view id 申请）；
     *         pass.setSize 内部会调 bgfx 创建 RT，须在渲染线程执行。
     * @explain[en] Injects the shared full-screen quad singleton + mounts hooks (view id allocation);
     *         pass.setSize calls bgfx internally to create RTs and must run on the render thread.
     */
    public func addPass(pass: Pass): Unit {
        // 注入共享全屏 quad 单例 + 挂载钩子（view id 申请）
        pass.setQuad(this.quad)
        pass.onAttach(this)
        this.passes.add(pass)
        // pass.setSize 内部会调 bgfx 创建 RT，须在渲染线程执行
        let w = this._width
        let h = this._height
        this.renderer.execBgfx({ =>
            pass.setSize(w, h)
        })
    }

    /**
     * @brief[zh-cn] 在指定位置插入 pass
     * @brief[en] Inserts a pass at the given index
     * @param[zh-cn] pass 待插入的 pass
     * @param[zh-cn] index 插入位置
     * @param[en] pass The pass to insert
     * @param[en] index Insertion index
     * @explain[zh-cn] ArrayList 无 insert，用 add + 重建实现；其余同 addPass（注入 quad + 挂载钩子）。
     * @explain[en] ArrayList has no insert, implemented via add + rebuild; otherwise same as addPass
     *         (injecting quad + mounting hooks).
     */
    public func insertPass(pass: Pass, index: Int64): Unit {
        // 注入共享全屏 quad 单例 + 挂载钩子（view id 申请）
        pass.setQuad(this.quad)
        pass.onAttach(this)
        let newList = ArrayList<Pass>()
        var inserted = false
        for (i in 0..this.passes.size) {
            if (Int64(i) == index) {
                newList.add(pass)
                inserted = true
            }
            newList.add(this.passes[i])
        }
        if (!inserted) {
            newList.add(pass)
        }
        this.passes = newList
        // pass.setSize 内部会调 bgfx 创建 RT，须在渲染线程执行
        let w = this._width
        let h = this._height
        this.renderer.execBgfx({ =>
            pass.setSize(w, h)
        })
    }

    /**
     * @brief[zh-cn] 移除指定 pass
     * @brief[en] Removes the given pass
     * @param[zh-cn] pass 待移除的 pass
     * @param[en] pass The pass to remove
     * @explain[zh-cn] ArrayList 无 removeAt，用 add + 重建实现；按对象引用（refEq）匹配移除。
     * @explain[en] ArrayList has no removeAt, implemented via add + rebuild; matched and removed by
     *         object reference (refEq).
     */
    public func removePass(pass: Pass): Unit {
        var idx: Int64 = -1
        for (i in 0..this.passes.size) {
            let p = this.passes[i]
            if (refEq(p, pass)) {
                idx = Int64(i)
                break
            }
        }
        if (idx >= 0) {
            let newList = ArrayList<Pass>()
            for (i in 0..this.passes.size) {
                if (Int64(i) != idx) {
                    newList.add(this.passes[i])
                }
            }
            this.passes = newList
        }
    }
    /**
     * 判断指定索引的 pass 是否为最后一个 enabled pass。
     */
    private func isLastEnabledPass(passIndex: Int64): Bool {
        var i = passIndex + 1
        while (i < Int64(this.passes.size)) {
            if (this.passes[i].enabled) {
                return false
            }
            i++
        }
        return true
    }

    /**
     * @brief[zh-cn] 设置 RT 尺寸（重建内部双 RT）
     * @brief[en] Sets the RT size (rebuilding the internal dual RTs)
     * @param[zh-cn] width 宽度
     * @param[zh-cn] height 高度
     * @param[en] width Width
     * @param[en] height Height
     * @explain[zh-cn] 通知所有 pass 尺寸变化。关键：pass.setSize 内部会调 bgfx 创建/销毁 RT，
     *         必须在渲染线程执行（bgfx API 线程约束），故包进 renderer.execBgfx。
     * @explain[en] Notifies all passes of the size change. Key: pass.setSize calls bgfx internally to
     *         create/destroy RTs and must run on the render thread (bgfx API thread constraint), hence wrapped
     *         in renderer.execBgfx.
     */
    public func setSize(width: Int64, height: Int64): Unit {
        // width/height 为逻辑尺寸；内部 RT 与转发给 pass 的尺寸都使用物理尺寸
        this._width = width
        this._height = height
        this._pixelRatio = this.renderer.getPixelRatio()
        this._createRTs()
        let physicalW = Int64(Float64(width) * this._pixelRatio)
        let physicalH = Int64(Float64(height) * this._pixelRatio)
        // 通知所有 pass 尺寸变化。
        // 关键：pass.setSize 内部会调 bgfx 创建/销毁 RT（如 UnrealBloomPass._createRTs），
        // 必须在渲染线程执行（bgfx API 线程约束），故包进 renderer.execBgfx。
        this.renderer.execBgfx({ =>
            for (pass in this.passes) {
                pass.setSize(physicalW, physicalH)
            }
        })
    }

    /**
     * 创建内部双 RT（RGBA16F + D24 depth attachment）。
     * 若已存在先销毁，避免句柄泄漏。
     *
     * 关键：必须带 depth attachment，否则 RenderPass 把 view 0 指向 readBuffer 后，
     * BgfxBackend.draw 启用 DEPTH_TEST_LESS + WRITE_Z，RT 无 depth buffer 时
     * 深度测试行为未定义 → 片元被错误剔除 → 画面全黑。
     */
    private func _createRTs(): Unit {
        // 先销毁旧 RT（经渲染线程序列化）
        if (this._rtsCreated) {
            this.renderer.destroyFrameBuffer(this._rt1.value)
            this.renderer.destroyFrameBuffer(this._rt2.value)
        }
        let physicalW = Int64(Float64(this._width) * this._pixelRatio)
        let physicalH = Int64(Float64(this._height) * this._pixelRatio)
        let w = UInt16(physicalW)
        let h = UInt16(physicalH)
        // 颜色纹理（RGBA16F 半浮点，支持 >1 亮度）
        let colorFlags: UInt64 = BgfxConstants.TEXTURE_RT | UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP)
        // 所有 bgfx 调用经 renderer 高阶 API 序列化到渲染线程（各自 execBgfx），
        // 避免与 ThreeRenderer 内部 _execBgfx 的 bgfx 调用产生数据竞争。
        let rt1Color = this.renderer.createTexture2D(w, h, false, 1u16, EffectComposer.RT_FORMAT, colorFlags, None)
        let rt1Depth = this.renderer.createTexture2D(w, h, false, 1u16, TextureFormat.D24S8.value(), colorFlags, None)
        this._rt1.value = this._createFBWithDepth(rt1Color, rt1Depth)

        let rt2Color = this.renderer.createTexture2D(w, h, false, 1u16, EffectComposer.RT_FORMAT, colorFlags, None)
        // 深度附件必须用 D24S8：新版 bgfx 的 D3D11 后端中 D24 无 DSV 格式
        // （s_textureFormat[D24].m_fmtDsv = DXGI_FORMAT_UNKNOWN），以 D24 为深度附件
        // 创建 frame buffer 会失败返回 INVALID，ping-pong 的 readBuffer 退化为无效句柄，
        // 场景经 set_view_frame_buffer(INVALID) 直接画进主 backbuffer（与后处理帧交替上屏），
        // 后处理 pass 再从无效 FB 取色 → 采样到垃圾纹理。rt1/rt2 统一 D24S8。
        let rt2Depth = this.renderer.createTexture2D(w, h, false, 1u16, TextureFormat.D24S8.value(), colorFlags, None)
        this._rt2.value = this._createFBWithDepth(rt2Color, rt2Depth)

        this._writeBuffer.value = this._rt1.value
        this._readBuffer.value = this._rt2.value
        this._rtsCreated = true
    }

    /**
     * 创建带 depth attachment 的 frame buffer（color + depth 两纹理）。
     * 对照 SSAOPass._createFBWithDepth：handle 顺序 [0]=color, [1]=depth。
     */
    private func _createFBWithDepth(colorTex: TextureHandle, depthTex: TextureHandle): FrameBufferHandle {
        let handles = Array<TextureHandle>(2, { i => if (i == 0) { colorTex } else { depthTex } })
        let fb = this.renderer.createFrameBuffer(2u8, handles, true)
        return fb
    }

    /**
     * 执行 pass 链，产出最终帧。
     *
     * @param deltaTime 帧间隔（秒），默认 0.016
     *
     * bgfx 差异：bgfx 是显式提交模型（bgfx_frame 双缓冲交换），
     * 每帧只需在 pass 链全部 submit 后触发一次上屏（renderToScreen=true 时）。
     * 各 pass 内部不再调 bgfx_frame（已收敛到此统一入口），避免重复 frame。
     * 注意：若链中含 RenderPass，其 renderer.render(scene,camera) 内部
     * finishRender 会触发一次 bgfx_frame（场景渲染阶段的上屏交换），
     * 本处仅负责最后一个上屏 pass 之后的那一次交换，二者帧序不冲突。
     */
    public func render(deltaTime!: Float64 = 0.016): Unit {
        if (!this._rtsCreated) {
            this.setSize(this._width, this._height)
        }
        // 执行所有 enabled pass
        for (i in 0..this.passes.size) {
            let pass = this.passes[i]
            if (!pass.enabled) {
                continue
            }
            // 最后一个 enabled pass 渲染到屏幕
            pass.renderToScreen = (this.renderToScreen && this.isLastEnabledPass(Int64(i)))
            pass.render(this.renderer, this._writeBuffer.value, this._readBuffer.value, deltaTime)
            if (pass.needsSwap) {
                this.swapBuffers()
            }
        }
        // 统一触发一次上屏（renderToScreen=true 时）
        // 经 renderer.present 序列化到渲染线程，避免与 pass 内的 bgfx 调用竞态。
        if (this.renderToScreen) {
            this.renderer.present(capture: false)
        }
    }

    /**
     * @brief[zh-cn] 释放 EffectComposer 占用的所有 GPU 资源（内部双 RT + 所有 pass）
     * @brief[en] Releases all GPU resources held by EffectComposer (internal dual RTs + all passes)
     * @explain[zh-cn] 依次销毁内部双 RT、各 pass、共享全屏 quad 单例（VB/IB/layout）。
     * @explain[en] Destroys the internal dual RTs, each pass, and the shared full-screen quad singleton (VB/IB/layout).
     */
    public func dispose(): Unit {
        if (this._rtsCreated) {
            this.renderer.destroyFrameBuffer(this._rt1.value)
            this.renderer.destroyFrameBuffer(this._rt2.value)
            this._rtsCreated = false
        }
        for (pass in this.passes) {
            pass.dispose()
        }
        // 销毁共享全屏 quad 单例（VB/IB/layout）
        this.quad.dispose()
    }
}
