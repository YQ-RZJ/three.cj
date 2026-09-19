# Class
## class UiColorPicker4
```cj
public class UiColorPicker4 <: UiWidget
```
Color picker widget (RGBA)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the color picker

Return: 

- Whether the color changed this frame

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label!: String, col!: PtrArray < Float32 >, flags!: Int32 = 0)
```
Constructs a color picker widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|col|PtrArray<Float32>|Color buffer (PtrArray<Float32> of 4 RGBA components, 0.0~1.0)|
|flags|Int32|ImGui color picker flags (default 0)|

