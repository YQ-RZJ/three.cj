# Class
## class UiValueUint
```cj
public class UiValueUint <: UiWidget
```
Unsigned integer value display widget (Value)

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the unsigned integer value display

Return: 

- Always false (this widget has no interaction state)

### func init\(String,UInt32\)
```cj
public init(prefix!: String, v!: UInt32)
```
Constructs an unsigned integer value display widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|prefix|String|Display prefix text|
|v|UInt32|Unsigned integer value|

