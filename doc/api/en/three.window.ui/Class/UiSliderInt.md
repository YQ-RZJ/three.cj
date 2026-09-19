# Class
## class UiSliderInt
```cj
public class UiSliderInt <: UiWidget
```
Integer slider widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the slider and syncs the value

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Int32
```
Gets the current value

Return: 

- The current slider value

### func init\(String,PtrArray<Int32>,Int32,Int32,String\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, min!: Int32 = 0, max!: Int32 = 100, format!: String = "%d")
```
Constructs an integer slider widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Slider label text|
|value|PtrArray<Int32>|Value buffer (single-element PtrArray<Int32>, updated on drag)|
|min|Int32|Minimum value (default 0)|
|max|Int32|Maximum value (default 100)|
|format|String|Number display format (default "%d")|

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
Sets the current value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|The value to set|

