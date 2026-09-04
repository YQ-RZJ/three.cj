/**
 * @file[zh-cn] CubeTexturePass 立方体贴图背景后处理 pass
 * @brief[zh-cn] 立方体贴图背景 pass —— 把 CubeTexture 当作天空盒/背景渲染
 * @explain[zh-cn] 设计：
 *         - 持 camera（取投影/朝向） + cubeTex（CubeTexture 引用） + opacity
 *         - 内部 cubeMesh：BoxGeometry + cube ShaderMaterial（depthTest=false, depthWrite=false, side=BackSide）
 *         - 渲染 cubeMesh 到 readBuffer / 屏幕
 *         - needsSwap=false（本 pass 是"背景覆盖"，不参与 composer 双 RT ping-pong）
 *         渲染差异：
 *         - bgfx 无 box mesh 内置 quad，本 pass 自持 cubeMesh（VB/IB）+ view 级 submit。
 *         - cube shader 用 transformDirection(position, modelMatrix) → vWorldDirection，
 *           gl_Position.z = gl_Position.w（推到远平面）；bgfx 走 ShaderLib.cube 同样逻辑。
 *         - CubeTexture 经 renderer 的 CubeTexture→bgfx TextureHandle 桥接取句柄绑 sampler。
 *         用法：
 *         let cubeTex = CubeTextureLoader().load(urls, ..., ..., ...)
 *         let cubePass = CubeTexturePass(camera, cubeTex, opacity: 1.0)
 *         composer.addPass(cubePass)
 *
 * @file[en] CubeTexturePass cube-texture background post-processing pass
 * @brief[en] Cube-texture background pass - renders a CubeTexture as skybox/background
 * @explain[en] Design:
 *         - Holds camera (for projection/orientation) + cubeTex (CubeTexture reference) + opacity
 *         - Internal cubeMesh: BoxGeometry + cube ShaderMaterial (depthTest=false, depthWrite=false, side=BackSide)
 *         - Renders cubeMesh to readBuffer / screen
 *         - needsSwap=false (this pass is a "background overlay", not part of the composer dual-RT ping-pong)
 *         Rendering differences:
 *         - bgfx has no built-in box mesh quad; this pass holds its own cubeMesh (VB/IB) + view-level submit.
 *         - cube shader uses transformDirection(position, modelMatrix) → vWorldDirection,
 *           gl_Position.z = gl_Position.w (pushed to the far plane); bgfx follows the same logic in ShaderLib.cube.
 *         - CubeTexture handle is obtained via the renderer's CubeTexture→bgfx TextureHandle bridge and bound to a sampler.
 *         Usage:
 *         let cubeTex = CubeTextureLoader().load(urls, ..., ..., ...)
 *         let cubePass = CubeTexturePass(camera, cubeTex, opacity: 1.0)
 *         composer.addPass(cubePass)
 *
 * @package three.rendering.postprocessing
 */
package three.rendering.postprocessing

import three.rendering.cameras.*
import three.rendering.textures.*
import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxUniforms
import three.rendering.shaders.ShaderLibs
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger
import three.rendering.types.*
import three.rendering.bgfx.BgfxAttributeDesc
import std.collection.*
import std.math.*

/**
 * @brief[zh-cn] 立方体贴图背景 pass
 * @brief[en] Cube-texture background pass
 * @explain[zh-cn] 把 CubeTexture 当作天空盒/背景渲染到 readBuffer 或屏幕。
 * @explain[en] Renders a CubeTexture as a skybox/background to readBuffer or screen.
 */
public class CubeTexturePass <: Pass {
    /**
     * @brief[zh-cn] 相机（取投影/朝向）
     * @brief[en] The camera (for projection/orientation)
     */
    public let camera: Camera

    /**
     * @brief[zh-cn] 立方体贴图引用
     * @brief[en] The cube texture reference
     */
    public var cubeTex: CubeTexture

    /**
     * @brief[zh-cn] 不透明度 [0,1]
     * @brief[en] Opacity [0,1]
     */
    public var opacity: Float64 = 1.0

    /**
     * view id（150，避开 shadow 50~127/SSAO 160/ShaderPass 200~209/SavePass 210/
     * TexturePass 211/OutputPass 212/MaskPass 220~221/OutlinePass 223~239/SSRPass 240+）。
     *
     * 关键：bgfx 按 view id 升序渲染，CubeTexturePass 必须在 OutputPass（212）之前渲染，
     * 否则 OutputPass 先上屏、cube 后渲进 readBuffer 无人上屏 → cube 背景不可见。
     * 150 < 212 满足"RenderPass(view0) → CubeTexturePass(150) → OutputPass(212)"顺序。
     */
    public static let CUBE_VIEW_ID: UInt16 = 150u16

    /**
     * 已编译 cube program handle 缓存。
     */
    private var _cubeProg: Option<ProgramHandle> = None

    /**
     * 已上传的 bgfx cube 纹理句柄缓存（首次上传后复用）。
     */
    private var _cubeTexHandleCache: Option<TextureHandle> = None

    /**
     * cube mesh VB（BoxGeometry 顶点缓冲）。
     */
    private var _cubeVB: Option<VertexBufferHandle> = None

    /**
     * cube mesh IB（BoxGeometry 索引缓冲）。
     */
    private var _cubeIB: Option<IndexBufferHandle> = None

    /**
     * cube mesh 顶点 layout handle。
     */
    private var _cubeLayout: Option<VertexLayoutHandle> = None

    /** 渲染器引用（render() 时缓存，dispose 经其高阶 API 销毁 GPU 资源） */
    private var _renderer: Option<BgfxRenderer> = None

    /**
     * 构造 CubeTexturePass。
     *
     * @param camera 相机
     * @param cubeTex 立方体贴图
     * @param opacity 不透明度（默认 1.0）
     */
    public init(camera: Camera, cubeTex: CubeTexture, opacity!: Float64 = 1.0) {
        super()
        this.camera = camera
        this.cubeTex = cubeTex
        this.opacity = opacity
        // 本 pass 是"背景覆盖"，不参与 composer 双 RT ping-pong
        this.needsSwap = false
    }

    /**
     * 创建 cube mesh 资源（BoxGeometry 10x10x10，BackSide）。
     *
     * bgfx 差异：BoxGeometry 在 bgfx 里是 VB（24 顶点 × position+normal+uv）+ IB（36 索引），
     * cube shader 只用 position，故 VB 仅存 position（8 顶点，36 索引）。
     */
    private func _ensureCubeMesh(renderer: BgfxRenderer): Unit {
        match (this._cubeVB) {
            case Some(_) => return
            case None => ()
        }

        // 8 顶点的 BoxGeometry（100x100x100），BackSide 需 CCW 翻转索引
        // 注意：cube 背景（天空盒）要求相机位于 cube 内部；测试相机 orbitDist 可达 40，
        // 故 cube 半边长取 50（±50）确保相机始终在内部（10 太小会导致 BackSide 剔除后看不到 cube）。
        // 顶点：8 角点
        let vertsF64: Array<Float64> = [
            // 8 角点 × 3 floats
            -50.0, -50.0,  50.0,   // 0: 左下前
             50.0, -50.0,  50.0,   // 1: 右下前
             50.0,  50.0,  50.0,   // 2: 右上前
            -50.0,  50.0,  50.0,   // 3: 左上前
            -50.0, -50.0, -50.0,   // 4: 左下后
             50.0, -50.0, -50.0,   // 5: 右下后
             50.0,  50.0, -50.0,   // 6: 右上后
            -50.0,  50.0, -50.0    // 7: 左上后
        ]
        let mem = BgfxMemory(UInt32(vertsF64.size * 4))
        mem.writeFloats(vertsF64, Int64(vertsF64.size))

        // layout：position only，经 renderer.createVertexLayout 高阶 API 创建句柄
        let layout = renderer.createVertexLayout(this._getLayoutAttrs())
        this._cubeLayout = Some(layout)

        this._cubeVB = Some(renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16))

        // 36 索引（6 面 × 2 三角 × 3 顶点）
        // BackSide 需翻转面序（CW→CCW），即每个三角交换后两索引
        let indices: Array<UInt16> = [
            // 前 (z=+5)：0,1,2,3 → BackSide 翻转
            0u16, 2u16, 1u16,
            0u16, 3u16, 2u16,
            // 后 (z=-5)：4,5,6,7 → BackSide 翻转
            4u16, 5u16, 6u16,
            4u16, 6u16, 7u16,
            // 左 (x=-5)：0,3,7,4 → BackSide 翻转
            0u16, 7u16, 3u16,
            0u16, 4u16, 7u16,
            // 右 (x=+5)：1,2,6,5 → BackSide 翻转
            1u16, 2u16, 6u16,
            1u16, 6u16, 5u16,
            // 上 (y=+5)：2,3,6,7 → BackSide 翻转
            2u16, 7u16, 6u16,
            2u16, 3u16, 7u16,
            // 下 (y=-5)：0,1,5,4 → BackSide 翻转
            0u16, 5u16, 4u16,
            0u16, 1u16, 5u16
        ]
        let idxBytes = ArrayList<UInt8>()
        for (i in 0..indices.size) {
            idxBytes.add(UInt8(indices[i] & 0xFFu16))
            idxBytes.add(UInt8((indices[i] >> 8) & 0xFFu16))
        }
        let idxPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(idxBytes.size + 1)) })
        let idxPtr = idxPtrHolder.get()
        unsafe {
            for (i in 0..idxBytes.size) { (idxPtr + Int64(i)).write(idxBytes[i]) }
            (idxPtr + Int64(idxBytes.size)).write(0u8)
        }
        let idxBgfxMem = BgfxMemory(CPointer<Unit>(idxPtr), UInt32(idxBytes.size))
        this._cubeIB = Some(renderer.createIndexBuffer(idxBgfxMem, flags: 0u16))
        idxPtrHolder.dispose()
    }

    /** 构建 cube mesh 顶点布局属性描述（对齐旧 begin/add/end 序列：position(3)） */
    private func _getLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
        return list.toArray()
    }

    /**
     * 执行立方体贴图 pass：把 cubeTex 渲到 readBuffer 或屏幕。
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 不用）
     * @param readBuffer 读 buffer（renderToScreen=false 时写这里）
     * @param deltaTime 帧间隔
     */
    public override func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 取 cube shader + 编译（仅首次）
        // cube shader 已在 ShaderLib.cj 注册
        match (this._cubeProg) {
            case None =>
                // 用 PostProcessingShaders.cj 注册的 cube_tex（真正采样 textureCube 的天空盒 shader），
                // 替代 ShaderLibs 中 basic 占位的 "cube"（basic 无 textureCube 采样，背景不会显示）。
                match (PostProcessingShaders.get("cube_tex")) {
                    case Some(sp) =>
                        sp.compileBgfx()
                        this._cubeProg = Some(Box(sp.programHandle))
                    case None =>
                        Logger.trace(["CubeTexturePass", "cube_tex shader not registered in PostProcessingShaders"])
                        return
                }
            case Some(_) => ()
        }

        match (this._cubeProg) {
            case Some(prog) =>
                if (!isValidHandle(prog)) {
                    Logger.trace(["CubeTexturePass", "cube program compile FAILED"])
                    return
                }
                let viewId = CubeTexturePass.CUBE_VIEW_ID
                let w = UInt16(renderer.width)
                let h = UInt16(renderer.height)
                let rt = this.renderToScreen
                // 取 cubeTex 对应的 bgfx cube 纹理句柄
                // CubeTexture 在场景中已加载并上传到 bgfx cube 纹理句柄
                // 这里经 renderer 的 CubeTexture→bgfx TextureHandle 桥接取句柄
                let cubeTexHandleRaw = this._getCubeTextureHandle(renderer)
                if (!isValidHandle(cubeTexHandleRaw)) {
                    Logger.trace(["CubeTexturePass", "cubeTex bgfx handle invalid (CubeTexture not uploaded?)"])
                    return
                }
                // 调试日志用的 idx（UInt16 普通值）
                let progIdx = handleIdx(prog)
                let cubeTexIdx = handleIdx(cubeTexHandleRaw)

                // 计算相机 view/projection 矩阵
                // cube shader 用 modelMatrix（=identity）→ vWorldDirection = position
                // gl_Position = projectionMatrix * viewMatrix * modelMatrix * position
                let viewMtx = this.camera.matrixWorldInverse.elements
                let projMtx = this.camera.projectionMatrix.elements
                // modelMatrix = identity（cube 在世界原点）
                let modelMtx: Array<Float64> = [
                    1.0, 0.0, 0.0, 0.0,
                    0.0, 1.0, 0.0, 0.0,
                    0.0, 0.0, 1.0, 0.0,
                    0.0, 0.0, 0.0, 1.0
                ]
                // tFlip：CubeTexture 通常是 -1（背景立方体贴图翻转 X）
                let tFlip: Float64 = -1.0
                let op = this.opacity

                // 确保 cube mesh 资源已创建
                this._ensureCubeMesh(renderer)
                Logger.trace(["CubeTexturePass", "render: viewId=" + viewId.toString() + " prog=" + progIdx.toString() + " cubeTex=" + cubeTexIdx.toString() + " vb=" + (match (this._cubeVB) { case Some(v) => handleIdx(v).toString() case None => "-1" }) + " ib=" + (match (this._cubeIB) { case Some(v) => handleIdx(v).toString() case None => "-1" }) + " layout=" + (match (this._cubeLayout) { case Some(v) => handleIdx(v).toString() case None => "-1" })])

                // 设置 view 视口（Pass 基类高阶 API，内部走 renderer.execBgfx）
                this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
                if (rt) {
                    this.setRenderTarget(renderer, viewId, INVALID_FRAME_BUFFER_HANDLE)
                } else {
                    this.setRenderTarget(renderer, viewId, readBuffer)
                }
                // 不清任何（保留 RenderPass 场景的 COLOR + DEPTH）：
                // cube 用 DEPTH_TEST_LEQUAL + z=w（深度=1.0 远平面），
                // 背景处 depth=1.0 通过 → 写 cube；场景物体处 depth<1.0 不通过 → 保留场景。
                // 本 pass：cube 渲到 readBuffer 不 clear，depthTest 仅填背景。
                this.clearRenderTarget(renderer, viewId, 0x0000u16, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

                // 绑 view transform（view + projection）—— renderer.setViewTransform 高阶 API
                let viewMem = BgfxMemory(64u32)
                viewMem.writeFloats(viewMtx, 16)
                let projMem = BgfxMemory(64u32)
                projMem.writeFloats(projMtx, 16)
                renderer.setViewTransform(viewId, viewMem, projMem)

                // 绑 model matrix（identity）—— 几何提交 API，保留直接 bgfx 调用
                let modelMem = BgfxMemory(64u32)
                modelMem.writeFloats(modelMtx, 16)
                renderer.setTransform(modelMem, num: 1u16)

                // 绑 cube texture 到 tCube sampler（stage 0）—— Pass 基类高阶 API
                let uniforms = BgfxUniforms()
                let uCube = uniforms.createUniform("tCube", UniformType.Sampler.value())
                this.bindTexture(renderer, 0u8, uCube, cubeTexHandleRaw, 0u32)

                // tFlip uniform（float，bgfx 用 vec4）—— 名须与 cube_tex FS 的 u_tFlip 一致
                let uFlip = uniforms.createUniform("u_tFlip", UniformType.Vec4.value())
                let flipMem = BgfxMemory(16u32)
                flipMem.writeFloats([tFlip, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uFlip, flipMem, num: 1u16)

                // opacity uniform
                let uOpacity = uniforms.createUniform("u_opacity", UniformType.Vec4.value())
                let opMem = BgfxMemory(16u32)
                opMem.writeFloats([op, 0.0, 0.0, 0.0], 4)
                this.setUniform(renderer, uOpacity, opMem, num: 1u16)

                // 绑 cube mesh VB/IB —— 几何提交 API，保留直接 bgfx 调用（CubeTexturePass 渲 BoxGeometry 几何体）
                match (this._cubeVB) {
                    case Some(vb) =>
                        match (this._cubeIB) {
                            case Some(ib) =>
                                match (this._cubeLayout) {
                                    case Some(layout) =>
                                        renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                                        renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                                        // state：写 RGB/A，FrontCCW（cube 用 BackSide，但 bgfx 翻转面序后 CCW 正确）
                                        // DEPTH_TEST_LEQUAL：cube 深度=1.0（远平面），
                                        // 背景处(已清 depth=1.0 或 RenderPass 背景 depth=1.0)通过 → 填 cube；
                                        // 场景物体处(depth<1.0)不通过 → 保留场景前景。
                                        // 本 pass：depthTest 仅填背景、depthWrite=false。
                                        let cubeState: UInt64 = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A |
                                                                BgfxConstants.DEPTH_TEST_LEQUAL | BgfxConstants.FRONT_CCW
                                        renderer.setState(cubeState, rgba: 0x00000000u32)
                                        renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                                    case None => ()
                                }
                            case None => ()
                        }
                    case None => ()
                }
            case None => ()
        }
    }

    /**
     * 取 CubeTexture 对应的 bgfx cube 纹理句柄。
     *
     * CubeTexture 的 6 面像素数据（images）经 bgfx_create_texture_cube_cj 上传为
     * 真 cube 纹理；句柄缓存复用（首次上传后不再重复创建）。
     *
     * 若 CubeTexture 无 images 数据（空占位），返回 invalid handle（idx=65535），
     * 调用方日志告警（测试侧需构造带 6 面数据的 CubeTexture）。
     */
    private func _getCubeTextureHandle(renderer: BgfxRenderer): TextureHandle {
        // 缓存命中直接返回
        match (this._cubeTexHandleCache) {
            case Some(h) => return h
            case None => ()
        }
        let imgs = this.cubeTex.images
        if (imgs.size < 6) {
            Logger.trace(["CubeTexturePass", "cubeTex.images 不足 6 面（size=" + imgs.size.toString() + "），无法上传 cube 纹理"])
            return INVALID_TEXTURE_HANDLE
        }
        // 每面 RGBA 数据（4 字节/像素），取第 0 面推导边长
        let face0 = imgs[0]
        let faceBytes = face0.size
        if (faceBytes <= 0) { return INVALID_TEXTURE_HANDLE }
        let side = Int64(sqrt(Float64(faceBytes / 4)))
        if (side <= 0) { return INVALID_TEXTURE_HANDLE }

        // 拼接 6 面数据为连续内存（bgfx cube 纹理数据布局：6 面连续，每面 side*side*4 字节）
        let total = Int64(side) * Int64(side) * 4 * 6
        let data = Array<UInt8>(total, { i => 0u8 })
        for (f in 0..6) {
            let face = imgs[f]
            let base = f * Int64(side) * Int64(side) * 4
            for (i in 0..Int64(side) * Int64(side) * 4) {
                if (i < face.size) {
                    data[base + i] = face[i]
                }
            }
        }
        // 用 BgfxMemory(data, size) copy 构造（bgfx_copy 语义：bgfx 内部持有数据副本）
        let dataPtrHolder = AutoFreePtr<UInt8>(unsafe { LibC.malloc<UInt8>(count: Int64(data.size)) })
        let dataPtr = dataPtrHolder.get()
        unsafe {
            for (i in 0..data.size) { (dataPtr + Int64(i)).write(data[i]) }
        }
        let mem = BgfxMemory(CPointer<Unit>(dataPtr), UInt32(data.size))
        dataPtrHolder.dispose()
        let flags: UInt64 = UInt64(BgfxConstants.SAMPLER_U_CLAMP) | UInt64(BgfxConstants.SAMPLER_V_CLAMP) | UInt64(BgfxConstants.SAMPLER_MIN_ANISOTROPIC)
        let handle = renderer.createTextureCube(
            UInt16(side), false, 1u16,
            TextureFormat.RGBA8.value(),
            flags,
            mem
        )
        if (!isValidHandle(handle)) {
            Logger.trace(["CubeTexturePass", "bgfx_create_texture_cube FAILED"])
            return handle
        }
        this._cubeTexHandleCache = Some(handle)
        Logger.trace(["CubeTexturePass", "cube texture uploaded side=" + side.toString()])
        return handle
    }

    /**
     * 释放 CubeTexturePass 占用的 GPU 资源（cube mesh + shader 缓存）。
     */
    public override func dispose(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                match (this._cubeVB) {
                    case Some(vb) =>
                        renderer.destroyVertexBuffer(vb)
                        this._cubeVB = None
                    case None => ()
                }
                match (this._cubeIB) {
                    case Some(ib) =>
                        renderer.destroyIndexBuffer(ib)
                        this._cubeIB = None
                    case None => ()
                }
                match (this._cubeLayout) {
                    case Some(layout) =>
                        renderer.destroyVertexLayout(layout)
                        this._cubeLayout = None
                    case None => ()
                }
            case None => ()
        }
        this._cubeProg = None
    }
}
