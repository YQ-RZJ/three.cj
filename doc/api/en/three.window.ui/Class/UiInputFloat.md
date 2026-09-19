# Class
## class UiInputFloat
```cj
public class UiInputFloat <: UiWidget
```
Float input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the float input box

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Float32
```
Gets the current value

Return: 

- The current input value

### func init\(String,PtrArray<Float32>,Float32,Float32,String\)
```cj
public init(label!: String, value!: PtrArray < Float32 >, step!: Float32 = 0.1, stepFast!: Float32 = 1.0, format!: String = "%.3f")
```
Constructs a float input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text|
|value|PtrArray<Float32>|Value buffer (single-element PtrArray<Float32>, updated on input)|
|step|Float32|Step value (default 0.1)|
|stepFast|Float32|Fast step while holding Shift (default 1.0)|
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

