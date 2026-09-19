# Class
## class UiGroup
```cj
public class UiGroup <: UiWidget
```
Group container widget

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the group (content wrapped in BeginGroup/EndGroup)

Return: 

- Widget interaction result; always false for this widget

### func init\(\(\)\->Unit\)
```cj
public init(content!:() -> Unit)
```
Constructs a group container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|content|()->Unit|Render callback for widgets inside the group|

