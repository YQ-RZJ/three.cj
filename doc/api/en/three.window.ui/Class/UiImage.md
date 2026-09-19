# Class
## class UiImage
```cj
public class UiImage <: UiWidget
```
Image display widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the image

Return: 

- Always false (no interaction)

### func init\(UInt64,Vector2\)
```cj
public init(texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0))
```
Constructs an image display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|texId|UInt64|Texture ID (bgfx texture handle value)|
|size|Vector2|Display size (default 64x64)|

