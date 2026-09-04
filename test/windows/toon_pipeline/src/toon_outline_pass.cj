package toon_pipeline

/**
 * ToonOutlinePass —— 自定义卡通描边后处理 pass
 *
 * 设计目标：完整实现自定义后处理 pass，不复用引擎内置 OutlinePass。
 *
 * 算法流程（基于深度的 Sobel 边缘检测，对照 three.js OutlinePass 简化版）：
 *   1. 场景渲染到 readBuffer（由 RenderPass 完成）
 *   2. ToonOutlinePass 采样 readBuffer 的颜色 + 深度
 *   3. 用 Sobel 算子检测深度边缘
 *   4. 边缘像素混合描边颜色，输出到 writeBuffer
 *
 * 渲染管线组装（对照 three.js 官方 toon 案例 webgl_materials_toon.html）：
 *   EffectComposer
 *     ├── RenderPass（场景→readBuffer）
 *     └── ToonOutlinePass（边缘检测描边→writeBuffer→上屏）
 *
 * bgfx 特性适配：
 *   - 使用 BgfxRenderer 高阶 API（setViewFrameBuffer/setViewRect/setViewClear）
 *   - 自定义全屏 quad（position+texcoord0）+ ToonEdge shader
 *   - 深度纹理通过 readBuffer 的 depth attachment 获取
 *   - view id 独立分配（避免与 EffectComposer 内部 view 冲突）
 *
 * 对照 three.js OutlinePass.js：
 *   - JS 用 WebGLRenderTarget + FullScreenQuad；
 *     本 pass 用 BgfxRenderer 高阶 API + 自定义全屏 quad submit
 *   - JS 7-pass chain（depth/mask/downsample/edge/blur1/blur2/overlay）；
 *     本 pass 简化为单 pass Sobel 边缘检测 + 颜色合成
 *   - JS 用 depthTexture 比较；本 pass 直接采样 depth attachment
 */

import std.collection.*
import std.math.*
import three.core.*
import three.scene.scenegraph.*
import three.rendering.cameras.*
import three.scene.entity.*
import three.scene.scenegraph.*
import three.scene.objects.*
import three.rendering.materials.*
import three.core.math.*
import three.rendering.BgfxRenderer
import three.rendering.bgfx.BgfxConstants
import three.rendering.bgfx.BgfxAttributeDesc
import three.rendering.types.*
import three.utils.memory.AutoFreePtr
import three.utils.memory.BgfxMemory
import three.utils.log.Logger

/**
 * 卡通描边后处理 pass。
 *
 * 单 pass Sobel 边缘检测：
 *   - 采样 readBuffer 颜色（t_scene）+ 深度（t_depth）
 *   - Sobel 算子检测深度边缘
 *   - 边缘像素混合描边颜色，输出到 writeBuffer
 */
public class ToonOutlinePass {
    /**
     * 待渲染场景（用于获取 depth attachment）。
     */
    public let renderScene: Scene

    /**
     * 待渲染相机。
     */
    public let renderCamera: Camera

    /**
     * 描边颜色（默认黑色）。
     * 对照 JS OutlinePass.visibleEdgeColor。
     */
    public var outlineColor: Color = Color(0.0, 0.0, 0.0)

    /**
     * 描边强度（0~1，边缘像素混合描边颜色的比例）。
     */
    public var outlineStrength: Float64 = 1.0

    /**
     * 边缘检测阈值（Sobel 算子输出超过此值则为边缘）。
     */
    public var edgeThreshold: Float64 = 0.001

    /**
     * pass 输出宽度（像素）。
     */
    private var _width: Int64 = 0

    /**
     * pass 输出高度（像素）。
     */
    private var _height: Int64 = 0

    /**
     * view id 基址（250，避开 EffectComposer 内部 view 0~9、
     * SSAO 160/Bloom 200/ShaderPass 200~209/SavePass 210/TexturePass 211/
     * OutputPass 212/SMAA 214~216/SSAA 217/TAA 219~220/MaskPass 220~221/
     * CubeTexturePass 222/OutlinePass 223~239 区段）。
     */
    public static let TOON_OUTLINE_VIEW_ID: UInt16 = 250u16

    /**
     * 渲染器引用（render() 时注入）。
     */
    private var _renderer: Option<BgfxRenderer> = None

    // ===== 全屏 quad 资源（懒创建） =====

    /**
     * 全屏 quad 顶点缓冲（4 顶点 × 5 floats = 20 floats）。
     */
    private var _quadVB: Option<VertexBufferHandle> = None

    /**
     * 全屏 quad 索引缓冲（6 索引）。
     */
    private var _quadIB: Option<IndexBufferHandle> = None

    /**
     * 全屏 quad 顶点 layout handle。
     */
    private var _quadLayout: Option<VertexLayoutHandle> = None

    // ===== 编译后 program handle 缓存 =====

    /**
     * ToonEdge shader 编译后的 program handle。
     */
    private var _edgeProg: Option<ProgramHandle> = None

    /**
     * 是否已编译 shader。
     */
    private var _shaderCompiled: Bool = false

    // ===== uniform 句柄缓存 =====

    private var _uTexelOffset: Option<UniformHandle> = None
    private var _uEdgeColor: Option<UniformHandle> = None
    private var _uEdgeThreshold: Option<UniformHandle> = None
    private var _samplerScene: Option<UniformHandle> = None
    private var _samplerDepth: Option<UniformHandle> = None

    /**
     * 构造 ToonOutlinePass。
     *
     * @param scene 待渲染场景
     * @param camera 待渲染相机
     *
     * 对照 JS: `constructor(resolution, scene, camera, selectedObjects)`。
     * 简化：本 pass 对整个场景做边缘检测，不区分 selectedObjects。
     */
    public init(scene: Scene, camera: Camera) {
        this.renderScene = scene
        this.renderCamera = camera
    }

    /**
     * 设置 pass 尺寸。
     * 对照 JS: `setSize(width, height)`。
     *
     * @param width 宽度（像素）
     * @param height 高度（像素）
     */
    public func setSize(width: Int64, height: Int64): Unit {
        this._width = width
        this._height = height
    }

    /**
     * 确保 ToonEdge shader 已编译。
     * 对照 JS: `this._ensureShaders()`。
     */
    private func _ensureShader(renderer: BgfxRenderer): Unit {
        if (this._shaderCompiled) { return }

        // 编译 ToonEdge shader（VS + FS）
        let vsMem = BgfxMemory(UInt32(TOON_EDGE_VS.size + 1))
        let vsBytes = TOON_EDGE_VS.toArray()
        unsafe {
            let ptr = vsMem.data()
            for (i in 0..vsBytes.size) { (ptr + Int64(i)).write(vsBytes[i]) }
            (ptr + Int64(vsBytes.size)).write(0u8)
        }
        let vshHandle = renderer.createShader(vsMem)

        let fsMem = BgfxMemory(UInt32(TOON_EDGE_FS.size + 1))
        let fsBytes = TOON_EDGE_FS.toArray()
        unsafe {
            let ptr = fsMem.data()
            for (i in 0..fsBytes.size) { (ptr + Int64(i)).write(fsBytes[i]) }
            (ptr + Int64(fsBytes.size)).write(0u8)
        }
        let fshHandle = renderer.createShader(fsMem)

        Logger.debug(["ToonOutline", "VS compile result idx=${vshHandle.value.idx}"])
        Logger.debug(["ToonOutline", "FS compile result idx=${fshHandle.value.idx}"])

        // 链接 program
        let prog = renderer.createProgram(vshHandle, fshHandle, true)
        Logger.debug(["ToonOutline", "Program link result idx=${prog.value.idx}"])
        if (isValidHandle(prog)) {
            this._edgeProg = Some(prog)
            this._shaderCompiled = true
        } else {
            Logger.error(["ToonOutline", "ToonEdge shader 编译失败"])
        }

        // 创建 uniform 句柄（缓存复用）
        this._uTexelOffset = Some(renderer.createUniform("u_texelOffset", UniformType.Vec4.value()))
        this._uEdgeColor = Some(renderer.createUniform("u_edgeColor", UniformType.Vec4.value()))
        this._uEdgeThreshold = Some(renderer.createUniform("u_edgeThreshold", UniformType.Vec4.value()))
        this._samplerScene = Some(renderer.createUniform("t_scene", UniformType.Sampler.value()))
        this._samplerDepth = Some(renderer.createUniform("t_depth", UniformType.Sampler.value()))
    }

    /**
     * 确保全屏四边形资源已创建（懒创建）。
     * 对照 FullScreenQuad.ensureResources 范式。
     *
     * @param renderer 渲染器
     */
    private func _ensureQuadResources(renderer: BgfxRenderer): Unit {
        match (this._quadVB) {
            case Some(_) => return
            case None => ()
        }

        // 4 顶点：position(xyz) + texcoord0(uv) = 5 floats × 4 = 20 floats
        // 全屏 NDC 坐标，UV 与纹理 V 同向（bgfx 纹理 v=0 顶 + quad 顶点布布自洽）
        let vertsF64: Array<Float64> = [
            -1.0, -1.0, 0.0,  0.0, 1.0,
             1.0, -1.0, 0.0,  1.0, 1.0,
             1.0,  1.0, 0.0,  1.0, 0.0,
            -1.0,  1.0, 0.0,  0.0, 0.0
        ]
        let mem = BgfxMemory(UInt32(vertsF64.size * 4))
        mem.writeFloats(vertsF64, Int64(vertsF64.size))

        // layout：position(3) + texcoord0(2)
        let layout = renderer.createVertexLayout(this._getQuadLayoutAttrs())
        this._quadLayout = Some(layout)

        this._quadVB = Some(renderer.createVertexBufferFromLayout(mem, layout, flags: 0u16))

        // 6 索引：两个三角形 (0,1,2) 和 (0,2,3)
        let indices: Array<UInt16> = [0u16, 1u16, 2u16, 0u16, 2u16, 3u16]
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
        this._quadIB = Some(renderer.createIndexBuffer(idxBgfxMem, flags: 0u16))
        idxPtrHolder.dispose()
    }

    /**
     * 构建全屏 quad 顶点布局属性描述。
     * 对照 FullScreenQuad._getQuadLayoutAttrs 范式：position(3) + texcoord0(2)。
     */
    private func _getQuadLayoutAttrs(): Array<BgfxAttributeDesc> {
        let list = ArrayList<BgfxAttributeDesc>()
        let pos = BgfxAttributeDesc()
        pos.attrib = Attrib.Position.value()
        pos.num = 3u8
        pos.attribType = AttribType.Float.value()
        pos.normalized = false
        pos.asInt = false
        list.add(pos)
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
     * 执行 ToonOutline pass。
     *
     * 流程：
     *   1. 编译 ToonEdge shader（首次）
     *   2. 创建全屏 quad 资源（首次）
     *   3. 设置 view：视口、渲染目标、clear
     *   4. 绑定 readBuffer 的 color + depth 到 shader sampler
     *   5. 设置 uniform（texelOffset/edgeColor/edgeThreshold）
     *   6. submit 全屏 quad
     *
     * @param renderer 渲染器
     * @param writeBuffer 写 buffer（本 pass 输出目标）
     * @param readBuffer 读 buffer（上一 pass 的场景渲染结果）
     * @param deltaTime 帧间隔
     */
    public func render(
        renderer: BgfxRenderer,
        writeBuffer: FrameBufferHandle,
        readBuffer: FrameBufferHandle,
        deltaTime: Float64
    ): Unit {
        this._renderer = Some(renderer)

        // 确保 shader 已编译
        this._ensureShader(renderer)
        match (this._edgeProg) {
            case None => return  // shader 编译失败，跳过
            case Some(_) => ()
        }

        // 确保全屏 quad 资源已创建
        this._ensureQuadResources(renderer)

        let viewId = ToonOutlinePass.TOON_OUTLINE_VIEW_ID
        let w = UInt16(renderer.width)
        let h = UInt16(renderer.height)

        // 1. 设置视口
        renderer.setViewRect(viewId, 0u16, 0u16, w, h)

        // 2. 设置渲染目标：writeBuffer
        renderer.setViewFrameBuffer(viewId, writeBuffer)

        // 3. 设置 clear（清颜色，保留深度）
        renderer.setViewClear(viewId, BgfxConstants.CLEAR_COLOR, 0x00000000u32, depth: 1.0f32, stencil: 0u8)

        // 4. 绑定 readBuffer 的 color attachment 0 到 t_scene sampler（stage 0）
        let sceneTex = renderer.getTexture(readBuffer, 0u8)
        match (this._samplerScene) {
            case Some(sampler) =>
                renderer.bindTexture(0u8, sampler, sceneTex, 0u32)
            case None => ()
        }

        // 5. 绑定 readBuffer 的 depth attachment 1 到 t_depth sampler（stage 1）
        // 注意：readBuffer 必须有 depth attachment（EffectComposer 的 RT 带 depth）
        let depthTex = renderer.getTexture(readBuffer, 1u8)
        match (this._samplerDepth) {
            case Some(sampler) =>
                renderer.bindTexture(1u8, sampler, depthTex, 0u32)
            case None => ()
        }

        // 6. 设置 uniform：texelOffset = (1/width, 1/height)
        let texelOffsetData = BgfxMemory(16u32)
        texelOffsetData.writeFloats([1.0 / Float64(w), 1.0 / Float64(h), 0.0, 0.0], 4)
        match (this._uTexelOffset) {
            case Some(u) => renderer.setUniform(u, texelOffsetData, num: 1u16)
            case None => ()
        }

        // 7. 设置 uniform：edgeColor = (outlineColor.rgb, outlineStrength)
        let edgeColorData = BgfxMemory(16u32)
        edgeColorData.writeFloats([
            this.outlineColor.r, this.outlineColor.g, this.outlineColor.b, this.outlineStrength
        ], 4)
        match (this._uEdgeColor) {
            case Some(u) => renderer.setUniform(u, edgeColorData, num: 1u16)
            case None => ()
        }

        // 8. 设置 uniform：edgeThreshold
        let thresholdData = BgfxMemory(16u32)
        thresholdData.writeFloats([this.edgeThreshold, 0.0, 0.0, 0.0], 4)
        match (this._uEdgeThreshold) {
            case Some(u) => renderer.setUniform(u, thresholdData, num: 1u16)
            case None => ()
        }

        // 9. 绑定全屏 quad VB/IB/layout + 设置 render state + submit
        match (this._quadVB) {
            case Some(vb) =>
                match (this._quadIB) {
                    case Some(ib) =>
                        match (this._quadLayout) {
                            case Some(layout) =>
                                // 渲染状态：写入 RGB+A，CCW 正面，启用深度测试
                                let state: UInt64 = BgfxConstants.WRITE_RGB | BgfxConstants.WRITE_A | BgfxConstants.FRONT_CCW
                                renderer.setVertexBufferWithLayout(0u8, vb, layout, startVertex: 0u32, numVertices: 0xFFFFFFFFu32)
                                renderer.setIndexBuffer(ib, firstIndex: 0u32, numIndices: 0xFFFFFFFFu32)
                                renderer.setState(state, rgba: 0x00000000u32)
                                match (this._edgeProg) {
                                    case Some(prog) =>
                                        renderer.submit(viewId, prog, depth: 0u32, blend: 0xFFu8)
                                    case None => ()
                                }
                            case None => ()
                        }
                    case None => ()
                }
            case None => ()
        }

        Logger.debug(["ToonOutline", "render done (Sobel edge detection)"])
    }

    /**
     * 释放 ToonOutlinePass 占用的 GPU 资源。
     * 对照 JS: `dispose()`。
     */
    public func dispose(): Unit {
        match (this._renderer) {
            case Some(renderer) =>
                match (this._quadVB) {
                    case Some(vb) =>
                        renderer.destroyVertexBuffer(vb)
                        this._quadVB = None
                    case None => ()
                }
                match (this._quadIB) {
                    case Some(ib) =>
                        renderer.destroyIndexBuffer(ib)
                        this._quadIB = None
                    case None => ()
                }
                match (this._quadLayout) {
                    case Some(layout) =>
                        renderer.destroyVertexLayout(layout)
                        this._quadLayout = None
                    case None => ()
                }
                match (this._edgeProg) {
                    case Some(prog) =>
                        renderer.destroyProgram(prog)
                        this._edgeProg = None
                    case None => ()
                }
            case None => ()
        }
    }
}
