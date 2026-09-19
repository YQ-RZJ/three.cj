# Class
## class UiDragFloat3
```cj
public class UiDragFloat3 <: UiWidget
```
3-channel float drag widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel float drag widget

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Float32>,Float32,Float32,Float32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, speed!: Float32 = 1.0f32, min!: Float32 = 0.0f32, max!: Float32 = 0.0f32, format!: String = "%.3f", flags!: Int32 = 0)
```
Constructs a 3-channel float drag widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|v|PtrArray<Float32>|Value buffer (PtrArray<Float32> of 3 components)|
|speed|Float32|Drag speed (default 1.0)|
|min|Float32|Minimum value (default 0.0)|
|max|Float32|Maximum value (default 0.0 means unbounded)|
|format|String|Number display format (default "%.3f")|
|flags|Int32|ImGui drag flags (default 0)|

