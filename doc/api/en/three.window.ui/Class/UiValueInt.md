# Class
## class UiValueInt
```cj
public class UiValueInt <: UiWidget
```
Integer value display widget (Value)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the integer value display

Return: 

- Always false (this widget has no interaction state)

### func init\(String,Int32\)
```cj
public init(prefix!: String, v!: Int32)
```
Constructs an integer value display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|prefix|String|Display prefix text|
|v|Int32|Integer value|

