# 类
## class LightShadow
```cj
public open class LightShadow
```
光源阴影配置的抽象基类，各具体光源阴影类型继承本类

### func calculateCascadeSplits\(Int64,Float64,Float64,Float64\)
```cj
public func calculateCascadeSplits(numSplits: Int64, nearClip: Float64, farClip: Float64, splitLambda: Float64): ArrayList < Float64 >
```
计算级联阴影贴图（CSM）的切分距离

参数: 

|名称|类型|描述|
|---|---|---|
|numSplits|Int64|级联数量（默认CSM_CASCADE_COUNT=4）nearClip 主相机近裁剪面farClip 主相机远裁剪面splitLambda 切分系数（0=均匀，1=对数，默认0.5）|
|nearClip|Float64||
|farClip|Float64||
|splitLambda|Float64||

返回: 

- 切分距离数组（长度=numSplits+1，索引0=nearClip，索引numSplits=farClip）

### func clone\(\)
```cj
public func clone(): LightShadow
```
返回一个与本实例值相同的新光源阴影实例

返回: 

- 克隆的光源阴影实例

### func copy\(LightShadow\)
```cj
public open func copy(source: LightShadow): LightShadow
```
将给定光源阴影实例的值复制到本实例

参数: 

|名称|类型|描述|
|---|---|---|
|source|LightShadow|源光源阴影实例|

返回: 

- 本实例

### func dispose\(\)
```cj
public func dispose(): Unit
```
释放本实例分配的GPU相关资源，当实例不再使用时应调用

### func getFrameExtents\(\)
```cj
public func getFrameExtents(): Vector2
```
返回帧范围

返回: 

- 帧范围向量

### func getFrustum\(\)
```cj
public func getFrustum(): Frustum
```
获取阴影相机的视锥体，渲染器内部用于裁剪物体

返回: 

- 视锥体

### func getViewportCount\(\)
```cj
public func getViewportCount(): Int64
```
获取本阴影需要渲染的视口数量

返回: 

- 视口数量

### func getViewport\(Int64\)
```cj
public func getViewport(viewportIndex: Int64): Vector4
```
返回指定索引的视口定义

参数: 

|名称|类型|描述|
|---|---|---|
|viewportIndex|Int64|视口索引|

返回: 

- 视口定义向量

### func initCascadeCameras\(\)
```cj
public func initCascadeCameras(): Unit
```
初始化CSM级联阴影相机数组，仅当smType==Cascade时调用

### func init\(Camera\)
```cj
public init(camera: Camera)
```
构造一个新的光源阴影配置

参数: 

|名称|类型|描述|
|---|---|---|
|camera|Camera|光源观察世界的视角相机|

### func init\(\)
```cj
public init()
```
无参构造，供fastjson反序列化使用

### func updateCascadeMatrices\(Light,Camera,Int64\)
```cj
public open func updateCascadeMatrices(light: Light, mainCamera: Camera, cascadeIndex: Int64): Unit
```
更新CSM级联阴影相机参数

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|正在渲染阴影的DirectionalLightmainCamera 主相机，提供near/far用于切分cascadeIndex 当前级联索引（0..cascadeCount-1）|
|mainCamera|Camera||
|cascadeIndex|Int64||

### func updateMatrices\(Light\)
```cj
public open func updateMatrices(light: Light): Unit
```
更新相机与阴影矩阵，渲染器内部调用

参数: 

|名称|类型|描述|
|---|---|---|
|light|Light|正在渲染阴影的光源|

### var autoUpdate
```cj
public var autoUpdate: Bool
```
是否自动更新光源阴影，无需动态光照/阴影时可设为false

### var bias
```cj
public var bias: Float64
```
阴影贴图偏置，默认0，微小调整可减少阴影瑕疵

### var blurSamples
```cj
public var blurSamples: Int64
```
模糊VSM阴影贴图时的采样数量，默认8

### var camera
```cj
public var camera: Camera
```
光源观察世界的视角相机

### var cascadeCameras
```cj
public var cascadeCameras: ArrayList < OrthographicCamera >
```
CSM各级阴影相机数组，长度=cascadeCount，每级独立OrthographicCamera

### var cascadeCount
```cj
public var cascadeCount: Int64
```
CSM级联数量，仅当smType==Cascade时有效，默认4

### var cascadeLambda
```cj
public var cascadeLambda: Float64
```
CSM级联切分系数（lambda），0=均匀切分，1=对数切分，默认0.5

### var cascadeSplits
```cj
public var cascadeSplits: ArrayList < Float64 >
```
CSM各级near/far距离数组，长度=cascadeCount+1，由updateMatrices计算

### var depthImpl
```cj
public var depthImpl: Int64
```
深度计算方式（InvZ/Linear）

### var intensity
```cj
public var intensity: Float64
```
阴影强度，默认1，有效范围[0, 1]

### var kind
```cj
public var kind: String
```
类型标签，与JS侧的type字段对齐

### var mapPass
```cj
public var mapPass: Option < RenderTarget >
```
由内部相机生成的分布贴图，基于深度分布计算遮挡

### var mapSize
```cj
public var mapSize: Vector2
```
阴影贴图宽高（必须是2的幂），值越大质量越好但更耗时

### var mapType
```cj
public var mapType: Int64
```
阴影纹理类型，默认UnsignedByteType

### var map
```cj
public var map: Option < RenderTarget >
```
由内部相机生成的深度贴图，超过某像素深度的位置视为在阴影中

### var matrix
```cj
public var matrix: Matrix4
```
模型空间到阴影相机空间的矩阵，用于在阴影贴图中查询位置与深度

### var needsUpdate
```cj
public var needsUpdate: Bool
```
设为true时，下次render调用会更新阴影贴图

### var normalBias
```cj
public var normalBias: Float64
```
沿物体法线方向对采样位置的偏置量，默认0

### var packDepth
```cj
public var packDepth: Int64
```
深度打包方式（RGBA/VSM）

### var radius
```cj
public var radius: Float64
```
阴影边缘模糊半径，大于1时模糊边缘，过大值会导致条带瑕疵

### var smType
```cj
public var smType: Int64
```
阴影贴图分布类型（Single/Omni/Cascade）

