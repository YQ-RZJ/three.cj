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
 * @file[zh-cn] Backend
 * @brief[zh-cn] 渲染后端抽象基类 — 即时命令模型
 * @explain[zh-cn] 定义即时命令模型：beginRender → draw → finishRender，每个调用立即转为 GPU 命令。bgfx 适配：bgfx 是延迟命令缓冲，Backend 的即时命令方法在内部映射为 bgfx 延迟调用。对照源码: three.js/src/renderers/common/Backend.js
 *
 * @file[en] Backend
 * @brief[en] Render backend abstract base class — immediate command model
 * @explain[en] Defines the immediate command model: beginRender → draw → finishRender, each call is immediately converted to a GPU command. bgfx adaptation: bgfx uses deferred command buffering, Backend's immediate command methods are internally mapped to bgfx deferred calls. Reference: three.js/src/renderers/common/Backend.js
 *
 * @package three.rendering.common
 */
package three.rendering.common

import three.rendering.buffer.*
import three.rendering.geometry.*
import three.scene.objects.*
import three.core.time.*
import three.rendering.rendertarget.*
import three.core.event.*
import three.rendering.textures.Texture
import three.rendering.cameras.*
import three.core.math.*
import three.rendering.materials.*
import three.scene.scenegraph.*
import three.scene.scenegraph.*
import bgfx4cj.bgfx.*
import std.collection.*

/**
 * @brief[zh-cn] 渲染对象占位接口，提供矩阵/几何体/材质/对象 ID 等查询方法
 * @explain[zh-cn] 本子 change 用 interface 占位，子 change 4（RenderList/ContextCollector）补全具体实现。
 *
 * @brief[en] Render object placeholder interface, providing matrix/geometry/material/object ID query methods
 * @explain[en] This change uses an interface placeholder; sub-change 4 (RenderList/ContextCollector) will provide concrete implementation.
 * IRenderObject：渲染对象占位接口
 */
public interface IRenderObject {
    /**
     * @brief[zh-cn] 返回 world matrix（16 个 Float64 列主序）
     *
     * @brief[en] Returns world matrix (16 Float64 column-major)
     */
    func getMatrix(): Array<Float64>
    /**
     * @brief[zh-cn] 返回几何体 ID
     *
     * @brief[en] Returns geometry ID
     */
    func getGeometryId(): Int64
    /**
     * @brief[zh-cn] 返回材质 ID
     *
     * @brief[en] Returns material ID
     */
    func getMaterialId(): Int64
    /**
     * @brief[zh-cn] 返回对象 ID
     *
     * @brief[en] Returns object ID
     */
    func getObjectId(): Int64
    /**
     * @brief[zh-cn] 返回节点链（用于变换矩阵）
     *
     * @brief[en] Returns node chain (for transform matrix)
     */
    func getNodeChain(): ArrayList<Object3D>
    /**
     * @brief[zh-cn] 返回渲染组索引
     *
     * @brief[en] Returns render group order
     */
    func getGroupOrder(): Float64
    /**
     * @brief[zh-cn] 返回渲染顺序
     *
     * @brief[en] Returns render order
     */
    func getRenderOrder(): Float64
}

/**
 * @brief[zh-cn] 渲染上下文占位接口，提供视图/视口/清除色/帧缓冲等查询方法
 *
 * @brief[en] Render context placeholder interface, providing view/viewport/clear color/framebuffer query methods
 */
public interface IRenderContext {
    /**
     * @brief[zh-cn] 返回 view ID
     *
     * @brief[en] Returns view ID
     */
    func getViewId(): UInt16
    /**
     * @brief[zh-cn] 返回视口 (x, y, w, h)
     *
     * @brief[en] Returns viewport (x, y, w, h)
     */
    func getViewport(): (Int32, Int32, UInt32, UInt32)
    /**
     * @brief[zh-cn] 返回清除颜色（UInt32 RGBA）
     *
     * @brief[en] Returns clear color (UInt32 RGBA)
     */
    func getClearColor(): UInt32
    /**
     * @brief[zh-cn] 返回帧缓冲对象（可为空）
     *
     * @brief[en] Returns framebuffer object (optional)
     */
    func getFrameBuffer(): Option<RenderTarget>
    /**
     * @brief[zh-cn] 返回场景
     *
     * @brief[en] Returns scene
     */
    func getScene(): Option<Scene>
    /**
     * @brief[zh-cn] 返回相机
     *
     * @brief[en] Returns camera
     */
    func getCamera(): Option<Camera>
}

/**
 * @brief[zh-cn] 渲染后端抽象基类
 * @explain[zh-cn] 定义即时命令模型全套接口。每个方法在子类（如 BgfxBackend）中实现具体的 GPU 命令映射。
 *
 * @brief[en] Render backend abstract base class
 * @explain[en] Defines the full set of interfaces for the immediate command model. Each method is implemented in subclasses (e.g. BgfxBackend) with concrete GPU command mapping.
 */
public open class Backend {
    /**
     * @brief[zh-cn] 后端类型标识（"WebGL"/"WebGPU"/"bgfx"）
     *
     * @brief[en] Backend type identifier ("WebGL"/"WebGPU"/"bgfx")
     */
    public var kind: String

    /**
     * @brief[zh-cn] 是否已初始化
     *
     * @brief[en] Whether the backend is initialized
     */
    public var initialized: Bool = false

    /**
     * @brief[zh-cn] 清除色（UInt32 RGBA）
     *
     * @brief[en] Clear color (UInt32 RGBA)
     */
    public var clearColor: UInt32 = 0x00000000u32

    /**
     * @brief[zh-cn] 平台窗口句柄
     *
     * @brief[en] Platform window handle
     */
    public var hwnd: Option<UIntNative> = None

    /**
     * @brief[zh-cn] 渲染器引用
     *
     * @brief[en] Renderer reference
     */
    public var renderer: Option<Renderer> = None

    /**
     * @brief[zh-cn] 坐标系统（默认 2000 = WebGPUCoordinateSystem）
     *
     * @brief[en] Coordinate system (default 2000 = WebGPUCoordinateSystem)
     */
    public var coordinateSystem: Int64 = 2000

    public init() {
        this.kind = "Backend"
    }

    // ===== 初始化与生命周期 =====

    /**
     * @brief[zh-cn] 初始化渲染后端
     * @param[zh-cn] renderer 渲染器实例
     *
     * @brief[en] Initialize the render backend
     * @param[en] renderer Renderer instance
     */
    public open func initialize(renderer: Renderer): Unit {
        this.renderer = Some(renderer)
        this.initialized = true
    }

    // ===== 即时命令模型核心方法 =====

    /**
     * @brief[zh-cn] 开始渲染 pass
     * @param[zh-cn] renderContext 渲染上下文
     *
     * @brief[en] Begin render pass
     * @param[en] renderContext Render context
     */
    public open func beginRender(renderContext: IRenderContext): Unit {
        let (_, _, vw, vh) = renderContext.getViewport()
        bgfx_set_view_rect_cj(renderContext.getViewId(), 0, 0, UInt16(vw), UInt16(vh))
    }

    /**
     * @brief[zh-cn] 执行 draw 调用
     * @param[zh-cn] renderObject 渲染对象
     *
     * @brief[en] Execute draw call
     * @param[en] renderObject Render object
     */
    public open func draw(renderObject: IRenderObject): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 结束渲染 pass
     * @param[zh-cn] renderContext 渲染上下文
     *
     * @brief[en] Finish render pass
     * @param[en] renderContext Render context
     */
    public open func finishRender(renderContext: IRenderContext): Unit {
        bgfx_frame_cj(false)
    }

    /**
     * @brief[zh-cn] 阴影深度预 pass 钩子，基类默认抛异常，子类 override 实现具体阴影深度 pass
     * @param[zh-cn] scene 渲染场景（含光源与 caster 几何体）
     *
     * @brief[en] Shadow depth pre-pass hook, base class throws exception by default, subclass override implements concrete shadow depth pass
     * @param[en] scene Render scene (contains lights and caster geometry)
     */
    public open func prepareShadowMap(scene: Scene): Unit {
        // 诊断 override：若子类 override 没生效，运行时会炸这里
        throw Exception("Backend.prepareShadowMap base no-op called — override not dispatched!")
    }

    /**
     * @brief[zh-cn] 绑定阴影 uniform 到主 pass draw，基类默认抛异常
     *
     * @brief[en] Bind shadow uniforms to main pass draw, base class throws exception by default
     */
    public open func bindShadowUniforms(): Unit {
        throw Exception("Backend.bindShadowUniforms base no-op called — override not dispatched!")
    }

    /**
     * @brief[zh-cn] 全屏 blit 阴影贴图到屏幕（debug 模式用），基类默认抛异常
     * @param[zh-cn] mainViewId 主渲染 view ID（blit 输出目标）
     *
     * @brief[en] Full-screen blit shadow map to screen (for debug mode), base class throws exception by default
     * @param[en] mainViewId Main render view ID (blit output target)
     */
    public open func blitShadowMap(mainViewId: UInt16): Unit {
        throw Exception("Backend.blitShadowMap base no-op called — override not dispatched!")
    }

    /**
     * @brief[zh-cn] 清除缓冲
     * @param[zh-cn] renderContext 渲染上下文
     * color 是否清除颜色缓冲
     * depth 是否清除深度缓冲
     * stencil 是否清除模板缓冲
     *
     * @brief[en] Clear buffers
     * @param[en] renderContext Render context
     * color Whether to clear color buffer
     * depth Whether to clear depth buffer
     * stencil Whether to clear stencil buffer
     */
    public open func clear(renderContext: IRenderContext, color: Bool, depth: Bool, stencil: Bool): Unit {
        var clearFlags: UInt16 = 0u16
        if (color) { clearFlags = clearFlags | CLEAR_COLOR }
        if (depth) { clearFlags = clearFlags | CLEAR_DEPTH }
        if (stencil) { clearFlags = clearFlags | CLEAR_STENCIL }
        bgfx_set_view_clear_cj(renderContext.getViewId(), clearFlags, renderContext.getClearColor(), 1.0f32, 0)
    }

    /**
     * @brief[zh-cn] 解析渲染目标
     * @param[zh-cn] renderTarget 渲染目标
     *
     * @brief[en] Resolve render target
     * @param[en] renderTarget Render target
     */
    public open func resolveRenderTarget(renderTarget: RenderTarget): Unit {
        // base: no-op
    }

    // ===== 纹理/资源操作 =====

    /**
     * @brief[zh-cn] Blit 操作，从源纹理复制到目标纹理
     * @param[zh-cn] textureSrc 源纹理
     * textureDst 目标纹理
     * viewId view ID
     *
     * @brief[en] Blit operation, copy from source texture to destination texture
     * @param[en] textureSrc Source texture
     * textureDst Destination texture
     * viewId View ID
     */
    public open func blit(textureSrc: Texture, textureDst: Texture, viewId: UInt16): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 拷贝纹理
     * @param[zh-cn] textureSrc 源纹理
     * textureDst 目标纹理
     *
     * @brief[en] Copy texture
     * @param[en] textureSrc Source texture
     * textureDst Destination texture
     */
    public open func copyTo(textureSrc: Texture, textureDst: Texture): Unit {
        // base: no-op
    }

    // ===== Compute 相关（可选） =====

    /**
     * @brief[zh-cn] 开始 compute pass
     * @param[zh-cn] computeContext 计算管线
     *
     * @brief[en] Begin compute pass
     * @param[en] computeContext Compute pipeline
     */
    public open func beginCompute(computeContext: ComputePipeline): Unit {
        throw Exception("beginCompute not implemented")
    }

    /**
     * @brief[zh-cn] 执行 compute dispatch
     * @param[zh-cn] computeNode 计算节点
     *
     * @brief[en] Execute compute dispatch
     * @param[en] computeNode Compute node
     */
    public open func compute(computeNode: ComputePipeline): Unit {
        throw Exception("compute not implemented")
    }

    /**
     * @brief[zh-cn] 结束 compute pass
     * @param[zh-cn] computeContext 计算管线
     *
     * @brief[en] Finish compute pass
     * @param[en] computeContext Compute pipeline
     */
    public open func finishCompute(computeContext: ComputePipeline): Unit {
        throw Exception("finishCompute not implemented")
    }

    // ===== 管线/绑定/程序/采样器/纹理创建 =====

    /**
     * @brief[zh-cn] 创建管线
     * @param[zh-cn] renderObject 渲染对象
     * @return[zh-cn] 计算管线实例
     *
     * @brief[en] Create pipeline
     * @param[en] renderObject Render object
     * @return[en] Compute pipeline instance
     */
    public open func createPipeline(renderObject: IRenderObject): ComputePipeline {
        // base: no-op
        return ComputePipeline()
    }

    /**
     * @brief[zh-cn] 创建绑定
     * @param[zh-cn] bindings 绑定对象
     *
     * @brief[en] Create bindings
     * @param[en] bindings Bindings object
     */
    public open func createBindings(bindings: Bindings): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 创建程序
     * @param[zh-cn] program 可编程阶段
     *
     * @brief[en] Create program
     * @param[en] program Programmable stage
     */
    public open func createProgram(program: ProgrammableStage): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 创建采样器
     * @param[zh-cn] sampler 采样器
     *
     * @brief[en] Create sampler
     * @param[en] sampler Sampler
     */
    public open func createSampler(sampler: Sampler): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 创建纹理
     * @param[zh-cn] texture 纹理
     *
     * @brief[en] Create texture
     * @param[en] texture Texture
     */
    public open func createTexture(texture: Texture): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 更新纹理
     * @param[zh-cn] texture 纹理
     *
     * @brief[en] Update texture
     * @param[en] texture Texture
     */
    public open func updateTexture(texture: Texture): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 销毁纹理
     * @param[zh-cn] texture 纹理
     *
     * @brief[en] Destroy texture
     * @param[en] texture Texture
     */
    public open func destroyTexture(texture: Texture): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 生成 mipmap
     * @param[zh-cn] texture 纹理
     *
     * @brief[en] Generate mipmaps
     * @param[en] texture Texture
     */
    public open func generateMipmaps(texture: Texture): Unit {
        // base: no-op
    }

    // ===== 销毁 =====

    /**
     * @brief[zh-cn] 销毁后端，释放资源
     *
     * @brief[en] Dispose backend and release resources
     */
    public open func dispose(): Unit {
        this.initialized = false
    }

    // ===== 向后兼容重载（与既有 Renderer/BgfxBackend 配合）=====

    /**
     * @brief[zh-cn] beginRender 重载，接受 RenderContext 具体类
     * @param[zh-cn] renderContext 渲染上下文
     *
     * @brief[en] beginRender overload, accepts concrete RenderContext class
     * @param[en] renderContext Render context
     */
    public open func beginRender(renderContext: RenderContext): Unit {
        let (x, y, w, h) = renderContext.viewport
        bgfx_set_view_rect_cj(0, UInt16(x), UInt16(y), UInt16(w), UInt16(h))
    }

    /**
     * @brief[zh-cn] finishRender 重载，接受 RenderContext 具体类
     * @param[zh-cn] renderContext 渲染上下文
     *
     * @brief[en] finishRender overload, accepts concrete RenderContext class
     * @param[en] renderContext Render context
     */
    public open func finishRender(renderContext: RenderContext): Unit {
        bgfx_frame_cj(false)
    }

    /**
     * @brief[zh-cn] clear 重载，接受 RenderContext 具体类
     * @param[zh-cn] renderContext 渲染上下文
     * color 是否清除颜色缓冲
     * depth 是否清除深度缓冲
     * stencil 是否清除模板缓冲
     *
     * @brief[en] clear overload, accepts concrete RenderContext class
     * @param[en] renderContext Render context
     * color Whether to clear color buffer
     * depth Whether to clear depth buffer
     * stencil Whether to clear stencil buffer
     */
    public open func clear(renderContext: RenderContext, color: Bool, depth: Bool, stencil: Bool): Unit {
        var clearFlags: UInt16 = 0u16
        if (color) { clearFlags = clearFlags | CLEAR_COLOR }
        if (depth) { clearFlags = clearFlags | CLEAR_DEPTH }
        if (stencil) { clearFlags = clearFlags | CLEAR_STENCIL }
        bgfx_set_view_clear_cj(0, clearFlags, UInt32(renderContext.depthClearValue), 1.0f32, 0)
    }

    /**
     * @brief[zh-cn] clear 无参数版本（旧版兼容）
     *
     * @brief[en] clear no-argument version (legacy compatibility)
     */
    public open func clear(): Unit {
        bgfx_frame_cj(false)
    }

    /**
     * @brief[zh-cn] draw 旧版兼容（geometry + material）
     * @param[zh-cn] geometry 缓冲几何体
     * material 材质
     *
     * @brief[en] draw legacy compatibility (geometry + material)
     * @param[en] geometry Buffer geometry
     * material Material
     */
    public open func draw(geometry: BufferGeometry, material: Material): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] destroy 是 dispose 的别名（旧版兼容）
     *
     * @brief[en] destroy is an alias of dispose (legacy compatibility)
     */
    public open func destroy(): Unit {
        this.dispose()
    }

    // ===== 视口/裁剪/清除颜色（向下兼容已有 Backend 方法） =====

    /**
     * @brief[zh-cn] 设置视口
     * @param[zh-cn] x 视口 X 坐标
     * y 视口 Y 坐标
     * w 视口宽度
     * h 视口高度
     *
     * @brief[en] Set viewport
     * @param[en] x Viewport X coordinate
     * y Viewport Y coordinate
     * w Viewport width
     * h Viewport height
     */
    public open func setViewport(x: Int32, y: Int32, w: Int32, h: Int32): Unit {
        bgfx_set_view_rect_cj(0, UInt16(x), UInt16(y), UInt16(w), UInt16(h))
    }

    /**
     * @brief[zh-cn] 设置裁剪区域
     * @param[zh-cn] x 裁剪区域 X 坐标
     * y 裁剪区域 Y 坐标
     * w 裁剪区域宽度
     * h 裁剪区域高度
     *
     * @brief[en] Set scissor region
     * @param[en] x Scissor X coordinate
     * y Scissor Y coordinate
     * w Scissor width
     * h Scissor height
     */
    public open func setScissor(x: Int32, y: Int32, w: Int32, h: Int32): Unit {
        // base: no-op
    }

    /**
     * @brief[zh-cn] 设置清除颜色
     * @param[zh-cn] color 清除颜色（UInt32 RGBA）
     *
     * @brief[en] Set clear color
     * @param[en] color Clear color (UInt32 RGBA)
     */
    public open func setClearColor(color: UInt32): Unit {
        bgfx_set_view_clear_cj(0, CLEAR_COLOR | CLEAR_DEPTH, color, 1.0f32, 0)
    }

    // ===== 能力查询 =====

    /**
     * @brief[zh-cn] 获取最大纹理尺寸
     * @return[zh-cn] 最大纹理尺寸
     *
     * @brief[en] Get maximum texture size
     * @return[en] Maximum texture size
     */
    public open func getMaxTextureSize(): Int64 { return 4096 }
    /**
     * @brief[zh-cn] 获取最大各向异性
     * @return[zh-cn] 最大各向异性值
     *
     * @brief[en] Get maximum anisotropy
     * @return[en] Maximum anisotropy value
     */
    public open func getMaxAnisotropy(): Int64 { return 16 }
    /**
     * @brief[zh-cn] 查询是否支持指定特性
     * @param[zh-cn] name 特性名称
     * @return[zh-cn] 是否支持
     *
     * @brief[en] Query whether a specified feature is supported
     * @param[en] name Feature name
     * @return[en] Whether supported
     */
    public open func hasFeature(name: String): Bool { return false }
}
