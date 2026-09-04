# 类
## class Material
```cj
public open class Material <: EventDispatcher & IMaterial & ILoadResult
```
材质抽象基类，所有具体材质类型继承本类

### func clone\(\)
```cj
public func clone(): Material
```
返回一个与本实例值相同的新材质实例

返回: 

- 克隆的材质实例

### func copy\(Material\)
```cj
public func copy(source: Material): Material
```
将给定材质实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|Material|源材质实例|

返回: 

- 本实例

### func createFromJSON\(HashMap<String,Any>,HashMap<String,Texture>\)
```cj
public static func createFromJSON(json: HashMap < String, Any >, textures: HashMap < String, Texture >): Option < Material >
```
从JSON反序列化构造材质

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|JSON数据textures 纹理映射|
|textures|HashMap<String,Texture>||

返回: 

- 构造的材质实例，若类型未知返回None

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放本实例分配的GPU相关资源，并派发dispose事件

### func fromJSON\(HashMap<String,Any>,HashMap<String,Texture>\)
```cj
public open func fromJSON(json: HashMap < String, Any >, textures: HashMap < String, Texture >): Unit
```
从JSON反序列化设置材质属性

参数: 

|名称|类型|描述|
|---|---|---|
|json|HashMap<String,Any>|JSON数据textures 纹理映射|
|textures|HashMap<String,Texture>||

### func init\(\)
```cj
public init()
```
构造一个新的材质

### func setValues\(HashMap<String,Any>\)
```cj
public func setValues(values: HashMap < String, Any >): Unit
```
用HashMap中的值批量设置本材质的字段

参数: 

|名称|类型|描述|
|---|---|---|
|values|HashMap<String,Any>|包含字段名和值的HashMap|

### prop alphaTest: Float64
```cj
public mut prop alphaTest: Float64
```
alpha测试阈值的访问属性

### var alphaToCoverage
```cj
public var alphaToCoverage: Bool
```
是否启用alpha-to-coverage，默认false

### var blendDst
```cj
public var blendDst: Int64
```
目标颜色混合因子，默认OneMinusSrcAlphaFactor

### var blendEquation
```cj
public var blendEquation: Int64
```
混合方程，默认AddEquation

### var blendSrc
```cj
public var blendSrc: Int64
```
源颜色混合因子，默认SrcAlphaFactor

### var blending
```cj
public var blending: Int64
```
混合模式，默认NormalBlending

### var clipIntersection
```cj
public var clipIntersection: Bool
```
是否使用裁剪交叉模式

### var clipShadows
```cj
public var clipShadows: Bool
```
是否裁剪阴影

### var clippingPlanes
```cj
public var clippingPlanes: Option < ArrayList < Plane >>
```
裁剪平面数组

### var colorWrite
```cj
public var colorWrite: Bool
```
是否写入颜色通道，默认true

### var color
```cj
public var color: Color
```
材质主色，默认0xffffff

### var customProgramCacheKey
```cj
public var customProgramCacheKey: Option <() -> String >
```
自定义程序缓存键回调函数

### var depthFunc
```cj
public var depthFunc: Int64
```
深度比较函数，默认LessEqualDepth

### var depthTest
```cj
public var depthTest: Bool
```
是否开启深度测试，默认true

### var depthWrite
```cj
public var depthWrite: Bool
```
是否写入深度缓冲，默认true

### var dithering
```cj
public var dithering: Bool
```
是否启用抖动，默认false

### var envMapIntensity
```cj
public var envMapIntensity: Float64
```
环境贴图强度，默认1

### var envMapRotation
```cj
public var envMapRotation: Option < Euler >
```
环境贴图旋转

### var envMap
```cj
public var envMap: Option < Texture >
```
环境贴图

### var flatShading
```cj
public var flatShading: Bool
```
是否使用flat shading，默认false

### var fog
```cj
public var fog: Bool
```
是否启用雾效，默认true

### var forceSinglePass
```cj
public var forceSinglePass: Bool
```
是否强制单pass渲染，默认false

### var kind
```cj
public var kind: String
```
类型标签

### var name
```cj
public var name: String
```
用户可命名标签

### var onBeforeCompile
```cj
public var onBeforeCompile: Option <(shaderobject: IShaderProgram, renderer: IRenderer) -> Unit >
```
编译前回调函数

### var onBeforeRender
```cj
public var onBeforeRender: Option <(renderer: IRenderer, scene: IScene, camera: Camera, geometry: BufferGeometry, object: Object3D, group: IGroup) -> Unit >
```
渲染前回调函数

### var opacity
```cj
public var opacity: Float64
```
不透明度（0.0~1.0），默认1.0

### var polygonOffsetFactor
```cj
public var polygonOffsetFactor: Float64
```
多边形偏移因子，默认0

### var polygonOffsetUnits
```cj
public var polygonOffsetUnits: Float64
```
多边形偏移单位，默认0

### var polygonOffset
```cj
public var polygonOffset: Bool
```
是否启用多边形偏移，默认false

### var premultipliedAlpha
```cj
public var premultipliedAlpha: Bool
```
是否已预乘alpha，默认false

### var shadowSide
```cj
public var shadowSide: Option < Int64 >
```
阴影面，None表示与side一致

### var side
```cj
public var side: Int64
```
渲染面（FrontSide/BackSide/DoubleSide），默认FrontSide

### var stencilFail
```cj
public var stencilFail: Int64
```
模板失败操作，默认KeepStencilOp

### var stencilFuncMask
```cj
public var stencilFuncMask: Int64
```
模板比较掩码，默认0xFF

### var stencilFunc
```cj
public var stencilFunc: Int64
```
模板比较函数，默认AlwaysStencilFunc

### var stencilRef
```cj
public var stencilRef: Int64
```
模板参考值，默认0

### var stencilWriteMask
```cj
public var stencilWriteMask: Int64
```
模板写入掩码，默认0xFF

### var stencilWrite
```cj
public var stencilWrite: Bool
```
是否启用模板写入，默认false

### var stencilZFail
```cj
public var stencilZFail: Int64
```
模板深度测试失败操作，默认KeepStencilOp

### var stencilZPass
```cj
public var stencilZPass: Int64
```
模板深度测试通过操作，默认KeepStencilOp

### var toneMapped
```cj
public var toneMapped: Bool
```
是否应用色调映射，默认true

### var transparent
```cj
public var transparent: Bool
```
是否透明，默认false

### var userData
```cj
public var userData: HashMap < String, Any >
```
用户自定义元数据

### var uuid
```cj
public var uuid: String
```
唯一标识

### var version
```cj
public var version: Int64
```
渲染器内部版本号，每次字段变化时递增

### var vertexColors
```cj
public var vertexColors: Bool
```
是否启用顶点颜色，默认false

### var visible
```cj
public var visible: Bool
```
是否可见，默认true

### var wireframe
```cj
public var wireframe: Bool
```
是否以线框模式渲染，默认false

