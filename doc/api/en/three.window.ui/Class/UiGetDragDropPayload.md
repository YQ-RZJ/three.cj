# Class
## class UiGetDragDropPayload
```cj
public class UiGetDragDropPayload <: UiWidget
```
Get drag payload widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Gets the current drag payload

Return: 

- Whether a valid payload exists

### func init\(String\)
```cj
public init(`type`!: String = "")
```
Constructs a drag payload getter

Parameter: 

|Name|Type|Describe|
|---|---|---|
|`type`|String|Payload type identifier (default empty string)|

