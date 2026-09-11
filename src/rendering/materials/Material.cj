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
 * @file[zh-cn] 材质抽象基类
 * @brief[zh-cn] 材质抽象基类，所有具体材质类型继承本类
 * @explain[zh-cn] 
 * 对应 Three.js materials/Material.js。定义通用渲染状态（混合、深度、模板、多边形偏移等）与序列化/反序列化接口。
 * 继承 EventDispatcher 以支持 dispose 事件；子类扩展字段（如 map/color/roughness 等）。
 *
 * @file[en] Material Abstract Base Class
 * @brief[en] Abstract base class for materials, subclassed by all concrete material types
 * @explain[en] 
 * Corresponds to Three.js materials/Material.js. Defines common rendering state (blending, depth, stencil, polygon offset, etc.)
 * and serialization/deserialization interfaces. Inherits EventDispatcher to support dispose events;
 * subclasses extend with fields such as map, color, roughness, etc.
 */
package three.rendering.materials

import three.core.math.*
import three.rendering.textures.*
import three.utils.constants.*
import three.core.event.EventDispatcher
import three.core.event.Event
import three.rendering.geometry.BufferGeometry
import three.scene.objects.Object3D
import three.scene.objects.deepCopyUserData
import three.rendering.cameras.Camera
import three.core.interfaces.IMaterial
import three.core.interfaces.ILoadResult
import three.rendering.interfaces.IRenderer
import three.scene.interfaces.IScene
import three.scene.interfaces.IGroup
import three.rendering.interfaces.IShaderProgram
import std.collection.*
import fastjson.*
import fastjson.macros.*
import fastjson.stream.*

/**
 * @brief[zh-cn] 材质抽象基类，所有具体材质类型继承本类
 * @explain[zh-cn] 
 * 对应 Three.js materials/Material.js。定义通用渲染状态（混合、深度、模板、多边形偏移等）与序列化/反序列化接口。
 * 继承 EventDispatcher 以支持 dispose 事件；子类扩展字段（如 map/color/roughness 等）。
 *
 * @brief[en] Abstract base class for materials, subclassed by all concrete material types
 * @explain[en] 
 * Corresponds to Three.js materials/Material.js. Defines common rendering state (blending, depth, stencil, polygon offset, etc.)
 * and serialization/deserialization interfaces. Inherits EventDispatcher to support dispose events;
 * subclasses extend with fields such as map, color, roughness, etc.
 */
@JsonAdapter[polymorphic = true ; ignorePrivate = true]
public open class Material <: EventDispatcher & IMaterial & ILoadResult {

    /**
     * @brief[zh-cn] 类型标签（由 @JsonAdapter 宏自动生成 mut prop）
     *
     * @brief[en] Type label (auto-generated as mut prop by @JsonAdapter macro)
     */
    // kind: String 由宏生成，不需要手动定义

    /**
     * @brief[zh-cn] 材质主色，默认0xffffff
     *
     * @brief[en] Material main color, default 0xffffff
     */
    public var color: Color

    /**
     * @brief[zh-cn] 不透明度（0.0~1.0），默认1.0
     *
     * @brief[en] Opacity (0.0~1.0), default 1.0
     */
    public var opacity: Float64

    /**
     * @brief[zh-cn] 是否透明，默认false
     *
     * @brief[en] Whether transparent, default false
     */
    public var transparent: Bool

    /**
     * @brief[zh-cn] 渲染面（FrontSide/BackSide/DoubleSide），默认FrontSide
     *
     * @brief[en] Rendering side (FrontSide/BackSide/DoubleSide), default FrontSide
     */
    public var side: Int64

    /**
     * @brief[zh-cn] 是否开启深度测试，默认true
     *
     * @brief[en] Whether to enable depth test, default true
     */
    public var depthTest: Bool

    /**
     * @brief[zh-cn] 是否写入深度缓冲，默认true
     *
     * @brief[en] Whether to write to depth buffer, default true
     */
    public var depthWrite: Bool

    /**
     * @brief[zh-cn] 混合模式，默认NormalBlending
     *
     * @brief[en] Blending mode, default NormalBlending
     */
    public var blending: Int64

    /**
     * @brief[zh-cn] 唯一标识
     *
     * @brief[en] Unique identifier
     */
    public var uuid: String

    /**
     * @brief[zh-cn] 用户可命名标签
     *
     * @brief[en] User-namable label
     */
    public var name: String

    /**
     * @brief[zh-cn] 是否启用顶点颜色，默认false
     *
     * @brief[en] Whether to enable vertex colors, default false
     */
    public var vertexColors: Bool

    /**
     * @brief[zh-cn] 是否以线框模式渲染，默认false
     *
     * @brief[en] Whether to render in wireframe mode, default false
     */
    public var wireframe: Bool

    /**
     * @brief[zh-cn] 是否使用flat shading，默认false
     *
     * @brief[en] Whether to use flat shading, default false
     */
    public var flatShading: Bool

    /**
     * @brief[zh-cn] 阴影面，None表示与side一致
     *
     * @brief[en] Shadow side, None means same as side
     */
    public var shadowSide: Option<Int64>

    /**
     * @brief[zh-cn] 源颜色混合因子，默认SrcAlphaFactor
     *
     * @brief[en] Source color blend factor, default SrcAlphaFactor
     */
    public var blendSrc: Int64

    /**
     * @brief[zh-cn] 目标颜色混合因子，默认OneMinusSrcAlphaFactor
     *
     * @brief[en] Destination color blend factor, default OneMinusSrcAlphaFactor
     */
    public var blendDst: Int64

    /**
     * @brief[zh-cn] 混合方程，默认AddEquation
     *
     * @brief[en] Blend equation, default AddEquation
     */
    public var blendEquation: Int64

    /**
     * @brief[zh-cn] 深度比较函数，默认LessEqualDepth
     *
     * @brief[en] Depth comparison function, default LessEqualDepth
     */
    public var depthFunc: Int64

    /**
     * @brief[zh-cn] 模板写入掩码，默认0xFF
     *
     * @brief[en] Stencil write mask, default 0xFF
     */
    public var stencilWriteMask: Int64

    /**
     * @brief[zh-cn] 模板比较函数，默认AlwaysStencilFunc
     *
     * @brief[en] Stencil comparison function, default AlwaysStencilFunc
     */
    public var stencilFunc: Int64

    /**
     * @brief[zh-cn] 模板参考值，默认0
     *
     * @brief[en] Stencil reference value, default 0
     */
    public var stencilRef: Int64

    /**
     * @brief[zh-cn] 模板比较掩码，默认0xFF
     *
     * @brief[en] Stencil comparison mask, default 0xFF
     */
    public var stencilFuncMask: Int64

    /**
     * @brief[zh-cn] 模板失败操作，默认KeepStencilOp
     *
     * @brief[en] Stencil fail operation, default KeepStencilOp
     */
    public var stencilFail: Int64

    /**
     * @brief[zh-cn] 模板深度测试失败操作，默认KeepStencilOp
     *
     * @brief[en] Stencil depth test fail operation, default KeepStencilOp
     */
    public var stencilZFail: Int64

    /**
     * @brief[zh-cn] 模板深度测试通过操作，默认KeepStencilOp
     *
     * @brief[en] Stencil depth test pass operation, default KeepStencilOp
     */
    public var stencilZPass: Int64

    /**
     * @brief[zh-cn] 是否启用模板写入，默认false
     *
     * @brief[en] Whether to enable stencil writing, default false
     */
    public var stencilWrite: Bool

    /**
     * @brief[zh-cn] 是否写入颜色通道，默认true
     *
     * @brief[en] Whether to write to color channels, default true
     */
    public var colorWrite: Bool

    /**
     * @brief[zh-cn] 是否启用多边形偏移，默认false
     *
     * @brief[en] Whether to enable polygon offset, default false
     */
    public var polygonOffset: Bool

    /**
     * @brief[zh-cn] 多边形偏移因子，默认0
     *
     * @brief[en] Polygon offset factor, default 0
     */
    public var polygonOffsetFactor: Float64

    /**
     * @brief[zh-cn] 多边形偏移单位，默认0
     *
     * @brief[en] Polygon offset units, default 0
     */
    public var polygonOffsetUnits: Float64

    /**
     * @brief[zh-cn] 是否启用抖动，默认false
     *
     * @brief[en] Whether to enable dithering, default false
     */
    public var dithering: Bool

    /**
     * @brief[zh-cn] 是否启用alpha-to-coverage，默认false
     *
     * @brief[en] Whether to enable alpha-to-coverage, default false
     */
    public var alphaToCoverage: Bool

    /**
     * @brief[zh-cn] 是否已预乘alpha，默认false
     *
     * @brief[en] Whether alpha is premultiplied, default false
     */
    public var premultipliedAlpha: Bool

    /**
     * @brief[zh-cn] 是否强制单pass渲染，默认false
     *
     * @brief[en] Whether to force single-pass rendering, default false
     */
    public var forceSinglePass: Bool

    /**
     * @brief[zh-cn] 是否可见，默认true
     *
     * @brief[en] Whether visible, default true
     */
    public var visible: Bool

    /**
     * @brief[zh-cn] 是否应用色调映射，默认true
     *
     * @brief[en] Whether to apply tone mapping, default true
     */
    public var toneMapped: Bool

    /**
     * @brief[zh-cn] 用户自定义元数据
     *
     * @brief[en] User-defined metadata
     */
    public var userData: HashMap<String, Any>

    /**
     * @brief[zh-cn] 渲染器内部版本号，每次字段变化时递增
     *
     * @brief[en] Renderer internal version number, incremented on each field change
     */
    public var version: Int64

    /**
     * @brief[zh-cn] alpha测试阈值，>0时启用，默认0
     *
     * @brief[en] Alpha test threshold, enabled when >0, default 0
     */
    @JsonName["alphaTest"]
    private var _alphaTest: Float64

    /**
     * @brief[zh-cn] alpha测试阈值的访问属性
     *
     * @brief[en] Accessor property for alpha test threshold
     */
    @JsonIgnore
    public mut prop alphaTest: Float64 {
        get() { return this._alphaTest }
        set(v) {
            if (this._alphaTest > 0.0 != v > 0.0) { this.version += 1 }
            this._alphaTest = v
        }
    }

    /**
     * @brief[zh-cn] 是否启用雾效，默认true
     *
     * @brief[en] Whether to enable fog, default true
     */
    public var fog: Bool

    /**
     * @brief[zh-cn] 裁剪平面数组
     *
     * @brief[en] Clipping planes array
     */
    @JsonIgnore
    public var clippingPlanes: Option<ArrayList<Plane>>

    /**
     * @brief[zh-cn] 是否使用裁剪交叉模式
     *
     * @brief[en] Whether to use clip intersection mode
     */
    public var clipIntersection: Bool

    /**
     * @brief[zh-cn] 是否裁剪阴影
     *
     * @brief[en] Whether to clip shadows
     */
    public var clipShadows: Bool

    /**
     * @brief[zh-cn] 渲染前回调函数
     *
     * @brief[en] Before-render callback function
     */
    @JsonIgnore
    public var onBeforeRender: Option<(renderer: IRenderer, scene: IScene, camera: Camera, geometry: BufferGeometry, object: Object3D, group: IGroup) -> Unit>

    /**
     * @brief[zh-cn] 编译前回调函数
     *
     * @brief[en] Before-compile callback function
     */
    @JsonIgnore
    public var onBeforeCompile: Option<(shaderobject: IShaderProgram, renderer: IRenderer) -> Unit>

    /**
     * @brief[zh-cn] 自定义程序缓存键回调函数
     *
     * @brief[en] Custom program cache key callback function
     */
    @JsonIgnore
    public var customProgramCacheKey: Option<() -> String>

    /**
     * @brief[zh-cn] 环境贴图
     *
     * @brief[en] Environment map
     */
    @JsonIgnore
    public var envMap: Option<Texture>

    /**
     * @brief[zh-cn] 环境贴图旋转
     *
     * @brief[en] Environment map rotation
     */
    @JsonIgnore
    public var envMapRotation: Option<Euler>

    /**
     * @brief[zh-cn] 环境贴图强度，默认1
     *
     * @brief[en] Environment map intensity, default 1
     */
    public var envMapIntensity: Float64

    /**
     * @brief[zh-cn] 构造一个新的材质
     *
     * @brief[en] Construct a new material
     */
    public init() {
        super()
        this.uuid = MathUtils.generateUUID()
        this.name = ""
        this.color = Color(0xffffff)
        this.opacity = 1.0
        this.transparent = false
        this.side = FrontSide
        this.depthTest = true
        this.depthWrite = true
        this.blending = NormalBlending
        this.vertexColors = false
        this.wireframe = false
        this.flatShading = false
        this.blendSrc = SrcAlphaFactor
        this.blendDst = OneMinusSrcAlphaFactor
        this.blendEquation = AddEquation
        this.depthFunc = LessEqualDepth
        this.stencilWriteMask = 0xFF
        this.stencilFunc = AlwaysStencilFunc
        this.stencilRef = 0
        this.stencilFuncMask = 0xFF
        this.stencilFail = KeepStencilOp
        this.stencilZFail = KeepStencilOp
        this.stencilZPass = KeepStencilOp
        this.stencilWrite = false
        this.colorWrite = true
        this.polygonOffset = false
        this.polygonOffsetFactor = 0.0
        this.polygonOffsetUnits = 0.0
        this.dithering = false
        this.alphaToCoverage = false
        this.premultipliedAlpha = false
        this.forceSinglePass = false
        this.visible = true
        this.toneMapped = true
        this.userData = HashMap<String, Any>()
        this.version = 0
        this._alphaTest = 0.0
        this.shadowSide = None
        this.fog = true
        this.clippingPlanes = None
        this.clipIntersection = false
        this.clipShadows = false
        this.onBeforeRender = None
        this.onBeforeCompile = None
        this.customProgramCacheKey = None
        this.envMap = None
        this.envMapRotation = None
        this.envMapIntensity = 1.0
    }

    /**
     * @brief[zh-cn] 释放本实例分配的GPU相关资源，并派发dispose事件
     *
     * @brief[en] Dispose GPU-related resources and dispatch dispose event
     */
    public func dispose(): Unit {
        this.dispatchEvent(Event("dispose"))
    }

    /**
     * @brief[zh-cn] 返回一个与本实例值相同的新材质实例
     * @return[zh-cn] 克隆的材质实例
     *
     * @brief[en] Return a new material instance with the same values as this instance
     * @return[en] Cloned material instance
     */
    public func clone(): Material {
        let m = Material()
        return m.copy(this)
    }

    /**
     * @brief[zh-cn] 将给定材质实例的值复制到本实例
     * @param[zh-cn] source 源材质实例
     * @return[zh-cn] 本实例
     *
     * @brief[en] Copy the values from the given material instance to this instance
     * @param[en] source Source material instance
     * @return[en] This instance
     */
    public func copy(source: Material): Material {
        this.name = source.name
        this.blending = source.blending
        this.side = source.side
        this.vertexColors = source.vertexColors
        this.opacity = source.opacity
        this.transparent = source.transparent
        this.blendSrc = source.blendSrc
        this.blendDst = source.blendDst
        this.blendEquation = source.blendEquation
        this.depthFunc = source.depthFunc
        this.depthTest = source.depthTest
        this.depthWrite = source.depthWrite
        this.colorWrite = source.colorWrite
        this.stencilWriteMask = source.stencilWriteMask
        this.stencilFunc = source.stencilFunc
        this.stencilRef = source.stencilRef
        this.stencilFuncMask = source.stencilFuncMask
        this.stencilFail = source.stencilFail
        this.stencilZFail = source.stencilZFail
        this.stencilZPass = source.stencilZPass
        this.stencilWrite = source.stencilWrite
        this.shadowSide = source.shadowSide
        this.polygonOffset = source.polygonOffset
        this.polygonOffsetFactor = source.polygonOffsetFactor
        this.polygonOffsetUnits = source.polygonOffsetUnits
        this.dithering = source.dithering
        this.alphaTest = source.alphaTest
        this.alphaToCoverage = source.alphaToCoverage
        this.premultipliedAlpha = source.premultipliedAlpha
        this.forceSinglePass = source.forceSinglePass
        this.visible = source.visible
        this.toneMapped = source.toneMapped
        
        // 仓颉侧：使用 cjfast_json 实现 userData 深拷贝
        this.userData = deepCopyUserData(source.userData)
        this.version = source.version
        this.fog = source.fog
        this.clippingPlanes = source.clippingPlanes
        this.clipIntersection = source.clipIntersection
        this.clipShadows = source.clipShadows
        return this
    }

    /**
     * @brief[zh-cn] 用HashMap中的值批量设置本材质的字段
     * @param[zh-cn] values 包含字段名和值的HashMap
     *
     * @brief[en] Batch set material fields from a HashMap
     * @param[en] values HashMap containing field names and values
     */
    public func setValues(values: HashMap<String, Any>): Unit {
        match (values.get("opacity")) { case Some(v) => match (v) { case f: Float64 => this.opacity = f; case _ => () }; case None => () }
        match (values.get("transparent")) { case Some(v) => match (v) { case b: Bool => this.transparent = b; case _ => () }; case None => () }
        match (values.get("side")) { case Some(v) => match (v) { case i: Int64 => this.side = i; case _ => () }; case None => () }
        match (values.get("color")) { case Some(v) => match (v) { case c: Color => this.color.copy(c); case i: Int64 => this.color.setHex(UInt32(i)); case _ => () }; case None => () }
        match (values.get("depthTest")) { case Some(v) => match (v) { case b: Bool => this.depthTest = b; case _ => () }; case None => () }
        match (values.get("depthWrite")) { case Some(v) => match (v) { case b: Bool => this.depthWrite = b; case _ => () }; case None => () }
        match (values.get("blending")) { case Some(v) => match (v) { case i: Int64 => this.blending = i; case _ => () }; case None => () }
        match (values.get("visible")) { case Some(v) => match (v) { case b: Bool => this.visible = b; case _ => () }; case None => () }
        match (values.get("fog")) { case Some(v) => match (v) { case b: Bool => this.fog = b; case _ => () }; case None => () }
    }

    /**
     * @brief[zh-cn] 从JSON反序列化设置材质属性
     * @param[zh-cn] json JSON数据
     * textures 纹理映射
     *
     * @brief[en] Set material properties from JSON deserialization
     * @param[en] json JSON data
     * textures Texture mapping
     */
    public open func fromJSON(json: HashMap<String, Any>, textures: HashMap<String, Texture>): Unit {
        _setFromJsonStr(json, "uuid", { v => this.uuid = v })
        _setFromJsonStr(json, "name", { v => this.name = v })
        _setFromJsonColor(json, "color", this.color)
        _setFromJsonFloat(json, "opacity", { v => this.opacity = v })
        _setFromJsonBool(json, "transparent", { v => this.transparent = v })
        _setFromJsonInt(json, "side", { v => this.side = v })
        _setFromJsonInt(json, "shadowSide", { v => this.shadowSide = Some(v) })
        _setFromJsonInt(json, "blending", { v => this.blending = v })
        _setFromJsonInt(json, "blendSrc", { v => this.blendSrc = v })
        _setFromJsonInt(json, "blendDst", { v => this.blendDst = v })
        _setFromJsonInt(json, "blendEquation", { v => this.blendEquation = v })
        _setFromJsonInt(json, "depthFunc", { v => this.depthFunc = v })
        _setFromJsonBool(json, "depthTest", { v => this.depthTest = v })
        _setFromJsonBool(json, "depthWrite", { v => this.depthWrite = v })
        _setFromJsonBool(json, "stencilWrite", { v => this.stencilWrite = v })
        _setFromJsonInt(json, "stencilWriteMask", { v => this.stencilWriteMask = v })
        _setFromJsonInt(json, "stencilFunc", { v => this.stencilFunc = v })
        _setFromJsonInt(json, "stencilRef", { v => this.stencilRef = v })
        _setFromJsonInt(json, "stencilFuncMask", { v => this.stencilFuncMask = v })
        _setFromJsonInt(json, "stencilFail", { v => this.stencilFail = v })
        _setFromJsonInt(json, "stencilZFail", { v => this.stencilZFail = v })
        _setFromJsonInt(json, "stencilZPass", { v => this.stencilZPass = v })
        _setFromJsonBool(json, "fog", { v => this.fog = v })
        _setFromJsonBool(json, "visible", { v => this.visible = v })
        _setFromJsonBool(json, "toneMapped", { v => this.toneMapped = v })
        _setFromJsonBool(json, "dithering", { v => this.dithering = v })
        _setFromJsonBool(json, "alphaToCoverage", { v => this.alphaToCoverage = v })
        _setFromJsonBool(json, "premultipliedAlpha", { v => this.premultipliedAlpha = v })
        _setFromJsonFloat(json, "alphaTest", { v => this.alphaTest = v })
        _setFromJsonBool(json, "polygonOffset", { v => this.polygonOffset = v })
        _setFromJsonFloat(json, "polygonOffsetFactor", { v => this.polygonOffsetFactor = v })
        _setFromJsonFloat(json, "polygonOffsetUnits", { v => this.polygonOffsetUnits = v })
        _setFromJsonBool(json, "vertexColors", { v => this.vertexColors = v })
        _setFromJsonBool(json, "forceSinglePass", { v => this.forceSinglePass = v })

        // userData
        match (json.get("userData")) {
            case Some(v) => match (v) {
                case m: HashMap<String, Any> =>
                    for ((k, val) in m) { this.userData.add(k, val) }
                case _ => ()
            }
            case None => ()
        }
    }

    /**
     * @brief[zh-cn] 从JSON反序列化构造材质
     * @param[zh-cn] json JSON数据
     * textures 纹理映射
     * @return[zh-cn] 构造的材质实例，若类型未知返回None
     *
     * @brief[en] Construct a material from JSON deserialization
     * @param[en] json JSON data
     * textures Texture mapping
     * @return[en] Constructed material instance, or None if type is unknown
     */
    public static func createFromJSON(json: HashMap<String, Any>, textures: HashMap<String, Texture>): Option<Material> {
        let typeStr = match (json.get("type")) {
            case Some(v) => match (v) { case s: String => s; case _ => return None }
            case None => return None
        }

        var material: Material
        if (typeStr == "MeshBasicMaterial") {
            material = MeshBasicMaterial()
        } else if (typeStr == "MeshStandardMaterial") {
            material = MeshStandardMaterial()
        } else if (typeStr == "MeshPhysicalMaterial") {
            material = MeshPhysicalMaterial()
        } else if (typeStr == "MeshPhongMaterial") {
            material = MeshPhongMaterial()
        } else if (typeStr == "MeshLambertMaterial") {
            material = MeshLambertMaterial()
        } else if (typeStr == "MeshMatcapMaterial") {
            material = MeshMatcapMaterial()
        } else if (typeStr == "MeshNormalMaterial") {
            material = MeshNormalMaterial()
        } else if (typeStr == "MeshDepthMaterial") {
            material = MeshDepthMaterial()
        } else if (typeStr == "MeshToonMaterial") {
            material = MeshToonMaterial()
        } else if (typeStr == "LineBasicMaterial") {
            material = LineBasicMaterial()
        } else if (typeStr == "LineDashedMaterial") {
            material = LineDashedMaterial()
        } else if (typeStr == "PointsMaterial") {
            material = PointsMaterial()
        } else if (typeStr == "SpriteMaterial") {
            material = SpriteMaterial()
        } else if (typeStr == "ShadowMaterial") {
            material = ShadowMaterial()
        } else if (typeStr == "RawShaderMaterial") {
            material = RawShaderMaterial()
        } else if (typeStr == "ShaderMaterial") {
            material = ShaderMaterial()
        } else {
            material = MeshBasicMaterial()
        }

        // 调用实例方法 fromJSON 设置属性
        material.fromJSON(json, textures)
        return Some(material)
    }
}

// ===== fromJSON 辅助函数 =====

/**
 * @brief[zh-cn] 从JSON中设置字符串字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * setter 设置回调
 *
 * @brief[en] Set a string field from JSON
 * @param[en] json JSON data
 * key Field key name
 * setter Setter callback
 */
internal func _setFromJsonStr(json: HashMap<String, Any>, key: String, setter: (String) -> Unit): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) { case s: String => setter(s); case _ => () }
        case None => ()
    }
}

/**
 * @brief[zh-cn] 从JSON中设置浮点数字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * setter 设置回调
 *
 * @brief[en] Set a float field from JSON
 * @param[en] json JSON data
 * key Field key name
 * setter Setter callback
 */
internal func _setFromJsonFloat(json: HashMap<String, Any>, key: String, setter: (Float64) -> Unit): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) { case f: Float64 => setter(f); case i: Int64 => setter(Float64(i)); case _ => () }
        case None => ()
    }
}

/**
 * @brief[zh-cn] 从JSON中设置整数字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * setter 设置回调
 *
 * @brief[en] Set an integer field from JSON
 * @param[en] json JSON data
 * key Field key name
 * setter Setter callback
 */
internal func _setFromJsonInt(json: HashMap<String, Any>, key: String, setter: (Int64) -> Unit): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) { case i: Int64 => setter(i); case f: Float64 => setter(Int64(f)); case _ => () }
        case None => ()
    }
}

/**
 * @brief[zh-cn] 从JSON中设置布尔字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * setter 设置回调
 *
 * @brief[en] Set a boolean field from JSON
 * @param[en] json JSON data
 * key Field key name
 * setter Setter callback
 */
internal func _setFromJsonBool(json: HashMap<String, Any>, key: String, setter: (Bool) -> Unit): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) { case b: Bool => setter(b); case _ => () }
        case None => ()
    }
}

/**
 * @brief[zh-cn] 从JSON中设置颜色字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * color 目标颜色对象
 *
 * @brief[en] Set a color field from JSON
 * @param[en] json JSON data
 * key Field key name
 * color Target color object
 */
internal func _setFromJsonColor(json: HashMap<String, Any>, key: String, color: Color): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) { case i: Int64 => color.setHex(UInt32(i)); case _ => () }
        case None => ()
    }
}

/**
 * @brief[zh-cn] 从JSON中设置纹理字段
 * @param[zh-cn] json JSON数据
 * key 字段键名
 * textures 纹理映射
 * setter 设置回调
 *
 * @brief[en] Set a texture field from JSON
 * @param[en] json JSON data
 * key Field key name
 * textures Texture mapping
 * setter Setter callback
 */
internal func _setFromJsonTexture(json: HashMap<String, Any>, key: String, textures: HashMap<String, Texture>, setter: (Option<Texture>) -> Unit): Unit {
    match (json.get(key)) {
        case Some(v) => match (v) {
            case uuid: String =>
                match (textures.get(uuid)) {
                    case Some(tex) => setter(Some(tex))
                    case None => setter(None)
                }
            case _ => setter(None)
        }
        case None => ()
    }
}
