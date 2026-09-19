# Class
## class UiDragInt3
```cj
public class UiDragInt3 <: UiWidget
```
3-channel integer drag widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel integer drag widget

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Int32>,Float32,Int32,Int32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, speed!: Float32 = 1.0f32, min!: Int32 = 0, max!: Int32 = 0, format!: String = "%d", flags!: Int32 = 0)
```
Constructs a 3-channel integer drag widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|v|PtrArray<Int32>|Value buffer (PtrArray<Int32> of 3 components)|
|speed|Float32|Drag speed (default 1.0)|
|min|Int32|Minimum value (default 0)|
|max|Int32|Maximum value (default 0 means unbounded)|
|format|String|Number display format (default "%d")|
|flags|Int32|ImGui drag flags (default 0)|

