# Class
## class UiTooltip
```cj
public class UiTooltip <: UiWidget
```
Tooltip widget (shown on hover)

### func draw\(\)
```cj
public override func draw(): Bool
```
Shows the tooltip content on hover

Return: 

- Always false (no interaction)

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a tooltip widget

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Content closure shown on hover|

