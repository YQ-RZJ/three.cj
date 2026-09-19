# Class
## class UiInputInt3
```cj
public class UiInputInt3 <: UiWidget
```
3-channel integer input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 3-channel integer input

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, flags!: Int32 = 0)
```
Constructs a 3-channel integer input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text|
|v|PtrArray<Int32>|Value buffer (PtrArray<Int32> of 3 components)|
|flags|Int32|ImGui input flags (default 0)|

