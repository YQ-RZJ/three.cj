# Class
## class CubeCamera
```cj
public class CubeCamera <: Object3D
```
Cube camera

### func init\(\)
```cj
public init()
```
Construct a new cube camera

### func init\(Float64,Float64,?IRenderTarget\)
```cj
public init(near: Float64, far: Float64, renderTarget:?IRenderTarget)
```


Parameter: 

|Name|Type|Describe|
|---|---|---|
|near|Float64||
|far|Float64||
|renderTarget|?IRenderTarget||

### func updateCoordinateSystem\(\)
```cj
public func updateCoordinateSystem(): Unit
```
Update 6 sub-camera orientations based on current coordinate system

### func update\(IRenderer,IScene\)
```cj
public func update(renderer: IRenderer, scene: IScene): Unit
```
Render scene to cube map

Parameter: 

|Name|Type|Describe|
|---|---|---|
|renderer|IRenderer|Renderer instance (must implement setRenderTarget/render/getRenderTarget interfaces)scene Scene to capture|
|scene|IScene||

### var activeMipmapLevel
```cj
public var activeMipmapLevel: Int64
```
Active mipmap level after generating texture, 0 = all levels

### var coordinateSystem
```cj
public var coordinateSystem: Option < Int64 >
```
Current coordinate system (None means uninitialized, aligned with JS side default null)

### var renderTarget
```cj
public var renderTarget:?IRenderTarget
```
Cube map render target (CubeRenderTarget), 6-face color + optional mipmap

