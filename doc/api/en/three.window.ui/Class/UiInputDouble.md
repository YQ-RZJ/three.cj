# Class
## class UiInputDouble
```cj
public class UiInputDouble <: UiWidget
```
Double precision input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the double-precision input box

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Float64
```
Gets the current value

Return: 

- The current input value

### func init\(String,PtrArray<Float64>,Float64,Float64,String\)
```cj
public init(label!: String, value!: PtrArray < Float64 >, step!: Float64 = 0.1, stepFast!: Float64 = 1.0, format!: String = "%.6f")
```
Constructs a double-precision input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text|
|value|PtrArray<Float64>|Value buffer (single-element PtrArray<Float64>, updated on input)|
|step|Float64|Step value (default 0.1)|
|stepFast|Float64|Fast step while holding Shift (default 1.0)|
|format|String|Number display format (default "%.6f")|

