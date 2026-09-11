# Class
## class CameraView
```cj
public class CameraView
```
Camera multi-viewport clipping configuration

### func clone\(\)
```cj
public func clone(): CameraView
```
Deep copy

Return: 

- New CameraView instance

### func init\(\)
```cj
public init()
```
No-arg constructor (for fastjson deserialization)

### func init\(Bool,Float64,Float64,Float64,Float64,Float64,Float64\)
```cj
public init(enabled: Bool, fullWidth: Float64, fullHeight: Float64, offsetX: Float64, offsetY: Float64, width: Float64, height: Float64)
```
Construct camera view configuration

Parameter: 

|Name|Type|Describe|
|---|---|---|
|enabled|Bool|Whether enabledfullWidth Full viewport widthfullHeight Full viewport heightoffsetX Viewport offset XoffsetY Viewport offset Ywidth Viewport widthheight Viewport height|
|fullWidth|Float64||
|fullHeight|Float64||
|offsetX|Float64||
|offsetY|Float64||
|width|Float64||
|height|Float64||

### func toHashMap\(\)
```cj
public func toHashMap(): HashMap < String, Any >
```
Convert to HashMap (for handwritten toJSON compatibility layer to output three.js view object structure)

Return: 

- View configuration HashMap

### var enabled
```cj
public var enabled: Bool
```
Whether viewport clipping is enabled

### var fullHeight
```cj
public var fullHeight: Float64
```
Full viewport height (pixels)

### var fullWidth
```cj
public var fullWidth: Float64
```
Full viewport width (pixels)

### var height
```cj
public var height: Float64
```
Viewport height (pixels)

### var offsetX
```cj
public var offsetX: Float64
```
Viewport offset X (pixels)

### var offsetY
```cj
public var offsetY: Float64
```
Viewport offset Y (pixels)

### var width
```cj
public var width: Float64
```
Viewport width (pixels)

