# Class
## class UiInputInt
```cj
public class UiInputInt <: UiWidget
```
Integer input widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the integer input box

Return: 

- Whether the value changed this frame

### func getValue\(\)
```cj
public func getValue(): Int32
```
Gets the current value

Return: 

- The current input value

### func init\(String,PtrArray<Int32>,Int32,Int32\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, step!: Int32 = 1, stepFast!: Int32 = 100)
```
Constructs an integer input widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Input label text|
|value|PtrArray<Int32>|Value buffer (single-element PtrArray<Int32>, updated on input)|
|step|Int32|Step value (default 1)|
|stepFast|Int32|Fast step while holding Shift (default 100)|

