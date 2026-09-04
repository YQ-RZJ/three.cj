/**
 * @file[zh-cn] 纹理基类
 * @brief[zh-cn] 纹理资源基类，所有具体贴图类型的父类
 * @explain[zh-cn] 纹理资源基类，包装一个 Source（贴图数据源）+ 采样状态（wrapS/wrapT/magFilter/minFilter/anisotropy）+ UV 变换（offset/repeat/center/rotation/matrix）。flipY/colorSpace/premultiplyAlpha 控制上传时的像素处理。继承 EventDispatcher 以支持 dispose 事件；渲染器内部按 needsUpdate/version 增量更新 GPU 纹理。实现 IRenderTargetTexture 接口以解除 core→textures 循环依赖。

 * @file[en] Texture Base Class
 * @brief[en] Texture resource base class, parent of all concrete texture types
 * @explain[en] Texture resource base class, wrapping a Source (texture data source) + sampling state (wrapS/wrapT/magFilter/minFilter/anisotropy) + UV transform (offset/repeat/center/rotation/matrix). flipY/colorSpace/premultiplyAlpha control pixel processing on upload. Extends EventDispatcher to support dispose event; the renderer incrementally updates GPU textures by needsUpdate/version. Implements IRenderTargetTexture interface to break core→textures circular dependency. 
 */
package three.rendering.textures

import three.core.math.*
import three.utils.constants.*
import three.core.event.EventDispatcher
import three.core.event.Event
import three.rendering.rendertarget.RenderTarget
import three.rendering.rendertarget.IRenderTargetTexture
import three.scene.objects.deepCopyUserData
import three.core.interfaces.IBackground
import three.core.interfaces.ILoadResult
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 纹理资源基类
 * @explain[zh-cn] 所有具体贴图类型（DataTexture/CubeTexture/CanvasTexture 等）继承本类。包装 Source + 采样状态 + UV 变换。继承 EventDispatcher 支持 dispose 事件；实现 IRenderTargetTexture 接口解除 core→textures 循环依赖。

 * @brief[en] Texture resource base class
 * @explain[en] All concrete texture types (DataTexture/CubeTexture/CanvasTexture, etc.) extend this class. Wraps Source + sampling state + UV transform. Extends EventDispatcher to support dispose event; implements IRenderTargetTexture interface to break core→textures circular dependency.
 */
@JsonAdapter
public open class Texture <: EventDispatcher & IRenderTargetTexture & IBackground & ILoadResult {

    /**
     * @brief[zh-cn] 类型标签

     * @brief[en] Type tag
     */
    public var kind: String

    /**
     * @brief[zh-cn] 贴图数据（像素数组）

     * @brief[en] Texture data (pixel array)
     */
    public var image: Array<UInt8>

    /**
     * @brief[zh-cn] 贴图宽度（像素）

     * @brief[en] Texture width in pixels
     */
    public var width: Int64

    /**
     * @brief[zh-cn] 贴图高度（像素）

     * @brief[en] Texture height in pixels
     */
    public var height: Int64

    /**
     * @brief[zh-cn] 水平采样环绕模式，默认 ClampToEdgeWrapping

     * @brief[en] Horizontal sampling wrap mode, defaults to ClampToEdgeWrapping
     */
    public var wrapS: Int64

    /**
     * @brief[zh-cn] 垂直采样环绕模式，默认 ClampToEdgeWrapping

     * @brief[en] Vertical sampling wrap mode, defaults to ClampToEdgeWrapping
     */
    public var wrapT: Int64

    /**
     * @brief[zh-cn] 放大采样过滤器，默认 LinearFilter

     * @brief[en] Magnification filter, defaults to LinearFilter
     */
    public var magFilter: Int64

    /**
     * @brief[zh-cn] 缩小采样过滤器，默认 LinearMipmapLinearFilter

     * @brief[en] Minification filter, defaults to LinearMipmapLinearFilter
     */
    public var minFilter: Int64

    /**
     * @brief[zh-cn] 渲染器内部增量更新标志，true 时下次 render 会重传 GPU 纹理

     * @brief[en] Renderer internal incremental update flag, when true the next render will re-upload GPU texture
     */
    @JsonIgnore
    public mut prop needsUpdate: Bool {
        get() { this._needsUpdateFlag }
        set(v) {
            if (v) {
                this.version += 1
                if (this.source is Source) { this.source.needsUpdate = true }
            }
            this._needsUpdateFlag = v
        }
    }
    /**
     * @brief[zh-cn] 私有 backing field（不参与序列化）
     */
    @JsonIgnore
    internal var _needsUpdateFlag: Bool

    /**
     * @brief[zh-cn] 渲染器内部版本号，每次 update() 递增

     * @brief[en] Renderer internal version number, incremented each update()
     */
    public var version: Int64

    /**
     * @brief[zh-cn] UV 映射模式，默认 UVMapping

     * @brief[en] UV mapping mode, defaults to UVMapping
     */
    public var mapping: Int64

    /**
     * @brief[zh-cn] 纹理像素格式，默认 RGBAFormat

     * @brief[en] Texture pixel format, defaults to RGBAFormat
     */
    public var format: Int64

    /**
     * @brief[zh-cn] 像素格式覆盖（如 "GL_RGBA16F"/"GL_R32F" 等），None 表示由 format+type 自动派生

     * @brief[en] Pixel format override (e.g. "GL_RGBA16F"/"GL_R32F"), None means auto-derived from format+type
     */
    public var internalFormat: Option<String>

    /**
     * @brief[zh-cn] 纹理像素数据类型，默认 UnsignedByteType

     * @brief[en] Texture pixel data type, defaults to UnsignedByteType
     */
    public var `type`: Int64

    /**
     * @brief[zh-cn] 各向异性采样等级，默认 1

     * @brief[en] Anisotropy sampling level, defaults to 1
     */
    public var anisotropy: Int64

    /**
     * @brief[zh-cn] 颜色空间，默认空（按渲染器全局）

     * @brief[en] Color space, defaults to empty (follows renderer global)
     */
    public var colorSpace: String

    /**
     * @brief[zh-cn] 唯一标识

     * @brief[en] Unique identifier
     */
    public var uuid: String

    /**
     * @brief[zh-cn] 用户可命名标签

     * @brief[en] User-namable tag
     */
    public var name: String

    /**
     * @brief[zh-cn] 贴图数据源（持有 data + needsUpdate + version）

     * @brief[en] Texture data source (holds data + needsUpdate + version)
     */
    public var source: Source

    /**
     * @brief[zh-cn] 预生成 mipmap 数组（手动 mipmap 时填充）

     * @brief[en] Pre-generated mipmap array (filled when using manual mipmaps)
     */
    public var mipmaps: ArrayList<Any>

    /**
     * @brief[zh-cn] 通道偏移（WebGL2/GLSL3 中将某通道重解释为另一通道，0=不偏移）

     * @brief[en] Channel offset (reinterprets a channel as another in WebGL2/GLSL3, 0=no offset)
     */
    public var channel: Int64

    /**
     * @brief[zh-cn] UV 偏移

     * @brief[en] UV offset
     */
    public var offset: Vector2

    /**
     * @brief[zh-cn] UV 重复

     * @brief[en] UV repeat
     */
    public var repeat: Vector2

    /**
     * @brief[zh-cn] UV 旋转中心

     * @brief[en] UV rotation center
     */
    public var center: Vector2

    /**
     * @brief[zh-cn] UV 旋转角度（弧度）

     * @brief[en] UV rotation angle in radians
     */
    public var rotation: Float64

    /**
     * @brief[zh-cn] 是否自动更新 UV 变换矩阵

     * @brief[en] Whether to auto-update UV transform matrix
     */
    public var matrixAutoUpdate: Bool

    /**
     * @brief[zh-cn] UV 变换矩阵（3×3）

     * @brief[en] UV transform matrix (3×3)
     */
    public var matrix: Matrix3

    /**
     * @brief[zh-cn] 是否自动生成 mipmap

     * @brief[en] Whether to auto-generate mipmaps
     */
    public var generateMipmaps: Bool

    /**
     * @brief[zh-cn] 上传前是否预乘 alpha

     * @brief[en] Whether to premultiply alpha before upload
     */
    public var premultiplyAlpha: Bool

    /**
     * @brief[zh-cn] 上传时是否沿 Y 轴翻转

     * @brief[en] Whether to flip along Y axis on upload
     */
    public var flipY: Bool

    /**
     * @brief[zh-cn] 像素行对齐字节数（1/2/4/8），默认 4

     * @brief[en] Pixel row alignment bytes (1/2/4/8), defaults to 4
     */
    public var unpackAlignment: Int64

    /**
     * @brief[zh-cn] 用户自定义数据容器

     * @brief[en] User custom data container
     */
    public var userData: HashMap<String, Any>

    /**
     * @brief[zh-cn] 是否渲染目标纹理

     * @brief[en] Whether this is a render target texture
     */
    public var isRenderTargetTexture: Bool

    /**
     * @brief[zh-cn] 渲染目标反向引用

     * @brief[en] Render target back reference
     */
    @JsonIgnore
    public var renderTarget: ?RenderTarget

    /**
     * @brief[zh-cn] 贴图深度（3D 纹理用，默认 1）

     * @brief[en] Texture depth (for 3D textures, defaults to 1)
     */
    public var depth: Int64

    /**
     * @brief[zh-cn] 是否数组纹理

     * @brief[en] Whether this is an array texture
     */
    public var isArrayTexture: Bool

    /**
     * @brief[zh-cn] 是否使用 16 位归一化整数格式，默认 false

     * @brief[en] Whether to use 16-bit normalized integer format, defaults to false
     */
    public var normalized: Bool

    /**
     * @brief[zh-cn] 是否 3D 数据纹理（子类 override 为 true）

     * @brief[en] Whether this is a 3D data texture (subclass overrides to true)
     */
    public open func getIsData3DTexture(): Bool { false }

    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：贴图宽度

     * @brief[en] IRenderTargetTexture interface: texture width
     */
    @JsonIgnore
    public mut prop rtWidth: Int64 {
        get() { this.width }
        set(v) { this.width = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：贴图高度

     * @brief[en] IRenderTargetTexture interface: texture height
     */
    @JsonIgnore
    public mut prop rtHeight: Int64 {
        get() { this.height }
        set(v) { this.height = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：贴图深度

     * @brief[en] IRenderTargetTexture interface: texture depth
     */
    @JsonIgnore
    public mut prop rtDepth: Int64 {
        get() { this.depth }
        set(v) { this.depth = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：是否数组纹理

     * @brief[en] IRenderTargetTexture interface: whether array texture
     */
    @JsonIgnore
    public mut prop rtIsArrayTexture: Bool {
        get() { this.isArrayTexture }
        set(v) { this.isArrayTexture = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：是否 3D 数据纹理

     * @brief[en] IRenderTargetTexture interface: whether 3D data texture
     */
    public func rtIsData3DTexture(): Bool { this.getIsData3DTexture() }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：渲染目标反向引用

     * @brief[en] IRenderTargetTexture interface: render target back reference
     */
    @JsonIgnore
    public mut prop rtRenderTarget: ?RenderTarget {
        get() { this.renderTarget }
        set(v) { this.renderTarget = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：是否渲染目标纹理

     * @brief[en] IRenderTargetTexture interface: whether render target texture
     */
    @JsonIgnore
    public mut prop rtIsRenderTargetTexture: Bool {
        get() { this.isRenderTargetTexture }
        set(v) { this.isRenderTargetTexture = v }
    }
    /**
     * @brief[zh-cn] IRenderTargetTexture 接口：克隆自身

     * @brief[en] IRenderTargetTexture interface: clone itself
     */
    public func rtClone(): IRenderTargetTexture { this.clone() }

    /**
     * @brief[zh-cn] 构造一个新的纹理
     * @param[zh-cn] image 像素数组，默认空
     * width 贴图宽度（像素），默认 0
     * height 贴图高度（像素），默认 0
     * wrapS 水平环绕模式，默认 ClampToEdgeWrapping
     * wrapT 垂直环绕模式，默认 ClampToEdgeWrapping
     * magFilter 放大过滤器，默认 LinearFilter
     * minFilter 缩小过滤器，默认 LinearMipmapLinearFilter
     * mapping UV 映射模式，默认 UVMapping
     * format 像素格式，默认 RGBAFormat
     * type 像素数据类型，默认 UnsignedByteType
     * anisotropy 各向异性等级，默认 1
     * colorSpace 颜色空间，默认空

     * @brief[en] Construct a new texture
     * @param[en] image Pixel array, defaults to empty
     * width Texture width in pixels, defaults to 0
     * height Texture height in pixels, defaults to 0
     * wrapS Horizontal wrap mode, defaults to ClampToEdgeWrapping
     * wrapT Vertical wrap mode, defaults to ClampToEdgeWrapping
     * magFilter Magnification filter, defaults to LinearFilter
     * minFilter Minification filter, defaults to LinearMipmapLinearFilter
     * mapping UV mapping mode, defaults to UVMapping
     * format Pixel format, defaults to RGBAFormat
     * type Pixel data type, defaults to UnsignedByteType
     * anisotropy Anisotropy level, defaults to 1
     * colorSpace Color space, defaults to empty
     */
    public init(image!: Array<UInt8> = Array<UInt8>(), width!: Int64 = 0, height!: Int64 = 0, wrapS!: Int64 = ClampToEdgeWrapping, wrapT!: Int64 = ClampToEdgeWrapping, magFilter!: Int64 = LinearFilter, minFilter!: Int64 = LinearMipmapLinearFilter, mapping!: Int64 = UVMapping, format!: Int64 = RGBAFormat, `type`!: Int64 = UnsignedByteType, anisotropy!: Int64 = 1, colorSpace!: String = "") {
        super()
        this.kind = "Texture"
        this.image = image
        this.width = width
        this.height = height
        this.wrapS = wrapS
        this.wrapT = wrapT
        this.magFilter = magFilter
        this.minFilter = minFilter
        this.version = 0
        this.mapping = mapping
        this.format = format
        this.`type` = `type`
        this.internalFormat = None
        this._needsUpdateFlag = false
        this.anisotropy = anisotropy
        this.colorSpace = colorSpace
        this.uuid = MathUtils.generateUUID()
        this.name = ""
        this.source = Source(data: image)
        this.mipmaps = ArrayList<Any>()
        this.channel = 0
        this.offset = Vector2(0.0, 0.0)
        this.repeat = Vector2(1.0, 1.0)
        this.center = Vector2(0.0, 0.0)
        this.rotation = 0.0
        this.matrixAutoUpdate = true
        this.matrix = Matrix3()
        this.generateMipmaps = true
        this.premultiplyAlpha = false
        this.flipY = true
        this.unpackAlignment = 4
        this.userData = HashMap<String, Any>()
        this.isRenderTargetTexture = false
        this.renderTarget = None
        this.depth = 1
        this.isArrayTexture = false
        this.normalized = false
    }

    /**
     * @brief[zh-cn] 释放本实例分配的 GPU 相关资源，并派发 dispose 事件

     * @brief[en] Release GPU-related resources allocated by this instance and dispatch dispose event
     */
    public open func dispose(): Unit {
        this.dispatchEvent(Event("dispose"))
    }

    /**
     * @brief[zh-cn] 通知渲染器纹理内容已变，下次 render 会重传 GPU 纹理

     * @brief[en] Notify the renderer that texture content has changed, next render will re-upload GPU texture
     */
    public open func update(): Unit {
        this.version += 1
        this.needsUpdate = true
    }

    /**
     * @brief[zh-cn] 重算 UV 变换矩阵（按 offset/repeat/rotation/center）

     * @brief[en] Recalculate UV transform matrix (by offset/repeat/rotation/center)
     */
    public func updateMatrix(): Unit {
        this.matrix.setUvTransform(this.offset.x, this.offset.y, this.repeat.x, this.repeat.y, this.rotation, this.center.x, this.center.y)
        this.matrixAutoUpdate = false
    }

    /**
     * @brief[zh-cn] 将 UV 坐标按本纹理的 offset/repeat/center/rotation 变换后写入 target
     * @param[zh-cn] uv 待变换的 UV 坐标
     * target 接收结果的目标向量
     * @return[zh-cn] 变换后的 UV 坐标

     * @brief[en] Transform UV coordinates by this texture's offset/repeat/center/rotation and write to target
     * @param[en] uv UV coordinates to transform
     * target Target vector to receive the result
     * @return[en] Transformed UV coordinates
     */
    public func transformUv(uv: Vector2, target: Vector2): Vector2 {
        if (this.matrixAutoUpdate) { this.updateMatrix() }
        return target.copy(uv).applyMatrix3(this.matrix)
    }

    /**
     * @brief[zh-cn] 将给定纹理实例的值复制到本实例
     * @param[zh-cn] source 源纹理
     * @return[zh-cn] 当前实例

     * @brief[en] Copy values from the given texture instance to this instance
     * @param[en] source Source texture
     * @return[en] This instance
     */
    public open func copy(source: Texture): Texture {
        this.image = source.image
        this.width = source.width
        this.height = source.height
        this.wrapS = source.wrapS
        this.wrapT = source.wrapT
        this.magFilter = source.magFilter
        this.minFilter = source.minFilter
        this.mapping = source.mapping
        this.format = source.format
        this.`type` = source.`type`
        this.internalFormat = source.internalFormat
        this.anisotropy = source.anisotropy
        this.colorSpace = source.colorSpace
        this.channel = source.channel
        this.offset.copy(source.offset)
        this.repeat.copy(source.repeat)
        this.center.copy(source.center)
        this.rotation = source.rotation
        this.matrixAutoUpdate = source.matrixAutoUpdate
        this.matrix.copy(source.matrix)
        this.generateMipmaps = source.generateMipmaps
        this.premultiplyAlpha = source.premultiplyAlpha
        this.flipY = source.flipY
        this.unpackAlignment = source.unpackAlignment
        
        // 仓颉侧：使用 cjfast_json 实现 userData 深拷贝
        this.userData = deepCopyUserData(source.userData)
        this.isRenderTargetTexture = source.isRenderTargetTexture
        this.source = source.source
        this.mipmaps.clear()
        for (m in source.mipmaps) { this.mipmaps.add(m) }
        
        this.depth = source.depth
        this.isArrayTexture = source.isArrayTexture
        this.normalized = source.normalized
        this.needsUpdate = true
        return this
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新纹理实例
     * @return[zh-cn] 克隆的纹理实例

     * @brief[en] Return a new texture instance with the same values as this instance
     * @return[en] Cloned texture instance
     */
    public open func clone(): Texture {
        let t = match (this.kind) {
            case "DataTexture" => DataTexture(this.image, this.width, this.height)
            case "CanvasTexture" => CanvasTexture(this.image, this.width, this.height)
            case "DepthTexture" => DepthTexture(this.width, this.height)
            case "CubeTexture" => CubeTexture()
            case "CompressedTexture" => CompressedTexture(this.image, this.width, this.height)
            case "CompressedArrayTexture" => CompressedArrayTexture(this.image, this.width, this.height, 1)
            case "CompressedCubeTexture" => CompressedCubeTexture(Array<Array<UInt8>>(), this.width, this.height)
            case "CubeDepthTexture" => CubeDepthTexture(this.width, this.height)
            case "Data3DTexture" => Data3DTexture(this.image, this.width, this.height, 1)
            case "DataArrayTexture" => DataArrayTexture(this.image, this.width, this.height, 1)
            case "FramebufferTexture" => FramebufferTexture(this.width, this.height)
            case "ExternalTexture" => ExternalTexture()
            case "VideoFrameTexture" => VideoFrameTexture(this.width, this.height)
            case "VideoTexture" => VideoTexture(this.image)
            case _ => Texture()
        }
        return t.copy(this)
    }

    /**
     * @brief[zh-cn] 用 HashMap 中的值批量设置本纹理的字段（键名匹配字段名）
     * @param[zh-cn] values 字段值字典

     * @brief[en] Batch set texture fields from HashMap values (key names match field names)
     * @param[en] values Field value dictionary
     */
    public func setValues(values: HashMap<String, Any>): Unit {
        // 与 JS side 一致：逐键反射赋值；仓颉侧无反射，故此处显式列举常见字段。
        match (values.get("wrapS")) { case Some(v) => match (v) { case i: Int64 => this.wrapS = i; case _ => () }; case None => () }
        match (values.get("wrapT")) { case Some(v) => match (v) { case i: Int64 => this.wrapT = i; case _ => () }; case None => () }
        match (values.get("magFilter")) { case Some(v) => match (v) { case i: Int64 => this.magFilter = i; case _ => () }; case None => () }
        match (values.get("minFilter")) { case Some(v) => match (v) { case i: Int64 => this.minFilter = i; case _ => () }; case None => () }
        match (values.get("anisotropy")) { case Some(v) => match (v) { case i: Int64 => this.anisotropy = i; case _ => () }; case None => () }
        match (values.get("format")) { case Some(v) => match (v) { case i: Int64 => this.format = i; case _ => () }; case None => () }
        match (values.get("mapping")) { case Some(v) => match (v) { case i: Int64 => this.mapping = i; case _ => () }; case None => () }
        match (values.get("colorSpace")) { case Some(v) => match (v) { case s: String => this.colorSpace = s; case _ => () }; case None => () }
        match (values.get("flipY")) { case Some(v) => match (v) { case b: Bool => this.flipY = b; case _ => () }; case None => () }
        match (values.get("generateMipmaps")) { case Some(v) => match (v) { case b: Bool => this.generateMipmaps = b; case _ => () }; case None => () }
        match (values.get("premultiplyAlpha")) { case Some(v) => match (v) { case b: Bool => this.premultiplyAlpha = b; case _ => () }; case None => () }
        this.needsUpdate = true
    }
}
