# Class
## class UiSliderFloat3
```cj
public class UiSliderFloat3 <: UiWidget
```
3-channel float slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel float slider

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Float32>,Float32,Float32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, min: Float32, max: Float32, format!: String = "%.3f", flags!: Int32 = 0)
```
Constructs a 3-channel float slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|v|PtrArray<Float32>|Value buffer (PtrArray<Float32> of 3 components)|
|min|Float32|Minimum value|
|max|Float32|Maximum value|
|format|String|Number display format (default "%.3f")|
|flags|Int32|ImGui slider flags (default 0)|

