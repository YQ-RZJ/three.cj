# Class
## class CubeRenderTarget
```cj
public open class CubeRenderTarget
```
Cube render target, used for cube map rendering

### func init\(Int64,Int64\)
```cj
public init(width: Int64, height: Int64)
```
Constructs a cube render target with specified dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|width|Int64|Widthheight Height|
|height|Int64||

### func setSize\(Int64,Int64\)
```cj
public func setSize(w: Int64, h: Int64): Unit
```
Sets the render target dimensions

Parameter: 

|Name|Type|Describe|
|---|---|---|
|w|Int64|New widthh New height|
|h|Int64||

### var height
```cj
public var height: Int64
```
Render target height

### var texture
```cj
public var texture: Texture
```
Associated texture

### var width
```cj
public var width: Int64
```
Render target width

