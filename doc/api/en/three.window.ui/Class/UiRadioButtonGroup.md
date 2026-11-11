# Class
## class UiRadioButtonGroup
```cj
public class UiRadioButtonGroup <: UiWidget
```
Radio button group widget (shared Int value form)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the radio group button and syncs the selected value

Return: 

- Whether the selected value changed this frame (i.e. this button was clicked)

### func init\(String,PtrArray<Int32>,Int32\)
```cj
public init(label!: String, value!: PtrArray < Int32 >, buttonValue!: Int32)
```
Constructs a radio group button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Button label|
|value|PtrArray<Int32>|Shared selected value (single-element PtrArray<Int32>)|
|buttonValue|Int32|The value this button represents|

