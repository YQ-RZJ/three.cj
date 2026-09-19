# Class
## class UiCheckbox
```cj
public class UiCheckbox <: UiWidget
```
Checkbox widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the checkbox and syncs the check state

Return: 

- Whether the check state changed this frame

### func getValue\(\)
```cj
public func getValue(): Int32
```
Gets the current value

Return: 

- 0=unchecked, 1=checked

### func init\(String,PtrArray<Int32>\)
```cj
public init(label!: String, value!: PtrArray < Int32 >)
```
Constructs a checkbox widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Checkbox label text|
|value|PtrArray<Int32>|State buffer (single-element PtrArray<Int32>, 0=unchecked 1=checked)|

### func setValue\(Int32\)
```cj
public func setValue(v: Int32): Unit
```
Sets the value

Parameter: 

|Name|Type|Describe|
|---|---|---|
|v|Int32|0=unchecked, 1=checked|

