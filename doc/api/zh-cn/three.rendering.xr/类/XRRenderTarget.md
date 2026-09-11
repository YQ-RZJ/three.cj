# 类
## class XRRenderTarget
```cj
public class XRRenderTarget
```
XR 渲染目标

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
构造 XR 渲染目标

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度height 高度|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(width: Int64, height: Int64): Unit
```
设置渲染目标尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度height 高度|
|height|Int64||

### var colorTexture
```cj
public var colorTexture: Texture
```
颜色纹理

### var depthTexture
```cj
public var depthTexture: DepthTexture
```
深度纹理

### var height
```cj
public var height: Int64
```
高度

### var width
```cj
public var width: Int64
```
宽度

