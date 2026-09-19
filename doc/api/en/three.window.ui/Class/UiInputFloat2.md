# Class
## class UiInputFloat2
```cj
public class UiInputFloat2 <: UiWidget
```
2-channel float input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 2-channel float input

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Float32>,String,Int32\)
```cj
public init(label: String, v: PtrArray < Float32 >, format!: String = "%.3f", flags!: Int32 = 0)
```
Constructs a 2-channel float input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text|
|v|PtrArray<Float32>|Value buffer (PtrArray<Float32> of 2 components)|
|format|String|Number display format (default "%.3f")|
|flags|Int32|ImGui input flags (default 0)|

