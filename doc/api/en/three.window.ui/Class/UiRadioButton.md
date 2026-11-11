# Class
## class UiRadioButton
```cj
public class UiRadioButton <: UiWidget
```
Radio button widget (boolean active form)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the radio button

Return: 

- Whether it was clicked this frame

### func init\(String,Bool\)
```cj
public init(label!: String, active!: Bool)
```
Constructs a radio button

Parameter: 

|Name|Type|Describe|
|---|---|---|
|label|String|Button label|
|active|Bool|Whether currently selected|

