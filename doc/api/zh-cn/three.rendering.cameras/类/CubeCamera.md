# 类
## class CubeCamera
```cj
public class CubeCamera <: Object3D
```
立方体相机

### func init\(\)
```cj
public init()
```
构造一个新的立方体相机

### func init\(Float64,Float64,?IRenderTarget\)
```cj
public init(near: Float64, far: Float64, renderTarget:?IRenderTarget)
```


参数: 

|名称|类型|描述|
|---|---|---|
|near|Float64||
|far|Float64||
|renderTarget|?IRenderTarget||

### func updateCoordinateSystem\(\)
```cj
public func updateCoordinateSystem(): Unit
```
按当前坐标系更新 6 子相机朝向

### func update\(IRenderer,IScene\)
```cj
public func update(renderer: IRenderer, scene: IScene): Unit
```
渲染场景到立方体贴图

参数: 

|名称|类型|描述|
|---|---|---|
|renderer|IRenderer|渲染器实例（需实现 setRenderTarget/render/getRenderTarget 接口）scene 待捕获的场景|
|scene|IScene||

### var activeMipmapLevel
```cj
public var activeMipmapLevel: Int64
```
生成贴图后激活的 mipmap 层级，0 = 全层

### var coordinateSystem
```cj
public var coordinateSystem: Option < Int64 >
```
当前坐标系（None 表示未初始化，与 JS side 默认 null 对齐）

### var renderTarget
```cj
public var renderTarget:?IRenderTarget
```
立方体贴图渲染目标（CubeRenderTarget），6 面颜色 + optional mipmap

