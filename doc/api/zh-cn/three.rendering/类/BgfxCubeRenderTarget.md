# 类
## class BgfxCubeRenderTarget
```cj
public class BgfxCubeRenderTarget
```
基于 bgfx 帧缓冲的立方体渲染目标

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
构造指定尺寸的立方体渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度（像素，每面边长）height 高度（像素，每面边长）|
|height|Int64||

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

