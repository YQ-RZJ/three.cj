# Class
## class UiValueBool
```cj
public class UiValueBool <: UiWidget
```
Boolean value display widget (Value)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the boolean value display

Return: 

- Always false (this widget has no interaction state)

### func init\(String,Bool\)
```cj
public init(prefix!: String, v!: Bool)
```
Constructs a boolean value display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|prefix|String|Display prefix text|
|v|Bool|Boolean value|

