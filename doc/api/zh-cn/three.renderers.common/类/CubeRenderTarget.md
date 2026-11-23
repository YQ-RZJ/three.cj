# 类
## class CubeRenderTarget
```cj
public open class CubeRenderTarget
```
立方体渲染目标，用于立方体贴图渲染

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
构造立方体渲染目标，指定尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|width|Int64|宽度height 高度|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(w: Int64, h: Int64): Unit
```
设置渲染目标尺寸

参数: 

|名称|类型|描述|
|---|---|---|
|w|Int64|新宽度h 新高度|
|h|Int64||

### var height
```cj
public var height: Int64
```
渲染目标高度

### var texture
```cj
public var texture: Texture
```
关联的纹理

### var width
```cj
public var width: Int64
```
渲染目标宽度

