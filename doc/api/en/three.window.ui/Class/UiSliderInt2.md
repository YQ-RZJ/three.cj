# Class
## class UiSliderInt2
```cj
public class UiSliderInt2 <: UiWidget
```
2-channel integer slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the 2-channel integer slider

Return: 

- Whether the value changed this frame

### func init\(String,PtrArray<Int32>,Int32,Int32,String,Int32\)
```cj
public init(label: String, v: PtrArray < Int32 >, min: Int32, max: Int32, format!: String = "%d", flags!: Int32 = 0)
```
Constructs a 2-channel integer slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|v|PtrArray<Int32>|Value buffer (PtrArray<Int32> of 2 components)|
|min|Int32|Minimum value|
|max|Int32|Maximum value|
|format|String|Number display format (default "%d")|
|flags|Int32|ImGui slider flags (default 0)|

