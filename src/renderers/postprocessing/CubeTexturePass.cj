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
 *         - CubeTexture 经 renderer 的 CubeTexture→bgfx GfxTextureHandle 桥接取句柄绑 sampler。
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
 *         renderers differences:
 *         - bgfx has no built-in box mesh quad; this pass holds its own cubeMesh (VB/IB) + view-level submit.
 *         - cube shader uses transformDirection(position, modelMatrix) → vWorldDirection,
 *           gl_Position.z = gl_Position.w (pushed to the far plane); bgfx follows the same logic in ShaderLib.cube.
 *         - CubeTexture handle is obtained via the renderer's CubeTexture→bgfx GfxTextureHandle bridge and bound to a sampler.
 *         Usage:
 *         let cubeTex = CubeTextureLoader().load(urls, ..., ..., ...)
 *         let cubePass = CubeTexturePass(camera, cubeTex, opacity: 1.0)
 *         composer.addPass(cubePass)
 *
 * @package three.renderers.postprocessing
 */
package three.renderers.postprocessing

import three.renderers._gfx.*
import three.utils.safe.IReleasable
import three.renderers.cameras.*
import three.renderers.textures.*
import three.renderers.ThreeRenderer
import three.utils.memory.PtrArray
import three.utils.log.*
import three.utils.log.macros.*
import std.collection.*
import std.math.*
import three.profiler.*
import three.profiler.macros.*

/**
 * @brief[zh-cn] 立方体贴图背景 pass
 * @explain[zh-cn] 把 CubeTexture 当作天空盒/背景渲染到 readBuffer 或屏幕。
 *
 * @brief[en] Cube-texture background pass
 * @explain[en] Renders a CubeTexture as a skybox/background to readBuffer or screen.
 */
public class CubeTexturePass <: Pass & IReleasable {
    /**
     * @brief[zh-cn] 相机（取投影/朝向）
     *
     * @brief[en] The camera (for projection/orientation)
     */
    public let camera: Camera

    /**
     * @brief[zh-cn] 立方体贴图引用
     *
     * @brief[en] The cube texture reference
     */
    public var cubeTex: CubeTexture

    /**
     * @brief[zh-cn] 不透明度 [0,1]
     *
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
    private var _cubeProg: Option<GfxProgramHandle> = None

    /**
     * 已上传的 bgfx cube 纹理句柄缓存（首次上传后复用）。
     */
    private var _cubeTexHandleCache: Option<GfxTextureHandle> = None

    /**
     * cube mesh VB（BoxGeometry 顶点缓冲）。
     */
    private var _cubeVB: Option<GfxVertexBufferHandle> = None

    /**
     * cube mesh IB（BoxGeometry 索引缓冲）。
     */
    private var _cubeIB: Option<GfxIndexBufferHandle> = None

    /**
     * cube mesh 顶点 layout handle。
     */
    private var _cubeLayout: Option<GfxVertexLayoutHandle> = None

    /**
     * 单位矩阵（cube 在世界原点，model 恒等）——复用字段，
     * 原实现每帧新建一个 16 元素数组字面量。
     */
    private let _identityMtx: Array<Float64> = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    ]

    /** 渲染器引用（render() 时缓存，dispose 经其高阶 API 销毁 GPU 资源） */
    private var _renderer: Option<ThreeRenderer> = None

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
        // 终结器兜底：GC 回收时自动执行 dispose()（函数值捕获 this，非 open 类构造器允许）
        this._finalizerFallback = Some({ => let _ = this.release() })
    }

    /**
     * 创建 cube mesh 资源（BoxGeometry 10x10x10，BackSide）。
     *
     * bgfx 差异：BoxGeometry 在 bgfx 里是 VB（24 顶点 × position+normal+uv）+ IB（36 索引），
     * cube shader 只用 position，故 VB 仅存 position（8 顶点，36 索引）。
     */
    private func _ensureCubeMesh(renderer: ThreeRenderer): Unit {
        if (let Some(_) <- this._cubeVB) { return }

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
        let mem = PtrArray<UInt8>(Int64(vertsF64.size * 4))
        _writeFloatsToBytes(mem, vertsF64, Int64(vertsF64.size))

        // layout：position only，经 renderer.createVertexLayout 高阶 API 创建句柄
        let layout = renderer.backend.createVertexLayout(this._getLayoutAttrs())
        this._cubeLayout = Some(layout)

        this._cubeVB = Some(renderer.backend.createVertexBuffer(layout, mem, 0u16))

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
        let idxBuf = PtrArray<UInt8>(Int64(indices.size * 2))
        _writeUInt16Bytes(idxBuf, indices, Int64(indices.size))
        this._cubeIB = Some(renderer.backend.createIndexBuffer(idxBuf, 0u16))
    }

    /** 构建 cube mesh 顶点布局属性描述（对齐旧 begin/add/end 序列：position(3)） */
    private func _getLayoutAttrs(): Array<GfxAttributeDesc> {
        let list = ArrayList<GfxAttributeDesc>()
        let pos = GfxAttributeDesc(GfxAttrib.Position, 3u8, GfxAttribType.Float, normalized: false, asInt: false)
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
    @Zone[three.renderers.postprocessing.CubeTexturePass.render, name=cubeTexturePass]
    public override func render(
        renderer: ThreeRenderer,
        writeBuffer: GfxFrameBufferHandle,
        readBuffer: GfxFrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)
        // 取 cube shader + 编译（仅首次）
        // cube shader 已在 ShaderLib.cj 注册
        if (let Some(_) <- this._cubeProg) {
        } else {
            // 用 PostProcessingShaders.cj 注册的 cube_tex（真正采样 textureCube 的天空盒 shader），
            // 替代 ShaderLibs 中 basic 占位的 "cube"（basic 无 textureCube 采样，背景不会显示）。
            if (let Some(sp) <- PostProcessingShaders.get("cube_tex")) {
                sp.compile()
                this._cubeProg = Some(sp.gfxProgramHandle)
            } else {
                @LogTrace(["CubeTexturePass", "cube_tex shader not registered in PostProcessingShaders"])
                return
            }
        }

        if (let Some(prog) <- this._cubeProg) {
            if (!prog.isValid) {
                @LogTrace(["CubeTexturePass", "cube program compile FAILED"])
                return
            }
            let viewId = CubeTexturePass.CUBE_VIEW_ID
            let w = UInt16(renderer.width)
            let h = UInt16(renderer.height)
            let rt = this.renderToScreen
            // 取 cubeTex 对应的 bgfx cube 纹理句柄
            // CubeTexture 在场景中已加载并上传到 bgfx cube 纹理句柄
            // 这里经 renderer 的 CubeTexture→bgfx GfxTextureHandle 桥接取句柄
            let cubeTexHandleRaw = this._getCubeTextureHandle(renderer)
            if (!cubeTexHandleRaw.isValid) {
                @LogTrace(["CubeTexturePass", "cubeTex bgfx handle invalid (CubeTexture not uploaded?)"])
                return
            }
            // 调试日志用的 idx（UInt16 普通值）
            let progIdx = prog.idx
            let cubeTexIdx = cubeTexHandleRaw.idx

            // 计算相机 view/projection 矩阵
            // cube shader 用 modelMatrix（=identity）→ vWorldDirection = position
            // gl_Position = projectionMatrix * viewMatrix * modelMatrix * position
            let viewMtx = this.camera.matrixWorldInverse.elements
            let projMtx = this.camera.projectionMatrix.elements
            // modelMatrix = identity（cube 在世界原点）
            // 复用字段（原实现每帧新建一个 16 元素数组字面量）
            let modelMtx = this._identityMtx
            // tFlip：CubeTexture 通常是 -1（背景立方体贴图翻转 X）
            let tFlip: Float64 = -1.0
            let op = this.opacity

            // 确保 cube mesh 资源已创建
            this._ensureCubeMesh(renderer)
            @LogTrace(["CubeTexturePass", "render: viewId=" + viewId.toString() + " prog=" + progIdx.toString() + " cubeTex=" + cubeTexIdx.toString() + " vb=" + (if (let Some(v) <- this._cubeVB) { v.idx.toString() } else { "-1" }) + " ib=" + (if (let Some(v) <- this._cubeIB) { v.idx.toString() } else { "-1" }) + " layout=" + (if (let Some(v) <- this._cubeLayout) { v.idx.toString() } else { "-1" })])

            // 设置 view 视口（Pass 基类高阶 API，内部走 renderer.execBgfx）
            this.setViewport(renderer, viewId, 0u16, 0u16, w, h)
            if (rt) {
                this.setRenderTarget(renderer, viewId, GfxFrameBufferHandle.INVALID)
            } else {
                this.setRenderTarget(renderer, viewId, readBuffer)
            }
            // 不清任何（保留 RenderPass 场景的 COLOR + DEPTH）：
            // cube 用 DEPTH_TEST_LEQUAL + z=w（深度=1.0 远平面），
            // 背景处 depth=1.0 通过 → 写 cube；场景物体处 depth<1.0 不通过 → 保留场景。
            // 本 pass：cube 渲到 readBuffer 不 clear，depthTest 仅填背景。
            this.clearRenderTarget(renderer, viewId, 0x0000u16, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

            // 绑 view transform（view + projection）—— renderer.setViewTransform 高阶 API
            // 复用的上传缓冲（原实现每帧新建 2 块原生上传缓冲且不归还 → 逐帧泄漏）
            // view/proj 必须是两块独立缓冲：二者在同一调用内同时写入后一起传给
            // setViewTransform，共用一块会让后写覆盖先写的数据。
            let viewMem = this._uploadMem(0, 64u32)
            let projMem = this._uploadMem(1, 64u32)
            _writeFloats(viewMem, viewMtx, 16)
            _writeFloats(projMem, projMtx, 16)
            renderer.backend.setViewTransform(viewId, viewMem, projMem)

            // 绑 model matrix（identity）—— 几何提交 API，保留直接后端调用
            let modelMem = this._uploadMem(2, 64u32)
            _writeFloats(modelMem, modelMtx, 16)
            renderer.backend.setTransform(modelMem, num: 1u16)

            // 绑 cube texture 到 tCube sampler（stage 0）—— Pass 基类高阶 API
            let uniforms = this._passUniforms()
            let uCube = uniforms.createUniform("tCube", GfxUniformType.Sampler)
            this.bindTexture(renderer, 0u8, uCube, cubeTexHandleRaw, 0u32)

            // tFlip uniform（float，bgfx 用 vec4）—— 名须与 cube_tex FS 的 u_tFlip 一致
            let uFlip = uniforms.createUniform("u_tFlip", GfxUniformType.Vec4)
            this._setScalarUniform(renderer, uFlip, 3, tFlip)

            // opacity uniform
            let uOpacity = uniforms.createUniform("u_opacity", GfxUniformType.Vec4)
            this._setScalarUniform(renderer, uOpacity, 4, op)

            // 绑 cube mesh VB/IB —— 几何提交 API，保留直接 bgfx 调用（CubeTexturePass 渲 BoxGeometry 几何体）
            if (let Some(vb) <- this._cubeVB && let Some(ib) <- this._cubeIB && let Some(layout) <- this._cubeLayout) {
                renderer.backend.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                renderer.backend.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                // state：写 RGB/A，FrontCCW（cube 用 BackSide，但 bgfx 翻转面序后 CCW 正确）
                // DEPTH_TEST_LEQUAL：cube 深度=1.0（远平面），
                // 背景处(已清 depth=1.0 或 RenderPass 背景 depth=1.0)通过 → 填 cube；
                // 场景物体处(depth<1.0)不通过 → 保留场景前景。
                // 本 pass：depthTest 仅填背景、depthWrite=false。
                let cubeState: UInt64 = GfxState.WRITE_RGB | GfxState.WRITE_A |
                                        GfxState.DEPTH_TEST_LEQUAL | GfxState.FRONT_CCW
                renderer.backend.setState(cubeState, rgba: 0x00000000u32)
                renderer.backend.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
            }
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
    private func _getCubeTextureHandle(renderer: ThreeRenderer): GfxTextureHandle {
        // 缓存命中直接返回
        if (let Some(h) <- this._cubeTexHandleCache) { return h }
        let imgs = this.cubeTex.images
        if (imgs.size < 6) {
            @LogTrace(["CubeTexturePass", "cubeTex.images 不足 6 面（size=" + imgs.size.toString() + "），无法上传 cube 纹理"])
            return GfxTextureHandle.INVALID
        }
        // 每面 RGBA 数据（4 字节/像素），取第 0 面推导边长
        let face0 = imgs[0]
        let faceBytes = face0.size
        if (faceBytes <= 0) { return GfxTextureHandle.INVALID }
        let side = Int64(sqrt(Float64(faceBytes / 4)))
        if (side <= 0) { return GfxTextureHandle.INVALID }

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
        // 用 PtrArray 构造（createTextureCube 在调用时拷走数据）
        let mem = PtrArray<UInt8>(data)
        let flags: UInt64 = GfxTextureFlag.SAMPLER_U_CLAMP | GfxTextureFlag.SAMPLER_V_CLAMP | GfxTextureFlag.SAMPLER_MIN_ANISOTROPIC
        let handle = renderer.backend.createTextureCube(
            UInt16(side), false, 1u16,
            GfxTextureFormat.RGBA8,
            flags,
            Some(mem)
        )
        if (!handle.isValid) {
            @LogTrace(["CubeTexturePass", "bgfx_create_texture_cube FAILED"])
            return handle
        }
        this._cubeTexHandleCache = Some(handle)
        @LogTrace(["CubeTexturePass", "cube texture uploaded side=" + side.toString()])
        return handle
    }

    /**
     * 释放 CubeTexturePass 占用的 GPU 资源（cube mesh + cube 纹理 + uniform 缓存）。
     */
    public override func release(): Bool {
        if (let Some(renderer) <- this._renderer) {
            if (let Some(vb) <- this._cubeVB) {
                renderer.backend.destroyVertexBuffer(vb)
                this._cubeVB = None
            }
            if (let Some(ib) <- this._cubeIB) {
                renderer.backend.destroyIndexBuffer(ib)
                this._cubeIB = None
            }
            if (let Some(layout) <- this._cubeLayout) {
                renderer.backend.destroyVertexLayout(layout)
                this._cubeLayout = None
            }
            // cube 纹理句柄为本 pass 经 createTextureCube 创建/bgfx 持有，须显式销毁，
            // 否则退出时 bgfx 纹理句柄泄漏（此前仅置缓存为 None）。
            if (let Some(cubeTex) <- this._cubeTexHandleCache) {
                renderer.backend.destroyTexture(cubeTex)
                this._cubeTexHandleCache = None
            }
        }
        // 释放本 pass 私有 uniform 句柄缓存（tCube/u_tFlip/u_opacity 等由 _passUniforms() 创建）
        this._disposePassUniforms()
        // cube shader program 由 PostProcessingShaders 全局缓存管理，不在此 dispose
        this._cubeProg = None
        return true
    }
}
