# Class
## class UiColorEdit3
```cj
public class UiColorEdit3 <: UiWidget
```
3-channel color editor widget (RGB)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel color editor

Return: 

- Whether the color changed this frame

### func init\(String,PtrArray<Float32>,Int32\)
```cj
public init(label: String, col: PtrArray < Float32 >, flags!: Int32 = 0)
```
Constructs a 3-channel color editor widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|col|PtrArray<Float32>|Color buffer (PtrArray<Float32> of 3 RGB components, 0.0~1.0)|
|flags|Int32|ImGui color edit flags (default 0)|

