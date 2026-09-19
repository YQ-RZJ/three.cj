# Class
## class UiImageButton
```cj
public class UiImageButton <: UiWidget
```
Image button widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the image button

Return: 

- Whether it was clicked this frame

### func init\(String,UInt64,Vector2\)
```cj
public init(strId!: String, texId!: UInt64, size!: Vector2 = Vector2(64.0, 64.0))
```
Constructs an image button widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|strId|String|Button string ID (used for ImGui ID naming)|
|texId|UInt64|Texture ID (bgfx texture handle value)|
|size|Vector2|Button display size (default 64x64)|

