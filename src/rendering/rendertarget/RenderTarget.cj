/**
 * @file[zh-cn] 渲染目标
 * @brief[zh-cn] 几何缓冲区（颜色、可选深度/模板）的持包，用于离屏渲染
 * @explain[zh-cn] 在 bgfx 渲染后端中，渲染目标对应 bgfx 的 FrameBuffer handle。本类仅持有描述性字段（width/height/depth/scissor/viewport/textures/samples 等），具体 GPU 句柄实现推迟到 Level 8 由 bgfx4cj 接管。对照源码: Three.js RenderTarget.js
 *
 * @file[en] Render Target
 * @brief[en] Holder for geometry buffers (color, optional depth/stencil), used for off-screen rendering
 * @explain[en] In the bgfx rendering backend, render targets correspond to bgfx's FrameBuffer handle. This class only holds descriptive fields (width/height/depth/scissor/viewport/textures/samples, etc.), and the actual GPU handle implementation is deferred to Level 8 managed by bgfx4cj. Reference: Three.js RenderTarget.js
 */
package three.rendering.rendertarget

import three.core.math.*
import three.core.event.*
import three.utils.constants.*
import std.collection.*
import fastjson.*
import fastjson.macros.*

/**
 * @brief[zh-cn] 渲染目标选项
 * @explain[zh-cn] 用于构造 RenderTarget 时描述纹理与缓冲配置：generateMipmaps、magFilter/minFilter、format/type、internalFormat、wrapS/wrapT/wrapR、anisotropy、colorSpace、depthBuffer/stencilBuffer、resolveColorBuffer/resolveDepthBuffer/resolveStencilBuffer、storeMultisampledColorBuffer/storeMultisampledDepthBuffer/storeMultisampledStencilBuffer、depthTexture、samples、count、depth、multiview、useArrayDepthTexture。
 *
 * @brief[en] Render target options
 * @explain[en] Used when constructing a RenderTarget to describe texture and buffer configuration: generateMipmaps, magFilter/minFilter, format/type, internalFormat, wrapS/wrapT/wrapR, anisotropy, colorSpace, depthBuffer/stencilBuffer, resolveColorBuffer/resolveDepthBuffer/resolveStencilBuffer, storeMultisampledColorBuffer/storeMultisampledDepthBuffer/storeMultisampledStencilBuffer, depthTexture, samples, count, depth, multiview, useArrayDepthTexture.
 */
public class RenderTargetOptions {
    /**
     * @brief[zh-cn] 是否生成 mipmap
     *
     * @brief[en] Whether to generate mipmaps
     */
    public var generateMipmaps: Bool
    /**
     * @brief[zh-cn] 放大过滤模式
     *
     * @brief[en] Magnification filter mode
     */
    public var magFilter: Int64
    /**
     * @brief[zh-cn] 缩小过滤模式
     *
     * @brief[en] Minification filter mode
     */
    public var minFilter: Int64
    /**
     * @brief[zh-cn] 纹理格式
     *
     * @brief[en] Texture format
     */
    public var format: Int64
    /**
     * @brief[zh-cn] 纹理数据类型
     *
     * @brief[en] Texture data type
     */
    public var `type`: Int64
    /**
     * @brief[zh-cn] 内部格式（可选）
     *
     * @brief[en] Internal format (optional)
     */
    public var internalFormat: ?String
    /**
     * @brief[zh-cn] S 轴包裹模式
     *
     * @brief[en] S-axis wrapping mode
     */
    public var wrapS: Int64
    /**
     * @brief[zh-cn] T 轴包裹模式
     *
     * @brief[en] T-axis wrapping mode
     */
    public var wrapT: Int64
    /**
     * @brief[zh-cn] R 轴包裹模式
     *
     * @brief[en] R-axis wrapping mode
     */
    public var wrapR: Int64
    /**
     * @brief[zh-cn] 各向异性过滤值
     *
     * @brief[en] Anisotropy filtering value
     */
    public var anisotropy: Int64
    /**
     * @brief[zh-cn] 颜色空间
     *
     * @brief[en] Color space
     */
    public var colorSpace: String
    /**
     * @brief[zh-cn] 是否分配深度缓冲
     *
     * @brief[en] Whether to allocate a depth buffer
     */
    public var depthBuffer: Bool
    /**
     * @brief[zh-cn] 是否分配模板缓冲
     *
     * @brief[en] Whether to allocate a stencil buffer
     */
    public var stencilBuffer: Bool
    /**
     * @brief[zh-cn] 是否解析颜色缓冲
     *
     * @brief[en] Whether to resolve the color buffer
     */
    public var resolveColorBuffer: Bool
    /**
     * @brief[zh-cn] 是否解析深度缓冲
     *
     * @brief[en] Whether to resolve the depth buffer
     */
    public var resolveDepthBuffer: Bool
    /**
     * @brief[zh-cn] 是否解析模板缓冲
     *
     * @brief[en] Whether to resolve the stencil buffer
     */
    public var resolveStencilBuffer: Bool
    /**
     * @brief[zh-cn] 是否存储多采样颜色缓冲
     *
     * @brief[en] Whether to store multisampled color buffer
     */
    public var storeMultisampledColorBuffer: Bool
    /**
     * @brief[zh-cn] 是否存储多采样深度缓冲
     *
     * @brief[en] Whether to store multisampled depth buffer
     */
    public var storeMultisampledDepthBuffer: Bool
    /**
     * @brief[zh-cn] 是否存储多采样模板缓冲
     *
     * @brief[en] Whether to store multisampled stencil buffer
     */
    public var storeMultisampledStencilBuffer: Bool
    /**
     * @brief[zh-cn] 深度纹理引用（可选）
     *
     * @brief[en] Depth texture reference (optional)
     */
    public var depthTexture: ?IRenderTargetTexture
    /**
     * @brief[zh-cn] MSAA 采样数，0 表示禁用
     *
     * @brief[en] MSAA sample count, 0 means disabled
     */
    public var samples: Int64
    /**
     * @brief[zh-cn] 颜色附件数量
     *
     * @brief[en] Color attachment count
     */
    public var count: Int64
    /**
     * @brief[zh-cn] 纹理深度
     *
     * @brief[en] Texture depth
     */
    public var depth: Int64
    /**
     * @brief[zh-cn] 是否用于 multiview 渲染
     *
     * @brief[en] Whether to use for multiview rendering
     */
    public var multiview: Bool
    /**
     * @brief[zh-cn] 是否创建为分层深度纹理
     *
     * @brief[en] Whether to create as array depth texture
     */
    public var useArrayDepthTexture: Bool

    /**
     * @brief[zh-cn] 构造渲染目标选项，使用默认值
     *
     * @brief[en] Construct render target options with default values
     */
    public init() {
        this.generateMipmaps = false
        this.magFilter = LinearFilter
        this.minFilter = LinearFilter
        this.format = RGBAFormat
        this.`type` = UnsignedByteType
        this.internalFormat = None
        this.wrapS = ClampToEdgeWrapping
        this.wrapT = ClampToEdgeWrapping
        this.wrapR = ClampToEdgeWrapping
        this.anisotropy = 1
        this.colorSpace = NoColorSpace
        this.depthBuffer = true
        this.stencilBuffer = false
        this.resolveColorBuffer = true
        this.resolveDepthBuffer = true
        this.resolveStencilBuffer = true
        this.storeMultisampledColorBuffer = true
        this.storeMultisampledDepthBuffer = true
        this.storeMultisampledStencilBuffer = true
        this.depthTexture = None
        this.samples = 0
        this.count = 1
        this.depth = 1
        this.multiview = false
        this.useArrayDepthTexture = false
    }
}

/**
 * @brief[zh-cn] 渲染目标类，存储离屏渲染缓冲描述
 * @explain[zh-cn] 使用示例：let rt = RenderTarget(512, 512); rt.setSize(1024, 1024); renderer.setRenderTarget(rt)。继承自 EventDispatcher，管理离屏渲染的颜色/深度/模板缓冲及纹理附件。
 *
 * @brief[en] Render target class, storing off-screen render buffer description
 * @explain[en] Usage example: let rt = RenderTarget(512, 512); rt.setSize(1024, 1024); renderer.setRenderTarget(rt). Extends EventDispatcher, managing off-screen rendering color/depth/stencil buffers and texture attachments.
 */
public open class RenderTarget <: EventDispatcher {
    /**
     * @brief[zh-cn] 几何体类型字符串
     *
     * @brief[en] Geometry type string
     */
    public var kind: String

    /**
     * @brief[zh-cn] 渲染目标宽度
     *
     * @brief[en] Render target width
     */
    public var width: Int64

    /**
     * @brief[zh-cn] 渲染目标高度
     *
     * @brief[en] Render target height
     */
    public var height: Int64

    /**
     * @brief[zh-cn] 渲染目标深度
     *
     * @brief[en] Render target depth
     */
    public var depth: Int64

    /**
     * @brief[zh-cn] 渲染目标内的矩形裁剪区域，区域外的片元会被丢弃
     *
     * @brief[en] Scissor rectangle within the render target, fragments outside are discarded
     */
    public var scissor: Vector4

    /**
     * @brief[zh-cn] 是否在渲染到此目标时启用 scissor 测试
     *
     * @brief[en] Whether to enable scissor test when rendering to this target
     */
    public var scissorTest: Bool

    /**
     * @brief[zh-cn] 渲染目标的视口矩形
     *
     * @brief[en] Viewport rectangle of the render target
     */
    public var viewport: Vector4

    /**
     * @brief[zh-cn] 纹理数组，每个颜色附件用一个独立纹理表示，至少有一个默认颜色附件条目
     *
     * @brief[en] Texture array, each color attachment represented by an independent texture, at least one default color attachment entry
     */
    public var textures: ArrayList<Option<IRenderTargetTexture>>

    /**
     * @brief[zh-cn] 是否分配深度缓冲
     *
     * @brief[en] Whether to allocate a depth buffer
     */
    public var depthBuffer: Bool

    /**
     * @brief[zh-cn] 是否分配模板缓冲
     *
     * @brief[en] Whether to allocate a stencil buffer
     */
    public var stencilBuffer: Bool

    /**
     * @brief[zh-cn] 是否解析颜色缓冲（仅多采样渲染目标相关），设为 false 时颜色附件不接收解析输出
     *
     * @brief[en] Whether to resolve the color buffer (only for multisampled render targets), when false the color attachment does not receive resolve output
     */
    public var resolveColorBuffer: Bool

    /**
     * @brief[zh-cn] 是否解析深度缓冲（仅多采样渲染目标相关），设为 false 节省内存带宽
     *
     * @brief[en] Whether to resolve the depth buffer (only for multisampled render targets), when false saves memory bandwidth
     */
    public var resolveDepthBuffer: Bool

    /**
     * @brief[zh-cn] 是否解析模板缓冲
     *
     * @brief[en] Whether to resolve the stencil buffer
     */
    public var resolveStencilBuffer: Bool

    /**
     * @brief[zh-cn] 是否存储多采样颜色缓冲，设为 false 在 render pass 结束后丢弃多采样数据
     *
     * @brief[en] Whether to store multisampled color buffer, when false discards multisampled data after render pass
     */
    public var storeMultisampledColorBuffer: Bool

    /**
     * @brief[zh-cn] 是否存储多采样深度缓冲，设为 false 节省带宽；WebGPU 中若需采样多采样深度纹理须为 true
     *
     * @brief[en] Whether to store multisampled depth buffer, when false saves bandwidth; must be true in WebGPU if sampling multisampled depth texture
     */
    public var storeMultisampledDepthBuffer: Bool

    /**
     * @brief[zh-cn] 是否存储多采样模板缓冲
     *
     * @brief[en] Whether to store multisampled stencil buffer
     */
    public var storeMultisampledStencilBuffer: Bool

    /**
     * @brief[zh-cn] 深度纹理内部引用
     */
    private var _depthTexture: ?IRenderTargetTexture

    /**
     * @brief[zh-cn] MSAA 采样数，0 表示禁用 MSAA
     *
     * @brief[en] MSAA sample count, 0 means MSAA disabled
     */
    public var samples: Int64

    /**
     * @brief[zh-cn] 是否用于 multiview 渲染（WebGL OVR_multiview2 扩展）
     *
     * @brief[en] Whether to use for multiview rendering (WebGL OVR_multiview2 extension)
     */
    public var multiview: Bool

    /**
     * @brief[zh-cn] 是否创建为分层深度纹理（独立于 multiview）
     *
     * @brief[en] Whether to create as array depth texture (independent of multiview)
     */
    public var useArrayDepthTexture: Bool

    /**
     * @brief[zh-cn] 自定义数据存储对象
     *
     * @brief[en] Custom data storage object
     */
    public var userData: HashMap<String, Any>

    /**
     * @brief[zh-cn] 构造新的渲染目标
     * @param[zh-cn] width 渲染目标宽度，默认为 1
     * height 渲染目标高度，默认为 1
     * options 渲染目标选项，默认为空（使用默认值）
     *
     * @brief[en] Construct a new render target
     * @param[en] width Render target width, defaults to 1
     * height Render target height, defaults to 1
     * options Render target options, defaults to None (use default values)
     */
    public init(width!: Int64 = 1, height!: Int64 = 1, options!: ?RenderTargetOptions = None) {
        this.kind = "RenderTarget"
        this.width = width
        this.height = height
        let opts = match (options) { case Some(o) => o; case None => RenderTargetOptions() }
        this.depth = opts.depth
        this.scissor = Vector4(0.0, 0.0, Float64(width), Float64(height))
        this.scissorTest = false
        this.viewport = Vector4(0.0, 0.0, Float64(width), Float64(height))
        this.textures = ArrayList<Option<IRenderTargetTexture>>()
        // Ignore: 纹理由 Level 5 Texture 实现；此处仅占位填充 count 个空槽（None），语义对齐 JS RenderTarget。
        for (_ in 0..opts.count) {
            this.textures.add(None)
        }
        this.depthBuffer = opts.depthBuffer
        this.stencilBuffer = opts.stencilBuffer
        this.resolveColorBuffer = opts.resolveColorBuffer
        this.resolveDepthBuffer = opts.resolveDepthBuffer
        this.resolveStencilBuffer = opts.resolveStencilBuffer
        this.storeMultisampledColorBuffer = opts.storeMultisampledColorBuffer
        this.storeMultisampledDepthBuffer = opts.storeMultisampledDepthBuffer
        this.storeMultisampledStencilBuffer = opts.storeMultisampledStencilBuffer
        this._depthTexture = opts.depthTexture
        this.samples = opts.samples
        this.multiview = opts.multiview
        this.useArrayDepthTexture = opts.useArrayDepthTexture
        this.userData = HashMap<String, Any>()
    }

    /**
     * @brief[zh-cn] 兼容重载：2 参数形式（options 为空）
     *
     * @brief[en] Compatibility overload: 2-parameter form (options is None)
     */
    public init(width: Int64, height: Int64) {
        this.kind = "RenderTarget"
        this.width = width
        this.height = height
        this.depth = 1
        this.scissor = Vector4(0.0, 0.0, Float64(width), Float64(height))
        this.scissorTest = false
        this.viewport = Vector4(0.0, 0.0, Float64(width), Float64(height))
        this.textures = ArrayList<Option<IRenderTargetTexture>>()
        this.textures.add(None)
        this.depthBuffer = true
        this.stencilBuffer = false
        this.resolveColorBuffer = true
        this.resolveDepthBuffer = true
        this.resolveStencilBuffer = true
        this.storeMultisampledColorBuffer = true
        this.storeMultisampledDepthBuffer = true
        this.storeMultisampledStencilBuffer = true
        this._depthTexture = None
        this.samples = 0
        this.multiview = false
        this.useArrayDepthTexture = false
        this.userData = HashMap<String, Any>()
    }

    /**
     * @brief[zh-cn] 获取默认颜色附件纹理
     * @return[zh-cn] 默认颜色附件纹理（textures[0]）
     *
     * @brief[en] Get the default color attachment texture
     * @return[en] Default color attachment texture (textures[0])
     */
    public func getTexture(): Option<IRenderTargetTexture> {
        return this.textures[0]
    }

    /**
     * @brief[zh-cn] 设置默认颜色附件纹理
     * @param[zh-cn] value 纹理值
     *
     * @brief[en] Set the default color attachment texture
     * @param[en] value Texture value
     */
    public func setTexture(value: Option<IRenderTargetTexture>): Unit {
        this.textures[0] = value
    }

    /**
     * @brief[zh-cn] 获取深度纹理
     * @return[zh-cn] 深度纹理
     *
     * @brief[en] Get the depth texture
     * @return[en] Depth texture
     */
    public func getDepthTexture(): ?IRenderTargetTexture {
        return this._depthTexture
    }

    /**
     * @brief[zh-cn] 设置深度纹理，会解绑旧纹理的反向引用并建立新纹理的反向引用
     * @param[zh-cn] current 新的深度纹理
     *
     * @brief[en] Set depth texture, unbinds old texture back reference and establishes new texture back reference
     * @param[en] current New depth texture
     */
    public func setDepthTexture(current: ?IRenderTargetTexture): Unit {
        
        // 解 RT 纹理反向引用：跨包循环依赖通过 core 侧 IRenderTargetTexture 接口解除，
        // 旧/新纹理的具体类型 Texture 在 textures 包中实现本接口，core 经接口访问。
        match (this._depthTexture) {
            case Some(old) => old.rtRenderTarget = None
            case None => ()
        }
        
        match (current) {
            case Some(c) => c.rtRenderTarget = Some(this)
            case None => ()
        }
        this._depthTexture = current
    }

    /**
     * @brief[zh-cn] 设置此渲染目标的大小
     * @param[zh-cn] width 新的宽度
     * height 新的高度
     * depth 新的深度，默认为 1
     *
     * @brief[en] Set the size of this render target
     * @param[en] width New width
     * height New height
     * depth New depth, defaults to 1
     */
    public func setSize(width: Int64, height: Int64, depth!: Int64 = 1): Unit {
        if (this.width != width || this.height != height || this.depth != depth) {
            this.width = width
            this.height = height
            this.depth = depth
            
            for (i in 0..this.textures.size) {
                match (this.textures[i]) {
                    case Some(tex) =>
                        tex.rtWidth = width
                        tex.rtHeight = height
                        tex.rtDepth = depth
                        
                        if (!tex.rtIsData3DTexture()) {
                            tex.rtIsArrayTexture = depth > 1
                        }
                    case None => ()
                }
            }
            this.dispose()
        }
        this.viewport.set(0.0, 0.0, Float64(width), Float64(height))
        this.scissor.set(0.0, 0.0, Float64(width), Float64(height))
    }

    /**
     * @brief[zh-cn] 返回从此实例复制值的新渲染目标
     * @return[zh-cn] 此实例的克隆
     *
     * @brief[en] Return a new render target with values copied from this instance
     * @return[en] Clone of this instance
     */
    public open func clone(): RenderTarget {
        let rt = RenderTarget()
        return rt.copy(this)
    }

    /**
     * @brief[zh-cn] 将给定渲染目标的设置复制到此实例
     * @param[zh-cn] source 要复制的渲染目标
     * @return[zh-cn] 当前实例的引用
     *
     * @brief[en] Copy settings from the given render target to this instance
     * @param[en] source Render target to copy from
     * @return[en] Reference to this instance
     */
    public func copy(source: RenderTarget): RenderTarget {
        this.width = source.width
        this.height = source.height
        this.depth = source.depth
        this.scissor.copy(source.scissor)
        this.scissorTest = source.scissorTest
        this.viewport.copy(source.viewport)
        this.textures.clear()
        for (i in 0..source.textures.size) {
            
            // 解循环依赖：纹理类型 Texture 在 textures 包中实现 IRenderTargetTexture 接口，
            // core 侧经接口访问，避免 core→textures 反向导入。
            match (source.textures[i]) {
                case Some(srcTex) =>
                    let cloned = srcTex.rtClone()
                    cloned.rtIsRenderTargetTexture = true
                    cloned.rtRenderTarget = Some(this)
                    this.textures.add(Some(cloned))
                case None =>
                    // 空槽直接复制 None
                    this.textures.add(None)
            }
        }
        this.depthBuffer = source.depthBuffer
        this.stencilBuffer = source.stencilBuffer
        this.resolveColorBuffer = source.resolveColorBuffer
        this.resolveDepthBuffer = source.resolveDepthBuffer
        this.resolveStencilBuffer = source.resolveStencilBuffer
        this.storeMultisampledColorBuffer = source.storeMultisampledColorBuffer
        this.storeMultisampledDepthBuffer = source.storeMultisampledDepthBuffer
        this.storeMultisampledStencilBuffer = source.storeMultisampledStencilBuffer
        
        match (source._depthTexture) {
            case Some(srcDepth) =>
                match (srcDepth) {
                    case srcDepthTex: IRenderTargetTexture =>
                        let clonedDepth = srcDepthTex.rtClone()
                        this.setDepthTexture(Some(clonedDepth))
                    case _ => this._depthTexture = source._depthTexture
                }
            case None => this._depthTexture = None
        }
        this.samples = source.samples
        this.multiview = source.multiview
        this.useArrayDepthTexture = source.useArrayDepthTexture
        return this
    }

    /**
     * @brief[zh-cn] 释放此实例分配的 GPU 相关资源
     *
     * @brief[en] Release GPU-related resources allocated by this instance
     */
    public func dispose(): Unit {
        
        this.dispatchEvent(Event("dispose"))
    }
}
