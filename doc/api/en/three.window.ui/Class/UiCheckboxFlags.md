# Class
## class UiCheckboxFlags
```cj
public class UiCheckboxFlags <: UiWidget
```
Checkbox flags widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the checkbox flags widget

Return: 

- Whether the flags changed this frame

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label!: String, flags!: PtrArray < Int32 >, flagsValue!: Int32)
```
Constructs a checkbox flags widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Label text|
|flags|PtrArray<Int32>|Shared flags value (single-element PtrArray<Int32>)|
|flagsValue|Int32|The bit(s) this checkbox controls|

