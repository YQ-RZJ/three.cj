# 类
## class Bgfx3DRenderTarget
```cj
public class Bgfx3DRenderTarget
```
基于 bgfx 帧缓冲的 3D 渲染目标

### func init\(Int64,Int64,Int64\)
```cj
public init(width: Int64, height: Int64, depth: Int64)
```
构造指定尺寸的 3D 渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度（像素）height 高度（像素）depth 深度（层数）|
|height|Int64||
|depth|Int64||

### var depth
```cj
public var depth: Int64
```
渲染目标深度（层数）

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

### var width
```cj
public var width: Int64
```
渲染目标宽度（像素）

