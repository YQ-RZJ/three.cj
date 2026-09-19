# Class
## class UiDisabledBlock
```cj
public class UiDisabledBlock <: UiWidget
```
Disabled state container

### func draw\(\)
```cj
public override func draw(): Bool
```
Renders the disabled container (content wrapped in BeginDisabled/EndDisabled)

Return: 

- Widget interaction result; always false for this widget

### func init\(Bool,\(\)\->Unit\)
```cj
public init(disabled!: Bool = true, content!:() -> Unit)
```
Constructs a disabled-state container

Parameter: 

|Name|Type|Describe|
|---|---|---|
|disabled|Bool|Whether the disabled state is enabled, defaults to true|
|content|()->Unit|Render callback for widgets inside the container|

