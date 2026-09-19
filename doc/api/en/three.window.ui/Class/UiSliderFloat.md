# Class
## class UiSliderFloat
```cj
public class UiSliderFloat <: UiWidget
```
Float slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the slider and syncs the value

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Float32
```
Gets the current value

Return: 

- The current slider value

### func init\(String,PtrArray<Float32>,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, min!: Float32 = 0.0, max!: Float32 = 1.0, format!: String = "%.3f")
```
Constructs a float slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|value|PtrArray<Float32>|Value buffer (single-element PtrArray<Float32>, updated on drag)|
|min|Float32|Minimum value (default 0.0)|
|max|Float32|Maximum value (default 1.0)|
|format|String|Number display format (default "%.3f")|

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```
Sets the current value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|The value to set|

