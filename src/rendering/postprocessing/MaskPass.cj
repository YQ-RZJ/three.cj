/**
 * @file[zh-cn] MaskPass 遮罩后处理 pass + ClearMaskPass 清遮罩 pass
 * @brief[zh-cn] 遮罩 pass + 清遮罩 pass —— 用 stencil buffer 定义后处理遮罩区域
 * @explain[zh-cn] 设计：
 *         - MaskPass 持 scene + camera，把场景几何体写入 stencil buffer
 *           （writeValue=1，inverse 时 writeValue=0/clearValue=1），
 *           后续 pass 仅在 stencil==1 区域渲染（EQUAL/KEEP/KEEP）。
 *         - needsSwap=false（不参与 composer 双 RT ping-pong；本 pass 是"模板标记"，主链 readBuffer 不变）
 *         - clear=true（默认渲染前清 stencil）
 *         - ClearMaskPass 与 MaskPass 同文件导出。
 *         渲染差异：
 *         - bgfx 用 bgfx_set_stencil(fstencil, bstencil) 设前/后面 stencil 状态，
 *           模板操作/比较函数/读写掩码全部编码进 fstencil/bstencil 位域
 *           （见 bgfx BGFX_STENCIL_* 宏：op_fail/op_zfail/op_pass/ref/func/rwmask）。
 *         - MaskPass.render 内部两次 submit 场景几何（一次到 readBuffer，
 *           一次到 writeBuffer，两侧都打 stencil 标记）。
 *         关键实现点（BIGFIX：不调 renderer.render）：
 *         - 早期实现经 renderer.render(scene, camera) 渲场景写 stencil，但 renderer.render
 *           内部 finishRender 触发 bgfx_frame（双缓冲交换），在 composer 链中间触发 frame
 *           会破坏帧序 → 屏幕出现扫描线/闪烁（mask 测试实测）。
 *         - 正确做法（参照 SSAO._renderNormals/OutlinePass 几何 submit 模式）：
 *           遍历场景收集 Mesh，对每个 mesh 用共享全屏几何 VB/IB + 独立 view id
 *           （MASK_VIEW_ID_BASE+0/+1）直接 bgfx_submit；submit 前 bgfx_set_stencil_cj
 *           写 ref=writeValue。不调 renderer.render → 不触发 bgfx_frame → 帧序稳定。
 *         - bgfx stencil 是"下一次 submit 前设置"的瞬态状态（非持久全局状态），
 *           故 ClearMaskPass 重置为 disabled，后续 pass submit 前自行重设所需测试状态。
 *         用法：
 *         let maskPass = MaskPass(scene, camera)
 *         composer.addPass(maskPass)
 *         // ... 后续 pass 仅在 mask 区域生效 ...
 *         composer.addPass(ClearMaskPass())
 *
 * @file[en] MaskPass mask post-processing pass + ClearMaskPass clear-mask pass
 * @brief[en] Mask pass + clear-mask pass - uses the stencil buffer to define post-processing mask regions
 * @explain[en] Design:
 *         - MaskPass holds scene + camera and writes the scene geometry into the stencil buffer
 *           (writeValue=1, with inverse writeValue=0/clearValue=1);
 *           later passes render only where stencil==1 (EQUAL/KEEP/KEEP).
 *         - needsSwap=false (not part of the composer dual-RT ping-pong; this pass is a "stencil marker", main chain readBuffer unchanged)
 *         - clear=true (clears stencil before rendering by default)
 *         - ClearMaskPass is exported together with MaskPass from the same file.
 *         Rendering differences:
 *         - bgfx uses bgfx_set_stencil(fstencil, bstencil) for front/back stencil state;
 *           stencil ops/compare function/read-write mask are all encoded into the fstencil/bstencil bit fields
 *           (see bgfx BGFX_STENCIL_* macros: op_fail/op_zfail/op_pass/ref/func/rwmask).
 *         - MaskPass.render submits the scene geometry twice (once to readBuffer,
 *           once to writeBuffer, marking stencil on both sides).
 *         Key implementation point (BIGFIX: no renderer.render):
 *         - Early implementation rendered the scene to stencil via renderer.render(scene, camera),
 *           but renderer.render calls finishRender which triggers bgfx_frame (double-buffer swap);
 *           triggering a frame in the middle of the composer chain breaks frame order
 *           → scanlines/flicker on screen (observed in mask tests).
 *         - Correct approach (following SSAO._renderNormals/OutlinePass geometry-submit pattern):
 *           traverse the scene collecting Meshes, then for each mesh use the shared fullscreen
 *           geometry VB/IB + a dedicated view id (MASK_VIEW_ID_BASE+0/+1) and submit directly
 *           via bgfx; before submit, bgfx_set_stencil_cj writes ref=writeValue. No renderer.render
 *           → no bgfx_frame → stable frame order.
 *         - bgfx stencil is a transient state set before the next submit (not persistent global state),
 *           so ClearMaskPass resets it to disabled; later passes re-establish their own test state before submit.
 *         Usage:
 *         let maskPass = MaskPass(scene, camera)
 *         composer.addPass(maskPass)
 *         // ... later passes only take effect in the mask region ...
 *         composer.addPass(ClearMaskPass())
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.scene.scenegraph.*
import three.scene.entity.*
import three.rendering.cameras.*
import three.rendering.BgfxRenderer
import three.rendering.common.*
import three.rendering.bgfx.*
import three.rendering.types.*
import three.rendering.bgfx.BgfxAttributeDesc
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import std.collection.*

/**
 * bgfx stencil 位域宏（对照 bgfx.h BGFX_STENCIL_* 定义）。
 *
 * bgfx_set_stencil(fstencil, bstencil) 的参数是位域编码的完整 stencil 状态：
 *   - FUNC: 比较函数（ALWAYS/EQUAL/LESS/...），3 位
 *   - OP_FAIL: 失败时操作（KEEP/ZERO/REPLACE/INCR/...），3 位
 *   - OP_ZFAIL: 深度测试失败时操作，3 位
 *   - OP_PASS: 深度通过时操作，3 位
 *   - REF: 模板参考值，8 位
 *   - RWMASK: 读写掩码，8 位
 *
 * 本 pass 仅需：
 *   - FUNC_ALWAYS（不依赖当前 stencil 值，总是写 ref）
 *   - OP_PASS_REPLACE（深度测试通过时把 stencil 替换为 ref）
 *   - REF=writeValue（setFunc(ALWAYS, writeValue, ...) 语义）
 *   - RWMASK=0xFF（全位写）
 *
 * bgfx.h 实际位偏移（取自 BGFX_STENCIL_* 宏）：
 *   TEST_FUNC(f)   = (f & 0xff) << 0   // func
 *   OP_FAIL(f)     = (f & 0xff) << 8   // op_fail
 *   OP_ZFAIL(f)    = (f & 0xff) << 11  // op_zfail
 *   OP_PASS(f)     = (f & 0xff) << 14  // op_pass
 *   REF(r)         = (r & 0xff) << 17  // ref
 *   RWMASK(m)      = (m & 0xff) << 25  // rwmask
 *
 * 其中 func/op_* 的常量值：
 *   FUNC_ALWAYS    = 0x00000000
 *   OP_FAIL_KEEP   = 0x00000001
 *   OP_PASS_REPLACE  = 0x00000005
 */

/**
 * @brief[zh-cn] 遮罩 pass
 * @brief[en] Mask pass
 * @explain[zh-cn] 用 stencil buffer 标记 scene 的可渲染区域。
 * @explain[en] Marks the renderable region of the scene using the stencil buffer.
 */
public open class MaskPass <: Pass {
    /**
     * @brief[zh-cn] 待渲染场景（定义遮罩几何）
     * @brief[en] The scene to render (defines the mask geometry)
     */
    public let scene: Scene

    /**
     * @brief[zh-cn] 待渲染相机
     * @brief[en] The camera to render with
     */
    public let camera: Camera

    /**
     * @brief[zh-cn] 是否反转遮罩
     * @brief[en] Whether to invert the mask
     */
    public var inverse: Bool = false

    /**
     * view id 基址（220~221，避开 SSAO 160/Bloom 200/ShaderPass 200~209/SavePass 210/
     * TexturePass 211/OutputPass 212/SMAA 214~216/SSAA 217/TAA 219~220 区段）。
     * +0 = readBuffer view，+1 = writeBuffer view。
     */
    public static let MASK_VIEW_ID_BASE: UInt16 = 220u16

    // ===== 几何 submit 缓存（参照 OutlinePass/SSAO） =====
    private var _prog: Option<ProgramHandle> = None   // outline_white 几何 shader
    private var _vbCache: HashMap<Int64, VertexBufferHandle> = HashMap<Int64, VertexBufferHandle>()
    private var _ibCache: HashMap<Int64, IndexBufferHandle> = HashMap<Int64, IndexBufferHandle>()
    private var _layoutHandleCache: Option<VertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，dispose 经其高阶 API 销毁 GPU 资源） */
    private var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造 MaskPass。
     *
     * @param scene 场景
     * @param camera 相机
     */
    public init(scene: Scene, camera: Camera) {
        super()
        this.scene = scene
        this.camera = camera
        // 默认渲染前清 stencil/color/depth
        this.clear = true
        // 本 pass 是"模板标记"，不参与双 RT ping-pong
        this.needsSwap = false
    }

    /**
     * 编码 bgfx stencil 状态（前/背面相同）。
     *
     * 组合：TEST_ALWAYS | OP_FAIL_S_KEEP | OP_FAIL_Z_KEEP | OP_PASS_Z_REPLACE |
     *       REF=writeValue | RMASK=0xFF
     *
     * bgfx 位域（对照 cxx/bgfx/include/bgfx/defines.h BGFX_STENCIL_* 宏，实测编码）：
     *   FUNC_REF(v)      = v << 0          （bit 0-7，模板参考值）
     *   FUNC_RMASK(v)    = v << 8          （bit 8-15，读写掩码）
     *   TEST_ALWAYS      = 0x00080000      （bit 16-19，测试函数）
     *   TEST_EQUAL       = 0x00030000
     *   OP_FAIL_S_KEEP   = 0x00100000      （bit 20-23，stencil 测试失败操作）
     *   OP_FAIL_Z_KEEP   = 0x01000000      （bit 24-27，深度测试失败操作）
     *   OP_PASS_Z_REPLACE= 0x20000000      （bit 28-31，深度测试通过操作）
     *   OP_PASS_Z_KEEP   = 0x10000000
     *
     * @param writeValue 模板写入值（inverse=0 否则=1）
     * @return 已编码的 32 位 stencil 状态
     */
    private func _encodeStencilState(writeValue: UInt32): UInt32 {
        let ref: UInt32 = (writeValue & 0xFFu32) << 0          // REF（bit 0-7）
        let rwmask: UInt32 = 0xFFu32 << 8                      // RMASK=0xFF（bit 8-15）
        let testAlways: UInt32 = BgfxConstants.STENCIL_TEST_ALWAYS   // TEST_ALWAYS（bit 16-19）
        let opFailSKeep: UInt32 = BgfxConstants.STENCIL_OP_FAIL_S_KEEP   // OP_FAIL_S_KEEP（bit 20-23）
        let opFailZKeep: UInt32 = BgfxConstants.STENCIL_OP_FAIL_Z_KEEP   // OP_FAIL_Z_KEEP（bit 24-27）
        let opPassZReplace: UInt32 = BgfxConstants.STENCIL_OP_PASS_Z_REPLACE // OP_PASS_Z_REPLACE（bit 28-31）
        let state: UInt32 = ref | rwmask | testAlways | opFailSKeep | opFailZKeep | opPassZReplace
        return state
    }

    // ===== 几何 submit 工具（参照 OutlinePass/SSAO） =====

    /**
     * 取共享顶点 layout handle（position+normal+color+uv，缓存复用）。
     */
    private func _getOrCreateLayout(renderer: BgfxRenderer): VertexLayoutHandle {
        match (this._layoutHandleCache) {
            case Some(lh) => return lh
            case None => ()
        }
        // 经 renderer.createVertexLayout(attrs) 高阶 API 创建布局句柄（封装 begin/add/end/create 序列）。
        // _createVB 经 renderer.createVertexBufferFromLayout(handle) 创建顶点缓冲
        // （renderer 内部从 handle 查回 layout 内存指针，无须接触 CPointer<VertexLayout>）。
        let handle = renderer.createVertexLayout(this._getLayoutAttrs())
        this._layoutHandleCache = Some(handle)
        return handle
    }

    /** 构建顶点布局属性描述（对齐旧 begin/add/end 序列：position(3) + normal(3) + color(4) + uv(2)） */
    private func _getLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        let normal = BgfxAttributeDesc()
        normal.attrib = Attrib.Normal.value()
        normal.num = 3u8
        normal.attribType = AttribType.Float.value()
        normal.normalized = true
        normal.asInt = false
        list.add(normal)
        let color = BgfxAttributeDesc()
        color.attrib = Attrib.Color0.value()
        color.num = 4u8
        color.attribType = AttribType.Float.value()
        color.normalized = false
        color.asInt = false
        list.add(color)
        let uv = BgfxAttributeDesc()
        uv.attrib = Attrib.TexCoord0.value()
        uv.num = 2u8
        uv.attribType = AttribType.Float.value()
        uv.normalized = false
        uv.asInt = false
        list.add(uv)
        return list.toArray()
    }

    /**
     * 创建/复用 geometry 的顶点缓冲（按 geomId 缓存）。
     */
    private func _createVB(renderer: BgfxRenderer, geom: BufferGeometry): VertexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._vbCache.get(geomId)) {
            case Some(vb) => return vb
            case None => ()
        }
        let posAttrOpt = geom.getAttribute("position")
        match (posAttrOpt) {
            case Some(pos) =>
                let vc = pos.count
                if (vc == 0) { return INVALID_VERTEX_BUFFER_HANDLE }
                let vertStride: Int64 = 12   // position(3) + normal(3) + color(4) + uv(2)
                let totalFloats = vc * vertStride
                let data = Array<Float64>(totalFloats, { i => 0.0 })
                let normAttrOpt = geom.getAttribute("normal")
                let colAttrOpt = geom.getAttribute("color")
                let uvAttrOpt = geom.getAttribute("uv")
                for (vi in 0..vc) {
                    let base = vi * vertStride
                    data[base] = pos.getX(vi)
                    data[base + 1] = pos.getY(vi)
                    data[base + 2] = pos.getZ(vi)
                    match (normAttrOpt) {
                        case Some(na) =>
                            data[base + 3] = na.getX(vi)
                            data[base + 4] = na.getY(vi)
                            data[base + 5] = na.getZ(vi)
                        case None => data[base + 5] = 1.0
                    }
                    match (colAttrOpt) {
                        case Some(ca) =>
                            data[base + 6] = ca.getX(vi)
                            data[base + 7] = ca.getY(vi)
                            data[base + 8] = ca.getZ(vi)
                            data[base + 9] = if (ca.itemSize > 3) { ca.getW(vi) } else { 1.0 }
                        case None =>
                            for (j in 0..4) { data[base + 6 + j] = 1.0 }
                    }
                    match (uvAttrOpt) {
                        case Some(ua) =>
                            data[base + 10] = ua.getX(vi)
                            data[base + 11] = ua.getY(vi)
                        case None => ()
                    }
                }
                let mem = BgfxMemory(UInt32(totalFloats * 4))
                mem.writeFloats(data, totalFloats)
                let layout = this._getOrCreateLayout(renderer)
                let handle = renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16)
                this._vbCache.add(geomId, handle)
                return handle
            case None => return INVALID_VERTEX_BUFFER_HANDLE
        }
    }

    /**
     * 创建/复用 geometry 的索引缓冲（按 geomId 缓存）。
     */
    private func _createIB(renderer: BgfxRenderer, geom: BufferGeometry): IndexBufferHandle {
        let geomId = geom.uuid.hashCode()
        match (this._ibCache.get(geomId)) {
            case Some(ib) => return ib
            case None => ()
        }
        match (geom.index) {
            case Some(idxAttr) =>
                let count = idxAttr.count
                if (count == 0) { return INVALID_INDEX_BUFFER_HANDLE }
                let idxData = Array<UInt16>(count, { i => UInt16(idxAttr.getX(i)) })
                let mem = BgfxMemory(UInt32(count * 2))
                mem.writeUInt16(idxData, count)
                let handle = renderer.createIndexBuffer(mem, flags: 0u16)
                this._ibCache.add(geomId, handle)
                return handle
            case None => return INVALID_INDEX_BUFFER_HANDLE
        }
    }

    /**
     * 为指定 view 设置相机 view/proj 变换（用 renderer.setViewTransform 高阶 API）。
     */
    private func _setViewTransformFor(renderer: BgfxRenderer, viewId: UInt16, camera: Camera): Unit {
        let viewArr = camera.matrixWorldInverse.elements
        let projArr = camera.projectionMatrix.elements
        let viewMem = BgfxMemory(64u32)
        let projMem = BgfxMemory(64u32)
        viewMem.writeFloats(viewArr, 16)
        projMem.writeFloats(projArr, 16)
        renderer.setViewTransform(viewId, viewMem, projMem)
    }

    /**
     * 递归收集场景中的 Mesh（参照 OutlinePass/SSAO._collectMeshes）。
     */
    private func _collectMeshes(obj: Object3D, renderObjects: ArrayList<RenderObject>): Unit {
        for (child in obj.children) {
            if (child.children.size > 0) {
                this._collectMeshes(child, renderObjects)
            }
            if (child.kind == "Mesh") {
                match (child as Mesh) {
                    case Some(mesh) =>
                        let ro = RenderObject(mesh.id, mesh, mesh.geometry, mesh.material, mesh.matrixWorld)
                        renderObjects.add(ro)
                    case None => ()
                }
            }
        }
    }

    /**
     * 确保 mask 几何 shader（outline_white）已编译，返回 program handle。
     * outline_white：几何 VS（u_model × u_viewProj）+ 纯白 FS —— 仅触发光栅化，
     * stencil 写入由 bgfx_set_stencil_cj 控制，与 FS 输出颜色无关。
     */
    private func _ensureProg(): Option<ProgramHandle> {
        match (this._prog) {
            case Some(p) => return Some(p)
            case None => ()
        }
        match (PostProcessingShaders.get("outline_white")) {
            case Some(sp) =>
                sp.compileBgfx()
                let p = Box(sp.programHandle)
                if (!isValidHandle(p)) {
                    Logger.trace(["MaskPass", "outline_white compile FAILED"])
                    return None
                }
                this._prog = Some(p)
                return Some(p)
            case None =>
                Logger.trace(["MaskPass", "outline_white shader NOT REGISTERED"])
                return None
        }
    }

    /**
     * 在指定 frame buffer 上提交场景几何（写 stencil ref=writeValue）。
     *
     * @param renderer 渲染器
     * @param viewId 目标 view id（readBuffer/writeBuffer 各一）
     * @param targetFB 目标 frame buffer
     * @param stencilState 已编码的 stencil 写状态
     * @param clearValue stencil clear 值（inverse=true 时=1，背景 stencil 置 1 → 后续 EQUAL 测试反选）
     */
    private func _submitSceneToStencil(renderer: BgfxRenderer, viewId: UInt16, targetFB: FrameBufferHandle, stencilState: UInt32, clearValue: UInt32): Unit {
        let w = UInt16(renderer.width)
        let h = UInt16(renderer.height)
        this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
        this.setRenderTarget(renderer, viewId, targetFB)
        // 只清 DEPTH + STENCIL（不清 COLOR！）：MaskPass 是"遮罩标记"，不应破坏
        // readBuffer/writeBuffer 的场景颜色（RenderPass 渲的场景要保留给后续 pass 采样）。
        // BUGFIX：此前误用 COLOR|DEPTH|STENCIL 全清，导致 readBuffer 场景被清黑。
        this.clearRenderTarget(renderer, viewId, BgfxConstants.CLEAR_DEPTH | BgfxConstants.CLEAR_STENCIL, 0x00000000u32, depth: 1.0f32, stencil: UInt8(clearValue))
        this._setViewTransformFor(renderer, viewId, this.camera)

        let renderObjects = ArrayList<RenderObject>()
        this._collectMeshes(this.scene, renderObjects)
        let layout = this._getOrCreateLayout(renderer)
        var submitCnt: Int64 = 0
        for (ro in renderObjects) {
            let vb = this._createVB(renderer, ro.geometry)
            if (!isValidHandle(vb)) { continue }
            let mtxArr = ro.worldMatrix.elements
            let mtxMem = BgfxMemory(64u32)
            mtxMem.writeFloats(mtxArr, 16)
            renderer.setTransform(mtxMem, num: 1u16)
            renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
            let ib = this._createIB(renderer, ro.geometry)
            if (isValidHandle(ib)) {
                renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
            }
            // 写 stencil：FUNC_ALWAYS + OP_PASS_REPLACE + REF=writeValue
            Logger.trace(["MaskPass", "write stencilState=" + stencilState.toString()])
            this.setStencil(renderer, stencilState, stencilState)
            // state：只写深度 + stencil（不写 RGB/A！）—— 遮罩标记不改变 readBuffer 颜色，
            // 后续受 mask 影响的 pass 采样 readBuffer 仍是原场景。
            // 注意：bgfx stencil op 在片元光栅化时执行，与 color 写入相互独立，
            // state 不设 WRITE_RGB/WRITE_A 时颜色保留、stencil 照常写入。
            let state: UInt64 = BgfxConstants.WRITE_Z | BgfxConstants.DEPTH_TEST_LESS |
                                BgfxConstants.FRONT_CCW
            renderer.setState(state, rgba: 0x00000000u32)
            match (this._ensureProg()) {
                case Some(prog) =>
                    renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                    submitCnt += 1
                case None => ()
            }
        }
        Logger.trace(["MaskPass", "_submitSceneToStencil view=" + viewId.toString() + " submitCnt=" + submitCnt.toString()])
    }

    /**
     * 执行遮罩 pass：把场景几何体写入 stencil buffer。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（与 readBuffer 两侧都打 stencil 标记）
     * @param readBuffer 读 buffer
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // writeValue/clearValue（inverse 分支：write=0/clear=1）
        let writeValue: UInt32 = if (this.inverse) { 0u32 } else { 1u32 }
        let clearValue: UInt32 = if (this.inverse) { 1u32 } else { 0u32 }
        let stencilState = this._encodeStencilState(writeValue)
        Logger.trace(["MaskPass", "render ENTER writeValue=" + writeValue.toString() + " clearValue=" + clearValue.toString() + " inverse=" + this.inverse.toString()])

        // readBuffer 侧打 stencil 标记（view +0）
        this._submitSceneToStencil(renderer, MaskPass.MASK_VIEW_ID_BASE, readBuffer, stencilState, clearValue)
        // writeBuffer 侧打 stencil 标记（view +1）
        this._submitSceneToStencil(renderer, UInt16(UInt16(MaskPass.MASK_VIEW_ID_BASE) + 1u16), writeBuffer, stencilState, clearValue)

        // BUGFIX：不再调 renderer.render(scene, camera) —— 其内部 finishRender 触发
        // bgfx_frame（双缓冲交换），在 composer 链中间触发 frame 会破坏帧序，
        // 导致屏幕出现扫描线/闪烁（mask 测试实测）。改直接 submit 后帧序稳定。
        Logger.trace(["MaskPass", "render done (stencil marked on readBuffer + writeBuffer)"])
    }

    /**
     * 释放 MaskPass 占用的 GPU 资源（几何缓存 + shader 缓存）。
     */
    public override func dispose(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                for ((_, vb) in this._vbCache) {
                    renderer.destroyVertexBuffer(vb)
                }
                for ((_, ib) in this._ibCache) {
                    renderer.destroyIndexBuffer(ib)
                }
                match (this._layoutHandleCache) {
                    case Some(lh) =>
                        renderer.destroyVertexLayout(lh)
                        this._layoutHandleCache = None
                    case None => ()
                }
            case None => ()
        }
        this._vbCache.clear()
        this._ibCache.clear()
        this._prog = None
    }
}

/**
 * @brief[zh-cn] 清遮罩 pass
 * @brief[en] Clear-mask pass
 * @explain[zh-cn] 清除 MaskPass 设置的 stencil 状态（后续 pass 不再受 mask 约束）。
 * @explain[en] Clears the stencil state set by MaskPass (later passes are no longer constrained by the mask).
 * @explain[zh-cn] bgfx 差异：bgfx 的 stencil 状态是 per-draw-call 的瞬态设置（bgfx_set_stencil_cj），
 * @explain[en] bgfx difference: bgfx stencil state is a per-draw-call transient setting (bgfx_set_stencil_cj),
 * @explain[zh-cn] 不像持久全局状态。故 ClearMaskPass 在 bgfx 里实际只需"重置 stencil 状态到 disabled"
 * @explain[en] not persistent global state. So in bgfx, ClearMaskPass only needs to "reset stencil state to disabled"
 * @explain[zh-cn] ——通过 bgfx_set_stencil_cj(0, 0) 实现。
 * @explain[en] - implemented via bgfx_set_stencil_cj(0, 0).
 * @explain[zh-cn] bgfx_set_stencil_cj(0, 0)：FUNC_ALWAYS（默认）+ op KEEP，等价于 stencil disabled。
 * @explain[en] bgfx_set_stencil_cj(0, 0): FUNC_ALWAYS (default) + op KEEP, equivalent to stencil disabled.
 */
public class ClearMaskPass <: Pass {
    /**
     * 构造 ClearMaskPass。
     */
    public init() {
        super()
        // 本 pass 是"清标记"，不参与双 RT ping-pong
        this.needsSwap = false
    }

    /**
     * 执行清遮罩。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 不用）
     * @param readBuffer 读 buffer（本 pass 不用）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        // 重置 stencil 状态到 disabled（FUNC_ALWAYS + op KEEP = 不写 stencil）
        this.setStencil(renderer, 0u32, 0u32)
        Logger.trace(["ClearMaskPass", "stencil state reset (disabled)"])
    }
}
