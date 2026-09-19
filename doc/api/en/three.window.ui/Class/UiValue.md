# Class
## class UiValue
```cj
public class UiValue <: UiWidget
```
Value display widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the value display

Return: 

- Always false (no interaction)

### func getValue\(\)
```cj
public func getValue(): Float32
```
Gets the currently displayed value

Return: 

- The currently displayed value

### func init\(String,Float32,String\)
```cj
public init(prefix!: String, value!: Float32, format!: String = "")
```
Constructs a value display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|prefix|String|Value prefix label|
|value|Float32|The number to display|
|format|String|Number display format (default empty means ImGui default format)|

### func setValue\(Float32\)
```cj
public func setValue(v: Float32): Unit
```
Sets the value to display

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Float32|The value to display|

