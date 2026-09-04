# 类
## class BgfxRenderTarget
```cj
public class BgfxRenderTarget <: IRenderTarget
```
基于 bgfx 帧缓冲的标准 2D 渲染目标

### func dispose\(\)
```cj
public func dispose(): Unit
```
销毁帧缓冲，释放 GPU 资源

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
构造指定尺寸的 2D 渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度（像素）height 高度（像素）|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
重新设置渲染目标尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|新宽度（像素）height 新高度（像素）|
|height|Int64||

### var depth
```cj
public var depth: Int64
```
渲染目标深度（层数，3D 目标用）

### var frameBuffer
```cj
public var frameBuffer: FrameBufferHandle
```
bgfx 帧缓冲句柄

### var height
```cj
public var height: Int64
```
渲染目标高度（像素）

### var kind
```cj
public var kind: String
```
渲染目标类型标识

### var texture
```cj
public var texture: Texture
```
关联的颜色纹理

### var width
```cj
public var width: Int64
```
渲染目标宽度（像素）

