# Class
## class UiColorButton
```cj
public class UiColorButton <: UiWidget
```
Color button widget (shows a color swatch, clickable)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the color button

Return: 

- Whether it was clicked this frame

### func init\(String,Float32,Float32,Float32,Float32,Int32,Float32,Float32\)
```cj
public init(desc: String, r: Float32, g: Float32, b: Float32, a!: Float32 = 1.0f32, flags!: Int32 = 0, w!: Float32 = 0.0f32, h!: Float32 = 0.0f32)
```
Constructs a color button widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|desc|String|Button description text (used for ID naming)|
|r|Float32|Red component (0.0~1.0)|
|g|Float32|Green component (0.0~1.0)|
|b|Float32|Blue component (0.0~1.0)|
|a|Float32|Alpha component (default 1.0)|
|flags|Int32|ImGui color button flags (default 0)|
|w|Float32|Button width (default 0.0 means auto)|
|h|Float32|Button height (default 0.0 means auto)|

