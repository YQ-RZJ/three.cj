# Class
## class UiColorPicker3
```cj
public class UiColorPicker3 <: UiWidget
```
3-channel color picker widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel color picker

Return: 

- Whether the color value changed this frame

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label!: String, col!: PtrArray < Float32 >, flags!: Int32 = 0)
```
Constructs a 3-channel color picker widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Picker label text|
|col|PtrArray<Float32>|Color value buffer (PtrArray<Float32> of RGB 3 components, range 0.0~1.0)|
|flags|Int32|ImGui color picker flags (default 0)|

